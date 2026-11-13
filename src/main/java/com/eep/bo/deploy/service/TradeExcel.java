package com.eep.bo.deploy.service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 * 매출·매입 한 달을 '이에스티_계산서' 엑셀과 같은 칸 배치로 만든다.
 * 건 한 줄 = 거래처·프로젝트명·성명·시작일·종료일·월 단가·실 금액 + 품목·기간, 세금계산서 묶음의 첫 줄에 공급가액·세액·합계금액. 묶음 사이는 한 줄 띈다
 */
public final class TradeExcel {

	private TradeExcel() {
	}

	public static byte[] build(String kind, String ym, List<Map<String, Object>> lines) throws IOException {
		boolean sale = "SALE".equals(kind);
		List<Map<String, Object>> rows = new ArrayList<>(lines);
		rows.sort((a, b) -> {
			int c = str(a.get("PARTNER_NM")).compareTo(str(b.get("PARTNER_NM")));
			if (c == 0) c = Integer.compare(inv(a), inv(b));
			if (c == 0) c = Integer.compare(num(a.get("SORT_NO")), num(b.get("SORT_NO")));
			return c != 0 ? c : str(a.get("ITEM_NM")).compareTo(str(b.get("ITEM_NM")));
		});
		try (XSSFWorkbook wb = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
			Sheet sh = wb.createSheet(ym.substring(2, 4) + "년 " + Integer.parseInt(ym.substring(5)) + "월");
			CellStyle money = wb.createCellStyle();
			money.setDataFormat(wb.createDataFormat().getFormat("#,##0"));
			CellStyle head = wb.createCellStyle();
			Font bold = wb.createFont();
			bold.setBold(true);
			head.setFont(bold);
			String[] titles = { sale ? "매출처" : "매입처", "프로젝트명", "성명", "시작일", "종료일", sale ? "월매출" : "월단가", sale ? "실매출" : "실매입", "", "품목", "기간", "", "세금계산서", "공급가액", "세액", "합계금액" };
			Row h = sh.createRow(0);
			for (int i = 0; i < titles.length; i++) text(h, i, titles[i]).setCellStyle(head);
			int r = 1;
			for (int i = 0; i < rows.size(); i++) {
				Map<String, Object> l = rows.get(i), prev = i == 0 ? null : rows.get(i - 1);
				boolean first = prev == null || !sameGroup(prev, l);
				if (first && prev != null) r++; // 묶음 사이 빈 줄
				Row x = sh.createRow(r++);
				String from = md(l.get("START_DT")), to = md(l.get("END_DT"));
				text(x, 0, str(l.get("PARTNER_NM")));
				text(x, 1, "D".equals(l.get("SRC_CD")) ? str(l.get("PRJ_NM")) : str(l.get("ITEM_NM")));
				text(x, 2, str(l.get("STAFF_NM")));
				text(x, 3, from);
				text(x, 4, to);
				if (l.get("MONTHLY") != null) money(x, 5, lng(l.get("MONTHLY")), money);
				money(x, 6, lng(l.get("AMT")), money);
				text(x, 8, str(l.get("ITEM_NM")));
				text(x, 9, from.isEmpty() && to.isEmpty() ? "" : from + "-" + to);
				if (first) {
					long sum = 0;
					for (int k = i; k < rows.size() && sameGroup(l, rows.get(k)); k++) sum += lng(rows.get(k).get("AMT"));
					long vat = sum < 0 ? -(-sum / 10) : sum / 10;
					text(x, 11, l.get("INV_NO") == null ? "묶기 전" : "계산서 " + l.get("INV_NO") + (l.get("ISSUE_DT") == null ? "" : " (발급 " + l.get("ISSUE_DT") + ")"));
					money(x, 12, sum, money);
					money(x, 13, vat, money);
					money(x, 14, sum + vat, money);
				}
			}
			int[] widths = { 14, 40, 10, 8, 8, 13, 13, 2, 46, 13, 2, 26, 14, 13, 14 };
			for (int i = 0; i < widths.length; i++) sh.setColumnWidth(i, widths[i] * 256);
			sh.createFreezePane(0, 1);
			wb.write(out);
			return out.toByteArray();
		}
	}

	/** 같은 거래처의 같은 계산서. 아직 묶지 않은 건은 거래처마다 한 덩어리 */
	static boolean sameGroup(Map<String, Object> a, Map<String, Object> b) {
		return str(a.get("PARTNER_NM")).equals(str(b.get("PARTNER_NM"))) && Objects.equals(a.get("PARTNER_SQ"), b.get("PARTNER_SQ")) && inv(a) == inv(b);
	}

	private static int inv(Map<String, Object> l) {
		return l.get("INV_NO") == null ? Integer.MAX_VALUE : num(l.get("INV_NO"));
	}

	/** 2026-10-01 -> 10/1 */
	static String md(Object d) {
		String s = str(d);
		return s.length() < 10 ? "" : Integer.parseInt(s.substring(5, 7)) + "/" + Integer.parseInt(s.substring(8, 10));
	}

	private static Cell text(Row r, int c, String v) {
		Cell cell = r.createCell(c);
		cell.setCellValue(v);
		return cell;
	}

	private static void money(Row r, int c, long v, CellStyle style) {
		Cell cell = r.createCell(c);
		cell.setCellValue(v);
		cell.setCellStyle(style);
	}

	private static int num(Object o) {
		return o == null ? 0 : ((Number) o).intValue();
	}

	private static long lng(Object o) {
		return o == null ? 0 : ((Number) o).longValue();
	}

	private static String str(Object o) {
		return o == null ? "" : o.toString();
	}
}
