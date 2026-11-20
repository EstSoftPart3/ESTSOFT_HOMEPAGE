package com.eep.bo.my;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import javax.annotation.PostConstruct;
import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;

import com.eep.bo.system.service.BoSystemService;
import com.fasterxml.jackson.databind.ObjectMapper;

import common.util.RrnCipher;

/**
 * 휴대폰 알림(텔레그램 봇). 봇 토큰은 내 연동 화면에서 슈퍼관리자가 넣고(TB_EEP_CAL_CONF_M, RrnCipher 암호),
 * 관리자마다 1회용 코드 딥링크로 자기 텔레그램을 연결한다. 1분마다 곧 시작할 일정을 사람별 설정으로 걸러 보내고,
 * 면접·모집 인터뷰는 시간 변경·취소도 알린다(사람이 켠 종류만). 같은 알림은 TB_EEP_TG_SEND_H 의 UNIQUE 로 한 번만 간다.
 * 웹훅 대신 getUpdates 로 연결 메시지를 가져와 외부에서 들어오는 주소가 필요 없다.
 */
@Service
public class TelegramService {

	static final String CONF_TOKEN = "TELEGRAM_BOT_TOKEN", CONF_NAME = "TELEGRAM_BOT_NAME", CONF_BASE = "TELEGRAM_BASE_URL", CONF_OFFSET = "TELEGRAM_UPDATE_OFFSET";
	static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");
	/** 알림 종류. 코드는 홈 달력 CAL_KIND 와 같다. 시간이 있는 일정만(하루 종일 일정은 받지 않기로 함) */
	public static final Map<String, String> KINDS = new LinkedHashMap<>();
	/** 그 종류를 보려면 열려 있어야 하는 화면 데이터 주소(메뉴 권한). 내 할 일은 본인 것이라 없음 */
	static final Map<String, String> PAGE = new HashMap<>();
	/** 시간 변경·취소 알림을 고를 수 있는 종류(내 할 일은 본인이 고치므로 뺌) */
	static final Set<String> CHANGE_KINDS = new LinkedHashSet<>(Arrays.asList("INTV_NEW", "INTV_EXP", "RC_INTV"));
	static final Set<Integer> BEFORE = new LinkedHashSet<>(Arrays.asList(10, 30, 60));
	private static final DateTimeFormatter AT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
	static {
		KINDS.put("INTV_NEW", "신입면접");
		KINDS.put("INTV_EXP", "경력면접");
		KINDS.put("RC_INTV", "모집 인터뷰");
		KINDS.put("MY", "내 할 일");
		PAGE.put("INTV_NEW", "/admin/hr/interviewListData.do");
		PAGE.put("INTV_EXP", "/admin/hr/interviewListData.do");
		PAGE.put("RC_INTV", "/admin/recruit/listData.do");
	}

	private JdbcTemplate jdbc;
	private final RestTemplate rest;
	private final ObjectMapper om = new ObjectMapper();

	@Autowired
	private BoSystemService systemService;

	public TelegramService() {
		SimpleClientHttpRequestFactory f = new SimpleClientHttpRequestFactory();
		f.setConnectTimeout(10000);
		f.setReadTimeout(15000);
		rest = new RestTemplate(f);
	}

	@Autowired
	public void setDataSource(@Qualifier("dataSource") DataSource ds) { // dataSourceSpied 와 2개라 이름을 지정해야 기동된다
		jdbc = new JdbcTemplate(ds);
	}

	/** sql/telegram_alarm.sql 과 같은 내용. 이미 있으면 아무것도 하지 않는다 */
	@PostConstruct
	public void ensureSchema() {
		try {
			jdbc.execute("CREATE TABLE IF NOT EXISTS TB_EEP_TG_LINK_R (EMPLY_ID VARCHAR(50) NOT NULL PRIMARY KEY, CHAT_ID VARCHAR(30) NULL, TG_USER_NM VARCHAR(100) NULL,"
					+ " LINK_CODE VARCHAR(40) NULL, CODE_EXP_DT DATETIME NULL, STATUS_CD VARCHAR(10) NOT NULL DEFAULT 'WAIT',"
					+ " KINDS VARCHAR(100) NULL DEFAULT 'INTV_NEW,INTV_EXP,RC_INTV,MY', BEFORE_MIN INT NOT NULL DEFAULT 30, CHANGE_KINDS VARCHAR(100) NULL,"
					+ " LINK_DT DATETIME NULL, UPDT_DT DATETIME NULL, UNIQUE KEY UX_TG_CODE (LINK_CODE))"
					+ " DEFAULT CHARSET=utf8mb4 COMMENT='텔레그램 알림 연결·설정(관리자별)'");
			jdbc.execute("CREATE TABLE IF NOT EXISTS TB_EEP_TG_SEND_H (SEND_SQ INT NOT NULL AUTO_INCREMENT PRIMARY KEY, EMPLY_ID VARCHAR(50) NOT NULL, KIND VARCHAR(10) NOT NULL,"
					+ " SRC_SQ VARCHAR(20) NOT NULL, EVENT_AT VARCHAR(16) NOT NULL, MSG_CD VARCHAR(10) NOT NULL, RESULT_CD VARCHAR(10) NOT NULL, ERR_MSG VARCHAR(300) NULL,"
					+ " SEND_DT DATETIME NOT NULL, UNIQUE KEY UX_TG_SEND (EMPLY_ID, KIND, SRC_SQ, EVENT_AT, MSG_CD), KEY IX_TG_SEND_DT (SEND_DT))"
					+ " DEFAULT CHARSET=utf8mb4 COMMENT='텔레그램 알림 발송 기록(중복 방지)'");
			jdbc.execute("CREATE TABLE IF NOT EXISTS TB_EEP_TG_EVT_S (KIND VARCHAR(10) NOT NULL, SRC_SQ VARCHAR(20) NOT NULL, EVENT_AT VARCHAR(16) NOT NULL, TITLE VARCHAR(200) NULL,"
					+ " PRIMARY KEY (KIND, SRC_SQ)) DEFAULT CHARSET=utf8mb4 COMMENT='텔레그램 알림 변경·취소 감지용 직전 일정 상태'");
		} catch (RuntimeException e) {
			System.out.println("TG_SCHEMA_ERROR " + e.getClass().getSimpleName());
		}
	}

	// ── 봇(슈퍼관리자) ──

	public Map<String, Object> bot() {
		Map<String, Object> out = new HashMap<>();
		String token = token();
		out.put("ready", token != null);
		out.put("name", conf(CONF_NAME));
		out.put("mask", token == null ? null : "****" + token.substring(token.length() - 4));
		return out;
	}

	/** 토큰을 텔레그램에 물어(getMe) 맞으면 봇 아이디와 함께 저장한다. base 는 「상세 보기」 버튼이 열 이 사이트 주소 */
	public Map<String, Object> saveBot(String token, String base) {
		String t = token == null ? "" : token.trim();
		if (!t.matches("\\d{5,15}:[A-Za-z0-9_-]{30,60}")) throw new IllegalArgumentException("봇 토큰 모양이 아닙니다. BotFather 가 준 「숫자:영문」 값을 그대로 붙여 넣어 주세요.");
		Map<String, Object> me;
		try {
			me = call(t, "getMe", new HashMap<String, Object>());
		} catch (TgError e) {
			throw new IllegalArgumentException(e.status == 401 || e.status == 404 ? "텔레그램이 이 토큰을 모릅니다. BotFather 에서 받은 토큰을 다시 복사해 주세요." : "텔레그램에 연결하지 못했습니다. 잠시 뒤 다시 시도해 주세요.");
		}
		String name = String.valueOf(((Map<?, ?>) me.get("result")).get("username"));
		boolean same = t.equals(token());
		saveConf(CONF_TOKEN, RrnCipher.encrypt(t));
		saveConf(CONF_NAME, name);
		saveConf(CONF_BASE, base);
		if (!same) { // 다른 봇이면 이전 봇의 대화 번호는 쓸 수 없다
			saveConf(CONF_OFFSET, "0");
			jdbc.update("UPDATE TB_EEP_TG_LINK_R SET STATUS_CD = 'OFF', CHAT_ID = NULL, LINK_CODE = NULL, UPDT_DT = NOW() WHERE STATUS_CD <> 'OFF'");
		}
		return bot();
	}

	// ── 내 연결·설정(본인) ──

	public Map<String, Object> mine(String user) {
		Map<String, Object> out = new HashMap<>();
		out.put("bot", bot());
		List<Map<String, Object>> r = jdbc.queryForList("SELECT STATUS_CD, TG_USER_NM, DATE_FORMAT(LINK_DT, '%Y-%m-%d %H:%i') LINK_DT, KINDS, BEFORE_MIN, CHANGE_KINDS,"
				+ " (LINK_CODE IS NOT NULL AND CODE_EXP_DT > NOW()) WAITING FROM TB_EEP_TG_LINK_R WHERE EMPLY_ID = ?", user);
		out.put("link", r.isEmpty() ? null : r.get(0));
		BoSystemService.Access acc = systemService.access(user);
		List<Map<String, Object>> kinds = new ArrayList<>();
		for (Map.Entry<String, String> k : KINDS.entrySet()) {
			if (PAGE.containsKey(k.getKey()) && !acc.allows(PAGE.get(k.getKey()))) continue;
			Map<String, Object> m = new HashMap<>();
			m.put("cd", k.getKey());
			m.put("nm", k.getValue());
			m.put("change", CHANGE_KINDS.contains(k.getKey()));
			kinds.add(m);
		}
		out.put("kinds", kinds);
		return out;
	}

	/** 1회용 코드(10분)를 만들고 봇 딥링크를 돌려준다. 이미 연결돼 있으면 연결은 그대로 두고 새 휴대폰으로 바꿀 코드만 준다 */
	public String start(String user) {
		String token = token(), name = conf(CONF_NAME);
		if (token == null || name == null) throw new IllegalArgumentException("아직 알림 봇이 설정되지 않았습니다. 시스템 관리자에게 요청해 주세요.");
		String code = UUID.randomUUID().toString().replace("-", "");
		if (jdbc.update("UPDATE TB_EEP_TG_LINK_R SET LINK_CODE = ?, CODE_EXP_DT = DATE_ADD(NOW(), INTERVAL 10 MINUTE), UPDT_DT = NOW() WHERE EMPLY_ID = ?", code, user) == 0) {
			jdbc.update("INSERT INTO TB_EEP_TG_LINK_R (EMPLY_ID, LINK_CODE, CODE_EXP_DT, STATUS_CD, UPDT_DT) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 10 MINUTE), 'WAIT', NOW())", user, code);
		}
		return "https://t.me/" + name + "?start=" + code;
	}

	public void saveConf(String user, String kinds, String before, String changeKinds) {
		int b;
		try {
			b = Integer.parseInt(before);
		} catch (NumberFormatException e) {
			b = -1;
		}
		if (!BEFORE.contains(b)) throw new IllegalArgumentException("몇 분 전은 10·30·60 중에서 골라 주세요.");
		if (jdbc.update("UPDATE TB_EEP_TG_LINK_R SET KINDS = ?, BEFORE_MIN = ?, CHANGE_KINDS = ?, UPDT_DT = NOW() WHERE EMPLY_ID = ?",
				pick(kinds, KINDS.keySet()), b, pick(changeKinds, CHANGE_KINDS), user) == 0) {
			throw new IllegalArgumentException("먼저 텔레그램을 연결해 주세요.");
		}
	}

	public void test(String user) {
		Map<String, Object> l = onLink(user);
		String token = token();
		if (token == null) throw new IllegalArgumentException("알림 봇이 설정되지 않았습니다.");
		Map<String, Object> p = new HashMap<>();
		p.put("chat_id", l.get("CHAT_ID"));
		p.put("text", "🔔 시험 알림입니다. 이 메시지가 울렸다면 일정 알림도 이렇게 옵니다.");
		try {
			call(token, "sendMessage", p);
		} catch (TgError e) {
			if (e.status == 403) off((String) l.get("CHAT_ID"));
			throw new IllegalArgumentException(e.status == 403 ? "봇이 차단돼 보내지 못했습니다. 텔레그램에서 봇 차단을 풀고 다시 연결해 주세요." : "보내지 못했습니다. 잠시 뒤 다시 시도해 주세요.");
		}
	}

	public void unlink(String user) {
		jdbc.update("UPDATE TB_EEP_TG_LINK_R SET STATUS_CD = 'OFF', CHAT_ID = NULL, LINK_CODE = NULL, UPDT_DT = NOW() WHERE EMPLY_ID = ?", user);
	}

	private Map<String, Object> onLink(String user) {
		List<Map<String, Object>> r = jdbc.queryForList("SELECT CHAT_ID FROM TB_EEP_TG_LINK_R WHERE EMPLY_ID = ? AND STATUS_CD = 'ON' AND CHAT_ID IS NOT NULL", user);
		if (r.isEmpty()) throw new IllegalArgumentException("텔레그램이 연결돼 있지 않습니다.");
		return r.get(0);
	}

	// ── 봇에 온 메시지(연결) ──

	/** 봇에 온 「/start 코드」를 읽어 계정과 잇는다. 「연결 확인」 버튼과 1분 배치(기다리는 코드가 있을 때만)가 부른다 */
	public synchronized void poll() {
		String token = token();
		if (token == null) return;
		long offset = Long.parseLong(conf(CONF_OFFSET) == null ? "0" : conf(CONF_OFFSET));
		Map<String, Object> p = new HashMap<>();
		p.put("offset", offset);
		p.put("timeout", 0);
		p.put("allowed_updates", Arrays.asList("message"));
		List<?> updates = (List<?>) call(token, "getUpdates", p).get("result");
		for (Object o : updates) {
			Map<?, ?> u = (Map<?, ?>) o;
			offset = Math.max(offset, ((Number) u.get("update_id")).longValue() + 1);
			Map<?, ?> msg = (Map<?, ?>) u.get("message");
			if (msg == null || msg.get("chat") == null || !"private".equals(((Map<?, ?>) msg.get("chat")).get("type"))) continue;
			String chat = String.valueOf(((Map<?, ?>) msg.get("chat")).get("id")), text = msg.get("text") == null ? "" : String.valueOf(msg.get("text")).trim();
			Map<?, ?> from = (Map<?, ?>) msg.get("from");
			try {
				reply(token, chat, handle(chat, text, from));
			} catch (RuntimeException e) {
				System.out.println("TG_POLL_ERROR " + e.getClass().getSimpleName());
			}
		}
		saveConf(CONF_OFFSET, String.valueOf(offset));
	}

	private String handle(String chat, String text, Map<?, ?> from) {
		if (text.startsWith("/start")) {
			String code = text.substring(6).trim();
			List<Map<String, Object>> r = code.matches("[0-9a-f]{32}")
					? jdbc.queryForList("SELECT EMPLY_ID FROM TB_EEP_TG_LINK_R WHERE LINK_CODE = ? AND CODE_EXP_DT > NOW()", code) : new ArrayList<Map<String, Object>>();
			if (r.isEmpty()) return "연결 코드가 없거나 10분이 지났습니다. 관리자 화면 › 내 연동에서 「텔레그램 연결」을 다시 눌러 주세요.";
			String user = (String) r.get(0).get("EMPLY_ID");
			String nm = from == null ? "" : from.get("username") != null ? "@" + from.get("username") : String.valueOf(from.get("first_name"));
			jdbc.update("UPDATE TB_EEP_TG_LINK_R SET CHAT_ID = ?, TG_USER_NM = ?, STATUS_CD = 'ON', LINK_CODE = NULL, CODE_EXP_DT = NULL, LINK_DT = NOW(), UPDT_DT = NOW() WHERE EMPLY_ID = ?",
					chat, cut(nm, 100), user);
			int before = jdbc.queryForObject("SELECT BEFORE_MIN FROM TB_EEP_TG_LINK_R WHERE EMPLY_ID = ?", Integer.class, user);
			return "✅ 관리자 계정 " + user + " 과 연결됐습니다.\n이제 일정 " + before + "분 전에 알려 드립니다. 받을 종류·시간은 내 연동 화면에서 바꿀 수 있습니다.";
		}
		if (text.startsWith("/stop")) {
			off(chat);
			return "알림을 끊었습니다. 다시 받으려면 관리자 화면 › 내 연동에서 「텔레그램 연결」을 눌러 주세요.";
		}
		return "일정 알림을 보내는 봇입니다. 연결·설정은 관리자 화면 › 내 연동에서 합니다.";
	}

	private void off(String chat) {
		jdbc.update("UPDATE TB_EEP_TG_LINK_R SET STATUS_CD = 'OFF', CHAT_ID = NULL, UPDT_DT = NOW() WHERE CHAT_ID = ?", chat);
	}

	private void reply(String token, String chat, String text) {
		Map<String, Object> p = new HashMap<>();
		p.put("chat_id", chat);
		p.put("text", text);
		call(token, "sendMessage", p);
	}

	// ── 1분 배치 ──

	/** 컨테이너는 UTC 지만 시각은 코드에서 서울로 계산한다(면접 전 배치와 같음) */
	@Scheduled(cron = "30 * * * * *")
	public void tick() {
		if (token() == null) return;
		try {
			if (jdbc.queryForObject("SELECT COUNT(*) FROM TB_EEP_TG_LINK_R WHERE LINK_CODE IS NOT NULL AND CODE_EXP_DT > NOW()", Integer.class) > 0) poll();
		} catch (RuntimeException e) {
			System.out.println("TG_POLL_ERROR " + e.getClass().getSimpleName());
		}
		LocalDateTime now = LocalDateTime.now(SEOUL).truncatedTo(ChronoUnit.MINUTES);
		try {
			sendDue(now);
		} catch (RuntimeException e) {
			System.out.println("TG_SEND_ERROR " + e.getClass().getSimpleName());
		}
		try {
			trackChanges(now);
		} catch (RuntimeException e) {
			System.out.println("TG_TRACK_ERROR " + e.getClass().getSimpleName());
		}
	}

	/** 일정 N분 전 알림. 「시작 N분 전 ~ 시작 전」 사이면 보낸다(재시작으로 놓친 분도 시작 전이면 보냄). 바뀐 시각은 EVENT_AT 이 달라 새로 보낸다 */
	void sendDue(LocalDateTime now) {
		List<Map<String, Object>> users = users();
		if (users.isEmpty()) return;
		List<Ev> evs = shared(now, now.plusMinutes(61));
		evs.addAll(myTasks(now, now.plusMinutes(61)));
		if (evs.isEmpty()) return;
		for (Map<String, Object> u : users) {
			String id = (String) u.get("EMPLY_ID");
			Set<String> kinds = set(u.get("KINDS"));
			int before = ((Number) u.get("BEFORE_MIN")).intValue();
			BoSystemService.Access acc = null;
			for (Ev ev : evs) {
				if (!kinds.contains(ev.kind) || (ev.owner != null && !ev.owner.equals(id))) continue;
				if (now.isBefore(ev.at.minusMinutes(before)) || !now.isBefore(ev.at)) continue;
				if (PAGE.containsKey(ev.kind)) {
					if (acc == null) acc = systemService.access(id);
					if (!acc.allows(PAGE.get(ev.kind))) continue;
				}
				send(u, ev, "BEFORE", ev.at, beforeText(ev, now));
			}
		}
	}

	/** 면접·모집 인터뷰의 직전 상태(TB_EEP_TG_EVT_S)와 비교해 시각 변경·취소를 찾는다. 새로 생긴 일정은 알리지 않는다 */
	void trackChanges(LocalDateTime now) {
		Map<String, Ev> cur = new HashMap<>();
		for (Ev ev : shared(now.toLocalDate().atStartOfDay(), now.plusDays(180))) cur.put(ev.kind + ":" + ev.sq, ev);
		List<Map<String, Object>> watchers = null;
		for (Map<String, Object> s : jdbc.queryForList("SELECT KIND, SRC_SQ, EVENT_AT, TITLE FROM TB_EEP_TG_EVT_S")) {
			String kind = (String) s.get("KIND"), sq = (String) s.get("SRC_SQ");
			LocalDateTime was = LocalDateTime.parse((String) s.get("EVENT_AT"), AT);
			Ev ev = cur.remove(kind + ":" + sq);
			if (ev == null) {
				jdbc.update("DELETE FROM TB_EEP_TG_EVT_S WHERE KIND = ? AND SRC_SQ = ?", kind, sq);
				if (!was.isAfter(now)) continue; // 지난 일정이 범위에서 빠진 것
				Ev gone = new Ev(kind, sq, was, (String) s.get("TITLE"), null, null, null);
				if (watchers == null) watchers = users();
				notifyChange(watchers, gone, "CANCEL", was, "❌ 일정 취소 · " + KINDS.get(kind) + " " + gone.title + "\n" + when(was, now) + " 일정이 취소·삭제됐습니다.");
			} else if (!ev.at.equals(was)) {
				jdbc.update("UPDATE TB_EEP_TG_EVT_S SET EVENT_AT = ?, TITLE = ? WHERE KIND = ? AND SRC_SQ = ?", ev.at.format(AT), cut(ev.title, 200), kind, sq);
				if (!was.isAfter(now) && !ev.at.isAfter(now)) continue;
				if (watchers == null) watchers = users();
				notifyChange(watchers, ev, "CHANGE", ev.at, "🔁 일정 변경 · " + KINDS.get(kind) + " " + ev.title + "\n" + when(was, now) + " → " + when(ev.at, now));
			}
		}
		for (Ev ev : cur.values()) {
			jdbc.update("INSERT IGNORE INTO TB_EEP_TG_EVT_S (KIND, SRC_SQ, EVENT_AT, TITLE) VALUES (?, ?, ?, ?)", ev.kind, ev.sq, ev.at.format(AT), cut(ev.title, 200));
		}
	}

	private void notifyChange(List<Map<String, Object>> users, Ev ev, String msgCd, LocalDateTime at, String text) {
		for (Map<String, Object> u : users) {
			if (!set(u.get("CHANGE_KINDS")).contains(ev.kind)) continue;
			if (!systemService.access((String) u.get("EMPLY_ID")).allows(PAGE.get(ev.kind))) continue;
			send(u, ev, msgCd, at, text);
		}
	}

	/** 먼저 기록을 넣어(UNIQUE) 자리를 잡은 사람만 보낸다. 로컬 실행이 같은 DB 로 같이 돌아도 두 번 가지 않는다 */
	private void send(Map<String, Object> u, Ev ev, String msgCd, LocalDateTime at, String text) {
		String id = (String) u.get("EMPLY_ID"), chat = (String) u.get("CHAT_ID");
		if (jdbc.update("INSERT IGNORE INTO TB_EEP_TG_SEND_H (EMPLY_ID, KIND, SRC_SQ, EVENT_AT, MSG_CD, RESULT_CD, SEND_DT) VALUES (?, ?, ?, ?, ?, 'WAIT', NOW())",
				id, ev.kind, ev.sq, at.format(AT), msgCd) == 0) return;
		Map<String, Object> p = new HashMap<>();
		p.put("chat_id", chat);
		p.put("text", text);
		String base = conf(CONF_BASE);
		// 텔레그램은 localhost 링크 버튼을 받지 않는다
		if (ev.url != null && base != null && base.startsWith("https://")) {
			Map<String, Object> btn = new HashMap<>();
			btn.put("text", "상세 보기");
			btn.put("url", base + ev.url);
			Map<String, Object> kb = new HashMap<>();
			kb.put("inline_keyboard", Arrays.asList(Arrays.asList(btn)));
			p.put("reply_markup", kb);
		}
		String result = "OK", err = null;
		try {
			call(token(), "sendMessage", p);
		} catch (TgError e) {
			result = "FAIL";
			err = e.getMessage();
			if (e.status == 403) off(chat); // 사용자가 봇을 차단·삭제함
		} catch (RuntimeException e) {
			result = "FAIL";
			err = e.getClass().getSimpleName();
		}
		jdbc.update("UPDATE TB_EEP_TG_SEND_H SET RESULT_CD = ?, ERR_MSG = ? WHERE EMPLY_ID = ? AND KIND = ? AND SRC_SQ = ? AND EVENT_AT = ? AND MSG_CD = ?",
				result, cut(err, 300), id, ev.kind, ev.sq, at.format(AT), msgCd);
	}

	/** 90일 지난 발송 기록은 지운다(매일 서울 04:10 = UTC 19:10) */
	@Scheduled(cron = "0 10 19 * * *")
	public void cleanup() {
		try {
			jdbc.update("DELETE FROM TB_EEP_TG_SEND_H WHERE SEND_DT < DATE_SUB(NOW(), INTERVAL 90 DAY)");
		} catch (RuntimeException e) {
			System.out.println("TG_CLEAN_ERROR " + e.getClass().getSimpleName());
		}
	}

	/** 연결된 사용자(사용 중인 관리자 계정만) */
	private List<Map<String, Object>> users() {
		List<Map<String, Object>> out = new ArrayList<>();
		for (Map<String, Object> u : jdbc.queryForList("SELECT EMPLY_ID, CHAT_ID, KINDS, BEFORE_MIN, CHANGE_KINDS FROM TB_EEP_TG_LINK_R WHERE STATUS_CD = 'ON' AND CHAT_ID IS NOT NULL")) {
			if (systemService.isActiveAdmin((String) u.get("EMPLY_ID"))) out.add(u);
		}
		return out;
	}

	// ── 일정 읽기(홈 달력과 같은 조건) ──

	static final class Ev {
		final String kind, sq, title, extra, url, owner;
		final LocalDateTime at;

		Ev(String kind, String sq, LocalDateTime at, String title, String extra, String url, String owner) {
			this.kind = kind;
			this.sq = sq;
			this.at = at;
			this.title = title;
			this.extra = extra;
			this.url = url;
			this.owner = owner;
		}
	}

	/** 면접(취소 빼고, 시간 있는 것)·모집 인터뷰(인터뷰확정·결과 제출·확인중, 일시 있는 것) */
	private List<Ev> shared(LocalDateTime from, LocalDateTime to) {
		List<Ev> out = new ArrayList<>();
		for (Map<String, Object> r : jdbc.queryForList("SELECT INTV_SQ, HIRE_CD, APLY_NM, DATE_FORMAT(INTV_DT, '%Y-%m-%d') D, INTV_TM FROM TB_EEP_HR_INTV_M"
				+ " WHERE INTV_DT BETWEEN ? AND ? AND INTV_TM IS NOT NULL AND IFNULL(ATTEND_ST, '') <> 'CANCEL'", from.toLocalDate().toString(), to.toLocalDate().toString())) {
			String tm = String.valueOf(r.get("INTV_TM"));
			if (!tm.matches("\\d{2}:\\d{2}")) continue;
			LocalDateTime at = LocalDateTime.parse(r.get("D") + " " + tm, AT);
			if (at.isBefore(from) || at.isAfter(to)) continue;
			out.add(new Ev("EXP".equals(r.get("HIRE_CD")) ? "INTV_EXP" : "INTV_NEW", String.valueOf(r.get("INTV_SQ")), at, String.valueOf(r.get("APLY_NM")), null,
					"/admin/hr/openInterviewList.do?INTV_SQ=" + r.get("INTV_SQ"), null));
		}
		for (Map<String, Object> r : jdbc.queryForList("SELECT A.APPLY_SQ, A.RECRUIT_SQ, DATE_FORMAT(A.INTV_DT, '%Y-%m-%d %H:%i') AT, A.INTV_PLACE, S.STAFF_NM, R.CLIENT_NM"
				+ " FROM TB_EEP_RECRUIT_APPLY_R A JOIN TB_EEP_RECRUIT_M R ON R.RECRUIT_SQ = A.RECRUIT_SQ AND R.DEL_YN = 'N' JOIN TB_EEP_HR_STAFF_M S ON S.STAFF_SQ = A.STAFF_SQ"
				+ " WHERE A.STEP_CD IN ('INTV', 'INTV_SUB', 'INTV_CHK') AND A.INTV_DT BETWEEN ? AND ?", from.format(AT), to.format(AT))) { // 홈 달력과 같은 단계
			Object place = r.get("INTV_PLACE");
			out.add(new Ev("RC_INTV", String.valueOf(r.get("APPLY_SQ")), LocalDateTime.parse((String) r.get("AT"), AT),
					r.get("STAFF_NM") + (r.get("CLIENT_NM") == null ? "" : " · " + r.get("CLIENT_NM")), place == null || "".equals(place) ? null : "장소: " + place,
					"/admin/recruit/openRecruitList.do?open=" + r.get("RECRUIT_SQ"), null));
		}
		return out;
	}

	/** 시간 있는 내 할 일. 반복은 from~to 날짜의 회차로 펼친다(완료·빠진 회차 제외) */
	private List<Ev> myTasks(LocalDateTime from, LocalDateTime to) {
		List<Ev> out = new ArrayList<>();
		String d0 = from.toLocalDate().toString(), d1 = to.toLocalDate().toString();
		for (Map<String, Object> t : jdbc.queryForList("SELECT TASK_SQ, EMPLY_ID, TITLE, DATE_FORMAT(START_DT, '%Y-%m-%d') START_DT, START_TM, RPT_CD, RPT_DOW,"
				+ " DATE_FORMAT(RPT_UNTIL, '%Y-%m-%d') RPT_UNTIL, DONE_DTS, SKIP_DTS FROM TB_EEP_MY_TASK_R"
				+ " WHERE ALL_DAY = 'N' AND START_TM IS NOT NULL AND START_DT <= ? AND (START_DT >= ? OR (RPT_CD <> 'NONE' AND (RPT_UNTIL IS NULL OR RPT_UNTIL >= ?)))", d1, d0, d0)) {
			for (LocalDate d = from.toLocalDate(); !d.isAfter(to.toLocalDate()); d = d.plusDays(1)) {
				if (!occurs(t, d)) continue;
				LocalDateTime at = LocalDateTime.parse(d + " " + t.get("START_TM"), AT);
				if (at.isBefore(from) || at.isAfter(to)) continue;
				out.add(new Ev("MY", String.valueOf(t.get("TASK_SQ")), at, String.valueOf(t.get("TITLE")), null, "/admin/home.do", (String) t.get("EMPLY_ID")));
			}
		}
		return out;
	}

	/** 그 날짜가 할 일의 회차 시작일인가(홈 달력 펼치기와 같은 규칙: DAY·WEEK(RPT_DOW 0=일)·MONTH(같은 날)) */
	static boolean occurs(Map<String, Object> t, LocalDate d) {
		LocalDate start = LocalDate.parse((String) t.get("START_DT"));
		String rpt = t.get("RPT_CD") == null ? "NONE" : (String) t.get("RPT_CD"), until = (String) t.get("RPT_UNTIL");
		if (d.isBefore(start) || (until != null && d.isAfter(LocalDate.parse(until)))) return false;
		if (set(t.get("SKIP_DTS")).contains(d.toString()) || set(t.get("DONE_DTS")).contains(d.toString())) return false;
		switch (rpt) {
		case "DAY":
			return true;
		case "WEEK":
			String dow = t.get("RPT_DOW") == null ? "" : (String) t.get("RPT_DOW");
			return dow.indexOf((char) ('0' + d.getDayOfWeek().getValue() % 7)) >= 0;
		case "MONTH":
			return d.getDayOfMonth() == start.getDayOfMonth();
		default:
			return d.equals(start);
		}
	}

	static String beforeText(Ev ev, LocalDateTime now) {
		long min = ChronoUnit.MINUTES.between(now, ev.at);
		return "🔔 " + when(ev.at, now) + " " + KINDS.get(ev.kind) + " " + ev.title + " (" + min + "분 후)" + (ev.extra == null ? "" : "\n" + ev.extra);
	}

	/** 오늘이면 시각만, 아니면 「11/21(금) 14:00」 */
	static String when(LocalDateTime at, LocalDateTime now) {
		String hm = at.format(DateTimeFormatter.ofPattern("HH:mm"));
		if (at.toLocalDate().equals(now.toLocalDate())) return hm;
		return at.getMonthValue() + "/" + at.getDayOfMonth() + "(" + "월화수목금토일".charAt(at.getDayOfWeek().getValue() - 1) + ") " + hm;
	}

	// ── 텔레그램 호출·설정값 ──

	static final class TgError extends RuntimeException {
		final int status;

		TgError(int status, String msg) {
			super(msg);
			this.status = status;
		}
	}

	/** 토큰이 주소에 들어가므로 오류 메시지에 주소를 남기지 않는다 */
	private Map<String, Object> call(String token, String method, Map<String, Object> body) {
		HttpHeaders h = new HttpHeaders();
		h.setContentType(new MediaType("application", "json", java.nio.charset.StandardCharsets.UTF_8));
		try {
			String res = rest.postForObject("https://api.telegram.org/bot" + token + "/" + method, new HttpEntity<>(om.writeValueAsString(body), h), String.class);
			@SuppressWarnings("unchecked")
			Map<String, Object> m = om.readValue(res, Map.class);
			return m;
		} catch (HttpStatusCodeException e) {
			String desc = e.getResponseBodyAsString();
			try {
				Object d = om.readValue(desc, Map.class).get("description");
				desc = d == null ? "" : String.valueOf(d);
			} catch (Exception ignore) {
				desc = "";
			}
			throw new TgError(e.getStatusCode().value(), e.getStatusCode().value() + " " + desc.replace(token, "***"));
		} catch (java.io.IOException e) {
			throw new TgError(0, "JSON " + e.getClass().getSimpleName());
		} catch (RuntimeException e) {
			throw new TgError(0, e.getClass().getSimpleName());
		}
	}

	private String token() {
		String v = conf(CONF_TOKEN);
		if (v == null) return null;
		try {
			return RrnCipher.decrypt(v);
		} catch (RuntimeException e) {
			System.out.println("TG_TOKEN_ERROR " + e.getClass().getSimpleName());
			return null;
		}
	}

	private String conf(String key) {
		List<String> r = jdbc.queryForList("SELECT CONF_VAL FROM TB_EEP_CAL_CONF_M WHERE CONF_KEY = ?", String.class, key);
		return r.isEmpty() || r.get(0) == null || r.get(0).isEmpty() ? null : r.get(0);
	}

	private void saveConf(String key, String val) {
		jdbc.update("INSERT INTO TB_EEP_CAL_CONF_M (CONF_KEY, CONF_VAL, UPDT_DT) VALUES (?, ?, NOW()) ON DUPLICATE KEY UPDATE CONF_VAL = VALUES(CONF_VAL), UPDT_DT = NOW()", key, val);
	}

	static Set<String> set(Object csv) {
		Set<String> s = new LinkedHashSet<>();
		if (csv != null) for (String x : String.valueOf(csv).split(",")) if (!x.trim().isEmpty()) s.add(x.trim());
		return s;
	}

	private static String pick(String csv, Set<String> allowed) {
		Set<String> s = set(csv);
		s.retainAll(allowed);
		return s.isEmpty() ? null : String.join(",", s);
	}

	private static String cut(String s, int n) {
		return s == null || s.length() <= n ? s : s.substring(0, n);
	}
}
