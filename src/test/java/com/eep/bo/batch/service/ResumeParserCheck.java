package com.eep.bo.batch.service;

import java.util.Map;

/**
 * 프로젝트에 JUnit 이 없어 main 으로 확인한다. 내용은 실제 출력본 양식을 본뜬 가짜 값이다.
 * 실행: java -cp "target/classes;target/test-classes" com.eep.bo.batch.service.ResumeParserCheck
 */
public class ResumeParserCheck {

	public static void main(String[] args) {
		String saramin = String.join("\n",
				"26. 10. 30. 오후 3:38 지원자 이력서 인쇄하기",
				"지원분야 : 웹프로그래머 입사지원일 : 2026년 10월 22일 (목)",
				"홍길동 신입",
				"남, 1996 (30세)",
				"이메일 hong@example.com 휴대폰 010-1111-2222",
				"주소 (12345) 경기 고양시 일산서구 어딘가로",
				"학력 전공 경력 희망연봉 포트폴리오",
				"가나대학교 컴퓨터 예시회사 면접 후 결정 총 5건",
				"대학교(4년) 중퇴 총 2년 5개월",
				"나의 스킬",
				"Java  Spring Boot  MySQL  React  Docker  AWS  Git  Redis  Kafka",
				"학력 대학교(4년) 중퇴",
				"https://www.saramin.co.kr/zf_user/company/applicant-resume-printing 1/10",
				"26. 10. 30. 오후 3:38 지원자 이력서 인쇄하기",
				"2014.07 ~ 2015.03 가나대학교(4년제) 컴퓨터",
				"중퇴",
				"경력 총 2년 5개월",
				"2026.05 ~ 2026.06 예시회사 개발TF · 인턴/수습 · 기획",
				"2개월",
				"2016.12 ~ 재직중 다른회사 물류 · 사원",
				"서비스 운영",
				"자격/어학/수상",
				"2021.08 JLPT 1급/PASS 일본어",
				"2025.03 OPIC intermediate Mid1급/PASS 영어",
				"2021.05 컴퓨터활용능력 2급 최종합격 대한상공회의소",
				"본인 주민등록번호 900101-1234567");
		Map<String, Object> r = ResumeParser.parse(saramin);
		same(r, "GENDER", "M");
		same(r, "AGE", "30");
		same(r, "ADDR", "경기 고양시 일산서구 어딘가로");
		same(r, "EDU", "가나대학교(4년제) 컴퓨터 중퇴");
		same(r, "CAREER", "신입 · 총 2년 5개월 · 예시회사 2개월, 다른회사 재직중 · Java, Spring Boot, MySQL, React, Docker, AWS, Git, Redis");
		same(r, "LANG", "JA,EN");
		same(r, "LANG_NOTE", "일본어 JLPT 1급/PASS, 영어 OPIC intermediate Mid1급/PASS");
		check(!r.toString().contains("900101"), "주민번호가 결과에 들어가면 안 된다");

		// 성별 미공개, 경력 없음, 줄 순서가 다른 졸업예정
		r = ResumeParser.parse(String.join("\n", "홍길동 신입", "1994 (31세)", "주소 (12345) 서울 금천구 어딘가", "학력 대학교(4년) 졸업예정",
				"졸업예정 다라대학교(ERICA)(4년제) 컴퓨터학부", "경험/활동/교육", "2026.09 ~ 2026.10 팀 과제 수행과제"));
		same(r, "GENDER", null);
		same(r, "AGE", "31");
		same(r, "EDU", "다라대학교(ERICA)(4년제) 컴퓨터학부 졸업예정");
		same(r, "CAREER", null);
		same(r, "LANG", null);

		// 경력 지원 양식(잡코리아 출력본)
		r = ResumeParser.parse(String.join("\n", "26. 10. 28. 오후 3:03 인쇄", "포지션 개발자 모집", "홍길동", "남, 1984년 (만 42세)", "010-1111-2222",
				"hong@example.com", "경기 광명시 하안동", "경력 총 7년", "(주)원회사 2022.09~2023.11", "게임개발 사원 1년 3개월", "담당 업무", "DB, Backend",
				"（주）이회사 2018.11~2020.05", "사원 1년 7개월", "병역 : 군필 육군/병장 2013.03 ~ 2015.02", "학력 대학교(4년) 휴학", "마바대학교 2003.03~2005.02", "스킬", "Java, Spring"));
		same(r, "GENDER", "M");
		same(r, "AGE", "42");
		same(r, "ADDR", "경기 광명시 하안동");
		same(r, "EDU", "마바대학교 휴학");
		same(r, "CAREER", "경력 · 총 7년 · (주)원회사 1년 3개월, （주）이회사 1년 7개월 · Java, Spring");

		check(ResumeParser.parse("아무 내용 없는 포트폴리오").isEmpty(), "항목이 없으면 빈 결과");
		System.out.println("OK");
	}

	private static void same(Map<String, Object> r, String key, String want) {
		Object got = r.get(key);
		check(want == null ? got == null : want.equals(got), key + ": " + got + " != " + want);
	}

	private static void check(boolean ok, String label) {
		if (!ok) {
			throw new AssertionError(label);
		}
	}
}
