package com.eep.bo.staff.controller;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.batch.controller.BoBatchController;
import com.eep.bo.staff.service.BoStaffService;
import com.eep.bo.staff.service.StaffDriveService;

/**
 * 직원 - 직원관리(인사카드) Controller
 * 권한은 /admin/** 인터셉터(관리자만 통과)가 맡는다. 쓰기와 원문 보기는 POST 만 받는다
 */
@Controller
public class BoStaffController {

	@Autowired
	private BoStaffService BoStaffService;

	@Autowired
	private StaffDriveService StaffDriveService;

	@RequestMapping("/admin/staff/openStaffList.do")
	public ModelAndView openStaffList() {
		return new ModelAndView("bo/staff/staff_list");
	}

	@RequestMapping(value = "/admin/staff/staffListData.do", method = RequestMethod.POST)
	public ModelAndView staffListData() {
		return json("list", BoStaffService.list());
	}

	@RequestMapping(value = "/admin/staff/revealStaffData.do", method = RequestMethod.POST)
	public ModelAndView revealStaffData(@RequestParam Map<String, Object> param, HttpSession session) {
		try {
			String value = BoStaffService.reveal(param);
			// 누가 누구의 어느 값을 봤는지만 남긴다(값은 남기지 않는다)
			System.out.println("STAFF_REVEAL by=" + loginId(session) + " staff=" + param.get("STAFF_SQ") + " field=" + param.get("FIELD"));
			return json("value", value);
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/staff/saveStaffFieldData.do", method = RequestMethod.POST)
	public ModelAndView saveStaffFieldData(@RequestParam Map<String, Object> param, HttpSession session) {
		try {
			param.put("UPDT_EMPLY_ID", loginId(session));
			BoStaffService.fieldSave(param);
			return json("result", "OK");
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/staff/insertStaffData.do", method = RequestMethod.POST)
	public ModelAndView insertStaffData(@RequestParam Map<String, Object> param, HttpSession session) {
		try {
			param.put("UPDT_EMPLY_ID", loginId(session));
			return json("STAFF_SQ", BoStaffService.insert(param));
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/staff/deleteStaffData.do", method = RequestMethod.POST)
	public ModelAndView deleteStaffData(@RequestParam Map<String, Object> param) {
		BoStaffService.delete(param);
		return json("result", "OK");
	}

	// ── 서류 첨부(구글 드라이브) ──

	/** 구글 승인 화면으로 보낸다. 돌아오는 곳은 콘솔에 등록된 /admin/batch/driveCallback.do 이고, 세션 표시를 보고 이쪽 연결로 처리한다 */
	@RequestMapping("/admin/staff/driveStart.do")
	public String driveStart(HttpServletRequest request, HttpSession session) {
		String state = UUID.randomUUID().toString();
		String url = StaffDriveService.authUrl(BoBatchController.redirectUri(request), state);
		if (url == null) {
			return "redirect:/admin/staff/openStaffList.do?drive=noclient";
		}
		session.setAttribute(SS_STAFF_DRIVE_STATE, state);
		return "redirect:" + url;
	}

	@RequestMapping(value = "/admin/staff/staffDriveStatusData.do", method = RequestMethod.POST)
	public ModelAndView staffDriveStatusData() {
		return json("drive", StaffDriveService.status());
	}

	@RequestMapping(value = "/admin/staff/staffDocsData.do", method = RequestMethod.POST)
	public ModelAndView staffDocsData(@RequestParam("STAFF_SQ") int staffSq) {
		return json("docs", StaffDriveService.docs(staffSq));
	}

	@RequestMapping(value = "/admin/staff/uploadStaffDocData.do", method = RequestMethod.POST)
	public ModelAndView uploadStaffDocData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("DOC_CD") String doc,
			@RequestParam("file") MultipartFile file, HttpSession session) {
		return drive(() -> StaffDriveService.upload(staffSq, doc, file.getOriginalFilename(), file.getContentType(), file.getBytes(), loginId(session)));
	}

	@RequestMapping(value = "/admin/staff/scanStaffDocsData.do", method = RequestMethod.POST)
	public ModelAndView scanStaffDocsData(@RequestParam("STAFF_SQ") int staffSq) {
		return drive(() -> StaffDriveService.scan(staffSq));
	}

	@RequestMapping(value = "/admin/staff/linkStaffDocData.do", method = RequestMethod.POST)
	public ModelAndView linkStaffDocData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("DOC_CD") String doc, @RequestParam("FILE_ID") String fileId, HttpSession session) {
		return drive(() -> StaffDriveService.link(staffSq, doc, fileId, loginId(session)));
	}

	@RequestMapping(value = "/admin/staff/readStaffDocData.do", method = RequestMethod.POST)
	public ModelAndView readStaffDocData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("DOC_CD") String doc, @RequestParam("FILE_ID") String fileId, HttpSession session) {
		return drive(() -> StaffDriveService.read(staffSq, doc, fileId, loginId(session)));
	}

	@RequestMapping(value = "/admin/staff/unlinkStaffDocData.do", method = RequestMethod.POST)
	public ModelAndView unlinkStaffDocData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("DOC_SQ") int docSq) {
		StaffDriveService.unlink(staffSq, docSq);
		return json("result", "OK");
	}

	public static final String SS_STAFF_DRIVE_STATE = "staffDriveState";

	private interface DriveCall {
		Object run() throws Exception;
	}

	/** 드라이브 호출 오류를 화면에 보일 글로 바꾼다. 응답 본문(토큰·경로가 섞일 수 있음)은 내보내지 않는다 */
	private static ModelAndView drive(DriveCall call) {
		try {
			return json("result", call.run());
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		} catch (HttpStatusCodeException e) {
			int code = e.getStatusCode().value();
			return json("error", code == 401 || code == 403 ? "구글 드라이브 권한이 없습니다. '드라이브 연결'을 다시 하거나, 연결 계정에 '2. 인사관리' 폴더 편집 권한이 있는지 확인해 주세요. (" + code + ")"
					: code == 404 ? "드라이브에서 파일이나 폴더를 찾지 못했습니다. (404)" : "구글 드라이브 처리에 실패했습니다. (" + code + ")");
		} catch (Exception e) {
			System.out.println("STAFF_DRIVE_ERROR " + e.getClass().getSimpleName());
			return json("error", "구글 드라이브 처리에 실패했습니다. (" + e.getClass().getSimpleName() + ")");
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
