package com.eep.bo.staff.service;

import java.util.HashMap;
import java.util.Map;

/**
 * 프로젝트에 JUnit 이 없어 main 으로 확인한다.
 * 실행: java -cp "target/classes;target/test-classes;target/est_eep/WEB-INF/lib/*" com.eep.bo.staff.service.StaffPrjCheck
 */
public class StaffPrjCheck {

	public static void main(String[] args) {
		Map<String, Object> ok = valid();
		ok.put("PRJ_NM", "  포털 구축 ");
		BoStaffService.checkPrj(ok);
		check("포털 구축".equals(ok.get("PRJ_NM")) && "".equals(ok.get("ETC_NM")), "값 다듬기");

		Map<String, Object> ongoing = valid();
		ongoing.remove("END_YM");
		ongoing.put("ONGOING_YN", "Y");
		BoStaffService.checkPrj(ongoing);
		check(ongoing.get("END_YM") == null, "진행중이면 종료월 없음");

		for (String f : new String[] { "PRJ_NM", "CLIENT_NM", "ROLE_NM", "START_YM", "WORK_NM", "END_YM" }) {
			Map<String, Object> m = valid();
			m.put(f, " ");
			rejected(m, f + " 빈 값");
		}
		rejected(with("ROLE_NM", "PM"), "없는 역할");
		rejected(with("START_YM", "2024-13"), "없는 달");
		rejected(with("END_YM", "2023-12"), "종료월이 시작월보다 빠름");
		BoStaffService.checkPrj(with("END_YM", "2024-01"));
		Map<String, Object> edu = item("EDU", "대학교(4년제)", " 가나대 ");
		edu.put("C5", "졸업");
		BoStaffService.checkItem(edu);
		check("가나대".equals(edu.get("C2")) && "".equals(edu.get("C3")), "항목 값 다듬기");
		BoStaffService.checkItem(item("EDU", "사이버·방통대·학점은행제", "가나사이버대"));
		BoStaffService.checkItem(item("TRAIN", "자바 과정", ""));
		BoStaffService.checkItem(item("EMG", "배우자", "010-0000-0000"));
		rejectedItem(item("NOPE", "a", "b"), "없는 항목");
		rejectedItem(item("EDU", "대학교", "가나대"), "없는 구분");
		rejectedItem(item("EDU", "대학교(4년제)", " "), "학교명 없음");
		rejectedItem(item("TRAIN", " ", "기관"), "교육명 없음");
		rejectedItem(item("EMG", "배우자", ""), "연락처 없음");
		Map<String, Object> badState = item("EDU", "대학교(4년제)", "가나대");
		badState.put("C5", "졸업예정");
		rejectedItem(badState, "없는 상태");
		System.out.println("StaffPrjCheck OK");
	}

	private static Map<String, Object> valid() {
		Map<String, Object> m = new HashMap<>();
		m.put("PRJ_NM", "포털");
		m.put("CLIENT_NM", "샘플은행");
		m.put("ROLE_NM", "운영/개발");
		m.put("START_YM", "2024-01");
		m.put("END_YM", "2024-03");
		m.put("WORK_NM", "유지보수");
		return m;
	}

	private static Map<String, Object> with(String k, String v) {
		Map<String, Object> m = valid();
		m.put(k, v);
		return m;
	}

	private static void rejected(Map<String, Object> m, String label) {
		try {
			BoStaffService.checkPrj(m);
		} catch (IllegalArgumentException e) {
			return;
		}
		throw new AssertionError(label);
	}

	private static Map<String, Object> item(String cd, String c1, String c2) {
		Map<String, Object> m = new HashMap<>();
		m.put("ITEM_CD", cd);
		m.put("C1", c1);
		m.put("C2", c2);
		return m;
	}

	private static void rejectedItem(Map<String, Object> m, String label) {
		try {
			BoStaffService.checkItem(m);
		} catch (IllegalArgumentException e) {
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
