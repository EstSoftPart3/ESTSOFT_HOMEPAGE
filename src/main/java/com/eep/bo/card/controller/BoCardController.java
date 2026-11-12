package com.eep.bo.card.controller;

import java.io.IOException;
import java.net.URLEncoder;
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
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.card.service.BoCardService;

/** 경영지원 - 법인카드. 권한은 /admin/** 인터셉터(메뉴 K00001 의 /admin/card/**)가 맡고 쓰기는 POST 만 받는다 */
@Controller
public class BoCardController {

	@Autowired
	private BoCardService service;

	@RequestMapping("/admin/card/openCardList.do")
	public String openCardList() {
		return "bo/card/card_list";
	}

	@RequestMapping(value = "/admin/card/cardListData.do", method = RequestMethod.POST)
	public ModelAndView cardListData(HttpSession session) {
		return call(() -> service.cards(loginId(session)));
	}

	@RequestMapping(value = "/admin/card/saveCardData.do", method = RequestMethod.POST)
	public ModelAndView saveCardData(@RequestParam Map<String, Object> param, HttpSession session) {
		return call(() -> service.saveCard(param, loginId(session)));
	}

	@RequestMapping(value = "/admin/card/monthUseData.do", method = RequestMethod.POST)
	public ModelAndView monthUseData(@RequestParam("CARD_SQ") int cardSq, @RequestParam("YM") String ym, HttpSession session) {
		return call(() -> service.month(cardSq, ym, loginId(session)));
	}

	@RequestMapping(value = "/admin/card/saveUseData.do", method = RequestMethod.POST)
	public ModelAndView saveUseData(@RequestParam Map<String, Object> param, HttpSession session) {
		return call(() -> { service.saveUse(param, loginId(session)); return "OK"; });
	}

	@RequestMapping(value = "/admin/card/deleteUseData.do", method = RequestMethod.POST)
	public ModelAndView deleteUseData(@RequestParam("CARD_SQ") int cardSq, @RequestParam("USE_SQ") int useSq, HttpSession session) {
		return call(() -> { service.deleteUse(cardSq, useSq, loginId(session)); return "OK"; });
	}

	/** 정산 기간 목록. 카드사 엑셀(file)은 있으면 대조한다 */
	@RequestMapping(value = "/admin/card/periodData.do", method = RequestMethod.POST)
	public ModelAndView periodData(@RequestParam("CARD_SQ") int cardSq, @RequestParam("FROM") String from, @RequestParam("TO") String to,
			@RequestParam(value = "file", required = false) MultipartFile file, HttpSession session) {
		return call(() -> service.period(cardSq, from, to, file == null ? null : file.getBytes(), loginId(session)));
	}

	/** 중간 저장(CLOSE=N)과 마감(CLOSE=Y). 배열은 String[] 로 받으면 값이 하나일 때 쉼표로 쪼개지므로 그대로 읽는다 */
	@RequestMapping(value = "/admin/card/savePeriodData.do", method = RequestMethod.POST)
	public ModelAndView savePeriodData(@RequestParam("CARD_SQ") int cardSq, @RequestParam("FROM") String from, @RequestParam("TO") String to,
			@RequestParam("CLOSE") String close, HttpServletRequest req, HttpSession session) {
		return call(() -> service.savePeriod(cardSq, from, to, "Y".equals(close), req.getParameterMap(), loginId(session)));
	}

	@RequestMapping(value = "/admin/card/closedData.do", method = RequestMethod.POST)
	public ModelAndView closedData(@RequestParam("CARD_SQ") int cardSq, @RequestParam("FROM") String from, @RequestParam("TO") String to, HttpSession session) {
		return call(() -> service.closed(cardSq, from, to, loginId(session)));
	}

	@RequestMapping(value = "/admin/card/reopenData.do", method = RequestMethod.POST)
	public ModelAndView reopenData(@RequestParam("CARD_SQ") int cardSq, @RequestParam("FROM") String from, @RequestParam("TO") String to, HttpSession session) {
		return call(() -> service.reopen(cardSq, from, to, loginId(session)));
	}

	@RequestMapping(value = "/admin/card/closedExcel.do", method = RequestMethod.POST)
	public void closedExcel(@RequestParam("CARD_SQ") int cardSq, @RequestParam("FROM") String from, @RequestParam("TO") String to, @RequestParam("NAME") String name,
			HttpSession session, HttpServletResponse res) throws IOException {
		byte[] x;
		try {
			x = service.closedExcel(cardSq, from, to, loginId(session));
		} catch (IllegalArgumentException e) {
			res.setContentType("text/plain;charset=UTF-8");
			res.setStatus(400);
			res.getWriter().write(e.getMessage());
			return;
		}
		String file = URLEncoder.encode(name.replaceAll("[\\\\/:*?\"<>|]", "_") + ".xlsx", "UTF-8").replace("+", "%20");
		res.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
		res.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + file);
		res.setContentLength(x.length);
		res.getOutputStream().write(x);
	}

	private interface Call {
		Object run() throws Exception;
	}

	private static ModelAndView call(Call call) {
		ModelAndView mv = new ModelAndView("jsonView");
		try {
			mv.addObject("result", call.run());
		} catch (IllegalArgumentException e) {
			mv.addObject("error", e.getMessage());
		} catch (Exception e) {
			System.out.println("CARD_ERROR " + e.getClass().getSimpleName());
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
