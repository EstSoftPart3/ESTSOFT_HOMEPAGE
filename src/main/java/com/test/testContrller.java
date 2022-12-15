package com.test;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class testContrller {

	@RequestMapping(value = "/")
	public ModelAndView home() {
		
		ModelAndView mv = new ModelAndView("/test_page");
		return mv;
	}
}
