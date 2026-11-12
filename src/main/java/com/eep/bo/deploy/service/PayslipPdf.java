package com.eep.bo.deploy.service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.encryption.AccessPermission;
import org.apache.pdfbox.pdmodel.encryption.StandardProtectionPolicy;
import org.apache.pdfbox.pdmodel.font.PDFont;
import org.apache.pdfbox.pdmodel.font.PDType0Font;
import org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject;

/**
 * 급여명세서 PDF 한 장. 양식은 기존 '이에스티_급여명세서' PDF 를 따른다. DB 를 쓰지 않는다.
 * slip: TITLE, NAME, BIRTH, POSITION, JOIN_DT, PAY_DT, DEPT, PAY·DED([[이름, 금액]]), PAY_TOTAL, DED_TOTAL, NET
 */
public final class PayslipPdf {

	private static final String[] ADDRESS = { "3rd floor, Songam Building, 4", "Dangsan-ro 28-gil,", "Yeongdeungpo-gu, Seoul", "Republic of Korea", "Tel: +82 70 7794 1123", "Fax: +82 2 2069 1123" };
	private static final float LEFT = 56, RIGHT = PDRectangle.A4.getWidth() - 56, WIDTH = RIGHT - LEFT, ROW = 22;

	private PayslipPdf() {
	}

	/** password 가 있으면 PDF 를 열 때 그 암호를 묻는다(AES-128). logo 는 없어도 된다 */
	@SuppressWarnings("unchecked")
	public static byte[] build(Map<String, Object> slip, byte[] logo, String password) throws IOException {
		try (PDDocument doc = new PDDocument(); InputStream r = font("NanumGothic-Regular.ttf"); InputStream b = font("NanumGothic-Bold.ttf")) {
			PDFont regular = PDType0Font.load(doc, r), bold = PDType0Font.load(doc, b);
			PDPage page = new PDPage(PDRectangle.A4);
			doc.addPage(page);
			try (PDPageContentStream c = new PDPageContentStream(doc, page)) {
				float y = PDRectangle.A4.getHeight() - 50;
				if (logo != null) {
					c.drawImage(PDImageXObject.createFromByteArray(doc, logo, "logo"), LEFT, y - 62, 68, 68);
				}
				for (int i = 0; i < ADDRESS.length; i++) {
					right(c, regular, 8, ADDRESS[i], RIGHT, y - 4 - i * 11);
				}
				y -= 110;
				center(c, bold, 20, str(slip.get("TITLE")), y);
				y -= 40;

				text(c, bold, 10.5f, "[ 인적사항 ]", LEFT, y);
				y -= 8;
				String[][] info = { { "성명", str(slip.get("NAME")), "생년월일", str(slip.get("BIRTH")) }, { "직급", str(slip.get("POSITION")), "입사일", str(slip.get("JOIN_DT")) },
						{ "지급일자", str(slip.get("PAY_DT")), "부서", str(slip.get("DEPT")) } };
				float[] ix = { LEFT, LEFT + 80, LEFT + WIDTH / 2, LEFT + WIDTH / 2 + 80, RIGHT };
				for (String[] row : info) {
					for (int i = 0; i < 4; i++) {
						cell(c, ix[i], y - ROW, ix[i + 1] - ix[i], i % 2 == 0);
						text(c, i % 2 == 0 ? bold : regular, 10, row[i], ix[i] + 8, y - 15);
					}
					y -= ROW;
				}
				y -= 22;

				List<Object[]> pay = (List<Object[]>) slip.get("PAY"), ded = (List<Object[]>) slip.get("DED");
				float mid = LEFT + WIDTH / 2;
				float[] tx = { LEFT, LEFT + 110, mid, mid + 110, RIGHT };
				text(c, bold, 10.5f, "[ 지급 내역 ]", LEFT, y);
				text(c, bold, 10.5f, "[ 공제 내역 ]", mid, y);
				y -= 8;
				String[] head = { "항목", "금액", "항목", "금액" };
				for (int i = 0; i < 4; i++) {
					cell(c, tx[i], y - ROW, tx[i + 1] - tx[i], true);
					text(c, bold, 10, head[i], tx[i] + 8, y - 15);
				}
				y -= ROW;
				int rows = Math.max(Math.max(pay.size(), ded.size()), 1);
				for (int n = 0; n < rows; n++) {
					for (int side = 0; side < 2; side++) {
						Object[] item = n < (side == 0 ? pay : ded).size() ? (side == 0 ? pay : ded).get(n) : null;
						cell(c, tx[side * 2], y - ROW, tx[side * 2 + 1] - tx[side * 2], false);
						cell(c, tx[side * 2 + 1], y - ROW, tx[side * 2 + 2] - tx[side * 2 + 1], false);
						if (item != null) {
							text(c, regular, 10, str(item[0]), tx[side * 2] + 8, y - 15);
							right(c, regular, 10, won(item[1]), tx[side * 2 + 2] - 8, y - 15);
						}
					}
					y -= ROW;
				}
				String[] total = { "지급총액", won(slip.get("PAY_TOTAL")), "공제총액", won(slip.get("DED_TOTAL")) };
				for (int i = 0; i < 4; i++) {
					cell(c, tx[i], y - ROW, tx[i + 1] - tx[i], true);
					if (i % 2 == 0) {
						text(c, bold, 10, total[i], tx[i] + 8, y - 15);
					} else {
						right(c, bold, 10, total[i], tx[i + 1] - 8, y - 15);
					}
				}
				y -= ROW + 14;

				c.setLineWidth(1.4f);
				c.addRect(LEFT, y - 28, WIDTH, 28);
				c.stroke();
				text(c, bold, 12, "실지급액", LEFT + 10, y - 19);
				right(c, bold, 13, won(slip.get("NET")), RIGHT - 10, y - 19);
				y -= 70;

				center(c, regular, 11, str(slip.get("NAME")) + " 님 수고하셨습니다.", y);
				y -= 46;
				right(c, bold, 12, "주식회사 이에스티소프트          (인)", RIGHT, y);
			}
			if (password != null && !password.isEmpty()) {
				// 소유자 암호는 아무도 모르게 두고, 여는 암호만 생년월일로 건다. 인쇄·복사는 막지 않는다
				StandardProtectionPolicy policy = new StandardProtectionPolicy(UUID.randomUUID().toString(), password, new AccessPermission());
				policy.setEncryptionKeyLength(128);
				policy.setPreferAES(true);
				doc.protect(policy);
			}
			ByteArrayOutputStream out = new ByteArrayOutputStream();
			doc.save(out);
			return out.toByteArray();
		}
	}

	private static InputStream font(String name) {
		InputStream in = PayslipPdf.class.getClassLoader().getResourceAsStream("fonts/" + name);
		if (in == null) {
			throw new IllegalStateException("글꼴 파일이 없습니다: fonts/" + name);
		}
		return in;
	}

	private static void cell(PDPageContentStream c, float x, float y, float w, boolean shaded) throws IOException {
		if (shaded) {
			c.setNonStrokingColor(0.95f, 0.96f, 0.97f);
			c.addRect(x, y, w, ROW);
			c.fill();
			c.setNonStrokingColor(0f, 0f, 0f);
		}
		c.setLineWidth(0.6f);
		c.setStrokingColor(0.6f, 0.65f, 0.7f);
		c.addRect(x, y, w, ROW);
		c.stroke();
		c.setStrokingColor(0f, 0f, 0f);
	}

	private static void text(PDPageContentStream c, PDFont f, float size, String s, float x, float y) throws IOException {
		c.beginText();
		c.setFont(f, size);
		c.newLineAtOffset(x, y);
		c.showText(safe(f, s));
		c.endText();
	}

	private static void right(PDPageContentStream c, PDFont f, float size, String s, float x, float y) throws IOException {
		text(c, f, size, s, x - f.getStringWidth(safe(f, s)) / 1000 * size, y);
	}

	private static void center(PDPageContentStream c, PDFont f, float size, String s, float y) throws IOException {
		text(c, f, size, s, (PDRectangle.A4.getWidth() - f.getStringWidth(safe(f, s)) / 1000 * size) / 2, y);
	}

	/** 글꼴에 없는 글자(이모지·드문 한자)는 PDF 생성을 실패시키므로 ? 로 바꾼다 */
	private static String safe(PDFont f, String s) {
		StringBuilder out = new StringBuilder();
		for (int i = 0; i < s.length(); ) {
			int cp = s.codePointAt(i);
			String ch = new String(Character.toChars(cp));
			try {
				f.encode(ch);
				out.append(ch);
			} catch (IOException | IllegalArgumentException e) {
				out.append('?');
			}
			i += Character.charCount(cp);
		}
		return out.toString();
	}

	private static String won(Object v) {
		return String.format("%,d 원", BoPayrollService.n(v));
	}

	private static String str(Object v) {
		return Objects.toString(v, "").replaceAll("[\\r\\n\\t]", " ");
	}
}
