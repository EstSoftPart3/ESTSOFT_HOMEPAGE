package com.eep.bo.hr.service;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.encryption.InvalidPasswordException;
import org.apache.pdfbox.text.PDFTextStripper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import com.eep.bo.batch.service.GoogleDriveApi;
import com.eep.bo.batch.service.ResumeParser;
import com.eep.bo.hr.dao.BoHrDao;
import com.eep.bo.staff.service.BoStaffService;
import com.eep.mapper.BoEquipmentMapper;
import com.eep.mapper.BoHrMapper;
import com.eep.mapper.BoStaffMapper;

@Service
public class BoHrServiceImpl implements BoHrService {

	private static final List<String> STATUS_CODES = Arrays.asList("ING", "END", "DROP");
	private static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");
	private static final List<String> SKILL_COLS = Arrays.asList("SK_JSP", "SK_THYMELEAF", "SK_VUE", "SK_REACT", "SK_NODE_FE",
			"SK_SPRING", "SK_JAVA", "SK_NODE_BE", "SK_NEXACRO", "SK_WEBSQUARE", "SK_EXBUILDER");
	private static final List<String> SKILL_VALS = Arrays.asList("", "상", "중", "하");
	private static final List<String> WEEK_CODES = Arrays.asList("1", "2", "3", "OVER");
	// 목록에서 바로 고칠 수 있는 글자 칸. 코드·날짜 칸은 각 저장 메서드에서 따로 검사한다
	private static final List<String> INTV_TEXT_FIELDS = Arrays.asList("APLY_NM", "INTV_TM", "PHONE", "JOIN_DT");
	private static final List<String> TRAINEE_TEXT_FIELDS = Arrays.asList("TRN_NM", "AGE", "INTERVIEW_AVAIL");
	// 항목별 코드 그룹. 비어 있거나 파라미터가 없으면 값 없음으로 저장한다
	private static final String[][] INTV_CODES = { { "GENDER", "HR_GENDER" }, { "APLY_ROUTE", "HR_ROUTE" }, { "ATTEND_ST", "HR_ATTEND" },
			{ "RESULT_ST", "HR_RESULT" }, { "NOTICE_ST", "HR_NOTICE" }, { "JOIN_ST", "HR_JOIN" }, { "LOCAL_YN", "HR_LOCAL" }, { "LANG", "HR_LANG" }, { "HIRE_CD", "HR_HIRE" } };
	private static final String[][] TRAINEE_CODES = { { "LEAVE_NOTE", "HR_LEAVE" }, { "GENDER", "HR_GENDER" }, { "INTERVIEW_YN", "HR_INTERVIEW" },
			{ "LOCAL_YN", "HR_LOCAL" }, { "EARLY_YN", "HR_OXT" }, { "SPECIAL_YN", "HR_OXT" }, { "LANG", "HR_LANG" } };

	@Autowired
	private BoHrDao BoHrDao;
	@Autowired
	private BoHrMapper hrMapper;
	@Autowired
	private BoStaffMapper staffMapper;
	@Autowired
	private BoEquipmentMapper eqpMapper;
	@Autowired
	private BoStaffService staffService;
	@Autowired
	private com.eep.bo.staff.service.StaffDriveService staffDrive;
	@Autowired
	private com.eep.bo.batch.service.BoBatchService batchService;

	@Autowired
	private com.eep.bo.staff.service.StaffCareerService careerService;

	private TransactionTemplate tx;
	private org.springframework.jdbc.core.JdbcTemplate jdbc;

	@Autowired
	public void setDataSource(@Qualifier("dataSource") DataSource ds) { // dataSourceSpied 와 2개라 이름을 지정해야 기동된다
		tx = new TransactionTemplate(new DataSourceTransactionManager(ds));
		jdbc = new org.springframework.jdbc.core.JdbcTemplate(ds);
	}

	@Override
	public List<Map<String, Object>> CodeList() {
		return BoHrDao.CodeList();
	}

	@Override
	public List<Map<String, Object>> IntvList() {
		return BoHrDao.IntvList();
	}

	@Override
	public void IntvSave(Map<String, Object> param) {
		require(param, "APLY_NM", "이름을 입력해 주세요.");
		checkDate(param, "INTV_DT", "면접일자");
		checkCodes(param, INTV_CODES);
		// 추천·소개가 아니면 숨겨진 칸에 남은 추천자명을 저장하지 않는다
		if (!"REFERRAL".equals(param.get("APLY_ROUTE"))) {
			param.put("REFERRER", null);
		}
		if (str(param, "INTV_SQ").isEmpty()) {
			BoHrDao.IntvInsert(param);
		} else {
			Map<String, Object> before = hrMapper.selectIntvResume(param);
			BoHrDao.IntvUpdate(param);
			moveResume(before, param.get("INTV_DT"), param);
		}
	}

	@Override
	public Map<String, Object> ReadResume(byte[] pdf, String fileName) {
		// 원문과 파일은 남기지 않고 칸 값만 돌려준다
		try (PDDocument doc = PDDocument.load(pdf)) {
			PDFTextStripper stripper = new PDFTextStripper();
			stripper.setSortByPosition(true);
			return ResumeParser.parseAny(stripper.getText(doc), fileName);
		} catch (InvalidPasswordException e) {
			throw new IllegalArgumentException("암호가 걸린 PDF입니다. 암호를 해제한 뒤 다시 끌어 놓아 주세요.");
		} catch (java.io.IOException e) {
			throw new IllegalArgumentException("PDF를 읽지 못했습니다. 파일이 손상되지 않았는지 확인해 주세요.");
		}
	}

	@Override
	public void IntvResumeSave(Object intvSq, String kind, String fileName, byte[] pdf) {
		Map<String, Object> row = intvResume(intvSq);
		if (!hasText(row.get("INTV_DT"))) {
			throw new IllegalArgumentException("면접일자가 없어 파일을 올릴 폴더를 정할 수 없습니다.");
		}
		row.put("INTV_SQ", intvSq);
		if ("PROFILE".equals(kind)) { // 워드라 이력서 찾기(PDF)와 섞이지 않는다
			String id = batchService.saveResume((String) row.get("INTV_DT"), (String) row.get("APLY_NM"), fileName.startsWith("프로필") ? fileName : "프로필_" + fileName, pdf);
			jdbc.update("UPDATE TB_EEP_HR_INTV_M SET PROFILE_FILE_ID = ? WHERE INTV_SQ = ?", id, intvSq);
			return;
		}
		if ("PORTFOLIO".equals(kind)) {
			// 같은 이름 폴더에 두므로 이력서 찾기(GoogleDriveApi.resumePdf)가 건너뛰게 이름 앞에 표시한다
			String name = fileName.startsWith(GoogleDriveApi.PORTFOLIO_PREFIX) ? fileName : GoogleDriveApi.PORTFOLIO_PREFIX + "_" + fileName;
			row.put("PORTFOLIO_FILE_ID", batchService.saveResume((String) row.get("INTV_DT"), (String) row.get("APLY_NM"), name, pdf));
			hrMapper.updateIntvPortfolio(row);
			return;
		}
		row.put("RESUME_FILE_ID", batchService.saveResume((String) row.get("INTV_DT"), (String) row.get("APLY_NM"), fileName, pdf));
		hrMapper.updateIntvResume(row);
	}

	@Override
	public byte[] IntvResumeFile(Object intvSq, String kind) {
		Map<String, Object> row = intvResume(intvSq);
		if ("PORTFOLIO".equals(kind) || "PROFILE".equals(kind)) {
			// 포트폴리오·프로필은 올린 파일만 본다(폴더에서 찾지 않는다)
			String id = (String) row.get(kind + "_FILE_ID");
			return hasText(id) ? batchService.resumeFile(id, null, null) : null;
		}
		return batchService.resumeFile((String) row.get("RESUME_FILE_ID"), (String) row.get("INTV_DT"), (String) row.get("APLY_NM"));
	}

	private Map<String, Object> intvResume(Object intvSq) {
		Map<String, Object> p = new HashMap<>();
		p.put("INTV_SQ", intvSq);
		Map<String, Object> row = hrMapper.selectIntvResume(p);
		if (row == null) {
			throw new IllegalArgumentException("면접자를 찾을 수 없습니다.");
		}
		return row;
	}

	private static boolean hasText(Object v) {
		return v != null && !v.toString().trim().isEmpty();
	}

	@Override
	public void IntvDelete(Map<String, Object> param) {
		Map<String, Object> row = hrMapper.selectIntvResume(param);
		BoHrDao.IntvDelete(param);
		// 드라이브 이력서는 휴지통으로. 같은 날·같은 이름 면접자가 남아 있으면 그 사람 것이므로 둔다. 실패해도 삭제는 그대로, 안내만 한다
		if (row == null || hrMapper.countIntvSameDay(row) > 0) return;
		try {
			if (batchService.trashResume((String) row.get("RESUME_FILE_ID"), (String) row.get("INTV_DT"), (String) row.get("APLY_NM")) != null) {
				param.put("DRIVE_NOTE", "드라이브의 이력서 폴더를 휴지통으로 보냈습니다(30일 안에 되살릴 수 있음).");
			}
		} catch (Exception e) {
			param.put("DRIVE_NOTE", "면접자는 삭제했지만 드라이브 이력서는 지우지 못했습니다. 드라이브에서 직접 지워 주세요.");
		}
	}

	@Override
	public boolean TraineeFromIntv(Map<String, Object> param) {
		boolean ok = tx.execute(s -> {
			if (BoHrDao.TraineeFromIntv(param) == 0) return false;
			staffMapper.insertWaitFromTrainee(param); // 교육진행중으로 들어오므로 대기 카드를 만든다(INTV_SQ 로 찾음)
			return true;
		});
		// 드라이브 '1. 대기자 관리/(0000.00.00) 이름'. 실패해도 등록은 그대로, 안내 문구만 돌려준다
		if (ok) param.put("DRIVE_NOTE", staffDrive.traineeCreated(hrMapper.selectPersonName(param)));
		return ok;
	}

	@Override
	public boolean WaitFromIntv(Map<String, Object> param) {
		if (staffMapper.insertWaitFromIntv(param) == 0) return false;
		// 교육생과 같은 '1. 대기자 관리/(0000.00.00) 이름' 폴더. 직원으로 등록할 때 그 폴더를 이어 쓴다
		String drive = staffDrive.traineeCreated(hrMapper.selectPersonName(param));
		String filled = fillWaitCard(param);
		param.put("DRIVE_NOTE", String.join(" ", Arrays.asList(drive == null ? "" : drive, filled)).trim());
		return true;
	}

	// ── 면접결과 기록(칩) ──
	// 키 → [공통코드 그룹 이름, 기본 예시...]. 공통코드 HR_INTV_<키> 로 만들고, 그 뒤로는 화면의 ＋·✎ 나 공통코드관리에서 고친다(2026-11-20 사용자 승인)
	static final Map<String, String[]> NOTE_CODES = new java.util.LinkedHashMap<>();
	static {
		NOTE_CODES.put("SCHED", new String[] { "면접결과 일정", "즉시 가능", "상시 가능", "2주 내", "1개월 내", "협의 필요" });
		NOTE_CODES.put("AREA", new String[] { "면접결과 출근 가능 지역", "홍대", "여의도", "중구·종로", "잠실", "강남", "마곡", "판교", "구로·가산", "상암", "전 지역" });
		NOTE_CODES.put("DOMAIN", new String[] { "면접결과 업무단", "이커머스", "그룹웨어", "금융", "공공", "제조", "물류", "통신", "의료", "교육" });
		NOTE_CODES.put("WORK", new String[] { "면접결과 업무 형태", "개발", "운영", "상관없음" });
		NOTE_CODES.put("POS", new String[] { "면접결과 포지션", "풀스택", "백엔드", "프론트엔드", "퍼블리셔", "DBA", "PM·PL" });
		NOTE_CODES.put("SCORE", new String[] { "면접결과 점수", "상", "중상", "중", "중하", "하" });
		NOTE_CODES.put("FE", new String[] { "면접결과 프론트", "JSP", "jQuery", "JavaScript", "Vue.js", "React", "Thymeleaf", "WebSquare", "Nexacro" });
		NOTE_CODES.put("BE", new String[] { "면접결과 백엔드", "Java", "Spring", "Spring Boot", "전자정부 F/W", "Node.js", "Python", "C#" });
		NOTE_CODES.put("DB", new String[] { "면접결과 DB", "Oracle", "MySQL", "MariaDB", "PostgreSQL", "MSSQL", "Tibero" });
		NOTE_CODES.put("FW", new String[] { "면접결과 프레임워크", "Spring", "Spring Boot", "전자정부 F/W", "MyBatis", "JPA" });
		NOTE_CODES.put("SP", new String[] { "면접결과 특수", "Linux", "Jenkins", "Git", "SVN", "AWS", "Docker", "Jennifer" });
		NOTE_CODES.put("GRADE", new String[] { "면접결과 지원등급", "초급", "중급", "고급", "특급" });
		NOTE_CODES.put("PERS", new String[] { "면접결과 성격", "밝음", "차분함", "성실해 보임", "자신감 있음", "말투 불친절", "자기주장 강함", "소극적" });
		NOTE_CODES.put("COMM", new String[] { "면접결과 소통", "원활", "보통", "아쉬움" });
		NOTE_CODES.put("AUTO", new String[] { "면접결과 자동지원", "예", "아니오" });
		NOTE_CODES.put("CERT", new String[] { "면접결과 정보처리기사", "정보처리기사", "정보처리산업기사", "없음" });
		NOTE_CODES.put("VERDICT", new String[] { "면접결과 종합", "추천", "보통", "보류", "비추천" });
		NOTE_CODES.put("MAJOR", new String[] { "면접결과 전공", "전공", "유사 전공", "비전공" });
		NOTE_CODES.put("TRAIN", new String[] { "면접결과 교육 이수", "국비교육", "부트캠프", "학원", "독학", "없음" });
		NOTE_CODES.put("TECH", new String[] { "면접결과 기술 이해도", "상", "중상", "중", "중하", "하" });
		NOTE_CODES.put("ATTI", new String[] { "면접결과 태도", "성실함", "적극적", "밝음", "차분함", "소극적", "산만함" });
		NOTE_CODES.put("WILL", new String[] { "면접결과 입사 의지", "높음", "보통", "낮음" });
	}
	private static final com.fasterxml.jackson.databind.ObjectMapper JSON = new com.fasterxml.jackson.databind.ObjectMapper();
	private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(BoHrServiceImpl.class);

	/** 면접 표에 프로필·면접결과 칸을 넣고 칩 공통코드를 만든다(2026-11-20 사용자 승인). 이미 있으면 그대로 */
	@javax.annotation.PostConstruct
	public void ensureSchema() {
		try {
			jdbc.execute("ALTER TABLE TB_EEP_HR_INTV_M ADD COLUMN IF NOT EXISTS PROFILE_FILE_ID VARCHAR(100) NULL COMMENT '프로필 워드 드라이브 파일 ID'");
			jdbc.execute("ALTER TABLE TB_EEP_HR_INTV_M ADD COLUMN IF NOT EXISTS INTV_NOTE TEXT NULL COMMENT '면접결과 기록 JSON'");
			for (String k : NOTE_CODES.keySet()) noteGroup(k);
		} catch (RuntimeException e) {
			log.error("면접결과 칸·코드 준비 실패: {}", e.getClass().getSimpleName());
		}
	}

	/** HR_INTV_<키> 그룹 번호. 없으면 만들고 기본 예시를 넣는다. 칩은 이름을 그대로 값으로 쓴다 */
	private int noteGroup(String kind) {
		String[] def = NOTE_CODES.get(kind);
		if (def == null) throw new IllegalArgumentException("알 수 없는 항목입니다.");
		String grp = "HR_INTV_" + kind;
		List<Integer> g = jdbc.queryForList("SELECT COMN_CD_SQ FROM TB_EEP_COMN_CD_M WHERE COMN_CD = ? AND DEL_YN = 'N'", Integer.class, grp);
		if (!g.isEmpty()) return g.get(0);
		jdbc.update("INSERT INTO TB_EEP_COMN_CD_M (COMN_CD, COMN_CD_NM, NOTE, REG_DT, USE_YN, DEL_YN) VALUES (?, ?, '면접관리 면접결과 기록', NOW(), 'Y', 'N')", grp, def[0]);
		int sq = jdbc.queryForObject("SELECT COMN_CD_SQ FROM TB_EEP_COMN_CD_M WHERE COMN_CD = ? AND DEL_YN = 'N'", Integer.class, grp);
		for (int i = 1; i < def.length; i++) jdbc.update("INSERT INTO TB_EEP_COMN_DTL_CD_S (COMN_CD_SQ, COMN_DTL_CD, COMN_DTL_CD_NM, COMN_DTL_CD_ORD, REG_DT, USE_YN, DEL_YN) VALUES (?, ?, ?, ?, NOW(), 'Y', 'N')", sq, def[i], def[i], i);
		return sq;
	}

	@Override
	public List<Map<String, Object>> IntvCodeSave(String kind, String act, String raw) {
		String n = raw == null ? "" : raw.trim().replaceAll("\\s+", " ");
		if (n.isEmpty() || n.length() > 50) throw new IllegalArgumentException("이름은 1~50자로 넣어 주세요.");
		int g = noteGroup(kind);
		if ("DEL".equals(act)) {
			jdbc.update("UPDATE TB_EEP_COMN_DTL_CD_S SET DEL_YN = 'Y', UPDT_DT = NOW() WHERE COMN_CD_SQ = ? AND DEL_YN = 'N' AND COMN_DTL_CD_NM = ?", g, n);
		} else if (jdbc.queryForObject("SELECT COUNT(*) FROM TB_EEP_COMN_DTL_CD_S WHERE COMN_CD_SQ = ? AND COMN_DTL_CD_NM = ? AND DEL_YN = 'N'", Integer.class, g, n) == 0) {
			jdbc.update("INSERT INTO TB_EEP_COMN_DTL_CD_S (COMN_CD_SQ, COMN_DTL_CD, COMN_DTL_CD_NM, COMN_DTL_CD_ORD, REG_DT, USE_YN, DEL_YN)"
					+ " SELECT ?, ?, ?, IFNULL(MAX(COMN_DTL_CD_ORD), 0) + 1, NOW(), 'Y', 'N' FROM TB_EEP_COMN_DTL_CD_S WHERE COMN_CD_SQ = ?", g, n, n, g);
		}
		return CodeList();
	}

	@Override
	public void IntvNoteSave(Object intvSq, String note, String loginId) {
		String v = note == null || note.trim().isEmpty() || "{}".equals(note.trim()) ? null : note;
		if (v != null) {
			if (v.length() > 20000) throw new IllegalArgumentException("기록이 너무 깁니다. 메모를 줄여 주세요.");
			readNote(v); // JSON 이 아니면 저장하지 않는다
		}
		if (jdbc.update("UPDATE TB_EEP_HR_INTV_M SET INTV_NOTE = ?, UPDT_EMPLY_ID = ?, UPDT_DT = NOW() WHERE INTV_SQ = ?", v, loginId, intvSq) == 0) {
			throw new IllegalArgumentException("면접자를 찾을 수 없습니다.");
		}
	}

	private static Map<String, Object> readNote(String v) {
		try {
			Map<String, Object> m = JSON.readValue(v, new com.fasterxml.jackson.core.type.TypeReference<Map<String, Object>>() { });
			return m == null ? new HashMap<>() : m;
		} catch (java.io.IOException e) {
			throw new IllegalArgumentException("기록 형식이 올바르지 않습니다.");
		}
	}

	/**
	 * 대기 카드를 면접 정보로 채운다(비어 있는 칸만). 우선순위: 면접결과 기록 → 면접 칸 → 이력서 PDF.
	 * 프로필 워드가 있으면 SKILL INVENTORY 표를 수행이력으로 넣는다. 실패해도 등록은 그대로, 안내 문구만 돌려준다
	 */
	private String fillWaitCard(Map<String, Object> param) {
		List<Object> staff = jdbc.queryForList("SELECT STAFF_SQ FROM TB_EEP_HR_STAFF_M WHERE INTV_SQ = ?", Object.class, param.get("INTV_SQ"));
		if (staff.isEmpty()) return "";
		Object staffSq = staff.get(0);
		Map<String, Object> i = jdbc.queryForMap("SELECT DATE_FORMAT(INTV_DT, '%Y-%m-%d') AS INTV_DT, APLY_NM, ADDR, STATION, EDU, CAREER, HOBBY, SPECIALTY, LANG_NOTE, RESUME_FILE_ID, PROFILE_FILE_ID, INTV_NOTE FROM TB_EEP_HR_INTV_M WHERE INTV_SQ = ?", param.get("INTV_SQ"));
		Map<String, Object> n = hasText(i.get("INTV_NOTE")) ? readNote((String) i.get("INTV_NOTE")) : new HashMap<>();
		List<String> notes = new java.util.ArrayList<>();
		Map<String, Object> cv = new HashMap<>();
		try { // 이력서는 면접 칸이 빈 것을 채우는 데만 쓴다
			byte[] pdf = batchService.resumeFile((String) i.get("RESUME_FILE_ID"), (String) i.get("INTV_DT"), (String) i.get("APLY_NM"));
			if (pdf != null) try (PDDocument doc = PDDocument.load(pdf)) {
				PDFTextStripper st = new PDFTextStripper();
				st.setSortByPosition(true);
				cv = ResumeParser.parse(st.getText(doc));
			}
		} catch (Exception e) {
			notes.add("이력서는 읽지 못했습니다.");
		}
		String[][] cols = { // 직원 칸, 값, 칸 길이
				{ "ADDR", first(n.get("addr"), i.get("ADDR"), cv.get("ADDR")), "500" },
				{ "STATION", first(n.get("station"), i.get("STATION")), "200" },
				{ "WISH_LOC", join(n.get("area")), "500" },
				{ "WORK_DOMAIN", join(n.get("domain"), n.get("work"), n.get("pos")), "500" },
				{ "HS_NM", first(n.get("hs")), "200" },
				{ "UNIV_NM", first(n.get("univ")), "200" },
				{ "FINAL_EDU", first(i.get("EDU"), cv.get("EDU")), "50" },
				{ "SCORE", first(n.get("score")), "50" },
				{ "GRADE_NM", first(n.get("grade")), "50" },
				{ "REAL_CAREER", first(n.get("years")), "100" },
				{ "WISH_PRICE", first(n.get("price")), "200" },
				{ "SK_FE", join(n.get("fe")), "500" },
				{ "SK_BE", join(n.get("be")), "500" },
				{ "SK_DB", join(n.get("db")), "500" },
				{ "SK_FW", join(n.get("fw")), "500" },
				{ "EXPERTISE", join(n.get("sp")), "500" },
				{ "AUTO_APLY_YN", first(n.get("auto")), "20" },
				{ "CERT_DT", join(n.get("cert"), n.get("certDt")), "50" },
				{ "PREV_CAREER", first(i.get("CAREER"), cv.get("CAREER")), "500" },
				{ "HOBBY", first(i.get("HOBBY")), "200" },
				{ "SPECIALTY", first(i.get("SPECIALTY")), "200" },
				{ "LANG_SKILL", first(i.get("LANG_NOTE"), cv.get("LANG_NOTE")), "200" },
				{ "MEMO", first(param.get("REPORT")), "20000" } };
		int filled = 0;
		for (String[] c : cols) {
			if (c[1].isEmpty()) continue;
			String v = c[1].length() > Integer.parseInt(c[2]) ? c[1].substring(0, Integer.parseInt(c[2])) : c[1];
			filled += jdbc.update("UPDATE TB_EEP_HR_STAFF_M SET " + c[0] + " = ? WHERE STAFF_SQ = ? AND (" + c[0] + " IS NULL OR " + c[0] + " = '')", v, staffSq);
		}
		if (filled > 0) notes.add("면접 정보로 " + filled + "칸을 채웠습니다.");
		if (hasText(i.get("PROFILE_FILE_ID"))) {
			try {
				byte[] docx = batchService.resumeFile((String) i.get("PROFILE_FILE_ID"), null, null);
				List<Map<String, Object>> rows = com.eep.bo.staff.service.StaffCareerWord.parse(new java.io.ByteArrayInputStream(docx));
				notes.add(rows.isEmpty() ? "프로필에서 수행이력 표를 찾지 못했습니다." : "프로필에서 수행이력 " + careerService.importApply(staffSq, rows, "면접 프로필", (String) param.get("UPDT_EMPLY_ID")) + "건을 넣었습니다.");
			} catch (Exception e) {
				notes.add("프로필 수행이력은 넣지 못했습니다. 직원관리 수행이력에서 워드를 직접 가져와 주세요.");
			}
		}
		return String.join(" ", notes);
	}

	/** 처음으로 비어 있지 않은 값(목록이면 쉼표로 이은 것) */
	private static String first(Object... vs) {
		for (Object v : vs) {
			String s = join(v);
			if (!s.isEmpty()) return s;
		}
		return "";
	}

	/** 값·목록을 쉼표로 잇는다. 빈 것은 뺀다 */
	private static String join(Object... vs) {
		List<String> out = new java.util.ArrayList<>();
		for (Object v : vs) {
			if (v instanceof java.util.Collection) for (Object x : (java.util.Collection<?>) v) { if (hasText(x)) out.add(x.toString().trim()); }
			else if (hasText(v)) out.add(v.toString().trim());
		}
		return String.join(", ", out);
	}

	/** 면접일이 바뀌면 드라이브의 이력서 이름 폴더도 새 날짜 폴더로 옮긴다. 실패해도 저장은 그대로, 안내만 한다 */
	private void moveResume(Map<String, Object> before, Object newDt, Map<String, Object> param) {
		if (before == null || !hasText(newDt) || !hasText(before.get("INTV_DT")) || newDt.equals(before.get("INTV_DT"))) return;
		// 같은 날·같은 이름 면접자가 예전 날짜에 남아 있으면 누구 폴더인지 알 수 없어 두고 간다
		if (hrMapper.countIntvSameDay(before) > 0) return;
		try {
			if (batchService.moveResume((String) before.get("RESUME_FILE_ID"), (String) before.get("INTV_DT"), newDt.toString(), (String) before.get("APLY_NM"))) {
				param.put("DRIVE_NOTE", "드라이브의 이력서 폴더도 " + newDt + " 폴더로 옮겼습니다.");
			}
		} catch (Exception e) {
			param.put("DRIVE_NOTE", "면접일은 바꿨지만 드라이브 이력서 폴더는 옮기지 못했습니다. 드라이브에서 직접 옮겨 주세요.");
		}
	}

	/** 교육생 상태가 바뀐 뒤 드라이브 폴더: 새 교육생이면 대기자 관리에 만들고, 교육종료·중도이탈이면 퇴사자 관리로 옮긴다 */
	private void traineeDrive(Map<String, Object> param, String from, String to) {
		if (to.equals(from)) return;
		String name = hrMapper.selectPersonName(param);
		if (name == null) return;
		if (from == null && "ING".equals(to)) param.put("DRIVE_NOTE", staffDrive.traineeCreated(name));
		else if ("END".equals(to) || "DROP".equals(to)) param.put("DRIVE_NOTE", staffDrive.traineeLeft(name));
	}

	@Override
	public List<Map<String, Object>> TraineeList() {
		return BoHrDao.TraineeList();
	}

	@Override
	public void TraineeSave(Map<String, Object> param) {
		require(param, "TRN_NM", "이름을 입력해 주세요.");
		checkDate(param, "EDU_START_DT", "교육 시작일");
		if (!STATUS_CODES.contains(str(param, "STATUS_CD"))) {
			throw new IllegalArgumentException("상태를 선택해 주세요.");
		}
		checkCodes(param, TRAINEE_CODES);
		String from = str(param, "TRN_SQ").isEmpty() ? null : hrMapper.selectTraineeStatus(param);
		tx.execute(s -> {
			if (str(param, "TRN_SQ").isEmpty()) {
				BoHrDao.TraineeInsert(param);
			} else {
				BoHrDao.TraineeUpdate(param);
			}
			syncStaff(param.get("TRN_SQ"), from, str(param, "STATUS_CD"), param);
			return null;
		});
		traineeDrive(param, from, str(param, "STATUS_CD"));
	}

	@Override
	public void TraineeFieldSave(Map<String, Object> param) {
		String field = str(param, "FIELD"), value = str(param, "VALUE");
		// 컬럼명이 SQL 에 그대로 들어가므로 허용 목록으로만 받는다
		if (!TRAINEE_TEXT_FIELDS.contains(field) && !hasCodeField(TRAINEE_CODES, field) && !"STATUS_CD".equals(field) && !"EDU_WEEK".equals(field) && !"EDU_START_DT".equals(field)) {
			throw new IllegalArgumentException("이 항목은 목록에서 고칠 수 없습니다.");
		}
		if ("TRN_NM".equals(field) && value.trim().isEmpty()) {
			throw new IllegalArgumentException("이름을 입력해 주세요.");
		}
		if ("STATUS_CD".equals(field) && !STATUS_CODES.contains(value)) {
			throw new IllegalArgumentException("상태 값이 올바르지 않습니다.");
		}
		if ("EDU_WEEK".equals(field)) {
			if (!WEEK_CODES.contains(value)) {
				throw new IllegalArgumentException("주차 값이 올바르지 않습니다.");
			}
			param.put("WEEK_NO", "OVER".equals(value) ? 4 : Integer.parseInt(value));
			if (BoHrDao.TraineeWeekUpdate(param) == 0) {
				throw new IllegalArgumentException("교육 시작일이 없어 주차를 정할 수 없습니다. 시작일을 먼저 넣어 주세요.");
			}
			return;
		}
		if ("EDU_START_DT".equals(field)) {
			checkDate(param, "VALUE", "교육 시작일");
		}
		checkFieldCode(TRAINEE_CODES, field, param);
		if (!"STATUS_CD".equals(field)) {
			BoHrDao.TraineeFieldUpdate(param);
			return;
		}
		String from = hrMapper.selectTraineeStatus(param);
		tx.execute(s -> {
			BoHrDao.TraineeFieldUpdate(param);
			syncStaff(param.get("TRN_SQ"), from, value, param);
			return null;
		});
		traineeDrive(param, from, value);
	}

	/** 교육생 상태가 바뀌면 직원관리 대기 카드를 맞춘다. 교육종료·중도이탈은 대기 카드의 대여 장비를 반납하고, 중도이탈은 대기 카드를 지운다 */
	private void syncStaff(Object trnSq, String from, String to, Map<String, Object> param) {
		if (trnSq == null || to.equals(from)) return;
		Map<String, Object> key = new HashMap<>();
		key.put("TRN_SQ", trnSq);
		key.put("UPDT_EMPLY_ID", param.get("UPDT_EMPLY_ID"));
		Map<String, Object> staff = staffMapper.selectStaffByTrainee(key);
		// 이미 계약해 재직 등으로 옮긴 카드는 건드리지 않는다
		boolean waiting = staff != null && "WAIT".equals(staff.get("STATUS_CD"));
		if (waiting && !"ING".equals(to)) {
			Map<String, Object> s = new HashMap<>();
			s.put("STAFF_SQ", staff.get("STAFF_SQ"));
			List<Map<String, Object>> rents = eqpMapper.selectStaffEquipment(s);
			if (!rents.isEmpty()) {
				if (!"Y".equals(param.get("RETURN_YN"))) throw new NeedReturn(rents);
				s.put("END_DT", LocalDate.now(SEOUL).toString());
				s.put("UPDT_EMPLY_ID", param.get("UPDT_EMPLY_ID"));
				s.put("CONTENT", "교육생 " + ("END".equals(to) ? "교육종료" : "중도이탈") + " 처리로 자동 반납");
				eqpMapper.insertReturnMemoByStaff(s);
				eqpMapper.updateEquipmentReturnedByStaff(s);
				eqpMapper.closeRentsByStaff(s);
			}
		}
		if (!"DROP".equals(to)) {
			staffMapper.insertWaitFromTrainee(key);
		} else if (waiting) {
			Map<String, Object> s = new HashMap<>();
			s.put("STAFF_SQ", staff.get("STAFF_SQ"));
			staffService.delete(s);
		}
	}

	@Override
	public void IntvFieldSave(Map<String, Object> param) {
		String field = str(param, "FIELD"), value = str(param, "VALUE");
		if (!INTV_TEXT_FIELDS.contains(field) && !hasCodeField(INTV_CODES, field) && !"INTV_DT".equals(field)) {
			throw new IllegalArgumentException("이 항목은 목록에서 고칠 수 없습니다.");
		}
		if ("APLY_NM".equals(field) && value.trim().isEmpty()) {
			throw new IllegalArgumentException("이름을 입력해 주세요.");
		}
		if ("INTV_DT".equals(field)) {
			checkDate(param, "VALUE", "면접일자");
		}
		if ("HIRE_CD".equals(field) && value.trim().isEmpty()) {
			param.put("VALUE", "NEW"); // 구분은 비울 수 없는 칸이라 비우면 신입으로 둔다
		}
		checkFieldCode(INTV_CODES, field, param);
		Map<String, Object> before = "INTV_DT".equals(field) ? hrMapper.selectIntvResume(param) : null;
		BoHrDao.IntvFieldUpdate(param);
		moveResume(before, value, param);
		// 추천·소개가 아니게 되면 남은 추천자명을 지운다
		if ("APLY_ROUTE".equals(field) && !"REFERRAL".equals(value)) {
			BoHrDao.IntvReferrerClear(param);
		}
	}

	private static boolean hasCodeField(String[][] fields, String field) {
		return Arrays.stream(fields).anyMatch(f -> f[0].equals(field));
	}

	private void checkFieldCode(String[][] fields, String field, Map<String, Object> param) {
		for (String[] f : fields) {
			if (f[0].equals(field)) {
				Map<String, Object> one = new java.util.HashMap<>();
				one.put(field, param.get("VALUE"));
				checkCodes(one, new String[][] { f });
			}
		}
	}

	@Override
	public void TraineeSkillSave(Map<String, Object> param) {
		// 컬럼명이 SQL 에 그대로 들어가므로 허용 목록으로만 받는다
		if (!SKILL_COLS.contains(str(param, "SKILL_COL")) || !SKILL_VALS.contains(str(param, "SKILL_VAL"))) {
			throw new IllegalArgumentException("기술 평가 값이 올바르지 않습니다.");
		}
		BoHrDao.TraineeSkillUpdate(param);
	}

	@Override
	public void TraineeDelete(Map<String, Object> param) {
		String from = hrMapper.selectTraineeStatus(param);
		tx.execute(s -> {
			syncStaff(param.get("TRN_SQ"), from, "DROP", param); // 삭제도 중도이탈처럼 대기 카드를 정리한다
			BoHrDao.TraineeDelete(param);
			return null;
		});
	}

	private void checkCodes(Map<String, Object> param, String[][] fields) {
		List<Map<String, Object>> codes = BoHrDao.CodeList();
		for (String[] field : fields) {
			String vals = str(param, field[0]);
			// 외국어처럼 여러 개를 고르는 칸은 코드를 쉼표로 이어 보낸다
			for (String val : vals.isEmpty() ? new String[0] : vals.split(",")) {
				if (codes.stream().noneMatch(c -> field[1].equals(c.get("GRP")) && val.equals(c.get("CD")))) {
					throw new IllegalArgumentException("선택할 수 없는 값입니다: " + val);
				}
			}
		}
	}

	private static void require(Map<String, Object> param, String key, String message) {
		if (str(param, key).trim().isEmpty()) {
			throw new IllegalArgumentException(message);
		}
	}

	private static void checkDate(Map<String, Object> param, String key, String label) {
		String val = str(param, key);
		if (!val.isEmpty()) {
			try {
				LocalDate.parse(val);
			} catch (Exception e) {
				throw new IllegalArgumentException(label + "는 yyyy-MM-dd 형식으로 입력해 주세요.");
			}
		}
	}

	private static String str(Map<String, Object> param, String key) {
		Object val = param.get(key);
		return val == null ? "" : val.toString();
	}
}
