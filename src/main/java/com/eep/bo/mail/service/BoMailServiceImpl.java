package com.eep.bo.mail.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.mail.AuthenticationFailedException;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.stereotype.Service;

import com.eep.bo.mail.dao.BoMailDao;

@Service
public class BoMailServiceImpl implements BoMailService {

	private static final Logger log = LoggerFactory.getLogger(BoMailServiceImpl.class);

	private static final int MAX_USE_LENGTH = 100;
	private static final String TIMEOUT_MS = "15000";

	@Autowired
	private BoMailDao BoMailDao;

	// 서버·포트·보안 설정은 입사지원 메일과 같은 값을 쓴다
	@Autowired
	private JavaMailSenderImpl mailSender;

	@Value("${mail.crypto.key}")
	private String cryptoKey;

	@Override
	public List<Map<String, Object>> AcctList() {
		return BoMailDao.AcctList();
	}

	@Override
	public void AcctAdd(Map<String, Object> param, String emplyId) {
		String addr = normalizeAddr(param.get("MAIL_ADDR"));
		String use = normalizeUse(param.get("ACCT_USE"));
		String password = normalizePassword(param.get("APP_PW"));
		checkLogin(addr, password);

		// SQL 로그에 원문이 남지 않도록 요청값을 그대로 넘기지 않는다
		Map<String, Object> row = new HashMap<String, Object>();
		row.put("MAIL_ADDR", addr);
		row.put("ACCT_USE", use);
		row.put("APP_PW_ENC", MailPasswordCipher.encrypt(password, cryptoKey));
		row.put("RGST_EMPLY_ID", emplyId);
		try {
			BoMailDao.AcctInsert(row);
		} catch (DuplicateKeyException e) {
			throw new IllegalArgumentException("이미 등록된 메일 주소입니다.");
		}
	}

	@Override
	public void AcctDelete(Map<String, Object> param) {
		BoMailDao.AcctDelete(param);
	}

	static String normalizeAddr(Object value) {
		String addr = value == null ? "" : value.toString().trim().toLowerCase();
		if (!addr.matches("^[a-z0-9._%+-]+@gmail\\.com$") || addr.length() > 190) {
			throw new IllegalArgumentException("Gmail 주소를 입력해 주세요.");
		}
		return addr;
	}

	static String normalizeUse(Object value) {
		String use = value == null ? "" : value.toString().trim();
		if (use.isEmpty() || use.length() > MAX_USE_LENGTH) {
			throw new IllegalArgumentException("용도를 " + MAX_USE_LENGTH + "자 이내로 입력해 주세요.");
		}
		return use;
	}

	// Google 화면에 4자리씩 띄어 표시되므로 공백은 지운다. 일반 로그인 비밀번호를 Google 로 보내지 않도록 형식을 먼저 본다
	static String normalizePassword(Object value) {
		String password = value == null ? "" : value.toString().replaceAll("\\s", "");
		if (!password.matches("^[a-z]{16}$")) {
			throw new IllegalArgumentException("Google 앱 비밀번호 16자리를 입력해 주세요. 로그인 비밀번호는 쓸 수 없습니다.");
		}
		return password;
	}

	private void checkLogin(String addr, String password) {
		Properties props = new Properties();
		props.putAll(mailSender.getJavaMailProperties());
		props.setProperty("mail.debug", "false");
		props.setProperty("mail.smtp.connectiontimeout", TIMEOUT_MS);
		props.setProperty("mail.smtp.timeout", TIMEOUT_MS);
		Transport transport = null;
		try {
			transport = Session.getInstance(props).getTransport("smtp");
			transport.connect(mailSender.getHost(), mailSender.getPort(), addr, password);
		} catch (AuthenticationFailedException e) {
			throw new IllegalArgumentException("Gmail 로그인에 실패했습니다. 주소와 앱 비밀번호를 확인해 주세요.");
		} catch (MessagingException e) {
			log.warn("Gmail SMTP 연결 실패: {}", e.getClass().getSimpleName());
			throw new IllegalArgumentException("Gmail 에 연결하지 못했습니다. 잠시 후 다시 시도해 주세요.");
		} finally {
			closeQuietly(transport);
		}
	}

	private static void closeQuietly(Transport transport) {
		if (transport == null) {
			return;
		}
		try {
			transport.close();
		} catch (MessagingException e) {
			log.debug("SMTP 연결 종료 실패: {}", e.getClass().getSimpleName());
		}
	}
}
