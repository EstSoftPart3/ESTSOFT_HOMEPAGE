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

/** 연구소 - 연구일지, 연구소 관리. 권한은 /admin/** 인터셉터(관리자만 통과)와 서비스의 결재자 확인이 맡는다 */
@Controller
public class BoLabController {

	@Autowired
	private BoLabService lab;

	@RequestMapping("/admin/lab/openJournalList.do")
	public String openJournalList() {
		return "bo/lab/journal_list";
	}

	@RequestMapping("/admin/lab/openLabManage.do")
	public String openLabManage() {
		return "bo/lab/lab_manage";
	}

	@RequestMapping(value = "/admin/lab/optionsData.do", method = RequestMethod.POST)
	public ModelAndView optionsData() {
		return result(lab::options);
	}

	// ── 연구소 관리 ──

	@RequestMapping(value = "/admin/lab/teamListData.do", method = RequestMethod.POST)
	public ModelAndView teamListData() {
		return result(lab::teams);
	}

	@RequestMapping(value = "/admin/lab/teamDetailData.do", method = RequestMethod.POST)
	public ModelAndView teamDetailData(@RequestParam("TEAM_SQ") int teamSq, HttpSession session) {
		return result(() -> lab.teamDetail(teamSq, login(session)));
	}

	@RequestMapping(value = "/admin/lab/saveTeamData.do", method = RequestMethod.POST)
	public ModelAndView saveTeamData(@RequestParam Map<String, Object> param, HttpSession session) {
		return result(() -> lab.saveTeam(param, login(session)));
	}

	@RequestMapping(value = "/admin/lab/saveApprovalData.do", method = RequestMethod.POST)
	public ModelAndView saveApprovalData(@RequestParam("TEAM_SQ") int teamSq, @RequestParam(value = "STEP_NM", required = false) String[] names,
			@RequestParam(value = "EMPLY_ID", required = false) String[] ids) {
		return result(() -> { lab.saveApproval(teamSq, names, ids); return "OK"; });
	}

	@RequestMapping(value = "/admin/lab/saveResearcherData.do", method = RequestMethod.POST)
	public ModelAndView saveResearcherData(@RequestParam Map<String, Object> param, HttpSession session) {
		return result(() -> { lab.saveResearcher(param, login(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/lab/saveSignData.do", method = RequestMethod.POST)
	public ModelAndView saveSignData(@RequestParam("IMG") String image, HttpSession session) {
		return result(() -> { lab.saveSign(image, login(session)); return "OK"; });
	}

	// ── 연구일지 ──

	@RequestMapping(value = "/admin/lab/projectListData.do", method = RequestMethod.POST)
	public ModelAndView projectListData() {
		return result(lab::projects);
	}

	@RequestMapping(value = "/admin/lab/projectDetailData.do", method = RequestMethod.POST)
	public ModelAndView projectDetailData(@RequestParam("PRJ_SQ") int prjSq) {
		return result(() -> lab.projectDetail(prjSq));
	}

	@RequestMapping(value = "/admin/lab/saveProjectData.do", method = RequestMethod.POST)
	public ModelAndView saveProjectData(@RequestParam Map<String, Object> param, HttpSession session) {
		return result(() -> { lab.saveProject(param, login(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/lab/monthMembersData.do", method = RequestMethod.POST)
	public ModelAndView monthMembersData(@RequestParam("TEAM_SQ") int teamSq, @RequestParam("YM") String ym) {
		return result(() -> lab.monthMembers(teamSq, ym));
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
	public ModelAndView submitJournalData(@RequestParam("JRN_SQ") int sq, HttpSession session) {
		return result(() -> { lab.submitJournal(sq, login(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/lab/approveJournalData.do", method = RequestMethod.POST)
	public ModelAndView approveJournalData(@RequestParam("JRN_SQ") int sq, HttpSession session) {
		return result(() -> lab.approveJournal(sq, login(session)));
	}

	@RequestMapping(value = "/admin/lab/rejectJournalData.do", method = RequestMethod.POST)
	public ModelAndView rejectJournalData(@RequestParam("JRN_SQ") int sq, @RequestParam("NOTE") String note, HttpSession session) {
		return result(() -> { lab.rejectJournal(sq, note, login(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/lab/closeJournalData.do", method = RequestMethod.POST)
	public ModelAndView closeJournalData(@RequestParam("JRN_SQ") int sq, HttpSession session) {
		return result(() -> lab.closeJournal(sq, login(session)));
	}

	/** 마감 뒤 PDF 업로드·메일이 실패했을 때 다시 시도 */
	@RequestMapping(value = "/admin/lab/uploadJournalData.do", method = RequestMethod.POST)
	public ModelAndView uploadJournalData(@RequestParam("JRN_SQ") int sq, HttpSession session) {
		return result(() -> { String error = lab.publish(sq, login(session)); if (error != null) throw new IllegalArgumentException(error); return "OK"; });
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
