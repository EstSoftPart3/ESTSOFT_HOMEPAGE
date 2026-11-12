package com.eep.bo.equipment.controller;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.equipment.service.BoEquipmentService;

/** 장비 - 장비대장, 전수조사, 대여증서. 권한은 /admin/** 인터셉터가 맡고 쓰기는 POST 만 받는다 */
@Controller
public class BoEquipmentController {

	@Autowired
	private BoEquipmentService service;

	@RequestMapping("/admin/equipment/openEquipmentList.do")
	public ModelAndView openEquipmentList() {
		return new ModelAndView("bo/equipment/equipment_list");
	}

	@RequestMapping("/admin/equipment/openAuditList.do")
	public ModelAndView openAuditList() {
		return new ModelAndView("bo/equipment/audit_list");
	}

	@RequestMapping(value = "/admin/equipment/equipmentListData.do", method = RequestMethod.POST)
	public ModelAndView equipmentListData() {
		return call(service::list);
	}

	@RequestMapping(value = "/admin/equipment/equipmentCardData.do", method = RequestMethod.POST)
	public ModelAndView equipmentCardData(@RequestParam("EQP_SQ") int eqpSq) {
		return call(() -> service.card(eqpSq));
	}

	@RequestMapping(value = "/admin/equipment/saveEquipmentFieldData.do", method = RequestMethod.POST)
	public ModelAndView saveEquipmentFieldData(@RequestParam Map<String, Object> param, HttpSession session) {
		return write(param, session, () -> service.saveField(param));
	}

	@RequestMapping(value = "/admin/equipment/insertEquipmentData.do", method = RequestMethod.POST)
	public ModelAndView insertEquipmentData(@RequestParam Map<String, Object> param, HttpSession session) {
		param.put("UPDT_EMPLY_ID", loginId(session));
		return call(() -> service.insert(param));
	}

	@RequestMapping(value = "/admin/equipment/deleteEquipmentData.do", method = RequestMethod.POST)
	public ModelAndView deleteEquipmentData(@RequestParam("EQP_SQ") int eqpSq) {
		return call(() -> { service.delete(eqpSq); return "OK"; });
	}

	@RequestMapping(value = "/admin/equipment/suggestNoData.do", method = RequestMethod.POST)
	public ModelAndView suggestNoData(@RequestParam("TYPE_CD") String type) {
		return call(() -> service.suggestNo(type));
	}

	@RequestMapping(value = "/admin/equipment/rentEquipmentData.do", method = RequestMethod.POST)
	public ModelAndView rentEquipmentData(@RequestParam Map<String, Object> param, HttpSession session) {
		param.put("UPDT_EMPLY_ID", loginId(session));
		return call(() -> service.rent(param));
	}

	@RequestMapping(value = "/admin/equipment/returnEquipmentData.do", method = RequestMethod.POST)
	public ModelAndView returnEquipmentData(@RequestParam Map<String, Object> param, HttpSession session) {
		return write(param, session, () -> service.returnRents(param));
	}

	@RequestMapping(value = "/admin/equipment/disposeEquipmentData.do", method = RequestMethod.POST)
	public ModelAndView disposeEquipmentData(@RequestParam Map<String, Object> param, HttpSession session) {
		return write(param, session, () -> service.dispose(param));
	}

	@RequestMapping(value = "/admin/equipment/saveRentFieldData.do", method = RequestMethod.POST)
	public ModelAndView saveRentFieldData(@RequestParam Map<String, Object> param, HttpSession session) {
		return write(param, session, () -> service.saveRentField(param));
	}

	@RequestMapping(value = "/admin/equipment/addIssueData.do", method = RequestMethod.POST)
	public ModelAndView addIssueData(@RequestParam Map<String, Object> param, HttpSession session) {
		return write(param, session, () -> service.addIssue(param));
	}

	@RequestMapping(value = "/admin/equipment/uploadFileData.do", method = RequestMethod.POST)
	public ModelAndView uploadFileData(@RequestParam("EQP_SQ") int eqpSq, @RequestParam("DOC_CD") String doc, @RequestParam("file") MultipartFile file, HttpSession session) {
		return call(() -> { service.uploadFile(eqpSq, doc, file.getOriginalFilename(), file.getContentType(), file.getBytes(), loginId(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/equipment/deleteFileData.do", method = RequestMethod.POST)
	public ModelAndView deleteFileData(@RequestParam Map<String, Object> param, HttpSession session) {
		return write(param, session, () -> service.deleteFile(param));
	}

	@RequestMapping(value = "/admin/equipment/staffEquipmentData.do", method = RequestMethod.POST)
	public ModelAndView staffEquipmentData(@RequestParam("STAFF_SQ") int staffSq) {
		return call(() -> service.staffEquipment(staffSq));
	}

	@RequestMapping(value = "/admin/equipment/saveSealData.do", method = RequestMethod.POST)
	public ModelAndView saveSealData(@RequestParam("IMG") String image, HttpSession session) {
		return call(() -> { service.saveSeal(image, loginId(session)); return "OK"; });
	}

	// ── 전수조사 ──

	@RequestMapping(value = "/admin/equipment/auditListData.do", method = RequestMethod.POST)
	public ModelAndView auditListData() {
		return call(service::audits);
	}

	@RequestMapping(value = "/admin/equipment/createAuditData.do", method = RequestMethod.POST)
	public ModelAndView createAuditData(@RequestParam("AUDIT_YM") String ym, HttpSession session) {
		return call(() -> service.createAudit(ym, loginId(session)));
	}

	@RequestMapping(value = "/admin/equipment/auditDetailData.do", method = RequestMethod.POST)
	public ModelAndView auditDetailData(@RequestParam("AUDIT_SQ") int auditSq) {
		return call(() -> service.auditDetail(auditSq));
	}

	@RequestMapping(value = "/admin/equipment/saveAuditResultData.do", method = RequestMethod.POST)
	public ModelAndView saveAuditResultData(@RequestParam Map<String, Object> param, HttpSession session) {
		return write(param, session, () -> service.saveAuditResult(param));
	}

	/** 체크한 장비의 결과를 한 번에 바꾼다. 메모(NOTE)는 그대로 둔다 */
	@RequestMapping(value = "/admin/equipment/saveAuditResultsData.do", method = RequestMethod.POST)
	public ModelAndView saveAuditResultsData(@RequestParam("AUDIT_SQ") int auditSq, @RequestParam("RESULT_CD") String result,
			@RequestParam(value = "EQP_SQ", required = false) int[] eqpSqs, HttpSession session) {
		return call(() -> service.saveAuditResults(auditSq, result, eqpSqs, loginId(session)));
	}

	@RequestMapping(value = "/admin/equipment/closeAuditData.do", method = RequestMethod.POST)
	public ModelAndView closeAuditData(@RequestParam("AUDIT_SQ") int auditSq) {
		return call(() -> { service.closeAudit(auditSq); return "OK"; });
	}

	// ── 대여증서 ──

	@RequestMapping("/admin/equipment/certificate.do")
	public ModelAndView certificate(@RequestParam("group") String group) {
		ModelAndView mv = new ModelAndView("bo/equipment/certificate");
		Map<String, Object> cert = service.certificate(group);
		mv.addObject("cert", cert);
		// 계정이 있는 직원은 본인 로그인으로 서명한다. 담당자 화면 서명은 게스트만
		mv.addObject("canSign", cert.get("sign") == null && Boolean.TRUE.equals(cert.get("guest")));
		mv.addObject("canUpload", cert.get("sign") == null);
		mv.addObject("signUrl", "/admin/equipment/signCertificateData.do");
		return mv;
	}

	@RequestMapping(value = "/admin/equipment/signCertificateData.do", method = RequestMethod.POST)
	public ModelAndView signCertificateData(@RequestParam("group") String group, @RequestParam("IMG") String image, HttpServletRequest request, HttpSession session) {
		return call(() -> {
			if (!Boolean.TRUE.equals(service.certificate(group).get("guest"))) throw new IllegalArgumentException("계정이 있는 직원은 홈페이지의 내 장비에서 직접 서명해야 합니다.");
			service.sign(group, image, loginId(session), "GUEST", ip(request));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/equipment/uploadSignedData.do", method = RequestMethod.POST)
	public ModelAndView uploadSignedData(@RequestParam("group") String group, @RequestParam("file") MultipartFile file, HttpServletRequest request, HttpSession session) {
		return call(() -> { service.uploadSigned(group, file.getOriginalFilename(), file.getContentType(), file.getBytes(), loginId(session), ip(request)); return "OK"; });
	}

	public static String ip(HttpServletRequest request) {
		String forwarded = request.getHeader("X-Forwarded-For");
		return forwarded != null && !forwarded.isEmpty() ? forwarded.split(",")[0].trim() : request.getRemoteAddr();
	}

	private interface Call {
		Object run() throws Exception;
	}

	private ModelAndView write(Map<String, Object> param, HttpSession session, Runnable action) {
		param.put("UPDT_EMPLY_ID", loginId(session));
		return call(() -> { action.run(); return "OK"; });
	}

	/** 드라이브 응답 본문(토큰·경로가 섞일 수 있음)은 화면에 내보내지 않는다 */
	private static ModelAndView call(Call call) {
		ModelAndView mv = new ModelAndView("jsonView");
		try {
			mv.addObject("result", call.run());
		} catch (IllegalArgumentException e) {
			mv.addObject("error", e.getMessage());
		} catch (DataIntegrityViolationException e) {
			mv.addObject("error", "이미 사용 중인 번호이거나 이미 처리된 건입니다. 입력이 너무 길어도 저장되지 않습니다.");
		} catch (HttpStatusCodeException e) {
			mv.addObject("error", "구글 드라이브 처리에 실패했습니다. (" + e.getStatusCode().value() + ") 직원관리의 드라이브 연결과 폴더 권한을 확인해 주세요.");
		} catch (Exception e) {
			System.out.println("EQUIPMENT_ERROR " + e.getClass().getSimpleName());
			mv.addObject("error", "처리하지 못했습니다. (" + e.getClass().getSimpleName() + ")");
		}
		return mv;
	}

	@SuppressWarnings("unchecked")
	private static String loginId(HttpSession session) {
		Map<String, Object> info = (Map<String, Object>) session.getAttribute("loginInfo");
		List<Map<String, Object>> list = (List<Map<String, Object>>) info.get("loginInfo");
		return (String) list.get(0).get("emplyId");
	}
}
