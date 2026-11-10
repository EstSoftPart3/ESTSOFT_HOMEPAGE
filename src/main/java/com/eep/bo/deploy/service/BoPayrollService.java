package com.eep.bo.deploy.service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.eep.mapper.BoDeployMapper;

/**
 * 월 급여대장. 마감 전 달은 열 때마다 투입 건으로 기본·식대·상여를 다시 계산하고, 사람이 고친 칸은 건드리지 않는다.
 * 공제는 급여대장·사업소득대장 파일에서 불러온다(세금은 계산하지 않는다).
 */
@Service
public class BoPayrollService {

	static final List<String> PAY_FIELDS = Arrays.asList("BASE_AMT", "MEAL_AMT", "RESEARCH_AMT", "DRIVE_AMT", "CHILD_AMT", "BONUS_AMT", "FUEL_AMT");
	static final List<String> DED_FIELDS = Arrays.asList("NP_AMT", "HI_AMT", "LTC_AMT", "EI_AMT", "ACC_AMT", "IT_AMT", "LIT_AMT",
			"NP_SETTLE", "HI_SETTLE", "EI_SETTLE", "LTC_SETTLE", "IT_SETTLE", "LIT_SETTLE", "MUTUAL_AMT", "ETC_DED");
	/** 자동으로 채우는 칸. 사람이 고치면 MANUAL_FIELDS 에 남기고, 빈 값으로 고치면 다시 자동이 된다 */
	private static final List<String> AUTO_FIELDS = Arrays.asList("BASE_AMT", "MEAL_AMT", "BONUS_AMT");
	/** 공제가 있어야 하는 고용형태. 기타계약·외부업체·사업자프리는 공제가 없는 것이 정상이다 */
	private static final Set<String> NEED_DED = new HashSet<>(Arrays.asList("REGULAR", "PROBATION", "SPECIAL", "EMP_INS"));
	private static final String SS_IMPORT = "payImport";

	@Autowired
	private BoDeployMapper mapper;

	public boolean closed(String ym) {
		return "Y".equals(mapper.selectClosed(one("YM", ym)));
	}

	/** 그 달 대장. 마감 전이면 먼저 다시 계산한다 */
	public Map<String, Object> month(String ym) {
		checkYm(ym);
		boolean closed = closed(ym);
		if (!closed) {
			sync(ym);
		}
		List<Map<String, Object>> rows = derive(mapper.selectPayrollRows(one("YM", ym)), mapper.selectPayrollDetails(one("YM", ym)));
		Map<Object, Map<String, Object>> prev = new HashMap<>();
		derive(mapper.selectPayrollRows(one("YM", YearMonth.parse(ym).minusMonths(1).toString())), new ArrayList<>()).forEach(r -> prev.put(r.get("STAFF_SQ"), r));
		for (Map<String, Object> r : rows) {
			Map<String, Object> p = prev.get(r.get("STAFF_SQ"));
			List<String> flags = flags(r);
			if (p != null && n(p.get("NET")) > 0 && n(r.get("NET")) > 0) {
				double pct = (n(r.get("NET")) - n(p.get("NET"))) * 100.0 / n(p.get("NET"));
				r.put("DELTA_PCT", Math.round(pct * 10) / 10.0);
				if (Math.abs(pct) >= 10) {
					flags.add("전월 대비 " + (pct > 0 ? "+" : "") + Math.round(pct * 10) / 10.0 + "%");
				}
			}
		}
		Map<String, Object> out = new HashMap<>();
		out.put("rows", rows);
		out.put("closed", closed);
		return out;
	}

	/** 한 사람의 그 해 월별 내역 */
	public List<Map<String, Object>> staffYear(Object staffSq, String year) {
		Map<String, Object> q = one("YEAR", year);
		q.put("STAFF_SQ", staffSq);
		return derive(mapper.selectPayrollRows(q), mapper.selectPayrollDetails(q));
	}

	/** 투입 건 하나의 월별 단가와 지급. 투입 이력 마우스 올림 카드용 */
	public Map<String, Object> deployHistory(Object staffSq, Object deploySq) {
		Map<String, Object> q = new HashMap<>();
		q.put("STAFF_SQ", staffSq);
		List<Map<String, Object>> details = mapper.selectPayrollDetails(q);
		List<Map<String, Object>> rows = derive(mapper.selectPayrollRows(q), details);
		Map<Object, Map<String, Object>> byYm = new HashMap<>();
		rows.forEach(r -> byYm.put(r.get("PAY_YM"), r));
		List<Map<String, Object>> rates = new ArrayList<>();
		long sale = 0, pay = 0, company = 0;
		Map<String, Object> last = null;
		for (Map<String, Object> d : details) {
			if (!String.valueOf(deploySq).equals(String.valueOf(d.get("DEPLOY_SQ")))) {
				continue;
			}
			Map<String, Object> month = byYm.get(d.get("PAY_YM"));
			boolean only = month != null && ((List<?>) month.get("DETAILS")).size() == 1;
			sale += n(d.get("REAL_SALE"));
			pay += only ? n(month.get("PAY_TOTAL")) : n(d.get("BASE_AMT"));
			company += only ? n(month.get("COMPANY")) : 0;
			Map<String, Object> prevRate = rates.isEmpty() ? null : rates.get(rates.size() - 1);
			if (prevRate != null && n(prevRate.get("SALE_PRICE")) == n(d.get("SALE_PRICE")) && n(prevRate.get("COST_PRICE")) == n(d.get("COST_PRICE"))) {
				prevRate.put("TO_YM", d.get("PAY_YM"));
			} else {
				Map<String, Object> rate = new HashMap<>();
				rate.put("FROM_YM", d.get("PAY_YM"));
				rate.put("TO_YM", d.get("PAY_YM"));
				rate.put("SALE_PRICE", n(d.get("SALE_PRICE")));
				rate.put("COST_PRICE", n(d.get("COST_PRICE")));
				rates.add(rate);
			}
			if (month != null) {
				last = month;
			}
		}
		Map<String, Object> out = new HashMap<>();
		out.put("rates", rates);
		out.put("last", last);
		out.put("SALE", sale);
		out.put("PAY", pay);
		out.put("PROFIT", sale - pay - company);
		return out;
	}

	// ── 다시 계산 ──

	void sync(String ym) {
		YearMonth m = YearMonth.parse(ym);
		int total = m.lengthOfMonth();
		Map<Object, List<Map<String, Object>>> byStaff = new LinkedHashMap<>();
		for (Map<String, Object> d : mapper.selectDeployList()) {
			byStaff.computeIfAbsent(d.get("STAFF_SQ"), k -> new ArrayList<>()).add(d);
		}
		Map<Object, Map<String, Object>> existing = new HashMap<>();
		mapper.selectPayrollRows(one("YM", ym)).forEach(r -> existing.put(r.get("STAFF_SQ"), r));
		List<Object> keepDeploy = new ArrayList<>(), keepStaff = new ArrayList<>();
		for (List<Map<String, Object>> rows : byStaff.values()) {
			Map<String, Object> staff = rows.get(0);
			LocalDate leave = PayCalc.date(staff.get("LEAVE_DT"));
			if (leave != null && leave.isBefore(m.atDay(1))) {
				continue;
			}
			List<Map<String, Object>> overlap = new ArrayList<>();
			Map<String, Object> lastPast = null;
			for (Map<String, Object> d : rows) {
				LocalDate start = PayCalc.date(d.get("START_DT")), end = PayCalc.date(d.get("END_DT"));
				int days = PayCalc.workDays(start, end, ym);
				if (days > 0) {
					d.put("WORK_DAYS", days);
					overlap.add(d);
				} else if (!start.isAfter(m.atDay(1))) {
					lastPast = d;
				}
			}
			Map<String, Object> primary = overlap.isEmpty() ? lastPast : overlap.get(overlap.size() - 1);
			// 투입이 없는 달은 고정급(정규·수습) 재직자만 대기로 넣는다
			if (primary == null || (overlap.isEmpty() && (!PayCalc.isSalaried(str(primary.get("EMP_TYPE_CD"))) || "LEFT".equals(staff.get("STATUS_CD"))))) {
				continue;
			}
			if (overlap.isEmpty()) {
				primary.put("WORK_DAYS", 0);
				overlap.add(primary);
			}
			String type = str(primary.get("EMP_TYPE_CD"));
			long base = 0, meal = 0;
			for (Map<String, Object> d : overlap) {
				int days = (Integer) d.get("WORK_DAYS");
				long b;
				if (!PayCalc.isSalaried(type)) {
					b = PayCalc.prorate(n(d.get("COST_PRICE")), days, total);
				} else if (d == primary) {
					LocalDate end = PayCalc.date(d.get("END_DT"));
					LocalDate lastDay = end != null && YearMonth.from(end).equals(m) ? end : m.atEndOfMonth();
					long[] bm = PayCalc.salaried(type, n(d.get("COST_PRICE")), ym, PayCalc.date(staff.get("JOIN_DT")), PayCalc.date(d.get("PROB_END_DT")), lastDay);
					b = bm[0];
					meal = bm[1];
				} else {
					b = 0; // 고정급은 한 달에 한 번만
				}
				base += b;
				Map<String, Object> row = new HashMap<>();
				row.put("YM", ym);
				row.put("DEPLOY_SQ", d.get("DEPLOY_SQ"));
				row.put("STAFF_SQ", d.get("STAFF_SQ"));
				row.put("WORK_DAYS", days);
				row.put("TOTAL_DAYS", total);
				row.put("SALE_PRICE", n(d.get("SALE_PRICE")));
				row.put("COST_PRICE", n(d.get("COST_PRICE")));
				row.put("REAL_SALE", PayCalc.prorate(n(d.get("SALE_PRICE")), days, total));
				row.put("BASE_AMT", b);
				mapper.savePayrollDetail(row);
				keepDeploy.add(d.get("DEPLOY_SQ"));
			}
			long bonus = PayCalc.bonusFor(PayCalc.bonusPlan(type, PayCalc.date(staff.get("JOIN_DT"))), ym);
			Map<String, Object> cur = existing.get(staff.get("STAFF_SQ"));
			Map<String, Object> auto = new HashMap<>();
			auto.put("YM", ym);
			auto.put("STAFF_SQ", staff.get("STAFF_SQ"));
			auto.put("EMP_TYPE_CD", type);
			auto.put("BASE_AMT", base);
			auto.put("MEAL_AMT", meal);
			auto.put("BONUS_AMT", bonus);
			if (cur == null) {
				mapper.insertPayroll(auto);
			} else {
				Set<String> manual = manual(cur);
				boolean changed = !type.equals(cur.get("EMP_TYPE_CD"));
				for (String f : AUTO_FIELDS) {
					if (manual.contains(f)) {
						auto.put(f, n(cur.get(f)));
					}
					changed |= n(auto.get(f)) != n(cur.get(f));
				}
				if (changed) {
					mapper.updatePayrollAuto(auto);
				}
			}
			keepStaff.add(staff.get("STAFF_SQ"));
		}
		Map<String, Object> q = one("YM", ym);
		q.put("KEEP", keepDeploy);
		mapper.deletePayrollDetailsExcept(q);
		q.put("KEEP", keepStaff);
		mapper.deleteEmptyPayroll(q);
	}

	/** 합계·손익·확인 사항을 붙인다. details 는 같은 범위의 투입 건별 행 */
	static List<Map<String, Object>> derive(List<Map<String, Object>> rows, List<Map<String, Object>> details) {
		Map<String, List<Map<String, Object>>> byKey = new HashMap<>();
		for (Map<String, Object> d : details) {
			byKey.computeIfAbsent(d.get("PAY_YM") + "/" + d.get("STAFF_SQ"), k -> new ArrayList<>()).add(d);
		}
		for (Map<String, Object> r : rows) {
			List<Map<String, Object>> ds = byKey.getOrDefault(r.get("PAY_YM") + "/" + r.get("STAFF_SQ"), new ArrayList<>());
			long pay = 0, ded = 0, sale = 0, days = 0, totalDays = 0;
			for (String f : PAY_FIELDS) {
				pay += n(r.get(f));
			}
			for (String f : DED_FIELDS) {
				ded += n(r.get(f));
			}
			for (Map<String, Object> d : ds) {
				sale += n(d.get("REAL_SALE"));
				days += n(d.get("WORK_DAYS"));
				totalDays = n(d.get("TOTAL_DAYS"));
			}
			String type = str(r.get("EMP_TYPE_CD"));
			long company = PayCalc.isSalaried(type)
					? n(r.get("NP_AMT")) + n(r.get("HI_AMT")) + n(r.get("EI_AMT")) + n(r.get("LTC_AMT")) + n(r.get("ACC_AMT"))
							+ PayCalc.retire(n(r.get("BASE_AMT")), n(r.get("MEAL_AMT")), n(r.get("RESEARCH_AMT")), n(r.get("FUEL_AMT")), n(r.get("BONUS_AMT")))
					: 0;
			Map<String, Object> latest = ds.isEmpty() ? null : ds.get(ds.size() - 1);
			r.put("DETAILS", ds);
			r.put("PAY_TOTAL", pay);
			r.put("DED_TOTAL", ded);
			r.put("NET", pay - ded);
			r.put("REAL_SALE", sale);
			r.put("COMPANY", company);
			r.put("PROFIT", sale - pay - company);
			r.put("WORK_DAYS", Math.min(days, totalDays));
			r.put("TOTAL_DAYS", totalDays);
			r.put("SALE_PRICE", latest == null ? 0 : n(latest.get("SALE_PRICE")));
			r.put("COST_PRICE", latest == null ? 0 : n(latest.get("COST_PRICE")));
			r.put("BONUS_PLAN", PayCalc.bonusPlan(type, PayCalc.date(r.get("JOIN_DT"))));
		}
		return rows;
	}

	static List<String> flags(Map<String, Object> r) {
		List<String> f = new ArrayList<>();
		if (NEED_DED.contains(str(r.get("EMP_TYPE_CD"))) && n(r.get("DED_TOTAL")) == 0) {
			f.add("공제 미입력");
		}
		if (n(r.get("WORK_DAYS")) < n(r.get("TOTAL_DAYS"))) {
			f.add(n(r.get("WORK_DAYS")) == 0 ? "대기" : "일할 " + r.get("WORK_DAYS") + "/" + r.get("TOTAL_DAYS"));
		}
		if (n(r.get("BONUS_AMT")) > 0) {
			f.add("상여");
		}
		if (!manual(r).isEmpty()) {
			f.add("수기 수정");
		}
		if (r.get("LEDGER_PAY") != null && n(r.get("LEDGER_PAY")) != n(r.get("PAY_TOTAL"))) {
			long diff = n(r.get("LEDGER_PAY")) - n(r.get("PAY_TOTAL"));
			f.add("대장 지급 " + (diff > 0 ? "+" : "") + String.format("%,d", diff));
		}
		r.put("FLAGS", f);
		return f;
	}

	// ── 수정·마감 ──

	public void saveField(Map<String, Object> p, String loginId) {
		String ym = str(p.get("YM")), field = str(p.get("FIELD")), raw = str(p.get("VALUE")).replace(",", "").trim();
		checkYm(ym);
		require(!closed(ym), "마감된 달은 고칠 수 없습니다. 마감을 해제한 뒤 고쳐 주세요.");
		require(PAY_FIELDS.contains(field) || DED_FIELDS.contains(field) || "MEMO".equals(field), "고칠 수 없는 칸입니다.");
		Map<String, Object> q = one("YM", ym);
		q.put("STAFF_SQ", p.get("STAFF_SQ"));
		List<Map<String, Object>> found = mapper.selectPayrollRows(q);
		require(!found.isEmpty(), "급여 행을 찾지 못했습니다. 새로 고쳐 주세요.");
		Map<String, Object> cur = found.get(0);
		Set<String> manual = manual(cur);
		Object value;
		if ("MEMO".equals(field)) {
			value = raw;
		} else if (raw.isEmpty() && AUTO_FIELDS.contains(field)) {
			manual.remove(field);
			value = n(cur.get(field)); // 다음 계산 때 자동값으로 바뀐다
		} else {
			value = BoDeployService.money(raw.isEmpty() ? "0" : raw);
			require(DED_FIELDS.contains(field) || (Long) value >= 0, "지급 금액은 0 이상이어야 합니다.");
			if (AUTO_FIELDS.contains(field)) {
				manual.add(field);
			}
		}
		q.put("FIELD", field);
		q.put("VALUE", value);
		q.put("MANUAL_FIELDS", String.join(",", manual));
		q.put("UPDT_EMPLY_ID", loginId);
		mapper.updatePayrollField(q);
		if (!"MEMO".equals(field)) {
			change(ym, p.get("STAFF_SQ"), field, cur.get(field), value, raw.isEmpty() && AUTO_FIELDS.contains(field) ? "자동으로 되돌림" : null, loginId);
		}
	}

	public void setClosed(String ym, boolean close, String reason, String loginId) {
		checkYm(ym);
		require(close || !reason.trim().isEmpty(), "마감 해제 사유를 입력해 주세요.");
		if (close) {
			sync(ym); // 마감하는 순간의 투입 상태로 확정한다
		}
		Map<String, Object> q = one("YM", ym);
		q.put("CLOSED_YN", close ? "Y" : "N");
		q.put("EMPLY_ID", loginId);
		mapper.saveClosed(q);
		change(ym, 0, close ? "CLOSE" : "REOPEN", null, null, close ? null : reason.trim(), loginId);
	}

	// ── 대장 불러오기 ──

	/** 파일들을 읽어 직원과 맞춰 보여 주고, 반영할 때 쓰도록 세션에 둔다 */
	public Map<String, Object> importPreview(String ym, List<byte[]> files, Map<String, Object> session) {
		checkYm(ym);
		require(!closed(ym), "마감된 달에는 불러올 수 없습니다.");
		require(!files.isEmpty(), "급여대장이나 사업소득대장 파일을 골라 주세요.");
		List<Map<String, Object>> rows = new ArrayList<>(), summary = new ArrayList<>();
		for (byte[] f : files) {
			PayLedgerParser.Result r = PayLedgerParser.parse(f);
			require(ym.equals(r.ym), (PayLedgerParser.KIND_PAY.equals(r.kind) ? "급여대장" : "사업소득대장") + "의 귀속월(" + r.ym + ")이 " + ym + " 과 다릅니다.");
			r.rows.forEach(x -> x.put("SRC_CD", r.kind));
			rows.addAll(r.rows);
			Map<String, Object> s = new HashMap<>();
			s.put("KIND", r.kind);
			s.put("COUNT", r.rows.size());
			summary.add(s);
		}
		Map<String, Object> codes = new HashMap<>();
		mapper.selectLedgerCodes().forEach(c -> codes.put(c.get("SRC_CD") + "/" + c.get("LEDGER_CD"), c.get("STAFF_SQ")));
		Map<String, List<Object>> byName = new HashMap<>();
		for (Map<String, Object> s : mapper.selectStaffOptions()) {
			byName.computeIfAbsent(str(s.get("STAFF_NM")), k -> new ArrayList<>()).add(s.get("STAFF_SQ"));
		}
		Map<Object, Map<String, Object>> pays = new HashMap<>();
		derive(mapper.selectPayrollRows(one("YM", ym)), mapper.selectPayrollDetails(one("YM", ym))).forEach(r -> pays.put(String.valueOf(r.get("STAFF_SQ")), r));
		for (Map<String, Object> r : rows) {
			Object staff = codes.get(r.get("SRC_CD") + "/" + r.get("LEDGER_CD"));
			List<Object> same = byName.get(str(r.get("LEDGER_NM")));
			if (staff == null && same != null && same.size() == 1) {
				staff = same.get(0);
			}
			r.put("STAFF_SQ", staff);
			Map<String, Object> pay = staff == null ? null : pays.get(String.valueOf(staff));
			r.put("SYSTEM_PAY", pay == null ? null : pay.get("PAY_TOTAL"));
		}
		session.put(SS_IMPORT, new Object[] { ym, rows });
		Map<String, Object> out = new HashMap<>();
		out.put("rows", rows);
		out.put("files", summary);
		return out;
	}

	/** links: 행 번호 -> 고른 STAFF_SQ (자동으로 못 맞춘 행). 같은 사람이 두 대장에 있으면 더한다 */
	@SuppressWarnings("unchecked")
	public int importApply(String ym, Map<String, Object> links, Map<String, Object> session, String loginId) {
		Object[] saved = (Object[]) session.get(SS_IMPORT);
		require(saved != null && ym.equals(saved[0]), "불러온 파일이 없습니다. 파일을 다시 골라 주세요.");
		require(!closed(ym), "마감된 달에는 불러올 수 없습니다.");
		List<Map<String, Object>> rows = (List<Map<String, Object>>) saved[1];
		Map<String, Map<String, Object>> merged = new LinkedHashMap<>();
		for (int i = 0; i < rows.size(); i++) {
			Map<String, Object> r = rows.get(i);
			String chosen = str(links.get("LINK_" + i));
			Object staff = chosen.isEmpty() ? r.get("STAFF_SQ") : chosen;
			if (staff == null) {
				continue;
			}
			if (!chosen.isEmpty()) {
				Map<String, Object> code = new HashMap<>();
				code.put("SRC_CD", r.get("SRC_CD"));
				code.put("LEDGER_CD", r.get("LEDGER_CD"));
				code.put("STAFF_SQ", staff);
				mapper.saveLedgerCode(code);
			}
			Map<String, Object> m = merged.computeIfAbsent(String.valueOf(staff), k -> new HashMap<>());
			m.put("SRC_CD", m.containsKey("SRC_CD") ? m.get("SRC_CD") : r.get("SRC_CD"));
			for (String f : DED_FIELDS) {
				m.put(f, n(m.get(f)) + n(r.get(f)));
			}
			m.put("LEDGER_PAY", n(m.get("LEDGER_PAY")) + n(r.get("LEDGER_PAY")));
		}
		Map<String, Map<String, Object>> current = new HashMap<>();
		mapper.selectPayrollRows(one("YM", ym)).forEach(r -> current.put(String.valueOf(r.get("STAFF_SQ")), r));
		for (Map.Entry<String, Map<String, Object>> e : merged.entrySet()) {
			Map<String, Object> q = e.getValue();
			q.put("YM", ym);
			q.put("STAFF_SQ", e.getKey());
			q.put("UPDT_EMPLY_ID", loginId);
			Map<String, Object> cur = current.get(e.getKey());
			if (cur == null) {
				// 이번 달 투입이 없는 사람도 공제는 남긴다. 고용형태는 대장 종류로 짐작하고 투입을 넣으면 다시 맞춰진다
				Map<String, Object> ins = one("YM", ym);
				ins.put("STAFF_SQ", e.getKey());
				ins.put("EMP_TYPE_CD", PayLedgerParser.KIND_PAY.equals(q.get("SRC_CD")) ? PayCalc.REGULAR : "SPECIAL");
				ins.put("BASE_AMT", 0L);
				ins.put("MEAL_AMT", 0L);
				ins.put("BONUS_AMT", 0L);
				mapper.insertPayroll(ins);
				cur = new HashMap<>();
			}
			mapper.updatePayrollDeductions(q);
			for (String f : DED_FIELDS) {
				if (n(cur.get(f)) != n(q.get(f))) {
					change(ym, e.getKey(), f, cur.get(f), q.get(f), "대장 불러오기", loginId);
				}
			}
		}
		session.remove(SS_IMPORT);
		return merged.size();
	}

	// ── 도움 ──

	private void change(String ym, Object staffSq, String field, Object before, Object after, String reason, String loginId) {
		Map<String, Object> h = one("YM", ym);
		h.put("STAFF_SQ", staffSq);
		h.put("FIELD", field);
		h.put("BEFORE_VAL", before == null ? null : before.toString());
		h.put("AFTER_VAL", after == null ? null : after.toString());
		h.put("REASON", reason);
		h.put("UPDT_EMPLY_ID", loginId);
		mapper.insertPayrollChange(h);
	}

	private static Set<String> manual(Map<String, Object> r) {
		Set<String> s = new HashSet<>();
		for (String f : str(r.get("MANUAL_FIELDS")).split(",")) {
			if (!f.isEmpty()) {
				s.add(f);
			}
		}
		return s;
	}

	static void checkYm(String ym) {
		require(ym != null && ym.matches("\\d{4}-(0[1-9]|1[0-2])"), "월은 yyyy-MM 형식이어야 합니다.");
	}

	private static Map<String, Object> one(String k, Object v) {
		Map<String, Object> m = new HashMap<>();
		m.put(k, v);
		return m;
	}

	static long n(Object v) {
		return v == null ? 0 : v instanceof Number ? ((Number) v).longValue() : Long.parseLong(v.toString());
	}

	private static String str(Object v) {
		return Objects.toString(v, "");
	}

	private static void require(boolean ok, String message) {
		if (!ok) {
			throw new IllegalArgumentException(message);
		}
	}
}
