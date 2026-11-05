package com.eep.bo.batch.dao;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.eep.mapper.BoBatchMapper;

@Repository
public class BoBatchDao {

	@Autowired
	BoBatchMapper BoBatchMapper;

	public Map<String, Object> IntvByGcalId(Map<String, Object> param) {
		return BoBatchMapper.selectIntvByGcalId(param);
	}

	public Map<String, Object> IntvToLink(Map<String, Object> param) {
		return BoBatchMapper.selectIntvToLink(param);
	}

	public int IntvInsert(Map<String, Object> param) {
		return BoBatchMapper.insertBatchIntv(param);
	}

	public int IntvUpdate(Map<String, Object> param) {
		return BoBatchMapper.updateBatchIntv(param);
	}

	public int LogInsert(Map<String, Object> param) {
		return BoBatchMapper.insertBatchLog(param);
	}

	public List<Map<String, Object>> LogList(Map<String, Object> param) {
		return BoBatchMapper.selectBatchLogList(param);
	}
}
