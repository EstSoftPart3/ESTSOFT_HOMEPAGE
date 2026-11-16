package com.eep.bo.staff.controller;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.multipart.MultipartFile;

import com.common.upload.Upload;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.deploy.service.SecretFilter;
import com.eep.bo.member.service.BoMemberService;
import com.eep.bo.member.service.BoMemberService.Actor;
import com.eep.bo.staff.service.BoStaffService;
import com.eep.bo.staff.service.StaffCareerService;
import com.eep.bo.staff.service.StaffCareerWord;
import com.eep.bo.staff.service.StaffDriveService;
import com.eep.bo.system.service.BoSystemService;

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

	@Autowired
	private StaffCareerService career;

	@Autowired
	private BoMemberService memberService;

	@Autowired
	private BoSystemService system;

	@Autowired
	private SecretFilter secretFilter;

	@RequestMapping("/admin/staff/openStaffList.do")
	public ModelAndView openStaffList() {
		return new ModelAndView("bo/staff/staff_list");
	}

	@RequestMapping(value = "/admin/staff/staffListData.do", method = RequestMethod.POST)
	public ModelAndView staffListData(HttpSession session) {
		SecretFilter.View v = secretFilter.view(loginId(session));
		ModelAndView mv = json("list", v.filter(BoStaffService.list())); // 투입현황·급여관리와 같이 시크릿 직원은 시크릿 계정에게만
		mv.addObject("secretViewer", v.secret);
		mv.addObject("canSecret", memberService.canSecret(actor(session))); // 시크릿 탭은 계정관리와 같이 슈퍼관리자에게만 그린다
		return mv;
	}

	/** 잡지 않은 입력 오류(시크릿 검사 포함)는 화면이 알림으로 보이도록 JSON 오류로 돌려준다. 공통 처리기는 빈 응답을 준다 */
	@ExceptionHandler(IllegalArgumentException.class)
	public ModelAndView inputError(IllegalArgumentException e) {
		return json("error", e.getMessage());
	}

	/** 숨긴 시크릿 직원을 번호로 직접 요청해도 없는 것처럼 막는다. 이 컨트롤러의 모든 요청 전에 돈다 */
	@ModelAttribute
	public void secretGuard(@RequestParam(value = "STAFF_SQ", required = false) String staffSq, HttpSession session) {
		if (staffSq != null && !staffSq.isEmpty()) {
			secretFilter.view(loginId(session)).guard(staffSq);
		}
	}

	// ── 시크릿 (계정관리와 같은 정책·저장. 직원에 연결된 로그인 계정에 켠다) ──

	@RequestMapping(value = "/admin/staff/staffSecretData.do", method = RequestMethod.POST)
	public ModelAndView staffSecretData(@RequestParam("STAFF_SQ") int staffSq, HttpSession session) {
		try {
			Map<String, Object> staff = BoStaffService.one(staffSq);
			Map<String, Object> out = memberService.staffSecret((String) staff.get("EMPLY_ID"), actor(session));
			// 계정이 없거나, 계정 연결 전에 직원에 켜 둔 시크릿도 켜진 것으로 보인다
			if ("Y".equals(staff.get("SECRET_YN"))) out.put("SECRET_YN", "Y");
			return json("result", out);
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/staff/setStaffSecretData.do", method = RequestMethod.POST)
	public ModelAndView setStaffSecretData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("SECRET_YN") String on, HttpSession session) {
		try {
			boolean toAccount = memberService.setStaffSecret((String) BoStaffService.one(staffSq).get("EMPLY_ID"), "Y".equals(on), actor(session));
			// 계정에 저장했으면 직원 쪽 표시는 지워 두 값이 어긋나지 않게 한다
			BoStaffService.setSecret(staffSq, !toAccount && "Y".equals(on));
			return json("result", "OK");
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	private Actor actor(HttpSession session) {
		String id = loginId(session);
		return new Actor(id, system.access(id).superUser);
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
			// 재직 상태가 바뀌면 드라이브 사람 폴더도 옮긴다(퇴사 → 퇴사자 관리, 대기 → 재직은 교육생 폴더 이동, 재입사는 새 폴더)
			boolean status = "STATUS_CD".equals(param.get("FIELD"));
			String before = status ? String.valueOf(BoStaffService.one(param.get("STAFF_SQ")).get("STATUS_CD")) : null;
			BoStaffService.fieldSave(param);
			ModelAndView mv = json("result", "OK");
			if (status) mv.addObject("driveNote", StaffDriveService.statusChanged(param.get("STAFF_SQ"), before, String.valueOf(param.get("VALUE"))));
			return mv;
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/staff/insertStaffData.do", method = RequestMethod.POST)
	public ModelAndView insertStaffData(@RequestParam Map<String, Object> param, HttpSession session) {
		try {
			param.put("UPDT_EMPLY_ID", loginId(session));
			Object sq = BoStaffService.insert(param);
			ModelAndView mv = json("STAFF_SQ", sq);
			// 직원 등록 때 드라이브 사람 폴더를 바로 만든다(대기 카드면 대기자 관리, 프리랜서는 계약직 관리)
			mv.addObject("driveNote", "WAIT".equals(param.get("STATUS_CD")) ? null : StaffDriveService.staffCreated(sq));
			return mv;
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/staff/deleteStaffData.do", method = RequestMethod.POST)
	public ModelAndView deleteStaffData(@RequestParam Map<String, Object> param) {
		BoStaffService.delete(param);
		career.deleteAll(param.get("STAFF_SQ"));
		return json("result", "OK");
	}

	// ── 서류 첨부(구글 드라이브) ──

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
		Upload[] u = new Upload[1];
		return Upload.noted(drive(() -> { u[0] = Upload.of(file); return StaffDriveService.upload(staffSq, doc, u[0].name, u[0].mime, u[0].data, loginId(session)); }), u);
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

	/** 드라이브 파일을 서버가 받아 전달한다. 관리자 개인 구글 계정의 권한과 상관없이 받을 수 있다 */
	@RequestMapping(value = "/admin/staff/downloadStaffDoc.do", method = RequestMethod.GET)
	@SuppressWarnings("unchecked")
	public void downloadStaffDoc(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("DOC_SQ") int docSq, HttpServletResponse response, HttpSession session) throws IOException {
		ModelAndView mv = drive(() -> StaffDriveService.download(staffSq, docSq));
		Object error = mv.getModel().get("error");
		if (error != null && error.toString().startsWith("[연동 필요:")) {
			response.sendRedirect("/admin/my/openGoogleLink.do?need=1&svc=DRIVE");
			return;
		}
		if (error != null) {
			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			response.setContentType("text/plain; charset=UTF-8");
			response.getWriter().write(error.toString());
			return;
		}
		byte[] data = (byte[]) ((Map<String, Object>) mv.getModel().get("result")).get("data");
		System.out.println("STAFF_DOC_DOWNLOAD by=" + loginId(session) + " staff=" + staffSq + " doc=" + docSq);
		response.setContentType("application/octet-stream");
		response.setHeader("X-Content-Type-Options", "nosniff");
		response.setContentLength(data.length);
		response.getOutputStream().write(data);
	}

	// ── 수행이력 (입력 오류는 inputError 가 JSON 오류로 돌려준다) ──

	@RequestMapping(value = "/admin/staff/careerData.do", method = RequestMethod.POST)
	public ModelAndView careerData(@RequestParam("STAFF_SQ") int staffSq) {
		return json("result", career.state(staffSq));
	}

	@RequestMapping(value = "/admin/staff/saveCareerData.do", method = RequestMethod.POST)
	public ModelAndView saveCareerData(@RequestParam Map<String, Object> param, HttpSession session) {
		career.save(param, loginId(session));
		return json("result", "OK");
	}

	@RequestMapping(value = "/admin/staff/deleteCareerData.do", method = RequestMethod.POST)
	public ModelAndView deleteCareerData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("PRJ_SQS") String prjSqs, HttpSession session) {
		career.delete(staffSq, StaffCareerService.tokens(prjSqs), loginId(session));
		return json("result", "OK");
	}

	@RequestMapping(value = "/admin/staff/bulkCareerData.do", method = RequestMethod.POST)
	public ModelAndView bulkCareerData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("PRJ_SQS") String prjSqs, @RequestParam("FIELD") String field,
			@RequestParam("VALUES") String values, HttpSession session) {
		career.bulkAdd(staffSq, StaffCareerService.tokens(prjSqs), field, values, loginId(session));
		return json("result", "OK");
	}

	@RequestMapping(value = "/admin/staff/saveCareerVersionData.do", method = RequestMethod.POST)
	public ModelAndView saveCareerVersionData(@RequestParam("STAFF_SQ") int staffSq, HttpSession session) {
		return json("result", career.saveVersion(staffSq, loginId(session)));
	}

	@RequestMapping(value = "/admin/staff/careerVersionsData.do", method = RequestMethod.POST)
	public ModelAndView careerVersionsData(@RequestParam("STAFF_SQ") int staffSq) {
		return json("result", career.versions(staffSq));
	}

	@RequestMapping(value = "/admin/staff/careerVersionData.do", method = RequestMethod.POST)
	public ModelAndView careerVersionData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("VER_NO") String verNo) {
		return json("result", career.versionItems(staffSq, verNo));
	}

	@RequestMapping(value = "/admin/staff/restoreCareerData.do", method = RequestMethod.POST)
	public ModelAndView restoreCareerData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("VER_NO") String verNo, HttpSession session) {
		career.restore(staffSq, verNo, loginId(session));
		return json("result", "OK");
	}

	/** 워드를 읽어 지금 내용과 비교만 한다(저장하지 않음) */
	@RequestMapping(value = "/admin/staff/importCareerPreviewData.do", method = RequestMethod.POST)
	public ModelAndView importCareerPreviewData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("file") MultipartFile file) throws IOException {
		Upload.check(file, "docx");
		List<Map<String, Object>> rows;
		try {
			rows = StaffCareerWord.parse(file.getInputStream());
		} catch (RuntimeException e) {
			throw new IllegalArgumentException("워드 파일을 읽지 못했습니다. .docx 형식인지 확인해 주세요.");
		}
		if (rows.isEmpty()) throw new IllegalArgumentException("SKILL INVENTORY 표에서 프로젝트를 찾지 못했습니다.");
		return json("result", career.importPreview(staffSq, rows));
	}

	@RequestMapping(value = "/admin/staff/importCareerData.do", method = RequestMethod.POST)
	public ModelAndView importCareerData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("ROWS") String rows, @RequestParam(value = "FILE_NM", required = false) String fileNm, HttpSession session) {
		return json("result", career.importApply(staffSq, StaffCareerService.parse(rows), fileNm, loginId(session)));
	}

	/** 회사 양식 워드 내려받기. VER_NO 가 없으면 최신 버전 */
	@RequestMapping(value = "/admin/staff/careerWord.do", method = RequestMethod.GET)
	public void careerWord(@RequestParam("STAFF_SQ") int staffSq, @RequestParam(value = "VER_NO", required = false) String verNo, HttpServletResponse response, HttpSession session) throws IOException {
		byte[] data;
		try {
			data = career.word(staffSq, verNo);
		} catch (IllegalArgumentException e) {
			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			response.setContentType("text/plain; charset=UTF-8");
			response.getWriter().write(e.getMessage());
			return;
		}
		System.out.println("STAFF_CAREER_WORD by=" + loginId(session) + " staff=" + staffSq + " ver=" + verNo);
		response.setContentType("application/vnd.openxmlformats-officedocument.wordprocessingml.document");
		response.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + java.net.URLEncoder.encode(career.wordName(staffSq), "UTF-8").replace("+", "%20"));
		response.setContentLength(data.length);
		response.getOutputStream().write(data);
	}

	@RequestMapping(value = "/admin/staff/careerWordDriveData.do", method = RequestMethod.POST)
	public ModelAndView careerWordDriveData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam(value = "VER_NO", required = false) String verNo) {
		return drive(() -> StaffDriveService.uploadCareerWord(staffSq, career.word(staffSq, verNo)));
	}

	// ── 학력·교육·비상연락 추가 건 ──

	@RequestMapping(value = "/admin/staff/staffItemData.do", method = RequestMethod.POST)
	public ModelAndView staffItemData(@RequestParam Map<String, Object> param) {
		return json("list", BoStaffService.itemList(param));
	}

	@RequestMapping(value = "/admin/staff/saveStaffItemData.do", method = RequestMethod.POST)
	public ModelAndView saveStaffItemData(@RequestParam Map<String, Object> param, HttpSession session) {
		try {
			param.put("UPDT_EMPLY_ID", loginId(session));
			BoStaffService.itemSave(param);
			return json("result", "OK");
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/staff/deleteStaffItemData.do", method = RequestMethod.POST)
	public ModelAndView deleteStaffItemData(@RequestParam Map<String, Object> param) {
		BoStaffService.itemDelete(param);
		return json("result", "OK");
	}

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
			return json("error", code == 401 || code == 403 ? "구글 드라이브 권한이 없습니다. 내 연동에서 드라이브를 다시 연결하거나, 내 구글 계정에 '2. 인사관리' 폴더 편집 권한이 있는지 확인해 주세요. (" + code + ")"
					: code == 404 ? "드라이브에서 파일이나 폴더를 찾지 못했습니다. 내 구글 계정에 '2. 인사관리' 폴더가 공유돼 있는지 확인해 주세요. (404)" : "구글 드라이브 처리에 실패했습니다. (" + code + ")");
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
