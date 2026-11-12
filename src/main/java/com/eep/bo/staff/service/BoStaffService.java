package com.eep.bo.staff.service;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.eep.bo.member.service.BoMemberService;
import com.eep.mapper.BoStaffMapper;

import common.util.RrnCipher;

/** 직원관리(인사카드). 주민번호·계좌번호는 암호화해 저장하고 목록에는 가린 값만 보낸다 */
@Service
public class BoStaffService {

	private static final List<String> STATUS_CODES = Arrays.asList("WORK", "LEFT", "WAIT");
	private static final List<String> PRJ_ROLES = Arrays.asList("운영", "개발", "운영/개발");
	private static final String[] PRJ_OPTIONAL = { "IND_NM", "APP_NM", "MACHINE_NM", "OS_NM", "LANG_NM", "DBMS_NM", "TOOL_NM", "FRAMEWORK_NM", "ETC_NM" };
	private static final String YM = "\\d{4}-(0[1-9]|1[0-2])";
	private static final List<String> EDU_KINDS = Arrays.asList("검정고시", "고등학교(인문계)", "고등학교(실업계)", "대학교(2~3년제)", "대학교(4년제)", "사이버·방통대·학점은행제", "대학원(석사)", "대학원(박사)");
	private static final List<String> EDU_STATES = Arrays.asList("졸업", "재학", "휴학", "수료", "중퇴");
	/** 항목 -> 필수 칸 {컬럼, 이름} */
	private static final Map<String, String[][]> ITEM_REQUIRED = new HashMap<>();
	static {
		ITEM_REQUIRED.put("EDU", new String[][] { { "C1", "구분" }, { "C2", "학교명" } });
		ITEM_REQUIRED.put("TRAIN", new String[][] { { "C1", "교육·자격명" } });
		ITEM_REQUIRED.put("EMG", new String[][] { { "C1", "관계" }, { "C2", "연락처" } });
	}
	/** 화면 칸 이름 -> 암호문 컬럼. 이 두 칸은 저장 때 암호화하고 원문은 따로 요청해야 보인다 */
	private static final Map<String, String> SECRET_COLS = new HashMap<>();
	static {
		SECRET_COLS.put("RRN", "RRN_ENC");
		SECRET_COLS.put("ACCOUNT", "ACCOUNT_ENC");
	}
	// 컬럼명이 SQL 에 그대로 들어가므로 허용 목록으로만 받는다
	private static final Set<String> TEXT_FIELDS = new HashSet<>(Arrays.asList(
			"SEQ_NO", "ORG_NM", "DEPT_NM", "POSITION_NM", "STAFF_NM", "PHONE", "EMAIL", "COMPANY_EMAIL", "ADDR", "STATION", "JOIN_DT", "LEAVE_DT",
			"HS_NM", "HS_MAJOR", "HS_GRAD", "HS_KIND", "HS_STATE", "UNIV_NM", "UNIV_MAJOR", "UNIV_GRAD", "UNIV_KIND", "UNIV_STATE", "FINAL_EDU", "MIL_IN_DT", "MIL_OUT_DT", "MIL_EXEMPT",
			"EDU_NM", "EDU_START_DT", "EDU_END_DT", "EDU_ORG", "CERT_DT", "BANK_NM",
			"DOC_REG", "DOC_ID", "DOC_GRAD", "DOC_BANK", "DOC_PHOTO", "DOC_HI", "DOC_CONTRACT", "DOC_BIZ", "DOC_EI", "DOC_SEC",
			"DOC_EDU", "DOC_NEP", "DOC_PRIV", "DOC_CRIME", "DOC_MIL",
			"EMG_REL1", "EMG_TEL1", "EMG_REL2", "EMG_TEL2", "PREV_CAREER", "HOBBY", "LANG_SKILL", "SPECIALTY",
			"SCORE", "GAPIL_YN", "AUTO_APLY_YN", "GRADE_NM", "REAL_CAREER", "WISH_PRICE", "SK_FE", "SK_BE", "WORK_DOMAIN", "WISH_LOC",
			"ETC1", "SK_LANG", "REPORT", "SK_FW", "SK_DB", "SK_IDE", "SK_VCS", "ETC2", "EXPERTISE", "SK_OS", "EMPLY_ID"));

	@Autowired
	private BoStaffMapper BoStaffMapper;

	public List<Map<String, Object>> list() {
		List<Map<String, Object>> rows = BoStaffMapper.selectStaffList();
		for (Map<String, Object> r : rows) {
			r.put("RRN", RrnCipher.maskStored((String) r.remove("RRN_ENC")));
			r.put("ACCOUNT", RrnCipher.maskTailStored((String) r.remove("ACCOUNT_ENC")));
		}
		return rows;
	}

	/** 관리자가 눈 표시를 눌렀을 때만 원문을 돌려준다 */
	public String reveal(Map<String, Object> param) {
		String col = SECRET_COLS.get(str(param, "FIELD"));
		if (col == null) {
			throw new IllegalArgumentException("원문을 볼 수 없는 항목입니다.");
		}
		Map<String, Object> q = new HashMap<>();
		q.put("COL", col);
		q.put("STAFF_SQ", param.get("STAFF_SQ"));
		String stored = BoStaffMapper.selectStaffSecret(q);
		if (stored == null || stored.isEmpty()) {
			return "";
		}
		return RrnCipher.isEncrypted(stored) ? RrnCipher.decrypt(stored) : stored;
	}

	public void fieldSave(Map<String, Object> param) {
		String field = str(param, "FIELD"), value = str(param, "VALUE").trim();
		if (SECRET_COLS.containsKey(field)) {
			if (RrnCipher.isMasked(value)) {
				return; // 가린 값이 그대로 오면 바꾸지 않는다
			}
			param.put("FIELD", SECRET_COLS.get(field));
			// 서류 충돌 화면은 암호문을 돌려보낸다. 복호화해 다시 암호화하므로 위조된 값은 저장되지 않는다
			param.put("VALUE", value.isEmpty() ? "" : RrnCipher.encrypt(RrnCipher.isEncrypted(value) ? RrnCipher.decrypt(value) : value));
		} else if ("STATUS_CD".equals(field)) {
			if (!STATUS_CODES.contains(value)) {
				throw new IllegalArgumentException("재직 상태 값이 올바르지 않습니다.");
			}
		} else if (!TEXT_FIELDS.contains(field)) {
			throw new IllegalArgumentException("이 항목은 고칠 수 없습니다.");
		} else if ("STAFF_NM".equals(field) && value.isEmpty()) {
			throw new IllegalArgumentException("성명을 입력해 주세요.");
		} else if (("JOIN_DT".equals(field) || "LEAVE_DT".equals(field)) && !value.isEmpty()) {
			checkDate(value);
		} else if ("COMPANY_EMAIL".equals(field) && !value.isEmpty()) {
			String mail = BoMemberService.companyEmail(value);
			if (mail == null) {
				throw new IllegalArgumentException("회사 메일은 @gmail.com 주소만 쓸 수 있습니다.");
			}
			param.put("VALUE", mail);
		} else if ("EMPLY_ID".equals(field) && !value.isEmpty()) {
			Map<String, Object> check = BoStaffMapper.selectEmplyLinkCheck(param);
			if (((Number) check.get("ACCOUNT_CNT")).intValue() == 0) {
				throw new IllegalArgumentException("없는 로그인 계정입니다.");
			}
			if (((Number) check.get("TAKEN_CNT")).intValue() > 0) {
				throw new IllegalArgumentException("다른 인사카드에 연결된 계정입니다.");
			}
		}
		BoStaffMapper.updateStaffField(param);
	}

	public Object insert(Map<String, Object> param) {
		if (str(param, "STAFF_NM").trim().isEmpty()) {
			throw new IllegalArgumentException("성명을 입력해 주세요.");
		}
		if (!STATUS_CODES.contains(str(param, "STATUS_CD"))) {
			param.put("STATUS_CD", "WORK");
		}
		if (!str(param, "JOIN_DT").isEmpty()) {
			checkDate(str(param, "JOIN_DT"));
		}
		BoStaffMapper.insertStaff(param);
		return param.get("STAFF_SQ");
	}

	public void delete(Map<String, Object> param) {
		BoStaffMapper.deleteStaffPrjAll(param);
		BoStaffMapper.deleteStaffItemAll(param);
		BoStaffMapper.deleteStaff(param);
	}

	public List<Map<String, Object>> itemList(Map<String, Object> param) {
		return BoStaffMapper.selectStaffItemList(param);
	}

	public void itemSave(Map<String, Object> param) {
		checkItem(param);
		if (str(param, "ITEM_SQ").isEmpty()) {
			BoStaffMapper.insertStaffItem(param);
		} else {
			BoStaffMapper.updateStaffItem(param);
		}
	}

	public void itemDelete(Map<String, Object> param) {
		BoStaffMapper.deleteStaffItem(param);
	}

	/** 항목 종류·필수 칸을 확인하고 값을 다듬는다 */
	static void checkItem(Map<String, Object> param) {
		String item = str(param, "ITEM_CD");
		String[][] required = ITEM_REQUIRED.get(item);
		if (required == null) {
			throw new IllegalArgumentException("항목 종류가 올바르지 않습니다.");
		}
		for (String c : new String[] { "C1", "C2", "C3", "C4", "C5" }) {
			param.put(c, str(param, c).trim());
		}
		for (String[] r : required) {
			if (str(param, r[0]).isEmpty()) {
				throw new IllegalArgumentException(r[1] + "을(를) 입력해 주세요.");
			}
		}
		if ("EDU".equals(item) && !EDU_KINDS.contains(param.get("C1"))) {
			throw new IllegalArgumentException("학력 구분 값이 올바르지 않습니다.");
		}
		if ("EDU".equals(item) && !str(param, "C5").isEmpty() && !EDU_STATES.contains(param.get("C5"))) {
			throw new IllegalArgumentException("학력 상태 값이 올바르지 않습니다.");
		}
	}

	public List<Map<String, Object>> prjList(Map<String, Object> param) {
		return BoStaffMapper.selectStaffPrjList(param);
	}

	public void prjSave(Map<String, Object> param) {
		checkPrj(param);
		if (str(param, "PRJ_SQ").isEmpty()) {
			BoStaffMapper.insertStaffPrj(param);
		} else {
			BoStaffMapper.updateStaffPrj(param);
		}
	}

	public void prjDelete(Map<String, Object> param) {
		BoStaffMapper.deleteStaffPrj(param);
	}

	/** 필수 항목과 기간을 확인하고 값을 다듬는다. 진행중이면 END_YM 은 null */
	static void checkPrj(Map<String, Object> param) {
		String[][] required = { { "PRJ_NM", "프로젝트명" }, { "CLIENT_NM", "고객사" }, { "ROLE_NM", "역할" }, { "START_YM", "시작월" }, { "WORK_NM", "업무단" } };
		for (String[] r : required) {
			String v = str(param, r[0]).trim();
			if (v.isEmpty()) {
				throw new IllegalArgumentException(r[1] + "을(를) 입력해 주세요.");
			}
			param.put(r[0], v);
		}
		if (!PRJ_ROLES.contains(param.get("ROLE_NM"))) {
			throw new IllegalArgumentException("역할 값이 올바르지 않습니다.");
		}
		String start = (String) param.get("START_YM");
		if (!start.matches(YM)) {
			throw new IllegalArgumentException("시작월은 yyyy-MM 형식으로 입력해 주세요.");
		}
		if ("Y".equals(param.get("ONGOING_YN"))) {
			param.put("END_YM", null);
		} else {
			String end = str(param, "END_YM").trim();
			if (!end.matches(YM)) {
				throw new IllegalArgumentException("종료월을 선택하거나 진행중을 체크해 주세요.");
			}
			if (end.compareTo(start) < 0) {
				throw new IllegalArgumentException("종료월이 시작월보다 빠릅니다.");
			}
			param.put("END_YM", end);
		}
		for (String f : PRJ_OPTIONAL) {
			param.put(f, str(param, f).trim());
		}
	}

	private static void checkDate(String val) {
		try {
			LocalDate.parse(val);
		} catch (Exception e) {
			throw new IllegalArgumentException("날짜는 yyyy-MM-dd 형식으로 입력해 주세요.");
		}
	}

	private static String str(Map<String, Object> param, String key) {
		Object val = param.get(key);
		return val == null ? "" : val.toString();
	}
}
