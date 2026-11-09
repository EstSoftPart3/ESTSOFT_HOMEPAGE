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

import com.eep.mapper.BoStaffMapper;

import common.util.RrnCipher;

/** 직원관리(인사카드). 주민번호·계좌번호는 암호화해 저장하고 목록에는 가린 값만 보낸다 */
@Service
public class BoStaffService {

	private static final List<String> STATUS_CODES = Arrays.asList("WORK", "LEFT");
	/** 화면 칸 이름 -> 암호문 컬럼. 이 두 칸은 저장 때 암호화하고 원문은 따로 요청해야 보인다 */
	private static final Map<String, String> SECRET_COLS = new HashMap<>();
	static {
		SECRET_COLS.put("RRN", "RRN_ENC");
		SECRET_COLS.put("ACCOUNT", "ACCOUNT_ENC");
	}
	// 컬럼명이 SQL 에 그대로 들어가므로 허용 목록으로만 받는다
	private static final Set<String> TEXT_FIELDS = new HashSet<>(Arrays.asList(
			"SEQ_NO", "ORG_NM", "DEPT_NM", "POSITION_NM", "STAFF_NM", "PHONE", "EMAIL", "ADDR", "STATION", "JOIN_DT", "LEAVE_DT",
			"HS_NM", "HS_MAJOR", "HS_GRAD", "UNIV_NM", "UNIV_MAJOR", "UNIV_GRAD", "FINAL_EDU", "MIL_IN_DT", "MIL_OUT_DT", "MIL_EXEMPT",
			"EDU_NM", "EDU_START_DT", "EDU_END_DT", "EDU_ORG", "CERT_DT", "BANK_NM",
			"DOC_REG", "DOC_ID", "DOC_GRAD", "DOC_BANK", "DOC_PHOTO", "DOC_HI", "DOC_CONTRACT", "DOC_BIZ", "DOC_EI", "DOC_SEC",
			"DOC_EDU", "DOC_NEP", "DOC_PRIV", "DOC_CRIME", "DOC_MIL",
			"EMG_REL1", "EMG_TEL1", "EMG_REL2", "EMG_TEL2", "PREV_CAREER", "HOBBY", "LANG_SKILL", "SPECIALTY", "MEMO",
			"SCORE", "GAPIL_YN", "AUTO_APLY_YN", "GRADE_NM", "REAL_CAREER", "WISH_PRICE", "SK_FE", "SK_BE", "WORK_DOMAIN", "WISH_LOC",
			"ETC1", "SK_LANG", "REPORT", "SK_FW", "SK_DB", "SK_IDE", "SK_VCS", "ETC2", "EXPERTISE", "SK_OS"));

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
		BoStaffMapper.deleteStaff(param);
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
