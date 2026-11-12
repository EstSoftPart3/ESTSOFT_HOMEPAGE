package com.eep.bo.card.service;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 * 프로젝트에 JUnit 이 없어 main 으로 확인한다.
 * 실행: java -cp "target/classes;target/test-classes;target/est_eep/WEB-INF/lib/*" com.eep.bo.card.service.CardCheck
 */
public class CardCheck {

	public static void main(String[] args) throws Exception {
		// 날짜·금액 글자
		same(CardStatementParser.date("2026.10.09"), "2026-10-09", "점 날짜");
		same(CardStatementParser.date("2026-10-09 12:30"), "2026-10-09", "시각 붙은 날짜");
		same(CardStatementParser.date("20261009"), "2026-10-09", "8자리 날짜");
		same(CardStatementParser.date("26.10.09"), "2026-10-09", "2자리 연도");
		same(CardStatementParser.date("2026년 10월 9일"), "2026-10-09", "한글 날짜");
		same(CardStatementParser.date("합계"), null, "날짜 아님");
		same(CardStatementParser.date("2026-02-30"), null, "없는 날");
		same(CardStatementParser.amount("18,000원"), 18000L, "쉼표·원");
		same(CardStatementParser.amount("-5,000"), -5000L, "취소 음수");
		same(CardStatementParser.amount("총 3건"), null, "금액 아님");

		// 엑셀: 위에 제목 줄이 있고, 머리글 이름이 카드사식이고, 합계 줄이 끝에 있다
		XSSFWorkbook wb = new XSSFWorkbook();
		Sheet s = wb.createSheet("이용내역");
		row(s, 0, "국민카드 이용대금 명세");
		row(s, 2, "이용일자", "이용카드", "이용 가맹점", "이용금액", "승인번호");
		row(s, 3, "2026.10.03", "본인5678", "○○식당", "42,000", "1111");
		row(s, 4, "2026.10.09", "본인5678", "□□카페", "18,000", "2222");
		row(s, 5, "2026.10.09", "본인5678", "택시", "18,000", "3333");
		row(s, 6, "2026.10.21", "본인5678", "◇◇주유소", "60,000", "4444");
		row(s, 7, "합계", "", "", "138,000", "");
		ByteArrayOutputStream bo = new ByteArrayOutputStream();
		wb.write(bo);
		wb.close();
		List<Map<String, Object>> excel = CardStatementParser.parse(bo.toByteArray());
		same(excel.size(), 4, "합계 줄 제외 4건");
		same(excel.get(0).get("MERCHANT"), "○○식당", "가맹점 칸 찾기");
		same(excel.get(0).get("AMT"), 42000L, "금액 칸 찾기");

		// 대조: 일치 1, 같은 날 같은 금액 2건은 확인 필요, 엑셀에만 1, 등록에만 1
		List<Map<String, Object>> uses = new ArrayList<>(Arrays.asList(use(1, "2026-10-03", 42000), use(2, "2026-10-09", 18000), use(3, "2026-10-09", 18000), use(4, "2026-10-28", 25000)));
		List<Map<String, Object>> m = CardStatementParser.match(excel, uses);
		same(count(m, "MATCH"), 3, "일치(같은 날 같은 금액은 순서대로)");
		same(count(m, "EXCEL_ONLY"), 1, "엑셀에만");
		same(count(m, "REG_ONLY"), 1, "등록에만");
		same(((Map<?, ?>) m.get(0).get("USE")).get("USE_SQ"), 1, "일치 건 연결");
		Set<Object> paired = new HashSet<>();
		for (Map<String, Object> r : m) if ("MATCH".equals(r.get("TYPE"))) paired.add(((Map<?, ?>) r.get("USE")).get("USE_SQ"));
		same(paired.size(), 3, "한 등록 건을 두 번 쓰지 않음");
		// 엑셀 2건 · 등록 1건이면 하나는 일치, 하나는 엑셀에만
		List<Map<String, Object>> m2 = CardStatementParser.match(excel, Arrays.asList(use(9, "2026-10-09", 18000)));
		same(count(m2, "MATCH"), 1, "후보 1건뿐인 중복");
		same(count(m2, "EXCEL_ONLY"), 3, "남는 엑셀 건");
		for (Map<String, Object> r : m2) if ("EXCEL_ONLY".equals(r.get("TYPE")) && r.get("GUESS_CD") == null) throw new AssertionError("추정 코드 없음");
		// 가맹점으로 사용처 코드 추정
		same(CardStatementParser.guess("스타벅스 강남점"), "MEAL", "카페");
		same(CardStatementParser.guess("서울역 주차장"), "PARK", "주차");
		same(CardStatementParser.guess("코레일 KTX"), "TRANS", "KTX 는 통신 아님");
		same(CardStatementParser.guess("KT 통신요금"), "COMM", "통신");
		same(CardStatementParser.guess("AWS EMEA"), "SW", "구독");
		same(CardStatementParser.guess("이름 모를 가게"), "ETC", "기타");

		// 마감 엑셀: 연도별 시트, B2 제목, 4행 머리글, 카드는 첫 줄에만, 사용처·대상 빈 값 채움
		Map<String, Object> cardRow = new HashMap<>();
		cardRow.put("HOLDER_NM", "홍길동");
		cardRow.put("CARD_CO", "롯데카드");
		Map<String, Object> a = use(1, "2025-12-30", 12000), b = use(2, "2026-04-16", 11000), c = use(3, "2026-04-24", 5000);
		a.put("MERCHANT", "돈오"); a.put("DETAIL", "점심식사"); a.put("TARGET_NM", "홍길동, 대표님");
		b.put("USE_CD", "MEAL");
		Map<String, String> nm = new HashMap<>();
		nm.put("MEAL", "식대");
		XSSFWorkbook out = new XSSFWorkbook(new java.io.ByteArrayInputStream(CardLedgerExcel.build(cardRow, Arrays.asList(a, b, c), nm)));
		same(out.getNumberOfSheets(), 2, "연도별 시트");
		same(out.getSheetAt(1).getSheetName(), "2026", "시트 이름은 연도");
		Sheet o = out.getSheetAt(1);
		same(o.getRow(1).getCell(1).getStringCellValue(), "법인카드 사용내역", "B2 제목");
		same(o.getRow(3).getCell(5).getStringCellValue(), "사용처", "머리글");
		same(o.getRow(4).getCell(2).getStringCellValue(), "롯데카드", "첫 줄 카드");
		same(o.getRow(5).getCell(2).getStringCellValue(), "", "둘째 줄 카드 빈칸");
		same(o.getRow(4).getCell(3).getNumericCellValue(), 4.0, "월");
		same(o.getRow(4).getCell(4).getNumericCellValue(), 16.0, "일");
		same(o.getRow(4).getCell(5).getStringCellValue(), "식대", "사용처 없으면 코드 이름");
		same(o.getRow(4).getCell(6).getNumericCellValue(), 11000.0, "금액");
		same(o.getRow(4).getCell(8).getStringCellValue(), "홍길동", "대상 없으면 담당");
		same(out.getSheetAt(0).getRow(4).getCell(8).getStringCellValue(), "홍길동, 대표님", "대상");
		out.close();

		// 머리글이 없는 엑셀은 거부
		XSSFWorkbook bad = new XSSFWorkbook();
		row(bad.createSheet(), 0, "이름", "부서");
		ByteArrayOutputStream bb = new ByteArrayOutputStream();
		bad.write(bb);
		bad.close();
		try {
			CardStatementParser.parse(bb.toByteArray());
			throw new AssertionError("머리글 없는 엑셀을 받음");
		} catch (IllegalArgumentException expected) {
			System.out.println("ok  머리글 없는 엑셀 거부");
		}
		System.out.println("ALL OK");
	}

	private static void row(Sheet s, int r, String... v) {
		Row row = s.createRow(r);
		for (int i = 0; i < v.length; i++) row.createCell(i).setCellValue(v[i]);
	}

	private static Map<String, Object> use(int sq, String dt, long amt) {
		Map<String, Object> m = new HashMap<>();
		m.put("USE_SQ", sq);
		m.put("USE_DT", dt);
		m.put("AMT", amt);
		return m;
	}

	private static int count(List<Map<String, Object>> m, String type) {
		int n = 0;
		for (Map<String, Object> r : m) if (type.equals(r.get("TYPE"))) n++;
		return n;
	}

	private static void same(Object a, Object b, String name) {
		if (a == null ? b != null : !a.equals(b)) throw new AssertionError(name + ": " + a + " != " + b);
		System.out.println("ok  " + name);
	}
}
