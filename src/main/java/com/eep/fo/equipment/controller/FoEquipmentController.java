package com.eep.fo.equipment.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.equipment.controller.BoEquipmentController;
import com.eep.bo.equipment.service.BoEquipmentService;

/** 내 장비. /eep/** 에는 로그인 인터셉터가 없어 여기서 세션과 본인 여부를 직접 검사한다 */
@Controller
public class FoEquipmentController {

	private static final String LOGIN_REQUIRED = "로그인 후 이용해 주세요.";
	private static final String NOT_LINKED = "인사카드와 연결되지 않은 계정입니다. 담당자에게 문의해 주세요.";

	@Autowired
	private BoEquipmentService service;

	@RequestMapping("/eep/equipment/myEquipment.do")
	public String myEquipment(HttpSession session) {
		return loginId(session) == null ? "redirect:/eep/login/loginPage.do" : "fo/equipment/my_equipment";
	}

	@RequestMapping(value = "/eep/equipment/myEquipmentData.do", method = RequestMethod.POST)
	public ModelAndView myEquipmentData(HttpSession session) {
		ModelAndView mv = new ModelAndView("jsonView");
		Map<String, Object> staff = staff(session);
		if (staff == null) {
			mv.addObject("error", loginId(session) == null ? LOGIN_REQUIRED : NOT_LINKED);
			return mv;
		}
		mv.addObject("list", service.myRents(staff.get("STAFF_SQ")));
		return mv;
	}

	/** 로그인 직후 응답·서명할 것이 있는지 본다. 인사카드와 연결되지 않았으면 0 */
	@RequestMapping(value = "/eep/equipment/pendingData.do", method = RequestMethod.POST)
	public ModelAndView pendingData(HttpSession session) {
		ModelAndView mv = new ModelAndView("jsonView");
		Map<String, Object> staff = staff(session);
		mv.addObject("count", staff == null ? 0 : service.pending(staff.get("STAFF_SQ")));
		return mv;
	}

	@RequestMapping(value = "/eep/equipment/respondData.do", method = RequestMethod.POST)
	public ModelAndView respondData(@RequestParam("EQP_SQ") int eqpSq, @RequestParam("RESULT_CD") String result, @RequestParam(value = "NOTE", defaultValue = "") String note, HttpSession session) {
		ModelAndView mv = new ModelAndView("jsonView");
		Map<String, Object> staff = staff(session);
		if (staff == null) {
			mv.addObject("error", loginId(session) == null ? LOGIN_REQUIRED : NOT_LINKED);
			return mv;
		}
		// 본인 행만 고치도록 사람은 세션에서만 정한다
		Map<String, Object> p = new HashMap<>();
		p.put("EQP_SQ", eqpSq);
		p.put("RESULT_CD", result);
		p.put("NOTE", note);
		p.put("STAFF_SQ", staff.get("STAFF_SQ"));
		p.put("UPDT_EMPLY_ID", loginId(session));
		try {
			service.respond(p);
			mv.addObject("result", "OK");
		} catch (IllegalArgumentException e) {
			mv.addObject("error", e.getMessage());
		}
		return mv;
	}

	@RequestMapping("/eep/equipment/certificate.do")
	public ModelAndView certificate(@RequestParam("group") String group, HttpSession session) {
		Map<String, Object> staff = staff(session);
		if (staff == null || !owns(group, staff)) {
			return new ModelAndView("redirect:/eep/equipment/myEquipment.do");
		}
		ModelAndView mv = new ModelAndView("bo/equipment/certificate");
		Map<String, Object> cert = service.certificate(group);
		mv.addObject("cert", cert);
		mv.addObject("canSign", cert.get("sign") == null);
		mv.addObject("canUpload", false);
		mv.addObject("signUrl", "/eep/equipment/signCertificateData.do");
		return mv;
	}

	@RequestMapping(value = "/eep/equipment/signCertificateData.do", method = RequestMethod.POST)
	public ModelAndView signCertificateData(@RequestParam("group") String group, @RequestParam("IMG") String image, HttpServletRequest request, HttpSession session) {
		ModelAndView mv = new ModelAndView("jsonView");
		Map<String, Object> staff = staff(session);
		if (staff == null || !owns(group, staff)) {
			mv.addObject("error", "본인에게 대여된 장비의 증서만 서명할 수 있습니다.");
			return mv;
		}
		try {
			service.sign(group, image, loginId(session), "SELF", BoEquipmentController.ip(request));
			mv.addObject("result", "OK");
		} catch (IllegalArgumentException e) {
			mv.addObject("error", e.getMessage());
		} catch (DataIntegrityViolationException e) {
			mv.addObject("error", "이미 서명된 증서입니다.");
		}
		return mv;
	}

	private boolean owns(String group, Map<String, Object> staff) {
		try {
			return service.ownsGroup(group, staff.get("STAFF_SQ"));
		} catch (IllegalArgumentException e) {
			return false;
		}
	}

	private Map<String, Object> staff(HttpSession session) {
		return service.staffByLogin(loginId(session));
	}

	@SuppressWarnings("unchecked")
	private static String loginId(HttpSession session) {
		Object info = session.getAttribute("loginInfo");
		if (!(info instanceof Map)) return null;
		List<Map<String, Object>> list = (List<Map<String, Object>>) ((Map<String, Object>) info).get("loginInfo");
		return list == null || list.isEmpty() ? null : (String) list.get(0).get("emplyId");
	}
}
