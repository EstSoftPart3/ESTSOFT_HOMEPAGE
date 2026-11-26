package com.eep.bo.batch.service;

import java.io.IOException;
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
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.annotation.PostConstruct;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.eep.bo.batch.dao.BoBatchDao;
import com.eep.bo.calendar.dao.BoCalendarDao;
import com.eep.bo.calendar.service.BoCalendarServiceImpl;
import com.eep.bo.my.GoogleLinkService;

@Service
public class BoBatchServiceImpl implements BoBatchService {

	private static final Logger log = LoggerFactory.getLogger(BoBatchServiceImpl.class);

	private static final String BATCH_CD = "INTERVIEW_CAL";
	private static final String ICAL_PREFIX = "https://calendar.google.com/calendar/ical/";
	private static final String CLIENT_ID_SUFFIX = ".apps.googleusercontent.com";
	private static final Pattern FOLDER_ID = Pattern.compile("^(?:https://drive\\.google\\.com/.*/folders/)?([\\w-]{10,})(?:[?/#].*)?$");
	// 이력서 칸 -> 화면 이름
	private static final String[][] RESUME_FIELDS = { { "ADDR", "주소" }, { "EDU", "학력" }, { "AGE", "나이" }, { "GENDER", "성별" }, { "CAREER", "경력" }, { "LANG", "외국어" } };
	// 일정 제목에서 넣은 신입·경력 표시와 이전 형식의 긴 요약(신입 · ...)은 이력서 경력으로 바꿔도 된다. 매퍼의 updateIntvFromResume 과 같은 조건
	private static final String TITLE_CAREER = "^(신입|경력)( [0-9년개월 ]+| · .*)?$";

	@Autowired
	private BoBatchDao BoBatchDao;

	@Autowired
	private BoCalendarDao BoCalendarDao;

	@Autowired
	private GoogleDriveApi GoogleDriveApi;

	@Autowired
	private GoogleLinkService googleLink;

	@Autowired
	private com.eep.bo.calendar.service.GoogleCalendarApi calendarApi;

	@Autowired
	private com.eep.bo.recruit.service.RecruitService recruitService;

	private final RestTemplate rest;
	private volatile LocalDateTime lastPreRunCheck;

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

	// homepage 컨테이너가 UTC 이고 Spring 3.2 @Scheduled 에는 zone 이 없다. UTC 00~09시 정각 = 서울 09~18시 매시(2026-11-26 사용자 요청)
	@Override
	@Scheduled(cron = "0 0 0-9 * * *")
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
			run("AUTO", Collections.<String, Object> emptyMap());
		}
		for (Map<String, Object> target : targets) {
			run("AUTO", target);
		}
		// 모집 캘린더(est.part2)의 모집·인터뷰도 같이 가져온다(최근 30일, 같은 일정은 한 번만). 결과는 모집 관리 「📅 캘린더」에
		try {
			Map<String, Object> r = recruitService.importCalendar(LocalDate.now(InterviewCalendarParser.SEOUL).minusDays(30), "AUTO");
			log.warn("모집 캘린더 가져오기 {} {}", r.get("OK"), r.get("CNT"));
		} catch (Exception e) {
			log.error("모집 캘린더 가져오기 실패: {}", InterviewCalendarParser.cleanError(e));
		}
	}

	// 면접 10분 전에 한 번 더 돌린다. 1분마다 면접관리에서 10분 뒤 면접을 찾는다. 시간대는 코드에서 서울로 계산한다
	@Override
	@Scheduled(cron = "0 * * * * *")
	public void runInterviewBeforeScheduled() {
		LocalDateTime now = LocalDateTime.now(InterviewCalendarParser.SEOUL).withSecond(0).withNano(0);
		LocalDateTime last = lastPreRunCheck == null ? now.minusMinutes(1) : lastPreRunCheck;
		boolean first = lastPreRunCheck == null;
		lastPreRunCheck = now;
		try {
			// 정상 로그 수준이 warn 이라 스케줄러 동작을 확인할 수 있게 warn 으로 남긴다. 개인정보 없이 시각만 적는다
			if (first) {
				log.warn("면접 전 배치 확인 시작 {}, 오늘 면접 시각 {}", now, BoBatchDao.IntvTimesOn(now.toLocalDate().toString()));
			}
			boolean due = false;
			for (LocalDateTime target : InterviewCalendarParser.preRunTargets(last, now)) {
				due |= BoBatchDao.IntvCountAt(target.toLocalDate().toString(), target.toLocalTime().format(DateTimeFormatter.ofPattern("HH:mm"))) > 0;
			}
			// 09:00 에는 정기 배치가 같이 돌므로 또 돌리지 않는다
			if (due && !(now.getHour() == 9 && now.getMinute() == 0)) {
				List<Map<String, Object>> targets = BoBatchDao.IcalAutoList();
				log.warn("면접 전 배치 실행 {}, 세트 {}개", now, targets.size());
				for (Map<String, Object> target : targets) {
					Map<String, Object> result = run("PRE", target);
					log.warn("면접 전 배치 결과 {}", result.get("STATUS_CD"));
				}
			}
		} catch (Exception e) {
			log.error("면접 전 배치 실패: {}", InterviewCalendarParser.cleanError(e));
		}
	}

	@Override
	public Map<String, Object> preRunStatus() {
		Map<String, Object> status = new HashMap<>();
		LocalDateTime check = lastPreRunCheck;
		status.put("lastCheck", check == null ? null : check.toLocalTime().format(DateTimeFormatter.ofPattern("HH:mm")));
		status.put("todayTimes", BoBatchDao.IntvTimesOn(LocalDate.now(InterviewCalendarParser.SEOUL).toString()));
		return status;
	}

	@Override
	public Map<String, Object> runInterview(int icalSq) {
		Map<String, Object> target = BoBatchDao.IcalOne(icalSq);
		if (target == null) {
			throw new IllegalArgumentException("선택한 세트를 찾을 수 없습니다.");
		}
		return run("MANUAL", target);
	}

	// 화면 버튼과 스케줄이 겹쳐도 같은 일정을 두 번 넣지 않게 한 번에 하나만 돈다
	private synchronized Map<String, Object> run(String triggerCd, Map<String, Object> target) {
		Map<String, Object> run = new HashMap<>();
		run.put("BATCH_CD", BATCH_CD);
		run.put("TRIGGER_CD", triggerCd);
		run.put("ICAL_NM", target.get("ICAL_NM"));
		run.put("START_DT", LocalDateTime.now(InterviewCalendarParser.SEOUL).format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
		for (String key : new String[] { "READ_CNT", "INSERT_CNT", "UPDATE_CNT", "SAME_CNT", "EXCL_CNT", "SKIP_CNT" }) {
			run.put(key, 0);
		}
		LocalDate[] week = InterviewCalendarParser.weekOf(LocalDate.now(InterviewCalendarParser.SEOUL));
		run.put("FROM_DT", week[0].toString());
		run.put("TO_DT", week[1].toString());
		List<Map<String, Object>> details = new ArrayList<>();
		try {
			sync((String) target.get("ICAL_URL"), week, run, details);
			run.put("STATUS_CD", (Integer) run.get("SKIP_CNT") > 0 ? "WARN" : "OK");
			fillResumes(details, target);
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
			throw new IllegalStateException("자동 실행으로 지정한 세트가 없습니다.");
		}
		String from = week[0].toString(), to = week[1].toString();
		List<String> unread = new ArrayList<>();
		List<Map<String, String>> events = readEvents(url, week, unread);
		for (String calId : unread) {
			// 캘린더 하나를 못 읽어도 나머지는 가져오고, 실행 상세에 실패로 남긴다
			add(run, "SKIP_CNT");
			Map<String, Object> detail = new HashMap<>();
			detail.put("RESULT_CD", "SKIP");
			detail.put("EVT_TITLE", cut("캘린더 " + calId, 500));
			detail.put("REASON", "캘린더를 읽지 못함(연결 계정에 공유됐는지 확인)");
			details.add(detail);
		}
		for (Map<String, String> event : events) {
			String date = event.get("DATE");
			if (date == null || date.compareTo(from) < 0 || date.compareTo(to) > 0) {
				continue;
			}
			add(run, "READ_CNT");
			String title = event.get("TITLE");
			// 개인 캘린더도 읽으므로 면접과 무관한 일정은 제목을 남기지 않고 제외 건수만 센다
			if (!InterviewCalendarParser.looksLikeInterview(title)) {
				add(run, "EXCL_CNT");
				continue;
			}
			Map<String, Object> detail = new HashMap<>();
			detail.put("INTV_DT", date);
			detail.put("INTV_TM", event.get("TIME"));
			detail.put("EVT_TITLE", cut(InterviewCalendarParser.maskPhone(title), 500));
			detail.put("ATTACH_FILE_ID", event.get("ATTACH"));
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

	/**
	 * 면접 일정. ICAL_URL 칸에 예전 iCal 비공개 주소가 있으면 그것을, 아니면 그 칸의 구글 캘린더 ID 를 회사 공용 캘린더 연결로 읽는다.
	 * 둘 다 parseIcs 와 같은 {UID, TITLE, STATUS, ALL_DAY, DATE, TIME} 로 맞춘다(UID 는 iCalUID 라 예전에 넣은 면접과 이어진다)
	 */
	private List<Map<String, String>> readEvents(String source, LocalDate[] week, List<String> unread) {
		if (source.startsWith(ICAL_PREFIX)) {
			String ics = new String(rest.getForObject(URI.create(source), byte[].class), StandardCharsets.UTF_8);
			// 주소가 잘못돼 다른 페이지가 오면 '일정 0건 성공'으로 보이지 않게 한다
			if (!ics.contains("BEGIN:VCALENDAR")) {
				throw new IllegalStateException("iCal 형식의 응답이 아닙니다. 비공개 주소를 확인해 주세요.");
			}
			return InterviewCalendarParser.parseIcs(ics);
		}
		String token = googleLink.accessToken(GoogleLinkService.COMPANY, GoogleLinkService.CALENDAR);
		List<Map<String, String>> events = new ArrayList<>();
		// 캘린더 여러 개는 쉼표로 이어 저장돼 있다. 초대로 여러 캘린더에 같이 올라온 일정은 한 번만 넣는다
		String[] calIds = source.split(",");
		java.util.Set<String> seen = new java.util.HashSet<>();
		List<Map<String, Object>> rows = new ArrayList<>();
		RuntimeException last = null;
		for (String calId : calIds) {
			try {
				rows.addAll(calendarApi.events(token, calId.trim(), week[0], week[1]));
			} catch (RuntimeException e) {
				log.error("면접 캘린더를 읽지 못함: {}", InterviewCalendarParser.cleanError(e));
				unread.add(calId.trim());
				last = e;
			}
		}
		if (last != null && unread.size() == calIds.length) {
			throw last; // 하나도 못 읽었으면 실행 자체를 실패로 남긴다
		}
		for (Map<String, Object> r : rows) {
			if (r.get("ICAL_UID") != null && !seen.add((String) r.get("ICAL_UID"))) continue;
			Map<String, String> e = new HashMap<>();
			String start = (String) r.get("START_DT"); // yyyy-MM-dd HH:mm:ss (서울)
			e.put("UID", (String) r.get("ICAL_UID"));
			e.put("TITLE", (String) r.get("EVT_TITLE"));
			e.put("ALL_DAY", (String) r.get("ALL_DAY_YN"));
			e.put("DATE", start.substring(0, 10));
			if (!"Y".equals(r.get("ALL_DAY_YN"))) e.put("TIME", start.substring(11, 16));
			e.put("ATTACH", (String) r.get("ATTACH_FILE_ID")); // 일정에 붙은 이력서. iCal 주소로 읽을 때는 없다
			events.add(e);
		}
		return events;
	}

	/** 면접 행마다 드라이브의 년도/월/일/이름 폴더에서 이력서를 찾아 빈 칸을 채운다. 결과는 실행 상세의 RESUME_NOTE 에 남긴다 */
	private void fillResumes(List<Map<String, Object>> details, Map<String, Object> target) {
		List<Map<String, Object>> targets = new ArrayList<>();
		for (Map<String, Object> d : details) {
			if (d.get("INTV_SQ") != null && d.get("APLY_NM") != null) {
				targets.add(d);
			}
		}
		if (targets.isEmpty()) {
			return;
		}
		// 회사 공용 드라이브 연동을 쓴다(GoogleLinkService.COMPANY)
		String root = (String) target.get("DRIVE_FOLDER_ID");
		if (!hasText(root)) {
			targets.forEach(d -> d.put("RESUME_NOTE", "이력서 폴더 미설정"));
			return;
		}
		String token;
		try {
			token = googleLink.accessToken(GoogleLinkService.COMPANY, GoogleLinkService.DRIVE);
		} catch (GoogleLinkService.NeedLink e) {
			targets.forEach(d -> d.put("RESUME_NOTE", "회사 공용 드라이브 미연결 - 시스템 관리자가 연결해 주세요"));
			return;
		} catch (Exception e) {
			log.error("드라이브 인증 실패: {}", InterviewCalendarParser.cleanError(e));
			targets.forEach(d -> d.put("RESUME_NOTE", "드라이브 인증 실패 - 다시 연결해 주세요"));
			return;
		}
		Map<String, String> dayFolders = new HashMap<>();
		for (Map<String, Object> d : targets) {
			try {
				d.put("RESUME_NOTE", fillResume(d, root, token, dayFolders));
			} catch (Exception e) {
				// 파일 하나 때문에 나머지 면접자를 놓치지 않는다. 원문이 섞일 수 있어 사유에는 예외 내용을 넣지 않는다
				log.error("이력서 처리 실패: {}", e.getClass().getSimpleName());
				d.put("RESUME_NOTE", "이력서 읽기 실패");
			}
		}
	}

	/**
	 * 이력서 파일을 찾아 면접 행에 기록하고(「이력서 보기」가 그 파일을 연다) 빈 칸을 채운다.
	 * 찾는 순서: 이미 기록된 파일 → 드라이브 날짜/이름 폴더 → 날짜 폴더의 이름_….pdf → 일정 첨부(드라이브 날짜/이름 폴더에 복사)
	 */
	private String fillResume(Map<String, Object> d, String root, String token, Map<String, String> dayFolders) throws IOException {
		Map<String, Object> current = BoBatchDao.IntvResumeCheck(d);
		if (current == null) {
			return "면접 행 없음";
		}
		String linked = null;
		Map<String, Object> file = null;
		if (hasText(current.get("RESUME_FILE_ID"))) {
			file = new HashMap<>();
			file.put("id", current.get("RESUME_FILE_ID"));
		} else {
			String[] how = new String[1];
			file = findResume(d, root, token, dayFolders, how);
			if (file == null) {
				return how[0];
			}
			BoBatchDao.IntvResumeLink(d.get("INTV_SQ"), (String) file.get("id"));
			linked = how[0];
		}
		List<String> blanks = new ArrayList<>();
		for (String[] field : RESUME_FIELDS) {
			boolean titleOnly = "CAREER".equals(field[0]) && current.get("CAREER") != null && current.get("CAREER").toString().matches(TITLE_CAREER);
			if (!hasText(current.get(field[0])) || titleOnly) {
				blanks.add(field[0]);
			}
		}
		String note = fillFromResume(d, file, token, blanks);
		return linked == null ? note : linked + " · " + note;
	}

	/** @param how [0] 에 찾은 경로(성공) 또는 못 찾은 사유(null 반환)를 넣는다 */
	private Map<String, Object> findResume(Map<String, Object> d, String root, String token, Map<String, String> dayFolders, String[] how) {
		LocalDate date = LocalDate.parse((String) d.get("INTV_DT"));
		String name = (String) d.get("APLY_NM");
		String day = dayFolders.containsKey(date.toString()) ? dayFolders.get(date.toString()) : dayFolder(root, date, token);
		dayFolders.put(date.toString(), day);
		if (day != null) {
			String person = GoogleDriveApi.childFolderId(day, name, token);
			// 이름 폴더를 만든 날과 날짜 폴더에 PDF 를 바로 둔 날이 섞여 있다
			Map<String, Object> file = person != null ? GoogleDriveApi.resumePdf(person, null, token) : GoogleDriveApi.resumePdf(day, name, token);
			if (file != null) {
				how[0] = "드라이브 이력서 연결";
				return file;
			}
		}
		String attach = (String) d.get("ATTACH_FILE_ID");
		if (!hasText(attach)) {
			how[0] = "이력서 없음(드라이브 날짜·이름 폴더와 일정 첨부 모두 없음)";
			return null;
		}
		// 일정 첨부는 올린 사람이 지우거나 공유를 끊으면 사라지므로 회사 이력서 폴더로 복사해 둔다
		byte[] pdf;
		String fileName;
		try {
			Map<String, Object> meta = new HashMap<>();
			meta.put("id", attach);
			pdf = GoogleDriveApi.download(meta, token);
			fileName = (String) GoogleDriveApi.file(attach, token).get("name");
		} catch (Exception e) {
			log.warn("일정 첨부 이력서를 받지 못함: {}", e.getClass().getSimpleName());
			how[0] = "일정 첨부 이력서를 열 수 없음(회사 공용 계정에 공유됐는지 확인)";
			return null;
		}
		String folder = folders(new String[] { root, token }, date.getYear() + "년도", date.getMonthValue() + "월", date.getDayOfMonth() + "일", name);
		Map<String, Object> saved = GoogleDriveApi.upload(hasText(fileName) ? fileName : name + "_이력서.pdf", "application/pdf", pdf, folder, token);
		how[0] = "일정 첨부 이력서 저장";
		return saved;
	}

	private String fillFromResume(Map<String, Object> d, Map<String, Object> file, String token, List<String> blanks) throws IOException {
		if (blanks.isEmpty()) {
			return "이미 입력됨";
		}
		Map<String, Object> found;
		try (PDDocument pdf = PDDocument.load(GoogleDriveApi.download(file, token))) {
			PDFTextStripper stripper = new PDFTextStripper();
			stripper.setSortByPosition(true);
			found = ResumeParser.parse(stripper.getText(pdf));
		}
		List<String> filled = new ArrayList<>();
		for (String[] field : RESUME_FIELDS) {
			if (found.get(field[0]) != null && blanks.contains(field[0])) {
				filled.add(field[1]);
			}
		}
		if (filled.isEmpty()) {
			return found.isEmpty() ? "항목을 찾지 못함" : "새로 채울 칸 없음";
		}
		found.put("INTV_SQ", d.get("INTV_SQ"));
		BoBatchDao.IntvFromResume(found);
		return "반영: " + String.join(", ", filled);
	}

	@Override
	public String saveResume(String intvDt, String name, String fileName, byte[] pdf) {
		String[] drive = resumeDrive();
		LocalDate date = LocalDate.parse(intvDt);
		String folder = folders(drive, date.getYear() + "년도", date.getMonthValue() + "월", date.getDayOfMonth() + "일", name);
		String mime = fileName.toLowerCase().endsWith(".docx") ? "application/vnd.openxmlformats-officedocument.wordprocessingml.document" : "application/pdf"; // 면접 프로필은 워드
		return (String) GoogleDriveApi.upload(fileName, mime, pdf, folder, drive[1]).get("id");
	}

	/** 이력서 최상위 폴더 아래로 폴더를 차례로 찾고 없으면 만든다. fillResume·resumeFile 이 찾는 경로와 같다 */
	private String folders(String[] drive, String... parts) {
		String folder = drive[0];
		for (String part : parts) {
			String id = GoogleDriveApi.childFolderId(folder, part, drive[1]);
			folder = id != null ? id : GoogleDriveApi.createFolder(part, folder, drive[1]);
		}
		return folder;
	}

	@Override
	public byte[] resumeFile(String fileId, String intvDt, String name) {
		String[] drive = resumeDrive();
		Map<String, Object> file;
		if (hasText(fileId)) {
			file = new HashMap<>();
			file.put("id", fileId);
		} else {
			if (!hasText(intvDt) || !hasText(name)) return null;
			String day = dayFolder(drive[0], LocalDate.parse(intvDt), drive[1]);
			if (day == null) return null;
			String person = GoogleDriveApi.childFolderId(day, name, drive[1]);
			file = person != null ? GoogleDriveApi.resumePdf(person, null, drive[1]) : GoogleDriveApi.resumePdf(day, name, drive[1]);
			if (file == null) return null;
		}
		return GoogleDriveApi.download(file, drive[1]);
	}

	@Override
	public String trashResume(String fileId, String intvDt, String name) {
		String[] drive = resumeDrive();
		String target = resumeTarget(drive, fileId, intvDt, name);
		if (target == null) return null;
		String from = parentOf(target, drive[1]);
		GoogleDriveApi.trash(target, drive[1]);
		sweep(from, drive);
		return target;
	}

	@Override
	public boolean moveResume(String fileId, String oldDt, String newDt, String name) {
		if (!hasText(newDt) || newDt.equals(oldDt)) return false;
		String[] drive = resumeDrive();
		String target = resumeTarget(drive, fileId, oldDt, name);
		if (target == null) return false;
		LocalDate date = LocalDate.parse(newDt);
		String from = parentOf(target, drive[1]), to = folders(drive, date.getYear() + "년도", date.getMonthValue() + "월", date.getDayOfMonth() + "일");
		if (to.equals(from)) return false; // 이미 그 날짜 폴더에 있다(사람이 먼저 옮겼거나 올린 뒤 그대로)
		GoogleDriveApi.move(target, to, null, drive[1]);
		sweep(from, drive);
		return true;
	}

	/** 면접자의 이력서 자리: 이름 폴더, 없으면 날짜 폴더에 바로 둔 PDF. 못 찾으면 null */
	private String resumeTarget(String[] drive, String fileId, String intvDt, String name) {
		if (hasText(fileId)) {
			// 올린 파일은 지금 있는 곳에서 찾는다(면접일을 옮긴 뒤에도 맞다). 부모가 이름 폴더면 폴더째
			String parent = parentOf(fileId, drive[1]);
			return parent != null && String.valueOf(name).equals(GoogleDriveApi.file(parent, drive[1]).get("name")) ? parent : fileId;
		}
		if (!hasText(intvDt) || !hasText(name)) return null;
		String day = dayFolder(drive[0], LocalDate.parse(intvDt), drive[1]);
		if (day == null) return null;
		String person = GoogleDriveApi.childFolderId(day, name, drive[1]);
		if (person != null) return person;
		Map<String, Object> pdf = GoogleDriveApi.resumePdf(day, name, drive[1]);
		return pdf == null ? null : (String) pdf.get("id");
	}

	@SuppressWarnings("unchecked")
	private String parentOf(String id, String token) {
		List<String> parents = (List<String>) GoogleDriveApi.file(id, token).get("parents");
		return parents == null || parents.isEmpty() ? null : parents.get(0);
	}

	/** 비게 된 일·월 폴더를 휴지통으로 보낸다. 연도 폴더와 이력서 최상위 폴더는 두고, 다른 면접자가 있으면 멈춘다 */
	private void sweep(String folder, String[] drive) {
		for (int level = 0; level < 2 && folder != null && !folder.equals(drive[0]) && GoogleDriveApi.children(folder, drive[1]).isEmpty(); level++) {
			String next = parentOf(folder, drive[1]);
			GoogleDriveApi.trash(folder, drive[1]);
			folder = next;
		}
	}

	/** 면접 이력서 폴더(신입면접 배치 첫 세트와 같은 값)와 회사 공용 드라이브 토큰 */
	private String[] resumeDrive() {
		List<Map<String, Object>> sets = BoBatchDao.IcalList();
		String root = sets.isEmpty() ? null : (String) sets.get(0).get("DRIVE_FOLDER_ID");
		if (!hasText(root)) {
			throw new IllegalArgumentException("면접 이력서 폴더가 정해지지 않았습니다. 시스템 관리자가 내 연동에서 폴더를 골라 주세요.");
		}
		return new String[] { root, googleLink.accessToken(GoogleLinkService.COMPANY, GoogleLinkService.DRIVE) };
	}

	private String dayFolder(String root, LocalDate date, String token) {
		String year = GoogleDriveApi.childFolderId(root, date.getYear() + "년도", token);
		String month = year == null ? null : GoogleDriveApi.childFolderId(year, date.getMonthValue() + "월", token);
		return month == null ? null : GoogleDriveApi.childFolderId(month, date.getDayOfMonth() + "일", token);
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
			for (String key : new String[] { "APLY_TARGET", "APLY_ROUTE", "REFERRER", "PHONE", "CAREER", "HIRE_CD" }) {
				row.put(key, null);
			}
			BoBatchDao.IntvUpdate(row);
			// 구글 캘린더 날짜로 되돌리거나 바뀔 때 이력서 폴더도 그 날짜로 맞춘다. 사람이 이미 옮겼으면 할 일이 없고, 실패해도 일정 반영은 그대로다
			try {
				moveResume((String) linked.get("RESUME_FILE_ID"), (String) linked.get("INTV_DT"), (String) row.get("INTV_DT"), (String) linked.get("APLY_NM"));
			} catch (Exception e) {
				// 다음에 날짜가 또 바뀌거나 화면에서 옮길 때 다시 시도된다
			}
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
		List<Map<String, Object>> list = new ArrayList<>();
		for (Map<String, Object> row : BoBatchDao.IcalList()) {
			// 비공개 주소와 토큰은 화면으로 내보내지 않는다
			// 공용 캘린더 연결로 바꾼 뒤에는 이 칸이 캘린더 ID 라 가릴 것이 없다(ICAL_MASK 는 예전 iCal 일 때만)
			String src = (String) row.remove("ICAL_URL");
			row.put("ICAL_MASK", src != null && src.startsWith(ICAL_PREFIX) ? InterviewCalendarParser.maskIcalUrl(src) : null);
			row.put("DRIVE_CONNECTED", "Y".equals(row.remove("DRIVE_LINKED")));
			row.put("FOLDER_MASK", InterviewCalendarParser.maskMiddle((String) row.remove("DRIVE_FOLDER_ID")));
			list.add(row);
		}
		return list;
	}

	@Override
	public void saveIcal(Integer icalSq, String name, String url, String folder) {
		String nm = name == null ? "" : name.trim(), trimmed = url == null ? "" : url.trim(), folderText = folder == null ? "" : folder.trim();
		if (nm.isEmpty() || nm.length() > 100) {
			throw new IllegalArgumentException("이름을 100자 이내로 입력해 주세요.");
		}
		// 수정할 때 비워 두면 기존 주소를 유지한다(화면에 다시 보여주지 않으므로)
		if (!(icalSq != null && trimmed.isEmpty())
				// 서버가 이 주소를 직접 호출하므로 구글 캘린더 주소만 받는다. 공개 주소는 비공개 캘린더에서 404 가 난다
				&& (!trimmed.startsWith(ICAL_PREFIX) || !trimmed.contains("/private-") || !trimmed.endsWith(".ics") || trimmed.length() > 500)) {
			throw new IllegalArgumentException("구글 캘린더의 'iCal 형식의 비공개 주소'를 입력해 주세요. /private- 가 들어 있어야 합니다.");
		}
		String folderId = null;
		if (!folderText.isEmpty()) {
			Matcher m = FOLDER_ID.matcher(folderText);
			if (!m.matches()) {
				throw new IllegalArgumentException("이력서 폴더 주소를 확인해 주세요.");
			}
			folderId = m.group(1);
		}
		try {
			BoBatchDao.IcalSave(icalSq, nm, trimmed, folderId);
		} catch (DataIntegrityViolationException e) { // MariaDB 드라이버에서는 DuplicateKeyException 으로 구분되지 않는다
			throw new IllegalArgumentException("이미 등록된 iCal 주소입니다.");
		}
	}

	@Override
	public Map<String, Object> driveStatus() {
		Map<String, String> conf = BoCalendarDao.ConfMap();
		Map<String, Object> status = new HashMap<>();
		String clientId = conf.get(BoCalendarServiceImpl.CONF_CLIENT_ID), secret = conf.get(BoCalendarServiceImpl.CONF_CLIENT_SECRET);
		status.put("clientMask", InterviewCalendarParser.maskMiddle(clientId));
		status.put("secretMask", hasText(secret) ? "****" + secret.substring(Math.max(0, secret.length() - 4)) : null);
		status.put("clientReady", validClient(clientId, secret));
		return status;
	}

	@Override
	public void saveDriveConf(String clientId, String clientSecret) {
		String id = clientId == null ? "" : clientId.trim(), secret = clientSecret == null ? "" : clientSecret.trim();
		// 브라우저 자동완성으로 이메일이나 계정 비밀번호가 들어가는 것을 막는다. 비운 칸은 기존 값을 유지한다
		if (!id.isEmpty() && !id.endsWith(CLIENT_ID_SUFFIX)) {
			throw new IllegalArgumentException("클라이언트 ID가 올바르지 않습니다. " + CLIENT_ID_SUFFIX + " 로 끝나는 값을 입력해 주세요.");
		}
		if (!secret.isEmpty() && !secret.startsWith("GOCSPX-")) {
			throw new IllegalArgumentException("클라이언트 시크릿이 올바르지 않습니다. GOCSPX- 로 시작하는 값을 입력해 주세요.");
		}
		if (!id.isEmpty()) {
			BoCalendarDao.ConfSave(BoCalendarServiceImpl.CONF_CLIENT_ID, id);
		}
		if (!secret.isEmpty()) {
			BoCalendarDao.ConfSave(BoCalendarServiceImpl.CONF_CLIENT_SECRET, secret);
		}
	}

	private static boolean validClient(String clientId, String secret) {
		return clientId != null && clientId.endsWith(CLIENT_ID_SUFFIX) && secret != null && secret.startsWith("GOCSPX-");
	}

	@Override
	public Map<String, Object> interviewSource() {
		List<Map<String, Object>> rows = BoBatchDao.IcalList();
		Map<String, Object> out = new HashMap<>();
		if (rows.isEmpty()) return out;
		Map<String, Object> r = rows.get(0);
		String src = (String) r.get("ICAL_URL");
		out.put("ICAL_SQ", r.get("ICAL_SQ"));
		out.put("AUTO_YN", r.get("AUTO_YN"));
		out.put("CAL_NM", r.get("ICAL_NM"));
		// 예전 iCal 주소면 캘린더 ID 가 아니다(목록에서 다시 고르게 한다)
		out.put("CAL_ID", src == null || src.startsWith(ICAL_PREFIX) ? null : src);
		out.put("LEGACY_ICAL", src != null && src.startsWith(ICAL_PREFIX));
		out.put("FOLDER_MASK", InterviewCalendarParser.maskMiddle((String) r.get("DRIVE_FOLDER_ID")));
		out.put("FOLDER_ID", r.get("DRIVE_FOLDER_ID")); // 화면에는 내보내지 않고 폴더 경로 이름을 찾는 데만 쓴다(BoMyController)
		return out;
	}

	/** 면접 일정은 한 세트(첫 줄)만 쓴다. 캘린더는 회사 공용 캘린더 연결에서 고른 ID. 캘린더·폴더 중 비운 쪽은 그대로 둔다 */
	@Override
	public void saveInterviewSource(String calId, String calName, String folder) {
		String id = calId == null ? "" : calId.trim(), nm = calName == null || calName.trim().isEmpty() ? "면접일정" : calName.trim();
		List<Map<String, Object>> current = BoBatchDao.IcalList();
		if (id.isEmpty()) {
			// 폴더만 바꿀 때: 지금 캘린더(예전 iCal 포함)와 이름을 그대로 둔다
			if (current.isEmpty()) throw new IllegalArgumentException("면접 캘린더를 먼저 골라 주세요.");
			Object old = current.get(0).get("ICAL_NM");
			nm = old == null ? nm : String.valueOf(old);
		} else {
			// 캘린더 여러 개는 쉼표로 이어 저장한다(구글 캘린더 ID 에는 쉼표가 없다)
			java.util.Set<String> ids = new java.util.LinkedHashSet<>();
			for (String part : id.split(",")) {
				if (part.trim().startsWith("http")) throw new IllegalArgumentException("면접 캘린더를 목록에서 골라 주세요.");
				if (!part.trim().isEmpty()) ids.add(part.trim());
			}
			id = String.join(",", ids);
			if (id.isEmpty() || id.length() > 500) throw new IllegalArgumentException("면접 캘린더를 목록에서 골라 주세요. 너무 많이 고르면 저장할 수 없습니다.");
		}
		String folderText = folder == null ? "" : folder.trim(), folderId = null;
		if (!folderText.isEmpty()) {
			Matcher m = FOLDER_ID.matcher(folderText);
			if (!m.matches()) throw new IllegalArgumentException("이력서 폴더 주소를 확인해 주세요.");
			folderId = m.group(1);
		}
		Integer sq = current.isEmpty() ? null : ((Number) current.get(0).get("ICAL_SQ")).intValue();
		BoBatchDao.IcalSave(sq, nm.length() > 100 ? nm.substring(0, 100) : nm, id, folderId);
	}

	@Override
	public void setDriveOwner(int icalSq, String emplyId) {
		BoBatchDao.IcalDrive(icalSq, emplyId);
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
