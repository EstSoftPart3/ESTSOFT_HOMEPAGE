package com.eep.bo.mail.service;

import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.util.Arrays;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/** 앱 비밀번호 암복호화. SMTP 로그인에 원문이 필요해 해시가 아닌 AES-256-GCM 을 쓴다 */
final class MailPasswordCipher {

	private static final int IV_BYTES = 12;
	private static final int TAG_BITS = 128;

	private MailPasswordCipher() {
	}

	static String encrypt(String plain, String base64Key) {
		try {
			byte[] iv = new byte[IV_BYTES];
			new SecureRandom().nextBytes(iv);
			Cipher cipher = cipher(Cipher.ENCRYPT_MODE, base64Key, iv);
			byte[] enc = cipher.doFinal(plain.getBytes(StandardCharsets.UTF_8));
			byte[] out = Arrays.copyOf(iv, IV_BYTES + enc.length);
			System.arraycopy(enc, 0, out, IV_BYTES, enc.length);
			return Base64.getEncoder().encodeToString(out);
		} catch (GeneralSecurityException e) {
			throw new IllegalStateException("앱 비밀번호 암호화에 실패했습니다.");
		}
	}

	static String decrypt(String stored, String base64Key) {
		try {
			byte[] in = Base64.getDecoder().decode(stored);
			Cipher cipher = cipher(Cipher.DECRYPT_MODE, base64Key, Arrays.copyOf(in, IV_BYTES));
			return new String(cipher.doFinal(in, IV_BYTES, in.length - IV_BYTES), StandardCharsets.UTF_8);
		} catch (GeneralSecurityException e) {
			throw new IllegalStateException("앱 비밀번호 복호화에 실패했습니다.");
		}
	}

	private static Cipher cipher(int mode, String base64Key, byte[] iv) throws GeneralSecurityException {
		byte[] key = Base64.getDecoder().decode(base64Key.trim());
		if (key.length != 32) {
			throw new IllegalStateException("mail.crypto.key 는 32바이트 Base64 값이어야 합니다.");
		}
		Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
		cipher.init(mode, new SecretKeySpec(key, "AES"), new GCMParameterSpec(TAG_BITS, iv));
		return cipher;
	}
}
