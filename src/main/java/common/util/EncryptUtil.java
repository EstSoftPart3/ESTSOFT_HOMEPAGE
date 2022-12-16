package common.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * 
 * 암호화 관련 유틸
 * 
 * <pre>
 * est.common.util
 * EncryptUtil.java
 * </pre>
 * 
 * @Since 2019. 6. 4.
 * @Author SH KIM
 * 
 */
public class EncryptUtil {

	public static String getSha256Hash(String str) {

		String SHA = "";

		try {
			MessageDigest sh = MessageDigest.getInstance("SHA-256");
			sh.update(str.getBytes());
			byte byteData[] = sh.digest();
			StringBuffer sb = new StringBuffer();
			
			for (int i = 0; i < byteData.length; i++) {
				sb.append(Integer.toString((byteData[i] & 0xff) + 0x100, 16).substring(1));
			}
			
			SHA = sb.toString();
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
			SHA = str;
		}
		
		return SHA;

	}
}
