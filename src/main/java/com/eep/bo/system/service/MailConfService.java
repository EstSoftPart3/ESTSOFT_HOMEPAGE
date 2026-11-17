package com.eep.bo.system.service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Properties;
import java.util.regex.Pattern;

import javax.mail.AuthenticationFailedException;
import javax.mail.MessagingException;
import javax.mail.Transport;
import javax.mail.internet.MimeMessage;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailAuthenticationException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import com.eep.mapper.BoMailMapper;

import common.util.RrnCipher;

/**
 * 홈페이지가 보내는 모든 메일의 보내는 계정과 받는 사람(시스템관리 › 메일 설정, plans/mail-conf-spec-3.html).
 * 메일을 보내는 곳은 create(메일 코드) 로 보내는 사람·답장·숨은참조가 채워진 메시지를 받아 받는 사람·제목·내용만 넣고 send 한다.
 * 1번 계정(기본)에 앱 비밀번호가 없으면 서버 설정 파일의 계정(mailSender 빈)으로 보낸다. 앱 비밀번호는 이 클래스 밖으로 내보내지 않는다.
 */
@Service
public class MailConfService {

	public static final String APPLY = "APPLY", CONSULT = "CONSULT", SIGNUP = "SIGNUP", GRANT_REQ = "GRANT_REQ", GRANT = "GRANT", PAYSLIP = "PAYSLIP", PAYSLIP_TEST = "PAYSLIP_TEST",
			TAX = "TAX", LAB_REQ = "LAB_REQ", LAB_RESEND = "LAB_RESEND", LAB_CLOSE = "LAB_CLOSE", LAB_CEO = "LAB_CEO";

	/** 메일 목록: 코드, 묶음, 이름, 언제, 받는 사람(null 이면 화면에서 정한다) */
	static final String[][] USES = {
			{ APPLY, "홈페이지(외부)", "입사지원 알림", "입사지원 제출", null },
			{ CONSULT, "홈페이지(외부)", "컨설팅 문의 알림", "컨설팅 문의 제출", null },
			{ SIGNUP, "홈페이지(외부)", "가입 인증번호", "직원 가입", "가입하는 직원 회사 메일" },
			{ GRANT_REQ, "계정", "권한 발급 요청", "직원 가입 완료", "슈퍼관리자 전원" },
			{ GRANT, "계정", "권한 발급 안내", "권한 생김·계정 발급", "본인 회사 메일" },
			{ PAYSLIP, "급여", "급여명세서", "명세서 발송", "직원 인사카드 개인 메일" },
			{ PAYSLIP_TEST, "급여", "명세서 시험 발송", "급여 ⚙ 시험 발송", "내 계정 메일" },
			{ TAX, "급여", "세무서 급여 자료", "세무서 자료 발송", null },
			{ LAB_REQ, "연구일지", "승인 요청", "제출·단계 승인", "다음 결재자" },
			{ LAB_RESEND, "연구일지", "승인 요청 다시 보내기", "상세 버튼", "지금 결재자" },
			{ LAB_CLOSE, "연구일지", "마감 메일", "마감 후 드라이브 업로드", "그 달 연구원" },
			{ LAB_CEO, "연구일지", "대표 참조", "마감 메일과 함께", "결재라인 '대표' 단계" } };
	private static final Pattern EMAIL = Pattern.compile("[^@\\s<>\",]+@[^@\\s<>\",]+\\.[^@\\s<>\",]+");
	private static final String DEFAULT_FROM_NM = "주식회사 이에스티소프트";

	@Autowired
	private BoMailMapper mapper;
	@Autowired
	private JavaMailSender serverSender;
	@Value("${mail.username}")
	private String serverAddr;

	// ── 보내기 ──

	/** 보낼 메시지. h 에 받는 사람·제목·내용·첨부를 넣고 send 에 넘긴다 */
	public static class Mail {
		public final MimeMessageHelper h;
		final JavaMailSender sender;
		final Object accSq;

		Mail(MimeMessageHelper h, JavaMailSender sender, Object accSq) {
			this.h = h;
			this.sender = sender;
			this.accSq = accSq;
		}
	}

	public Mail create(String use, boolean multipart) throws MessagingException {
		Map<String, Object> a = account(use);
		JavaMailSender s = sender(a);
		MimeMessage message = s.createMimeMessage();
		MimeMessageHelper h = new MimeMessageHelper(message, multipart, "UTF-8");
		try {
			h.setFrom(fromAddr(a), str(a.get("FROM_NM")).isEmpty() ? DEFAULT_FROM_NM : str(a.get("FROM_NM")));
		} catch (java.io.UnsupportedEncodingException e) {
			h.setFrom(fromAddr(a));
		}
		if (!str(a.get("REPLY_TO")).isEmpty()) h.setReplyTo(str(a.get("REPLY_TO")));
		if (!str(a.get("BCC")).isEmpty()) h.setBcc(str(a.get("BCC")));
		return new Mail(h, s, a.get("ACC_SQ"));
	}

	/** Gmail 로그인이 거부되면 그 계정의 연결 상태를 '실패'로 바꿔 메일 설정 화면에 보이게 한다 */
	public void send(Mail m) {
		try {
			m.sender.send(m.h.getMimeMessage());
		} catch (RuntimeException e) {
			if (authFailed(e)) markFailed(m.accSq, reason(e));
			throw e;
		}
	}

	/** 화면에서 정한 받는 사람(계정은 지금 계정 메일로 바꾼다). 없으면 빈 배열 */
	public String[] to(String use) {
		List<String> out = new ArrayList<>();
		for (Map<String, Object> t : resolve(toList(use))) {
			String addr = str(t.get("EMAIL"));
			if (!addr.isEmpty() && !out.contains(addr)) out.add(addr);
		}
		return out.toArray(new String[0]);
	}

	/** 그 메일이 쓰는 계정(앱 비밀번호 제외): ACC_NM, FROM_NM, FROM_ADDR, REPLY_TO, BCC, CONTACT, VERIFIED_YN, VERIFIED_DT, VERIFY_MSG */
	public Map<String, Object> accountInfo(String use) {
		Map<String, Object> a = account(use);
		Map<String, Object> out = new HashMap<>(a);
		out.remove("APP_PW_ENC");
		out.put("FROM_ADDR", fromAddr(a));
		return out;
	}

	private Map<String, Object> account(String use) {
		Map<String, Object> a = mapper.selectAccountOfUse(use);
		if (a == null) throw new IllegalArgumentException("메일 설정에 '" + use + "' 메일이 없습니다. 시스템관리 › 메일 설정을 확인해 주세요.");
		return a;
	}

	/** 1번 계정에 앱 비밀번호가 없으면 서버 설정 파일 계정 */
	private boolean server(Map<String, Object> a) {
		return "1".equals(str(a.get("ACC_SQ"))) && str(a.get("APP_PW_ENC")).isEmpty();
	}

	private String fromAddr(Map<String, Object> a) {
		return server(a) ? serverAddr : str(a.get("FROM_ADDR"));
	}

	private JavaMailSender sender(Map<String, Object> a) {
		if (server(a)) return serverSender;
		if (str(a.get("FROM_ADDR")).isEmpty() || str(a.get("APP_PW_ENC")).isEmpty()) {
			throw new IllegalArgumentException("'" + a.get("ACC_NM") + "' 계정의 Gmail 주소와 앱 비밀번호를 시스템관리 › 메일 설정에서 먼저 넣어 주세요.");
		}
		JavaMailSenderImpl s = new JavaMailSenderImpl();
		s.setHost("smtp.gmail.com");
		s.setPort(587);
		s.setUsername(str(a.get("FROM_ADDR")));
		s.setPassword(RrnCipher.decrypt(str(a.get("APP_PW_ENC"))));
		Properties p = new Properties();
		p.put("mail.transport.protocol", "smtp");
		p.put("mail.smtp.auth", "true");
		p.put("mail.smtp.starttls.enable", "true");
		p.put("mail.smtp.ssl.trust", "smtp.gmail.com");
		p.put("mail.smtp.ssl.protocols", "TLSv1.2");
		p.put("mail.smtp.connectiontimeout", "10000");
		p.put("mail.smtp.timeout", "20000");
		s.setJavaMailProperties(p);
		return s;
	}

	private static boolean authFailed(Throwable e) {
		for (Throwable t = e; t != null; t = t.getCause()) {
			if (t instanceof AuthenticationFailedException || t instanceof MailAuthenticationException) return true;
		}
		return false;
	}

	/** 메일 오류를 사람 말로 */
	public static String reason(Throwable e) {
		for (Throwable t = e; t != null; t = t.getCause()) {
			if (t instanceof AuthenticationFailedException || t instanceof MailAuthenticationException) {
				return "Gmail 로그인에 실패했습니다. 앱 비밀번호가 틀렸거나, 2단계 인증·앱 비밀번호가 설정되지 않았습니다.";
			}
			if (t instanceof java.net.UnknownHostException || t instanceof java.net.ConnectException || t instanceof java.net.SocketTimeoutException) {
				return "메일 서버에 연결할 수 없습니다. 잠시 뒤 다시 해 주세요.";
			}
			if (t instanceof javax.mail.SendFailedException) {
				return "받는 주소로 보낼 수 없습니다. 주소를 확인해 주세요.";
			}
			if (t instanceof IllegalArgumentException && t.getMessage() != null) return t.getMessage();
		}
		System.out.println("MAIL_ERROR " + e.getClass().getSimpleName());
		return "보내지 못했습니다. (" + e.getClass().getSimpleName() + ")";
	}

	private void markFailed(Object accSq, String msg) {
		try {
			Map<String, Object> q = new HashMap<>();
			q.put("ACC_SQ", accSq);
			q.put("VERIFIED_YN", "N");
			q.put("VERIFY_MSG", msg);
			mapper.updateVerified(q);
		} catch (RuntimeException ignore) {
			// 상태 기록 실패가 원래 오류를 가리지 않게
		}
	}

	// ── 화면 ──

	/** 메일 목록 + 계정 목록 + 이력 건수 */
	public Map<String, Object> screen() {
		Map<String, Map<String, Object>> accs = new LinkedHashMap<>();
		for (Map<String, Object> a : mapper.selectAccounts()) {
			Map<String, Object> v = new HashMap<>(a);
			v.put("HAS_PW", !str(v.remove("APP_PW_ENC")).isEmpty());
			v.put("SERVER", server(a));
			v.put("FROM_ADDR", fromAddr(a));
			v.put("USE_CNT", 0);
			accs.put(str(a.get("ACC_SQ")), v);
		}
		Map<String, Map<String, Object>> saved = new HashMap<>();
		for (Map<String, Object> u : mapper.selectUses()) saved.put(str(u.get("USE_CD")), u);
		List<Map<String, Object>> uses = new ArrayList<>();
		for (String[] d : USES) {
			Map<String, Object> u = saved.get(d[0]);
			if (u == null) continue;
			Map<String, Object> v = new LinkedHashMap<>();
			v.put("USE_CD", d[0]);
			v.put("GRP", d[1]);
			v.put("NM", d[2]);
			v.put("WHEN", d[3]);
			v.put("AUTO_TO", d[4]);
			v.put("ACC_SQ", u.get("ACC_SQ"));
			v.put("TO", d[4] == null ? resolve(str(u.get("TO_LIST"))) : null);
			Map<String, Object> a = accs.get(str(u.get("ACC_SQ")));
			if (a != null) a.put("USE_CNT", (Integer) a.get("USE_CNT") + 1);
			uses.add(v);
		}
		Map<String, Object> out = new HashMap<>();
		out.put("uses", uses);
		out.put("accounts", new ArrayList<>(accs.values()));
		out.put("histCnt", mapper.selectHist().size());
		return out;
	}

	public List<Map<String, Object>> users() {
		return mapper.selectUsers();
	}

	public List<Map<String, Object>> hist() {
		return mapper.selectHist();
	}

	private String toList(String use) {
		for (Map<String, Object> u : mapper.selectUses()) if (use.equals(u.get("USE_CD"))) return str(u.get("TO_LIST"));
		return "";
	}

	/** 저장된 받는 사람 → [{V: 저장값, ID, NM, EMAIL, MISSING}] (주소는 V=EMAIL, 계정은 지금 메일) */
	List<Map<String, Object>> resolve(String toList) {
		List<String> tokens = new ArrayList<>(), ids = new ArrayList<>();
		for (String t : str(toList).split("\\s*,\\s*")) {
			if (!t.isEmpty() && !tokens.contains(t)) {
				tokens.add(t);
				if (!t.contains("@")) ids.add(t);
			}
		}
		Map<String, Map<String, Object>> users = new HashMap<>();
		if (!ids.isEmpty()) for (Map<String, Object> u : mapper.selectUserMails(ids)) users.put(str(u.get("EMPLY_ID")), u);
		List<Map<String, Object>> out = new ArrayList<>();
		for (String t : tokens) {
			Map<String, Object> v = new HashMap<>();
			v.put("V", t);
			if (t.contains("@")) {
				v.put("EMAIL", t);
			} else {
				Map<String, Object> u = users.get(t);
				v.put("ID", t);
				v.put("NM", u == null ? t : u.get("EMPLY_NM"));
				v.put("EMAIL", u == null ? null : u.get("EMAIL"));
				v.put("MISSING", u == null ? "계정 없음" : u.get("EMAIL") == null ? "메일 없음" : null);
			}
			out.add(v);
		}
		return out;
	}

	/**
	 * 팝업 저장: 계정(ACC_SQ 가 NEW 면 새로 만든다)의 칸과, 그 메일의 보내는 계정·받는 사람.
	 * @return 저장된 ACC_SQ
	 */
	public Object save(Map<String, Object> p, String loginId) {
		String use = str(p.get("USE_CD"));
		String[] def = def(use);
		Object accSq = saveAccount(p, loginId);
		Map<String, Object> cur = null;
		for (Map<String, Object> u : mapper.selectUses()) if (use.equals(u.get("USE_CD"))) cur = u;
		require(cur != null, "메일을 찾지 못했습니다.");
		String to = def[4] == null ? cleanTo(str(p.get("TO_LIST"))) : null;
		if (def[4] == null) require(!to.isEmpty(), "받는 사람을 한 명 이상 넣어 주세요.");
		List<String> changed = new ArrayList<>();
		if (!str(accSq).equals(str(cur.get("ACC_SQ")))) changed.add("보내는 계정 " + accName(cur.get("ACC_SQ")) + " → " + accName(accSq));
		if (def[4] == null) {
			List<String> before = Arrays.asList(str(cur.get("TO_LIST")).split("\\s*,\\s*")), after = Arrays.asList(to.split(","));
			List<String> diff = new ArrayList<>();
			for (String t : after) if (!t.isEmpty() && !before.contains(t)) diff.add("+ " + t);
			for (String t : before) if (!t.isEmpty() && !after.contains(t)) diff.add("- " + t);
			if (!diff.isEmpty()) changed.add("받는 사람 " + String.join(", ", diff));
		}
		if (changed.isEmpty()) return accSq;
		Map<String, Object> q = new HashMap<>();
		q.put("USE_CD", use);
		q.put("ACC_SQ", accSq);
		q.put("TO_LIST", to);
		q.put("EMPLY_ID", loginId);
		mapper.updateUse(q);
		hist(def[2], String.join(" · ", changed), loginId);
		return accSq;
	}

	/** 받는 사람 칸: 주소는 형식 확인, 계정 아이디는 있는지 확인. 1~10개 */
	String cleanTo(String raw) {
		List<String> out = new ArrayList<>(), ids = new ArrayList<>();
		for (String t : raw.split("[,;\\s]+")) {
			if (t.isEmpty() || out.contains(t)) continue;
			if (t.contains("@")) require(EMAIL.matcher(t).matches(), "받는 주소를 확인해 주세요: " + t);
			else ids.add(t);
			out.add(t);
		}
		require(out.size() <= 10, "받는 사람은 10명까지입니다.");
		if (!ids.isEmpty()) {
			List<Map<String, Object>> found = mapper.selectUserMails(ids);
			for (String id : ids) require(found.stream().anyMatch(u -> id.equals(u.get("EMPLY_ID")) && u.get("EMAIL") != null), "메일이 없는 계정입니다: " + id);
		}
		String joined = String.join(",", out);
		require(joined.length() <= 1000, "받는 사람이 너무 깁니다.");
		return joined;
	}

	private Object saveAccount(Map<String, Object> p, String loginId) {
		boolean isNew = "NEW".equals(str(p.get("ACC_SQ")));
		Map<String, Object> cur = null;
		if (!isNew) {
			for (Map<String, Object> a : mapper.selectAccounts()) if (str(a.get("ACC_SQ")).equals(str(p.get("ACC_SQ")))) cur = a;
			require(cur != null, "보내는 계정을 골라 주세요.");
		}
		String accNm = str(p.get("ACC_NM")).trim(), name = str(p.get("FROM_NM")).trim(), addr = str(p.get("FROM_ADDR")).trim(), reply = str(p.get("REPLY_TO")).trim(),
				bcc = str(p.get("BCC")).trim(), contact = str(p.get("CONTACT")).trim(), pw = str(p.get("APP_PW")).replaceAll("\\s", "");
		boolean first = !isNew && "1".equals(str(cur.get("ACC_SQ")));
		require(!accNm.isEmpty() && accNm.length() <= 50, "계정 이름을 1~50자로 입력해 주세요.");
		require(!name.isEmpty() && name.length() <= 100, "보내는 사람 이름을 1~100자로 입력해 주세요.");
		require(pw.isEmpty() || pw.matches("[A-Za-z]{16}"), "앱 비밀번호는 영문 16자리입니다(띄어쓰기는 빼도 됩니다). Google 계정 로그인 비밀번호가 아닙니다.");
		boolean hasPw = !pw.isEmpty() || (cur != null && !str(cur.get("APP_PW_ENC")).isEmpty());
		// 1번 계정은 앱 비밀번호 없이 서버 설정 파일 계정으로 보낼 수 있다(주소는 그 계정으로 고정)
		if (first && !hasPw) addr = "";
		else {
			require(EMAIL.matcher(addr).matches() && addr.length() <= 200, "보내는 Gmail 주소를 확인해 주세요.");
			require(hasPw, "앱 비밀번호를 입력해 주세요.");
		}
		require(reply.isEmpty() || EMAIL.matcher(reply).matches(), "답장 받을 주소를 확인해 주세요.");
		require(bcc.isEmpty() || EMAIL.matcher(bcc).matches(), "숨은 참조 주소를 확인해 주세요.");
		require(contact.length() <= 100, "담당자 연락처는 100자까지입니다.");
		for (Map<String, Object> a : mapper.selectAccounts()) {
			require(isNew ? !accNm.equals(a.get("ACC_NM")) : !accNm.equals(a.get("ACC_NM")) || str(a.get("ACC_SQ")).equals(str(cur.get("ACC_SQ"))), "같은 이름의 계정이 있습니다: " + accNm);
		}
		Map<String, Object> q = new HashMap<>();
		q.put("ACC_NM", accNm);
		q.put("FROM_NM", name);
		q.put("FROM_ADDR", addr);
		q.put("REPLY_TO", reply);
		q.put("BCC", bcc);
		q.put("CONTACT", contact);
		q.put("APP_PW_ENC", pw.isEmpty() ? null : RrnCipher.encrypt(pw));
		q.put("EMPLY_ID", loginId);
		if (isNew) {
			mapper.insertAccount(q);
			hist(accNm + " 계정", "새 계정 " + addr, loginId);
			return q.get("ACC_SQ");
		}
		List<String> changed = new ArrayList<>();
		if (!accNm.equals(str(cur.get("ACC_NM")))) changed.add("이름 " + cur.get("ACC_NM") + " → " + accNm);
		if (!addr.equals(str(cur.get("FROM_ADDR")))) changed.add("주소 " + (str(cur.get("FROM_ADDR")).isEmpty() ? "서버 설정" : cur.get("FROM_ADDR")) + " → " + (addr.isEmpty() ? "서버 설정" : addr));
		if (!name.equals(str(cur.get("FROM_NM")))) changed.add("보내는 이름");
		if (!pw.isEmpty()) changed.add("앱 비밀번호 변경");
		if (!reply.equals(str(cur.get("REPLY_TO"))) || !bcc.equals(str(cur.get("BCC"))) || !contact.equals(str(cur.get("CONTACT")))) changed.add("답장·숨은참조·연락처");
		if (changed.isEmpty()) return cur.get("ACC_SQ");
		q.put("ACC_SQ", cur.get("ACC_SQ"));
		q.put("RESET_VERIFIED", !pw.isEmpty() || !addr.equals(str(cur.get("FROM_ADDR")))); // 계정이 바뀌면 연결을 다시 확인해야 한다
		mapper.updateAccount(q);
		hist(accNm + " 계정", String.join(", ", changed), loginId);
		return cur.get("ACC_SQ");
	}

	/** Gmail 에 로그인만 해 본다. 결과는 계정 연결 상태와 이력에 남기고, 실패면 이유를 오류로 돌려준다 */
	public void verify(Object accSq, String loginId) {
		Map<String, Object> a = null;
		for (Map<String, Object> x : mapper.selectAccounts()) if (str(x.get("ACC_SQ")).equals(str(accSq))) a = x;
		require(a != null, "계정을 찾지 못했습니다.");
		String error = null;
		try {
			JavaMailSender js = sender(a);
			JavaMailSenderImpl s = (JavaMailSenderImpl) js;
			Transport t = s.getSession().getTransport("smtp");
			try {
				t.connect(s.getHost(), s.getPort(), s.getUsername(), s.getPassword());
			} finally {
				t.close();
			}
		} catch (MessagingException | RuntimeException e) {
			error = reason(e);
		}
		Map<String, Object> q = new HashMap<>();
		q.put("ACC_SQ", a.get("ACC_SQ"));
		q.put("VERIFIED_YN", error == null ? "Y" : "N");
		q.put("VERIFY_MSG", error);
		mapper.updateVerified(q);
		hist(a.get("ACC_NM") + " 계정", error == null ? "연결 확인 성공" : "연결 확인 실패: " + error, loginId);
		require(error == null, error);
	}

	/** 전체 연결 확인. @return 실패한 계정 이름들 */
	public List<String> verifyAll(String loginId) {
		List<String> failed = new ArrayList<>();
		for (Map<String, Object> a : mapper.selectAccounts()) {
			try {
				verify(a.get("ACC_SQ"), loginId);
			} catch (IllegalArgumentException e) {
				failed.add(str(a.get("ACC_NM")));
			}
		}
		return failed;
	}

	/** 그 메일의 계정으로 내 계정 메일(없으면 보내는 주소 자신)에 시험 메일 1통. @return 받은 주소 */
	public String test(String use, String loginId) {
		String[] def = def(use);
		String mine = str(mapper.selectMyMail(loginId));
		try {
			Mail m = create(use, false);
			String to = EMAIL.matcher(mine).matches() ? mine : str(accountInfo(use).get("FROM_ADDR"));
			m.h.setTo(to);
			m.h.setSubject("[이에스티소프트] 메일 설정 시험 - " + def[2]);
			m.h.setText("메일 설정의 시험 메일입니다.\n\n메일: " + def[2] + "\n보내는 계정: " + accountInfo(use).get("ACC_NM") + " <" + accountInfo(use).get("FROM_ADDR") + ">\n\n이 메일이 왔으면 이 메일의 보내는 설정은 정상입니다.");
			send(m);
			hist(def[2], "시험 메일 → " + to, loginId);
			return to;
		} catch (IllegalArgumentException e) {
			throw e;
		} catch (Exception e) {
			throw new IllegalArgumentException(reason(e));
		}
	}

	private String accName(Object accSq) {
		for (Map<String, Object> a : mapper.selectAccounts()) if (str(a.get("ACC_SQ")).equals(str(accSq))) return str(a.get("ACC_NM"));
		return str(accSq);
	}

	private static String[] def(String use) {
		for (String[] d : USES) if (d[0].equals(use)) return d;
		throw new IllegalArgumentException("알 수 없는 메일입니다.");
	}

	private void hist(String target, String summary, String loginId) {
		Map<String, Object> q = new HashMap<>();
		q.put("TARGET", target.substring(0, Math.min(100, target.length())));
		q.put("SUMMARY", summary.substring(0, Math.min(500, summary.length())));
		q.put("EMPLY_ID", loginId);
		mapper.insertHist(q);
	}

	private static String str(Object v) {
		return Objects.toString(v, "");
	}

	private static void require(boolean ok, String message) {
		if (!ok) throw new IllegalArgumentException(message);
	}
}
