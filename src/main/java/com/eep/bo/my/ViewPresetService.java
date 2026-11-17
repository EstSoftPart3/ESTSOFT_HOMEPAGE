package com.eep.bo.my;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;
import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

/**
 * 목록 화면 '보기' 저장(resources/common/bo-view.js). 계정·화면 주소마다 최대 5개, 설정(CONF)은 화면이 만든 JSON 을 그대로 둔다.
 * USED_DT 가 가장 최근인 보기가 다음 접속 때 자동으로 적용되고, 순정을 고르면 모두 비운다.
 */
@Service
public class ViewPresetService {

	static final int MAX = 5;

	private JdbcTemplate jdbc;

	@Autowired
	public void setDataSource(@Qualifier("dataSource") DataSource ds) { // dataSourceSpied 와 2개라 이름을 지정해야 기동된다
		jdbc = new JdbcTemplate(ds);
	}

	@PostConstruct
	public void ensureSchema() {
		try {
			jdbc.execute("CREATE TABLE IF NOT EXISTS TB_EEP_VIEW_PRESET_R (VW_SQ INT NOT NULL AUTO_INCREMENT PRIMARY KEY, EMPLY_ID VARCHAR(50) NOT NULL, PAGE VARCHAR(200) NOT NULL,"
					+ " NM VARCHAR(50) NOT NULL, CONF MEDIUMTEXT, USED_DT DATETIME NULL, REG_DT DATETIME NOT NULL, UPDT_DT DATETIME NULL, KEY IX_VIEW_PRESET (EMPLY_ID, PAGE))"
					+ " DEFAULT CHARSET=utf8mb4 COMMENT='목록 화면 보기 저장'");
		} catch (RuntimeException e) {
			System.out.println("VIEW_PRESET_SCHEMA_ERROR " + e.getClass().getSimpleName());
		}
	}

	/** { list: [{VW_SQ, NM, CONF}], last: 마지막에 쓴 VW_SQ(순정이면 null) } */
	public Map<String, Object> list(String user, String page) {
		page = page(page);
		Map<String, Object> out = new HashMap<>();
		out.put("list", jdbc.queryForList("SELECT VW_SQ, NM, CONF FROM TB_EEP_VIEW_PRESET_R WHERE EMPLY_ID = ? AND PAGE = ? ORDER BY REG_DT, VW_SQ", user, page));
		List<Map<String, Object>> last = jdbc.queryForList("SELECT VW_SQ FROM TB_EEP_VIEW_PRESET_R WHERE EMPLY_ID = ? AND PAGE = ? AND USED_DT IS NOT NULL ORDER BY USED_DT DESC, VW_SQ DESC LIMIT 1", user, page);
		out.put("last", last.isEmpty() ? null : last.get(0).get("VW_SQ"));
		return out;
	}

	/**
	 * vwSq 가 있으면 그 보기에 덮어쓰고, 없으면 새 이름으로 만든다. 5개가 차 있으면 drop 일 때만 가장 오래된 것을 지운다.
	 * @return 저장한 VW_SQ, 5개가 차서 못 만들면 null
	 */
	public Object save(String user, String page, String vwSq, String nm, String conf, boolean drop) {
		page = page(page);
		if (conf == null || conf.isEmpty() || conf.length() > 60000) throw new IllegalArgumentException("저장할 보기 내용이 올바르지 않습니다.");
		if (vwSq != null && !vwSq.isEmpty()) {
			if (jdbc.update("UPDATE TB_EEP_VIEW_PRESET_R SET CONF = ?, USED_DT = NOW(), UPDT_DT = NOW() WHERE VW_SQ = ? AND EMPLY_ID = ? AND PAGE = ?", conf, vwSq, user, page) == 0) {
				throw new IllegalArgumentException("보기를 찾지 못했습니다.");
			}
			return vwSq;
		}
		nm = nm == null ? "" : nm.trim();
		if (nm.isEmpty() || nm.length() > 30) throw new IllegalArgumentException("보기 이름을 1~30자로 입력해 주세요.");
		if (jdbc.queryForObject("SELECT COUNT(*) FROM TB_EEP_VIEW_PRESET_R WHERE EMPLY_ID = ? AND PAGE = ? AND NM = ?", Integer.class, user, page, nm) > 0) {
			throw new IllegalArgumentException("같은 이름의 보기가 있습니다. 덮어쓰려면 그 보기를 고른 뒤 저장해 주세요.");
		}
		List<Map<String, Object>> all = jdbc.queryForList("SELECT VW_SQ FROM TB_EEP_VIEW_PRESET_R WHERE EMPLY_ID = ? AND PAGE = ? ORDER BY REG_DT, VW_SQ", user, page);
		if (all.size() >= MAX) {
			if (!drop) return null;
			for (int i = 0; i <= all.size() - MAX; i++) jdbc.update("DELETE FROM TB_EEP_VIEW_PRESET_R WHERE VW_SQ = ?", all.get(i).get("VW_SQ"));
		}
		jdbc.update("UPDATE TB_EEP_VIEW_PRESET_R SET USED_DT = NULL WHERE EMPLY_ID = ? AND PAGE = ?", user, page);
		jdbc.update("INSERT INTO TB_EEP_VIEW_PRESET_R (EMPLY_ID, PAGE, NM, CONF, USED_DT, REG_DT) VALUES (?, ?, ?, ?, NOW(), NOW())", user, page, nm, conf);
		return jdbc.queryForObject("SELECT MAX(VW_SQ) FROM TB_EEP_VIEW_PRESET_R WHERE EMPLY_ID = ? AND PAGE = ? AND NM = ?", Object.class, user, page, nm);
	}

	/** 그 보기를 마지막에 쓴 것으로. vwSq 가 비면 순정(모두 비움) */
	public void use(String user, String page, String vwSq) {
		page = page(page);
		jdbc.update("UPDATE TB_EEP_VIEW_PRESET_R SET USED_DT = NULL WHERE EMPLY_ID = ? AND PAGE = ?", user, page);
		if (vwSq != null && !vwSq.isEmpty()) jdbc.update("UPDATE TB_EEP_VIEW_PRESET_R SET USED_DT = NOW() WHERE VW_SQ = ? AND EMPLY_ID = ? AND PAGE = ?", vwSq, user, page);
	}

	public void delete(String user, String page, String vwSq) {
		jdbc.update("DELETE FROM TB_EEP_VIEW_PRESET_R WHERE VW_SQ = ? AND EMPLY_ID = ? AND PAGE = ?", vwSq, user, page(page));
	}

	/** 관리자 화면 주소만 받는다 */
	static String page(String page) {
		if (page == null || !page.startsWith("/admin/") || page.length() > 200) throw new IllegalArgumentException("화면 주소가 올바르지 않습니다.");
		return page;
	}
}
