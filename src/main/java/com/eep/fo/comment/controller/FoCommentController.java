package com.eep.fo.comment.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.eep.fo.comment.service.FoCommentService;

@Controller
public class FoCommentController {
	
	@Autowired
	private FoCommentService FoCommentService;
	
	//댓글 리스트 가져오기
	@RequestMapping("/eep/comment/commentListData.do")
	@ResponseBody
	public ModelAndView commentListData(@RequestParam Map<String, Object> param) {
		ModelAndView mv = new ModelAndView();
		
		mv.setViewName("jsonView");
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoCommentService.commentList(param);
		
		mv.addObject("commentData", result);
		return mv;
	}
	
	//댓글 등록
	@RequestMapping("/eep/comment/commentInsert.do")
	@ResponseBody
	public int commentInsert(@RequestParam Map<String, Object> param) {
		System.out.println("댓글 등록 되었습니다.");
		
		int brdSq = Integer.parseInt((String) param.get("brdSq"));
		int emplySq = Integer.parseInt((String) param.get("emplySq"));
		String cmmntCntnt = (String) param.get("cmmntCntnt");

		param.put("cmmntSq", null); //댓글 번호를 NULL로 Insert시 자동으로 SEQ 번호 부여
		param.put("brdSq", brdSq);
		param.put("emplySq", emplySq);
		param.put("cmmntCntnt", cmmntCntnt);
		
		int result = FoCommentService.commentInsert(param);
		
		return result;
	}
	
	//댓글 수정
	@RequestMapping("/eep/comment/commentUpdate.do")
	@ResponseBody
	public int commentUpdate(@RequestParam Map<String, Object> param) {
		System.out.println("댓글 수정 되었습니다.");
		
		int cmmntSq = Integer.parseInt((String) param.get("cmmntSq"));
		int brdSq = Integer.parseInt((String) param.get("brdSq"));
		int emplySq = Integer.parseInt((String) param.get("emplySq"));
		String cmmntCntnt = (String) param.get("cmmntCntnt");

		param.put("cmmntSq", cmmntSq);
		param.put("brdSq", brdSq);
		param.put("emplySq", emplySq);
		param.put("cmmntCntnt", cmmntCntnt);
		
		int result = FoCommentService.commentUpdate(param);
		
		return result;
	}
	
	//댓글 삭제
	@RequestMapping("/eep/comment/commentDelete.do")
	@ResponseBody
	public int commentDelete(@RequestParam Map<String, Object> param) {
		System.out.println("댓글 삭제 되었습니다.");
		
		int cmmntSq = Integer.parseInt((String) param.get("cmmntSq"));
		int brdSq = Integer.parseInt((String) param.get("brdSq"));
		int emplySq = Integer.parseInt((String) param.get("emplySq"));
		String cmmntCntnt = (String) param.get("cmmntCntnt");

		param.put("cmmntSq", cmmntSq);
		param.put("brdSq", brdSq);
		param.put("emplySq", emplySq);
		param.put("cmmntCntnt", cmmntCntnt);
		param.put("uesYn", "N");
		param.put("delYn", "Y");
		
		//삭제 시 업데이트 날짜 갱신
		int result = FoCommentService.commentDelete(param);
		
		return result;
	}

}
