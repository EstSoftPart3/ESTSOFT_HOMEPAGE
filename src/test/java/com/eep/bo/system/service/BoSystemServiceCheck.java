package com.eep.bo.system.service;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** 프로젝트에 JUnit 이 없어 main 으로 확인한다 */
public class BoSystemServiceCheck {

	public static void main(String[] args) {
		List<Map<String, Object>> menus = Arrays.asList(
				menu("G1", null, null, null), menu("A", "G1", "/admin/a/openA.do", "/admin/a/**"),
				menu("H1", null, null, null), menu("HI", "H1", "/admin/hr/openInterviewList.do", "/admin/hr/*nterview*,/admin/x/one.do"), menu("HT", "H1", "/admin/hr/openTraineeList.do", "/admin/hr/*rainee*"));

		BoSystemService.Access none = BoSystemService.Access.of(menus, Collections.<Map<String, Object>>emptyList());
		check(!none.allows("/admin/a/openA.do") && none.allows(BoSystemService.HOME) && none.tree.isEmpty() && none.firstUrl() == null, "권한 없음");

		BoSystemService.Access hr = BoSystemService.Access.of(menus, Arrays.asList(grant("HR", "HI")));
		check(hr.allows("/admin/hr/interviewListData.do") && hr.allows("/admin/x/one.do"), "부여 메뉴 허용");
		check(!hr.allows("/admin/hr/saveTraineeData.do") && !hr.allows("/admin/a/openA.do"), "미부여 메뉴 차단");
		check(!hr.allows("/admin/unknown/any.do"), "메뉴에 없는 주소 차단");
		check(hr.tree.size() == 1 && "/admin/hr/openInterviewList.do".equals(hr.firstUrl()), "권한 있는 메뉴만 표시");

		BoSystemService.Access sup = BoSystemService.Access.of(menus, Arrays.asList(grant("SUPER", null)));
		check(sup.superUser && sup.allows("/admin/unknown/any.do") && sup.tree.size() == 2, "슈퍼관리자 전체 허용");

		BoSystemService.validatePatterns("/admin/hr/*x*, /admin/a/**");
		rejects("/eep/**");
		rejects("/admin/**");
		System.out.println("BoSystemServiceCheck OK");
	}

	private static void rejects(String pattern) {
		try {
			BoSystemService.validatePatterns(pattern);
		} catch (IllegalArgumentException e) {
			return;
		}
		throw new AssertionError("거부해야 함: " + pattern);
	}

	private static Map<String, Object> menu(String code, String parent, String url, String pattern) {
		Map<String, Object> m = new HashMap<>();
		m.put("MENU_CODE", code);
		m.put("REL_CODE", parent);
		m.put("MENU_URL", url);
		m.put("AUTH_PATTERN", pattern);
		return m;
	}

	private static Map<String, Object> grant(String role, String menu) {
		Map<String, Object> g = new HashMap<>();
		g.put("ROLE_CD", role);
		g.put("MENU_CODE", menu);
		return g;
	}

	private static void check(boolean ok, String name) {
		if (!ok) {
			throw new AssertionError(name);
		}
	}
}
