package com.eep.travel.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.eep.mapper.TravelMapper;

@Repository
public class TravelDao {

	@Autowired
	TravelMapper TravelMapper;

	public List<Map<String, Object>> PhraseList() {
		return TravelMapper.selectPhraseList();
	}

	public Map<String, Object> PhraseInsert(Map<String, Object> param) {
		TravelMapper.insertPhrase(param);
		return param;
	}

	public List<String> HideKeyList() {
		return TravelMapper.selectHideKeyList();
	}

	public int Hide(String key, String ip) {
		Map<String, Object> param = new HashMap<>();
		param.put("PHRASE_KEY", key);
		param.put("HIDE_IP", ip);
		return TravelMapper.insertHide(param);
	}

	public int Unhide(String key) {
		Map<String, Object> param = new HashMap<>();
		param.put("PHRASE_KEY", key);
		return TravelMapper.deleteHide(param);
	}
}
