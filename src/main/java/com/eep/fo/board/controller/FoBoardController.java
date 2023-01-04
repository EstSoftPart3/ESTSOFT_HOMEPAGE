package com.eep.fo.board.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.common.pager.pagerMaster;
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
	public ModelAndView noticeBoardListData(@RequestParam Map<String, Object> param, 
											@RequestParam(defaultValue="1") int curPage) {
		
		ModelAndView mv = new ModelAndView();
		mv.setViewName("jsonView");
		
		int count = FoBoardService.noticeBoardListCountData(param);
		
		pagerMaster pagerMaster = new pagerMaster(count, curPage, 10, 10);
		int start = pagerMaster.getPageBegin();
		int end = pagerMaster.getPageEnd();
		
		param.put("start", start);
		param.put("end", end);
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardService.noticeBoardListData(param);
									
		mv.addObject("noticeBoardData", result);
		mv.addObject("boardPager", pagerMaster);
		
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
	
	/**
	 * 교육일정 게시판 Controller
	 * 
	 * **/
	
	//교율일정 게시판 목록 페이지 이동
	@RequestMapping("/eep/board/education/openEducationBoardList.do")
	public String openEducationBoardList() {
		
		return "fo/board/education/education_board_list";
	}
	
	//공지사항 게시판 목록 데이터
	@RequestMapping("/eep/board/education/educationBoardListData.do")
	@ResponseBody
	public ModelAndView educationBoardListData(@RequestParam Map<String, Object> param, 
											@RequestParam(defaultValue="1") int curPage) {
		
		ModelAndView mv = new ModelAndView();
		mv.setViewName("jsonView");
		
		int count = FoBoardService.educationBoardListCountData(param);
		
		pagerMaster pagerMaster = new pagerMaster(count, curPage, 10, 10);
		int start = pagerMaster.getPageBegin();
		int end = pagerMaster.getPageEnd();
		
		param.put("start", start);
		param.put("end", end);
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardService.educationBoardListData(param);
									
		mv.addObject("educationBoardData", result);
		mv.addObject("boardPager", pagerMaster);
		
		return mv;
	}
	
	//교육일정 게시판 등록 페이지 이동
	@RequestMapping("/eep/board/education/openEducationBoardInsert.do")
	public String openEducationBoardInsert() {
		
		return "fo/board/education/education_board_insert";
	}
	
	//교육일정 게시판 등록 데이터
	@RequestMapping("/eep/board/education/educationBoardInsertData.do")
	@ResponseBody
	public void educationBoardInsertData(@RequestParam Map<String, Object> param) {

	    int emplySq = Integer.parseInt((String) param.get("emplySq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String brdWrtr = (String) param.get("brdWrtr");
		String brdTchr = (String) param.get("brdTchr");
		String brdEduDt = (String) param.get("brdEduDt");

		param.put("emplySq", emplySq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("brdWrtr", brdWrtr);
		param.put("brdTchr", brdTchr);
		param.put("brdEduDt", brdEduDt);
		
		System.out.println(param);
		
		FoBoardService.educationBoardInsertData(param);

	}
	
	//교육일정 게시판 상세 페이지 이동
	@RequestMapping("/eep/board/education/openEducationBoardDetail.do")
	public String openEducationBoardDetail() {
		
		return "fo/board/education/education_board_detail";
	}
	
	//교육일정 게시판 상세 데이터
	@RequestMapping("/eep/board/education/educationBoardDetailData.do")
	@ResponseBody
	public ModelAndView educationBoardDetailData(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		
		mv.setViewName("jsonView");
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardService.educationBoardDetailData(param);
		
		mv.addObject("educationBoardDetailData", result);
		
		return mv;
	}
	
	//교육일정 게시판 삭제
	@RequestMapping("/eep/board/education/educationBoardDeleteData.do")
	@ResponseBody
	public void educationBoardDeleteData(@RequestParam Map<String, Object> param) {
		
		int brdSq = Integer.parseInt((String) param.get("brdSq"));
	
		param.put("brdSq", brdSq);
		
		FoBoardService.educationBoardDeleteData(param);
		
	}
	
	//교육일정 게시판 수정 페이지 이동
	@RequestMapping("/eep/board/education/openEducationBoardUpdate.do")
	public String openEducationBoardUpdate() {
		
		return "fo/board/education/education_board_update";
	}
	
	//교육일정 게시판 수정
	@RequestMapping("/eep/board/educationeducationBoardUpdateData.do")
	@ResponseBody
	public void educationBoardUpdateData(@RequestParam Map<String, Object> param) {

		
	    int brdSq = Integer.parseInt((String) param.get("brdSq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String brdTchr = (String) param.get("brdTchr");
		String brdEduDt = (String) param.get("brdEduDt");

		param.put("brdSq", brdSq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("brdTchr", brdTchr);
		param.put("brdEduDt", brdEduDt);

		System.out.println(param);

		FoBoardService.educationBoardUpdateData(param);
		
	}
	
}
