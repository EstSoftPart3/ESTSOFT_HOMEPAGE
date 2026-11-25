package com.eep.bo.recruit.service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 모집 캘린더(est.part2) 일정 읽기(plans/recruit-cal-import-spec.html).
 * 「모집(등급 인원) - 사업명」은 RecruitParser 가 그대로 읽고, 여기서는 「인터뷰 - 이름(사업명)」과 설명 속 「인터뷰 보고」만 읽는다.
 * 자체 검사: RecruitCalParserCheck
 */
public final class RecruitCalParser {

	private RecruitCalParser() {}

	private static final Pattern RECRUIT = Pattern.compile("^\\s*모\\s*집\\s*\\(.*?\\)\\s*[-–—]\\s*(.+?)\\s*$");
	private static final Pattern INTERVIEW = Pattern.compile("^\\s*인\\s*터\\s*뷰\\s*[-–—]\\s*([^()]+?)\\s*\\((.+)\\)\\s*$");
	/** 「1. 인터뷰 분위기 :」 같은 보고 칸 제목 */
	private static final Pattern SECTION = Pattern.compile("^\\s*\\d\\s*[.)]\\s*(인터뷰\\s*분위기|질의\\s*응답|답변\\s*못\\s*한\\s*질문|예상\\s*결과|투입\\s*의사)[^:：]*[:：]?\\s*(.*)$");
	private static final Pattern Q = Pattern.compile("^\\s*질\\s*문\\s*[:：]\\s*(.*)$");
	private static final Pattern A = Pattern.compile("^\\s*대\\s*답\\s*[:：]\\s*(.*)$");
	/** 질문 사이의 「- 1.」 같은 번호 줄 */
	private static final Pattern NUM = Pattern.compile("^\\s*-?\\s*\\d{1,2}\\s*\\.?\\s*$");

	/** 모집 일정이면 사업명 부분, 아니면 null */
	public static String recruitTitle(String title) {
		Matcher m = RECRUIT.matcher(s(title));
		return m.matches() ? m.group(1) : null;
	}

	/** 인터뷰 일정이면 {이름, 사업명}, 아니면 null */
	public static String[] interview(String title) {
		Matcher m = INTERVIEW.matcher(s(title));
		return m.matches() ? new String[] { m.group(1).trim(), m.group(2).trim() } : null;
	}

	/** 사업명 비교용: 띄어쓰기·괄호·따옴표·구분 기호를 빼고 소문자 */
	public static String key(String s) {
		return s(s).toLowerCase().replaceAll("[\\s\\[\\]()（）\"'“”‘’\\-–—_·.,/:]", "");
	}

	/**
	 * 설명 속 인터뷰 보고 → 인터뷰 기록 칸(mood·qa·memo). 보고가 없으면 null.
	 * moods 는 분위기 칩 목록(같은 글이면 분위기 칩으로, 아니면 메모에)
	 */
	public static Map<String, Object> report(String desc, List<String> moods) {
		String text = RecruitParser.stripHtml(s(desc));
		List<Map<String, String>> qa = new ArrayList<>();
		Map<String, StringBuilder> sec = new LinkedHashMap<>();
		String cur = null;
		Map<String, String> pair = null;
		StringBuilder field = null; // 지금 이어 붙이는 질문 또는 대답
		for (String line : text.split("\\r?\\n")) {
			Matcher m;
			if ((m = SECTION.matcher(line)).matches()) {
				cur = m.group(1).replaceAll("\\s", "");
				sec.put(cur, new StringBuilder(m.group(2).trim()));
				field = null;
				continue;
			}
			if ((m = Q.matcher(line)).matches()) {
				pair = new LinkedHashMap<>();
				pair.put("q", m.group(1).trim());
				pair.put("a", "");
				qa.add(pair);
				field = new StringBuilder(m.group(1).trim());
				cur = "Q";
				continue;
			}
			if ((m = A.matcher(line)).matches() && pair != null) {
				field = new StringBuilder(m.group(1).trim());
				cur = "A";
				pair.put("a", field.toString());
				continue;
			}
			String t = line.trim();
			if (t.isEmpty() || NUM.matcher(t).matches() || t.matches("-{5,}")) continue;
			if (("Q".equals(cur) || "A".equals(cur)) && pair != null && field != null) {
				field.append(field.length() > 0 ? " " : "").append(t);
				pair.put("Q".equals(cur) ? "q" : "a", field.toString());
			} else if (cur != null && sec.containsKey(cur)) {
				StringBuilder b = sec.get(cur);
				b.append(b.length() > 0 ? " " : "").append(t);
			}
		}
		if (qa.isEmpty() && sec.isEmpty()) return null;
		Map<String, Object> out = new LinkedHashMap<>();
		String mood = sec.containsKey("인터뷰분위기") ? sec.get("인터뷰분위기").toString().trim() : "";
		if (!mood.isEmpty() && moods != null && moods.contains(mood)) out.put("mood", mood);
		out.put("qa", qa);
		List<String> memo = new ArrayList<>();
		if (!mood.isEmpty() && !out.containsKey("mood")) memo.add("분위기: " + mood);
		String[][] names = { { "답변못한질문", "답변 못한 질문" }, { "예상결과", "예상 결과" }, { "투입의사", "투입 의사" } };
		for (String[] n : names) if (sec.containsKey(n[0]) && sec.get(n[0]).toString().trim().length() > 0) memo.add(n[1] + ": " + sec.get(n[0]).toString().trim());
		out.put("memo", cut(String.join("\n", memo), 1000));
		return out;
	}

	private static String s(Object v) {
		return v == null ? "" : String.valueOf(v);
	}

	private static String cut(String s, int max) {
		return s.length() <= max ? s : s.substring(0, max);
	}
}
