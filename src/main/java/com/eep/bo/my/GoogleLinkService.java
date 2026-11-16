package com.eep.bo.my;

import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import com.eep.bo.batch.service.GoogleDriveApi;
import com.eep.bo.calendar.dao.BoCalendarDao;
import com.eep.bo.calendar.service.BoCalendarServiceImpl;
import com.eep.mapper.BoGoogleLinkMapper;

import common.util.RrnCipher;

/**
 * 구글 연동(드라이브·캘린더)은 회사 공용 하나(EMPLY_ID=COMPANY). 시스템 관리자만 연결·해제하고 모두가 쓴다.
 * 없으면 NeedLink 로 '내 연동'(연결 상태 화면)에 보낸다.
 */
@Service
public class GoogleLinkService {

	public static final String DRIVE = "DRIVE", CALENDAR = "CALENDAR";
	/** 서비스 → { 구글 권한, 이름 }. email 은 연결한 계정을 보여 주려고 함께 받는다 */
	static final Map<String, String[]> SERVICES = new LinkedHashMap<>();
	static {
		SERVICES.put(DRIVE, new String[] { GoogleDriveApi.WRITE_SCOPE + " email", "구글 드라이브" });
		SERVICES.put(CALENDAR, new String[] { "https://www.googleapis.com/auth/calendar.readonly email", "구글 캘린더" });
	}

	/** 연동이 없거나 끊겼을 때. 메시지 앞의 [연동 필요:서비스] 를 화면 공통 스크립트가 보고 '내 연동'으로 보낸다 */
	public static class NeedLink extends IllegalArgumentException {
		private static final long serialVersionUID = 1L;
		public final String service;

		public NeedLink(String service, String why) {
			super("[연동 필요:" + service + "] " + SERVICES.get(service)[1] + " " + why + " 회사 공용 연결이라 시스템 관리자가 연결해야 합니다.");
			this.service = service;
		}
	}

	@Autowired
	private BoGoogleLinkMapper mapper;
	@Autowired
	private GoogleDriveApi drive;
	@Autowired
	private BoCalendarDao confDao;

	private final RestTemplate rest = new RestTemplate();

	public List<Map<String, Object>> links(String loginId) {
		return mapper.selectLinks(key(loginId, null));
	}

	public boolean linked(String loginId, String service) {
		return mapper.selectRefresh(key(loginId, service)) != null;
	}

	public String account(String loginId, String service) {
		for (Map<String, Object> l : links(loginId)) if (service.equals(l.get("SERVICE_CD"))) return (String) l.get("ACCOUNT");
		return null;
	}

	/** 구글 승인 화면 주소. 클라이언트 설정이 없으면 null */
	public String authUrl(String service, String redirectUri, String state) {
		check(service);
		Map<String, String> conf = confDao.ConfMap();
		String id = conf.get(BoCalendarServiceImpl.CONF_CLIENT_ID);
		return id == null || id.trim().isEmpty() ? null : drive.authUrl(id, redirectUri, state, SERVICES.get(service)[0]);
	}

	/** 승인 코드를 토큰으로 바꿔 저장한다. @return null 이면 성공, 아니면 실패 사유 */
	public String connect(String loginId, String service, String redirectUri, String code) {
		check(service);
		Map<String, String> conf = confDao.ConfMap();
		Map<String, Object> tokens = drive.exchangeCode(conf.get(BoCalendarServiceImpl.CONF_CLIENT_ID), conf.get(BoCalendarServiceImpl.CONF_CLIENT_SECRET), redirectUri, code);
		String refresh = (String) tokens.get("refresh_token"), granted = (String) tokens.get("scope");
		if (refresh == null) return "fail";
		// 동의 화면에서 권한 체크를 빼면 연결돼도 쓸 수 없다
		String need = SERVICES.get(service)[0].split(" ")[0];
		if (granted == null || !Arrays.asList(granted.split(" ")).contains(need)) {
			revoke(refresh);
			return "scope";
		}
		Map<String, Object> p = key(loginId, service);
		p.put("REFRESH_ENC", RrnCipher.encrypt(refresh));
		p.put("ACCOUNT", email((String) tokens.get("access_token")));
		mapper.saveLink(p);
		return null;
	}

	public void disconnect(String loginId, String service) {
		check(service);
		String stored = mapper.selectRefresh(key(loginId, service));
		if (stored != null) revoke(RrnCipher.decrypt(stored));
		mapper.deleteLink(key(loginId, service));
	}

	/** 그 관리자의 연동으로 액세스 토큰. 연동이 없거나 구글에서 끊겼으면 NeedLink */
	public String accessToken(String loginId, String service) {
		check(service);
		String stored = mapper.selectRefresh(key(loginId, service));
		if (stored == null) throw new NeedLink(service, "연동이 없습니다.");
		Map<String, String> conf = confDao.ConfMap();
		try {
			return drive.accessToken(conf.get(BoCalendarServiceImpl.CONF_CLIENT_ID), conf.get(BoCalendarServiceImpl.CONF_CLIENT_SECRET), RrnCipher.decrypt(stored));
		} catch (HttpClientErrorException e) {
			// invalid_grant: 구글에서 권한 취소·비밀번호 변경·오래 안 씀
			if (e.getStatusCode().value() == 400 || e.getStatusCode().value() == 401) {
				mapper.deleteLink(key(loginId, service));
				throw new NeedLink(service, "연동이 끊겼습니다.");
			}
			throw e;
		}
	}

	/** 지금 요청한 관리자의 연동. 요청 밖(배치)에서는 아이디를 직접 넘긴 accessToken 을 쓴다 */
	public String accessToken(String service) {
		return accessToken(currentUser(), service);
	}

	@SuppressWarnings("unchecked")
	public static String currentUser() {
		ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
		HttpSession session = attrs == null ? null : attrs.getRequest().getSession(false);
		Object info = session == null ? null : session.getAttribute("loginInfo");
		if (!(info instanceof Map)) return null;
		List<Map<String, Object>> list = (List<Map<String, Object>>) ((Map<String, Object>) info).get("loginInfo");
		return list == null || list.isEmpty() ? null : (String) list.get(0).get("emplyId");
	}

	@SuppressWarnings("unchecked")
	private String email(String accessToken) {
		HttpHeaders h = new HttpHeaders();
		h.set("Authorization", "Bearer " + accessToken);
		try {
			Map<String, Object> me = rest.exchange("https://openidconnect.googleapis.com/v1/userinfo", HttpMethod.GET, new HttpEntity<Void>(h), Map.class).getBody();
			return me == null ? null : (String) me.get("email");
		} catch (RuntimeException e) {
			return null;
		}
	}

	private void revoke(String token) {
		try {
			rest.postForObject("https://oauth2.googleapis.com/revoke?token={t}", null, String.class, token);
		} catch (RuntimeException e) {
			// 이미 취소된 토큰이면 구글이 400 을 준다. 저장분은 어차피 지운다
		}
	}

	private static void check(String service) {
		if (!SERVICES.containsKey(service)) throw new IllegalArgumentException("알 수 없는 연동입니다.");
	}

	/** 회사 공용 연동 하나를 모두가 쓴다(사용자 결정). 넘어온 아이디는 무시하고 이 키로 저장·조회한다 */
	public static final String COMPANY = "COMPANY";

	private static Map<String, Object> key(String loginId, String service) {
		Map<String, Object> p = new HashMap<>();
		p.put("EMPLY_ID", COMPANY);
		if (service != null) p.put("SERVICE_CD", service);
		return p;
	}
}
