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

import com.eep.bo.deploy.service.BoDeployService;
import com.eep.bo.deploy.service.BoPayrollService;
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

	// ── 투입현황 ──

	@RequestMapping("/admin/deploy/openDeployList.do")
	public ModelAndView openDeployList() {
		return new ModelAndView("bo/deploy/deploy_list");
	}

	@RequestMapping(value = "/admin/deploy/deployListData.do", method = RequestMethod.POST)
	public ModelAndView deployListData(HttpSession session) {
		String id = loginId(session);
		Map<String, Object> out = deployService.deployList(canPay(id));
		out.putAll(deployService.options(id));
		return json("data", out);
	}

	@RequestMapping(value = "/admin/deploy/saveDeployData.do", method = RequestMethod.POST)
	public ModelAndView saveDeployData(@RequestParam Map<String, Object> param, HttpSession session) {
		return run(() -> {
			param.put("UPDT_EMPLY_ID", loginId(session));
			deployService.saveDeploy(param, canPay(loginId(session)));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/deploy/deleteDeployData.do", method = RequestMethod.POST)
	public ModelAndView deleteDeployData(@RequestParam Map<String, Object> param) {
		return run(() -> {
			deployService.deleteDeploy(param);
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/deploy/extendDeployData.do", method = RequestMethod.POST)
	public ModelAndView extendDeployData(@RequestParam Map<String, Object> param, HttpSession session) {
		return run(() -> {
			param.put("UPDT_EMPLY_ID", loginId(session));
			deployService.extendDeploy(param, canPay(loginId(session)));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/deploy/projectHistoryData.do", method = RequestMethod.POST)
	public ModelAndView projectHistoryData(@RequestParam("STAFF_SQ") int staffSq, HttpSession session) {
		return run(() -> deployService.projectHistory(staffSq, canPay(loginId(session))));
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
		return run(() -> {
			String remove = String.valueOf(param.getOrDefault("REMOVE", ""));
			param.remove("REMOVE");
			param.put("UPDT_EMPLY_ID", loginId(session));
			Map<String, Map<String, Object>> files = new HashMap<>();
			for (Map.Entry<String, MultipartFile> e : request.getFileMap().entrySet()) {
				MultipartFile f = e.getValue();
				if (!f.isEmpty()) {
					Map<String, Object> m = new HashMap<>();
					m.put("FILE_NM", f.getOriginalFilename());
					m.put("FILE_TYPE", f.getContentType());
					m.put("FILE_DATA", f.getBytes());
					files.put(e.getKey(), m);
				}
			}
			deployService.savePartner(param, files, remove.isEmpty() ? new ArrayList<>() : Arrays.asList(remove.split(",")));
			return "OK";
		});
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
		return run(() -> deployService.readDoc(file.getOriginalFilename(), file.getContentType(), file.getBytes(), kind));
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
	public ModelAndView monthData(@RequestParam(value = "YM", required = false) String ym) {
		return run(() -> payrollService.month(ym == null || ym.isEmpty() ? YearMonth.now().toString() : ym));
	}

	@RequestMapping(value = "/admin/pay/staffYearData.do", method = RequestMethod.POST)
	public ModelAndView staffYearData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("YEAR") String year) {
		return run(() -> payrollService.staffYear(staffSq, year));
	}

	@RequestMapping(value = "/admin/pay/deployHistoryData.do", method = RequestMethod.POST)
	public ModelAndView deployHistoryData(@RequestParam("STAFF_SQ") int staffSq, @RequestParam("DEPLOY_SQ") int deploySq) {
		return run(() -> payrollService.deployHistory(staffSq, deploySq));
	}

	@RequestMapping(value = "/admin/pay/saveFieldData.do", method = RequestMethod.POST)
	public ModelAndView saveFieldData(@RequestParam Map<String, Object> param, HttpSession session) {
		return run(() -> {
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
					data.add(f.getBytes());
				}
			}
			return payrollService.importPreview(ym, data, new SessionMap(session));
		});
	}

	@RequestMapping(value = "/admin/pay/importApplyData.do", method = RequestMethod.POST)
	public ModelAndView importApplyData(@RequestParam Map<String, Object> param, HttpSession session) {
		return run(() -> payrollService.importApply(String.valueOf(param.get("YM")), param, new SessionMap(session), loginId(session)));
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
