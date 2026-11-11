package com.common.logger;

import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.json.simple.JSONArray;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;
import org.springframework.web.util.UrlPathHelper;

import com.eep.bo.deploy.service.SecretFilter;
import com.eep.bo.login.service.BoLoginRememberService;
import com.eep.bo.system.service.BoSystemService;

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

	@Autowired
	private BoLoginRememberService BoLoginRememberService;

	@Autowired
	private BoSystemService systemService;

	@Autowired
	private SecretFilter secretFilter;

	@SuppressWarnings("unchecked")
	private static String loginId(Object loginInfo) {
		List<Map<String, Object>> list = (List<Map<String, Object>>) ((Map<String, Object>) loginInfo).get("loginInfo");
		return (String) list.get(0).get("emplyId");
	}

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
		// 세션이 끊겼으면 자동로그인 쿠키로 다시 만든다
		if(obj == null && BoLoginRememberService.restoreAdmin(request, response)) {
			session = request.getSession();
			obj = session.getAttribute("loginInfo");
			authCheck = (String) session.getAttribute("emplyAuthCheck");
		}
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

		}else if(!"2".equals(authCheck)) { // 관리자(2)만 통과. BO 로그인 쿼리와 같은 기준
			
			response.setContentType("text/html; charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('현재 계정은 관리자 계정이 아닙니다. 강제 로그아웃 후 관리자 로그인 페이지로 넘어갑니다.'); location.href='/admin/login/loginPage.do';</script>");
            out.flush();
			
			session.invalidate();

			return false;
		}

		// 로그인 중에 중지·퇴사되거나 직원 계정으로 바뀌어도 다음 요청부터 막는다
		if(!systemService.isActiveAdmin(loginId(obj))) {
			BoLoginRememberService.clear(request, response);
			session.invalidate();
			response.sendRedirect("/admin/login/loginPage.do");
			return false;
		}

		// Spring 이 핸들러를 찾을 때와 같은 경로로 판단해야 ;나 인코딩으로 우회되지 않는다
		BoSystemService.Access access = systemService.access(loginId(obj));
		if(!access.allows(new UrlPathHelper().getLookupPathForRequest(request))) {
			response.setStatus(HttpServletResponse.SC_FORBIDDEN);
			response.setContentType("text/html; charset=UTF-8");
			response.getWriter().println("<script>alert('이 메뉴를 사용할 권한이 없습니다.'); location.replace('" + BoSystemService.HOME + "');</script>");
			return false;
		}
		request.setAttribute("boMenus", access.tree);

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

		// 화면 가이드의 시크릿 설명은 시크릿 계정에게만 출력한다. 화면을 그릴 때만 묻는다(ajax 응답은 건너뜀)
		Object loginInfo = request.getSession().getAttribute("loginInfo");
		if (modelAndView != null && loginInfo != null) {
			request.setAttribute("secretViewer", secretFilter.isViewer(loginId(loginInfo)));
		}

		if (log.isDebugEnabled()) {
			log.debug(
					"======================================           END          ======================================\n");
		}
	}
}