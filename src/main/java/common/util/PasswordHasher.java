package common.util;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.mindrot.jbcrypt.BCrypt;

/** 직원 비밀번호(TB_EEP_EMPLY_M.EMPLY_PW)는 bcrypt 해시로만 저장하고 비교한다. */
public final class PasswordHasher {

	/** 로그인 쿼리가 비교용으로 함께 돌려주는 해시 컬럼 이름. 응답·세션에 남기지 않는다. */
	public static final String HASH_KEY = "emplyPwHash";

	private PasswordHasher() {}

	public static String hash(String raw) {
		return BCrypt.hashpw(raw, BCrypt.gensalt(10));
	}

	public static boolean matches(String raw, String hash) {
		if (raw == null || raw.isEmpty() || hash == null || !hash.startsWith("$2a$")) {
			return false;
		}
		try {
			return BCrypt.checkpw(raw, hash);
		} catch (IllegalArgumentException e) {
			return false;
		}
	}

	/** 아이디로 조회한 행 중 비밀번호가 맞는 것만 남기고, 해시 컬럼은 지운다. */
	public static List<Map<String, Object>> keepMatched(List<Map<String, Object>> rows, String raw) {
		List<Map<String, Object>> matched = new ArrayList<>();
		if (rows == null) {
			return matched;
		}
		for (Map<String, Object> row : rows) {
			Object hash = row.remove(HASH_KEY);
			if (matches(raw, hash == null ? null : hash.toString())) {
				matched.add(row);
			}
		}
		return matched;
	}
}
