package com.eep.bo.deploy.service;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;

/** 홈택스 일괄발급 엑셀 자체 검사(기본 양식에 채운 뒤 다시 읽어 칸·금액 확인). 실행: java -ea -cp ... HometaxExcelCheck */
public class HometaxExcelCheck {

	public static void main(String[] args) throws Exception {
		check(HometaxExcel.lastWeekday(YearMonth.of(2026, 10)).equals(LocalDate.of(2026, 10, 30)), "10월 마지막 평일 10/30(금)");
		check(HometaxExcel.lastWeekday(YearMonth.of(2026, 5)).equals(LocalDate.of(2026, 5, 29)), "5/31 일요일 → 5/29");
		check(HometaxExcel.cut("가나다라", 5).equals("가나"), "한글 2byte 자르기");
		check(HometaxExcel.norm("일자1\n(2자리, 작성년월 내)").equals("일자1"), "머리글 괄호 빼기");
		check(HometaxExcel.norm("영수(01),\n청구(02)").equals("영수청구"), "영수청구 머리글");

		byte[] form;
		try (InputStream in = HometaxExcel.class.getResourceAsStream(HometaxExcel.DEFAULT_FORM)) {
			java.io.ByteArrayOutputStream b = new java.io.ByteArrayOutputStream();
			byte[] buf = new byte[8192];
			for (int n; (n = in.read(buf)) > 0;) b.write(buf, 0, n);
			form = b.toByteArray();
		}
		HometaxExcel.Form fm = HometaxExcel.form(form);
		check(fm.head == 5 && fm.items == 4 && fm.max == 100 && fm.supplier(), "기본 양식: 6행 머리글, 품목 4, 100장, 공급자 칸 " + fm.summary());

		Map<String, String> sup = new HashMap<>();
		sup.put("BIZ_NO", "000-00-00000");
		sup.put("NM", "예시회사");
		sup.put("CEO", "홍대표");
		Map<String, Object> p = new HashMap<>();
		p.put("BIZ_NO", "111-11-11111");
		p.put("PARTNER_NM", "가나다시스템");
		p.put("CEO_NM", "김대표");
		p.put("TAX_EMAIL", "tax@example.com");
		List<Map<String, Object>> lines = new ArrayList<>();
		for (long a : new long[] { 3333333, 3333333, 3333334 }) {
			Map<String, Object> l = new HashMap<>();
			l.put("ITEM_NM", "용역-홍길동");
			l.put("START_DT", "2026-10-01");
			l.put("END_DT", "2026-10-31");
			l.put("AMT", a);
			lines.add(l);
		}
		byte[] out = HometaxExcel.build(form, sup, Arrays.asList(new HometaxExcel.Invoice(p, lines)), LocalDate.of(2026, 10, 30));
		try (Workbook wb = WorkbookFactory.create(new ByteArrayInputStream(out))) {
			Sheet sh = wb.getSheetAt(0);
			Row r = sh.getRow(6);
			DataFormatter f = new DataFormatter();
			String[] cols = { "A", "B", "C", "E", "F", "K", "M", "N", "R", "T", "U", "W", "X", "AB", "AC", "AD", "AJ", "AK", "AR", "AS", "BG" };
			StringBuilder s = new StringBuilder();
			for (String c : cols) s.append(c).append('=').append(f.formatCellValue(r.getCell(org.apache.poi.ss.util.CellReference.convertColStringToIndex(c)))).append(' ');
			System.out.println(s);
			String v = s.toString();
			check(v.contains("A=01 ") && v.contains("B=20261030 ") && v.contains("C=0000000000 ") && v.contains("K=1111111111 "), "종류·작성일자·등록번호");
			check(v.contains("T=10000000 ") && v.contains("U=1000000 "), "합계 공급가액·세액(합계의 10%)");
			check(v.contains("AC=333333 ") && v.contains("AK=333333 ") && v.contains("AS=333334 "), "품목 세액 합이 합계 세액과 같게 마지막 줄 조정");
			check(v.contains("W=30 ") && v.contains("AD=10/1~10/31 ") && v.contains("BG=02"), "일자·품목비고 기간·청구");
			check(sh.getRow(7) == null || f.formatCellValue(sh.getRow(7).getCell(0)).isEmpty(), "8행은 비어 있음");
		}
		try {
			HometaxExcel.form(new byte[] { 1, 2, 3 });
			check(false, "엉뚱한 파일 거부");
		} catch (IllegalArgumentException e) {
			System.out.println("OK 엉뚱한 파일 거부: " + e.getMessage());
		}
		System.out.println("ALL OK");
	}

	static void check(boolean ok, String what) {
		if (!ok) throw new AssertionError("FAIL " + what);
		System.out.println("OK " + what);
	}
}
