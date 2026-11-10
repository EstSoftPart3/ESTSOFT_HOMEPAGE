package com.eep.bo.deploy.service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** 월 급여 계산. '이에스티_투입현황' 엑셀의 수식을 그대로 옮겼다. DB 를 쓰지 않는다 */
public final class PayCalc {

	public static final String REGULAR = "REGULAR";
	public static final String PROBATION = "PROBATION";
	// 엑셀 시트 위쪽 고정값(R1, R2). shortcut: 코드 상수라 금액이 바뀌면 배포가 필요하다, 자주 바뀌면 공통코드로 옮긴다
	static final long PROBATION_PAY = 2160000L;
	static final long MEAL = 200000L;
	private static final long WELCOME_BONUS = 500000L;
	private static final long TENURE_BONUS = 500000L;

	private PayCalc() {
	}

	/** 정규·수습만 회사부담금이 사업수익에서 빠지고 고정급으로 계산한다 */
	public static boolean isSalaried(String type) {
		return REGULAR.equals(type) || PROBATION.equals(type);
	}

	public static LocalDate date(Object v) {
		String s = v == null ? "" : v.toString().trim();
		if (s.length() < 10) {
			return null;
		}
		try {
			return LocalDate.parse(s.substring(0, 10));
		} catch (DateTimeParseException e) {
			return null; // 입사일 칸은 날짜가 아닌 글자가 있을 수 있다
		}
	}

	public static int totalDays(String ym) {
		return YearMonth.parse(ym).lengthOfMonth();
	}

	/** 그 달 안의 투입일~철수일 일수. 겹치지 않으면 0 */
	public static int workDays(LocalDate start, LocalDate end, String ym) {
		YearMonth m = YearMonth.parse(ym);
		LocalDate from = start.isBefore(m.atDay(1)) ? m.atDay(1) : start;
		LocalDate to = end == null || end.isAfter(m.atEndOfMonth()) ? m.atEndOfMonth() : end;
		return to.isBefore(from) ? 0 : (int) ChronoUnit.DAYS.between(from, to) + 1;
	}

	/** 월 금액 ÷ 전체일수 × 근무일수, 천원 미만 버림 */
	public static long prorate(long monthly, int days, int total) {
		return monthly * days / total / 1000 * 1000;
	}

	/** 정규·수습의 { 기본, 식대 }. lastDay 는 그 달의 마지막 근무일(철수일 또는 말일) */
	public static long[] salaried(String type, long cost, String ym, LocalDate join, LocalDate release, LocalDate lastDay) {
		YearMonth m = YearMonth.parse(ym);
		int total = m.lengthOfMonth();
		if (REGULAR.equals(type) || (release != null && !release.isAfter(m.atDay(1)))) {
			return new long[] { cost - MEAL, MEAL };
		}
		int probationDays = release != null && YearMonth.from(release).equals(m) ? release.getDayOfMonth() - 1 : 0;
		long span = join == null ? Long.MAX_VALUE : ChronoUnit.DAYS.between(join, lastDay) + 1;
		long base;
		if (span > total) {
			base = probationDays > 0 ? PROBATION_PAY * probationDays / total + cost * (total - probationDays) / total : PROBATION_PAY;
		} else {
			base = PROBATION_PAY * span / total;
		}
		return new long[] { base, probationDays > 0 ? MEAL * (total - probationDays) / total : 0 };
	}

	/** 퇴직금 적립: (기본+식대+연구비+유류비+상여) ÷ 10 */
	public static long retire(long base, long meal, long research, long fuel, long bonus) {
		return (base + meal + research + fuel + bonus) / 10;
	}

	/** 취업축하(입사 익월), 근속 3·6·9·12개월(달성 익월). 정규·수습만. { LABEL, YM, AMT } */
	public static List<Map<String, Object>> bonusPlan(String type, LocalDate join) {
		List<Map<String, Object>> out = new ArrayList<>();
		if (!isSalaried(type) || join == null) {
			return out;
		}
		out.add(bonus("취업축하", YearMonth.from(join).plusMonths(1), WELCOME_BONUS));
		for (int months : new int[] { 3, 6, 9, 12 }) {
			out.add(bonus("근속 " + months + "개월", YearMonth.from(join.plusMonths(months)).plusMonths(1), TENURE_BONUS));
		}
		return out;
	}

	public static long bonusFor(List<Map<String, Object>> plan, String ym) {
		long sum = 0;
		for (Map<String, Object> b : plan) {
			if (ym.equals(b.get("YM"))) {
				sum += (Long) b.get("AMT");
			}
		}
		return sum;
	}

	private static Map<String, Object> bonus(String label, YearMonth ym, long amt) {
		Map<String, Object> m = new HashMap<>();
		m.put("LABEL", label);
		m.put("YM", ym.toString());
		m.put("AMT", amt);
		return m;
	}
}
