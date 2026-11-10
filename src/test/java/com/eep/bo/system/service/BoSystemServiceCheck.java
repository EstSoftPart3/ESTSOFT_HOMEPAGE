package com.eep.bo.system.service;

import java.util.ArrayList;
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

		List<Map<String, Object>> rows = BoSystemService.menuOrderRows("H1:,HT:H1,A:H1,G1:,H2:,HI:H2", withHiddenGroup(menus));
		check(rows.size() == 6 && "H1".equals(rows.get(0).get("MENU_CODE")) && rows.get(0).get("REL_CODE") == null && (int) rows.get(0).get("SORT_NO") == 10 && "1".equals(rows.get(0).get("MENU_DEPTH")), "그룹 순서");
		check("A".equals(rows.get(2).get("MENU_CODE")) && "H1".equals(rows.get(2).get("REL_CODE")) && (int) rows.get(2).get("SORT_NO") == 2 && "2".equals(rows.get(2).get("MENU_DEPTH")), "다른 그룹으로 이동");
		rejectsOrder("", menus);
		rejectsOrder("G1:,A:G1,H1:,HI:H1", menus); // HT 누락
		rejectsOrder("G1:,A:G1,A:G1,H1:,HI:H1,HT:H1", menus); // 중복
		rejectsOrder("A:,G1:A,H1:,HI:H1,HT:H1", menus); // 화면을 그룹으로
		rejectsOrder("G1:,A:G1,X:G1,H1:,HI:H1,HT:H1", menus); // 없는 메뉴

		List<Map<String, Object>> core = new ArrayList<>(withHiddenGroup(menus));
		core.add(menu("M00002", "G1", "/admin/system/menu/open.do", "/admin/system/menu/**"));
		rejectsOrder("G1:,A:G1,HI:G1,H1:,HT:H1,H2:,M00002:H2", core); // 메뉴 관리를 숨긴 그룹으로 이동

		List<Map<String, Object>> deep = Arrays.asList(
				menu("R", null, null, null), menu("F", "R", null, null), menu("L", "F", "/admin/l/open.do", "/admin/l/**"), menu("S", "R", "/admin/s/open.do", "/admin/s/**"), menu("E", "R", null, null));
		BoSystemService.Access three = BoSystemService.Access.of(deep, Arrays.asList(grant("X", "L")));
		List<?> kids = (List<?>) three.tree.get(0).get("children");
		check(three.allows("/admin/l/data.do") && !three.allows("/admin/s/open.do") && kids.size() == 1 && "/admin/l/open.do".equals(three.firstUrl()), "3단계 권한과 빈 묶음 제외");
		check(BoSystemService.Access.of(deep, Arrays.asList(grant("X", "S"))).tree.size() == 1 && BoSystemService.Access.of(deep, Collections.<Map<String, Object>>emptyList()).tree.isEmpty(), "권한 없는 그룹 제외");
		BoSystemService.Access hiddenFolder = BoSystemService.Access.of(Arrays.asList(menu("R", null, null, null), menu("L", "F", "/admin/l/open.do", "/admin/l/**")), Arrays.asList(grant("X", "L")));
		check(!hiddenFolder.allows("/admin/l/open.do") && hiddenFolder.tree.isEmpty(), "숨긴 묶음 아래 화면 차단");
		check(BoSystemService.validateMenuTree(deep).get("L") == 3, "3단계 허용");
		List<Map<String, Object>> iconed = new ArrayList<>(deep);
		Map<String, Object> s = new HashMap<>(deep.get(3));
		s.put("ICON_NM", "fa-laptop");
		iconed.set(3, s);
		List<Map<String, Object>> moved = BoSystemService.menuOrderRows("R:,F:R,L:F,S:F,E:R", iconed);
		check(moved.get(3).get("ICON_NM") == null && "3".equals(moved.get(3).get("MENU_DEPTH")), "3단계로 옮기면 아이콘 제거");
		check("fa-laptop".equals(BoSystemService.menuOrderRows("R:,S:R,F:R,L:F,E:R", iconed).get(1).get("ICON_NM")), "2단계 아이콘 유지");
		rejectsTree(with(deep, menu("D", "L", "/admin/d/open.do", null))); // 4단계이자 화면 아래
		rejectsTree(with(deep, menu("D", "S", "/admin/d/open.do", null))); // 화면 아래
		rejectsTree(with(deep, menu("D", "F", null, null))); // 3단계 묶음
		rejectsTree(with(deep, menu("D", "NONE", "/admin/d/open.do", null))); // 상위 없음
		rejectsTree(Arrays.asList(menu("C1", "C2", null, null), menu("C2", "C1", null, null))); // 순환
		List<Map<String, Object>> roles = Arrays.asList(role(1, "SUPER"), role(2, "SYS"), role(3, "HR"), role(4, "EMPTY"));
		List<Map<String, Object>> roleMenus = Arrays.asList(roleMenu(2, "A"), roleMenu(3, "A"), roleMenu(3, "HI"), roleMenu(3, "HT"));
		List<Map<String, Object>> sys = BoSystemService.grantInfo(roles, roleMenus, Arrays.asList(grant("SYS", "A")), menus);
		check("N".equals(sys.get(0).get("GRANTABLE")) && "Y".equals(sys.get(1).get("GRANTABLE")) && "Y".equals(sys.get(3).get("GRANTABLE")), "내 메뉴 안의 권한만 지정, 슈퍼는 불가");
		check("N".equals(sys.get(2).get("GRANTABLE")) && ((String) sys.get(2).get("LOCK_REASON")).contains("외 1개"), "메뉴가 모자란 권한은 이유와 함께 잠금");
		List<Map<String, Object>> wider = BoSystemService.grantInfo(roles, roleMenus, Arrays.asList(grant("SYS", "A"), grant("SYS", "HI"), grant("SYS", "HT")), menus);
		check("Y".equals(wider.get(2).get("GRANTABLE")), "매핑을 늘리면 바로 지정 가능");
		for (Map<String, Object> r : BoSystemService.grantInfo(roles, roleMenus, Arrays.asList(grant("SUPER", null)), menus)) {
			check("Y".equals(r.get("GRANTABLE")), "슈퍼관리자는 전체 지정");
		}

		Map<String, Object> emptyOldGroup = menu("M001", null, null, null);
		emptyOldGroup.put("USE_YN", "N");
		BoSystemService.validateMenuTree(Arrays.asList(emptyOldGroup)); // 비어 있는 옛 그룹은 숨길 수 있다
		System.out.println("BoSystemServiceCheck OK");
	}

	private static Map<String, Object> role(int sq, String code) {
		Map<String, Object> r = new HashMap<>();
		r.put("ROLE_SQ", sq);
		r.put("ROLE_CD", code);
		r.put("ROLE_NM", code);
		return r;
	}

	private static Map<String, Object> roleMenu(int sq, String menu) {
		Map<String, Object> r = new HashMap<>();
		r.put("ROLE_SQ", sq);
		r.put("MENU_CODE", menu);
		return r;
	}

	private static List<Map<String, Object>> with(List<Map<String, Object>> menus, Map<String, Object> extra) {
		List<Map<String, Object>> all = new ArrayList<>(menus);
		all.add(extra);
		return all;
	}

	private static void rejectsTree(List<Map<String, Object>> menus) {
		try {
			BoSystemService.validateMenuTree(menus);
		} catch (IllegalArgumentException e) {
			return;
		}
		throw new AssertionError("거부해야 함: " + menus);
	}

	private static List<Map<String, Object>> withHiddenGroup(List<Map<String, Object>> menus) {
		List<Map<String, Object>> all = new ArrayList<>(menus);
		Map<String, Object> hidden = menu("H2", null, null, null);
		hidden.put("USE_YN", "N");
		all.add(hidden);
		return all;
	}

	private static void rejectsOrder(String order, List<Map<String, Object>> menus) {
		try {
			BoSystemService.menuOrderRows(order, menus);
		} catch (IllegalArgumentException e) {
			return;
		}
		throw new AssertionError("거부해야 함: " + order);
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
