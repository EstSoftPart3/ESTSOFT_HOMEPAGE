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
		BoBatchMapper.alterBatchLogDetailForResume();
		BoBatchMapper.createBatchIcalTable();
		// 설정 테이블에 한 건만 두던 주소를 목록으로 옮긴다
		if (BoBatchMapper.moveConfIcalToList() > 0) {
			BoBatchMapper.deleteConfIcal();
		}
		BoBatchMapper.alterIcalForDrive();
		// 공통 설정에 잠시 두었던 이력서 폴더를 세트로 옮긴다
		if (BoBatchMapper.moveConfFolderToIcal() > 0) {
			BoBatchMapper.deleteConfFolder();
		}
	}

	public int IntvCountAt(String date, String time) {
		Map<String, Object> param = new HashMap<>();
		param.put("INTV_DT", date);
		param.put("INTV_TM", time);
		return BoBatchMapper.countIntvAt(param);
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

	public Map<String, Object> IntvResumeCheck(Map<String, Object> param) {
		return BoBatchMapper.selectIntvResumeCheck(param);
	}

	public int IntvFromResume(Map<String, Object> param) {
		return BoBatchMapper.updateIntvFromResume(param);
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

	public int IcalSave(Integer icalSq, String name, String url, String folderId) {
		Map<String, Object> param = new HashMap<>();
		param.put("ICAL_SQ", icalSq);
		param.put("ICAL_NM", name);
		param.put("ICAL_URL", url);
		param.put("DRIVE_FOLDER_ID", folderId);
		return icalSq == null ? BoBatchMapper.insertIcal(param) : BoBatchMapper.updateIcal(param);
	}

	public int IcalDrive(int icalSq, String token, String account) {
		Map<String, Object> param = sq("ICAL_SQ", icalSq);
		param.put("DRIVE_TOKEN", token);
		param.put("DRIVE_ACCOUNT", account);
		return BoBatchMapper.updateIcalDrive(param);
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
