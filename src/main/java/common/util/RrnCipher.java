package common.util;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Properties;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Base64;

/**
 * 직원 주민등록번호(TB_EEP_EMPLY_M.EMPLY_RRN)는 AES-256-GCM 으로 암호화해 저장하고, 화면에는 뒷자리를 가려 보여 준다.
 * 저장 형식: "enc:v1:" + base64(IV 12바이트 + 암호문 + 태그 16바이트).
 * 키는 config/db.properties 의 rrn.key (base64 32바이트). 키를 잃으면 복호화할 수 없다.
 */
public final class RrnCipher {

	public static final String PREFIX = "enc:v1:";
	private static final SecureRandom RANDOM = new SecureRandom();
	private static volatile byte[] key;

	private RrnCipher() {}

	public static boolean isEncrypted(String value) {
		return value != null && value.startsWith(PREFIX);
	}

	public static String encrypt(String plain) {
		return encrypt(plain, key());
	}

	public static String decrypt(String stored) {
		return decrypt(stored, key());
	}

	/** 저장값을 복호화해 "900101-*******" 형태로 가린다. 빈 값은 그대로 돌려준다. */
	public static String maskStored(String stored) {
		if (stored == null || stored.isEmpty()) {
			return stored;
		}
		try {
			return mask(isEncrypted(stored) ? decrypt(stored) : stored);
		} catch (RuntimeException e) {
			return "(복호화 실패)";
		}
	}

	public static String mask(String plain) {
		String digits = plain.replaceAll("[^0-9]", "");
		return digits.length() < 6 ? "*******" : digits.substring(0, 6) + "-*******";
	}

	/** 계좌번호처럼 끝 4자리만 보여 줄 값: "******1234". 저장값(암호문·평문 모두)을 받는다 */
	public static String maskTailStored(String stored) {
		if (stored == null || stored.isEmpty()) {
			return stored;
		}
		try {
			String digits = (isEncrypted(stored) ? decrypt(stored) : stored).replaceAll("[^0-9]", "");
			return digits.length() <= 4 ? "****" : "******" + digits.substring(digits.length() - 4);
		} catch (RuntimeException e) {
			return "(복호화 실패)";
		}
	}

	/** 화면에서 가린 값이 그대로 돌아온 것인지. 이 경우 저장값을 바꾸지 않는다. */
	public static boolean isMasked(String value) {
		return value != null && (value.contains("*") || value.startsWith("("));
	}

	static String encrypt(String plain, byte[] k) {
		try {
			byte[] iv = new byte[12];
			RANDOM.nextBytes(iv);
			Cipher c = Cipher.getInstance("AES/GCM/NoPadding");
			c.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(k, "AES"), new GCMParameterSpec(128, iv));
			byte[] ct = c.doFinal(plain.getBytes(StandardCharsets.UTF_8));
			byte[] out = new byte[iv.length + ct.length];
			System.arraycopy(iv, 0, out, 0, iv.length);
			System.arraycopy(ct, 0, out, iv.length, ct.length);
			return PREFIX + Base64.encodeBase64String(out);
		} catch (Exception e) {
			throw new IllegalStateException("주민번호 암호화 실패", e);
		}
	}

	static String decrypt(String stored, byte[] k) {
		try {
			byte[] in = Base64.decodeBase64(stored.substring(PREFIX.length()));
			Cipher c = Cipher.getInstance("AES/GCM/NoPadding");
			c.init(Cipher.DECRYPT_MODE, new SecretKeySpec(k, "AES"), new GCMParameterSpec(128, in, 0, 12));
			return new String(c.doFinal(in, 12, in.length - 12), StandardCharsets.UTF_8);
		} catch (Exception e) {
			throw new IllegalStateException("주민번호 복호화 실패", e);
		}
	}

	private static byte[] key() {
		if (key == null) {
			synchronized (RrnCipher.class) {
				if (key == null) {
					key = loadKey();
				}
			}
		}
		return key;
	}

	private static byte[] loadKey() {
		Properties p = new Properties();
		try (InputStream in = RrnCipher.class.getClassLoader().getResourceAsStream("config/db.properties")) {
			if (in == null) {
				throw new IllegalStateException("config/db.properties 가 없다");
			}
			p.load(in);
		} catch (java.io.IOException e) {
			throw new IllegalStateException("config/db.properties 를 읽지 못했다", e);
		}
		String b64 = p.getProperty("rrn.key", "").trim();
		byte[] k = Base64.decodeBase64(b64);
		if (k.length != 32) {
			throw new IllegalStateException("db.properties 의 rrn.key 는 base64 32바이트여야 한다");
		}
		return k;
	}
}
