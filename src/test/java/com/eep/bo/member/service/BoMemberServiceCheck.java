package com.eep.bo.member.service;

import java.util.HashSet;
import java.util.Set;

/** 프로젝트에 JUnit 이 없어 main 으로 확인한다 */
public class BoMemberServiceCheck {

	public static void main(String[] args) {
		check("sample.lee".equals(BoMemberService.idFromEmail(" sample.lee@example.com ")), "이메일 앞부분");
		check("hong.gd@gmail.com".equals(BoMemberService.companyEmail(" Hong.GD@Gmail.com ")), "회사 메일 소문자 정리");
		check(BoMemberService.companyEmail("hong@naver.com") == null && BoMemberService.companyEmail("h@gmail.com") == null
				&& BoMemberService.companyEmail("hong+1@gmail.com") == null && BoMemberService.companyEmail(null) == null, "회사 메일은 아이디 규칙의 gmail 만");
		check(BoMemberService.idFromEmail(null) == null && BoMemberService.idFromEmail("없음") == null && BoMemberService.idFromEmail("a@b@c") == null, "잘못된 이메일");

		Set<String> seen = new HashSet<>();
		for (int i = 0; i < 200; i++) {
			String p = BoMemberService.tempPassword();
			check(p.length() == 12 && BoMemberService.passwordProblem("id", "old", p) == null, "초기 비밀번호가 규칙을 만족");
			check(!p.matches(".*[0O1lI].*"), "헷갈리는 글자 제외");
			seen.add(p);
		}
		check(seen.size() == 200, "매번 다른 값");

		check(BoMemberService.passwordProblem("id", "old", "short1") != null, "짧은 비밀번호");
		check(BoMemberService.passwordProblem("id", "old", "abcdefghijkl") != null, "숫자 없음");
		check(BoMemberService.passwordProblem("id", "old", "1234567890!") != null, "영문 없음");
		check(BoMemberService.passwordProblem("id", "old", "goodpass123") != null, "특수문자 없음");
		check(BoMemberService.passwordProblem("id", "old", "good pass 123") != null, "공백은 특수문자가 아님");
		check(BoMemberService.passwordProblem("id", "old", "abcdefghij!") != null, "숫자 없음(특수문자 있음)");
		check(BoMemberService.passwordProblem("sample12!@", "old", "SAMPLE12!@") != null, "아이디와 같음(대소문자만 다름)");
		check(BoMemberService.passwordProblem("id", "same12345!", "same12345!") != null, "현재와 같음");
		check(BoMemberService.passwordProblem("id", "old", "good-pass-123") == null, "통과");
		check("M".equals(BoMemberService.sexFromRrn("900101-1234567")) && "F".equals(BoMemberService.sexFromRrn("0001014234567")), "주민번호 성별");
		check(BoMemberService.sexFromRrn("900101") == null, "뒷자리 없는 주민번호");
		check(BoMemberService.roleSet(" 1,7,,1 ").size() == 2 && BoMemberService.roleSet(null).isEmpty() && BoMemberService.roleSet("").isEmpty(), "권한 목록 읽기");
		System.out.println("BoMemberServiceCheck OK");
	}

	private static void check(boolean ok, String name) {
		if (!ok) {
			throw new AssertionError(name);
		}
	}
}
