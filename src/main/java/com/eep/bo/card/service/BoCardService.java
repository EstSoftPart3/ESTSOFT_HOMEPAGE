package com.eep.bo.card.service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;
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

/** 경영지원 - 법인카드: 카드 등록, 날짜별 사용 등록, 카드사 엑셀과 대조하는 월 정산 */
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
		Map<String, Object> key = monthKey(cardSq, ym), out = new HashMap<>();
		out.put("card", card(cardSq, loginId));
		out.put("uses", mapper.selectMonthUses(key));
		out.put("settle", mapper.selectSettle(key));
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
		if (!codeSet().contains(str(p.get("USE_CD")))) throw new IllegalArgumentException("사용처 코드를 선택해 주세요.");
		if (str(p.get("DETAIL")).length() > 500) throw new IllegalArgumentException("사용 상세 내용은 500자 안으로 입력해 주세요.");
		p.put("UPDT_EMPLY_ID", loginId);
		if (str(p.get("USE_SQ")).isEmpty()) mapper.insertUse(p);
		else if (mapper.updateUse(p) != 1) throw new IllegalArgumentException("사용 내역을 찾지 못했습니다. 화면을 다시 열어 주세요.");
	}

	public void deleteUse(Object cardSq, Object useSq, String loginId) {
		card(cardSq, loginId);
		Map<String, Object> p = one("CARD_SQ", cardSq);
		p.put("USE_SQ", useSq);
		if (mapper.deleteUse(p) != 1) throw new IllegalArgumentException("사용 내역을 찾지 못했습니다. 화면을 다시 열어 주세요.");
	}

	private Set<String> codeSet() {
		Set<String> s = new HashSet<>();
		for (Map<String, Object> c : mapper.selectCodes()) s.add(str(c.get("CD")));
		return s;
	}

	// ── 정산 ──

	/** 올린 엑셀을 그 달 등록 내역과 대조한다. 파일은 저장하지 않는다 */
	public Map<String, Object> compare(Object cardSq, String ym, byte[] file, String loginId) {
		Map<String, Object> key = monthKey(cardSq, ym);
		card(cardSq, loginId);
		if (file == null || file.length == 0) throw new IllegalArgumentException("엑셀 파일을 골라 주세요.");
		if (file.length > 10L * 1024 * 1024) throw new IllegalArgumentException("10MB 이하 파일만 올릴 수 있습니다.");
		List<Map<String, Object>> excel = new ArrayList<>(), other = new ArrayList<>();
		for (Map<String, Object> r : CardStatementParser.parse(file)) (str(r.get("USE_DT")).startsWith(ym) ? excel : other).add(r);
		Map<String, Object> out = new HashMap<>();
		Set<String> codes = codeSet();
		List<Map<String, Object>> rows = CardStatementParser.match(excel, mapper.selectMonthUses(key));
		for (Map<String, Object> r : rows) {
			// 공통코드관리에서 지운 코드로 추정됐으면 기타, 기타도 없으면 첫 코드
			if (r.containsKey("GUESS_CD") && !codes.contains(r.get("GUESS_CD"))) r.put("GUESS_CD", codes.contains("ETC") ? "ETC" : codes.isEmpty() ? "" : mapper.selectCodes().get(0).get("CD"));
		}
		out.put("rows", rows);
		out.put("excelCnt", excel.size());
		out.put("otherMonthCnt", other.size());
		return out;
	}

	/** 엑셀 건을 모두 반영한다: 짝지은 건은 가맹점을 붙이고, 등록 안 된 건은 추정 코드로 새로 등록한 뒤 그 달을 정산 완료로 남긴다 */
	public void confirm(Object cardSq, String ym, String fileNm, int excelCnt, String[] useSqs, String[] merchants,
			String[] newDts, String[] newAmts, String[] newCds, String[] newMerchants, String loginId) {
		Map<String, Object> key = monthKey(cardSq, ym);
		card(cardSq, loginId);
		int n = len(useSqs), k = len(newDts);
		if (n != len(merchants) || k != len(newAmts) || k != len(newCds) || k != len(newMerchants)) throw new IllegalArgumentException("정산 결과를 다시 불러와 주세요.");
		Set<String> codes = codeSet();
		tx.execute(s -> {
			for (int i = 0; i < n; i++) {
				Map<String, Object> p = new HashMap<>(key);
				p.put("USE_SQ", useSqs[i]);
				p.put("MERCHANT", cut(merchants[i], 200));
				if (mapper.updateMerchant(p) != 1) throw new IllegalArgumentException("이 달 사용 내역이 아닌 건이 있습니다. 다시 대조해 주세요.");
			}
			for (int i = 0; i < k; i++) {
				Map<String, Object> p = new HashMap<>(key);
				if (!newDts[i].startsWith(ym)) throw new IllegalArgumentException("다른 달 건이 섞였습니다. 다시 대조해 주세요.");
				try {
					p.put("USE_DT", LocalDate.parse(newDts[i]).toString());
					p.put("AMT", Long.parseLong(newAmts[i]));
				} catch (DateTimeParseException | NumberFormatException e) {
					throw new IllegalArgumentException("정산 결과를 다시 불러와 주세요.");
				}
				if (!codes.contains(newCds[i])) throw new IllegalArgumentException("사용처 코드를 확인해 주세요.");
				p.put("USE_CD", newCds[i]);
				p.put("DETAIL", cut(newMerchants[i], 500));
				p.put("MERCHANT", cut(newMerchants[i], 200));
				p.put("UPDT_EMPLY_ID", loginId);
				mapper.insertUse(p);
			}
			Map<String, Object> p = new HashMap<>(key);
			p.put("FILE_NM", cut(fileNm, 200));
			p.put("EXCEL_CNT", excelCnt);
			p.put("MATCH_CNT", n + k);
			p.put("UPDT_EMPLY_ID", loginId);
			mapper.upsertSettle(p);
			return null;
		});
	}

	private static Map<String, Object> monthKey(Object cardSq, String ym) {
		if (ym == null || !ym.matches("\\d{4}-(0[1-9]|1[0-2])")) throw new IllegalArgumentException("월을 확인해 주세요.");
		Map<String, Object> m = one("CARD_SQ", cardSq);
		m.put("YM", ym);
		return m;
	}

	private static Map<String, Object> one(String k, Object v) {
		Map<String, Object> m = new HashMap<>();
		m.put(k, v);
		return m;
	}

	private static int len(String[] a) {
		return a == null ? 0 : a.length;
	}

	private static String cut(String s, int max) {
		return s == null ? "" : s.length() > max ? s.substring(0, max) : s;
	}

	private static String str(Object o) {
		return o == null ? "" : o.toString();
	}
}
