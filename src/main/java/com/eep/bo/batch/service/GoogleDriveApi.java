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
	public static final String FOLDER = "application/vnd.google-apps.folder";
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
		return authUrl(clientId, redirectUri, state, SCOPE);
	}

	/** 직원서류처럼 쓰기가 필요한 연결은 WRITE_SCOPE 로 따로 승인받는다 */
	public String authUrl(String clientId, String redirectUri, String state, String scope) {
		// select_account: 구글 계정을 여러 개 로그인한 브라우저에서 기본 계정으로 넘어가지 않게 한다
		return AUTH_URL + "?response_type=code&access_type=offline&prompt=select_account%20consent"
				+ "&client_id=" + enc(clientId)
				+ "&redirect_uri=" + enc(redirectUri)
				+ "&scope=" + enc(scope)
				+ "&state=" + enc(state);
	}

	public static final String WRITE_SCOPE = "https://www.googleapis.com/auth/drive";
	private static final String FILE_FIELDS = "id,name,mimeType,size,modifiedTime,webViewLink,shortcutDetails";

	/** 폴더 안 항목(폴더·파일). 휴지통 제외 */
	public List<Map<String, Object>> children(String folderId, String token) {
		return search("'" + quote(folderId) + "' in parents and trashed = false", token);
	}

	/** 드라이브 검색식 그대로. shortcut: 첫 페이지(200건)만 본다 */
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> search(String query, String token) {
		String url = API_URL + "/files?pageSize=200&supportsAllDrives=true&includeItemsFromAllDrives=true&corpora=allDrives"
				+ "&fields=" + enc("files(" + FILE_FIELDS + ")") + "&orderBy=name&q=" + enc(query);
		return (List<Map<String, Object>>) get(url, token).get("files");
	}

	@SuppressWarnings("unchecked")
	public Map<String, Object> file(String fileId, String token) {
		return get(API_URL + "/files/" + enc(fileId) + "?supportsAllDrives=true&fields=" + enc(FILE_FIELDS + ",parents"), token);
	}

	public String createFolder(String name, String parentId, String token) {
		Map<String, Object> body = new java.util.HashMap<>();
		body.put("name", name);
		body.put("mimeType", FOLDER);
		body.put("parents", java.util.Collections.singletonList(parentId));
		return (String) postJson(API_URL + "/files?supportsAllDrives=true&fields=id", body, token).get("id");
	}

	/** 파일 하나를 폴더에 올린다(multipart). {id, name, mimeType, webViewLink} */
	@SuppressWarnings("unchecked")
	public Map<String, Object> upload(String name, String mimeType, byte[] data, String parentId, String token) {
		return multipart("{\"name\":" + jsonStr(name) + ",\"parents\":[" + jsonStr(parentId) + "]}", mimeType, data, token);
	}

	/** 파일을 바로 지운다(휴지통을 거치지 않는다) */
	public void delete(String fileId, String token) {
		rest.exchange(URI.create(API_URL + "/files/" + enc(fileId) + "?supportsAllDrives=true"), HttpMethod.DELETE, new HttpEntity<Void>(auth(token)), Void.class);
	}

	/** HTML 을 구글 문서로 올려 PDF 로 받고 문서는 바로 지운다. 문서는 연결 계정의 내 드라이브(root)에 잠깐 생긴다 */
	public byte[] htmlToPdf(String name, String html, String token) {
		String meta = "{\"name\":" + jsonStr(name) + ",\"mimeType\":\"application/vnd.google-apps.document\",\"parents\":[\"root\"]}";
		String id = (String) multipart(meta, "text/html; charset=UTF-8", html.getBytes(java.nio.charset.StandardCharsets.UTF_8), token).get("id");
		try {
			String url = API_URL + "/files/" + enc(id) + "/export?mimeType=" + enc("application/pdf");
			return rest.exchange(URI.create(url), HttpMethod.GET, new HttpEntity<Void>(auth(token)), byte[].class).getBody();
		} finally {
			rest.exchange(URI.create(API_URL + "/files/" + enc(id) + "?supportsAllDrives=true"), HttpMethod.DELETE, new HttpEntity<Void>(auth(token)), Void.class);
		}
	}

	@SuppressWarnings("unchecked")
	private Map<String, Object> multipart(String meta, String mimeType, byte[] data, String token) {
		String boundary = "est" + java.util.UUID.randomUUID().toString().replace("-", "");
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		try {
			out.write(("--" + boundary + "\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n" + meta + "\r\n--" + boundary
					+ "\r\nContent-Type: " + mimeType + "\r\n\r\n").getBytes("UTF-8"));
			out.write(data);
			out.write(("\r\n--" + boundary + "--").getBytes("UTF-8"));
		} catch (java.io.IOException e) {
			throw new IllegalStateException(e);
		}
		HttpHeaders headers = auth(token);
		headers.set("Content-Type", "multipart/related; boundary=" + boundary);
		String url = "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&supportsAllDrives=true&fields=" + enc("id,name,mimeType,webViewLink");
		return rest.exchange(URI.create(url), HttpMethod.POST, new HttpEntity<byte[]>(out.toByteArray(), headers), Map.class).getBody();
	}

	/**
	 * 이미지·PDF 의 글자. 구글 문서로 복사하면 드라이브가 OCR 하고, 글자만 받은 뒤 복사본은 바로 지운다.
	 * 복사본은 연결 계정의 내 드라이브(root)에 잠깐 생긴다.
	 */
	public String ocrText(String fileId, String token) {
		Map<String, Object> body = new java.util.HashMap<>();
		body.put("name", "ocr-temp-" + fileId);
		body.put("mimeType", "application/vnd.google-apps.document");
		body.put("parents", java.util.Collections.singletonList("root"));
		String copyId = (String) postJson(API_URL + "/files/" + enc(fileId) + "/copy?supportsAllDrives=true&ocrLanguage=ko&fields=id", body, token).get("id");
		try {
			String url = API_URL + "/files/" + enc(copyId) + "/export?mimeType=" + enc("text/plain");
			byte[] text = rest.exchange(URI.create(url), HttpMethod.GET, new HttpEntity<Void>(auth(token)), byte[].class).getBody();
			return text == null ? "" : new String(text, java.nio.charset.StandardCharsets.UTF_8);
		} finally {
			rest.exchange(URI.create(API_URL + "/files/" + enc(copyId) + "?supportsAllDrives=true"), HttpMethod.DELETE, new HttpEntity<Void>(auth(token)), Void.class);
		}
	}

	@SuppressWarnings("unchecked")
	private Map<String, Object> postJson(String url, Map<String, Object> body, String token) {
		HttpHeaders headers = auth(token);
		headers.set("Content-Type", "application/json; charset=UTF-8");
		StringBuilder json = new StringBuilder("{");
		for (Map.Entry<String, Object> e : body.entrySet()) {
			if (json.length() > 1) json.append(',');
			json.append(jsonStr(e.getKey())).append(':');
			if (e.getValue() instanceof List) {
				json.append('[');
				List<?> l = (List<?>) e.getValue();
				for (int i = 0; i < l.size(); i++) json.append(i > 0 ? "," : "").append(jsonStr(String.valueOf(l.get(i))));
				json.append(']');
			} else {
				json.append(jsonStr(String.valueOf(e.getValue())));
			}
		}
		json.append('}');
		byte[] bytes = json.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8);
		return rest.exchange(URI.create(url), HttpMethod.POST, new HttpEntity<byte[]>(bytes, headers), Map.class).getBody();
	}

	static String jsonStr(String s) {
		StringBuilder b = new StringBuilder("\"");
		for (char c : s.toCharArray()) {
			if (c == '"' || c == '\\') b.append('\\').append(c);
			else if (c < 0x20) b.append(String.format("\\u%04x", (int) c));
			else b.append(c);
		}
		return b.append('"').toString();
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
