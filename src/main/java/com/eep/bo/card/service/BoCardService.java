package com.eep.bo.card.service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.PostConstruct;
import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import com.eep.mapper.BoCardMapper;

/** 경영지원 - 법인카드: 카드 등록, 날짜별 사용 등록, 기간 정산(카드사 엑셀 대조·바로 수정·중간 저장·마감), 마감 목록과 엑셀 */
@Service
public class BoCardService {

	@Autowired
	private BoCardMapper mapper;
	@Autowired
	private DataSource dataSource;

	private TransactionTemplate tx;

	@PostConstruct
	public void init() {
		tx = new TransactionTemplate(new DataSourceTransactionManager(dataSource));
		try {
			mapper.ensureSchema();
		} catch (RuntimeException e) {
			System.out.println("CARD_SCHEMA_ERROR " + e.getClass().getSimpleName());
		}
	}

	// ── 카드 ──

	/** 관리자(슈퍼관리자·법인카드 메뉴를 받은 다른 역할)는 모든 카드, 나머지는 본인이 사용자인 카드만 */
	private boolean manager(String loginId) {
		return mapper.countManager(loginId) > 0;
	}

	public Map<String, Object> cards(String loginId) {
		boolean mgr = manager(loginId);
		Map<String, Object> key = one("YM", YearMonth.now(ZoneId.of("Asia/Seoul")).toString()), out = new HashMap<>();
		if (!mgr) key.put("ME", loginId);
		out.put("cards", mapper.selectCards(key));
		out.put("codes", mapper.selectCodes());
		out.put("manager", mgr);
		if (mgr) out.put("staffs", mapper.selectStaffs());
		return out;
	}

	public Object saveCard(Map<String, Object> p, String loginId) {
		if (!manager(loginId)) throw new IllegalArgumentException("카드 등록·수정은 경영지원 담당자만 할 수 있습니다.");
		String nm = str(p.get("CARD_NM")).trim(), last4 = str(p.get("LAST4")).trim();
		if (nm.isEmpty() || nm.length() > 50) throw new IllegalArgumentException("카드명을 50자 안으로 입력해 주세요.");
		if (!last4.matches("\\d{4}")) throw new IllegalArgumentException("카드번호 끝 4자리를 숫자로 입력해 주세요.");
		if (str(p.get("CARD_CO")).length() > 30) throw new IllegalArgumentException("카드사는 30자 안으로 입력해 주세요.");
		if (!"Y".equals(p.get("USE_YN")) && !"N".equals(p.get("USE_YN"))) throw new IllegalArgumentException("사용 여부를 선택해 주세요.");
		Map<String, Object> staff = str(p.get("STAFF_SQ")).isEmpty() ? null : mapper.selectStaff(p);
		if (staff == null) throw new IllegalArgumentException("사용자를 직원 명단에서 골라 주세요.");
		p.put("CARD_NM", nm);
		p.put("LAST4", last4);
		p.put("HOLDER_NM", staff.get("STAFF_NM"));
		p.put("UPDT_EMPLY_ID", loginId);
		Object sq;
		if (!str(p.get("CARD_SQ")).isEmpty()) {
			card(p.get("CARD_SQ"), loginId);
			mapper.updateCard(p);
			sq = p.get("CARD_SQ");
		} else {
			mapper.insertCard(p);
			sq = p.get("NEW_CARD_SQ");
		}
		// 사용자 계정이 있으면 법인카드 메뉴(본인 카드만)를 열어 준다
		if (!str(staff.get("EMPLY_ID")).isEmpty()) {
			Map<String, Object> g = one("EMPLY_ID", staff.get("EMPLY_ID"));
			g.put("UPDT_EMPLY_ID", loginId);
			mapper.grantCardRole(g);
		}
		return sq;
	}

	private Map<String, Object> card(Object cardSq, String loginId) {
		if (str(cardSq).isEmpty()) throw new IllegalArgumentException("카드를 선택해 주세요.");
		Map<String, Object> key = one("CARD_SQ", cardSq);
		key.put("YM", YearMonth.now(ZoneId.of("Asia/Seoul")).toString());
		if (!manager(loginId)) key.put("ME", loginId);
		List<Map<String, Object>> list = mapper.selectCards(key);
		if (list.isEmpty()) throw new IllegalArgumentException("카드를 찾지 못했습니다.");
		return list.get(0);
	}

	// ── 사용 내역 ──

	public Map<String, Object> month(Object cardSq, String ym, String loginId) {
		if (ym == null || !ym.matches("\\d{4}-(0[1-9]|1[0-2])")) throw new IllegalArgumentException("월을 확인해 주세요.");
		YearMonth m = YearMonth.parse(ym);
		Map<String, Object> out = new HashMap<>();
		out.put("card", card(cardSq, loginId));
		out.put("uses", mapper.selectUses(range(cardSq, m.atDay(1), m.atEndOfMonth())));
		return out;
	}

	public void saveUse(Map<String, Object> p, String loginId) {
		card(p.get("CARD_SQ"), loginId);
		try {
			p.put("USE_DT", LocalDate.parse(str(p.get("USE_DT"))).toString());
		} catch (DateTimeParseException e) {
			throw new IllegalArgumentException("사용일을 확인해 주세요.");
		}
		long amt;
		try {
			amt = Long.parseLong(str(p.get("AMT")).replaceAll("[,\\s]", ""));
		} catch (NumberFormatException e) {
			throw new IllegalArgumentException("금액을 숫자로 입력해 주세요.");
		}
		if (amt == 0 || Math.abs(amt) > 1_000_000_000L) throw new IllegalArgumentException("금액을 확인해 주세요. 취소는 음수로 넣습니다.");
		p.put("AMT", amt);
		checkFields(p, codeSet());
		p.put("UPDT_EMPLY_ID", loginId);
		if (str(p.get("USE_SQ")).isEmpty()) mapper.insertUse(p);
		else if (mapper.updateUse(p) != 1) throw new IllegalArgumentException("마감됐거나 없는 사용 내역입니다. 화면을 다시 열어 주세요.");
	}

	public void deleteUse(Object cardSq, Object useSq, String loginId) {
		card(cardSq, loginId);
		Map<String, Object> p = one("CARD_SQ", cardSq);
		p.put("USE_SQ", useSq);
		if (mapper.deleteUse(p) != 1) throw new IllegalArgumentException("마감됐거나 없는 사용 내역입니다. 화면을 다시 열어 주세요.");
	}

	/** 사용처 코드·내용·가맹점·대상. 사용 등록 창과 정산 화면이 같이 쓴다 */
	private static void checkFields(Map<String, Object> p, Set<String> codes) {
		if (!codes.contains(str(p.get("USE_CD")))) throw new IllegalArgumentException("사용처 코드를 선택해 주세요.");
		if (str(p.get("DETAIL")).length() > 500) throw new IllegalArgumentException("내용은 500자 안으로 입력해 주세요.");
		if (str(p.get("MERCHANT")).length() > 200) throw new IllegalArgumentException("사용처는 200자 안으로 입력해 주세요.");
		if (str(p.get("TARGET_NM")).length() > 100) throw new IllegalArgumentException("대상은 100자 안으로 입력해 주세요.");
	}

	private Set<String> codeSet() {
		Set<String> s = new HashSet<>();
		for (Map<String, Object> c : mapper.selectCodes()) s.add(str(c.get("CD")));
		return s;
	}

	// ── 정산: 기간 목록 ──

	/**
	 * 기간 안의 등록 건을 상태와 함께 준다. 엑셀을 올리면 날짜·금액으로 대조하고(파일은 저장하지 않는다),
	 * 안 올리면 예전에 대조해 사용처가 붙은 건을 일치로, 나머지는 대조 전(NONE)으로 둔다.
	 */
	public Map<String, Object> period(Object cardSq, String from, String to, byte[] file, String loginId) {
		LocalDate[] r = dates(from, to);
		card(cardSq, loginId);
		List<Map<String, Object>> uses = mapper.selectUses(range(cardSq, r[0], r[1])), rows;
		Map<String, Object> out = new HashMap<>();
		if (file != null && file.length > 0) {
			if (file.length > 10L * 1024 * 1024) throw new IllegalArgumentException("10MB 이하 파일만 올릴 수 있습니다.");
			List<Map<String, Object>> excel = new ArrayList<>();
			int other = 0;
			for (Map<String, Object> e : CardStatementParser.parse(file)) {
				LocalDate d = LocalDate.parse(str(e.get("USE_DT")));
				if (d.isBefore(r[0]) || d.isAfter(r[1])) other++;
				else excel.add(e);
			}
			rows = CardStatementParser.match(excel, uses);
			Set<String> codes = codeSet();
			for (Map<String, Object> x : rows) {
				// 공통코드관리에서 지운 코드로 추정됐으면 기타
				if (x.containsKey("GUESS_CD") && !codes.contains(x.get("GUESS_CD"))) x.put("GUESS_CD", codes.contains("ETC") ? "ETC" : "");
			}
			out.put("excelCnt", excel.size());
			out.put("otherCnt", other);
		} else {
			rows = new ArrayList<>();
			for (Map<String, Object> u : uses) {
				Map<String, Object> x = new HashMap<>();
				x.put("TYPE", str(u.get("MERCHANT")).isEmpty() ? "NONE" : "MATCH");
				x.put("USE_DT", u.get("USE_DT"));
				x.put("AMT", u.get("AMT"));
				x.put("MERCHANT", u.get("MERCHANT"));
				x.put("USE", u);
				rows.add(x);
			}
		}
		out.put("rows", rows);
		return out;
	}

	/**
	 * 정산 화면의 중간 저장과 마감. 등록 건은 코드·내용·사용처·대상을 고치고, 엑셀에만 있던 건은 새로 등록한다.
	 * close 면 저장 뒤 기간 안의 모든 건을 마감한다.
	 */
	public Map<String, Object> savePeriod(Object cardSq, String from, String to, boolean close, Map<String, String[]> a, String loginId) {
		LocalDate[] r = dates(from, to);
		card(cardSq, loginId);
		String[] sq = arr(a, "USE_SQ"), cd = arr(a, "USE_CD"), dt = arr(a, "DETAIL"), mc = arr(a, "MERCHANT"), tg = arr(a, "TARGET_NM");
		String[] nDt = arr(a, "NEW_DT"), nAmt = arr(a, "NEW_AMT"), nCd = arr(a, "NEW_CD"), nDetail = arr(a, "NEW_DETAIL"), nMc = arr(a, "NEW_MERCHANT"), nTg = arr(a, "NEW_TARGET_NM");
		if (!sameLen(sq, cd, dt, mc, tg) || !sameLen(nDt, nAmt, nCd, nDetail, nMc, nTg)) throw new IllegalArgumentException("목록을 다시 불러와 주세요.");
		Set<String> codes = codeSet();
		Map<String, Object> key = range(cardSq, r[0], r[1]);
		key.put("UPDT_EMPLY_ID", loginId);
		int[] cnt = new int[3];
		tx.execute(s -> {
			for (int i = 0; i < sq.length; i++) {
				Map<String, Object> p = new HashMap<>(key);
				p.put("USE_SQ", sq[i]);
				p.put("USE_CD", cd[i]);
				p.put("DETAIL", dt[i].trim());
				p.put("MERCHANT", mc[i].trim());
				p.put("TARGET_NM", tg[i].trim());
				checkFields(p, codes);
				if (mapper.updateSettleUse(p) != 1) throw new IllegalArgumentException("마감됐거나 기간 밖의 건이 있습니다. 목록을 다시 불러와 주세요.");
				cnt[0]++;
			}
			for (int i = 0; i < nDt.length; i++) {
				Map<String, Object> p = new HashMap<>(key);
				LocalDate d;
				try {
					d = LocalDate.parse(nDt[i]);
					p.put("AMT", Long.parseLong(nAmt[i]));
				} catch (DateTimeParseException | NumberFormatException e) {
					throw new IllegalArgumentException("목록을 다시 불러와 주세요.");
				}
				if (d.isBefore(r[0]) || d.isAfter(r[1])) throw new IllegalArgumentException("기간 밖의 건이 섞였습니다. 다시 대조해 주세요.");
				p.put("USE_DT", d.toString());
				p.put("USE_CD", nCd[i]);
				p.put("DETAIL", nDetail[i].trim());
				p.put("MERCHANT", nMc[i].trim());
				p.put("TARGET_NM", nTg[i].trim());
				checkFields(p, codes);
				mapper.insertUse(p);
				cnt[1]++;
			}
			if (close) cnt[2] = mapper.closeUses(key);
			return null;
		});
		Map<String, Object> out = new HashMap<>();
		out.put("updated", cnt[0]);
		out.put("added", cnt[1]);
		out.put("closed", cnt[2]);
		return out;
	}

	// ── 마감 ──

	public Map<String, Object> closed(Object cardSq, String from, String to, String loginId) {
		LocalDate[] r = dates(from, to);
		Map<String, Object> out = new HashMap<>(), key = range(cardSq, r[0], r[1]);
		out.put("card", card(cardSq, loginId));
		key.put("CLOSED", "Y");
		out.put("uses", mapper.selectUses(key));
		return out;
	}

	public int reopen(Object cardSq, String from, String to, String loginId) {
		if (!manager(loginId)) throw new IllegalArgumentException("마감 풀기는 경영지원 담당자만 할 수 있습니다.");
		LocalDate[] r = dates(from, to);
		card(cardSq, loginId);
		return mapper.reopenUses(range(cardSq, r[0], r[1]));
	}

	/** 마감 건을 경영지원 양식(담당·카드·월·일·사용처·금액·내용·대상, 연도별 시트)으로 */
	@SuppressWarnings("unchecked")
	public byte[] closedExcel(Object cardSq, String from, String to, String loginId) {
		Map<String, Object> c = closed(cardSq, from, to, loginId);
		List<Map<String, Object>> uses = (List<Map<String, Object>>) c.get("uses");
		Map<String, String> codeNm = new HashMap<>();
		for (Map<String, Object> x : mapper.selectCodes()) codeNm.put(str(x.get("CD")), str(x.get("NM")));
		return CardLedgerExcel.build((Map<String, Object>) c.get("card"), uses, codeNm);
	}

	// ── 공통 ──

	/** 기간은 하루~1년(366일) */
	private static LocalDate[] dates(String from, String to) {
		LocalDate f, t;
		try {
			f = LocalDate.parse(str(from));
			t = LocalDate.parse(str(to));
		} catch (DateTimeParseException e) {
			throw new IllegalArgumentException("기간을 확인해 주세요.");
		}
		if (t.isBefore(f)) throw new IllegalArgumentException("기간의 끝이 시작보다 빠릅니다.");
		if (ChronoUnit.DAYS.between(f, t) > 366) throw new IllegalArgumentException("기간은 1년 안으로 잡아 주세요.");
		return new LocalDate[] { f, t };
	}

	private static Map<String, Object> range(Object cardSq, LocalDate from, LocalDate to) {
		Map<String, Object> m = one("CARD_SQ", cardSq);
		m.put("FROM", from.toString());
		m.put("TO", to.toString());
		return m;
	}

	private static String[] arr(Map<String, String[]> a, String k) {
		String[] v = a.get(k);
		return v == null ? new String[0] : v;
	}

	private static boolean sameLen(String[]... a) {
		for (String[] x : a) if (x.length != a[0].length) return false;
		return true;
	}

	private static Map<String, Object> one(String k, Object v) {
		Map<String, Object> m = new HashMap<>();
		m.put(k, v);
		return m;
	}

	private static String str(Object o) {
		return o == null ? "" : o.toString();
	}
}
