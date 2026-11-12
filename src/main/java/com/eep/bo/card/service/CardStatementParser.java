package com.eep.bo.card.service;

import java.io.ByteArrayInputStream;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;

/**
 * 카드사 이용내역 엑셀을 읽어 (이용일, 가맹점, 금액) 으로 만들고, 등록한 사용 내역과 날짜·금액으로 짝짓는다. DB 를 쓰지 않는다.
 * 카드사마다 칸 이름이 달라 머리글 이름으로 칸을 찾는다.
 */
public final class CardStatementParser {

	static final String[] DATE_KEYS = { "이용일자", "이용일", "거래일자", "거래일", "승인일자", "승인일", "매출일자", "매출일", "사용일자", "사용일", "일자", "날짜" };
	static final String[] AMT_KEYS = { "이용금액", "승인금액", "거래금액", "매출금액", "결제금액", "사용금액", "금액" };
	static final String[] SHOP_KEYS = { "가맹점명", "이용가맹점", "가맹점", "이용처", "사용처", "상호" };
	private static final Pattern YMD = Pattern.compile("(\\d{4})\\s*[.\\-/년]\\s*(\\d{1,2})\\s*[.\\-/월]\\s*(\\d{1,2})");
	private static final Pattern YMD8 = Pattern.compile("^(\\d{4})(\\d{2})(\\d{2})");
	private static final Pattern YMD_SHORT = Pattern.compile("^(\\d{2})[.\\-/](\\d{1,2})[.\\-/](\\d{1,2})");
	private static final DataFormatter FORMAT = new DataFormatter();

	private CardStatementParser() {
	}

	/** @return [{USE_DT(yyyy-MM-dd), MERCHANT, AMT(long)}] 엑셀 순서대로 */
	public static List<Map<String, Object>> parse(byte[] file) {
		try (Workbook wb = WorkbookFactory.create(new ByteArrayInputStream(file))) {
			for (int si = 0; si < wb.getNumberOfSheets(); si++) {
				Sheet s = wb.getSheetAt(si);
				for (int r = s.getFirstRowNum(); r <= Math.min(s.getFirstRowNum() + 30, s.getLastRowNum()); r++) {
					Row head = s.getRow(r);
					if (head == null) continue;
					List<String> names = new ArrayList<>();
					for (int c = 0; c < Math.max(0, head.getLastCellNum()); c++) names.add(squash(text(head.getCell(c))));
					int dateCol = column(names, DATE_KEYS), amtCol = column(names, AMT_KEYS);
					if (dateCol < 0 || amtCol < 0) continue;
					return rows(s, r, dateCol, amtCol, column(names, SHOP_KEYS));
				}
			}
		} catch (IllegalArgumentException e) {
			throw e;
		} catch (Exception e) {
			throw new IllegalArgumentException("엑셀 파일을 읽지 못했습니다. (" + e.getClass().getSimpleName() + ")");
		}
		throw new IllegalArgumentException("이용일과 금액 칸을 찾지 못했습니다. 카드사 이용내역 엑셀인지 확인해 주세요.");
	}

	private static List<Map<String, Object>> rows(Sheet s, int head, int dateCol, int amtCol, int shopCol) {
		List<Map<String, Object>> out = new ArrayList<>();
		for (int r = head + 1; r <= s.getLastRowNum(); r++) {
			Row row = s.getRow(r);
			if (row == null) continue;
			String date = date(row.getCell(dateCol));
			Long amt = amount(row.getCell(amtCol));
			// 합계·빈 줄처럼 날짜나 금액이 없는 줄은 건너뛴다
			if (date == null || amt == null || amt == 0) continue;
			Map<String, Object> m = new LinkedHashMap<>();
			m.put("USE_DT", date);
			m.put("MERCHANT", shopCol < 0 ? "" : text(row.getCell(shopCol)).trim());
			m.put("AMT", amt);
			out.add(m);
		}
		if (out.isEmpty()) throw new IllegalArgumentException("엑셀에서 이용 건을 찾지 못했습니다.");
		return out;
	}

	/** 우선순위가 앞인 이름부터, 그 이름이 든 첫 칸 */
	static int column(List<String> names, String[] keys) {
		for (String k : keys) {
			for (int i = 0; i < names.size(); i++) if (names.get(i).contains(k)) return i;
		}
		return -1;
	}

	static String date(Cell c) {
		if (c == null) return null;
		if (c.getCellTypeEnum() == CellType.NUMERIC && DateUtil.isCellDateFormatted(c)) {
			return c.getDateCellValue().toInstant().atZone(ZoneId.of("Asia/Seoul")).toLocalDate().toString();
		}
		return date(text(c));
	}

	static String date(String v) {
		String s = v == null ? "" : v.trim();
		Matcher m = YMD.matcher(s);
		if (!m.find()) m = YMD8.matcher(s);
		if (!m.reset().find()) {
			m = YMD_SHORT.matcher(s);
			if (!m.find()) return null;
			return ymd(2000 + Integer.parseInt(m.group(1)), m.group(2), m.group(3));
		}
		return ymd(Integer.parseInt(m.group(1)), m.group(2), m.group(3));
	}

	private static String ymd(int y, String mo, String d) {
		try {
			return LocalDate.of(y, Integer.parseInt(mo), Integer.parseInt(d)).toString();
		} catch (RuntimeException e) {
			return null;
		}
	}

	static Long amount(Cell c) {
		if (c == null) return null;
		if (c.getCellTypeEnum() == CellType.NUMERIC) return Math.round(c.getNumericCellValue());
		return amount(text(c));
	}

	static Long amount(String v) {
		String s = v == null ? "" : v.replaceAll("[,\\s원]", "");
		if (!s.matches("-?\\d+(\\.\\d+)?")) return null;
		return Math.round(Double.parseDouble(s));
	}

	private static String text(Cell c) {
		return c == null ? "" : FORMAT.formatCellValue(c);
	}

	private static String squash(String s) {
		return s.replaceAll("\\s", "");
	}

	/**
	 * 같은 날짜·금액끼리 짝짓는다. 한 건씩이면 일치, 여러 건이면 사람이 고르게 확인 필요, 남으면 한쪽에만 있음.
	 * @param uses 등록한 사용 내역 [{USE_SQ, USE_DT, AMT, ...}]
	 * @return [{TYPE: MATCH|AMBIG|EXCEL_ONLY|REG_ONLY, USE_DT, AMT, MERCHANT, USE, CANDIDATES}]
	 */
	public static List<Map<String, Object>> match(List<Map<String, Object>> excel, List<Map<String, Object>> uses) {
		Map<String, List<Map<String, Object>>> byKey = new LinkedHashMap<>(), excelByKey = new LinkedHashMap<>();
		for (Map<String, Object> u : uses) byKey.computeIfAbsent(key(u), k -> new ArrayList<>()).add(u);
		for (Map<String, Object> e : excel) excelByKey.computeIfAbsent(key(e), k -> new ArrayList<>()).add(e);
		List<Map<String, Object>> out = new ArrayList<>();
		for (Map.Entry<String, List<Map<String, Object>>> en : excelByKey.entrySet()) {
			List<Map<String, Object>> regs = byKey.getOrDefault(en.getKey(), new ArrayList<>());
			List<Map<String, Object>> rows = en.getValue();
			for (int i = 0; i < rows.size(); i++) {
				Map<String, Object> r = new HashMap<>(rows.get(i));
				if (i >= regs.size()) r.put("TYPE", "EXCEL_ONLY");
				else if (rows.size() == 1 && regs.size() == 1) { r.put("TYPE", "MATCH"); r.put("USE", regs.get(0)); }
				else { r.put("TYPE", "AMBIG"); r.put("CANDIDATES", regs); }
				out.add(r);
			}
			for (int i = rows.size(); i < regs.size(); i++) out.add(regOnly(regs.get(i)));
		}
		for (Map.Entry<String, List<Map<String, Object>>> en : byKey.entrySet()) {
			if (!excelByKey.containsKey(en.getKey())) for (Map<String, Object> u : en.getValue()) out.add(regOnly(u));
		}
		out.sort((a, b) -> String.valueOf(a.get("USE_DT")).compareTo(String.valueOf(b.get("USE_DT"))));
		return out;
	}

	private static Map<String, Object> regOnly(Map<String, Object> u) {
		Map<String, Object> r = new HashMap<>();
		r.put("TYPE", "REG_ONLY");
		r.put("USE_DT", u.get("USE_DT"));
		r.put("AMT", u.get("AMT"));
		r.put("MERCHANT", "");
		r.put("USE", u);
		return r;
	}

	private static String key(Map<String, Object> m) {
		return m.get("USE_DT") + "|" + Long.parseLong(String.valueOf(m.get("AMT")));
	}
}
