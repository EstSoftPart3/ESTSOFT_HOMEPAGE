package com.eep.bo.mail.controller;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.mail.service.BoMailService;

@Controller
public class BoMailController {

	@Autowired
	private BoMailService BoMailService;

	/**
	 * 업무툴 - 메일계정 관리 Controller
	 * 권한은 /admin/** 인터셉터(관리자만 통과)가 맡는다. 쓰기는 POST 만 받는다
	 *
	 * **/

	@RequestMapping("/admin/mail/openMailAccount.do")
	public ModelAndView openMailAccount() {
		return new ModelAndView("bo/mail/mail_account");
	}

	@RequestMapping(value = "/admin/mail/mailAccountListData.do", method = RequestMethod.POST)
	public ModelAndView mailAccountListData() {
		return json("list", BoMailService.AcctList());
	}

	@RequestMapping(value = "/admin/mail/saveMailAccountData.do", method = RequestMethod.POST)
	public ModelAndView saveMailAccountData(@RequestParam Map<String, Object> param, HttpSession session) {
		try {
			BoMailService.AcctAdd(param, loginId(session));
			return json("result", "OK");
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/mail/deleteMailAccountData.do", method = RequestMethod.POST)
	public ModelAndView deleteMailAccountData(@RequestParam Map<String, Object> param) {
		BoMailService.AcctDelete(param);
		return json("result", "OK");
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
}
