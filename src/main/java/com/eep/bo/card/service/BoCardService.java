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

	public Map<String, Object> cards() {
		Map<String, Object> out = new HashMap<>();
		out.put("cards", mapper.selectCards(one("YM", YearMonth.now(ZoneId.of("Asia/Seoul")).toString())));
		out.put("codes", mapper.selectCodes());
		return out;
	}

	public Object saveCard(Map<String, Object> p, String loginId) {
		String nm = str(p.get("CARD_NM")).trim(), last4 = str(p.get("LAST4")).trim();
		if (nm.isEmpty() || nm.length() > 50) throw new IllegalArgumentException("카드명을 50자 안으로 입력해 주세요.");
		if (!last4.matches("\\d{4}")) throw new IllegalArgumentException("카드번호 끝 4자리를 숫자로 입력해 주세요.");
		if (str(p.get("CARD_CO")).length() > 30 || str(p.get("HOLDER_NM")).length() > 30) throw new IllegalArgumentException("카드사와 사용자는 30자 안으로 입력해 주세요.");
		if (!"Y".equals(p.get("USE_YN")) && !"N".equals(p.get("USE_YN"))) throw new IllegalArgumentException("사용 여부를 선택해 주세요.");
		p.put("CARD_NM", nm);
		p.put("LAST4", last4);
		p.put("UPDT_EMPLY_ID", loginId);
		if (!str(p.get("CARD_SQ")).isEmpty()) {
			card(p.get("CARD_SQ"));
			mapper.updateCard(p);
			return p.get("CARD_SQ");
		}
		mapper.insertCard(p);
		return p.get("NEW_CARD_SQ");
	}

	private Map<String, Object> card(Object cardSq) {
		if (str(cardSq).isEmpty()) throw new IllegalArgumentException("카드를 선택해 주세요.");
		Map<String, Object> key = one("CARD_SQ", cardSq);
		key.put("YM", YearMonth.now(ZoneId.of("Asia/Seoul")).toString());
		List<Map<String, Object>> list = mapper.selectCards(key);
		if (list.isEmpty()) throw new IllegalArgumentException("카드를 찾지 못했습니다.");
		return list.get(0);
	}

	// ── 사용 내역 ──

	public Map<String, Object> month(Object cardSq, String ym) {
		Map<String, Object> key = monthKey(cardSq, ym), out = new HashMap<>();
		out.put("card", card(cardSq));
		out.put("uses", mapper.selectMonthUses(key));
		out.put("settle", mapper.selectSettle(key));
		return out;
	}

	public void saveUse(Map<String, Object> p, String loginId) {
		card(p.get("CARD_SQ"));
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

	public void deleteUse(Object cardSq, Object useSq) {
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
	public Map<String, Object> compare(Object cardSq, String ym, byte[] file) {
		Map<String, Object> key = monthKey(cardSq, ym);
		card(cardSq);
		if (file == null || file.length == 0) throw new IllegalArgumentException("엑셀 파일을 골라 주세요.");
		if (file.length > 10L * 1024 * 1024) throw new IllegalArgumentException("10MB 이하 파일만 올릴 수 있습니다.");
		List<Map<String, Object>> excel = new ArrayList<>(), other = new ArrayList<>();
		for (Map<String, Object> r : CardStatementParser.parse(file)) (str(r.get("USE_DT")).startsWith(ym) ? excel : other).add(r);
		Map<String, Object> out = new HashMap<>();
		out.put("rows", CardStatementParser.match(excel, mapper.selectMonthUses(key)));
		out.put("excelCnt", excel.size());
		out.put("otherMonthCnt", other.size());
		return out;
	}

	/** 화면에서 확정한 짝(사용 내역 ↔ 엑셀 가맹점)을 저장하고 그 달을 정산 완료로 남긴다 */
	public void confirm(Object cardSq, String ym, String fileNm, int excelCnt, String[] useSqs, String[] merchants, String loginId) {
		Map<String, Object> key = monthKey(cardSq, ym);
		card(cardSq);
		int n = useSqs == null ? 0 : useSqs.length;
		if (n != (merchants == null ? 0 : merchants.length)) throw new IllegalArgumentException("정산 결과를 다시 불러와 주세요.");
		tx.execute(s -> {
			for (int i = 0; i < n; i++) {
				Map<String, Object> p = new HashMap<>(key);
				p.put("USE_SQ", useSqs[i]);
				p.put("MERCHANT", merchants[i].length() > 200 ? merchants[i].substring(0, 200) : merchants[i]);
				if (mapper.updateMerchant(p) != 1) throw new IllegalArgumentException("이 달 사용 내역이 아닌 건이 있습니다. 다시 대조해 주세요.");
			}
			Map<String, Object> p = new HashMap<>(key);
			p.put("FILE_NM", fileNm == null ? "" : fileNm.length() > 200 ? fileNm.substring(0, 200) : fileNm);
			p.put("EXCEL_CNT", excelCnt);
			p.put("MATCH_CNT", n);
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

	private static String str(Object o) {
		return o == null ? "" : o.toString();
	}
}
