package com.eep.bo.my;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.PostConstruct;
import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

/**
 * 관리자 홈 달력의 개인 할 일(본인만 보고 고친다). 반복 회차는 화면이 펼치고, 여기에는 규칙과 회차별 완료(DONE_DTS)·빠진 날(SKIP_DTS)만 둔다.
 * RPT_CD: NONE·DAY·WEEK(RPT_DOW 의 요일 0=일~6=토)·MONTH(시작일과 같은 날). 기간 할 일(START_DT~END_DT)도 회차마다 같은 길이로 반복한다.
 */
@Service
public class MyTaskService {

	static final Set<String> RPT = new LinkedHashSet<>(Arrays.asList("NONE", "DAY", "WEEK", "MONTH"));
	static final String COLS = "TASK_SQ, TITLE, DATE_FORMAT(START_DT, '%Y-%m-%d') START_DT, DATE_FORMAT(END_DT, '%Y-%m-%d') END_DT, ALL_DAY, START_TM, END_TM, MEMO,"
			+ " RPT_CD, RPT_DOW, DATE_FORMAT(RPT_UNTIL, '%Y-%m-%d') RPT_UNTIL, DONE_DTS, SKIP_DTS";

	private JdbcTemplate jdbc;

	@Autowired
	public void setDataSource(@Qualifier("dataSource") DataSource ds) { // dataSourceSpied 와 2개라 이름을 지정해야 기동된다
		jdbc = new JdbcTemplate(ds);
	}

	@PostConstruct
	public void ensureSchema() {
		try {
			jdbc.execute("CREATE TABLE IF NOT EXISTS TB_EEP_MY_TASK_R (TASK_SQ INT NOT NULL AUTO_INCREMENT PRIMARY KEY, EMPLY_ID VARCHAR(50) NOT NULL,"
					+ " TITLE VARCHAR(100) NOT NULL, START_DT DATE NOT NULL, END_DT DATE NOT NULL, ALL_DAY CHAR(1) NOT NULL DEFAULT 'Y', START_TM VARCHAR(5) NULL, END_TM VARCHAR(5) NULL,"
					+ " MEMO VARCHAR(2000) NULL, RPT_CD VARCHAR(10) NOT NULL DEFAULT 'NONE', RPT_DOW VARCHAR(7) NULL, RPT_UNTIL DATE NULL,"
					+ " DONE_DTS TEXT NULL, SKIP_DTS TEXT NULL, REG_DT DATETIME NOT NULL, UPDT_DT DATETIME NULL, KEY IX_MY_TASK (EMPLY_ID))"
					+ " DEFAULT CHARSET=utf8mb4 COMMENT='관리자 홈 개인 할 일'");
		} catch (RuntimeException e) {
			System.out.println("MY_TASK_SCHEMA_ERROR " + e.getClass().getSimpleName());
		}
	}

	public List<Map<String, Object>> list(String user) {
		return jdbc.queryForList("SELECT " + COLS + " FROM TB_EEP_MY_TASK_R WHERE EMPLY_ID = ? ORDER BY START_DT, START_TM, TASK_SQ", user);
	}

	/** TASK_SQ 가 있으면 내 것만 고치고, 없으면 만든다. 회차 완료·빠진 날은 그대로 둔다 */
	public Map<String, Object> save(String user, Map<String, Object> p) {
		String title = str(p, "TITLE").trim();
		if (title.isEmpty() || title.length() > 100) throw new IllegalArgumentException("제목을 1~100자로 입력해 주세요.");
		LocalDate start = date(str(p, "START_DT"), "시작일"), end = date(str(p, "END_DT").isEmpty() ? str(p, "START_DT") : str(p, "END_DT"), "끝 날짜");
		if (end.isBefore(start)) throw new IllegalArgumentException("끝 날짜가 시작일보다 앞입니다.");
		if (end.isAfter(start.plusDays(366))) throw new IllegalArgumentException("기간은 1년까지만 됩니다.");
		boolean allDay = !"N".equals(str(p, "ALL_DAY"));
		String st = allDay ? null : time(str(p, "START_TM")), et = allDay ? null : time(str(p, "END_TM"));
		if (!allDay && start.equals(end) && et.compareTo(st) < 0) throw new IllegalArgumentException("끝 시간이 시작 시간보다 앞입니다.");
		String rpt = str(p, "RPT_CD").isEmpty() ? "NONE" : str(p, "RPT_CD");
		if (!RPT.contains(rpt)) throw new IllegalArgumentException("반복 값이 올바르지 않습니다.");
		String dow = "WEEK".equals(rpt) ? str(p, "RPT_DOW") : "";
		if (!dow.matches("[0-6]{0,7}")) throw new IllegalArgumentException("반복 요일이 올바르지 않습니다.");
		if ("WEEK".equals(rpt) && dow.isEmpty()) dow = String.valueOf(start.getDayOfWeek().getValue() % 7);
		LocalDate until = "NONE".equals(rpt) || str(p, "RPT_UNTIL").isEmpty() ? null : date(str(p, "RPT_UNTIL"), "반복 끝");
		if (until != null && until.isBefore(start)) throw new IllegalArgumentException("반복 끝이 시작일보다 앞입니다.");
		String memo = str(p, "MEMO");
		if (memo.length() > 2000) throw new IllegalArgumentException("메모는 2000자까지입니다.");
		Object[] v = { title, start.toString(), end.toString(), allDay ? "Y" : "N", st, et, memo.isEmpty() ? null : memo, rpt, dow.isEmpty() ? null : dow, until == null ? null : until.toString() };
		String sq = str(p, "TASK_SQ");
		if (sq.isEmpty()) {
			jdbc.update("INSERT INTO TB_EEP_MY_TASK_R (TITLE, START_DT, END_DT, ALL_DAY, START_TM, END_TM, MEMO, RPT_CD, RPT_DOW, RPT_UNTIL, EMPLY_ID, REG_DT) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())", concat(v, user));
			sq = String.valueOf(jdbc.queryForObject("SELECT MAX(TASK_SQ) FROM TB_EEP_MY_TASK_R WHERE EMPLY_ID = ?", Integer.class, user));
		} else if (jdbc.update("UPDATE TB_EEP_MY_TASK_R SET TITLE = ?, START_DT = ?, END_DT = ?, ALL_DAY = ?, START_TM = ?, END_TM = ?, MEMO = ?, RPT_CD = ?, RPT_DOW = ?, RPT_UNTIL = ?, UPDT_DT = NOW() WHERE TASK_SQ = ? AND EMPLY_ID = ?", concat(v, sq, user)) == 0) {
			throw new IllegalArgumentException("할 일을 찾지 못했습니다.");
		}
		return one(user, sq);
	}

	public void delete(String user, String sq) {
		jdbc.update("DELETE FROM TB_EEP_MY_TASK_R WHERE TASK_SQ = ? AND EMPLY_ID = ?", sq, user);
	}

	/** 회차(그 회차 시작일) 하나를 완료·미완료로. 반복 없는 할 일은 시작일이 그 회차 */
	public Map<String, Object> done(String user, String sq, String occ, boolean done) {
		return mark(user, sq, "DONE_DTS", date(occ, "날짜").toString(), done);
	}

	/** 반복 할 일에서 그 회차만 빼기(이 날만 고치기·지우기) */
	public Map<String, Object> skip(String user, String sq, String occ) {
		return mark(user, sq, "SKIP_DTS", date(occ, "날짜").toString(), true);
	}

	private Map<String, Object> mark(String user, String sq, String col, String day, boolean on) {
		Map<String, Object> t = one(user, sq);
		Set<String> set = new LinkedHashSet<>();
		String now = (String) t.get(col);
		if (now != null && !now.isEmpty()) set.addAll(Arrays.asList(now.split(",")));
		if (on) set.add(day); else set.remove(day);
		if (set.size() > 2000) throw new IllegalArgumentException("기록이 너무 많습니다.");
		jdbc.update("UPDATE TB_EEP_MY_TASK_R SET " + col + " = ?, UPDT_DT = NOW() WHERE TASK_SQ = ? AND EMPLY_ID = ?", set.isEmpty() ? null : String.join(",", set), sq, user);
		return one(user, sq);
	}

	private Map<String, Object> one(String user, String sq) {
		List<Map<String, Object>> r = jdbc.queryForList("SELECT " + COLS + " FROM TB_EEP_MY_TASK_R WHERE TASK_SQ = ? AND EMPLY_ID = ?", sq, user);
		if (r.isEmpty()) throw new IllegalArgumentException("할 일을 찾지 못했습니다.");
		return r.get(0);
	}

	private static Object[] concat(Object[] a, Object... b) {
		Object[] r = Arrays.copyOf(a, a.length + b.length);
		System.arraycopy(b, 0, r, a.length, b.length);
		return r;
	}

	private static String str(Map<String, Object> p, String k) {
		Object v = p.get(k);
		return v == null ? "" : String.valueOf(v);
	}

	private static LocalDate date(String s, String nm) {
		try {
			return LocalDate.parse(s);
		} catch (DateTimeParseException | NullPointerException e) {
			throw new IllegalArgumentException(nm + " 값이 올바르지 않습니다.");
		}
	}

	private static String time(String s) {
		if (s == null || !s.matches("([01]\\d|2[0-3]):[0-5]\\d")) throw new IllegalArgumentException("시간을 HH:mm 으로 입력해 주세요.");
		return s;
	}
}
