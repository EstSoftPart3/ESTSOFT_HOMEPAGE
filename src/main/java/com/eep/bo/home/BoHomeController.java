package com.eep.bo.home;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.deploy.service.SecretFilter;
import com.eep.bo.system.service.BoSystemService;
import com.eep.bo.system.service.BoSystemService.Access;
import com.eep.mapper.BoLabMapper;
import com.eep.mapper.BoMemoMapper;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * 관리자 홈 대시보드(로그인 뒤·로고·관리자 전환의 진입점).
 * 카드마다 그 카드가 읽는 데이터 주소를 인터셉터와 같은 규칙(Access.allows)으로 검사해, 열 수 있는 카드만 화면에 알린다.
 * 카드 숫자는 화면이 기존 목록 주소를 그대로 불러 계산하고, 메모·결재 차례만 여기서 읽어 넣는다.
 */
@Controller
public class BoHomeController {

	// 카드 → 그 카드가 부르는 데이터 주소
	private static final Map<String, String> CARDS = new LinkedHashMap<>();
	// 메모 대상 → 그 메모 창 주소(BoMemoController·투입 메모)
	private static final Map<String, String> MEMOS = new LinkedHashMap<>();
	static {
		CARDS.put("STAFF", "/admin/staff/staffListData.do");
		CARDS.put("DEPLOY", "/admin/deploy/deployListData.do");
		CARDS.put("INTV", "/admin/hr/interviewListData.do");
		CARDS.put("TRAINEE", "/admin/hr/traineeListData.do");
		CARDS.put("PAY", "/admin/pay/monthData.do");
		CARDS.put("JOURNAL", "/admin/lab/journalDetailData.do");
		CARDS.put("EQP", "/admin/equipment/equipmentListData.do");
		CARDS.put("MEMBER", "/admin/member/memberListData.do");
		MEMOS.put("STAFF", "/admin/staff/memoListData.do");
		MEMOS.put("INTV", "/admin/hr/interviewMemoListData.do");
		MEMOS.put("TRAINEE", "/admin/hr/traineeMemoListData.do");
		MEMOS.put("EQP", "/admin/equipment/equipmentMemoListData.do");
		MEMOS.put("LAB_TEAM", "/admin/lab/teamMemoListData.do");
		MEMOS.put("DEPLOY", "/admin/deploy/memoListData.do");
	}

	@Autowired
	private BoSystemService systemService;

	@Autowired
	private BoMemoMapper memoMapper;

	@Autowired
	private BoLabMapper labMapper;

	@Autowired
	private SecretFilter secret;

	@RequestMapping(BoSystemService.HOME)
	public ModelAndView home(HttpSession session) throws Exception {
		String id = loginId(session);
		Access access = systemService.access(id);
		List<String> cards = new ArrayList<>();
		CARDS.forEach((k, url) -> { if (access.allows(url)) cards.add(k); });
		List<String> targets = new ArrayList<>();
		MEMOS.forEach((k, url) -> { if (access.allows(url)) targets.add(k); });
		if (cards.isEmpty() && targets.isEmpty()) {
			// 볼 카드가 없으면 예전처럼 권한 있는 첫 메뉴로
			String url = access.firstUrl();
			return new ModelAndView(url != null ? "redirect:" + url : "bo/system/no_access");
		}

		Map<String, Object> data = new HashMap<>();
		data.put("cards", cards);
		data.put("journals", cards.contains("JOURNAL") ? labMapper.selectMyApprovals(one("EMPLY_ID", id)) : new ArrayList<>());
		List<Map<String, Object>> memos = new ArrayList<>();
		if (!targets.isEmpty()) {
			Map<String, Object> q = new HashMap<>();
			boolean deploy = targets.remove("DEPLOY");
			q.put("DEPLOY", deploy);
			q.put("TARGETS", targets.isEmpty() ? java.util.Collections.singletonList("-") : targets);
			memos = memoMapper.selectRecentMemos(q);
			// 시크릿 직원 메모는 시크릿 계정에게만(직원·투입 메모)
			SecretFilter.View v = secret.view(id);
			memos.removeIf(m -> ("STAFF".equals(m.get("TARGET_CD")) || "DEPLOY".equals(m.get("TARGET_CD"))) && v.hides(m.get("TARGET_SQ")));
			if (memos.size() > 8) memos = new ArrayList<>(memos.subList(0, 8));
		}
		data.put("memos", memos);
		ModelAndView mv = new ModelAndView("bo/home/home");
		// <script> 안에 넣으므로 </ 를 끊는다
		mv.addObject("homeJson", new ObjectMapper().writeValueAsString(data).replace("</", "<\\/"));
		return mv;
	}

	private static Map<String, Object> one(String k, Object v) {
		Map<String, Object> m = new HashMap<>();
		m.put(k, v);
		return m;
	}

	@SuppressWarnings("unchecked")
	private static String loginId(HttpSession session) {
		Map<String, Object> info = (Map<String, Object>) session.getAttribute("loginInfo");
		List<Map<String, Object>> list = (List<Map<String, Object>>) info.get("loginInfo");
		return (String) list.get(0).get("emplyId");
	}
}
