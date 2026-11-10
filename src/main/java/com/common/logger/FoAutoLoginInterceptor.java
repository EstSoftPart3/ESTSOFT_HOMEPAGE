package com.common.logger;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import com.eep.bo.login.service.BoLoginRememberService;

/** 홈페이지 세션이 끊겼으면 자동로그인 쿠키로 다시 만든다 */
public class FoAutoLoginInterceptor extends HandlerInterceptorAdapter {

	@Autowired
	private BoLoginRememberService rememberService;

	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("loginInfo") == null) {
			rememberService.restore(request, response);
		}
		return true;
	}
}
