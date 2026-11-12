package com.eep.bo.memo;

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

import com.eep.bo.deploy.service.SecretFilter;
import com.eep.mapper.BoMemoMapper;

/**
 * 목록 메모(쌓기만, 본인 것만 삭제). 화면마다 그 메뉴의 AUTH_PATTERN 에 걸리는 주소를 써서 권한 설정을 새로 하지 않는다.
 * 대상 구분(TARGET_CD)은 요청 값이 아니라 주소로 정한다.
 */
@Controller
public class BoMemoController {

	private static final Map<String, String> TARGET = new HashMap<>();
	static {
		TARGET.put("/admin/staff/", "STAFF");						// /admin/staff/**
		TARGET.put("/admin/hr/interview", "INTV");					// /admin/hr/*nterview*
		TARGET.put("/admin/hr/trainee", "TRAINEE");					// /admin/hr/*rainee*
		TARGET.put("/admin/equipment/equipment", "EQP");			// /admin/equipment/*quipment*
		TARGET.put("/admin/equipment/audit", "EQP");				// /admin/equipment/*udit* (전수조사 권한만 있어도 같은 장비 메모)
		TARGET.put("/admin/lab/team", "LAB_TEAM");					// /admin/lab/*eam*
	}

	@Autowired
	private BoMemoMapper mapper;

	@Autowired
	private SecretFilter secret;

	@RequestMapping(value = { "/admin/staff/memoListData.do", "/admin/hr/interviewMemoListData.do", "/admin/hr/traineeMemoListData.do",
			"/admin/equipment/equipmentMemoListData.do", "/admin/equipment/auditMemoListData.do", "/admin/lab/teamMemoListData.do" }, method = RequestMethod.POST)
	public ModelAndView memoListData(@RequestParam("TARGET_SQ") int targetSq, HttpServletRequest request, HttpSession session) {
		return run(() -> {
			Map<String, Object> q = key(request, session, targetSq);
			Map<String, Object> out = new HashMap<>();
			out.put("list", mapper.selectMemos(q));
			out.put("me", loginId(session));
			return out;
		});
	}

	@RequestMapping(value = { "/admin/staff/memoCountData.do", "/admin/hr/interviewMemoCountData.do", "/admin/hr/traineeMemoCountData.do",
			"/admin/equipment/equipmentMemoCountData.do", "/admin/lab/teamMemoCountData.do" }, method = RequestMethod.POST)
	public ModelAndView memoCountData(HttpServletRequest request, HttpSession session) {
		return run(() -> {
			Map<String, Object> q = new HashMap<>();
			q.put("TARGET_CD", target(request));
			List<Map<String, Object>> rows = mapper.selectMemoCounts(q);
			if ("STAFF".equals(q.get("TARGET_CD"))) {
				secret.view(loginId(session)).filter(rows, "TARGET_SQ");
			}
			Map<String, Object> out = new HashMap<>();
			rows.forEach(r -> out.put(String.valueOf(r.get("TARGET_SQ")), r.get("CNT")));
			return out;
		});
	}

	@RequestMapping(value = { "/admin/staff/saveMemoData.do", "/admin/hr/interviewSaveMemoData.do", "/admin/hr/traineeSaveMemoData.do",
			"/admin/equipment/equipmentSaveMemoData.do", "/admin/equipment/auditSaveMemoData.do", "/admin/lab/teamSaveMemoData.do" }, method = RequestMethod.POST)
	public ModelAndView saveMemoData(@RequestParam("TARGET_SQ") int targetSq, @RequestParam("CONTENT") String content, HttpServletRequest request, HttpSession session) {
		return run(() -> {
			Map<String, Object> q = key(request, session, targetSq);
			String c = content == null ? "" : content.trim();
			if (c.isEmpty() || c.length() > 2000) {
				throw new IllegalArgumentException("메모는 1~2000자로 입력해 주세요.");
			}
			q.put("CONTENT", c);
			q.put("EMPLY_ID", loginId(session));
			mapper.insertMemo(q);
			return "OK";
		});
	}

	@RequestMapping(value = { "/admin/staff/deleteMemoData.do", "/admin/hr/interviewDeleteMemoData.do", "/admin/hr/traineeDeleteMemoData.do",
			"/admin/equipment/equipmentDeleteMemoData.do", "/admin/equipment/auditDeleteMemoData.do", "/admin/lab/teamDeleteMemoData.do" }, method = RequestMethod.POST)
	public ModelAndView deleteMemoData(@RequestParam("MEMO_SQ") long memoSq, HttpServletRequest request, HttpSession session) {
		return run(() -> {
			Map<String, Object> q = new HashMap<>();
			q.put("MEMO_SQ", memoSq);
			q.put("TARGET_CD", target(request));
			if ("STAFF".equals(q.get("TARGET_CD"))) {
				secret.view(loginId(session)).guard(mapper.selectMemoTarget(q));
			}
			q.put("EMPLY_ID", loginId(session));
			if (mapper.deleteMemo(q) != 1) {
				throw new IllegalArgumentException("본인이 남긴 메모만 지울 수 있습니다.");
			}
			return "OK";
		});
	}

	private Map<String, Object> key(HttpServletRequest request, HttpSession session, int targetSq) {
		Map<String, Object> q = new HashMap<>();
		q.put("TARGET_CD", target(request));
		q.put("TARGET_SQ", targetSq);
		if ("STAFF".equals(q.get("TARGET_CD"))) {
			secret.view(loginId(session)).guard(targetSq);
		}
		return q;
	}

	private static String target(HttpServletRequest request) {
		String path = request.getServletPath();
		for (Map.Entry<String, String> e : TARGET.entrySet()) {
			if (path.startsWith(e.getKey())) {
				return e.getValue();
			}
		}
		throw new IllegalArgumentException("메모 대상을 찾지 못했습니다.");
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
			System.out.println("MEMO_ERROR " + e.getClass().getSimpleName() + " " + e.getMessage());
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
