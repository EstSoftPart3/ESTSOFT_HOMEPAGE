package com.eep.bo.feedback;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.system.service.BoSystemService;
import com.eep.mapper.BoFeedbackMapper;

/**
 * 피드백(/admin/feedback)·업데이트 내역(/admin/update). 두 메뉴는 모든 관리자에게 열린다(BoSystemService.OPEN_MENUS).
 * 진행·보류·반려는 슈퍼관리자·시스템 운영자만. 기획서·업데이트 내역은 Claude 가 DB 에 직접 넣는다(plans/feedback-spec.html).
 */
@Controller
public class BoFeedbackController {

	private static final List<String> KINDS = Arrays.asList("INCONV", "BUG", "NEW");
	private static final List<String> ACTS = Arrays.asList("ING", "HOLD", "REJECT");

	@Autowired
	private BoFeedbackMapper mapper;

	@Autowired
	private BoSystemService systemService;

	// ── 피드백 ──

	@RequestMapping("/admin/feedback/openFeedbackList.do")
	public ModelAndView openFeedbackList() {
		return new ModelAndView("bo/system/feedback_list");
	}

	@RequestMapping(value = "/admin/feedback/saveData.do", method = RequestMethod.POST)
	public ModelAndView saveData(@RequestParam Map<String, Object> p, HttpSession session) {
		return run(() -> {
			String content = str(p, "CONTENT");
			require(!content.isEmpty() && content.length() <= 4000, "내용을 1~4000자로 적어 주세요.");
			require(KINDS.contains(str(p, "KIND_CD")), "종류를 골라 주세요.");
			p.put("CONTENT", content);
			p.put("SCREEN_NM", cut(str(p, "SCREEN_NM"), 100));
			p.put("SCREEN_URL", cut(str(p, "SCREEN_URL"), 300));
			p.put("EMPLY_ID", loginId(session));
			mapper.insertFeedback(p);
			return "OK";
		});
	}

	/**
	 * 홈페이지(사용자 화면) 피드백. 로그인 안 한 사람도 보낸다: EMPLY_ID 'GUEST', 이름·이메일(선택)은 내용 앞줄에 붙인다.
	 * 도배 막기: 숨은 칸(HP)이 채워지면 버리고, IP 당 10분 5건·게스트 전체 하루 100건.
	 */
	@RequestMapping(value = "/eep/feedback/saveData.do", method = RequestMethod.POST)
	public ModelAndView foSaveData(@RequestParam Map<String, Object> p, HttpSession session, HttpServletRequest req) {
		return run(() -> {
			if (!str(p, "HP").isEmpty()) {
				return "OK"; // 봇: 받은 척만 한다
			}
			String content = str(p, "CONTENT");
			require(!content.isEmpty() && content.length() <= 4000, "내용을 1~4000자로 적어 주세요.");
			require(KINDS.contains(str(p, "KIND_CD")), "종류를 골라 주세요.");
			String id = foLoginId(session);
			if (id == null) {
				require(GUEST_LIMIT.allow(clientIp(req), System.currentTimeMillis()), "잠시 뒤 다시 보내 주세요.");
				String name = cut(str(p, "NAME"), 30), mail = cut(str(p, "MAIL"), 100);
				require(mail.isEmpty() || mail.matches("[^@\\s]+@[^@\\s]+\\.[^@\\s]+"), "이메일 형식을 확인해 주세요.");
				String who = (name.isEmpty() ? "이름 없음" : name) + (mail.isEmpty() ? "" : " · " + mail);
				content = "[게스트] " + who + "\n" + content;
				id = "GUEST";
			}
			p.put("CONTENT", cut(content, 4000));
			p.put("SCREEN_NM", cut("홈페이지 · " + str(p, "SCREEN_NM"), 100));
			p.put("SCREEN_URL", cut(str(p, "SCREEN_URL"), 300));
			p.put("EMPLY_ID", id);
			mapper.insertFeedback(p);
			return "OK";
		});
	}

	private static final GuestLimit GUEST_LIMIT = new GuestLimit();

	/** shortcut: 서버 메모리에만 세므로 재시작하면 초기화된다, 스팸이 늘면 DB·캡차로 바꾼다 */
	public static final class GuestLimit {
		private static final long WINDOW = 10 * 60 * 1000L, DAY = 24 * 60 * 60 * 1000L;
		private final Map<String, java.util.Deque<Long>> byIp = new HashMap<>();
		private final java.util.Deque<Long> all = new java.util.ArrayDeque<>();

		public synchronized boolean allow(String ip, long now) {
			while (!all.isEmpty() && now - all.peekFirst() >= DAY) {
				all.pollFirst();
			}
			byIp.values().removeIf(q -> { while (!q.isEmpty() && now - q.peekFirst() >= WINDOW) { q.pollFirst(); } return q.isEmpty(); });
			java.util.Deque<Long> q = byIp.computeIfAbsent(ip, k -> new java.util.ArrayDeque<>());
			if (q.size() >= 5 || all.size() >= 100) {
				return false;
			}
			q.addLast(now);
			all.addLast(now);
			return true;
		}
	}

	// cloudflared → nginx 를 거쳐 오므로 Cloudflare 가 붙인 실제 주소를 먼저 본다
	public static String clientIp(HttpServletRequest req) {
		String ip = req.getHeader("CF-Connecting-IP");
		if (ip == null || ip.isEmpty()) {
			String xff = req.getHeader("X-Forwarded-For");
			ip = xff == null || xff.isEmpty() ? req.getRemoteAddr() : xff.split(",")[0].trim();
		}
		return ip;
	}

	@SuppressWarnings("unchecked")
	private static String foLoginId(HttpSession session) {
		try {
			Map<String, Object> info = (Map<String, Object>) session.getAttribute("loginInfo");
			List<Map<String, Object>> list = (List<Map<String, Object>>) info.get("loginInfo");
			return (String) list.get(0).get("emplyId");
		} catch (RuntimeException e) {
			return null;
		}
	}

	/** 전체 목록. 화면이 '내 피드백'을 걸러 보인다. 기획서 HTML 은 상세에서만 */
	@RequestMapping(value = "/admin/feedback/listData.do", method = RequestMethod.POST)
	public ModelAndView listData(HttpSession session) {
		return run(() -> {
			Map<String, Object> out = new HashMap<>();
			out.put("list", mapper.selectFeedbacks());
			out.put("me", loginId(session));
			out.put("canAct", canAct(loginId(session)));
			return out;
		});
	}

	@RequestMapping(value = "/admin/feedback/detailData.do", method = RequestMethod.POST)
	public ModelAndView detailData(@RequestParam("FB_SQ") int fbSq) {
		return run(() -> mapper.selectFeedback(one("FB_SQ", fbSq)));
	}

	/** 진행(개발 반영 내용 필수)·보류·반려(사유 필수). 반영된 건은 바꾸지 않는다 */
	@RequestMapping(value = "/admin/feedback/actData.do", method = RequestMethod.POST)
	public ModelAndView actData(@RequestParam("FB_SQ") int fbSq, @RequestParam("STATUS_CD") String status, @RequestParam(value = "TEXT", defaultValue = "") String text, HttpSession session) {
		return run(() -> {
			String id = loginId(session);
			require(canAct(id), "슈퍼관리자·시스템 운영자만 처리할 수 있습니다.");
			require(ACTS.contains(status), "처리 값이 올바르지 않습니다.");
			String t = text.trim();
			require(!"ING".equals(status) || !t.isEmpty(), "개발 반영 내용을 적어 주세요.");
			require(!"REJECT".equals(status) || !t.isEmpty(), "반려 사유를 적어 주세요.");
			require(t.length() <= 4000, "4000자 이내로 적어 주세요.");
			Map<String, Object> q = one("FB_SQ", fbSq);
			q.put("STATUS_CD", status);
			q.put("DEV_NOTE", t);
			q.put("REJECT_REASON", t);
			q.put("ACT_EMPLY_ID", id);
			require(mapper.updateFeedbackAct(q) == 1, "이미 반영된 피드백입니다.");
			return "OK";
		});
	}

	/** 기획서 코멘트(슈퍼관리자·시스템 운영자, 요청자 본인): 로그에 쌓고 접수로 돌린다. 다음 처리(평일 9시 30분·11시·14시·16시) 때 코멘트까지 반영해 기획서를 다시 만든다 */
	@RequestMapping(value = "/admin/feedback/commentData.do", method = RequestMethod.POST)
	public ModelAndView commentData(@RequestParam("FB_SQ") int fbSq, @RequestParam(value = "CONTENT", defaultValue = "") String content, HttpSession session) {
		return run(() -> {
			String id = loginId(session);
			Map<String, Object> q = one("FB_SQ", fbSq);
			Map<String, Object> f = mapper.selectFeedback(q);
			require(f != null, "피드백을 찾지 못했습니다.");
			require(canAct(id) || id.equals(f.get("EMPLY_ID")), "요청자 본인·슈퍼관리자·시스템 운영자만 의견을 남길 수 있습니다.");
			String c = content.trim();
			require(!c.isEmpty() && c.length() <= 4000, "의견을 1~4000자로 적어 주세요.");
			q.put("CONTENT", c);
			q.put("EMPLY_ID", id);
			require(mapper.insertComment(q) > 0, "반영·반려된 피드백에는 코멘트를 남길 수 없습니다.");
			return "OK";
		});
	}

	@RequestMapping(value = "/admin/feedback/logData.do", method = RequestMethod.POST)
	public ModelAndView logData(@RequestParam("FB_SQ") int fbSq) {
		return run(() -> mapper.selectLogs(one("FB_SQ", fbSq)));
	}

	@RequestMapping(value = "/admin/feedback/logSpecData.do", method = RequestMethod.POST)
	public ModelAndView logSpecData(@RequestParam("LOG_SQ") int logSq) {
		return run(() -> mapper.selectLogSpec(one("LOG_SQ", logSq)));
	}

	/** 상단 버튼 숫자(상태가 바뀌었는데 안 본 내 피드백)와 최신 업데이트 번호(메뉴 N 표시) */
	@RequestMapping(value = "/admin/feedback/badgeData.do", method = RequestMethod.POST)
	public ModelAndView badgeData(HttpSession session) {
		return run(() -> {
			Map<String, Object> out = new HashMap<>();
			out.put("unseen", mapper.countUnseen(one("EMPLY_ID", loginId(session))));
			out.put("latestUpdate", mapper.selectLatestUpdate());
			return out;
		});
	}

	@RequestMapping(value = "/admin/feedback/seenData.do", method = RequestMethod.POST)
	public ModelAndView seenData(HttpSession session) {
		return run(() -> mapper.updateSeen(one("EMPLY_ID", loginId(session))));
	}

	// ── 업데이트 내역 ──

	@RequestMapping("/admin/update/openUpdateList.do")
	public ModelAndView openUpdateList() {
		return new ModelAndView("bo/system/update_list");
	}

	@RequestMapping(value = "/admin/update/listData.do", method = RequestMethod.POST)
	public ModelAndView updateListData() {
		return run(() -> mapper.selectUpdates(new HashMap<>()));
	}

	@RequestMapping(value = "/admin/update/detailData.do", method = RequestMethod.POST)
	public ModelAndView updateDetailData(@RequestParam("UPD_SQ") int updSq) {
		return run(() -> mapper.selectUpdate(one("UPD_SQ", updSq)));
	}

	// ── 도움 ──

	private boolean canAct(String id) {
		BoSystemService.Access a = systemService.access(id);
		return a.superUser || a.hasRole("SYS");
	}

	private static String str(Map<String, Object> p, String k) {
		Object v = p.get(k);
		return v == null ? "" : String.valueOf(v).trim();
	}

	private static String cut(String s, int n) {
		return s.length() > n ? s.substring(0, n) : s;
	}

	private static void require(boolean ok, String msg) {
		if (!ok) {
			throw new IllegalArgumentException(msg);
		}
	}

	private static Map<String, Object> one(String k, Object v) {
		Map<String, Object> m = new HashMap<>();
		m.put(k, v);
		return m;
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
			System.out.println("FEEDBACK_ERROR " + e.getClass().getSimpleName() + " " + e.getMessage());
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
