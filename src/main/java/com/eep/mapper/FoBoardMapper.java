package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

@MapperScan
public interface FoBoardMapper {

	/**
	 * 메인 게시판 출력용 Mapper Interface
	 * 
	 * **/

	public List mainNoticeList();							//메인 공지사항 게시판 리스트
	public List mainTechnologyList();						//메인 기술지원 게시판 리스트
	public List mainEductaionList();						//메인 교육일정 게시판 리스트
	
	/**
	 * 공지사항 게시판 Mapper Interface
	 * 
	 * **/

	public List noticeBoardListData(Map<String, Object> param);						//공지사항 게시판 리스트
	public void noticeBoardInsertData(Map<String, Object> param);					//공지사항 게시판 등록
	public List noticeBoardDetailData(Map<String, Object> param); 					//공지사항 게시판 상세
	public void noticeBoardDeleteData(Map<String, Object> param);   				//공지사항 게시판 삭제
	public void noticeBoardUpdateData(Map<String, Object> param);					//공지사항 게시판 수정
	public int noticeBoardListCountData(Map<String, Object> param);					//공지사항 게시판 개수
	
}
