package com.eep.bo.card.service;

import java.io.ByteArrayInputStream;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;

/**
 * 경영지원 「법인카드 사용내역」 엑셀(담당·카드·월·일·사용처·금액·내용·대상, 연도별 시트)을 읽는다. DB 를 쓰지 않는다.
 * 연도는 시트 이름의 4자리 숫자, 칸은 머리글 이름으로 찾는다. 카드·담당 칸은 비면 위 줄 값을 이어 쓴다.
 */
public final class CardUseExcelParser {

	private static final Pattern YEAR = Pattern.compile("(20\\d{2})");
	private static final DataFormatter FORMAT = new DataFormatter();

	private CardUseExcelParser() {
	}

	/** @return [{SHEET, ROW(엑셀 행 번호), CARD_TXT, USE_DT, AMT, MERCHANT, DETAIL, TARGET_NM, GUESS_CD, ERR}] — 날짜·금액을 못 읽은 줄은 ERR 에 이유 */
	public static List<Map<String, Object>> parse(byte[] file) {
		List<Map<String, Object>> out = new ArrayList<>();
		boolean found = false;
		try (Workbook wb = WorkbookFactory.create(new ByteArrayInputStream(file))) {
			for (int si = 0; si < wb.getNumberOfSheets(); si++) {
				Sheet s = wb.getSheetAt(si);
				Matcher y = YEAR.matcher(s.getSheetName());
				if (!y.find()) continue;
				int year = Integer.parseInt(y.group(1));
				for (int r = s.getFirstRowNum(); r <= Math.min(s.getFirstRowNum() + 30, s.getLastRowNum()); r++) {
					Row head = s.getRow(r);
					if (head == null) continue;
					List<String> names = new ArrayList<>();
					for (int c = 0; c < Math.max(0, head.getLastCellNum()); c++) names.add(text(head.getCell(c)).replaceAll("\\s", ""));
					int mo = names.indexOf("월"), dd = names.indexOf("일"), amt = names.indexOf("금액");
					if (mo < 0 || dd < 0 || amt < 0) continue;
					found = true;
					rows(s, r, year, mo, dd, amt, names.indexOf("카드"), names.indexOf("사용처"), names.indexOf("내용"), names.indexOf("대상"), out);
					break;
				}
			}
		} catch (IllegalArgumentException e) {
			throw e;
		} catch (Exception e) {
			throw new IllegalArgumentException("엑셀 파일을 읽지 못했습니다. (" + e.getClass().getSimpleName() + ")");
		}
		if (!found) throw new IllegalArgumentException("「월·일·금액」 머리글이 있는 연도 시트(예: 2026)를 찾지 못했습니다. 법인카드 사용내역 양식인지 확인해 주세요.");
		return out;
	}

	private static void rows(Sheet s, int head, int year, int mo, int dd, int amt, int cardCol, int shopCol, int detailCol, int targetCol, List<Map<String, Object>> out) {
		String card = "";
		for (int r = head + 1; r <= s.getLastRowNum(); r++) {
			Row row = s.getRow(r);
			if (row == null) continue;
			String m = text(cell(row, mo)), d = text(cell(row, dd)), shop = text(cell(row, shopCol)), detail = text(cell(row, detailCol)), target = text(cell(row, targetCol));
			Cell ac = cell(row, amt);
			Long a = ac != null && ac.getCellTypeEnum() == CellType.NUMERIC ? CardStatementParser.amount(ac) : CardStatementParser.amount(text(ac));
			String cardTxt = text(cell(row, cardCol));
			if (!cardTxt.isEmpty()) card = cardTxt;
			// 카드 이름만 적힌 줄(아래 줄들의 카드 표시)과 빈 줄은 건너뛴다
			if (m.isEmpty() && d.isEmpty() && a == null && shop.isEmpty() && detail.isEmpty()) continue;
			Map<String, Object> x = new LinkedHashMap<>();
			x.put("SHEET", s.getSheetName());
			x.put("ROW", r + 1);
			x.put("CARD_TXT", card);
			x.put("MERCHANT", cut(shop, 200));
			x.put("DETAIL", cut(detail, 500));
			x.put("TARGET_NM", cut(target, 100));
			x.put("GUESS_CD", guess(detail, shop));
			String date = null;
			try {
				date = LocalDate.of(year, Integer.parseInt(m.replaceAll("\\D", "")), Integer.parseInt(d.replaceAll("\\D", ""))).toString();
			} catch (RuntimeException e) {
				x.put("ERR", "월·일을 읽지 못함");
			}
			if (date != null && (a == null || a == 0)) x.put("ERR", "금액을 읽지 못함");
			x.put("USE_DT", date == null ? "" : date);
			x.put("AMT", a == null ? 0 : a);
			out.add(x);
		}
	}

	// 내용 글자로 먼저 고른다(회식을 식사보다 먼저). 못 찾으면 사용처로 카드사 대조 때 쓰는 추정을 쓴다
	private static final String[][] DETAIL_GUESS = {
		{ "DINNER", "회식" },
		{ "ENT", "접대" },
		{ "EVENT", "경조", "조의", "축의", "화환", "부의" },
		{ "PARK", "주차", "통행료" },
		{ "TRANS", "택시", "주유", "교통" },
		{ "TRIP", "출장", "숙박" },
		{ "POST", "택배", "퀵", "우편", "등기" },
		{ "SW", "서버", "구독", "라이선스", "라이센스", "도메인", "호스팅" },
		{ "EDU", "도서", "교육", "강의", "교재" },
		{ "COMM", "통신", "휴대폰", "인터넷요금" },
		{ "MEAL", "점심", "저녁", "식사", "식권", "식대", "커피", "간식", "다과" },
		{ "SUPPLY", "비품", "소모품", "사무용품", "구매", "폐기물" },
	};

	static String guess(String detail, String merchant) {
		String t = (detail == null ? "" : detail).replaceAll("\\s", "").toLowerCase();
		for (String[] g : DETAIL_GUESS) for (int i = 1; i < g.length; i++) if (t.contains(g[i])) return g[0];
		return CardStatementParser.guess(merchant);
	}

	private static Cell cell(Row row, int c) {
		return c < 0 ? null : row.getCell(c);
	}

	private static String text(Cell c) {
		if (c == null) return "";
		if (c.getCellTypeEnum() == CellType.FORMULA) {
			try {
				return c.getCachedFormulaResultTypeEnum() == CellType.NUMERIC ? FORMAT.formatRawCellContents(c.getNumericCellValue(), -1, "General").trim() : c.getStringCellValue().trim();
			} catch (RuntimeException e) {
				return "";
			}
		}
		return FORMAT.formatCellValue(c).trim();
	}

	private static String cut(String s, int n) {
		return s.length() > n ? s.substring(0, n) : s;
	}
}
