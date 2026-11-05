package com.eep.bo.batch.service;

import java.io.ByteArrayOutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URLEncoder;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

/** 이력서 폴더를 읽는 구글 드라이브 REST 호출. 사람이 한 번 승인해 받은 refresh token 으로 무인 실행한다 */
@Component
public class GoogleDriveApi {

	private static final String AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth";
	private static final String TOKEN_URL = "https://oauth2.googleapis.com/token";
	private static final String API_URL = "https://www.googleapis.com/drive/v3";
	private static final String SCOPE = "https://www.googleapis.com/auth/drive.readonly";
	private static final String FOLDER = "application/vnd.google-apps.folder";
	private static final String SHORTCUT = "application/vnd.google-apps.shortcut";
	private static final long MAX_PDF_BYTES = 30L * 1024 * 1024;

	private final RestTemplate rest;

	public GoogleDriveApi() {
		SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
		factory.setConnectTimeout(10000);
		factory.setReadTimeout(60000);
		rest = new RestTemplate(factory);
	}

	/** prompt=consent 가 있어야 다시 연결할 때도 refresh token 을 준다 */
	public String authUrl(String clientId, String redirectUri, String state) {
		return AUTH_URL + "?response_type=code&access_type=offline&prompt=consent"
				+ "&client_id=" + enc(clientId)
				+ "&redirect_uri=" + enc(redirectUri)
				+ "&scope=" + enc(SCOPE)
				+ "&state=" + enc(state);
	}

	/** @return access_token, refresh_token 이 든 응답 */
	@SuppressWarnings("unchecked")
	public Map<String, Object> exchangeCode(String clientId, String clientSecret, String redirectUri, String code) {
		MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
		form.add("grant_type", "authorization_code");
		form.add("code", code);
		form.add("client_id", clientId);
		form.add("client_secret", clientSecret);
		form.add("redirect_uri", redirectUri);
		return rest.postForObject(TOKEN_URL, form, Map.class);
	}

	@SuppressWarnings("unchecked")
	public String accessToken(String clientId, String clientSecret, String refreshToken) {
		MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
		form.add("grant_type", "refresh_token");
		form.add("refresh_token", refreshToken);
		form.add("client_id", clientId);
		form.add("client_secret", clientSecret);
		return (String) rest.postForObject(TOKEN_URL, form, Map.class).get("access_token");
	}

	/** 승인한 계정 이메일. 화면에 어느 계정으로 연결됐는지 보여 준다 */
	@SuppressWarnings("unchecked")
	public String accountEmail(String token) {
		Map<String, Object> about = get(API_URL + "/about?fields=user(emailAddress)", token);
		return (String) ((Map<String, Object>) about.get("user")).get("emailAddress");
	}

	/** 부모 폴더 안에서 이름이 같은 폴더(바로가기 포함)의 ID. 없으면 null */
	@SuppressWarnings("unchecked")
	public String childFolderId(String parentId, String name, String token) {
		for (Map<String, Object> file : list("'" + quote(parentId) + "' in parents and name = '" + quote(name) + "' and trashed = false", token)) {
			if (FOLDER.equals(file.get("mimeType"))) {
				return (String) file.get("id");
			}
			if (SHORTCUT.equals(file.get("mimeType"))) {
				Map<String, Object> target = (Map<String, Object>) file.get("shortcutDetails");
				if (target != null && FOLDER.equals(target.get("targetMimeType"))) {
					return (String) target.get("targetId");
				}
			}
		}
		return null;
	}

	/** 폴더 안의 PDF 중 이름에 '이력서' 가 든 것을 우선해 하나 고른다. 없으면 null. {id, name, size} */
	public Map<String, Object> resumePdf(String folderId, String token) {
		Map<String, Object> first = null;
		for (Map<String, Object> file : list("'" + quote(folderId) + "' in parents and mimeType = 'application/pdf' and trashed = false", token)) {
			if (String.valueOf(file.get("name")).contains("이력서")) {
				return file;
			}
			if (first == null) {
				first = file;
			}
		}
		return first;
	}

	public byte[] download(Map<String, Object> file, String token) {
		if (file.get("size") != null && Long.parseLong(file.get("size").toString()) > MAX_PDF_BYTES) {
			throw new IllegalArgumentException("파일이 너무 큽니다.");
		}
		String url = API_URL + "/files/" + enc((String) file.get("id")) + "?alt=media&supportsAllDrives=true";
		return rest.exchange(URI.create(url), HttpMethod.GET, new HttpEntity<Void>(auth(token)), byte[].class).getBody();
	}

	@SuppressWarnings("unchecked")
	private List<Map<String, Object>> list(String query, String token) {
		// shortcut: 이름 일치 폴더 하나, 사람 폴더 안 파일 몇 개라 첫 페이지(100건)면 충분하다. 폴더에 100개가 넘게 쌓이면 페이지를 넘겨야 한다
		String url = API_URL + "/files?pageSize=100&supportsAllDrives=true&includeItemsFromAllDrives=true"
				+ "&fields=" + enc("files(id,name,mimeType,size,shortcutDetails)") + "&orderBy=name&q=" + enc(query);
		return (List<Map<String, Object>>) get(url, token).get("files");
	}

	@SuppressWarnings("unchecked")
	private Map<String, Object> get(String url, String token) {
		// String 대신 URI 로 넘겨야 이미 인코딩한 쿼리를 RestTemplate 이 다시 인코딩하지 않는다
		return rest.exchange(URI.create(url), HttpMethod.GET, new HttpEntity<Void>(auth(token)), Map.class).getBody();
	}

	private static HttpHeaders auth(String token) {
		HttpHeaders headers = new HttpHeaders();
		headers.set("Authorization", "Bearer " + token);
		return headers;
	}

	/** 드라이브 검색식의 작은따옴표·역슬래시 이스케이프 */
	static String quote(String s) {
		return s.replace("\\", "\\\\").replace("'", "\\'");
	}

	private static String enc(String s) {
		try {
			return URLEncoder.encode(s, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			throw new IllegalStateException(e);
		}
	}
}
