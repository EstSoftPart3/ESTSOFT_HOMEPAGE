package com.eep.bo.deploy.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.deploy.service.PayslipService;
import com.eep.bo.deploy.service.SecretFilter;

/**
 * 급여 - 급여명세서(/admin/payslip). 권한은 메뉴의 AUTH_PATTERN 으로 인터셉터가 막고,
 * 시크릿 직원은 급여관리와 같이 시크릿 계정에게만 보이고 그 밖의 요청은 거부한다.
 */
@Controller
public class BoPayslipController {

	@Autowired
	private PayslipService service;

	@Autowired
	private SecretFilter secret;

	@RequestMapping("/admin/payslip/openPayslipList.do")
	public ModelAndView openPayslipList() {
		return new ModelAndView("bo/deploy/payslip_list");
	}

	@RequestMapping(value = "/admin/payslip/listData.do", method = RequestMethod.POST)
	public ModelAndView listData(@RequestParam("YM") String ym, HttpSession session) {
		return run(() -> {
			SecretFilter.View v = secret.view(loginId(session));
			Map<String, Object> out = v.filterMap(service.list(ym), "rows");
			out.put("secretViewer", v.secret);
			return out;
		});
	}

	/** 미리보기: 암호 없는 PDF 를 브라우저에서 바로 본다 */
	@RequestMapping(value = "/admin/payslip/preview.do", method = RequestMethod.GET)
	public void preview(@RequestParam("YM") String ym, @RequestParam("STAFF_SQ") int staffSq, HttpSession session, HttpServletResponse response) throws IOException {
		try {
			secret.view(loginId(session)).guard(staffSq);
			Map<String, Object> slip = service.slip(ym, staffSq);
			write(response, service.pdf(slip, false), "application/pdf", "inline", PayslipService.fileName(slip));
		} catch (IllegalArgumentException e) {
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
		}
	}

	/** 고른 사람들의 암호 걸린 PDF 묶음 */
	@RequestMapping(value = "/admin/payslip/zip.do", method = RequestMethod.POST)
	public void zip(@RequestParam("YM") String ym, @RequestParam("STAFF_SQ") String staffSqs, HttpSession session, HttpServletResponse response) throws IOException {
		try {
			SecretFilter.View v = secret.view(loginId(session));
			List<String> sqs = new ArrayList<>(Arrays.asList(staffSqs.split(",")));
			sqs.removeIf(s -> !s.matches("\\d+"));
			sqs.forEach(v::guard);
			write(response, service.zip(ym, sqs), "application/zip", "attachment", Integer.parseInt(ym.substring(5)) + "월 급여명세서.zip");
		} catch (IllegalArgumentException e) {
			response.setContentType("text/plain; charset=UTF-8");
			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			response.getWriter().write(e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/payslip/sendData.do", method = RequestMethod.POST)
	public ModelAndView sendData(@RequestParam("YM") String ym, @RequestParam("STAFF_SQ") int staffSq, HttpServletRequest request, HttpSession session) {
		return run(() -> {
			secret.view(loginId(session)).guard(staffSq);
			return service.send(ym, staffSq, baseUrl(request), loginId(session));
		});
	}

	@RequestMapping(value = "/admin/payslip/logData.do", method = RequestMethod.POST)
	public ModelAndView logData(@RequestParam("YM") String ym, @RequestParam("STAFF_SQ") int staffSq, HttpSession session) {
		return run(() -> {
			secret.view(loginId(session)).guard(staffSq);
			return service.logs(ym, staffSq);
		});
	}

	// ── 보내는 메일 설정 ──

	@RequestMapping(value = "/admin/payslip/confData.do", method = RequestMethod.POST)
	public ModelAndView confData() {
		return run(() -> service.conf());
	}

	@RequestMapping(value = "/admin/payslip/saveAccountData.do", method = RequestMethod.POST)
	public ModelAndView saveAccountData(@RequestParam Map<String, Object> param, HttpSession session) {
		return run(() -> {
			service.saveAccount(param, loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/payslip/verifyData.do", method = RequestMethod.POST)
	public ModelAndView verifyData(HttpSession session) {
		return run(() -> {
			service.verify(loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/payslip/saveBodyData.do", method = RequestMethod.POST)
	public ModelAndView saveBodyData(@RequestParam("SUBJECT") String subject, @RequestParam("BODY") String body, HttpSession session) {
		return run(() -> {
			service.saveBody(subject, body, loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/payslip/bodyVersionData.do", method = RequestMethod.POST)
	public ModelAndView bodyVersionData(@RequestParam("HIST_SQ") long histSq) {
		return run(() -> service.bodyVersion(histSq));
	}

	@RequestMapping(value = "/admin/payslip/revertBodyData.do", method = RequestMethod.POST)
	public ModelAndView revertBodyData(@RequestParam("HIST_SQ") long histSq, HttpSession session) {
		return run(() -> {
			service.revertBody(histSq, loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/payslip/testSendData.do", method = RequestMethod.POST)
	public ModelAndView testSendData(@RequestParam(value = "SUBJECT", defaultValue = "") String subject, @RequestParam(value = "BODY", defaultValue = "") String body,
			HttpServletRequest request, HttpSession session) {
		return run(() -> service.testSend(subject, body, baseUrl(request), loginId(session)));
	}

	// ── 세무서 자료 ──

	/** 그해 1월~YM 급여 엑셀. 시크릿 직원은 시크릿 계정이 받을 때만 들어간다 */
	@RequestMapping(value = "/admin/payslip/taxExcel.do", method = RequestMethod.GET)
	public void taxExcel(@RequestParam("YM") String ym, HttpSession session, HttpServletResponse response) throws IOException {
		try {
			SecretFilter.View v = secret.view(loginId(session));
			write(response, service.taxExcel(ym, v::hides), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "attachment", PayslipService.taxFileName(ym));
		} catch (IllegalArgumentException | java.time.format.DateTimeParseException e) {
			response.setContentType("text/plain; charset=UTF-8");
			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			response.getWriter().write(e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/payslip/taxConfData.do", method = RequestMethod.POST)
	public ModelAndView taxConfData() {
		return run(() -> service.taxConf());
	}

	@RequestMapping(value = "/admin/payslip/saveTaxConfData.do", method = RequestMethod.POST)
	public ModelAndView saveTaxConfData(@RequestParam("TO_ADDR") String to, @RequestParam("SUBJECT") String subject, @RequestParam("BODY") String body, HttpSession session) {
		return run(() -> {
			service.saveTaxConf(to, subject, body, loginId(session));
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/payslip/sendTaxData.do", method = RequestMethod.POST)
	public ModelAndView sendTaxData(@RequestParam("YM") String ym, HttpServletRequest request, HttpSession session) {
		return run(() -> {
			SecretFilter.View v = secret.view(loginId(session));
			return service.sendTax(ym, baseUrl(request), loginId(session), v::hides);
		});
	}

	// ── 도움 ──

	/** 메일 본문의 사이트 안 주소를 전체 주소로 바꿀 때 쓴다. 프록시 뒤라 전달된 머리말을 먼저 본다 */
	private static String baseUrl(HttpServletRequest request) {
		String proto = request.getHeader("X-Forwarded-Proto"), host = request.getHeader("X-Forwarded-Host");
		return (proto == null ? request.getScheme() : proto.split(",")[0].trim()) + "://" + (host == null ? request.getHeader("Host") : host.split(",")[0].trim());
	}

	private static void write(HttpServletResponse response, byte[] data, String type, String disposition, String name) throws IOException {
		response.setContentType(type);
		response.setHeader("X-Content-Type-Options", "nosniff");
		response.setHeader("Cache-Control", "no-store");
		response.setHeader("Content-Disposition", disposition + "; filename*=UTF-8''" + URLEncoder.encode(name, "UTF-8").replace("+", "%20"));
		response.setContentLength(data.length);
		response.getOutputStream().write(data);
	}

	private interface Call {
		Object run() throws Exception;
	}

	private static ModelAndView run(Call call) {
		ModelAndView mv = new ModelAndView("jsonView");
		try {
			mv.addObject("result", call.run());
		} catch (IllegalArgumentException e) {
			mv.addObject("error", e.getMessage());
		} catch (Exception e) {
			System.out.println("PAYSLIP_ERROR " + e.getClass().getSimpleName());
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
