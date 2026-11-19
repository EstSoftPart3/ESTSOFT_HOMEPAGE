package com.eep.bo.staff.service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.eep.mapper.BoStaffMapper;

import common.util.RrnCipher;

/**
 * 직원 수행이력(프로젝트 이력). 인사카드 수행이력 탭과 투입현황 프로젝트 이력이 같이 쓴다.
 * 고친 내용은 바로 저장되는 '작업 중' 이고, 「새 버전으로 저장」을 누를 때만 버전(전체 스냅샷)이 생긴다. 최신 버전과 같으면 버전을 만들지 않는다.
 * 사내 투입(TB_EEP_DEPLOY_R)은 자동으로 한 줄이 되고, 그 줄에 보탠 개발환경은 DEPLOY_SQ 가 붙은 수행이력 줄에 둔다.
 * 표 칸이 스냅샷·복원에서 동적으로 쓰여 매퍼 XML 대신 JdbcTemplate 으로 둔다.
 */
@Service
public class StaffCareerService {

	/** 화면·스냅샷·워드가 같이 쓰는 칸 순서 */
	public static final String[] COLS = { "PRJ_NM", "CLIENT_NM", "COMPANY_NM", "WORK_NM", "WORK_AREA", "ROLE_NM", "START_YM", "END_YM", "IND_NM", "APP_NM",
			"MACHINE_NM", "OS_NM", "LANG_NM", "DBMS_NM", "TOOL_NM", "FRAMEWORK_NM", "ETC_NM" };
	/** 쉼표로 여러 값을 담는 칸(칩으로 고른다) */
	public static final List<String> MULTI = Arrays.asList("ROLE_NM", "IND_NM", "APP_NM", "MACHINE_NM", "OS_NM", "LANG_NM", "DBMS_NM", "TOOL_NM", "FRAMEWORK_NM", "ETC_NM");
	private static final Map<String, String> LABEL = new LinkedHashMap<>();
	static {
		String[][] l = { { "PRJ_NM", "프로젝트명" }, { "CLIENT_NM", "고객사" }, { "COMPANY_NM", "근무회사" }, { "WORK_NM", "업무단" }, { "WORK_AREA", "근무지" }, { "ROLE_NM", "역할" },
				{ "START_YM", "시작월" }, { "END_YM", "종료월" }, { "IND_NM", "산업" }, { "APP_NM", "응용" }, { "MACHINE_NM", "기종" }, { "OS_NM", "O.S" }, { "LANG_NM", "언어" },
				{ "DBMS_NM", "DBMS" }, { "TOOL_NM", "TOOL" }, { "FRAMEWORK_NM", "FRAMEWORK" }, { "ETC_NM", "기타" } };
		for (String[] x : l) LABEL.put(x[0], x[1]);
	}
	private static final List<String> DEFAULT_ROLES = Arrays.asList("PM", "PL", "분석", "설계", "개발", "운영");
	private static final String YM = "\\d{4}-(0[1-9]|1[0-2])";
	private static final ObjectMapper JSON = new ObjectMapper();
	private static final String SELECT_COLS = String.join(", ", COLS);

	private JdbcTemplate jdbc;
	private TransactionTemplate tx;
	@Autowired
	private BoStaffMapper staffMapper;

	@Autowired
	public void setDataSource(@Qualifier("dataSource") DataSource ds) { // dataSourceSpied 와 2개라 이름을 지정해야 기동된다
		jdbc = new JdbcTemplate(ds);
		tx = new TransactionTemplate(new DataSourceTransactionManager(ds));
	}

	/** 버전 구분(순정 ORIG·가필 EDIT)과 가필의 기준 순정 버전·자동생성 설정 칸. 기존 버전은 모두 순정 */
	@javax.annotation.PostConstruct
	public void ensureSchema() {
		try {
			jdbc.execute("ALTER TABLE TB_EEP_HR_STAFF_PRJ_VER_H ADD COLUMN IF NOT EXISTS VER_KIND VARCHAR(10) NOT NULL DEFAULT 'ORIG' COMMENT '순정 ORIG, 가필 EDIT',"
					+ " ADD COLUMN IF NOT EXISTS BASE_VER INT NULL COMMENT '가필의 기준 순정 버전', ADD COLUMN IF NOT EXISTS GEN_CONF TEXT NULL COMMENT '프로필 자동생성 설정 JSON'");
		} catch (RuntimeException e) {
			System.out.println("STAFF_CAREER_SCHEMA_ERROR " + e.getClass().getSimpleName());
		}
	}

	// ── 조회 ──

	/** 지금(작업 중) 수행이력. 직접 입력한 줄 + 사내 투입에서 온 줄, 진행중 먼저·최근순 */
	public List<Map<String, Object>> items(Object staffSq) {
		List<Map<String, Object>> prjs = jdbc.queryForList("SELECT PRJ_SQ, DEPLOY_SQ, " + SELECT_COLS + " FROM TB_EEP_HR_STAFF_PRJ_R WHERE STAFF_SQ = ? ORDER BY PRJ_SQ", staffSq);
		List<Map<String, Object>> deps = jdbc.queryForList("SELECT DEPLOY_SQ, CLIENT_NM, PRJ_NM, WORK_AREA, DATE_FORMAT(START_DT, '%Y-%m-%d') AS START_DT, DATE_FORMAT(END_DT, '%Y-%m-%d') AS END_DT"
				+ " FROM TB_EEP_DEPLOY_R WHERE STAFF_SQ = ? AND START_DT IS NOT NULL ORDER BY START_DT, DEPLOY_SQ", staffSq);
		return merge(prjs, mergeDeploys(deps));
	}

	/** 같은 고객사·프로젝트에서 기간이 겹치거나 바로 이어지는 투입 건(수습→정규, 정규+외부 계약)은 한 프로젝트로 묶는다. SQS 는 묶인 투입 번호 */
	static List<Map<String, Object>> mergeDeploys(List<Map<String, Object>> deps) {
		List<Map<String, Object>> out = new ArrayList<>();
		for (Map<String, Object> d : deps) {
			String key = s(d.get("CLIENT_NM")) + "|" + s(d.get("PRJ_NM")), start = s(d.get("START_DT")), end = s(d.get("END_DT"));
			Map<String, Object> g = null;
			for (Map<String, Object> o : out) {
				String oe = s(o.get("END_DT"));
				if (key.equals(o.get("_KEY")) && (oe.isEmpty() || !LocalDate.parse(start).isAfter(LocalDate.parse(oe).plusDays(1)))) g = o;
			}
			if (g == null) {
				g = new HashMap<>(d);
				g.put("_KEY", key);
				g.put("SQS", new ArrayList<>(Collections.singletonList(s(d.get("DEPLOY_SQ")))));
				out.add(g);
				continue;
			}
			@SuppressWarnings("unchecked")
			List<String> sqs = (List<String>) g.get("SQS");
			sqs.add(s(d.get("DEPLOY_SQ")));
			String ge = s(g.get("END_DT"));
			g.put("END_DT", ge.isEmpty() || end.isEmpty() ? null : end.compareTo(ge) > 0 ? end : ge);
			if (s(g.get("WORK_AREA")).isEmpty()) g.put("WORK_AREA", d.get("WORK_AREA"));
		}
		return out;
	}

	/** 투입 묶음마다 한 줄. 그 묶음에 보탠 줄(DEPLOY_SQ)이 있으면 개발환경 등은 그 줄에서, 이름·고객사·기간은 투입현황에서 가져온다 */
	static List<Map<String, Object>> merge(List<Map<String, Object>> prjs, List<Map<String, Object>> groups) {
		List<Map<String, Object>> out = new ArrayList<>();
		Set<Object> used = new LinkedHashSet<>();
		for (Map<String, Object> g : groups) {
			@SuppressWarnings("unchecked")
			List<String> sqs = (List<String>) g.get("SQS");
			Map<String, Object> it = new LinkedHashMap<>();
			Map<String, Object> linked = null;
			for (Map<String, Object> p : prjs) if (linked == null && !s(p.get("DEPLOY_SQ")).isEmpty() && sqs.contains(s(p.get("DEPLOY_SQ")))) linked = p;
			if (linked != null) {
				it.putAll(linked);
				used.add(linked.get("PRJ_SQ"));
			}
			it.put("SRC", "DEPLOY");
			it.put("DEPLOY_SQ", sqs.get(0));
			it.put("PRJ_NM", g.get("PRJ_NM"));
			it.put("CLIENT_NM", g.get("CLIENT_NM"));
			if (s(it.get("WORK_AREA")).isEmpty()) it.put("WORK_AREA", g.get("WORK_AREA"));
			it.put("START_YM", s(g.get("START_DT")).substring(0, 7));
			it.put("END_YM", s(g.get("END_DT")).isEmpty() ? null : s(g.get("END_DT")).substring(0, 7));
			out.add(it);
		}
		for (Map<String, Object> p : prjs) {
			if (used.contains(p.get("PRJ_SQ"))) continue;
			Map<String, Object> it = new LinkedHashMap<>(p);
			it.put("SRC", "PRJ");
			it.put("DEPLOY_SQ", null); // 투입 건이 지워졌으면 직접 입력한 줄로 본다
			out.add(it);
		}
		out.sort((a, b) -> {
			int open = Boolean.compare(s(b.get("END_YM")).isEmpty(), s(a.get("END_YM")).isEmpty());
			return open != 0 ? open : s(b.get("START_YM")).compareTo(s(a.get("START_YM")));
		});
		return out;
	}

	/** 인사카드 수행이력 탭 한 번에: 지금 내용, 최신 버전, 그 뒤 달라진 점, 최근 변경, 자주 쓰는 칩 */
	public Map<String, Object> state(Object staffSq) {
		List<Map<String, Object>> items = items(staffSq);
		Map<String, Object> out = new HashMap<>();
		out.put("items", items);
		Map<String, Object> ver = latest(staffSq);
		if (ver != null) {
			String snap = (String) ver.remove("SNAPSHOT");
			out.put("dirty", diff(parse(snap), items)); // 같으면 null
		} else {
			out.put("dirty", items.isEmpty() ? null : diff(Collections.<Map<String, Object>> emptyList(), items));
		}
		out.put("ver", ver);
		Map<String, Object> edit = latest(staffSq, "EDIT");
		if (edit != null) edit.remove("SNAPSHOT");
		out.put("edit", edit);
		out.put("logs", jdbc.queryForList("SELECT ACT_CD, PRJ_NM, DETAIL, REG_EMPLY_ID, DATE_FORMAT(REG_DT, '%m-%d %H:%i') AS REG_DT FROM TB_EEP_HR_STAFF_PRJ_LOG_H WHERE STAFF_SQ = ? ORDER BY LOG_SQ DESC LIMIT 30", staffSq));
		out.put("chips", chips(staffSq));
		return out;
	}

	/** 칸마다 자주 쓰는 값. 이 사람이 쓴 것 먼저, 그다음 회사 전체에서 많이 쓴 순 */
	public Map<String, List<String>> chips(Object staffSq) {
		List<Map<String, Object>> all = jdbc.queryForList("SELECT STAFF_SQ, CLIENT_NM, COMPANY_NM, " + String.join(", ", MULTI) + " FROM TB_EEP_HR_STAFF_PRJ_R");
		Map<String, List<String>> out = new LinkedHashMap<>();
		List<String> cols = new ArrayList<>(MULTI);
		cols.add("CLIENT_NM");
		cols.add("COMPANY_NM");
		for (String col : cols) {
			Map<String, int[]> count = new LinkedHashMap<>(); // {회사 전체, 이 사람}
			if ("ROLE_NM".equals(col)) for (String r : DEFAULT_ROLES) count.put(r, new int[2]);
			for (Map<String, Object> row : all) {
				boolean mine = s(row.get("STAFF_SQ")).equals(s(staffSq));
				for (String t : new LinkedHashSet<>(tokens(s(row.get(col))))) {
					int[] c = count.computeIfAbsent(t, k -> new int[2]);
					c[0]++;
					if (mine) c[1]++;
				}
			}
			List<String> keys = new ArrayList<>(count.keySet());
			if (!"ROLE_NM".equals(col)) keys.sort((a, b) -> count.get(b)[1] != count.get(a)[1] ? count.get(b)[1] - count.get(a)[1] : count.get(b)[0] - count.get(a)[0]);
			out.put(col, keys.size() > 40 ? keys.subList(0, 40) : keys);
		}
		return out;
	}

	// ── 고치기 (작업 중 내용. 버전은 saveVersion 때만) ──

	public void save(Map<String, Object> p, String loginId) {
		Map<String, Object> row = clean(p);
		Object staffSq = p.get("STAFF_SQ");
		String prjSq = s(p.get("PRJ_SQ")), deploySq = s(p.get("DEPLOY_SQ"));
		tx.execute(st -> {
			if (prjSq.isEmpty()) {
				List<Object> args = new ArrayList<>(Arrays.asList(staffSq, deploySq.isEmpty() ? null : deploySq));
				for (String c : COLS) args.add(row.get(c));
				args.add(loginId);
				jdbc.update("INSERT INTO TB_EEP_HR_STAFF_PRJ_R (STAFF_SQ, DEPLOY_SQ, " + SELECT_COLS + ", REG_EMPLY_ID, REG_DT) VALUES (?, ?" + repeat(", ?", COLS.length) + ", ?, NOW())", args.toArray());
				log(staffSq, deploySq.isEmpty() ? "ADD" : "EDIT", s(row.get("PRJ_NM")), deploySq.isEmpty() ? period(row) : "개발환경 입력", loginId);
			} else {
				List<Map<String, Object>> before = jdbc.queryForList("SELECT " + SELECT_COLS + " FROM TB_EEP_HR_STAFF_PRJ_R WHERE PRJ_SQ = ? AND STAFF_SQ = ?", prjSq, staffSq);
				if (before.isEmpty()) throw new IllegalArgumentException("수행이력을 찾지 못했습니다.");
				List<Object> args = new ArrayList<>();
				StringBuilder set = new StringBuilder();
				for (String c : COLS) {
					set.append(c).append(" = ?, ");
					args.add(row.get(c));
				}
				args.addAll(Arrays.asList(loginId, prjSq, staffSq));
				jdbc.update("UPDATE TB_EEP_HR_STAFF_PRJ_R SET " + set + "UPDT_EMPLY_ID = ?, UPDT_DT = NOW() WHERE PRJ_SQ = ? AND STAFF_SQ = ?", args.toArray());
				String changed = changes(before.get(0), row);
				if (!changed.isEmpty()) log(staffSq, "EDIT", s(row.get("PRJ_NM")), changed, loginId);
			}
			return null;
		});
	}

	public void delete(Object staffSq, List<String> prjSqs, String loginId) {
		tx.execute(st -> {
			for (String sq : prjSqs) {
				List<Map<String, Object>> b = jdbc.queryForList("SELECT " + SELECT_COLS + " FROM TB_EEP_HR_STAFF_PRJ_R WHERE PRJ_SQ = ? AND STAFF_SQ = ?", sq, staffSq);
				if (b.isEmpty()) continue;
				jdbc.update("DELETE FROM TB_EEP_HR_STAFF_PRJ_R WHERE PRJ_SQ = ? AND STAFF_SQ = ?", sq, staffSq);
				log(staffSq, "DEL", s(b.get(0).get("PRJ_NM")), period(b.get(0)), loginId);
			}
			return null;
		});
	}

	/** 고른 줄들의 한 칸에 값을 한 번에 보탠다(이미 있는 값은 건너뜀) */
	public void bulkAdd(Object staffSq, List<String> prjSqs, String field, String values, String loginId) {
		if (!MULTI.contains(field)) throw new IllegalArgumentException("한 번에 넣을 수 없는 항목입니다.");
		List<String> add = tokens(values);
		if (add.isEmpty() || prjSqs.isEmpty()) throw new IllegalArgumentException("넣을 값과 줄을 골라 주세요.");
		tx.execute(st -> {
			for (String sq : prjSqs) {
				List<Map<String, Object>> b = jdbc.queryForList("SELECT PRJ_NM, " + field + " FROM TB_EEP_HR_STAFF_PRJ_R WHERE PRJ_SQ = ? AND STAFF_SQ = ?", sq, staffSq);
				if (b.isEmpty()) continue;
				Set<String> now = new LinkedHashSet<>(tokens(s(b.get(0).get(field))));
				if (!now.addAll(add)) continue;
				jdbc.update("UPDATE TB_EEP_HR_STAFF_PRJ_R SET " + field + " = ?, UPDT_EMPLY_ID = ?, UPDT_DT = NOW() WHERE PRJ_SQ = ? AND STAFF_SQ = ?", String.join(", ", now), loginId, sq, staffSq);
				log(staffSq, "EDIT", s(b.get(0).get("PRJ_NM")), LABEL.get(field) + " +" + String.join(", +", add), loginId);
			}
			return null;
		});
	}

	// ── 버전 ──

	/** 최신 순정 버전과 다를 때만 새 순정 버전을 만든다. @return 새 버전 번호 */
	public int saveVersion(Object staffSq, String loginId) {
		return tx.execute(st -> {
			List<Map<String, Object>> items = items(staffSq);
			Map<String, Object> last = latest(staffSq);
			String summary = diff(last == null ? Collections.<Map<String, Object>> emptyList() : parse((String) last.get("SNAPSHOT")), items);
			if (summary == null) throw new IllegalArgumentException("바뀐 내용이 없습니다. 최신 버전과 같아 버전을 올리지 않았습니다.");
			int no = nextNo(staffSq);
			jdbc.update("INSERT INTO TB_EEP_HR_STAFF_PRJ_VER_H (STAFF_SQ, VER_NO, VER_KIND, SNAPSHOT, SUMMARY, PRJ_CNT, REG_EMPLY_ID, REG_DT) VALUES (?, ?, 'ORIG', ?, ?, ?, ?, NOW())",
					staffSq, no, json(snapshot(items)), cut(summary, 500), items.size(), loginId);
			log(staffSq, "VERSION", null, "v" + no + " 저장 · " + summary, loginId);
			return no;
		});
	}

	public List<Map<String, Object>> versions(Object staffSq) {
		return jdbc.queryForList("SELECT VER_NO, VER_KIND, BASE_VER, SUMMARY, PRJ_CNT, REG_EMPLY_ID, DATE_FORMAT(REG_DT, '%Y-%m-%d %H:%i') AS REG_DT FROM TB_EEP_HR_STAFF_PRJ_VER_H WHERE STAFF_SQ = ? ORDER BY VER_NO DESC", staffSq);
	}

	/** 그 버전의 수행이력. verNo 가 비면 최신 순정 버전(버전이 없으면 지금 내용), EDIT 면 최신 가필 버전 */
	public List<Map<String, Object>> versionItems(Object staffSq, String verNo) {
		if ("EDIT".equals(verNo)) {
			Map<String, Object> e = latest(staffSq, "EDIT");
			if (e == null) throw new IllegalArgumentException("가필 버전이 없습니다. ✨ 프로필 자동생성에서 만들어 주세요.");
			return parse((String) e.get("SNAPSHOT"));
		}
		if (verNo == null || verNo.isEmpty()) {
			Map<String, Object> o = latest(staffSq);
			return o == null ? items(staffSq) : parse((String) o.get("SNAPSHOT"));
		}
		List<Map<String, Object>> v = jdbc.queryForList("SELECT SNAPSHOT FROM TB_EEP_HR_STAFF_PRJ_VER_H WHERE STAFF_SQ = ? AND VER_NO = ?", staffSq, verNo);
		if (v.isEmpty()) throw new IllegalArgumentException("버전을 찾지 못했습니다.");
		return parse((String) v.get(0).get("SNAPSHOT"));
	}

	// ── 프로필 자동생성(가필) ──

	/**
	 * 최신 순정 버전(없으면 지금 내용)에서 실제 있는 프로젝트만 골라 순서·기술 표시만 바꾼다. 없는 프로젝트·기간은 만들지 않는다.
	 * conf: skills[] 필수 기술, months(0 전체) 최근 N개월 안에 끝났거나 진행중(옛 설정 years 도 읽음), max(0 전체), sort match|recent,
	 * inds[]·roles[] 산업·역할 중 하나라도 맞는 것만(비면 전체), photo 워드에 증명사진. 옛 설정의 deploy·ext 포함 범위, show front|only 도 그대로 읽는다
	 */
	public List<Map<String, Object>> generate(Object staffSq, Map<String, Object> conf) {
		List<String> skills = strs(conf.get("skills")), inds = strs(conf.get("inds")), roles = strs(conf.get("roles"));
		int months = conf.containsKey("months") ? num(conf.get("months")) : num(conf.get("years")) * 12, max = num(conf.get("max"));
		boolean deploy = !Boolean.FALSE.equals(conf.get("deploy")), ext = !Boolean.FALSE.equals(conf.get("ext")), only = "only".equals(conf.get("show"));
		String cutYm = months > 0 ? LocalDate.now().minusMonths(months).toString().substring(0, 7) : "";
		List<Map<String, Object>> out = new ArrayList<>();
		for (Map<String, Object> it : versionItems(staffSq, "")) {
			boolean isDeploy = "DEPLOY".equals(it.get("SRC"));
			if (isDeploy ? !deploy : !ext) continue;
			String end = s(it.get("END_YM"));
			if (!cutYm.isEmpty() && !end.isEmpty() && end.compareTo(cutYm) < 0) continue;
			if (!inds.isEmpty() && Collections.disjoint(inds, tokens(s(it.get("IND_NM"))))) continue;
			if (!roles.isEmpty() && Collections.disjoint(roles, tokens(s(it.get("ROLE_NM"))))) continue;
			Map<String, Object> m = new LinkedHashMap<>(it);
			int hit = 0;
			for (String c : TECH) {
				List<String> on = new ArrayList<>(), off = new ArrayList<>();
				for (String t : tokens(s(it.get(c)))) (skills.contains(t) ? on : off).add(t);
				hit += on.size();
				if (!skills.isEmpty()) {
					if (!only) on.addAll(off);
					m.put(c, String.join(", ", on));
				}
			}
			m.put("MATCH", hit);
			out.add(m);
		}
		// 정렬은 안정 정렬이라 같은 일치 수 안에서는 원래 순서(진행중 먼저·최근순)를 지킨다
		if ("match".equals(conf.get("sort"))) out.sort((a, b) -> num(b.get("MATCH")) - num(a.get("MATCH")));
		return max > 0 && out.size() > max ? new ArrayList<>(out.subList(0, max)) : out;
	}

	/** 자동생성 결과를 가필 버전으로 남긴다(순정은 그대로). @return 새 버전 번호 */
	public int saveGenerated(Object staffSq, String confJson, String loginId) {
		Map<String, Object> conf = parseMap(confJson);
		return tx.execute(st -> {
			List<Map<String, Object>> items = generate(staffSq, conf);
			if (items.isEmpty()) throw new IllegalArgumentException("조건에 맞는 프로젝트가 없습니다. 기간을 늘리거나 산업·역할 선택을 줄여 주세요.");
			Map<String, Object> base = latest(staffSq);
			Object baseNo = base == null ? null : base.get("VER_NO");
			String d = diff(base == null ? items(staffSq) : parse((String) base.get("SNAPSHOT")), items);
			String summary = (baseNo == null ? "작업 중 내용" : "v" + baseNo) + " 기준 자동생성 · " + (d == null ? "순서만 바꿈" : d);
			int no = nextNo(staffSq);
			jdbc.update("INSERT INTO TB_EEP_HR_STAFF_PRJ_VER_H (STAFF_SQ, VER_NO, VER_KIND, BASE_VER, GEN_CONF, SNAPSHOT, SUMMARY, PRJ_CNT, REG_EMPLY_ID, REG_DT) VALUES (?, ?, 'EDIT', ?, ?, ?, ?, ?, ?, NOW())",
					staffSq, no, baseNo, confJson, json(snapshot(items)), cut(summary, 500), items.size(), loginId);
			log(staffSq, "VERSION", null, "v" + no + " 가필 저장 · " + summary, loginId);
			return no;
		});
	}

	/** 자동생성 결과로 바로 워드 */
	public byte[] generatedWord(Object staffSq, String confJson, Object[] photo) {
		List<Map<String, Object>> items = generate(staffSq, parseMap(confJson));
		if (items.isEmpty()) throw new IllegalArgumentException("조건에 맞는 프로젝트가 없습니다.");
		return word(staffSq, items, photo);
	}

	/** 워드에 증명사진을 넣는지: 자동생성 설정(gen) 또는 그 가필 버전을 만들 때 고른 설정의 photo */
	public boolean wantsPhoto(Object staffSq, String verNo, String gen) {
		if (gen != null && !gen.isEmpty()) return Boolean.TRUE.equals(parseMap(gen).get("photo"));
		Map<String, Object> v = null;
		if ("EDIT".equals(verNo)) v = latest(staffSq, "EDIT");
		else if (verNo != null && !verNo.isEmpty()) {
			List<Map<String, Object>> l = jdbc.queryForList("SELECT GEN_CONF FROM TB_EEP_HR_STAFF_PRJ_VER_H WHERE STAFF_SQ = ? AND VER_NO = ? AND VER_KIND = 'EDIT'", staffSq, verNo);
			v = l.isEmpty() ? null : l.get(0);
		}
		return v != null && v.get("GEN_CONF") != null && Boolean.TRUE.equals(parseMap((String) v.get("GEN_CONF")).get("photo"));
	}

	/** 작업 중 내용을 그 순정 버전으로 바꾼다. 사내 투입에서 온 줄의 이름·기간은 투입현황을 따르므로 직접 입력한 줄과 보탠 개발환경만 되돌린다 */
	public void restore(Object staffSq, String verNo, String loginId) {
		if (jdbc.queryForObject("SELECT COUNT(*) FROM TB_EEP_HR_STAFF_PRJ_VER_H WHERE STAFF_SQ = ? AND VER_NO = ? AND VER_KIND = 'EDIT'", Integer.class, staffSq, verNo) > 0) {
			throw new IllegalArgumentException("가필 버전은 제출용이라 작업 중 내용으로 되돌릴 수 없습니다. 순정 버전을 골라 주세요.");
		}
		List<Map<String, Object>> snap = versionItems(staffSq, verNo == null || verNo.isEmpty() ? "0" : verNo);
		tx.execute(st -> {
			jdbc.update("DELETE FROM TB_EEP_HR_STAFF_PRJ_R WHERE STAFF_SQ = ?", staffSq);
			for (Map<String, Object> it : snap) {
				boolean deploy = "DEPLOY".equals(it.get("SRC"));
				if (deploy && !Boolean.TRUE.equals(it.get("LINKED"))) continue;
				List<Object> args = new ArrayList<>(Arrays.asList(staffSq, deploy ? it.get("DEPLOY_SQ") : null));
				for (String c : COLS) args.add(blankToNull(s(it.get(c))));
				args.add(loginId);
				jdbc.update("INSERT INTO TB_EEP_HR_STAFF_PRJ_R (STAFF_SQ, DEPLOY_SQ, " + SELECT_COLS + ", REG_EMPLY_ID, REG_DT) VALUES (?, ?" + repeat(", ?", COLS.length) + ", ?, NOW())", args.toArray());
			}
			log(staffSq, "RESTORE", null, "v" + verNo + " 내용으로 되돌림", loginId);
			return null;
		});
	}

	// ── 워드 가져오기 ──

	/** 읽은 줄마다 STATE: NEW(추가)·DIFF(다름)·SAME(같음). 같은 프로젝트는 프로젝트명+시작월로 본다 */
	public List<Map<String, Object>> importPreview(Object staffSq, List<Map<String, Object>> rows) {
		Map<String, Map<String, Object>> now = byKey(items(staffSq));
		for (Map<String, Object> r : rows) {
			Map<String, Object> cur = now.get(key(r));
			String changed = cur == null ? "" : changes(cur, r, true);
			r.put("STATE", cur == null ? "NEW" : changed.isEmpty() ? "SAME" : "DIFF");
			r.put("CHANGED", changed);
		}
		return rows;
	}

	/** 고른 줄을 반영한다. 있는 프로젝트는 워드에 적힌 칸만 덮어쓴다. 처음 가져오는 것이면 바로 v1 로 남긴다 */
	public int importApply(Object staffSq, List<Map<String, Object>> rows, String fileName, String loginId) {
		if (rows.isEmpty()) throw new IllegalArgumentException("반영할 줄을 골라 주세요.");
		return tx.execute(st -> {
			boolean first = latest(staffSq) == null;
			Map<String, Map<String, Object>> now = byKey(items(staffSq));
			for (Map<String, Object> r : rows) {
				Map<String, Object> cur = now.get(key(r)), p = new HashMap<>();
				for (String c : COLS) {
					String v = s(r.get(c)).trim();
					p.put(c, v.isEmpty() && cur != null ? cur.get(c) : v);
				}
				p.put("STAFF_SQ", staffSq);
				if (s(p.get("END_YM")).isEmpty()) p.put("ONGOING_YN", "Y");
				if (cur != null) {
					p.put("PRJ_SQ", cur.get("PRJ_SQ"));
					if (s(cur.get("PRJ_SQ")).isEmpty()) p.put("DEPLOY_SQ", cur.get("DEPLOY_SQ")); // 사내 투입 줄이면 개발환경을 보탠다
				}
				saveQuiet(p, loginId);
			}
			log(staffSq, "IMPORT", null, "워드에서 " + rows.size() + "건 반영" + (fileName == null || fileName.isEmpty() ? "" : " (" + cut(fileName, 100) + ")"), loginId);
			if (first) saveVersion(staffSq, loginId);
			return rows.size();
		});
	}

	public void deleteAll(Object staffSq) {
		jdbc.update("DELETE FROM TB_EEP_HR_STAFF_PRJ_VER_H WHERE STAFF_SQ = ?", staffSq);
		jdbc.update("DELETE FROM TB_EEP_HR_STAFF_PRJ_LOG_H WHERE STAFF_SQ = ?", staffSq);
	}

	// ── 워드 만들기 ──

	/** 회사 양식 워드. verNo 가 비면 최신 버전(버전이 없으면 지금 내용). 주민번호는 가리고 전화·메일은 원본 양식처럼 넣지 않는다 */
	public byte[] word(Object staffSq, String verNo) {
		return word(staffSq, verNo, null);
	}

	public byte[] word(Object staffSq, String verNo, Object[] photo) {
		return word(staffSq, versionItems(staffSq, verNo), photo);
	}

	/** @param photo {확장자 jpeg|png, 바이트} 또는 null */
	private byte[] word(Object staffSq, List<Map<String, Object>> items, Object[] photo) {
		Map<String, Object> q = new HashMap<>();
		q.put("STAFF_SQ", staffSq);
		Map<String, Object> st = staffMapper.selectStaffOne(q);
		if (st == null) throw new IllegalArgumentException("직원을 찾지 못했습니다.");
		List<Map<String, Object>> extra = staffMapper.selectStaffItemList(q);
		Map<String, String> info = new HashMap<>();
		info.put("성명", s(st.get("STAFF_NM")));
		info.put("주민번호", RrnCipher.maskStored((String) st.get("RRN_ENC")));
		info.put("소속회사", "이에스티소프트");
		info.put("부서", s(st.get("DEPT_NM")));
		info.put("직위", s(st.get("POSITION_NM")));
		info.put("기술등급", s(st.get("GRADE_NM")));
		info.put("주소", s(st.get("ADDR")));
		String mil = s(st.get("MIL_EXEMPT"));
		info.put("병역", !mil.isEmpty() ? "면제 (" + mil + ")" : s(st.get("MIL_OUT_DT")).isEmpty() ? "" : "군필 (" + s(st.get("MIL_IN_DT")) + " ~ " + s(st.get("MIL_OUT_DT")) + ")");
		info.put("언어", skills(items, "LANG_NM"));
		info.put("DBMS", skills(items, "DBMS_NM"));
		info.put("TOOL", skills(items, "TOOL_NM"));
		List<String[]> schools = new ArrayList<>(), careers = new ArrayList<>(), trainings = new ArrayList<>();
		for (String p : new String[] { "UNIV", "HS" }) if (!s(st.get(p + "_NM")).isEmpty()) schools.add(new String[] { s(st.get(p + "_NM")), s(st.get(p + "_MAJOR")), s(st.get(p + "_GRAD")), "" });
		if (!s(st.get("EDU_NM")).isEmpty()) trainings.add(new String[] { s(st.get("EDU_NM")), s(st.get("EDU_START_DT")), s(st.get("EDU_END_DT")), s(st.get("EDU_ORG")) });
		for (Map<String, Object> e : extra) {
			if ("EDU".equals(e.get("ITEM_CD"))) schools.add(new String[] { s(e.get("C2")), s(e.get("C3")), s(e.get("C4")), "" });
			if ("TRAIN".equals(e.get("ITEM_CD"))) trainings.add(new String[] { s(e.get("C1")), s(e.get("C3")), s(e.get("C4")), s(e.get("C2")) });
		}
		if (!s(st.get("PREV_CAREER")).isEmpty()) careers.add(new String[] { s(st.get("PREV_CAREER")), "", "", "" });
		return StaffCareerWord.build(info, schools, careers, trainings, items, photo);
	}

	/** 내려받을 파일 이름: 성명_등급.docx */
	public String wordName(Object staffSq) {
		Map<String, Object> q = new HashMap<>();
		q.put("STAFF_SQ", staffSq);
		Map<String, Object> st = staffMapper.selectStaffOne(q);
		return s(st == null ? null : st.get("STAFF_NM")) + (st == null || s(st.get("GRADE_NM")).isEmpty() ? "" : "_" + s(st.get("GRADE_NM"))) + ".docx";
	}

	private static String skills(List<Map<String, Object>> items, String col) {
		Set<String> out = new LinkedHashSet<>();
		for (Map<String, Object> it : items) out.addAll(tokens(s(it.get(col))));
		return String.join(", ", out);
	}

	// ── 내부 ──

	/** save 와 같지만 건별 기록을 남기지 않는다(가져오기는 한 줄로 남김) */
	private void saveQuiet(Map<String, Object> p, String loginId) {
		Map<String, Object> row = clean(p);
		String prjSq = s(p.get("PRJ_SQ"));
		List<Object> args = new ArrayList<>();
		if (prjSq.isEmpty()) {
			args.addAll(Arrays.asList(p.get("STAFF_SQ"), blankToNull(s(p.get("DEPLOY_SQ")))));
			for (String c : COLS) args.add(row.get(c));
			args.add(loginId);
			jdbc.update("INSERT INTO TB_EEP_HR_STAFF_PRJ_R (STAFF_SQ, DEPLOY_SQ, " + SELECT_COLS + ", REG_EMPLY_ID, REG_DT) VALUES (?, ?" + repeat(", ?", COLS.length) + ", ?, NOW())", args.toArray());
			return;
		}
		StringBuilder set = new StringBuilder();
		for (String c : COLS) {
			set.append(c).append(" = ?, ");
			args.add(row.get(c));
		}
		args.addAll(Arrays.asList(loginId, prjSq, p.get("STAFF_SQ")));
		jdbc.update("UPDATE TB_EEP_HR_STAFF_PRJ_R SET " + set + "UPDT_EMPLY_ID = ?, UPDT_DT = NOW() WHERE PRJ_SQ = ? AND STAFF_SQ = ?", args.toArray());
	}

	/** 최신 순정 버전(작업 중 내용과 비교·새 버전 기준) */
	private Map<String, Object> latest(Object staffSq) {
		return latest(staffSq, "ORIG");
	}

	private Map<String, Object> latest(Object staffSq, String kind) {
		List<Map<String, Object>> v = jdbc.queryForList("SELECT VER_NO, BASE_VER, SNAPSHOT, PRJ_CNT, REG_EMPLY_ID, DATE_FORMAT(REG_DT, '%Y-%m-%d %H:%i') AS REG_DT FROM TB_EEP_HR_STAFF_PRJ_VER_H WHERE STAFF_SQ = ? AND VER_KIND = ? ORDER BY VER_NO DESC LIMIT 1", staffSq, kind);
		return v.isEmpty() ? null : v.get(0);
	}

	/** 버전 번호는 순정·가필이 같이 이어진다 */
	private int nextNo(Object staffSq) {
		Integer n = jdbc.queryForObject("SELECT MAX(VER_NO) FROM TB_EEP_HR_STAFF_PRJ_VER_H WHERE STAFF_SQ = ?", Integer.class, staffSq);
		return n == null ? 1 : n + 1;
	}

	/** 자동생성에서 고르는 기술 칸(개발환경) */
	static final String[] TECH = { "LANG_NM", "FRAMEWORK_NM", "DBMS_NM", "TOOL_NM", "OS_NM", "MACHINE_NM", "ETC_NM" };

	/** 설정 JSON 의 글자 목록(빈 값은 뺀다) */
	private static List<String> strs(Object o) {
		List<String> out = new ArrayList<>();
		if (o instanceof List) for (Object v : (List<?>) o) if (!s(v).trim().isEmpty()) out.add(s(v).trim());
		return out;
	}

	private static int num(Object o) {
		try {
			return o instanceof Number ? ((Number) o).intValue() : Integer.parseInt(s(o).trim());
		} catch (NumberFormatException e) {
			return 0;
		}
	}

	public static Map<String, Object> parseMap(String json) {
		try {
			return JSON.readValue(json == null || json.isEmpty() ? "{}" : json, new TypeReference<Map<String, Object>>() { });
		} catch (java.io.IOException e) {
			throw new IllegalArgumentException("자동생성 설정을 읽지 못했습니다.");
		}
	}

	private void log(Object staffSq, String act, String prjNm, String detail, String loginId) {
		jdbc.update("INSERT INTO TB_EEP_HR_STAFF_PRJ_LOG_H (STAFF_SQ, ACT_CD, PRJ_NM, DETAIL, REG_EMPLY_ID, REG_DT) VALUES (?, ?, ?, ?, ?, NOW())", staffSq, act, prjNm, cut(detail, 1000), loginId);
	}

	/** 입력값을 확인하고 저장할 모양으로 다듬는다. 여러 값 칸은 "a, b" 로 맞춘다 */
	static Map<String, Object> clean(Map<String, Object> p) {
		Map<String, Object> row = new LinkedHashMap<>();
		for (String c : COLS) {
			String v = s(p.get(c)).trim();
			row.put(c, blankToNull(MULTI.contains(c) ? String.join(", ", new LinkedHashSet<>(tokens(v))) : v));
		}
		if (row.get("PRJ_NM") == null) throw new IllegalArgumentException("프로젝트명을 입력해 주세요.");
		String start = s(row.get("START_YM")), end = s(row.get("END_YM"));
		if (!start.matches(YM)) throw new IllegalArgumentException("시작월을 골라 주세요.");
		if ("Y".equals(p.get("ONGOING_YN"))) {
			row.put("END_YM", null);
		} else {
			if (!end.matches(YM)) throw new IllegalArgumentException("종료월을 고르거나 진행중을 체크해 주세요.");
			if (end.compareTo(start) < 0) throw new IllegalArgumentException("종료월이 시작월보다 빠릅니다.");
		}
		return row;
	}

	/** 쉼표·줄바꿈으로 나눈 값. 빈 값은 뺀다 */
	public static List<String> tokens(String v) {
		List<String> out = new ArrayList<>();
		for (String t : s(v).split("[,\\n]")) if (!t.trim().isEmpty()) out.add(t.trim());
		return out;
	}

	/** 버전에 넣을 모양: 칸 값 + 출처. LINKED 는 사내 투입 줄에 보탠 줄이 있었는지(되돌릴 때 쓴다) */
	static List<Map<String, Object>> snapshot(List<Map<String, Object>> items) {
		List<Map<String, Object>> out = new ArrayList<>();
		for (Map<String, Object> it : items) {
			Map<String, Object> m = new LinkedHashMap<>();
			for (String c : COLS) m.put(c, s(it.get(c)));
			m.put("SRC", s(it.get("SRC")));
			m.put("DEPLOY_SQ", s(it.get("DEPLOY_SQ")));
			m.put("LINKED", "DEPLOY".equals(it.get("SRC")) && !s(it.get("PRJ_SQ")).isEmpty());
			out.add(m);
		}
		return out;
	}

	/** 두 수행이력이 같으면 null, 다르면 "추가 1 · 수정 2 · 삭제 1 (이름…)" */
	static String diff(List<Map<String, Object>> before, List<Map<String, Object>> after) {
		Map<String, Map<String, Object>> b = byKey(before), a = byKey(after);
		List<String> add = new ArrayList<>(), edit = new ArrayList<>(), del = new ArrayList<>();
		for (Map.Entry<String, Map<String, Object>> e : a.entrySet()) {
			Map<String, Object> old = b.get(e.getKey());
			if (old == null) add.add(s(e.getValue().get("PRJ_NM")));
			else if (!changes(old, e.getValue()).isEmpty()) edit.add(s(e.getValue().get("PRJ_NM")));
		}
		for (Map.Entry<String, Map<String, Object>> e : b.entrySet()) if (!a.containsKey(e.getKey())) del.add(s(e.getValue().get("PRJ_NM")));
		if (add.isEmpty() && edit.isEmpty() && del.isEmpty()) return null;
		List<String> parts = new ArrayList<>();
		if (!add.isEmpty()) parts.add("추가 " + add.size() + " (" + names(add) + ")");
		if (!edit.isEmpty()) parts.add("수정 " + edit.size() + " (" + names(edit) + ")");
		if (!del.isEmpty()) parts.add("삭제 " + del.size() + " (" + names(del) + ")");
		return String.join(" · ", parts);
	}

	private static String names(List<String> l) {
		return String.join(", ", l.subList(0, Math.min(3, l.size()))) + (l.size() > 3 ? " 외 " + (l.size() - 3) : "");
	}

	private static Map<String, Map<String, Object>> byKey(List<Map<String, Object>> items) {
		Map<String, Map<String, Object>> m = new LinkedHashMap<>();
		for (Map<String, Object> it : items) m.put(key(it), it);
		return m;
	}

	private static String key(Map<String, Object> it) {
		return s(it.get("PRJ_NM")).replaceAll("\\s", "") + "|" + s(it.get("START_YM"));
	}

	static String changes(Map<String, Object> before, Map<String, Object> after) {
		return changes(before, after, false);
	}

	/** 달라진 칸을 "역할 개발 → PL, 개발 · TOOL +Nexacro" 처럼. onlyFilled 면 새 값이 빈 칸은 건너뛴다(워드에 없는 칸) */
	static String changes(Map<String, Object> before, Map<String, Object> after, boolean onlyFilled) {
		List<String> out = new ArrayList<>();
		for (String c : COLS) {
			String o = s(before.get(c)).trim(), n = s(after.get(c)).trim();
			if (onlyFilled && n.isEmpty()) continue;
			if (MULTI.contains(c)) {
				List<String> ot = tokens(o), nt = tokens(n), d = new ArrayList<>();
				for (String t : nt) if (!ot.contains(t)) d.add("+" + t);
				for (String t : ot) if (!nt.contains(t)) d.add("-" + t);
				if (!d.isEmpty()) out.add(LABEL.get(c) + " " + String.join(", ", d));
			} else if (!o.equals(n)) {
				out.add(LABEL.get(c) + " " + (o.isEmpty() ? "(빈칸)" : o) + " → " + (n.isEmpty() ? "(빈칸)" : n));
			}
		}
		return String.join(" · ", out);
	}

	private static String period(Map<String, Object> row) {
		return s(row.get("START_YM")) + " ~ " + (s(row.get("END_YM")).isEmpty() ? "진행중" : s(row.get("END_YM"))) + (s(row.get("CLIENT_NM")).isEmpty() ? "" : ", " + s(row.get("CLIENT_NM")));
	}

	public static List<Map<String, Object>> parse(String json) {
		try {
			return JSON.readValue(json, new TypeReference<List<Map<String, Object>>>() { });
		} catch (java.io.IOException e) {
			throw new IllegalStateException("버전 내용을 읽지 못했습니다", e);
		}
	}

	static String json(Object o) {
		try {
			return JSON.writeValueAsString(o);
		} catch (java.io.IOException e) {
			throw new IllegalStateException(e);
		}
	}

	private static String repeat(String s, int n) {
		StringBuilder b = new StringBuilder();
		for (int i = 0; i < n; i++) b.append(s);
		return b.toString();
	}

	private static String cut(String s, int n) {
		return s == null || s.length() <= n ? s : s.substring(0, n - 1) + "…";
	}

	private static String blankToNull(String v) {
		return v == null || v.trim().isEmpty() ? null : v.trim();
	}

	private static String s(Object o) {
		return o == null ? "" : o.toString();
	}
}
