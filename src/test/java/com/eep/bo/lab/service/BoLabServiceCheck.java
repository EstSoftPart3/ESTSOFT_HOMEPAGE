package com.eep.bo.lab.service;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 프로젝트에 JUnit 이 없어 main 으로 확인한다.
 * 실행: java -cp "target/classes;target/test-classes;<spring-web, spring-core, commons-logging>" com.eep.bo.lab.service.BoLabServiceCheck
 */
public class BoLabServiceCheck {

	public static void main(String[] args) {
		// 결재 단계
		same(BoLabService.approverColumn("SUBMITTED"), "MANAGER_EMPLY_ID", "제출은 부서장이 결재");
		same(BoLabService.approverColumn("MANAGER_OK"), "CEO_EMPLY_ID", "부서장 확인 후 대표가 결재");
		same(BoLabService.approverColumn("DRAFT"), null, "작성 중은 결재 없음");
		same(BoLabService.approverColumn("CEO_OK"), null, "확정 후 결재 없음");
		same(BoLabService.afterApprove("SUBMITTED"), "MANAGER_OK", "제출 다음");
		same(BoLabService.afterApprove("MANAGER_OK"), "CEO_OK", "부서장 확인 다음");

		// 과제 기간 (달 단위, 첫 달과 끝 달 포함)
		same(BoLabService.inPeriod("2026-03", "2026-03-15", "2026-11-02"), true, "첫 달 포함");
		same(BoLabService.inPeriod("2026-11", "2026-03-15", "2026-11-02"), true, "끝 달 포함");
		same(BoLabService.inPeriod("2026-02", "2026-03-15", "2026-11-02"), false, "시작 전");
		same(BoLabService.inPeriod("2026-12", "2026-03-15", "2026-11-02"), false, "종료 후");

		// 폴더 주소
		same(BoLabService.folderId(" https://drive.google.com/drive/folders/abc_D-1?usp=sharing "), "abc_D-1", "주소에서 ID");
		same(BoLabService.folderId("abc_D-1"), "abc_D-1", "ID 그대로");
		try {
			BoLabService.folderId("a' or name != 'x");
			throw new AssertionError("잘못된 폴더 ID 를 받음");
		} catch (IllegalArgumentException expected) {
			System.out.println("ok  잘못된 폴더 ID 거부");
		}

		// PDF: 입력 이스케이프, 줄바꿈, 반려 후 다시 결재하면 마지막 기록
		Map<String, Object> j = new HashMap<>();
		j.put("YM", "2026-11");
		j.put("WRITER_NM", "작성자");
		j.put("PRJ_NM", "<script>alert(1)</script>");
		j.put("SNAP_MEMBERS", "홍길동(연구소장)");
		j.put("CONTENT", "첫 줄\n둘째 줄 & <b>");
		List<Map<String, Object>> h = Arrays.asList(row("SUBMIT", "작성자", "2026-11-09 10:00:00"), row("APPROVE_MANAGER", "옛부서장", "2026-11-09 11:00:00"),
				row("SUBMIT", "작성자", "2026-11-10 10:00:00"), row("APPROVE_MANAGER", "새부서장", "2026-11-10 11:00:00"), row("APPROVE_CEO", "대표", "2026-11-10 12:00:00"));
		String html = BoLabService.pdfHtml(j, h);
		yes(!html.contains("<script>") && html.contains("&lt;script&gt;"), "태그 이스케이프");
		yes(html.contains("첫 줄<br>둘째 줄 &amp; &lt;b&gt;"), "줄바꿈·특수문자");
		yes(html.contains("홍길동(연구소장)"), "한글 유지");
		yes(html.contains("새부서장") && !html.contains("옛부서장"), "마지막 결재자");
		yes(html.contains("2026-11-10 10:00:00") && !html.contains("2026-11-09 10:00:00"), "마지막 제출일");
		System.out.println("ALL OK");
	}

	private static Map<String, Object> row(String action, String nm, String dt) {
		Map<String, Object> m = new HashMap<>();
		m.put("ACTION_CD", action);
		m.put("ACTOR_NM", nm);
		m.put("REG_DT", dt);
		return m;
	}

	private static void same(Object a, Object b, String name) {
		if (a == null ? b != null : !a.equals(b)) throw new AssertionError(name + ": " + a + " != " + b);
		System.out.println("ok  " + name);
	}

	private static void yes(boolean v, String name) {
		same(v, true, name);
	}
}
