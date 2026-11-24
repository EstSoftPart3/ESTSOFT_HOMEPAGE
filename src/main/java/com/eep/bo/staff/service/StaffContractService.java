package com.eep.bo.staff.service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import com.common.upload.Upload;

/**
 * 인사카드 계약 목록: 계약(형태·기간·연봉·월 급여) 여러 건, 계약 안의 급여 변경 줄, 계약·변경마다 첨부(계약서).
 * 계약의 금액은 시작 때 값이고, 지금 값은 마지막 변경 줄이다. 진행 중 계약의 상여는 직원관리 상여 칩(TB_EEP_BONUS_STAFF_R)을 그대로 쓴다.
 * 인사카드 입사·퇴사일(JOIN_DT·LEAVE_DT)은 급여·상여·세무 자료가 쓰므로 여기서 바꾸지 않는다.
 */
@Service
public class StaffContractService {

	private static final String DT = "\\d{4}-\\d{2}-\\d{2}";
	private static final long FILE_MAX = 15L * 1024 * 1024; // MEDIUMBLOB 16MB 안쪽

	private JdbcTemplate jdbc;
	private TransactionTemplate tx;

	@Autowired
	public void setDataSource(@Qualifier("dataSource") DataSource dataSource) { // dataSourceSpied 와 2개라 이름을 지정해야 기동된다
		jdbc = new JdbcTemplate(dataSource);
		tx = new TransactionTemplate(new DataSourceTransactionManager(dataSource));
	}

	@javax.annotation.PostConstruct
	public void ensureSchema() {
		try {
			jdbc.execute("CREATE TABLE IF NOT EXISTS TB_EEP_HR_CONTRACT_M (CONTRACT_SQ INT AUTO_INCREMENT PRIMARY KEY, STAFF_SQ INT NOT NULL, EMP_TYPE_CD VARCHAR(20) NOT NULL,"
					+ " START_DT CHAR(10) NOT NULL, END_DT CHAR(10) NULL, PROB_END_DT CHAR(10) NULL COMMENT '수습 종료일', ANNUAL_AMT BIGINT NULL, MONTH_AMT BIGINT NULL COMMENT '시작 때 월 급여(지금 값은 마지막 변경 줄)',"
					+ " BONUS_NOTE VARCHAR(500) NULL COMMENT '상여 조건 메모(진행 중 계약은 직원관리 상여 칩)', MEMO VARCHAR(500) NULL, SRC_CD VARCHAR(10) NOT NULL DEFAULT 'USER' COMMENT 'USER 직접, AUTO 투입현황에서 채움',"
					+ " UPDT_EMPLY_ID VARCHAR(50) NULL, UPDT_DT DATETIME NULL, KEY IX_CONTRACT_STAFF (STAFF_SQ)) COMMENT='인사카드 계약'");
			jdbc.execute("CREATE TABLE IF NOT EXISTS TB_EEP_HR_CONTRACT_CHG_R (CHG_SQ INT AUTO_INCREMENT PRIMARY KEY, CONTRACT_SQ INT NOT NULL, APPLY_DT CHAR(10) NOT NULL,"
					+ " REASON VARCHAR(50) NOT NULL, ANNUAL_AMT BIGINT NULL, MONTH_AMT BIGINT NULL, BONUS_NOTE VARCHAR(500) NULL, MEMO VARCHAR(500) NULL, SRC_CD VARCHAR(10) NOT NULL DEFAULT 'USER',"
					+ " UPDT_EMPLY_ID VARCHAR(50) NULL, UPDT_DT DATETIME NULL, KEY IX_CHG_CONTRACT (CONTRACT_SQ)) COMMENT='계약 안의 급여·연봉·상여 변경'");
			jdbc.execute("CREATE TABLE IF NOT EXISTS TB_EEP_HR_CONTRACT_FILE_R (FILE_SQ INT AUTO_INCREMENT PRIMARY KEY, CONTRACT_SQ INT NOT NULL, CHG_SQ INT NULL COMMENT '변경 줄 첨부면 번호',"
					+ " FILE_NM VARCHAR(300) NOT NULL, FILE_TYPE VARCHAR(100) NULL, FILE_SIZE INT NOT NULL, FILE_DATA MEDIUMBLOB NOT NULL, UPDT_EMPLY_ID VARCHAR(50) NULL, UPDT_DT DATETIME NULL,"
					+ " KEY IX_FILE_CONTRACT (CONTRACT_SQ)) COMMENT='계약서·연봉계약서 첨부'");
		} catch (RuntimeException e) {
			System.out.println("STAFF_CONTRACT_SCHEMA_ERROR " + e.getClass().getSimpleName());
		}
	}

	/** 계약 목록(최근 시작 먼저). 각 계약에 CHANGES(최근 먼저), FILES(파일 내용 없이) */
	public List<Map<String, Object>> list(int staffSq) {
		List<Map<String, Object>> cs = jdbc.queryForList("SELECT CONTRACT_SQ, EMP_TYPE_CD, START_DT, END_DT, PROB_END_DT, ANNUAL_AMT, MONTH_AMT, BONUS_NOTE, MEMO, SRC_CD"
				+ " FROM TB_EEP_HR_CONTRACT_M WHERE STAFF_SQ = ? ORDER BY START_DT DESC, CONTRACT_SQ DESC", staffSq);
		if (cs.isEmpty()) return cs;
		List<Map<String, Object>> chg = jdbc.queryForList("SELECT G.CHG_SQ, G.CONTRACT_SQ, G.APPLY_DT, G.REASON, G.ANNUAL_AMT, G.MONTH_AMT, G.BONUS_NOTE, G.MEMO FROM TB_EEP_HR_CONTRACT_CHG_R G"
				+ " JOIN TB_EEP_HR_CONTRACT_M C ON C.CONTRACT_SQ = G.CONTRACT_SQ WHERE C.STAFF_SQ = ? ORDER BY G.APPLY_DT DESC, G.CHG_SQ DESC", staffSq);
		List<Map<String, Object>> files = jdbc.queryForList("SELECT F.FILE_SQ, F.CONTRACT_SQ, F.CHG_SQ, F.FILE_NM, F.FILE_TYPE, F.FILE_SIZE FROM TB_EEP_HR_CONTRACT_FILE_R F"
				+ " JOIN TB_EEP_HR_CONTRACT_M C ON C.CONTRACT_SQ = F.CONTRACT_SQ WHERE C.STAFF_SQ = ? ORDER BY F.FILE_SQ", staffSq);
		Map<Object, Map<String, Object>> by = new LinkedHashMap<>();
		for (Map<String, Object> c : cs) {
			c.put("CHANGES", new ArrayList<Map<String, Object>>());
			c.put("FILES", new ArrayList<Map<String, Object>>());
			by.put(c.get("CONTRACT_SQ"), c);
		}
		for (Map<String, Object> g : chg) add(by.get(g.get("CONTRACT_SQ")), "CHANGES", g);
		for (Map<String, Object> f : files) add(by.get(f.get("CONTRACT_SQ")), "FILES", f);
		return cs;
	}

	@SuppressWarnings("unchecked")
	private static void add(Map<String, Object> c, String key, Map<String, Object> row) {
		if (c != null) ((List<Map<String, Object>>) c.get(key)).add(row);
	}

	/** 계약 추가·수정. 돌려주는 값은 계약 번호 */
	public int saveContract(Map<String, Object> p, String user) {
		int staffSq = num(p.get("STAFF_SQ"));
		String type = str(p.get("EMP_TYPE_CD")), start = str(p.get("START_DT")), end = str(p.get("END_DT")), prob = str(p.get("PROB_END_DT"));
		if (type == null) throw new IllegalArgumentException("형태를 고르세요.");
		date(start, "시작일", true);
		date(end, "종료일", false);
		date(prob, "수습 종료일", false);
		if (end != null && end.compareTo(start) < 0) throw new IllegalArgumentException("종료일이 시작일보다 빠릅니다.");
		Object[] v = { type, start, end, prob, amt(p.get("ANNUAL_AMT")), amt(p.get("MONTH_AMT")), cut(p.get("BONUS_NOTE")), cut(p.get("MEMO")), user };
		Integer sq = str(p.get("CONTRACT_SQ")) == null ? null : num(p.get("CONTRACT_SQ"));
		if (sq == null) {
			return tx.execute(s -> {
				jdbc.update("INSERT INTO TB_EEP_HR_CONTRACT_M (EMP_TYPE_CD, START_DT, END_DT, PROB_END_DT, ANNUAL_AMT, MONTH_AMT, BONUS_NOTE, MEMO, UPDT_EMPLY_ID, UPDT_DT, STAFF_SQ, SRC_CD)"
						+ " VALUES (?,?,?,?,?,?,?,?,?,NOW(),?,'USER')", plus(v, staffSq));
				return jdbc.queryForObject("SELECT LAST_INSERT_ID()", Integer.class);
			});
		}
		own(sq, staffSq);
		jdbc.update("UPDATE TB_EEP_HR_CONTRACT_M SET EMP_TYPE_CD = ?, START_DT = ?, END_DT = ?, PROB_END_DT = ?, ANNUAL_AMT = ?, MONTH_AMT = ?, BONUS_NOTE = ?, MEMO = ?, UPDT_EMPLY_ID = ?, UPDT_DT = NOW()"
				+ " WHERE CONTRACT_SQ = ? AND STAFF_SQ = ?", plus(plus(v, sq), staffSq));
		return sq;
	}

	public void deleteContract(int contractSq, int staffSq) {
		own(contractSq, staffSq);
		tx.execute(s -> {
			jdbc.update("DELETE FROM TB_EEP_HR_CONTRACT_FILE_R WHERE CONTRACT_SQ = ?", contractSq);
			jdbc.update("DELETE FROM TB_EEP_HR_CONTRACT_CHG_R WHERE CONTRACT_SQ = ?", contractSq);
			return jdbc.update("DELETE FROM TB_EEP_HR_CONTRACT_M WHERE CONTRACT_SQ = ?", contractSq);
		});
	}

	/** 급여 변경 줄 추가·수정. 돌려주는 값은 변경 번호 */
	public int saveChange(Map<String, Object> p, String user) {
		int contractSq = num(p.get("CONTRACT_SQ")), staffSq = num(p.get("STAFF_SQ"));
		own(contractSq, staffSq);
		String apply = str(p.get("APPLY_DT")), reason = str(p.get("REASON"));
		date(apply, "적용일", true);
		if (reason == null) throw new IllegalArgumentException("사유를 고르세요.");
		Object[] v = { apply, reason.length() > 50 ? reason.substring(0, 50) : reason, amt(p.get("ANNUAL_AMT")), amt(p.get("MONTH_AMT")), cut(p.get("BONUS_NOTE")), cut(p.get("MEMO")), user };
		Integer sq = str(p.get("CHG_SQ")) == null ? null : num(p.get("CHG_SQ"));
		if (sq == null) {
			return tx.execute(s -> {
				jdbc.update("INSERT INTO TB_EEP_HR_CONTRACT_CHG_R (APPLY_DT, REASON, ANNUAL_AMT, MONTH_AMT, BONUS_NOTE, MEMO, UPDT_EMPLY_ID, UPDT_DT, CONTRACT_SQ) VALUES (?,?,?,?,?,?,?,NOW(),?)", plus(v, contractSq));
				return jdbc.queryForObject("SELECT LAST_INSERT_ID()", Integer.class);
			});
		}
		if (jdbc.update("UPDATE TB_EEP_HR_CONTRACT_CHG_R SET APPLY_DT = ?, REASON = ?, ANNUAL_AMT = ?, MONTH_AMT = ?, BONUS_NOTE = ?, MEMO = ?, UPDT_EMPLY_ID = ?, UPDT_DT = NOW() WHERE CHG_SQ = ? AND CONTRACT_SQ = ?",
				plus(plus(v, sq), contractSq)) == 0) throw new IllegalArgumentException("변경 줄을 찾지 못했습니다.");
		return sq;
	}

	public void deleteChange(int chgSq, int contractSq, int staffSq) {
		own(contractSq, staffSq);
		tx.execute(s -> {
			jdbc.update("DELETE FROM TB_EEP_HR_CONTRACT_FILE_R WHERE CHG_SQ = ? AND CONTRACT_SQ = ?", chgSq, contractSq);
			return jdbc.update("DELETE FROM TB_EEP_HR_CONTRACT_CHG_R WHERE CHG_SQ = ? AND CONTRACT_SQ = ?", chgSq, contractSq);
		});
	}

	/** 첨부. 변경 줄 첨부면 chgSq, 계약 첨부면 null */
	public int addFile(int contractSq, Integer chgSq, int staffSq, Upload u, String user) {
		own(contractSq, staffSq);
		if (chgSq != null && jdbc.queryForObject("SELECT COUNT(*) FROM TB_EEP_HR_CONTRACT_CHG_R WHERE CHG_SQ = ? AND CONTRACT_SQ = ?", Integer.class, chgSq, contractSq) == 0)
			throw new IllegalArgumentException("변경 줄을 찾지 못했습니다.");
		if (u.data.length > FILE_MAX) throw new IllegalArgumentException("15MB 이하 파일만 붙일 수 있습니다.");
		return tx.execute(s -> {
			jdbc.update("INSERT INTO TB_EEP_HR_CONTRACT_FILE_R (CONTRACT_SQ, CHG_SQ, FILE_NM, FILE_TYPE, FILE_SIZE, FILE_DATA, UPDT_EMPLY_ID, UPDT_DT) VALUES (?,?,?,?,?,?,?,NOW())",
					contractSq, chgSq, u.name, u.mime, u.data.length, u.data, user);
			return jdbc.queryForObject("SELECT LAST_INSERT_ID()", Integer.class);
		});
	}

	/** 파일 하나(FILE_NM·FILE_TYPE·FILE_DATA). 다른 직원의 파일이면 없는 것처럼 막는다 */
	public Map<String, Object> file(int fileSq, int staffSq) {
		List<Map<String, Object>> l = jdbc.queryForList("SELECT F.FILE_NM, F.FILE_TYPE, F.FILE_DATA FROM TB_EEP_HR_CONTRACT_FILE_R F JOIN TB_EEP_HR_CONTRACT_M C ON C.CONTRACT_SQ = F.CONTRACT_SQ"
				+ " WHERE F.FILE_SQ = ? AND C.STAFF_SQ = ?", fileSq, staffSq);
		if (l.isEmpty()) throw new IllegalArgumentException("파일을 찾지 못했습니다.");
		return l.get(0);
	}

	public void deleteFile(int fileSq, int staffSq) {
		if (jdbc.update("DELETE F FROM TB_EEP_HR_CONTRACT_FILE_R F JOIN TB_EEP_HR_CONTRACT_M C ON C.CONTRACT_SQ = F.CONTRACT_SQ WHERE F.FILE_SQ = ? AND C.STAFF_SQ = ?", fileSq, staffSq) == 0)
			throw new IllegalArgumentException("파일을 찾지 못했습니다.");
	}

	/** 직원 삭제 때 같이 지운다 */
	public void deleteAll(Object staffSq) {
		tx.execute(s -> {
			jdbc.update("DELETE F FROM TB_EEP_HR_CONTRACT_FILE_R F JOIN TB_EEP_HR_CONTRACT_M C ON C.CONTRACT_SQ = F.CONTRACT_SQ WHERE C.STAFF_SQ = ?", staffSq);
			jdbc.update("DELETE G FROM TB_EEP_HR_CONTRACT_CHG_R G JOIN TB_EEP_HR_CONTRACT_M C ON C.CONTRACT_SQ = G.CONTRACT_SQ WHERE C.STAFF_SQ = ?", staffSq);
			return jdbc.update("DELETE FROM TB_EEP_HR_CONTRACT_M WHERE STAFF_SQ = ?", staffSq);
		});
	}

	private void own(int contractSq, int staffSq) {
		if (jdbc.queryForObject("SELECT COUNT(*) FROM TB_EEP_HR_CONTRACT_M WHERE CONTRACT_SQ = ? AND STAFF_SQ = ?", Integer.class, contractSq, staffSq) == 0)
			throw new IllegalArgumentException("계약을 찾지 못했습니다.");
	}

	private static Object[] plus(Object[] a, Object b) {
		Object[] o = Arrays.copyOf(a, a.length + 1);
		o[a.length] = b;
		return o;
	}

	private static void date(String v, String label, boolean required) {
		if (v == null) {
			if (required) throw new IllegalArgumentException(label + "을 넣으세요.");
			return;
		}
		if (!v.matches(DT)) throw new IllegalArgumentException(label + "은 YYYY-MM-DD 로 넣으세요.");
	}

	private static String str(Object o) {
		String s = o == null ? null : o.toString().trim();
		return s == null || s.isEmpty() ? null : s;
	}

	private static String cut(Object o) {
		String s = str(o);
		return s != null && s.length() > 500 ? s.substring(0, 500) : s;
	}

	static Long amt(Object o) {
		String s = str(o);
		if (s == null) return null;
		s = s.replaceAll("[,\\s원]", "");
		if (!s.matches("\\d{1,12}")) throw new IllegalArgumentException("금액은 숫자로 넣으세요.");
		return Long.parseLong(s);
	}

	private static int num(Object o) {
		String s = str(o);
		if (s == null || !s.matches("\\d+")) throw new IllegalArgumentException("번호가 올바르지 않습니다.");
		return Integer.parseInt(s);
	}
}
