package com.eep.bo.staff.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.eep.bo.batch.service.GoogleDriveApi;
import com.eep.bo.my.DriveConfService;
import com.eep.bo.my.GoogleLinkService;
import com.eep.mapper.BoStaffMapper;

import common.util.RrnCipher;

/**
 * 직원 서류를 구글 드라이브 '2. 인사관리' 폴더에 올리고, 글자를 읽어 인사카드 빈 칸을 채운다.
 * 폴더: 2. 인사관리 / <구분 폴더> / (yyyy.MM.dd) 성명 / 00. 입사관련서류 / 성명_서류명.확장자 — 이름은 모두 직원관리 ⚙(DriveConfService STAFF) 로 바꿀 수 있다.
 * 단계가 바뀌면 폴더를 만들고 옮긴다: 교육생 → 1. 대기자 관리 '(0000.00.00) 이름', 중도이탈 → 퇴사자 관리, 직원 등록 → 소속 구분 폴더 '(입사일) 이름', 퇴사 → 퇴사자 관리, 재입사 → 새 폴더.
 */
@Service
public class StaffDriveService {

	private static final long MAX_BYTES = 20L * 1024 * 1024;
	private static final Pattern READABLE = Pattern.compile("^(image/|application/pdf)");
	private static final java.util.Set<String> PARSEABLE = new java.util.HashSet<>(java.util.Arrays.asList("DOC_BANK", "DOC_ID", "DOC_REG", "DOC_GRAD", "DOC_MIL"));
	/** 서류 칸 -> 파일 이름에 쓰는 서류명 */
	static final Map<String, String> DOC_NAMES = new LinkedHashMap<>();
	static {
		String[][] d = { { "DOC_REG", "주민등록등본" }, { "DOC_ID", "신분증" }, { "DOC_GRAD", "졸업증명서" }, { "DOC_BANK", "급여통장" }, { "DOC_PHOTO", "증명사진" },
				{ "DOC_HI", "건강보험자격득실확인서" }, { "DOC_CONTRACT", "근로계약서" }, { "DOC_BIZ", "사업자사실증명" }, { "DOC_EI", "고용보험자격이력" },
				{ "DOC_SEC", "보안서약서" }, { "DOC_EDU", "직무교육동의서" }, { "DOC_NEP", "국민취업제도참여" }, { "DOC_PRIV", "이력비공개" },
				{ "DOC_CRIME", "범죄기록회보" }, { "DOC_MIL", "병적증명서" } };
		for (String[] x : d) DOC_NAMES.put(x[0], x[1]);
	}

	@Autowired
	private GoogleDriveApi drive;
	@Autowired
	private GoogleLinkService link;
	@Autowired
	private DriveConfService conf;
	@Autowired
	private BoStaffMapper mapper;
	@Autowired
	private BoStaffService staffService;

	// ── 연결 ──

	/** 지금 관리자의 내 연동 드라이브 상태 */
	public Map<String, Object> status() {
		String me = GoogleLinkService.currentUser();
		Map<String, Object> s = new HashMap<>();
		s.put("connected", link.linked(me, GoogleLinkService.DRIVE));
		s.put("account", link.account(me, GoogleLinkService.DRIVE));
		return s;
	}

	/** 요청한 관리자의 내 연동 드라이브. 없으면 NeedLink(→ 내 연동으로 안내). 장비·거래처·연구일지도 이것을 쓴다 */
	public String token() {
		return link.accessToken(GoogleLinkService.DRIVE);
	}

	/** 최상위 '2. 인사관리' 폴더(직원관리 ⚙, 기본은 db.properties staff.drive.root) */
	private String root() {
		String id = conf.get("STAFF", "ROOT");
		if (!hasText(id)) {
			throw new IllegalArgumentException("직원관리 ⚙ 드라이브 설정에서 최상위 폴더를 먼저 정해 주세요.");
		}
		return id;
	}

	// ── 폴더 ──

	/** 사람 폴더 ID. 저장된 것이 있으면 그대로, 없으면 구분 폴더들에서 '(입사일) 성명' 을 찾고, 그래도 없으면 만든다 */
	String personFolder(Map<String, Object> staff, String token) {
		String saved = str(staff.get("DRIVE_FOLDER_ID"));
		if (hasText(saved)) {
			return saved;
		}
		String id = findPersonFolder(staff, token);
		if (id == null) {
			String name = str(staff.get("STAFF_NM"));
			// 대기(교육생) 카드는 입사 전이라 '(0000.00.00) 이름'
			String folderName = "WAIT".equals(str(staff.get("STATUS_CD"))) ? traineeName(name) : personName(staff);
			id = drive.createFolder(folderName, groupId(groupFolderName(str(staff.get("STATUS_CD")), str(staff.get("ORG_NM"))), token), token);
		}
		saveFolder(staff.get("STAFF_SQ"), id);
		return id;
	}

	/** 사람 폴더를 찾기만 한다(저장된 것 → 구분 폴더에서 '(입사일) 성명'). 없으면 null */
	private String findPersonFolder(Map<String, Object> staff, String token) {
		String saved = str(staff.get("DRIVE_FOLDER_ID"));
		if (hasText(saved)) {
			return saved;
		}
		String name = str(staff.get("STAFF_NM")), left = conf.get("STAFF", "LEFT");
		boolean isLeft = "LEFT".equals(str(staff.get("STATUS_CD")));
		List<Map<String, Object>> groups = new ArrayList<>();
		for (Map<String, Object> g : groups(token)) {
			// 재입사한 사람이 퇴사자 관리의 예전 폴더를 다시 잡지 않게, 퇴사자 폴더는 퇴사 상태일 때만 찾는다(⚙ 에서 고른 폴더면 ID 로 비교)
			if (!(left.equals(g.get("name")) || left.equals(g.get("id"))) || isLeft) groups.add(g);
		}
		String id = null;
		if (!groups.isEmpty()) {
			StringBuilder q = new StringBuilder("mimeType = '" + GoogleDriveApi.FOLDER + "' and trashed = false and name contains '" + quoteQ(name) + "' and (");
			for (int i = 0; i < groups.size(); i++) q.append(i > 0 ? " or " : "").append("'").append(quoteQ(str(groups.get(i).get("id")))).append("' in parents");
			q.append(")");
			id = pickPersonFolder(drive.search(q.toString(), token), name, str(staff.get("JOIN_DT")));
		}
		return id;
	}

	/** 최상위 아래 '…관리' 구분 폴더들 + ⚙ 에서 직접 고른 구분 폴더(최상위 밖일 수도 있음) */
	private List<Map<String, Object>> groups(String token) {
		List<Map<String, Object>> groups = new ArrayList<>();
		java.util.Set<String> ids = new java.util.HashSet<>();
		for (Map<String, Object> f : drive.children(root(), token)) {
			if (GoogleDriveApi.FOLDER.equals(f.get("mimeType")) && str(f.get("name")).endsWith("관리")) { groups.add(f); ids.add(str(f.get("id"))); }
		}
		for (String k : new String[] { "WAIT", "REG", "CON", "LEFT" }) {
			String v = conf.get("STAFF", k);
			if (DriveConfService.isFolderId(v) && ids.add(v)) {
				Map<String, Object> g = new HashMap<>();
				g.put("id", v);
				g.put("name", v);
				groups.add(g);
			}
		}
		return groups;
	}

	/** 구분 폴더 ID. ⚙ 에서 고른 폴더면 그대로, 이름이면 같은 이름 구분 폴더를 찾고 없으면 만든다 */
	private String groupId(String group, String token) {
		if (DriveConfService.isFolderId(group)) return group;
		for (Map<String, Object> g : groups(token)) if (group.equals(g.get("name"))) return str(g.get("id"));
		return drive.createFolder(group, root(), token);
	}

	/** 안내 문구용 구분 폴더 이름(고른 폴더면 드라이브에서 이름을 읽는다) */
	private String groupLabel(String group, String token) {
		if (!DriveConfService.isFolderId(group)) return group;
		try {
			return str(drive.file(group, token).get("name"));
		} catch (RuntimeException e) {
			return "구분 폴더";
		}
	}

	private void saveFolder(Object staffSq, String id) {
		Map<String, Object> p = new HashMap<>();
		p.put("STAFF_SQ", staffSq);
		p.put("DRIVE_FOLDER_ID", id);
		mapper.updateStaffFolder(p);
	}

	/** 이름이 '(yyyy.MM.dd) 성명' 으로 시작하는 폴더. 입사일이 같은 것을 먼저 고른다 */
	static String pickPersonFolder(List<Map<String, Object>> folders, String name, String joinDt) {
		String exact = "(" + dot(joinDt) + ") " + name, any = null;
		Pattern p = Pattern.compile("^\\(\\d{4}\\.\\d{2}\\.\\d{2}\\)\\s*" + Pattern.quote(name) + "(?![가-힣]).*");
		for (Map<String, Object> f : folders) {
			String n = str(f.get("name"));
			if (n.startsWith(exact)) return str(f.get("id"));
			if (any == null && p.matcher(n).matches()) any = str(f.get("id"));
		}
		return any;
	}

	static String dot(String date) {
		return date != null && date.matches("\\d{4}-\\d{2}-\\d{2}") ? date.replace('-', '.') : LocalDate.now().toString().replace('-', '.');
	}

	/** 직원 폴더 이름(⚙ 규칙, 기본 '({입사일}) {성명}') */
	private String personName(Map<String, Object> staff) {
		Map<String, String> v = new HashMap<>();
		v.put("성명", str(staff.get("STAFF_NM")));
		v.put("입사일", dot(str(staff.get("JOIN_DT"))));
		return DriveConfService.render(conf.get("STAFF", "PERSON"), v);
	}

	private String traineeName(String name) {
		Map<String, String> v = new HashMap<>();
		v.put("성명", name);
		return DriveConfService.render(conf.get("STAFF", "TRAINEE"), v);
	}

	/** 새로 만들 사람 폴더의 구분 폴더. 인사카드 소속 기준. 정규·계약·퇴사는 ⚙ 이름, 영업지원·외부인원은 그대로 */
	String groupFolderName(String status, String org) {
		if ("LEFT".equals(status)) return conf.get("STAFF", "LEFT");
		if ("WAIT".equals(status)) return conf.get("STAFF", "WAIT");
		if (org.matches("정규직|반정규")) return conf.get("STAFF", "REG");
		if (org.matches("계약직|인턴|알바") || org.startsWith("프리")) return conf.get("STAFF", "CON");
		if (org.equals("영업")) return "7. 영업지원 관리";
		return "5. 외부인원 관리";
	}

	private String docsFolder(String personId, String token) {
		String docs = conf.get("STAFF", "DOCS");
		for (Map<String, Object> f : drive.children(personId, token)) {
			if (GoogleDriveApi.FOLDER.equals(f.get("mimeType")) && docs.equals(f.get("name"))) return str(f.get("id"));
		}
		return drive.createFolder(docs, personId, token);
	}

	// ── 단계가 바뀔 때 폴더 만들기·옮기기. 드라이브가 안 돼도 업무 처리는 막지 않고 안내 문구만 돌려준다(null 이면 할 말 없음) ──

	/** 면접자 → 교육생: 대기자 관리에 '(0000.00.00) 이름' */
	public String traineeCreated(String name) {
		return safe("교육생 폴더", () -> {
			String token = token(), wait = conf.get("STAFF", "WAIT"), folder = traineeName(name);
			String g = groupId(wait, token);
			if (drive.childFolderId(g, folder, token) == null) drive.createFolder(folder, g, token);
			return "드라이브 '" + groupLabel(wait, token) + "/" + folder + "' 폴더를 만들었습니다.";
		});
	}

	/** 교육생 중도이탈·교육종료: 대기자 관리의 그 폴더를 퇴사자 관리로 */
	public String traineeLeft(String name) {
		return safe("교육생 폴더", () -> {
			String token = token(), folder = traineeName(name);
			String id = drive.childFolderId(groupId(conf.get("STAFF", "WAIT"), token), folder, token);
			if (id == null) return null;
			drive.move(id, groupId(conf.get("STAFF", "LEFT"), token), null, token);
			return "드라이브 '" + folder + "' 폴더를 '" + groupLabel(conf.get("STAFF", "LEFT"), token) + "' 로 옮겼습니다.";
		});
	}

	/** 직원 등록: 교육생 폴더(대기자·퇴사자 관리)가 있으면 소속 구분 폴더로 옮기고 '(입사일) 이름' 으로, 없으면 새로 만든다 */
	public String staffCreated(Object staffSq) {
		return staffCreated(staffSq, true);
	}

	/** reuseTrainee=false 는 재입사: 예전 폴더는 두고 새로 만든다 */
	private String staffCreated(Object staffSq, boolean reuseTrainee) {
		return safe("직원 폴더", () -> {
			Map<String, Object> staff = staff(staffSq);
			String token = token(), folder = traineeName(str(staff.get("STAFF_NM")));
			String group = groupFolderName(str(staff.get("STATUS_CD")), str(staff.get("ORG_NM"))), target = groupId(group, token), name = personName(staff);
			// 대기 카드가 이미 잡아 둔 폴더가 있으면 그것을, 없으면 대기자·퇴사자 관리에서 '(0000.00.00) 이름' 을 찾는다
			String id = reuseTrainee ? str(staff.get("DRIVE_FOLDER_ID")) : null;
			if (reuseTrainee && !hasText(id)) id = drive.childFolderId(groupId(conf.get("STAFF", "WAIT"), token), folder, token);
			if (reuseTrainee && id == null) id = drive.childFolderId(groupId(conf.get("STAFF", "LEFT"), token), folder, token);
			if (!hasText(id)) id = null;
			String msg;
			if (id != null) {
				drive.move(id, target, name, token);
				msg = "교육생 폴더를 '" + groupLabel(group, token) + "/" + name + "' 로 옮겼습니다.";
			} else {
				id = drive.childFolderId(target, name, token);
				if (id == null) id = drive.createFolder(name, target, token);
				msg = "드라이브 '" + groupLabel(group, token) + "/" + name + "' 폴더를 만들었습니다.";
			}
			saveFolder(staffSq, id);
			return msg;
		});
	}

	/** 재직 상태가 바뀔 때: 퇴사면 퇴사자 관리로 옮기고, 퇴사에서 돌아오면(재입사) 예전 폴더는 두고 새로 만든다 */
	public String statusChanged(Object staffSq, String before, String after) {
		if (before == null || before.equals(after)) return null;
		if ("LEFT".equals(after)) {
			return safe("퇴사자 폴더", () -> {
				Map<String, Object> staff = staff(staffSq);
				String token = token(), left = conf.get("STAFF", "LEFT");
				String id = personFolder(staff, token);
				drive.move(id, groupId(left, token), null, token);
				return "드라이브 사람 폴더를 '" + groupLabel(left, token) + "' 로 옮겼습니다.";
			});
		}
		if ("LEFT".equals(before)) {
			saveFolder(staffSq, null);
			return staffCreated(staffSq, false);
		}
		// 대기(교육생) → 재직: 교육생 폴더를 소속 구분 폴더로 옮기고 '(입사일) 이름' 으로
		if ("WAIT".equals(before) && "WORK".equals(after)) return staffCreated(staffSq);
		return null;
	}

	private interface DriveStep {
		String run() throws Exception;
	}

	private static String safe(String what, DriveStep step) {
		try {
			return step.run();
		} catch (GoogleLinkService.NeedLink e) {
			return what + "는 만들지 못했습니다(내 연동 드라이브 없음). 처리는 끝났고, 폴더는 서류를 올릴 때 다시 맞춥니다.";
		} catch (Exception e) {
			System.out.println("STAFF_DRIVE_LIFECYCLE " + e.getClass().getSimpleName() + " " + e.getMessage());
			return what + " 처리에 실패했습니다(" + e.getClass().getSimpleName() + "). 처리는 끝났고, 폴더는 서류를 올릴 때 다시 맞춥니다.";
		}
	}
	// ── 서류 ──

	public List<Map<String, Object>> docs(Object staffSq) {
		return mapper.selectStaffDocList(one("STAFF_SQ", staffSq));
	}

	/** 올리고 연결한 뒤 글자를 읽어 채운다 */
	public Map<String, Object> upload(Object staffSq, String doc, String fileName, String mimeType, byte[] data, String loginId) {
		checkDoc(doc);
		if (data == null || data.length == 0) throw new IllegalArgumentException("파일이 비어 있습니다.");
		if (data.length > MAX_BYTES) throw new IllegalArgumentException("20MB 이하 파일만 올릴 수 있습니다.");
		Map<String, Object> staff = staff(staffSq);
		String token = token();
		String folder = docsFolder(personFolder(staff, token), token);
		String ext = fileName != null && fileName.lastIndexOf('.') > 0 ? fileName.substring(fileName.lastIndexOf('.')).toLowerCase() : "";
		Map<String, String> v = new HashMap<>();
		v.put("성명", str(staff.get("STAFF_NM")));
		v.put("서류명", DOC_NAMES.get(doc));
		v.put("올린날짜", LocalDate.now().toString().replace("-", ""));
		String base = DriveConfService.render(conf.get("STAFF", "FILE"), v);
		boolean taken = false;
		for (Map<String, Object> f : drive.children(folder, token)) if ((base + ext).equals(f.get("name"))) taken = true;
		String name = taken ? base + "_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmm")) + ext : base + ext;
		Map<String, Object> file = drive.upload(name, hasText(mimeType) ? mimeType : "application/octet-stream", data, folder, token);
		return linkAndRead(staff, doc, file, loginId, token);
	}

	/** 사람 폴더(와 그 안의 00. 입사관련서류)에 이미 있는 파일. 파일 이름으로 맞힌 서류 칸을 붙여 준다 */
	public Map<String, Object> scan(Object staffSq) {
		Map<String, Object> staff = staff(staffSq);
		String token = token();
		String person = personFolder(staff, token), docs = conf.get("STAFF", "DOCS");
		List<Map<String, Object>> files = new ArrayList<>();
		for (Map<String, Object> f : drive.children(person, token)) {
			if (GoogleDriveApi.FOLDER.equals(f.get("mimeType"))) {
				if (docs.equals(f.get("name"))) {
					for (Map<String, Object> d : drive.children(str(f.get("id")), token)) addScanned(files, d, docs + "/");
				}
				continue;
			}
			addScanned(files, f, "");
		}
		Map<String, Object> out = new HashMap<>();
		out.put("files", files);
		out.put("folderLink", "https://drive.google.com/drive/folders/" + person);
		return out;
	}

	static final String DOCX = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
	private static final Pattern PHOTO_NAME = Pattern.compile("사진|프로필|photo|profile", Pattern.CASE_INSENSITIVE);
	private static final Pattern CAREER_NAME = Pattern.compile("이력|경력|프로필|skill|인벤토리|inventory", Pattern.CASE_INSENSITIVE);
	/** 이 시스템이 만든 워드(이력카드(시스템)·지원 프로필 _수행이력_v1)는 가져올 원본이 아니다 */
	private static final Pattern SYSTEM_WORD = Pattern.compile("\\(시스템\\)|_수행이력_(순정|가필)?v?\\d");

	/**
	 * 드라이브 일괄 매핑 미리보기(아무것도 바꾸지 않는다, 폴더도 만들지 않는다).
	 * 사람 폴더와 그 하위 폴더 한 단계, 그리고 공유 드라이브 전체에서 이름(앞뒤가 한글이 아닌 성명)이 들어간 파일을 본다.
	 * @return folder(사람 폴더 ID 또는 null), photos·words 후보 {FILE_ID, FILE_NM, PATH, MIME_TYPE, WEB_LINK}, linkedPhoto(이미 연결된 증명사진 수)
	 */
	public Map<String, Object> match(Object staffSq) {
		Map<String, Object> staff = staff(staffSq);
		String token = token(), name = str(staff.get("STAFF_NM"));
		Pattern who = Pattern.compile("(?<![가-힣])" + Pattern.quote(name) + "(?![가-힣])");
		String folder = findPersonFolder(staff, token);
		List<Map<String, Object>> files = new ArrayList<>();
		java.util.Set<String> seen = new java.util.HashSet<>();
		if (folder != null) {
			for (Map<String, Object> f : drive.children(folder, token)) {
				if (GoogleDriveApi.FOLDER.equals(f.get("mimeType"))) {
					for (Map<String, Object> d : drive.children(str(f.get("id")), token)) if (seen.add(str(d.get("id")))) addScanned(files, d, f.get("name") + "/");
				} else if (seen.add(str(f.get("id")))) addScanned(files, f, "");
			}
		}
		for (Map<String, Object> f : drive.search("name contains '" + quoteQ(name) + "' and trashed = false and (mimeType contains 'image/' or mimeType = '" + DOCX + "')", token)) {
			if (who.matcher(str(f.get("name"))).find() && seen.add(str(f.get("id")))) addScanned(files, f, "드라이브 검색 · ");
		}
		List<Map<String, Object>> photos = new ArrayList<>(), words = new ArrayList<>();
		for (Map<String, Object> f : files) {
			String n = str(f.get("FILE_NM")), mime = str(f.get("MIME_TYPE"));
			boolean inFolder = !str(f.get("PATH")).startsWith("드라이브 검색");
			if (mime.startsWith("image/") && ("DOC_PHOTO".equals(f.get("GUESS")) || PHOTO_NAME.matcher(n).find())) photos.add(f);
			// 사람 폴더 안 워드는 이름이 무엇이든 후보, 드라이브 검색은 이력·경력 같은 이름일 때만
			if (DOCX.equals(mime) && !SYSTEM_WORD.matcher(n).find() && (inFolder || CAREER_NAME.matcher(n).find())) words.add(f);
		}
		words.sort((a, b) -> Boolean.compare(!CAREER_NAME.matcher(str(a.get("FILE_NM"))).find(), !CAREER_NAME.matcher(str(b.get("FILE_NM"))).find()));
		int linked = 0;
		for (Map<String, Object> d : docs(staffSq)) if ("DOC_PHOTO".equals(d.get("DOC_CD"))) linked++;
		Map<String, Object> out = new HashMap<>();
		out.put("folder", folder);
		out.put("photos", photos);
		out.put("words", words);
		out.put("linkedPhoto", linked);
		return out;
	}

	/** 드라이브 워드 파일 내용(.docx 만). {name, data} */
	public Map<String, Object> wordFile(String fileId) {
		String token = token();
		Map<String, Object> file = drive.file(fileId, token);
		if (!DOCX.equals(file.get("mimeType"))) throw new IllegalArgumentException("워드(.docx) 파일이 아닙니다: " + str(file.get("name")));
		Map<String, Object> out = new HashMap<>();
		out.put("name", file.get("name"));
		out.put("data", drive.download(file, token));
		return out;
	}

	private static void addScanned(List<Map<String, Object>> files, Map<String, Object> f, String prefix) {
		if (GoogleDriveApi.FOLDER.equals(f.get("mimeType"))) return;
		Map<String, Object> x = new HashMap<>();
		x.put("FILE_ID", f.get("id"));
		x.put("FILE_NM", f.get("name"));
		x.put("PATH", prefix + f.get("name"));
		x.put("MIME_TYPE", f.get("mimeType"));
		x.put("WEB_LINK", f.get("webViewLink"));
		x.put("GUESS", StaffDocParser.guessDoc(str(f.get("name"))));
		files.add(x);
	}

	/** 드라이브에 있는 파일을 서류 칸에 연결하고 글자를 읽어 채운다 */
	public Map<String, Object> link(Object staffSq, String doc, String fileId, String loginId) {
		checkDoc(doc);
		Map<String, Object> staff = staff(staffSq);
		String token = token();
		return linkAndRead(staff, doc, drive.file(fileId, token), loginId, token);
	}

	/** 이미 연결한 파일의 글자를 다시 읽는다 */
	public Map<String, Object> read(Object staffSq, String doc, String fileId, String loginId) {
		checkDoc(doc);
		Map<String, Object> staff = staff(staffSq);
		String token = token();
		Map<String, Object> file = drive.file(fileId, token);
		Map<String, Object> out = fillFrom(staff, doc, file, loginId, token);
		out.put("file", file);
		return out;
	}

	/** 이 직원에게 연결된 서류 파일만 받는다. {name, data} */
	public Map<String, Object> download(Object staffSq, int docSq) {
		for (Map<String, Object> d : docs(staffSq)) {
			if (((Number) d.get("DOC_SQ")).intValue() != docSq) continue;
			String token = token();
			Map<String, Object> file = drive.file(str(d.get("FILE_ID")), token);
			if (str(file.get("mimeType")).startsWith("application/vnd.google-apps.")) {
				throw new IllegalArgumentException("구글 문서 형식은 파일 이름을 눌러 드라이브에서 받아 주세요.");
			}
			Map<String, Object> out = new HashMap<>();
			out.put("name", file.get("name"));
			out.put("data", drive.download(file, token));
			return out;
		}
		throw new IllegalArgumentException("연결된 서류를 찾지 못했습니다.");
	}

	/** 이력카드 워드에 넣을 증명사진: 서류 탭 증명사진 중 가장 최근에 연결한 jpg·png. {ext, data} */
	public Object[] photo(Object staffSq) {
		Map<String, Object> last = null;
		for (Map<String, Object> d : docs(staffSq)) if ("DOC_PHOTO".equals(d.get("DOC_CD"))) last = d; // 목록은 연결 순서
		if (last == null) throw new IllegalArgumentException("서류 탭에 증명사진 파일이 없습니다. 사진을 먼저 첨부해 주세요.");
		String token = token();
		Map<String, Object> file = drive.file(str(last.get("FILE_ID")), token);
		String mime = str(file.get("mimeType"));
		String ext = mime.equals("image/png") ? "png" : mime.equals("image/jpeg") ? "jpeg" : null;
		if (ext == null) throw new IllegalArgumentException("증명사진이 jpg·png 가 아니라 워드에 넣을 수 없습니다(" + str(file.get("name")) + ").");
		return new Object[] { ext, drive.download(file, token) };
	}

	/** 시스템이 만든 이력카드 워드를 사람 폴더에 올린다. 같은 이름의 이전 파일만 지워 최신 한 개를 둔다. 사람이 올린 원본 워드는 건드리지 않는다 */
	public Map<String, Object> uploadCareerWord(Object staffSq, byte[] data) {
		Map<String, Object> staff = staff(staffSq);
		String token = token();
		Map<String, String> v = new HashMap<>();
		v.put("성명", str(staff.get("STAFF_NM")));
		String folder = personFolder(staff, token), name = DriveConfService.render(conf.get("STAFF", "WORD"), v) + ".docx";
		List<String> old = new ArrayList<>();
		for (Map<String, Object> f : drive.children(folder, token)) if (name.equals(f.get("name"))) old.add(str(f.get("id")));
		Map<String, Object> file = drive.upload(name, "application/vnd.openxmlformats-officedocument.wordprocessingml.document", data, folder, token);
		for (String id : old) drive.delete(id, token); // 새 파일이 올라간 뒤에 지운다
		return file;
	}

	public void unlink(Object staffSq, Object docSq) {
		Map<String, Object> p = one("STAFF_SQ", staffSq);
		p.put("DOC_SQ", docSq);
		mapper.deleteStaffDoc(p);
	}

	private Map<String, Object> linkAndRead(Map<String, Object> staff, String doc, Map<String, Object> file, String loginId, String token) {
		Map<String, Object> p = one("STAFF_SQ", staff.get("STAFF_SQ"));
		p.put("DOC_CD", doc);
		p.put("FILE_ID", file.get("id"));
		p.put("FILE_NM", file.get("name"));
		p.put("MIME_TYPE", file.get("mimeType"));
		p.put("WEB_LINK", file.get("webViewLink"));
		p.put("UPDT_EMPLY_ID", loginId);
		mapper.insertStaffDoc(p);
		save(staff, doc, "O", loginId);
		Map<String, Object> out = fillFrom(staff, doc, file, loginId, token);
		out.put("file", file);
		return out;
	}

	/** 읽은 값 중 빈 칸은 바로 채우고(filled), 이미 다른 값이 있으면 conflicts 로 돌려 사람이 고르게 한다 */
	private Map<String, Object> fillFrom(Map<String, Object> staff, String doc, Map<String, Object> file, String loginId, String token) {
		Map<String, Object> out = new HashMap<>();
		Map<String, String> filled = new LinkedHashMap<>();
		List<Map<String, String>> conflicts = new ArrayList<>();
		out.put("filled", filled);
		out.put("conflicts", conflicts);
		// 읽을 칸이 있는 서류이고 이미지·PDF 일 때만 OCR 한다
		if (PARSEABLE.contains(doc) && READABLE.matcher(str(file.get("mimeType"))).find()) {
			String text;
			try {
				text = drive.ocrText(str(file.get("id")), token);
			} catch (RuntimeException e) {
				out.put("ocrError", "글자를 읽지 못했습니다(" + e.getClass().getSimpleName() + ").");
				return out;
			}
			for (Map.Entry<String, String> e : StaffDocParser.parse(doc, text).entrySet()) {
				String field = e.getKey(), val = e.getValue(), cur = current(staff, field);
				if (!hasText(cur)) {
					save(staff, field, val, loginId);
					filled.put(field, mask(field, val));
				} else if (!same(field, cur, val)) {
					Map<String, String> c = new HashMap<>();
					c.put("field", field);
					c.put("old", mask(field, cur));
					c.put("shown", mask(field, val));
					// 저장하러 돌아올 값. 주민번호·계좌는 응답에 원문이 실리지 않게 암호문으로 보낸다
					c.put("value", "RRN".equals(field) || "ACCOUNT".equals(field) ? RrnCipher.encrypt(val) : val);
					conflicts.add(c);
				}
			}
		}
		return out;
	}

	private static String current(Map<String, Object> staff, String field) {
		if ("RRN".equals(field) || "ACCOUNT".equals(field)) {
			String enc = str(staff.get(field + "_ENC"));
			if (!hasText(enc)) return "";
			try {
				return RrnCipher.isEncrypted(enc) ? RrnCipher.decrypt(enc) : enc;
			} catch (RuntimeException e) {
				return "(복호화 실패)";
			}
		}
		return str(staff.get(field));
	}

	/** 숫자만 비교(계좌·주민번호 하이픈 차이는 같은 값), 나머지는 공백 무시 */
	private static boolean same(String field, String a, String b) {
		if ("RRN".equals(field) || "ACCOUNT".equals(field)) return a.replaceAll("[^0-9]", "").equals(b.replaceAll("[^0-9]", ""));
		return a.replaceAll("\\s", "").equals(b.replaceAll("\\s", ""));
	}

	private static String mask(String field, String v) {
		if ("RRN".equals(field)) return RrnCipher.maskStored(v);
		if ("ACCOUNT".equals(field)) return RrnCipher.maskTailStored(v);
		return v;
	}

	private void save(Map<String, Object> staff, String field, String value, String loginId) {
		Map<String, Object> p = one("STAFF_SQ", staff.get("STAFF_SQ"));
		p.put("FIELD", field);
		p.put("VALUE", value);
		p.put("UPDT_EMPLY_ID", loginId);
		staffService.fieldSave(p);
		// 같은 요청 안에서 다음 비교가 새 값을 보게 한다
		staff.put("RRN".equals(field) || "ACCOUNT".equals(field) ? field + "_ENC" : field, "RRN".equals(field) || "ACCOUNT".equals(field) ? RrnCipher.encrypt(value) : value);
	}

	private Map<String, Object> staff(Object staffSq) {
		Map<String, Object> s = mapper.selectStaffOne(one("STAFF_SQ", staffSq));
		if (s == null) throw new IllegalArgumentException("직원을 찾지 못했습니다.");
		return s;
	}

	private static void checkDoc(String doc) {
		if (!DOC_NAMES.containsKey(doc)) throw new IllegalArgumentException("서류 종류가 올바르지 않습니다.");
	}

	private static Map<String, Object> one(String k, Object v) {
		Map<String, Object> m = new HashMap<>();
		m.put(k, v);
		return m;
	}

	private static String quoteQ(String s) {
		return s.replace("\\", "\\\\").replace("'", "\\'");
	}

	private static boolean hasText(String s) {
		return s != null && !s.trim().isEmpty();
	}

	private static String str(Object o) {
		return o == null ? "" : o.toString();
	}
}
