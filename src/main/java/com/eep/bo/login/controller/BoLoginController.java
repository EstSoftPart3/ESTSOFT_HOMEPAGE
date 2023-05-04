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
import com.eep.mapper.BoLoginMapper;


@Controller
public class BoLoginController {

	@Autowired
	private BoLoginService BoLoginService;
	
	@Autowired
	private BoLoginMapper BoLoginMapper;
	
	@RequestMapping(value = "/admin/login/loginPage.do")
	public String openLoginPage() {

		return "/bo/login/login_page";
	}
	
}
