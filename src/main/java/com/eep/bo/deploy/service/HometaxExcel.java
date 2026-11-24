package com.eep.bo.deploy.service;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;

/**
 * 홈택스 전자세금계산서 일괄발급 엑셀. 홈택스 양식 파일(첫 시트)에 7행부터 한 장씩 채운다.
 * 칸은 위치가 아니라 머리글 이름으로 찾는다(양식이 바뀌어도 이름이 같으면 그대로 쓴다). 공급자 칸이 없는 대량 양식도 된다
 */
public final class HometaxExcel {

	public static final String DEFAULT_FORM = "/hometax/tax_invoice_form.xls";
	private static final String[] NEED = { "종류", "작성일자", "공급받는자등록번호", "공급받는자상호", "공급받는자성명", "공급가액합계", "세액합계", "일자1", "품목1", "공급가액1", "세액1", "영수청구" };
	private static final Charset KR = Charset.forName("MS949");

	private HometaxExcel() {
	}

	/** 양식 한 장: 머리글 행, 칸 위치, 품목 칸 수, 한 파일 최대 장 수 */
	static final class Form {
		int head, items, max = 100;
		final Map<String, Integer> col = new HashMap<>();

		boolean supplier() {
			return col.containsKey("공급자등록번호");
		}

		String summary() {
			return "칸 " + col.size() + "개 · 품목 " + items + "줄 · 한 파일 최대 " + max + "장 · " + (supplier() ? "공급자 칸 있음" : "공급자 칸 없음(대량 양식)");
		}
	}

	/** 양식 검사. 문제가 있으면 IllegalArgumentException(요약은 form(..).summary()) */
	static Form form(byte[] data) {
		try (Workbook wb = open(data)) {
			return read(wb);
		} catch (IOException e) {
			throw new IllegalArgumentException("엑셀을 읽지 못했습니다. 홈택스에서 받은 양식 파일(xls, xlsx)인지 확인해 주세요.");
		}
	}

	private static Workbook open(byte[] data) throws IOException {
		try (InputStream in = new ByteArrayInputStream(data)) {
			return WorkbookFactory.create(in);
		} catch (IOException e) {
			throw e;
		} catch (Exception e) {
			throw new IOException(e);
		}
	}

	/** 머리글 이름 → 칸. 줄바꿈·공백과 (괄호 안 설명)은 빼고 비교한다. 예: '일자1\n(2자리, 작성년월 내)' → 일자1 */
	static String norm(String s) {
		String n = s.replaceAll("\\([^)]*\\)", "").replaceAll("[\\s,\"']", "");
		if (n.endsWith("종류")) return "종류";
		if (n.startsWith("영수")) return "영수청구";
		return n;
	}

	static Form read(Workbook wb) {
		if (wb.getNumberOfSheets() == 0) throw new IllegalArgumentException("시트가 없는 파일입니다.");
		Sheet sh = wb.getSheetAt(0);
		DataFormatter f = new DataFormatter();
		Form form = new Form();
		Pattern maxP = Pattern.compile("최대\\s*(\\d{2,5})\\s*건");
		form.head = -1;
		for (int r = 0; r <= Math.min(30, sh.getLastRowNum()) && form.head < 0; r++) {
			Row row = sh.getRow(r);
			if (row == null) continue;
			for (Cell c : row) {
				String v = f.formatCellValue(c);
				Matcher m = maxP.matcher(v);
				if (m.find() && form.max == 100) form.max = Integer.parseInt(m.group(1));
				if ("작성일자".equals(norm(v))) form.head = r;
			}
		}
		if (form.head < 0) throw new IllegalArgumentException("'작성일자' 머리글을 찾지 못했습니다. 홈택스 전자세금계산서 일괄발급 양식인지 확인해 주세요.");
		for (Cell c : sh.getRow(form.head)) {
			String k = norm(f.formatCellValue(c));
			if (!k.isEmpty() && !form.col.containsKey(k)) form.col.put(k, c.getColumnIndex());
		}
		StringBuilder miss = new StringBuilder();
		for (String k : NEED) if (!form.col.containsKey(k)) miss.append(miss.length() > 0 ? ", " : "").append(k);
		if (miss.length() > 0) throw new IllegalArgumentException("양식에 필요한 칸이 없습니다: " + miss);
		while (form.col.containsKey("품목" + (form.items + 1)) && form.col.containsKey("공급가액" + (form.items + 1))) form.items++;
		return form;
	}

	/** 계산서 한 장 = 거래처(PARTNER: BIZ_NO, PARTNER_NM, CEO_NM, ADDR, BIZ_TYPE, BIZ_ITEM, TAX_EMAIL) + 품목 줄(ITEM_NM, START_DT, END_DT, AMT) */
	public static final class Invoice {
		final Map<String, Object> partner;
		final List<Map<String, Object>> lines;

		public Invoice(Map<String, Object> partner, List<Map<String, Object>> lines) {
			this.partner = partner;
			this.lines = lines;
		}
	}

	/** sup: BIZ_NO, NM, CEO, ADDR, TYPE, ITEM, EMAIL (공급자 칸이 없는 양식이면 안 쓴다) */
	public static byte[] build(byte[] form, Map<String, String> sup, List<Invoice> invoices, LocalDate writeDt) throws IOException {
		try (Workbook wb = open(form); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
			Form fm = read(wb);
			if (invoices.size() > fm.max) throw new IllegalArgumentException("한 파일에 " + fm.max + "장까지 넣을 수 있습니다. 나눠서 골라 주세요.");
			Sheet sh = wb.getSheetAt(0);
			String ymd = writeDt.format(DateTimeFormatter.BASIC_ISO_DATE), dd = ymd.substring(6);
			int r = fm.head + 1;
			for (Invoice inv : invoices) {
				if (inv.lines.size() > fm.items) throw new IllegalArgumentException(s(inv.partner.get("PARTNER_NM")) + " 계산서 한 장에 품목이 " + fm.items + "줄을 넘습니다. 나눠 주세요.");
				Row row = sh.getRow(r) != null ? sh.getRow(r) : sh.createRow(r);
				r++;
				put(fm, row, "종류", "01");
				put(fm, row, "작성일자", ymd);
				if (fm.supplier()) {
					put(fm, row, "공급자등록번호", digits(sup.get("BIZ_NO")));
					put(fm, row, "공급자상호", cut(sup.get("NM"), 70));
					put(fm, row, "공급자성명", cut(sup.get("CEO"), 30));
					put(fm, row, "공급자사업장주소", cut(sup.get("ADDR"), 150));
					put(fm, row, "공급자업태", cut(sup.get("TYPE"), 40));
					put(fm, row, "공급자종목", cut(sup.get("ITEM"), 60));
					put(fm, row, "공급자이메일", cut(sup.get("EMAIL"), 40));
				}
				Map<String, Object> p = inv.partner;
				put(fm, row, "공급받는자등록번호", digits(s(p.get("BIZ_NO"))));
				put(fm, row, "공급받는자상호", cut(s(p.get("PARTNER_NM")), 70));
				put(fm, row, "공급받는자성명", cut(s(p.get("CEO_NM")), 30));
				put(fm, row, "공급받는자사업장주소", cut(s(p.get("ADDR")), 150));
				put(fm, row, "공급받는자업태", cut(s(p.get("BIZ_TYPE")), 40));
				put(fm, row, "공급받는자종목", cut(s(p.get("BIZ_ITEM")), 60));
				put(fm, row, "공급받는자이메일1", cut(s(p.get("TAX_EMAIL")), 40));
				long[] amt = new long[inv.lines.size()], tax = taxes(inv.lines, amt);
				long sum = 0, taxSum = 0;
				for (int i = 0; i < amt.length; i++) {
					Map<String, Object> l = inv.lines.get(i);
					String n = String.valueOf(i + 1);
					put(fm, row, "일자" + n, dd);
					put(fm, row, "품목" + n, cut(s(l.get("ITEM_NM")), 100));
					put(fm, row, "공급가액" + n, String.valueOf(amt[i]));
					put(fm, row, "세액" + n, String.valueOf(tax[i]));
					put(fm, row, "품목비고" + n, cut(period(l), 100));
					sum += amt[i];
					taxSum += tax[i];
				}
				put(fm, row, "공급가액합계", String.valueOf(sum));
				put(fm, row, "세액합계", String.valueOf(taxSum));
				put(fm, row, "영수청구", "02");
			}
			wb.setActiveSheet(0);
			wb.write(out);
			return out.toByteArray();
		}
	}

	/** 품목별 세액. 합계 세액이 화면과 같게(공급가액 합계의 10%, 원 미만 버림) 맞추고 차이는 마지막 줄에 둔다 */
	static long[] taxes(List<Map<String, Object>> lines, long[] amt) {
		long[] tax = new long[lines.size()];
		long sum = 0, taxSum = 0;
		for (int i = 0; i < tax.length; i++) {
			amt[i] = ((Number) lines.get(i).get("AMT")).longValue();
			tax[i] = vat(amt[i]);
			sum += amt[i];
			taxSum += tax[i];
		}
		if (tax.length > 0) tax[tax.length - 1] += vat(sum) - taxSum;
		return tax;
	}

	/** 화면(trade_list.jsp vat)과 같은 계산: 10%, 원 미만 버림(음수는 0 쪽으로) */
	static long vat(long a) {
		return a < 0 ? -((-a) / 10) : a / 10;
	}

	/** 작성일자 기본값: 그 달 마지막 평일(토·일만 건너뛴다, 공휴일은 보지 않는다) */
	public static LocalDate lastWeekday(YearMonth m) {
		LocalDate d = m.atEndOfMonth();
		while (d.getDayOfWeek() == DayOfWeek.SATURDAY || d.getDayOfWeek() == DayOfWeek.SUNDAY) d = d.minusDays(1);
		return d;
	}

	private static void put(Form fm, Row row, String key, String v) {
		Integer c = fm.col.get(key);
		if (c == null || v == null || v.isEmpty()) return;
		Cell cell = row.getCell(c) != null ? row.getCell(c) : row.createCell(c);
		cell.setCellValue(v); // 양식 칸이 모두 텍스트(@) 서식이라 글자로 넣는다
	}

	private static String period(Map<String, Object> l) {
		String a = s(l.get("START_DT")), b = s(l.get("END_DT"));
		return a.isEmpty() && b.isEmpty() ? "" : md(a) + "~" + md(b);
	}

	private static String md(String d) {
		return d.length() >= 10 ? Integer.parseInt(d.substring(5, 7)) + "/" + Integer.parseInt(d.substring(8, 10)) : d;
	}

	static String digits(String s) {
		return s == null ? "" : s.replaceAll("\\D", "");
	}

	/** 홈택스 길이 제한(한글 2byte) 안으로 자른다 */
	static String cut(String s, int bytes) {
		if (s == null) return "";
		String t = s.trim();
		while (t.getBytes(KR).length > bytes) t = t.substring(0, t.length() - 1);
		return t;
	}

	private static String s(Object o) {
		return Objects.toString(o, "");
	}
}
