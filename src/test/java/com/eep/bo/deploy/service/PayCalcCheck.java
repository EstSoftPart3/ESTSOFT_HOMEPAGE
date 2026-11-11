package com.eep.bo.deploy.service;

import java.io.ByteArrayOutputStream;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;

/**
 * 프로젝트에 JUnit 이 없어 main 으로 확인한다. 이름·금액은 모두 가짜 값이다.
 * 실행: java -cp "target/classes;target/test-classes;(poi jar)" com.eep.bo.deploy.service.PayCalcCheck
 */
public class PayCalcCheck {

	public static void main(String[] args) throws Exception {
		// 일수·일할 (엑셀 AO, AQ, AV)
		same(PayCalc.workDays(LocalDate.parse("2026-01-05"), LocalDate.parse("2026-11-20"), "2026-11"), 20, "11/20 철수 근무일");
		same(PayCalc.workDays(LocalDate.parse("2026-11-16"), null, "2026-11"), 15, "11/16 투입");
		same(PayCalc.workDays(LocalDate.parse("2026-12-01"), null, "2026-11"), 0, "다음 달 투입");
		same(PayCalc.prorate(6000000, 20, 30), 4000000L, "일할 계약단가");
		same(PayCalc.prorate(6800000, 26, 28), 6314000L, "천원 미만 버림");
		// 정규: 계약단가 - 식대, 일할하지 않는다
		long[] r = PayCalc.salaried("REGULAR", 4200000, "2026-11", LocalDate.parse("2025-10-13"), null, LocalDate.parse("2026-11-30"));
		same(r[0], 4000000L, "정규 기본");
		same(r[1], 200000L, "정규 식대");
		// 수습: 온달은 216만, 식대 없음
		r = PayCalc.salaried("PROBATION", 3000000, "2026-11", LocalDate.parse("2026-09-14"), null, LocalDate.parse("2026-11-30"));
		same(r[0], 2160000L, "수습 기본");
		same(r[1], 0L, "수습 식대");
		// 수습 첫 달: 입사일부터 일할
		r = PayCalc.salaried("PROBATION", 3000000, "2026-09", LocalDate.parse("2026-09-14"), null, LocalDate.parse("2026-09-30"));
		same(r[0], 2160000L * 17 / 30, "수습 첫 달");
		// 수습해제 달: 해제 전날까지 수습급여, 이후 계약단가 일할, 식대도 일할
		r = PayCalc.salaried("PROBATION", 3000000, "2026-12", LocalDate.parse("2026-09-14"), LocalDate.parse("2026-12-14"), LocalDate.parse("2026-12-31"));
		same(r[0], 2160000L * 13 / 31 + 3000000L * 18 / 31, "수습해제 달 기본");
		same(r[1], 200000L * 18 / 31, "수습해제 달 식대");
		// 해제가 지난 수습은 정규로 계산
		r = PayCalc.salaried("PROBATION", 3000000, "2027-01", LocalDate.parse("2026-09-14"), LocalDate.parse("2026-12-14"), LocalDate.parse("2027-01-31"));
		same(r[0], 2800000L, "해제 지난 수습");
		same(PayCalc.retire(4000000, 200000, 0, 0, 500000), 470000L, "퇴직금 적립");
		bonus();

		// 대장 합계·손익 (엑셀 BP, BQ, BV)
		Map<String, Object> row = new HashMap<>();
		row.put("PAY_YM", "2026-11");
		row.put("STAFF_SQ", 1);
		row.put("EMP_TYPE_CD", "REGULAR");
		row.put("BASE_AMT", 4000000L);
		row.put("MEAL_AMT", 200000L);
		row.put("BONUS_AMT", 500000L);
		row.put("NP_AMT", 180000L);
		row.put("HI_AMT", 141800L);
		row.put("LTC_AMT", 18350L);
		row.put("EI_AMT", 42300L);
		row.put("IT_AMT", 180000L);
		row.put("LIT_AMT", 18000L);
		row.put("MUTUAL_AMT", 20000L);
		row.put("MANUAL_FIELDS", "");
		Map<String, Object> d = new HashMap<>();
		d.put("PAY_YM", "2026-11");
		d.put("STAFF_SQ", 1);
		d.put("REAL_SALE", 7000000L);
		d.put("WORK_DAYS", 30);
		d.put("TOTAL_DAYS", 30);
		d.put("SALE_PRICE", 7000000L);
		d.put("COST_PRICE", 4200000L);
		List<Map<String, Object>> rows = new ArrayList<>();
		rows.add(row);
		List<Map<String, Object>> ds = new ArrayList<>();
		ds.add(d);
		BoPayrollService.derive(rows, ds);
		same(row.get("PAY_TOTAL"), 4700000L, "지급계");
		same(row.get("DED_TOTAL"), 600450L, "공제계");
		same(row.get("NET"), 4099550L, "실지급");
		same(row.get("COMPANY"), 852450L, "회사부담");
		same(row.get("PROFIT"), 1447550L, "영업이익");
		same(BoPayrollService.flags(row).get(0).get("K"), "상여", "확인 사항 키워드");
		row.put("LEDGER_PAY", 4900000L);
		same(BoPayrollService.flags(row).get(1).get("D").toString().split("\n")[2], "차이 +200,000", "대장차 설명");
		row.remove("LEDGER_PAY");
		// 정규 행 + 소액 계약 행: 퇴직금 적립은 정규 행 기본에만 (엑셀 BP 열은 행마다 계산)
		d.put("DEPLOY_TYPE", "REGULAR");
		Map<String, Object> split = new HashMap<>();
		split.put("PAY_YM", "2026-11");
		split.put("STAFF_SQ", 1);
		split.put("BASE_AMT", 600000L);
		split.put("DEPLOY_TYPE", "ETC");
		ds.add(split);
		row.put("BASE_AMT", 4600000L);
		BoPayrollService.derive(rows, ds);
		same(row.get("COMPANY"), 852450L, "계약 행 기본에는 퇴직금 적립 없음");
		ds.remove(split);
		d.remove("DEPLOY_TYPE");
		row.put("BASE_AMT", 4000000L);
		row.put("EMP_TYPE_CD", "SPECIAL");
		BoPayrollService.derive(rows, ds);
		same(row.get("COMPANY"), 0L, "특고는 회사부담 0 (엑셀과 같음)");

		// 투입현황: 진행 중 > 앞으로 > 재직자 대기
		List<Map<String, Object>> all = new ArrayList<>();
		all.add(deploy(1, "2025-01-01", "2025-12-31", "WORK"));
		all.add(deploy(1, "2026-01-05", "2026-11-20", "WORK"));
		all.add(deploy(2, "2025-01-01", "2026-10-31", "WORK"));
		all.add(deploy(3, "2025-01-01", "2026-10-31", "LEFT"));
		all.add(deploy(4, "2026-12-01", null, "WORK"));
		List<Map<String, Object>> cur = BoDeployService.current(all, LocalDate.parse("2026-11-10"));
		same(cur.size(), 3, "현재 건 수(퇴사자 제외)");
		same(cur.get(0).get("START_DT") + "/" + cur.get(0).get("STATE"), "2026-01-05/ACTIVE", "진행 중");
		same(cur.get(1).get("STATE"), "WAIT", "대기");
		same(cur.get(2).get("STATE"), "FUTURE", "투입 예정");

		secret();
		ledger();
		license();
		System.out.println("PayCalcCheck OK");
	}

	/** 실제 대장과 같은 칸 배치의 가짜 파일 */
	private static void ledger() throws Exception {
		HSSFWorkbook wb = new HSSFWorkbook();
		Sheet s = wb.createSheet();
		put(s, 0, 7, "2026년 11월분  급여대장");
		put(s, 2, 7, "[귀속:2026년 11월] [지급:2026년 12월 10일]");
		String[] h1 = { "사원번호", "성  명", "기본급", "상여", "식대", "연구개발", "운전보조", "자녀보육", "", "국민연금", "건강보험", "고용보험", "장기요양보험료", "소득세", "지방소득세" };
		String[] h2 = { "입 사 일", "직  급", "", "", "", "", "", "", "", "국민연금정산", "건강보험정산", "고용보험정산", "장기요양정산", "상조회비", "공제합계" };
		String[] h3 = { "퇴 사 일", "부  서", "", "", "", "", "", "", "지급합계", "환급금이자", "", "", "", "", "차인지급액" };
		for (int c = 0; c < h1.length; c++) {
			put(s, 5, c, h1[c]);
			put(s, 6, c, h2[c]);
			put(s, 7, c, h3[c]);
		}
		put(s, 8, 0, "27");
		put(s, 8, 1, "최가상");
		num(s, 8, 2, 4000000);
		num(s, 8, 3, 500000);
		num(s, 8, 4, 200000);
		long[] ded = { 180000, 141800, 42300, 18350, 180000, 18000 };
		for (int i = 0; i < ded.length; i++) {
			num(s, 8, 9 + i, ded[i]);
		}
		num(s, 9, 13, 20000);
		num(s, 9, 14, 600450);
		num(s, 10, 8, 4700000);
		num(s, 10, 14, 4099550);
		PayLedgerParser.Result r = PayLedgerParser.parse(bytes(wb));
		same(r.kind + "/" + r.ym + "/" + r.rows.size(), "PAY/2026-11/1", "급여대장 읽기");
		same(r.rows.get(0).get("MUTUAL_AMT"), 20000L, "상조회비 위치");
		same(r.rows.get(0).get("LTC_AMT"), 18350L, "장기요양 위치");
		num(s, 10, 14, 4099551);
		try {
			PayLedgerParser.parse(bytes(wb));
			throw new AssertionError("합계가 틀린 대장을 받았다");
		} catch (IllegalArgumentException expected) {
			// 합계가 틀리면 파일 전체를 거부한다
		}

		HSSFWorkbook biz = new HSSFWorkbook();
		Sheet b = biz.createSheet();
		String[] b1 = { "NO", "코드", "성   명", "귀속년월", "지급액", "소득세", "예술/특고인 경비", "학자금상환액", "", "영수인" };
		String[] b2 = { "", "", "", "지급년월", "", "지방소득세", "고용보험료", "산재보험료", "차인지급액" };
		for (int c = 0; c < b1.length; c++) {
			put(b, 4, c, b1[c]);
		}
		for (int c = 0; c < b2.length; c++) {
			put(b, 5, c, b2[c]);
		}
		put(b, 6, 0, "1");
		put(b, 6, 1, "900012");
		put(b, 6, 2, "박테스트");
		put(b, 6, 3, "2026.11");
		num(b, 6, 4, 4200000);
		num(b, 6, 5, 126000);
		num(b, 6, 6, 840000);
		put(b, 7, 3, "2026.12");
		num(b, 7, 5, 12600);
		num(b, 7, 6, 33600);
		num(b, 7, 7, 4200);
		num(b, 7, 8, 4023600);
		r = PayLedgerParser.parse(bytes(biz));
		same(r.kind + "/" + r.ym, "BIZ/2026-11", "사업소득대장 읽기");
		same(r.rows.get(0).get("LEDGER_DED"), 176400L, "경비는 공제가 아님");
		same(r.rows.get(0).get("ACC_AMT"), 4200L, "산재 위치");
	}

	private static void license() {
		Map<String, String> m = BizLicenseParser.parse("사 업 자 등 록 증\n(법인사업자)\n등록번호 : 123-45-67890\n법인명(단체명) : 가나시스템 주식회사\n대 표 자 : 홍길동\n개업연월일 : 2015 년 03 월 02 일 법인등록번호 : 110111-1234567\n사업장 소재지 : 서울특별시 예시구 예시로 1, 2층\n본 점 소 재 지 : 서울특별시 예시구 예시로 1\n사업의 종류 : 업태 : 서비스 종목 : 소프트웨어 개발\n");
		same(m.get("BIZ_NO"), "123-45-67890", "등록번호");
		same(m.get("PARTNER_NM"), "가나시스템 주식회사", "법인명");
		same(m.get("CEO_NM"), "홍길동", "대표자");
		same(m.get("OPEN_DT"), "2015-03-02", "개업일");
		same(m.get("ADDR"), "서울특별시 예시구 예시로 1, 2층", "주소");
		same(m.get("BIZ_TYPE"), "서비스", "업태");
		same(m.get("BIZ_ITEM"), "소프트웨어 개발", "종목");
		m = BizLicenseParser.parse("상호: 신규상사\n성명: 김예시 생년월일: 1980년 01월 01일\n");
		same(m.get("PARTNER_NM") + "/" + m.get("CEO_NM"), "신규상사/김예시", "개인사업자");
		// 서류 종류와 통장사본
		same(BizLicenseParser.kindByName("MCS_사업자등록증_2020.pdf"), "LICENSE", "이름-사업자");
		same(BizLicenseParser.kindByName("mcs_logo.png") + BizLicenseParser.kindByName("CI.jpg"), "LOGOLOGO", "이름-로고");
		same(BizLicenseParser.kindByName("도장.png") + BizLicenseParser.kindByName("통장사본.pdf"), "SEALBANK", "이름-직인·통장");
		same(BizLicenseParser.kindByName("scan001.pdf") + "/" + BizLicenseParser.kindByName("circle.png"), "null/null", "이름-모름");
		String bank = "통장사본\n신한은행\n계좌번호 140-012-345678\n예금주 (주)가나시스템\n";
		same(BizLicenseParser.kindByText(bank), "BANK", "글자-통장");
		same(BizLicenseParser.kindByText("사 업 자 등 록 증\n등록번호 : 123-45-67890"), "LICENSE", "글자-사업자");
		same(BizLicenseParser.kindByText("안녕하세요"), "null", "글자-모름");
		Map<String, String> b = BizLicenseParser.bank(bank);
		same(b.get("BANK_NM") + "/" + b.get("ACCOUNT_NO") + "/" + b.get("ACCOUNT_HOLDER"), "신한/140-012-345678/(주)가나시스템", "통장 칸");
	}

	/** 시크릿: 시크릿 아닌 사람에게는 행을 빼고 요청을 거부, 시크릿 계정에게는 SECRET 표시 */
	private static void secret() {
		java.util.Set<String> staff = new java.util.HashSet<>(java.util.Arrays.asList("7"));
		List<Map<String, Object>> rows = new ArrayList<>(java.util.Arrays.asList(deploy(7, "2026-01-01", null, "WORK"), deploy(8, "2026-01-01", null, "WORK")));
		same(new SecretFilter.View(false, staff).filter(rows).size(), 1, "시크릿 아닌 사람에게 시크릿 행 빠짐");
		rows.add(0, deploy(7, "2026-01-01", null, "WORK"));
		new SecretFilter.View(true, staff).filter(rows);
		same(rows.size() + "/" + rows.get(0).get("SECRET") + "/" + rows.get(1).get("SECRET"), "2/true/null", "시크릿 계정은 다 보고 표시");
		try {
			new SecretFilter.View(false, staff).guard(7);
			throw new AssertionError("숨긴 직원 요청을 받았다");
		} catch (IllegalArgumentException expected) {
			// 없는 것처럼 거부
		}
		new SecretFilter.View(true, staff).guard(7);
	}

	/** 상여: 기준일 + n개월 달성 → 익월, 만근·근속 조건, 사람별 금액, 추천인 */
	private static void bonus() {
		List<Map<String, Object>> bonuses = new ArrayList<>(), applies = new ArrayList<>(), deploys = new ArrayList<>();
		bonuses.add(item(1, "1년 근속상여", "JOIN", "SELF", "12:FULL:500000", "Y"));
		bonuses.add(item(2, "연차수당", "JOIN_OR_CONTRACT", "SELF", "3:FULL:500000,6:FULL:500000", "N"));
		bonuses.add(item(3, "인재추천", "CONTRACT", "REFERRER", "0:NONE:100000,3:TENURE:200000", "N"));
		// 1번 정규: 입사 2025-10-13. 2번 프리: 2026-03-02 시작, 2026-05-10~05-19 공백. 3번은 1번이 추천
		Map<String, Object> d1 = deploy(1, "2025-10-13", null, "WORK");
		d1.put("JOIN_DT", "2025-10-13");
		d1.put("EMP_TYPE_CD", "REGULAR");
		Map<String, Object> d2 = deploy(2, "2026-03-02", "2026-05-09", "WORK"), d2b = deploy(2, "2026-05-20", null, "WORK");
		d2.put("EMP_TYPE_CD", "SPECIAL");
		d2b.put("EMP_TYPE_CD", "SPECIAL");
		Map<String, Object> d3 = deploy(3, "2026-09-01", null, "WORK");
		d3.put("EMP_TYPE_CD", "SPECIAL");
		d3.put("STAFF_NM", "가나다");
		deploys.addAll(java.util.Arrays.asList(d1, d2, d2b, d3));
		applies.add(apply(1, 1, 800000L, null));
		applies.add(apply(2, 2, null, null));
		applies.add(apply(3, 3, null, 1));
		Map<String, List<Map<String, Object>>> by = BonusCalc.byRecipient(BonusCalc.plans(bonuses, applies, deploys));
		same(BonusCalc.sumFor(by.get("1"), "2026-11"), 800000L, "1년 근속 2026-11, 사람별 금액");
		same(BonusCalc.sumFor(by.get("2"), "2026-07"), 0L, "공백이 있으면 3개월 만근 미달");
		same(by.get("2").get(0).get("WHY"), "만근 미달: 2026-05 근무 21/31일", "만근 미달 이유");
		same(BonusCalc.sumFor(by.get("1"), "2026-10"), 100000L, "추천 계약 시 → 추천인 익월");
		same(BonusCalc.sumFor(by.get("1"), "2027-01"), 200000L, "추천 3개월 근속");
		same(by.get("1").get(1).get("LABEL"), "인재추천 계약 (가나다)", "추천 항목 이름");
		bonuses.get(0).put("USE_YN", "N");
		same(BonusCalc.byRecipient(BonusCalc.plans(bonuses, applies, deploys)).get("1").size(), 2, "사용 끈 항목은 빠짐");
		try {
			BonusCalc.steps("3:FULL:abc");
			throw new AssertionError("틀린 단계를 받았다");
		} catch (IllegalArgumentException expected) {
			// 저장 전에 막는다
		}
	}

	private static Map<String, Object> item(int sq, String nm, String base, String target, String steps, String per) {
		Map<String, Object> m = new HashMap<>();
		m.put("BONUS_SQ", sq);
		m.put("BONUS_NM", nm);
		m.put("BASE_CD", base);
		m.put("TARGET_CD", target);
		m.put("STEPS", steps);
		m.put("PER_AMT_YN", per);
		m.put("USE_YN", "Y");
		return m;
	}

	private static Map<String, Object> apply(int bonus, int staff, Long amt, Integer referrer) {
		Map<String, Object> m = new HashMap<>();
		m.put("BONUS_SQ", bonus);
		m.put("STAFF_SQ", staff);
		m.put("AMT", amt);
		m.put("REFERRER_SQ", referrer);
		return m;
	}

	private static Map<String, Object> deploy(int staff, String start, String end, String status) {
		Map<String, Object> m = new HashMap<>();
		m.put("STAFF_SQ", staff);
		m.put("START_DT", start);
		m.put("END_DT", end);
		m.put("STATUS_CD", status);
		return m;
	}

	private static void put(Sheet s, int r, int c, String v) {
		Row row = s.getRow(r) == null ? s.createRow(r) : s.getRow(r);
		row.createCell(c).setCellValue(v);
	}

	private static void num(Sheet s, int r, int c, double v) {
		Row row = s.getRow(r) == null ? s.createRow(r) : s.getRow(r);
		row.createCell(c).setCellValue(v);
	}

	private static byte[] bytes(HSSFWorkbook wb) throws Exception {
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		wb.write(out);
		return out.toByteArray();
	}

	private static void same(Object actual, Object expected, String what) {
		if (!String.valueOf(expected).equals(String.valueOf(actual))) {
			throw new AssertionError(what + ": " + actual + " (기대 " + expected + ")");
		}
	}
}
