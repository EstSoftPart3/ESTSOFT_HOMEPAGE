package com.eep.bo.recruit.service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 모집 원문(붙여 넣은 메일·카톡·문서 글)을 칸으로 나눈다. 못 읽은 칸은 비워 두고 화면이 '확인 필요'로 보인다.
 * 제목: 「모집(중급 2) - 고객사 사업명」, 본문: 「기간: / 근무지: / 단가: / 기술: / 우대: / 매출처: / 담당: / 마감:」 이름표,
 * 이름표 없는 문장(「12월 초 ~ 6개월」「초급 1명」「을지로 상주」「○○ 통해서」「단가 미정」)도 읽는다.
 */
public final class RecruitParser {

	/** 읽어 내는 칸(서비스·화면이 같이 쓴다) */
	public static final String[] FIELDS = { "CLIENT_NM", "PRJ_NM", "GRADE_TXT", "HEAD_CNT", "START_DT", "END_DT", "PERIOD_TXT", "WORK_AREA", "PRICE_TXT", "SKILLS",
			"PREFER", "SALE_PARTNER_TXT", "MGR_NM", "CLOSE_DT", "MEMO" };

	private static final Pattern TITLE = Pattern.compile("^\\s*[\\[(]?\\s*모\\s*집\\s*[\\])]?\\s*(?:[(\\[]([^)\\]]*)[)\\]])?\\s*[-–—:]?\\s*(.*)$");
	private static final Pattern GRADE = Pattern.compile("(초급|중급|고급|특급)\\s*(\\d{1,2})?\\s*(?:명|인)?");
	private static final Pattern LABEL = Pattern.compile("^\\s*[-•·*]?\\s*([가-힣 ]{1,8})\\s*[:：]\\s*(.*)$");
	private static final Pattern YMD = Pattern.compile("(\\d{4})\\s*[-./년]\\s*(\\d{1,2})\\s*[-./월]\\s*(\\d{1,2})\\s*일?");
	private static final Pattern MD = Pattern.compile("(?<![\\d.])(\\d{1,2})\\s*[/.월]\\s*(\\d{1,2})\\s*일?(?![\\d])");
	private static final Pattern MONTH_PART = Pattern.compile("(\\d{1,2})\\s*월\\s*(초|중순|중|말)?");
	private static final Pattern MONTHS = Pattern.compile("(\\d{1,2})\\s*개월");
	private static final Pattern PLACE_FREE = Pattern.compile("([가-힣A-Za-z0-9]+)\\s*(?:상주|근무|출근)");
	private static final Pattern PARTNER_FREE = Pattern.compile("([가-힣A-Za-z0-9()（）㈜]+)\\s*(?:통해서|통해|경유)");
	private static final Pattern PRICE_FREE = Pattern.compile("단가\\s*[:：]?\\s*([^,\\n]+)");
	private static final DateTimeFormatter ISO = DateTimeFormatter.ISO_LOCAL_DATE;

	private RecruitParser() {
	}

	/** 이름표 → 칸. 같은 뜻의 다른 말도 받는다 */
	private static String fieldOf(String label) {
		String l = label.replace(" ", "");
		if (l.matches("기간|투입기간|투입|투입일|일정|계약기간")) return "PERIOD";
		if (l.matches("근무지|근무지역|장소|위치|근무장소")) return "WORK_AREA";
		if (l.matches("단가|금액|비용|예산")) return "PRICE_TXT";
		if (l.matches("기술|요구기술|스킬|기술스택|필수기술|필수")) return "SKILLS";
		if (l.matches("우대|우대사항|우대조건")) return "PREFER";
		if (l.matches("매출처|거래처|업체|발주처|원청")) return "SALE_PARTNER_TXT";
		if (l.matches("담당|담당자|영업담당")) return "MGR_NM";
		if (l.matches("마감|지원마감|마감일|제출마감")) return "CLOSE_DT";
		if (l.matches("등급|인원|등급인원|모집인원")) return "GRADE";
		if (l.matches("고객사|고객")) return "CLIENT_NM";
		if (l.matches("사업명|사업|프로젝트|프로젝트명")) return "PRJ_NM";
		return null;
	}

	/** today 는 '12월 초' 처럼 연도가 없는 날짜의 해를 정할 때 쓴다(지난 달이면 내년) */
	public static Map<String, Object> parse(String title, String body, LocalDate today) {
		Map<String, Object> out = new LinkedHashMap<>();
		for (String f : FIELDS) out.put(f, null);
		String t = clean(title), b = body == null ? "" : stripHtml(body);
		List<String> lines = new ArrayList<>();
		// 제목이 없으면(붙여 넣기) 첫 줄을 제목으로
		if (t.isEmpty()) {
			String[] all = b.split("\\r?\\n");
			int i = 0;
			while (i < all.length && all[i].trim().isEmpty()) i++;
			t = i < all.length ? clean(all[i]) : "";
			for (int j = i + 1; j < all.length; j++) lines.add(all[j]);
		} else {
			for (String l : b.split("\\r?\\n")) lines.add(l);
		}

		// ── 제목 ──
		String rest = t;
		Matcher m = TITLE.matcher(t);
		if (m.matches()) {
			if (m.group(1) != null) grades(m.group(1), out);
			rest = m.group(2).trim();
		}
		// 제목 안의 등급·인원(「… 초급 1명」)은 떼어 낸다
		if (out.get("GRADE_TXT") == null && GRADE.matcher(rest).find()) {
			grades(rest, out);
			rest = GRADE.matcher(rest).replaceAll(" ").replaceAll("\\s+", " ").trim();
		}
		rest = rest.replaceAll("^[-–—:\\s]+|[-–—:\\s]+$", "");
		if (!rest.isEmpty()) {
			int sp = rest.indexOf(' ');
			out.put("CLIENT_NM", sp < 0 ? rest : rest.substring(0, sp).trim());
			if (sp > 0) out.put("PRJ_NM", rest.substring(sp + 1).trim());
		}

		// ── 본문 ──
		List<String> memo = new ArrayList<>();
		for (String raw : lines) {
			String line = clean(raw);
			if (line.isEmpty()) continue;
			Matcher lm = LABEL.matcher(line);
			String f = lm.matches() ? fieldOf(lm.group(1)) : null;
			if (f != null) {
				String v = lm.group(2).trim();
				if ("PERIOD".equals(f)) period(v, out, today);
				else if ("GRADE".equals(f)) grades(v, out);
				else if ("CLOSE_DT".equals(f)) { LocalDate cd = date(v, today); out.put("CLOSE_DT", cd == null ? null : cd.format(ISO)); }
				else if (!v.isEmpty()) out.put(f, cut(v, 300));
				continue;
			}
			// 이름표 없는 문장
			boolean used = false;
			if (out.get("GRADE_TXT") == null && GRADE.matcher(line).find()) { grades(line, out); used = true; }
			if (out.get("START_DT") == null && (YMD.matcher(line).find() || MONTH_PART.matcher(line).find() || line.contains("~"))) {
				Object before = out.get("PERIOD_TXT");
				period(line, out, today);
				if (out.get("START_DT") != null) used = true;
				else out.put("PERIOD_TXT", before); // 날짜가 아닌 문장은 기간 칸을 덮지 않는다
			}
			Matcher pm = PLACE_FREE.matcher(line);
			if (out.get("WORK_AREA") == null && pm.find()) { out.put("WORK_AREA", pm.group(1)); used = true; }
			Matcher sm = PARTNER_FREE.matcher(line);
			if (out.get("SALE_PARTNER_TXT") == null && sm.find()) { out.put("SALE_PARTNER_TXT", sm.group(1)); used = true; }
			Matcher cm = PRICE_FREE.matcher(line);
			if (out.get("PRICE_TXT") == null && cm.find()) { out.put("PRICE_TXT", cut(cm.group(1).trim(), 300)); used = true; }
			if (!used) memo.add(line);
		}
		if (!memo.isEmpty()) out.put("MEMO", cut(String.join("\n", memo), 2000));
		return out;
	}

	/** 「중급 2」「중급 1 · 고급 2」「초급 1명」 → GRADE_TXT, HEAD_CNT(합). 인원이 없으면 1명 */
	static void grades(String s, Map<String, Object> out) {
		Matcher g = GRADE.matcher(s);
		List<String> parts = new ArrayList<>();
		int sum = 0;
		while (g.find()) {
			int n = g.group(2) == null ? 1 : Integer.parseInt(g.group(2));
			parts.add(g.group(1) + " " + n);
			sum += n;
		}
		if (parts.isEmpty()) {
			Matcher n = Pattern.compile("(\\d{1,2})\\s*(?:명|인)?").matcher(s);
			if (n.find()) out.put("HEAD_CNT", Integer.parseInt(n.group(1)));
			return;
		}
		out.put("GRADE_TXT", String.join(" · ", parts));
		out.put("HEAD_CNT", sum);
	}

	/** 「2026-12-01 ~ 2027-05-31」「12월 초 ~ 6개월」「12/1 ~ (미정)」 → START_DT, END_DT, PERIOD_TXT */
	static void period(String v, Map<String, Object> out, LocalDate today) {
		out.put("PERIOD_TXT", cut(v, 200));
		String[] se = v.split("~|∼|부터|에서", 2);
		LocalDate start = date(se[0], today);
		if (start == null) return;
		out.put("START_DT", start.format(ISO));
		String tail = se.length > 1 ? se[1] : v.substring(Math.min(v.length(), se[0].length()));
		Matcher mm = MONTHS.matcher(tail.isEmpty() ? v : tail);
		LocalDate end = null;
		if (se.length > 1) end = dateAfter(tail, start);
		if (end == null && mm.find()) end = start.plusMonths(Integer.parseInt(mm.group(1))).minusDays(1);
		if (end != null && !end.isBefore(start)) out.put("END_DT", end.format(ISO));
	}

	private static LocalDate dateAfter(String s, LocalDate start) {
		LocalDate d = date(s, start);
		if (d != null && d.isBefore(start) && !YMD.matcher(s).find()) d = d.plusYears(1);
		return d;
	}

	/** 날짜 한 개. 연도가 없으면 today 기준으로 지난 달이면 내년. 초=1일, 중순=15일, 말=말일 */
	static LocalDate date(String s, LocalDate today) {
		if (s == null) return null;
		Matcher y = YMD.matcher(s);
		try {
			if (y.find()) return LocalDate.of(Integer.parseInt(y.group(1)), Integer.parseInt(y.group(2)), Integer.parseInt(y.group(3)));
			Matcher md = MD.matcher(s);
			if (md.find()) return yearOf(Integer.parseInt(md.group(1)), Integer.parseInt(md.group(2)), today);
			Matcher mp = MONTH_PART.matcher(s);
			if (mp.find()) {
				int mon = Integer.parseInt(mp.group(1));
				if (mon < 1 || mon > 12) return null;
				LocalDate first = yearOf(mon, 1, today);
				String part = mp.group(2) == null ? "" : mp.group(2);
				return part.startsWith("중") ? first.withDayOfMonth(15) : "말".equals(part) ? first.withDayOfMonth(first.lengthOfMonth()) : first;
			}
		} catch (RuntimeException e) {
			return null; // 13월·32일 같은 값
		}
		return null;
	}

	private static LocalDate yearOf(int mon, int day, LocalDate today) {
		LocalDate d = LocalDate.of(today.getYear(), mon, day);
		return d.isBefore(today.withDayOfMonth(1)) ? d.plusYears(1) : d;
	}

	/** 전각 기호·여러 칸 띄기 정리 */
	static String clean(String s) {
		if (s == null) return "";
		return s.replace('（', '(').replace('）', ')').replace('［', '[').replace('］', ']').replace('：', ':').replace('～', '~').replace(' ', ' ').replaceAll("[ \\t]+", " ").trim();
	}

	/** 구글 캘린더 설명은 HTML 일 때가 있다 */
	static String stripHtml(String s) {
		return s.replaceAll("(?i)<br\\s*/?>|</p>|</div>|</li>", "\n").replaceAll("<[^>]+>", "").replace("&nbsp;", " ").replace("&amp;", "&").replace("&lt;", "<").replace("&gt;", ">");
	}

	private static String cut(String s, int max) {
		return s == null || s.length() <= max ? s : s.substring(0, max);
	}
}
