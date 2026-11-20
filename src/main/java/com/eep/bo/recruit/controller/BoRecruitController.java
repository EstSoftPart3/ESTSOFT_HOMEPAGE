package com.eep.bo.recruit.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
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
import com.eep.bo.deploy.service.SecretFilter;
import com.eep.bo.recruit.service.RecruitService;
import com.eep.bo.staff.service.StaffCareerService;
import com.eep.bo.system.service.BoSystemService;
import com.eep.mapper.BoDeployMapper;

/**
 * 모집 관리(/admin/recruit). 주소 권한은 메뉴 AUTH_PATTERN(/admin/recruit/**), 단가는 급여관리 권한. 구글 캘린더와는 연동하지 않는다.
 */
@Controller
public class BoRecruitController {

	private static final String PAY_PAGE = "/admin/pay/openPayList.do";

	@Autowired
	private RecruitService recruit;
	@Autowired
	private StaffCareerService career;
	@Autowired
	private SecretFilter secret;
	@Autowired
	private BoSystemService systemService;
	@Autowired
	private BoDeployMapper deployMapper;

	@RequestMapping("/admin/recruit/openRecruitList.do")
	public ModelAndView open() {
		return new ModelAndView("bo/recruit/recruit_list");
	}

	@RequestMapping(value = "/admin/recruit/listData.do", method = RequestMethod.POST)
	public ModelAndView listData(HttpSession session) {
		return run(() -> {
			String id = loginId(session);
			SecretFilter.View v = secret.view(id);
			Map<String, Object> out = recruit.screen(canPay(id));
			v.filterMap(out, "applies");
			Map<String, Object> people = recruit.people();
			v.filterMap(people, "staff", "profiles", "current");
			out.putAll(people);
			out.put("partners", deployMapper.selectPartnerList());
			out.put("codes", deployMapper.selectCodes());
			out.put("superUser", systemService.access(id).superUser);
			out.put("canStaff", systemService.access(id).allows("/admin/staff/staffListData.do")); // 대기자 이름 → 인사카드 팝업
			return out;
		});
	}

	@RequestMapping(value = "/admin/recruit/parseData.do", method = RequestMethod.POST)
	public ModelAndView parseData(@RequestParam(value = "RAW_TEXT", defaultValue = "") String raw) {
		return run(() -> recruit.parse(raw));
	}

	@RequestMapping(value = "/admin/recruit/saveData.do", method = RequestMethod.POST)
	public ModelAndView saveData(@RequestParam Map<String, Object> p, HttpSession session) {
		return run(() -> {
			if (!canPay(loginId(session))) p.remove("PRICE_TXT"); // 단가는 볼 수 있는 사람만 고친다
			return recruit.save(p, loginId(session));
		});
	}

	@RequestMapping(value = "/admin/recruit/detailData.do", method = RequestMethod.POST)
	public ModelAndView detailData(@RequestParam("RECRUIT_SQ") int sq, HttpSession session) {
		return run(() -> {
			Map<String, Object> out = new HashMap<>();
			Map<String, Object> r = recruit.one(sq);
			if (!canPay(loginId(session)) && r.get("PRICE_TXT") != null) r.put("PRICE_TXT", "🔒");
			out.put("recruit", r);
			out.put("files", recruit.files(sq));
			out.put("logs", recruit.logs(sq));
			return out;
		});
	}

	@RequestMapping(value = "/admin/recruit/statusData.do", method = RequestMethod.POST)
	public ModelAndView statusData(@RequestParam("RECRUIT_SQ") int sq, @RequestParam("STATUS_CD") String status, HttpSession session) {
		return run(() -> { recruit.setStatus(sq, status, loginId(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/recruit/deleteData.do", method = RequestMethod.POST)
	public ModelAndView deleteData(@RequestParam("RECRUIT_SQ") int sq, HttpSession session) {
		return run(() -> { recruit.delete(sq, loginId(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/recruit/folderData.do", method = RequestMethod.POST)
	public ModelAndView folderData(@RequestParam("RECRUIT_SQ") int sq) {
		return run(() -> recruit.ensureFolder(sq));
	}

	@RequestMapping(value = "/admin/recruit/uploadData.do", method = RequestMethod.POST)
	public ModelAndView uploadData(@RequestParam("RECRUIT_SQ") int sq, @RequestParam("file") MultipartFile file, HttpSession session) {
		List<Upload> ups = new ArrayList<>();
		return Upload.noted(run(() -> {
			Upload u = Upload.of(file); // 요구사항서·RFP(hwp·xlsx 등)도 받는다. 크기 검사와 PDF·이미지 줄이기는 공통 규칙
			ups.add(u);
			recruit.upload(sq, u, loginId(session));
			return "OK";
		}), ups.toArray(new Upload[0]));
	}

	@RequestMapping(value = "/admin/recruit/deleteFileData.do", method = RequestMethod.POST)
	public ModelAndView deleteFileData(@RequestParam("RECRUIT_SQ") int sq, @RequestParam("FILE_SQ") int fileSq, HttpSession session) {
		return run(() -> { recruit.deleteFile(sq, fileSq, loginId(session)); return "OK"; });
	}

	// ── 지원·단계 ──

	@RequestMapping(value = "/admin/recruit/applyData.do", method = RequestMethod.POST)
	public ModelAndView applyData(@RequestParam("RECRUIT_SQ") int sq, @RequestParam("STAFF_SQ") int staffSq, @RequestParam("VER") String ver, HttpSession session) {
		return run(() -> {
			secret.view(loginId(session)).guard(staffSq);
			return recruit.apply(sq, staffSq, ver, loginId(session));
		});
	}

	@RequestMapping(value = "/admin/recruit/wordData.do", method = RequestMethod.POST)
	public ModelAndView wordData(@RequestParam("APPLY_SQ") int applySq, HttpSession session) {
		return run(() -> { guardApply(applySq, session); recruit.saveWord(applySq, loginId(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/recruit/stepData.do", method = RequestMethod.POST)
	public ModelAndView stepData(@RequestParam("APPLY_SQ") int applySq, @RequestParam("STEP_CD") String step, @RequestParam(value = "DEL_DEPLOY", defaultValue = "N") String delDeploy,
			@RequestParam(value = "REASON", defaultValue = "") String reason, HttpSession session) {
		return run(() -> { guardApply(applySq, session); return recruit.step(applySq, step, "Y".equals(delDeploy), reason, loginId(session)); });
	}

	@RequestMapping(value = "/admin/recruit/cancelData.do", method = RequestMethod.POST)
	public ModelAndView cancelData(@RequestParam("APPLY_SQ") int applySq, HttpSession session) {
		return run(() -> { guardApply(applySq, session); return recruit.cancel(applySq, loginId(session)); });
	}

	@RequestMapping(value = "/admin/recruit/interviewData.do", method = RequestMethod.POST)
	public ModelAndView interviewData(@RequestParam("APPLY_SQ") int applySq, @RequestParam Map<String, Object> p, HttpSession session) {
		return run(() -> { guardApply(applySq, session); return recruit.interview(applySq, p, loginId(session)); });
	}

	@RequestMapping(value = "/admin/recruit/joinData.do", method = RequestMethod.POST)
	public ModelAndView joinData(@RequestParam("APPLY_SQ") int applySq, @RequestParam Map<String, Object> p, HttpSession session) {
		return run(() -> {
			guardApply(applySq, session);
			String id = loginId(session);
			return recruit.join(applySq, p, "Y".equals(p.get("DRAFT")), canPay(id), id);
		});
	}

	/** 지원 창의 버전 미리보기·대기자 패널 칩: 그 버전 워드 받기 */
	@RequestMapping(value = "/admin/recruit/profileWord.do", method = RequestMethod.GET)
	public void profileWord(@RequestParam("STAFF_SQ") int staffSq, @RequestParam(value = "VER_NO", defaultValue = "") String verNo, HttpServletResponse response, HttpSession session) throws IOException {
		word(career, secret.view(loginId(session)), staffSq, verNo, response);
	}

	/** 투입현황 대기 현황 칸과 같이 쓴다 */
	public static void word(StaffCareerService career, SecretFilter.View v, int staffSq, String verNo, HttpServletResponse response) throws IOException {
		byte[] data;
		try {
			v.guard(staffSq);
			data = career.word(staffSq, verNo);
		} catch (IllegalArgumentException e) {
			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			response.setContentType("text/plain; charset=UTF-8");
			response.getWriter().write(e.getMessage());
			return;
		}
		response.setContentType("application/vnd.openxmlformats-officedocument.wordprocessingml.document");
		response.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + java.net.URLEncoder.encode(career.wordName(staffSq).replaceAll("\\.docx$", "") + (verNo.isEmpty() ? "" : "_v" + verNo) + ".docx", "UTF-8").replace("+", "%20"));
		response.setContentLength(data.length);
		response.getOutputStream().write(data);
	}

	// ── 공통 ──

	private void guardApply(int applySq, HttpSession session) {
		secret.view(loginId(session)).guard(recruit.apply(applySq).get("STAFF_SQ"));
	}

	private boolean canPay(String loginId) {
		return systemService.access(loginId).allows(PAY_PAGE);
	}

	private interface Call {
		Object run() throws Exception;
	}

	private static ModelAndView run(Call call) {
		try {
			return json("result", call.run());
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		} catch (Exception e) {
			System.out.println("RECRUIT_ERROR " + e.getClass().getSimpleName() + " " + e.getMessage());
			return json("error", "처리하지 못했습니다. (" + e.getClass().getSimpleName() + ")");
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
