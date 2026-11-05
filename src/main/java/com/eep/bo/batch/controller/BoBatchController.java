package com.eep.bo.batch.controller;

import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestClientException;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.batch.service.BoBatchService;

@Controller
public class BoBatchController {

	private static final Logger log = LoggerFactory.getLogger(BoBatchController.class);
	private static final String SS_DRIVE_STATE = "driveState";
	private static final String SS_DRIVE_ICAL = "driveIcalSq";

	@Autowired
	private BoBatchService BoBatchService;

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
		return json("list", BoBatchService.interviewLogList());
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

	// 구글 승인 화면으로 보낸다. 끝나면 driveCallback 으로 돌아온다
	@RequestMapping("/admin/batch/driveStart.do")
	public String driveStart(@RequestParam("icalSq") int icalSq, HttpServletRequest request, HttpSession session) {
		String state = UUID.randomUUID().toString();
		String url = BoBatchService.driveAuthUrl(redirectUri(request), state);
		if (url == null) {
			return "redirect:/admin/batch/openInterviewBatch.do?drive=noclient";
		}
		session.setAttribute(SS_DRIVE_STATE, state);
		session.setAttribute(SS_DRIVE_ICAL, icalSq);
		return "redirect:" + url;
	}

	@RequestMapping("/admin/batch/driveCallback.do")
	public String driveCallback(@RequestParam Map<String, Object> param, HttpServletRequest request, HttpSession session) {
		Object state = session.getAttribute(SS_DRIVE_STATE);
		Object icalSq = session.getAttribute(SS_DRIVE_ICAL);
		session.removeAttribute(SS_DRIVE_STATE);
		session.removeAttribute(SS_DRIVE_ICAL);
		// state 가 다르면 이 세션이 시작한 승인이 아니다(CSRF)
		if (state == null || icalSq == null || !state.equals(param.get("state")) || param.get("code") == null) {
			return "redirect:/admin/batch/openInterviewBatch.do?drive=fail";
		}
		try {
			boolean ok = BoBatchService.connectDrive((Integer) icalSq, redirectUri(request), (String) param.get("code"));
			return "redirect:/admin/batch/openInterviewBatch.do?drive=" + (ok ? "ok" : "fail");
		} catch (RestClientException e) {
			log.error("드라이브 연결 실패: {}", e.getClass().getSimpleName());
			return "redirect:/admin/batch/openInterviewBatch.do?drive=fail";
		}
	}

	/** 구글 콘솔에 등록한 리디렉션 URI 와 글자까지 같아야 한다. 프록시가 https 를 전달하지 않아 운영 도메인은 https 로 고정한다 */
	private static String redirectUri(HttpServletRequest request) {
		String host = request.getHeader("Host");
		String proto = host != null && host.startsWith("localhost") ? request.getScheme() : "https";
		return proto + "://" + host + "/admin/batch/driveCallback.do";
	}

	private static ModelAndView json(String key, Object value) {
		ModelAndView mv = new ModelAndView("jsonView");
		mv.addObject(key, value);
		return mv;
	}
}
