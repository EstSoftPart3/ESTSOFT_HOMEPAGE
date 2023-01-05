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
	@RequestMapping("/eep/board/education/educationBoardUpdateData.do")
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
	
	/**
	 * 자유 게시판 Controller
	 * 
	 * **/
	
	//자유 게시판 목록 페이지 이동
	@RequestMapping("/eep/board/freedom/openFreedomBoardList.do")
	public String openFreedomBoardList() {
		
		return "fo/board/freedom/freedom_board_list";
	}
	
	//자유 게시판 목록 데이터
	@RequestMapping("/eep/board/freedom/freedomBoardListData.do")
	@ResponseBody
	public ModelAndView freedomBoardListData(@RequestParam Map<String, Object> param,
											 @RequestParam(defaultValue="1") int curPage) {
		
		ModelAndView mv = new ModelAndView();
		mv.setViewName("jsonView");
		
		int count = FoBoardService.freedomBoardListCountData(param);
		
		pagerMaster pagerMaster = new pagerMaster(count, curPage, 10, 10);
		int start = pagerMaster.getPageBegin();
		int end = pagerMaster.getPageEnd();
		
		param.put("start", start);
		param.put("end", end);
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardService.freedomBoardListData(param);
									
		mv.addObject("freedomBoardData", result);
		mv.addObject("boardPager", pagerMaster);
		
		return mv;
	}
	
	//자유 게시판 등록 페이지 이동
	@RequestMapping("/eep/board/freedom/openFreedomBoardInsert.do")
	public String openFreedomBoardInsert() {
		
		return "fo/board/freedom/freedom_board_insert";
	}
	
	//자유 게시판 등록 데이터
	@RequestMapping("/eep/board/freedom/freedomBoardInsertData.do")
	@ResponseBody
	public void freedomBoardInsertData(@RequestParam Map<String, Object> param) {

	    int emplySq = Integer.parseInt((String) param.get("emplySq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String brdWrtr = (String) param.get("brdWrtr");

		param.put("emplySq", emplySq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("brdWrtr", brdWrtr);
		
		System.out.println(param);
		
		FoBoardService.freedomBoardInsertData(param);

	}
	
	//자유  게시판 상세 페이지 이동
	@RequestMapping("/eep/board/freedom/openFreedomBoardDetail.do")
	public String openFreedomBoardDetail() {
		
		return "fo/board/freedom/freedom_board_detail";
	}
	
	//자유 게시판 상세 데이터
	@RequestMapping("/eep/board/freedom/freedomBoardDetailData.do")
	@ResponseBody
	public ModelAndView freedomBoardDetailData(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		
		mv.setViewName("jsonView");
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardService.freedomBoardDetailData(param);
		
		mv.addObject("freedomBoardDetailData", result);
		
		return mv;
	}
	
	//자유  게시판 답글 등록 페이지 이동
	@RequestMapping("/eep/board/freedom/openFeedomBoardReplyInsert.do")
	public String openㄹreedomBoardReplyInsert() {
		
		return "fo/board/freedom/freedom_board_reply_insert";
	}
	
	//자유 게시판 답글 등록 데이터
	@RequestMapping("/eep/board/freedom/freedomBoardReplyInsertData.do")
	@ResponseBody
	public void freedomBoardReplyInsertData(@RequestParam Map<String, Object> param) {

	    int emplySq = Integer.parseInt((String) param.get("emplySq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String brdWrtr = (String) param.get("brdWrtr");
		int brdReRep = Integer.parseInt((String) param.get("brdReRep"));
		int brdReLev = Integer.parseInt((String) param.get("brdReLev"));
		int brdReOrd = Integer.parseInt((String) param.get("brdReOrd"));

		
		param.put("emplySq", emplySq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("brdWrtr", brdWrtr);
		param.put("brdReRep", brdReRep);
		param.put("brdReLev", brdReLev);
		param.put("brdReOrd", brdReOrd);
		
		System.out.println(param);
		
		FoBoardService.freedomBoardReplyInsertData(param);

	}

	//자유 게시판 삭제
	@RequestMapping("/eep/board/freedom/freedomBoardDeleteData.do")
	@ResponseBody
	public void freedomBoardDeleteData(@RequestParam Map<String, Object> param) {
		
		int brdSq = Integer.parseInt((String) param.get("brdSq"));
	
		param.put("brdSq", brdSq);
		
		FoBoardService.freedomBoardDeleteData(param);
		
	}
	
	//자유 게시판 수정 페이지 이동
	@RequestMapping("/eep/board/freedom/openFreedomBoardUpdate.do")
	public String openFreedomBoardUpdate() {
		
		return "fo/board/freedom/freedom_board_update";
	}
	
	//자유 게시판 수정
	@RequestMapping("/eep/board/freedom/freedomBoardUpdateData.do")
	@ResponseBody
	public void freedomBoardUpdateData(@RequestParam Map<String, Object> param) {

		
	    int brdSq = Integer.parseInt((String) param.get("brdSq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");

		param.put("brdSq", brdSq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);

		System.out.println(param);

		
		FoBoardService.freedomBoardUpdateData(param);
		
	}
	
	/**
	 * 기술문의 게시판 Controller
	 * 
	 * **/
	
	//기술문의 게시판 목록 페이지 이동
	@RequestMapping("/eep/board/technology/openTechnologyBoardList.do")
	public String openTechnologyBoardList() {
		
		return "fo/board/technology/technology_board_list";
	}
	
	//기술문의 게시판 목록 데이터
	@RequestMapping("/eep/board/technology/technologyBoardListData.do")
	@ResponseBody
	public ModelAndView technologyBoardListData(@RequestParam Map<String, Object> param,
											 @RequestParam(defaultValue="1") int curPage) {
		
		ModelAndView mv = new ModelAndView();
		mv.setViewName("jsonView");
		
		int count = FoBoardService.technologyBoardListCountData(param);
		
		pagerMaster pagerMaster = new pagerMaster(count, curPage, 10, 10);
		int start = pagerMaster.getPageBegin();
		int end = pagerMaster.getPageEnd();
		
		param.put("start", start);
		param.put("end", end);
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardService.technologyBoardListData(param);
									
		mv.addObject("technologyBoardData", result);
		mv.addObject("boardPager", pagerMaster);
		
		return mv;
	}
	
	//기술문의 게시판 등록 페이지 이동
	@RequestMapping("/eep/board/technology/openTechnologyBoardInsert.do")
	public String openTechnologyBoardInsert() {
		
		return "fo/board/technology/technology_board_insert";
	}
	
	//기술문의 게시판 등록 데이터
	@RequestMapping("/eep/board/technology/technologyBoardInsertData.do")
	@ResponseBody
	public void technologyBoardInsertData(@RequestParam Map<String, Object> param) {

	    int emplySq = Integer.parseInt((String) param.get("emplySq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String brdWrtr = (String) param.get("brdWrtr");

		param.put("emplySq", emplySq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("brdWrtr", brdWrtr);
		
		System.out.println(param);
		
		FoBoardService.technologyBoardInsertData(param);

	}
	
	//기술문의  게시판 상세 페이지 이동
	@RequestMapping("/eep/board/technology/openTechnologyBoardDetail.do")
	public String openTechnologyBoardDetail() {
		
		return "fo/board/technology/technology_board_detail";
	}
	
	//기술문의 게시판 상세 데이터
	@RequestMapping("/eep/board/technology/technologyBoardDetailData.do")
	@ResponseBody
	public ModelAndView technologyBoardDetailData(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		
		mv.setViewName("jsonView");
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardService.technologyBoardDetailData(param);
		
		mv.addObject("technologyBoardDetailData", result);
		
		return mv;
	}
	
	//기술문의  게시판 답글 등록 페이지 이동
	@RequestMapping("/eep/board/technology/openTechnologyBoardReplyInsert.do")
	public String openTechnologyBoardReplyInsert() {
		
		return "fo/board/technology/technology_board_reply_insert";
	}
	
	//기술문의 게시판 답글 등록 데이터
	@RequestMapping("/eep/board/technology/technologyBoardReplyInsertData.do")
	@ResponseBody
	public void technologyBoardReplyInsertData(@RequestParam Map<String, Object> param) {

	    int emplySq = Integer.parseInt((String) param.get("emplySq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String brdWrtr = (String) param.get("brdWrtr");
		int brdReRep = Integer.parseInt((String) param.get("brdReRep"));
		int brdReLev = Integer.parseInt((String) param.get("brdReLev"));
		int brdReOrd = Integer.parseInt((String) param.get("brdReOrd"));

		
		param.put("emplySq", emplySq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("brdWrtr", brdWrtr);
		param.put("brdReRep", brdReRep);
		param.put("brdReLev", brdReLev);
		param.put("brdReOrd", brdReOrd);
		
		System.out.println(param);
		
		FoBoardService.technologyBoardReplyInsertData(param);

	}

	//기술문의 게시판 삭제
	@RequestMapping("/eep/board/technology/technologyBoardDeleteData.do")
	@ResponseBody
	public void technologyBoardDeleteData(@RequestParam Map<String, Object> param) {
		
		int brdSq = Integer.parseInt((String) param.get("brdSq"));
	
		param.put("brdSq", brdSq);
		
		FoBoardService.technologyBoardDeleteData(param);
		
	}
	
	//기술문의 게시판 수정 페이지 이동
	@RequestMapping("/eep/board/technology/openTechnologyBoardUpdate.do")
	public String openTechnologyBoardUpdate() {
		
		return "fo/board/technology/technology_board_update";
	}
	
	//기술문의 게시판 수정
	@RequestMapping("/eep/board/technology/technologyBoardUpdateData.do")
	@ResponseBody
	public void technologyBoardUpdateData(@RequestParam Map<String, Object> param) {

		
	    int brdSq = Integer.parseInt((String) param.get("brdSq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");

		param.put("brdSq", brdSq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);

		System.out.println(param);

		
		FoBoardService.technologyBoardUpdateData(param);
		
	}
	
}
