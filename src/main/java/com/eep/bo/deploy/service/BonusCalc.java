package com.eep.bo.deploy.service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * 상여관리 조건 × 직원관리에서 켠 것 → 단계별 지급 예정. DB 를 쓰지 않는다.
 * 모든 상여는 기준일부터 n개월 달성하면 달성한 달의 익월 급여 상여 칸에 들어간다.
 */
public final class BonusCalc {

	public static final List<String> BASES = Arrays.asList("JOIN", "CONTRACT", "JOIN_OR_CONTRACT");
	public static final List<String> CONDS = Arrays.asList("FULL", "TENURE", "NONE");

	private BonusCalc() {
	}

	/** "3:FULL:500000,6:TENURE:300000" → [{MONTHS, COND, AMT}]. 형식이 틀리면 IllegalArgumentException */
	public static List<Map<String, Object>> steps(String s) {
		List<Map<String, Object>> out = new ArrayList<>();
		for (String one : Objects.toString(s, "").split(",")) {
			String[] p = one.trim().split(":");
			if (p.length != 3 || !p[0].matches("\\d{1,3}") || !CONDS.contains(p[1]) || !p[2].matches("\\d{1,9}") || Integer.parseInt(p[0]) > 120) {
				throw new IllegalArgumentException("지급 단계가 올바르지 않습니다: " + one);
			}
			Map<String, Object> m = new HashMap<>();
			m.put("MONTHS", Integer.parseInt(p[0]));
			m.put("COND", p[1]);
			m.put("AMT", Long.parseLong(p[2]));
			out.add(m);
		}
		return out;
	}

	/**
	 * 지급 예정 목록. deploys 는 selectDeployList(직원의 입사·퇴사일 포함).
	 * 항목: BONUS_SQ, LABEL, PERSON_SQ(조건을 따지는 사람), RECIPIENT_SQ(받는 사람), BASE_DT, ACHIEVE_DT, YM(지급월), AMT, OK, WHY(못 받는 이유)
	 */
	public static List<Map<String, Object>> plans(List<Map<String, Object>> bonuses, List<Map<String, Object>> applies, List<Map<String, Object>> deploys) {
		Map<String, List<Map<String, Object>>> byStaff = new HashMap<>();
		for (Map<String, Object> d : deploys) {
			byStaff.computeIfAbsent(str(d.get("STAFF_SQ")), k -> new ArrayList<>()).add(d);
		}
		Map<String, Map<String, Object>> byBonus = new LinkedHashMap<>();
		for (Map<String, Object> b : bonuses) {
			if ("Y".equals(b.get("USE_YN"))) {
				byBonus.put(str(b.get("BONUS_SQ")), b);
			}
		}
		List<Map<String, Object>> out = new ArrayList<>();
		for (Map<String, Object> a : applies) {
			Map<String, Object> b = byBonus.get(str(a.get("BONUS_SQ")));
			List<Map<String, Object>> ds = byStaff.get(str(a.get("STAFF_SQ")));
			boolean referral = "REFERRER".equals(b == null ? null : b.get("TARGET_CD"));
			Object recipient = referral ? a.get("REFERRER_SQ") : a.get("STAFF_SQ");
			LocalDate base = b == null || ds == null ? null : base(str(b.get("BASE_CD")), ds);
			if (base == null || recipient == null || str(recipient).isEmpty()) {
				continue;
			}
			List<Map<String, Object>> steps = steps(str(b.get("STEPS")));
			for (Map<String, Object> s : steps) {
				int months = (Integer) s.get("MONTHS");
				LocalDate achieve = base.plusMonths(months);
				String why = check(str(s.get("COND")), months, base, achieve, ds);
				long amt = "Y".equals(b.get("PER_AMT_YN")) && a.get("AMT") != null ? BoPayrollService.n(a.get("AMT")) : (Long) s.get("AMT");
				Map<String, Object> m = new HashMap<>();
				m.put("BONUS_SQ", b.get("BONUS_SQ"));
				m.put("LABEL", str(b.get("BONUS_NM")) + (steps.size() > 1 ? " " + (months == 0 ? "계약" : months + "개월") : "")
						+ (referral ? " (" + str(ds.get(0).get("STAFF_NM")) + ")" : ""));
				m.put("PERSON_SQ", a.get("STAFF_SQ"));
				m.put("RECIPIENT_SQ", recipient);
				m.put("MONTHS", months);
				m.put("COND", s.get("COND"));
				m.put("BASE_DT", base.toString());
				m.put("ACHIEVE_DT", achieve.toString());
				m.put("YM", YearMonth.from(achieve).plusMonths(1).toString());
				m.put("AMT", amt);
				m.put("OK", why == null);
				m.put("WHY", why);
				out.add(m);
			}
		}
		return out;
	}

	/** 받는 사람별로 묶는다 */
	public static Map<String, List<Map<String, Object>>> byRecipient(List<Map<String, Object>> plans) {
		Map<String, List<Map<String, Object>>> m = new HashMap<>();
		plans.forEach(p -> m.computeIfAbsent(str(p.get("RECIPIENT_SQ")), k -> new ArrayList<>()).add(p));
		return m;
	}

	/** 그 달에 지급할 금액(조건을 채운 것만) */
	public static long sumFor(List<Map<String, Object>> plans, String ym) {
		long sum = 0;
		for (Map<String, Object> p : plans == null ? new ArrayList<Map<String, Object>>() : plans) {
			if (ym.equals(p.get("YM")) && Boolean.TRUE.equals(p.get("OK"))) {
				sum += (Long) p.get("AMT");
			}
		}
		return sum;
	}

	static LocalDate base(String code, List<Map<String, Object>> ds) {
		LocalDate join = PayCalc.date(ds.get(0).get("JOIN_DT")), contract = null;
		for (Map<String, Object> d : ds) {
			LocalDate s = PayCalc.date(d.get("START_DT"));
			if (s != null && (contract == null || s.isBefore(contract))) {
				contract = s;
			}
		}
		if ("JOIN".equals(code)) {
			return join;
		}
		if ("CONTRACT".equals(code) || join == null) {
			return contract;
		}
		return salaried(ds) ? join : contract;
	}

	private static boolean salaried(List<Map<String, Object>> ds) {
		return ds.stream().anyMatch(d -> PayCalc.isSalaried(str(d.get("EMP_TYPE_CD"))));
	}

	/**
	 * 그 날 근무했는지. 투입 기간 안이면 근무, 정규·수습은 재직 기간 전체를 근무로 본다.
	 * shortcut: 근태(결근·휴직) 기록이 없어 투입·재직 기간으로만 본다, 근태를 관리하게 되면 그 기록으로 바꾼다
	 */
	static boolean covered(List<Map<String, Object>> ds, LocalDate day) {
		Map<String, Object> staff = ds.get(0);
		LocalDate join = PayCalc.date(staff.get("JOIN_DT")), leave = PayCalc.date(staff.get("LEAVE_DT"));
		if (leave != null && day.isAfter(leave)) {
			return false;
		}
		if (salaried(ds) && join != null && !day.isBefore(join)) {
			return true;
		}
		for (Map<String, Object> d : ds) {
			LocalDate s = PayCalc.date(d.get("START_DT")), e = PayCalc.date(d.get("END_DT"));
			if (s != null && !day.isBefore(s) && (e == null || !day.isAfter(e))) {
				return true;
			}
		}
		return false;
	}

	/** 조건을 채웠으면 null, 아니면 이유. 만근 = 기준일부터 달성일 전날까지 매일 근무 */
	static String check(String cond, int months, LocalDate base, LocalDate achieve, List<Map<String, Object>> ds) {
		if ("NONE".equals(cond) || months == 0 && !"TENURE".equals(cond)) {
			return null;
		}
		if ("TENURE".equals(cond)) {
			LocalDate day = months == 0 ? base : achieve.minusDays(1);
			return covered(ds, day) ? null : "근속 미달: " + day + " 근무 기록 없음";
		}
		for (LocalDate d = base; d.isBefore(achieve); d = d.plusDays(1)) {
			if (!covered(ds, d)) {
				YearMonth m = YearMonth.from(d);
				int worked = 0, total = 0;
				for (LocalDate x = d.withDayOfMonth(1); !x.isAfter(m.atEndOfMonth()); x = x.plusDays(1)) {
					if (!x.isBefore(base) && x.isBefore(achieve)) {
						total++;
						worked += covered(ds, x) ? 1 : 0;
					}
				}
				return "만근 미달: " + m + " 근무 " + worked + "/" + total + "일";
			}
		}
		return null;
	}

	private static String str(Object v) {
		return Objects.toString(v, "");
	}
}
