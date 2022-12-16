package com.eep.fo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import common.base.controller.BaseController;

@Controller
public class FoMainController extends BaseController {

	@RequestMapping(value = "/eep/mainPage.do")
	public ModelAndView openFoMainPage() {
		
		ModelAndView mv = new ModelAndView("/main");
		return mv;
	}
	
}
