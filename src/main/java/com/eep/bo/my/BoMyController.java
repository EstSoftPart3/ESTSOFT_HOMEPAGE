package com.eep.bo.my;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.servlet.ModelAndView;

/**
 * 내 연동(/admin/my). 누구나 회사 공용 연결 상태를 보고, 연결·해제는 시스템 관리자만 한다(BoSystemService.Access).
 * 구글 콘솔의 승인된 리디렉션 URI 는 예전부터 등록된 https://www.estsw.co.kr/admin/batch/driveCallback.do 를 그대로 쓴다.
 */
@Controller
public class BoMyController {

	private static final String SS_STATE = "myGoogleState", SS_SERVICE = "myGoogleService", SS_BACK = "myGoogleBack";

	@Autowired
	private GoogleLinkService link;
	@Autowired
	private DriveConfService driveConf;
	@Autowired
	private com.eep.bo.system.service.BoSystemService systemService;
	@Autowired
	private com.eep.bo.batch.service.BoBatchService batch;
	@Autowired
	private com.eep.bo.calendar.service.GoogleCalendarApi calendarApi;
	@Autowired
	private com.eep.bo.batch.service.GoogleDriveApi drive;
	@Autowired
	private ViewPresetService views;

	@RequestMapping("/admin/my/openGoogleLink.do")
	public ModelAndView openGoogleLink() {
		return new ModelAndView("bo/my/google_link");
	}

	@RequestMapping(value = "/admin/my/googleLinkData.do", method = RequestMethod.POST)
	public ModelAndView googleLinkData(HttpSession session) {
		Map<String, Map<String, Object>> by = new HashMap<>();
		for (Map<String, Object> l : link.links(GoogleLinkService.currentUser())) by.put((String) l.get("SERVICE_CD"), l);
		List<Map<String, Object>> out = new ArrayList<>();
		for (String svc : GoogleLinkService.SERVICES.keySet()) {
			Map<String, Object> row = by.containsKey(svc) ? by.get(svc) : new HashMap<String, Object>();
			row.put("SERVICE_CD", svc);
			row.put("LINKED", by.containsKey(svc));
			out.add(row);
		}
		return json("result", out);
	}

	/** 구글 승인 화면으로 보낸다. back 은 연결 뒤 돌아갈 이 사이트 안 주소 */
	@RequestMapping("/admin/my/googleStart.do")
	public String googleStart(@RequestParam("svc") String svc, @RequestParam(value = "back", required = false) String back, HttpServletRequest request, HttpSession session) {
		if (!superUser()) return "redirect:/admin/my/openGoogleLink.do?result=admin";
		String state = UUID.randomUUID().toString();
		String url;
		try {
			url = link.authUrl(svc, redirectUri(request), state);
		} catch (IllegalArgumentException e) {
			return "redirect:/admin/my/openGoogleLink.do";
		}
		if (url == null) return "redirect:/admin/my/openGoogleLink.do?result=noclient";
		session.setAttribute(SS_STATE, state);
		session.setAttribute(SS_SERVICE, svc);
		// 열린 리디렉션이 되지 않게 이 사이트 /admin/ 아래 주소만 받는다
		session.setAttribute(SS_BACK, back != null && back.startsWith("/admin/") && !back.startsWith("//") ? back : null);
		return "redirect:" + url;
	}

	// 구글 콘솔에 이미 등록된 /admin/batch/driveCallback.do 로 돌아온다(새 URI 등록 없이). 이 주소는 BoSystemService.Access 가 모두에게 연다
	@RequestMapping({ "/admin/batch/driveCallback.do", "/admin/my/googleCallback.do" })
	public String googleCallback(@RequestParam Map<String, Object> param, HttpServletRequest request, HttpSession session) {
		Object state = session.getAttribute(SS_STATE), svc = session.getAttribute(SS_SERVICE), back = session.getAttribute(SS_BACK);
		session.removeAttribute(SS_STATE);
		session.removeAttribute(SS_SERVICE);
		session.removeAttribute(SS_BACK);
		String fail = "redirect:/admin/my/openGoogleLink.do?svc=" + (svc == null ? "" : svc) + "&result=";
		// state 가 다르면 이 세션이 시작한 승인이 아니다(CSRF). 사용자가 동의를 취소하면 code 없이 error 로 온다
		if (state == null || svc == null || !state.equals(param.get("state")) || param.get("code") == null || !superUser()) {
			return fail + (param.get("error") != null ? "denied" : "fail");
		}
		try {
			String why = link.connect(GoogleLinkService.currentUser(), (String) svc, redirectUri(request), (String) param.get("code"));
			if (why != null) return fail + why;
		} catch (RestClientException e) {
			System.out.println("GOOGLE_LINK_ERROR " + e.getClass().getSimpleName());
			return fail + "fail";
		}
		return back != null ? "redirect:" + back : "redirect:/admin/my/openGoogleLink.do?svc=" + svc + "&result=ok";
	}

	// ── 화면별 드라이브 설정(각 화면 ⚙). 그 화면을 열 수 있는 사람만 보고 고친다 ──

	@RequestMapping(value = "/admin/my/driveConfData.do", method = RequestMethod.POST)
	public ModelAndView driveConfData(@RequestParam("screen") String screen) {
		try {
			canEdit(screen);
			return json("result", driveConf.view(screen));
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/my/saveDriveConfData.do", method = RequestMethod.POST)
	public ModelAndView saveDriveConfData(@RequestParam("screen") String screen, @RequestParam Map<String, Object> param) {
		try {
			canEdit(screen);
			driveConf.save(screen, param);
			return json("result", "OK");
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	private void canEdit(String screen) {
		if (!systemService.access(GoogleLinkService.currentUser()).allows(DriveConfService.page(screen))) {
			throw new IllegalArgumentException("이 화면의 드라이브 설정을 고칠 권한이 없습니다.");
		}
	}

	// ── 구글 앱(OAuth 클라이언트) 설정. 슈퍼관리자만. 저장 검사는 예전 배치 화면 것 그대로 ──

	@RequestMapping(value = "/admin/my/googleClientData.do", method = RequestMethod.POST)
	public ModelAndView googleClientData() {
		if (!systemService.access(GoogleLinkService.currentUser()).superUser) return json("error", "슈퍼관리자만 볼 수 있습니다.");
		return json("result", batch.driveStatus());
	}

	@RequestMapping(value = "/admin/my/saveGoogleClientData.do", method = RequestMethod.POST)
	public ModelAndView saveGoogleClientData(@RequestParam(value = "clientId", defaultValue = "") String clientId, @RequestParam(value = "clientSecret", defaultValue = "") String clientSecret) {
		if (!systemService.access(GoogleLinkService.currentUser()).superUser) return json("error", "슈퍼관리자만 고칠 수 있습니다.");
		try {
			batch.saveDriveConf(clientId, clientSecret);
			return json("result", batch.driveStatus());
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	// ── 신입면접 배치가 읽을 면접 캘린더·이력서 폴더. 신입면접 배치 화면에서 고르고, 시스템 관리자만 고친다 ──
	// 주소는 /admin/my/ 라 메뉴 권한과 무관하게 열리고, 여기서 superUser 를 다시 본다

	@RequestMapping(value = "/admin/my/interviewSourceData.do", method = RequestMethod.POST)
	public ModelAndView interviewSourceData() {
		if (!superUser()) return json("error", "시스템 관리자만 볼 수 있습니다.");
		Map<String, Object> src = batch.interviewSource();
		String folderId = (String) src.remove("FOLDER_ID");
		ModelAndView mv = json("result", src);
		try {
			mv.addObject("calendars", calendarApi.calendarList(link.accessToken(GoogleLinkService.COMPANY, GoogleLinkService.CALENDAR)));
		} catch (RuntimeException e) {
			mv.addObject("calendarError", googleError("CALENDAR", e));
		}
		if (folderId != null) {
			try {
				mv.addObject("folderPath", drive.pathOf(folderId, link.accessToken(GoogleLinkService.COMPANY, GoogleLinkService.DRIVE)));
			} catch (RuntimeException e) {
				mv.addObject("folderError", googleError("DRIVE", e));
			}
		}
		return mv;
	}

	/**
	 * 폴더 고르기 창(공통 folder_pick.jspf): parent 아래 폴더(없으면 내 드라이브 맨 위, SHARED 면 나와 공유됨), q 가 있으면 이름으로 찾기.
	 * 신입면접 배치는 시스템 관리자만, 각 화면 ⚙ 드라이브 설정은 그 화면(screen)을 고칠 수 있는 사람이 쓴다
	 */
	@RequestMapping(value = "/admin/my/driveFoldersData.do", method = RequestMethod.POST)
	public ModelAndView driveFoldersData(@RequestParam(value = "parent", defaultValue = "") String parent, @RequestParam(value = "mode", defaultValue = "MY") String mode,
			@RequestParam(value = "q", defaultValue = "") String q, @RequestParam(value = "screen", defaultValue = "") String screen) {
		if (!superUser()) {
			if (screen.isEmpty()) return json("error", "시스템 관리자만 볼 수 있습니다.");
			try {
				canEdit(screen);
			} catch (IllegalArgumentException e) {
				return json("error", e.getMessage());
			}
		}
		try {
			String token = link.accessToken(GoogleLinkService.COMPANY, GoogleLinkService.DRIVE);
			String text = q.trim(), at = parent.trim().isEmpty() ? ("SHARED".equals(mode) ? null : "root") : parent.trim();
			List<Map<String, Object>> folders = !text.isEmpty() ? drive.findFolders(text.length() > 100 ? text.substring(0, 100) : text, token) : drive.folders(at, token);
			List<Map<String, Object>> out = new ArrayList<>();
			for (Map<String, Object> f : folders) {
				Map<String, Object> m = new HashMap<>();
				m.put("id", f.get("id"));
				m.put("name", f.get("name"));
				out.add(m);
			}
			ModelAndView mv = json("result", out);
			mv.addObject("path", text.isEmpty() && at != null ? drive.pathOf(at, token) : new ArrayList<Object>());
			return mv;
		} catch (RuntimeException e) {
			return json("googleError", googleError("DRIVE", e));
		}
	}

	/** 구글 응답을 화면 안내용 { code, msg, url } 으로. code: NOLINK·API_OFF·EXPIRED·SCOPE·NOTFOUND·OTHER */
	static Map<String, Object> googleError(String service, RuntimeException e) {
		Map<String, Object> err = new HashMap<>();
		String nm = "CALENDAR".equals(service) ? "Google Calendar" : "Google Drive";
		if (e instanceof GoogleLinkService.NeedLink) {
			err.put("code", "NOLINK");
			err.put("msg", nm + " 회사 공용 연결이 없거나 끊겼습니다. 내 연동에서 연결해 주세요.");
			return err;
		}
		String body = e instanceof HttpStatusCodeException ? ((HttpStatusCodeException) e).getResponseBodyAsString() : "";
		int status = e instanceof HttpStatusCodeException ? ((HttpStatusCodeException) e).getStatusCode().value() : 0;
		System.out.println("GOOGLE_API_ERROR " + service + " " + status + " " + (body.length() > 300 ? body.substring(0, 300) : body).replaceAll("\\s+", " "));
		if (body.contains("accessNotConfigured") || body.contains("SERVICE_DISABLED")) {
			err.put("code", "API_OFF");
			err.put("msg", "구글 클라우드 프로젝트에서 " + nm + " API 가 꺼져 있습니다. 앱 키를 만든 계정으로 켜고 1~2분 뒤 다시 시도해 주세요.");
			Matcher m = Pattern.compile("https://console\\.(?:developers|cloud)\\.google\\.com/apis/[^\\s\"\\\\]+").matcher(body);
			err.put("url", m.find() ? m.group() : "https://console.cloud.google.com/apis/library/" + ("CALENDAR".equals(service) ? "calendar-json" : "drive") + ".googleapis.com");
		} else if (status == 401) {
			err.put("code", "EXPIRED");
			err.put("msg", nm + " 연결이 만료됐습니다. 내 연동에서 다시 연결해 주세요.");
		} else if (body.contains("insufficientPermissions") || body.contains("ACCESS_TOKEN_SCOPE_INSUFFICIENT")) {
			err.put("code", "SCOPE");
			err.put("msg", nm + " 권한 체크가 빠져 있습니다. 내 연동에서 권한을 모두 켜고 다시 연결해 주세요.");
		} else if (status == 404) {
			err.put("code", "NOTFOUND");
			err.put("msg", "폴더나 캘린더를 찾지 못했습니다. 지워졌거나 연결 계정에 공유되지 않았습니다. 다시 골라 주세요.");
		} else {
			Matcher m = Pattern.compile("\"message\"\\s*:\\s*\"([^\"]+)\"").matcher(body);
			err.put("code", "OTHER");
			err.put("msg", "구글이 요청을 거절했습니다" + (m.find() ? ": " + m.group(1) : " (" + e.getClass().getSimpleName() + ")") + ". 잠시 뒤 다시 시도해 주세요.");
		}
		return err;
	}

	@RequestMapping(value = "/admin/my/saveInterviewSourceData.do", method = RequestMethod.POST)
	public ModelAndView saveInterviewSourceData(@RequestParam(value = "calId", defaultValue = "") String calId, @RequestParam(value = "calName", defaultValue = "") String calName, @RequestParam(value = "folder", defaultValue = "") String folder) {
		if (!superUser()) return json("error", "시스템 관리자만 고칠 수 있습니다.");
		try {
			batch.saveInterviewSource(calId, calName, folder);
			return json("result", batch.interviewSource());
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	@RequestMapping(value = "/admin/my/googleUnlinkData.do", method = RequestMethod.POST)
	public ModelAndView googleUnlinkData(@RequestParam("svc") String svc) {
		if (!superUser()) return json("error", "회사 공용 연결이라 시스템 관리자만 해제할 수 있습니다.");
		try {
			link.disconnect(GoogleLinkService.currentUser(), svc);
			return json("result", "OK");
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	// ── 목록 화면 '보기' 저장(bo-view.js). 자기 계정 것만 읽고 고친다 ──

	@RequestMapping(value = "/admin/my/viewPresetData.do", method = RequestMethod.POST)
	public ModelAndView viewPresetData(@RequestParam("page") String page) {
		return viewDo(() -> views.list(me(), page));
	}

	@RequestMapping(value = "/admin/my/saveViewPresetData.do", method = RequestMethod.POST)
	public ModelAndView saveViewPresetData(@RequestParam("page") String page, @RequestParam(value = "vwSq", defaultValue = "") String vwSq,
			@RequestParam(value = "nm", defaultValue = "") String nm, @RequestParam("conf") String conf, @RequestParam(value = "drop", defaultValue = "") String drop) {
		return viewDo(() -> {
			Object sq = views.save(me(), page, vwSq, nm, conf, "Y".equals(drop));
			if (sq != null) return sq;
			Map<String, Object> full = new HashMap<>();
			full.put("full", ((List<?>) views.list(me(), page).get("list")).get(0));
			return full;
		});
	}

	@RequestMapping(value = "/admin/my/useViewPresetData.do", method = RequestMethod.POST)
	public ModelAndView useViewPresetData(@RequestParam("page") String page, @RequestParam(value = "vwSq", defaultValue = "") String vwSq) {
		return viewDo(() -> { views.use(me(), page, vwSq); return "OK"; });
	}

	@RequestMapping(value = "/admin/my/deleteViewPresetData.do", method = RequestMethod.POST)
	public ModelAndView deleteViewPresetData(@RequestParam("page") String page, @RequestParam("vwSq") String vwSq) {
		return viewDo(() -> { views.delete(me(), page, vwSq); return "OK"; });
	}

	private static String me() {
		String id = GoogleLinkService.currentUser();
		if (id == null) throw new IllegalArgumentException("로그인이 필요합니다.");
		return id;
	}

	private static ModelAndView viewDo(java.util.function.Supplier<Object> f) {
		try {
			return json("result", f.get());
		} catch (IllegalArgumentException e) {
			return json("error", e.getMessage());
		}
	}

	/** 구글 연동은 회사 공용 하나라 시스템 관리자(superUser)만 연결·해제한다 */
	private boolean superUser() {
		return systemService.access(GoogleLinkService.currentUser()).superUser;
	}

	/** 구글 콘솔 등록값과 글자까지 같아야 한다. 프록시가 https 를 전달하지 않아 운영 도메인은 https 로 고정한다(BoBatchController 와 같음) */
	public static String redirectUri(HttpServletRequest request) {
		String host = request.getHeader("Host");
		String proto = host != null && host.startsWith("localhost") ? request.getScheme() : "https";
		return proto + "://" + host + "/admin/batch/driveCallback.do";
	}

	private static ModelAndView json(String key, Object value) {
		ModelAndView mv = new ModelAndView("jsonView");
		mv.addObject(key, value);
		return mv;
	}
}
