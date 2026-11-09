package com.eep.bo.lab.service;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.annotation.PostConstruct;
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

/** 연구소 - 연구원, 연구과제, 월간 연구일지. 결재: 작성 중 -> 제출 -> 부서장 확인 -> 대표 확인(잠금 후 PDF 업로드). 반려하면 작성 중으로 돌아간다 */
@Service
public class BoLabService {

	static final String DRAFT = "DRAFT", SUBMITTED = "SUBMITTED", MANAGER_OK = "MANAGER_OK", CEO_OK = "CEO_OK";
	static final String JOURNAL_FOLDER = "02. 연구일지";
	private static final Pattern FOLDER_LINK = Pattern.compile("/folders/([\\w-]+)");

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
		out.put("projects", mapper.selectProjects());
		return out;
	}

	// ── 연구원 ──

	public List<Map<String, Object>> researchers() {
		return mapper.selectResearchers();
	}

	public void saveResearcher(Map<String, Object> p, Map<String, Object> login) {
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

	public void saveProject(Map<String, Object> p, Map<String, Object> login) {
		for (String[] f : new String[][] { { "PRJ_NM", "과제명" }, { "PLACE", "연구장소" }, { "DRIVE_FOLDER_ID", "드라이브 과제 폴더" } }) {
			if (!hasText(str(p.get(f[0])))) throw new IllegalArgumentException(f[1] + "을(를) 입력해 주세요.");
		}
		if (date(p, "END_DT", "연구 종료일").isBefore(date(p, "START_DT", "연구 시작일"))) throw new IllegalArgumentException("연구 종료일이 시작일보다 빠릅니다.");
		List<Object> admins = new ArrayList<>();
		for (Map<String, Object> a : mapper.selectAdminAccounts()) admins.add(a.get("EMPLY_ID"));
		if (!admins.contains(p.get("MANAGER_EMPLY_ID")) || !admins.contains(p.get("CEO_EMPLY_ID"))) throw new IllegalArgumentException("부서장과 대표 계정을 선택해 주세요.");
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

	public List<Map<String, Object>> journals() {
		return mapper.selectJournals();
	}

	public Map<String, Object> journalDetail(Object sq, Map<String, Object> login) {
		Map<String, Object> j = journal(sq);
		Map<String, Object> out = new HashMap<>();
		out.put("journal", j);
		out.put("history", mapper.selectJournalHistory(key(sq)));
		out.put("members", hasText(str(j.get("SNAP_MEMBERS"))) ? j.get("SNAP_MEMBERS") : members(str(j.get("YM"))));
		String col = approverColumn(str(j.get("STATUS_CD")));
		out.put("canApprove", col != null && str(j.get(col)).equals(login.get("emplyId")));
		return out;
	}

	public Object createJournal(Map<String, Object> p, Map<String, Object> login) {
		String ym = str(p.get("YM"));
		if (!ym.matches("\\d{4}-(0[1-9]|1[0-2])")) throw new IllegalArgumentException("대상 월을 선택해 주세요.");
		Map<String, Object> prj = mapper.selectProjectOne(p);
		if (prj == null) throw new IllegalArgumentException("과제를 선택해 주세요.");
		if (!inPeriod(ym, str(prj.get("START_DT")), str(prj.get("END_DT")))) throw new IllegalArgumentException("과제 기간 밖의 달입니다.");
		actor(p, login);
		try {
			tx.execute(s -> {
				mapper.insertJournal(p);
				history(p.get("JRN_SQ"), "CREATE", DRAFT, null, login);
				return null;
			});
		} catch (DuplicateKeyException e) {
			throw new IllegalArgumentException("이 과제에 그 달 일지가 이미 있습니다.");
		}
		return p.get("JRN_SQ");
	}

	public void saveJournal(Object sq, String content, Map<String, Object> login) {
		Map<String, Object> p = key(sq);
		p.put("CONTENT", content);
		tx.execute(s -> {
			if (mapper.updateJournalContent(p) != 1) throw new IllegalArgumentException("작성 중인 일지만 고칠 수 있습니다.");
			history(sq, "SAVE", DRAFT, null, login);
			return null;
		});
	}

	public void submitJournal(Object sq, String content, Map<String, Object> login) {
		if (!hasText(content)) throw new IllegalArgumentException("연구 내용을 입력해 주세요.");
		String members = members(str(journal(sq).get("YM")));
		if (!hasText(members)) throw new IllegalArgumentException("그 달에 소속된 연구원이 없습니다. 연구원 화면에서 소속 기간을 먼저 확인해 주세요.");
		Map<String, Object> p = key(sq);
		p.put("CONTENT", content);
		p.put("MEMBERS", members);
		tx.execute(s -> {
			if (mapper.updateJournalContent(p) != 1 || mapper.updateJournalSubmit(p) != 1) throw new IllegalArgumentException("작성 중인 일지만 제출할 수 있습니다.");
			history(sq, "SUBMIT", SUBMITTED, null, login);
			return null;
		});
	}

	/** @return STATUS_CD, 대표 확인에서 업로드가 실패했으면 uploadError (결재는 유지) */
	public Map<String, Object> approveJournal(Object sq, Map<String, Object> login) {
		Map<String, Object> j = journalForApprover(sq, login);
		String from = str(j.get("STATUS_CD")), to = afterApprove(from);
		// 제출 뒤 소속이 바뀌었으면 확정하지 않는다
		if (CEO_OK.equals(to) && !members(str(j.get("YM"))).equals(str(j.get("SNAP_MEMBERS")))) {
			throw new IllegalArgumentException("제출 뒤 연구인원이 바뀌었습니다. 반려한 뒤 다시 제출해 주세요.");
		}
		tx.execute(s -> {
			move(sq, from, to);
			history(sq, CEO_OK.equals(to) ? "APPROVE_CEO" : "APPROVE_MANAGER", to, null, login);
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
			history(sq, "REJECT", DRAFT, note, login);
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
			byte[] pdf = drive.htmlToPdf(name, pdfHtml(j, mapper.selectJournalHistory(key(sq))), token);
			Map<String, Object> file = drive.upload(name + ".pdf", "application/pdf", pdf, folder, token);
			Map<String, Object> p = key(sq);
			p.put("PDF_FILE_ID", file.get("id"));
			p.put("PDF_LINK", file.get("webViewLink"));
			tx.execute(s -> {
				mapper.updateJournalUploaded(p);
				history(sq, "UPLOAD", CEO_OK, str(file.get("name")), login);
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

	private void history(Object sq, String action, String status, String note, Map<String, Object> login) {
		Map<String, Object> h = key(sq);
		h.put("ACTION_CD", action);
		h.put("STATUS_CD", status);
		h.put("NOTE", note);
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

	/** 그 달 소속 연구원. 예: 홍길동(연구소장), 김철수(연구원) */
	private String members(String ym) {
		StringBuilder b = new StringBuilder();
		for (Map<String, Object> r : mapper.selectMonthResearchers(ym)) {
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
		String written = "", managerNm = "", managerDt = "", ceoNm = "", ceoDt = "";
		// 반려 후 다시 결재하면 마지막 기록이 남도록 순서대로 덮어쓴다
		for (Map<String, Object> h : history) {
			String action = str(h.get("ACTION_CD")), nm = str(h.get("ACTOR_NM")), dt = str(h.get("REG_DT"));
			if ("SUBMIT".equals(action)) written = dt;
			if ("APPROVE_MANAGER".equals(action)) { managerNm = nm; managerDt = dt; }
			if ("APPROVE_CEO".equals(action)) { ceoNm = nm; ceoDt = dt; }
		}
		String cell = "border:1px solid #000;padding:6px;", head = cell + "background-color:#eeeeee;font-weight:bold;text-align:center;";
		StringBuilder b = new StringBuilder("<html><head><meta charset=\"UTF-8\"></head><body>");
		b.append("<h1 style=\"text-align:center;\">월간 연구일지</h1>");
		b.append("<table style=\"border-collapse:collapse;width:100%;\"><tr>")
				.append(td(head, "결재", "")).append(td(head, "부서장", "")).append(td(head, "대표", "")).append("</tr><tr>")
				.append(td(head, "확인자", "")).append(td(cell, managerNm, "")).append(td(cell, ceoNm, "")).append("</tr><tr>")
				.append(td(head, "확인일시", "")).append(td(cell, managerDt, "")).append(td(cell, ceoDt, "")).append("</tr></table><p></p>");
		b.append("<table style=\"border-collapse:collapse;width:100%;\">");
		String[][] rows = { { "작성자", str(j.get("WRITER_NM")) }, { "작성일", written }, { "대상 월", str(j.get("YM")) }, { "연구주제", str(j.get("PRJ_NM")) },
				{ "연구장소", str(j.get("PLACE")) }, { "연구기간", str(j.get("PERIOD")) }, { "연구인원", str(j.get("SNAP_MEMBERS")) }, { "내용", str(j.get("CONTENT")) } };
		for (String[] r : rows) b.append("<tr>").append(td(head, r[0], " width=\"20%\"")).append(td(cell, r[1], "")).append("</tr>");
		return b.append("</table></body></html>").toString();
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
		Map<String, Object> m = new HashMap<>();
		m.put("JRN_SQ", sq);
		return m;
	}

	private static boolean hasText(String s) {
		return s != null && !s.trim().isEmpty();
	}

	private static String str(Object o) {
		return o == null ? "" : o.toString();
	}
}
