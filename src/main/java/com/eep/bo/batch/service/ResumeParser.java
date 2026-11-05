package com.eep.bo.batch.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 이력서 PDF 글자에서 면접관리 칸 값을 뽑는다. 사람인·잡코리아 출력본 기준이고, 못 찾은 칸은 넣지 않는다.
 * 주민등록번호 등 나머지 내용은 읽지 않으며 원문은 어디에도 저장하지 않는다.
 */
public final class ResumeParser {

	private static final Pattern NOISE = Pattern.compile("saramin\\.co\\.kr|^about:blank|^\\d{2}\\. \\d{1,2}\\. \\d{1,2}\\. 오[전후] .*(인쇄|인쇄하기)$");
	private static final Pattern PERSON = Pattern.compile("^(?:(남|여),\\s*)?\\d{4}년?\\s*\\((?:만\\s*)?(\\d{1,2})세\\)$");
	private static final Pattern MAIL = Pattern.compile("^[\\w.+-]+@[\\w.-]+$");
	private static final Pattern EDU_HEAD = Pattern.compile("^학력\\s+(?:대학|고등|대학원|중학|초등|검정|박사|석사)\\S*(?:\\(\\S+\\))?\\s*(\\S*)$");
	private static final Pattern EDU_ROW = Pattern.compile("^(?:\\d{4}\\.\\d{2}\\s*~\\s*(?:\\d{4}\\.\\d{2})?\\s*|(?:졸업예정|졸업|중퇴|휴학|재학중?)\\s+)(.+)$");
	private static final Pattern SECTION = Pattern.compile("^(학력\\s|경력\\s*총|경력기술서|자격/어학/수상|경험/활동/교육|교육이수|포트폴리오|자기소개|나의 스킬|스킬$|자격증$|간략 소개|취업우대|희망근무|주/야간|병역)");
	private static final Pattern CAREER_TOTAL = Pattern.compile("^경력\\s*총\\s*(.+)$");
	// 사람인: 2022.01 ~ 2022.02 회사 부서 · 직급 / 잡코리아: 회사 2022.09~2023.11
	private static final Pattern JOB_SARAMIN = Pattern.compile("^\\d{4}\\.\\d{2}\\s*~\\s*(\\d{4}\\.\\d{2}|재직중)\\s+(\\S+).*$");
	private static final Pattern JOB_JOBKOREA = Pattern.compile("^(.+?)\\s+\\d{4}\\.\\d{2}\\s*~\\s*(\\d{4}\\.\\d{2}|재직중)$");
	private static final Pattern PERIOD = Pattern.compile("(\\d+년(?:\\s*\\d+개월)?|\\d+개월)$");
	private static final Pattern LANG_ROW = Pattern.compile("^\\d{4}\\.\\d{2}\\s+(.+\\S)\\s+(영어|일본어|중국어|힌디어|포르투갈어|러시아어|독일어|인도네시아어|프랑스어|베트남어|스페인어)$");
	private static final Map<String, String> LANG_CODES = new HashMap<>();
	static {
		String[][] codes = { { "영어", "EN" }, { "일본어", "JA" }, { "중국어", "ZH" }, { "힌디어", "HI" }, { "포르투갈어", "PT" }, { "러시아어", "RU" },
				{ "독일어", "DE" }, { "인도네시아어", "ID" }, { "프랑스어", "FR" }, { "베트남어", "VI" }, { "스페인어", "ES" } };
		for (String[] c : codes) {
			LANG_CODES.put(c[0], c[1]);
		}
	}
	private static final int MAX_JOBS = 6, MAX_SKILLS = 8;

	private ResumeParser() {
	}

	/** @return 찾은 칸만 든 맵: GENDER, AGE, ADDR, EDU, CAREER, LANG, LANG_NOTE */
	public static Map<String, Object> parse(String text) {
		List<String> lines = new ArrayList<>();
		for (String raw : text.replace("\r", "").split("\n")) {
			String line = raw.trim();
			if (!line.isEmpty() && !NOISE.matcher(line).find()) {
				lines.add(line);
			}
		}
		Map<String, Object> row = new LinkedHashMap<>();
		person(lines, row);
		address(lines, row);
		education(lines, row);
		career(lines, row);
		language(lines, row);
		return row;
	}

	private static void person(List<String> lines, Map<String, Object> row) {
		for (String line : lines) {
			Matcher m = PERSON.matcher(line);
			if (m.matches()) {
				if (m.group(1) != null) {
					row.put("GENDER", "남".equals(m.group(1)) ? "M" : "F");
				}
				row.put("AGE", m.group(2));
				return;
			}
		}
	}

	private static void address(List<String> lines, Map<String, Object> row) {
		String addr = null;
		for (int i = 0; i < lines.size() && addr == null; i++) {
			String line = lines.get(i);
			if (line.startsWith("주소 ")) {
				addr = line.substring(3).replaceFirst("^\\(\\d{5}\\)\\s*", "");
			} else if (MAIL.matcher(line).matches() && i + 1 < lines.size() && !SECTION.matcher(lines.get(i + 1)).find()) {
				addr = lines.get(i + 1); // 잡코리아: 메일 다음 줄이 주소다
			}
		}
		if (addr != null && !addr.trim().isEmpty()) {
			row.put("ADDR", cut(addr.trim(), 200));
		}
	}

	private static void education(List<String> lines, Map<String, Object> row) {
		for (int i = 0; i < lines.size(); i++) {
			Matcher head = EDU_HEAD.matcher(lines.get(i));
			if (!head.matches()) {
				continue;
			}
			if (i + 1 >= lines.size() || SECTION.matcher(lines.get(i + 1)).find()) {
				return;
			}
			Matcher school = EDU_ROW.matcher(lines.get(i + 1));
			// 잡코리아는 학교 이름 뒤에 기간이 붙어 나온다
			String name = (school.matches() ? school.group(1).trim() : lines.get(i + 1)).replaceAll("\\s*\\d{4}\\.\\d{2}\\s*~\\s*(?:\\d{4}\\.\\d{2})?", "").trim();
			row.put("EDU", cut((name + " " + head.group(1)).trim(), 200));
			return;
		}
	}

	/** 신입·경력 구분, 총 경력, 회사별 기간, 주요 스킬을 한 줄로 요약한다 */
	private static void career(List<String> lines, Map<String, Object> row) {
		List<String> parts = new ArrayList<>();
		boolean experienced = false;
		for (int i = 0; i < lines.size(); i++) {
			Matcher total = CAREER_TOTAL.matcher(lines.get(i));
			if (!total.matches()) {
				continue;
			}
			experienced = true;
			parts.add("총 " + total.group(1).trim());
			List<String> jobs = jobs(lines, i + 1);
			if (!jobs.isEmpty()) {
				parts.add(String.join(", ", jobs));
			}
			break;
		}
		String type = experienced ? "경력" : "신입";
		for (String line : lines.subList(0, Math.min(5, lines.size()))) {
			if (line.matches("^\\S+\\s+신입$")) {
				type = "신입"; // 인턴 등 경력이 있어도 본인이 신입으로 지원한 경우
			}
		}
		List<String> skills = skills(lines);
		if (!skills.isEmpty()) {
			parts.add(String.join(", ", skills));
		}
		if (!parts.isEmpty()) {
			row.put("CAREER", cut(type + " · " + String.join(" · ", parts), 500));
		}
	}

	private static List<String> jobs(List<String> lines, int from) {
		List<String> jobs = new ArrayList<>();
		for (int i = from; i < lines.size() && jobs.size() < MAX_JOBS; i++) {
			String line = lines.get(i);
			if (SECTION.matcher(line).find()) {
				break;
			}
			Matcher saramin = JOB_SARAMIN.matcher(line), jobkorea = JOB_JOBKOREA.matcher(line);
			String company = saramin.matches() ? saramin.group(2) : jobkorea.matches() ? jobkorea.group(1).trim() : null;
			if (company == null) {
				continue;
			}
			boolean current = line.contains("재직중");
			Matcher period = i + 1 < lines.size() ? PERIOD.matcher(lines.get(i + 1)) : null;
			jobs.add(company + (period != null && period.find() ? " " + period.group(1) : current ? " 재직중" : ""));
		}
		return jobs;
	}

	private static List<String> skills(List<String> lines) {
		Set<String> skills = new LinkedHashSet<>();
		for (int i = 0; i < lines.size(); i++) {
			String line = lines.get(i);
			if (!line.equals("나의 스킬") && !line.equals("스킬")) {
				continue;
			}
			for (int j = i + 1; j < lines.size() && j <= i + 5 && !SECTION.matcher(lines.get(j)).find(); j++) {
				for (String skill : lines.get(j).split("\\s{2,}|\\s*,\\s*")) {
					if (skills.size() < MAX_SKILLS && !skill.isEmpty() && skill.length() <= 30 && !skill.startsWith("http")) {
						skills.add(skill);
					}
				}
			}
			break;
		}
		return new ArrayList<>(skills);
	}

	private static void language(List<String> lines, Map<String, Object> row) {
		Set<String> codes = new LinkedHashSet<>(), notes = new LinkedHashSet<>();
		for (String line : lines) {
			Matcher m = LANG_ROW.matcher(line);
			if (m.matches()) {
				codes.add(LANG_CODES.get(m.group(2)));
				notes.add(m.group(2) + " " + m.group(1));
			}
		}
		if (!codes.isEmpty()) {
			row.put("LANG", String.join(",", codes));
			row.put("LANG_NOTE", cut(String.join(", ", notes), 500));
		}
	}

	private static String cut(String s, int max) {
		return s.length() > max ? s.substring(0, max) : s;
	}
}
