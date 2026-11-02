package com.eep.bo.hr.dao;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.eep.mapper.BoHrMapper;

@Repository
public class BoHrDao {

	@Autowired
	BoHrMapper BoHrMapper;

	//셀렉트박스 코드
	public List<Map<String, Object>> CodeList() {
		return BoHrMapper.selectHrCodeList();
	}

	//면접자
	public List<Map<String, Object>> IntvList() {
		return BoHrMapper.selectIntvList();
	}

	public int IntvInsert(Map<String, Object> param) {
		return BoHrMapper.insertIntv(param);
	}

	public int IntvUpdate(Map<String, Object> param) {
		return BoHrMapper.updateIntv(param);
	}

	public int IntvDelete(Map<String, Object> param) {
		return BoHrMapper.deleteIntv(param);
	}

	public int TraineeFromIntv(Map<String, Object> param) {
		return BoHrMapper.insertTraineeFromIntv(param);
	}

	//교육생
	public List<Map<String, Object>> TraineeList() {
		return BoHrMapper.selectTraineeList();
	}

	public int TraineeInsert(Map<String, Object> param) {
		return BoHrMapper.insertTrainee(param);
	}

	public int TraineeUpdate(Map<String, Object> param) {
		return BoHrMapper.updateTrainee(param);
	}

	public int TraineeFieldUpdate(Map<String, Object> param) {
		return BoHrMapper.updateTraineeField(param);
	}

	public int IntvFieldUpdate(Map<String, Object> param) {
		return BoHrMapper.updateIntvField(param);
	}

	public int IntvReferrerClear(Map<String, Object> param) {
		return BoHrMapper.clearIntvReferrer(param);
	}

	public int TraineeSkillUpdate(Map<String, Object> param) {
		return BoHrMapper.updateTraineeSkill(param);
	}

	public int TraineeDelete(Map<String, Object> param) {
		return BoHrMapper.deleteTrainee(param);
	}
}
