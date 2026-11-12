package com.eep.bo.deploy.service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;

/** 월 급여 계산. '이에스티_투입현황' 엑셀의 수식을 그대로 옮겼다. DB 를 쓰지 않는다 */
public final class PayCalc {

	public static final String REGULAR = "REGULAR";
	public static final String PROBATION = "PROBATION";
	// 엑셀 시트 위쪽 고정값(R1, R2). 급여관리 계산기 버튼에서 고치고 TB_EEP_PAYROLL_PARAM_M 에서 읽는다(BoPayrollService.loadParams)
	static volatile long PROBATION_PAY = 2160000L;
	static volatile long MEAL = 200000L;
	static volatile long PRORATE_UNIT = 1000L;
	/** 고칠 수 있는 기준값과 허용 범위: [키, 이름, 최소, 최대] */
	static final Object[][] PARAMS = { { "PROBATION_PAY", "수습급여(월)", 0L, 20000000L }, { "MEAL", "식대(월)", 0L, 1000000L }, { "PRORATE_UNIT", "일할 버림 단위(원)", 1L, 10000L } };

	static void setParam(String k, long v) {
		if ("PROBATION_PAY".equals(k)) {
			PROBATION_PAY = v;
		} else if ("MEAL".equals(k)) {
			MEAL = v;
		} else if ("PRORATE_UNIT".equals(k)) {
			PRORATE_UNIT = v;
		}
	}

	static long param(String k) {
		return "PROBATION_PAY".equals(k) ? PROBATION_PAY : "MEAL".equals(k) ? MEAL : PRORATE_UNIT;
	}

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

	/** 월 금액 ÷ 전체일수 × 근무일수, 버림 단위(기본 천원) 미만 버림 */
	public static long prorate(long monthly, int days, int total) {
		return monthly * days / total / PRORATE_UNIT * PRORATE_UNIT;
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

}
