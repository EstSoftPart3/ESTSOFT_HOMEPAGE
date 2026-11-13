package com.eep.bo.deploy.controller;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.deploy.service.BoTradeService;
import com.eep.bo.deploy.service.SecretFilter;

/**
 * 영업 > 업체 - 매출관리(/admin/trade/sale/**), 매입관리(/admin/trade/buy/**). 화면은 하나이고 주소의 sale·buy 로 메뉴 권한이 갈린다.
 * 투입 건은 직원 행이라 시크릿 직원을 입구에서 걸러 낸다
 */
@Controller
public class BoTradeController {

	@Autowired
	private BoTradeService service;
	@Autowired
	private SecretFilter secret;

	@RequestMapping("/admin/trade/openSaleList.do")
	public ModelAndView openSaleList() {
		return new ModelAndView("bo/deploy/trade_list").addObject("kind", "SALE");
	}

	@RequestMapping("/admin/trade/openBuyList.do")
	public ModelAndView openBuyList() {
		return new ModelAndView("bo/deploy/trade_list").addObject("kind", "BUY");
	}

	/** 매출·매입 현황: 투입·매출·매입·급여·손익을 한 줄에. 투입·급여 데이터는 그 화면들의 주소를 그대로 부른다 */
	@RequestMapping("/admin/trade/openAllList.do")
	public ModelAndView openAllList() {
		return new ModelAndView("bo/deploy/trade_all");
	}

	/** 세금계산서: 매출 건의 묶음·발급 표시만 */
	@RequestMapping("/admin/trade/openInvoiceList.do")
	public ModelAndView openInvoiceList() {
		return new ModelAndView("bo/deploy/trade_list").addObject("kind", "SALE").addObject("invoiceOnly", true);
	}

	/** 매출·매입 마감·해제(급여 마감과 따로) */
	@RequestMapping(value = "/admin/trade/all/closeData.do", method = RequestMethod.POST)
	public ModelAndView closeData(@RequestParam("YM") String ym, @RequestParam("CLOSE") boolean close, HttpSession session) {
		return run(() -> { service.setClosed(ym, close, loginId(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/trade/{kind}/listData.do", method = RequestMethod.POST)
	public ModelAndView listData(@PathVariable("kind") String kind, @RequestParam("YM") String ym, HttpSession session) {
		return run(() -> {
			String k = BoTradeService.kind(kind);
			Map<String, Object> out = new HashMap<>(service.options(k));
			out.put("closed", service.closed(ym));
			out.put("lines", visible(k, ym, session));
			return out;
		});
	}

	@RequestMapping(value = "/admin/trade/{kind}/saveData.do", method = RequestMethod.POST)
	public ModelAndView saveData(@PathVariable("kind") String kind, @RequestParam Map<String, Object> param, HttpSession session) {
		return run(() -> { service.saveTrade(BoTradeService.kind(kind), param, loginId(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/trade/{kind}/deleteData.do", method = RequestMethod.POST)
	public ModelAndView deleteData(@PathVariable("kind") String kind, @RequestParam("TRADE_SQ") int tradeSq) {
		return run(() -> { service.deleteTrade(BoTradeService.kind(kind), tradeSq); return "OK"; });
	}

	@RequestMapping(value = "/admin/trade/{kind}/amountData.do", method = RequestMethod.POST)
	public ModelAndView amountData(@PathVariable("kind") String kind, @RequestParam("YM") String ym, @RequestParam("KEY") String key,
			@RequestParam(value = "AMT", defaultValue = "") String amt, HttpSession session) {
		return run(() -> { String k = BoTradeService.kind(kind); service.setAmount(k, ym, key, amt, keys(k, ym, session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/trade/{kind}/layoutData.do", method = RequestMethod.POST)
	public ModelAndView layoutData(@PathVariable("kind") String kind, @RequestParam("YM") String ym, @RequestParam(value = "ITEM", required = false) String[] items, HttpSession session) {
		return run(() -> { String k = BoTradeService.kind(kind); service.saveLayout(k, ym, items, keys(k, ym, session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/trade/{kind}/issueData.do", method = RequestMethod.POST)
	public ModelAndView issueData(@PathVariable("kind") String kind, @RequestParam("YM") String ym, @RequestParam("KEY") String[] keys,
			@RequestParam("ON") String on, HttpSession session) {
		return run(() -> { String k = BoTradeService.kind(kind); service.issue(k, ym, keys, "Y".equals(on), keys(k, ym, session)); return "OK"; });
	}

	/** 그 달 엑셀. 화면과 같은 건(시크릿 직원 제외)을 계산서 엑셀 칸 배치로 내려 준다 */
	@RequestMapping(value = "/admin/trade/{kind}/excel.do", method = RequestMethod.GET)
	public void excel(@PathVariable("kind") String kind, @RequestParam("YM") String ym, HttpSession session, javax.servlet.http.HttpServletResponse res) throws java.io.IOException {
		byte[] file;
		String k;
		try {
			k = BoTradeService.kind(kind);
			file = com.eep.bo.deploy.service.TradeExcel.build(k, ym, visible(k, ym, session));
		} catch (IllegalArgumentException e) {
			res.sendError(400);
			return;
		}
		String name = java.net.URLEncoder.encode("이에스티_" + ym + "_" + ("SALE".equals(k) ? "매출" : "매입") + "_계산서.xlsx", "UTF-8").replace("+", "%20");
		res.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
		res.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + name);
		res.setContentLength(file.length);
		res.getOutputStream().write(file);
	}

	private List<Map<String, Object>> visible(String kind, String ym, HttpSession session) {
		return secret.view(loginId(session)).filter(service.lines(kind, ym));
	}

	private Set<String> keys(String kind, String ym, HttpSession session) {
		Set<String> keys = new HashSet<>();
		for (Map<String, Object> l : visible(kind, ym, session)) keys.add(String.valueOf(l.get("KEY")));
		return keys;
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
			System.out.println("TRADE_ERROR " + e.getClass().getSimpleName());
			mv.addObject("error", "처리하지 못했습니다. (" + e.getClass().getSimpleName() + ")");
		}
		return mv;
	}

	@SuppressWarnings("unchecked")
	private static String loginId(HttpSession session) {
		Map<String, Object> info = (Map<String, Object>) session.getAttribute("loginInfo");
		return (String) ((List<Map<String, Object>>) info.get("loginInfo")).get(0).get("emplyId");
	}
}
