package com.eep.bo.recruit.service;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * 프로젝트에 JUnit 이 없어 main 으로 확인한다. 값은 가짜다.
 * 실행: java -cp "target/classes;target/test-classes" com.eep.bo.recruit.service.RecruitCalParserCheck
 */
public class RecruitCalParserCheck {

	static int fail;

	@SuppressWarnings("unchecked")
	public static void main(String[] args) {
		eq(RecruitCalParser.recruitTitle("모집(초급~중급 2) - 예시생명 신계약 운영"), "예시생명 신계약 운영");
		eq(RecruitCalParser.recruitTitle("모집(고급00) - 예시결제원 차세대 사업"), "예시결제원 차세대 사업");
		eq(RecruitCalParser.recruitTitle("방문 - 홍길동(재계약서 작성)"), null);
		String[] iv = RecruitCalParser.interview("인터뷰 - 홍길동(예시은행 유지보수 플젝)");
		eq(iv[0], "홍길동");
		eq(iv[1], "예시은행 유지보수 플젝");
		eq(RecruitCalParser.interview("인터뷰 - 김철수(kt gis)")[1], "kt gis");
		eq(RecruitCalParser.interview("직원특이사항 - 박준수"), null);
		eq(RecruitCalParser.key("[예시캐피탈 화면개선] - 추가"), RecruitCalParser.key("예시캐피탈 화면개선 추가"));

		// 보고: 칸 제목 + 질문/대답(여러 줄 대답, 번호 줄)
		String desc = String.join("<br>", "예시은행 유지보수 플젝", "", "1. 인터뷰 분위기 : 편안함", "", "2. 질의응답(자세하게 예제와 대답) : ", "",
				"- 1.", "질문 : 도커는 직접 써 봤나?", "대답 : 운영 환경에 참여했다.", "세팅을 보면 기억날 것 같다.", "", "- 2.", "질문: 쿼리 능력은?", "대답: 기본 조회 정도.",
				"", "3. 답변 못한 질문 : 인터페이스 방식", "", "4. 예상 결과 : 잘 모르겠습니다.", "", "5. 투입 의사 : O");
		Map<String, Object> r = RecruitCalParser.report(desc, Arrays.asList("편안함", "평범함"));
		eq(r.get("mood"), "편안함");
		List<Map<String, String>> qa = (List<Map<String, String>>) r.get("qa");
		eq(qa.size(), 2);
		eq(qa.get(0).get("q"), "도커는 직접 써 봤나?");
		eq(qa.get(0).get("a"), "운영 환경에 참여했다. 세팅을 보면 기억날 것 같다.");
		eq(qa.get(1).get("a"), "기본 조회 정도.");
		eq(r.get("memo"), "답변 못한 질문: 인터페이스 방식\n예상 결과: 잘 모르겠습니다.\n투입 의사: O");

		// 분위기가 여러 줄이고 칩에 없으면 메모로
		Map<String, Object> r2 = RecruitCalParser.report("1. 인터뷰 분위기 :\n  1대1 면접으로 괜찮았습니다\n2. 질의응답 :\n질문 : A?\n대답 : B", Arrays.asList("편안함"));
		eq(r2.get("mood"), null);
		eq(((String) r2.get("memo")).startsWith("분위기: 1대1 면접으로 괜찮았습니다"), true);

		// 보고가 없는 안내만 있는 일정
		eq(RecruitCalParser.report("정서영님 인터뷰정보\n11/24 화요일 오후 2시20분\n가산", Arrays.asList("편안함")), null);

		System.out.println(fail == 0 ? "RecruitCalParserCheck OK" : "RecruitCalParserCheck FAIL " + fail);
		if (fail > 0) System.exit(1);
	}

	static void eq(Object got, Object want) {
		if (want == null ? got != null : !want.equals(got)) {
			fail++;
			System.out.println("틀림: [" + got + "] 기대 [" + want + "]");
		}
	}
}
