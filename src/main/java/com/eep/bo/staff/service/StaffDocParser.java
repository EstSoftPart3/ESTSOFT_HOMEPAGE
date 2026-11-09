package com.eep.bo.staff.service;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 서류 파일 이름으로 서류 종류를 맞히고, OCR 글자에서 인사카드 칸 값을 찾는다. DB·네트워크를 쓰지 않는다.
 * shortcut: 규칙 기반이라 양식이 크게 다른 서류는 못 읽을 수 있다. 못 읽으면 빈 결과이고 사람이 채운다.
 */
public final class StaffDocParser {

	/** 파일 이름 키워드 -> 서류 칸. 앞에 있는 것부터 본다(주민등록등본을 신분증보다 먼저) */
	private static final String[][] NAME_RULES = {
			{ "주민등록등본|등본", "DOC_REG" }, { "신분증|주민등록증|운전면허", "DOC_ID" }, { "졸업증명|졸업장", "DOC_GRAD" },
			{ "통장|계좌", "DOC_BANK" }, { "증명사진|사진", "DOC_PHOTO" }, { "건강보험|득실", "DOC_HI" }, { "근로계약", "DOC_CONTRACT" },
			{ "사업자", "DOC_BIZ" }, { "고용보험", "DOC_EI" }, { "보안서약", "DOC_SEC" }, { "직무교육", "DOC_EDU" }, { "국민취업", "DOC_NEP" },
			{ "이력비공개|비공개", "DOC_PRIV" }, { "범죄", "DOC_CRIME" }, { "병적|병역", "DOC_MIL" } };

	/** 은행 표기 -> 엑셀에서 쓰는 짧은 이름 */
	private static final String[][] BANKS = {
			{ "카카오\\s*뱅크", "카카오" }, { "토스\\s*뱅크", "토스" }, { "케이\\s*뱅크|K\\s*뱅크", "케이" }, { "IBK|기업\\s*은행", "기업" },
			{ "KB|국민\\s*은행", "국민" }, { "신한\\s*은행|SHINHAN", "신한" }, { "우리\\s*은행|WOORI", "우리" }, { "하나\\s*은행|KEB", "하나" },
			{ "NH|농협", "농협" }, { "새마을\\s*금고", "새마을" }, { "우체국", "우체국" }, { "수협", "수협" }, { "SC\\s*제일|제일\\s*은행", "SC제일" },
			{ "씨티\\s*은행", "씨티" }, { "신협", "신협" }, { "부산\\s*은행", "부산" }, { "대구\\s*은행|iM\\s*뱅크", "대구" }, { "경남\\s*은행", "경남" },
			{ "광주\\s*은행", "광주" }, { "전북\\s*은행", "전북" }, { "제주\\s*은행", "제주" }, { "산업\\s*은행|KDB", "산업" } };

	private static final Pattern RRN = Pattern.compile("(?<!\\d)(\\d{2})(\\d{2})(\\d{2})\\s*-\\s*([1-8]\\d{6})(?!\\d)");
	private static final Pattern ACCOUNT = Pattern.compile("(?<![\\d-])(\\d{2,6}(?:[- ]\\d{2,8}){1,4}|\\d{10,14})(?![\\d-])");
	private static final Pattern PHONE = Pattern.compile("^01[016789]");
	private static final Pattern DATE = Pattern.compile("((?:19|20)\\d{2})\\s*[.년/-]\\s*(\\d{1,2})\\s*(?:[.월/-]\\s*(\\d{1,2})\\s*일?)?");
	private static final Pattern SIDO = Pattern.compile("(서울|부산|대구|인천|광주|대전|울산|세종|경기|강원|충청북|충북|충청남|충남|전라북|전북|전북특별자치|전라남|전남|경상북|경북|경상남|경남|제주)"
			+ "[가-힣]*\\s+[가-힣0-9]+(?:시|군|구)(?![가-힣])[^\\n]*");
	private static final Pattern SCHOOL = Pattern.compile("([가-힣A-Za-z]+(?:대학교|대학원|대학))(?![가-힣])");
	private static final Pattern MAJOR = Pattern.compile("([가-힣A-Za-z]+(?:학과|학부))|전공\\s*[:：]?\\s*([가-힣A-Za-z]+)");

	private StaffDocParser() {
	}

	/** 파일 이름으로 서류 칸을 맞힌다. 모르면 null */
	public static String guessDoc(String fileName) {
		String n = fileName == null ? "" : fileName;
		for (String[] r : NAME_RULES) {
			if (Pattern.compile(r[0]).matcher(n).find()) {
				return r[1];
			}
		}
		return null;
	}

	/** 서류 칸과 OCR 글자로 채울 수 있는 인사카드 칸 값. 화면 칸 이름(RRN, ACCOUNT 는 원문) -> 값 */
	public static Map<String, String> parse(String doc, String text) {
		Map<String, String> out = new LinkedHashMap<>();
		if (text == null || doc == null) {
			return out;
		}
		String t = text.replace('\r', '\n');
		switch (doc) {
		case "DOC_BANK":
			put(out, "BANK_NM", bank(t));
			put(out, "ACCOUNT", account(t));
			break;
		case "DOC_ID":
		case "DOC_REG":
			put(out, "RRN", rrn(t));
			put(out, "ADDR", address(t));
			break;
		case "DOC_GRAD":
			put(out, "UNIV_NM", first(SCHOOL, t, 1));
			put(out, "UNIV_MAJOR", major(t));
			put(out, "UNIV_GRAD", dateNear(t, "졸업", false));
			break;
		case "DOC_MIL":
			put(out, "MIL_IN_DT", dateNear(t, "입영|입대", true));
			put(out, "MIL_OUT_DT", dateNear(t, "전역|소집해제", true));
			if (out.isEmpty() && t.contains("면제")) {
				Matcher m = Pattern.compile("면제\\s*사유\\s*[:：]?\\s*([^\\n]+)").matcher(t);
				put(out, "MIL_EXEMPT", m.find() ? m.group(1).trim() : "면제");
			}
			break;
		default:
		}
		return out;
	}

	static String bank(String t) {
		int best = Integer.MAX_VALUE;
		String name = null;
		for (String[] b : BANKS) {
			Matcher m = Pattern.compile(b[0]).matcher(t);
			if (m.find() && m.start() < best) {
				best = m.start();
				name = b[1];
			}
		}
		return name;
	}

	/** '계좌' 글자가 있는 줄(또는 다음 줄)의 번호를 먼저, 없으면 자릿수가 가장 긴 번호. 전화번호·주민번호·날짜는 뺀다 */
	static String account(String t) {
		String[] lines = t.split("\n");
		String near = null, longest = null;
		for (int i = 0; i < lines.length; i++) {
			Matcher m = ACCOUNT.matcher(lines[i]);
			while (m.find()) {
				String c = m.group(1).trim().replace(' ', '-');
				String digits = c.replace("-", "");
				if (digits.length() < 10 || digits.length() > 16 || PHONE.matcher(digits).find() || RRN.matcher(c).matches()
						|| c.matches("(19|20)\\d{2}-\\d{1,2}-\\d{1,2}")) {
					continue;
				}
				boolean labeled = lines[i].contains("계좌") || (i > 0 && lines[i - 1].contains("계좌"));
				if (labeled && near == null) {
					near = c;
				}
				if (longest == null || digits.length() > longest.replace("-", "").length()) {
					longest = c;
				}
			}
		}
		return near != null ? near : longest;
	}

	static String rrn(String t) {
		Matcher m = RRN.matcher(t);
		while (m.find()) {
			int month = Integer.parseInt(m.group(2)), day = Integer.parseInt(m.group(3));
			if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
				return m.group(1) + m.group(2) + m.group(3) + "-" + m.group(4);
			}
		}
		return null;
	}

	/** '주소' 글자 뒤의 첫 시·도 주소, 없으면 글 전체의 첫 시·도 주소 한 줄 */
	static String address(String t) {
		int at = t.indexOf("주소");
		Matcher m = SIDO.matcher(t);
		if (at >= 0 && m.find(at)) {
			return cut(m.group().trim(), 100);
		}
		m = SIDO.matcher(t);
		return m.find() ? cut(m.group().trim(), 100) : null;
	}

	static String major(String t) {
		Matcher m = MAJOR.matcher(t);
		while (m.find()) {
			String v = m.group(1) != null ? m.group(1) : m.group(2);
			if (v != null && v.length() > 2) {
				return v;
			}
		}
		return null;
	}

	/** 키워드가 든 줄(없으면 다음 줄)의 날짜. full 이면 yyyy-MM-dd, 아니면 yyyy.MM */
	static String dateNear(String t, String keyword, boolean full) {
		String[] lines = t.split("\n");
		Pattern key = Pattern.compile(keyword);
		for (int i = 0; i < lines.length; i++) {
			Matcher k = key.matcher(lines[i]);
			if (!k.find()) {
				continue;
			}
			for (String line : new String[] { lines[i].substring(k.start()), i + 1 < lines.length ? lines[i + 1] : "" }) {
				Matcher d = DATE.matcher(line);
				if (d.find()) {
					String y = d.group(1), mo = pad(d.group(2));
					if (full) {
						return d.group(3) == null ? null : y + "-" + mo + "-" + pad(d.group(3));
					}
					return y + "." + mo;
				}
			}
		}
		return null;
	}

	private static String first(Pattern p, String t, int group) {
		Matcher m = p.matcher(t);
		return m.find() ? m.group(group) : null;
	}

	private static String pad(String s) {
		return s.length() == 1 ? "0" + s : s;
	}

	private static String cut(String s, int n) {
		return s.length() > n ? s.substring(0, n) : s;
	}

	private static void put(Map<String, String> out, String key, String val) {
		if (val != null && !val.trim().isEmpty()) {
			out.put(key, val.trim());
		}
	}
}
