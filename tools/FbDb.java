import java.io.FileInputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

/**
 * 피드백·업데이트 내역 DB 도구(Claude 반자동 처리·배포 때 사용, plans/feedback-spec.html).
 * 접속 정보는 src/main/resources/config/db.properties 에서 읽고 출력하지 않는다. PC 의 hosts 에 mariadb 가 운영 서버로 잡혀 있어야 한다.
 *
 * 실행(프로젝트 폴더에서): java -cp "tools;<mariadb-java-client.jar>" FbDb <명령>
 *   new                         접수(NEW) 피드백을 줄마다 출력: FB_SQ | 화면 | 종류 | 요청자 | 내용 | 코멘트 수
 *                               (코멘트가 있으면 이미 기획서가 있던 건을 관리자가 코멘트로 되돌린 것 → comments 로 읽어 모두 반영해 다시 만든다)
 *   comments FB_SQ              그 피드백의 코멘트(오래된 것부터): 일시 | 누가 | 내용
 *   ing                         진행(ING) 피드백: FB_SQ | 화면 | 요청자 | 내용 | 개발 반영 내용
 *   spec FB_SQ 파일              파일의 @@PLAN·@@EST·@@HTML 을 기획서로 넣고 변경 로그에 남긴다. 접수(NEW)면 검토 대기로, 검토 대기·보류·진행 중이면 기획서만 바꿈
 *   update 파일                  업데이트 내역 1건 등록(@@TITLE @@SCREENS @@COMMIT @@FB_SQ @@CHANGED @@TESTS @@CAUTIONS @@HTML).
 *                               @@FB_SQ 가 있으면 그 피드백을 반영(DONE)으로 바꾸고 요청자 버튼에 숫자가 뜨게 한다
 * 파일은 UTF-8, '@@키' 줄 다음부터 다음 '@@' 줄 전까지가 값이다.
 */
public class FbDb {
	public static void main(String[] a) throws Exception {
		Properties p = new Properties();
		p.load(new FileInputStream("src/main/resources/config/db.properties"));
		Class.forName("org.mariadb.jdbc.Driver");
		try (Connection c = DriverManager.getConnection("jdbc:mariadb://mariadb:3306/est_eep_db?characterEncoding=UTF-8", p.getProperty("db.username"), p.getProperty("db.password"))) {
			switch (a[0]) {
				case "new": print(c, "SELECT F.FB_SQ, F.SCREEN_NM, F.KIND_CD, IFNULL(E.EMPLY_NM, F.EMPLY_ID), F.CONTENT, (SELECT COUNT(*) FROM TB_EEP_FEEDBACK_LOG L WHERE L.FB_SQ = F.FB_SQ AND L.LOG_CD = 'COMMENT') FROM TB_EEP_FEEDBACK_M F LEFT JOIN TB_EEP_EMPLY_M E ON E.EMPLY_ID = F.EMPLY_ID WHERE F.STATUS_CD = 'NEW' ORDER BY F.FB_SQ", 6); break;
				case "comments": comments(c, Integer.parseInt(a[1])); break;
				case "ing": print(c, "SELECT F.FB_SQ, F.SCREEN_NM, IFNULL(E.EMPLY_NM, F.EMPLY_ID), F.CONTENT, F.DEV_NOTE FROM TB_EEP_FEEDBACK_M F LEFT JOIN TB_EEP_EMPLY_M E ON E.EMPLY_ID = F.EMPLY_ID WHERE F.STATUS_CD = 'ING' ORDER BY F.FB_SQ", 5); break;
				case "spec": spec(c, Integer.parseInt(a[1]), read(a[2])); break;
				case "update": update(c, read(a[1])); break;
				default: throw new IllegalArgumentException("명령: new | comments FB_SQ | ing | spec FB_SQ 파일 | update 파일");
			}
		}
	}

	static void print(Connection c, String sql, int n) throws SQLException {
		try (ResultSet r = c.createStatement().executeQuery(sql)) {
			while (r.next()) {
				StringBuilder b = new StringBuilder();
				for (int i = 1; i <= n; i++) b.append(i > 1 ? " | " : "").append(String.valueOf(r.getString(i)).replace("\r", "").replace("\n", " ⏎ "));
				System.out.println(b);
			}
		}
	}

	static void spec(Connection c, int fbSq, Map<String, String> f) throws SQLException {
		// 접수 건은 검토 대기로. 검토 대기·보류·진행 중 건은 상태를 두고 기획서만 바꾼다(피드백 화면의 '다시 만들기').
		// 바뀐 기획서는 변경 로그(TB_EEP_FEEDBACK_LOG, SPEC)에도 남겨 피드백 화면의 '변경 로그' 탭에서 예전 것과 비교해 본다
		c.setAutoCommit(false);
		try (PreparedStatement s = c.prepareStatement("UPDATE TB_EEP_FEEDBACK_M SET PLAN_TXT = ?, EST_TXT = ?, SPEC_HTML = ?, STATUS_CD = IF(STATUS_CD = 'NEW', 'REVIEW', STATUS_CD) WHERE FB_SQ = ? AND STATUS_CD IN ('NEW', 'REVIEW', 'HOLD', 'ING')");
				PreparedStatement l = c.prepareStatement("INSERT INTO TB_EEP_FEEDBACK_LOG (FB_SQ, LOG_CD, PLAN_TXT, EST_TXT, SPEC_HTML, EMPLY_ID) VALUES (?, 'SPEC', ?, ?, ?, 'CLAUDE')")) {
			s.setString(1, f.get("PLAN")); s.setString(2, f.get("EST")); s.setString(3, f.get("HTML")); s.setInt(4, fbSq);
			int n = s.executeUpdate();
			if (n == 1) {
				l.setInt(1, fbSq); l.setString(2, f.get("PLAN")); l.setString(3, f.get("EST")); l.setString(4, f.get("HTML"));
				l.executeUpdate();
			}
			c.commit();
			System.out.println("spec " + fbSq + " → " + n);
		} catch (SQLException e) {
			c.rollback();
			throw e;
		}
	}

	/** 그 피드백의 코멘트(오래된 것부터): 일시 | 누가 | 내용. 기획서를 다시 만들 때 모두 반영한다 */
	static void comments(Connection c, int fbSq) throws SQLException {
		print(c, "SELECT DATE_FORMAT(L.REG_DT, '%m-%d %H:%i'), IFNULL(E.EMPLY_NM, L.EMPLY_ID), L.CONTENT FROM TB_EEP_FEEDBACK_LOG L LEFT JOIN TB_EEP_EMPLY_M E ON E.EMPLY_ID = L.EMPLY_ID WHERE L.FB_SQ = " + fbSq + " AND L.LOG_CD = 'COMMENT' ORDER BY L.LOG_SQ", 3);
	}

	static void update(Connection c, Map<String, String> f) throws SQLException {
		require(f.get("TITLE") != null && !f.get("TITLE").isEmpty(), "@@TITLE 이 필요합니다.");
		String fb = f.get("FB_SQ");
		c.setAutoCommit(false);
		try (PreparedStatement s = c.prepareStatement("INSERT INTO TB_EEP_UPDATE_H (TITLE, SCREENS, CHANGED_TXT, TESTS_TXT, CAUTIONS_TXT, SPEC_HTML, COMMIT_ID, FB_SQ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", Statement.RETURN_GENERATED_KEYS)) {
			s.setString(1, f.get("TITLE")); s.setString(2, f.get("SCREENS")); s.setString(3, f.get("CHANGED")); s.setString(4, f.get("TESTS"));
			s.setString(5, f.get("CAUTIONS")); s.setString(6, f.get("HTML")); s.setString(7, f.get("COMMIT"));
			if (fb == null || fb.isEmpty()) s.setNull(8, Types.INTEGER); else s.setInt(8, Integer.parseInt(fb));
			s.executeUpdate();
			ResultSet k = s.getGeneratedKeys();
			k.next();
			int upd = k.getInt(1);
			if (fb != null && !fb.isEmpty()) {
				try (PreparedStatement u = c.prepareStatement("UPDATE TB_EEP_FEEDBACK_M SET STATUS_CD = 'DONE', UPD_SQ = ?, SEEN_YN = 'N' WHERE FB_SQ = ?")) {
					u.setInt(1, upd); u.setInt(2, Integer.parseInt(fb));
					require(u.executeUpdate() == 1, "피드백 " + fb + " 이 없습니다.");
				}
			}
			c.commit();
			System.out.println("update " + upd + (fb == null || fb.isEmpty() ? "" : " (피드백 " + fb + " 반영)"));
		} catch (RuntimeException | SQLException e) {
			c.rollback();
			throw e;
		}
	}

	static Map<String, String> read(String path) throws Exception {
		Map<String, String> m = new HashMap<>();
		String key = null;
		StringBuilder v = new StringBuilder();
		for (String line : new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8).replace("﻿", "").replace("\r", "").split("\n", -1)) {
			if (line.startsWith("@@")) {
				if (key != null) m.put(key, v.toString().trim());
				key = line.substring(2).trim();
				v.setLength(0);
			} else if (key != null) {
				v.append(line).append('\n');
			}
		}
		if (key != null) m.put(key, v.toString().trim());
		return m;
	}

	static void require(boolean ok, String msg) {
		if (!ok) throw new IllegalArgumentException(msg);
	}
}
