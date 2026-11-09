package com.eep.bo.lab.controller;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.lab.service.BoLabService;

/** 연구소 - 연구원, 연구과제, 월간 연구일지. 권한은 /admin/** 인터셉터(관리자만 통과)와 서비스의 결재자 확인이 맡는다 */
@Controller
public class BoLabController {

	@Autowired
	private BoLabService lab;

	@RequestMapping("/admin/lab/openResearcherList.do")
	public String openResearcherList() {
		return "bo/lab/researcher_list";
	}

	@RequestMapping("/admin/lab/openProjectList.do")
	public String openProjectList() {
		return "bo/lab/project_list";
	}

	@RequestMapping("/admin/lab/openJournalList.do")
	public String openJournalList() {
		return "bo/lab/journal_list";
	}

	@RequestMapping(value = "/admin/lab/optionsData.do", method = RequestMethod.POST)
	public ModelAndView optionsData() {
		return result(lab::options);
	}

	@RequestMapping(value = "/admin/lab/researcherListData.do", method = RequestMethod.POST)
	public ModelAndView researcherListData() {
		return result(lab::researchers);
	}

	@RequestMapping(value = "/admin/lab/saveResearcherData.do", method = RequestMethod.POST)
	public ModelAndView saveResearcherData(@RequestParam Map<String, Object> param, HttpSession session) {
		return result(() -> { lab.saveResearcher(param, login(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/lab/projectListData.do", method = RequestMethod.POST)
	public ModelAndView projectListData() {
		return result(lab::projects);
	}

	@RequestMapping(value = "/admin/lab/saveProjectData.do", method = RequestMethod.POST)
	public ModelAndView saveProjectData(@RequestParam Map<String, Object> param, HttpSession session) {
		return result(() -> { lab.saveProject(param, login(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/lab/journalListData.do", method = RequestMethod.POST)
	public ModelAndView journalListData() {
		return result(lab::journals);
	}

	@RequestMapping(value = "/admin/lab/journalDetailData.do", method = RequestMethod.POST)
	public ModelAndView journalDetailData(@RequestParam("JRN_SQ") int sq, HttpSession session) {
		return result(() -> lab.journalDetail(sq, login(session)));
	}

	@RequestMapping(value = "/admin/lab/createJournalData.do", method = RequestMethod.POST)
	public ModelAndView createJournalData(@RequestParam Map<String, Object> param, HttpSession session) {
		return result(() -> lab.createJournal(param, login(session)));
	}

	@RequestMapping(value = "/admin/lab/saveJournalData.do", method = RequestMethod.POST)
	public ModelAndView saveJournalData(@RequestParam("JRN_SQ") int sq, @RequestParam("CONTENT") String content, HttpSession session) {
		return result(() -> { lab.saveJournal(sq, content, login(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/lab/submitJournalData.do", method = RequestMethod.POST)
	public ModelAndView submitJournalData(@RequestParam("JRN_SQ") int sq, @RequestParam("CONTENT") String content, HttpSession session) {
		return result(() -> { lab.submitJournal(sq, content, login(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/lab/approveJournalData.do", method = RequestMethod.POST)
	public ModelAndView approveJournalData(@RequestParam("JRN_SQ") int sq, HttpSession session) {
		return result(() -> lab.approveJournal(sq, login(session)));
	}

	@RequestMapping(value = "/admin/lab/rejectJournalData.do", method = RequestMethod.POST)
	public ModelAndView rejectJournalData(@RequestParam("JRN_SQ") int sq, @RequestParam("NOTE") String note, HttpSession session) {
		return result(() -> { lab.rejectJournal(sq, note, login(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/lab/uploadJournalData.do", method = RequestMethod.POST)
	public ModelAndView uploadJournalData(@RequestParam("JRN_SQ") int sq, HttpSession session) {
		return result(() -> { String error = lab.upload(sq, login(session)); if (error != null) throw new IllegalArgumentException(error); return "OK"; });
	}

	private interface Call {
		Object run();
	}

	private static ModelAndView result(Call call) {
		ModelAndView mv = new ModelAndView("jsonView");
		try {
			mv.addObject("result", call.run());
		} catch (IllegalArgumentException e) {
			mv.addObject("error", e.getMessage());
		}
		return mv;
	}

	@SuppressWarnings("unchecked")
	private static Map<String, Object> login(HttpSession session) {
		Map<String, Object> info = (Map<String, Object>) session.getAttribute("loginInfo");
		return ((List<Map<String, Object>>) info.get("loginInfo")).get(0);
	}
}
