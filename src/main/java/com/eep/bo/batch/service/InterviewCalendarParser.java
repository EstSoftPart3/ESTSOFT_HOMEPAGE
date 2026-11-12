package com.eep.bo.batch.service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** 인터뷰 일정 캘린더의 iCal 과 일정 제목을 면접관리 칸 값으로 바꾼다. DB·네트워크를 쓰지 않는다 */
public final class InterviewCalendarParser {

	static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");
	static final int PRE_RUN_MINUTES = 10;

	private static final DateTimeFormatter ICS_DT = DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmss");
	private static final DateTimeFormatter ICS_D = DateTimeFormatter.ofPattern("yyyyMMdd");
	// 예: [취소][신입]이름(사람인_공고/010-0000-0000), [신입]이름/사람인_공고/010-0000-0000, [경력]면접-이름(...), [경력재지원]-이름(...)
	// 사람이 손으로 쓰는 제목이라 괄호 짝이 안 맞기도 해서, 이름 뒤는 괄호를 떼고 '/' 로만 나눈다
	private static final Pattern TITLE = Pattern.compile("^((?:\\[[^\\]]*\\]\\s*)*)-?\\s*(?:면접\\s*-\\s*)?([^\\s\\[\\]()/]+)\\s*[(/](.*)$");
	private static final Pattern TAG = Pattern.compile("\\[([^\\]]*)\\]");
	private static final Pattern LEAD_TAGS = Pattern.compile("^((?:\\[[^\\]]*\\]\\s*)*)");
	private static final Pattern PHONE = Pattern.compile("01\\d-?\\d{3,4}-?\\d{4}");
	private static final Pattern ICAL_URL = Pattern.compile("/ical/([^/]+)/private-([^/]+)/");
	private static final Pattern YEARS =Pattern.compile("^(\\d+년\\s*)?(\\d+개월)?$");

	private InterviewCalendarParser() {
	}

	/**
	 * 지난 확인 뒤 지금까지 지나간 각 분의 10분 뒤 시각. 앞선 배치가 길어져 건너뛴 분도 놓치지 않으려고 구간으로 본다.
	 * @param last 지난 확인 시각, now 지금 (둘 다 분 단위로 잘린 값). 오래 멈췄다 깨어나도 최근 2시간만 본다
	 */
	public static List<LocalDateTime> preRunTargets(LocalDateTime last, LocalDateTime now) {
		LocalDateTime from = last.isBefore(now.minusHours(2)) ? now.minusHours(2) : last;
		List<LocalDateTime> targets = new ArrayList<>();
		for (LocalDateTime t = from.plusMinutes(1); !t.isAfter(now); t = t.plusMinutes(1)) {
			targets.add(t.plusMinutes(PRE_RUN_MINUTES));
		}
		return targets;
	}

	/** 면접관리 화면이 처음 보여 주는 주(월~일). 토·일이면 지난주다 */
	public static LocalDate[] weekOf(LocalDate today) {
		LocalDate d = today.getDayOfWeek().getValue() > 5 ? today.minusDays(7) : today;
		LocalDate monday = d.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
		return new LocalDate[] { monday, monday.plusDays(6) };
	}

	/**
	 * VEVENT 를 {UID, TITLE, STATUS, ALL_DAY(Y/N), DATE(yyyy-MM-dd), TIME(HH:mm)} 로 돌려준다.
	 * shortcut: RRULE 은 펼치지 않고 첫 회차만 본다. 면접은 반복 일정이 아니라서 괜찮고, 반복 면접이 생기면 펼쳐야 한다
	 */
	public static List<Map<String, String>> parseIcs(String ics) {
		List<Map<String, String>> events = new ArrayList<>();
		Map<String, String> cur = null;
		// 75자가 넘는 줄은 줄바꿈 + 공백으로 접혀 온다(RFC 5545)
		for (String line : ics.replace("\r\n", "\n").replaceAll("\n[ \t]", "").split("\n")) {
			if ("BEGIN:VEVENT".equals(line)) {
				cur = new HashMap<>();
			} else if ("END:VEVENT".equals(line)) {
				if (cur != null) {
					events.add(cur);
				}
				cur = null;
			} else if (cur != null) {
				int colon = line.indexOf(':');
				if (colon < 0) {
					continue;
				}
				String head = line.substring(0, colon), value = line.substring(colon + 1);
				if (head.equals("UID")) {
					cur.put("UID", value);
				} else if (head.equals("SUMMARY")) {
					cur.put("TITLE", unescape(value));
				} else if (head.equals("STATUS")) {
					cur.put("STATUS", value);
				} else if (head.equals("DTSTART") || head.startsWith("DTSTART;")) {
					putStart(cur, head, value);
				}
			}
		}
		return events;
	}

	private static void putStart(Map<String, String> event, String head, String value) {
		if (value.length() == 8) {
			event.put("ALL_DAY", "Y");
			event.put("DATE", LocalDate.parse(value, ICS_D).toString());
			return;
		}
		LocalDateTime local;
		if (value.endsWith("Z")) {
			local = LocalDateTime.parse(value.substring(0, value.length() - 1), ICS_DT).atOffset(ZoneOffset.UTC).atZoneSameInstant(SEOUL).toLocalDateTime();
		} else {
			int tz = head.indexOf("TZID=");
			ZoneId zone = tz < 0 ? SEOUL : ZoneId.of(head.substring(tz + 5).split(";")[0]);
			local = LocalDateTime.parse(value, ICS_DT).atZone(zone).withZoneSameInstant(SEOUL).toLocalDateTime();
		}
		event.put("ALL_DAY", "N");
		event.put("DATE", local.toLocalDate().toString());
		event.put("TIME", local.format(DateTimeFormatter.ofPattern("HH:mm")));
	}

	private static String unescape(String s) {
		return s.replace("\\n", " ").replace("\\N", " ").replace("\\,", ",").replace("\\;", ";").replace("\\\\", "\\");
	}

	/** 면접이 아닌 일정이면 제외 사유, 면접 대상이면 null */
	public static String excludeReason(Map<String, String> event) {
		String title = event.get("TITLE");
		if ("CANCELLED".equals(event.get("STATUS"))) return "캘린더에서 삭제된 일정";
		if ("Y".equals(event.get("ALL_DAY"))) return "종일 일정";
		if (title != null && title.trim().startsWith("출근")) return "출근 일정";
		if (hasCareerTag(title)) return "경력 면접";
		return null;
	}

	/** 신입면접 배치라서 앞쪽 대괄호 태그에 경력…([경력], [경력재지원] 등)이 있으면 가져오지 않는다 */
	private static boolean hasCareerTag(String title) {
		Matcher m = title == null ? null : LEAD_TAGS.matcher(title.trim());
		if (m == null || !m.find()) {
			return false;
		}
		Matcher tags = TAG.matcher(m.group(1));
		while (tags.find()) {
			for (String raw : tags.group(1).split("/")) {
				if (raw.trim().startsWith("경력")) return true;
			}
		}
		return false;
	}

	/** 제목을 면접관리 칸 값으로 바꾼다. 형식이 다르거나 전화번호가 없으면 null */
	public static Map<String, Object> parseTitle(String title) {
		Matcher m = title == null ? null : TITLE.matcher(title.trim());
		if (m == null || !m.matches()) {
			return null;
		}
		Map<String, Object> row = new HashMap<>();
		row.put("APLY_NM", m.group(2));
		String career = null, years = null;

		Matcher tags = TAG.matcher(m.group(1));
		while (tags.find()) {
			for (String raw : tags.group(1).split("/")) {
				String tag = raw.trim();
				if (tag.equals("신입")) career = "신입";
				else if (tag.startsWith("경력")) career = "경력";
				else if (tag.equals("취소")) row.put("ATTEND_ST", "CANCEL");
				else if (tag.equals("불참")) row.put("ATTEND_ST", "ABSENT");
				else if (tag.equals("합격")) row.put("RESULT_ST", "PASS");
				else if (tag.equals("불합격")) row.put("RESULT_ST", "FAIL");
			}
		}
		for (String raw : m.group(3).replaceAll("[()]", "/").split("/")) {
			String part = raw.trim();
			Matcher phone = PHONE.matcher(part);
			if (part.isEmpty()) continue;
			if (phone.find()) row.put("PHONE", phone.group());
			else if (part.equals("노쇼")) row.put("ATTEND_ST", "ABSENT");
			else if (part.equals("신입")) career = "신입";
			else if (part.startsWith("경력")) career = "경력";
			else if (YEARS.matcher(part).matches()) years = part;
			else putRouteAndTarget(row, part);
		}
		if (row.get("PHONE") == null) {
			return null;
		}
		if (row.get("APLY_TARGET") == null) {
			row.put("APLY_TARGET", "이에스티"); // 면접관리 새 행의 기본값과 같다
		}
		if (career == null && years != null) {
			career = "경력";
		}
		row.put("CAREER", career == null ? null : years == null ? career : career + " " + years);
		return row;
	}

	/** 사람인_공고 -> 경로 + 이에스티, 사람인_농협은행 -> 경로 + 농협은행, 새마을은행 -> 대상만 */
	private static void putRouteAndTarget(Map<String, Object> row, String part) {
		int bar = part.indexOf('_');
		String head = bar < 0 ? part : part.substring(0, bar), rest = bar < 0 ? "" : part.substring(bar + 1).trim();
		String route = head.equals("사람인") ? ("챗봇".equals(rest) ? "SARAMIN_BOT" : "SARAMIN") : head.equals("잡코리아") || head.equals("잡코") ? "JOBKOREA" : null;
		if (route == null) {
			row.putIfAbsent("APLY_TARGET", part);
			return;
		}
		row.put("APLY_ROUTE", route);
		if (!rest.isEmpty() && !rest.equals("공고") && !rest.equals("챗봇")) {
			row.put("APLY_TARGET", rest);
		}
	}

	/** 이력 화면에 남기는 글자에서 전화번호를 가린다 */
	public static String maskPhone(String s) {
		return s == null ? "" : PHONE.matcher(s).replaceAll("010-****-****");
	}

	/** 화면 표시용: 어느 캘린더인지는 보이고 비공개 키는 끝 4자리만 남긴다. 예) est.supprt@gmail.com · private-****abcd */
	public static String maskIcalUrl(String url) {
		Matcher m = url == null ? null : ICAL_URL.matcher(url);
		if (m == null || !m.find()) {
			return "****";
		}
		String key = m.group(2);
		return m.group(1).replace("%40", "@") + " · private-****" + key.substring(Math.max(0, key.length() - 4));
	}

	/** 화면 표시용: 앞 6자리와 끝 4자리만 남긴다. 값이 없으면 null */
	public static String maskMiddle(String s) {
		if (s == null || s.isEmpty()) {
			return null;
		}
		return s.length() <= 10 ? "****" : s.substring(0, 6) + "****" + s.substring(s.length() - 4);
	}

	/** 오류 글에 iCal 비공개 주소가 섞여 들어가므로 URL 을 지운다 */
	public static String cleanError(Throwable e) {
		String msg = e.getClass().getSimpleName() + (e.getMessage() == null ? "" : ": " + e.getMessage());
		msg = maskPhone(msg.replaceAll("https?://[^\\s\"']+", "[URL]"));
		return msg.length() > 500 ? msg.substring(0, 500) : msg;
	}
}
