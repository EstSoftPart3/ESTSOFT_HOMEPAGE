package com.eep.fo.board.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.board.service.BoBoardService;
import com.eep.fo.board.service.FoBoardService;

@Controller
public class FoBoardController {

	@Autowired
	private FoBoardService FoBoardService;
	
	/**
	 * 공지사항 게시판 Controller
	 * 
	 * **/
	
	//공지사항 게시판 목록 페이지 이동
	@RequestMapping("/eep/board/notice/openNoticeBoardList.do")
	public String openNoticeBoardList() {
		
		return "fo/board/notice/notice_board_list";
	}
	
	//공지사항 게시판 목록 데이터
	@RequestMapping("/eep/board/notice/noticeBoardListData.do")
	@ResponseBody
	public ModelAndView noticeBoardListData(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		mv.setViewName("jsonView");
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardService.noticeBoardListData(param);
									
		mv.addObject("noticeBoardData", result);
		
		return mv;
	}
	
	//공지사항 게시판 등록 페이지 이동
	@RequestMapping("/eep/board/notice/openNoticeBoardInsert.do")
	public String openNoticeBoardInsert() {
		
		return "fo/board/notice/notice_board_insert";
	}
	
	//공지사항 게시판 등록 데이터
	@RequestMapping("/eep/board/notice/noticeBoardInsertData.do")
	@ResponseBody
	public void noticeBoardInsertData(@RequestParam Map<String, Object> param) {

	    int emplySq = Integer.parseInt((String) param.get("emplySq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String brdWrtr = (String) param.get("brdWrtr");

		param.put("emplySq", emplySq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("brdWrtr", brdWrtr);
		
		System.out.println(param);
		
		FoBoardService.noticeBoardInsertData(param);

	}
	
	//공지사항 게시판 상세 페이지 이동
	@RequestMapping("/eep/board/notice/openNoticeBoardDetail.do")
	public String openNoticeBoardDetail() {
		
		return "fo/board/notice/notice_board_detail";
	}
	
	//공지사항 게시판 상세 데이터
	@RequestMapping("/eep/board/notice/noticeBoardDetailData.do")
	@ResponseBody
	public ModelAndView noticeBoardDetailData(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		
		mv.setViewName("jsonView");
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardService.noticeBoardDetailData(param);
		
		mv.addObject("noticeBoardDetailData", result);
		
		return mv;
	}
	
	//공지사항 게시판 삭제
	@RequestMapping("/eep/board/notice/noticeBoardDeleteData.do")
	@ResponseBody
	public void noticeBoardDeleteData(@RequestParam Map<String, Object> param) {
		
		int brdSq = Integer.parseInt((String) param.get("brdSq"));
	
		param.put("brdSq", brdSq);
		
		FoBoardService.noticeBoardDeleteData(param);
		
	}
	
	//공지사항 게시판 수정 페이지 이동
	@RequestMapping("/eep/board/notice/openNoticeBoardUpdate.do")
	public String openNoticeBoardUpdate() {
		
		return "fo/board/notice/notice_board_update";
	}
	
	//공지사항 게시판 수정
	@RequestMapping("/eep/board/notice/noticeBoardUpdateData.do")
	@ResponseBody
	public void noticeBoardUpdateData(@RequestParam Map<String, Object> param) {

		
	    int brdSq = Integer.parseInt((String) param.get("brdSq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");

		param.put("brdSq", brdSq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);

		System.out.println(param);

		FoBoardService.noticeBoardUpdateData(param);
		
	}
	
}
