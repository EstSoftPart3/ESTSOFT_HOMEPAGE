package com.eep.fo.signup.service;

import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.mail.internet.MimeMessage;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import com.eep.bo.member.service.BoMemberService;
import com.eep.mapper.BoMemberMapper;

import common.util.RrnCipher;

/**
 * 직원 본인 가입: 인사정보 4항목 일치 → 본인 선택 → 회사 메일 입력·인증 → 회사 메일 앞부분으로 계정 발급.
 * 진행 상태는 세션에만 두고, 시도 제한은 세션을 새로 열어 우회하지 못하게 서버 전체에서 센다.
 */
@Service
public class SignupService {

	private static final String STATE = "signupState";
	private static final long WINDOW = 10 * 60 * 1000L, RESEND = 60 * 1000L;
	private static final int LIMIT = 5;
	private static final String MISMATCH = "입력한 정보로 직원을 찾지 못했습니다. 입력값을 확인하거나 인사 담당자에게 문의해 주세요.";
	private static final String RESTART = "입력 시간이 지났습니다. 처음부터 다시 진행해 주세요.";
	private static final SecureRandom RANDOM = new SecureRandom();

	private final Throttle throttle = new Throttle();

	@Autowired
	private BoMemberMapper mapper;
	@Autowired
	private BoMemberService memberService;
	@Autowired
	private JavaMailSender mailSender;
	@Value("${mail.username}")
	private String mailFrom;

	/** 4항목이 모두 맞는 재직자 목록. 어느 항목이 틀렸는지, 재직 여부는 알려 주지 않는다 */
	public List<Map<String, Object>> match(String name, String joinDt, String birth, String phone, HttpSession session) {
		String nm = name == null ? "" : name.trim();
		String tel = phone == null ? "" : phone.replaceAll("[^0-9]", "");
		require(!nm.isEmpty() && nm.length() <= 50 && joinDt != null && joinDt.matches("\\d{4}-\\d{2}-\\d{2}")
				&& birth != null && birth.matches("\\d{6}") && tel.length() >= 9 && tel.length() <= 11, "입력값을 확인해 주세요.");
		long now = System.currentTimeMillis();
		// 전화번호나 생년월일만 바꿔 대입하는 것을 막으려고 이름으로 센다
		require(!throttle.blocked(nm, now), "시도 횟수를 초과했습니다. 10분 뒤 다시 시도해 주세요.");

		Map<String, Object> p = new HashMap<>();
		p.put("NAME", nm);
		p.put("PHONE", tel);
		p.put("JOIN", joinDt.replace("-", ""));
		List<Map<String, Object>> found = new ArrayList<>();
		Set<Integer> selectable = new HashSet<>();
		for (Map<String, Object> r : mapper.selectSignupStaff(p)) {
			if (!birthMatches((String) r.get("RRN_ENC"), birth)) {
				continue;
			}
			Map<String, Object> row = new HashMap<>();
			int sq = ((Number) r.get("STAFF_SQ")).intValue();
			boolean joined = r.get("EMPLY_ID") != null && !r.get("EMPLY_ID").toString().trim().isEmpty();
			row.put("STAFF_SQ", sq);
			row.put("STAFF_NM", r.get("STAFF_NM"));
			row.put("ORG_NM", r.get("ORG_NM"));
			row.put("DEPT_NM", r.get("DEPT_NM"));
			row.put("POSITION_NM", r.get("POSITION_NM"));
			row.put("JOINED", joined);
			found.add(row);
			if (!joined) {
				selectable.add(sq);
			}
		}
		if (found.isEmpty()) {
			throttle.fail(nm, now);
			throw new IllegalArgumentException(MISMATCH);
		}
		throttle.clear(nm);
		session.setAttribute(STATE, new State(selectable, now + WINDOW));
		return found;
	}

	/** 직원이 입력한 회사 메일로 인증번호를 보낸다. 받을 수 있어야 그 주소가 본인 것으로 확인된다. 다시 받기도 여기로 온다 */
	public Map<String, Object> send(int staffSq, String companyEmail, HttpSession session) {
		State state = state(session);
		require(state.staff.contains(staffSq), RESTART);
		String email = BoMemberService.companyEmail(companyEmail);
		require(email != null, "회사 메일은 @gmail.com 주소만 쓸 수 있습니다.");
		memberService.signupStaff(staffSq, email);
		long now = System.currentTimeMillis();
		require(throttle.allowMail(staffSq, now), "인증번호는 1분에 한 번만 받을 수 있습니다.");

		String code = String.format("%06d", RANDOM.nextInt(1000000));
		mail(email, code);
		synchronized (state) {
			state.staffSq = staffSq;
			state.email = email;
			state.code = code;
			state.tries = 0;
			state.expire = now + WINDOW;
		}
		Map<String, Object> out = new HashMap<>();
		out.put("EMAIL", maskEmail(email));
		out.put("SECONDS", WINDOW / 1000);
		out.put("RESEND_SECONDS", RESEND / 1000);
		return out;
	}

	/** 인증번호가 맞으면 계정을 만든다. 초기 비밀번호는 이 응답으로만 나간다 */
	public Map<String, Object> verify(String code, HttpSession session) {
		State state = state(session);
		synchronized (state) { // 동시 요청으로 시도 횟수를 넘기지 못하게 한다
			require(state.code != null, RESTART);
			if (code == null || !MessageDigest.isEqual(state.code.getBytes(StandardCharsets.UTF_8), code.trim().getBytes(StandardCharsets.UTF_8))) {
				if (++state.tries >= LIMIT) {
					session.removeAttribute(STATE);
					throw new IllegalArgumentException("인증번호를 5회 틀렸습니다. 처음부터 다시 진행해 주세요.");
				}
				throw new IllegalArgumentException("인증번호가 맞지 않습니다.");
			}
			Map<String, Object> created = memberService.issueBySignup(state.staffSq, state.email);
			session.removeAttribute(STATE);
			return created;
		}
	}

	private State state(HttpSession session) {
		State state = (State) session.getAttribute(STATE);
		if (state == null || System.currentTimeMillis() > state.expire) {
			session.removeAttribute(STATE);
			throw new IllegalArgumentException(RESTART);
		}
		return state;
	}

	private void mail(String to, String code) {
		try {
			MimeMessage message = mailSender.createMimeMessage();
			MimeMessageHelper helper = new MimeMessageHelper(message, false, "UTF-8");
			helper.setFrom(mailFrom);
			helper.setTo(to);
			helper.setSubject("[이에스티소프트] 직원 가입 인증번호");
			helper.setText("직원 가입 인증번호: " + code + "\n\n10분 안에 입력해 주세요. 직접 요청하지 않았다면 이 메일을 무시해 주세요.");
			mailSender.send(message);
		} catch (Exception e) {
			throw new IllegalArgumentException("메일을 보내지 못했습니다. 잠시 후 다시 시도해 주세요.");
		}
	}

	static boolean birthMatches(String stored, String birth) {
		if (stored == null || stored.isEmpty()) {
			return false;
		}
		try {
			return (RrnCipher.isEncrypted(stored) ? RrnCipher.decrypt(stored) : stored).replaceAll("[^0-9]", "").startsWith(birth);
		} catch (RuntimeException e) {
			return false;
		}
	}

	/** ho***@ex*****.com */
	static String maskEmail(String email) {
		int at = email.indexOf('@');
		String local = email.substring(0, at), domain = email.substring(at + 1);
		int dot = domain.indexOf('.');
		String host = dot < 0 ? domain : domain.substring(0, dot), tail = dot < 0 ? "" : domain.substring(dot);
		int keep = Math.min(2, Math.max(1, host.length() - 1));
		return local.substring(0, Math.min(2, Math.max(1, local.length() - 1))) + "***@" + host.substring(0, keep)
				+ new String(new char[host.length() - keep]).replace('\0', '*') + tail;
	}

	private static void require(boolean ok, String message) {
		if (!ok) {
			throw new IllegalArgumentException(message);
		}
	}

	private static final class State implements Serializable {
		private static final long serialVersionUID = 1L;
		final HashSet<Integer> staff;
		long expire;
		int staffSq;
		String email;
		String code;
		int tries;

		State(Set<Integer> staff, long expire) {
			this.staff = new HashSet<>(staff);
			this.expire = expire;
		}
	}

	/** shortcut: 서버 메모리라 재시작하면 초기화된다, 서버를 여러 대로 늘리면 DB 로 옮긴다 */
	static final class Throttle {
		private final Map<String, long[]> failures = new HashMap<>();
		private final Map<Integer, Long> mails = new HashMap<>();

		synchronized boolean blocked(String name, long now) {
			long[] f = failures.get(name);
			return f != null && now < f[1] && f[0] >= LIMIT;
		}

		synchronized void fail(String name, long now) {
			failures.values().removeIf(f -> now >= f[1]);
			long[] f = failures.get(name);
			if (f == null) {
				failures.put(name, new long[] { 1, now + WINDOW });
			} else {
				f[0]++;
			}
		}

		synchronized void clear(String name) {
			failures.remove(name);
		}

		synchronized boolean allowMail(int staffSq, long now) {
			Long last = mails.get(staffSq);
			if (last != null && now - last < RESEND) {
				return false;
			}
			mails.put(staffSq, now);
			return true;
		}
	}
}
