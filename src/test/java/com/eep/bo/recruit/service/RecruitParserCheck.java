package com.eep.bo.recruit.service;

import java.time.LocalDate;
import java.util.Map;

/**
 * 프로젝트에 JUnit 이 없어 main 으로 확인한다. 값은 가짜다.
 * 실행: java -cp "target/classes;target/test-classes" com.eep.bo.recruit.service.RecruitParserCheck
 */
public class RecruitParserCheck {

	static int fail;
	static final LocalDate TODAY = LocalDate.of(2026, 11, 18);

	public static void main(String[] args) {
		// 캘린더 형식(제목 + 이름표)
		Map<String, Object> a = RecruitParser.parse("모집(중급 2) - OO생명보험사 유지보수 운영", String.join("\n",
				"기간: 2026-12-01 ~ 2027-05-31", "근무지: 서울 중구", "단가: 중급 650", "기술: Java, Spring, Oracle", "우대: 금융권 경험",
				"매출처: (주)예시파트너스", "담당: 김담당", "마감: 2026-11-21", "주 5일 상주 아님 메모줄"), TODAY);
		eq(a, "CLIENT_NM", "OO생명보험사");
		eq(a, "PRJ_NM", "유지보수 운영");
		eq(a, "GRADE_TXT", "중급 2");
		eq(a, "HEAD_CNT", 2);
		eq(a, "START_DT", "2026-12-01");
		eq(a, "END_DT", "2027-05-31");
		eq(a, "WORK_AREA", "서울 중구");
		eq(a, "PRICE_TXT", "중급 650");
		eq(a, "SKILLS", "Java, Spring, Oracle");
		eq(a, "SALE_PARTNER_TXT", "(주)예시파트너스");
		eq(a, "MGR_NM", "김담당");
		eq(a, "CLOSE_DT", "2026-11-21");

		// 붙여 넣기(제목 줄 + 문장)
		Map<String, Object> b = RecruitParser.parse(null, String.join("\n",
				"[모집] 신한금융그룹 책무이행시스템 초급 1명", "기간: 12월 초 ~ 6개월", "근무지: 을지로 상주", "기술: Java, Spring, Oracle", "예시정보 통해서 들어온 건, 단가 미정"), TODAY);
		eq(b, "CLIENT_NM", "신한금융그룹");
		eq(b, "PRJ_NM", "책무이행시스템");
		eq(b, "GRADE_TXT", "초급 1");
		eq(b, "START_DT", "2026-12-01");
		eq(b, "END_DT", "2027-05-31");
		eq(b, "WORK_AREA", "을지로 상주");
		eq(b, "SALE_PARTNER_TXT", "예시정보");
		eq(b, "PRICE_TXT", "미정");

		// 이름표 없는 문장만
		Map<String, Object> c = RecruitParser.parse("모집(초급 1) - 신한금융그룹 책무이행시스템", String.join("\n", "12월초부터 6개월, 을지로 상주", "예시정보 통해서 들어온 건", "단가 미정"), TODAY);
		eq(c, "START_DT", "2026-12-01");
		eq(c, "END_DT", "2027-05-31");
		eq(c, "WORK_AREA", "을지로");
		eq(c, "SALE_PARTNER_TXT", "예시정보");
		eq(c, "PRICE_TXT", "미정");

		// 오타·여러 등급·전각 괄호·연도 없는 날짜
		Map<String, Object> d = RecruitParser.parse("모집（중급 1, 고급 2）- LG화학", "기간: 1/2 ~ (미정)\n마감: 11/30", TODAY);
		eq(d, "GRADE_TXT", "중급 1 · 고급 2");
		eq(d, "HEAD_CNT", 3);
		eq(d, "CLIENT_NM", "LG화학");
		eq(d, "PRJ_NM", null);
		eq(d, "START_DT", "2027-01-02");
		eq(d, "END_DT", null);
		eq(d, "CLOSE_DT", "2026-11-30");

		// 형식이 다른 제목: 고객사에 제목 전체가 들어가고 나머지는 비운다
		Map<String, Object> e = RecruitParser.parse("모집 - 현대글로비스 HGLIS 기반 물류 시스템", "<p>근무지: 서울 강남구</p><br>기술: React, Node", TODAY);
		eq(e, "CLIENT_NM", "현대글로비스");
		eq(e, "PRJ_NM", "HGLIS 기반 물류 시스템");
		eq(e, "WORK_AREA", "서울 강남구");
		eq(e, "SKILLS", "React, Node");
		eq(e, "GRADE_TXT", null);

		check("잘못된 날짜", RecruitParser.date("13월 40일", TODAY) == null);

		System.out.println(fail == 0 ? "RecruitParserCheck OK" : "RecruitParserCheck FAIL " + fail);
		if (fail > 0) System.exit(1);
	}

	static void eq(Map<String, Object> m, String k, Object want) {
		Object got = m.get(k);
		boolean ok = want == null ? got == null : want.equals(got);
		if (!ok) {
			fail++;
			System.out.println("FAIL " + k + " want=" + want + " got=" + got);
		}
	}

	static void check(String name, boolean ok) {
		if (!ok) {
			fail++;
			System.out.println("FAIL " + name);
		}
	}
}
