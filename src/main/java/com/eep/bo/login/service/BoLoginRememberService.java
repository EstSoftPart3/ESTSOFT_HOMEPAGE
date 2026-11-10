package com.eep.bo.login.service;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.eep.mapper.BoLoginMapper;

/**
 * 직원·관리자 아이디 저장·자동로그인 쿠키
 * 비밀번호는 쿠키에 넣지 않는다. 자동로그인 쿠키에는 무작위 토큰만 넣고 DB 에는 그 해시만 둔다
 * 토큰은 교체하지 않는다: 만료 전 세션이 끊긴 화면에서 요청이 동시에 나가면 교체 때문에 로그아웃되기 때문이다
 */
@Service
public class BoLoginRememberService {

	private static final String AUTO_COOKIE = "EEP_ADMIN_AUTO";
	private static final String ID_COOKIE = "EEP_ADMIN_ID";
	private static final String AUTO_CHECK_COOKIE = "EEP_ADMIN_AUTO_CHECK";
	private static final int AUTO_SECONDS = 7 * 24 * 60 * 60;
	private static final int ID_SECONDS = 90 * 24 * 60 * 60;
	private static final SecureRandom RANDOM = new SecureRandom();

	@Autowired
	private BoLoginMapper BoLoginMapper;

	/** 로그인 성공 시 자동로그인 토큰 발급 */
	public void issue(String emplyId, HttpServletRequest request, HttpServletResponse response) {
		byte[] raw = new byte[32];
		RANDOM.nextBytes(raw);
		String token = Base64.getUrlEncoder().withoutPadding().encodeToString(raw);

		BoLoginMapper.deleteExpiredLoginToken();
		Map<String, Object> param = new HashMap<>();
		param.put("TOKEN_HASH", sha256(token));
		param.put("EMPLY_ID", emplyId);
		param.put("DAYS", AUTO_SECONDS / 86400);
		BoLoginMapper.insertLoginToken(param);
		addCookie(AUTO_COOKIE, token, AUTO_SECONDS, request, response);
	}

	/** 로그인 성공 후 아이디 저장·자동로그인 선택을 반영한다 */
	public void afterLogin(String emplyId, Map<String, Object> param, HttpServletRequest request, HttpServletResponse response) {
		if ("Y".equals(param.get("saveId"))) {
			saveId(emplyId, request, response);
		} else {
			forgetId(request, response);
		}
		boolean auto = "Y".equals(param.get("autoLogin"));
		saveAutoCheck(auto, request, response);
		if (auto) {
			issue(emplyId, request, response);
		}
	}

	/** 쿠키의 토큰이 유효하면 세션을 만든다. 쿠키가 없거나 무효면 false */
	public boolean restore(HttpServletRequest request, HttpServletResponse response) {
		return restore(request, response, false);
	}

	/** 직원 토큰으로 관리자 화면을 복원하면 튕겨 나온 뒤 다시 복원을 반복하므로, 관리자 화면은 이쪽을 쓴다 */
	public boolean restoreAdmin(HttpServletRequest request, HttpServletResponse response) {
		return restore(request, response, true);
	}

	private boolean restore(HttpServletRequest request, HttpServletResponse response, boolean adminOnly) {
		String token = cookie(AUTO_COOKIE, request);
		if (token == null) {
			return false;
		}
		Map<String, Object> param = new HashMap<>();
		param.put("TOKEN_HASH", sha256(token));
		Map<String, Object> emply = BoLoginMapper.selectLoginToken(param);
		if (emply == null) {
			clear(request, response);
			return false;
		}
		if (adminOnly && !"2".equals(emply.get("emplyAuthTypCd"))) {
			return false;
		}
		// 비로그인 때 쓰던 세션 ID 를 이어 쓰지 않는다
		HttpSession old = request.getSession(false);
		if (old != null) {
			old.invalidate();
		}
		List<Map<String, Object>> list = new ArrayList<>();
		list.add(emply);
		Map<String, Object> loginInfo = new HashMap<>();
		loginInfo.put("loginInfo", list);
		HttpSession session = request.getSession(true);
		session.setAttribute("loginInfo", loginInfo);
		session.setAttribute("emplyAuthCheck", emply.get("emplyAuthTypCd"));
		return true;
	}

	/** 로그아웃: 토큰을 DB 와 브라우저에서 지운다. 아이디 저장 쿠키는 남긴다 */
	public void clear(HttpServletRequest request, HttpServletResponse response) {
		String token = cookie(AUTO_COOKIE, request);
		if (token != null) {
			Map<String, Object> param = new HashMap<>();
			param.put("TOKEN_HASH", sha256(token));
			BoLoginMapper.deleteLoginToken(param);
		}
		addCookie(AUTO_COOKIE, "", 0, request, response);
	}

	/** 로그아웃해도 다음 로그인 화면에 자동로그인 체크를 켜 두려고 기억한다. 로그인 권한은 없는 값이다 */
	public void saveAutoCheck(boolean checked, HttpServletRequest request, HttpServletResponse response) {
		addCookie(AUTO_CHECK_COOKIE, checked ? "Y" : "", checked ? ID_SECONDS : 0, request, response);
	}

	public boolean savedAutoCheck(HttpServletRequest request) {
		return "Y".equals(cookie(AUTO_CHECK_COOKIE, request));
	}

	public void saveId(String emplyId, HttpServletRequest request, HttpServletResponse response) {
		try {
			addCookie(ID_COOKIE, URLEncoder.encode(emplyId, "UTF-8"), ID_SECONDS, request, response);
		} catch (UnsupportedEncodingException e) {
			throw new IllegalStateException(e);
		}
	}

	public void forgetId(HttpServletRequest request, HttpServletResponse response) {
		addCookie(ID_COOKIE, "", 0, request, response);
	}

	public String savedId(HttpServletRequest request) {
		String val = cookie(ID_COOKIE, request);
		try {
			return val == null ? null : URLDecoder.decode(val, "UTF-8");
		} catch (UnsupportedEncodingException | IllegalArgumentException e) {
			return null;
		}
	}

	private static String cookie(String name, HttpServletRequest request) {
		if (request.getCookies() != null) {
			for (Cookie c : request.getCookies()) {
				if (name.equals(c.getName()) && !c.getValue().isEmpty()) {
					return c.getValue();
				}
			}
		}
		return null;
	}

	// SameSite 는 Cookie 클래스로 지정할 수 없어 헤더로 쓴다. 프록시 뒤면 X-Forwarded-Proto 로 HTTPS 를 판단한다
	private static void addCookie(String name, String value, int maxAge, HttpServletRequest request, HttpServletResponse response) {
		boolean https = request.isSecure() || "https".equalsIgnoreCase(request.getHeader("X-Forwarded-Proto"));
		response.addHeader("Set-Cookie", name + "=" + value + "; Path=/; Max-Age=" + maxAge + "; HttpOnly; SameSite=Lax" + (https ? "; Secure" : ""));
	}

	private static String sha256(String text) {
		try {
			StringBuilder hex = new StringBuilder();
			for (byte b : MessageDigest.getInstance("SHA-256").digest(text.getBytes(StandardCharsets.UTF_8))) {
				hex.append(String.format("%02x", b));
			}
			return hex.toString();
		} catch (NoSuchAlgorithmException e) {
			throw new IllegalStateException(e);
		}
	}
}
