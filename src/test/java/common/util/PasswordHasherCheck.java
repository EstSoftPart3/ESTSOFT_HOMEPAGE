package common.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 프로젝트에 JUnit 이 없어 main 으로 확인한다.
 * 실행: java -cp "target/classes;target/test-classes;<jbcrypt jar>" common.util.PasswordHasherCheck
 */
public class PasswordHasherCheck {

	public static void main(String[] args) {
		String h = PasswordHasher.hash("abc123!");
		check(h.startsWith("$2a$10$") && h.length() == 60, "해시 형식");
		check(PasswordHasher.matches("abc123!", h), "맞는 비밀번호");
		check(!PasswordHasher.matches("abc123", h), "틀린 비밀번호");
		check(!PasswordHasher.matches("", h), "빈 비밀번호");
		check(!PasswordHasher.matches("abc123!", "abc123!"), "평문 저장값은 거부");
		check(!PasswordHasher.matches("abc123!", null), "null 저장값은 거부");

		// 서버 python bcrypt 로 만든 $2b$ 해시를 $2a$ 로 바꿔 저장한다. 값: "test-pw"
		String fromPython = "$2a$10$SjEWgG/hjgVQGw/ANX7H2eqLJVBPEQal3HKrH2zXIBE/k9/YzFLgi";
		check(PasswordHasher.matches("test-pw", fromPython), "python 해시 호환");

		List<Map<String, Object>> rows = new ArrayList<>();
		Map<String, Object> row = new HashMap<>();
		row.put("emplyId", "u1");
		row.put(PasswordHasher.HASH_KEY, h);
		rows.add(row);
		List<Map<String, Object>> ok = PasswordHasher.keepMatched(rows, "abc123!");
		check(ok.size() == 1 && !ok.get(0).containsKey(PasswordHasher.HASH_KEY), "일치 행만 남고 해시 제거");
		row.put(PasswordHasher.HASH_KEY, h);
		check(PasswordHasher.keepMatched(rows, "wrong").isEmpty(), "불일치 행 제거");
		System.out.println("PasswordHasherCheck OK");
	}

	private static void check(boolean ok, String name) {
		if (!ok) {
			throw new AssertionError(name);
		}
	}
}
