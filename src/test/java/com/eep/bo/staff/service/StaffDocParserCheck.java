package com.eep.bo.staff.service;

import java.util.Map;

/**
 * 프로젝트에 JUnit 이 없어 main 으로 확인한다. 글자는 서류 양식을 본뜬 가짜 값이다.
 * 실행: java -cp "target/classes;target/test-classes" com.eep.bo.staff.service.StaffDocParserCheck
 */
public class StaffDocParserCheck {

	public static void main(String[] args) {
		// 파일 이름 -> 서류
		same(StaffDocParser.guessDoc("홍길동_급여통장.jpg"), "DOC_BANK", "급여통장");
		same(StaffDocParser.guessDoc("홍길동_주민등록등본.jpg"), "DOC_REG", "등본");
		same(StaffDocParser.guessDoc("주민등록등본 - 홍길동.pdf"), "DOC_REG", "등본(앞에 서류명)");
		same(StaffDocParser.guessDoc("홍길동_신분증앞면(주민번호 뒷자리 제외).jpg"), "DOC_ID", "신분증");
		same(StaffDocParser.guessDoc("가나대학교_졸업증명서_홍길동.png"), "DOC_GRAD", "졸업증명");
		same(StaffDocParser.guessDoc("건강보험자격득실확인서_홍길동.jpg"), "DOC_HI", "건보득실");
		same(StaffDocParser.guessDoc("홍길동_증명사진.JPG"), "DOC_PHOTO", "증명사진");
		same(StaffDocParser.guessDoc("가족관계증명서 - 홍길동.pdf"), null, "모르는 서류");

		// 통장사본
		Map<String, String> r = StaffDocParser.parse("DOC_BANK", "IBK기업은행\n예금주 홍길동\n계좌번호 123-456789-01-012\n개설일 2020-01-02\n고객센터 1566-2566\n연락처 010-1234-5678");
		same(r.get("BANK_NM"), "기업", "은행");
		same(r.get("ACCOUNT"), "123-456789-01-012", "계좌번호");
		r = StaffDocParser.parse("DOC_BANK", "카카오뱅크 입출금통장\n3333 01 2345678\n홍길동");
		same(r.get("BANK_NM"), "카카오", "카카오뱅크");
		same(r.get("ACCOUNT"), "3333-01-2345678", "띄어 쓴 계좌번호");
		r = StaffDocParser.parse("DOC_BANK", "국민은행\n예금주 홍길동 900101-1234567\n계좌\n123456-01-123456");
		same(r.get("ACCOUNT"), "123456-01-123456", "주민번호는 계좌가 아님, 다음 줄 계좌");

		// 신분증·등본
		r = StaffDocParser.parse("DOC_ID", "주민등록증\n홍길동 (洪吉童)\n900101-1234567\n서울특별시 강남구 테헤란로 123\n2020.1.2\n서울특별시 강남구청장");
		same(r.get("RRN"), "900101-1234567", "주민번호");
		same(r.get("ADDR"), "서울특별시 강남구 테헤란로 123", "주소");
		r = StaffDocParser.parse("DOC_REG", "주민등록표 (등본)\n현주소 : 경기도 성남시 분당구 판교로 1 (삼평동)\n세대주 홍길동\n1 본인 홍길동 900101-1******");
		same(r.get("RRN"), null, "가린 주민번호는 읽지 않음");
		same(r.get("ADDR"), "경기도 성남시 분당구 판교로 1 (삼평동)", "등본 주소");

		// 졸업증명
		r = StaffDocParser.parse("DOC_GRAD", "졸 업 증 명 서\n성명 홍길동\n학과 컴퓨터공학과\n졸업일자 2015년 2월 20일\n가나대학교 총장");
		same(r.get("UNIV_NM"), "가나대학교", "학교");
		same(r.get("UNIV_MAJOR"), "컴퓨터공학과", "학과");
		same(r.get("UNIV_GRAD"), "2015.02", "졸업년월");

		// 병적증명서
		r = StaffDocParser.parse("DOC_MIL", "병적증명서\n입영일자 2010.03.02\n전역일자 2012. 1. 1\n전역사유 만기");
		same(r.get("MIL_IN_DT"), "2010-03-02", "입영");
		same(r.get("MIL_OUT_DT"), "2012-01-01", "전역");
		r = StaffDocParser.parse("DOC_MIL", "병적증명서\n병역사항 면제\n면제사유 : 질병");
		same(r.get("MIL_EXEMPT"), "질병", "면제사유");

		check(StaffDocParser.parse("DOC_PHOTO", "아무 글자").isEmpty(), "읽을 칸이 없는 서류");
		check(StaffDocParser.parse("DOC_BANK", null).isEmpty(), "글자 없음");
		System.out.println("StaffDocParserCheck OK");
	}

	private static void same(String got, String want, String label) {
		check(want == null ? got == null : want.equals(got), label + ": " + got + " != " + want);
	}

	private static void check(boolean ok, String label) {
		if (!ok) {
			throw new AssertionError(label);
		}
	}
}
