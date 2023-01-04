package com.eep.fo.board.service;

import java.util.Map;

public interface FoBoardService {

	/**
	 * 메인 게시판 출력용  Service Interface
	 * 
	 * **/
	
	public Map<String, Object> mainNoticeList(); 				//메인 공지사항 게시판 리스트
	public Map<String, Object> mainTechnologyList(); 			//메인 기술지원 게시판 리스트
	public Map<String, Object> mainEductaionList(); 			//메인 교육일정 게시판 리스트
	
	/**
	 * 공지사항 게시판 Service Interface
	 * 
	 * **/
	
	public Map<String, Object> noticeBoardListData(Map<String, Object> param); 			//공지시항 게시판 리스트
	public void noticeBoardInsertData(Map<String, Object> param);						//공지사항 게시판 등록
	public Map<String, Object> noticeBoardDetailData(Map<String, Object> param);		//공지사항 게시판 상세
	public void noticeBoardDeleteData(Map<String, Object> param); 						//공지사항 게시판 삭제
	public void noticeBoardUpdateData(Map<String, Object> param);						//공지사항 게시판 수정
	public int noticeBoardListCountData(Map<String, Object> param);						//공지사항 게시판 개수
	
	/**
	 * 교육일정 게시판 Service Interface
	 * 
	 * **/
	
	public Map<String, Object> educationBoardListData(Map<String, Object> param); 		//교육일정 게시판 리스트
	public void educationBoardInsertData(Map<String, Object> param);					//교육일정 게시판 등록
	public Map<String, Object> educationBoardDetailData(Map<String, Object> param);		//교육일정 게시판 상세
	public void educationBoardDeleteData(Map<String, Object> param); 					//교육일정 게시판 삭제
	public void educationBoardUpdateData(Map<String, Object> param);					//교육일정 게시판 수정
	public int educationBoardListCountData(Map<String, Object> param);					//교육일정 게시판 개수
	
}
