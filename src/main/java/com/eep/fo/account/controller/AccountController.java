package com.eep.fo.account.controller;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.member.service.BoMemberService;

/** 직원·관리자 공통 비밀번호 변경. 로그인 세션의 본인만 바꾼다 */
@Controller
public class AccountController {

	@Autowired
	private BoMemberService service;

	@RequestMapping("/eep/account/changePassword.do")
	public ModelAndView changePassword(HttpSession session) {
		return login(session) == null ? new ModelAndView("redirect:/eep/login/loginPage.do") : new ModelAndView("fo/account/change_password");
	}

	@RequestMapping(value = "/eep/account/changePasswordData.do", method = RequestMethod.POST)
	public ModelAndView changePasswordData(@RequestParam("CURRENT_PW") String current, @RequestParam("NEW_PW") String next, HttpSession session) {
		ModelAndView mv = new ModelAndView("jsonView");
		Map<String, Object> login = login(session);
		if (login == null) {
			mv.addObject("error", "다시 로그인해 주세요.");
			return mv;
		}
		try {
			service.changeOwnPassword((String) login.get("emplyId"), current, next);
			login.put("pwInitYn", "N");
			mv.addObject("result", "2".equals(session.getAttribute("emplyAuthCheck")) ? "/admin/home.do" : "/eep/mainPage.do");
		} catch (IllegalArgumentException e) {
			mv.addObject("error", e.getMessage());
		}
		return mv;
	}

	@SuppressWarnings("unchecked")
	private static Map<String, Object> login(HttpSession session) {
		Map<String, Object> info = (Map<String, Object>) session.getAttribute("loginInfo");
		return info == null ? null : ((List<Map<String, Object>>) info.get("loginInfo")).get(0);
	}
}
