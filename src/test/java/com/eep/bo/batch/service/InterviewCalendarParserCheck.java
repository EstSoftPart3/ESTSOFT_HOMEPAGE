package com.eep.bo.batch.service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * 프로젝트에 JUnit 이 없어 main 으로 확인한다. 이름·번호는 가짜이고, 제목 형식은 실제 인터뷰 일정에서 본 변형들이다.
 * 실행: java -cp "target/classes;target/test-classes" com.eep.bo.batch.service.InterviewCalendarParserCheck
 */
public class InterviewCalendarParserCheck {

	public static void main(String[] args) {
		Map<String, Object> r = title("[신입]홍길동(사람인_공고/010-1111-2222)");
		eq(r, "APLY_NM", "홍길동");
		eq(r, "PHONE", "010-1111-2222");
		eq(r, "APLY_ROUTE", "SARAMIN");
		eq(r, "APLY_TARGET", "이에스티");
		eq(r, "CAREER", "신입");
		eq(r, "ATTEND_ST", null);

		r = title("[취소][신입]홍길동(사람인_농협은행/010-1111-2222)");
		eq(r, "ATTEND_ST", "CANCEL");
		eq(r, "APLY_TARGET", "농협은행");

		r = title("[경력재지원]-홍길동(6년4개월/잡코리아_농협은행/010-1111-2222)");
		eq(r, "APLY_NM", "홍길동");
		eq(r, "CAREER", "경력 6년4개월");
		eq(r, "APLY_ROUTE", "JOBKOREA");

		r = title("[경력]면접-홍길동(새마을은행계정계/010-1111-2222)");
		eq(r, "APLY_NM", "홍길동");
		eq(r, "APLY_ROUTE", null);
		eq(r, "APLY_TARGET", "새마을은행계정계");

		r = title("[경력]홍길동(사람인_삼성이커머스/010-1111-2222/노쇼)");
		eq(r, "ATTEND_ST", "ABSENT");

		r = title("[불참][신입]홍길동(사람인_공고/010-1111-2222)");
		eq(r, "ATTEND_ST", "ABSENT");

		r = title("[합격][신입]홍길동(사람인_공고/010-1111-2222)");
		eq(r, "RESULT_ST", "PASS");

		r = title("[합격/프리/통보대기/*]면접-홍길동(사람인_공고/신입/ 010-1111-2222)");
		eq(r, "APLY_NM", "홍길동");
		eq(r, "CAREER", "신입");
		eq(r, "PHONE", "010-1111-2222");

		r = title("[신입]ooo(010-1111-2222)");
		eq(r, "APLY_NM", "ooo");
		eq(r, "APLY_TARGET", "이에스티");

		check(InterviewCalendarParser.parseTitle("월례회의 - 전원참석") == null, "면접 형식이 아닌 제목");
		check(InterviewCalendarParser.parseTitle("[신입]홍길동(사람인_공고)") == null, "전화번호 없는 제목");
		check(InterviewCalendarParser.parseTitle(null) == null, "제목 없음");

		String ics = "BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\nDTSTART:20261103T050000Z\r\nUID:aaa@google.com\r\n"
				+ "SUMMARY:[신입]홍길동(사람인_공고/010-1111-\r\n 2222)\r\nSTATUS:CONFIRMED\r\nEND:VEVENT\r\n"
				+ "BEGIN:VEVENT\r\nDTSTART;TZID=Asia/Seoul:20261104T153000\r\nUID:bbb@google.com\r\nSUMMARY:출근 - [신입]홍길동(010-1111-2222)\r\nEND:VEVENT\r\n"
				+ "BEGIN:VEVENT\r\nDTSTART;VALUE=DATE:20261105\r\nUID:ccc@google.com\r\nSUMMARY:[신입/합격]홍길동(010-1111-2222)\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n";
		List<Map<String, String>> events = InterviewCalendarParser.parseIcs(ics);
		check(events.size() == 3, "VEVENT 3건");
		same(events.get(0).get("DATE"), "2026-11-03", "UTC -> 서울 날짜");
		same(events.get(0).get("TIME"), "14:00", "UTC -> 서울 시간");
		same(events.get(0).get("TITLE"), "[신입]홍길동(사람인_공고/010-1111-2222)", "접힌 줄 펼치기");
		same(events.get(1).get("TIME"), "15:30", "TZID 시간");
		check(InterviewCalendarParser.isExcluded(events.get(1)), "출근 제외");
		check(InterviewCalendarParser.isExcluded(events.get(2)), "종일 제외");
		check(!InterviewCalendarParser.isExcluded(events.get(0)), "면접은 포함");

		// 2026-11-02 는 월요일
		same(InterviewCalendarParser.weekOf(LocalDate.of(2026, 11, 2))[0].toString(), "2026-11-02", "월요일");
		same(InterviewCalendarParser.weekOf(LocalDate.of(2026, 11, 6))[1].toString(), "2026-11-08", "금요일이 든 주의 일요일");
		same(InterviewCalendarParser.weekOf(LocalDate.of(2026, 11, 7))[0].toString(), "2026-10-26", "토요일은 지난주");
		same(InterviewCalendarParser.weekOf(LocalDate.of(2026, 11, 8))[0].toString(), "2026-10-26", "일요일은 지난주");

		String err = InterviewCalendarParser.cleanError(new RuntimeException("I/O error on GET request for \"https://calendar.google.com/calendar/ical/x/private-secret/basic.ics\": timeout"));
		check(!err.contains("private-secret"), "오류 글에서 비공개 주소 제거");
		check(!InterviewCalendarParser.maskPhone("홍길동(010-1111-2222)").contains("1111"), "전화번호 가리기");

		System.out.println("OK");
	}

	private static Map<String, Object> title(String title) {
		Map<String, Object> r = InterviewCalendarParser.parseTitle(title);
		check(r != null, "해석 실패: " + title);
		return r;
	}

	private static void eq(Map<String, Object> r, String key, String want) {
		same((String) r.get(key), want, key);
	}

	private static void same(String got, String want, String label) {
		check(want == null ? got == null : want.equals(got), label + ": " + got + " != " + want);
	}

	private static void check(boolean ok, String label) {
		if (!ok) {
			throw new AssertionError(label);
		}
	}
}
