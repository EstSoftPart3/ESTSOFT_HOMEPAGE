package com.eep.bo.hr.service;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import com.eep.bo.hr.dao.BoHrDao;
import com.eep.bo.staff.service.BoStaffService;
import com.eep.mapper.BoEquipmentMapper;
import com.eep.mapper.BoHrMapper;
import com.eep.mapper.BoStaffMapper;

@Service
public class BoHrServiceImpl implements BoHrService {

	private static final List<String> STATUS_CODES = Arrays.asList("ING", "END", "DROP");
	private static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");
	private static final List<String> SKILL_COLS = Arrays.asList("SK_JSP", "SK_THYMELEAF", "SK_VUE", "SK_REACT", "SK_NODE_FE",
			"SK_SPRING", "SK_JAVA", "SK_NODE_BE", "SK_NEXACRO", "SK_WEBSQUARE", "SK_EXBUILDER");
	private static final List<String> SKILL_VALS = Arrays.asList("", "상", "중", "하");
	private static final List<String> WEEK_CODES = Arrays.asList("1", "2", "3", "OVER");
	// 목록에서 바로 고칠 수 있는 글자 칸. 코드·날짜 칸은 각 저장 메서드에서 따로 검사한다
	private static final List<String> INTV_TEXT_FIELDS = Arrays.asList("APLY_NM", "INTV_TM", "PHONE", "JOIN_DT");
	private static final List<String> TRAINEE_TEXT_FIELDS = Arrays.asList("TRN_NM", "AGE", "INTERVIEW_AVAIL");
	// 항목별 코드 그룹. 비어 있거나 파라미터가 없으면 값 없음으로 저장한다
	private static final String[][] INTV_CODES = { { "GENDER", "HR_GENDER" }, { "APLY_ROUTE", "HR_ROUTE" }, { "ATTEND_ST", "HR_ATTEND" },
			{ "RESULT_ST", "HR_RESULT" }, { "NOTICE_ST", "HR_NOTICE" }, { "JOIN_ST", "HR_JOIN" }, { "LOCAL_YN", "HR_LOCAL" }, { "LANG", "HR_LANG" } };
	private static final String[][] TRAINEE_CODES = { { "LEAVE_NOTE", "HR_LEAVE" }, { "GENDER", "HR_GENDER" }, { "INTERVIEW_YN", "HR_INTERVIEW" },
			{ "LOCAL_YN", "HR_LOCAL" }, { "EARLY_YN", "HR_OXT" }, { "SPECIAL_YN", "HR_OXT" }, { "LANG", "HR_LANG" } };

	@Autowired
	private BoHrDao BoHrDao;
	@Autowired
	private BoHrMapper hrMapper;
	@Autowired
	private BoStaffMapper staffMapper;
	@Autowired
	private BoEquipmentMapper eqpMapper;
	@Autowired
	private BoStaffService staffService;

	private TransactionTemplate tx;

	@Autowired
	public void setDataSource(@Qualifier("dataSource") DataSource ds) { // dataSourceSpied 와 2개라 이름을 지정해야 기동된다
		tx = new TransactionTemplate(new DataSourceTransactionManager(ds));
	}

	@Override
	public List<Map<String, Object>> CodeList() {
		return BoHrDao.CodeList();
	}

	@Override
	public List<Map<String, Object>> IntvList() {
		return BoHrDao.IntvList();
	}

	@Override
	public void IntvSave(Map<String, Object> param) {
		require(param, "APLY_NM", "이름을 입력해 주세요.");
		checkDate(param, "INTV_DT", "면접일자");
		checkCodes(param, INTV_CODES);
		// 추천·소개가 아니면 숨겨진 칸에 남은 추천자명을 저장하지 않는다
		if (!"REFERRAL".equals(param.get("APLY_ROUTE"))) {
			param.put("REFERRER", null);
		}
		if (str(param, "INTV_SQ").isEmpty()) {
			BoHrDao.IntvInsert(param);
		} else {
			BoHrDao.IntvUpdate(param);
		}
	}

	@Override
	public void IntvDelete(Map<String, Object> param) {
		BoHrDao.IntvDelete(param);
	}

	@Override
	public boolean TraineeFromIntv(Map<String, Object> param) {
		return tx.execute(s -> {
			if (BoHrDao.TraineeFromIntv(param) == 0) return false;
			staffMapper.insertWaitFromTrainee(param); // 교육진행중으로 들어오므로 대기 카드를 만든다(INTV_SQ 로 찾음)
			return true;
		});
	}

	@Override
	public List<Map<String, Object>> TraineeList() {
		return BoHrDao.TraineeList();
	}

	@Override
	public void TraineeSave(Map<String, Object> param) {
		require(param, "TRN_NM", "이름을 입력해 주세요.");
		checkDate(param, "EDU_START_DT", "교육 시작일");
		if (!STATUS_CODES.contains(str(param, "STATUS_CD"))) {
			throw new IllegalArgumentException("상태를 선택해 주세요.");
		}
		checkCodes(param, TRAINEE_CODES);
		String from = str(param, "TRN_SQ").isEmpty() ? null : hrMapper.selectTraineeStatus(param);
		tx.execute(s -> {
			if (str(param, "TRN_SQ").isEmpty()) {
				BoHrDao.TraineeInsert(param);
			} else {
				BoHrDao.TraineeUpdate(param);
			}
			syncStaff(param.get("TRN_SQ"), from, str(param, "STATUS_CD"), param);
			return null;
		});
	}

	@Override
	public void TraineeFieldSave(Map<String, Object> param) {
		String field = str(param, "FIELD"), value = str(param, "VALUE");
		// 컬럼명이 SQL 에 그대로 들어가므로 허용 목록으로만 받는다
		if (!TRAINEE_TEXT_FIELDS.contains(field) && !hasCodeField(TRAINEE_CODES, field) && !"STATUS_CD".equals(field) && !"EDU_WEEK".equals(field) && !"EDU_START_DT".equals(field)) {
			throw new IllegalArgumentException("이 항목은 목록에서 고칠 수 없습니다.");
		}
		if ("TRN_NM".equals(field) && value.trim().isEmpty()) {
			throw new IllegalArgumentException("이름을 입력해 주세요.");
		}
		if ("STATUS_CD".equals(field) && !STATUS_CODES.contains(value)) {
			throw new IllegalArgumentException("상태 값이 올바르지 않습니다.");
		}
		if ("EDU_WEEK".equals(field) && !WEEK_CODES.contains(value)) {
			throw new IllegalArgumentException("주차 값이 올바르지 않습니다.");
		}
		if ("EDU_START_DT".equals(field)) {
			checkDate(param, "VALUE", "교육 시작일");
		}
		checkFieldCode(TRAINEE_CODES, field, param);
		if (!"STATUS_CD".equals(field)) {
			BoHrDao.TraineeFieldUpdate(param);
			return;
		}
		String from = hrMapper.selectTraineeStatus(param);
		tx.execute(s -> {
			BoHrDao.TraineeFieldUpdate(param);
			syncStaff(param.get("TRN_SQ"), from, value, param);
			return null;
		});
	}

	/** 교육생 상태가 바뀌면 직원관리 대기 카드를 맞춘다. 교육종료·중도이탈은 대기 카드의 대여 장비를 반납하고, 중도이탈은 대기 카드를 지운다 */
	private void syncStaff(Object trnSq, String from, String to, Map<String, Object> param) {
		if (trnSq == null || to.equals(from)) return;
		Map<String, Object> key = new HashMap<>();
		key.put("TRN_SQ", trnSq);
		key.put("UPDT_EMPLY_ID", param.get("UPDT_EMPLY_ID"));
		Map<String, Object> staff = staffMapper.selectStaffByTrainee(key);
		// 이미 계약해 재직 등으로 옮긴 카드는 건드리지 않는다
		boolean waiting = staff != null && "WAIT".equals(staff.get("STATUS_CD"));
		if (waiting && !"ING".equals(to)) {
			Map<String, Object> s = new HashMap<>();
			s.put("STAFF_SQ", staff.get("STAFF_SQ"));
			List<Map<String, Object>> rents = eqpMapper.selectStaffEquipment(s);
			if (!rents.isEmpty()) {
				if (!"Y".equals(param.get("RETURN_YN"))) throw new NeedReturn(rents);
				s.put("END_DT", LocalDate.now(SEOUL).toString());
				s.put("UPDT_EMPLY_ID", param.get("UPDT_EMPLY_ID"));
				s.put("CONTENT", "교육생 " + ("END".equals(to) ? "교육종료" : "중도이탈") + " 처리로 자동 반납");
				eqpMapper.insertReturnMemoByStaff(s);
				eqpMapper.updateEquipmentReturnedByStaff(s);
				eqpMapper.closeRentsByStaff(s);
			}
		}
		if (!"DROP".equals(to)) {
			staffMapper.insertWaitFromTrainee(key);
		} else if (waiting) {
			Map<String, Object> s = new HashMap<>();
			s.put("STAFF_SQ", staff.get("STAFF_SQ"));
			staffService.delete(s);
		}
	}

	@Override
	public void IntvFieldSave(Map<String, Object> param) {
		String field = str(param, "FIELD"), value = str(param, "VALUE");
		if (!INTV_TEXT_FIELDS.contains(field) && !hasCodeField(INTV_CODES, field) && !"INTV_DT".equals(field)) {
			throw new IllegalArgumentException("이 항목은 목록에서 고칠 수 없습니다.");
		}
		if ("APLY_NM".equals(field) && value.trim().isEmpty()) {
			throw new IllegalArgumentException("이름을 입력해 주세요.");
		}
		if ("INTV_DT".equals(field)) {
			checkDate(param, "VALUE", "면접일자");
		}
		checkFieldCode(INTV_CODES, field, param);
		BoHrDao.IntvFieldUpdate(param);
		// 추천·소개가 아니게 되면 남은 추천자명을 지운다
		if ("APLY_ROUTE".equals(field) && !"REFERRAL".equals(value)) {
			BoHrDao.IntvReferrerClear(param);
		}
	}

	private static boolean hasCodeField(String[][] fields, String field) {
		return Arrays.stream(fields).anyMatch(f -> f[0].equals(field));
	}

	private void checkFieldCode(String[][] fields, String field, Map<String, Object> param) {
		for (String[] f : fields) {
			if (f[0].equals(field)) {
				Map<String, Object> one = new java.util.HashMap<>();
				one.put(field, param.get("VALUE"));
				checkCodes(one, new String[][] { f });
			}
		}
	}

	@Override
	public void TraineeSkillSave(Map<String, Object> param) {
		// 컬럼명이 SQL 에 그대로 들어가므로 허용 목록으로만 받는다
		if (!SKILL_COLS.contains(str(param, "SKILL_COL")) || !SKILL_VALS.contains(str(param, "SKILL_VAL"))) {
			throw new IllegalArgumentException("기술 평가 값이 올바르지 않습니다.");
		}
		BoHrDao.TraineeSkillUpdate(param);
	}

	@Override
	public void TraineeDelete(Map<String, Object> param) {
		String from = hrMapper.selectTraineeStatus(param);
		tx.execute(s -> {
			syncStaff(param.get("TRN_SQ"), from, "DROP", param); // 삭제도 중도이탈처럼 대기 카드를 정리한다
			BoHrDao.TraineeDelete(param);
			return null;
		});
	}

	private void checkCodes(Map<String, Object> param, String[][] fields) {
		List<Map<String, Object>> codes = BoHrDao.CodeList();
		for (String[] field : fields) {
			String vals = str(param, field[0]);
			// 외국어처럼 여러 개를 고르는 칸은 코드를 쉼표로 이어 보낸다
			for (String val : vals.isEmpty() ? new String[0] : vals.split(",")) {
				if (codes.stream().noneMatch(c -> field[1].equals(c.get("GRP")) && val.equals(c.get("CD")))) {
					throw new IllegalArgumentException("선택할 수 없는 값입니다: " + val);
				}
			}
		}
	}

	private static void require(Map<String, Object> param, String key, String message) {
		if (str(param, key).trim().isEmpty()) {
			throw new IllegalArgumentException(message);
		}
	}

	private static void checkDate(Map<String, Object> param, String key, String label) {
		String val = str(param, key);
		if (!val.isEmpty()) {
			try {
				LocalDate.parse(val);
			} catch (Exception e) {
				throw new IllegalArgumentException(label + "는 yyyy-MM-dd 형식으로 입력해 주세요.");
			}
		}
	}

	private static String str(Map<String, Object> param, String key) {
		Object val = param.get(key);
		return val == null ? "" : val.toString();
	}
}
