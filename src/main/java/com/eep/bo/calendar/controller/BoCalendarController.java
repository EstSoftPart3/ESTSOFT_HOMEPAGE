package com.eep.bo.calendar.controller;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

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
import com.eep.bo.my.GoogleLinkService;

@Controller
public class BoCalendarController {

	@Autowired
	private BoCalendarService BoCalendarService;

	@Autowired
	private GoogleLinkService link;

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
		mv.addObject("googleLogin", link.linked(GoogleLinkService.currentUser(), GoogleLinkService.CALENDAR));
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

	// 구글 연결은 내 연동에서 한다. 연결하고 나면 조회하려던 조건으로 이 페이지에 돌아온다
	@RequestMapping("/admin/calendar/oauthStart.do")
	public String oauthStart(@RequestParam Map<String, Object> param) throws Exception {
		StringBuilder back = new StringBuilder("/admin/calendar/openCalendarSync.do?auto=1");
		for (String key : new String[] { "fromDt", "toDt", "calId" }) {
			if (param.get(key) != null) {
				back.append('&').append(key).append('=').append(UriUtils.encodeQueryParam((String) param.get(key), "UTF-8"));
			}
		}
		return "redirect:/admin/my/openGoogleLink.do?svc=CALENDAR&need=1&back=" + UriUtils.encodeQueryParam(back.toString(), "UTF-8");
	}

	/** 내 연동 캘린더의 액세스 토큰. 없거나 끊겼으면 null(화면이 내 연동으로 보낸다) */
	private String token() {
		try {
			return link.accessToken(GoogleLinkService.CALENDAR);
		} catch (GoogleLinkService.NeedLink e) {
			return null;
		}
	}

	// 내 연동 구글 계정의 캘린더 목록
	@RequestMapping("/admin/calendar/calendarListData.do")
	@ResponseBody
	public ModelAndView calendarListData(HttpSession session) {
		String token = token();
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
		String token = token();
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
		if (e.getStatusCode() == HttpStatus.UNAUTHORIZED || e.getStatusCode() == HttpStatus.FORBIDDEN) {
			return json("needLogin", true);
		}
		if (e.getStatusCode() == HttpStatus.NOT_FOUND) {
			return json("error", "캘린더를 찾을 수 없습니다. 캘린더를 다시 선택해 주세요.");
		}
		return json("error", "구글 캘린더 호출 실패: " + e.getStatusCode() + " " + e.getResponseBodyAsString());
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
