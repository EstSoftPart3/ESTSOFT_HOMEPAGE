package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

@MapperScan
public interface BoCalendarMapper {

	/**
	 * 업무툴 - 구글 캘린더 일정 분류 Mapper Interface
	 *
	 * **/

	public List<Map<String, Object>> selectRuleList();							//사용 중인 분류 규칙(우선순위 순)
	public List<Map<String, Object>> selectConfList();							//구글 OAuth 설정
	public int upsertConf(Map<String, Object> param);							//구글 OAuth 설정 저장
	public int deleteTmp(Map<String, Object> param);							//관리자의 임시 일정 비우기
	public int insertTmpList(Map<String, Object> param);						//임시 일정 일괄 등록
	public List<Map<String, Object>> selectTmpList(Map<String, Object> param);	//임시 일정 목록(확정 여부 포함)
	public int updateTmpCate(Map<String, Object> param);						//임시 일정 분류 수정
	public int confirmTmpList(Map<String, Object> param);						//임시 일정 -> 확정 일정
	public List<Map<String, Object>> selectEvtList(Map<String, Object> param);	//확정 일정 목록
	public List<Map<String, Object>> selectEvtCateCount(Map<String, Object> param);	//확정 일정 분류별 건수

}
