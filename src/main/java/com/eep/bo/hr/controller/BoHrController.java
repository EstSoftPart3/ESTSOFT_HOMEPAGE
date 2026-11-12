package com.eep.bo.hr.controller;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.hr.service.BoHrService;

@Controller
public class BoHrController {

	@Autowired
	private BoHrService BoHrService;

	/**
	 * 업무툴 - 면접·교육생 관리 Controller
	 * 권한은 /admin/** 인터셉터(관리자만 통과)가 맡는다. 쓰기는 POST 만 받는다
	 *
	 * **/

	@RequestMapping("/admin/hr/openInterviewList.do")
	public ModelAndView openInterviewList() {
		return new ModelAndView("bo/hr/interview_list");
	}

	@RequestMapping("/admin/hr/openTraineeList.do")
	public ModelAndView openTraineeList() {
		return new ModelAndView("bo/hr/trainee_list");
	}

	// 면접자 전체. 건수가 적어 연도·상태·검색은 화면에서 거른다
	@RequestMapping(value = "/admin/hr/interviewListData.do", method = RequestMethod.POST)
	public ModelAndView interviewListData() {
		ModelAndView mv = json("list", BoHrService.IntvList());
		mv.addObject("codes", BoHrService.CodeList());
		return mv;
	}

	@RequestMapping(value = "/admin/hr/saveInterviewData.do", method = RequestMethod.POST)
	public ModelAndView saveInterviewData(@RequestParam Map<String, Object> param, HttpSession session) {
		try {
			param.put("UPDT_EMPLY_ID", loginId(session));
			BoHrService.IntvSave(param);
			return json("result", "OK");
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/hr/deleteInterviewData.do", method = RequestMethod.POST)
	public ModelAndView deleteInterviewData(@RequestParam Map<String, Object> param) {
		BoHrService.IntvDelete(param);
		return json("result", "OK");
	}

	@RequestMapping(value = "/admin/hr/traineeFromInterviewData.do", method = RequestMethod.POST)
	public ModelAndView traineeFromInterviewData(@RequestParam Map<String, Object> param, HttpSession session) {
		param.put("UPDT_EMPLY_ID", loginId(session));
		if (!BoHrService.TraineeFromIntv(param)) {
			return json("error", "이미 교육생으로 등록된 면접자입니다.");
		}
		return json("result", "OK");
	}

	@RequestMapping(value = "/admin/hr/traineeListData.do", method = RequestMethod.POST)
	public ModelAndView traineeListData() {
		ModelAndView mv = json("list", BoHrService.TraineeList());
		mv.addObject("codes", BoHrService.CodeList());
		return mv;
	}

	@RequestMapping(value = "/admin/hr/saveTraineeData.do", method = RequestMethod.POST)
	public ModelAndView saveTraineeData(@RequestParam Map<String, Object> param, HttpSession session) {
		try {
			param.put("UPDT_EMPLY_ID", loginId(session));
			BoHrService.TraineeSave(param);
			return json("result", "OK");
		} catch (BoHrService.NeedReturn e) {
			return json("needReturn", e.rents);
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/hr/saveTraineeFieldData.do", method = RequestMethod.POST)
	public ModelAndView saveTraineeFieldData(@RequestParam Map<String, Object> param, HttpSession session) {
		try {
			param.put("UPDT_EMPLY_ID", loginId(session));
			BoHrService.TraineeFieldSave(param);
			return json("result", "OK");
		} catch (BoHrService.NeedReturn e) {
			return json("needReturn", e.rents);
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/hr/saveInterviewFieldData.do", method = RequestMethod.POST)
	public ModelAndView saveInterviewFieldData(@RequestParam Map<String, Object> param, HttpSession session) {
		try {
			param.put("UPDT_EMPLY_ID", loginId(session));
			BoHrService.IntvFieldSave(param);
			return json("result", "OK");
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/hr/saveTraineeSkillData.do", method = RequestMethod.POST)
	public ModelAndView saveTraineeSkillData(@RequestParam Map<String, Object> param, HttpSession session) {
		try {
			param.put("UPDT_EMPLY_ID", loginId(session));
			BoHrService.TraineeSkillSave(param);
			return json("result", "OK");
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/hr/deleteTraineeData.do", method = RequestMethod.POST)
	public ModelAndView deleteTraineeData(@RequestParam Map<String, Object> param, HttpSession session) {
		try {
			param.put("UPDT_EMPLY_ID", loginId(session));
			BoHrService.TraineeDelete(param);
			return json("result", "OK");
		} catch (BoHrService.NeedReturn e) {
			return json("needReturn", e.rents);
		}
	}

	@SuppressWarnings("unchecked")
	private static String loginId(HttpSession session) {
		Map<String, Object> info = (Map<String, Object>) session.getAttribute("loginInfo");
		List<Map<String, Object>> list = (List<Map<String, Object>>) info.get("loginInfo");
		return (String) list.get(0).get("emplyId");
	}

	private static ModelAndView json(String key, Object value) {
		ModelAndView mv = new ModelAndView("jsonView");
		mv.addObject(key, value);
		return mv;
	}
}
