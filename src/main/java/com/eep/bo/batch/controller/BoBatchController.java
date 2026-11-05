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
		ModelAndView mv = new ModelAndView("bo/batch/interview_batch");
		mv.addObject("urlReady", BoBatchService.icalUrlReady());
		return mv;
	}

	@RequestMapping("/admin/batch/interviewBatchLogData.do")
	@ResponseBody
	public ModelAndView interviewBatchLogData() {
		return json("list", BoBatchService.interviewLogList());
	}

	@RequestMapping(value = "/admin/batch/runInterviewBatchData.do", method = RequestMethod.POST)
	@ResponseBody
	public ModelAndView runInterviewBatchData() {
		ModelAndView mv = json("run", BoBatchService.runInterview("MANUAL"));
		mv.addObject("list", BoBatchService.interviewLogList());
		return mv;
	}

	@RequestMapping(value = "/admin/batch/saveInterviewBatchUrlData.do", method = RequestMethod.POST)
	@ResponseBody
	public ModelAndView saveInterviewBatchUrlData(@RequestParam Map<String, Object> param) {
		try {
			BoBatchService.saveIcalUrl((String) param.get("url"));
			return json("result", "OK");
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	private static ModelAndView json(String key, Object value) {
		ModelAndView mv = new ModelAndView("jsonView");
		mv.addObject(key, value);
		return mv;
	}
}
