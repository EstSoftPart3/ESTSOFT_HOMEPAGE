package com.common.logger;

import java.io.PrintWriter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.json.simple.JSONArray;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

/**
 * <pre>
 *로그인 처리, 로깅, 메뉴 및 프로그램 권한 체크
 * erp.common.logger
 * LoggerInterceptor.java
 * </pre>
 * 
 * @Since 2019. 5. 15.
 * @Author SH KIM
 * 
 */
public class boLoggerInterceptor extends HandlerInterceptorAdapter {
	
	protected Log log = LogFactory.getLog(boLoggerInterceptor.class);
	
	private final static String USER_SESSION_ID = "USER_SESSION_ID";

	/**
	 * 
	 * 서버 요청 전처리 핸들러
	 * 
	 * @param request
	 * @param response
	 * @param handler
	 * @return
	 * @throws Exception
	 */
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

		String reqUrl = request.getRequestURI().toString();
		HttpSession session = request.getSession(); //2021-08-07 Session Check : Ctrl + Shift + O를 눌러 해당 Package를 Import한다.
		Object obj = session.getAttribute("loginInfo");
		String authCheck = (String) session.getAttribute("emplyAuthCheck");
		String path = request.getServletPath(); 
		String query = request.getQueryString(); //파라미터가 있는지 없는지

		/*System.out.println("세션 IN 계정 정보 : " + obj);
		System.out.println("권한 체크 : " + authCheck);
		System.out.println("reqUrl : " + reqUrl);
		System.out.println("path : " + path);
		System.out.println("query : " + query);*/
		
		
		if(obj == null) {

			response.sendRedirect("/admin/login/loginPage.do");
			
			return false;

		}else if(authCheck.equals("1")) {
			
			response.setContentType("text/html; charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('현재 계정은 관리자 계정이 아닙니다. 강제 로그아웃 후 관리자 로그인 페이지로 넘어갑니다.'); location.href='/admin/login/loginPage.do';</script>");
            out.flush();
			
			session.invalidate();
			
			return false;
		}


		if (log.isDebugEnabled()) {
			log.debug(
				"======================================          START 00        ======================================");
			log.debug(" Request URI \t:  " + reqUrl);
		}

		return super.preHandle(request, response, handler);
			
	}
		
	

	/**
	 * 
	 * 서버 응답 전 서버로직 후처리 핸들러
	 * 
	 * @param request
	 * @param response
	 * @param handler
	 * @param modelAndView
	 * @throws Exception
	 */
	@Override
	public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler,
			ModelAndView modelAndView) throws Exception {

		if (log.isDebugEnabled()) {
			log.debug(
					"======================================           END          ======================================\n");
		}
	}
}