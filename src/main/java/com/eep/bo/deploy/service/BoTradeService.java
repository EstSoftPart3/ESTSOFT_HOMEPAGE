package com.eep.bo.deploy.service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.PostConstruct;
import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import com.eep.mapper.BoTradeMapper;

/**
 * 매출관리·매입관리. 한 달의 건 = 투입 건(자동) + 일반 건(직접 등록).
 * 세금계산서는 건을 거래처별로 몇 줄씩 묶은 것이고(INV_NO), 실제 발행은 홈택스에서 하고 여기서는 묶음·순서·발급 표시만 둔다
 */
@Service
public class BoTradeService {

	@Autowired
	private BoTradeMapper mapper;
	@Autowired
	private DataSource dataSource;

	private TransactionTemplate tx;

	@PostConstruct
	public void init() {
		tx = new TransactionTemplate(new DataSourceTransactionManager(dataSource));
		try {
			mapper.ensureSchema();
		} catch (RuntimeException e) {
			System.out.println("TRADE_SCHEMA_ERROR " + e.getClass().getSimpleName());
		}
	}

	public static String kind(String path) {
		if ("sale".equals(path)) return "SALE";
		if ("buy".equals(path)) return "BUY";
		throw new IllegalArgumentException("주소가 올바르지 않습니다.");
	}

	public Map<String, Object> options(String kind) {
		Map<String, Object> out = new HashMap<>();
		out.put("partners", mapper.selectPartners());
		out.put("types", mapper.selectTypes(q(kind, null)));
		return out;
	}

	/** 그 달의 모든 건. 투입 건에는 STAFF_SQ 가 있어 컨트롤러가 시크릿 직원을 걸러 낸다 */
	public List<Map<String, Object>> lines(String kind, String ym) {
		YearMonth m = month(ym);
		Map<String, Object> q = q(kind, ym);
		q.put("FROM_DT", m.atDay(1).toString());
		q.put("TO_DT", m.atEndOfMonth().toString());
		// shortcut: 반복 건은 그 달을 처음 열 때 만든다(동시에 두 사람이 처음 열면 두 번 생길 수 있다), 겹치면 배치로 옮긴다
		if (!closed(ym)) mapper.insertRepeats(q);
		Map<String, Map<String, Object>> saved = new HashMap<>();
		for (Map<String, Object> l : mapper.selectLines(q)) saved.put(l.get("SRC_CD") + ":" + l.get("SRC_SQ"), l);
		List<Map<String, Object>> out = new ArrayList<>();
		int total = m.lengthOfMonth();
		for (Map<String, Object> d : mapper.selectDeployLines(q)) {
			LocalDate start = PayCalc.date(d.get("START_DT")), end = PayCalc.date(d.get("END_DT"));
			if (start == null) continue;
			int days = PayCalc.workDays(start, end, ym);
			boolean sale = "SALE".equals(kind), closed = "Y".equals(d.get("CLOSED_YN"));
			long monthly = sale ? Math.max(0, n(d.get("SALE_PRICE")) - n(d.get("DIRECT_AMT"))) : n(d.get("COST_PRICE"));
			Object fixed = sale ? d.get("REAL_SALE") : d.get("BASE_AMT");
			// 마감한 달은 급여관리에 남은 금액, 아니면 투입 단가 일할
			long calc = closed && fixed != null ? n(fixed) : PayCalc.prorate(monthly, days, total);
			Map<String, Object> l = line("D", d.get("DEPLOY_SQ"), "투입", d, saved);
			if (calc == 0 && l.get("AMT_FIXED") == null) continue;
			l.put("STAFF_SQ", d.get("STAFF_SQ"));
			l.put("STAFF_NM", d.get("STAFF_NM"));
			l.put("ITEM_NM", s(d.get("PRJ_NM")) + "-" + s(d.get("STAFF_NM")));
			l.put("PRJ_NM", d.get("PRJ_NM"));
			l.put("MONTHLY", monthly);
			LocalDate from = start.isBefore(m.atDay(1)) ? m.atDay(1) : start, to = end == null || end.isAfter(m.atEndOfMonth()) ? m.atEndOfMonth() : end;
			l.put("START_DT", from.toString());
			l.put("END_DT", to.toString());
			l.put("CALC_AMT", calc);
			l.put("AMT", l.get("AMT_FIXED") == null ? calc : n(l.get("AMT_FIXED")));
			l.put("HOW", closed && fixed != null ? "마감한 달의 급여관리 금액" : "월 " + monthly + " ÷ " + total + "일 × " + days + "일");
			out.add(l);
		}
		for (Map<String, Object> t : mapper.selectTrades(q)) {
			Map<String, Object> l = line("M", t.get("TRADE_SQ"), s(t.get("TYPE_NM")), t, saved);
			l.put("ITEM_NM", t.get("ITEM_NM"));
			l.put("START_DT", t.get("START_DT"));
			l.put("END_DT", t.get("END_DT"));
			l.put("AMT", n(t.get("AMT")));
			l.put("MEMO", t.get("MEMO"));
			l.put("REPEAT_UNTIL", t.get("REPEAT_UNTIL"));
			out.add(l);
		}
		return out;
	}

	private static Map<String, Object> line(String src, Object sq, String type, Map<String, Object> row, Map<String, Map<String, Object>> saved) {
		Map<String, Object> l = new HashMap<>(), sv = saved.get(src + ":" + sq);
		l.put("KEY", src + ":" + sq);
		l.put("SRC_CD", src);
		l.put("SRC_SQ", sq);
		l.put("TYPE_NM", type);
		l.put("PARTNER_SQ", row.get("PARTNER_SQ"));
		l.put("PARTNER_NM", row.get("PARTNER_NM"));
		if (sv != null) {
			l.put("INV_NO", sv.get("INV_NO"));
			l.put("SORT_NO", sv.get("SORT_NO"));
			l.put("ISSUE_DT", sv.get("ISSUE_DT"));
			l.put("AMT_FIXED", sv.get("AMT"));
		}
		return l;
	}

	public void saveTrade(String kind, Map<String, Object> p, String loginId) {
		String ym = s(p.get("YM"));
		month(ym);
		open(ym);
		// 매달 반복: 비우면 반복 없음, 종료월(yyyy-MM) 또는 9999-12(끌 때까지)
		String until = s(p.get("REPEAT_UNTIL")).trim();
		if (!until.isEmpty() && (!until.matches("\\d{4}-(0[1-9]|1[0-2])") || until.compareTo(ym) < 0)) throw new IllegalArgumentException("반복 종료월은 이 달이나 그 뒤로 골라 주세요.");
		p.put("REPEAT_UNTIL", until);
		// 거래처는 등록된 곳을 고르거나, 등록하지 않은 곳은 이름만 적는다
		String partnerNm = s(p.get("PARTNER_SQ")).isEmpty() ? s(p.get("PARTNER_NM")).trim() : "";
		if (s(p.get("PARTNER_SQ")).isEmpty() && (partnerNm.isEmpty() || partnerNm.length() > 200)) throw new IllegalArgumentException("거래처를 고르거나 이름을 200자 안으로 입력해 주세요.");
		p.put("PARTNER_NM", partnerNm);
		String item = s(p.get("ITEM_NM")).trim(), type = s(p.get("TYPE_NM")).trim();
		if (item.isEmpty() || item.length() > 300) throw new IllegalArgumentException("품목을 300자 안으로 입력해 주세요.");
		if (type.isEmpty() || type.length() > 50 || "투입".equals(type)) throw new IllegalArgumentException("구분을 입력해 주세요. ('투입'은 투입 건에만 씁니다)");
		for (String f : new String[] { "START_DT", "END_DT" }) {
			if (!s(p.get(f)).isEmpty() && PayCalc.date(p.get(f)) == null) throw new IllegalArgumentException("날짜를 확인해 주세요.");
		}
		String amt = s(p.get("AMT")).replace(",", "").trim();
		if (!amt.matches("-?\\d{1,13}")) throw new IllegalArgumentException("공급가액을 숫자로 입력해 주세요.");
		p.put("KIND_CD", kind);
		p.put("ITEM_NM", item);
		p.put("TYPE_NM", type);
		p.put("AMT", Long.parseLong(amt));
		p.put("UPDT_EMPLY_ID", loginId);
		if (s(p.get("TRADE_SQ")).isEmpty()) {
			mapper.insertTrade(p);
			return;
		}
		String saved = tradeYm(kind, p.get("TRADE_SQ"));
		open(saved);
		notIssued(kind, saved, "M", p.get("TRADE_SQ"));
		mapper.updateTrade(p);
	}

	public void deleteTrade(String kind, Object tradeSq) {
		String ym = tradeYm(kind, tradeSq);
		open(ym);
		notIssued(kind, ym, "M", tradeSq);
		Map<String, Object> q = key(kind, ym, "M:" + tradeSq);
		q.put("TRADE_SQ", tradeSq);
		q.put("PREV_YM", YearMonth.parse(ym).minusMonths(1).toString());
		tx.execute(st -> {
			mapper.stopRepeat(q); // 지운 달에 다시 생기지 않게 반복을 전달까지로 줄인다
			mapper.deleteTrade(q);
			mapper.deleteLine(q);
			return null;
		});
	}

	private String tradeYm(String kind, Object tradeSq) {
		Map<String, Object> q = q(kind, null);
		q.put("TRADE_SQ", tradeSq);
		String ym = mapper.selectTradeYm(q);
		if (ym == null) throw new IllegalArgumentException("건을 찾지 못했습니다.");
		return ym;
	}

	/** 투입 건 금액을 이 달만 고친다. 비우면 계산 금액으로 돌아간다 */
	public void setAmount(String kind, String ym, String key, String amt, Set<String> valid) {
		month(ym);
		open(ym);
		if (!key.startsWith("D:") || !valid.contains(key)) throw new IllegalArgumentException("건을 찾지 못했습니다.");
		String v = amt == null ? "" : amt.replace(",", "").trim();
		if (!v.isEmpty() && !v.matches("-?\\d{1,13}")) throw new IllegalArgumentException("금액을 숫자로 입력해 주세요.");
		Map<String, Object> q = key(kind, ym, key);
		notIssued(kind, ym, "D", q.get("SRC_SQ"));
		q.put("AMT", v.isEmpty() ? null : Long.parseLong(v));
		mapper.upsertAmt(q);
	}

	/** items: "D:12:1:0" = 건:계산서 번호:순서. 화면에 보이는 건(valid)만 받는다 */
	public void saveLayout(String kind, String ym, String[] items, Set<String> valid) {
		month(ym);
		List<Map<String, Object>> rows = new ArrayList<>();
		for (String it : items == null ? new String[0] : items) {
			String[] p = it.split(":");
			if (p.length != 4 || !valid.contains(p[0] + ":" + p[1]) || !p[2].matches("\\d{1,4}") || !p[3].matches("\\d{1,4}")) throw new IllegalArgumentException("묶음을 다시 불러와 주세요.");
			Map<String, Object> q = key(kind, ym, p[0] + ":" + p[1]);
			q.put("INV_NO", Integer.parseInt(p[2]));
			q.put("SORT_NO", Integer.parseInt(p[3]));
			rows.add(q);
		}
		tx.execute(st -> {
			rows.forEach(mapper::upsertLayout);
			return null;
		});
	}

	/** 발급 완료 표시·취소. 묶음이 저장된 건만 된다 */
	public void issue(String kind, String ym, String[] keys, boolean on, Set<String> valid) {
		month(ym);
		String today = LocalDate.now(ZoneId.of("Asia/Seoul")).toString();
		tx.execute(st -> {
			for (String k : keys) {
				if (!valid.contains(k)) throw new IllegalArgumentException("건을 찾지 못했습니다.");
				Map<String, Object> q = key(kind, ym, k);
				q.put("ISSUE_DT", on ? today : null);
				if (mapper.updateIssue(q) != 1) throw new IllegalArgumentException("묶음을 먼저 저장해 주세요.");
			}
			return null;
		});
	}

	/** 매출·매입 마감(급여 마감과 따로). 마감한 달은 건 등록·수정·삭제와 금액 고치기를 막는다. 세금계산서 묶음·발급 표시는 그대로 된다 */
	public boolean closed(String ym) {
		return mapper.selectClosed(ym) > 0;
	}

	public void setClosed(String ym, boolean close, String loginId) {
		month(ym);
		if (!close) {
			mapper.deleteClose(ym);
			return;
		}
		Map<String, Object> q = q(null, ym);
		q.put("UPDT_EMPLY_ID", loginId);
		mapper.insertClose(q);
	}

	private void open(String ym) {
		if (closed(ym)) throw new IllegalArgumentException("매출·매입을 마감한 달입니다. 마감을 해제한 뒤 고쳐 주세요.");
	}

	private void notIssued(String kind, String ym, String src, Object sq) {
		if (mapper.selectIssueDt(key(kind, ym, src + ":" + sq)) != null) throw new IllegalArgumentException("발급 완료로 표시한 건입니다. 세금계산서 화면에서 발급을 취소한 뒤 고쳐 주세요.");
	}

	private static Map<String, Object> key(String kind, String ym, String key) {
		String[] p = key.split(":");
		if (p.length != 2 || !p[0].matches("[DM]") || !p[1].matches("\\d{1,9}")) throw new IllegalArgumentException("건을 찾지 못했습니다.");
		Map<String, Object> q = q(kind, ym);
		q.put("SRC_CD", p[0]);
		q.put("SRC_SQ", Integer.parseInt(p[1]));
		return q;
	}

	private static Map<String, Object> q(String kind, String ym) {
		Map<String, Object> q = new HashMap<>();
		q.put("KIND_CD", kind);
		q.put("YM", ym);
		return q;
	}

	static YearMonth month(String ym) {
		if (ym == null || !ym.matches("\\d{4}-(0[1-9]|1[0-2])")) throw new IllegalArgumentException("기준월을 확인해 주세요.");
		return YearMonth.parse(ym);
	}

	private static long n(Object o) {
		return o == null ? 0 : ((Number) o).longValue();
	}

	private static String s(Object o) {
		return o == null ? "" : o.toString();
	}
}
