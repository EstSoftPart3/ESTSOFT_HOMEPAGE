package com.eep.bo.member.service;

import java.util.HashSet;
import java.util.Set;

/** 프로젝트에 JUnit 이 없어 main 으로 확인한다 */
public class BoMemberServiceCheck {

	public static void main(String[] args) {
		check("sample.lee".equals(BoMemberService.idFromEmail(" sample.lee@example.com ")), "이메일 앞부분");
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
		check(BoMemberService.passwordProblem("id", "old", "1234567890") != null, "영문 없음");
		check(BoMemberService.passwordProblem("sample1234", "old", "SAMPLE1234") != null, "아이디와 같음");
		check(BoMemberService.passwordProblem("id", "same123456", "same123456") != null, "현재와 같음");
		check(BoMemberService.passwordProblem("id", "old", "good-pass-123") == null, "통과");
		System.out.println("BoMemberServiceCheck OK");
	}

	private static void check(boolean ok, String name) {
		if (!ok) {
			throw new AssertionError(name);
		}
	}
}
