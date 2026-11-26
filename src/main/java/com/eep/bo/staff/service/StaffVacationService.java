package com.eep.bo.staff.service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

/**
 * 직원 휴가(인사카드 휴가 탭·홈 캘린더에서 등록). 기간·종류·유급/무급·메모.
 * 끝날짜가 없으면 기간 미정(화면은 오늘까지로 보인다). 반차는 하루(시작=끝)에 오전·오후.
 * 급여: 유급휴가는 지금처럼 「대기-유급휴가」 투입 건으로 계산하고, 화면에서 등록한(SRC_CD=USER) 무급휴가만 마감 전 달의 일할에서 뺀다.
 * 엑셀에서 옮긴 휴가(SRC_CD=EXCEL)는 이미 급여에 반영된 기록이라 급여 계산에 쓰지 않는다.
 * 투입현황 등 다른 화면은 range(from, to) 를 쓴다.
 */
@Service
public class StaffVacationService {

	private static final String DT = "\\d{4}-\\d{2}-\\d{2}";
	/** 종류 기본값(공통코드 HR_VAC_TYPE 이 없을 때). {코드, 이름, 기본 유급 여부} */
	public static final String[][] TYPES = { { "ANNUAL", "연차", "Y" }, { "HALF", "반차", "Y" }, { "SICK", "병가", "Y" }, { "FAMILY", "경조", "Y" }, { "PERSONAL", "개인사유", "N" },
			{ "MATERNITY", "출산휴가", "Y" }, { "PARENTAL", "육아휴직", "N" }, { "LEAVE", "무급휴직", "N" }, { "ETC", "기타", "N" } };

	private JdbcTemplate jdbc;

	@Autowired
	public void setDataSource(@Qualifier("dataSource") DataSource dataSource) { // dataSourceSpied 와 2개라 이름을 지정해야 기동된다
		jdbc = new JdbcTemplate(dataSource);
	}

	@javax.annotation.PostConstruct
	public void ensureSchema() {
		try {
			jdbc.execute("CREATE TABLE IF NOT EXISTS TB_EEP_HR_VACATION_R (VAC_SQ INT AUTO_INCREMENT PRIMARY KEY, STAFF_SQ INT NOT NULL, START_DT CHAR(10) NOT NULL,"
					+ " END_DT CHAR(10) NULL COMMENT '비면 기간 미정', HALF_CD VARCHAR(2) NULL COMMENT '반차 AM·PM(시작=끝)', VAC_CD VARCHAR(20) NOT NULL COMMENT '공통코드 HR_VAC_TYPE',"
					+ " PAID_YN CHAR(1) NOT NULL, MEMO VARCHAR(1000) NULL, SRC_CD VARCHAR(10) NOT NULL DEFAULT 'USER' COMMENT 'USER 화면 등록(무급은 급여 일할), EXCEL 엑셀에서 옮김(기록만)',"
					+ " SRC_REF VARCHAR(500) NULL COMMENT '엑셀 출처', UPDT_EMPLY_ID VARCHAR(50) NULL, UPDT_DT DATETIME NULL,"
					+ " KEY IX_VAC_STAFF (STAFF_SQ), KEY IX_VAC_START (START_DT)) COMMENT='직원 휴가'");
		} catch (RuntimeException e) {
			System.out.println("STAFF_VACATION_SCHEMA_ERROR " + e.getClass().getSimpleName());
		}
	}

	/** 한 직원의 휴가(최근 먼저). DAYS 는 일수(기간 미정은 오늘까지) */
	public List<Map<String, Object>> list(int staffSq) {
		return withDays(jdbc.queryForList("SELECT VAC_SQ, STAFF_SQ, START_DT, END_DT, HALF_CD, VAC_CD, PAID_YN, MEMO, SRC_CD, SRC_REF, UPDT_EMPLY_ID, DATE_FORMAT(UPDT_DT, '%Y-%m-%d') UPDT_DT"
				+ " FROM TB_EEP_HR_VACATION_R WHERE STAFF_SQ = ? ORDER BY START_DT DESC, VAC_SQ DESC", staffSq));
	}

	/** from~to 에 걸친 모든 직원 휴가(이름·소속 포함). 홈 캘린더·투입현황이 쓴다 */
	public List<Map<String, Object>> range(String from, String to) {
		date(from, "시작", true);
		date(to, "끝", true);
		return withDays(jdbc.queryForList("SELECT V.VAC_SQ, V.STAFF_SQ, S.STAFF_NM, S.ORG_NM, S.STATUS_CD, V.START_DT, V.END_DT, V.HALF_CD, V.VAC_CD, V.PAID_YN, V.MEMO, V.SRC_CD"
				+ " FROM TB_EEP_HR_VACATION_R V JOIN TB_EEP_HR_STAFF_M S ON S.STAFF_SQ = V.STAFF_SQ"
				+ " WHERE V.START_DT <= ? AND (V.END_DT IS NULL OR V.END_DT >= ?) ORDER BY V.START_DT, S.STAFF_NM", to, from));
	}

	private static List<Map<String, Object>> withDays(List<Map<String, Object>> rows) {
		LocalDate today = LocalDate.now();
		for (Map<String, Object> r : rows) r.put("DAYS", days(str(r.get("START_DT")), str(r.get("END_DT")), str(r.get("HALF_CD")), today));
		return rows;
	}

	/** 일수: 반차 0.5, 그 밖은 달력일(시작~끝, 끝이 없으면 오늘까지) */
	static double days(String start, String end, String half, LocalDate today) {
		if (half != null) return 0.5;
		LocalDate s = LocalDate.parse(start), e = end == null ? today : LocalDate.parse(end);
		return e.isBefore(s) ? 0 : ChronoUnit.DAYS.between(s, e) + 1;
	}

	/**
	 * 추가·수정. FORCE 가 Y 가 아니면 같은 직원의 다른 휴가와 겹칠 때 저장하지 않고 {OVERLAP: [겹친 휴가]} 를 돌려준다(화면이 확인 뒤 다시 보냄).
	 * 저장하면 {VAC_SQ}
	 */
	public Map<String, Object> save(Map<String, Object> p, String user) {
		int staffSq = num(p.get("STAFF_SQ"));
		if (staffSq <= 0 || jdbc.queryForObject("SELECT COUNT(*) FROM TB_EEP_HR_STAFF_M WHERE STAFF_SQ = ?", Integer.class, staffSq) == 0) throw new IllegalArgumentException("직원을 고르세요.");
		String start = str(p.get("START_DT")), end = str(p.get("END_DT")), half = str(p.get("HALF_CD")), cd = str(p.get("VAC_CD")), paid = str(p.get("PAID_YN")), memo = str(p.get("MEMO"));
		date(start, "시작일", true);
		date(end, "종료일", false);
		if (end != null && end.compareTo(start) < 0) throw new IllegalArgumentException("종료일이 시작일보다 빠릅니다.");
		if (half != null) {
			if (!half.equals("AM") && !half.equals("PM")) throw new IllegalArgumentException("반차는 오전·오후 중에서 고르세요.");
			end = start; // 반차는 하루
		}
		if (cd == null || cd.length() > 20) throw new IllegalArgumentException("종류를 고르세요.");
		if (!"Y".equals(paid) && !"N".equals(paid)) throw new IllegalArgumentException("유급·무급을 고르세요.");
		if (memo != null && memo.length() > 1000) throw new IllegalArgumentException("메모는 1000자까지 넣을 수 있습니다.");
		int vacSq = num(p.get("VAC_SQ"));
		String why = notAllowed(start, end, jdbc.queryForObject("SELECT LEAVE_DT FROM TB_EEP_HR_STAFF_M WHERE STAFF_SQ = ?", String.class, staffSq), spans(staffSq));
		if (why != null) throw new IllegalArgumentException(why);
		if (!"Y".equals(p.get("FORCE"))) {
			List<Map<String, Object>> over = jdbc.queryForList("SELECT VAC_SQ, START_DT, END_DT, VAC_CD, PAID_YN FROM TB_EEP_HR_VACATION_R WHERE STAFF_SQ = ? AND VAC_SQ <> ?"
					+ " AND START_DT <= ? AND (END_DT IS NULL OR END_DT >= ?)", staffSq, vacSq, end == null ? "9999-12-31" : end, start);
			if (!over.isEmpty()) {
				Map<String, Object> out = new HashMap<>();
				out.put("OVERLAP", over);
				return out;
			}
		}
		if (vacSq > 0) {
			if (jdbc.update("UPDATE TB_EEP_HR_VACATION_R SET START_DT = ?, END_DT = ?, HALF_CD = ?, VAC_CD = ?, PAID_YN = ?, MEMO = ?, UPDT_EMPLY_ID = ?, UPDT_DT = NOW() WHERE VAC_SQ = ? AND STAFF_SQ = ?",
					start, end, half, cd, paid, memo, user, vacSq, staffSq) == 0) throw new IllegalArgumentException("휴가를 찾지 못했습니다.");
		} else {
			jdbc.update("INSERT INTO TB_EEP_HR_VACATION_R (STAFF_SQ, START_DT, END_DT, HALF_CD, VAC_CD, PAID_YN, MEMO, SRC_CD, SRC_REF, UPDT_EMPLY_ID, UPDT_DT) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())",
					staffSq, start, end, half, cd, paid, memo, "EXCEL".equals(p.get("SRC_CD")) ? "EXCEL" : "USER", str(p.get("SRC_REF")), user);
			vacSq = jdbc.queryForObject("SELECT LAST_INSERT_ID()", Integer.class);
		}
		Map<String, Object> out = new HashMap<>();
		out.put("VAC_SQ", vacSq);
		return out;
	}

	/** 투입 건·계약 목록의 {형태, 시작, 끝(null=열림)}. 시작 순 */
	private List<String[]> spans(int staffSq) {
		List<String[]> out = new ArrayList<>();
		for (Map<String, Object> r : jdbc.queryForList("SELECT EMP_TYPE_CD T, DATE_FORMAT(START_DT, '%Y-%m-%d') S, DATE_FORMAT(END_DT, '%Y-%m-%d') E FROM TB_EEP_DEPLOY_R WHERE STAFF_SQ = ? AND START_DT IS NOT NULL"
				+ " UNION ALL SELECT EMP_TYPE_CD, START_DT, END_DT FROM TB_EEP_HR_CONTRACT_M WHERE STAFF_SQ = ? ORDER BY 2", staffSq, staffSq)) {
			out.add(new String[] { str(r.get("T")), str(r.get("S")), str(r.get("E")) });
		}
		return out;
	}

	private static boolean salaried(String t) {
		return "REGULAR".equals(t) || "PROBATION".equals(t);
	}

	/**
	 * 휴가를 등록할 수 없으면 그 까닭, 되면 null (2026-11-26 사용자 규칙).
	 * 퇴사일 뒤는 안 됨. 정규·수습은 시작일에 정규·수습 투입·계약이 걸쳐 있거나 앞뒤 투입이 정규·수습인 대기 기간이면 됨.
	 * 계약직·프리는 휴가 기간 전체가 한 투입·계약 기간 안일 때만(계약이 끝나면 휴가가 아니라 대기로 옮긴다).
	 * spans: {형태, 시작, 끝(null=열림)} 시작 순, end 가 null 이면 기간 미정
	 */
	static String notAllowed(String start, String end, String leaveDt, List<String[]> spans) {
		if (leaveDt != null && leaveDt.length() >= 10 && start.compareTo(leaveDt.substring(0, 10)) > 0) return "퇴사일(" + leaveDt.substring(0, 10) + ") 뒤에는 휴가를 등록할 수 없어요.";
		String[] prev = null, next = null;
		for (String[] s : spans) {
			boolean covers = s[1].compareTo(start) <= 0 && (s[2] == null || s[2].compareTo(start) >= 0);
			if (covers && salaried(s[0])) return null;
			if (covers && (s[2] == null || end != null && s[2].compareTo(end) >= 0)) return null; // 계약직·프리: 한 계약 안
			if (s[1].compareTo(start) < 0) prev = s;
			else if (next == null) next = s;
		}
		if (prev != null && salaried(prev[0]) && (next == null || salaried(next[0]))) return null; // 정규·수습의 투입 사이 대기
		return "휴가·휴직은 정규·수습이거나 계약 기간 안일 때만 등록할 수 있어요. 계약직·프리는 계약 기간 안의 날짜로 등록하고, 계약이 끝났으면 투입현황에서 대기로 옮겨 주세요.";
	}

	public void delete(int vacSq, int staffSq) {
		if (jdbc.update("DELETE FROM TB_EEP_HR_VACATION_R WHERE VAC_SQ = ? AND STAFF_SQ = ?", vacSq, staffSq) == 0) throw new IllegalArgumentException("휴가를 찾지 못했습니다.");
	}

	/** 직원 카드를 지울 때 */
	public void deleteAll(Object staffSq) {
		jdbc.update("DELETE FROM TB_EEP_HR_VACATION_R WHERE STAFF_SQ = ?", staffSq);
	}

	/**
	 * 급여 일할용: 그 달 화면에서 등록한 무급휴가. 직원 → [{START_DT, END_DT(기간 미정이면 그 달 말일), HALF(true/false)}]
	 * 엑셀에서 옮긴 휴가는 이미 급여에 반영돼 있어 넣지 않는다
	 */
	public Map<Object, List<Map<String, Object>>> unpaid(String ym) {
		YearMonth m = YearMonth.parse(ym);
		Map<Object, List<Map<String, Object>>> out = new HashMap<>();
		for (Map<String, Object> r : jdbc.queryForList("SELECT STAFF_SQ, START_DT, END_DT, HALF_CD FROM TB_EEP_HR_VACATION_R WHERE PAID_YN = 'N' AND SRC_CD = 'USER'"
				+ " AND START_DT <= ? AND (END_DT IS NULL OR END_DT >= ?)", m.atEndOfMonth().toString(), m.atDay(1).toString())) {
			if (r.get("END_DT") == null) r.put("END_DT", m.atEndOfMonth().toString());
			out.computeIfAbsent(r.get("STAFF_SQ"), k -> new ArrayList<>()).add(r);
		}
		return out;
	}

	/** 투입 기간(start~end, end 가 비면 열림)과 겹치는 무급휴가를 그 달 안에서 반일 단위로 센다(하루 = 2) */
	public static int unpaidHalfDays(List<Map<String, Object>> vacs, LocalDate start, LocalDate end, String ym) {
		if (vacs == null) return 0;
		YearMonth m = YearMonth.parse(ym);
		int half = 0;
		for (Map<String, Object> v : vacs) {
			LocalDate vs = LocalDate.parse(str(v.get("START_DT"))), ve = LocalDate.parse(str(v.get("END_DT")));
			LocalDate s = max(max(vs, start), m.atDay(1)), e = min(min(ve, end == null ? ve : end), m.atEndOfMonth());
			if (e.isBefore(s)) continue;
			half += v.get("HALF_CD") != null ? 1 : 2 * ((int) ChronoUnit.DAYS.between(s, e) + 1);
		}
		return half;
	}

	private static LocalDate max(LocalDate a, LocalDate b) {
		return a.isAfter(b) ? a : b;
	}

	private static LocalDate min(LocalDate a, LocalDate b) {
		return a.isBefore(b) ? a : b;
	}

	private static void date(String v, String label, boolean required) {
		if (v == null) {
			if (required) throw new IllegalArgumentException(label + "을 넣으세요.");
			return;
		}
		if (!v.matches(DT)) throw new IllegalArgumentException(label + " 형식이 올바르지 않습니다.");
		LocalDate.parse(v);
	}

	private static String str(Object o) {
		if (o == null) return null;
		String s = o.toString().trim();
		return s.isEmpty() ? null : s;
	}

	private static int num(Object o) {
		try {
			return o == null ? 0 : Integer.parseInt(o.toString().trim());
		} catch (NumberFormatException e) {
			return 0;
		}
	}
}
