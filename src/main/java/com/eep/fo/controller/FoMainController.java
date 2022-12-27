package com.eep.fo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import common.base.controller.BaseController;

@Controller
public class FoMainController extends BaseController {

	//메인 페이지
	@RequestMapping(value = "/eep/mainPage.do")
	public ModelAndView openFoMainPage() { 
		
		ModelAndView mv = new ModelAndView("/index");
		return mv;
	}
	
	//회사연혁
	@RequestMapping(value = "/eep/historyPage.do")
	public ModelAndView openFoHistoryPage() { 
		
		ModelAndView mv = new ModelAndView("/history");
		return mv;
	}
	
	//조직도
	@RequestMapping(value = "/eep/organizationPage.do")
	public ModelAndView openFoOrganizationPage() { 
		
		ModelAndView mv = new ModelAndView("/organization");
		return mv;
	}
	
	
	//CEO 인사말
	@RequestMapping(value = "/eep/ceoPage.do")
	public ModelAndView openFoCeoPage() { 
		
		ModelAndView mv = new ModelAndView("/ceo");
		return mv;
	}
	
	
	//자격인증
	@RequestMapping(value = "/eep/certiPage.do")
	public ModelAndView openFoCertiPage() { 
		ModelAndView mv = new ModelAndView("/certification");
		return mv;
	}
	
	
}
