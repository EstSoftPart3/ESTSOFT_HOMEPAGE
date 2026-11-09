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
import com.eep.bo.calendar.dao.BoCalendarDao;
import com.eep.bo.calendar.service.BoCalendarServiceImpl;
import com.eep.mapper.BoStaffMapper;

import common.util.RrnCipher;

/**
 * 직원 서류를 구글 드라이브 '2. 인사관리' 폴더에 올리고, 글자를 읽어 인사카드 빈 칸을 채운다.
 * 폴더: 2. 인사관리 / <구분 폴더> / (yyyy.MM.dd) 성명 / 00. 입사관련서류 / 성명_서류명.확장자
 */
@Service
public class StaffDriveService {

	static final String CONF_TOKEN = "STAFF_DRIVE_TOKEN";		// refresh token (RrnCipher 암호문)
	static final String CONF_ACCOUNT = "STAFF_DRIVE_ACCOUNT";
	static final String DOCS_FOLDER = "00. 입사관련서류";
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

	/** 구글드라이브 '2. 인사관리' 폴더 ID. 공개 저장소라 config/db.properties 에 둔다 */
	@Value("${staff.drive.root:}")
	private String rootId;

	@Autowired
	private GoogleDriveApi drive;
	@Autowired
	private BoCalendarDao confDao;
	@Autowired
	private BoStaffMapper mapper;
	@Autowired
	private BoStaffService staffService;

	// ── 연결 ──

	public Map<String, Object> status() {
		Map<String, String> conf = confDao.ConfMap();
		Map<String, Object> s = new HashMap<>();
		s.put("connected", hasText(conf.get(CONF_TOKEN)));
		s.put("account", conf.get(CONF_ACCOUNT));
		s.put("clientReady", hasText(conf.get(BoCalendarServiceImpl.CONF_CLIENT_ID)) && hasText(conf.get(BoCalendarServiceImpl.CONF_CLIENT_SECRET)));
		return s;
	}

	public String authUrl(String redirectUri, String state) {
		Map<String, String> conf = confDao.ConfMap();
		String id = conf.get(BoCalendarServiceImpl.CONF_CLIENT_ID);
		return hasText(id) ? drive.authUrl(id, redirectUri, state, GoogleDriveApi.WRITE_SCOPE) : null;
	}

	public boolean connect(String redirectUri, String code) {
		Map<String, String> conf = confDao.ConfMap();
		Map<String, Object> tokens = drive.exchangeCode(conf.get(BoCalendarServiceImpl.CONF_CLIENT_ID), conf.get(BoCalendarServiceImpl.CONF_CLIENT_SECRET), redirectUri, code);
		String refresh = (String) tokens.get("refresh_token");
		if (!hasText(refresh)) {
			return false;
		}
		confDao.ConfSave(CONF_TOKEN, RrnCipher.encrypt(refresh));
		confDao.ConfSave(CONF_ACCOUNT, drive.accountEmail((String) tokens.get("access_token")));
		return true;
	}

	public String token() {
		Map<String, String> conf = confDao.ConfMap();
		String stored = conf.get(CONF_TOKEN);
		if (!hasText(stored)) {
			throw new IllegalArgumentException("구글 드라이브가 연결되지 않았습니다. 직원관리 위쪽의 '드라이브 연결'을 먼저 눌러 주세요.");
		}
		return drive.accessToken(conf.get(BoCalendarServiceImpl.CONF_CLIENT_ID), conf.get(BoCalendarServiceImpl.CONF_CLIENT_SECRET), RrnCipher.decrypt(stored));
	}

	private String root() {
		if (!hasText(rootId)) {
			throw new IllegalArgumentException("db.properties 의 staff.drive.root 가 비어 있습니다.");
		}
		return rootId;
	}

	// ── 폴더 ──

	/** 사람 폴더 ID. 저장된 것이 있으면 그대로, 없으면 구분 폴더들에서 '(입사일) 성명' 을 찾고, 그래도 없으면 만든다 */
	String personFolder(Map<String, Object> staff, String token) {
		String saved = str(staff.get("DRIVE_FOLDER_ID"));
		if (hasText(saved)) {
			return saved;
		}
		String name = str(staff.get("STAFF_NM"));
		List<Map<String, Object>> groups = new ArrayList<>();
		for (Map<String, Object> f : drive.children(root(), token)) {
			if (GoogleDriveApi.FOLDER.equals(f.get("mimeType")) && str(f.get("name")).matches("^\\d+\\.\\s.*관리$")) {
				groups.add(f);
			}
		}
		String id = null;
		if (!groups.isEmpty()) {
			StringBuilder q = new StringBuilder("mimeType = '" + GoogleDriveApi.FOLDER + "' and trashed = false and name contains '" + quoteQ(name) + "' and (");
			for (int i = 0; i < groups.size(); i++) q.append(i > 0 ? " or " : "").append("'").append(quoteQ(str(groups.get(i).get("id")))).append("' in parents");
			q.append(")");
			id = pickPersonFolder(drive.search(q.toString(), token), name, str(staff.get("JOIN_DT")));
		}
		if (id == null) {
			String group = groupFolderName(str(staff.get("STATUS_CD")), str(staff.get("ORG_NM")));
			String groupId = null;
			for (Map<String, Object> g : groups) if (group.equals(g.get("name"))) groupId = str(g.get("id"));
			if (groupId == null) {
				groupId = drive.createFolder(group, root(), token);
			}
			id = drive.createFolder(personFolderName(name, str(staff.get("JOIN_DT"))), groupId, token);
		}
		Map<String, Object> p = new HashMap<>();
		p.put("STAFF_SQ", staff.get("STAFF_SQ"));
		p.put("DRIVE_FOLDER_ID", id);
		mapper.updateStaffFolder(p);
		return id;
	}

	/** 이름이 '(yyyy.MM.dd) 성명' 으로 시작하는 폴더. 입사일이 같은 것을 먼저 고른다 */
	static String pickPersonFolder(List<Map<String, Object>> folders, String name, String joinDt) {
		String exact = personFolderName(name, joinDt), any = null;
		Pattern p = Pattern.compile("^\\(\\d{4}\\.\\d{2}\\.\\d{2}\\)\\s*" + Pattern.quote(name) + "(?![가-힣]).*");
		for (Map<String, Object> f : folders) {
			String n = str(f.get("name"));
			if (n.startsWith(exact)) return str(f.get("id"));
			if (any == null && p.matcher(n).matches()) any = str(f.get("id"));
		}
		return any;
	}

	static String personFolderName(String name, String joinDt) {
		String d = joinDt != null && joinDt.matches("\\d{4}-\\d{2}-\\d{2}") ? joinDt.replace('-', '.') : LocalDate.now().toString().replace('-', '.');
		return "(" + d + ") " + name;
	}

	/** 새로 만들 사람 폴더의 구분 폴더. 엑셀 소속 기준 */
	static String groupFolderName(String status, String org) {
		if ("LEFT".equals(status)) return "4. 퇴사자 관리";
		if (org.matches("정규직|반정규")) return "2. 정규직 관리";
		if (org.matches("계약직|인턴|알바")) return "3. 계약직 관리";
		if (org.equals("영업")) return "7. 영업지원 관리";
		return "5. 외부인원 관리";
	}

	private String docsFolder(String personId, String token) {
		for (Map<String, Object> f : drive.children(personId, token)) {
			if (GoogleDriveApi.FOLDER.equals(f.get("mimeType")) && DOCS_FOLDER.equals(f.get("name"))) return str(f.get("id"));
		}
		return drive.createFolder(DOCS_FOLDER, personId, token);
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
		String base = str(staff.get("STAFF_NM")) + "_" + DOC_NAMES.get(doc);
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
		String person = personFolder(staff, token);
		List<Map<String, Object>> files = new ArrayList<>();
		for (Map<String, Object> f : drive.children(person, token)) {
			if (GoogleDriveApi.FOLDER.equals(f.get("mimeType"))) {
				if (DOCS_FOLDER.equals(f.get("name"))) {
					for (Map<String, Object> d : drive.children(str(f.get("id")), token)) addScanned(files, d, DOCS_FOLDER + "/");
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
