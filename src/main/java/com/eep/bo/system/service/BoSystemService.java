package com.eep.bo.system.service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.util.AntPathMatcher;

import com.eep.mapper.BoSystemMapper;

/** 메뉴, 권한, 권한별 사용자. /admin 요청의 접근 판단도 여기서 한다 */
@Service
public class BoSystemService {

	public static final String HOME = "/admin/home.do";
	static final String SUPER = "SUPER";
	// 화면만 지킨다. 담긴 그룹은 숨김 검사가 상위까지 보고, 하위가 있으면 삭제도 막힌다
	private static final Set<String> CORE_MENUS = new HashSet<>(Arrays.asList("M00002", "C00002"));
	private static final Pattern URL = Pattern.compile("^/[A-Za-z0-9_./-]*$");
	private static final Pattern ICON = Pattern.compile("^fa-[a-z0-9-]+$");
	private static final AntPathMatcher MATCHER = new AntPathMatcher();

	@Autowired
	private BoSystemMapper mapper;

	private TransactionTemplate tx;

	@Autowired
	public void setDataSource(@Qualifier("dataSource") DataSource ds) { // dataSourceSpied 와 2개라 이름을 지정해야 기동된다
		tx = new TransactionTemplate(new DataSourceTransactionManager(ds));
	}

	// ── 접근 판단 ──

	/** 권한을 바꾸면 다음 요청부터 바로 적용되도록 세션에 담지 않고 요청마다 읽는다 */
	public Access access(String emplyId) {
		return Access.of(mapper.selectActiveMenus(), mapper.selectMyGrants(emplyId));
	}

	public boolean isActiveAdmin(String emplyId) {
		return mapper.countActiveAdmin(emplyId) > 0;
	}

	public static class Access {
		public final boolean superUser;
		public final List<Map<String, Object>> tree = new ArrayList<>();
		private final List<Map<String, Object>> items = new ArrayList<>();

		private Access(boolean superUser) {
			this.superUser = superUser;
		}

		static Access of(List<Map<String, Object>> menus, List<Map<String, Object>> grants) {
			boolean superUser = false;
			Set<Object> granted = new HashSet<>();
			for (Map<String, Object> g : grants) {
				superUser |= SUPER.equals(g.get("ROLE_CD"));
				granted.add(g.get("MENU_CODE"));
			}
			Access access = new Access(superUser);
			Map<Object, List<Map<String, Object>>> byParent = new HashMap<>();
			for (Map<String, Object> m : menus) {
				byParent.computeIfAbsent(m.get("REL_CODE"), k -> new ArrayList<>()).add(m);
			}
			// 그룹에서 내려가며 모으므로 숨겨서 목록에 없는 상위의 하위 메뉴는 자연히 빠진다
			for (Map<String, Object> root : byParent.getOrDefault(null, new ArrayList<>())) {
				Map<String, Object> group = access.branch(root, byParent, granted);
				if (!children(group).isEmpty()) {
					access.tree.add(group);
				}
			}
			return access;
		}

		/** 권한 있는 화면만 남긴 그룹·묶음의 사본을 만든다 */
		private Map<String, Object> branch(Map<String, Object> parent, Map<Object, List<Map<String, Object>>> byParent, Set<Object> granted) {
			Map<String, Object> copy = new HashMap<>(parent);
			List<Map<String, Object>> kids = new ArrayList<>();
			copy.put("children", kids);
			for (Map<String, Object> m : byParent.getOrDefault(parent.get("MENU_CODE"), new ArrayList<>())) {
				if (m.get("MENU_URL") == null) {
					Map<String, Object> sub = branch(m, byParent, granted);
					if (!children(sub).isEmpty()) {
						kids.add(sub);
					}
				} else if (superUser || granted.contains(m.get("MENU_CODE"))) {
					kids.add(m);
					items.add(m);
				}
			}
			return copy;
		}

		/** 어떤 메뉴에도 속하지 않은 /admin 주소는 슈퍼관리자만 연다 */
		public boolean allows(String path) {
			if (superUser || HOME.equals(path)) {
				return true;
			}
			for (Map<String, Object> m : items) {
				if (m.get("AUTH_PATTERN") != null) {
					for (String pattern : ((String) m.get("AUTH_PATTERN")).split(",")) {
						if (MATCHER.match(pattern.trim(), path)) {
							return true;
						}
					}
				}
			}
			return false;
		}

		/** 로그인 뒤 처음 열 화면. 새 창 메뉴는 건너뛴다 */
		public String firstUrl() {
			for (Map<String, Object> m : items) {
				if (!"Y".equals(m.get("NEW_WIN_YN")) && m.get("MENU_URL") != null) {
					return (String) m.get("MENU_URL");
				}
			}
			return null;
		}

		@SuppressWarnings("unchecked")
		private static List<Map<String, Object>> children(Map<String, Object> group) {
			return (List<Map<String, Object>>) group.get("children");
		}
	}

	// ── 메뉴 ──

	public List<Map<String, Object>> menus() {
		return mapper.selectAllMenus();
	}

	public void saveMenu(Map<String, Object> p) {
		String name = trim(p.get("MENU_NM")), code = trim(p.get("MENU_CODE")), parent = trim(p.get("REL_CODE"));
		String url = trim(p.get("MENU_URL")), patterns = trim(p.get("AUTH_PATTERN")), icon = trim(p.get("ICON_NM"));
		require(name != null && name.length() <= 50, "메뉴명을 50자 이내로 입력해 주세요.");
		require(icon == null || ICON.matcher(icon).matches(), "아이콘은 fa-로 시작하는 이름으로 입력해 주세요.");
		boolean group = parent == null;
		if (group) {
			url = null;
			patterns = null;
		} else {
			require(url == null || (url.length() <= 200 && URL.matcher(url).matches() && !url.startsWith("//")), "화면 주소는 /로 시작하는 내부 주소로 입력해 주세요.");
			validatePatterns(patterns);
			if (url == null) {
				patterns = null;
			}
		}
		p.put("MENU_CODE", code != null ? code : "MN" + System.currentTimeMillis());
		p.put("MENU_NM", name);
		p.put("REL_CODE", parent);
		p.put("MENU_URL", url);
		p.put("ICON_NM", icon);
		p.put("AUTH_PATTERN", patterns);
		p.put("USE_YN", "N".equals(p.get("USE_YN")) ? "N" : "Y");
		p.put("NEW_WIN_YN", "Y".equals(p.get("NEW_WIN_YN")) ? "Y" : "N");
		p.put("SORT_NO", number(p.get("SORT_NO"), "순서"));
		List<Map<String, Object>> after = new ArrayList<>(mapper.selectAllMenus());
		after.removeIf(m -> p.get("MENU_CODE").equals(m.get("MENU_CODE")));
		after.add(p);
		setDepth(p, validateMenuTree(after));
		mapper.upsertMenu(p);
	}

	/** 아이콘은 2단계까지만 쓰고 3단계는 동그라미로 표시한다 */
	private static void setDepth(Map<String, Object> menu, Map<String, Integer> depths) {
		int depth = depths.get(menu.get("MENU_CODE"));
		menu.put("MENU_DEPTH", String.valueOf(depth));
		if (depth == 3) {
			menu.put("ICON_NM", null);
		}
	}

	/** 저장 후의 전체 메뉴로 구조를 검사하고 메뉴별 단계를 돌려준다. 3단계 제한이 순환 참조도 막는다 */
	static Map<String, Integer> validateMenuTree(List<Map<String, Object>> menus) {
		Map<String, Map<String, Object>> byCode = new HashMap<>();
		menus.forEach(m -> byCode.put((String) m.get("MENU_CODE"), m));
		Map<String, Integer> depths = new HashMap<>();
		for (Map<String, Object> m : menus) {
			require(m.get("REL_CODE") != null || m.get("MENU_URL") == null, "화면 주소가 있는 메뉴는 그룹이 될 수 없습니다.");
			int depth = 1;
			boolean visible = !"N".equals(m.get("USE_YN"));
			for (Map<String, Object> at = m; at.get("REL_CODE") != null; depth++) {
				require(depth < 3, "메뉴는 3단계까지만 만들 수 있습니다.");
				at = byCode.get(at.get("REL_CODE"));
				require(at != null, "상위 메뉴를 찾을 수 없습니다.");
				require(at.get("MENU_URL") == null, "화면 주소가 있는 메뉴 아래에는 메뉴를 둘 수 없습니다.");
				visible &= !"N".equals(at.get("USE_YN"));
			}
			require(depth < 3 || m.get("MENU_URL") != null, "3단계 메뉴는 화면 주소를 입력해 주세요.");
			require(visible || !CORE_MENUS.contains(m.get("MENU_CODE")), "메뉴·권한 관리에 필요한 메뉴는 숨길 수 없습니다.");
			depths.put((String) m.get("MENU_CODE"), depth);
		}
		return depths;
	}

	static void validatePatterns(String patterns) {
		if (patterns == null) {
			return;
		}
		require(patterns.length() <= 1000, "접근 경로가 너무 깁니다.");
		for (String pattern : patterns.split(",")) {
			String t = pattern.trim();
			require(t.startsWith("/admin/") && t.length() > "/admin/".length() && !t.startsWith("/admin/**"), "접근 경로는 /admin/업무폴더/ 아래로 입력해 주세요: " + t);
		}
	}

	public void deleteMenu(String code) {
		require(!CORE_MENUS.contains(code), "메뉴·권한 관리에 필요한 메뉴는 삭제할 수 없습니다.");
		require(mapper.countChildMenus(code) == 0, "하위 메뉴를 먼저 옮기거나 삭제해 주세요.");
		tx.execute(s -> {
			mapper.deleteMenuGrants(code);
			mapper.deleteMenu(code);
			return null;
		});
	}

	/** 드래그 후의 전체 배치를 저장한다 */
	public void sortMenus(String order) {
		List<Map<String, Object>> rows = menuOrderRows(order, mapper.selectAllMenus());
		tx.execute(s -> {
			rows.forEach(mapper::updateMenuOrder);
			return null;
		});
	}

	/** order 형식: 코드:상위코드,코드:상위코드 (화면 위에서 아래 순서, 그룹은 상위코드 없음). 화면을 연 뒤 메뉴가 바뀌었으면 일부만 저장되지 않게 전부 거부한다 */
	static List<Map<String, Object>> menuOrderRows(String order, List<Map<String, Object>> menus) {
		String stale = "메뉴가 변경되었습니다. 새로고침 후 다시 시도해 주세요.";
		Map<String, Map<String, Object>> remaining = new HashMap<>();
		menus.forEach(m -> remaining.put((String) m.get("MENU_CODE"), m));
		List<Map<String, Object>> rows = new ArrayList<>();
		Map<String, Integer> counts = new HashMap<>();
		for (String entry : order.split(",")) {
			String[] parts = entry.split(":", -1);
			Map<String, Object> menu = remaining.remove(parts[0]);
			require(parts.length == 2 && menu != null, stale);
			String parent = parts[1].isEmpty() ? null : parts[1];
			int position = counts.merge(parent, 1, Integer::sum);
			Map<String, Object> row = new HashMap<>(menu);
			row.put("REL_CODE", parent);
			row.put("SORT_NO", parent == null ? position * 10 : position);
			rows.add(row);
		}
		require(remaining.isEmpty(), stale);
		Map<String, Integer> depths = validateMenuTree(rows);
		rows.forEach(r -> setDepth(r, depths));
		return rows;
	}

	// ── 권한 ──

	public Map<String, Object> roles() {
		Map<String, Object> out = new HashMap<>();
		out.put("roles", mapper.selectRoles());
		out.put("menus", mapper.selectAllMenus());
		out.put("roleMenus", mapper.selectRoleMenus());
		out.put("roleUsers", mapper.selectRoleUsers());
		out.put("admins", mapper.selectAdminOptions());
		return out;
	}

	public void saveRole(Map<String, Object> p) {
		String name = trim(p.get("ROLE_NM")), desc = trim(p.get("ROLE_DESC"));
		require(name != null && name.length() <= 50, "권한명을 50자 이내로 입력해 주세요.");
		require(desc == null || desc.length() <= 200, "설명은 200자 이내로 입력해 주세요.");
		p.put("ROLE_NM", name);
		p.put("ROLE_DESC", desc);
		if (trim(p.get("ROLE_SQ")) == null) {
			p.put("ROLE_CD", "R" + System.currentTimeMillis());
			mapper.insertRole(p);
		} else {
			role(number(p.get("ROLE_SQ"), "권한"));
			mapper.updateRole(p);
		}
	}

	public void deleteRole(int roleSq) {
		require(!"Y".equals(role(roleSq).get("SYSTEM_YN")), "시스템 권한은 삭제할 수 없습니다.");
		tx.execute(s -> {
			mapper.deleteRoleUsers(roleSq);
			mapper.deleteRoleMenus(roleSq);
			mapper.deleteRole(roleSq);
			return null;
		});
	}

	public void saveRoleMenus(int roleSq, String codes) {
		require(!SUPER.equals(role(roleSq).get("ROLE_CD")), "슈퍼관리자는 항상 모든 메뉴를 사용합니다.");
		List<String> list = new ArrayList<>();
		if (codes != null) {
			for (String c : codes.split(",")) {
				if (!c.trim().isEmpty()) {
					list.add(c.trim());
				}
			}
		}
		Map<String, Object> p = new HashMap<>();
		p.put("ROLE_SQ", roleSq);
		p.put("MENU_CODES", list);
		tx.execute(s -> {
			mapper.deleteRoleMenus(roleSq);
			if (!list.isEmpty()) {
				mapper.insertRoleMenus(p);
			}
			return null;
		});
	}

	public void addRoleUser(int roleSq, String emplyId, String loginId) {
		guardGrant(roleSq, emplyId, loginId);
		require(emplyId != null && mapper.countActiveAdmin(emplyId) > 0, "사용 중인 관리자 계정만 추가할 수 있습니다.");
		mapper.insertRoleUser(userParam(roleSq, emplyId, loginId));
	}

	public void removeRoleUser(int roleSq, String emplyId, String loginId) {
		guardGrant(roleSq, emplyId, loginId);
		if (SUPER.equals(role(roleSq).get("ROLE_CD"))) {
			require(mapper.countRoleUsers(roleSq) > 1, "슈퍼관리자는 최소 1명이 필요합니다.");
		}
		mapper.deleteRoleUser(userParam(roleSq, emplyId, loginId));
	}

	/** 권한별로 지금 접속한 사람이 주고 뺄 수 있는지(GRANTABLE)와 못 하는 이유(LOCK_REASON). 매핑을 바꾸면 다음 요청부터 바로 반영된다 */
	public List<Map<String, Object>> rolesFor(String loginId) {
		return grantInfo(mapper.selectRoles(), mapper.selectRoleMenus(), mapper.selectMyGrants(loginId), mapper.selectAllMenus());
	}

	private void guardGrant(int roleSq, String emplyId, String loginId) {
		role(roleSq);
		require(!loginId.equals(emplyId), "내 계정의 권한은 바꿀 수 없습니다.");
		for (Map<String, Object> r : rolesFor(loginId)) {
			if (((Number) r.get("ROLE_SQ")).intValue() == roleSq) {
				require("Y".equals(r.get("GRANTABLE")), r.get("ROLE_NM") + " 권한은 바꿀 수 없습니다. " + r.get("LOCK_REASON"));
			}
		}
	}

	/** 슈퍼관리자가 아니면 권한의 메뉴가 모두 내 메뉴 안에 있을 때만 그 권한을 주고 뺄 수 있다 */
	static List<Map<String, Object>> grantInfo(List<Map<String, Object>> roles, List<Map<String, Object>> roleMenus, List<Map<String, Object>> myGrants, List<Map<String, Object>> menus) {
		boolean superUser = false;
		Set<Object> mine = new HashSet<>();
		for (Map<String, Object> g : myGrants) {
			superUser |= SUPER.equals(g.get("ROLE_CD"));
			mine.add(g.get("MENU_CODE"));
		}
		Map<Object, Object> names = new HashMap<>();
		menus.forEach(m -> names.put(m.get("MENU_CODE"), m.get("MENU_NM")));
		List<Map<String, Object>> out = new ArrayList<>();
		for (Map<String, Object> role : roles) {
			Map<String, Object> r = new HashMap<>(role);
			String reason = null;
			if (!superUser) {
				if (SUPER.equals(role.get("ROLE_CD"))) {
					reason = "슈퍼관리자만 지정할 수 있습니다.";
				} else {
					List<Object> missing = new ArrayList<>();
					for (Map<String, Object> rm : roleMenus) {
						if (role.get("ROLE_SQ").equals(rm.get("ROLE_SQ")) && !mine.contains(rm.get("MENU_CODE"))) {
							Object name = names.get(rm.get("MENU_CODE"));
							missing.add(name != null ? name : rm.get("MENU_CODE"));
						}
					}
					if (!missing.isEmpty()) {
						reason = "내 메뉴에 없음: " + missing.get(0) + (missing.size() > 1 ? " 외 " + (missing.size() - 1) + "개" : "");
					}
				}
			}
			r.put("GRANTABLE", reason == null ? "Y" : "N");
			r.put("LOCK_REASON", reason);
			out.add(r);
		}
		return out;
	}

	private static Map<String, Object> userParam(int roleSq, String emplyId, String loginId) {
		Map<String, Object> p = new HashMap<>();
		p.put("ROLE_SQ", roleSq);
		p.put("EMPLY_ID", emplyId);
		p.put("UPDT_EMPLY_ID", loginId);
		return p;
	}

	private Map<String, Object> role(int roleSq) {
		Map<String, Object> role = mapper.selectRole(roleSq);
		require(role != null, "권한을 찾을 수 없습니다.");
		return role;
	}

	private static String trim(Object value) {
		String s = value == null ? "" : value.toString().trim();
		return s.isEmpty() ? null : s;
	}

	private static int number(Object value, String label) {
		try {
			return Integer.parseInt(String.valueOf(value).trim());
		} catch (NumberFormatException e) {
			throw new IllegalArgumentException(label + " 값을 확인해 주세요.");
		}
	}

	private static void require(boolean ok, String message) {
		if (!ok) {
			throw new IllegalArgumentException(message);
		}
	}
}
