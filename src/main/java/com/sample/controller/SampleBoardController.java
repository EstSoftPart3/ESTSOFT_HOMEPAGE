package com.sample.controller;

import java.util.List;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Controller;

import org.springframework.web.bind.annotation.RequestMapping;

import org.springframework.web.servlet.ModelAndView;

import com.sample.service.SampleBoardService;
import com.sample.vo.BoardSampleVo;

@Controller
public class SampleBoardController{
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Resource(name = "sampleBoardService")
	SampleBoardService sampleBoardService;

	
	//샘플 게시판 페이징+리스트 페이지 오픈
	//처리형태 : ajax
	@RequestMapping(value="/erp/sample/openSampleBoardAjaxPage.do")
	public ModelAndView openPageingentalListPage(BoardSampleVo Vo) throws Exception {

		ModelAndView mv = new ModelAndView("sampleBoard/scr_paging_ajax_excel_list");
		
		List<BoardSampleVo> list = sampleBoardService.sampleBoardAjaxPagingList(Vo);
		
		/*System.out.println("LIST :" + list);*/
		
	    return mv;  
	}
	
}
