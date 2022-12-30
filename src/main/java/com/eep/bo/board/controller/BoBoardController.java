package com.eep.bo.board.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.board.service.BoBoardService;
import com.eep.bo.board.vo.BoBoardVo;

@Controller
public class BoBoardController {
	
	@Autowired
	private BoBoardService BoBoardService;
	
	
	@RequestMapping(value = "/admin/openAdminMainPage.do")
	public ModelAndView openBoMainpage() {
		
		ModelAndView mv = new ModelAndView("/bo/board/board_main_page");
		return mv;
	}
	
	/*@RequestMapping(value = "/admin/boardListPage.do")
	public ModelAndView boardListPage() {
		
		ModelAndView mv = new ModelAndView("/bo/board/boardList");
		return mv;
	}
	
    *//** 게시판 - 목록 조회 */
    /*@RequestMapping(value = "/admin/getBoardList.do")
    public ModelAndView getBoardList(BoBoardVo BoBoardVo) throws Exception {
 
    	ModelAndView mv = new ModelAndView("jsonView");
    	
    	List<BoBoardVo> list = BoBoardService.getBoardList(BoBoardVo);
 
    	mv.addObject("list", list);
    	
        return mv;
    }*/
	//게시판 목록 페이지 이동
	@RequestMapping("/admin/board/boardListPage.do")
	public String openBoardList(HttpServletRequest req) {
		
		String brdTypCd = req.getParameter("brdTypCd");
		
		return "bo/board/boardList";
	}
	
	//게시판 목록 데이터
	@RequestMapping("/admin/board/boardListData.do")
	@ResponseBody
	public ModelAndView boardListData(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		mv.setViewName("jsonView");
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardService.boardListData(param);
									
		mv.addObject("boardData", result);
		
		return mv;
	}

	/**
	 * 공지사항 게시판 Controller
	 * 
	 * **/
	
	//공지사항 게시판 목록 페이지 이동
	@RequestMapping("/admin/board/notice/openNoticeBoardList.do")
	public String openNoticeBoardList() {
		
		return "bo/board/notice/notice_board_list";
	}
	
	//공지사항 게시판 목록 데이터
	@RequestMapping("/admin/board/notice/noticeBoardListData.do")
	@ResponseBody
	public ModelAndView noticeBoardListData(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		mv.setViewName("jsonView");
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardService.noticeBoardListData(param);
									
		mv.addObject("noticeBoardData", result);
		
		return mv;
	}
	
	//공지사항 게시판 등록 페이지 이동
	@RequestMapping("/admin/board/notice/openNoticeBoardInsert.do")
	public String openNoticeBoardInsert() {
		
		return "bo/board/notice/notice_board_insert";
	}
	
	//공지사항 게시판 등록 데이터
	@RequestMapping("/admin/board/notice/noticeBoardInsertData.do")
	@ResponseBody
	public void noticeBoardInsertData(@RequestParam Map<String, Object> param) {

	    int emplySq = Integer.parseInt((String) param.get("emplySq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String brdWrtr = (String) param.get("brdWrtr");
		String useYn = (String) param.get("useYn");

		param.put("emplySq", emplySq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("brdWrtr", brdWrtr);
		param.put("useYn", useYn);
		
		System.out.println(param);
		
		BoBoardService.noticeBoardInsertData(param);

	}
	
	//공지사항 게시판 상세 페이지 이동
	@RequestMapping("/admin/board/notice/openNoticeBoardDetail.do")
	public String openNoticeBoardDetail() {
		
		return "bo/board/notice/notice_board_detail";
	}
	
	//공지사항 게시판 상세 데이터
	@RequestMapping("/admin/board/notice/noticeBoardDetailData.do")
	@ResponseBody
	public ModelAndView noticeBoardDetailData(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		
		mv.setViewName("jsonView");
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardService.noticeBoardDetailData(param);
		
		mv.addObject("noticeBoardDetailData", result);
		
		return mv;
	}
	
	//공지사항 게시판 삭제
	@RequestMapping("/admin/board/notice/noticeBoardDeleteData.do")
	@ResponseBody
	public void noticeBoardDeleteData(@RequestParam Map<String, Object> param) {
		
		int brdSq = Integer.parseInt((String) param.get("brdSq"));
	
		param.put("brdSq", brdSq);
		
		BoBoardService.noticeBoardDeleteData(param);
		
	}
	
	//공지사항 게시판 수정 페이지 이동
	@RequestMapping("/admin/board/notice/openNoticeBoardUpdate.do")
	public String openNoticeBoardUpdate() {
		
		return "bo/board/notice/notice_board_update";
	}
	
	//공지사항 게시판 수정
	@RequestMapping("/admin/board/notice/noticeBoardUpdateData.do")
	@ResponseBody
	public void noticeBoardUpdateData(@RequestParam Map<String, Object> param) {

		
	    int brdSq = Integer.parseInt((String) param.get("brdSq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String useYn = (String) param.get("useYn");;
		String delYn = (String) param.get("delYn");;

		param.put("brdSq", brdSq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("useYn", useYn);
		param.put("delYn", delYn);

		
		System.out.println(param);

		
		BoBoardService.noticeBoardUpdateData(param);
		
	}
	
	/**
	 * 교육 게시판 Controller
	 * 
	 * **/
	
	//교육 게시판 목록 페이지 이동
	@RequestMapping("/admin/board/education/openEducationBoardList.do")
	public String openEducationBoardList() {
		
		return "bo/board/education/education_board_list";
	}
	
	//교육 게시판 목록 데이터
	@RequestMapping("/admin/board/education/educationBoardListData.do")
	@ResponseBody
	public ModelAndView educationBoardListData(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		mv.setViewName("jsonView");
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardService.educationBoardListData(param);
									
		mv.addObject("educationBoardData", result);
		
		return mv;
	}
	
	//교육 게시판 등록 페이지 이동
	@RequestMapping("/admin/board/education/openEducationBoardInsert.do")
	public String openEducationBoardInsert() {
		
		return "bo/board/education/education_board_insert";
	}
	
	//교육 게시판 등록 데이터
	@RequestMapping("/admin/board/education/educationBoardInsertData.do")
	@ResponseBody
	public void educationBoardInsertData(@RequestParam Map<String, Object> param) {

	    int emplySq = Integer.parseInt((String) param.get("emplySq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String brdWrtr = (String) param.get("brdWrtr");
		String brdTchr = (String) param.get("brdTchr");
		String brdEduDt = (String) param.get("brdEduDt");
		String useYn = (String) param.get("useYn");

		param.put("emplySq", emplySq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("brdWrtr", brdWrtr);
		param.put("brdTchr", brdTchr);
		param.put("brdEduDt", brdEduDt);
		param.put("useYn", useYn);
		
		System.out.println(param);
		
		BoBoardService.educationBoardInsertData(param);

	}
	
	//교육  게시판 상세 페이지 이동
	@RequestMapping("/admin/board/education/openEducationBoardDetail.do")
	public String openEducationBoardDetail() {
		
		return "bo/board/education/education_board_detail";
	}
	
	//교육 게시판 상세 데이터
	@RequestMapping("/admin/board/education/educationBoardDetailData.do")
	@ResponseBody
	public ModelAndView educationBoardDetailData(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		
		mv.setViewName("jsonView");
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardService.educationBoardDetailData(param);
		
		mv.addObject("educationBoardDetailData", result);
		
		return mv;
	}
	
	//교육 게시판 삭제
	@RequestMapping("/admin/board/education/educationBoardDeleteData.do")
	@ResponseBody
	public void educationBoardDeleteData(@RequestParam Map<String, Object> param) {
		
		int brdSq = Integer.parseInt((String) param.get("brdSq"));
	
		param.put("brdSq", brdSq);
		
		BoBoardService.educationBoardDeleteData(param);
		
	}
	
	//교육 게시판 수정 페이지 이동
	@RequestMapping("/admin/board/education/openEducationBoardUpdate.do")
	public String openEducationBoardUpdate() {
		
		return "bo/board/education/education_board_update";
	}
	
	//교육 게시판 수정
	@RequestMapping("/admin/board/education/educationBoardUpdateData.do")
	@ResponseBody
	public void educationBoardUpdateData(@RequestParam Map<String, Object> param) {

		
	    int brdSq = Integer.parseInt((String) param.get("brdSq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String brdTchr = (String) param.get("brdTchr");
		String brdEduDt = (String) param.get("brdEduDt");
		String useYn = (String) param.get("useYn");;
		String delYn = (String) param.get("delYn");;

		param.put("brdSq", brdSq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("brdTchr", brdTchr);
		param.put("brdEduDt", brdEduDt);
		param.put("useYn", useYn);
		param.put("delYn", delYn);

		
		System.out.println(param);

		
		BoBoardService.educationBoardUpdateData(param);
		
	}
	
	/**
	 * 자유 게시판 Controller
	 * 
	 * **/
	
	//자유 게시판 목록 페이지 이동
	@RequestMapping("/admin/board/freedom/openFreedomBoardList.do")
	public String openFreedomBoardList() {
		
		return "bo/board/freedom/freedom_board_list";
	}
	
	//자유 게시판 목록 데이터
	@RequestMapping("/admin/board/freedom/freedomBoardListData.do")
	@ResponseBody
	public ModelAndView freedomBoardListData(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		mv.setViewName("jsonView");
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardService.freedomBoardListData(param);
									
		mv.addObject("freedomBoardData", result);
		
		return mv;
	}
	
	//자유 게시판 등록 페이지 이동
	@RequestMapping("/admin/board/freedom/openFreedomBoardInsert.do")
	public String openFreedomBoardInsert() {
		
		return "bo/board/freedom/freedom_board_insert";
	}
	
	//자유 게시판 등록 데이터
	@RequestMapping("/admin/board/freedom/freedomBoardInsertData.do")
	@ResponseBody
	public void freedomBoardInsertData(@RequestParam Map<String, Object> param) {

	    int emplySq = Integer.parseInt((String) param.get("emplySq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String brdWrtr = (String) param.get("brdWrtr");
		String useYn = (String) param.get("useYn");

		param.put("emplySq", emplySq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("brdWrtr", brdWrtr);
		param.put("useYn", useYn);
		
		System.out.println(param);
		
		BoBoardService.freedomBoardInsertData(param);

	}
	
	//자유  게시판 상세 페이지 이동
	@RequestMapping("/admin/board/freedom/openFreedomBoardDetail.do")
	public String openFreedomBoardDetail() {
		
		return "bo/board/freedom/freedom_board_detail";
	}
	
	//자유 게시판 상세 데이터
	@RequestMapping("/admin/board/freedom/freedomBoardDetailData.do")
	@ResponseBody
	public ModelAndView freedomBoardDetailData(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		
		mv.setViewName("jsonView");
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardService.freedomBoardDetailData(param);
		
		mv.addObject("freedomBoardDetailData", result);
		
		return mv;
	}
	
	//자유  게시판 답글 등록 페이지 이동
	@RequestMapping("/admin/board/freedom/openFeedomBoardReplyInsert.do")
	public String openㄹreedomBoardReplyInsert() {
		
		return "bo/board/freedom/freedom_board_reply_insert";
	}
	
	//자유 게시판 답글 등록 데이터
	@RequestMapping("/admin/board/freedom/freedomBoardReplyInsertData.do")
	@ResponseBody
	public void freedomBoardReplyInsertData(@RequestParam Map<String, Object> param) {

	    int emplySq = Integer.parseInt((String) param.get("emplySq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String brdWrtr = (String) param.get("brdWrtr");
		int brdReRep = Integer.parseInt((String) param.get("brdReRep"));
		int brdReLev = Integer.parseInt((String) param.get("brdReLev"));
		int brdReOrd = Integer.parseInt((String) param.get("brdReOrd"));
		String useYn = (String) param.get("useYn");

		
		param.put("emplySq", emplySq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("brdWrtr", brdWrtr);
		param.put("brdReRep", brdReRep);
		param.put("brdReLev", brdReLev);
		param.put("brdReOrd", brdReOrd);
		param.put("useYn", useYn);
		
		System.out.println(param);
		
		BoBoardService.freedomBoardReplyInsertData(param);

	}

	//자유 게시판 삭제
	@RequestMapping("/admin/board/freedom/freedomBoardDeleteData.do")
	@ResponseBody
	public void freedomBoardDeleteData(@RequestParam Map<String, Object> param) {
		
		int brdSq = Integer.parseInt((String) param.get("brdSq"));
	
		param.put("brdSq", brdSq);
		
		BoBoardService.freedomBoardDeleteData(param);
		
	}
	
	//자유 게시판 수정 페이지 이동
	@RequestMapping("/admin/board/freedom/openFreedomBoardUpdate.do")
	public String openFreedomBoardUpdate() {
		
		return "bo/board/freedom/freedom_board_update";
	}
	
	//자유 게시판 수정
	@RequestMapping("/admin/board/freedom/freedomBoardUpdateData.do")
	@ResponseBody
	public void freedomBoardUpdateData(@RequestParam Map<String, Object> param) {

		
	    int brdSq = Integer.parseInt((String) param.get("brdSq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String useYn = (String) param.get("useYn");;
		String delYn = (String) param.get("delYn");;

		param.put("brdSq", brdSq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("useYn", useYn);
		param.put("delYn", delYn);

		
		System.out.println(param);

		
		BoBoardService.freedomBoardUpdateData(param);
		
	}
	
	/**
	 * 기술문의 게시판 Controller
	 * 
	 * **/
	
	//기술문의 게시판 목록 페이지 이동
	@RequestMapping("/admin/board/technology/openTechnologyBoardList.do")
	public String openTechnologyBoardList() {
		
		return "bo/board/technology/technology_board_list";
	}
	
	//기술문의 게시판 목록 데이터
	@RequestMapping("/admin/board/technology/technologyBoardListData.do")
	@ResponseBody
	public ModelAndView technologyBoardListData(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		mv.setViewName("jsonView");
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardService.technologyBoardListData(param);
									
		mv.addObject("technologyBoardData", result);
		
		return mv;
	}
	
	//기술문의 게시판 등록 페이지 이동
	@RequestMapping("/admin/board/technology/openTechnologyBoardInsert.do")
	public String openTechnologyBoardInsert() {
		
		return "bo/board/technology/technology_board_insert";
	}
	
	//기술문의 게시판 등록 데이터
	@RequestMapping("/admin/board/technology/technologyBoardInsertData.do")
	@ResponseBody
	public void technologyBoardInsertData(@RequestParam Map<String, Object> param) {

	    int emplySq = Integer.parseInt((String) param.get("emplySq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String brdWrtr = (String) param.get("brdWrtr");
		String useYn = (String) param.get("useYn");

		param.put("emplySq", emplySq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("brdWrtr", brdWrtr);
		param.put("useYn", useYn);
		
		System.out.println(param);
		
		BoBoardService.technologyBoardInsertData(param);

	}
	
	//기술문의  게시판 상세 페이지 이동
	@RequestMapping("/admin/board/technology/openTechnologyBoardDetail.do")
	public String openTechnologyBoardDetail() {
		
		return "bo/board/technology/technology_board_detail";
	}
	
	//기술문의 게시판 상세 데이터
	@RequestMapping("/admin/board/technology/technologyBoardDetailData.do")
	@ResponseBody
	public ModelAndView technologyBoardDetailData(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		
		mv.setViewName("jsonView");
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardService.technologyBoardDetailData(param);
		
		mv.addObject("technologyBoardDetailData", result);
		
		return mv;
	}
	
	//기술문의  게시판 답글 등록 페이지 이동
	@RequestMapping("/admin/board/technology/openTechnologyBoardReplyInsert.do")
	public String openTechnologyBoardReplyInsert() {
		
		return "bo/board/technology/technology_board_reply_insert";
	}
	
	//기술문의 게시판 답글 등록 데이터
	@RequestMapping("/admin/board/technology/technologyBoardReplyInsertData.do")
	@ResponseBody
	public void technologyBoardReplyInsertData(@RequestParam Map<String, Object> param) {

	    int emplySq = Integer.parseInt((String) param.get("emplySq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String brdWrtr = (String) param.get("brdWrtr");
		int brdReRep = Integer.parseInt((String) param.get("brdReRep"));
		int brdReLev = Integer.parseInt((String) param.get("brdReLev"));
		int brdReOrd = Integer.parseInt((String) param.get("brdReOrd"));
		String useYn = (String) param.get("useYn");

		
		param.put("emplySq", emplySq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("brdWrtr", brdWrtr);
		param.put("brdReRep", brdReRep);
		param.put("brdReLev", brdReLev);
		param.put("brdReOrd", brdReOrd);
		param.put("useYn", useYn);
		
		System.out.println(param);
		
		BoBoardService.technologyBoardReplyInsertData(param);

	}

	//기술문의 게시판 삭제
	@RequestMapping("/admin/board/technology/technologyBoardDeleteData.do")
	@ResponseBody
	public void technologyBoardDeleteData(@RequestParam Map<String, Object> param) {
		
		int brdSq = Integer.parseInt((String) param.get("brdSq"));
	
		param.put("brdSq", brdSq);
		
		BoBoardService.technologyBoardDeleteData(param);
		
	}
	
	//기술문의 게시판 수정 페이지 이동
	@RequestMapping("/admin/board/technology/openTechnologyBoardUpdate.do")
	public String openTechnologyBoardUpdate() {
		
		return "bo/board/technology/technology_board_update";
	}
	
	//기술문의 게시판 수정
	@RequestMapping("/admin/board/technology/technologyBoardUpdateData.do")
	@ResponseBody
	public void technologyBoardUpdateData(@RequestParam Map<String, Object> param) {

		
	    int brdSq = Integer.parseInt((String) param.get("brdSq"));
		String brdTtl = (String) param.get("brdTtl");
		String brdCntnt = (String) param.get("brdCntnt");
		String useYn = (String) param.get("useYn");;
		String delYn = (String) param.get("delYn");;

		param.put("brdSq", brdSq);
		param.put("brdTtl", brdTtl);
		param.put("brdCntnt", brdCntnt);
		param.put("useYn", useYn);
		param.put("delYn", delYn);

		System.out.println(param);

		BoBoardService.technologyBoardUpdateData(param);
		
	}
	
}
