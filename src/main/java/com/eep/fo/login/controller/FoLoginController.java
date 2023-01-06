package com.eep.fo.login.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.eep.fo.login.service.FoLoginService;
import com.eep.mapper.FoLoginMapper;

@Controller
public class FoLoginController {

	@Autowired
	private FoLoginService FoLoginService;
	
	@Autowired
	private FoLoginMapper FoLoginMapper;
	
	@RequestMapping(value = "/eep/login/loginPage.do")
	public String openLoginPage() {

		return "/fo/login/login_page";
	}
	
	
	//LOGIN DATA
	@RequestMapping("/eep/login/loginData.do")
	@ResponseBody
	public ModelAndView loginData(@RequestParam Map<String, Object> param,HttpServletRequest request) {
		
		HttpSession session = request.getSession();
		ModelAndView mv = new ModelAndView("jsonView");	

		String emplyId = (String) param.get("emplyId");
		String emplyPw = (String) param.get("emplyPw");
		
		param.put("emplyId", emplyId);
		param.put("emplyPw", emplyPw);
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoLoginService.loginAdminData(param);
		
		mv.addObject("result", result);

		if(result.get("loginInfo").toString().length() != 2) {
			
			//권한 체크 세션 생성
			@SuppressWarnings({ "unchecked", "unused" })
			List<Map<String, Object>> AuthCheck = FoLoginMapper.loginAdminData(param);
			String emplyAuthCheck = (String) AuthCheck.get(0).get("emplyAuthTypCd");
			
			System.out.println("emplyAuthCheck : : " + emplyAuthCheck);
			
			session.setAttribute("loginInfo", result);	
			session.setAttribute("emplyAuthCheck", emplyAuthCheck);
		} 

		return mv;

	}
	
	//직원 계정 로그아웃
	@RequestMapping("/eep/logout.do")
	//@ResponseBody
	public ModelAndView adminLogout (HttpSession session) {		
		
		ModelAndView mv = new ModelAndView();
		//접속중인지 확인하기 위해 세션의 mbrSq의 값이 null 혹은 공백인지 확인
		if(session.getAttribute("loginInfo") != null && session.getAttribute("loginInfo") != "") {
			session.invalidate();
			mv.setViewName("redirect:/eep/mainPage.do");				
		}
		return mv;
	}
	
}
