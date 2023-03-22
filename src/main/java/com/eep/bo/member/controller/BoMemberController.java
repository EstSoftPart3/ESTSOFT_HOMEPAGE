package com.eep.bo.member.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.member.service.BoMemberService;

import common.base.service.CommonService;

@Controller
public class BoMemberController {
	
	@Autowired
	private BoMemberService BoMemberService;
	
	//직원 목록 페이지 이동
	@RequestMapping("/admin/member/memberList.do")
	public String openMemberList() {
		return "bo/member/member_list";
	}
	
	//직원 목록 검색
	@RequestMapping("/admin/member/memberSearch.do")
	@ResponseBody
	public ModelAndView memberSearch(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		mv.setViewName("jsonView");
		
		try {
			
			Map<String, Object> result = new HashMap<>();
			
			result = BoMemberService.memberList(param);
										
			mv.addObject("memberData", result);
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return mv;
	}
	
	//직원 상세 보기
	@RequestMapping("/admin/member/memberContent.do")
	public String openMemberContent() {
		return "bo/member/member_detail";
	}
	
	@RequestMapping("/admin/member/memberContentData.do")
	@ResponseBody
	public ModelAndView memberContentData(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		mv.setViewName("jsonView");
		
		try {
			Map<String, Object> result = new HashMap<>();
			
			result = BoMemberService.memberContent(param);
			
			mv.addObject("memberContentData", result);
		}catch (Exception e) {
			e.printStackTrace();
		}
		
		return mv;
	}
	
	//직원 등록 페이지 이동
	@RequestMapping("/admin/member/memberInsert.do")
	public String openMemberInput() {
		return "bo/member/member_insert";
	}

	//직원 등록
	@RequestMapping("/admin/member/memberInsertData.do")
	@ResponseBody
	public void memberInsertData(@RequestParam Map<String, Object> param) {
		try {
			BoMemberService.memberInsert(param);
		}catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	//직원 목록 페이지 이동
	@RequestMapping("/admin/member/memberUpdate.do")
	public String openMemberUpdate() {
		return "bo/member/member_update";
	}
	
	//직원 수정
	@RequestMapping("/admin/member/memberUpdateData.do")
	@ResponseBody
	public void memberUpdateData(@RequestParam Map<String, Object> param) {
		
		int saveState = -1;
		
		saveState = BoMemberService.memberUpdate(param);
		
	}
	
	//직원 비밀번호 초기화
	@RequestMapping("/admin/member/memberPasswdClear.do")
	@ResponseBody
	public ModelAndView memberPasswdClear(@RequestParam Map<String, Object> param) {
		
		ModelAndView mv = new ModelAndView();
		mv.setViewName("jsonView");
		
		param.put("mbrPasswrd", "a123456!");
				
		mv.addObject("result", BoMemberService.memberPasswdClear(param));
		
		return mv;
	}
	
	//탈퇴 직원 목록 페이지 이동
	@RequestMapping("/admin/member/outMemberList.do")
	public String outMemberList() {
		return "bo/member/out_member_list";
	}
	
	//탈퇴 직원 상세 페이지 이동
	@RequestMapping("/admin/member/outMemberContent.do")
	public String outMemberContent() {
		return "bo/member/out_member_detail";
	}

	//직원 탈퇴, 복구 하기
	@RequestMapping("/admin/member/outMember.do")
	@ResponseBody
	public void outMember(@RequestParam Map<String, Object> param) {
		try {
			BoMemberService.outMember(param);
		}catch (Exception e) {
			e.printStackTrace();
		}
	}
	
}
