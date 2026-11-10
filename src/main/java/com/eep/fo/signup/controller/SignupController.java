package com.eep.fo.signup.controller;

import java.util.function.Supplier;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.eep.fo.signup.service.SignupService;

/** 로그인 없이 쓰는 직원 본인 가입 */
@Controller
public class SignupController {

	@Autowired
	private SignupService service;

	@RequestMapping("/eep/signup/page.do")
	public String page() {
		return "fo/signup/signup";
	}

	@RequestMapping(value = "/eep/signup/matchData.do", method = RequestMethod.POST)
	public ModelAndView matchData(@RequestParam("NAME") String name, @RequestParam("JOIN_DT") String joinDt, @RequestParam("BIRTH") String birth,
			@RequestParam("PHONE") String phone, HttpSession session) {
		return call(() -> service.match(name, joinDt, birth, phone, session));
	}

	@RequestMapping(value = "/eep/signup/sendCodeData.do", method = RequestMethod.POST)
	public ModelAndView sendCodeData(@RequestParam("STAFF_SQ") int staffSq, HttpSession session) {
		return call(() -> service.send(staffSq, session));
	}

	@RequestMapping(value = "/eep/signup/verifyData.do", method = RequestMethod.POST)
	public ModelAndView verifyData(@RequestParam("CODE") String code, HttpSession session) {
		return call(() -> service.verify(code, session));
	}

	private static ModelAndView call(Supplier<Object> work) {
		ModelAndView mv = new ModelAndView("jsonView");
		try {
			mv.addObject("result", work.get());
		} catch (IllegalArgumentException e) {
			mv.addObject("error", e.getMessage());
		}
		return mv;
	}
}
