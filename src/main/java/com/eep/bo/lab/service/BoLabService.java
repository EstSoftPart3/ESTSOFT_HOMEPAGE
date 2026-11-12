package com.eep.bo.lab.service;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.annotation.PostConstruct;
import javax.imageio.ImageIO;
import javax.mail.internet.MimeMessage;
import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.util.HtmlUtils;

import com.eep.bo.batch.service.GoogleDriveApi;
import com.eep.bo.staff.service.StaffDriveService;
import com.eep.mapper.BoLabMapper;

/**
 * 연구소 - 연구팀, 결재라인, 연구원, 연구과제, 월간 연구일지.
 * 흐름: 작성 중 -> 제출 -> 결재라인 1~n단계 -> 결재 완료 -> 연구소장 마감(잠금, PDF 업로드, 연구원 메일). 반려하면 작성 중으로 돌아간다
 */
@Service
public class BoLabService {

	static final String DRAFT = "DRAFT", SUBMITTED = "SUBMITTED", APPROVED = "APPROVED", CLOSED = "CLOSED";
	static final String JOURNAL_FOLDER = "02. 연구일지";
	static final int MAX_STEPS = 5;
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
	@Autowired
	private JavaMailSender mailSender;
	@Value("${mail.username}")
	private String mailFrom;

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
		Map<String, Object> key = one("TEAM_SQ", teamSq), out = new HashMap<>();
		out.put("team", team(teamSq));
		out.put("researchers", mapper.selectResearchers(key));
		out.put("line", mapper.selectApprovalLine(key));
		out.put("me", login.get("emplyId"));
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

	/** 결재라인 전체를 화면의 순서대로 다시 저장한다. 이미 제출된 일지는 제출 때 복사한 단계를 쓰므로 바뀌지 않는다 */
	public void saveApproval(Object teamSq, String[] names, String[] ids) {
		team(teamSq);
		List<String[]> steps = checkSteps(names, ids, adminIds());
		tx.execute(s -> {
			mapper.deleteApprovalLine(one("TEAM_SQ", teamSq));
			for (int i = 0; i < steps.size(); i++) {
				Map<String, Object> p = one("TEAM_SQ", teamSq);
				p.put("STEP_NO", i + 1);
				p.put("STEP_NM", steps.get(i)[0]);
				p.put("EMPLY_ID", steps.get(i)[1]);
				mapper.insertApprovalStep(p);
			}
			return null;
		});
	}

	static List<String[]> checkSteps(String[] names, String[] ids, Set<String> admins) {
		int n = names == null ? 0 : names.length;
		if (n != (ids == null ? 0 : ids.length)) throw new IllegalArgumentException("결재라인을 다시 불러와 주세요.");
		if (n > MAX_STEPS) throw new IllegalArgumentException("결재 단계는 " + MAX_STEPS + "단계까지 둘 수 있습니다.");
		List<String[]> out = new ArrayList<>();
		Set<String> seen = new HashSet<>();
		for (int i = 0; i < n; i++) {
			String nm = names[i] == null ? "" : names[i].trim(), id = ids[i] == null ? "" : ids[i].trim();
			if (nm.isEmpty() || nm.length() > 50) throw new IllegalArgumentException((i + 1) + "단계 이름을 50자 안으로 입력해 주세요.");
			if (!admins.contains(id)) throw new IllegalArgumentException((i + 1) + "단계 결재자 계정을 선택해 주세요.");
			if (!seen.add(id)) throw new IllegalArgumentException("같은 계정을 두 단계에 넣을 수 없습니다.");
			out.add(new String[] { nm, id });
		}
		return out;
	}

	private Set<String> adminIds() {
		Set<String> ids = new HashSet<>();
		for (Map<String, Object> a : mapper.selectAdminAccounts()) ids.add(str(a.get("EMPLY_ID")));
		return ids;
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
		Map<String, Object> j = journal(sq), out = new HashMap<>();
		String st = str(j.get("STATUS_CD")), me = str(login.get("emplyId"));
		List<Map<String, Object>> steps = mapper.selectJournalSteps(key(sq));
		out.put("journal", j);
		out.put("steps", steps.isEmpty() ? mapper.selectApprovalLine(one("TEAM_SQ", j.get("TEAM_SQ"))) : steps);
		out.put("history", mapper.selectJournalHistory(key(sq)));
		out.put("members", hasText(str(j.get("SNAP_MEMBERS"))) ? j.get("SNAP_MEMBERS") : members(j.get("TEAM_SQ"), str(j.get("YM"))));
		boolean canApprove = SUBMITTED.equals(st) && me.equals(str(currentStep(j, steps).get("EMPLY_ID")));
		out.put("canApprove", canApprove);
		out.put("needSign", canApprove && mapper.selectLatestSign(me) == null);
		Map<String, Object> head = mapper.selectTeamHead(one("TEAM_SQ", j.get("TEAM_SQ")));
		out.put("headNm", head == null ? null : head.get("STAFF_NM"));
		out.put("canClose", APPROVED.equals(st) && head != null && me.equals(str(head.get("EMPLY_ID"))));
		// 연구원별 업무요약 탭과 마감 메일 미리보기가 함께 쓴다
		out.put("recipients", recipients(j));
		return out;
	}

	private static Map<String, Object> currentStep(Map<String, Object> j, List<Map<String, Object>> steps) {
		for (Map<String, Object> s : steps) if (str(s.get("STEP_NO")).equals(str(j.get("CUR_STEP")))) return s;
		return new HashMap<>();
	}

	/** 마감 메일 받을 사람. 회사 메일을 먼저 쓰고 없으면 개인 메일 */
	private List<Map<String, Object>> recipients(Map<String, Object> j) {
		List<Map<String, Object>> out = new ArrayList<>();
		for (Map<String, Object> r : mapper.selectMonthResearchers(j.get("TEAM_SQ"), str(j.get("YM")))) {
			Map<String, Object> x = new HashMap<>();
			String company = str(r.get("COMPANY_EMAIL")).trim(), personal = str(r.get("EMAIL")).trim(), nm = str(r.get("STAFF_NM"));
			x.put("STAFF_NM", nm);
			x.put("ROLE_CD", r.get("ROLE_CD"));
			x.put("ADDR", hasText(company) ? company : personal);
			x.put("KIND", hasText(company) ? "COMPANY" : hasText(personal) ? "PERSONAL" : "NONE");
			x.put("ITEMS", workItems(str(j.get("CONTENT")), nm));
			out.add(x);
		}
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
		Map<String, Object> team = one("TEAM_SQ", j.get("TEAM_SQ"));
		if (mapper.selectApprovalLine(team).isEmpty()) throw new IllegalArgumentException("연구소 관리의 결재라인을 먼저 지정해 주세요.");
		String members = members(j.get("TEAM_SQ"), str(j.get("YM")));
		if (!hasText(members)) throw new IllegalArgumentException("그 달에 소속된 연구원이 없습니다. 연구소 관리에서 소속 기간을 먼저 확인해 주세요.");
		Map<String, Object> p = key(sq);
		p.put("MEMBERS", members);
		p.put("TEAM_SQ", j.get("TEAM_SQ"));
		tx.execute(s -> {
			if (mapper.updateJournalSubmit(p) != 1) throw new IllegalArgumentException("작성 중인 일지만 제출할 수 있습니다.");
			mapper.deleteJournalSteps(p);
			mapper.insertJournalSteps(p);
			history(sq, "SUBMIT", SUBMITTED, null, null, login);
			return null;
		});
	}

	/** 에디터의 빈 내용은 <p>&nbsp;</p> 처럼 태그만 남는다 */
	static boolean isBlankHtml(String html) {
		return html.replaceAll("<[^>]*>", "").replace("&nbsp;", " ").trim().isEmpty();
	}

	/** @return 처리 후 상태 (마지막 단계면 APPROVED) */
	public String approveJournal(Object sq, Map<String, Object> login) {
		Map<String, Object> j = journal(sq);
		Map<String, Object> step = stepForApprover(j, login);
		Map<String, Object> sign = mapper.selectLatestSign(str(login.get("emplyId")));
		if (sign == null) throw new IllegalArgumentException("서명을 먼저 등록해 주세요.");
		int cur = Integer.parseInt(str(j.get("CUR_STEP")));
		boolean last = cur >= mapper.selectJournalSteps(key(sq)).size();
		String to = last ? APPROVED : SUBMITTED;
		tx.execute(s -> {
			Map<String, Object> p = key(sq);
			p.put("STEP_NO", cur);
			p.put("SIGN_SQ", sign.get("SIGN_SQ"));
			actor(p, login);
			p.put("FROM_STEP", cur);
			p.put("TO_STEP", last ? null : cur + 1);
			p.put("TO", to);
			if (mapper.updateStepDone(p) != 1 || mapper.updateJournalStep(p) != 1) throw new IllegalArgumentException("다른 사용자가 먼저 처리했습니다. 화면을 다시 열어 주세요.");
			history(sq, "APPROVE", to, str(step.get("STEP_NM")), sign.get("SIGN_SQ"), login);
			return null;
		});
		return to;
	}

	public void rejectJournal(Object sq, String note, Map<String, Object> login) {
		if (!hasText(note)) throw new IllegalArgumentException("반려 사유를 입력해 주세요.");
		Map<String, Object> j = journal(sq);
		stepForApprover(j, login);
		tx.execute(s -> {
			move(sq, SUBMITTED, DRAFT);
			mapper.deleteJournalSteps(key(sq));
			history(sq, "REJECT", DRAFT, note, null, login);
			return null;
		});
	}

	private Map<String, Object> stepForApprover(Map<String, Object> j, Map<String, Object> login) {
		if (!SUBMITTED.equals(j.get("STATUS_CD"))) throw new IllegalArgumentException("결재할 단계가 아닙니다.");
		Map<String, Object> step = currentStep(j, mapper.selectJournalSteps(key(j.get("JRN_SQ"))));
		if (!str(step.get("EMPLY_ID")).equals(login.get("emplyId"))) throw new IllegalArgumentException("이 단계의 결재자가 아닙니다.");
		return step;
	}

	/** 연구소장이 결재 완료된 일지를 마감한다. 잠근 뒤 PDF 업로드와 메일은 실패해도 마감을 되돌리지 않는다 */
	public Map<String, Object> closeJournal(Object sq, Map<String, Object> login) {
		Map<String, Object> j = journal(sq);
		if (!APPROVED.equals(j.get("STATUS_CD"))) throw new IllegalArgumentException("결재가 모두 끝난 일지만 마감할 수 있습니다.");
		Map<String, Object> head = mapper.selectTeamHead(one("TEAM_SQ", j.get("TEAM_SQ")));
		if (head == null || !str(head.get("EMPLY_ID")).equals(login.get("emplyId"))) throw new IllegalArgumentException("연구소장만 마감할 수 있습니다.");
		// 제출 뒤 소속이 바뀌었으면 마감하지 않는다
		if (!members(j.get("TEAM_SQ"), str(j.get("YM"))).equals(str(j.get("SNAP_MEMBERS")))) {
			throw new IllegalArgumentException("제출 뒤 연구인원이 바뀌었습니다. 연구소 관리에서 소속 기간을 확인해 주세요.");
		}
		tx.execute(s -> {
			move(sq, APPROVED, CLOSED);
			history(sq, "CLOSE", CLOSED, null, null, login);
			return null;
		});
		Map<String, Object> out = new HashMap<>();
		out.put("publishError", publish(sq, login));
		return out;
	}

	/**
	 * 마감된 일지의 PDF 를 과제 폴더 '02. 연구일지' 에 올리고 연구원에게 메일을 보낸다. 끝난 것은 다시 하지 않는다.
	 * 재시도가 겹쳐 두 번 올라가거나 메일이 두 번 가지 않게 직렬로 돌린다(앱 서버 1대).
	 * @return 실패 메시지, 성공이면 null
	 */
	public synchronized String publish(Object sq, Map<String, Object> login) {
		Map<String, Object> j = journal(sq);
		if (!CLOSED.equals(j.get("STATUS_CD"))) throw new IllegalArgumentException("마감한 일지만 올릴 수 있습니다.");
		String name = j.get("YM") + " 월간연구일지_" + j.get("PRJ_NM");
		byte[] pdf = null;
		try {
			String token = driveConnection.token();
			if (!hasText(str(j.get("PDF_FILE_ID")))) {
				String parent = str(j.get("DRIVE_FOLDER_ID"));
				String folder = drive.childFolderId(parent, JOURNAL_FOLDER, token);
				if (folder == null) folder = drive.createFolder(JOURNAL_FOLDER, parent, token);
				Map<String, Object> withSign = key(sq);
				withSign.put("WITH_SIGN", "Y");
				pdf = drive.htmlToPdf(name, pdfHtml(j, mapper.selectJournalSteps(withSign), mapper.selectJournalHistory(key(sq))), token);
				Map<String, Object> file = drive.upload(name + ".pdf", "application/pdf", pdf, folder, token);
				Map<String, Object> p = key(sq);
				p.put("PDF_FILE_ID", file.get("id"));
				p.put("PDF_LINK", file.get("webViewLink"));
				tx.execute(s -> {
					mapper.updateJournalUploaded(p);
					history(sq, "UPLOAD", CLOSED, str(file.get("name")), null, login);
					return null;
				});
			}
			if (!hasText(str(j.get("MAIL_DT")))) {
				if (pdf == null) pdf = drive.download(drive.file(str(j.get("PDF_FILE_ID")), token), token);
				sendMails(j, pdf, name + ".pdf", login);
			}
			return null;
		} catch (RuntimeException e) {
			String message = uploadMessage(e);
			System.out.println("LAB_PUBLISH_ERROR journal=" + sq + " " + e.getClass().getSimpleName());
			Map<String, Object> p = key(sq);
			p.put("UPLOAD_ERR", message);
			mapper.updateJournalUploadError(p);
			return message;
		}
	}

	/** 사람마다 한 통씩. 실패한 사람은 이력에 남기고 나머지는 계속 보낸다. 한 번 보낸 일지는 다시 보내지 않는다 */
	private void sendMails(Map<String, Object> j, byte[] pdf, String fileName, Map<String, Object> login) {
		Object sq = j.get("JRN_SQ");
		for (Map<String, Object> r : recipients(j)) {
			String nm = str(r.get("STAFF_NM")), addr = str(r.get("ADDR"));
			if (!hasText(addr)) {
				history(sq, "MAIL_FAIL", CLOSED, nm + ": 메일 주소 없음", null, login);
				continue;
			}
			try {
				MimeMessage message = mailSender.createMimeMessage();
				MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
				helper.setFrom(mailFrom);
				helper.setTo(addr);
				helper.setSubject("[연구일지] " + j.get("YM") + " " + j.get("PRJ_NM") + " 마감");
				@SuppressWarnings("unchecked")
				List<String> items = (List<String>) r.get("ITEMS");
				helper.setText(mailHtml(nm, str(j.get("YM")), str(j.get("PRJ_NM")), items), true);
				helper.addAttachment(fileName, new ByteArrayResource(pdf));
				mailSender.send(message);
				history(sq, "MAIL", CLOSED, nm + " <" + addr + ">", null, login);
			} catch (Exception e) {
				history(sq, "MAIL_FAIL", CLOSED, nm + " <" + addr + "> " + e.getClass().getSimpleName(), null, login);
			}
		}
		mapper.updateJournalMailed(key(sq));
	}

	static String mailHtml(String name, String ym, String project, List<String> items) {
		StringBuilder b = new StringBuilder("<p>").append(esc(name)).append("님, ").append(esc(ym)).append(" 월간 연구일지(").append(esc(project)).append(")가 마감되었습니다.</p>");
		b.append("<p><b>이번 달 본인 작업</b></p>");
		if (items.isEmpty()) b.append("<p>일지에서 본인 담당 항목을 찾지 못했습니다.</p>");
		else {
			b.append("<ul>");
			for (String i : items) b.append("<li>").append(esc(i)).append("</li>");
			b.append("</ul>");
		}
		return b.append("<p>전체 내용은 첨부한 PDF 를 확인해 주세요.</p>").toString();
	}

	/**
	 * 일지 본문에서 이 사람이 담당한 항목 제목만 모은다.
	 * 형식 1: 제목 줄 다음 줄이 "담당자: 이름 ..." / 형식 2: "- 제목 (이름 연구원, 기간)"
	 */
	static List<String> workItems(String html, String name) {
		String text = HtmlUtils.htmlUnescape(html.replaceAll("(?i)<br\\s*/?>|</p>|</div>|</li>|</tr>|</h\\d>", "\n").replaceAll("<[^>]*>", "")).replace(' ', ' ');
		List<String> lines = new ArrayList<>();
		for (String l : text.split("\n")) if (!l.trim().isEmpty()) lines.add(l.trim());
		Set<String> out = new LinkedHashSet<>();
		Pattern inline = Pattern.compile("^[-•*]\\s*(.+?)\\s*\\(" + Pattern.quote(name) + "(?![가-힣]).*");
		for (int i = 0; i < lines.size() && out.size() < 30; i++) {
			String l = lines.get(i);
			if (l.matches("^담당자\\s*[:：].*") && l.matches(".*[:：,\\s]" + Pattern.quote(name) + "(?![가-힣]).*") && i > 0) {
				String content = "";
				for (int k = i + 1; k < Math.min(i + 4, lines.size()); k++) {
					if (lines.get(k).matches("^내용\\s*[:：].*")) { content = lines.get(k).replaceFirst("^내용\\s*[:：]\\s*", ""); break; }
				}
				addItem(out, cleanItem(lines.get(i - 1)), content);
			}
			Matcher m = inline.matcher(l);
			if (m.matches()) addItem(out, cleanItem(m.group(1)), "");
		}
		return new ArrayList<>(out);
	}

	private static void addItem(Set<String> out, String item, String fallback) {
		String v = item.isEmpty() ? fallback.trim() : item;
		if (!v.isEmpty()) out.add(v);
	}

	private static final Pattern CODE = Pattern.compile("^[A-Za-z][A-Za-z_]*\\d+[A-Za-z]?$");
	private static final Pattern FILE = Pattern.compile("^[\\w./-]+\\.[A-Za-z]{2,5}$");
	private static final Pattern CODE_NOTE = Pattern.compile("\\s*[(（][^()（）]*[{}=?/_][^()（）]*[)）]");

	/** 항목 제목에서 화면 코드(comm_ui001), 파일명(CommonHeader.tsx), 코드가 든 괄호 설명을 빼고 하는 일만 남긴다 */
	static String cleanItem(String title) {
		StringBuilder b = new StringBuilder();
		for (String part : title.split("\\s+-\\s+")) {
			String p = part.trim();
			if (p.isEmpty() || CODE.matcher(p).matches() || FILE.matcher(p).matches()) continue;
			b.append(b.length() > 0 ? " · " : "").append(p);
		}
		return CODE_NOTE.matcher(b.toString()).replaceAll("").trim();
	}

	/** 드라이브 응답 본문(토큰·경로가 섞일 수 있음)은 화면에 내보내지 않는다 */
	private static String uploadMessage(RuntimeException e) {
		if (e instanceof IllegalArgumentException) return e.getMessage();
		if (e instanceof HttpStatusCodeException) {
			int code = ((HttpStatusCodeException) e).getStatusCode().value();
			return code == 401 || code == 403 ? "드라이브 권한이 없습니다. 연결 계정에 과제 폴더 편집 권한이 있는지 확인해 주세요. (" + code + ")"
					: code == 404 ? "드라이브에서 과제 폴더를 찾지 못했습니다. (404)" : "드라이브 업로드에 실패했습니다. (" + code + ")";
		}
		return "PDF 업로드·메일 발송에 실패했습니다. (" + e.getClass().getSimpleName() + ")";
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
		h.put("NOTE", note == null || note.length() <= 1000 ? note : note.substring(0, 1000));
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

	/** 그 달 연구팀 소속 연구원. 예: 홍길동(연구소장), 김철수(연구원) */
	private String members(Object teamSq, String ym) {
		StringBuilder b = new StringBuilder();
		for (Map<String, Object> r : mapper.selectMonthResearchers(teamSq, ym)) {
			b.append(b.length() > 0 ? ", " : "").append(r.get("STAFF_NM")).append("HEAD".equals(r.get("ROLE_CD")) ? "(연구소장)" : "(연구원)");
		}
		return b.toString();
	}

	// ── 규칙 ──

	static boolean inPeriod(String ym, String start, String end) {
		return ym.compareTo(start.substring(0, 7)) >= 0 && ym.compareTo(end.substring(0, 7)) <= 0;
	}

	/** hwp 양식과 같은 항목에 결재 단계 수만큼 결재란을 둔다. 드라이브가 이 HTML 을 구글 문서로 바꿔 PDF 로 내보낸다 */
	static String pdfHtml(Map<String, Object> j, List<Map<String, Object>> steps, List<Map<String, Object>> history) {
		String written = "", closer = "", closedAt = "";
		for (Map<String, Object> h : history) {
			if ("SUBMIT".equals(h.get("ACTION_CD"))) written = str(h.get("REG_DT"));
			if ("CLOSE".equals(h.get("ACTION_CD"))) { closer = str(h.get("ACTOR_NM")); closedAt = str(h.get("REG_DT")); }
		}
		String cell = "border:1px solid #000;padding:6px;", head = cell + "background-color:#eeeeee;font-weight:bold;text-align:center;";
		StringBuilder b = new StringBuilder("<html><head><meta charset=\"UTF-8\"></head><body>");
		b.append("<h1 style=\"text-align:center;\">월간 연구일지</h1>");
		StringBuilder r1 = new StringBuilder(td(head, "결재", "")), r2 = new StringBuilder(td(head, "서명", "")), r3 = new StringBuilder(td(head, "확인자", "")), r4 = new StringBuilder(td(head, "확인일시", ""));
		for (Map<String, Object> s : steps) {
			r1.append(td(head, str(s.get("STEP_NM")), ""));
			r2.append(signTd(cell, str(s.get("SIGN_IMG"))));
			r3.append(td(cell, str(s.get("DONE_NM")), ""));
			r4.append(td(cell, str(s.get("DONE_DT")), ""));
		}
		b.append("<table style=\"border-collapse:collapse;width:100%;\"><tr>").append(r1).append("</tr><tr>").append(r2).append("</tr><tr>").append(r3).append("</tr><tr>").append(r4).append("</tr></table><p></p>");
		b.append("<table style=\"border-collapse:collapse;width:100%;\">");
		String[][] rows = { { "작성자", str(j.get("WRITER_NM")) }, { "작성일", written }, { "대상 월", str(j.get("YM")) }, { "연구주제", str(j.get("PRJ_NM")) },
				{ "연구장소", str(j.get("PLACE")) }, { "연구기간", str(j.get("PERIOD")) }, { "연구인원", str(j.get("SNAP_MEMBERS")) }, { "마감", closer.isEmpty() ? "" : closer + " (" + closedAt + ")" } };
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
		return "<td style=\"" + style + "\"" + attr + ">" + esc(text).replace("\n", "<br>") + "</td>";
	}

	private static String esc(String s) {
		return HtmlUtils.htmlEscape(s);
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
