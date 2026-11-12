package com.eep.bo.card.controller;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
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

	@RequestMapping(value = "/admin/card/compareData.do", method = RequestMethod.POST)
	public ModelAndView compareData(@RequestParam("CARD_SQ") int cardSq, @RequestParam("YM") String ym, @RequestParam("file") MultipartFile file, HttpSession session) {
		return call(() -> service.compare(cardSq, ym, file.getBytes(), loginId(session)));
	}

	@RequestMapping(value = "/admin/card/confirmSettleData.do", method = RequestMethod.POST)
	public ModelAndView confirmSettleData(@RequestParam("CARD_SQ") int cardSq, @RequestParam("YM") String ym, @RequestParam(value = "FILE_NM", required = false) String fileNm,
			@RequestParam("EXCEL_CNT") int excelCnt, HttpServletRequest req, HttpSession session) {
		// String[] 로 받으면 값이 하나일 때 쉼표로 쪼개져 "(주)가, 나" 같은 가맹점이 깨지므로 그대로 읽는다
		return call(() -> { service.confirm(cardSq, ym, fileNm, excelCnt, req.getParameterValues("USE_SQ"), req.getParameterValues("MERCHANT"),
				req.getParameterValues("NEW_DT"), req.getParameterValues("NEW_AMT"), req.getParameterValues("NEW_CD"), req.getParameterValues("NEW_MERCHANT"), loginId(session)); return "OK"; });
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
