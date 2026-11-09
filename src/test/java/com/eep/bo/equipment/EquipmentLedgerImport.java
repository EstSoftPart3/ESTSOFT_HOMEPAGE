package com.eep.bo.equipment;

import java.io.File;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;

/**
 * 장비관리대장.xlsx 를 sql/equipment.sql 의 표에 넣는 SQL 과 검토 목록으로 바꾼다. 한 번만 쓰는 도구라 war 에 넣지 않는다.
 * 사람 이름이 들어가므로 결과 파일은 저장소 밖에 만든다.
 * 인자 없이 실행하면 자체 확인, 인자가 있으면: <대장.xlsx> <결과.sql> <검토.txt>
 * 실행: java -cp "target/test-classes;target/est_eep/WEB-INF/lib/*" com.eep.bo.equipment.EquipmentLedgerImport
 */
public class EquipmentLedgerImport {

	private static final Pattern LINE = Pattern.compile("^([^/]*)/\\s*(\\d{4}-\\d{1,2}-\\d{1,2})?\\s*(~)?\\s*(\\d{4}-\\d{1,2}-\\d{1,2})?\\s*\\??\\s*(?:/(.*))?$");
	private static final Pattern DATE = Pattern.compile("\\d{4}-\\d{1,2}-\\d{1,2}");
	private static final Pattern SECRET = Pattern.compile("[(\\[]?\\s*(비밀번호|패스워드|password|\\bpw\\b)\\s*[::=]?\\s*\\S*\\s*[)\\]]?", Pattern.CASE_INSENSITIVE);
	private static final Pattern NO = Pattern.compile("(NB|MT|DT|MU|KB)[-–_](\\d+)");

	static class Hist {
		String holder, start, end, purpose;
		boolean slash;
	}

	static Hist parse(String line) {
		Hist h = new Hist();
		Matcher m = LINE.matcher(line.trim());
		if (m.matches()) {
			h.slash = true;
			h.holder = m.group(1).trim();
			h.start = date(m.group(2));
			h.end = date(m.group(4));
			h.purpose = m.group(5) == null ? "" : m.group(5).trim();
		} else if (line.contains("/")) {
			String[] p = line.trim().split("/");
			h.slash = true;
			h.holder = p[0].trim();
			h.purpose = p[p.length - 1].trim();
		} else {
			h.holder = line.trim();
		}
		return h;
	}

	static String date(String s) {
		if (s == null) return null;
		String[] p = s.split("-");
		try {
			return LocalDate.of(Integer.parseInt(p[0]), Integer.parseInt(p[1]), Integer.parseInt(p[2])).toString();
		} catch (RuntimeException e) {
			return null;
		}
	}

	static String normalizeNo(String no) {
		return no.trim().replace('_', '-').replace('–', '-').replace('—', '-').replaceAll("\\s", "").toUpperCase();
	}

	static String stripSecret(String memo) {
		return SECRET.matcher(memo).replaceAll("").trim();
	}

	static String q(String s) {
		return s == null || s.isEmpty() ? "NULL" : "'" + s.replace("\\", "\\\\").replace("'", "''") + "'";
	}

	private static final DataFormatter FMT = new DataFormatter();

	private static String cell(Row row, int i) {
		return row.getCell(i) == null ? "" : FMT.formatCellValue(row.getCell(i)).trim();
	}

	public static void main(String[] args) throws Exception {
		if (args.length == 0) {
			check();
			return;
		}
		List<String> sql = new ArrayList<>(), review = new ArrayList<>();
		sql.add("SET NAMES utf8mb4;");
		sql.add("START TRANSACTION;");
		int[] closedNoEnd = { 0 };
		try (Workbook wb = WorkbookFactory.create(new File(args[0]), null, true)) {
			for (int s = 0; s <= 5; s++) {
				Sheet sheet = wb.getSheetAt(s);
				boolean simple = s == 3 || s == 4; // 마우스·키보드 시트는 사양 열이 없다
				for (Row row : sheet) {
					String rawNo = cell(row, 1);
					if (!rawNo.contains("EQPMNT")) continue;
					equipment(row, simple, sql, review, closedNoEnd);
				}
			}
			issues(wb.getSheetAt(6), sql, review);
		}
		sql.add("COMMIT;");
		review.add("과거 줄인데 반납일이 없는 이력: " + closedNoEnd[0] + "줄 (반납일 빈칸으로 닫음)");
		try (PrintWriter w = new PrintWriter(args[1], StandardCharsets.UTF_8.name())) {
			sql.forEach(w::println);
		}
		try (PrintWriter w = new PrintWriter(args[2], StandardCharsets.UTF_8.name())) {
			review.forEach(w::println);
		}
		System.out.println("SQL " + sql.size() + "줄, 검토 " + review.size() + "건");
	}

	private static void equipment(Row r, boolean simple, List<String> sql, List<String> review, int[] closedNoEnd) {
		String no = normalizeNo(cell(r, 1)), type = no.replaceAll(".*-(NB|MT|DT|MU|KB)-.*", "$1");
		int st = simple ? 7 : 12;
		String statusText = cell(r, st), hist = cell(r, st + 1), check = cell(r, st + 2), memo = cell(r, st + 3);
		String status = statusText.contains("대여") ? "RENT" : statusText.contains("보관") ? "STOCK" : statusText.contains("폐기") ? "DISPOSED" : statusText.contains("분실") ? "LOST" : null;
		if (status == null) {
			review.add(no + ": 상태 값을 알 수 없어 건너뜀");
			return;
		}
		String clean = stripSecret(memo);
		if (!clean.equals(memo)) review.add(no + ": 특이사항에서 비밀번호로 보이는 내용을 뺐음");
		String[] lines = hist.isEmpty() ? new String[0] : hist.split("[\\r\\n]+");
		String location = null;
		if (status.equals("STOCK") && lines.length > 0 && !parse(lines[0]).slash) location = parse(lines[0]).holder;
		Matcher d = DATE.matcher(check);
		String checkDt = d.find() ? date(d.group()) : null, checkNm = checkDt != null && check.contains(":") ? check.substring(check.indexOf(':') + 1).trim() : null;
		String excl = check.contains("영구") ? "Y" : "N";
		if (checkDt == null && !check.isEmpty() && excl.equals("N")) review.add(no + ": 점검일자 값을 해석하지 못함");
		String spec = simple ? "NULL, NULL, NULL, NULL, NULL, " + q(cell(r, 6)) : q(cell(r, 6)) + ", " + q(cell(r, 7)) + ", " + q(cell(r, 8)) + ", " + q(cell(r, 9)) + ", " + q(cell(r, 10)) + ", " + q(cell(r, 11));
		boolean gone = status.equals("DISPOSED") || status.equals("LOST");
		sql.add("INSERT INTO TB_EEP_EQP_M (EQP_NO, TYPE_CD, BRAND_NM, MODEL_NM, SERIAL_NO, CPU_SPEC, MEM_SPEC, SSD_SPEC, HDD_SPEC, LAN_YN, ETC_TXT, STATUS_CD, LOCATION_NM, AUDIT_EXCL_YN, LAST_CHECK_DT, LAST_CHECK_NM, MEMO, UPDT_EMPLY_ID, UPDT_DT) VALUES ("
				+ q(no) + ", " + q(type) + ", " + q(cell(r, 3)) + ", " + q(cell(r, 4)) + ", " + q(cell(r, 5)) + ", " + spec + ", " + q(status) + ", " + q(location) + ", " + q(excl) + ", " + q(checkDt) + ", " + q(checkNm) + ", " + q(clean) + ", 'IMPORT', NOW());");
		sql.add("SET @e = LAST_INSERT_ID();");
		boolean opened = false;
		for (int i = 0; i < lines.length; i++) {
			Hist h = parse(lines[i]);
			if (i == 0 && location != null) continue;
			boolean top = i == 0 && status.equals("RENT");
			if (top) opened = true;
			if (top && !h.slash) review.add(no + ": 대여중인데 사용처 글자만 있음 (사용자 확인)");
			else if (top && h.end != null) review.add(no + ": 대여중인데 맨 윗줄에 반납일이 있음 (진행 중으로 넣음)");
			else if (top && h.start == null) review.add(no + ": 대여중인데 대여일이 없음");
			if (!top && h.slash && h.start != null && h.end == null) closedNoEnd[0]++;
			if (!top && !h.slash) review.add(no + ": 날짜 없는 이력 " + (i + 1) + "번째 줄");
			if (h.holder.isEmpty()) h.holder = "미상";
			sql.add("INSERT INTO TB_EEP_EQP_RENT_H (EQP_SQ, STAFF_SQ, HOLDER_NM, START_DT, END_DT, OPEN_YN, PURPOSE_NM, REG_EMPLY_ID, REG_DT) VALUES (@e, (SELECT MIN(STAFF_SQ) FROM TB_EEP_HR_STAFF_M WHERE STAFF_NM = "
					+ q(h.holder) + " HAVING COUNT(*) = 1), " + q(h.holder) + ", " + q(h.start) + ", " + q(h.end) + ", " + q(top ? "Y" : "N") + ", " + q(h.purpose) + ", 'IMPORT', NOW());");
		}
		if (status.equals("RENT") && !opened) {
			review.add(no + ": 대여중인데 이력이 없어 사용자를 미상으로 넣음");
			sql.add("INSERT INTO TB_EEP_EQP_RENT_H (EQP_SQ, HOLDER_NM, OPEN_YN, REG_EMPLY_ID, REG_DT) VALUES (@e, '미상', 'Y', 'IMPORT', NOW());");
		}
		if (gone) sql.add("UPDATE TB_EEP_EQP_M SET DISPOSE_REASON = MEMO WHERE EQP_SQ = @e;");
	}

	/** 월별 특이사항 맨 마지막 달만 열린 이슈로 넣는다. 번호가 있는 줄부터 다음 번호 줄 전까지가 한 건이다 */
	private static void issues(Sheet sheet, List<String> sql, List<String> review) {
		String month = "", text = "";
		for (Row row : sheet) {
			if (row.getRowNum() < 3 || cell(row, 1).isEmpty()) continue;
			month = cell(row, 1);
			text = row.getCell(2) == null ? "" : row.getCell(2).toString();
		}
		Matcher ym = Pattern.compile("(\\d{4})년\\s*(\\d{1,2})월").matcher(month);
		String open = ym.find() ? String.format("%s-%02d-01", ym.group(1), Integer.parseInt(ym.group(2))) : LocalDate.now().toString();
		List<String[]> blocks = blocks(text);
		for (String[] b : blocks) {
			if (b[0] == null) {
				review.add("월별 특이사항: 장비번호를 찾지 못한 내용 있음");
				continue;
			}
			sql.add("INSERT INTO TB_EEP_EQP_ISSUE_H (EQP_SQ, CONTENT, OPEN_DT, REG_EMPLY_ID) SELECT EQP_SQ, " + q(b[1]) + ", " + q(open) + ", 'IMPORT' FROM TB_EEP_EQP_M WHERE ACTIVE_NO LIKE " + q("%-" + b[0]) + ";");
		}
	}

	/** {NB-033 처럼 짧은 번호(없으면 null), 내용} */
	static List<String[]> blocks(String text) {
		List<String[]> out = new ArrayList<>();
		String[] cur = null;
		for (String line : text.split("[\\r\\n]+")) {
			if (line.trim().isEmpty()) continue;
			Matcher m = NO.matcher(line);
			if (m.find()) {
				cur = new String[] { m.group(1) + "-" + String.format("%03d", Integer.parseInt(m.group(2))), "" };
				out.add(cur);
				// '이름(번호)' 만 있는 머리줄은 내용에 넣지 않는다
				if (line.trim().matches("^\\S+\\s*\\([^)]*\\)\\s*$")) continue;
			} else if (cur == null) {
				cur = new String[] { null, "" };
				out.add(cur);
			}
			cur[1] = (cur[1].isEmpty() ? "" : cur[1] + " ") + line.trim().replaceFirst("^-\\s*", "");
		}
		return out;
	}

	private static void check() {
		Hist h = parse("홍길동/2026-08-27~/프로젝트");
		same(h.holder + "|" + h.start + "|" + h.end + "|" + h.purpose, "홍길동|2026-08-27|null|프로젝트", "진행 중");
		h = parse("홍길동/2024-1-5~2025-5-09/재택근무용");
		same(h.start + "|" + h.end, "2024-01-05|2025-05-09", "날짜 자리수 맞춤");
		h = parse("연구부서(김예시)/2025-06-18/연구용>대표가 사용중");
		same(h.holder + "|" + h.start + "|" + h.end + "|" + h.purpose, "연구부서(김예시)|2025-06-18|null|연구용>대표가 사용중", "물결표 없는 날짜");
		h = parse("홍길동/-/프로젝트");
		same(h.holder + "|" + h.start + "|" + h.purpose, "홍길동|null|프로젝트", "날짜 자리에 대시");
		h = parse("이샘플/~2023-01-02/");
		same(h.start + "|" + h.end + "|" + h.purpose, "null|2023-01-02|", "시작일 없음");
		h = parse("이샘플/2026-01-01~?/프로젝트");
		same(h.start + "|" + h.end + "|" + h.purpose, "2026-01-01|null|프로젝트", "반납일 물음표");
		h = parse("교육실");
		same(h.holder + "|" + h.slash, "교육실|false", "위치만");
		same(String.valueOf(date("2026-13-40")), "null", "없는 날짜");
		same(normalizeNo("ESTSW-EQPMNT-MT–001"), "ESTSW-EQPMNT-MT-001", "긴 대시");
		same(stripSecret("유지보수용 ( 비밀번호 : 0000 )"), "유지보수용", "비밀번호 제거");
		same(stripSecret("pw:abcd 재설치"), "재설치", "pw 제거");
		same(stripSecret("HDMI 케이블 동봉"), "HDMI 케이블 동봉", "다른 글자는 유지");
		same(q("O'Neil\\"), "'O''Neil\\\\'", "SQL 이스케이프");
		List<String[]> b = blocks("홍길동(ESTSW-EQPMNT-MT-035)\n - 포트가 끊김\n진행에 문제 없음\n - 김예시 노트북(NB-33)이 꺼짐");
		same(b.size() + "|" + b.get(0)[0] + "|" + b.get(0)[1], "2|MT-035|포트가 끊김 진행에 문제 없음", "머리줄 + 내용");
		same(b.get(1)[0] + "|" + b.get(1)[1], "NB-033|김예시 노트북(NB-33)이 꺼짐", "한 줄 이슈");
		System.out.println("EquipmentLedgerImport OK");
	}

	private static void same(String actual, String expected, String name) {
		if (!expected.equals(actual)) throw new AssertionError(name + ": " + actual);
	}
}
