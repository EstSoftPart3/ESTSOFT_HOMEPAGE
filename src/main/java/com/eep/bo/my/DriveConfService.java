package com.eep.bo.my;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.eep.bo.calendar.dao.BoCalendarDao;

/**
 * 화면별 구글 드라이브 설정(회사 공통). 폴더·파일 이름 규칙을 TB_EEP_CAL_CONF_M 에 'DRIVE.화면.칸' 키로 둔다.
 * 비어 있으면 아래 기본값(예전에 코드에 박혀 있던 규칙)을 쓴다. 규칙의 {이름표} 는 render 가 채운다.
 */
@Service
public class DriveConfService {

	/** 칸: { 키, 이름, 기본값, 쓸 수 있는 이름표(쉼표), 종류(folder=폴더 주소, 없으면 글자) } */
	static final Map<String, String[][]> FIELDS = new LinkedHashMap<>();
	/** 화면 → { 이름, 그 화면 주소(이 주소를 열 수 있는 사람만 고친다) } */
	static final Map<String, String[]> SCREENS = new LinkedHashMap<>();
	static {
		SCREENS.put("STAFF", new String[] { "직원관리 · 교육생", "/admin/staff/openStaffList.do" });
		FIELDS.put("STAFF", new String[][] {
			{ "ROOT", "최상위 폴더 ('2. 인사관리')", "", "", "folder" },
			// 구분 폴더: 골라 두면 폴더 ID, 비우면 최상위 폴더 아래에서 기본 이름으로 찾고 없으면 만든다(StaffDriveService.groupId)
			{ "WAIT", "대기자(교육생) 구분 폴더", "1. 대기자 관리", "", "folder" },
			{ "REG", "정규직 구분 폴더", "2. 정규직 관리", "", "folder" },
			{ "CON", "계약직·프리랜서 구분 폴더", "3. 계약직 관리", "", "folder" },
			{ "LEFT", "퇴사자 구분 폴더 (중도이탈 교육생 포함)", "4. 퇴사자 관리", "", "folder" },
			{ "TRAINEE", "교육생 폴더 이름", "(0000.00.00) {성명}", "{성명}", "" },
			{ "PERSON", "직원 폴더 이름", "({입사일}) {성명}", "{성명},{입사일}", "" },
			{ "DOCS", "서류 하위 폴더 이름 (사람 폴더마다 만들어짐)", "00. 입사관련서류", "", "" },
			{ "FILE", "서류 파일 이름", "{성명}_{서류명}", "{성명},{서류명},{올린날짜}", "" },
			{ "WORD", "이력카드 워드 이름", "{성명}_이력카드(시스템)", "{성명}", "" } });
		SCREENS.put("EQUIP", new String[] { "장비대장", "/admin/equipment/openEquipmentList.do" });
		FIELDS.put("EQUIP", new String[][] {
			// 예전엔 이름으로만 찾았다. 폴더를 고르면 ID 가 저장되고, 비우면 기본 이름으로 찾는다(BoEquipmentService.upload)
			{ "ROOT", "최상위 폴더", "3. 장비 관리", "", "folder" },
			// 하위 폴더도 골라 두면 폴더 ID, 비우면 최상위 폴더 아래에서 이름으로 찾고 없으면 만든다(BoEquipmentService.upload)
			{ "RECEIPT", "구매영수증 폴더", "01. 구매영수증", "", "folder" },
			{ "ETC", "기타 첨부 폴더", "04. 장비첨부", "", "folder" },
			{ "SIGN", "서명한 대여증서 폴더", "03. 대여증서", "", "folder" },
			{ "FILE", "첨부 파일 이름 (기본: 올린 파일 이름 그대로)", "{원래이름}", "{원래이름},{올린날짜}", "" } });
		SCREENS.put("PARTNER", new String[] { "매출·매입처", "/admin/partner/openPartnerList.do" });
		FIELDS.put("PARTNER", new String[][] {
			{ "TEMP", "서류 글자 읽기용 임시 폴더 (읽고 바로 지움)", "", "", "folder" } });
		SCREENS.put("LAB", new String[] { "연구소 관리(연구일지)", "/admin/lab/openLabManage.do" });
		FIELDS.put("LAB", new String[][] {
			{ "SUB", "과제 폴더 안 하위 폴더 이름 (과제마다 만들어짐)", "02. 연구일지", "", "" },
			{ "FILE", "마감 PDF 이름", "{연월} 월간연구일지_{과제명}", "{연월},{과제명}", "" } });
		SCREENS.put("RECRUIT", new String[] { "모집 관리", "/admin/recruit/openRecruitList.do" });
		FIELDS.put("RECRUIT", new String[][] {
			{ "ROOT", "모집 최상위 폴더", "", "", "folder" },
			{ "YEAR", "연도 폴더 이름", "{연도}년도", "{연도}", "" },
			{ "MONTH", "월 폴더 이름", "{월}월", "{월}", "" },
			{ "POST", "모집 폴더 이름", "({등록일}) {고객사}_{사업명}", "{등록일},{고객사},{사업명}", "" },
			{ "SUB", "첨부 하위 폴더 이름 (모집 폴더마다)", "첨부", "", "" },
			{ "WORD", "지원 프로필 워드 이름", "{성명}_수행이력_{버전}", "{성명},{버전}", "" } });
	}
	private static final Pattern FOLDER_URL = Pattern.compile("(?:folders/|id=)([A-Za-z0-9_-]{10,})");
	private static final Pattern FOLDER_ID = Pattern.compile("[A-Za-z0-9_-]{10,}");
	private static final Pattern TOKEN = Pattern.compile("\\{([^{}]+)\\}");

	/** 예전부터 db.properties 에 있던 인사관리 폴더. STAFF.ROOT·PARTNER.TEMP 기본값 */
	@Value("${staff.drive.root:}")
	private String staffRoot;

	@Autowired
	private BoCalendarDao confDao;

	public String get(String screen, String key) {
		String v = confDao.ConfMap().get("DRIVE." + screen + "." + key);
		if (v != null && !v.trim().isEmpty()) return v.trim();
		if (("STAFF".equals(screen) && "ROOT".equals(key)) || ("PARTNER".equals(screen) && "TEMP".equals(key))) return staffRoot;
		for (String[] f : FIELDS.get(screen)) if (f[0].equals(key)) return f[2];
		throw new IllegalArgumentException("알 수 없는 설정입니다.");
	}

	/** ⚙ 창에 그릴 칸과 지금 값 */
	public Map<String, Object> view(String screen) {
		check(screen);
		List<Map<String, Object>> rows = new ArrayList<>();
		for (String[] f : FIELDS.get(screen)) {
			Map<String, Object> r = new HashMap<>();
			r.put("KEY", f[0]); r.put("LABEL", f[1]); r.put("DEFAULT", f[2]); r.put("TOKENS", f[3]); r.put("KIND", f[4]);
			String saved = confDao.ConfMap().get("DRIVE." + screen + "." + f[0]);
			r.put("VALUE", saved == null ? "" : saved);
			// 폴더 칸: 실제로 쓰는 값(저장값, 없으면 기본값). 폴더 ID 면 화면이 경로 이름을 찾아 보이고, 이름이면 '이름으로 찾음'
			if ("folder".equals(f[4])) {
				String eff = get(screen, f[0]);
				r.put("EFFECTIVE", eff == null ? "" : eff);
				r.put("IS_ID", isFolderId(eff));
			}
			rows.add(r);
		}
		Map<String, Object> out = new HashMap<>();
		out.put("title", SCREENS.get(screen)[0]);
		out.put("fields", rows);
		return out;
	}

	/** 빈 칸은 기본값으로 돌린다. 폴더 칸은 드라이브 주소를 붙여넣어도 ID 만 남긴다 */
	public void save(String screen, Map<String, Object> param) {
		check(screen);
		for (String[] f : FIELDS.get(screen)) {
			Object raw = param.get(f[0]);
			if (raw == null) continue;
			String v = String.valueOf(raw).trim();
			if (v.length() > 300) throw new IllegalArgumentException(f[1] + " 이(가) 너무 깁니다.");
			if ("folder".equals(f[4]) && !v.isEmpty()) {
				Matcher m = FOLDER_URL.matcher(v);
				if (m.find()) v = m.group(1);
				else if (v.equals(confDao.ConfMap().get("DRIVE." + screen + "." + f[0]))) continue; // 예전 방식(폴더 이름)으로 저장된 값을 안 바꾼 채 저장
				else if (!FOLDER_ID.matcher(v).matches()) throw new IllegalArgumentException(f[1] + ": 드라이브 폴더 주소를 붙여넣어 주세요.");
			} else if (!v.isEmpty()) {
				if (v.contains("/")) throw new IllegalArgumentException(f[1] + ": 이름에는 / 를 쓸 수 없습니다.");
				Matcher m = TOKEN.matcher(v);
				while (m.find()) {
					if (f[3].isEmpty() || !("," + f[3] + ",").contains(",{" + m.group(1) + "},")) throw new IllegalArgumentException(f[1] + ": {" + m.group(1) + "} 는 쓸 수 없는 이름표입니다.");
				}
			}
			confDao.ConfSave("DRIVE." + screen + "." + f[0], v);
		}
	}

	/** 드라이브 폴더 ID 인지(이름이 아니라). 폴더 이름에는 보통 공백·점이 있고, ID 는 영문·숫자·_- 20자 이상 */
	public static boolean isFolderId(String v) {
		return v != null && v.length() >= 20 && FOLDER_ID.matcher(v).matches();
	}

	/** 그 화면을 열 수 있는 주소. 이 주소를 열 수 있는 사람만 고친다 */
	public static String page(String screen) {
		check(screen);
		return SCREENS.get(screen)[1];
	}

	/** {이름표} 를 값으로 바꾸고 드라이브 이름에 못 쓰는 / 는 · 로 */
	public static String render(String pattern, Map<String, String> vars) {
		Matcher m = TOKEN.matcher(pattern);
		StringBuffer b = new StringBuffer();
		while (m.find()) {
			String v = vars.get(m.group(1));
			m.appendReplacement(b, Matcher.quoteReplacement(v == null ? "" : v.replace("/", "·")));
		}
		m.appendTail(b);
		return b.toString().trim();
	}

	private static void check(String screen) {
		if (!SCREENS.containsKey(screen)) throw new IllegalArgumentException("알 수 없는 화면입니다.");
	}
}
