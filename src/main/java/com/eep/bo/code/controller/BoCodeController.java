package com.eep.bo.code.controller;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.code.service.BoCodeService;

@Controller
public class BoCodeController {
	
	@Autowired
	private BoCodeService BoCodeService;
	
	/**
	 * 코드관리 게시판 Controller
	 * 
	 * **/
	
	// 코드관리 게시판 목록 페이지 이동
	@RequestMapping("/admin/code/openCodeBoardList.do")
	public String openArtistMemberInput() {
		return "bo/code/codeList";
	}
	
	//공통코드 리스트
	@RequestMapping("/admin/code/codeBoardListData.do")
	@ResponseBody
	public ModelAndView comCodeListData(@RequestParam Map<String, Object> param) {		
		ModelAndView mv = new ModelAndView();
		mv.setViewName("jsonView");
		Map<String, Object> result = new HashMap<>();
			
		result = BoCodeService.CodeList(param);
			
		mv.addObject("comCodeList", result);
			
		return mv;
	}
	
	//공통코드 추가
	@RequestMapping("/admin/code/codeBoardIsertData.do")
	@ResponseBody
	public int comCodeInputData(@RequestParam Map<String, Object> param) {
		int resultState = -1;
		resultState = BoCodeService.CodeInsert(param);
		return resultState;
	}
	
	
	//공통코드 수정
	@RequestMapping("/admin/code/codeBoardUpdateData.do")
	@ResponseBody
	public int comCodeUpdateData(@RequestParam Map<String, Object> param) {
		int resultState = -1;
		resultState = BoCodeService.CodeUpdate(param);
		return resultState;
	}
	
	//공통코드 삭제
	@RequestMapping("/admin/code/codeBoardDeleteData.do")
	@ResponseBody
	public int comCodeDeleteData(@RequestParam Map<String, Object> param) {
		int resultState = -1;
		resultState = BoCodeService.CodeDelete(param);
		return resultState;
	}
	
	//공통 서브코드 리스트
	@RequestMapping("/admin/code/codeSubBoardListData.do")
	@ResponseBody
	public ModelAndView comSubCodeListData(@RequestParam Map<String, Object> param) {
		ModelAndView mv = new ModelAndView();
		mv.setViewName("jsonView");
		Map<String, Object> result = new HashMap<>();
		
		result = BoCodeService.SubCodeList(param);
		
		mv.addObject("comCodeList", result);
		
		return mv;
	}
	
	
	//공통 서브코드 추가
	@RequestMapping("/admin/code/codeSubBoardIsertData.do")
	@ResponseBody
	public int comSubCodeInsert(@RequestParam Map<String, Object> param) {
		int resultState = -1;
		resultState = BoCodeService.SubCodeInsert(param);
		return resultState;
	}
	
	
	//공통 서브코드 수정
	@RequestMapping("/admin/code/codeSubBoardUpdateData.do")
	@ResponseBody
	public int comSubCodeUpdateData(@RequestParam Map<String, Object> param) {
		int resultState = -1;
		resultState = BoCodeService.SubCodeUpdate(param);
		return resultState;
	}
	
	
	//공통 서브코드 삭제
	@RequestMapping("/admin/code/codeSubBoardDeleteData.do")
	@ResponseBody
	public int comSubCodeDeleteData(@RequestParam Map<String, Object> param) {
		int resultState = -1;
		resultState = BoCodeService.SubCodeDelete(param);
		return resultState;
	}
	
}
