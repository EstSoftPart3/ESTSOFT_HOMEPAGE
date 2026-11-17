package com.eep.bo.hr.controller;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import com.common.upload.Upload;
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
			ModelAndView mv = json("result", "OK");
			mv.addObject("INTV_SQ", param.get("INTV_SQ")); // 새로 넣었으면 만든 번호(캘린더 이력서 올리기에 쓴다)
			return mv;
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	// 캘린더에 끌어 놓은 이력서 PDF 를 읽기만 한다. 주소는 면접관리 권한 패턴(/admin/hr/*nterview*)에 맞춘다
	@RequestMapping(value = "/admin/hr/readInterviewResumeData.do", method = RequestMethod.POST)
	public ModelAndView readInterviewResumeData(@RequestParam("file") MultipartFile file) {
		try {
			Upload.check(file, "pdf");
			return json("fields", BoHrService.ReadResume(file.getBytes(), file.getOriginalFilename()));
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		} catch (java.io.IOException e) {
			return json("error", "파일을 받지 못했습니다. 다시 끌어 놓아 주세요.");
		}
	}

	// 캘린더에 끌어 놓은 이력서를 저장한 면접자의 드라이브 날짜·이름 폴더에 올린다
	@RequestMapping(value = "/admin/hr/uploadInterviewResumeData.do", method = RequestMethod.POST)
	public ModelAndView uploadInterviewResumeData(@RequestParam("INTV_SQ") int intvSq, @RequestParam("file") MultipartFile file) {
		try {
			Upload u = Upload.of(file, "pdf");
			BoHrService.IntvResumeSave(intvSq, u.name, u.data);
			return Upload.noted(json("result", "OK"), u);
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		} catch (Exception e) {
			return json("error", "드라이브에 올리지 못했습니다. 잠시 뒤 상세 창에서 다시 시도하거나 시스템 관리자에게 알려 주세요.");
		}
	}

	// 상세 창 「이력서 보기」: 회사 드라이브에서 받아 새 탭에 PDF 로 보여 준다(드라이브 권한이 없는 관리자도 볼 수 있게)
	@RequestMapping(value = "/admin/hr/interviewResumeFile.do", method = RequestMethod.GET)
	public void interviewResumeFile(@RequestParam("INTV_SQ") int intvSq, javax.servlet.http.HttpServletResponse response) throws java.io.IOException {
		byte[] pdf;
		String fail = null;
		try {
			pdf = BoHrService.IntvResumeFile(intvSq);
			if (pdf == null) fail = "이력서를 찾지 못했습니다. 드라이브의 면접일자·이름 폴더에 PDF 가 있는지 확인해 주세요.";
		} catch (IllegalArgumentException e) {
			pdf = null;
			fail = e.getMessage();
		} catch (Exception e) {
			pdf = null;
			fail = "드라이브에서 이력서를 받지 못했습니다. 잠시 뒤 다시 시도해 주세요.";
		}
		response.setHeader("X-Content-Type-Options", "nosniff");
		if (pdf == null) {
			response.setContentType("text/plain; charset=UTF-8");
			response.setStatus(HttpServletResponse.SC_NOT_FOUND);
			response.getWriter().write(fail);
			return;
		}
		response.setContentType("application/pdf");
		response.setHeader("Content-Disposition", "inline; filename=\"resume.pdf\"");
		response.setContentLength(pdf.length);
		response.getOutputStream().write(pdf);
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
			return json("error", "이미 교육생으로 등록됐거나 경력직인 면접자입니다. 경력직은 교육생으로 등록하지 않습니다.");
		}
		return withNote(json("result", "OK"), param);
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
			return withNote(json("result", "OK"), param);
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
			return withNote(json("result", "OK"), param);
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

	/** 드라이브 폴더 처리 안내(서비스가 param 의 DRIVE_NOTE 에 남긴 것). 화면은 hrPost 가 알림으로 보인다 */
	private static ModelAndView withNote(ModelAndView mv, Map<String, Object> param) {
		if (param.get("DRIVE_NOTE") != null) mv.addObject("driveNote", param.get("DRIVE_NOTE"));
		return mv;
	}
}
