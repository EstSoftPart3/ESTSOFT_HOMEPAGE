package com.eep.bo.batch.controller;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.batch.service.BoBatchService;
import com.eep.bo.my.BoMyController;
import com.eep.bo.my.GoogleLinkService;

@Controller
public class BoBatchController {

	@Autowired
	private BoBatchService BoBatchService;

	@Autowired
	private GoogleLinkService link;

	/**
	 * 배치 - 신입면접 Controller
	 *
	 * **/

	@RequestMapping("/admin/batch/openInterviewBatch.do")
	public ModelAndView openInterviewBatch() {
		return new ModelAndView("bo/batch/interview_batch");
	}

	@RequestMapping("/admin/batch/interviewBatchLogData.do")
	@ResponseBody
	public ModelAndView interviewBatchLogData() {
		ModelAndView mv = json("list", BoBatchService.interviewLogList());
		mv.addObject("pre", BoBatchService.preRunStatus());
		return mv;
	}

	// 한 실행의 일정별 처리 결과
	@RequestMapping("/admin/batch/interviewBatchDetailData.do")
	@ResponseBody
	public ModelAndView interviewBatchDetailData(@RequestParam("logSq") int logSq) {
		return json("list", BoBatchService.interviewLogDetail(logSq));
	}

	@RequestMapping(value = "/admin/batch/runInterviewBatchData.do", method = RequestMethod.POST)
	@ResponseBody
	public ModelAndView runInterviewBatchData(@RequestParam("icalSq") int icalSq) {
		try {
			ModelAndView mv = json("run", BoBatchService.runInterview(icalSq));
			mv.addObject("list", BoBatchService.interviewLogList());
			return mv;
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping("/admin/batch/icalListData.do")
	@ResponseBody
	public ModelAndView icalListData() {
		return json("list", BoBatchService.icalList());
	}

	@RequestMapping(value = "/admin/batch/saveIcalData.do", method = RequestMethod.POST)
	@ResponseBody
	public ModelAndView saveIcalData(@RequestParam Map<String, Object> param, @RequestParam(value = "icalSq", required = false) Integer icalSq) {
		try {
			BoBatchService.saveDriveConf((String) param.get("clientId"), (String) param.get("clientSecret"));
			BoBatchService.saveIcal(icalSq, (String) param.get("name"), (String) param.get("url"), (String) param.get("folder"));
			ModelAndView mv = json("list", BoBatchService.icalList());
			mv.addObject("drive", BoBatchService.driveStatus());
			return mv;
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/batch/deleteIcalData.do", method = RequestMethod.POST)
	@ResponseBody
	public ModelAndView deleteIcalData(@RequestParam("icalSq") int icalSq) {
		BoBatchService.deleteIcal(icalSq);
		return json("list", BoBatchService.icalList());
	}

	@RequestMapping(value = "/admin/batch/autoIcalData.do", method = RequestMethod.POST)
	@ResponseBody
	public ModelAndView autoIcalData(@RequestParam("icalSq") int icalSq, @RequestParam("auto") boolean auto) {
		BoBatchService.setIcalAuto(icalSq, auto);
		return json("list", BoBatchService.icalList());
	}

	@RequestMapping("/admin/batch/driveStatusData.do")
	@ResponseBody
	public ModelAndView driveStatusData(HttpServletRequest request) {
		ModelAndView mv = json("drive", BoBatchService.driveStatus());
		mv.addObject("redirectUri", redirectUri(request));
		return mv;
	}

	/** 이 iCal 의 이력서 드라이브를 누른 관리자의 내 연동으로 정한다. 연동이 없으면 내 연동에서 연결하고 돌아오게 한다 */
	@RequestMapping("/admin/batch/driveStart.do")
	public String driveStart(@RequestParam("icalSq") int icalSq) {
		String me = GoogleLinkService.currentUser();
		if (!link.linked(me, GoogleLinkService.DRIVE)) {
			return "redirect:/admin/my/openGoogleLink.do?svc=DRIVE&need=1&back=" + BACK;
		}
		BoBatchService.setDriveOwner(icalSq, me);
		return "redirect:/admin/batch/openInterviewBatch.do?drive=ok";
	}

	private static final String BACK = "/admin/batch/openInterviewBatch.do";

	/** 구글 콘솔에 등록해야 하는 리디렉션 URI(내 연동) */
	public static String redirectUri(HttpServletRequest request) {
		return BoMyController.redirectUri(request);
	}

	private static ModelAndView json(String key, Object value) {
		ModelAndView mv = new ModelAndView("jsonView");
		mv.addObject(key, value);
		return mv;
	}
}
