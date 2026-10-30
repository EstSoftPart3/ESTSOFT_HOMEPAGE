package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

@MapperScan
public interface TravelMapper {

	/**
	 * 여행 대화 사전(공개) Mapper Interface
	 *
	 * **/

	public List<Map<String, Object>> selectPhraseList();		//추가한 문장 전체
	public int insertPhrase(Map<String, Object> param);			//추가한 문장 등록 (PHRASE_SQ 를 param 에 채운다)
	public List<String> selectHideKeyList();					//숨긴 문장 키 전체
	public int insertHide(Map<String, Object> param);			//숨기기
	public int deleteHide(Map<String, Object> param);			//되돌리기

}
