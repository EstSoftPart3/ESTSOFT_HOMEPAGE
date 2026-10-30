package com.eep.travel.controller;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.eep.travel.service.TravelService;
import com.eep.travel.service.TravelServiceImpl;

/**
 * 여행 대화 사전(travel/index.html)의 공개 API. 로그인이 없으므로 쓰기는 IP 당 횟수를 제한한다.
 */
@Controller
public class TravelController {

	private static final int WRITE_LIMIT = 30;
	private static final long WRITE_WINDOW_MS = 10 * 60 * 1000L;
	// shortcut: 서버 메모리에 IP 별 최근 쓰기 시각만 둔다(재시작하면 초기화). 남용이 생기면 DB 기반으로 바꾼다
	private static final Map<String, Deque<Long>> WRITES = new ConcurrentHashMap<>();

	@Autowired
	private TravelService TravelService;

	// 추가한 문장 + 숨긴 문장 키
	@RequestMapping(value = "/travel/stateData.do", method = RequestMethod.GET)
	@ResponseBody
	public ModelAndView stateData() {
		ModelAndView mv = new ModelAndView("jsonView");
		mv.addObject("added", TravelService.PhraseList());
		mv.addObject("hidden", TravelService.HideKeyList());
		return mv;
	}

	// 번역한 문장 추가. 파라미터: sit, src, ko/en/vi/ja/zh/th
	@RequestMapping(value = "/travel/addData.do", method = RequestMethod.POST)
	@ResponseBody
	public ModelAndView addData(@RequestParam Map<String, String> param, HttpServletRequest request) {
		String ip = clientIp(request);
		if (!allowWrite(ip)) return json("error", "rate");
		Map<String, String> texts = new HashMap<>();
		for (String lang : TravelServiceImpl.LANGS) {
			texts.put(lang, param.get(lang));
		}
		try {
			return json("phrase", TravelService.PhraseAdd(Integer.parseInt(param.get("sit")), param.get("src"), texts, ip));
		} catch (IllegalArgumentException e) {
			return json("error", "invalid");
		}
	}

	@RequestMapping(value = "/travel/hideData.do", method = RequestMethod.POST)
	@ResponseBody
	public ModelAndView hideData(@RequestParam("key") String key, HttpServletRequest request) {
		String ip = clientIp(request);
		if (!allowWrite(ip)) return json("error", "rate");
		try {
			TravelService.Hide(key, ip);
			return json("result", "OK");
		} catch (IllegalArgumentException e) {
			return json("error", "invalid");
		}
	}

	@RequestMapping(value = "/travel/unhideData.do", method = RequestMethod.POST)
	@ResponseBody
	public ModelAndView unhideData(@RequestParam("key") String key, HttpServletRequest request) {
		if (!allowWrite(clientIp(request))) return json("error", "rate");
		try {
			TravelService.Unhide(key);
			return json("result", "OK");
		} catch (IllegalArgumentException e) {
			return json("error", "invalid");
		}
	}

	private static boolean allowWrite(String ip) {
		long now = System.currentTimeMillis();
		WRITES.putIfAbsent(ip, new ArrayDeque<Long>());
		Deque<Long> times = WRITES.get(ip);
		if (times == null) return true; // 상한 초과로 방금 비워진 경우
		synchronized (times) {
			while (!times.isEmpty() && now - times.peekFirst() > WRITE_WINDOW_MS) times.pollFirst();
			if (times.size() >= WRITE_LIMIT) return false;
			times.addLast(now);
		}
		if (WRITES.size() > 10000) WRITES.clear(); // 메모리 상한
		return true;
	}

	/** Cloudflare → 프록시 → Tomcat 순서라 원래 IP 는 헤더에 있다 */
	private static String clientIp(HttpServletRequest request) {
		for (String h : new String[] { "CF-Connecting-IP", "X-Real-IP" }) {
			String v = request.getHeader(h);
			if (v != null && !v.isEmpty()) return cut(v.trim());
		}
		return cut(request.getRemoteAddr());
	}

	private static String cut(String s) {
		return s.length() > 64 ? s.substring(0, 64) : s;
	}

	private static ModelAndView json(String key, Object value) {
		ModelAndView mv = new ModelAndView("jsonView");
		mv.addObject(key, value);
		return mv;
	}
}
