package com.eep.bo.my;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.RestClientException;
import org.springframework.web.servlet.ModelAndView;

/**
 * 내 연동(/admin/my). 메뉴 권한과 상관없이 로그인한 관리자 누구나 자기 연동만 다룬다(BoSystemService.Access).
 * 구글 콘솔의 승인된 리디렉션 URI 는 예전부터 등록된 https://www.estsw.co.kr/admin/batch/driveCallback.do 를 그대로 쓴다.
 */
@Controller
public class BoMyController {

	private static final String SS_STATE = "myGoogleState", SS_SERVICE = "myGoogleService", SS_BACK = "myGoogleBack";

	@Autowired
	private GoogleLinkService link;

	@RequestMapping("/admin/my/openGoogleLink.do")
	public ModelAndView openGoogleLink() {
		return new ModelAndView("bo/my/google_link");
	}

	@RequestMapping(value = "/admin/my/googleLinkData.do", method = RequestMethod.POST)
	public ModelAndView googleLinkData(HttpSession session) {
		Map<String, Map<String, Object>> by = new HashMap<>();
		for (Map<String, Object> l : link.links(GoogleLinkService.currentUser())) by.put((String) l.get("SERVICE_CD"), l);
		List<Map<String, Object>> out = new ArrayList<>();
		for (String svc : GoogleLinkService.SERVICES.keySet()) {
			Map<String, Object> row = by.containsKey(svc) ? by.get(svc) : new HashMap<String, Object>();
			row.put("SERVICE_CD", svc);
			row.put("LINKED", by.containsKey(svc));
			out.add(row);
		}
		return json("result", out);
	}

	/** 구글 승인 화면으로 보낸다. back 은 연결 뒤 돌아갈 이 사이트 안 주소 */
	@RequestMapping("/admin/my/googleStart.do")
	public String googleStart(@RequestParam("svc") String svc, @RequestParam(value = "back", required = false) String back, HttpServletRequest request, HttpSession session) {
		String state = UUID.randomUUID().toString();
		String url;
		try {
			url = link.authUrl(svc, redirectUri(request), state);
		} catch (IllegalArgumentException e) {
			return "redirect:/admin/my/openGoogleLink.do";
		}
		if (url == null) return "redirect:/admin/my/openGoogleLink.do?result=noclient";
		session.setAttribute(SS_STATE, state);
		session.setAttribute(SS_SERVICE, svc);
		// 열린 리디렉션이 되지 않게 이 사이트 /admin/ 아래 주소만 받는다
		session.setAttribute(SS_BACK, back != null && back.startsWith("/admin/") && !back.startsWith("//") ? back : null);
		return "redirect:" + url;
	}

	// 구글 콘솔에 이미 등록된 /admin/batch/driveCallback.do 로 돌아온다(새 URI 등록 없이). 이 주소는 BoSystemService.Access 가 모두에게 연다
	@RequestMapping({ "/admin/batch/driveCallback.do", "/admin/my/googleCallback.do" })
	public String googleCallback(@RequestParam Map<String, Object> param, HttpServletRequest request, HttpSession session) {
		Object state = session.getAttribute(SS_STATE), svc = session.getAttribute(SS_SERVICE), back = session.getAttribute(SS_BACK);
		session.removeAttribute(SS_STATE);
		session.removeAttribute(SS_SERVICE);
		session.removeAttribute(SS_BACK);
		String fail = "redirect:/admin/my/openGoogleLink.do?svc=" + (svc == null ? "" : svc) + "&result=";
		// state 가 다르면 이 세션이 시작한 승인이 아니다(CSRF). 사용자가 동의를 취소하면 code 없이 error 로 온다
		if (state == null || svc == null || !state.equals(param.get("state")) || param.get("code") == null) {
			return fail + (param.get("error") != null ? "denied" : "fail");
		}
		try {
			String why = link.connect(GoogleLinkService.currentUser(), (String) svc, redirectUri(request), (String) param.get("code"));
			if (why != null) return fail + why;
		} catch (RestClientException e) {
			System.out.println("GOOGLE_LINK_ERROR " + e.getClass().getSimpleName());
			return fail + "fail";
		}
		return back != null ? "redirect:" + back : "redirect:/admin/my/openGoogleLink.do?svc=" + svc + "&result=ok";
	}

	@RequestMapping(value = "/admin/my/googleUnlinkData.do", method = RequestMethod.POST)
	public ModelAndView googleUnlinkData(@RequestParam("svc") String svc) {
		try {
			link.disconnect(GoogleLinkService.currentUser(), svc);
			return json("result", "OK");
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	/** 구글 콘솔 등록값과 글자까지 같아야 한다. 프록시가 https 를 전달하지 않아 운영 도메인은 https 로 고정한다(BoBatchController 와 같음) */
	public static String redirectUri(HttpServletRequest request) {
		String host = request.getHeader("Host");
		String proto = host != null && host.startsWith("localhost") ? request.getScheme() : "https";
		return proto + "://" + host + "/admin/batch/driveCallback.do";
	}

	private static ModelAndView json(String key, Object value) {
		ModelAndView mv = new ModelAndView("jsonView");
		mv.addObject(key, value);
		return mv;
	}
}
