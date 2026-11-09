package com.common.logger;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

/** 초기 비밀번호로 로그인한 계정은 비밀번호를 바꾸기 전까지 다른 화면을 쓰지 못한다 */
public class PasswordInitInterceptor extends HandlerInterceptorAdapter {

	@Override
	@SuppressWarnings("unchecked")
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		HttpSession session = request.getSession(false);
		Object info = session == null ? null : session.getAttribute("loginInfo");
		if (info != null && "Y".equals(((List<Map<String, Object>>) ((Map<String, Object>) info).get("loginInfo")).get(0).get("pwInitYn"))) {
			response.sendRedirect("/eep/account/changePassword.do");
			return false;
		}
		return true;
	}
}
