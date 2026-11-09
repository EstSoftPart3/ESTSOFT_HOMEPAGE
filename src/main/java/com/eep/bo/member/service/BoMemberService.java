package com.eep.bo.member.service;

import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import com.eep.bo.system.service.BoSystemService;
import com.eep.mapper.BoMemberMapper;
import com.eep.mapper.BoSystemMapper;

import common.util.PasswordHasher;
import common.util.RrnCipher;

/** 계정 발급, 상태, 비밀번호. 직원 계정(1)은 홈페이지만, 관리자 계정(2)은 권한을 가지고 BO 까지 쓴다 */
@Service
public class BoMemberService {

	static final String STAFF = "1", ADMIN = "2";
	private static final Pattern ID = Pattern.compile("^[A-Za-z0-9._-]{2,50}$");
	private static final Pattern EMAIL = Pattern.compile("^[^@\\s]+@[^@\\s]+$");
	// 전달할 때 헷갈리는 글자(0 O 1 l I)는 뺀다
	private static final String LETTERS = "abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ", DIGITS = "23456789";
	private static final SecureRandom RANDOM = new SecureRandom();

	@Autowired
	private BoMemberMapper mapper;
	@Autowired
	private BoSystemMapper systemMapper;
	@Autowired
	private BoSystemService system;

	private TransactionTemplate tx;

	@Autowired
	public void setDataSource(@Qualifier("dataSource") DataSource ds) { // dataSourceSpied 와 2개라 이름을 지정해야 기동된다
		tx = new TransactionTemplate(new DataSourceTransactionManager(ds));
	}

	public Map<String, Object> list() {
		Map<String, Object> out = new HashMap<>();
		out.put("accounts", mapper.selectAccounts());
		out.put("pending", mapper.selectPendingStaff());
		out.put("roles", systemMapper.selectRoles());
		return out;
	}

	public Map<String, Object> card(int sq, Actor actor) {
		Map<String, Object> row = target(sq, actor);
		row.put("EMPLY_RRN", RrnCipher.maskStored((String) row.get("EMPLY_RRN")));
		return row;
	}

	// ── 발급 ──

	/** 재직자 계정을 한 번에 발급한다. 하나라도 실패하면 모두 취소하고, 초기 비밀번호는 이 응답으로만 나간다 */
	public List<Map<String, Object>> issueFromStaff(List<Integer> staffSqs, List<String> ids, String type, Integer roleSq, Actor actor) {
		require(staffSqs != null && ids != null && !staffSqs.isEmpty() && staffSqs.size() == ids.size(), "발급할 직원을 선택해 주세요.");
		requireType(type);
		require(ADMIN.equals(type) == (roleSq != null), "관리자 계정은 권한을 하나 골라야 합니다.");
		return tx.execute(s -> {
			List<Map<String, Object>> issued = new ArrayList<>();
			for (int i = 0; i < staffSqs.size(); i++) {
				Map<String, Object> staff = mapper.selectStaffForIssue(staffSqs.get(i));
				require(staff != null && "WORK".equals(staff.get("STATUS_CD")), "재직 중인 직원만 발급할 수 있습니다.");
				String name = (String) staff.get("STAFF_NM");
				require(blank(staff.get("EMPLY_ID")), name + "님은 이미 계정이 있습니다.");
				require(idFromEmail((String) staff.get("EMAIL")) != null, name + "님은 이메일이 없어 발급할 수 없습니다.");
				String id = text(ids.get(i));
				Map<String, Object> created = create(id, name, (String) staff.get("EMAIL"), (String) staff.get("PHONE"), type);
				Map<String, Object> link = new HashMap<>();
				link.put("EMPLY_ID", id);
				link.put("STAFF_SQ", staffSqs.get(i));
				mapper.linkStaff(link);
				if (roleSq != null) {
					system.addRoleUser(roleSq, id, actor.id, actor.superUser);
				}
				issued.add(created);
			}
			return issued;
		});
	}

	/** 직원이 아닌 담당자용 관리자 계정 */
	public List<Map<String, Object>> issueManualAdmin(String id, String name, String email, Integer roleSq, Actor actor) {
		require(roleSq != null, "관리자 계정은 권한을 하나 골라야 합니다.");
		require(text(name) != null && name.trim().length() <= 50, "이름을 입력해 주세요.");
		validateEmail(text(email));
		return tx.execute(s -> {
			Map<String, Object> created = create(text(id), name.trim(), text(email), null, ADMIN);
			system.addRoleUser(roleSq, text(id), actor.id, actor.superUser);
			List<Map<String, Object>> issued = new ArrayList<>();
			issued.add(created);
			return issued;
		});
	}

	private Map<String, Object> create(String id, String name, String email, String phone, String type) {
		validateId(id, null);
		String password = tempPassword();
		Map<String, Object> p = new HashMap<>();
		p.put("EMPLY_ID", id);
		p.put("EMPLY_PW", PasswordHasher.hash(password));
		p.put("EMPLY_NM", name);
		p.put("EMPLY_EMAIL", email);
		p.put("EMPLY_PH_NUM", phone);
		p.put("TYPE_CD", type);
		mapper.insertAccount(p);
		return credential(id, name, password);
	}

	private static Map<String, Object> credential(String id, String name, String password) {
		Map<String, Object> out = new HashMap<>();
		out.put("EMPLY_ID", id);
		out.put("EMPLY_NM", name);
		out.put("PASSWORD", password);
		return out;
	}

	public Map<String, Object> resetPassword(int sq, Actor actor) {
		Map<String, Object> row = target(sq, actor);
		require(!blank(row.get("EMPLY_ID")), "아이디를 먼저 입력해 주세요.");
		String password = tempPassword();
		Map<String, Object> p = new HashMap<>();
		p.put("EMPLY_SQ", sq);
		p.put("EMPLY_PW", PasswordHasher.hash(password));
		mapper.updatePassword(p);
		return credential((String) row.get("EMPLY_ID"), (String) row.get("EMPLY_NM"), password);
	}

	// ── 수정·상태 ──

	public void save(Map<String, Object> p, Actor actor) {
		int sq = number(p.get("EMPLY_SQ"));
		Map<String, Object> row = target(sq, actor);
		String id = text(p.get("EMPLY_ID")), name = text(p.get("EMPLY_NM")), email = text(p.get("EMPLY_EMAIL")), oldId = (String) row.get("EMPLY_ID");
		require(name != null && name.length() <= 50, "이름을 입력해 주세요.");
		validateId(id, sq);
		validateEmail(email);
		String phone = text(p.get("EMPLY_PH_NUM")), addr = text(p.get("EMPLY_HOME_ADDR")), sex = text(p.get("EMPLY_SEX_TYP_CD")), rrn = text(p.get("EMPLY_RRN"));
		require(phone == null || phone.length() <= 50, "휴대전화를 확인해 주세요.");
		require(addr == null || addr.length() <= 50, "주소는 50자 이내로 입력해 주세요.");
		require(sex == null || "M".equals(sex) || "F".equals(sex), "성별을 확인해 주세요.");
		p.put("EMPLY_SQ", sq);
		p.put("EMPLY_ID", id);
		p.put("EMPLY_NM", name);
		p.put("EMPLY_EMAIL", email);
		p.put("EMPLY_PH_NUM", phone);
		p.put("EMPLY_HOME_ADDR", addr);
		p.put("EMPLY_SEX_TYP_CD", sex);
		// 가려 보여 준 값이 그대로 오면 저장값을 유지한다
		p.put("EMPLY_RRN", rrn == null || RrnCipher.isMasked(rrn) ? null : RrnCipher.isEncrypted(rrn) ? rrn : RrnCipher.encrypt(rrn));
		p.put("OLD_ID", oldId);
		tx.execute(s -> {
			mapper.updateAccount(p);
			if (oldId != null && !oldId.equals(id)) {
				mapper.renameRoleUser(p);
				mapper.renameStaffLink(p);
			}
			return null;
		});
	}

	/** SUSPEND, RESUME, RETIRE, RESTORE */
	public void setStatus(int sq, String action, Actor actor) {
		Map<String, Object> row = target(sq, actor);
		boolean blocking = "SUSPEND".equals(action) || "RETIRE".equals(action);
		require(!blocking || !actor.id.equals(row.get("EMPLY_ID")), "내 계정은 중지하거나 퇴사 처리할 수 없습니다.");
		Map<String, Object> p = new HashMap<>();
		p.put("EMPLY_SQ", sq);
		if ("SUSPEND".equals(action) || "RESUME".equals(action)) {
			p.put("USE_YN", "SUSPEND".equals(action) ? "N" : "Y");
		} else {
			require("RETIRE".equals(action) || "RESTORE".equals(action), "처리할 수 없는 요청입니다.");
			p.put("DEL_YN", "RETIRE".equals(action) ? "Y" : "N");
		}
		mapper.updateStatus(p);
	}

	public void setType(int sq, String type, Integer roleSq, Actor actor) {
		requireType(type);
		Map<String, Object> row = target(sq, actor);
		String id = (String) row.get("EMPLY_ID");
		require(id != null, "아이디를 먼저 입력해 주세요.");
		require(!actor.id.equals(id), "내 계정의 구분은 바꿀 수 없습니다.");
		require(ADMIN.equals(type) == (roleSq != null), "관리자 계정은 권한을 하나 골라야 합니다.");
		Map<String, Object> p = new HashMap<>();
		p.put("EMPLY_SQ", sq);
		p.put("TYPE_CD", type);
		tx.execute(s -> {
			mapper.updateType(p);
			if (ADMIN.equals(type)) {
				system.addRoleUser(roleSq, id, actor.id, actor.superUser);
			} else {
				mapper.deleteUserRoles(id);
			}
			return null;
		});
	}

	public void linkStaff(int sq, Integer staffSq, Actor actor) {
		Map<String, Object> row = target(sq, actor);
		String id = (String) row.get("EMPLY_ID");
		require(id != null, "아이디를 먼저 입력해 주세요.");
		tx.execute(s -> {
			mapper.unlinkStaff(id);
			if (staffSq != null) {
				Map<String, Object> p = new HashMap<>();
				p.put("EMPLY_ID", id);
				p.put("STAFF_SQ", staffSq);
				mapper.linkStaff(p);
			}
			return null;
		});
	}

	// ── 본인 비밀번호 ──

	public void changeOwnPassword(String emplyId, String current, String next) {
		require(PasswordHasher.matches(current, mapper.selectPasswordHash(emplyId)), "현재 비밀번호가 맞지 않습니다.");
		String problem = passwordProblem(emplyId, current, next);
		require(problem == null, problem);
		Map<String, Object> p = new HashMap<>();
		p.put("EMPLY_ID", emplyId);
		p.put("EMPLY_PW", PasswordHasher.hash(next));
		mapper.changePassword(p);
	}

	public void touchLogin(String emplyId) {
		mapper.touchLogin(emplyId);
	}

	// ── 규칙 ──

	/** 슈퍼관리자 계정은 슈퍼관리자만 건드릴 수 있다. 비밀번호 재발급으로 권한을 가로채는 것을 막는다 */
	private Map<String, Object> target(int sq, Actor actor) {
		Map<String, Object> row = mapper.selectAccount(sq);
		require(row != null, "계정을 찾을 수 없습니다.");
		require(actor.superUser || ((Number) row.get("SUPER_CNT")).intValue() == 0, "슈퍼관리자 계정은 슈퍼관리자만 변경할 수 있습니다.");
		return row;
	}

	private void validateId(String id, Integer exceptSq) {
		require(id != null && ID.matcher(id).matches(), "아이디는 영문, 숫자, . _ - 로 2~50자여야 합니다: " + id);
		Map<String, Object> p = new HashMap<>();
		p.put("EMPLY_ID", id);
		p.put("EMPLY_SQ", exceptSq);
		require(mapper.countId(p) == 0, "이미 사용 중인 아이디입니다: " + id);
	}

	private static void validateEmail(String email) {
		require(email == null || (email.length() <= 200 && EMAIL.matcher(email).matches()), "이메일 형식을 확인해 주세요.");
	}

	private static void requireType(String type) {
		require(STAFF.equals(type) || ADMIN.equals(type), "계정 구분을 확인해 주세요.");
	}

	static String idFromEmail(String email) {
		if (email == null || !EMAIL.matcher(email.trim()).matches()) {
			return null;
		}
		return email.trim().substring(0, email.trim().indexOf('@'));
	}

	static String tempPassword() {
		StringBuilder b = new StringBuilder();
		for (int i = 0; i < 12; i++) {
			String from = i % 4 == 3 ? DIGITS : LETTERS;
			b.append(from.charAt(RANDOM.nextInt(from.length())));
		}
		return b.toString();
	}

	static String passwordProblem(String id, String current, String next) {
		if (next == null || next.length() < 10 || next.length() > 72) { // bcrypt 는 72바이트까지만 비교한다
			return "새 비밀번호는 10~72자로 입력해 주세요.";
		}
		if (!next.matches(".*[A-Za-z].*") || !next.matches(".*[0-9].*")) {
			return "새 비밀번호에 영문과 숫자를 모두 넣어 주세요.";
		}
		if (next.equalsIgnoreCase(id) || next.equals(current)) {
			return "아이디나 현재 비밀번호와 다르게 입력해 주세요.";
		}
		return null;
	}

	private static boolean blank(Object value) {
		return text(value) == null;
	}

	private static String text(Object value) {
		String s = value == null ? "" : value.toString().trim();
		return s.isEmpty() ? null : s;
	}

	private static int number(Object value) {
		try {
			return Integer.parseInt(String.valueOf(value).trim());
		} catch (NumberFormatException e) {
			throw new IllegalArgumentException("계정을 찾을 수 없습니다.");
		}
	}

	private static void require(boolean ok, String message) {
		if (!ok) {
			throw new IllegalArgumentException(message);
		}
	}

	/** 요청한 관리자 */
	public static class Actor {
		final String id;
		final boolean superUser;

		public Actor(String id, boolean superUser) {
			this.id = id;
			this.superUser = superUser;
		}
	}
}
