package com.common.upload;

import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.Locale;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;

import org.apache.pdfbox.cos.COSName;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDResources;
import org.apache.pdfbox.pdmodel.graphics.PDXObject;
import org.apache.pdfbox.pdmodel.graphics.form.PDFormXObject;
import org.apache.pdfbox.pdmodel.graphics.image.JPEGFactory;
import org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

/**
 * 모든 업로드의 공통 입구: 형식·용량 검사 후 PDF·이미지 용량을 줄인다.
 * - PDF: 글자·선은 그대로 두고 안의 큰 이미지만 긴 변 1654px(A4 150dpi)·JPEG 0.75 로 다시 넣는다
 * - 이미지: 긴 변 2000px·JPEG 0.8. 투명 PNG 는 PNG 그대로 크기만 줄인다. 휴대폰 사진의 회전(EXIF)은 반영한다
 * - 줄인 결과가 원본의 90% 이상이면 원본을 그대로 쓴다. 읽지 못하는 파일도 원본 그대로
 * 새 업로드 기능은 항상 Upload.of(...) 를 거친다. 저장 없이 읽기만 하는 업로드는 Upload.check(...)
 */
public final class Upload {

	public static final long MAX_BYTES = 50L * 1024 * 1024;
	public static final String[] DOCS = { "pdf", "jpg", "jpeg", "png" };
	public static final String[] EXCEL = { "xls", "xlsx" };
	private static final int PDF_IMAGE_MAX = 1654, PHOTO_MAX = 2000;

	public final String name, mime;
	public final byte[] data;
	public final long before;

	private Upload(String name, String mime, byte[] data, long before) {
		this.name = name;
		this.mime = mime;
		this.data = data;
		this.before = before;
	}

	/** 검사 + 용량 줄이기. exts 는 허용 확장자(소문자), 비우면 형식 제한 없음 */
	public static Upload of(MultipartFile f, String... exts) throws IOException {
		check(f, exts);
		return shrink(f.getOriginalFilename(), f.getContentType(), f.getBytes());
	}

	/** 검사만(읽기 전용 업로드) */
	public static void check(MultipartFile f, String... exts) {
		if (f == null || f.isEmpty()) throw new IllegalArgumentException("파일이 비어 있습니다.");
		if (f.getSize() > MAX_BYTES) throw new IllegalArgumentException("50MB 이하 파일만 올릴 수 있습니다.");
		if (exts.length > 0 && !Arrays.asList(exts).contains(ext(f.getOriginalFilename()))) throw new IllegalArgumentException(String.join(", ", exts).toUpperCase(Locale.ROOT) + " 파일만 올릴 수 있습니다.");
	}

	public static Upload shrink(String name, String mime, byte[] data) {
		String n = name == null || name.trim().isEmpty() ? "file" : name.replaceAll("[\\\\/:*?\"<>|\\r\\n]", "_");
		String ext = ext(n);
		try {
			if ("pdf".equals(ext)) {
				byte[] out = shrinkPdf(data);
				if (out != null && out.length < data.length * 0.9) return new Upload(n, "application/pdf", out, data.length);
			} else if ("jpg".equals(ext) || "jpeg".equals(ext) || "png".equals(ext)) {
				BufferedImage img = ImageIO.read(new ByteArrayInputStream(data));
				if (img != null) {
					boolean alpha = img.getColorModel().hasAlpha();
					if (!"png".equals(ext)) img = rotate(img, orientation(data));
					img = fit(img, PHOTO_MAX, alpha);
					byte[] out = alpha ? png(img) : jpeg(img, 0.8f);
					if (out.length < data.length * 0.9) {
						// 불투명 PNG 는 JPEG 로 바꿔 저장한다
						String nn = !alpha && "png".equals(ext) ? n.substring(0, n.length() - 4) + ".jpg" : n;
						return new Upload(nn, alpha ? "image/png" : "image/jpeg", out, data.length);
					}
				}
			}
		} catch (Exception | OutOfMemoryError e) {
			System.out.println("UPLOAD_SHRINK_SKIP " + n + " " + e);
		}
		return new Upload(n, mime == null || mime.isEmpty() ? "application/octet-stream" : mime, data, data.length);
	}

	/** 줄였으면 '이름 3.2MB → 0.6MB', 아니면 null */
	public String note() {
		return data.length < before ? name + " " + mb(before) + " → " + mb(data.length) : null;
	}

	/** 응답에 줄인 결과(uploaded)를 붙인다. 화면 공통 스크립트(include_bottom)가 알림으로 보여 준다 */
	public static ModelAndView noted(ModelAndView mv, Upload... ups) {
		StringBuilder s = new StringBuilder();
		for (Upload u : ups) if (u != null && u.note() != null) s.append(s.length() > 0 ? ", " : "").append(u.note());
		if (s.length() > 0 && !mv.getModel().containsKey("error")) mv.addObject("uploaded", "용량을 줄여 올렸습니다: " + s);
		return mv;
	}

	static String ext(String name) {
		int i = name == null ? -1 : name.lastIndexOf('.');
		return i < 0 ? "" : name.substring(i + 1).toLowerCase(Locale.ROOT);
	}

	private static String mb(long n) {
		return n >= 1024 * 1024 ? String.format("%.1fMB", n / 1048576.0) : Math.max(1, n / 1024) + "KB";
	}

	// ── PDF ──

	private static byte[] shrinkPdf(byte[] data) throws IOException {
		try (PDDocument doc = PDDocument.load(data)) {
			if (doc.isEncrypted()) return null;
			int[] changed = { 0 };
			for (PDPage page : doc.getPages()) shrinkImages(doc, page.getResources(), changed, 0);
			if (changed[0] == 0) return null;
			ByteArrayOutputStream out = new ByteArrayOutputStream();
			doc.save(out);
			return out.toByteArray();
		}
	}

	private static void shrinkImages(PDDocument doc, PDResources res, int[] changed, int depth) throws IOException {
		if (res == null || depth > 3) return;
		for (COSName key : res.getXObjectNames()) {
			PDXObject x = res.getXObject(key);
			if (x instanceof PDFormXObject) {
				shrinkImages(doc, ((PDFormXObject) x).getResources(), changed, depth + 1);
			} else if (x instanceof PDImageXObject) {
				PDImageXObject im = (PDImageXObject) x;
				// 마스크·투명이 있거나 작은 이미지는 그대로(JPEG 로 바꾸면 깨진다)
				if (im.isStencil() || im.getSoftMask() != null || im.getCOSObject().getItem(COSName.MASK) != null) continue;
				if (Math.max(im.getWidth(), im.getHeight()) <= PDF_IMAGE_MAX && im.getCOSObject().getLength() < 300 * 1024) continue;
				BufferedImage img = fit(im.getImage(), PDF_IMAGE_MAX, false);
				PDImageXObject jpg = JPEGFactory.createFromImage(doc, img, 0.75f);
				if (jpg.getCOSObject().getLength() < im.getCOSObject().getLength()) {
					res.put(key, jpg);
					changed[0]++;
				}
			}
		}
	}

	// ── 이미지 ──

	static BufferedImage fit(BufferedImage img, int max, boolean alpha) {
		int w = img.getWidth(), h = img.getHeight();
		double s = Math.min(1.0, (double) max / Math.max(w, h));
		int nw = Math.max(1, (int) Math.round(w * s)), nh = Math.max(1, (int) Math.round(h * s));
		int type = alpha ? BufferedImage.TYPE_INT_ARGB : BufferedImage.TYPE_INT_RGB;
		if (s == 1.0 && img.getType() == type) return img;
		BufferedImage out = new BufferedImage(nw, nh, type);
		Graphics2D g = out.createGraphics();
		g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
		g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
		if (!alpha) {
			g.setColor(java.awt.Color.WHITE);
			g.fillRect(0, 0, nw, nh);
		}
		g.drawImage(img, 0, 0, nw, nh, null);
		g.dispose();
		return out;
	}

	private static byte[] jpeg(BufferedImage img, float quality) throws IOException {
		ImageWriter w = ImageIO.getImageWritersByFormatName("jpeg").next();
		ImageWriteParam p = w.getDefaultWriteParam();
		p.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
		p.setCompressionQuality(quality);
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		try (ImageOutputStream ios = ImageIO.createImageOutputStream(out)) {
			w.setOutput(ios);
			w.write(null, new IIOImage(img, null, null), p);
		} finally {
			w.dispose();
		}
		return out.toByteArray();
	}

	private static byte[] png(BufferedImage img) throws IOException {
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		ImageIO.write(img, "png", out);
		return out.toByteArray();
	}

	/** JPEG EXIF 의 회전값(1~8). 없으면 1 */
	static int orientation(byte[] d) {
		for (int i = 2; i + 4 < d.length && (d[i] & 0xFF) == 0xFF; ) {
			int marker = d[i + 1] & 0xFF, len = ((d[i + 2] & 0xFF) << 8) | (d[i + 3] & 0xFF);
			if (marker == 0xE1 && i + 10 < d.length && d[i + 4] == 'E' && d[i + 5] == 'x' && d[i + 6] == 'i' && d[i + 7] == 'f') {
				int t = i + 10;
				boolean le = d[t] == 'I';
				int ifd = t + u32(d, t + 4, le), n = u16(d, ifd, le);
				for (int k = 0; k < n; k++) {
					int e = ifd + 2 + k * 12;
					if (e + 10 > d.length) break;
					if (u16(d, e, le) == 0x0112) return u16(d, e + 8, le);
				}
				return 1;
			}
			if (marker == 0xDA) break;
			i += 2 + len;
		}
		return 1;
	}

	private static int u16(byte[] d, int i, boolean le) {
		return le ? (d[i] & 0xFF) | (d[i + 1] & 0xFF) << 8 : (d[i] & 0xFF) << 8 | (d[i + 1] & 0xFF);
	}

	private static int u32(byte[] d, int i, boolean le) {
		return le ? u16(d, i, true) | u16(d, i + 2, true) << 16 : u16(d, i, false) << 16 | u16(d, i + 2, false);
	}

	static BufferedImage rotate(BufferedImage img, int o) {
		if (o < 2 || o > 8) return img;
		int w = img.getWidth(), h = img.getHeight();
		boolean swap = o >= 5;
		AffineTransform t = new AffineTransform();
		switch (o) {
			case 2: t.translate(w, 0); t.scale(-1, 1); break;
			case 3: t.translate(w, h); t.rotate(Math.PI); break;
			case 4: t.translate(0, h); t.scale(1, -1); break;
			case 5: t.rotate(Math.PI / 2); t.scale(1, -1); break;
			case 6: t.translate(h, 0); t.rotate(Math.PI / 2); break;
			case 7: t.scale(-1, 1); t.translate(-h, 0); t.translate(0, w); t.rotate(3 * Math.PI / 2); break;
			default: t.translate(0, w); t.rotate(3 * Math.PI / 2); break;
		}
		BufferedImage out = new BufferedImage(swap ? h : w, swap ? w : h, BufferedImage.TYPE_INT_RGB);
		Graphics2D g = out.createGraphics();
		g.drawImage(img, t, null);
		g.dispose();
		return out;
	}
}
