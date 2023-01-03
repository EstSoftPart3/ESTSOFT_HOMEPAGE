package com.common.logger;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
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
		
		//2021-08-07 Session Check : Ctrl + Shift + O를 눌러 해당 Package를 Import한다.
		HttpSession session = request.getSession();
		
		log.debug("reqUrl:" + reqUrl);
		
		Object obj = session.getAttribute("loginInfo");
		
		
		System.out.println("obj : " + obj);
		
		if(obj == null) {
			response.sendRedirect("/admin/login/loginPage.do");
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