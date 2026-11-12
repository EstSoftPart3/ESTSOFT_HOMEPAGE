package com.eep.bo.lab.service;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

/**
 * 프로젝트에 JUnit 이 없어 main 으로 확인한다.
 * 실행: java -cp "target/classes;target/test-classes;target/est_eep/WEB-INF/lib/*" com.eep.bo.lab.service.BoLabServiceCheck
 */
public class BoLabServiceCheck {

	/** 1x1 투명 PNG */
	private static final String PNG = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==";

	public static void main(String[] args) {
		// 결재라인 검사
		HashSet<String> admins = new HashSet<>(Arrays.asList("hong", "ceo", "lee"));
		same(BoLabService.checkSteps(new String[] { " 부서장 ", "대표" }, new String[] { "hong", "ceo" }, admins).get(0)[0], "부서장", "단계명 공백 정리");
		same(BoLabService.checkSteps(null, null, admins).size(), 0, "빈 결재라인 허용");
		fails(() -> BoLabService.checkSteps(new String[] { "부서장", "대표" }, new String[] { "hong", "hong" }, admins), "같은 계정 두 번");
		fails(() -> BoLabService.checkSteps(new String[] { "부서장" }, new String[] { "nobody" }, admins), "관리자 아닌 계정");
		fails(() -> BoLabService.checkSteps(new String[] { " " }, new String[] { "hong" }, admins), "빈 단계명");
		fails(() -> BoLabService.checkSteps(new String[] { "a" }, new String[] { "hong", "ceo" }, admins), "개수 불일치");
		fails(() -> BoLabService.checkSteps(new String[6], new String[6], admins), "6단계 초과");

		// 과제 기간 (달 단위, 첫 달과 끝 달 포함)
		same(BoLabService.inPeriod("2026-03", "2026-03-15", "2026-11-02"), true, "첫 달 포함");
		same(BoLabService.inPeriod("2026-12", "2026-03-15", "2026-11-02"), false, "종료 후");

		// 폴더 주소
		same(BoLabService.folderId(" https://drive.google.com/drive/folders/abc_D-1?usp=sharing "), "abc_D-1", "주소에서 ID");
		fails(() -> BoLabService.folderId("a' or name != 'x"), "잘못된 폴더 ID");

		// 서명 이미지와 에디터 빈 내용
		BoLabService.checkSign(PNG);
		for (String bad : new String[] { null, "", "data:image/svg+xml;base64,PHN2Zz4=", "data:image/png;base64,AAAA", "data:image/png;base64,\"><script>" }) {
			fails(() -> BoLabService.checkSign(bad), "잘못된 서명 " + bad);
		}
		same(BoLabService.isBlankHtml("<p>&nbsp;</p><br>"), true, "에디터 빈 내용");

		// 담당자 항목 요약: hwp 에서 옮긴 형식 두 가지
		String hwp = "<p>[공통]</p><p>comm_ui001 - CommonHeader.tsx - 2단 구성</p><p>담당자: 백바울 연구소장</p><p>기간: 9월</p>"
				+ "<p>salary001 - 연봉 계산 입력 6종</p><p>담당자: 정영우 연구원</p><p>main_p001 - 배너 축소</p><p>담당자: 백바울 연구소장</p>"
				+ "<p>- 입사지원 로직 (이정수 연구원, 12월 1일 ~ 12월 31일)</p><p>- 추천 공고 (이정수 연구원)</p><p>- 기타 (이정수라, 12월)</p>";
		same(BoLabService.workItems(hwp, "백바울"), Arrays.asList("2단 구성", "배너 축소"), "담당자 줄 형식, 코드·파일명 제거");
		same(BoLabService.workItems(hwp, "정영우"), Arrays.asList("연봉 계산 입력 6종"), "다른 사람 항목 제외");
		same(BoLabService.cleanItem("auth_ui001 - LoginForm.tsx - 개인/기업 전용 경로 분리(?loginType=COMPANY), 탭 토글 제거"), "개인/기업 전용 경로 분리, 탭 토글 제거", "코드 괄호 제거");
		same(BoLabService.cleanItem("comm_ui001 - CommonHeader.tsx - 1단(로고) + 2단(전체 네비) 구성"), "1단(로고) + 2단(전체 네비) 구성", "설명 괄호 유지");
		same(BoLabService.cleanItem("vote003 - 중복 투표 DB 차단(TBL_VOTE_RECORD_S UNIQUE)"), "중복 투표 DB 차단", "테이블명 괄호 제거");
		same(BoLabService.cleanItem("vote003 - 중복 투표 DB 차단（TBL_VOTE_RECORD_S UNIQUE）"), "중복 투표 DB 차단", "전각 괄호 제거");
		same(BoLabService.workItems("<p>tooltip001 - tooltip.tsx</p><p>담당자: 백바울</p><p>기간: 9월</p><p>내용: 툴팁이 열리지 않던 오류를 고쳤습니다.</p>", "백바울"),
				Arrays.asList("툴팁이 열리지 않던 오류를 고쳤습니다."), "제목이 코드뿐이면 내용 문장");
		same(BoLabService.workItems(hwp, "이정수"), Arrays.asList("입사지원 로직", "추천 공고"), "괄호 이름 형식, 비슷한 이름 제외");
		same(BoLabService.workItems(hwp, "이슬이").size(), 0, "담당 없음");
		String mail = BoLabService.mailHtml("<b>홍</b>", "2026-10", "과제 & A", Arrays.asList("<script>x</script>"));
		yes(!mail.contains("<script>") && mail.contains("&lt;b&gt;홍") && mail.contains("과제 &amp; A"), "메일 본문 이스케이프");

		// PDF: 단계 수만큼 결재란, 서명, 마감, 에디터 서식 유지
		Map<String, Object> j = new HashMap<>();
		j.put("YM", "2026-11");
		j.put("WRITER_NM", "작성자");
		j.put("PRJ_NM", "<script>alert(1)</script>");
		j.put("SNAP_MEMBERS", "홍길동(연구소장)");
		j.put("CONTENT", "<p><b>첫 줄</b></p><table><tr><td>칸</td></tr></table>");
		List<Map<String, Object>> steps = Arrays.asList(step("부서장", "홍길동", PNG), step("검토", "이부장", PNG), step("대표", "김대표", ""));
		List<Map<String, Object>> h = Arrays.asList(row("SUBMIT", "작성자", "2026-11-09 10:00:00"), row("SUBMIT", "작성자", "2026-11-10 10:00:00"), row("CLOSE", "연구소장", "2026-11-12 09:00:00"));
		String html = BoLabService.pdfHtml(j, steps, h);
		yes(!html.contains("<script>") && html.contains("&lt;script&gt;"), "태그 이스케이프");
		yes(html.contains("<p><b>첫 줄</b></p><table>"), "에디터 서식 유지");
		yes(html.split("<img src=\"" + PNG.replace("+", "\\+") + "\"", -1).length == 3, "서명 2개");
		yes(html.contains(">검토<") && html.contains(">대표<"), "단계 이름 열");
		yes(html.contains("연구소장 (2026-11-12 09:00:00)"), "마감 기록");
		yes(html.contains("2026-11-10 10:00:00") && !html.contains("2026-11-09 10:00:00"), "마지막 제출일");
		System.out.println("ALL OK");
	}

	private static Map<String, Object> step(String nm, String done, String sign) {
		Map<String, Object> m = new HashMap<>();
		m.put("STEP_NM", nm);
		m.put("DONE_NM", done);
		m.put("DONE_DT", "2026-11-11 10:00:00");
		m.put("SIGN_IMG", sign);
		return m;
	}

	private static Map<String, Object> row(String action, String nm, String dt) {
		Map<String, Object> m = new HashMap<>();
		m.put("ACTION_CD", action);
		m.put("ACTOR_NM", nm);
		m.put("REG_DT", dt);
		return m;
	}

	private static void fails(Runnable r, String name) {
		try {
			r.run();
			throw new AssertionError(name + ": 거부해야 함");
		} catch (IllegalArgumentException expected) {
			System.out.println("ok  " + name + " 거부");
		}
	}

	private static void same(Object a, Object b, String name) {
		if (a == null ? b != null : !a.equals(b)) throw new AssertionError(name + ": " + a + " != " + b);
		System.out.println("ok  " + name);
	}

	private static void yes(boolean v, String name) {
		same(v, true, name);
	}
}
