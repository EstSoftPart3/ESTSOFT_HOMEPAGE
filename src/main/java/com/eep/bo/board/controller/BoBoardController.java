package com.eep.bo.board.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class BoBoardController {
	
	@RequestMapping(value = "/admin/openAdminMainPage.do")
	public ModelAndView openBoMainpage() {
		
		ModelAndView mv = new ModelAndView("/bo/board/board_main_page");
		return mv;
	}
	
}
