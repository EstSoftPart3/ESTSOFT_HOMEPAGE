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
	public void noticeBoardDeleteData(Map<String, Object> param);   //공지사항 삭제
	public void noticeBoardUpdateData(Map<String, Object> param);	//공지사항 수정
	
	/**
	 * 교육 Mapper Interface
	 * 
	 * **/

	public List educationBoardListData(Map<String, Object> param);		//교육 리스트
	public void educationBoardInsertData(Map<String, Object> param);	//교육 등록
	public List educationBoardDetailData(Map<String, Object> param); 	//교육 상세
	public void educationBoardDeleteData(Map<String, Object> param);    //교육 삭제
	public void educationBoardUpdateData(Map<String, Object> param);	//교육 수정
}
