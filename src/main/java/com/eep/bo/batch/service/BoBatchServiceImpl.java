package com.eep.bo.batch.service;

import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.eep.bo.batch.dao.BoBatchDao;

@Service
public class BoBatchServiceImpl implements BoBatchService {

	private static final Logger log = LoggerFactory.getLogger(BoBatchServiceImpl.class);

	private static final String BATCH_CD = "INTERVIEW_CAL";
	private static final String ICAL_PREFIX = "https://calendar.google.com/calendar/ical/";

	@Autowired
	private BoBatchDao BoBatchDao;

	private final RestTemplate rest;

	public BoBatchServiceImpl() {
		SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
		factory.setConnectTimeout(10000);
		factory.setReadTimeout(60000);
		rest = new RestTemplate(factory);
	}

	// 운영 DB 스키마 변경 경로가 앱 계정뿐이라 기동 때 맞춘다. 실패해도 다른 화면까지 막지 않도록 로그만 남긴다
	@PostConstruct
	public void ensureSchema() {
		try {
			BoBatchDao.EnsureSchema();
		} catch (Exception e) {
			log.error("배치 테이블 준비 실패: {}", InterviewCalendarParser.cleanError(e));
		}
	}

	// homepage 컨테이너가 UTC 이고 Spring 3.2 @Scheduled 에는 zone 이 없다. UTC 00:00 = 서울 09:00
	@Override
	@Scheduled(cron = "0 0 0 * * *")
	public void runInterviewScheduled() {
		List<Map<String, Object>> targets;
		try {
			targets = BoBatchDao.IcalAutoList();
		} catch (Exception e) {
			log.error("자동 실행 주소 조회 실패: {}", InterviewCalendarParser.cleanError(e));
			return;
		}
		if (targets.isEmpty()) {
			// 아무도 모르게 멈추지 않도록 이력에 남긴다
			run("AUTO", null, null);
		}
		for (Map<String, Object> target : targets) {
			run("AUTO", (String) target.get("ICAL_NM"), (String) target.get("ICAL_URL"));
		}
	}

	@Override
	public Map<String, Object> runInterview(int icalSq) {
		Map<String, Object> target = BoBatchDao.IcalOne(icalSq);
		if (target == null) {
			throw new IllegalArgumentException("선택한 iCal 주소를 찾을 수 없습니다.");
		}
		return run("MANUAL", (String) target.get("ICAL_NM"), (String) target.get("ICAL_URL"));
	}

	// 화면 버튼과 스케줄이 겹쳐도 같은 일정을 두 번 넣지 않게 한 번에 하나만 돈다
	private synchronized Map<String, Object> run(String triggerCd, String icalNm, String url) {
		Map<String, Object> run = new HashMap<>();
		run.put("BATCH_CD", BATCH_CD);
		run.put("TRIGGER_CD", triggerCd);
		run.put("ICAL_NM", icalNm);
		run.put("START_DT", LocalDateTime.now(InterviewCalendarParser.SEOUL).format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
		for (String key : new String[] { "READ_CNT", "INSERT_CNT", "UPDATE_CNT", "SAME_CNT", "EXCL_CNT", "SKIP_CNT" }) {
			run.put(key, 0);
		}
		LocalDate[] week = InterviewCalendarParser.weekOf(LocalDate.now(InterviewCalendarParser.SEOUL));
		run.put("FROM_DT", week[0].toString());
		run.put("TO_DT", week[1].toString());
		List<Map<String, Object>> details = new ArrayList<>();
		try {
			sync(url, week, run, details);
			run.put("STATUS_CD", (Integer) run.get("SKIP_CNT") > 0 ? "WARN" : "OK");
		} catch (Exception e) {
			log.error("면접 일정 배치 실패: {}", InterviewCalendarParser.cleanError(e));
			run.put("STATUS_CD", "FAIL");
			run.put("ERROR_MSG", InterviewCalendarParser.cleanError(e));
		}
		try {
			BoBatchDao.LogInsert(run, details);
		} catch (Exception e) {
			log.error("배치 이력 저장 실패: {}", InterviewCalendarParser.cleanError(e));
		}
		return run;
	}

	private void sync(String url, LocalDate[] week, Map<String, Object> run, List<Map<String, Object>> details) {
		if (url == null) {
			throw new IllegalStateException("자동 실행으로 지정한 iCal 주소가 없습니다.");
		}
		String ics = new String(rest.getForObject(URI.create(url), byte[].class), StandardCharsets.UTF_8);
		// 주소가 잘못돼 다른 페이지가 오면 '일정 0건 성공'으로 보이지 않게 한다
		if (!ics.contains("BEGIN:VCALENDAR")) {
			throw new IllegalStateException("iCal 형식의 응답이 아닙니다. 비공개 주소를 확인해 주세요.");
		}
		String from = week[0].toString(), to = week[1].toString();
		for (Map<String, String> event : InterviewCalendarParser.parseIcs(ics)) {
			String date = event.get("DATE");
			if (date == null || date.compareTo(from) < 0 || date.compareTo(to) > 0) {
				continue;
			}
			add(run, "READ_CNT");
			String title = event.get("TITLE");
			Map<String, Object> detail = new HashMap<>();
			detail.put("INTV_DT", date);
			detail.put("INTV_TM", event.get("TIME"));
			detail.put("EVT_TITLE", cut(InterviewCalendarParser.maskPhone(title), 500));
			details.add(detail);

			String excluded = InterviewCalendarParser.excludeReason(event);
			if (excluded != null) {
				add(run, "EXCL_CNT");
				detail.put("RESULT_CD", "EXCL");
				detail.put("REASON", excluded);
				continue;
			}
			Map<String, Object> row = InterviewCalendarParser.parseTitle(title);
			if (row == null || event.get("UID") == null) {
				add(run, "SKIP_CNT");
				detail.put("RESULT_CD", "SKIP");
				detail.put("REASON", "제목에서 이름·전화번호를 찾지 못함");
				continue;
			}
			detail.put("APLY_NM", row.get("APLY_NM"));
			row.put("GCAL_EVT_ID", event.get("UID"));
			row.put("INTV_DT", date);
			row.put("INTV_TM", event.get("TIME"));
			try {
				String result = apply(row);
				add(run, result + "_CNT");
				detail.put("RESULT_CD", result);
				detail.put("INTV_SQ", row.get("INTV_SQ"));
			} catch (Exception e) {
				// 한 건 때문에 나머지 일정을 놓치지 않는다
				log.error("면접 일정 저장 실패: {}", InterviewCalendarParser.cleanError(e));
				add(run, "SKIP_CNT");
				detail.put("RESULT_CD", "SKIP");
				detail.put("REASON", "면접관리 저장 실패");
			}
		}
	}

	/** @return 처리 결과 코드 INSERT, UPDATE, SAME */
	private String apply(Map<String, Object> row) {
		Map<String, Object> linked = BoBatchDao.IntvByGcalId(row);
		if (linked != null) {
			row.put("INTV_SQ", linked.get("INTV_SQ"));
			boolean same = row.get("INTV_DT").equals(linked.get("INTV_DT")) && row.get("INTV_TM").equals(linked.get("INTV_TM"))
					&& (row.get("ATTEND_ST") == null || hasText(linked.get("ATTEND_ST")))
					&& (row.get("RESULT_ST") == null || hasText(linked.get("RESULT_ST")));
			if (same) {
				return "SAME";
			}
			// 이미 연결된 행은 일정과 상태만 반영한다. 사람이 지운 연락처 등을 다시 채우지 않는다
			for (String key : new String[] { "APLY_TARGET", "APLY_ROUTE", "PHONE", "CAREER" }) {
				row.put(key, null);
			}
			BoBatchDao.IntvUpdate(row);
			return "UPDATE";
		}
		Map<String, Object> manual = BoBatchDao.IntvToLink(row);
		if (manual != null) {
			row.put("INTV_SQ", manual.get("INTV_SQ"));
			if (hasText(manual.get("INTV_TM"))) {
				row.put("INTV_TM", manual.get("INTV_TM"));
			}
			BoBatchDao.IntvUpdate(row);
			return "UPDATE";
		}
		// shortcut: 면접관리에서 지운 행은 그 주 다음 실행 때 다시 들어온다. 지운 일정 기록이 필요해지면 제외 목록을 둔다
		BoBatchDao.IntvInsert(row);
		return "INSERT";
	}

	private static boolean hasText(Object o) {
		return o != null && !o.toString().isEmpty();
	}

	private static String cut(String s, int max) {
		return s.length() > max ? s.substring(0, max) : s;
	}

	private static void add(Map<String, Object> run, String key) {
		run.put(key, (Integer) run.get(key) + 1);
	}

	@Override
	public List<Map<String, Object>> interviewLogList() {
		return BoBatchDao.LogList(Collections.<String, Object> singletonMap("BATCH_CD", BATCH_CD));
	}

	@Override
	public List<Map<String, Object>> interviewLogDetail(int logSq) {
		return BoBatchDao.LogDetail(logSq);
	}

	@Override
	public List<Map<String, Object>> icalList() {
		return BoBatchDao.IcalList();
	}

	@Override
	public void saveIcal(String name, String url) {
		String nm = name == null ? "" : name.trim(), trimmed = url == null ? "" : url.trim();
		if (nm.isEmpty() || nm.length() > 100) {
			throw new IllegalArgumentException("이름을 100자 이내로 입력해 주세요.");
		}
		// 서버가 이 주소를 직접 호출하므로 구글 캘린더 주소만 받는다. 공개 주소는 비공개 캘린더에서 404 가 난다
		if (!trimmed.startsWith(ICAL_PREFIX) || !trimmed.contains("/private-") || !trimmed.endsWith(".ics") || trimmed.length() > 500) {
			throw new IllegalArgumentException("구글 캘린더의 'iCal 형식의 비공개 주소'를 입력해 주세요. /private- 가 들어 있어야 합니다.");
		}
		try {
			BoBatchDao.IcalInsert(nm, trimmed);
		} catch (DataIntegrityViolationException e) { // MariaDB 드라이버에서는 DuplicateKeyException 으로 구분되지 않는다
			throw new IllegalArgumentException("이미 등록된 주소입니다.");
		}
	}

	@Override
	public void deleteIcal(int icalSq) {
		BoBatchDao.IcalDelete(icalSq);
	}

	@Override
	public void setIcalAuto(int icalSq, boolean auto) {
		BoBatchDao.IcalAutoUpdate(icalSq, auto ? "Y" : "N");
	}
}
