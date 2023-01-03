package com.eep.bo.login.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.commons.collections4.MapUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.login.service.BoLoginService;


@Controller
public class BoLoginController {

	@Autowired
	private BoLoginService BoLoginService;
	
	@RequestMapping(value = "/admin/login/loginPage.do")
	public String openLoginPage() {

		return "/bo/login/login_page";
	}
	
	
	//LOGIN DATA
	@RequestMapping("/admin/login/loginData.do")
	@ResponseBody
	public ModelAndView loginData(@RequestParam Map<String, Object> param,HttpServletRequest request) {
		
		HttpSession session = request.getSession();
		ModelAndView mv = new ModelAndView("jsonView");	

		String emplyId = (String) param.get("emplyId");
		String emplyPw = (String) param.get("emplyPw");
		
		param.put("emplyId", emplyId);
		param.put("emplyPw", emplyPw);
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoLoginService.loginAdminData(param);
		
		mv.addObject("result", result);
		
		if(result.get("loginInfo").toString().length() != 2) {
			session.setAttribute("loginInfo", result);	
		} 

		return mv;

	}
	
	//관리자 계정 로그아웃
	@RequestMapping("/admin/logout.do")
	//@ResponseBody
	public ModelAndView adminLogout (HttpSession session) {		
		
		ModelAndView mv = new ModelAndView();
		//접속중인지 확인하기 위해 세션의 mbrSq의 값이 null 혹은 공백인지 확인
		if(session.getAttribute("loginInfo") != null && session.getAttribute("loginInfo") != "") {
			session.invalidate();
			mv.setViewName("redirect:/admin/login/loginPage.do");				
		}
		return mv;
	}
	
}
