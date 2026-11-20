package com.eep.bo.staff.service;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 프로젝트에 JUnit 이 없어 main 으로 확인한다. 값은 모두 가짜다.
 * 실행: java -cp "target/classes;target/test-classes;target/est_eep/WEB-INF/lib/*" com.eep.bo.staff.service.StaffPrjCheck
 */
public class StaffPrjCheck {

	public static void main(String[] args) throws Exception {
		// 입력값 다듬기
		Map<String, Object> ok = valid();
		ok.put("PRJ_NM", "  포털 구축 ");
		ok.put("LANG_NM", "Java,  JSP\nJava");
		Map<String, Object> row = StaffCareerService.clean(ok);
		check("포털 구축".equals(row.get("PRJ_NM")) && "Java, JSP".equals(row.get("LANG_NM")) && row.get("ETC_NM") == null, "값 다듬기·여러 값 합치기");
		Map<String, Object> ongoing = valid();
		ongoing.remove("END_YM");
		ongoing.put("ONGOING_YN", "Y");
		check(StaffCareerService.clean(ongoing).get("END_YM") == null, "진행중이면 종료월 없음");
		rejected(with("PRJ_NM", " "), "프로젝트명 없음");
		rejected(with("START_YM", "2024-13"), "없는 달");
		rejected(with("END_YM", ""), "종료월 없음");
		rejected(with("END_YM", "2023-12"), "종료월이 시작월보다 빠름");
		check("PL, 분석, 개발".equals(StaffCareerService.clean(with("ROLE_NM", "PL,분석, 개발")).get("ROLE_NM")), "역할 여러 개");

		// 사내 투입 묶기: 같은 고객사·프로젝트가 이어지면 한 줄, 떨어지면 따로
		List<Map<String, Object>> groups = StaffCareerService.mergeDeploys(Arrays.asList(dep(1, "가은행", "포털", "2025-03-03", "2025-05-31"), dep(2, "가은행", "포털", "2025-06-01", null),
				dep(3, "나공단", "민원", "2023-01-02", "2023-06-30"), dep(4, "나공단", "민원", "2024-01-02", "2024-03-31")));
		check(groups.size() == 3, "투입 묶음 3개: " + groups.size());
		check(groups.get(0).get("END_DT") == null && ((List<?>) groups.get(0).get("SQS")).size() == 2, "이어지는 투입은 한 줄·진행중");

		// 합치기: 투입에 보탠 줄은 그 투입 줄에 붙고, 이름·기간은 투입현황을 따른다
		Map<String, Object> linked = prj(10, "옛 이름", "2020-01", "2020-02", "Java");
		linked.put("DEPLOY_SQ", 2);
		List<Map<String, Object>> items = StaffCareerService.merge(new ArrayList<>(Arrays.asList(linked, prj(11, "보험 고도화", "2017-11", "2018-04", "Java, Oracle"))), groups);
		check(items.size() == 4, "합친 줄 4개: " + items.size());
		Map<String, Object> top = items.get(0);
		check("포털".equals(top.get("PRJ_NM")) && "2025-03".equals(top.get("START_YM")) && top.get("END_YM") == null && "Java".equals(top.get("LANG_NM")) && "DEPLOY".equals(top.get("SRC")), "진행중 투입이 맨 위·보탠 개발환경 유지");
		check("PRJ".equals(items.get(3).get("SRC")) && "보험 고도화".equals(items.get(3).get("PRJ_NM")), "직접 입력한 줄은 최근순 뒤");

		// 버전 비교: 같으면 null(버전 안 올라감), 다르면 요약
		List<Map<String, Object>> snap = StaffCareerService.parse(StaffCareerService.json(StaffCareerService.snapshot(items)));
		check(StaffCareerService.diff(snap, items) == null, "저장한 그대로면 바뀐 것 없음");
		List<Map<String, Object>> changed = new ArrayList<>(items);
		Map<String, Object> edited = new HashMap<>(items.get(3));
		edited.put("ROLE_NM", "PL, 개발");
		changed.set(3, edited);
		changed.add(prj(12, "새 프로젝트", "2026-01", "2026-03", ""));
		String diff = StaffCareerService.diff(snap, changed);
		check(diff != null && diff.contains("추가 1") && diff.contains("수정 1") && !diff.contains("삭제"), "달라진 점 요약: " + diff);
		check(StaffCareerService.diff(snap, changed.subList(0, 3)).contains("삭제 1"), "삭제 요약");
		edited.put("ROLE_NM", items.get(3).get("ROLE_NM"));
		check(StaffCareerService.diff(snap, changed.subList(0, 4)) == null, "고쳤다가 되돌리면 바뀐 것 없음");
		check(StaffCareerService.changes(items.get(3), with(items.get(3), "TOOL_NM", "Eclipse")).equals("TOOL +Eclipse"), "달라진 칸 글");

		// 워드: 만든 파일을 다시 읽으면 같은 프로젝트가 나온다
		Map<String, String> info = new HashMap<>();
		info.put("성명", "홍길동");
		byte[] docx = StaffCareerWord.build(info, Collections.<String[]> emptyList(), Collections.<String[]> emptyList(), Collections.<String[]> emptyList(), items);
		List<Map<String, Object>> read = StaffCareerWord.parse(new ByteArrayInputStream(docx));
		check(read.size() == items.size(), "워드 왕복 줄 수: " + read.size());
		Map<String, Object> first = read.get(0); // 워드는 오래된 것부터
		check("보험 고도화".equals(first.get("PRJ_NM")) && "2017-11".equals(first.get("START_YM")) && "2018-04".equals(first.get("END_YM")) && "Java, Oracle".equals(first.get("LANG_NM")), "워드 왕복 값: " + first);
		check("".equals(read.get(read.size() - 1).get("END_YM")), "워드의 '현재'는 진행중");
		// 증명사진: 첫 표 5번째 칸에 그림 1개, 프로젝트 줄은 그대로
		java.io.ByteArrayOutputStream png = new java.io.ByteArrayOutputStream();
		javax.imageio.ImageIO.write(new java.awt.image.BufferedImage(30, 40, java.awt.image.BufferedImage.TYPE_INT_RGB), "png", png);
		byte[] withPhoto = StaffCareerWord.build(info, Collections.<String[]> emptyList(), Collections.<String[]> emptyList(), Collections.<String[]> emptyList(), items, new Object[] { "png", png.toByteArray() });
		try (org.apache.poi.xwpf.usermodel.XWPFDocument d = new org.apache.poi.xwpf.usermodel.XWPFDocument(new ByteArrayInputStream(withPhoto))) {
			check(d.getAllPictures().size() == 1 && d.getTables().get(0).getRow(0).getTableCells().size() == 5, "워드 증명사진 칸");
			check(!d.getTables().get(0).getRow(0).getCell(4).getText().contains("PHOTO"), "사진 표시 글자가 남지 않음");
		}
		check(StaffCareerWord.parse(new ByteArrayInputStream(withPhoto)).size() == items.size(), "사진 넣어도 프로젝트 줄 수 같음");
		// 면접 교육용 샘플: 두 쪽 모두 「실제 경력이 아니며」 표시, 프로젝트 줄은 그대로 읽힘
		Map<String, String> sampleInfo = new HashMap<>(info);
		sampleInfo.put(StaffCareerWord.SAMPLE, "Y");
		byte[] sampleDoc = StaffCareerWord.build(sampleInfo, Collections.<String[]> emptyList(), Collections.<String[]> emptyList(), Collections.<String[]> emptyList(), items);
		try (org.apache.poi.xwpf.usermodel.XWPFDocument d = new org.apache.poi.xwpf.usermodel.XWPFDocument(new ByteArrayInputStream(sampleDoc))) {
			long notes = d.getParagraphs().stream().filter(p -> p.getText().contains("실제 경력이 아니며")).count();
			check(notes == 2, "샘플 표시 두 곳: " + notes);
		}
		check(StaffCareerWord.parse(new ByteArrayInputStream(sampleDoc)).size() == items.size(), "샘플도 프로젝트 줄 수 같음");

		// 자동생성 자리 맞추기: 전체 값 > 2단계 이름 > 1단계 이름
		check(StaffCareerService.tagScore(Arrays.asList("금융 > 은행"), "금융 > 은행") == 3 && StaffCareerService.tagScore(Arrays.asList("금융>은행"), "금융 > 은행") == 3, "자리: 전체 값");
		check(StaffCareerService.tagScore(Arrays.asList("은행"), "금융 > 은행") == 2 && StaffCareerService.tagScore(Arrays.asList("금융"), "금융 > 은행") == 1, "자리: 2단계·1단계 이름");
		check(StaffCareerService.tagScore(Arrays.asList("금융 > 증권"), "금융 > 은행") == 1 && StaffCareerService.tagScore(Arrays.asList("공공"), "금융 > 은행") == 0, "자리: 다른 2단계는 1단계만큼, 다른 산업은 0");
		check(StaffCareerService.tagScore(Arrays.asList("금융 > 은행"), "금융") == 3, "자리: 1단계만 고르면 그 아래 다 맞음");
		// 기간 조정은 실제 기간 안에서만
		Map<String, Object> per = new HashMap<>();
		per.put("ORIG_START", "2020-01");
		per.put("ORIG_END", "2022-12");
		StaffCareerService.narrow(per, "2021-03", "2022-06");
		check("2021-03".equals(per.get("START_YM")) && "2022-06".equals(per.get("END_YM")), "기간: 안쪽으로 좁힘");
		StaffCareerService.narrow(per, "2019-01", "2024-01");
		check("2020-01".equals(per.get("START_YM")) && "2022-12".equals(per.get("END_YM")), "기간: 밖으로는 못 늘림");
		StaffCareerService.narrow(per, "2022-05", "2021-01");
		check("2022-05".equals(per.get("START_YM")) && "2022-12".equals(per.get("END_YM")), "기간: 끝이 시작보다 빠르면 실제 끝");
		// 배치: 금융 > 은행 두 자리 → 은행 프로젝트 두 줄, 세 번째 자리는 못 채움, 고정 줄은 그 자리
		List<Map<String, Object>> all = new ArrayList<>();
		String[][] ps = { { "A", "공공" }, { "B", "금융 > 은행" }, { "C", "금융" }, { "D", "은행" }, { "E", "제조" } };
		for (String[] x : ps) {
			Map<String, Object> m = new HashMap<>();
			m.put("PRJ_NM", x[0]);
			m.put("IND_NM", x[1]);
			m.put("KEY", x[0]);
			m.put("ORIG_START", "2020-01");
			m.put("ORIG_END", "2020-12");
			all.add(m);
		}
		Map<String, Object> conf = new HashMap<>();
		List<Map<String, Object>> slots = new ArrayList<>();
		for (int i = 0; i < 3; i++) slots.add(kv("t", "IND", "v", "금융 > 은행"));
		conf.put("slots", slots);
		conf.put("pins", Arrays.asList(kv("key", "E", "pos", 0, "start", "2020-03", "end", "2020-06")));
		List<Map<String, Object>> ar = StaffCareerService.arrange(all, new ArrayList<>(all), conf, 4);
		check("EBDC".equals(names(ar)), "배치(고정 E 맨 앞, 은행 B·D, 세 번째 자리는 1단계 금융 C): " + names(ar));
		check("2020-03".equals(ar.get(0).get("START_YM")) && "Y".equals(ar.get(0).get("PIN")), "고정 줄 기간");
		slots.add(kv("t", "IND", "v", "의료 > 병원"));
		ar = StaffCareerService.arrange(all, new ArrayList<>(all), conf, 10);
		check("EBDC_".equals(names(ar)), "자리를 고르면 고른 자리(+고정)만, 못 채운 자리는 빈칸: " + names(ar));
		conf.remove("slots");
		ar = StaffCareerService.arrange(all, new ArrayList<>(all), conf, 3);
		check("EAB".equals(names(ar)), "자리를 안 고르면 횟수만큼 순서대로(고정 E 포함 3줄): " + names(ar));
		check("금융 > 은행".equals(StaffCareerService.codeName(" 금융>은행 ")), "코드 이름 다듬기");
		check("Spring Boot".equals(StaffCareerService.techName("  Spring   Boot ")) && "C>".equals(StaffCareerService.techName("C>")), "기술 이름 다듬기(한 단계라 > 허용)");
		// 기술 이름 맞추기·나누기
		check("Java, JavaScript".equals(StaffCareerService.canonTech("JAVA, Java, Java-Script, JavaScript")), "대소문자·하이픈 중복: " + StaffCareerService.canonTech("JAVA, Java, Java-Script, JavaScript"));
		check("MySQL, MSSQL".equals(StaffCareerService.canonTech("MY-SQL, My SQL, mySql, MS-SQL")), "MySQL·MSSQL: " + StaffCareerService.canonTech("MY-SQL, My SQL, mySql, MS-SQL"));
		check("STS, MySQL Workbench, HeidiSQL".equals(StaffCareerService.canonTech("STS Workbench HeidiSQL")), "붙은 값 나누기: " + StaffCareerService.canonTech("STS Workbench HeidiSQL"));
		check("IntelliJ, SourceTree".equals(StaffCareerService.canonTech("IntelliJ SourceTree")) && "iBatis, MyBatis".equals(StaffCareerService.canonTech("iBatis myBatis")), "붙은 값 나누기 2");
		check("전자정부프레임워크, iBatis".equals(StaffCareerService.canonTech("전자정부, 프레임웍, iBatis")), "전자정부+프레임웍 하나로");
		check("Visual Studio Code, Putty".equals(StaffCareerService.canonTech("Visual Studio Code, Putty")), "모르는 값·모르는 조각이 섞인 값은 그대로");
		try {
			StaffCareerService.techName("Java, JSP");
			check(false, "기술 이름 쉼표는 막아야 함");
		} catch (IllegalArgumentException e) {
			// 기대한 대로
		}
		for (String bad : new String[] { "a > b > c", "금융, 은행", " > 은행" }) {
			try {
				StaffCareerService.codeName(bad);
				check(false, "막아야 할 코드 이름: " + bad);
			} catch (IllegalArgumentException e) {
				// 기대한 대로
			}
		}

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
		m.put("ROLE_NM", "개발");
		m.put("START_YM", "2024-01");
		m.put("END_YM", "2024-03");
		return m;
	}

	private static Map<String, Object> kv(Object... kv) {
		Map<String, Object> m = new HashMap<>();
		for (int i = 0; i < kv.length; i += 2) m.put((String) kv[i], kv[i + 1]);
		return m;
	}

	/** 줄 이름 이어 붙이기(못 채운 자리는 _) */
	private static String names(List<Map<String, Object>> rows) {
		StringBuilder b = new StringBuilder();
		for (Map<String, Object> m : rows) b.append("Y".equals(m.get("EMPTY")) ? "_" : m.get("PRJ_NM"));
		return b.toString();
	}

	private static Map<String, Object> with(String k, String v) {
		return with(valid(), k, v);
	}

	private static Map<String, Object> with(Map<String, Object> base, String k, String v) {
		Map<String, Object> m = new HashMap<>(base);
		m.put(k, v);
		return m;
	}

	private static Map<String, Object> dep(int sq, String client, String prj, String start, String end) {
		Map<String, Object> m = new HashMap<>();
		m.put("DEPLOY_SQ", sq);
		m.put("CLIENT_NM", client);
		m.put("PRJ_NM", prj);
		m.put("START_DT", start);
		m.put("END_DT", end);
		return m;
	}

	private static Map<String, Object> prj(int sq, String name, String start, String end, String lang) {
		Map<String, Object> m = new HashMap<>();
		m.put("PRJ_SQ", sq);
		m.put("PRJ_NM", name);
		m.put("CLIENT_NM", "샘플");
		m.put("ROLE_NM", "개발");
		m.put("START_YM", start);
		m.put("END_YM", end);
		m.put("LANG_NM", lang);
		return m;
	}

	private static void rejected(Map<String, Object> m, String label) {
		try {
			StaffCareerService.clean(m);
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
