package com.eep.bo.card.service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.util.List;
import java.util.Map;

import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 * 경영지원이 쓰던 '법인카드사용내역' 양식 그대로 만든다: 시트 이름은 연도, B2 제목, 4행 머리글 B~I
 * (담당 | 카드 | 월 | 일 | 사용처 | 금액 | 내용 | 대상), 5행부터 자료, 카드는 시트 첫 자료 줄에만 쓴다.
 */
public final class CardLedgerExcel {

	private static final String[] HEAD = { "담당", "카드", "월", "일", "사용처", "금액", "내용", "대상" };
	private static final int[] WIDTH = { 853, 1934, 2901, 1194, 881, 9614, 2730, 6769, 11491 }; // A~I, 원본 파일 그대로

	private CardLedgerExcel() {
	}

	/** @param uses 날짜순 [{USE_DT yyyy-MM-dd, AMT, USE_CD, DETAIL, MERCHANT, TARGET_NM}] */
	public static byte[] build(Map<String, Object> card, List<Map<String, Object>> uses, Map<String, String> codeNm) {
		String holder = str(card.get("HOLDER_NM")), cardNm = str(card.get("CARD_CO")).isEmpty() ? str(card.get("CARD_NM")) : str(card.get("CARD_CO"));
		try (XSSFWorkbook wb = new XSSFWorkbook(); ByteArrayOutputStream bo = new ByteArrayOutputStream()) {
			CellStyle center = style(wb, HorizontalAlignment.CENTER, null), left = style(wb, HorizontalAlignment.LEFT, null);
			CellStyle money = style(wb, HorizontalAlignment.GENERAL, wb.createDataFormat().getFormat("_-* #,##0_-;\\-* #,##0_-;_-* \"-\"_-;_-@"));
			Sheet sh = null;
			String year = null;
			int row = 0;
			for (Map<String, Object> u : uses) {
				String d = str(u.get("USE_DT"));
				if (!d.substring(0, 4).equals(year)) {
					year = d.substring(0, 4);
					sh = sheet(wb, year, center, left);
					row = 4;
				}
				Row r = sh.createRow(row);
				r.setHeightInPoints(17.25f);
				text(r, 1, holder, center);
				text(r, 2, row == 4 ? cardNm : "", center);
				num(r, 3, Integer.parseInt(d.substring(5, 7)), center);
				num(r, 4, Integer.parseInt(d.substring(8, 10)), center);
				// 사용처는 카드사 가맹점, 대조 전이면 사용처 코드 이름
				String place = str(u.get("MERCHANT")).isEmpty() ? str(codeNm.get(str(u.get("USE_CD")))) : str(u.get("MERCHANT"));
				text(r, 5, place, left);
				num(r, 6, Long.parseLong(str(u.get("AMT"))), money);
				text(r, 7, str(u.get("DETAIL")), center);
				text(r, 8, str(u.get("TARGET_NM")).isEmpty() ? holder : str(u.get("TARGET_NM")), center);
				row++;
			}
			if (sh == null) sheet(wb, "마감 없음", center, left);
			wb.write(bo);
			return bo.toByteArray();
		} catch (IOException e) {
			throw new UncheckedIOException(e);
		}
	}

	private static Sheet sheet(XSSFWorkbook wb, String name, CellStyle center, CellStyle left) {
		Sheet sh = wb.createSheet(name);
		for (int i = 0; i < WIDTH.length; i++) sh.setColumnWidth(i, WIDTH[i]);
		Row t = sh.createRow(1);
		t.setHeightInPoints(17.25f);
		text(t, 1, "법인카드 사용내역", left);
		Row h = sh.createRow(3);
		h.setHeightInPoints(17.25f);
		for (int i = 0; i < HEAD.length; i++) text(h, i + 1, HEAD[i], center);
		return sh;
	}

	private static CellStyle style(XSSFWorkbook wb, HorizontalAlignment al, Short fmt) {
		CellStyle s = wb.createCellStyle();
		s.setAlignment(al);
		if (fmt != null) s.setDataFormat(fmt);
		return s;
	}

	private static void text(Row r, int c, String v, CellStyle s) {
		r.createCell(c).setCellValue(v);
		r.getCell(c).setCellStyle(s);
	}

	private static void num(Row r, int c, double v, CellStyle s) {
		r.createCell(c).setCellValue(v);
		r.getCell(c).setCellStyle(s);
	}

	private static String str(Object o) {
		return o == null ? "" : o.toString();
	}
}
