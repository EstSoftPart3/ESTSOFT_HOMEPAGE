package com.eep.bo.deploy.service;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 사업자등록증 글자에서 거래처 칸 값을 찾는다. DB·네트워크를 쓰지 않는다.
 * shortcut: 규칙 기반이라 양식이 크게 다르면 못 읽는다. 못 읽은 칸은 비워 두고 사람이 채운다.
 */
public final class BizLicenseParser {

	private static final Pattern BIZ_NO = Pattern.compile("(?<!\\d)(\\d{3})\\s*-\\s*(\\d{2})\\s*-\\s*(\\d{5})(?!\\d)");
	private static final Pattern OPEN = Pattern.compile("개\\s*업\\s*연\\s*월\\s*일\\s*[:：]?\\s*(\\d{4})\\s*[년.-]\\s*(\\d{1,2})\\s*[월.-]\\s*(\\d{1,2})");
	private static final String[][] LABELS = {
			{ "PARTNER_NM", "(?:상\\s*호|법\\s*인\\s*명(?:\\s*\\(\\s*단\\s*체\\s*명\\s*\\))?|단\\s*체\\s*명)" },
			{ "CEO_NM", "(?:대\\s*표\\s*자|성\\s*명)" },
			{ "ADDR", "사\\s*업\\s*장\\s*소\\s*재\\s*지" },
			{ "BIZ_TYPE", "업\\s*태" },
			{ "BIZ_ITEM", "종\\s*목" } };
	// 한 줄에 다음 항목이 이어 나올 때 그 앞에서 끊는다
	private static final Pattern NEXT = Pattern.compile("\\s+(?:대\\s*표\\s*자|성\\s*명|개\\s*업\\s*연\\s*월\\s*일|법\\s*인\\s*등\\s*록\\s*번\\s*호|생\\s*년\\s*월\\s*일|사\\s*업\\s*장|본\\s*점|종\\s*목|업\\s*태)\\s*[:：]");

	/** 파일 이름 키워드 -> 서류 종류. 앞에 있는 것부터 본다 */
	private static final String[][] KIND_NAMES = { { "(?i)사업자|등록증|license", "LICENSE" }, { "(?i)통장|계좌|bank", "BANK" },
			{ "(?i)직인|도장|인감|seal|stamp", "SEAL" }, { "(?i)로고|logo|(?<![a-z])ci(?![a-z])", "LOGO" } };
	private static final Pattern HOLDER = Pattern.compile("예\\s*금\\s*주(?:\\s*명)?\\s*[:：]?\\s*([^\\n]+)");

	private BizLicenseParser() {
	}

	/** 파일 이름으로 서류 종류(LICENSE·BANK·SEAL·LOGO)를 맞힌다. 모르면 null */
	public static String kindByName(String fileName) {
		String n = fileName == null ? "" : fileName;
		for (String[] k : KIND_NAMES) {
			if (Pattern.compile(k[0]).matcher(n).find()) {
				return k[1];
			}
		}
		return null;
	}

	/** 글자로 서류 종류를 맞힌다. 사업자등록번호가 있으면 사업자등록증, 은행과 계좌번호가 있으면 통장사본, 아니면 null */
	public static String kindByText(String text) {
		String t = text == null ? "" : text;
		if (t.replaceAll("\\s", "").contains("사업자") && parse(t).containsKey("BIZ_NO")) {
			return "LICENSE";
		}
		return bank(t).size() >= 2 ? "BANK" : null;
	}

	/** 통장사본 글자에서 BANK_NM, ACCOUNT_NO, ACCOUNT_HOLDER */
	public static Map<String, String> bank(String text) {
		Map<String, String> out = new LinkedHashMap<>();
		Map<String, String> b = com.eep.bo.staff.service.StaffDocParser.parse("DOC_BANK", text);
		if (b.containsKey("BANK_NM")) {
			out.put("BANK_NM", b.get("BANK_NM"));
		}
		if (b.containsKey("ACCOUNT")) {
			out.put("ACCOUNT_NO", b.get("ACCOUNT"));
		}
		Matcher h = HOLDER.matcher(text == null ? "" : text.replace('\r', '\n'));
		if (h.find()) {
			String v = h.group(1).split("\\s{2,}|계\\s*좌|은\\s*행")[0].trim();
			if (!v.isEmpty()) {
				out.put("ACCOUNT_HOLDER", v);
			}
		}
		return out;
	}

	/** 찾은 칸만 담아 돌려준다 */
	public static Map<String, String> parse(String text) {
		Map<String, String> out = new LinkedHashMap<>();
		String t = text == null ? "" : text;
		Matcher no = BIZ_NO.matcher(t);
		if (no.find()) {
			out.put("BIZ_NO", no.group(1) + "-" + no.group(2) + "-" + no.group(3));
		}
		Matcher open = OPEN.matcher(t);
		if (open.find()) {
			out.put("OPEN_DT", String.format("%s-%02d-%02d", open.group(1), Integer.parseInt(open.group(2)), Integer.parseInt(open.group(3))));
		}
		for (String[] f : LABELS) {
			Matcher m = Pattern.compile("(?m)(?:^|\\s)" + f[1] + "\\s*[:：]\\s*([^\\r\\n]+)").matcher(t);
			if (m.find()) {
				String v = NEXT.split(m.group(1), 2)[0].trim();
				if (!v.isEmpty()) {
					out.put(f[0], v);
				}
			}
		}
		return out;
	}
}
