package com.eep.fo.signup.service;

/** 프로젝트에 JUnit 이 없어 main 으로 확인한다 */
public class SignupServiceCheck {

	public static void main(String[] args) {
		check("ho***@ex*****.com".equals(SignupService.maskEmail("honggd@example.com")), "이메일 가림");
		check("ho***@ex*****.co.kr".equals(SignupService.maskEmail("honggd@example.co.kr")), "2단 도메인");
		check("a***@b*.kr".equals(SignupService.maskEmail("a@bc.kr")), "짧은 이메일");

		check(SignupService.birthMatches("900101-1234567", "900101"), "생년월일 일치");
		check(!SignupService.birthMatches("900101-1234567", "900102"), "생년월일 불일치");
		check(!SignupService.birthMatches(null, "900101") && !SignupService.birthMatches("", "900101"), "주민번호 없음");
		check(!SignupService.birthMatches("enc:v1:망가진값", "900101"), "복호화 실패는 불일치");

		SignupService.Throttle t = new SignupService.Throttle();
		long now = 1000;
		for (int i = 0; i < 4; i++) {
			t.fail("홍길동", now);
		}
		check(!t.blocked("홍길동", now), "4회는 허용");
		t.fail("홍길동", now);
		check(t.blocked("홍길동", now), "5회면 차단");
		check(!t.blocked("김철수", now), "다른 이름은 영향 없음");
		check(!t.blocked("홍길동", now + 10 * 60 * 1000L), "10분 뒤 해제");
		t.fail("홍길동", now + 10 * 60 * 1000L);
		check(!t.blocked("홍길동", now + 10 * 60 * 1000L), "해제 뒤에는 다시 1회부터");

		check(t.allowMail(7, now), "첫 발송");
		check(!t.allowMail(7, now + 59999), "1분 안에는 재발송 불가");
		check(t.allowMail(8, now), "다른 직원은 영향 없음");
		check(t.allowMail(7, now + 60000), "1분 뒤 재발송");
		System.out.println("SignupServiceCheck OK");
	}

	private static void check(boolean ok, String name) {
		if (!ok) {
			throw new AssertionError(name);
		}
	}
}
