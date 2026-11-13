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
	/** 상여 칩 키워드. 이 칩의 ✕ 는 숨김이 아니라 그 달 상여 제외다 */
	static final String BONUS_K = "상여";

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
		Map<String, List<Map<String, Object>>> plans = BonusCalc.byRecipient(bonusPlans());
		for (Map<String, Object> r : rows) {
			r.put("BONUS_PLAN", plans.getOrDefault(String.valueOf(r.get("STAFF_SQ")), new ArrayList<>()));
			Map<String, Object> p = prev.get(r.get("STAFF_SQ"));
			List<Map<String, Object>> flags = flags(r);
			if (p != null && n(p.get("NET")) > 0 && n(r.get("NET")) > 0) {
				double pct = Math.round((n(r.get("NET")) - n(p.get("NET"))) * 1000.0 / n(p.get("NET"))) / 10.0;
				r.put("DELTA_PCT", pct);
				if (Math.abs(pct) >= 10) {
					flag(flags, "전월", "전월 실지급 " + won(n(p.get("NET"))) + "\n이번 달 실지급 " + won(n(r.get("NET"))) + "\n차이 " + signed(n(r.get("NET")) - n(p.get("NET"))) + " (" + (pct > 0 ? "+" : "") + pct + "%)");
				}
			}
		}
		Map<String, Object> out = new HashMap<>();
		out.put("rows", rows);
		out.put("closed", closed);
		// 확인 완료(✕)한 칩은 빼고, 메모·수정이력 건수를 붙인다
		Map<String, Object> q = one("YM", ym);
		Map<String, Set<String>> acks = new HashMap<>();
		mapper.selectAcks(q).forEach(a -> acks.computeIfAbsent(String.valueOf(a.get("STAFF_SQ")), k -> new HashSet<>()).add(str(a.get("FLAG_K"))));
		Map<String, Long> memo = counts(mapper.selectMemoCounts(q)), chg = counts(mapper.selectChangeCounts(q));
		for (Map<String, Object> r : rows) {
			String sq = String.valueOf(r.get("STAFF_SQ"));
			Set<String> a = acks.getOrDefault(sq, new HashSet<>());
			@SuppressWarnings("unchecked")
			List<Map<String, Object>> f = (List<Map<String, Object>>) r.get("FLAGS");
			f.removeIf(x -> a.contains(x.get("K")));
			r.put("MEMO_CNT", memo.getOrDefault(sq, 0L));
			r.put("CHG_CNT", chg.getOrDefault(sq, 0L));
		}
		String payDt = mapper.selectPayDate(q);
		out.put("PAY_DT", payDt != null && !payDt.isEmpty() ? payDt : YearMonth.parse(ym).plusMonths(1).atDay(15).toString()); // 따로 정하지 않으면 익월 15일
		return out;
	}

	private static Map<String, Long> counts(List<Map<String, Object>> rows) {
		Map<String, Long> m = new HashMap<>();
		rows.forEach(r -> m.put(String.valueOf(r.get("STAFF_SQ")), n(r.get("CNT"))));
		return m;
	}

	// ── 2차: 확인 완료·지급일자·메모·수정이력·상세 ──

	public void ack(String ym, Object staffSq, String keyword, String loginId) {
		checkYm(ym);
		require(keyword != null && keyword.matches("[가-힣A-Za-z0-9]{1,20}"), "확인 사항이 올바르지 않습니다.");
		Map<String, Object> q = one("YM", ym);
		q.put("STAFF_SQ", staffSq);
		q.put("FLAG_K", keyword);
		q.put("EMPLY_ID", loginId);
		if (BONUS_K.equals(keyword)) {
			require(!closed(ym), "마감된 달은 상여를 뺄 수 없습니다.");
			if (mapper.saveAck(q) == 1) {
				change(ym, staffSq, "BONUS_EXCLUDE", null, null, "이번 달 상여 제외", loginId);
			}
			return;
		}
		mapper.saveAck(q);
	}

	/** 켠 상여 전체의 단계별 지급 예정 */
	public List<Map<String, Object>> bonusPlans() {
		return BonusCalc.plans(mapper.selectBonusList(), mapper.selectBonusApplies(), mapper.selectDeployList());
	}

	public void payDate(String ym, String date, String loginId) {
		checkYm(ym);
		require(PayCalc.date(date) != null, "지급일자가 날짜가 아닙니다.");
		Map<String, Object> q = one("YM", ym);
		q.put("PAY_DT", PayCalc.date(date).toString());
		q.put("EMPLY_ID", loginId);
		mapper.savePayDate(q);
	}

	public List<Map<String, Object>> memos(Object staffSq, String ym) {
		Map<String, Object> q = one("STAFF_SQ", staffSq);
		q.put("YM", ym == null || ym.isEmpty() ? null : ym);
		return mapper.selectMemos(q);
	}

	public void addMemo(String ym, Object staffSq, String content, String loginId) {
		checkYm(ym);
		String c = content == null ? "" : content.trim();
		require(!c.isEmpty() && c.length() <= 1000, "메모는 1~1000자로 입력해 주세요.");
		Map<String, Object> q = one("YM", ym);
		q.put("STAFF_SQ", staffSq);
		q.put("CONTENT", c);
		q.put("EMPLY_ID", loginId);
		mapper.insertMemo(q);
	}

	public void deleteMemo(Object memoSq, String loginId) {
		Map<String, Object> q = one("MEMO_SQ", memoSq);
		q.put("EMPLY_ID", loginId);
		require(mapper.deleteMemo(q) == 1, "본인이 남긴 메모만 지울 수 있습니다.");
	}

	public List<Map<String, Object>> changes(Object staffSq, String ym) {
		Map<String, Object> q = one("STAFF_SQ", staffSq);
		q.put("YM", ym == null || ym.isEmpty() ? null : ym);
		return mapper.selectChanges(q);
	}

	/** 수정이력 한 건을 되돌린다. 되돌린 것도 이력에 남는다 */
	public void revert(Object chgSq, String loginId) {
		Map<String, Object> h = mapper.selectChange(one("CHG_SQ", chgSq));
		require(h != null, "이력을 찾지 못했습니다.");
		String ym = str(h.get("PAY_YM")), field = str(h.get("FIELD_NM"));
		require(!"Y".equals(h.get("REVERTED_YN")), "이미 되돌린 이력입니다.");
		require(PAY_FIELDS.contains(field) || DED_FIELDS.contains(field), "금액 칸만 되돌릴 수 있습니다.");
		require(!closed(ym), "마감된 달은 되돌릴 수 없습니다. 마감을 해제한 뒤 되돌려 주세요.");
		Map<String, Object> q = one("YM", ym);
		q.put("STAFF_SQ", h.get("STAFF_SQ"));
		List<Map<String, Object>> found = mapper.selectPayrollRows(q);
		require(!found.isEmpty(), "급여 행을 찾지 못했습니다.");
		Map<String, Object> cur = found.get(0);
		Set<String> manual = manual(cur);
		if (AUTO_FIELDS.contains(field)) {
			// 사람이 고친 것을 되돌리면 자동값으로, 자동으로 되돌린 것을 되돌리면 다시 수기값으로
			if (h.get("REASON") == null) {
				manual.remove(field);
			} else if ("자동으로 되돌림".equals(h.get("REASON"))) {
				manual.add(field);
			}
		}
		long value = h.get("BEFORE_VAL") == null || str(h.get("BEFORE_VAL")).isEmpty() ? 0 : BoDeployService.money(h.get("BEFORE_VAL"));
		q.put("FIELD", field);
		q.put("VALUE", value);
		q.put("MANUAL_FIELDS", String.join(",", manual));
		q.put("UPDT_EMPLY_ID", loginId);
		mapper.updatePayrollField(q);
		change(ym, h.get("STAFF_SQ"), field, cur.get(field), value, "되돌리기 #" + chgSq, loginId);
		mapper.markReverted(one("CHG_SQ", chgSq));
	}

	/** 직원 상세 팝업: 인적사항, 그 달 행, 그 해 월별, 상여 내역 */
	@SuppressWarnings("unchecked")
	public Map<String, Object> detail(Object staffSq, String ym) {
		checkYm(ym);
		Map<String, Object> card = mapper.selectStaffCard(one("STAFF_SQ", staffSq));
		require(card != null, "직원을 찾지 못했습니다.");
		String rrn = str(card.remove("RRN_ENC"));
		card.put("BIRTH_DT", birth(rrn.isEmpty() ? "" : common.util.RrnCipher.isEncrypted(rrn) ? common.util.RrnCipher.decrypt(rrn) : rrn));
		Map<String, Object> all = one("STAFF_SQ", staffSq);
		List<Map<String, Object>> rows = derive(mapper.selectPayrollRows(all), mapper.selectPayrollDetails(all));
		Map<String, Object> out = new HashMap<>();
		out.put("card", card);
		out.put("year", rows.stream().filter(r -> str(r.get("PAY_YM")).startsWith(ym.substring(0, 4))).toArray());
		// 지급 = 마감된 달, 이번 달 = 작성중인 달, 예정 = 앞으로, 제외 = 상여 칩 ✕, 미달 = 조건 못 채움, 직접 입력 = 조건 밖 금액
		List<Map<String, Object>> plan = BonusCalc.byRecipient(bonusPlans()).getOrDefault(String.valueOf(staffSq), new ArrayList<>());
		Map<String, Map<String, Object>> byYm = new HashMap<>(), excluded = new HashMap<>();
		rows.forEach(r -> byYm.put(str(r.get("PAY_YM")), r));
		mapper.selectStaffAcks(one("STAFF_SQ", staffSq)).forEach(a -> excluded.put(str(a.get("PAY_YM")), a));
		Map<String, Boolean> closedYm = new HashMap<>();
		List<Map<String, Object>> bonus = new ArrayList<>();
		for (Map<String, Object> p : plan) {
			String m = str(p.get("YM"));
			Map<String, Object> row = byYm.get(m);
			if (m.compareTo(ym) <= 0 && row == null) {
				continue; // 이 시스템 이전 달
			}
			Map<String, Object> b = new HashMap<>(p);
			Map<String, Object> ex = excluded.get(m);
			b.put("BASIS", "기준 " + p.get("BASE_DT") + " → " + p.get("MONTHS") + "개월 " + p.get("ACHIEVE_DT") + ("FULL".equals(p.get("COND")) ? " · 만근" : "TENURE".equals(p.get("COND")) ? " · 근속" : ""));
			if (ex != null) {
				b.put("STATUS", "제외");
				b.put("NOTE", str(ex.get("EMPLY_NM")) + " · " + str(ex.get("REG_DT")));
			} else if (!Boolean.TRUE.equals(p.get("OK"))) {
				b.put("STATUS", "미달");
				b.put("NOTE", p.get("WHY"));
			} else if (m.compareTo(ym) > 0) {
				b.put("STATUS", "예정");
			} else {
				b.put("STATUS", closedYm.computeIfAbsent(m, this::closed) ? "지급" : "이번 달");
			}
			bonus.add(b);
		}
		for (Map<String, Object> r : rows) {
			String m = str(r.get("PAY_YM"));
			if (n(r.get("BONUS_AMT")) > 0 && (manual(r).contains("BONUS_AMT") || BonusCalc.sumFor(plan, m) == 0 || excluded.containsKey(m))) {
				Map<String, Object> b = new HashMap<>();
				b.put("YM", m);
				b.put("AMT", n(r.get("BONUS_AMT")));
				b.put("LABEL", "엑셀 이관".equals(r.get("MEMO")) ? "상여(엑셀 이관)" : "상여(직접 입력)");
				b.put("BASIS", "상여관리 조건 밖");
				b.put("STATUS", closedYm.computeIfAbsent(m, this::closed) ? "지급" : "이번 달");
				bonus.add(b);
			}
		}
		bonus.sort((a, b) -> str(b.get("YM")).compareTo(str(a.get("YM"))));
		out.put("bonus", bonus);
		return out;
	}

	/** 주민번호(원문)에서 생년월일만. 뒷자리 첫 숫자로 세기를 정한다 */
	static String birth(String rrn) {
		String d = rrn.replaceAll("[^0-9]", "");
		if (d.length() < 7) {
			return "";
		}
		char g = d.charAt(6);
		String century = g == '1' || g == '2' || g == '5' || g == '6' ? "19" : g == '3' || g == '4' || g == '7' || g == '8' ? "20" : "18";
		return century + d.substring(0, 2) + "-" + d.substring(2, 4) + "-" + d.substring(4, 6);
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
		List<Map<String, Object>> months = new ArrayList<>();
		for (Map<String, Object> d : details) {
			if (!String.valueOf(deploySq).equals(String.valueOf(d.get("DEPLOY_SQ")))) {
				continue;
			}
			Map<String, Object> month = byYm.get(d.get("PAY_YM"));
			boolean only = month != null && ((List<?>) month.get("DETAILS")).size() == 1;
			sale += n(d.get("REAL_SALE"));
			pay += only ? n(month.get("PAY_TOTAL")) : n(d.get("BASE_AMT"));
			company += only ? n(month.get("COMPANY")) : 0;
			// 한 달에 투입 건이 여럿이면 공제는 사람 단위라 나눌 수 없어 이 건의 기본만 보인다
			Map<String, Object> mo = new HashMap<>();
			mo.put("PAY_YM", d.get("PAY_YM"));
			mo.put("WORK_DAYS", d.get("WORK_DAYS"));
			mo.put("TOTAL_DAYS", d.get("TOTAL_DAYS"));
			mo.put("SALE_PRICE", n(d.get("SALE_PRICE")));
			mo.put("COST_PRICE", n(d.get("COST_PRICE")));
			mo.put("REAL_SALE", n(d.get("REAL_SALE")));
			mo.put("PAY", only ? n(month.get("PAY_TOTAL")) : n(d.get("BASE_AMT")));
			mo.put("DED", only ? month.get("DED_TOTAL") : null);
			mo.put("NET", only ? month.get("NET") : null);
			mo.put("PROFIT", only ? n(month.get("PROFIT")) : n(d.get("REAL_SALE")) - n(d.get("BASE_AMT")));
			mo.put("SHARED", !only);
			months.add(mo);
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
		out.put("MONTHS", months);
		out.put("SALE", sale);
		out.put("PAY", pay);
		out.put("PROFIT", sale - pay - company);
		return out;
	}

	// ── 다시 계산 ──

	// ── 계산 기준값 (급여관리 계산기 버튼) ──

	/** DB 의 기준값을 계산에 쓴다. 표가 없거나 읽지 못하면 코드 기본값 그대로 */
	void loadParams() {
		try {
			mapper.selectPayrollParams().forEach(p -> PayCalc.setParam(str(p.get("PARAM_K")), n(p.get("PARAM_V"))));
		} catch (RuntimeException e) {
			System.out.println("PAYROLL_PARAM_LOAD " + e.getClass().getSimpleName());
		}
	}

	public List<Map<String, Object>> params() {
		Map<String, Map<String, Object>> saved = new HashMap<>();
		mapper.selectPayrollParams().forEach(p -> saved.put(str(p.get("PARAM_K")), p));
		List<Map<String, Object>> out = new ArrayList<>();
		for (Object[] d : PayCalc.PARAMS) {
			Map<String, Object> m = new HashMap<>(saved.getOrDefault((String) d[0], new HashMap<>()));
			m.put("PARAM_K", d[0]);
			m.put("NM", d[1]);
			m.put("MIN", d[2]);
			m.put("MAX", d[3]);
			m.putIfAbsent("PARAM_V", PayCalc.param((String) d[0]));
			out.add(m);
		}
		return out;
	}

	/** 기준값을 바꾼다. 마감된 달은 다시 계산하지 않으므로 그대로이고, 바꾼 것은 수정이력(직원 없음)에 남는다 */
	public void saveParam(String key, String raw, String loginId) {
		Object[] def = null;
		for (Object[] d : PayCalc.PARAMS) {
			if (d[0].equals(key)) {
				def = d;
			}
		}
		require(def != null, "고칠 수 없는 기준값입니다.");
		long v = BoDeployService.money(raw);
		require(v >= (Long) def[2] && v <= (Long) def[3], def[1] + "은(는) " + won((Long) def[2]) + " ~ " + won((Long) def[3]) + " 사이로 입력해 주세요.");
		require(!"PRORATE_UNIT".equals(key) || Arrays.asList(1L, 10L, 100L, 1000L, 10000L).contains(v), "버림 단위는 1·10·100·1,000·10,000 중 하나입니다.");
		loadParams();
		long before = PayCalc.param(key);
		Map<String, Object> q = one("PARAM_K", key);
		q.put("PARAM_V", v);
		q.put("EMPLY_ID", loginId);
		mapper.savePayrollParam(q);
		PayCalc.setParam(key, v);
		change(YearMonth.now().toString(), 0, "PARAM_" + key, before, v, "계산 기준값 변경", loginId);
	}

	void sync(String ym) {
		loadParams();
		YearMonth m = YearMonth.parse(ym);
		int total = m.lengthOfMonth();
		Map<Object, List<Map<String, Object>>> byStaff = new LinkedHashMap<>();
		List<Map<String, Object>> deploys = mapper.selectDeployList();
		for (Map<String, Object> d : deploys) {
			byStaff.computeIfAbsent(d.get("STAFF_SQ"), k -> new ArrayList<>()).add(d);
		}
		Map<String, List<Map<String, Object>>> plans = BonusCalc.byRecipient(BonusCalc.plans(mapper.selectBonusList(), mapper.selectBonusApplies(), deploys));
		Set<String> noBonus = new HashSet<>(); // 상여 칩 ✕ 로 이번 달 상여에서 뺀 사람
		mapper.selectAcks(one("YM", ym)).forEach(a -> {
			if (BONUS_K.equals(a.get("FLAG_K"))) {
				noBonus.add(String.valueOf(a.get("STAFF_SQ")));
			}
		});
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
			Map<String, Object> primary = overlap.isEmpty() ? lastPast : pickPrimary(overlap);
			// 투입이 없는 달은 고정급(정규·수습) 재직자만 대기로 넣는다
			if (primary == null || (overlap.isEmpty() && (!PayCalc.isSalaried(str(primary.get("EMP_TYPE_CD"))) || "LEFT".equals(staff.get("STATUS_CD"))))) {
				continue;
			}
			if (overlap.isEmpty()) {
				primary.put("WORK_DAYS", 0);
				overlap.add(primary);
			}
			String type = str(primary.get("EMP_TYPE_CD"));
			boolean hasOwn = overlap.stream().anyMatch(x -> PayCalc.isOwn(str(x.get("EMP_TYPE_CD"))));
			long base = 0, meal = 0;
			for (Map<String, Object> d : overlap) {
				int days = (Integer) d.get("WORK_DAYS");
				long b;
				// 건마다 그 건의 형태로 계산한다: 정규 옆의 외부·기타 계약도 엑셀처럼 그 건 계약단가를 일할로 더한다
				if (!PayCalc.isSalaried(type) || !PayCalc.isSalaried(str(d.get("EMP_TYPE_CD")))) {
					b = PayCalc.prorate(n(d.get("COST_PRICE")), days, total);
				} else if (d == primary) {
					LocalDate end = PayCalc.date(d.get("END_DT"));
					LocalDate lastDay = end != null && YearMonth.from(end).equals(m) ? end : m.atEndOfMonth();
					long[] bm = PayCalc.salaried(type, n(d.get("COST_PRICE")), ym, PayCalc.date(staff.get("JOIN_DT")), PayCalc.date(d.get("PROB_END_DT")), lastDay);
					b = bm[0];
					meal = bm[1];
					if (PayCalc.REGULAR.equals(type) && leave != null && YearMonth.from(leave).equals(m)) {
						b = PayCalc.leaveMonth(n(d.get("COST_PRICE")), days, total);
						meal = 0;
					}
				} else {
					b = 0; // 고정급은 한 달에 한 번만
				}
				// 본인 계약이 있는 사람의 기타계약·외부(수수료·기타)는 업체에 주는 돈이라 급여 기본에 넣지 않는다. 건별 기본(PAYROLL_D)에는 남겨 derive 가 기타·수수료로 센다
				if (!hasOwn || PayCalc.isOwn(str(d.get("EMP_TYPE_CD")))) {
					base += b;
				}
				Map<String, Object> row = new HashMap<>();
				row.put("YM", ym);
				row.put("DEPLOY_SQ", d.get("DEPLOY_SQ"));
				row.put("STAFF_SQ", d.get("STAFF_SQ"));
				row.put("WORK_DAYS", days);
				row.put("TOTAL_DAYS", total);
				// 고객사 직접계약 금액만큼 우리 매출이 준다
				long sale = Math.max(0, n(d.get("SALE_PRICE")) - n(d.get("CLIENT_DIRECT_AMT")));
				row.put("SALE_PRICE", sale);
				row.put("COST_PRICE", n(d.get("COST_PRICE")));
				// 같은 기간의 정규 건과 수습 건은 한 투입이라 매출은 기준 건 쪽에서만 센다
				int saleDays = days;
				if (d != primary && PayCalc.isSalaried(str(d.get("EMP_TYPE_CD"))) && PayCalc.isSalaried(type)) {
					saleDays -= PayCalc.overlapDays(PayCalc.date(d.get("START_DT")), PayCalc.date(d.get("END_DT")), PayCalc.date(primary.get("START_DT")), PayCalc.date(primary.get("END_DT")), ym);
				}
				row.put("REAL_SALE", PayCalc.prorate(sale, Math.max(0, saleDays), total));
				row.put("BASE_AMT", b);
				mapper.savePayrollDetail(row);
				keepDeploy.add(d.get("DEPLOY_SQ"));
			}
			String sq = String.valueOf(staff.get("STAFF_SQ"));
			long bonus = noBonus.contains(sq) ? 0 : BonusCalc.sumFor(plans.get(sq), ym);
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

	/** 그 달 급여 형태의 기준 건. 정규·수습 건, 없으면 본인 계약 건(특고·사업자·알바), 그것도 없으면 마지막 건(목록은 투입일 순) */
	static Map<String, Object> pickPrimary(List<Map<String, Object>> overlap) {
		for (boolean salariedOnly : new boolean[] { true, false }) {
			for (int i = overlap.size() - 1; i >= 0; i--) {
				String t = str(overlap.get(i).get("EMP_TYPE_CD"));
				if (salariedOnly ? PayCalc.isSalaried(t) : PayCalc.isOwn(t)) {
					return overlap.get(i);
				}
			}
		}
		return overlap.get(overlap.size() - 1);
	}

	/**
	 * 기본 칸을 어떻게 셌는지 투입 건별 한 줄씩. sync 와 같은 식을 지금 기준값으로 다시 써 보고,
	 * 저장된 건별 기본과 다르면(마감 달의 엑셀 값, 바뀐 기준값) 저장된 금액만 보인다
	 */
	static List<String> baseHow(Map<String, Object> r, List<Map<String, Object>> ds) {
		List<String> out = new ArrayList<>();
		String ym = str(r.get("PAY_YM"));
		long auto = 0;
		boolean ownPerson = ds.stream().anyMatch(d -> PayCalc.isOwn(str(d.get("DEPLOY_TYPE"))));
		for (Map<String, Object> d : ds) {
			String t = str(d.get("DEPLOY_TYPE")).isEmpty() ? str(r.get("EMP_TYPE_CD")) : str(d.get("DEPLOY_TYPE"));
			long b = n(d.get("BASE_AMT")), cost = n(d.get("COST_PRICE"));
			int days = (int) n(d.get("WORK_DAYS")), total = (int) n(d.get("TOTAL_DAYS"));
			boolean vendor = ownPerson && !PayCalc.isOwn(t);
			auto += vendor ? 0 : b;
			// 돈 흐름 카드용: 이 건이 급여·기타·수수료 중 무엇인지
			d.put("KIND", !vendor ? "PAY" : PayCalc.isFee(t) ? "FEE" : "ETC");
			String how;
			if (ym.isEmpty() || total == 0) {
				how = won(b);
			} else if (!PayCalc.isSalaried(t)) {
				how = PayCalc.prorate(cost, days, total) == b ? PayCalc.prorateHow(cost, days, total) : won(b) + " (저장된 값)";
			} else if (b == 0 && days > 0) {
				how = "0 (고정급은 한 달에 한 건만 셉니다)";
			} else if (PayCalc.REGULAR.equals(t) && PayCalc.date(r.get("LEAVE_DT")) != null && YearMonth.from(PayCalc.date(r.get("LEAVE_DT"))).equals(YearMonth.parse(ym))) {
				long v = PayCalc.leaveMonth(cost, days, total);
				how = v == b ? "퇴사 달: 계약단가 " + won(cost) + " × " + days + "/" + total + "일 = " + won(b) + " (식대 없음)" : won(b) + " (저장된 값)";
			} else {
				YearMonth m = YearMonth.parse(ym);
				LocalDate end = PayCalc.date(d.get("END_DT"));
				LocalDate lastDay = end != null && YearMonth.from(end).equals(m) ? end : m.atEndOfMonth();
				String s = PayCalc.salariedHow(t, cost, ym, PayCalc.date(r.get("JOIN_DT")), PayCalc.date(d.get("PROB_END_DT")), lastDay);
				how = s.contains("= " + won(b)) ? s : won(b) + " (저장된 값)";
			}
			d.put("HOW", how);
			out.add((vendor ? (PayCalc.isFee(t) ? "[수수료 · 급여 아님] " : "[기타 · 급여 아님] ") : "") + label(d) + " · " + (days < total ? days + "/" + total + "일" : "만근") + " : " + how);
		}
		if (manual(r).contains("BASE_AMT")) {
			out.add("직접 입력 " + won(n(r.get("BASE_AMT"))) + (ds.isEmpty() ? "" : " (자동 계산이면 " + won(auto) + ")"));
		}
		return out;
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
			String type = str(r.get("EMP_TYPE_CD"));
			boolean salaried = PayCalc.isSalaried(type);
			// 본인 계약이 있는 사람의 기타계약·외부 몫은 업체에 주는 돈: 급여(기본)가 아니라 기타(BUY)·수수료(FEE)로 영업이익에서만 뺀다
			boolean hasOwn = ds.stream().anyMatch(d -> PayCalc.isOwn(str(d.get("DEPLOY_TYPE"))));
			long buy = 0, fee = 0;
			for (Map<String, Object> d : ds) {
				sale += n(d.get("REAL_SALE"));
				days += n(d.get("WORK_DAYS"));
				totalDays = n(d.get("TOTAL_DAYS"));
				String dt = str(d.get("DEPLOY_TYPE"));
				if (PayCalc.isSalaried(dt)) {
					salaried = true;
				}
				if (hasOwn && !dt.isEmpty() && !PayCalc.isOwn(dt)) {
					if (PayCalc.isFee(dt)) {
						fee += n(d.get("BASE_AMT"));
					} else {
						buy += n(d.get("BASE_AMT"));
					}
				}
			}
			long company = salaried
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
			r.put("BUY", buy);
			r.put("FEE", fee);
			// 투입현황에서 내근직으로 켠 건만 있는 사람(임원·내근)은 엑셀처럼 영업이익에서 뺀다. 급여·공제는 그대로
			boolean office = !ds.isEmpty() && ds.stream().allMatch(d -> "Y".equals(d.get("OFFICE_YN")));
			r.put("OFFICE", office);
			r.put("PROFIT", office ? 0 : sale - pay - company - buy - fee);
			r.put("WORK_DAYS", Math.min(days, totalDays));
			r.put("TOTAL_DAYS", totalDays);
			r.put("SALE_PRICE", latest == null ? 0 : n(latest.get("SALE_PRICE")));
			r.put("COST_PRICE", latest == null ? 0 : n(latest.get("COST_PRICE")));
			r.put("BASE_HOW", baseHow(r, ds));
		}
		return rows;
	}

	/** 확인 사항: { K 짧은 키워드, D 마우스를 올리면 보일 계산·근거(줄바꿈 구분) } */
	@SuppressWarnings("unchecked")
	static List<Map<String, Object>> flags(Map<String, Object> r) {
		List<Map<String, Object>> f = new ArrayList<>();
		if (NEED_DED.contains(str(r.get("EMP_TYPE_CD"))) && n(r.get("DED_TOTAL")) == 0) {
			flag(f, "공제없음", "공제 합계가 0원입니다.\n공제 불러오기로 대장을 넣거나 칸을 눌러 입력하세요.");
		}
		if (n(r.get("WORK_DAYS")) == 0 && n(r.get("TOTAL_DAYS")) > 0) {
			flag(f, "대기", "이번 달 투입이 없습니다.\n고정급 기본 " + won(n(r.get("BASE_AMT"))) + " 은 그대로 지급합니다.");
		} else if (n(r.get("WORK_DAYS")) < n(r.get("TOTAL_DAYS"))) {
			StringBuilder d = new StringBuilder();
			for (Map<String, Object> x : (List<Map<String, Object>>) r.get("DETAILS")) {
				if (n(x.get("WORK_DAYS")) < n(x.get("TOTAL_DAYS"))) {
					long cost = n(x.get("COST_PRICE")), raw = n(x.get("TOTAL_DAYS")) == 0 ? 0 : cost * n(x.get("WORK_DAYS")) / n(x.get("TOTAL_DAYS"));
					d.append(d.length() > 0 ? "\n" : "").append(label(x)).append(": (계약단가 ").append(won(cost)).append(" ÷ ").append(x.get("TOTAL_DAYS"))
							.append("일) × ").append(x.get("WORK_DAYS")).append("일 = ").append(won(n(x.get("BASE_AMT"))))
							.append(raw != n(x.get("BASE_AMT")) && raw / PayCalc.PRORATE_UNIT * PayCalc.PRORATE_UNIT == n(x.get("BASE_AMT")) ? " (" + won(PayCalc.PRORATE_UNIT) + "원 미만 버림)" : "");
				}
			}
			flag(f, "일할", d.toString());
		}
		List<Map<String, Object>> plan = (List<Map<String, Object>>) r.getOrDefault("BONUS_PLAN", new ArrayList<>());
		if (n(r.get("BONUS_AMT")) > 0) {
			StringBuilder d = new StringBuilder();
			for (Map<String, Object> b : plan) {
				if (str(b.get("YM")).equals(r.get("PAY_YM")) && Boolean.TRUE.equals(b.get("OK"))) {
					d.append(b.get("LABEL")).append(" ").append(won(n(b.get("AMT")))).append(" (").append(b.get("ACHIEVE_DT")).append(" 달성)\n");
				}
			}
			flag(f, BONUS_K, d + "상여 칸 " + won(n(r.get("BONUS_AMT"))) + (manual(r).contains("BONUS_AMT") ? " (직접 입력)" : "") + "\n✕ 를 누르면 이번 달 상여에서 뺍니다.");
		}
		StringBuilder miss = new StringBuilder();
		for (Map<String, Object> b : plan) {
			if (str(b.get("YM")).equals(r.get("PAY_YM")) && !Boolean.TRUE.equals(b.get("OK"))) {
				miss.append(b.get("LABEL")).append(" ").append(won(n(b.get("AMT")))).append("\n").append(b.get("WHY")).append("\n");
			}
		}
		if (miss.length() > 0) {
			flag(f, "만근미달", miss + "조건을 못 채워 상여에 넣지 않았습니다. 지급하려면 상여 칸을 직접 고치세요.");
		}
		if (!manual(r).isEmpty()) {
			List<String> names = new ArrayList<>();
			for (String m : manual(r)) {
				names.add(m.equals("BASE_AMT") ? "기본" : m.equals("MEAL_AMT") ? "식대" : m.equals("BONUS_AMT") ? "상여" : m);
			}
			flag(f, "수기", "사람이 고친 칸: " + String.join(", ", names) + "\n자동계산을 덮어쓰지 않습니다. 빈칸으로 저장하면 자동값으로 돌아갑니다.");
		}
		if (r.get("LEDGER_PAY") != null && n(r.get("LEDGER_PAY")) != n(r.get("PAY_TOTAL"))) {
			flag(f, "대장차", "대장 지급합계 " + won(n(r.get("LEDGER_PAY"))) + "\n화면 지급계 " + won(n(r.get("PAY_TOTAL"))) + "\n차이 " + signed(n(r.get("LEDGER_PAY")) - n(r.get("PAY_TOTAL")))
					+ "\n대장이 맞으면 해당 지급 칸을 고치세요.");
		}
		r.put("FLAGS", f);
		return f;
	}

	private static void flag(List<Map<String, Object>> f, String keyword, String detail) {
		Map<String, Object> m = new HashMap<>();
		m.put("K", keyword);
		m.put("D", detail);
		f.add(m);
	}

	private static String label(Map<String, Object> d) {
		String s = (str(d.get("CLIENT_NM")) + " " + str(d.get("PRJ_NM"))).trim();
		return s.isEmpty() ? "투입" : s;
	}

	private static String won(long v) {
		return String.format("%,d", v);
	}

	private static String signed(long v) {
		return (v > 0 ? "+" : "") + String.format("%,d", v);
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

	void change(String ym, Object staffSq, String field, Object before, Object after, String reason, String loginId) {
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
