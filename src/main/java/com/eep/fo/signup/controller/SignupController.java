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

	// 회사 메일 기준 가입으로 바꾸는 동안 개인 메일로 아이디가 생기지 않게 막는다
	private static final boolean PAUSED = true;

	@Autowired
	private SignupService service;

	@RequestMapping("/eep/signup/page.do")
	public String page() {
		return PAUSED ? "fo/signup/paused" : "fo/signup/signup";
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
		if (PAUSED) {
			mv.addObject("error", "가입 신청을 준비하고 있습니다. 인사 담당자에게 문의해 주세요.");
			return mv;
		}
		try {
			mv.addObject("result", work.get());
		} catch (IllegalArgumentException e) {
			mv.addObject("error", e.getMessage());
		}
		return mv;
	}
}
