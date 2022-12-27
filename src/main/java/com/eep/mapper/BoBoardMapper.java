package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

@MapperScan
public interface BoBoardMapper {

	//답변 관련 예시
	public List boardListData(Map<String, Object> param);
	
	/**
	 * 공지사항 Mapper Interface
	 * 
	 * **/
	
	public List noticeBoardListData(Map<String, Object> param);		//공지사항 리스트
	public void noticeBoardInsertData(Map<String, Object> param);	//공지사항 등록
	public List noticeBoardDetailData(Map<String, Object> param); 	//공지사항 상세
}
