package com.eep.bo.calendar.service;

import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URLEncoder;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

/**
 * 구글 캘린더 REST 호출 (OAuth 웹 로그인 + 읽기 전용).
 * 액세스 토큰은 세션에만 두고, 만료되면 다시 로그인한다(access_type=online).
 */
@Component
public class GoogleCalendarApi {

	public static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");

	private static final String AUTH_URL  = "https://accounts.google.com/o/oauth2/v2/auth";
	private static final String TOKEN_URL = "https://oauth2.googleapis.com/token";
	private static final String API_URL   = "https://www.googleapis.com/calendar/v3";
	private static final String SCOPE     = "https://www.googleapis.com/auth/calendar.readonly";
	private static final DateTimeFormatter DB_DT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
	// toString() 은 초가 0 이면 생략해서 구글이 거부한다
	private static final DateTimeFormatter RFC3339 = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ssXXX");

	private final RestTemplate rest = new RestTemplate();

	public String authUrl(String clientId, String redirectUri, String state) {
		return AUTH_URL + "?response_type=code&access_type=online&prompt=select_account"
				+ "&client_id=" + enc(clientId)
				+ "&redirect_uri=" + enc(redirectUri)
				+ "&scope=" + enc(SCOPE)
				+ "&state=" + enc(state);
	}

	@SuppressWarnings("unchecked")
	public String exchangeCode(String clientId, String clientSecret, String redirectUri, String code) {
		MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
		form.add("grant_type", "authorization_code");
		form.add("code", code);
		form.add("client_id", clientId);
		form.add("client_secret", clientSecret);
		form.add("redirect_uri", redirectUri);
		Map<String, Object> res = rest.postForObject(TOKEN_URL, form, Map.class);
		return (String) res.get("access_token");
	}

	/** 로그인한 계정이 볼 수 있는 캘린더 목록 (id, summary, primary) */
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> calendarList(String token) {
		List<Map<String, Object>> result = new ArrayList<>();
		for (Map<String, Object> item : (List<Map<String, Object>>) get(API_URL + "/users/me/calendarList?minAccessRole=reader", token).get("items")) {
			Map<String, Object> cal = new HashMap<>();
			cal.put("id", item.get("id"));
			cal.put("summary", item.get("summaryOverride") != null ? item.get("summaryOverride") : item.get("summary"));
			cal.put("primary", Boolean.TRUE.equals(item.get("primary")));
			result.add(cal);
		}
		return result;
	}

	/**
	 * from~to(종료일 포함) 사이에 시작하는 일정을 DB 저장 형태로 돌려준다.
	 * 반복 일정은 회차별로 펼친다(singleEvents=true).
	 */
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> events(String token, String calId, LocalDate from, LocalDate to) {
		String base = API_URL + "/calendars/" + enc(calId) + "/events?singleEvents=true&orderBy=startTime&maxResults=2500"
				+ "&timeMin=" + enc(from.atStartOfDay(SEOUL).format(RFC3339))
				+ "&timeMax=" + enc(to.plusDays(1).atStartOfDay(SEOUL).format(RFC3339));

		List<Map<String, Object>> result = new ArrayList<>();
		String pageToken = null;
		do {
			Map<String, Object> page = get(pageToken == null ? base : base + "&pageToken=" + enc(pageToken), token);
			List<Map<String, Object>> items = (List<Map<String, Object>>) page.get("items");
			if (items != null) {
				for (Map<String, Object> item : items) {
					if ("cancelled".equals(item.get("status"))) continue;
					result.add(toRow(calId, item));
				}
			}
			pageToken = (String) page.get("nextPageToken");
		} while (pageToken != null);
		return result;
	}

	@SuppressWarnings("unchecked")
	private static Map<String, Object> toRow(String calId, Map<String, Object> item) {
		Map<String, Object> start = (Map<String, Object>) item.get("start");
		Map<String, Object> end = (Map<String, Object>) item.get("end");
		boolean allDay = start.get("dateTime") == null;

		Map<String, Object> row = new HashMap<>();
		row.put("CAL_ID", calId);
		row.put("GCAL_EVT_ID", item.get("id"));
		row.put("EVT_TITLE", cut((String) item.get("summary"), 500));
		row.put("EVT_DESC", item.get("description"));
		row.put("EVT_LOC", cut((String) item.get("location"), 500));
		row.put("ALL_DAY_YN", allDay ? "Y" : "N");
		row.put("START_DT", toDbDt(start, false));
		row.put("END_DT", end == null ? null : toDbDt(end, true));
		return row;
	}

	/** 종일 일정의 구글 종료일은 다음날(미포함)이라 하루 빼서 그날 23:59:59 로 둔다 */
	private static String toDbDt(Map<String, Object> t, boolean isEnd) {
		if (t.get("dateTime") != null) {
			return OffsetDateTime.parse((String) t.get("dateTime")).atZoneSameInstant(SEOUL).toLocalDateTime().format(DB_DT);
		}
		LocalDate d = LocalDate.parse((String) t.get("date"));
		return isEnd ? d.minusDays(1).atTime(23, 59, 59).format(DB_DT) : d.atStartOfDay().format(DB_DT);
	}

	@SuppressWarnings("unchecked")
	private Map<String, Object> get(String url, String token) {
		HttpHeaders headers = new HttpHeaders();
		headers.set("Authorization", "Bearer " + token);
		// String 대신 URI 로 넘겨야 이미 인코딩한 쿼리를 RestTemplate 이 다시 인코딩하지 않는다
		return rest.exchange(URI.create(url), HttpMethod.GET, new HttpEntity<Void>(headers), Map.class).getBody();
	}

	private static String cut(String s, int max) {
		return s == null || s.length() <= max ? s : s.substring(0, max);
	}

	private static String enc(String s) {
		try {
			return URLEncoder.encode(s, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			throw new IllegalStateException(e);
		}
	}
}
