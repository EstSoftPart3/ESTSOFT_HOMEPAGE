package com.eep.bo.deploy.service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 * 세무서 전달용 급여 엑셀. 사용자가 손으로 만들던 '이에스티_YYYY년_급여관리.xlsx' 와 같은 양식(C~S 칸, 구역 3개)으로
 * 달마다 시트 하나, 최근 달이 맨 앞. 전월과 값이 다른 칸은 노란색, 중요한 변화(신규·퇴사·기본급 변경·수습 종료)는 기타 칸에 적는다.
 */
public final class TaxExcel {

	static final String REG = "<정규직>", FREE = "<프리랜서>", ALBA = "<고용보험 아르바이트>";
	static final String[] SECTIONS = { REG, FREE, ALBA };
	private static final String[] REG_HEAD = { "번호", "이름", "주민번호", "근무형태", "입사일", "퇴사일", "기본급", "식대", "연구개발", "운전보조", "자녀보육", "상여", "수습", "수습급여", "기타공제", "상조회비", "기타" };
	private static final String[] FREE_HEAD = { "번호", "이름", "주민번호", "근무형태", "입사일", "퇴사일", "급여", "-", "-", "-", "-", "상여", "-", "기준급여", "-", "-", "기타" };
	static final int PAY = 6, BONUS = 11, PROB = 12, STD = 13, LEAVE = 5, ETC = 16, COLS = 17;
	private static final int FIRST_COL = 2; // C 칸부터 (A·B 는 사용자 엑셀의 확인용 칸)

	private TaxExcel() {
	}

	/** 한 사람의 한 구역 줄. v[0] 번호는 쓸 때 매긴다 */
	static final class Line {
		final String sec, key;
		final Object[] v = new Object[COLS];
		final boolean[] yellow = new boolean[COLS];
		final List<String> notes = new ArrayList<>();
		boolean added;

		Line(String sec, Object staffSq) {
			this.sec = sec;
			this.key = sec + "/" + staffSq;
		}
	}

	static String section(String type) {
		return PayCalc.isSalaried(type) ? REG : "EMP_INS".equals(type) ? ALBA : PayCalc.isOwn(type) ? FREE : null;
	}

	/**
	 * 한 달 급여 행 → 구역별 줄. 기타·외부 업체 몫은 급여가 아니라 빠지고, 한 사람이 두 구역(정규 + 알바 등)에 걸리면 줄이 둘이다.
	 * staff: STAFF_SQ → { RRN(복호화된 전체), JOIN_DT, LEAVE_DT }
	 */
	@SuppressWarnings("unchecked")
	static List<Line> lines(String ym, List<Map<String, Object>> rows, Map<String, Map<String, Object>> staff) {
		YearMonth m = YearMonth.parse(ym);
		List<Line> out = new ArrayList<>();
		for (Map<String, Object> r : rows) {
			String rowType = str(r.get("EMP_TYPE_CD"));
			// 구역별 건 금액. 비어 있는 형태는 행의 형태로 본다
			Map<String, Long> bySec = new LinkedHashMap<>();
			Map<String, Long> stdBySec = new HashMap<>();
			LocalDate probEnd = null;
			for (Map<String, Object> d : (List<Map<String, Object>>) r.getOrDefault("DETAILS", new ArrayList<>())) {
				String t = str(d.get("DEPLOY_TYPE")).isEmpty() ? rowType : str(d.get("DEPLOY_TYPE"));
				String sec = section(t);
				if (sec == null) {
					continue;
				}
				bySec.merge(sec, BoPayrollService.n(d.get("BASE_AMT")), Long::sum);
				stdBySec.put(sec, BoPayrollService.n(d.get("COST_PRICE")));
				LocalDate pe = PayCalc.date(d.get("PROB_END_DT"));
				if (pe != null && (probEnd == null || pe.isAfter(probEnd))) {
					probEnd = pe;
				}
			}
			String main = section(rowType);
			if (main == null) {
				main = bySec.isEmpty() ? null : bySec.keySet().iterator().next();
			}
			if (main == null) {
				continue; // 업체 몫만 있는 사람: 급여 아님
			}
			bySec.putIfAbsent(main, 0L);
			Map<String, Object> s = staff.getOrDefault(str(r.get("STAFF_SQ")), new HashMap<>());
			LocalDate join = PayCalc.date(s.get("JOIN_DT") != null ? s.get("JOIN_DT") : r.get("JOIN_DT")), leave = PayCalc.date(s.get("LEAVE_DT"));
			long others = 0;
			for (Map.Entry<String, Long> e : bySec.entrySet()) {
				if (!e.getKey().equals(main)) {
					others += e.getValue();
				}
			}
			for (Map.Entry<String, Long> e : bySec.entrySet()) {
				String sec = e.getKey();
				boolean isMain = sec.equals(main);
				Line l = new Line(sec, r.get("STAFF_SQ"));
				l.v[1] = str(r.get("STAFF_NM"));
				l.v[2] = str(s.get("RRN"));
				l.v[3] = REG.equals(sec) ? "정규직" : "계약직";
				if (join != null && (!REG.equals(sec) || join.getYear() == m.getYear())) {
					l.v[4] = md(join);
				}
				if (leave != null && YearMonth.from(leave).equals(m)) {
					l.v[LEAVE] = md(leave);
				}
				long bonus = isMain ? BoPayrollService.n(r.get("BONUS_AMT")) : 0;
				if (REG.equals(sec)) {
					l.v[PAY] = isMain ? BoPayrollService.n(r.get("BASE_AMT")) - others : e.getValue();
					if (isMain) {
						l.v[7] = BoPayrollService.n(r.get("MEAL_AMT"));
						l.v[8] = BoPayrollService.n(r.get("RESEARCH_AMT"));
						l.v[9] = BoPayrollService.n(r.get("DRIVE_AMT"));
						l.v[10] = BoPayrollService.n(r.get("CHILD_AMT"));
						l.v[14] = BoPayrollService.n(r.get("ETC_DED"));
						l.v[15] = BoPayrollService.n(r.get("MUTUAL_AMT"));
					}
					LocalDate pe = probEnd != null ? probEnd : join == null ? null : join.plusMonths(3).minusDays(1);
					if (pe != null && !pe.isBefore(m.atDay(1)) && (join == null || !join.isAfter(m.atEndOfMonth()))) {
						l.v[PROB] = "~" + md(pe);
						l.v[STD] = PayCalc.PROBATION_PAY;
					}
					String memo = str(r.get("MEMO")).trim();
					l.v[ETC] = isMain && !memo.equals("엑셀 이관") ? memo : "";
				} else {
					// 급여 = 그 달 실제 지급(상여 빼고), 기준급여 = 월 계약단가
					l.v[PAY] = isMain ? BoPayrollService.n(r.get("PAY_TOTAL")) - bonus - others : e.getValue();
					l.v[STD] = stdBySec.getOrDefault(sec, isMain ? BoPayrollService.n(r.get("COST_PRICE")) : 0L);
					l.v[ETC] = ALBA.equals(sec) ? "경영지원 아르바이트(소프트웨어X)" : "소프트웨어 프리랜서";
				}
				l.v[BONUS] = bonus;
				out.add(l);
			}
		}
		return out;
	}

	/** 전월 줄과 비교해 다른 칸을 노랗게, 중요한 변화는 기타에 적는다 */
	static void compare(List<Line> cur, List<Line> prev) {
		Map<String, Line> p = new HashMap<>();
		prev.forEach(l -> p.put(l.key, l));
		for (Line l : cur) {
			Line b = p.get(l.key);
			if (b == null) {
				l.added = true;
				l.notes.add("신규");
			} else {
				for (int i = 1; i < COLS; i++) {
					l.yellow[i] = !same(l.v[i], b.v[i]);
				}
				int base = REG.equals(l.sec) ? PAY : STD;
				long now = num(l.v[base]), before = num(b.v[base]);
				if (REG.equals(l.sec) && l.v[PROB] != null) {
					// 수습 중 기본급은 매달 일할이 달라질 수 있어 변경으로 적지 않는다
				} else if (now != 0 && before != 0 && now != before) {
					l.notes.add((REG.equals(l.sec) ? "기본급" : "기준급여") + " 변경(전월 " + PayCalc.won(before) + ")");
				}
				if (REG.equals(l.sec) && b.v[PROB] != null && l.v[PROB] == null) {
					l.notes.add("수습 종료");
				}
			}
			if (l.v[LEAVE] != null) {
				l.notes.add("퇴사 " + l.v[LEAVE]);
			}
		}
	}

	/** 한 달 = { YM, CLOSED, LINES } . 받은 순서대로 시트를 만든다 */
	static byte[] build(List<Map<String, Object>> months) throws IOException {
		try (XSSFWorkbook wb = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
			Font bold = wb.createFont();
			bold.setBold(true);
			Font big = wb.createFont();
			big.setBold(true);
			big.setFontHeightInPoints((short) 14);
			CellStyle title = wb.createCellStyle(), sec = wb.createCellStyle(), head = cell(wb, false, false), text = cell(wb, false, false), num = cell(wb, true, false),
					textY = cell(wb, false, true), numY = cell(wb, true, true);
			title.setFont(big);
			sec.setFont(bold);
			head.setFont(bold);
			head.setAlignment(HorizontalAlignment.CENTER);
			head.setFillForegroundColor(IndexedColors.PALE_BLUE.getIndex());
			head.setFillPattern(FillPatternType.SOLID_FOREGROUND);
			for (Map<String, Object> mo : months) {
				String ym = str(mo.get("YM"));
				YearMonth m = YearMonth.parse(ym);
				boolean closed = Boolean.TRUE.equals(mo.get("CLOSED"));
				Sheet sh = wb.createSheet((m.getYear() % 100) + "년 " + m.getMonthValue() + "월" + (closed ? "" : "(작성중)"));
				int[] widths = { 3, 3, 6, 10, 16, 10, 8, 8, 12, 10, 10, 10, 10, 11, 10, 12, 10, 10, 34 };
				for (int i = 0; i < widths.length; i++) {
					sh.setColumnWidth(i, widths[i] * 256);
				}
				int r = 0;
				Row t = sh.createRow(r++);
				put(t, FIRST_COL, m.getYear(), title);
				put(t, FIRST_COL + 2, m.getMonthValue(), title);
				put(t, FIRST_COL + 3, "월 이에스티 급여내역" + (closed ? "" : " (작성중 · 마감 전 값)"), title);
				@SuppressWarnings("unchecked")
				List<Line> lines = (List<Line>) mo.get("LINES");
				for (String s : SECTIONS) {
					r++;
					Row sr = sh.createRow(r++);
					put(sr, FIRST_COL, s, sec);
					if (REG.equals(s)) {
						put(sr, FIRST_COL + 14, "기타공제(예:회사 자체대출 원금상환액 원천징수)", null);
					}
					Row hr = sh.createRow(r++);
					String[] h = REG.equals(s) ? REG_HEAD : FREE_HEAD;
					for (int i = 0; i < h.length; i++) {
						put(hr, FIRST_COL + i, h[i], head);
					}
					int no = 0;
					for (Line l : lines) {
						if (!s.equals(l.sec)) {
							continue;
						}
						Row row = sh.createRow(r++);
						l.v[0] = ++no;
						for (int i = 0; i < COLS; i++) {
							Object v = i == ETC ? etc(l) : l.v[i];
							boolean y = l.added || l.yellow[i] || (i == ETC && !l.notes.isEmpty());
							boolean isNum = v instanceof Number;
							if (isNum && ((Number) v).longValue() == 0 && i != 0) {
								v = null; // 0 원은 비워 둔다(사용자 엑셀과 같게)
							}
							Cell c = row.createCell(FIRST_COL + i);
							c.setCellStyle(isNum ? (y ? numY : num) : (y ? textY : text));
							if (v instanceof Number) {
								c.setCellValue(((Number) v).doubleValue());
							} else if (v != null) {
								c.setCellValue(v.toString());
							}
						}
					}
					r++;
				}
			}
			wb.write(out);
			return out.toByteArray();
		}
	}

	private static String etc(Line l) {
		String base = str(l.v[ETC]);
		if (l.notes.isEmpty()) {
			return base;
		}
		return (base.isEmpty() ? "" : base + " / ") + String.join(", ", l.notes);
	}

	private static CellStyle cell(XSSFWorkbook wb, boolean number, boolean yellow) {
		CellStyle s = wb.createCellStyle();
		s.setBorderTop(BorderStyle.THIN);
		s.setBorderBottom(BorderStyle.THIN);
		s.setBorderLeft(BorderStyle.THIN);
		s.setBorderRight(BorderStyle.THIN);
		if (number) {
			s.setDataFormat(wb.createDataFormat().getFormat("#,##0"));
		}
		if (yellow) {
			s.setFillForegroundColor(IndexedColors.YELLOW.getIndex());
			s.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		}
		return s;
	}

	private static void put(Row row, int col, Object v, CellStyle style) {
		Cell c = row.createCell(col);
		if (v instanceof Number) {
			c.setCellValue(((Number) v).doubleValue());
		} else {
			c.setCellValue(str(v));
		}
		if (style != null) {
			c.setCellStyle(style);
		}
	}

	private static boolean same(Object a, Object b) {
		if (a instanceof Number || b instanceof Number) {
			return num(a) == num(b);
		}
		return str(a).equals(str(b));
	}

	private static long num(Object v) {
		return v instanceof Number ? ((Number) v).longValue() : 0;
	}

	static String md(LocalDate d) {
		return d.getMonthValue() + "/" + d.getDayOfMonth();
	}

	private static String str(Object v) {
		return Objects.toString(v, "");
	}
}
