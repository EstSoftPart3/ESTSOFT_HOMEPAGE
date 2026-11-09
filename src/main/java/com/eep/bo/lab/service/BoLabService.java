package com.eep.bo.lab.service;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.annotation.PostConstruct;
import javax.imageio.ImageIO;
import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.util.HtmlUtils;

import com.eep.bo.batch.service.GoogleDriveApi;
import com.eep.bo.staff.service.StaffDriveService;
import com.eep.mapper.BoLabMapper;

/** 연구소 - 연구팀, 연구원, 연구과제, 월간 연구일지. 결재: 작성 중 -> 제출 -> 부서장 확인 -> 대표 확인(잠금 후 PDF 업로드). 반려하면 작성 중으로 돌아간다 */
@Service
public class BoLabService {

	static final String DRAFT = "DRAFT", SUBMITTED = "SUBMITTED", MANAGER_OK = "MANAGER_OK", CEO_OK = "CEO_OK";
	static final String JOURNAL_FOLDER = "02. 연구일지";
	private static final Pattern FOLDER_LINK = Pattern.compile("/folders/([\\w-]+)");
	private static final Pattern SIGN_PNG = Pattern.compile("^data:image/png;base64,([A-Za-z0-9+/]+={0,2})$");
	private static final int MAX_SIGN_CHARS = 400_000;

	@Autowired
	private BoLabMapper mapper;
	@Autowired
	private GoogleDriveApi drive;
	@Autowired
	private StaffDriveService driveConnection;
	@Autowired
	private DataSource dataSource;

	private TransactionTemplate tx;

	@PostConstruct
	public void init() {
		tx = new TransactionTemplate(new DataSourceTransactionManager(dataSource));
		try {
			mapper.ensureSchema();
		} catch (RuntimeException e) {
			System.out.println("LAB_SCHEMA_ERROR " + e.getClass().getSimpleName());
		}
	}

	// ── 선택 목록 ──

	public Map<String, Object> options() {
		Map<String, Object> out = new HashMap<>();
		out.put("staff", mapper.selectStaffOptions());
		out.put("accounts", mapper.selectAdminAccounts());
		out.put("teams", teams());
		return out;
	}

	// ── 연구팀 ──

	public List<Map<String, Object>> teams() {
		return mapper.selectTeams(new HashMap<>());
	}

	public Map<String, Object> teamDetail(Object teamSq, Map<String, Object> login) {
		Map<String, Object> team = team(teamSq), out = new HashMap<>();
		out.put("team", team);
		out.put("researchers", mapper.selectResearchers(one("TEAM_SQ", teamSq)));
		out.put("managerSign", signImage(str(team.get("MANAGER_EMPLY_ID"))));
		out.put("ceoSign", signImage(str(team.get("CEO_EMPLY_ID"))));
		out.put("mySign", signImage(str(login.get("emplyId"))));
		return out;
	}

	public Object saveTeam(Map<String, Object> p, Map<String, Object> login) {
		if (!hasText(str(p.get("TEAM_NM")))) throw new IllegalArgumentException("연구팀명을 입력해 주세요.");
		if (!Arrays.asList("Y", "N").contains(str(p.get("USE_YN")))) throw new IllegalArgumentException("사용 여부를 선택해 주세요.");
		p.put("UPDT_EMPLY_ID", login.get("emplyId"));
		if (hasText(str(p.get("TEAM_SQ")))) {
			mapper.updateTeam(p);
			return p.get("TEAM_SQ");
		}
		mapper.insertTeam(p);
		return p.get("NEW_TEAM_SQ");
	}

	public void saveApproval(Map<String, Object> p, Map<String, Object> login) {
		team(p.get("TEAM_SQ"));
		List<Object> admins = new ArrayList<>();
		for (Map<String, Object> a : mapper.selectAdminAccounts()) admins.add(a.get("EMPLY_ID"));
		if (!admins.contains(p.get("MANAGER_EMPLY_ID")) || !admins.contains(p.get("CEO_EMPLY_ID"))) throw new IllegalArgumentException("부서장과 대표 계정을 선택해 주세요.");
		p.put("UPDT_EMPLY_ID", login.get("emplyId"));
		mapper.updateTeamApproval(p);
	}

	private Map<String, Object> team(Object teamSq) {
		if (!hasText(str(teamSq))) throw new IllegalArgumentException("연구팀을 선택해 주세요.");
		List<Map<String, Object>> list = mapper.selectTeams(one("TEAM_SQ", teamSq));
		if (list.isEmpty()) throw new IllegalArgumentException("연구팀을 찾지 못했습니다.");
		return list.get(0);
	}

	// ── 서명 ──

	/** 항상 로그인한 본인 계정에만 쌓는다 */
	public void saveSign(String image, Map<String, Object> login) {
		checkSign(image);
		Map<String, Object> p = one("EMPLY_ID", login.get("emplyId"));
		p.put("SIGN_IMG", image);
		mapper.insertSign(p);
	}

	/** 화면이 보낸 값이 그대로 PDF 에 들어가므로 실제 PNG 인지 확인한다 */
	static void checkSign(String image) {
		Matcher m = image == null || image.length() > MAX_SIGN_CHARS ? null : SIGN_PNG.matcher(image);
		boolean ok = false;
		if (m != null && m.matches()) {
			try {
				ok = ImageIO.read(new ByteArrayInputStream(Base64.getDecoder().decode(m.group(1)))) != null;
			} catch (IllegalArgumentException | IOException e) {
				ok = false;
			}
		}
		if (!ok) throw new IllegalArgumentException("서명 이미지를 확인해 주세요.");
	}

	private String signImage(String emplyId) {
		Map<String, Object> s = hasText(emplyId) ? mapper.selectLatestSign(emplyId) : null;
		return s == null ? null : str(s.get("SIGN_IMG"));
	}

	// ── 연구원 ──

	public void saveResearcher(Map<String, Object> p, Map<String, Object> login) {
		team(p.get("TEAM_SQ"));
		boolean isNew = !hasText(str(p.get("RSCH_SQ")));
		if (isNew) p.put("RSCH_SQ", 0);
		if (!hasText(str(p.get("STAFF_SQ")))) throw new IllegalArgumentException("직원을 선택해 주세요.");
		if (!Arrays.asList("HEAD", "MEMBER").contains(str(p.get("ROLE_CD")))) throw new IllegalArgumentException("역할을 선택해 주세요.");
		LocalDate start = date(p, "START_DT", "소속 시작일");
		if (hasText(str(p.get("END_DT"))) && date(p, "END_DT", "소속 종료일").isBefore(start)) throw new IllegalArgumentException("소속 종료일이 시작일보다 빠릅니다.");
		// 겹치면 같은 달 연구인원에 한 사람이 두 번 들어간다
		if (mapper.countResearcherOverlap(p) > 0) throw new IllegalArgumentException("같은 직원의 소속 기간이 겹칩니다.");
		p.put("UPDT_EMPLY_ID", login.get("emplyId"));
		if (isNew) mapper.insertResearcher(p); else mapper.updateResearcher(p);
	}

	// ── 연구과제 ──

	public List<Map<String, Object>> projects() {
		return mapper.selectProjects();
	}

	public Map<String, Object> projectDetail(Object prjSq) {
		Map<String, Object> key = one("PRJ_SQ", prjSq), out = new HashMap<>();
		Map<String, Object> prj = mapper.selectProjectOne(key);
		if (prj == null) throw new IllegalArgumentException("과제를 찾지 못했습니다.");
		out.put("project", prj);
		out.put("journals", mapper.selectJournals(key));
		return out;
	}

	public void saveProject(Map<String, Object> p, Map<String, Object> login) {
		team(p.get("TEAM_SQ"));
		for (String[] f : new String[][] { { "PRJ_NM", "과제명" }, { "PLACE", "연구장소" }, { "DRIVE_FOLDER_ID", "드라이브 과제 폴더" } }) {
			if (!hasText(str(p.get(f[0])))) throw new IllegalArgumentException(f[1] + "을(를) 입력해 주세요.");
		}
		if (date(p, "END_DT", "연구 종료일").isBefore(date(p, "START_DT", "연구 시작일"))) throw new IllegalArgumentException("연구 종료일이 시작일보다 빠릅니다.");
		p.put("DRIVE_FOLDER_ID", folderId(str(p.get("DRIVE_FOLDER_ID"))));
		p.put("UPDT_EMPLY_ID", login.get("emplyId"));
		if (hasText(str(p.get("PRJ_SQ")))) mapper.updateProject(p); else mapper.insertProject(p);
	}

	/** 폴더 주소를 붙여 넣어도 ID 만 저장한다 */
	static String folderId(String input) {
		String v = input.trim();
		Matcher m = FOLDER_LINK.matcher(v);
		if (m.find()) return m.group(1);
		if (!v.matches("[\\w-]+")) throw new IllegalArgumentException("드라이브 과제 폴더 주소를 확인해 주세요.");
		return v;
	}

	// ── 월간 연구일지 ──

	public Map<String, Object> journalDetail(Object sq, Map<String, Object> login) {
		Map<String, Object> j = journal(sq);
		Map<String, Object> out = new HashMap<>();
		out.put("journal", j);
		out.put("history", mapper.selectJournalHistory(key(sq)));
		out.put("members", hasText(str(j.get("SNAP_MEMBERS"))) ? j.get("SNAP_MEMBERS") : members(j.get("TEAM_SQ"), str(j.get("YM"))));
		String col = approverColumn(str(j.get("STATUS_CD")));
		boolean canApprove = col != null && str(j.get(col)).equals(login.get("emplyId"));
		out.put("canApprove", canApprove);
		out.put("needSign", canApprove && signImage(str(login.get("emplyId"))) == null);
		return out;
	}

	/** 일지 등록 팝업의 연구인원(자동) */
	public String monthMembers(Object teamSq, String ym) {
		return members(teamSq, month(ym));
	}

	public Object createJournal(Map<String, Object> p, Map<String, Object> login) {
		String ym = month(str(p.get("YM")));
		Map<String, Object> prj = mapper.selectProjectOne(p);
		if (prj == null) throw new IllegalArgumentException("과제를 선택해 주세요.");
		if (!inPeriod(ym, str(prj.get("START_DT")), str(prj.get("END_DT")))) throw new IllegalArgumentException("과제 기간 밖의 달입니다.");
		actor(p, login);
		try {
			tx.execute(s -> {
				mapper.insertJournal(p);
				history(p.get("JRN_SQ"), "CREATE", DRAFT, null, null, login);
				return null;
			});
		} catch (DuplicateKeyException e) {
			throw new IllegalArgumentException("이 과제에 그 달 일지가 이미 있습니다.");
		}
		return p.get("JRN_SQ");
	}

	private static String month(String ym) {
		if (!ym.matches("\\d{4}-(0[1-9]|1[0-2])")) throw new IllegalArgumentException("대상 월을 선택해 주세요.");
		return ym;
	}

	public void saveJournal(Object sq, String content, Map<String, Object> login) {
		Map<String, Object> p = key(sq);
		p.put("CONTENT", content);
		tx.execute(s -> {
			if (mapper.updateJournalContent(p) != 1) throw new IllegalArgumentException("작성 중인 일지만 고칠 수 있습니다.");
			history(sq, "SAVE", DRAFT, null, null, login);
			return null;
		});
	}

	public void submitJournal(Object sq, Map<String, Object> login) {
		Map<String, Object> j = journal(sq);
		if (isBlankHtml(str(j.get("CONTENT")))) throw new IllegalArgumentException("연구 내용을 입력해 주세요.");
		if (!hasText(str(j.get("MANAGER_EMPLY_ID"))) || !hasText(str(j.get("CEO_EMPLY_ID")))) throw new IllegalArgumentException("연구소 관리의 결재라인을 먼저 지정해 주세요.");
		String members = members(j.get("TEAM_SQ"), str(j.get("YM")));
		if (!hasText(members)) throw new IllegalArgumentException("그 달에 소속된 연구원이 없습니다. 연구소 관리에서 소속 기간을 먼저 확인해 주세요.");
		Map<String, Object> p = key(sq);
		p.put("MEMBERS", members);
		tx.execute(s -> {
			if (mapper.updateJournalSubmit(p) != 1) throw new IllegalArgumentException("작성 중인 일지만 제출할 수 있습니다.");
			history(sq, "SUBMIT", SUBMITTED, null, null, login);
			return null;
		});
	}

	/** 에디터의 빈 내용은 <p>&nbsp;</p> 처럼 태그만 남는다 */
	static boolean isBlankHtml(String html) {
		return html.replaceAll("<[^>]*>", "").replace("&nbsp;", " ").trim().isEmpty();
	}

	/** @return STATUS_CD, 대표 확인에서 업로드가 실패했으면 uploadError (결재는 유지) */
	public Map<String, Object> approveJournal(Object sq, Map<String, Object> login) {
		Map<String, Object> j = journalForApprover(sq, login);
		String from = str(j.get("STATUS_CD")), to = afterApprove(from);
		Map<String, Object> sign = mapper.selectLatestSign(str(login.get("emplyId")));
		if (sign == null) throw new IllegalArgumentException("서명을 먼저 등록해 주세요.");
		// 제출 뒤 소속이 바뀌었으면 확정하지 않는다
		if (CEO_OK.equals(to) && !members(j.get("TEAM_SQ"), str(j.get("YM"))).equals(str(j.get("SNAP_MEMBERS")))) {
			throw new IllegalArgumentException("제출 뒤 연구인원이 바뀌었습니다. 반려한 뒤 다시 제출해 주세요.");
		}
		tx.execute(s -> {
			move(sq, from, to);
			history(sq, CEO_OK.equals(to) ? "APPROVE_CEO" : "APPROVE_MANAGER", to, null, sign.get("SIGN_SQ"), login);
			return null;
		});
		Map<String, Object> out = new HashMap<>();
		out.put("STATUS_CD", to);
		if (CEO_OK.equals(to)) out.put("uploadError", upload(sq, login));
		return out;
	}

	public void rejectJournal(Object sq, String note, Map<String, Object> login) {
		if (!hasText(note)) throw new IllegalArgumentException("반려 사유를 입력해 주세요.");
		Map<String, Object> j = journalForApprover(sq, login);
		tx.execute(s -> {
			move(sq, str(j.get("STATUS_CD")), DRAFT);
			history(sq, "REJECT", DRAFT, note, null, login);
			return null;
		});
	}

	/**
	 * PDF 를 만들어 과제 폴더의 '02. 연구일지' 에 올린다. 결재를 되돌리지 않도록 오류는 일지에 적고 메시지로 돌려준다.
	 * 재시도가 겹쳐 파일이 두 번 올라가지 않게 직렬로 돌린다(앱 서버 1대).
	 * @return 실패 메시지, 성공이면 null
	 */
	public synchronized String upload(Object sq, Map<String, Object> login) {
		Map<String, Object> j = journal(sq);
		if (!CEO_OK.equals(j.get("STATUS_CD"))) throw new IllegalArgumentException("대표 확인이 끝난 일지만 올릴 수 있습니다.");
		if (hasText(str(j.get("PDF_FILE_ID")))) return null;
		try {
			String token = driveConnection.token();
			String parent = str(j.get("DRIVE_FOLDER_ID"));
			String folder = drive.childFolderId(parent, JOURNAL_FOLDER, token);
			if (folder == null) folder = drive.createFolder(JOURNAL_FOLDER, parent, token);
			String name = j.get("YM") + " 월간연구일지_" + j.get("PRJ_NM");
			Map<String, Object> withSign = key(sq);
			withSign.put("WITH_SIGN", "Y");
			byte[] pdf = drive.htmlToPdf(name, pdfHtml(j, mapper.selectJournalHistory(withSign)), token);
			Map<String, Object> file = drive.upload(name + ".pdf", "application/pdf", pdf, folder, token);
			Map<String, Object> p = key(sq);
			p.put("PDF_FILE_ID", file.get("id"));
			p.put("PDF_LINK", file.get("webViewLink"));
			tx.execute(s -> {
				mapper.updateJournalUploaded(p);
				history(sq, "UPLOAD", CEO_OK, str(file.get("name")), null, login);
				return null;
			});
			return null;
		} catch (RuntimeException e) {
			String message = uploadMessage(e);
			System.out.println("LAB_UPLOAD_ERROR journal=" + sq + " " + e.getClass().getSimpleName());
			Map<String, Object> p = key(sq);
			p.put("UPLOAD_ERR", message);
			mapper.updateJournalUploadError(p);
			return message;
		}
	}

	/** 드라이브 응답 본문(토큰·경로가 섞일 수 있음)은 화면에 내보내지 않는다 */
	private static String uploadMessage(RuntimeException e) {
		if (e instanceof IllegalArgumentException) return e.getMessage();
		if (e instanceof HttpStatusCodeException) {
			int code = ((HttpStatusCodeException) e).getStatusCode().value();
			return code == 401 || code == 403 ? "드라이브 권한이 없습니다. 연결 계정에 과제 폴더 편집 권한이 있는지 확인해 주세요. (" + code + ")"
					: code == 404 ? "드라이브에서 과제 폴더를 찾지 못했습니다. (404)" : "드라이브 업로드에 실패했습니다. (" + code + ")";
		}
		return "드라이브 업로드에 실패했습니다. (" + e.getClass().getSimpleName() + ")";
	}

	private void move(Object sq, String from, String to) {
		Map<String, Object> p = key(sq);
		p.put("FROM", from);
		p.put("TO", to);
		if (mapper.updateJournalStatus(p) != 1) throw new IllegalArgumentException("다른 사용자가 먼저 처리했습니다. 화면을 다시 열어 주세요.");
	}

	private void history(Object sq, String action, String status, String note, Object signSq, Map<String, Object> login) {
		Map<String, Object> h = key(sq);
		h.put("ACTION_CD", action);
		h.put("STATUS_CD", status);
		h.put("NOTE", note);
		h.put("SIGN_SQ", signSq);
		actor(h, login);
		mapper.insertJournalHistory(h);
	}

	private static void actor(Map<String, Object> m, Map<String, Object> login) {
		m.put("ACTOR_ID", login.get("emplyId"));
		m.put("ACTOR_NM", login.get("emplyNm"));
	}

	private Map<String, Object> journal(Object sq) {
		Map<String, Object> j = mapper.selectJournalOne(key(sq));
		if (j == null) throw new IllegalArgumentException("일지를 찾지 못했습니다.");
		return j;
	}

	private Map<String, Object> journalForApprover(Object sq, Map<String, Object> login) {
		Map<String, Object> j = journal(sq);
		String col = approverColumn(str(j.get("STATUS_CD")));
		if (col == null) throw new IllegalArgumentException("결재할 단계가 아닙니다.");
		if (!str(j.get(col)).equals(login.get("emplyId"))) throw new IllegalArgumentException("이 단계의 결재자가 아닙니다.");
		return j;
	}

	/** 그 달 연구팀 소속 연구원. 예: 홍길동(연구소장), 김철수(연구원) */
	private String members(Object teamSq, String ym) {
		StringBuilder b = new StringBuilder();
		for (Map<String, Object> r : mapper.selectMonthResearchers(teamSq, ym)) {
			b.append(b.length() > 0 ? ", " : "").append(r.get("STAFF_NM")).append("HEAD".equals(r.get("ROLE_CD")) ? "(연구소장)" : "(연구원)");
		}
		return b.toString();
	}

	// ── 규칙 ──

	/** 이 상태를 결재하는 사람이 든 컬럼. 결재 단계가 아니면 null */
	static String approverColumn(String status) {
		return SUBMITTED.equals(status) ? "MANAGER_EMPLY_ID" : MANAGER_OK.equals(status) ? "CEO_EMPLY_ID" : null;
	}

	static String afterApprove(String status) {
		return SUBMITTED.equals(status) ? MANAGER_OK : CEO_OK;
	}

	static boolean inPeriod(String ym, String start, String end) {
		return ym.compareTo(start.substring(0, 7)) >= 0 && ym.compareTo(end.substring(0, 7)) <= 0;
	}

	/** hwp 양식과 같은 항목. 드라이브가 이 HTML 을 구글 문서로 바꿔 PDF 로 내보낸다 */
	static String pdfHtml(Map<String, Object> j, List<Map<String, Object>> history) {
		String written = "", managerNm = "", managerDt = "", managerImg = "", ceoNm = "", ceoDt = "", ceoImg = "";
		// 반려 후 다시 결재하면 마지막 기록이 남도록 순서대로 덮어쓴다
		for (Map<String, Object> h : history) {
			String action = str(h.get("ACTION_CD")), nm = str(h.get("ACTOR_NM")), dt = str(h.get("REG_DT")), img = str(h.get("SIGN_IMG"));
			if ("SUBMIT".equals(action)) written = dt;
			if ("APPROVE_MANAGER".equals(action)) { managerNm = nm; managerDt = dt; managerImg = img; }
			if ("APPROVE_CEO".equals(action)) { ceoNm = nm; ceoDt = dt; ceoImg = img; }
		}
		String cell = "border:1px solid #000;padding:6px;", head = cell + "background-color:#eeeeee;font-weight:bold;text-align:center;";
		StringBuilder b = new StringBuilder("<html><head><meta charset=\"UTF-8\"></head><body>");
		b.append("<h1 style=\"text-align:center;\">월간 연구일지</h1>");
		b.append("<table style=\"border-collapse:collapse;width:100%;\"><tr>")
				.append(td(head, "결재", "")).append(td(head, "부서장", "")).append(td(head, "대표", "")).append("</tr><tr>")
				.append(td(head, "서명", "")).append(signTd(cell, managerImg)).append(signTd(cell, ceoImg)).append("</tr><tr>")
				.append(td(head, "확인자", "")).append(td(cell, managerNm, "")).append(td(cell, ceoNm, "")).append("</tr><tr>")
				.append(td(head, "확인일시", "")).append(td(cell, managerDt, "")).append(td(cell, ceoDt, "")).append("</tr></table><p></p>");
		b.append("<table style=\"border-collapse:collapse;width:100%;\">");
		String[][] rows = { { "작성자", str(j.get("WRITER_NM")) }, { "작성일", written }, { "대상 월", str(j.get("YM")) }, { "연구주제", str(j.get("PRJ_NM")) },
				{ "연구장소", str(j.get("PLACE")) }, { "연구기간", str(j.get("PERIOD")) }, { "연구인원", str(j.get("SNAP_MEMBERS")) } };
		for (String[] r : rows) b.append("<tr>").append(td(head, r[0], " width=\"20%\"")).append(td(cell, r[1], "")).append("</tr>");
		// 내용은 에디터 HTML 이다. 이 문서는 구글 문서 변환에만 쓰여 브라우저에서 실행되지 않는다
		b.append("<tr>").append(td(head, "내용", " width=\"20%\"")).append("<td style=\"").append(cell).append("\">").append(str(j.get("CONTENT"))).append("</td></tr>");
		return b.append("</table></body></html>").toString();
	}

	private static String signTd(String style, String image) {
		// 값은 저장할 때 checkSign 으로 PNG data URI 만 받았다
		return "<td style=\"" + style + "text-align:center;\">" + (image.isEmpty() ? "" : "<img src=\"" + image + "\" width=\"110\" height=\"44\">") + "</td>";
	}

	private static String td(String style, String text, String attr) {
		return "<td style=\"" + style + "\"" + attr + ">" + HtmlUtils.htmlEscape(text).replace("\n", "<br>") + "</td>";
	}

	private static LocalDate date(Map<String, Object> p, String field, String label) {
		try {
			return LocalDate.parse(str(p.get(field)));
		} catch (DateTimeParseException e) {
			throw new IllegalArgumentException(label + "을(를) 확인해 주세요.");
		}
	}

	private static Map<String, Object> key(Object sq) {
		return one("JRN_SQ", sq);
	}

	private static Map<String, Object> one(String k, Object v) {
		Map<String, Object> m = new HashMap<>();
		m.put(k, v);
		return m;
	}

	private static boolean hasText(String s) {
		return s != null && !s.trim().isEmpty();
	}

	private static String str(Object o) {
		return o == null ? "" : o.toString();
	}
}
