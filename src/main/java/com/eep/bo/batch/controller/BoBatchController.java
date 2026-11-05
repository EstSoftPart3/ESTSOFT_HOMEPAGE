package com.eep.bo.batch.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.batch.service.BoBatchService;

@Controller
public class BoBatchController {

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
	public ModelAndView saveIcalData(@RequestParam Map<String, Object> param) {
		try {
			BoBatchService.saveIcal((String) param.get("name"), (String) param.get("url"));
			return json("list", BoBatchService.icalList());
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

	private static ModelAndView json(String key, Object value) {
		ModelAndView mv = new ModelAndView("jsonView");
		mv.addObject(key, value);
		return mv;
	}
}
