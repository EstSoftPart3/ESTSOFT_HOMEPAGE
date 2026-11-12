package com.eep.bo.member.service;

import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.regex.Pattern;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import com.eep.bo.system.service.BoSystemService;
import com.eep.mapper.BoMemberMapper;

import common.util.PasswordHasher;
import common.util.RrnCipher;

/** 계정 발급, 상태, 비밀번호. 직원 계정(1)은 홈페이지만, 관리자 계정(2)은 권한을 가지고 BO 까지 쓴다 */
@Service
public class BoMemberService {

	static final String STAFF = "1", ADMIN = "2";
	// PW_INIT_YN: Y 는 관리자 발급이라 변경 강제, R 은 본인 가입이라 로그인 때 변경 권고만 한다
	private static final String PW_FORCE = "Y", PW_ADVISE = "R";
	private static final Pattern ID = Pattern.compile("^[A-Za-z0-9._-]{2,50}$");
	private static final Pattern EMAIL = Pattern.compile("^[^@\\s]+@[^@\\s]+$");
	// 회사 계정도 gmail 이라 개인 gmail 과 구분할 수 없다. 앞부분이 아이디가 되므로 아이디 규칙과 같은 글자만 받는다
	private static final Pattern COMPANY_EMAIL = Pattern.compile("^[a-z0-9._-]{2,50}@gmail\\.com$");
	// 전달할 때 헷갈리는 글자(0 O 1 l I)는 뺀다
	private static final String LETTERS = "abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ", DIGITS = "23456789", SPECIALS = "!@#$%*";
	private static final SecureRandom RANDOM = new SecureRandom();

	@Autowired
	private BoMemberMapper mapper;
	@Autowired
	private BoSystemService system;

	private TransactionTemplate tx;

	@Autowired
	public void setDataSource(@Qualifier("dataSource") DataSource ds) { // dataSourceSpied 와 2개라 이름을 지정해야 기동된다
		tx = new TransactionTemplate(new DataSourceTransactionManager(ds));
	}

	public Map<String, Object> list(Actor actor) {
		Map<String, Object> out = new HashMap<>();
		out.put("accounts", mapper.selectAccounts());
		out.put("pending", mapper.selectPendingStaff());
		out.put("roles", system.rolesFor(actor.id));
		out.put("me", actor.id);
		out.put("canSecret", canSecret(actor));
		return out;
	}

	public Map<String, Object> card(int sq, Actor actor) {
		Map<String, Object> row = target(sq, actor);
		row.put("EMPLY_RRN", RrnCipher.maskStored((String) row.get("EMPLY_RRN")));
		if (canSecret(actor)) {
			row.put("SECRET_YN", mapper.selectSecretYn(sq));
		}
		return row;
	}

	/** 시크릿은 슈퍼관리자만 보고 바꾼다(내 계정 포함). 그 밖의 사람에게는 있다는 것도 알리지 않는다 */
	private boolean canSecret(Actor actor) {
		return actor.superUser;
	}

	public void setSecret(int sq, boolean on, Actor actor) {
		require(canSecret(actor), "계정을 찾을 수 없습니다.");
		target(sq, actor);
		Map<String, Object> p = new HashMap<>();
		p.put("EMPLY_SQ", sq);
		p.put("SECRET_YN", on ? "Y" : "N");
		mapper.updateSecretYn(p);
	}

	// ── 발급 ──

	/** 재직자 계정을 한 번에 발급한다. 하나라도 실패하면 모두 취소하고, 초기 비밀번호는 이 응답으로만 나간다 */
	public List<Map<String, Object>> issueFromStaff(List<Integer> staffSqs, List<String> ids, List<String> emails, String type, Integer roleSq, Actor actor) {
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
				String mail = (String) staff.get("COMPANY_EMAIL"), typed = emails != null && i < emails.size() ? text(emails.get(i)) : null;
				Map<String, Object> link = new HashMap<>();
				link.put("STAFF_SQ", staffSqs.get(i));
				// 인사정보에 회사 메일이 없으면 발급 화면에서 적은 메일을 인사정보에 저장하고 쓴다
				if (idFromEmail(mail) == null && typed != null) {
					mail = companyEmail(typed);
					require(mail != null, name + "님의 회사 메일은 @gmail.com 주소만 쓸 수 있습니다.");
					link.put("EMAIL", mail);
					require(mapper.countStaffCompanyEmail(link) == 0, name + "님의 회사 메일은 다른 직원이 쓰고 있습니다.");
					mapper.updateStaffCompanyEmail(link);
				}
				require(idFromEmail(mail) != null, name + "님은 회사 메일이 없어 발급할 수 없습니다.");
				String id = text(ids.get(i));
				Map<String, Object> created = create(id, name, mail, (String) staff.get("PHONE"), type, PW_FORCE);
				link.put("EMPLY_ID", id);
				mapper.linkStaff(link);
				if (roleSq != null) {
					system.addRoleUser(roleSq, id, actor.id);
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
			Map<String, Object> created = create(text(id), name.trim(), text(email), null, ADMIN, PW_FORCE);
			system.addRoleUser(roleSq, text(id), actor.id);
			List<Map<String, Object>> issued = new ArrayList<>();
			issued.add(created);
			return issued;
		});
	}

	// ── 직원 본인 가입 ──

	/** 가입할 수 있는 재직자면 인사정보를 돌려준다. 메일을 보내기 전과 계정을 만들 때 모두 확인한다 */
	public Map<String, Object> signupStaff(int staffSq, String companyEmail) {
		String mail = companyEmail(companyEmail);
		require(mail != null, "회사 메일은 @gmail.com 주소만 쓸 수 있습니다.");
		Map<String, Object> staff = mapper.selectStaffForIssue(staffSq);
		require(staff != null && "WORK".equals(staff.get("STATUS_CD")) && blank(staff.get("EMPLY_ID")), "가입할 수 없는 직원입니다. 인사 담당자에게 문의해 주세요.");
		String registered = text(staff.get("COMPANY_EMAIL"));
		require(registered == null || registered.equalsIgnoreCase(mail), "인사정보에 등록된 회사 메일과 다릅니다. 인사 담당자에게 문의해 주세요.");
		Map<String, Object> p = new HashMap<>();
		p.put("EMAIL", mail);
		p.put("STAFF_SQ", staffSq);
		require(mapper.countStaffCompanyEmail(p) == 0, "다른 직원이 쓰는 회사 메일입니다. 인사 담당자에게 문의해 주세요.");
		String id = idFromEmail(mail);
		p.put("EMPLY_ID", id);
		require(ID.matcher(id).matches() && mapper.countId(p) == 0, "이미 사용 중인 아이디입니다. 인사 담당자에게 문의해 주세요.");
		return staff;
	}

	/** 인증을 마친 직원의 계정을 회사 메일로 만든다. 하나라도 실패하면 모두 취소한다 */
	public Map<String, Object> issueBySignup(int staffSq, String companyEmail) {
		return tx.execute(s -> {
			Map<String, Object> staff = signupStaff(staffSq, companyEmail);
			String mail = companyEmail(companyEmail), id = idFromEmail(mail), name = (String) staff.get("STAFF_NM");
			String phone = (String) staff.get("PHONE");
			Map<String, Object> created = create(id, name, mail, phone, STAFF, PW_ADVISE);
			Map<String, Object> p = new HashMap<>();
			p.put("EMPLY_ID", id);
			p.put("STAFF_SQ", staffSq);
			require(mapper.linkStaff(p) == 1, "이미 가입된 계정이 있습니다.");
			p.put("EMAIL", mail);
			mapper.updateStaffCompanyEmail(p);
			p.put("EMPLY_NM", name);
			p.put("PHONE", phone == null ? "" : phone.replaceAll("[^0-9]", ""));
			mapper.retireOldStaffAccounts(p);
			return created;
		});
	}

	/** 회사 메일은 @gmail.com 주소만 받는다. 소문자로 맞춘 주소, 형식이 틀리면 null */
	public static String companyEmail(String value) {
		String s = value == null ? "" : value.trim().toLowerCase(Locale.ROOT);
		return COMPANY_EMAIL.matcher(s).matches() ? s : null;
	}

	private Map<String, Object> create(String id, String name, String email, String phone, String type, String pwInit) {
		validateId(id, null);
		String password = tempPassword();
		Map<String, Object> p = new HashMap<>();
		p.put("EMPLY_ID", id);
		p.put("EMPLY_PW", PasswordHasher.hash(password));
		p.put("EMPLY_NM", name);
		p.put("EMPLY_EMAIL", email);
		p.put("EMPLY_PH_NUM", phone);
		p.put("TYPE_CD", type);
		p.put("PW_INIT_YN", pwInit);
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
		require(addr == null || addr.length() <= 500, "주소는 500자 이내로 입력해 주세요.");
		require(sex == null || "M".equals(sex) || "F".equals(sex), "성별을 확인해 주세요.");
		p.put("EMPLY_SQ", sq);
		p.put("EMPLY_ID", id);
		p.put("EMPLY_NM", name);
		p.put("EMPLY_EMAIL", email);
		p.put("EMPLY_PH_NUM", phone);
		p.put("EMPLY_HOME_ADDR", addr);
		p.put("EMPLY_SEX_TYP_CD", sex);
		Integer staffSq = text(p.get("STAFF_SQ")) == null ? null : Integer.valueOf(number(p.get("STAFF_SQ")));
		boolean relink = !Objects.equals(staffSq, row.get("STAFF_SQ"));
		// 인사카드에서 불러온 가림값이면 암호문을 서버에서 복사해 원문이 화면을 거치지 않게 한다
		String staffRrn = relink && staffSq != null && "Y".equals(p.get("COPY_RRN")) && RrnCipher.isMasked(rrn) ? text(mapper.selectStaffRrn(staffSq)) : null;
		// 가려 보여 준 값이 그대로 오면 저장값을 유지한다
		p.put("EMPLY_RRN", staffRrn != null ? stored(staffRrn) : rrn == null || RrnCipher.isMasked(rrn) ? null : stored(rrn));
		p.put("OLD_ID", oldId);
		Set<Integer> current = roleSet(row.get("ROLE_SQS")), next = p.containsKey("ROLE_SQS") ? roleSet(p.get("ROLE_SQS")) : current;
		tx.execute(s -> {
			mapper.updateAccount(p);
			if (oldId != null && !oldId.equals(id)) {
				mapper.renameRoleUser(p);
				mapper.renameStaffLink(p);
			}
			applyRoles(sq, id, (String) row.get("EMPLY_AUTH_TYP_CD"), current, next, actor);
			if (relink) {
				mapper.unlinkStaff(id);
				if (staffSq != null) {
					Map<String, Object> link = new HashMap<>();
					link.put("EMPLY_ID", id);
					link.put("STAFF_SQ", staffSq);
					require(mapper.linkStaff(link) == 1, "이미 다른 계정에 연결된 직원입니다.");
				}
			}
			return null;
		});
	}

	private static String stored(String rrn) {
		return RrnCipher.isEncrypted(rrn) ? rrn : RrnCipher.encrypt(rrn);
	}

	/** 계정 카드의 직원 검색. 주민번호 원문은 내보내지 않고 가림값과 성별만 준다 */
	public List<Map<String, Object>> searchStaff(String keyword) {
		String q = text(keyword);
		require(q != null && q.length() <= 50, "검색어를 확인해 주세요.");
		List<Map<String, Object>> rows = mapper.searchStaff(q);
		for (Map<String, Object> r : rows) {
			String enc = (String) r.remove("RRN_ENC");
			r.put("RRN", RrnCipher.maskStored(enc));
			r.put("SEX_CD", sexOf(enc));
		}
		return rows;
	}

	private static String sexOf(String stored) {
		if (stored == null || stored.isEmpty()) {
			return null;
		}
		try {
			return sexFromRrn(RrnCipher.isEncrypted(stored) ? RrnCipher.decrypt(stored) : stored);
		} catch (RuntimeException e) {
			return null;
		}
	}

	/** 뒷자리 첫 숫자가 홀수면 남, 짝수면 여 */
	static String sexFromRrn(String plain) {
		String digits = plain.replaceAll("[^0-9]", "");
		return digits.length() < 7 ? null : (digits.charAt(6) - '0') % 2 == 1 ? "M" : "F";
	}

	/** 여러 계정에 한 번에. 하나라도 실패하면 모두 취소한다 */
	public void setStatus(List<Integer> sqs, String action, Actor actor) {
		require(sqs != null && !sqs.isEmpty(), "계정을 선택해 주세요.");
		tx.execute(s -> {
			for (Integer sq : sqs) {
				if ("DELETE".equals(action)) {
					delete(sq, actor);
				} else {
					setStatus(sq, action, actor);
				}
			}
			return null;
		});
	}

	/** 되돌릴 수 없다. 권한은 권한 규칙을 거쳐 빼고, 인사카드 연결·자동로그인·화면 설정을 지운다. 작성자 기록(REG_EMPLY_ID 등)은 남긴다 */
	private void delete(int sq, Actor actor) {
		Map<String, Object> row = target(sq, actor);
		String id = (String) row.get("EMPLY_ID");
		require(!actor.id.equals(id), "내 계정은 삭제할 수 없습니다.");
		if (id != null) {
			for (Integer r : roleSet(row.get("ROLE_SQS"))) {
				system.removeRoleUser(r, id, actor.id);
			}
			mapper.unlinkStaff(id);
			mapper.deletePrefs(id);
		}
		mapper.deleteLoginTokens(sq);
		mapper.deleteAccount(sq);
	}

	/** SUSPEND, RESUME, RETIRE, RESTORE */
	private void setStatus(int sq, String action, Actor actor) {
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

	/** 권한이 하나라도 있으면 관리자 계정, 없으면 직원 계정. 바뀐 권한만 권한 규칙을 거쳐 넣고 뺀다 */
	private void applyRoles(int sq, String id, String type, Set<Integer> current, Set<Integer> next, Actor actor) {
		String want = next.isEmpty() ? STAFF : ADMIN;
		Map<String, Object> p = new HashMap<>();
		p.put("EMPLY_SQ", sq);
		p.put("TYPE_CD", want);
		if (ADMIN.equals(want) && !want.equals(type)) {
			mapper.updateType(p); // 권한을 넣기 전에 관리자 계정이어야 한다
		}
		for (Integer r : next) {
			if (!current.contains(r)) {
				system.addRoleUser(r, id, actor.id);
			}
		}
		for (Integer r : current) {
			if (!next.contains(r)) {
				system.removeRoleUser(r, id, actor.id);
			}
		}
		if (STAFF.equals(want) && !want.equals(type)) {
			require(!actor.id.equals(id), "내 계정의 권한은 바꿀 수 없습니다.");
			mapper.updateType(p);
		}
	}

	static Set<Integer> roleSet(Object csv) {
		Set<Integer> out = new HashSet<>();
		for (String s : String.valueOf(csv == null ? "" : csv).split(",")) {
			if (!s.trim().isEmpty()) {
				out.add(number(s));
			}
		}
		return out;
	}

	// ── 본인 비밀번호 ──

	/** current 가 null 이면 현재 비밀번호 확인을 건너뛴다. 초기 비밀번호로 방금 로그인한 세션에서만 null 로 부른다 */
	public void changeOwnPassword(String emplyId, String current, String next) {
		String hash = mapper.selectPasswordHash(emplyId);
		require(current == null || PasswordHasher.matches(current, hash), "현재 비밀번호가 맞지 않습니다.");
		require(!PasswordHasher.matches(next, hash), "아이디나 현재 비밀번호와 다르게 입력해 주세요.");
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
			String from = i == 11 ? SPECIALS : i % 4 == 3 ? DIGITS : LETTERS;
			b.append(from.charAt(RANDOM.nextInt(from.length())));
		}
		return b.toString();
	}

	static String passwordProblem(String id, String current, String next) {
		if (next == null || next.length() < 8 || next.length() > 72) { // bcrypt 는 72바이트까지만 비교한다
			return "새 비밀번호는 8~72자로 입력해 주세요.";
		}
		// 특수문자는 영문·숫자·공백이 아닌 모든 문자다. 대소문자는 bcrypt 비교에서 구분된다
		if (!next.matches(".*[A-Za-z].*") || !next.matches(".*[0-9].*") || !next.matches(".*[^A-Za-z0-9\\s].*")) {
			return "새 비밀번호에 영문, 숫자, 특수문자를 모두 넣어 주세요.";
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
