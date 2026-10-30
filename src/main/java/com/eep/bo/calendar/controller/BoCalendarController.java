package com.eep.bo.calendar.controller;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.util.UriUtils;

import com.eep.bo.calendar.service.BoCalendarService;
import com.eep.bo.calendar.service.BoCalendarServiceImpl;
import com.eep.bo.calendar.service.GoogleCalendarApi;

@Controller
public class BoCalendarController {

	// 구글 액세스 토큰과 로그인 왕복 중 상태는 세션에만 둔다
	private static final String SS_TOKEN = "gcalToken";
	private static final String SS_STATE = "gcalState";
	private static final String SS_PENDING = "gcalPending";

	@Autowired
	private BoCalendarService BoCalendarService;

	@Autowired
	private GoogleCalendarApi GoogleCalendarApi;

	/**
	 * 업무툴 - 구글 캘린더 일정 분류 Controller
	 *
	 * **/

	// 일정 가져오기·분류 페이지
	@RequestMapping("/admin/calendar/openCalendarSync.do")
	public ModelAndView openCalendarSync(HttpSession session) {
		ModelAndView mv = new ModelAndView("bo/calendar/calendar_sync");
		Map<String, String> conf = BoCalendarService.ConfMap();
		String clientId = conf.get(BoCalendarServiceImpl.CONF_CLIENT_ID);
		mv.addObject("clientId", clientId);
		mv.addObject("confReady", notEmpty(clientId) && notEmpty(conf.get(BoCalendarServiceImpl.CONF_CLIENT_SECRET)));
		mv.addObject("googleLogin", session.getAttribute(SS_TOKEN) != null);
		mv.addObject("categories", BoCalendarServiceImpl.CATEGORIES);
		mv.addObject("subCategories", BoCalendarServiceImpl.SUB_CATEGORIES);
		return mv;
	}

	// 확정 일정 분류별 보기 페이지
	@RequestMapping("/admin/calendar/openCalendarList.do")
	public ModelAndView openCalendarList() {
		ModelAndView mv = new ModelAndView("bo/calendar/calendar_list");
		mv.addObject("categories", BoCalendarServiceImpl.CATEGORIES);
		mv.addObject("subCategories", BoCalendarServiceImpl.SUB_CATEGORIES);
		return mv;
	}

	// 구글 OAuth 클라이언트 설정 저장
	@RequestMapping("/admin/calendar/saveConfData.do")
	@ResponseBody
	public ModelAndView saveConfData(@RequestParam Map<String, Object> param) {
		String clientId = (String) param.get("clientId");
		if (!notEmpty(clientId)) {
			return json("error", "클라이언트 ID를 입력해 주세요.");
		}
		BoCalendarService.ConfSave(clientId, (String) param.get("clientSecret"));
		return json("result", "OK");
	}

	// 구글 로그인 시작. 끝나면 조회하려던 조건으로 페이지에 돌아온다
	@RequestMapping("/admin/calendar/oauthStart.do")
	public String oauthStart(@RequestParam Map<String, Object> param, HttpServletRequest request, HttpSession session) {
		String clientId = BoCalendarService.ConfMap().get(BoCalendarServiceImpl.CONF_CLIENT_ID);
		if (!notEmpty(clientId)) {
			return "redirect:/admin/calendar/openCalendarSync.do";
		}
		String state = UUID.randomUUID().toString();
		session.setAttribute(SS_STATE, state);
		session.setAttribute(SS_PENDING, new HashMap<>(param));
		return "redirect:" + GoogleCalendarApi.authUrl(clientId, redirectUri(request), state);
	}

	@RequestMapping("/admin/calendar/oauthCallback.do")
	@SuppressWarnings("unchecked")
	public String oauthCallback(@RequestParam Map<String, Object> param, HttpServletRequest request, HttpSession session) throws Exception {
		Object state = session.getAttribute(SS_STATE);
		session.removeAttribute(SS_STATE);
		// state 가 다르면 이 세션이 시작한 로그인이 아니다(CSRF)
		if (state == null || !state.equals(param.get("state")) || param.get("code") == null) {
			return "redirect:/admin/calendar/openCalendarSync.do?gerr=1";
		}
		Map<String, String> conf = BoCalendarService.ConfMap();
		String token = GoogleCalendarApi.exchangeCode(conf.get(BoCalendarServiceImpl.CONF_CLIENT_ID),
				conf.get(BoCalendarServiceImpl.CONF_CLIENT_SECRET), redirectUri(request), (String) param.get("code"));
		session.setAttribute(SS_TOKEN, token);

		Map<String, Object> pending = (Map<String, Object>) session.getAttribute(SS_PENDING);
		session.removeAttribute(SS_PENDING);
		StringBuilder back = new StringBuilder("redirect:/admin/calendar/openCalendarSync.do?auto=1");
		if (pending != null) {
			for (String key : new String[] { "fromDt", "toDt", "calId" }) {
				if (pending.get(key) != null) {
					back.append('&').append(key).append('=').append(UriUtils.encodeQueryParam((String) pending.get(key), "UTF-8"));
				}
			}
		}
		return back.toString();
	}

	// 로그인한 구글 계정의 캘린더 목록
	@RequestMapping("/admin/calendar/calendarListData.do")
	@ResponseBody
	public ModelAndView calendarListData(HttpSession session) {
		String token = (String) session.getAttribute(SS_TOKEN);
		if (token == null) {
			return json("needLogin", true);
		}
		try {
			return json("calendars", GoogleCalendarApi.calendarList(token));
		} catch (HttpClientErrorException e) {
			return googleError(e, session);
		}
	}

	// 구글에서 기간 일정을 가져와 1차 분류 후 임시 저장
	@RequestMapping("/admin/calendar/fetchEventsData.do")
	@ResponseBody
	public ModelAndView fetchEventsData(@RequestParam Map<String, Object> param, HttpSession session) {
		String token = (String) session.getAttribute(SS_TOKEN);
		if (token == null) {
			return json("needLogin", true);
		}
		LocalDate from, to;
		try {
			from = LocalDate.parse((String) param.get("fromDt"));
			to = LocalDate.parse((String) param.get("toDt"));
		} catch (Exception e) {
			return json("error", "조회 기간을 yyyy-MM-dd 형식으로 입력해 주세요.");
		}
		if (to.isBefore(from) || from.plusDays(366).isBefore(to)) {
			return json("error", "조회 기간은 1년 이내로, 종료일이 시작일보다 같거나 늦어야 합니다.");
		}
		String calId = notEmpty((String) param.get("calId")) ? (String) param.get("calId") : "primary";
		try {
			List<Map<String, Object>> events = GoogleCalendarApi.events(token, calId, from, to);
			return json("list", BoCalendarService.FetchToTmp(loginId(session), events));
		} catch (HttpClientErrorException e) {
			return googleError(e, session);
		}
	}

	// 마지막으로 가져온 임시 일정
	@RequestMapping("/admin/calendar/tmpListData.do")
	@ResponseBody
	public ModelAndView tmpListData(HttpSession session) {
		return json("list", BoCalendarService.TmpList(loginId(session)));
	}

	// 선택한 임시 일정을 (수정한 분류로) 확정. body: [{EVT_TMP_SQ, CATE_CD, SUB_CATE_CD}]
	@RequestMapping("/admin/calendar/confirmData.do")
	@ResponseBody
	public ModelAndView confirmData(@RequestBody List<Map<String, Object>> items, HttpSession session) {
		try {
			int cnt = BoCalendarService.Confirm(loginId(session), items);
			ModelAndView mv = json("count", cnt);
			mv.addObject("list", BoCalendarService.TmpList(loginId(session)));
			return mv;
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	// 확정 일정 목록 + 분류별 건수
	@RequestMapping("/admin/calendar/eventListData.do")
	@ResponseBody
	public ModelAndView eventListData(@RequestParam Map<String, Object> param) {
		try {
			LocalDate.parse((String) param.get("fromDt"));
			LocalDate.parse((String) param.get("toDt"));
		} catch (Exception e) {
			return json("error", "조회 기간을 yyyy-MM-dd 형식으로 입력해 주세요.");
		}
		param.put("FROM_DT", param.get("fromDt"));
		param.put("TO_DT", param.get("toDt"));
		param.put("CATE_CD", param.get("cateCd"));
		ModelAndView mv = json("list", BoCalendarService.EvtList(param));
		mv.addObject("counts", BoCalendarService.EvtCateCount(param));
		return mv;
	}

	// 토큰 만료·권한 없음이면 다시 로그인하게 한다
	private ModelAndView googleError(HttpClientErrorException e, HttpSession session) {
		if (e.getStatusCode() == HttpStatus.UNAUTHORIZED) {
			session.removeAttribute(SS_TOKEN);
			return json("needLogin", true);
		}
		if (e.getStatusCode() == HttpStatus.NOT_FOUND) {
			return json("error", "캘린더를 찾을 수 없습니다. 캘린더를 다시 선택해 주세요.");
		}
		return json("error", "구글 캘린더 호출 실패: " + e.getStatusCode() + " " + e.getResponseBodyAsString());
	}

	/** 구글 콘솔에 등록한 리디렉션 URI 와 글자까지 같아야 한다. 프록시 뒤면 X-Forwarded-Proto 를 따른다 */
	private static String redirectUri(HttpServletRequest request) {
		String proto = request.getHeader("X-Forwarded-Proto");
		if (!notEmpty(proto)) {
			proto = request.getScheme();
		}
		return proto + "://" + request.getHeader("Host") + "/admin/calendar/oauthCallback.do";
	}

	@SuppressWarnings("unchecked")
	private static String loginId(HttpSession session) {
		Map<String, Object> info = (Map<String, Object>) session.getAttribute("loginInfo");
		List<Map<String, Object>> list = (List<Map<String, Object>>) info.get("loginInfo");
		return (String) list.get(0).get("emplyId");
	}

	private static ModelAndView json(String key, Object value) {
		ModelAndView mv = new ModelAndView("jsonView");
		mv.addObject(key, value);
		return mv;
	}

	private static boolean notEmpty(String s) {
		return s != null && !s.trim().isEmpty();
	}
}
