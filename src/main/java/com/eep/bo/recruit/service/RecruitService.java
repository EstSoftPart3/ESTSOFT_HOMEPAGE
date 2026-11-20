package com.eep.bo.recruit.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import javax.annotation.PostConstruct;
import javax.sql.DataSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;

import com.common.upload.Upload;
import com.eep.bo.batch.service.GoogleDriveApi;
import com.eep.bo.calendar.dao.BoCalendarDao;
import com.eep.bo.deploy.service.BoDeployService;
import com.eep.bo.my.DriveConfService;
import com.eep.bo.my.GoogleLinkService;
import com.eep.bo.staff.service.StaffCareerService;
import com.eep.bo.system.service.MailConfService;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * 모집 관리(plans/deploy-recruit-split-spec.html). 모집은 우리 시스템에 등록한 것이 주 데이터다(구글 캘린더와 연동하지 않는다, 2026-11-18 사용자 결정).
 * 원문 붙여넣기 등록 → 대기자 지원(프로필 워드를 모집 드라이브 폴더에) → 진행 단계(서류검토 → 인터뷰대기 → 인터뷰확정 → 투입대기 → 투입확정, 탈락·취소)
 * → 인터뷰 알림 메일(본인 회사 메일) → 투입확정이면 투입현황에 투입 예정.
 * 표가 이 기능 전용이고 칸이 많아 매퍼 XML 대신 JdbcTemplate 으로 둔다(StaffCareerService 와 같음).
 */
@Service
public class RecruitService {

	private static final Logger log = LoggerFactory.getLogger(RecruitService.class);

	public static final String PAGE = "/admin/recruit/openRecruitList.do";
	public static final String MAIL_INTV = "RECRUIT_INTV";
	/** 지원 단계 순서. DROP 은 탈락·취소 */
	// INTV_SUB 인터뷰 결과 제출(본인이 링크로 기록 제출), INTV_CHK 인터뷰 결과 확인중(관리자가 기록을 열어 보거나 직접 기록)
	public static final List<String> STEPS = Arrays.asList("DOC", "INTV_WAIT", "INTV", "INTV_SUB", "INTV_CHK", "JOIN_WAIT", "JOIN");
	static final String ACTIVE_IN = "('DOC', 'INTV_WAIT', 'INTV', 'INTV_SUB', 'INTV_CHK', 'JOIN_WAIT')";
	private static final List<String> STATUS = Arrays.asList("OPEN", "APPLY", "FILLED", "CLOSED");
	/** 사람이 고칠 수 있는 모집 칸 */
	private static final List<String> EDIT_COLS = Arrays.asList("CLIENT_NM", "PRJ_NM", "GRADE_TXT", "HEAD_CNT", "START_DT", "END_DT", "PERIOD_TXT", "WORK_AREA", "PRICE_TXT",
			"SKILLS", "PREFER", "SALE_PARTNER_SQ", "SALE_PARTNER_TXT", "MGR_NM", "CLOSE_DT", "MEMO");
	private static final List<String> DATE_COLS = Arrays.asList("START_DT", "END_DT", "CLOSE_DT");
	private static final String CONF_MENU = "RECRUIT.MENU_DONE";

	/** 인터뷰 기록 칩 목록(공통코드 RC_INTV_*). 키 → { 그룹 이름, 기본 예시... }. 그룹이 없을 때만 기본 예시를 넣고, 그 뒤는 화면의 ＋/✎ 로 고친다 */
	static final Map<String, String[]> INTV_CODES = new LinkedHashMap<>();
	static {
		INTV_CODES.put("MOOD", new String[] { "인터뷰 분위기", "편안함", "평범함", "평범하고 살짝 무거움", "무거움·압박", "형식적·짧음" });
		INTV_CODES.put("WHO", new String[] { "인터뷰 면접관", "PM", "PL·기술 담당", "고객사 현업", "인사·구매", "우리 회사 동행" });
		INTV_CODES.put("DUR", new String[] { "인터뷰 소요 시간", "10분 이내", "20분", "30분", "1시간", "1시간 넘게" });
		INTV_CODES.put("FLOW", new String[] { "인터뷰 진행 흐름", "자기소개", "이력서 기반 질문", "최근 프로젝트 설명", "기술 상세 질문", "실무 상황 질문", "코딩·화면 테스트", "질문 거의 없음" });
		INTV_CODES.put("ASKD", new String[] { "인터뷰 많이 받은 질문", "기술 경험 깊이", "장애·이슈 대응", "업무 도메인", "협업·소통", "투입 가능일", "근무지·출퇴근", "단가·조건", "이직·공백 사유", "장기 근무 가능 여부" });
		INTV_CODES.put("TECH", new String[] { "인터뷰 질문받은 기술" });
		INTV_CODES.put("FEEL", new String[] { "인터뷰 본인 느낌", "잘 본 것 같음", "무난함", "일부 답변 아쉬움", "잘 모르겠음" });
		INTV_CODES.put("CLI", new String[] { "인터뷰 고객 반응", "호의적", "보통", "무덤덤", "부정적" });
		INTV_CODES.put("ETC", new String[] { "인터뷰 특이사항", "바로 투입 원함", "투입일 조율 언급", "재택·근무 형태 언급", "2차 인터뷰 예정", "다른 후보 있음", "단가 언급", "장비·보안 안내 받음" });
		INTV_CODES.put("NOTICE", new String[] { "인터뷰 결과 안내", "당일", "1~2일 내", "이번 주", "언급 없음" });
	}
	private static final ObjectMapper JSON = new ObjectMapper();
	private static final DateTimeFormatter DT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
	private static final java.time.ZoneId SEOUL = java.time.ZoneId.of("Asia/Seoul");

	private JdbcTemplate jdbc;

	@Autowired
	private BoCalendarDao confDao;
	@Autowired
	private GoogleLinkService googleLink;
	@Autowired
	private GoogleDriveApi drive;
	@Autowired
	private DriveConfService driveConf;
	@Autowired
	private StaffCareerService career;
	@Autowired
	private BoDeployService deployService;
	@Autowired
	private MailConfService mailConf;

	@Autowired
	public void setDataSource(@Qualifier("dataSource") DataSource ds) {
		jdbc = new JdbcTemplate(ds);
	}

	// ── 표·메뉴 준비 (운영 DB 스키마 변경 경로가 앱 계정뿐이라 기동 때 맞춘다, BoBatchServiceImpl 과 같음) ──

	@PostConstruct
	public void ensureSchema() {
		try {
			jdbc.execute("CREATE TABLE IF NOT EXISTS TB_EEP_RECRUIT_M (RECRUIT_SQ INT AUTO_INCREMENT PRIMARY KEY, RAW_TEXT TEXT NULL COMMENT '등록 원문',"
					+ " CLIENT_NM VARCHAR(200) NULL, PRJ_NM VARCHAR(300) NULL, GRADE_TXT VARCHAR(100) NULL, HEAD_CNT INT NULL,"
					+ " START_DT DATE NULL, END_DT DATE NULL, PERIOD_TXT VARCHAR(200) NULL, WORK_AREA VARCHAR(300) NULL, PRICE_TXT VARCHAR(300) NULL, SKILLS VARCHAR(500) NULL, PREFER VARCHAR(500) NULL,"
					+ " SALE_PARTNER_SQ INT NULL, SALE_PARTNER_TXT VARCHAR(200) NULL, MGR_NM VARCHAR(100) NULL, CLOSE_DT DATE NULL, MEMO TEXT NULL, STATUS_CD VARCHAR(10) NOT NULL DEFAULT 'OPEN',"
					+ " FOLDER_ID VARCHAR(100) NULL, DEL_YN CHAR(1) NOT NULL DEFAULT 'N',"
					+ " REG_EMPLY_ID VARCHAR(50) NULL, REG_DT DATETIME NOT NULL, UPDT_EMPLY_ID VARCHAR(50) NULL, UPDT_DT DATETIME NULL) COMMENT '모집'");
			jdbc.execute("CREATE TABLE IF NOT EXISTS TB_EEP_RECRUIT_APPLY_R (APPLY_SQ INT AUTO_INCREMENT PRIMARY KEY, RECRUIT_SQ INT NOT NULL, STAFF_SQ INT NOT NULL, STEP_CD VARCHAR(10) NOT NULL DEFAULT 'DOC',"
					+ " VER_NO INT NULL, VER_LABEL VARCHAR(50) NULL, FILE_ID VARCHAR(100) NULL, FILE_NM VARCHAR(200) NULL,"
					+ " INTV_DT DATETIME NULL, INTV_END_DT DATETIME NULL, INTV_WAY VARCHAR(10) NULL, INTV_PLACE VARCHAR(300) NULL, INTV_WITH VARCHAR(200) NULL,"
					+ " DRAFT TEXT NULL COMMENT '투입확정 임시 저장 JSON', DEPLOY_SQ INT NULL, DROP_REASON VARCHAR(500) NULL,"
					+ " REG_EMPLY_ID VARCHAR(50) NULL, REG_DT DATETIME NOT NULL, UPDT_EMPLY_ID VARCHAR(50) NULL, UPDT_DT DATETIME NULL, UNIQUE KEY UK_RECRUIT_APPLY (RECRUIT_SQ, STAFF_SQ)) COMMENT '모집 지원'");
			jdbc.execute("CREATE TABLE IF NOT EXISTS TB_EEP_RECRUIT_FILE_R (FILE_SQ INT AUTO_INCREMENT PRIMARY KEY, RECRUIT_SQ INT NOT NULL, FILE_ID VARCHAR(100) NOT NULL, FILE_NM VARCHAR(300) NOT NULL,"
					+ " FILE_SIZE BIGINT NULL, FILE_URL VARCHAR(500) NULL, REG_EMPLY_ID VARCHAR(50) NULL, REG_DT DATETIME NOT NULL, KEY IX_RECRUIT_FILE (RECRUIT_SQ)) COMMENT '모집 첨부'");
			jdbc.execute("CREATE TABLE IF NOT EXISTS TB_EEP_RECRUIT_LOG_H (LOG_SQ INT AUTO_INCREMENT PRIMARY KEY, RECRUIT_SQ INT NULL, APPLY_SQ INT NULL, ACT VARCHAR(30) NOT NULL,"
					+ " SUMMARY VARCHAR(2000) NULL, EMPLY_ID VARCHAR(50) NULL, REG_DT DATETIME NOT NULL, KEY IX_RECRUIT_LOG (RECRUIT_SQ)) COMMENT '모집 이력'");
			// 인터뷰 기록(칩으로 고른 결과·평가·확인할 것·메모 JSON). 2026-11-20 추가, 사용자 승인
			jdbc.execute("ALTER TABLE TB_EEP_RECRUIT_APPLY_R ADD COLUMN IF NOT EXISTS INTV_NOTE TEXT NULL COMMENT '인터뷰 기록 JSON' AFTER INTV_WITH");
			// 인터뷰 기록 링크(계정 없이 본인이 제출). 2026-11-20 사용자 승인(A 방식)
			jdbc.execute("ALTER TABLE TB_EEP_RECRUIT_APPLY_R ADD COLUMN IF NOT EXISTS LINK_TOKEN VARCHAR(64) NULL COMMENT '인터뷰 기록 링크 토큰' AFTER INTV_NOTE,"
					+ " ADD COLUMN IF NOT EXISTS LINK_EXP_DT DATETIME NULL COMMENT '링크 만료' AFTER LINK_TOKEN, ADD COLUMN IF NOT EXISTS LINK_SUBMIT_DT DATETIME NULL COMMENT '본인 제출 시각' AFTER LINK_EXP_DT");
			jdbc.update("INSERT IGNORE INTO TB_EEP_MAIL_USE_M (USE_CD, ACC_SQ, TO_LIST) VALUES (?, 1, NULL)", MAIL_INTV);
			seedMenu();
		} catch (RuntimeException e) {
			log.error("모집 테이블 준비 실패: {}", e.getClass().getSimpleName());
		}
		try {
			for (String k : INTV_CODES.keySet()) intvGroup(k); // 인터뷰 기록 공통코드(2026-11-20 사용자 승인)
		} catch (RuntimeException e) {
			log.error("인터뷰 기록 코드 준비 실패: {}", e.getClass().getSimpleName());
		}
	}

	/** RC_INTV_<키> 그룹 번호. 없으면 만들고 기본 예시를 넣는다 */
	private int intvGroup(String kind) {
		String[] def = INTV_CODES.get(kind);
		require(def != null, "알 수 없는 항목입니다.");
		String grp = "RC_INTV_" + kind;
		List<Integer> g = jdbc.queryForList("SELECT COMN_CD_SQ FROM TB_EEP_COMN_CD_M WHERE COMN_CD = ? AND DEL_YN = 'N'", Integer.class, grp);
		if (!g.isEmpty()) return g.get(0);
		jdbc.update("INSERT INTO TB_EEP_COMN_CD_M (COMN_CD, COMN_CD_NM, NOTE, REG_DT, USE_YN, DEL_YN) VALUES (?, ?, '모집 관리 인터뷰 기록', NOW(), 'Y', 'N')", grp, def[0]);
		int sq = jdbc.queryForObject("SELECT COMN_CD_SQ FROM TB_EEP_COMN_CD_M WHERE COMN_CD = ? AND DEL_YN = 'N'", Integer.class, grp);
		for (int i = 1; i < def.length; i++) jdbc.update("INSERT INTO TB_EEP_COMN_DTL_CD_S (COMN_CD_SQ, COMN_DTL_CD, COMN_DTL_CD_NM, COMN_DTL_CD_ORD, REG_DT, USE_YN, DEL_YN) VALUES (?, ?, ?, ?, NOW(), 'Y', 'N')", sq, def[i], def[i], i);
		return sq;
	}

	/** 인터뷰 기록 칩: 키 → 이름 목록(순서대로) */
	public Map<String, List<String>> intvCodes() {
		Map<String, List<String>> out = new LinkedHashMap<>();
		for (String k : INTV_CODES.keySet()) out.put(k, new ArrayList<>());
		for (Map<String, Object> r : jdbc.queryForList("SELECT SUBSTRING(C.COMN_CD, 9) AS K, D.COMN_DTL_CD_NM AS NM FROM TB_EEP_COMN_CD_M C JOIN TB_EEP_COMN_DTL_CD_S D ON D.COMN_CD_SQ = C.COMN_CD_SQ"
				+ " WHERE C.COMN_CD LIKE 'RC\\_INTV\\_%' AND C.DEL_YN = 'N' AND D.DEL_YN = 'N' AND D.USE_YN = 'Y' ORDER BY D.COMN_DTL_CD_ORD IS NULL, D.COMN_DTL_CD_ORD, D.COMN_DTL_CD_SQ")) {
			List<String> l = out.get(s(r.get("K")));
			if (l != null) l.add(s(r.get("NM")));
		}
		return out;
	}

	/** 인터뷰 기록 칩 추가(ADD)·빼기(DEL, 공통코드는 DEL_YN). 이미 남긴 기록은 그대로 */
	public Map<String, List<String>> saveIntvCode(String kind, String act, String raw) {
		String n = s(raw).trim().replaceAll("\\s+", " ");
		require(!n.isEmpty() && n.length() <= 50, "이름은 1~50자로 넣어 주세요.");
		int g = intvGroup(kind);
		if ("DEL".equals(act)) {
			jdbc.update("UPDATE TB_EEP_COMN_DTL_CD_S SET DEL_YN = 'Y', UPDT_DT = NOW() WHERE COMN_CD_SQ = ? AND DEL_YN = 'N' AND COMN_DTL_CD_NM = ?", g, n);
		} else if (jdbc.queryForObject("SELECT COUNT(*) FROM TB_EEP_COMN_DTL_CD_S WHERE COMN_CD_SQ = ? AND COMN_DTL_CD_NM = ? AND DEL_YN = 'N'", Integer.class, g, n) == 0) {
			jdbc.update("INSERT INTO TB_EEP_COMN_DTL_CD_S (COMN_CD_SQ, COMN_DTL_CD, COMN_DTL_CD_NM, COMN_DTL_CD_ORD, REG_DT, USE_YN, DEL_YN)"
					+ " SELECT ?, ?, ?, IFNULL(MAX(COMN_DTL_CD_ORD), 0) + 1, NOW(), 'Y', 'N' FROM TB_EEP_COMN_DTL_CD_S WHERE COMN_CD_SQ = ?", g, n, n, g);
		}
		return intvCodes();
	}

	/** 메뉴는 한 번만 넣는다(관리자가 지우면 다시 생기지 않게 설정 값으로 표시). 투입현황(H00004) 바로 아래, 투입현황 권한을 가진 역할에 같이 준다 */
	private void seedMenu() {
		if ("Y".equals(confDao.ConfMap().get(CONF_MENU))) return;
		if (jdbc.queryForObject("SELECT COUNT(*) FROM TB_EEP_MENU WHERE MENU_URL = ?", Integer.class, PAGE) == 0) {
			List<Map<String, Object>> base = jdbc.queryForList("SELECT REL_CODE, MENU_DEPTH, SORT_NO FROM TB_EEP_MENU WHERE MENU_CODE = 'H00004'");
			if (base.isEmpty()) return;
			Integer max = jdbc.queryForObject("SELECT MAX(CAST(SUBSTRING(MENU_CODE, 2) AS UNSIGNED)) FROM TB_EEP_MENU WHERE MENU_CODE REGEXP '^H[0-9]{5}$'", Integer.class);
			String code = String.format("H%05d", (max == null ? 0 : max) + 1);
			Map<String, Object> b = base.get(0);
			jdbc.update("UPDATE TB_EEP_MENU SET SORT_NO = SORT_NO + 1 WHERE REL_CODE = ? AND SORT_NO > ?", b.get("REL_CODE"), b.get("SORT_NO"));
			jdbc.update("INSERT INTO TB_EEP_MENU (MENU_CODE, MENU_NM, REL_CODE, MENU_DEPTH, MENU_URL, FRST_REG_DT, LAST_UPDT_DT, FRST_REGISTER, SORT_NO, USE_YN, AUTH_PATTERN, NEW_WIN_YN)"
					+ " VALUES (?, '모집 관리', ?, ?, ?, NOW(), NOW(), 'system', ?, 'Y', '/admin/recruit/**', 'N')", code, b.get("REL_CODE"), b.get("MENU_DEPTH"), PAGE, num(b.get("SORT_NO")) + 1);
			jdbc.update("INSERT IGNORE INTO TB_EEP_ROLE_MENU_R (ROLE_SQ, MENU_CODE) SELECT ROLE_SQ, ? FROM TB_EEP_ROLE_MENU_R WHERE MENU_CODE = 'H00004'", code);
			log.warn("모집 관리 메뉴 추가 {}", code);
		}
		confDao.ConfSave(CONF_MENU, "Y");
	}

	// ── 화면 ──

	/** 모집·지원. 단가는 canPay 일 때만 */
	public Map<String, Object> screen(boolean canPay) {
		Map<String, Object> out = new HashMap<>();
		List<Map<String, Object>> recruits = jdbc.queryForList("SELECT R.RECRUIT_SQ, R.CLIENT_NM, R.PRJ_NM, R.GRADE_TXT, R.HEAD_CNT, R.START_DT, R.END_DT, R.PERIOD_TXT, R.WORK_AREA, R.PRICE_TXT, R.SKILLS, R.PREFER,"
				+ " R.SALE_PARTNER_SQ, R.SALE_PARTNER_TXT, R.MGR_NM, R.CLOSE_DT, R.MEMO, R.STATUS_CD, R.FOLDER_ID, DATE_FORMAT(R.REG_DT, '%Y-%m-%d') AS REG_D, P.PARTNER_NM AS SALE_PARTNER_NM,"
				+ " (SELECT COUNT(*) FROM TB_EEP_RECRUIT_FILE_R F WHERE F.RECRUIT_SQ = R.RECRUIT_SQ) AS FILE_CNT"
				+ " FROM TB_EEP_RECRUIT_M R LEFT JOIN TB_EEP_PARTNER_M P ON P.PARTNER_SQ = R.SALE_PARTNER_SQ WHERE R.DEL_YN = 'N' ORDER BY R.REG_DT DESC");
		for (Map<String, Object> r : recruits) {
			for (String d : DATE_COLS) r.put(d, r.get(d) == null ? null : r.get(d).toString());
			if (!canPay) r.put("PRICE_TXT", r.get("PRICE_TXT") == null ? null : "🔒");
		}
		out.put("recruits", recruits);
		List<Map<String, Object>> applies = applies();
		if (!canPay) applies.forEach(a -> a.put("DRAFT", s(a.get("DRAFT")).replaceAll("\"(SALE|COST)_PRICE\":\"[^\"]*\",?", "").replace(",}", "}")));
		out.put("applies", applies);
		out.put("canPay", canPay);
		return out;
	}

	/** 지원 전체. 직원 이름 포함 */
	public List<Map<String, Object>> applies() {
		return jdbc.queryForList("SELECT A.APPLY_SQ, A.RECRUIT_SQ, A.STAFF_SQ, A.STEP_CD, A.VER_NO, A.VER_LABEL, A.FILE_ID, A.FILE_NM, A.DEPLOY_SQ, A.DROP_REASON, A.DRAFT,"
				+ " DATE_FORMAT(A.INTV_DT, '%Y-%m-%d %H:%i') AS INTV_DT, DATE_FORMAT(A.INTV_END_DT, '%Y-%m-%d %H:%i') AS INTV_END_DT, A.INTV_WAY, A.INTV_PLACE, A.INTV_WITH, A.INTV_NOTE, A.LINK_TOKEN,"
				+ " DATE_FORMAT(A.LINK_EXP_DT, '%Y-%m-%d %H:%i') AS LINK_EXP_DT, DATE_FORMAT(A.LINK_SUBMIT_DT, '%Y-%m-%d %H:%i') AS LINK_SUBMIT_DT,"
				+ " DATE_FORMAT(A.UPDT_DT, '%Y-%m-%d %H:%i') AS UPDT_DT, A.UPDT_EMPLY_ID, S.STAFF_NM, S.POSITION_NM, S.DEPT_NM"
				+ " FROM TB_EEP_RECRUIT_APPLY_R A JOIN TB_EEP_HR_STAFF_M S ON S.STAFF_SQ = A.STAFF_SQ JOIN TB_EEP_RECRUIT_M R ON R.RECRUIT_SQ = A.RECRUIT_SQ AND R.DEL_YN = 'N' ORDER BY A.APPLY_SQ");
	}

	/** 대기자 패널: 재직·대기 직원 + 프로필 버전. 투입 상태는 화면이 투입현황 목록(current)으로 계산한다 */
	public Map<String, Object> people() {
		Map<String, Object> out = new HashMap<>();
		List<Map<String, Object>> staff = jdbc.queryForList("SELECT STAFF_SQ, STAFF_NM, STATUS_CD, POSITION_NM, DEPT_NM, WISH_LOC, ADDR, GRADE_NM, REAL_CAREER, DATE_FORMAT(JOIN_DT, '%Y-%m-%d') AS JOIN_DT"
				+ " FROM TB_EEP_HR_STAFF_M WHERE STATUS_CD IN ('WORK', 'WAIT') ORDER BY STAFF_NM");
		// 연차(실경력이 없을 때)·주요기술 필터용: 수행이력 줄의 가장 이른 시작월, 언어·프레임워크·DBMS·TOOL 많이 쓴 순 5개
		Map<String, String> first = new HashMap<>();
		Map<String, Map<String, Integer>> tech = new HashMap<>();
		for (Map<String, Object> p : jdbc.queryForList("SELECT STAFF_SQ, START_YM, LANG_NM, FRAMEWORK_NM, DBMS_NM, TOOL_NM FROM TB_EEP_HR_STAFF_PRJ_R")) {
			String sq = String.valueOf(p.get("STAFF_SQ")), ym = Objects.toString(p.get("START_YM"), "");
			if (ym.matches("\\d{4}-\\d{2}.*") && (first.get(sq) == null || ym.compareTo(first.get(sq)) < 0)) first.put(sq, ym.substring(0, 7));
			for (String c : new String[] { "LANG_NM", "FRAMEWORK_NM", "DBMS_NM", "TOOL_NM" })
				for (String t : StaffCareerService.tokens(Objects.toString(p.get(c), ""))) tech.computeIfAbsent(sq, k -> new LinkedHashMap<>()).merge(t, 1, Integer::sum);
		}
		for (Map<String, Object> s : staff) {
			String sq = String.valueOf(s.get("STAFF_SQ"));
			Map<String, Integer> m = tech.getOrDefault(sq, new HashMap<>());
			List<String> keys = new ArrayList<>(m.keySet());
			keys.sort((a, b) -> m.get(b) - m.get(a));
			s.put("FIRST_YM", first.get(sq));
			s.put("TECHS", new ArrayList<>(keys.subList(0, Math.min(5, keys.size()))));
		}
		out.put("staff", staff);
		out.put("profiles", profiles());
		out.put("current", deployService.deployList(false).get("current"));
		return out;
	}

	/** 직원별 저장된 수행이력 버전(순정·가필). 투입현황 대기 현황 칸도 쓴다 */
	public List<Map<String, Object>> profiles() {
		return jdbc.queryForList("SELECT STAFF_SQ, VER_NO, VER_KIND, PRJ_CNT, DATE_FORMAT(REG_DT, '%Y-%m-%d') AS REG_DT FROM TB_EEP_HR_STAFF_PRJ_VER_H ORDER BY STAFF_SQ, VER_NO DESC");
	}

	/** 투입현황 대기 현황의 「지원 중 모집」: 탈락·투입확정 전 단계 */
	public List<Map<String, Object>> activeApplies() {
		return jdbc.queryForList("SELECT A.STAFF_SQ, A.RECRUIT_SQ, A.STEP_CD, DATE_FORMAT(A.INTV_DT, '%m-%d %H:%i') AS INTV_DT, R.CLIENT_NM, R.PRJ_NM"
				+ " FROM TB_EEP_RECRUIT_APPLY_R A JOIN TB_EEP_RECRUIT_M R ON R.RECRUIT_SQ = A.RECRUIT_SQ AND R.DEL_YN = 'N' WHERE A.STEP_CD IN " + ACTIVE_IN + " ORDER BY A.APPLY_SQ");
	}

	public List<Map<String, Object>> files(Object recruitSq) {
		return jdbc.queryForList("SELECT FILE_SQ, FILE_ID, FILE_NM, FILE_SIZE, FILE_URL, REG_EMPLY_ID, DATE_FORMAT(REG_DT, '%m-%d %H:%i') AS REG_DT FROM TB_EEP_RECRUIT_FILE_R WHERE RECRUIT_SQ = ? ORDER BY FILE_SQ", recruitSq);
	}

	public List<Map<String, Object>> logs(Object recruitSq) {
		return jdbc.queryForList("SELECT ACT, SUMMARY, EMPLY_ID, DATE_FORMAT(REG_DT, '%Y-%m-%d %H:%i') AS REG_DT FROM TB_EEP_RECRUIT_LOG_H WHERE RECRUIT_SQ = ? ORDER BY LOG_SQ DESC LIMIT 200", recruitSq);
	}

	// ── 원문 읽기·모집 저장 ──

	/** 붙여 넣은 원문을 칸으로(저장 전 미리 보기). 매출처 이름이 거래처 목록과 맞으면 SALE_PARTNER_SQ 도 */
	public Map<String, Object> parse(String raw) {
		Map<String, Object> f = RecruitParser.parse(null, raw, LocalDate.now(SEOUL));
		f.put("SALE_PARTNER_SQ", partnerOf(s(f.get("SALE_PARTNER_TXT"))));
		return f;
	}

	/** 거래처 이름 맞추기: (주)·㈜·띄어쓰기를 빼고 같거나 한쪽이 다른 쪽을 품으면. 하나만 맞을 때만 */
	Object partnerOf(String txt) {
		String t = normPartner(txt);
		if (t.length() < 2) return null;
		Object hit = null;
		int cnt = 0;
		for (Map<String, Object> p : jdbc.queryForList("SELECT PARTNER_SQ, PARTNER_NM FROM TB_EEP_PARTNER_M WHERE USE_YN = 'Y'")) {
			String n = normPartner(s(p.get("PARTNER_NM")));
			if (n.isEmpty()) continue;
			if (n.equals(t)) return p.get("PARTNER_SQ");
			if (n.contains(t) || t.contains(n)) { hit = p.get("PARTNER_SQ"); cnt++; }
		}
		return cnt == 1 ? hit : null;
	}

	static String normPartner(String s) {
		return s(s).replaceAll("\\(주\\)|㈜|주식회사|\\s", "").toLowerCase();
	}

	/** 새 모집(붙여넣기) 또는 고치기. 새 모집이면 드라이브 폴더를 만든다. @return {RECRUIT_SQ, notes[]} */
	public Map<String, Object> save(Map<String, Object> p, String loginId) {
		Map<String, Object> v = clean(p);
		List<String> notes = new ArrayList<>();
		Object sq = p.get("RECRUIT_SQ");
		if (s(sq).isEmpty()) {
			require(!s(p.get("RAW_TEXT")).trim().isEmpty() || !s(v.get("CLIENT_NM")).isEmpty(), "원문을 붙여 넣거나 고객사를 입력해 주세요.");
			KeyHolder kh = new GeneratedKeyHolder();
			StringBuilder cols = new StringBuilder("RAW_TEXT, STATUS_CD, REG_EMPLY_ID, REG_DT, UPDT_EMPLY_ID, UPDT_DT"), qs = new StringBuilder("?, 'OPEN', ?, NOW(), ?, NOW()");
			List<Object> args = new ArrayList<>(Arrays.asList(cut(s(p.get("RAW_TEXT")), 20000), loginId, loginId));
			for (String c : EDIT_COLS) { cols.append(", ").append(c); qs.append(", ?"); args.add(v.get(c)); }
			jdbc.update(con -> {
				java.sql.PreparedStatement ps = con.prepareStatement("INSERT INTO TB_EEP_RECRUIT_M (" + cols + ") VALUES (" + qs + ")", java.sql.Statement.RETURN_GENERATED_KEYS);
				for (int i = 0; i < args.size(); i++) ps.setObject(i + 1, args.get(i));
				return ps;
			}, kh);
			sq = kh.getKey().intValue();
			log(sq, null, "NEW", "등록 · " + brief(v), loginId);
			try {
				ensureFolder(sq);
			} catch (RuntimeException e) {
				notes.add("드라이브 폴더를 만들지 못했습니다: " + googleWhy(e) + " (상세에서 다시 만들 수 있습니다)");
			}
		} else {
			Map<String, Object> cur = one(sq);
			List<String> sets = new ArrayList<>(), names = new ArrayList<>();
			List<Object> args = new ArrayList<>();
			for (String c : EDIT_COLS) {
				if (!p.containsKey(c) || Objects.equals(s(v.get(c)), s(cur.get(c)))) continue;
				sets.add(c + " = ?");
				names.add(c);
				args.add(v.get(c));
			}
			if (sets.isEmpty()) return result(sq, notes);
			args.add(loginId);
			args.add(sq);
			jdbc.update("UPDATE TB_EEP_RECRUIT_M SET " + String.join(", ", sets) + ", UPDT_EMPLY_ID = ?, UPDT_DT = NOW() WHERE RECRUIT_SQ = ?", args.toArray());
			log(sq, null, "EDIT", "고침 · " + String.join(", ", names), loginId);
			refreshFill(sq, loginId);
		}
		return result(sq, notes);
	}

	private static Map<String, Object> result(Object sq, List<String> notes) {
		Map<String, Object> r = new HashMap<>();
		r.put("RECRUIT_SQ", sq);
		r.put("notes", notes);
		return r;
	}

	/** 화면에서 온 값 검사·정리 */
	private Map<String, Object> clean(Map<String, Object> p) {
		Map<String, Object> v = new HashMap<>();
		for (String c : EDIT_COLS) {
			String x = s(p.get(c)).trim();
			if (DATE_COLS.contains(c)) {
				require(x.isEmpty() || x.matches("\\d{4}-\\d{2}-\\d{2}"), "날짜 형식을 확인해 주세요.");
				v.put(c, x.isEmpty() ? null : x);
			} else if ("HEAD_CNT".equals(c) || "SALE_PARTNER_SQ".equals(c)) {
				require(x.matches("\\d{0,9}"), "숫자를 확인해 주세요.");
				v.put(c, x.isEmpty() ? null : Integer.valueOf(x));
			} else {
				v.put(c, x.isEmpty() ? null : cut(x, "MEMO".equals(c) ? 5000 : 300));
			}
		}
		require(v.get("START_DT") == null || v.get("END_DT") == null || s(v.get("END_DT")).compareTo(s(v.get("START_DT"))) >= 0, "종료일이 시작일보다 빠릅니다.");
		return v;
	}

	public void setStatus(Object sq, String status, String loginId) {
		require(STATUS.contains(status), "알 수 없는 상태입니다.");
		Map<String, Object> cur = one(sq);
		if (status.equals(cur.get("STATUS_CD"))) return;
		jdbc.update("UPDATE TB_EEP_RECRUIT_M SET STATUS_CD = ?, UPDT_EMPLY_ID = ?, UPDT_DT = NOW() WHERE RECRUIT_SQ = ?", status, loginId, sq);
		log(sq, null, "STATUS", statusName(s(cur.get("STATUS_CD"))) + " → " + statusName(status), loginId);
	}

	/** 지운 모집은 화면에서만 빠진다. 드라이브 폴더는 그대로 둔다 */
	public void delete(Object sq, String loginId) {
		one(sq);
		require(jdbc.queryForObject("SELECT COUNT(*) FROM TB_EEP_RECRUIT_APPLY_R WHERE RECRUIT_SQ = ? AND STEP_CD = 'JOIN'", Integer.class, sq) == 0, "투입확정된 지원자가 있어 지울 수 없습니다. 마감으로 바꿔 주세요.");
		jdbc.update("UPDATE TB_EEP_RECRUIT_M SET DEL_YN = 'Y', UPDT_EMPLY_ID = ?, UPDT_DT = NOW() WHERE RECRUIT_SQ = ?", loginId, sq);
		log(sq, null, "DELETE", "모집 삭제", loginId);
	}

	public Map<String, Object> one(Object sq) {
		List<Map<String, Object>> r = jdbc.queryForList("SELECT R.*, DATE_FORMAT(R.REG_DT, '%Y-%m-%d') AS REG_D FROM TB_EEP_RECRUIT_M R WHERE R.RECRUIT_SQ = ? AND R.DEL_YN = 'N'", sq);
		require(!r.isEmpty(), "모집을 찾지 못했습니다. 새로 고쳐 주세요.");
		Map<String, Object> m = r.get(0);
		for (String d : DATE_COLS) m.put(d, m.get(d) == null ? null : m.get(d).toString());
		m.remove("REG_DT");
		m.remove("UPDT_DT");
		return m;
	}

	// ── 드라이브 ──

	/** 모집 폴더(최상위/{연도}년도/{월}월/({등록일}) {고객사}_{사업명}). 있으면 그대로. @return 폴더 ID */
	public String ensureFolder(Object sq) {
		Map<String, Object> r = one(sq);
		if (!s(r.get("FOLDER_ID")).isEmpty()) return s(r.get("FOLDER_ID"));
		String root = driveConf.get("RECRUIT", "ROOT");
		require(!root.isEmpty(), "드라이브 설정에서 모집 최상위 폴더를 먼저 골라 주세요.");
		String token = googleLink.accessToken(GoogleLinkService.COMPANY, GoogleLinkService.DRIVE);
		LocalDate d = LocalDate.parse(s(r.get("REG_D")));
		Map<String, String> vars = new HashMap<>();
		vars.put("연도", String.valueOf(d.getYear()));
		vars.put("월", String.valueOf(d.getMonthValue()));
		vars.put("등록일", d.format(DateTimeFormatter.ofPattern("MM.dd")));
		vars.put("고객사", s(r.get("CLIENT_NM")).isEmpty() ? "고객사미정" : s(r.get("CLIENT_NM")));
		vars.put("사업명", s(r.get("PRJ_NM")));
		String id = root;
		for (String key : new String[] { "YEAR", "MONTH", "POST" }) {
			String name = DriveConfService.render(driveConf.get("RECRUIT", key), vars).replaceAll("_$", "");
			String found = drive.childFolderId(id, name, token);
			id = found != null ? found : drive.createFolder(name, id, token);
		}
		jdbc.update("UPDATE TB_EEP_RECRUIT_M SET FOLDER_ID = ? WHERE RECRUIT_SQ = ?", id, sq);
		return id;
	}

	/** 첨부: 모집 폴더 안 「첨부」 폴더에 공통 업로드 규칙으로 */
	public void upload(Object sq, Upload up, String loginId) {
		String folder = ensureFolder(sq), token = googleLink.accessToken(GoogleLinkService.COMPANY, GoogleLinkService.DRIVE);
		String subName = driveConf.get("RECRUIT", "SUB");
		String sub = drive.childFolderId(folder, subName, token);
		if (sub == null) sub = drive.createFolder(subName, folder, token);
		Map<String, Object> f = drive.upload(up.name, up.mime, up.data, sub, token);
		jdbc.update("INSERT INTO TB_EEP_RECRUIT_FILE_R (RECRUIT_SQ, FILE_ID, FILE_NM, FILE_SIZE, FILE_URL, REG_EMPLY_ID, REG_DT) VALUES (?, ?, ?, ?, ?, ?, NOW())",
				sq, f.get("id"), cut(up.name, 300), up.data.length, f.get("webViewLink"), loginId);
		log(sq, null, "FILE", "첨부 추가 · " + up.name, loginId);
	}

	/** 드라이브에서는 휴지통으로(되살릴 수 있다) */
	public void deleteFile(Object sq, Object fileSq, String loginId) {
		List<Map<String, Object>> f = jdbc.queryForList("SELECT FILE_ID, FILE_NM FROM TB_EEP_RECRUIT_FILE_R WHERE FILE_SQ = ? AND RECRUIT_SQ = ?", fileSq, sq);
		require(!f.isEmpty(), "첨부를 찾지 못했습니다.");
		try {
			drive.trash(s(f.get(0).get("FILE_ID")), googleLink.accessToken(GoogleLinkService.COMPANY, GoogleLinkService.DRIVE));
		} catch (HttpClientErrorException e) {
			if (e.getStatusCode().value() != 404) throw e; // 드라이브에서 이미 지운 파일
		}
		jdbc.update("DELETE FROM TB_EEP_RECRUIT_FILE_R WHERE FILE_SQ = ?", fileSq);
		log(sq, null, "FILE", "첨부 삭제 · " + f.get(0).get("FILE_NM"), loginId);
	}

	// ── 지원 ──

	/**
	 * 대기자를 모집에 지원시킨다. ver: 버전 번호(순정·가필) 또는 GEN(요구 기술로 가필 새로 생성).
	 * 프로필 워드를 모집 폴더에 저장한다. 드라이브가 실패해도 지원은 남기고 notes 로 알린다.
	 */
	public Map<String, Object> apply(Object sq, Object staffSq, String ver, String loginId) {
		Map<String, Object> r = one(sq);
		require(!career.versions(staffSq).isEmpty(), "저장된 수행이력 프로필이 없어 지원할 수 없습니다. 인사카드 › 수행이력에서 버전을 저장해 주세요.");
		require(jdbc.queryForObject("SELECT COUNT(*) FROM TB_EEP_RECRUIT_APPLY_R WHERE RECRUIT_SQ = ? AND STAFF_SQ = ?", Integer.class, sq, staffSq) == 0, "이미 이 모집에 지원했습니다.");
		int verNo;
		if ("GEN".equals(ver)) {
			Map<String, Object> conf = new HashMap<>();
			List<String> skills = new ArrayList<>();
			for (String t : s(r.get("SKILLS")).split("[,/·]")) if (!t.trim().isEmpty()) skills.add(t.trim());
			conf.put("skills", skills);
			conf.put("sort", "match");
			verNo = career.saveGenerated(staffSq, json(conf), loginId);
		} else {
			require(s(ver).matches("\\d+"), "프로필 버전을 골라 주세요.");
			verNo = Integer.parseInt(ver);
		}
		String kind = null;
		for (Map<String, Object> v : career.versions(staffSq)) if (num(v.get("VER_NO")) == verNo) kind = s(v.get("VER_KIND"));
		require(kind != null, "프로필 버전을 찾지 못했습니다.");
		String label = ("EDIT".equals(kind) ? "가필" : "순정") + "v" + verNo;
		jdbc.update("INSERT INTO TB_EEP_RECRUIT_APPLY_R (RECRUIT_SQ, STAFF_SQ, STEP_CD, VER_NO, VER_LABEL, REG_EMPLY_ID, REG_DT, UPDT_EMPLY_ID, UPDT_DT) VALUES (?, ?, 'DOC', ?, ?, ?, NOW(), ?, NOW())",
				sq, staffSq, verNo, label, loginId, loginId);
		Object applySq = jdbc.queryForObject("SELECT APPLY_SQ FROM TB_EEP_RECRUIT_APPLY_R WHERE RECRUIT_SQ = ? AND STAFF_SQ = ?", Integer.class, sq, staffSq);
		String staffNm = jdbc.queryForObject("SELECT STAFF_NM FROM TB_EEP_HR_STAFF_M WHERE STAFF_SQ = ?", String.class, staffSq);
		log(sq, applySq, "APPLY", staffNm + " 지원 · 프로필 " + label, loginId);
		if ("OPEN".equals(r.get("STATUS_CD"))) setStatus(sq, "APPLY", loginId);
		List<String> notes = new ArrayList<>();
		// 지원하면 바로 드라이브에 올린다. 한 번 실패하면(폴더를 막 만든 직후 등) 잠깐 뒤 한 번 더
		for (int i = 0; i < 2; i++) {
			try {
				saveWord(applySq, loginId);
				break;
			} catch (RuntimeException e) {
				log.warn("recruit word upload failed (apply " + applySq + ", try " + (i + 1) + "): " + e);
				if (i == 1) notes.add("프로필 워드를 드라이브에 저장하지 못했습니다: " + googleWhy(e) + " (지원자 줄의 「⚠ 다시 저장」으로 다시 올릴 수 있습니다)");
				else try { Thread.sleep(1500); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); }
			}
		}
		Map<String, Object> out = new HashMap<>();
		out.put("APPLY_SQ", applySq);
		out.put("notes", notes);
		return out;
	}

	/** 지원한 버전의 워드를 모집 폴더에 저장한다. 이름이 겹치면 _2, _3 */
	public void saveWord(Object applySq, String loginId) {
		Map<String, Object> a = apply(applySq);
		String folder = ensureFolder(a.get("RECRUIT_SQ")), token = googleLink.accessToken(GoogleLinkService.COMPANY, GoogleLinkService.DRIVE);
		byte[] data = career.word(a.get("STAFF_SQ"), s(a.get("VER_NO")));
		Map<String, String> vars = new HashMap<>();
		vars.put("성명", s(a.get("STAFF_NM")));
		vars.put("버전", s(a.get("VER_LABEL")));
		String base = DriveConfService.render(driveConf.get("RECRUIT", "WORD"), vars), name = base + ".docx";
		List<String> names = new ArrayList<>();
		for (Map<String, Object> f : drive.children(folder, token)) names.add(s(f.get("name")));
		for (int i = 2; names.contains(name); i++) name = base + "_" + i + ".docx";
		Map<String, Object> f = drive.upload(name, "application/vnd.openxmlformats-officedocument.wordprocessingml.document", data, folder, token);
		jdbc.update("UPDATE TB_EEP_RECRUIT_APPLY_R SET FILE_ID = ?, FILE_NM = ? WHERE APPLY_SQ = ?", f.get("id"), name, applySq);
		log(a.get("RECRUIT_SQ"), applySq, "WORD", "프로필 워드 저장 · " + name, loginId);
	}

	public Map<String, Object> apply(Object applySq) {
		List<Map<String, Object>> a = jdbc.queryForList("SELECT A.APPLY_SQ, A.RECRUIT_SQ, A.STAFF_SQ, A.STEP_CD, A.VER_NO, A.VER_LABEL, A.DEPLOY_SQ, A.DRAFT,"
				+ " DATE_FORMAT(A.INTV_DT, '%Y-%m-%d %H:%i') AS INTV_DT, DATE_FORMAT(A.INTV_END_DT, '%Y-%m-%d %H:%i') AS INTV_END_DT, A.INTV_WAY, A.INTV_PLACE, A.INTV_WITH,"
				+ " S.STAFF_NM, S.COMPANY_EMAIL, R.CLIENT_NM, R.PRJ_NM, R.WORK_AREA FROM TB_EEP_RECRUIT_APPLY_R A"
				+ " JOIN TB_EEP_HR_STAFF_M S ON S.STAFF_SQ = A.STAFF_SQ JOIN TB_EEP_RECRUIT_M R ON R.RECRUIT_SQ = A.RECRUIT_SQ AND R.DEL_YN = 'N' WHERE A.APPLY_SQ = ?", applySq);
		require(!a.isEmpty(), "지원을 찾지 못했습니다. 새로 고쳐 주세요.");
		return a.get(0);
	}

	/**
	 * 단계 바꾸기(인터뷰확정·투입확정은 각 창을 거친다). 투입확정에서 내리면 delDeploy=Y 일 때 만든 투입 예정을 지운다(이미 투입일이 지났으면 지우지 않는다).
	 * 앞으로 잡힌 인터뷰에서 앞 단계·탈락으로 바꾸면 인터뷰를 취소하고 취소 메일을 보낸다. @return notes
	 */
	public List<String> step(Object applySq, String step, boolean delDeploy, String reason, String loginId) {
		require(STEPS.contains(step) || "DROP".equals(step), "알 수 없는 단계입니다.");
		require(!"INTV".equals(step) && !"JOIN".equals(step), "인터뷰확정·투입확정은 각 창에서 저장해 주세요.");
		Map<String, Object> a = apply(applySq);
		String before = s(a.get("STEP_CD"));
		List<String> notes = new ArrayList<>();
		if (step.equals(before)) return notes;
		if ("JOIN".equals(before) && a.get("DEPLOY_SQ") != null && delDeploy) {
			List<Map<String, Object>> d = jdbc.queryForList("SELECT START_DT FROM TB_EEP_DEPLOY_R WHERE DEPLOY_SQ = ?", a.get("DEPLOY_SQ"));
			if (!d.isEmpty() && LocalDate.parse(d.get(0).get("START_DT").toString()).isAfter(LocalDate.now(SEOUL))) {
				Map<String, Object> q = new HashMap<>();
				q.put("DEPLOY_SQ", a.get("DEPLOY_SQ"));
				q.put("UPDT_EMPLY_ID", loginId);
				deployService.deleteDeploy(q);
				jdbc.update("UPDATE TB_EEP_RECRUIT_APPLY_R SET DEPLOY_SQ = NULL WHERE APPLY_SQ = ?", applySq);
				notes.add("투입현황의 투입 예정을 지웠습니다.");
			} else if (!d.isEmpty()) {
				notes.add("이미 투입일이 지나 투입현황의 투입 건은 지우지 않았습니다.");
			}
		}
		// 앞으로 잡힌 인터뷰에서 앞 단계·탈락(DROP 은 -1)으로 가면 취소 메일. 지난 인터뷰는 기록으로 둔다.
		// 탈락은 인터뷰 일시를 남겨 달력에 「탈락」으로 보이게 하고(메일은 이때 한 번), 탈락에서 되살릴 때는 메일 없이 일시만 비운다
		LocalDateTime intv = dateTime(a.get("INTV_DT"));
		if (STEPS.indexOf(step) < STEPS.indexOf("INTV") && intv != null && intv.isAfter(LocalDateTime.now(SEOUL))) {
			if (!"DROP".equals(before)) {
				notes.addAll(mailInterview(a, "취소", intv, dateTime(a.get("INTV_END_DT")), s(a.get("INTV_WAY")), s(a.get("INTV_PLACE")), s(a.get("INTV_WITH"))));
				log(a.get("RECRUIT_SQ"), applySq, "INTV", a.get("STAFF_NM") + " 인터뷰 취소", loginId);
			}
			if (!"DROP".equals(step)) jdbc.update("UPDATE TB_EEP_RECRUIT_APPLY_R SET INTV_DT = NULL, INTV_END_DT = NULL WHERE APPLY_SQ = ?", applySq);
		}
		jdbc.update("UPDATE TB_EEP_RECRUIT_APPLY_R SET STEP_CD = ?, DROP_REASON = ?, UPDT_EMPLY_ID = ?, UPDT_DT = NOW() WHERE APPLY_SQ = ?",
				step, "DROP".equals(step) ? cut(s(reason).trim(), 500) : null, loginId, applySq);
		log(a.get("RECRUIT_SQ"), applySq, "STEP", a.get("STAFF_NM") + " " + stepName(before) + " → " + stepName(step) + ("DROP".equals(step) && !s(reason).trim().isEmpty() ? " (" + reason.trim() + ")" : ""), loginId);
		refreshFill(a.get("RECRUIT_SQ"), loginId);
		return notes;
	}

	/** 지원 취소: 지원 기록을 지워 다시 지원할 수 있게 한다(탈락은 step DROP 으로 기록이 남음). 앞으로 잡힌 인터뷰는 취소 메일, 워드는 드라이브 휴지통. @return notes */
	public List<String> cancel(Object applySq, String loginId) {
		Map<String, Object> a = apply(applySq);
		require(!"JOIN".equals(s(a.get("STEP_CD"))), "투입확정된 지원은 취소할 수 없습니다. 먼저 단계를 되돌려 주세요.");
		List<String> notes = new ArrayList<>();
		LocalDateTime intv = dateTime(a.get("INTV_DT"));
		if (intv != null && intv.isAfter(LocalDateTime.now(SEOUL)))
			notes.addAll(mailInterview(a, "취소", intv, dateTime(a.get("INTV_END_DT")), s(a.get("INTV_WAY")), s(a.get("INTV_PLACE")), s(a.get("INTV_WITH"))));
		String fileId = jdbc.queryForObject("SELECT IFNULL(FILE_ID, '') FROM TB_EEP_RECRUIT_APPLY_R WHERE APPLY_SQ = ?", String.class, applySq);
		if (!fileId.isEmpty()) {
			try {
				drive.trash(fileId, googleLink.accessToken(GoogleLinkService.COMPANY, GoogleLinkService.DRIVE));
			} catch (RuntimeException e) {
				notes.add("드라이브의 프로필 워드를 휴지통으로 옮기지 못했습니다: " + googleWhy(e));
			}
		}
		jdbc.update("DELETE FROM TB_EEP_RECRUIT_APPLY_R WHERE APPLY_SQ = ?", applySq);
		log(a.get("RECRUIT_SQ"), null, "CANCEL", a.get("STAFF_NM") + " 지원 취소(기록 삭제, " + stepName(s(a.get("STEP_CD"))) + "에서)", loginId);
		refreshFill(a.get("RECRUIT_SQ"), loginId);
		return notes;
	}

	/** 인터뷰 기록 저장(화면이 칩으로 만든 JSON). summary 는 이력용 한 줄 */
	public void note(Object applySq, String note, String summary, String loginId) {
		Map<String, Object> a = apply(applySq);
		require(s(note).length() <= 30000, "인터뷰 기록이 너무 깁니다."); // 질문·답변 여러 개(모의 인터뷰 자료)
		jdbc.update("UPDATE TB_EEP_RECRUIT_APPLY_R SET INTV_NOTE = ?, UPDT_EMPLY_ID = ?, UPDT_DT = NOW() WHERE APPLY_SQ = ?", s(note).trim().isEmpty() ? null : note, loginId, applySq);
		log(a.get("RECRUIT_SQ"), applySq, "NOTE", a.get("STAFF_NM") + " 인터뷰 기록" + (s(summary).trim().isEmpty() ? "" : " · " + cut(summary.trim(), 300)), loginId);
		if (!s(note).trim().isEmpty()) autoStep(a, Arrays.asList("DOC", "INTV_WAIT", "INTV", "INTV_SUB"), "INTV_CHK", loginId); // 관리자가 통화로 기록하면 확인중
	}

	// ── 인터뷰 기록 링크: 계정 없이 본인이 제출(plans/recruit-intv-link-spec.html, A 방식) ──

	static final int LINK_DAYS = 7;
	static final String[] NOTE_ONE = { "mood", "dur", "feel", "cli", "notice" }, NOTE_MANY = { "who", "flow", "askd", "tech", "etc" };
	private final Map<String, java.util.Deque<Long>> linkHits = new java.util.concurrent.ConcurrentHashMap<>();

	/** 새 링크(옛 링크는 막힘). @return TOKEN, LINK_EXP_DT */
	public Map<String, Object> linkIssue(Object applySq, String loginId) {
		Map<String, Object> a = apply(applySq);
		byte[] b = new byte[24];
		new java.security.SecureRandom().nextBytes(b);
		String token = java.util.Base64.getUrlEncoder().withoutPadding().encodeToString(b);
		LocalDateTime exp = LocalDateTime.now(SEOUL).plusDays(LINK_DAYS);
		jdbc.update("UPDATE TB_EEP_RECRUIT_APPLY_R SET LINK_TOKEN = ?, LINK_EXP_DT = ? WHERE APPLY_SQ = ?", token, exp.format(DT), applySq);
		log(a.get("RECRUIT_SQ"), applySq, "LINK", a.get("STAFF_NM") + " 인터뷰 기록 링크 만듦(" + exp.format(DT) + " 만료)", loginId);
		Map<String, Object> out = new HashMap<>();
		out.put("TOKEN", token);
		out.put("LINK_EXP_DT", exp.format(DT));
		return out;
	}

	/** 링크 주인 지원 1건. 없거나 만료면 막는다 */
	private Map<String, Object> linkApply(String token) {
		require(s(token).matches("[A-Za-z0-9_-]{20,64}"), "링크가 올바르지 않아요.");
		List<Map<String, Object>> l = jdbc.queryForList("SELECT A.APPLY_SQ, A.RECRUIT_SQ, A.STEP_CD, A.INTV_NOTE, A.LINK_EXP_DT, DATE_FORMAT(A.INTV_DT, '%Y-%m-%d %H:%i') AS INTV_DT, A.INTV_WAY, A.INTV_PLACE,"
				+ " S.STAFF_NM, R.CLIENT_NM, R.SKILLS FROM TB_EEP_RECRUIT_APPLY_R A JOIN TB_EEP_HR_STAFF_M S ON S.STAFF_SQ = A.STAFF_SQ"
				+ " JOIN TB_EEP_RECRUIT_M R ON R.RECRUIT_SQ = A.RECRUIT_SQ AND R.DEL_YN = 'N' WHERE A.LINK_TOKEN = ?", token);
		require(!l.isEmpty(), "링크가 없거나 새 링크로 바뀌었어요. 담당자에게 새 링크를 요청해 주세요.");
		LocalDateTime exp = dateTime(l.get(0).get("LINK_EXP_DT"));
		require(exp != null && exp.isAfter(LocalDateTime.now(SEOUL)), "링크가 만료됐어요. 담당자에게 새 링크를 요청해 주세요.");
		return l.get(0);
	}

	/** 링크 화면에 보일 것: 이름·고객사·인터뷰 일시·고를 칩·지금 기록(허용한 칸만) */
	public Map<String, Object> linkView(String token) {
		Map<String, Object> a = linkApply(token);
		Map<String, Object> out = new HashMap<>();
		for (String k : new String[] { "STAFF_NM", "CLIENT_NM", "INTV_DT", "INTV_PLACE", "SKILLS" }) out.put(k, a.get(k));
		out.put("INTV_WAY", a.get("INTV_DT") == null ? "" : wayName(s(a.get("INTV_WAY"))));
		out.put("codes", intvCodes());
		out.put("note", cleanNote(s(a.get("INTV_NOTE"))));
		out.put("LINK_EXP_DT", dateTime(a.get("LINK_EXP_DT")).format(DT));
		return out;
	}

	/** 본인 제출. 토큰마다 10분에 20번까지 */
	public void linkSave(String token, String note) {
		Map<String, Object> a = linkApply(token);
		long now = System.currentTimeMillis();
		java.util.Deque<Long> q = linkHits.computeIfAbsent(token, k -> new java.util.ArrayDeque<>());
		synchronized (q) {
			while (!q.isEmpty() && now - q.peekFirst() > 600_000) q.pollFirst();
			require(q.size() < 20, "너무 자주 저장했어요. 잠시 뒤 다시 해 주세요.");
			q.addLast(now);
		}
		require(s(note).length() <= 30000, "기록이 너무 깁니다.");
		Map<String, Object> n = cleanNote(note);
		Map<String, Object> old = cleanNote(s(a.get("INTV_NOTE")));
		n.put("by", "SELF");
		n.put("selfAt", LocalDateTime.now(SEOUL).format(DT));
		if (old.get("adminAt") != null) n.put("adminAt", old.get("adminAt"));
		jdbc.update("UPDATE TB_EEP_RECRUIT_APPLY_R SET INTV_NOTE = ?, LINK_SUBMIT_DT = NOW() WHERE APPLY_SQ = ?", json(n), a.get("APPLY_SQ"));
		log(a.get("RECRUIT_SQ"), a.get("APPLY_SQ"), "NOTE", a.get("STAFF_NM") + " 인터뷰 기록 본인 제출", "(링크)");
		autoStep(a, Arrays.asList("DOC", "INTV_WAIT", "INTV", "INTV_CHK"), "INTV_SUB", "(링크)"); // 다시 제출하면 확인중에서도 결과 제출로
	}

	/** 인터뷰 기록에 따라 단계를 앞으로만 옮긴다(탈락·투입대기 이후는 그대로) */
	private void autoStep(Map<String, Object> a, List<String> from, String to, String who) {
		String before = s(a.get("STEP_CD"));
		if (!from.contains(before)) return;
		jdbc.update("UPDATE TB_EEP_RECRUIT_APPLY_R SET STEP_CD = ?, UPDT_DT = NOW() WHERE APPLY_SQ = ? AND STEP_CD = ?", to, a.get("APPLY_SQ"), before);
		log(a.get("RECRUIT_SQ"), a.get("APPLY_SQ"), "STEP", a.get("STAFF_NM") + " " + stepName(before) + " → " + stepName(to) + " (인터뷰 기록)", who);
	}

	/** 관리자가 본인 제출 기록을 열어 봄 → 새 제출 표시(●)를 끈다 */
	public void noteSeen(Object applySq) {
		String raw = jdbc.queryForObject("SELECT IFNULL(INTV_NOTE, '') FROM TB_EEP_RECRUIT_APPLY_R WHERE APPLY_SQ = ?", String.class, applySq);
		if (raw.isEmpty()) return;
		Map<String, Object> n = parseNote(raw);
		n.put("seenAt", LocalDateTime.now(SEOUL).format(DT));
		jdbc.update("UPDATE TB_EEP_RECRUIT_APPLY_R SET INTV_NOTE = ? WHERE APPLY_SQ = ?", json(n), applySq);
	}

	/** 담당자가 보고서(본인 제출 기록)를 「✓ 확인」 → 인터뷰 결과 확인중 */
	public void noteCheck(Object applySq, String loginId) {
		Map<String, Object> a = apply(applySq);
		require(Arrays.asList("DOC", "INTV_WAIT", "INTV", "INTV_SUB").contains(s(a.get("STEP_CD"))), "이미 확인중이거나 다음 단계예요.");
		noteSeen(applySq);
		autoStep(a, Arrays.asList("DOC", "INTV_WAIT", "INTV", "INTV_SUB"), "INTV_CHK", loginId);
	}

	@SuppressWarnings("unchecked")
	private static Map<String, Object> parseNote(String raw) {
		try {
			Object o = raw.trim().isEmpty() ? null : JSON.readValue(raw, Object.class);
			return o instanceof Map ? new LinkedHashMap<>((Map<String, Object>) o) : new LinkedHashMap<>();
		} catch (java.io.IOException e) {
			throw new IllegalArgumentException("기록 형식이 올바르지 않아요.");
		}
	}

	/** 공개 링크로 들어온 기록은 아는 칸·길이만 남긴다(글은 화면에서 글자 그대로만 표시) */
	@SuppressWarnings("unchecked")
	static Map<String, Object> cleanNote(String raw) {
		Map<String, Object> in = parseNote(raw), out = new LinkedHashMap<>();
		for (String k : NOTE_ONE) out.put(k, cut(s(in.get(k)).trim(), 100));
		for (String k : NOTE_MANY) {
			List<String> l = new ArrayList<>();
			if (in.get(k) instanceof List) for (Object v : (List<Object>) in.get(k)) if (l.size() < 30 && !s(v).trim().isEmpty()) l.add(cut(s(v).trim(), 100));
			out.put(k, l);
		}
		List<Map<String, String>> qa = new ArrayList<>();
		if (in.get("qa") instanceof List) for (Object v : (List<Object>) in.get("qa")) {
			if (!(v instanceof Map) || qa.size() >= 50) continue;
			Map<String, Object> m = (Map<String, Object>) v;
			String qq = cut(s(m.get("q")).trim(), 500), aa = cut(s(m.get("a")).trim(), 2000);
			if (qq.isEmpty() && aa.isEmpty()) continue;
			Map<String, String> x = new LinkedHashMap<>();
			x.put("q", qq);
			x.put("a", aa);
			qa.add(x);
		}
		out.put("qa", qa);
		out.put("memo", cut(s(in.get("memo")).trim(), 1000));
		for (String k : new String[] { "by", "selfAt", "adminAt", "seenAt" }) if (in.get(k) != null) out.put(k, cut(s(in.get(k)), 30));
		return out;
	}

	/** 인터뷰 일정 저장 → 단계 인터뷰확정, 본인 회사 메일(항상, 변경 때도). @return notes */
	public List<String> interview(Object applySq, Map<String, Object> p, String loginId) {
		Map<String, Object> a = apply(applySq);
		LocalDateTime start = dateTime(p.get("INTV_DT")), end = dateTime(p.get("INTV_END_DT"));
		require(start != null, "인터뷰 일시를 입력해 주세요.");
		if (end == null || !end.isAfter(start)) end = start.plusHours(1);
		String way = s(p.get("INTV_WAY"));
		require(Arrays.asList("FACE", "VIDEO", "PHONE").contains(way), "방식을 골라 주세요.");
		String place = cut(s(p.get("INTV_PLACE")).trim(), 300), with = cut(s(p.get("INTV_WITH")).trim(), 200);
		boolean changed = a.get("INTV_DT") != null;
		jdbc.update("UPDATE TB_EEP_RECRUIT_APPLY_R SET STEP_CD = 'INTV', INTV_DT = ?, INTV_END_DT = ?, INTV_WAY = ?, INTV_PLACE = ?, INTV_WITH = ?, UPDT_EMPLY_ID = ?, UPDT_DT = NOW() WHERE APPLY_SQ = ?",
				start.format(DT), end.format(DT), way, place, with, loginId, applySq);
		log(a.get("RECRUIT_SQ"), applySq, "INTV", a.get("STAFF_NM") + " 인터뷰 " + (changed ? "변경 " : "확정 ") + start.format(DT) + " · " + wayName(way) + (place.isEmpty() ? "" : " · " + place), loginId);
		return mailInterview(a, changed ? "변경" : "안내", start, end, way, place, with);
	}

	/** 안내·변경·취소 메일을 본인 회사 메일로. 실패는 notes 로 알린다(저장은 그대로) */
	private List<String> mailInterview(Map<String, Object> a, String kind, LocalDateTime start, LocalDateTime end, String way, String place, String with) {
		List<String> notes = new ArrayList<>();
		String to = s(a.get("COMPANY_EMAIL")).trim();
		if (to.isEmpty()) {
			notes.add(a.get("STAFF_NM") + " 님의 회사 메일이 인사카드에 없어 알림 메일을 보내지 못했습니다.");
			return notes;
		}
		String target = (s(a.get("CLIENT_NM")) + " " + s(a.get("PRJ_NM"))).trim();
		try {
			MailConfService.Mail m = mailConf.create(MAIL_INTV, false);
			m.h.setTo(to);
			m.h.setSubject("[이에스티소프트] 인터뷰 일정 " + kind + " - " + target);
			StringBuilder b = new StringBuilder();
			b.append(a.get("STAFF_NM")).append(" 님,\n\n").append(target).append(" 인터뷰 일정").append("취소".equals(kind) ? "이 취소되었습니다." : "을 " + ("변경".equals(kind) ? "변경했습니다." : "안내합니다.")).append("\n\n");
			b.append("일시: ").append(start.format(DateTimeFormatter.ofPattern("yyyy-MM-dd (E) HH:mm", java.util.Locale.KOREAN)));
			if (end != null) b.append(" ~ ").append(end.format(DateTimeFormatter.ofPattern("HH:mm")));
			b.append("\n방식: ").append(wayName(way)).append("\n장소: ").append(place.isEmpty() ? "-" : place);
			if (!with.isEmpty()) b.append("\n동행: ").append(with);
			if (!"취소".equals(kind)) b.append("\n\n준비: 제출한 수행이력 프로필을 미리 확인해 주세요.");
			m.h.setText(b.toString());
			mailConf.send(m);
			notes.add(to + " 로 " + kind + " 메일을 보냈습니다.");
		} catch (Exception e) {
			notes.add("알림 메일을 보내지 못했습니다: " + MailConfService.reason(e));
		}
		return notes;
	}

	/**
	 * 투입확정. draft=true 면 입력값만 남기고 단계는 투입대기. 아니면 투입현황에 투입 예정을 만들거나(이미 만든 건 고친다) 단계를 투입확정으로.
	 * p: EMP_TYPE_CD, BUY_PARTNER_SQ, SALE_PARTNER_SQ, CLIENT_NM, PRJ_NM, GRADE_CD, WORK_AREA, START_DT, END_DT, SALE_PRICE, COST_PRICE, WORK_WAY, MEMO
	 * @return {DEPLOY_SQ, others: 같은 사람의 다른 진행 중 지원}
	 */
	public Map<String, Object> join(Object applySq, Map<String, Object> p, boolean draft, boolean canPay, String loginId) {
		Map<String, Object> a = apply(applySq);
		Map<String, Object> d = new LinkedHashMap<>();
		for (String k : new String[] { "EMP_TYPE_CD", "BUY_PARTNER_SQ", "SALE_PARTNER_SQ", "CLIENT_NM", "PRJ_NM", "GRADE_CD", "WORK_AREA", "START_DT", "END_DT", "WORK_WAY", "MEMO" }) d.put(k, cut(s(p.get(k)).trim(), 1000));
		if (canPay) { d.put("SALE_PRICE", s(p.get("SALE_PRICE")).trim()); d.put("COST_PRICE", s(p.get("COST_PRICE")).trim()); }
		String draftJson = json(d);
		Map<String, Object> out = new HashMap<>();
		if (draft) {
			String step = STEPS.indexOf(s(a.get("STEP_CD"))) < STEPS.indexOf("JOIN_WAIT") ? "JOIN_WAIT" : s(a.get("STEP_CD"));
			jdbc.update("UPDATE TB_EEP_RECRUIT_APPLY_R SET DRAFT = ?, STEP_CD = ?, UPDT_EMPLY_ID = ?, UPDT_DT = NOW() WHERE APPLY_SQ = ?", draftJson, step, loginId, applySq);
			log(a.get("RECRUIT_SQ"), applySq, "JOIN_DRAFT", a.get("STAFF_NM") + " 투입확정 임시 저장", loginId);
			out.put("others", new ArrayList<>());
			return out;
		}
		Map<String, Object> dp = new HashMap<>(d);
		dp.remove("WORK_WAY");
		dp.put("STAFF_SQ", a.get("STAFF_SQ"));
		dp.put("UPDT_EMPLY_ID", loginId);
		String way = s(d.get("WORK_WAY"));
		dp.put("MEMO", ((way.isEmpty() ? "" : "[" + way + "] ") + s(d.get("MEMO")) + " (모집 #" + a.get("RECRUIT_SQ") + ")").trim());
		boolean exists = a.get("DEPLOY_SQ") != null && jdbc.queryForObject("SELECT COUNT(*) FROM TB_EEP_DEPLOY_R WHERE DEPLOY_SQ = ?", Integer.class, a.get("DEPLOY_SQ")) > 0;
		if (exists) dp.put("DEPLOY_SQ", a.get("DEPLOY_SQ").toString());
		deployService.saveDeploy(dp, canPay);
		Object deploySq = dp.get("DEPLOY_SQ");
		jdbc.update("UPDATE TB_EEP_RECRUIT_APPLY_R SET DRAFT = ?, STEP_CD = 'JOIN', DEPLOY_SQ = ?, UPDT_EMPLY_ID = ?, UPDT_DT = NOW() WHERE APPLY_SQ = ?", draftJson, deploySq, loginId, applySq);
		log(a.get("RECRUIT_SQ"), applySq, "JOIN", a.get("STAFF_NM") + " 투입확정 · 투입현황 " + (exists ? "투입 건 수정" : "투입 예정 등록") + " " + d.get("START_DT"), loginId);
		refreshFill(a.get("RECRUIT_SQ"), loginId);
		out.put("DEPLOY_SQ", deploySq);
		out.put("others", jdbc.queryForList("SELECT A.APPLY_SQ, R.CLIENT_NM, R.PRJ_NM, A.STEP_CD FROM TB_EEP_RECRUIT_APPLY_R A JOIN TB_EEP_RECRUIT_M R ON R.RECRUIT_SQ = A.RECRUIT_SQ AND R.DEL_YN = 'N'"
				+ " WHERE A.STAFF_SQ = ? AND A.APPLY_SQ <> ? AND A.STEP_CD IN " + ACTIVE_IN, a.get("STAFF_SQ"), applySq));
		return out;
	}

	/** 정원(HEAD_CNT)이 차면 충원 완료, 모자라게 되면 지원 진행으로 */
	private void refreshFill(Object sq, String loginId) {
		Map<String, Object> r = one(sq);
		int head = num(r.get("HEAD_CNT")), joined = jdbc.queryForObject("SELECT COUNT(*) FROM TB_EEP_RECRUIT_APPLY_R WHERE RECRUIT_SQ = ? AND STEP_CD = 'JOIN'", Integer.class, sq);
		String st = s(r.get("STATUS_CD"));
		if (head > 0 && joined >= head && ("OPEN".equals(st) || "APPLY".equals(st))) setStatus(sq, "FILLED", loginId);
		else if ("FILLED".equals(st) && joined < head) setStatus(sq, "APPLY", loginId);
	}

	// ── 공통 ──

	private void log(Object recruitSq, Object applySq, String act, String summary, String who) {
		jdbc.update("INSERT INTO TB_EEP_RECRUIT_LOG_H (RECRUIT_SQ, APPLY_SQ, ACT, SUMMARY, EMPLY_ID, REG_DT) VALUES (?, ?, ?, ?, ?, NOW())", recruitSq, applySq, act, cut(summary, 2000), who);
	}

	/** 구글 드라이브 오류를 사람 말로 */
	static String googleWhy(Throwable e) {
		if (e instanceof HttpClientErrorException) {
			int code = ((HttpClientErrorException) e).getStatusCode().value();
			if (code == 403) return "구글 드라이브 권한이 부족합니다. 시스템 관리자가 🔗 내 연동에서 구글 드라이브를 다시 연결해 주세요.";
			if (code == 404) return "드라이브에서 폴더를 찾지 못했습니다(폴더 공유를 확인해 주세요).";
			return "구글 오류 " + code;
		}
		if (e instanceof IllegalArgumentException && e.getMessage() != null) return e.getMessage();
		return "처리하지 못했습니다(" + e.getClass().getSimpleName() + ")";
	}

	private static String brief(Map<String, Object> f) {
		return (s(f.get("CLIENT_NM")) + " " + s(f.get("PRJ_NM"))).trim() + (f.get("GRADE_TXT") == null ? "" : " · " + f.get("GRADE_TXT"));
	}

	static String stepName(String s) {
		switch (s) {
		case "DOC": return "서류검토";
		case "INTV_WAIT": return "인터뷰대기";
		case "INTV": return "인터뷰확정";
		case "INTV_SUB": return "인터뷰 결과 제출";
		case "INTV_CHK": return "인터뷰 결과 확인중";
		case "JOIN_WAIT": return "투입대기";
		case "JOIN": return "투입확정";
		case "DROP": return "탈락";
		default: return s;
		}
	}

	static String statusName(String s) {
		switch (s) {
		case "OPEN": return "모집중";
		case "APPLY": return "지원 진행";
		case "FILLED": return "충원 완료";
		case "CLOSED": return "마감";
		default: return s;
		}
	}

	static String wayName(String w) {
		return "VIDEO".equals(w) ? "화상" : "PHONE".equals(w) ? "전화" : "대면";
	}

	private static String json(Object o) {
		try {
			return JSON.writeValueAsString(o);
		} catch (com.fasterxml.jackson.core.JsonProcessingException e) {
			throw new IllegalStateException(e);
		}
	}

	private static LocalDateTime dateTime(Object v) {
		String x = s(v).trim().replace('T', ' ');
		if (!x.matches("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}.*")) return null;
		return LocalDateTime.parse(x.substring(0, 16).replace(' ', 'T'));
	}

	static String s(Object v) {
		return v == null ? "" : v.toString();
	}

	private static int num(Object v) {
		try {
			return v == null ? 0 : Integer.parseInt(v.toString().trim());
		} catch (NumberFormatException e) {
			return 0;
		}
	}

	private static String cut(String s, int max) {
		return s == null || s.length() <= max ? s : s.substring(0, max);
	}

	private static void require(boolean ok, String message) {
		if (!ok) throw new IllegalArgumentException(message);
	}
}
