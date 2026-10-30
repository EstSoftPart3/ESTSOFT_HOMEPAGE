package com.eep.bo.calendar.service;

import java.util.List;
import java.util.Map;

public interface BoCalendarService {

	/**
	 * 업무툴 - 구글 캘린더 일정 분류 Service
	 *
	 * **/

	Map<String, String> ConfMap();																//구글 OAuth 설정
	void ConfSave(String clientId, String clientSecret);										//구글 OAuth 설정 저장
	List<Map<String, Object>> FetchToTmp(String emplyId, List<Map<String, Object>> events);	//가져온 일정을 1차 분류해 임시 저장
	List<Map<String, Object>> TmpList(String emplyId);											//임시 일정 목록
	int Confirm(String emplyId, List<Map<String, Object>> items);								//분류 수정 후 확정
	List<Map<String, Object>> EvtList(Map<String, Object> param);								//확정 일정 목록
	List<Map<String, Object>> EvtCateCount(Map<String, Object> param);							//확정 일정 분류별 건수

}
