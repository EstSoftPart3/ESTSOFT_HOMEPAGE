package com.eep.bo.mail.service;

import java.security.SecureRandom;
import java.util.Base64;

/**
 * 프로젝트에 JUnit 이 없어 main 으로 확인한다. 키와 비밀번호는 실행 때 만든 가짜 값이다.
 * 실행: java -cp "target/classes;target/test-classes" com.eep.bo.mail.service.MailAccountCheck
 */
public class MailAccountCheck {

	public static void main(String[] args) {
		String key = randomKey();
		String plain = "abcdefghijklmnop";

		String enc = MailPasswordCipher.encrypt(plain, key);
		check(!enc.contains(plain), "암호문에 원문이 없어야 한다");
		check(plain.equals(MailPasswordCipher.decrypt(enc, key)), "복호화하면 원문이 나와야 한다");
		check(!enc.equals(MailPasswordCipher.encrypt(plain, key)), "같은 원문도 매번 다르게 암호화돼야 한다");
		rejectedState(() -> MailPasswordCipher.decrypt(enc, randomKey()), "다른 키로는 복호화되지 않아야 한다");
		rejectedState(() -> MailPasswordCipher.encrypt(plain, Base64.getEncoder().encodeToString(new byte[16])), "32바이트가 아닌 키는 거부해야 한다");

		check("est.part1@gmail.com".equals(BoMailServiceImpl.normalizeAddr(" EST.part1@gmail.com ")), "주소를 정리해야 한다");
		rejected(() -> BoMailServiceImpl.normalizeAddr("est.part1@naver.com"), "Gmail 외 주소는 거부해야 한다");
		rejected(() -> BoMailServiceImpl.normalizeAddr("a@gmail.com\r\nBcc:b@gmail.com"), "줄바꿈이 든 주소는 거부해야 한다");

		check(plain.equals(BoMailServiceImpl.normalizePassword("abcd efgh ijkl mnop")), "Google 표시 형식의 공백을 지워야 한다");
		rejected(() -> BoMailServiceImpl.normalizePassword("Password1234!"), "로그인 비밀번호 형식은 Google 로 보내기 전에 거부해야 한다");
		rejected(() -> BoMailServiceImpl.normalizePassword(null), "빈 비밀번호는 거부해야 한다");

		check("연구개발".equals(BoMailServiceImpl.normalizeUse(" 연구개발 ")), "용도를 정리해야 한다");
		rejected(() -> BoMailServiceImpl.normalizeUse(" "), "빈 용도는 거부해야 한다");

		System.out.println("MailAccountCheck OK");
	}

	private static String randomKey() {
		byte[] key = new byte[32];
		new SecureRandom().nextBytes(key);
		return Base64.getEncoder().encodeToString(key);
	}

	private static void rejected(Runnable action, String label) {
		try {
			action.run();
		} catch (IllegalArgumentException e) {
			return;
		}
		throw new AssertionError(label);
	}

	private static void rejectedState(Runnable action, String label) {
		try {
			action.run();
		} catch (IllegalStateException e) {
			return;
		}
		throw new AssertionError(label);
	}

	private static void check(boolean ok, String label) {
		if (!ok) {
			throw new AssertionError(label);
		}
	}
}
