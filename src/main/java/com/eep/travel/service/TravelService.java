package com.eep.travel.service;

import java.util.List;
import java.util.Map;

public interface TravelService {

	/**
	 * 여행 대화 사전(공개) Service
	 *
	 * **/

	List<Map<String, Object>> PhraseList();												//추가한 문장 전체
	Map<String, Object> PhraseAdd(int sitIdx, String srcLang, Map<String, String> texts, String ip);	//번역한 문장 추가
	List<String> HideKeyList();															//숨긴 문장 키 전체
	void Hide(String key, String ip);													//숨기기
	void Unhide(String key);															//되돌리기

}
