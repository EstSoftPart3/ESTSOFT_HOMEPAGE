package com.eep.bo.board.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
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
	@RequestMapping({"/admin/board/openBoardManage.do", "/admin/board/notice/openNoticeBoardList.do"})
	public String openNoticeBoardList(Model model) {

		return boardTabs(model, "notice");
	}

	// 게시판 목록 4개는 탭 화면 하나로 보여 주고, 들어온 주소의 게시판 탭을 연다
	private String boardTabs(Model model, String tab) {
		model.addAttribute("tab", tab);
		return "bo/board/board_list_tabs";
	}

	// 게시판 4개의 상세(view)와 작성·수정·답글(write·edit·reply)은 화면 하나씩을 같이 쓴다
	private String boardPage(Model model, String board, String mode) {
		model.addAttribute("board", board);
		model.addAttribute("mode", mode);
		return "view".equals(mode) ? "bo/board/board_view" : "bo/board/board_form";
	}

	// 목록의 스위치·일괄 처리: field=blind|del, value=Y|N, brdSq=쉼표로 이은 글 번호
	@RequestMapping("/admin/board/boardFlagData.do")
	public ModelAndView boardFlagData(@RequestParam String field, @RequestParam String value, @RequestParam String brdSq) {
		ModelAndView mv = new ModelAndView("jsonView");
		List<Integer> ids = new java.util.ArrayList<>();
		try {
			for (String s : brdSq.split(",")) if (!s.trim().isEmpty()) ids.add(Integer.valueOf(s.trim()));
		} catch (NumberFormatException e) {
			ids.clear();
		}
		if (!("blind".equals(field) || "del".equals(field)) || !("Y".equals(value) || "N".equals(value)) || ids.isEmpty() || ids.size() > 500) {
			mv.addObject("error", "잘못된 요청입니다.");
			return mv;
		}
		Map<String, Object> param = new HashMap<>();
		param.put("field", field);
		param.put("value", value);
		param.put("ids", ids);
		mv.addObject("count", BoBoardService.boardFlagData(param));
		return mv;
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
	public String openNoticeBoardInsert(Model model) {
		
		return boardPage(model, "notice", "write");
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
	public String openNoticeBoardDetail(Model model) {
		
		return boardPage(model, "notice", "view");
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
	public String openNoticeBoardUpdate(Model model) {
		
		return boardPage(model, "notice", "edit");
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
	public String openEducationBoardList(Model model) {

		return boardTabs(model, "education");
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
	public String openEducationBoardInsert(Model model) {
		
		return boardPage(model, "education", "write");
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
	public String openEducationBoardDetail(Model model) {
		
		return boardPage(model, "education", "view");
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
	public String openEducationBoardUpdate(Model model) {
		
		return boardPage(model, "education", "edit");
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
	public String openFreedomBoardList(Model model) {

		return boardTabs(model, "freedom");
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
	public String openFreedomBoardInsert(Model model) {
		
		return boardPage(model, "freedom", "write");
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
	public String openFreedomBoardDetail(Model model) {
		
		return boardPage(model, "freedom", "view");
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
	public String openㄹreedomBoardReplyInsert(Model model) {
		
		return boardPage(model, "freedom", "reply");
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
	public String openFreedomBoardUpdate(Model model) {
		
		return boardPage(model, "freedom", "edit");
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
	public String openTechnologyBoardList(Model model) {

		return boardTabs(model, "technology");
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
	public String openTechnologyBoardInsert(Model model) {
		
		return boardPage(model, "technology", "write");
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
	public String openTechnologyBoardDetail(Model model) {
		
		return boardPage(model, "technology", "view");
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
	public String openTechnologyBoardReplyInsert(Model model) {
		
		return boardPage(model, "technology", "reply");
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
	public String openTechnologyBoardUpdate(Model model) {
		
		return boardPage(model, "technology", "edit");
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
