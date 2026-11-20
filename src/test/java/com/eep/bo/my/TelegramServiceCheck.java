package com.eep.bo.my;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/** 프로젝트에 JUnit 이 없어 main 으로 확인한다 */
public class TelegramServiceCheck {

	public static void main(String[] args) {
		// 2026-11-20 은 금요일
		Map<String, Object> once = task("2026-11-20", "NONE", null, null, null, null);
		check(TelegramService.occurs(once, LocalDate.parse("2026-11-20")) && !TelegramService.occurs(once, LocalDate.parse("2026-11-21")), "반복 없음");
		Map<String, Object> week = task("2026-11-02", "WEEK", "15", null, "2026-11-27", null); // 월·금
		check(TelegramService.occurs(week, LocalDate.parse("2026-11-20")) && !TelegramService.occurs(week, LocalDate.parse("2026-11-19")), "매주 요일");
		check(!TelegramService.occurs(task("2026-11-02", "WEEK", "15", "2026-11-20", null, null), LocalDate.parse("2026-11-20")), "빠진 회차");
		check(!TelegramService.occurs(task("2026-11-02", "WEEK", "15", null, null, "2026-11-20"), LocalDate.parse("2026-11-20")), "완료 회차");
		check(!TelegramService.occurs(task("2026-11-02", "DAY", null, null, "2026-11-19", null), LocalDate.parse("2026-11-20")), "반복 끝 지남");
		check(TelegramService.occurs(task("2026-10-20", "MONTH", null, null, null, null), LocalDate.parse("2026-11-20")), "매월 같은 날");

		LocalDateTime now = LocalDateTime.parse("2026-11-20T13:30");
		TelegramService.Ev ev = new TelegramService.Ev("INTV_NEW", "1", LocalDateTime.parse("2026-11-20T14:00"), "홍길동", null, "/x", null);
		check("🔔 14:00 신입면접 홍길동 (30분 후)".equals(TelegramService.beforeText(ev, now)), "알림 문구");
		check("11/21(토) 09:00".equals(TelegramService.when(LocalDateTime.parse("2026-11-21T09:00"), now)), "다른 날 표시");
		check(TelegramService.set(" A, ,B ").size() == 2, "쉼표 목록");
		System.out.println("OK");
	}

	private static Map<String, Object> task(String start, String rpt, String dow, String skip, String until, String done) {
		Map<String, Object> t = new HashMap<>();
		t.put("START_DT", start);
		t.put("RPT_CD", rpt);
		t.put("RPT_DOW", dow);
		t.put("SKIP_DTS", skip);
		t.put("RPT_UNTIL", until);
		t.put("DONE_DTS", done);
		return t;
	}

	private static void check(boolean ok, String name) {
		if (!ok) throw new AssertionError(name);
	}
}
