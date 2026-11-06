package common.util;

import org.apache.commons.codec.binary.Base64;

/**
 * 프로젝트에 JUnit 이 없어 main 으로 확인한다. 키와 값은 시험용 가짜다.
 * 실행: java -cp "target/classes;target/test-classes;<commons-codec jar>" common.util.RrnCipherCheck
 */
public class RrnCipherCheck {

	public static void main(String[] args) {
		byte[] key = new byte[32];
		for (int i = 0; i < key.length; i++) {
			key[i] = (byte) i;
		}
		String enc = RrnCipher.encrypt("900101-1234567", key);
		check(RrnCipher.isEncrypted(enc), "접두어");
		check(!enc.equals(RrnCipher.encrypt("900101-1234567", key)), "IV 가 매번 다름");
		check("900101-1234567".equals(RrnCipher.decrypt(enc, key)), "왕복");

		byte[] other = key.clone();
		other[0] = 99;
		boolean failed = false;
		try {
			RrnCipher.decrypt(enc, other);
		} catch (IllegalStateException e) {
			failed = true;
		}
		check(failed, "다른 키로는 복호화 실패");

		check("900101-*******".equals(RrnCipher.mask("900101-1234567")), "마스킹 하이픈");
		check("900101-*******".equals(RrnCipher.mask("9001011234567")), "마스킹 숫자만");
		check("*******".equals(RrnCipher.mask("12")), "짧은 값");
		check(RrnCipher.isMasked("900101-*******") && RrnCipher.isMasked("(복호화 실패)"), "가린 값 판별");
		check(!RrnCipher.isMasked("900101-1234567"), "실제 값은 가린 값 아님");
		check("******6789".equals(RrnCipher.maskTailStored("110-123-456789")), "계좌번호 끝 4자리");
		check("****".equals(RrnCipher.maskTailStored("123")), "짧은 계좌번호");

		// 서버 python cryptography(AESGCM) 로 같은 키로 만든 값: "800202-2345678"
		String fromPython = args.length > 0 ? args[0] : null;
		if (fromPython != null) {
			check("800202-2345678".equals(RrnCipher.decrypt(fromPython, key)), "python 암호문 호환");
		}
		System.out.println("RrnCipherCheck OK" + (fromPython == null ? " (python 호환은 인자 없이 생략)" : ""));
		System.out.println("key b64 for python: " + Base64.encodeBase64String(key));
	}

	private static void check(boolean ok, String name) {
		if (!ok) {
			throw new AssertionError(name);
		}
	}
}
