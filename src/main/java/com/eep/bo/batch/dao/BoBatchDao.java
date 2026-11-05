package com.eep.bo.batch.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.eep.mapper.BoBatchMapper;

@Repository
public class BoBatchDao {

	@Autowired
	BoBatchMapper BoBatchMapper;

	public void EnsureSchema() {
		BoBatchMapper.alterIntvForBatch();
		BoBatchMapper.createBatchLogTable();
		BoBatchMapper.alterBatchLogForIcal();
		BoBatchMapper.createBatchLogDetailTable();
		BoBatchMapper.createBatchIcalTable();
		// 설정 테이블에 한 건만 두던 주소를 목록으로 옮긴다
		if (BoBatchMapper.moveConfIcalToList() > 0) {
			BoBatchMapper.deleteConfIcal();
		}
	}

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

	//실행 이력과 일정별 처리 결과
	public void LogInsert(Map<String, Object> run, List<Map<String, Object>> details) {
		BoBatchMapper.insertBatchLog(run);
		if (!details.isEmpty()) {
			Map<String, Object> param = new HashMap<>();
			param.put("BATCH_LOG_SQ", run.get("BATCH_LOG_SQ"));
			param.put("list", details);
			BoBatchMapper.insertBatchLogDetail(param);
		}
	}

	public List<Map<String, Object>> LogList(Map<String, Object> param) {
		return BoBatchMapper.selectBatchLogList(param);
	}

	public List<Map<String, Object>> LogDetail(int logSq) {
		return BoBatchMapper.selectBatchLogDetail(sq("BATCH_LOG_SQ", logSq));
	}

	//iCal 주소
	public List<Map<String, Object>> IcalList() {
		return BoBatchMapper.selectIcalList();
	}

	public List<Map<String, Object>> IcalAutoList() {
		return BoBatchMapper.selectIcalAutoList();
	}

	public Map<String, Object> IcalOne(int icalSq) {
		return BoBatchMapper.selectIcalOne(sq("ICAL_SQ", icalSq));
	}

	public int IcalInsert(String name, String url) {
		Map<String, Object> param = new HashMap<>();
		param.put("ICAL_NM", name);
		param.put("ICAL_URL", url);
		return BoBatchMapper.insertIcal(param);
	}

	public int IcalDelete(int icalSq) {
		return BoBatchMapper.deleteIcal(sq("ICAL_SQ", icalSq));
	}

	public int IcalAutoUpdate(int icalSq, String autoYn) {
		Map<String, Object> param = sq("ICAL_SQ", icalSq);
		param.put("AUTO_YN", autoYn);
		return BoBatchMapper.updateIcalAuto(param);
	}

	private static Map<String, Object> sq(String key, int value) {
		Map<String, Object> param = new HashMap<>();
		param.put(key, value);
		return param;
	}
}
