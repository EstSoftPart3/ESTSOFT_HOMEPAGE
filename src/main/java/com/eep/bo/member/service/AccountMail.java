package com.eep.bo.member.service;

import java.util.List;
import java.util.Map;

import javax.mail.internet.MimeMessage;
import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import com.eep.mapper.BoMemberMapper;

/**
 * 계정 안내 메일. 가입하면 슈퍼관리자에게 권한 발급 요청, 권한이 처음 생기면 본인 회사 메일로 발급 안내.
 * 메일이 실패해도 가입·권한 저장은 그대로 둔다(로그만 남긴다). 비밀번호는 메일에 넣지 않는다.
 */
@Service
public class AccountMail {

	@Autowired
	private BoMemberMapper mapper;
	@Autowired
	private JavaMailSender mailSender;
	@Value("${mail.username}")
	private String mailFrom;

	/** 직원 본인 가입 직후 */
	public void signedUp(String id, String name) {
		List<String> to = mapper.selectSuperEmails();
		if (to.isEmpty()) {
			return;
		}
		send(to.toArray(new String[0]), "[이에스티소프트] 직원 가입 · 권한 발급 요청: " + name,
				name + "(" + id + ")님이 홈페이지에 직원으로 가입했습니다.\n\n"
				+ "지금은 권한 없는 일반 직원 계정입니다. 관리자 화면이 필요한 직원이면 계정관리에서 권한을 발급해 주세요.\n"
				+ "권한을 발급하면 본인 회사 메일로 안내가 갑니다.\n\n"
				+ "계정관리: " + base() + "/admin/member/memberList.do");
	}

	/** 권한이 없던 계정에 권한이 생겼을 때. issued 는 관리자가 계정을 새로 발급한 경우(비밀번호는 발급한 관리자가 전달) */
	public void granted(String id, boolean issued) {
		Map<String, Object> a = mapper.selectGrantMail(id);
		String to = a == null ? null : (String) a.get("EMPLY_EMAIL");
		if (to == null || !to.contains("@")) {
			return;
		}
		send(new String[] { to }, "[이에스티소프트] 관리자 권한이 발급되었습니다",
				a.get("EMPLY_NM") + "님, 관리자 권한이 발급되었습니다.\n\n"
				+ "- 아이디: " + id + "\n"
				+ "- 권한: " + (a.get("ROLE_NMS") == null ? "-" : a.get("ROLE_NMS")) + "\n"
				+ "- 관리자 로그인: " + base() + "/admin/login/loginPage.do (로그인 화면에서 「관리자」 선택)\n\n"
				+ (issued ? "초기 비밀번호는 계정을 발급한 관리자에게 받아 주세요. 첫 로그인 때 비밀번호를 바꾸게 됩니다.\n"
						: "비밀번호는 가입할 때 받은 초기 비밀번호(바꿨다면 바꾼 비밀번호)를 그대로 씁니다.\n"
						+ "비밀번호를 잊었으면 관리자에게 초기화를 요청해 주세요.\n"));
	}

	private void send(String[] to, String subject, String text) {
		try {
			MimeMessage message = mailSender.createMimeMessage();
			MimeMessageHelper helper = new MimeMessageHelper(message, false, "UTF-8");
			helper.setFrom(mailFrom);
			helper.setTo(to);
			helper.setSubject(subject);
			helper.setText(text);
			mailSender.send(message);
		} catch (Exception e) {
			System.out.println("ACCOUNT_MAIL_FAIL " + subject + " " + e.getClass().getSimpleName() + " " + e.getMessage());
		}
	}

	/** 프록시 뒤라 전달된 머리말을 먼저 본다(BoPayslipController.baseUrl 과 같은 규칙) */
	private static String base() {
		ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
		if (attrs == null) {
			return "";
		}
		HttpServletRequest request = attrs.getRequest();
		String proto = request.getHeader("X-Forwarded-Proto"), host = request.getHeader("X-Forwarded-Host");
		return (proto == null ? request.getScheme() : proto.split(",")[0].trim()) + "://" + (host == null ? request.getHeader("Host") : host.split(",")[0].trim());
	}
}
