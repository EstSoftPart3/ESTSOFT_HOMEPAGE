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
	private static final Set<String> CORE_MENUS = new HashSet<>(Arrays.asList("M001", "M00002", "C00002"));
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
			Map<Object, Map<String, Object>> groups = new HashMap<>();
			for (Map<String, Object> m : menus) {
				if (m.get("REL_CODE") == null) {
					Map<String, Object> group = new HashMap<>(m);
					group.put("children", new ArrayList<Map<String, Object>>());
					groups.put(m.get("MENU_CODE"), group);
				}
			}
			Set<Object> added = new HashSet<>();
			for (Map<String, Object> m : menus) {
				Map<String, Object> group = groups.get(m.get("REL_CODE"));
				if (group == null || !(superUser || granted.contains(m.get("MENU_CODE")))) {
					continue;
				}
				children(group).add(m);
				access.items.add(m);
				if (added.add(m.get("REL_CODE"))) {
					access.tree.add(group);
				}
			}
			return access;
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
		boolean group = parent == null;
		if (group) {
			require(icon == null || ICON.matcher(icon).matches(), "아이콘은 fa-로 시작하는 이름으로 입력해 주세요.");
			url = null;
			patterns = null;
		} else {
			require(mapper.countMenu(parent) == 1, "상위 그룹을 찾을 수 없습니다.");
			require(!parent.equals(code), "자기 자신을 상위 그룹으로 지정할 수 없습니다.");
			require(code == null || mapper.countChildMenus(code) == 0, "하위 메뉴가 있는 그룹은 메뉴로 바꿀 수 없습니다.");
			require(url != null && url.length() <= 200 && URL.matcher(url).matches() && !url.startsWith("//"), "화면 주소는 /로 시작하는 내부 주소로 입력해 주세요.");
			validatePatterns(patterns);
			icon = null;
		}
		boolean visible = !"N".equals(p.get("USE_YN"));
		if (code != null && CORE_MENUS.contains(code)) {
			require(visible, "메뉴·권한 관리에 필요한 메뉴는 숨길 수 없습니다.");
		}
		p.put("MENU_CODE", code != null ? code : "MN" + System.currentTimeMillis());
		p.put("MENU_NM", name);
		p.put("REL_CODE", parent);
		p.put("MENU_DEPTH", group ? "1" : "2");
		p.put("MENU_URL", url);
		p.put("ICON_NM", icon);
		p.put("AUTH_PATTERN", patterns);
		p.put("USE_YN", visible ? "Y" : "N");
		p.put("NEW_WIN_YN", "Y".equals(p.get("NEW_WIN_YN")) ? "Y" : "N");
		p.put("SORT_NO", number(p.get("SORT_NO"), "순서"));
		mapper.upsertMenu(p);
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

	/** order 형식: 그룹:메뉴,메뉴;그룹:메뉴. 화면을 연 뒤 메뉴가 바뀌었으면 일부만 저장되지 않게 전부 거부한다 */
	static List<Map<String, Object>> menuOrderRows(String order, List<Map<String, Object>> menus) {
		String stale = "메뉴가 변경되었습니다. 새로고침 후 다시 시도해 주세요.";
		Map<String, Map<String, Object>> byCode = new HashMap<>();
		menus.forEach(m -> byCode.put((String) m.get("MENU_CODE"), m));
		List<Map<String, Object>> rows = new ArrayList<>();
		Set<String> seen = new HashSet<>();
		String[] groups = order.split(";");
		for (int g = 0; g < groups.length; g++) {
			String[] parts = groups[g].split(":", -1);
			require(parts.length == 2, stale);
			Map<String, Object> group = byCode.get(parts[0]);
			require(group != null && group.get("REL_CODE") == null && seen.add(parts[0]), stale);
			rows.add(orderRow(parts[0], null, (g + 1) * 10));
			String[] items = parts[1].isEmpty() ? new String[0] : parts[1].split(",");
			for (int i = 0; i < items.length; i++) {
				Map<String, Object> item = byCode.get(items[i]);
				require(item != null && item.get("REL_CODE") != null && seen.add(items[i]), stale);
				require(!CORE_MENUS.contains(items[i]) || !"N".equals(group.get("USE_YN")), "메뉴·권한 관리에 필요한 메뉴는 숨긴 그룹으로 옮길 수 없습니다.");
				rows.add(orderRow(items[i], parts[0], i + 1));
			}
		}
		require(seen.size() == menus.size(), stale);
		return rows;
	}

	private static Map<String, Object> orderRow(String code, String parent, int sort) {
		Map<String, Object> row = new HashMap<>();
		row.put("MENU_CODE", code);
		row.put("REL_CODE", parent);
		row.put("SORT_NO", sort);
		return row;
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

	public void addRoleUser(int roleSq, String emplyId, String loginId, boolean actorSuper) {
		guardSuperChange(roleSq, actorSuper);
		require(emplyId != null && mapper.countActiveAdmin(emplyId) > 0, "사용 중인 관리자 계정만 추가할 수 있습니다.");
		mapper.insertRoleUser(userParam(roleSq, emplyId, loginId));
	}

	public void removeRoleUser(int roleSq, String emplyId, String loginId, boolean actorSuper) {
		boolean superRole = guardSuperChange(roleSq, actorSuper);
		if (superRole) {
			require(!loginId.equals(emplyId), "내 계정은 슈퍼관리자에서 제외할 수 없습니다.");
			require(mapper.countRoleUsers(roleSq) > 1, "슈퍼관리자는 최소 1명이 필요합니다.");
		}
		mapper.deleteRoleUser(userParam(roleSq, emplyId, loginId));
	}

	/** 슈퍼관리자 소속은 슈퍼관리자만 바꿀 수 있다 */
	private boolean guardSuperChange(int roleSq, boolean actorSuper) {
		boolean superRole = SUPER.equals(role(roleSq).get("ROLE_CD"));
		require(!superRole || actorSuper, "슈퍼관리자 소속은 슈퍼관리자만 변경할 수 있습니다.");
		return superRole;
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
