package com.eep.bo.staff.service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFTable;
import org.apache.poi.xwpf.usermodel.XWPFTableCell;
import org.apache.poi.xwpf.usermodel.XWPFTableRow;

/**
 * 워드 이력카드(개인이력카드 + SKILL INVENTORY). 가져오기는 표를 읽고, 만들기는 같은 양식으로 새로 쓴다. DB·네트워크를 쓰지 않는다.
 * 만들기는 칸 합치기를 POI(가벼운 스키마)로 쓰기 어려워 document.xml 을 직접 써서 zip 으로 묶는다.
 * shortcut: 양식의 글꼴·칸 너비는 비슷하게 맞춘 것이라 원본과 완전히 같지는 않다. 틀이 달라져야 하면 양식 파일을 채우는 방식으로 바꾼다.
 */
public final class StaffCareerWord {

	private static final Pattern PERIOD = Pattern.compile("((?:19|20)\\d{2})\\s*[.\\-/년]\\s*(\\d{1,2})[^~\\d]*~\\s*(?:((?:19|20)\\d{2})\\s*[.\\-/년]\\s*(\\d{1,2}))?");
	/** 머리글이 없을 때 SKILL INVENTORY 한 줄의 칸 순서(회사 양식: 4번째는 담당업무) */
	private static final String[] CELLS = { "PRJ_NM", "PERIOD", "CLIENT_NM", "WORK_NM", "IND_NM", "APP_NM", "ROLE_NM", "MACHINE_NM", "OS_NM", "LANG_NM", "DBMS_NM", "TOOL_NM", "FRAMEWORK_NM", "ETC_NM" };
	/** 머리글 글자 → 칸. 앞에 있는 것부터 본다(「근무회사」를 「업무」보다, 「응용」을 「개발분야」보다 먼저) */
	private static final String[][] HEADS = { { "프로젝트|업무명", "PRJ_NM" }, { "기간", "PERIOD" }, { "고객", "CLIENT_NM" }, { "근무회사|소속", "COMPANY_NM" }, { "업무", "WORK_NM" },
			{ "산업", "IND_NM" }, { "응용", "APP_NM" }, { "역할", "ROLE_NM" }, { "기종", "MACHINE_NM" }, { "TOOL|툴", "TOOL_NM" }, { "^O\\.?S$|운영체제", "OS_NM" }, { "언어", "LANG_NM" },
			{ "DBMS|^DB$", "DBMS_NM" }, { "FRAME|프레임", "FRAMEWORK_NM" }, { "기타", "ETC_NM" } };

	private StaffCareerWord() {
	}

	// ── 가져오기 ──

	/**
	 * 기간 칸이 '2010.03 ~ 2012.10' 같은 줄을 프로젝트로 읽는다(표가 쪽마다 나뉘어 있어도 된다).
	 * 칸은 표 머리글 글자로 맞춘다(합친 칸은 칸 너비대로 펼친다). 머리글을 못 찾은 표는 회사 양식 순서(CELLS)로 읽는다
	 */
	public static List<Map<String, Object>> parse(InputStream in) throws IOException {
		List<Map<String, Object>> out = new ArrayList<>();
		try (XWPFDocument doc = new XWPFDocument(in)) {
			String[] fields = null; // 앞 표에서 읽은 머리글(쪽이 나뉜 표는 머리글이 첫 표에만 있을 수 있다)
			for (XWPFTable t : doc.getTables()) {
				List<String[]> heads = new ArrayList<>();
				boolean data = false;
				for (XWPFTableRow r : t.getRows()) {
					String[] cells = grid(r);
					boolean known = fields != null && fields.length == cells.length;
					Map<String, Object> row = known || cells.length >= 13 ? parseRow(cells, known ? fields : CELLS) : null;
					if (row != null) {
						out.add(row);
						data = true;
						continue;
					}
					String all = String.join(" ", cells);
					if (!data && (heads.isEmpty() ? all.contains("프로젝트") && all.contains("기간") : heads.size() < 3)) {
						heads.add(cells);
						String[] f = headFields(heads);
						if (f != null) fields = f;
					}
				}
			}
		}
		return out;
	}

	/** 한 줄의 칸 글자를 칸 너비(gridSpan)대로 펼친다. 합친 칸은 같은 글자가 여러 칸에 들어간다 */
	private static String[] grid(XWPFTableRow r) {
		List<String> out = new ArrayList<>();
		for (XWPFTableCell c : r.getTableCells()) {
			int span = 1;
			if (c.getCTTc().getTcPr() != null && c.getCTTc().getTcPr().getGridSpan() != null) span = Math.max(1, c.getCTTc().getTcPr().getGridSpan().getVal().intValue());
			String t = text(c, "\n");
			for (int i = 0; i < span; i++) out.add(t);
		}
		return out.toArray(new String[0]);
	}

	/** 머리글 줄들(위 줄 → 아래 줄)로 칸마다 필드를 정한다. 아래 줄 글자가 있으면 그것을 쓴다. 프로젝트명·기간을 못 찾으면 null */
	static String[] headFields(List<String[]> heads) {
		int n = 0;
		for (String[] h : heads) n = Math.max(n, h.length);
		String[] out = new String[n];
		for (int i = 0; i < n; i++) {
			String label = "";
			for (String[] h : heads) if (i < h.length && !h[i].trim().isEmpty()) label = h[i].replaceAll("\\s+", "");
			out[i] = "";
			for (String[] x : HEADS) {
				if (Pattern.compile(x[0], Pattern.CASE_INSENSITIVE).matcher(label).find()) {
					out[i] = x[1];
					break;
				}
			}
		}
		List<String> f = java.util.Arrays.asList(out);
		return f.contains("PRJ_NM") && f.contains("PERIOD") ? out : null;
	}

	static Map<String, Object> parseRow(String[] cells, String[] fields) {
		int p = java.util.Arrays.asList(fields).indexOf("PERIOD");
		if (p < 0 || p >= cells.length) return null;
		Matcher m = PERIOD.matcher(cells[p].replace('\n', ' '));
		if (!m.find()) return null;
		Map<String, Object> row = new LinkedHashMap<>();
		for (int i = 0; i < fields.length && i < cells.length; i++) {
			String c = fields[i];
			if (c.isEmpty() || row.containsKey(c)) continue; // 모르는 칸·합친 칸의 둘째 이후는 건너뜀
			if ("PERIOD".equals(c)) {
				row.put("START_YM", m.group(1) + "-" + pad(m.group(2)));
				row.put("END_YM", m.group(3) == null ? "" : m.group(3) + "-" + pad(m.group(4)));
				row.put("PERIOD", "");
			} else if (StaffCareerService.MULTI.contains(c)) {
				// 여러 값은 쉼표·줄바꿈·「/」로만 나눈다(「PL 및 개발자」 같은 띄어 쓴 역할은 한 값)
				row.put(c, join(cells[i].split("[,\\n/]")));
			} else {
				row.put(c, cells[i].replaceAll("\\s+", " ").trim());
			}
		}
		row.remove("PERIOD");
		Object prj = row.get("PRJ_NM");
		return prj == null || prj.toString().isEmpty() ? null : row;
	}

	private static String text(XWPFTableCell cell, String sep) {
		StringBuilder b = new StringBuilder();
		for (XWPFParagraph p : cell.getParagraphs()) b.append(b.length() > 0 ? sep : "").append(p.getText());
		return b.toString();
	}

	private static String join(String[] parts) {
		Set<String> out = new LinkedHashSet<>();
		for (String p : parts) if (!p.trim().isEmpty()) out.add(p.trim());
		return String.join(", ", out);
	}

	private static String pad(String mm) {
		return mm.length() == 1 ? "0" + mm : mm;
	}

	// ── 만들기 ──

	/**
	 * @param info 개인이력카드 칸: 성명, 주민번호(가린 값), 소속회사, 부서, 직위, 병역, 기술등급, 주소, 언어, DBMS, TOOL
	 * @param schools {학교, 학과, 졸업년월}, careers {회사, 기간, 직위, 담당업무}, trainings {교육명, 시작, 종료, 기관}
	 */
	public static byte[] build(Map<String, String> info, List<String[]> schools, List<String[]> careers, List<String[]> trainings, List<Map<String, Object>> items) {
		return build(info, schools, careers, trainings, items, null);
	}

	/** info 에 이 키가 Y 면 면접 교육용 샘플: 두 쪽 제목 아래에 빨간 「실제 경력 아님」 줄 */
	public static final String SAMPLE = "_SAMPLE";

	private static String sampleNote() {
		return "<w:p><w:pPr><w:jc w:val=\"center\"/><w:spacing w:after=\"120\"/></w:pPr><w:r><w:rPr>" + font() + "<w:b/><w:color w:val=\"C00000\"/><w:sz w:val=\"20\"/></w:rPr>"
				+ "<w:t>※ 면접 교육용 샘플 이력입니다. 실제 경력이 아니며 제출용으로 쓸 수 없습니다.</w:t></w:r></w:p>";
	}

	/** @param photo {확장자 jpeg|png, 바이트} 이면 첫 표 오른쪽에 증명사진 칸(4줄 합침)을 둔다 */
	public static byte[] build(Map<String, String> info, List<String[]> schools, List<String[]> careers, List<String[]> trainings, List<Map<String, Object>> items, Object[] photo) {
		StringBuilder b = new StringBuilder();
		b.append("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><w:document xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\""
				+ " xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\"><w:body>");
		boolean sample = "Y".equals(info.get(SAMPLE));
		b.append(title(sample ? "개 인 이 력 카 드 (샘플)" : "개 인 이 력 카 드"));
		if (sample) b.append(sampleNote());
		String[][] top = { { h("성 명"), c(info.get("성명")), h("주민번호"), c(info.get("주민번호")) }, { h("소속회사"), c(info.get("소속회사")), h("직 위"), c(info.get("직위")) },
				{ h("부 서"), c(info.get("부서")), h("기술등급"), c(info.get("기술등급")) }, { h("병 역"), c(info.get("병역")), h("주 소"), c(info.get("주소")) } };
		if (photo == null) b.append(table(new int[] { 1400, 3400, 1400, 3400 }, row(top[0]), row(top[1]), row(top[2]), row(top[3])));
		else {
			String[] rs4 = new String[4];
			for (int i = 0; i < 4; i++) rs4[i] = row(top[i]) + "\u0002" + cell(false, 1, i == 0 ? 'R' : 'C', i == 0 ? PHOTO : "");
			b.append(table(new int[] { 1300, 2900, 1300, 2600, 1500 }, rs4));
		}
		b.append(gap());
		b.append(table(new int[] { 3400, 3000, 1600, 1600 }, rows(row(h("최 종 학 력"), h("학 과 명"), h("졸업년월"), h("소재지")), schools, 4, 2)));
		b.append(gap());
		b.append(table(new int[] { 1600, 8000 }, row(h("기 술 명"), h("가 용 기 술")), row(h("언 어"), c(info.get("언어"))), row(h("DBMS"), c(info.get("DBMS"))), row(h("TOOL"), c(info.get("TOOL")))));
		b.append(gap());
		b.append(table(new int[] { 2800, 2400, 1400, 3000 }, rows(row(h("근무회사명"), h("기 간"), h("직 위"), h("담당업무")), careers, 4, 3)));
		b.append(gap());
		b.append(table(new int[] { 3800, 1600, 1600, 2600 }, rows(row(h("교육명"), h("시작일"), h("종료일"), h("기관")), trainings, 4, 2)));
		// 여기까지 세로 쪽, 다음부터 가로 쪽
		b.append("<w:p><w:pPr><w:sectPr><w:pgSz w:w=\"11906\" w:h=\"16838\"/><w:pgMar w:top=\"1134\" w:right=\"1134\" w:bottom=\"1134\" w:left=\"1134\" w:header=\"720\" w:footer=\"720\" w:gutter=\"0\"/></w:sectPr></w:pPr></w:p>");
		b.append(title(sample ? "SKILL INVENTORY (샘플)" : "SKILL INVENTORY"));
		if (sample) b.append(sampleNote());
		int[] ws = { 2300, 1100, 1300, 1100, 700, 700, 900, 700, 700, 1300, 1000, 1200, 1300, 600 };
		List<String> rs = new ArrayList<>();
		rs.add(row(hv("프로젝트명 (업무명)", true), hv("참여기간", true), hv("고객사", true), hv("담당업무", true), hs("개발분야", 2), hv("역할", true), hs("개발환경", 7)));
		rs.add(row(hv("", false), hv("", false), hv("", false), hv("", false), h("산업"), h("응용"), hv("", false), h("기종"), h("O.S"), h("언어"), h("DBMS"), h("TOOL"), h("FRAME WORK"), h("기타")));
		for (int i = items.size() - 1; i >= 0; i--) { // 워드 양식은 오래된 것부터
			Map<String, Object> it = items.get(i);
			String end = s(it.get("END_YM"));
			rs.add(row(c(s(it.get("PRJ_NM"))), c(s(it.get("START_YM")).replace('-', '.') + "\n~\n" + (end.isEmpty() ? "현재" : end.replace('-', '.'))), c(s(it.get("CLIENT_NM"))), c(s(it.get("WORK_NM"))),
					c(lines(it.get("IND_NM"))), c(lines(it.get("APP_NM"))), c(lines(it.get("ROLE_NM"))), c(lines(it.get("MACHINE_NM"))), c(lines(it.get("OS_NM"))), c(lines(it.get("LANG_NM"))),
					c(lines(it.get("DBMS_NM"))), c(lines(it.get("TOOL_NM"))), c(lines(it.get("FRAMEWORK_NM"))), c(lines(it.get("ETC_NM")))));
		}
		b.append(table(ws, rs.toArray(new String[0])));
		b.append("<w:sectPr><w:pgSz w:w=\"16838\" w:h=\"11906\" w:orient=\"landscape\"/><w:pgMar w:top=\"1134\" w:right=\"850\" w:bottom=\"1134\" w:left=\"850\" w:header=\"720\" w:footer=\"720\" w:gutter=\"0\"/></w:sectPr>");
		b.append("</w:body></w:document>");
		String xml = b.toString();
		if (photo != null) xml = xml.replace(PHOTO_P, drawing((byte[]) photo[1]));
		return zip(xml, photo);
	}

	/** 사진 칸 표시. table() 이 글 대신 이 문단을 그대로 두면 build() 끝에서 그림으로 바꾼다 */
	private static final String PHOTO = "PHOTO"; // 사용자 글에 나올 수 없는 사설 영역 글자로 표시(esc 가 제어문자는 버린다)
	private static final String PHOTO_P = "<w:t xml:space=\"preserve\">" + PHOTO + "</w:t>";

	/** 너비 2.5cm, 높이는 사진 비율대로(못 읽으면 3:4) */
	private static String drawing(byte[] data) {
		long cx = 900000, cy = 1200000;
		try {
			java.awt.image.BufferedImage img = javax.imageio.ImageIO.read(new java.io.ByteArrayInputStream(data));
			if (img != null && img.getWidth() > 0) cy = cx * img.getHeight() / img.getWidth();
		} catch (IOException e) {
			// 비율만 못 구한 것이라 기본 3:4 로 둔다
		}
		String ext = "<wp:extent cx=\"" + cx + "\" cy=\"" + cy + "\"/>";
		return "</w:r><w:r><w:drawing><wp:inline distT=\"0\" distB=\"0\" distL=\"0\" distR=\"0\">" + ext + "<wp:docPr id=\"1\" name=\"증명사진\"/>"
				+ "<a:graphic xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\"><a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/picture\">"
				+ "<pic:pic xmlns:pic=\"http://schemas.openxmlformats.org/drawingml/2006/picture\"><pic:nvPicPr><pic:cNvPr id=\"1\" name=\"photo\"/><pic:cNvPicPr/></pic:nvPicPr>"
				+ "<pic:blipFill><a:blip r:embed=\"rIdPhoto\"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill><pic:spPr><a:xfrm><a:off x=\"0\" y=\"0\"/><a:ext cx=\"" + cx + "\" cy=\"" + cy + "\"/></a:xfrm>"
				+ "<a:prstGeom prst=\"rect\"><a:avLst/></a:prstGeom></pic:spPr></pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing>";
	}

	private static String[] rows(String head, List<String[]> data, int cols, int min) {
		List<String> out = new ArrayList<>();
		out.add(head);
		for (int i = 0; i < Math.max(min, data.size()); i++) {
			String[] cells = new String[cols];
			for (int k = 0; k < cols; k++) cells[k] = c(i < data.size() && k < data.get(i).length ? data.get(i)[k] : "");
			out.add(row(cells));
		}
		return out.toArray(new String[0]);
	}

	private static String lines(Object v) {
		return String.join("\n", StaffCareerService.tokens(s(v)));
	}

	private static String title(String t) {
		return "<w:p><w:pPr><w:jc w:val=\"center\"/><w:spacing w:after=\"160\"/></w:pPr><w:r><w:rPr>" + font() + "<w:b/><w:sz w:val=\"36\"/></w:rPr><w:t>" + esc(t) + "</w:t></w:r></w:p>";
	}

	private static String gap() {
		return "<w:p><w:pPr><w:spacing w:after=\"0\"/></w:pPr></w:p>";
	}

	private static String font() {
		return "<w:rFonts w:ascii=\"맑은 고딕\" w:eastAsia=\"맑은 고딕\" w:hAnsi=\"맑은 고딕\"/>";
	}

	/** 칸은 {머리글 여부, 가로 합침 수, 세로 합침(시작 R·이어짐 C·없음 N), 글} 을 \u0001 로 이어 둔 것. 너비는 표의 칸 너비를 차례로 쓴다 */
	private static String cell(boolean head, int span, char vmerge, String text) {
		return (head ? "H" : "D") + "\u0001" + span + "\u0001" + vmerge + "\u0001" + (text == null ? "" : text);
	}

	private static String h(String t) {
		return cell(true, 1, 'N', t);
	}

	private static String hs(String t, int span) {
		return cell(true, span, 'N', t);
	}

	private static String hv(String t, boolean start) {
		return cell(true, 1, start ? 'R' : 'C', t);
	}

	private static String c(String t) {
		return cell(false, 1, 'N', t);
	}

	private static String row(String... cells) {
		return String.join("\u0002", cells);
	}

	private static String table(int[] widths, String... rows) {
		StringBuilder b = new StringBuilder("<w:tbl><w:tblPr><w:tblW w:w=\"0\" w:type=\"auto\"/><w:jc w:val=\"center\"/><w:tblBorders>");
		for (String side : new String[] { "top", "left", "bottom", "right", "insideH", "insideV" }) b.append("<w:").append(side).append(" w:val=\"single\" w:sz=\"4\" w:space=\"0\" w:color=\"000000\"/>");
		b.append("</w:tblBorders><w:tblLayout w:type=\"fixed\"/></w:tblPr><w:tblGrid>");
		for (int w : widths) b.append("<w:gridCol w:w=\"").append(w).append("\"/>");
		b.append("</w:tblGrid>");
		for (String r : rows) {
			b.append("<w:tr><w:trPr><w:cantSplit/></w:trPr>");
			int col = 0;
			for (String cell : r.split("\u0002", -1)) {
				String[] p = cell.split("\u0001", -1);
				int span = Integer.parseInt(p[1]), w = 0;
				for (int i = 0; i < span && col + i < widths.length; i++) w += widths[col + i];
				col += span;
				b.append("<w:tc><w:tcPr><w:tcW w:w=\"").append(w).append("\" w:type=\"dxa\"/>");
				if (span > 1) b.append("<w:gridSpan w:val=\"").append(span).append("\"/>");
				if (p[2].charAt(0) == 'R') b.append("<w:vMerge w:val=\"restart\"/>");
				if (p[2].charAt(0) == 'C') b.append("<w:vMerge/>");
				if ("H".equals(p[0])) b.append("<w:shd w:val=\"clear\" w:color=\"auto\" w:fill=\"FFFF00\"/>");
				b.append("<w:vAlign w:val=\"center\"/></w:tcPr>");
				String[] ls = p[3].split("\n", -1);
				for (String line : ls) {
					b.append("<w:p><w:pPr><w:jc w:val=\"center\"/><w:spacing w:before=\"20\" w:after=\"20\"/></w:pPr><w:r><w:rPr>").append(font()).append("H".equals(p[0]) ? "<w:b/>" : "")
							.append("<w:sz w:val=\"16\"/></w:rPr><w:t xml:space=\"preserve\">").append(esc(line)).append("</w:t></w:r></w:p>");
				}
				b.append("</w:tc>");
			}
			b.append("</w:tr>");
		}
		return b.append("</w:tbl>").toString();
	}

	private static String esc(String s) {
		StringBuilder b = new StringBuilder();
		for (char ch : s.toCharArray()) {
			if (ch == '&') b.append("&amp;");
			else if (ch == '<') b.append("&lt;");
			else if (ch == '>') b.append("&gt;");
			else if (ch == '"') b.append("&quot;");
			else if (ch >= 0x20 || ch == '\t') b.append(ch); // XML 에 못 쓰는 제어문자는 버린다
		}
		return b.toString();
	}

	private static byte[] zip(String documentXml, Object[] photo) {
		try (ByteArrayOutputStream out = new ByteArrayOutputStream(); ZipOutputStream z = new ZipOutputStream(out)) {
			String ext = photo == null ? null : (String) photo[0];
			put(z, "[Content_Types].xml", "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">"
					+ "<Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/><Default Extension=\"xml\" ContentType=\"application/xml\"/>"
					+ (ext == null ? "" : "<Default Extension=\"" + ext + "\" ContentType=\"image/" + ext + "\"/>")
					+ "<Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/></Types>");
			put(z, "_rels/.rels", "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">"
					+ "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/></Relationships>");
			put(z, "word/document.xml", documentXml);
			if (ext != null) {
				put(z, "word/_rels/document.xml.rels", "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">"
						+ "<Relationship Id=\"rIdPhoto\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/image\" Target=\"media/photo." + ext + "\"/></Relationships>");
				z.putNextEntry(new ZipEntry("word/media/photo." + ext));
				z.write((byte[]) photo[1]);
				z.closeEntry();
			}
			z.finish();
			return out.toByteArray();
		} catch (IOException e) {
			throw new IllegalStateException(e);
		}
	}

	private static void put(ZipOutputStream z, String name, String body) throws IOException {
		z.putNextEntry(new ZipEntry(name));
		z.write(body.getBytes(StandardCharsets.UTF_8));
		z.closeEntry();
	}

	private static String s(Object o) {
		return o == null ? "" : o.toString();
	}
}
