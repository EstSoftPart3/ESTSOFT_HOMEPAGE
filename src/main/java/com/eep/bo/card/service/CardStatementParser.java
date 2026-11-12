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
	 * 같은 날짜·금액끼리 짝짓는다. 같은 날 같은 금액이 여러 건이면 순서대로 짝짓고, 남은 엑셀 건은 가맹점으로 사용처 코드를 추정해 둔다(확정 때 자동 등록).
	 * @param uses 등록한 사용 내역 [{USE_SQ, USE_DT, AMT, ...}]
	 * @return [{TYPE: MATCH|EXCEL_ONLY|REG_ONLY, USE_DT, AMT, MERCHANT, USE, GUESS_CD}]
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
				if (i >= regs.size()) { r.put("TYPE", "EXCEL_ONLY"); r.put("GUESS_CD", guess(String.valueOf(r.get("MERCHANT")))); }
				else { r.put("TYPE", "MATCH"); r.put("USE", regs.get(i)); }
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

	// 앞에서부터 먼저 걸리는 코드를 쓴다. 주차를 교통보다, KTX 를 KT(통신)보다 먼저 본다
	private static final String[][] GUESS = {
		{ "PARK", "주차", "파킹", "parking", "하이패스", "도로공사", "통행료" },
		{ "TRANS", "주유", "에너지", "오일", "칼텍스", "s-oil", "택시", "카카오t", "코레일", "ktx", "srt", "티머니", "버스", "렌터카", "쏘카" },
		{ "TRIP", "호텔", "모텔", "숙박", "리조트", "야놀자", "여기어때", "항공", "에어", "airbnb", "agoda", "아고다" },
		{ "POST", "우체국", "택배", "대한통운", "한진", "로젠", "퀵" },
		{ "COMM", "kt", "skt", "sk텔레콤", "유플러스", "lgu+", "통신" },
		{ "SW", "aws", "amazonweb", "google", "구글", "microsoft", "마이크로소프트", "adobe", "github", "notion", "slack", "openai", "anthropic", "claude", "zoom", "figma", "jetbrains", "apple.com", "atlassian" },
		{ "EDU", "서점", "문고", "교보", "영풍", "yes24", "예스24", "알라딘", "인프런", "유데미", "udemy", "패스트캠퍼스", "교육" },
		{ "EVENT", "꽃", "플라워", "화환", "장례" },
		{ "DINNER", "주점", "호프", "포차", "이자카야", "맥주", "술집" },
		{ "SUPPLY", "다이소", "오피스", "문구", "알파", "쿠팡", "11번가", "g마켓", "지마켓", "옥션", "이마트", "홈플러스", "롯데마트", "하이마트", "전자랜드" },
		{ "MEAL", "식당", "김밥", "국수", "분식", "한식", "중식", "일식", "반점", "치킨", "피자", "버거", "맥도날드", "롯데리아", "도시락", "배달", "요기요", "쿠팡이츠",
			"카페", "커피", "스타벅스", "투썸", "이디야", "메가", "빽다방", "베이커리", "파리바게뜨", "뚜레쥬르", "고기", "갈비", "국밥", "찌개", "냉면", "초밥", "돈까스", "샐러드" },
	};

	/** 가맹점 이름으로 사용처 코드를 추정한다. 못 찾으면 ETC */
	static String guess(String merchant) {
		String m = squash(merchant == null ? "" : merchant).toLowerCase();
		for (String[] g : GUESS) for (int i = 1; i < g.length; i++) if (m.contains(g[i])) return g[0];
		return "ETC";
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
