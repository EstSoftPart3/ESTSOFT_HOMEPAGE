package com.eep.bo.deploy.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.Arrays;
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
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.common.upload.Upload;
import com.eep.bo.deploy.service.BoBonusService;
import com.eep.bo.deploy.service.BoDeployService;
import com.eep.bo.deploy.service.BoPayrollService;
import com.eep.bo.deploy.service.SecretFilter;
import com.eep.bo.system.service.BoSystemService;

/**
 * 직원 - 투입현황(/admin/deploy), 급여관리(/admin/pay), 매출/매입처(/admin/partner).
 * 주소별 권한은 메뉴의 AUTH_PATTERN 으로 인터셉터가 막는다. 투입현황의 단가는 급여관리 권한이 있을 때만 주고받는다.
 */
@Controller
public class BoDeployController {

	private static final String PAY_PAGE = "/admin/pay/openPayList.do";

	@Autowired
	private BoDeployService deployService;

	@Autowired
	private BoPayrollService payrollService;

	@Autowired
	private BoSystemService systemService;

	@Autowired
	private BoBonusService bonusService;

	@Autowired
	private SecretFilter secret;

	// ── 투입현황 ──

	@RequestMapping("/admin/deploy/openDeployList.do")
	public ModelAndView openDeployList() {
		return new ModelAndView("bo/deploy/deploy_list");
	}

	@RequestMapping(value = "/admin/deploy/deployListData.do", method = RequestMethod.POST)
	public ModelAndView deployListData(HttpSession session) {
		String id = loginId(session);
		SecretFilter.View v = secret.view(id);
		Map<String, Object> out = v.filterMap(deployService.deployList(canPay(id)), "all", "current", "memoCounts", "chgCounts");
		out.put("me", id);
		out.putAll(v.filterMap(deployService.options(id), "staff"));
		out.put("secretViewer", v.secret);
		return json("data", out);
	}

	@RequestMapping(value = "/admin/deploy/saveDeployData.do", method = RequestMethod.POST)
	public ModelAndView saveDeployData(@RequestParam Map<String, Object> param, HttpSession session) {
		return run(() -> {
			param.put("UPDT_EMPLY_ID", loginId(session));
			SecretFilter.View v = secret.view(loginId(session));
			v.guard(param.get("STAFF_SQ"));
			if (param.get("DEPLOY_SQ") != null && !String.valueOf(param.get("DEPLOY_SQ")).isEmpty()) {
				v.guard(secret.staffOfDeploy(param.get("DEPLOY_SQ")));
			}
			deployService.saveDeploy(param, canPay(loginId(session)));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/deploy/deleteDeployData.do", method = RequestMethod.POST)
	public ModelAndView deleteDeployData(@RequestParam Map<String, Object> param, HttpSession session) {
		return run(() -> {
			param.put("UPDT_EMPLY_ID", loginId(session));
			secret.view(loginId(session)).guard(secret.staffOfDeploy(param.get("DEPLOY_SQ")));
			deployService.deleteDeploy(param);
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/deploy/extendDeployData.do", method = RequestMethod.POST)
	public ModelAndView extendDeployData(@RequestParam Map<String, Object> param, HttpSession session) {
		return run(() -> {
			param.put("UPDT_EMPLY_ID", loginId(session));
			secret.view(loginId(session)).guard(secret.staffOfDeploy(param.get("DEPLOY_SQ")));
			deployService.extendDeploy(param, canPay(loginId(session)));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/deploy/projectHistoryData.do", method = RequestMethod.POST)
	public ModelAndView projectHistoryData(@RequestParam("STAFF_SQ") int staffSq, HttpSession session) {
		return run(() -> {
			secret.view(loginId(session)).guard(staffSq);
			return deployService.projectHistory(staffSq, canPay(loginId(session)));
		});
	}

	/** 목록 칸 바로 수정. 단가 칸은 급여 권한이 있어야 한다 */
	@RequestMapping(value = "/admin/deploy/saveFieldData.do", method = RequestMethod.POST)
	public ModelAndView saveDeployFieldData(@RequestParam("DEPLOY_SQ") int deploySq, @RequestParam("FIELD") String field, @RequestParam(value = "VALUE", defaultValue = "") String value, HttpSession session) {
		return run(() -> {
			String id = loginId(session);
			secret.view(id).guard(secret.staffOfDeploy(deploySq));
			deployService.saveField(deploySq, field, value, canPay(id), id, null);
			return "OK";
		});
	}

	/** 고객사 직접계약 종류·금액. 종류(CLIENT_DIRECT_CD)를 비우면 지운다 */
	@RequestMapping(value = "/admin/deploy/saveDirectData.do", method = RequestMethod.POST)
	public ModelAndView saveDirectData(@RequestParam("DEPLOY_SQ") int deploySq, @RequestParam(value = "CLIENT_DIRECT_CD", defaultValue = "") String cd,
			@RequestParam(value = "CLIENT_DIRECT_AMT", defaultValue = "") String amt, HttpSession session) {
		return run(() -> {
			String id = loginId(session);
			secret.view(id).guard(secret.staffOfDeploy(deploySq));
			deployService.saveDirect(deploySq, cd, amt, canPay(id), id, null);
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/deploy/changeListData.do", method = RequestMethod.POST)
	public ModelAndView deployChangeListData(@RequestParam("STAFF_SQ") int staffSq, HttpSession session) {
		return run(() -> {
			String id = loginId(session);
			secret.view(id).guard(staffSq);
			return deployService.changes(staffSq, canPay(id));
		});
	}

	@RequestMapping(value = "/admin/deploy/revertData.do", method = RequestMethod.POST)
	public ModelAndView deployRevertData(@RequestParam("CHG_SQ") long chgSq, @RequestParam("STAFF_SQ") int staffSq, HttpSession session) {
		return run(() -> {
			String id = loginId(session);
			secret.view(id).guard(staffSq);
			deployService.revert(chgSq, staffSq, canPay(id), id);
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/deploy/memoListData.do", method = RequestMethod.POST)
	public ModelAndView deployMemoListData(@RequestParam("STAFF_SQ") int staffSq, HttpSession session) {
		return run(() -> {
			secret.view(loginId(session)).guard(staffSq);
			Map<String, Object> out = new HashMap<>();
			out.put("list", deployService.memos(staffSq));
			out.put("me", loginId(session));
			return out;
		});
	}

	@RequestMapping(value = "/admin/deploy/saveMemoData.do", method = RequestMethod.POST)
	public ModelAndView deploySaveMemoData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("CONTENT") String content, HttpSession session) {
		return run(() -> {
			secret.view(loginId(session)).guard(staffSq);
			deployService.addMemo(staffSq, content, loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/deploy/deleteMemoData.do", method = RequestMethod.POST)
	public ModelAndView deployDeleteMemoData(@RequestParam("MEMO_SQ") long memoSq, HttpSession session) {
		return run(() -> {
			secret.view(loginId(session)).guard(deployService.memoStaff(memoSq));
			deployService.deleteMemo(memoSq, loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/deploy/saveColumnsData.do", method = RequestMethod.POST)
	public ModelAndView saveColumnsData(@RequestParam(value = "ORDER", required = false) String order, HttpSession session) {
		return run(() -> {
			deployService.saveColumns(loginId(session), order);
			return "OK";
		});
	}

	// ── 매출/매입처 ──

	@RequestMapping("/admin/partner/openPartnerList.do")
	public ModelAndView openPartnerList() {
		return new ModelAndView("bo/deploy/partner_list");
	}

	@RequestMapping(value = "/admin/partner/partnerListData.do", method = RequestMethod.POST)
	public ModelAndView partnerListData() {
		return json("list", deployService.partnerList());
	}

	@RequestMapping(value = "/admin/partner/savePartnerData.do", method = RequestMethod.POST)
	/** 서류 파일은 종류 이름(LICENSE·LOGO·SEAL·BANK)으로, 지울 종류는 REMOVE 에 쉼표로 받는다 */
	public ModelAndView savePartnerData(@RequestParam Map<String, Object> param, MultipartHttpServletRequest request, HttpSession session) {
		List<Upload> ups = new ArrayList<>();
		return Upload.noted(run(() -> {
			String remove = String.valueOf(param.getOrDefault("REMOVE", ""));
			param.remove("REMOVE");
			param.put("UPDT_EMPLY_ID", loginId(session));
			Map<String, Map<String, Object>> files = new HashMap<>();
			for (Map.Entry<String, MultipartFile> e : request.getFileMap().entrySet()) {
				MultipartFile f = e.getValue();
				if (!f.isEmpty()) {
					Upload u = Upload.of(f, Upload.DOCS);
					ups.add(u);
					Map<String, Object> m = new HashMap<>();
					m.put("FILE_NM", u.name);
					m.put("FILE_TYPE", u.mime);
					m.put("FILE_DATA", u.data);
					files.put(e.getKey(), m);
				}
			}
			deployService.savePartner(param, files, remove.isEmpty() ? new ArrayList<>() : Arrays.asList(remove.split(",")));
			return "OK";
		}), ups.toArray(new Upload[0]));
	}

	@RequestMapping(value = "/admin/partner/deletePartnerData.do", method = RequestMethod.POST)
	public ModelAndView deletePartnerData(@RequestParam Map<String, Object> param) {
		return run(() -> {
			deployService.deletePartner(param);
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/partner/readDocData.do", method = RequestMethod.POST)
	public ModelAndView readDocData(@RequestParam("file") MultipartFile file, @RequestParam(value = "KIND", required = false) String kind) {
		// 저장 때와 같이 줄인 파일로 읽는다(서류 5MB 제한을 줄인 크기로 본다)
		return run(() -> { Upload u = Upload.of(file, Upload.DOCS); return deployService.readDoc(u.name, u.mime, u.data, kind); });
	}

	@RequestMapping(value = "/admin/partner/partnerFile.do", method = RequestMethod.GET)
	public void partnerFile(@RequestParam Map<String, Object> param, HttpServletResponse response) throws IOException {
		Map<String, Object> f = deployService.partnerFile(param);
		if (f == null || f.get("FILE_DATA") == null) {
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return;
		}
		byte[] data = (byte[]) f.get("FILE_DATA");
		String name = String.valueOf(f.get("FILE_NM"));
		response.setContentType(name.toLowerCase().endsWith(".pdf") ? "application/pdf" : name.toLowerCase().endsWith(".png") ? "image/png" : "image/jpeg");
		response.setHeader("X-Content-Type-Options", "nosniff");
		response.setHeader("Content-Disposition", "inline; filename*=UTF-8''" + URLEncoder.encode(name, "UTF-8").replace("+", "%20"));
		response.setContentLength(data.length);
		response.getOutputStream().write(data);
	}

	// ── 급여관리 ──

	@RequestMapping(PAY_PAGE)
	public ModelAndView openPayList() {
		return new ModelAndView("bo/deploy/pay_list");
	}

	@RequestMapping(value = "/admin/pay/monthData.do", method = RequestMethod.POST)
	public ModelAndView monthData(@RequestParam(value = "YM", required = false) String ym, HttpSession session) {
		return run(() -> {
			SecretFilter.View v = secret.view(loginId(session));
			Map<String, Object> out = v.filterMap(payrollService.month(ym == null || ym.isEmpty() ? YearMonth.now().toString() : ym), "rows");
			out.put("secretViewer", v.secret);
			return out;
		});
	}

	@RequestMapping(value = "/admin/pay/paramData.do", method = RequestMethod.POST)
	public ModelAndView paramData() {
		return run(() -> payrollService.params());
	}

	@RequestMapping(value = "/admin/pay/saveParamData.do", method = RequestMethod.POST)
	public ModelAndView saveParamData(@RequestParam("PARAM_K") String key, @RequestParam("PARAM_V") String value, HttpSession session) {
		return run(() -> {
			payrollService.saveParam(key, value, loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/pay/staffYearData.do", method = RequestMethod.POST)
	public ModelAndView staffYearData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("YEAR") String year, HttpSession session) {
		return run(() -> {
			secret.view(loginId(session)).guard(staffSq);
			return payrollService.staffYear(staffSq, year);
		});
	}

	@RequestMapping(value = "/admin/pay/deployHistoryData.do", method = RequestMethod.POST)
	public ModelAndView deployHistoryData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("DEPLOY_SQ") int deploySq, HttpSession session) {
		return run(() -> {
			SecretFilter.View v = secret.view(loginId(session));
			v.guard(staffSq);
			v.guard(secret.staffOfDeploy(deploySq));
			return payrollService.deployHistory(staffSq, deploySq);
		});
	}

	@RequestMapping(value = "/admin/pay/detailData.do", method = RequestMethod.POST)
	public ModelAndView detailData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("YM") String ym, HttpSession session) {
		return run(() -> {
			secret.view(loginId(session)).guard(staffSq);
			return payrollService.detail(staffSq, ym);
		});
	}

	@RequestMapping(value = "/admin/pay/ackData.do", method = RequestMethod.POST)
	public ModelAndView ackData(@RequestParam("YM") String ym, @RequestParam("STAFF_SQ") int staffSq, @RequestParam("FLAG_K") String keyword, HttpSession session) {
		return run(() -> {
			secret.view(loginId(session)).guard(staffSq);
			payrollService.ack(ym, staffSq, keyword, loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/pay/payDateData.do", method = RequestMethod.POST)
	public ModelAndView payDateData(@RequestParam("YM") String ym, @RequestParam("PAY_DT") String date, HttpSession session) {
		return run(() -> {
			payrollService.payDate(ym, date, loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/pay/memoListData.do", method = RequestMethod.POST)
	public ModelAndView memoListData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam(value = "YM", required = false) String ym, HttpSession session) {
		return run(() -> {
			secret.view(loginId(session)).guard(staffSq);
			Map<String, Object> out = new java.util.HashMap<>();
			out.put("list", payrollService.memos(staffSq, ym));
			out.put("me", loginId(session));
			return out;
		});
	}

	@RequestMapping(value = "/admin/pay/saveMemoData.do", method = RequestMethod.POST)
	public ModelAndView saveMemoData(@RequestParam("YM") String ym, @RequestParam("STAFF_SQ") int staffSq, @RequestParam("CONTENT") String content, HttpSession session) {
		return run(() -> {
			secret.view(loginId(session)).guard(staffSq);
			payrollService.addMemo(ym, staffSq, content, loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/pay/deleteMemoData.do", method = RequestMethod.POST)
	public ModelAndView deleteMemoData(@RequestParam("MEMO_SQ") long memoSq, HttpSession session) {
		return run(() -> {
			payrollService.deleteMemo(memoSq, loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/pay/changeListData.do", method = RequestMethod.POST)
	public ModelAndView changeListData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam(value = "YM", required = false) String ym, HttpSession session) {
		return run(() -> {
			secret.view(loginId(session)).guard(staffSq);
			return payrollService.changes(staffSq, ym);
		});
	}

	@RequestMapping(value = "/admin/pay/revertData.do", method = RequestMethod.POST)
	public ModelAndView revertData(@RequestParam("CHG_SQ") long chgSq, HttpSession session) {
		return run(() -> {
			secret.view(loginId(session)).guard(secret.staffOfChange(chgSq));
			payrollService.revert(chgSq, loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/pay/saveFieldData.do", method = RequestMethod.POST)
	public ModelAndView saveFieldData(@RequestParam Map<String, Object> param, HttpSession session) {
		return run(() -> {
			secret.view(loginId(session)).guard(param.get("STAFF_SQ"));
			payrollService.saveField(param, loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/pay/closeData.do", method = RequestMethod.POST)
	public ModelAndView closeData(@RequestParam("YM") String ym, @RequestParam("CLOSE") boolean close, @RequestParam(value = "REASON", defaultValue = "") String reason, HttpSession session) {
		return run(() -> {
			payrollService.setClosed(ym, close, reason, loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/pay/importPreviewData.do", method = RequestMethod.POST)
	public ModelAndView importPreviewData(@RequestParam("YM") String ym, MultipartHttpServletRequest request, HttpSession session) {
		return run(() -> {
			List<byte[]> data = new ArrayList<>();
			for (MultipartFile f : request.getFiles("files")) {
				if (!f.isEmpty()) {
					Upload.check(f, Upload.EXCEL);
					data.add(f.getBytes());
				}
			}
			return secret.view(loginId(session)).filterMap(payrollService.importPreview(ym, data, new SessionMap(session)), "rows");
		});
	}

	@RequestMapping(value = "/admin/pay/importApplyData.do", method = RequestMethod.POST)
	public ModelAndView importApplyData(@RequestParam Map<String, Object> param, HttpSession session) {
		return run(() -> payrollService.importApply(String.valueOf(param.get("YM")), param, new SessionMap(session), loginId(session)));
	}

	// ── 상여관리 (조건) · 직원관리 상여 토글 ──

	@RequestMapping("/admin/bonus/openBonusList.do")
	public ModelAndView openBonusList() {
		return new ModelAndView("bo/deploy/bonus_list");
	}

	@RequestMapping(value = "/admin/bonus/bonusListData.do", method = RequestMethod.POST)
	public ModelAndView bonusListData(HttpSession session) {
		return run(() -> {
			SecretFilter.View v = secret.view(loginId(session));
			Map<String, Object> out = v.filterMap(bonusService.list(), "applies");
			if (!v.secret) {
				// 적용 인원도 보이는 사람만 센다
				@SuppressWarnings("unchecked")
				List<Map<String, Object>> applies = (List<Map<String, Object>>) out.get("applies");
				@SuppressWarnings("unchecked")
				List<Map<String, Object>> items = (List<Map<String, Object>>) out.get("items");
				items.forEach(b -> b.put("APPLY_CNT", applies.stream().filter(a -> String.valueOf(a.get("BONUS_SQ")).equals(String.valueOf(b.get("BONUS_SQ")))).count()));
			}
			return out;
		});
	}

	@RequestMapping(value = "/admin/bonus/saveBonusData.do", method = RequestMethod.POST)
	public ModelAndView saveBonusData(@RequestParam Map<String, Object> param, HttpSession session) {
		return run(() -> {
			bonusService.save(param, loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/bonus/useBonusData.do", method = RequestMethod.POST)
	public ModelAndView useBonusData(@RequestParam("BONUS_SQ") int bonusSq, @RequestParam("USE_YN") String use, HttpSession session) {
		return run(() -> {
			bonusService.setUse(bonusSq, "Y".equals(use), loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/bonus/deleteBonusData.do", method = RequestMethod.POST)
	public ModelAndView deleteBonusData(@RequestParam("BONUS_SQ") int bonusSq) {
		return run(() -> {
			bonusService.delete(bonusSq);
			return "OK";
		});
	}

	/** 직원관리 화면이 부른다. 상여관리 권한이 없으면 인터셉터가 막아 칩 열이 안 생긴다 */
	@RequestMapping(value = "/admin/bonus/staffBonusData.do", method = RequestMethod.POST)
	public ModelAndView staffBonusData(HttpSession session) {
		return run(() -> {
			SecretFilter.View v = secret.view(loginId(session));
			Map<String, Object> out = v.filterMap(bonusService.staffData(), "applies", "staff");
			@SuppressWarnings("unchecked")
			List<Map<String, Object>> plans = (List<Map<String, Object>>) out.get("plans");
			v.filter(plans, "PERSON_SQ");
			v.filter(plans, "RECIPIENT_SQ");
			return out;
		});
	}

	@RequestMapping(value = "/admin/bonus/applyBonusData.do", method = RequestMethod.POST)
	public ModelAndView applyBonusData(@RequestParam Map<String, Object> param, HttpSession session) {
		return run(() -> {
			SecretFilter.View v = secret.view(loginId(session));
			v.guard(param.get("STAFF_SQ"));
			v.guard(param.get("REFERRER_SQ"));
			bonusService.apply(param, loginId(session));
			return "OK";
		});
	}

	// ── 도움 ──

	private boolean canPay(String loginId) {
		return systemService.access(loginId).allows(PAY_PAGE);
	}

	/** 서비스가 세션을 Map 으로만 다루게 한다 */
	@SuppressWarnings("serial")
	private static class SessionMap extends java.util.AbstractMap<String, Object> {
		private final HttpSession session;

		SessionMap(HttpSession session) {
			this.session = session;
		}

		@Override
		public Object get(Object key) {
			return session.getAttribute(String.valueOf(key));
		}

		@Override
		public Object put(String key, Object value) {
			session.setAttribute(key, value);
			return null;
		}

		@Override
		public Object remove(Object key) {
			session.removeAttribute(String.valueOf(key));
			return null;
		}

		@Override
		public java.util.Set<Entry<String, Object>> entrySet() {
			return java.util.Collections.emptySet();
		}
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
			System.out.println("DEPLOY_ERROR " + e.getClass().getSimpleName() + " " + e.getMessage());
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
