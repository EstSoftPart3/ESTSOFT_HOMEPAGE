package com.eep.bo.calendar.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.eep.bo.calendar.dao.BoCalendarDao;

@Service
public class BoCalendarServiceImpl implements BoCalendarService {

	/** 분류 코드 -> 화면 이름. 순서대로 화면에 나온다 */
	public static final Map<String, String> CATEGORIES;
	/** 면접정보(INTERVIEW)의 세부 구분 */
	public static final Map<String, String> SUB_CATEGORIES;
	static {
		Map<String, String> c = new LinkedHashMap<>();
		c.put("RECRUIT", "모집정보");
		c.put("INTERVIEW", "면접정보");
		c.put("ATTEND", "출근정보");
		c.put("DEPLOY", "투입정보");
		c.put("PERSONAL", "개인 업무");
		c.put("ETC", "기타");
		CATEGORIES = Collections.unmodifiableMap(c);

		Map<String, String> s = new LinkedHashMap<>();
		s.put("NEW", "신입");
		s.put("EXP", "경력");
		SUB_CATEGORIES = Collections.unmodifiableMap(s);
	}

	public static final String CONF_CLIENT_ID = "GOOGLE_CLIENT_ID";
	public static final String CONF_CLIENT_SECRET = "GOOGLE_CLIENT_SECRET";

	@Autowired
	BoCalendarDao BoCalendarDao;

	@Override
	public Map<String, String> ConfMap() {
		return BoCalendarDao.ConfMap();
	}

	@Override
	public void ConfSave(String clientId, String clientSecret) {
		BoCalendarDao.ConfSave(CONF_CLIENT_ID, clientId.trim());
		// 시크릿을 비워 두면 기존 값을 유지한다(화면에 다시 보여주지 않으므로)
		if (clientSecret != null && !clientSecret.trim().isEmpty()) {
			BoCalendarDao.ConfSave(CONF_CLIENT_SECRET, clientSecret.trim());
		}
	}

	@Override
	public List<Map<String, Object>> FetchToTmp(String emplyId, List<Map<String, Object>> events) {
		List<Map<String, Object>> rules = BoCalendarDao.RuleList();
		for (Map<String, Object> e : events) {
			String[] cate = classify((String) e.get("EVT_TITLE"), rules);
			e.put("CATE_CD", cate[0]);
			e.put("SUB_CATE_CD", cate[1]);
		}
		BoCalendarDao.TmpReplace(emplyId, events);
		return BoCalendarDao.TmpList(emplyId);
	}

	/**
	 * 제목으로 1차 분류. 규칙은 우선순위 순으로 와야 하고 처음 맞는 규칙을 쓴다.
	 * 키워드의 '+' 는 모든 단어가 있어야 맞는 것이고, 공백·대소문자는 무시한다.
	 * @return {CATE_CD, SUB_CATE_CD}, 맞는 규칙이 없으면 {ETC, null}
	 */
	public static String[] classify(String title, List<Map<String, Object>> rules) {
		String t = normalize(title);
		for (Map<String, Object> rule : rules) {
			boolean match = true;
			for (String word : ((String) rule.get("KEYWORD")).split("\\+")) {
				String w = normalize(word);
				if (!w.isEmpty() && !t.contains(w)) {
					match = false;
					break;
				}
			}
			if (match) {
				return new String[] { (String) rule.get("CATE_CD"), (String) rule.get("SUB_CATE_CD") };
			}
		}
		return new String[] { "ETC", null };
	}

	private static String normalize(String s) {
		return s == null ? "" : s.replaceAll("\\s+", "").toLowerCase();
	}

	@Override
	public List<Map<String, Object>> TmpList(String emplyId) {
		return BoCalendarDao.TmpList(emplyId);
	}

	@Override
	public int Confirm(String emplyId, List<Map<String, Object>> items) {
		List<Object> sqList = new ArrayList<>();
		for (Map<String, Object> item : items) {
			String cate = (String) item.get("CATE_CD");
			if (!CATEGORIES.containsKey(cate)) {
				throw new IllegalArgumentException("알 수 없는 분류: " + cate);
			}
			String sub = (String) item.get("SUB_CATE_CD");
			// 세부 구분은 면접정보에만 있다
			if (!"INTERVIEW".equals(cate) || !SUB_CATEGORIES.containsKey(sub)) {
				sub = null;
			}
			item.put("SUB_CATE_CD", sub);
			item.put("REG_EMPLY_ID", emplyId);
			BoCalendarDao.TmpCateUpdate(item);
			sqList.add(item.get("EVT_TMP_SQ"));
		}
		return sqList.isEmpty() ? 0 : BoCalendarDao.TmpConfirm(emplyId, sqList);
	}

	@Override
	public List<Map<String, Object>> EvtList(Map<String, Object> param) {
		return BoCalendarDao.EvtList(param);
	}

	@Override
	public List<Map<String, Object>> EvtCateCount(Map<String, Object> param) {
		return BoCalendarDao.EvtCateCount(param);
	}
}
