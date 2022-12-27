package com.eep.bo.board.controller;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.board.service.BoBoardService;

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
	
    *//** 게시판 - 목록 조회 *//*
    @RequestMapping(value = "/admin/getBoardList.do")
    public ModelAndView getBoardList(BoBoardVo BoBoardVo) throws Exception {
 
    	ModelAndView mv = new ModelAndView("jsonView");
    	
    	List<BoBoardVo> list = boBoardService.getBoardList(BoBoardVo);
 
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
	
	
	
	//공지사항 목록 페이지 이동
	@RequestMapping("/admin/board/notice/openNoticeBoardList.do")
	public String openNoticeBoardList() {
		
		return "bo/board/notice/notice_board_list";
	}
	
	//공지사항 목록 데이터
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
	
	//공지사항 등록 페이지 이동
	@RequestMapping("/admin/board/notice/openNoticeBoardInsert.do")
	public String openNoticeBoardInsert() {
		
		return "bo/board/notice/notice_board_insert";
	}
	
	//공지사항 등록 데이터
	@RequestMapping("/admin/board/notice/noticeBoardInsertData.do")
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
		
		BoBoardService.noticeBoardInsertData(param);

	}
	
	//공지사항 등록 페이지 이동
	@RequestMapping("/admin/board/notice/openNoticeBoardDetail.do")
	public String openNoticeBoardDetail() {
		
		return "bo/board/notice/notice_board_detail";
	}
	
	//공지사항 상세 데이터
	
	

/*	@RequestMapping(value = "/admin/boardDetailPage.do")
	public ModelAndView boardDetailPage(HttpServletRequest request, HttpServletResponse response) {
		
		ModelAndView mv = new ModelAndView("/bo/board/boardDetail");
		return mv;
	}*/
    
    
/*    //샘플 게시판 상세 조회 + 조회 수 카운트(페이지 요청과 동시에 데이터 출력하는 방식)
	@RequestMapping(value="/admin/getBoardDeteil.do")
    public ModelAndView sampleBoardDetail(BoBoardVo BoBoardVo) throws Exception {
        
        ModelAndView mv = new ModelAndView("jsonView");
        BoBoardVo detail = boBoardService.getBoardDetail(BoBoardVo);
        mv.addObject("detail",detail);

        
        return mv;
    }*/
    
}
