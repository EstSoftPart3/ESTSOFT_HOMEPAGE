package com.eep.bo.deploy.service;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;

/**
 * 급여대장(1명 3행), 사업소득대장(1명 2행) 파일을 읽는다. DB 를 쓰지 않는다.
 * 합계가 맞지 않는 행이 있으면 잘못 읽은 것이므로 파일 전체를 거부한다.
 */
public final class PayLedgerParser {

	public static final String KIND_PAY = "PAY";
	public static final String KIND_BIZ = "BIZ";
	private static final Pattern PAY_YM = Pattern.compile("(\\d{4})\\s*년\\s*(\\d{1,2})\\s*월");
	private static final Pattern BIZ_YM = Pattern.compile("(\\d{4})\\s*[.년]\\s*(\\d{1,2})");
	private static final Pattern DIGITS = Pattern.compile("\\d+");
	private static final DataFormatter FORMAT = new DataFormatter();

	private PayLedgerParser() {
	}

	public static class Result {
		public String kind;
		public String ym;
		public final List<Map<String, Object>> rows = new ArrayList<>();
	}

	public static Result parse(byte[] file) {
		try (Workbook wb = WorkbookFactory.create(new ByteArrayInputStream(file))) {
			Sheet s = wb.getSheetAt(0);
			for (int r = 0; r <= Math.min(12, s.getLastRowNum()); r++) {
				if ("사원번호".equals(squash(text(s, r, 0)))) {
					return payroll(s, r);
				}
				if ("NO".equals(squash(text(s, r, 0))) && "코드".equals(squash(text(s, r, 1)))) {
					return business(s, r);
				}
			}
		} catch (IllegalArgumentException e) {
			throw e;
		} catch (Exception e) {
			throw new IllegalArgumentException("엑셀 파일을 읽지 못했습니다. (" + e.getClass().getSimpleName() + ")");
		}
		throw new IllegalArgumentException("급여대장이나 사업소득대장 양식이 아닙니다.");
	}

	private static Result payroll(Sheet s, int head) {
		require(s, head, 2, "기본급");
		require(s, head, 9, "국민연금");
		require(s, head + 1, 13, "상조회비");
		require(s, head + 2, 14, "차인지급액");
		Result out = new Result();
		out.kind = KIND_PAY;
		out.ym = titleYm(s, head);
		for (int r = head + 3; r <= s.getLastRowNum(); r++) {
			if (!isCode(text(s, r, 0)) || text(s, r, 1).isEmpty()) {
				continue;
			}
			Map<String, Object> m = row(text(s, r, 0), text(s, r, 1));
			long pay = sum(s, r, 2, 7);
			long ded = 0;
			String[][] cells = { { "NP_AMT", "HI_AMT", "EI_AMT", "LTC_AMT", "IT_AMT", "LIT_AMT" }, { "NP_SETTLE", "HI_SETTLE", "EI_SETTLE", "LTC_SETTLE", "MUTUAL_AMT" }, { "ETC_DED" } };
			for (int line = 0; line < cells.length; line++) {
				for (int i = 0; i < cells[line].length; i++) {
					long v = num(s, r + line, 9 + i);
					m.put(cells[line][i], v);
					ded += v;
				}
			}
			long payTotal = num(s, r + 2, 8), dedTotal = num(s, r + 1, 14), net = num(s, r + 2, 14);
			if (pay != payTotal || ded != dedTotal || payTotal - dedTotal != net) {
				throw new IllegalArgumentException("급여대장 " + (r + 1) + "행의 합계가 맞지 않아 읽지 않았습니다.");
			}
			finish(m, payTotal, dedTotal, net);
			out.rows.add(m);
		}
		return nonEmpty(out);
	}

	private static Result business(Sheet s, int head) {
		require(s, head, 4, "지급액");
		require(s, head + 1, 5, "지방소득세");
		require(s, head + 1, 6, "고용보험료");
		require(s, head + 1, 7, "산재보험료");
		Result out = new Result();
		out.kind = KIND_BIZ;
		for (int r = head + 2; r <= s.getLastRowNum(); r++) {
			if (!isCode(text(s, r, 0)) || text(s, r, 2).isEmpty()) {
				continue;
			}
			Map<String, Object> m = row(text(s, r, 1), text(s, r, 2));
			String ym = ym(BIZ_YM, text(s, r, 3));
			if (out.ym == null) {
				out.ym = ym;
			} else if (!out.ym.equals(ym)) {
				throw new IllegalArgumentException("사업소득대장에 귀속월이 다른 행이 섞여 있습니다.");
			}
			long pay = num(s, r, 4), it = num(s, r, 5), lit = num(s, r + 1, 5), ei = num(s, r + 1, 6), acc = num(s, r + 1, 7), loan = num(s, r, 7), net = num(s, r + 1, 8);
			m.put("IT_AMT", it);
			m.put("LIT_AMT", lit);
			m.put("EI_AMT", ei);
			m.put("ACC_AMT", acc);
			m.put("ETC_DED", loan); // 학자금상환액. 예술/특고인 경비는 차인지급액 계산에 들어가지 않는 참고값이다
			long ded = it + lit + ei + acc + loan;
			if (pay - ded != net) {
				throw new IllegalArgumentException("사업소득대장 " + (r + 1) + "행의 합계가 맞지 않아 읽지 않았습니다.");
			}
			finish(m, pay, ded, net);
			out.rows.add(m);
			r++;
		}
		return nonEmpty(out);
	}

	private static Result nonEmpty(Result r) {
		if (r.rows.isEmpty() || r.ym == null) {
			throw new IllegalArgumentException("대장에서 읽을 사람이나 귀속월을 찾지 못했습니다.");
		}
		return r;
	}

	private static String titleYm(Sheet s, int head) {
		for (int r = 0; r < head; r++) {
			Row row = s.getRow(r);
			if (row == null) {
				continue;
			}
			for (Cell c : row) {
				String t = FORMAT.formatCellValue(c);
				if (t.contains("귀속")) {
					return ym(PAY_YM, t.substring(t.indexOf("귀속")));
				}
			}
		}
		return null;
	}

	private static String ym(Pattern p, String text) {
		Matcher m = p.matcher(text);
		return m.find() ? String.format("%s-%02d", m.group(1), Integer.parseInt(m.group(2))) : null;
	}

	private static Map<String, Object> row(String code, String name) {
		Map<String, Object> m = new HashMap<>();
		m.put("LEDGER_CD", code);
		m.put("LEDGER_NM", name);
		return m;
	}

	private static void finish(Map<String, Object> m, long pay, long ded, long net) {
		m.put("LEDGER_PAY", pay);
		m.put("LEDGER_DED", ded);
		m.put("LEDGER_NET", net);
	}

	private static boolean isCode(String s) {
		return DIGITS.matcher(s).matches();
	}

	private static long sum(Sheet s, int r, int from, int to) {
		long v = 0;
		for (int c = from; c <= to; c++) {
			v += num(s, r, c);
		}
		return v;
	}

	private static void require(Sheet s, int r, int c, String label) {
		if (!label.equals(squash(text(s, r, c)))) {
			throw new IllegalArgumentException("대장 양식이 달라 읽지 않았습니다. (" + label + " 칸을 찾지 못함)");
		}
	}

	private static String squash(String s) {
		return s.replaceAll("\\s", "");
	}

	private static String text(Sheet s, int r, int c) {
		Row row = s.getRow(r);
		Cell cell = row == null ? null : row.getCell(c);
		return cell == null ? "" : FORMAT.formatCellValue(cell).trim();
	}

	private static long num(Sheet s, int r, int c) {
		Row row = s.getRow(r);
		Cell cell = row == null ? null : row.getCell(c);
		if (cell == null) {
			return 0;
		}
		if (cell.getCellTypeEnum() == CellType.NUMERIC) {
			return Math.round(cell.getNumericCellValue());
		}
		String t = FORMAT.formatCellValue(cell).replace(",", "").trim();
		return t.isEmpty() ? 0 : Long.parseLong(t);
	}
}
