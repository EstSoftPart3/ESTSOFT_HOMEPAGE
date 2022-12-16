package common.logger;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
public class LoggerInterceptor extends HandlerInterceptorAdapter {
	
	protected Log log = LogFactory.getLog(LoggerInterceptor.class);

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
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
			throws Exception {

		String reqUrl = request.getRequestURI().toString();

		if (log.isDebugEnabled()) {
			log.debug(
					"======================================          START         ======================================");
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