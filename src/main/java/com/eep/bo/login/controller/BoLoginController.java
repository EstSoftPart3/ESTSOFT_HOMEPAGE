package com.eep.bo.login.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class BoLoginController {

	@RequestMapping(value = "/admin/login/openLoginPage.do")
	public ModelAndView openLoginPage() {
		
		ModelAndView mv = new ModelAndView("/bo/login/login");
		return mv;
	}
	
}
