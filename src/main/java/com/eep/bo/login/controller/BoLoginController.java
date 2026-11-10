package com.eep.bo.login.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.collections4.MapUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.login.service.BoLoginRememberService;
import com.eep.bo.login.service.BoLoginService;
import com.eep.bo.member.service.BoMemberService;


@Controller
public class BoLoginController {

	@Autowired
	private BoLoginService BoLoginService;

	@Autowired
	private BoLoginRememberService BoLoginRememberService;

	@Autowired
	private BoMemberService memberService;

	@RequestMapping(value = "/admin/login/loginPage.do")
	public String openLoginPage(HttpServletRequest request, HttpServletResponse response) {
		if(BoLoginRememberService.restoreAdmin(request, response)) {
			return "redirect:/admin/home.do";
		}
		request.setAttribute("savedId", BoLoginRememberService.savedId(request));
		request.setAttribute("savedAutoCheck", BoLoginRememberService.savedAutoCheck(request));

		return "/bo/login/login_page";
	}
	
	
	//LOGIN DATA
	@RequestMapping("/admin/login/loginData.do")
	@ResponseBody
	public ModelAndView loginData(@RequestParam Map<String, Object> param,HttpServletRequest request,HttpServletResponse response) {
		
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
			//권한 체크 세션 생성
			@SuppressWarnings({ "unchecked", "unused" })
			List<Map<String, Object>> AuthCheck = (List<Map<String, Object>>) result.get("loginInfo");
			String emplyAuthCheck = (String) AuthCheck.get(0).get("emplyAuthTypCd");
			
			session.setAttribute("loginInfo", result);	
			session.setAttribute("emplyAuthCheck", emplyAuthCheck);
			memberService.touchLogin(emplyId);

			BoLoginRememberService.afterLogin(emplyId, param, request, response);	
		} 

		return mv;

	}
	
	//관리자 계정 로그아웃
	@RequestMapping("/admin/logout.do")
	//@ResponseBody
	public ModelAndView adminLogout (HttpSession session,HttpServletRequest request,HttpServletResponse response) {		
		
		ModelAndView mv = new ModelAndView();
		//세션이 이미 끊긴 상태에서 눌러도 자동로그인을 지우고 로그인 화면으로 보낸다
		BoLoginRememberService.clear(request, response);
		mv.setViewName("redirect:/admin/login/loginPage.do");
		//접속중인지 확인하기 위해 세션의 mbrSq의 값이 null 혹은 공백인지 확인
		if(session.getAttribute("loginInfo") != null && session.getAttribute("loginInfo") != "") {
			session.invalidate();
			mv.setViewName("redirect:/admin/login/loginPage.do");				
		}
		return mv;
	}
	
}
