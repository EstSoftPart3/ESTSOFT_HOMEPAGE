package com.eep.bo.equipment.service;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 프로젝트에 JUnit 이 없어 main 으로 확인한다. 값은 가짜다.
 * 실행: java -cp "target/classes;target/test-classes;target/est_eep/WEB-INF/lib/*" com.eep.bo.equipment.service.BoEquipmentServiceCheck
 */
public class BoEquipmentServiceCheck {

	public static void main(String[] args) {
		same(BoEquipmentService.normalizeNo(" ESTSW_EQPMNT-NB–006 "), "ESTSW-EQPMNT-NB-006", "번호 표기 통일");
		same(BoEquipmentService.suggestNo("MT", Arrays.asList("ESTSW-EQPMNT-MT-001", "ESTSW-EQPMNT-MT-003")), "ESTSW-EQPMNT-MT-002", "가장 작은 빈 번호");
		same(BoEquipmentService.suggestNo("KB", Collections.<String>emptyList()), "ESTSW-EQPMNT-KB-001", "장비가 없을 때");
		same(BoEquipmentService.suggestNo("NB", Arrays.asList("ESTSW-EQPMNT-NB-001", "ESTSW-EQPMNT-NB-002")), "ESTSW-EQPMNT-NB-003", "빈 번호가 없을 때");

		String ok = "data:image/png;base64,iVBORw0KGgo=";
		same(BoEquipmentService.validImage(ok, true), true, "PNG 서명");
		same(BoEquipmentService.validImage("data:image/jpeg;base64,AAAA", true), false, "서명은 PNG 만");
		same(BoEquipmentService.validImage("data:image/jpeg;base64,AAAA", false), true, "직인은 JPG 가능");
		same(BoEquipmentService.validImage("data:image/svg+xml;base64,AAAA", false), false, "SVG 거부");
		same(BoEquipmentService.validImage("data:image/png;base64,AA\"><script>", false), false, "속성 탈출 거부");
		same(BoEquipmentService.validImage(null, false), false, "빈 값 거부");

		Map<String, Object> r = new HashMap<>();
		r.put("HOLDER_NM", "홍길동");
		r.put("PHONE", "010-0000-0000");
		r.put("TYPE_CD", "NB");
		r.put("EQP_NO", "ESTSW-EQPMNT-NB-901");
		r.put("MODEL_NM", "EX-1");
		r.put("SERIAL_NO", "S1");
		r.put("START_DT", "2026-11-09");
		List<String> pages = BoEquipmentService.certificatePages(Arrays.asList(r, r), LocalDate.of(2026, 11, 9));
		same(pages.size(), 2, "장비당 1장");
		has(pages.get(0), "∎대여 장비 항목 : 노트북", "구분 이름");
		has(pages.get(0), "∎Product number : EX-1", "모델명");
		has(pages.get(0), "수리비를 책임져야 함에 동의 합니다.", "동의 문구");
		has(pages.get(0), "2026년 11월 9일", "서명일");
		System.out.println("BoEquipmentServiceCheck OK");
	}

	private static void same(Object actual, Object expected, String name) {
		if (!expected.equals(actual)) throw new AssertionError(name + ": " + actual);
	}

	private static void has(String text, String part, String name) {
		if (!text.contains(part)) throw new AssertionError(name);
	}
}
