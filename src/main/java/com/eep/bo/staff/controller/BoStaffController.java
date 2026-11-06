package com.eep.bo.staff.controller;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.staff.service.BoStaffService;

/**
 * 직원 - 직원관리(인사카드) Controller
 * 권한은 /admin/** 인터셉터(관리자만 통과)가 맡는다. 쓰기와 원문 보기는 POST 만 받는다
 */
@Controller
public class BoStaffController {

	@Autowired
	private BoStaffService BoStaffService;

	@RequestMapping("/admin/staff/openStaffList.do")
	public ModelAndView openStaffList() {
		return new ModelAndView("bo/staff/staff_list");
	}

	@RequestMapping(value = "/admin/staff/staffListData.do", method = RequestMethod.POST)
	public ModelAndView staffListData() {
		return json("list", BoStaffService.list());
	}

	@RequestMapping(value = "/admin/staff/revealStaffData.do", method = RequestMethod.POST)
	public ModelAndView revealStaffData(@RequestParam Map<String, Object> param, HttpSession session) {
		try {
			String value = BoStaffService.reveal(param);
			// 누가 누구의 어느 값을 봤는지만 남긴다(값은 남기지 않는다)
			System.out.println("STAFF_REVEAL by=" + loginId(session) + " staff=" + param.get("STAFF_SQ") + " field=" + param.get("FIELD"));
			return json("value", value);
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/staff/saveStaffFieldData.do", method = RequestMethod.POST)
	public ModelAndView saveStaffFieldData(@RequestParam Map<String, Object> param, HttpSession session) {
		try {
			param.put("UPDT_EMPLY_ID", loginId(session));
			BoStaffService.fieldSave(param);
			return json("result", "OK");
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/staff/insertStaffData.do", method = RequestMethod.POST)
	public ModelAndView insertStaffData(@RequestParam Map<String, Object> param, HttpSession session) {
		try {
			param.put("UPDT_EMPLY_ID", loginId(session));
			return json("STAFF_SQ", BoStaffService.insert(param));
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/staff/deleteStaffData.do", method = RequestMethod.POST)
	public ModelAndView deleteStaffData(@RequestParam Map<String, Object> param) {
		BoStaffService.delete(param);
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
