package com.eep.bo.calendar.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.eep.mapper.BoCalendarMapper;

@Repository
public class BoCalendarDao {

	@Autowired
	BoCalendarMapper BoCalendarMapper;

	//분류 규칙
	public List<Map<String, Object>> RuleList() {
		return BoCalendarMapper.selectRuleList();
	}

	//구글 OAuth 설정 (CONF_KEY -> CONF_VAL)
	public Map<String, String> ConfMap() {
		Map<String, String> result = new HashMap<>();
		for (Map<String, Object> row : BoCalendarMapper.selectConfList()) {
			result.put((String) row.get("CONF_KEY"), (String) row.get("CONF_VAL"));
		}
		return result;
	}

	public int ConfSave(String key, String val) {
		Map<String, Object> param = new HashMap<>();
		param.put("CONF_KEY", key);
		param.put("CONF_VAL", val);
		return BoCalendarMapper.upsertConf(param);
	}

	//임시 일정을 이번 조회 결과로 교체
	public void TmpReplace(String emplyId, List<Map<String, Object>> rows) {
		Map<String, Object> param = new HashMap<>();
		param.put("REG_EMPLY_ID", emplyId);
		BoCalendarMapper.deleteTmp(param);
		if (!rows.isEmpty()) {
			param.put("list", rows);
			BoCalendarMapper.insertTmpList(param);
		}
	}

	public List<Map<String, Object>> TmpList(String emplyId) {
		Map<String, Object> param = new HashMap<>();
		param.put("REG_EMPLY_ID", emplyId);
		return BoCalendarMapper.selectTmpList(param);
	}

	public int TmpCateUpdate(Map<String, Object> param) {
		return BoCalendarMapper.updateTmpCate(param);
	}

	public int TmpConfirm(String emplyId, List<Object> tmpSqList) {
		Map<String, Object> param = new HashMap<>();
		param.put("REG_EMPLY_ID", emplyId);
		param.put("list", tmpSqList);
		return BoCalendarMapper.confirmTmpList(param);
	}

	//확정 일정
	public List<Map<String, Object>> EvtList(Map<String, Object> param) {
		return BoCalendarMapper.selectEvtList(param);
	}

	public List<Map<String, Object>> EvtCateCount(Map<String, Object> param) {
		return BoCalendarMapper.selectEvtCateCount(param);
	}
}
