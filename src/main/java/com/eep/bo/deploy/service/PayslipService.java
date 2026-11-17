package com.eep.bo.deploy.service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.servlet.ServletContext;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import com.eep.bo.system.service.MailConfService;
import com.eep.mapper.BoPayslipMapper;

import common.util.RrnCipher;

/**
 * 급여명세서: 마감된 달의 급여대장 값으로 PDF 를 만들어(여는 암호 = 생년월일 8자리) 직원의 개인 메일로 보낸다.
 * 메일 문구는 이 화면에서, 보내는 계정·세무서 받는 주소는 시스템관리 › 메일 설정(MailConfService)에서 정한다.
 */
@Service
public class PayslipService {

	private static final String[][] PAY_LABELS = { { "BASE_AMT", "기본급" }, { "MEAL_AMT", "식대" }, { "RESEARCH_AMT", "연구비" }, { "DRIVE_AMT", "운전보조금" }, { "CHILD_AMT", "자녀보육수당" },
			{ "BONUS_AMT", "상여" }, { "FUEL_AMT", "유류비" } };
	private static final String[][] DED_LABELS = { { "NP_AMT", "국민연금" }, { "HI_AMT", "건강보험" }, { "LTC_AMT", "장기요양보험" }, { "EI_AMT", "고용보험" }, { "ACC_AMT", "산재보험" },
			{ "IT_AMT", "소득세" }, { "LIT_AMT", "지방소득세" }, { "NP_SETTLE", "국민연금 정산" }, { "HI_SETTLE", "건강보험 정산" }, { "EI_SETTLE", "고용보험 정산" }, { "LTC_SETTLE", "장기요양 정산" },
			{ "IT_SETTLE", "소득세 정산" }, { "LIT_SETTLE", "지방소득세 정산" }, { "MUTUAL_AMT", "상조회비" }, { "ETC_DED", "기타공제" } };
	/** 제목·본문에 넣을 수 있는 값. 금액은 일부러 없다: 본문에 금액이 보이면 PDF 에 암호를 건 의미가 없다 */
	static final List<String> VARS = Arrays.asList("성명", "귀속월", "지급일자", "부서", "직급", "회사명", "담당자 연락처");
	static final String COMPANY = "주식회사 이에스티소프트";
	static final String DEFAULT_SUBJECT = "[이에스티소프트] {귀속월} 급여명세서 - {성명}";
	static final String DEFAULT_BODY = "<p>{성명} 님, 안녕하세요.</p>"
			+ "<p>{귀속월} 급여명세서를 첨부해 드립니다.<br>지급일자는 <b>{지급일자}</b> 입니다.</p>"
			+ "<p style=\"background:#fff5dc;padding:6px 8px;border-radius:4px\">첨부 PDF 는 <b>생년월일 8자리</b>(예: 19900101)로 열 수 있습니다.</p>"
			+ "<p>문의: 경영지원팀 {담당자 연락처}</p>"
			+ "<hr><p style=\"color:#5f6b75;font-size:11px\">본 메일은 발신 전용입니다. 개인정보가 담긴 메일이니 다른 사람에게 전달하지 마세요.</p>";
	private static final Pattern VAR = Pattern.compile("\\{([^{}<>]{1,20})\\}");
	private static final Pattern EMAIL = Pattern.compile("[^@\\s<>\"]+@[^@\\s<>\"]+\\.[^@\\s<>\"]+");

	@Autowired
	private BoPayslipMapper mapper;

	@Autowired
	private BoPayrollService payroll;

	@Autowired
	private MailConfService mailConf;

	@Autowired
	private ServletContext servletContext;

	// ── 목록·명세서 ──

	/** 급여관리와 같은 사람 목록 + 명세서를 보낼 수 있는지(생년월일·메일) + 마지막 발송 */
	@SuppressWarnings("unchecked")
	public Map<String, Object> list(String ym) {
		Map<String, Object> month = payroll.month(ym);
		Map<String, Map<String, Object>> staff = staffInfo(), last = new HashMap<>();
		Map<String, Object> q = new HashMap<>();
		q.put("YM", ym);
		mapper.selectLastLogs(q).forEach(l -> last.put(str(l.get("STAFF_SQ")), l));
		List<Map<String, Object>> rows = new ArrayList<>();
		for (Map<String, Object> r : (List<Map<String, Object>>) month.get("rows")) {
			String sq = str(r.get("STAFF_SQ"));
			Map<String, Object> s = staff.getOrDefault(sq, new HashMap<>()), row = new HashMap<>();
			List<String> types = new ArrayList<>(), prj = new ArrayList<>();
			for (Map<String, Object> d : (List<Map<String, Object>>) r.get("DETAILS")) {
				types.add(str(d.get("DEPLOY_TYPE")));
				prj.add((str(d.get("CLIENT_NM")) + " " + str(d.get("PRJ_NM"))).trim());
			}
			for (String k : new String[] { "STAFF_SQ", "STAFF_NM", "EMP_TYPE_CD", "PAY_TOTAL", "DED_TOTAL", "NET" }) {
				row.put(k, r.get(k));
			}
			row.put("TYPES", types);
			row.put("PRJ", prj.isEmpty() ? "" : prj.get(0) + (prj.size() > 1 ? " 외 " + (prj.size() - 1) : ""));
			row.put("HAS_BIRTH", !birth8(s).isEmpty());
			row.put("EMAIL", str(s.get("EMAIL")).trim());
			row.put("LAST", last.get(sq));
			rows.add(row);
		}
		Map<String, Object> out = new HashMap<>();
		out.put("rows", rows);
		out.put("closed", month.get("closed"));
		out.put("PAY_DT", month.get("PAY_DT"));
		out.put("ready", "Y".equals(mailConf.accountInfo(MailConfService.PAYSLIP).get("VERIFIED_YN")));
		return out;
	}

	private Map<String, Map<String, Object>> staffInfo() {
		Map<String, Map<String, Object>> m = new HashMap<>();
		mapper.selectStaffInfo().forEach(s -> m.put(str(s.get("STAFF_SQ")), s));
		return m;
	}

	/** 주민번호에서 생년월일 8자리. 없거나 읽지 못하면 빈 값 */
	private static String birth8(Map<String, Object> staff) {
		String rrn = str(staff.get("RRN_ENC"));
		if (rrn.isEmpty()) {
			return "";
		}
		try {
			String b = BoPayrollService.birth(RrnCipher.isEncrypted(rrn) ? RrnCipher.decrypt(rrn) : rrn).replace("-", "");
			return b.matches("(18|19|20)\\d{6}") ? b : "";
		} catch (RuntimeException e) {
			return "";
		}
	}

	/** 한 사람의 명세서 내용. EMAIL·PASSWORD 는 발송용이라 PDF 에는 안 들어간다 */
	@SuppressWarnings("unchecked")
	public Map<String, Object> slip(String ym, Object staffSq) {
		Map<String, Object> month = payroll.month(ym), row = null;
		for (Map<String, Object> r : (List<Map<String, Object>>) month.get("rows")) {
			if (str(r.get("STAFF_SQ")).equals(str(staffSq))) {
				row = r;
			}
		}
		require(row != null, "그 달 급여가 없는 직원입니다.");
		Map<String, Object> s = staffInfo().getOrDefault(str(staffSq), new HashMap<>()), slip = new HashMap<>();
		String b = birth8(s);
		slip.put("YM", ym);
		slip.put("TITLE", Integer.parseInt(ym.substring(5)) + "월분 급여명세서");
		slip.put("NAME", str(row.get("STAFF_NM")));
		slip.put("BIRTH", b.isEmpty() ? "" : b.substring(0, 4) + "-" + b.substring(4, 6) + "-" + b.substring(6));
		slip.put("POSITION", str(s.get("POSITION_NM")));
		slip.put("JOIN_DT", str(s.get("JOIN_DT")));
		slip.put("PAY_DT", str(month.get("PAY_DT")));
		slip.put("DEPT", str(s.get("DEPT_NM")).isEmpty() ? str(s.get("ORG_NM")) : str(s.get("DEPT_NM")));
		slip.put("PAY", items(row, PAY_LABELS));
		slip.put("DED", items(row, DED_LABELS));
		slip.put("PAY_TOTAL", row.get("PAY_TOTAL"));
		slip.put("DED_TOTAL", row.get("DED_TOTAL"));
		slip.put("NET", row.get("NET"));
		slip.put("EMAIL", str(s.get("EMAIL")).trim());
		slip.put("PASSWORD", b);
		return slip;
	}

	/** 금액이 있는 항목만 */
	private static List<Object[]> items(Map<String, Object> row, String[][] labels) {
		List<Object[]> out = new ArrayList<>();
		for (String[] l : labels) {
			long v = BoPayrollService.n(row.get(l[0]));
			if (v != 0) {
				out.add(new Object[] { l[1], v });
			}
		}
		return out;
	}

	public byte[] pdf(Map<String, Object> slip, boolean locked) throws IOException {
		require(!locked || !str(slip.get("PASSWORD")).isEmpty(), slip.get("NAME") + "님은 인사카드에 주민번호가 없어 암호(생년월일)를 걸 수 없습니다.");
		return PayslipPdf.build(slip, logo(), locked ? str(slip.get("PASSWORD")) : null);
	}

	private byte[] logo() {
		try (InputStream in = servletContext.getResourceAsStream("/resources/img/logo.png")) {
			if (in == null) {
				return null;
			}
			ByteArrayOutputStream out = new ByteArrayOutputStream();
			byte[] buf = new byte[8192];
			for (int n; (n = in.read(buf)) > 0; ) {
				out.write(buf, 0, n);
			}
			return out.toByteArray();
		} catch (IOException e) {
			return null;
		}
	}

	public static String fileName(Map<String, Object> slip) {
		return Integer.parseInt(str(slip.get("YM")).substring(5)) + "월 이에스티_급여명세서_" + str(slip.get("NAME")).replaceAll("[\\\\/:*?\"<>|]", "") + ".pdf";
	}

	/** 고른 사람들의 암호 걸린 PDF 묶음. 주민번호가 없는 사람은 빠진다 */
	public byte[] zip(String ym, List<String> staffSqs) throws IOException {
		require(payroll.closed(ym), "마감된 달만 내려받을 수 있습니다.");
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		try (ZipOutputStream zip = new ZipOutputStream(out, java.nio.charset.StandardCharsets.UTF_8)) {
			for (String sq : staffSqs) {
				Map<String, Object> slip = slip(ym, sq);
				if (str(slip.get("PASSWORD")).isEmpty()) {
					continue;
				}
				zip.putNextEntry(new ZipEntry(fileName(slip)));
				zip.write(pdf(slip, true));
				zip.closeEntry();
			}
		}
		return out.toByteArray();
	}

	// ── 발송 ──

	/** 한 사람에게 보낸다. 결과는 발송 이력에 남고, 실패해도 예외 대신 { RESULT: FAIL, MSG } 로 돌려준다(여러 명을 이어서 보내므로) */
	public Map<String, Object> send(String ym, Object staffSq, String baseUrl, String loginId) {
		require(payroll.closed(ym), "마감된 달만 보낼 수 있습니다. 급여관리에서 먼저 마감해 주세요.");
		Map<String, Object> conf = conf(MailConfService.PAYSLIP);
		require("Y".equals(conf.get("VERIFIED_YN")), NOT_VERIFIED);
		Map<String, Object> slip = slip(ym, staffSq), log = new HashMap<>();
		String to = str(slip.get("EMAIL")), error = null;
		try {
			require(EMAIL.matcher(to).matches(), "인사카드에 개인 메일이 없습니다.");
			mail(MailConfService.PAYSLIP, conf, to, vars(slip, conf), fileName(slip), pdf(slip, true), baseUrl);
		} catch (IllegalArgumentException e) {
			error = e.getMessage();
		} catch (Exception e) {
			error = reason(e);
		}
		log.put("YM", ym);
		log.put("STAFF_SQ", staffSq);
		log.put("CHANNEL", "MAIL");
		log.put("TO_ADDR", to.isEmpty() ? null : to);
		log.put("RESULT", error == null ? "OK" : "FAIL");
		log.put("ERROR_MSG", error == null ? null : error.substring(0, Math.min(300, error.length())));
		log.put("EMPLY_ID", loginId);
		mapper.insertLog(log);
		Map<String, Object> out = new HashMap<>();
		out.put("RESULT", log.get("RESULT"));
		out.put("MSG", error);
		return out;
	}

	public List<Map<String, Object>> logs(String ym, Object staffSq) {
		Map<String, Object> q = new HashMap<>();
		q.put("YM", ym);
		q.put("STAFF_SQ", staffSq);
		return mapper.selectLogs(q);
	}

	private static Map<String, String> vars(Map<String, Object> slip, Map<String, Object> conf) {
		Map<String, String> v = new LinkedHashMap<>();
		String ym = str(slip.get("YM"));
		v.put("성명", str(slip.get("NAME")));
		v.put("귀속월", ym.substring(0, 4) + "년 " + Integer.parseInt(ym.substring(5)) + "월");
		v.put("지급일자", str(slip.get("PAY_DT")));
		v.put("부서", str(slip.get("DEPT")));
		v.put("직급", str(slip.get("POSITION")));
		v.put("회사명", COMPANY);
		v.put("담당자 연락처", str(conf.get("CONTACT")));
		return v;
	}

	static String fill(String template, Map<String, String> vars, boolean html) {
		String out = template;
		for (Map.Entry<String, String> e : vars.entrySet()) {
			out = out.replace("{" + e.getKey() + "}", html ? esc(e.getValue()) : e.getValue());
		}
		return out;
	}

	private static String esc(String s) {
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
	}

	static final String NOT_VERIFIED = "보내는 계정의 연결 확인이 안 됐습니다. 시스템관리 › 메일 설정에서 연결 확인을 먼저 해 주세요.";

	/** 메일 문구(이 화면) + 그 메일이 쓰는 계정(메일 설정): FROM_NM, FROM_ADDR, CONTACT, VERIFIED_YN … */
	private Map<String, Object> conf(String use) {
		Map<String, Object> c = mapper.selectConf(), a = mailConf.accountInfo(use);
		for (String k : new String[] { "FROM_NM", "FROM_ADDR", "REPLY_TO", "BCC", "CONTACT", "VERIFIED_YN", "VERIFIED_DT", "VERIFY_MSG", "ACC_NM" }) c.put(k, a.get(k));
		c.remove("APP_PW_ENC");
		return c;
	}

	/** 보내는 사람·답장·숨은참조는 메일 설정의 계정 값이 들어간다 */
	private void mail(String use, Map<String, Object> conf, String to, Map<String, String> vars, String fileName, byte[] pdf, String baseUrl) throws Exception {
		MailConfService.Mail m = mailConf.create(use, true);
		MimeMessageHelper h = m.h;
		h.setTo(to.split("\\s*,\\s*"));
		h.setSubject(fill(subject(conf), vars, false));
		// 본문 이미지·링크의 사이트 안 주소는 받는 사람이 열 수 있게 전체 주소로 바꾼다
		h.setText(fill(body(conf), vars, true).replaceAll("(?i)(src|href)=\"/(?!/)", "$1=\"" + Matcher.quoteReplacement(baseUrl) + "/"), true);
		h.addAttachment(fileName, new ByteArrayResource(pdf));
		mailConf.send(m);
	}

	private static String subject(Map<String, Object> conf) {
		return str(conf.get("SUBJECT")).isEmpty() ? DEFAULT_SUBJECT : str(conf.get("SUBJECT"));
	}

	private static String body(Map<String, Object> conf) {
		return str(conf.get("BODY")).isEmpty() ? DEFAULT_BODY : str(conf.get("BODY"));
	}

	/** 메일 오류를 사람 말로 */
	private static String reason(Throwable e) {
		return MailConfService.reason(e);
	}

	// ── 메일 문구 (보내는 계정은 시스템관리 › 메일 설정) ──

	/** 화면에 주는 설정: 문구 + 보내는 계정 요약(앱 비밀번호는 없다) */
	public Map<String, Object> conf() {
		Map<String, Object> c = conf(MailConfService.PAYSLIP);
		c.put("SUBJECT", subject(c));
		c.put("BODY", body(c));
		c.put("DEFAULT_SUBJECT", DEFAULT_SUBJECT);
		c.put("DEFAULT_BODY", DEFAULT_BODY);
		c.put("VARS", VARS);
		c.put("hist", mapper.selectConfHist());
		return c;
	}

	public void saveBody(String subject, String body, String loginId) {
		String s = str(subject).trim(), b = clean(str(body));
		require(!s.isEmpty() && s.length() <= 300, "제목을 1~300자로 입력해 주세요.");
		require(!b.replaceAll("(?s)<[^>]*>|&nbsp;|\\s", "").isEmpty() && b.length() <= 200000, "메일 내용을 입력해 주세요.");
		for (String text : new String[] { s, b }) {
			Matcher m = VAR.matcher(text);
			while (m.find()) {
				require(VARS.contains(m.group(1)), "쓸 수 없는 값입니다: {" + m.group(1) + "}. 금액은 본문에 넣을 수 없고(PDF 에만), 넣을 수 있는 값은 " + VARS + " 입니다.");
			}
		}
		Map<String, Object> q = new HashMap<>();
		q.put("SUBJECT", s);
		q.put("BODY", b);
		q.put("EMPLY_ID", loginId);
		mapper.updateConfBody(q);
		hist("BODY", "메일 내용 수정", s, b, loginId);
	}

	public void revertBody(Object histSq, String loginId) {
		Map<String, Object> q = new HashMap<>();
		q.put("HIST_SQ", histSq);
		Map<String, Object> h = mapper.selectConfHistOne(q);
		require(h != null, "그 버전을 찾지 못했습니다.");
		saveBody(str(h.get("SUBJECT")), str(h.get("BODY")), loginId);
	}

	public Map<String, Object> bodyVersion(Object histSq) {
		Map<String, Object> q = new HashMap<>();
		q.put("HIST_SQ", histSq);
		Map<String, Object> h = mapper.selectConfHistOne(q);
		require(h != null, "그 버전을 찾지 못했습니다.");
		return h;
	}

	/** 내 계정 메일(없으면 보내는 주소 자신)로 예시 값·예시 PDF(암호 19900101)를 실제로 보낸다. 저장하기 전 문구로도 보낼 수 있다 */
	public String testSend(String subject, String body, String baseUrl, String loginId) throws IOException {
		Map<String, Object> q = new HashMap<>();
		q.put("EMPLY_ID", loginId);
		Map<String, Object> conf = conf(MailConfService.PAYSLIP_TEST), slip = sample();
		String mine = str(mapper.selectEmplyEmail(q)).trim(), to = EMAIL.matcher(mine).matches() ? mine : str(conf.get("FROM_ADDR")); // 내 계정에 메일이 없으면 보내는 주소 자신에게
		require(EMAIL.matcher(to).matches(), "시스템관리 › 메일 설정에서 보내는 Gmail 주소를 먼저 넣어 주세요.");
		if (!str(subject).trim().isEmpty()) {
			conf.put("SUBJECT", str(subject).trim());
		}
		if (!str(body).trim().isEmpty()) {
			conf.put("BODY", clean(str(body)));
		}
		try {
			mail(MailConfService.PAYSLIP_TEST, conf, to, vars(slip, conf), fileName(slip), PayslipPdf.build(slip, logo(), "19900101"), baseUrl);
		} catch (IllegalArgumentException e) {
			throw e;
		} catch (Exception e) {
			throw new IllegalArgumentException(reason(e));
		}
		return to;
	}

	static Map<String, Object> sample() {
		Map<String, Object> slip = new HashMap<>();
		String ym = java.time.YearMonth.now().minusMonths(1).toString();
		slip.put("YM", ym);
		slip.put("TITLE", Integer.parseInt(ym.substring(5)) + "월분 급여명세서");
		slip.put("NAME", "김예시");
		slip.put("BIRTH", "1990-01-01");
		slip.put("POSITION", "선임");
		slip.put("JOIN_DT", "2025-03-02");
		slip.put("PAY_DT", java.time.YearMonth.now().atDay(15).toString());
		slip.put("DEPT", "개발팀");
		slip.put("PAY", Arrays.asList(new Object[] { "기본급", 4000000L }, new Object[] { "식대", 200000L }));
		slip.put("DED", Arrays.asList(new Object[] { "고용보험", 36000L }, new Object[] { "소득세", 120000L }, new Object[] { "지방소득세", 12000L }));
		slip.put("PAY_TOTAL", 4200000L);
		slip.put("DED_TOTAL", 168000L);
		slip.put("NET", 4032000L);
		return slip;
	}

	// ── 세무서 자료: 그해 1월~고른 달 급여 엑셀(달마다 시트)을 정해 둔 주소로 보낸다 ──

	static final List<String> TAX_VARS = Arrays.asList("귀속월", "회사명", "담당자 연락처");
	static final String TAX_SUBJECT = "[이에스티소프트] {귀속월} 급여 자료";
	static final String TAX_BODY = "<p>안녕하세요. {회사명} 입니다.</p>"
			+ "<p>{귀속월} 급여 자료를 첨부해 드립니다.<br>그해 1월부터 {귀속월}까지 달마다 시트로 담았고, 전월과 달라진 칸은 노란색으로 표시했습니다.</p>"
			+ "<p>문의: 경영지원팀 {담당자 연락처}</p>";

	public static String taxFileName(String ym) {
		return "이에스티_" + ym.substring(0, 4) + "년_급여관리_" + Integer.parseInt(ym.substring(5)) + "월.xlsx";
	}

	/** hide: 이 사람을 빼야 하는지(시크릿 직원을 시크릿이 아닌 계정이 받을 때) */
	@SuppressWarnings("unchecked")
	public byte[] taxExcel(String ym, java.util.function.Predicate<Object> hide) throws IOException {
		java.time.YearMonth end = java.time.YearMonth.parse(ym), m = end.withMonth(1);
		Map<String, Map<String, Object>> staff = staffInfo();
		staff.values().forEach(s -> {
			String rrn = str(s.remove("RRN_ENC"));
			try {
				s.put("RRN", RrnCipher.isEncrypted(rrn) ? RrnCipher.decrypt(rrn) : rrn);
			} catch (RuntimeException e) {
				s.put("RRN", "");
			}
		});
		List<TaxExcel.Line> prev = taxLines(m.minusMonths(1).toString(), staff, hide);
		List<Map<String, Object>> months = new ArrayList<>();
		for (; !m.isAfter(end); m = m.plusMonths(1)) {
			List<TaxExcel.Line> cur = taxLines(m.toString(), staff, hide);
			TaxExcel.compare(cur, prev);
			prev = cur;
			Map<String, Object> mo = new HashMap<>();
			mo.put("YM", m.toString());
			mo.put("CLOSED", payroll.closed(m.toString()));
			mo.put("LINES", cur);
			months.add(0, mo); // 최근 달이 맨 앞
		}
		return TaxExcel.build(months);
	}

	@SuppressWarnings("unchecked")
	private List<TaxExcel.Line> taxLines(String ym, Map<String, Map<String, Object>> staff, java.util.function.Predicate<Object> hide) {
		List<Map<String, Object>> rows = new ArrayList<>((List<Map<String, Object>>) payroll.month(ym).get("rows"));
		rows.removeIf(r -> hide.test(r.get("STAFF_SQ")));
		return TaxExcel.lines(ym, rows, staff);
	}

	public Map<String, Object> taxConf() {
		Map<String, Object> c = mapper.selectTaxConf(), out = new HashMap<>();
		c = c == null ? new HashMap<>() : c;
		Map<String, Object> mail = mailConf.accountInfo(MailConfService.TAX);
		out.put("TO_ADDR", String.join(", ", mailConf.to(MailConfService.TAX))); // 받는 주소는 메일 설정에서 정한다
		out.put("ACC_NM", mail.get("ACC_NM"));
		out.put("SUBJECT", str(c.get("SUBJECT")).isEmpty() ? TAX_SUBJECT : c.get("SUBJECT"));
		out.put("BODY", str(c.get("BODY")).isEmpty() ? TAX_BODY : c.get("BODY"));
		out.put("REG_DT", c.get("REG_DT"));
		out.put("DEFAULT_SUBJECT", TAX_SUBJECT);
		out.put("DEFAULT_BODY", TAX_BODY);
		out.put("VARS", TAX_VARS);
		out.put("FROM_NM", mail.get("FROM_NM"));
		out.put("FROM_ADDR", mail.get("FROM_ADDR"));
		out.put("CONTACT", mail.get("CONTACT"));
		out.put("ready", "Y".equals(mail.get("VERIFIED_YN")));
		out.put("logs", mapper.selectTaxLogs());
		return out;
	}

	/** 문구만 저장한다. 이력 SUMMARY 에는 저장할 때의 받는 주소를 남긴다(받는 주소는 메일 설정) */
	public void saveTaxConf(String subject, String body, String loginId) {
		String to = String.join(", ", mailConf.to(MailConfService.TAX)), s = str(subject).trim(), b = clean(str(body));
		require(!s.isEmpty() && s.length() <= 300, "제목을 1~300자로 입력해 주세요.");
		require(!b.replaceAll("(?s)<[^>]*>|&nbsp;|\\s", "").isEmpty() && b.length() <= 200000, "메일 내용을 입력해 주세요.");
		for (String text : new String[] { s, b }) {
			Matcher m = VAR.matcher(text);
			while (m.find()) {
				require(TAX_VARS.contains(m.group(1)), "쓸 수 없는 값입니다: {" + m.group(1) + "}. 넣을 수 있는 값은 " + TAX_VARS + " 입니다.");
			}
		}
		hist("TAX", to.isEmpty() ? "-" : to, s, b, loginId);
	}

	/** 마감된 달만. 결과는 발송 이력(CHANNEL TAX)에 남기고, 실패하면 이유를 오류로 돌려준다 */
	public String sendTax(String ym, String baseUrl, String loginId, java.util.function.Predicate<Object> hide) throws IOException {
		require(payroll.closed(ym), "마감된 달만 보낼 수 있습니다. 급여관리에서 먼저 마감해 주세요(내려받기는 언제든 됩니다).");
		Map<String, Object> conf = conf(MailConfService.TAX), tax = mapper.selectTaxConf();
		require("Y".equals(conf.get("VERIFIED_YN")), NOT_VERIFIED);
		String to = String.join(", ", mailConf.to(MailConfService.TAX)), error = null;
		require(!to.isEmpty(), "받는 주소가 없습니다. 시스템관리 › 메일 설정의 '세무서 급여 자료'에서 넣어 주세요.");
		conf.put("SUBJECT", tax == null || str(tax.get("SUBJECT")).isEmpty() ? TAX_SUBJECT : tax.get("SUBJECT"));
		conf.put("BODY", tax == null || str(tax.get("BODY")).isEmpty() ? TAX_BODY : tax.get("BODY"));
		Map<String, String> v = new LinkedHashMap<>();
		v.put("귀속월", ym.substring(0, 4) + "년 " + Integer.parseInt(ym.substring(5)) + "월");
		v.put("회사명", COMPANY);
		v.put("담당자 연락처", str(conf.get("CONTACT")));
		byte[] xlsx = taxExcel(ym, hide);
		try {
			mail(MailConfService.TAX, conf, to, v, taxFileName(ym), xlsx, baseUrl);
		} catch (IllegalArgumentException e) {
			error = e.getMessage();
		} catch (Exception e) {
			error = reason(e);
		}
		Map<String, Object> log = new HashMap<>();
		log.put("YM", ym);
		log.put("STAFF_SQ", 0);
		log.put("CHANNEL", "TAX");
		log.put("TO_ADDR", to.substring(0, Math.min(200, to.length())));
		log.put("RESULT", error == null ? "OK" : "FAIL");
		log.put("ERROR_MSG", error == null ? null : error.substring(0, Math.min(300, error.length())));
		log.put("EMPLY_ID", loginId);
		mapper.insertLog(log);
		require(error == null, error);
		return to;
	}

	/** 급여 담당자만 쓰는 칸이지만, 메일로 나가므로 스크립트·폼·이벤트 속성은 걸러 낸다 */
	static String clean(String html) {
		return html.replaceAll("(?is)<(script|iframe|object|embed|form|style)\\b[^>]*>.*?</\\1\\s*>", "")
				.replaceAll("(?is)<(script|iframe|object|embed|form|input|link|meta|style)\\b[^>]*>", "")
				.replaceAll("(?i)\\son\\w+\\s*=\\s*(\"[^\"]*\"|'[^']*'|[^\\s>]+)", "")
				.replaceAll("(?i)javascript\\s*:", "");
	}

	private void hist(String kind, String summary, String subject, String body, String loginId) {
		Map<String, Object> q = new HashMap<>();
		q.put("KIND_CD", kind);
		q.put("SUMMARY", summary.substring(0, Math.min(500, summary.length())));
		q.put("SUBJECT", subject);
		q.put("BODY", body);
		q.put("EMPLY_ID", loginId);
		mapper.insertConfHist(q);
	}

	private static String str(Object v) {
		return Objects.toString(v, "");
	}

	private static void require(boolean ok, String message) {
		if (!ok) {
			throw new IllegalArgumentException(message);
		}
	}
}
