package com.eep.bo.member.controller;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.member.service.BoMemberService;
import com.eep.bo.member.service.BoMemberService.Actor;
import com.eep.bo.system.service.BoSystemService;

/** 계정관리. 접근 제어는 /admin/** 인터셉터가 맡고 쓰기는 POST 만 받는다 */
@Controller
public class BoMemberController {

	@Autowired
	private BoMemberService service;
	@Autowired
	private BoSystemService system;

	@RequestMapping("/admin/member/memberList.do")
	public ModelAndView memberList() {
		return new ModelAndView("bo/member/member_list");
	}

	@RequestMapping(value = "/admin/member/memberListData.do", method = RequestMethod.POST)
	public ModelAndView memberListData() {
		return call(service::list);
	}

	@RequestMapping(value = "/admin/member/memberCardData.do", method = RequestMethod.POST)
	public ModelAndView memberCardData(@RequestParam("EMPLY_SQ") int sq, HttpSession session) {
		Actor actor = actor(session);
		return call(() -> service.card(sq, actor));
	}

	@RequestMapping(value = "/admin/member/issueStaffData.do", method = RequestMethod.POST)
	public ModelAndView issueStaffData(@RequestParam("STAFF_SQ") List<Integer> staffSqs, @RequestParam("EMPLY_ID") List<String> ids, @RequestParam("TYPE_CD") String type,
			@RequestParam(value = "ROLE_SQ", required = false) Integer roleSq, HttpSession session) {
		Actor actor = actor(session);
		return call(() -> service.issueFromStaff(staffSqs, ids, type, roleSq, actor));
	}

	@RequestMapping(value = "/admin/member/issueManualData.do", method = RequestMethod.POST)
	public ModelAndView issueManualData(@RequestParam("EMPLY_ID") String id, @RequestParam("EMPLY_NM") String name, @RequestParam(value = "EMPLY_EMAIL", required = false) String email,
			@RequestParam(value = "ROLE_SQ", required = false) Integer roleSq, HttpSession session) {
		Actor actor = actor(session);
		return call(() -> service.issueManualAdmin(id, name, email, roleSq, actor));
	}

	@RequestMapping(value = "/admin/member/saveMemberData.do", method = RequestMethod.POST)
	public ModelAndView saveMemberData(@RequestParam Map<String, Object> param, HttpSession session) {
		Actor actor = actor(session);
		return call(() -> { service.save(param, actor); return "OK"; });
	}

	@RequestMapping(value = "/admin/member/resetPasswordData.do", method = RequestMethod.POST)
	public ModelAndView resetPasswordData(@RequestParam("EMPLY_SQ") int sq, HttpSession session) {
		Actor actor = actor(session);
		return call(() -> service.resetPassword(sq, actor));
	}

	@RequestMapping(value = "/admin/member/setStatusData.do", method = RequestMethod.POST)
	public ModelAndView setStatusData(@RequestParam("EMPLY_SQ") int sq, @RequestParam("ACTION") String action, HttpSession session) {
		Actor actor = actor(session);
		return call(() -> { service.setStatus(sq, action, actor); return "OK"; });
	}

	@RequestMapping(value = "/admin/member/setTypeData.do", method = RequestMethod.POST)
	public ModelAndView setTypeData(@RequestParam("EMPLY_SQ") int sq, @RequestParam("TYPE_CD") String type, @RequestParam(value = "ROLE_SQ", required = false) Integer roleSq, HttpSession session) {
		Actor actor = actor(session);
		return call(() -> { service.setType(sq, type, roleSq, actor); return "OK"; });
	}

	@RequestMapping(value = "/admin/member/searchStaffData.do", method = RequestMethod.POST)
	public ModelAndView searchStaffData(@RequestParam("KEYWORD") String keyword) {
		return call(() -> service.searchStaff(keyword));
	}

	private interface Call {
		Object run() throws Exception;
	}

	private static ModelAndView call(Call call) {
		ModelAndView mv = new ModelAndView("jsonView");
		try {
			mv.addObject("result", call.run());
		} catch (IllegalArgumentException e) {
			mv.addObject("error", e.getMessage());
		} catch (DataIntegrityViolationException e) {
			mv.addObject("error", "이미 사용 중인 아이디이거나 입력이 너무 깁니다.");
		} catch (Exception e) {
			System.out.println("MEMBER_ERROR " + e.getClass().getSimpleName());
			mv.addObject("error", "처리하지 못했습니다. (" + e.getClass().getSimpleName() + ")");
		}
		return mv;
	}

	@SuppressWarnings("unchecked")
	private Actor actor(HttpSession session) {
		Map<String, Object> info = (Map<String, Object>) session.getAttribute("loginInfo");
		String id = (String) ((List<Map<String, Object>>) info.get("loginInfo")).get(0).get("emplyId");
		return new Actor(id, system.access(id).superUser);
	}
}
