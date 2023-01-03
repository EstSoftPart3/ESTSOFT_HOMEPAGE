package com.eep.bo.board.service;

import java.util.Map;

import com.eep.bo.board.vo.BoBoardVo;

public interface BoBoardService {

	public Map<String, Object> boardListData(Map<String, Object> param);

	/**
	 * 공지사항 게시판 Service Interface
	 * 
	 * **/
	
	public Map<String, Object> noticeBoardListData(Map<String, Object> param); 			//공지시항 게시판 리스트
	public void noticeBoardInsertData(Map<String, Object> param);						//공지사항 게시판 등록
	public Map<String, Object> noticeBoardDetailData(Map<String, Object> param);		//공지사항 게시판 상세
	public void noticeBoardDeleteData(Map<String, Object> param); 						//공지사항 게시판 삭제
	public void noticeBoardUpdateData(Map<String, Object> param);						//공지사항 게시판 수정
	
	/**
	 * 교육 게시판 Service Interface
	 * 
	 * **/
	
	public Map<String, Object> educationBoardListData(Map<String, Object> param); 		//교육 게시판 리스트
	public void educationBoardInsertData(Map<String, Object> param);					//교육 게시판 등록
	public Map<String, Object> educationBoardDetailData(Map<String, Object> param);		//교육 게시판 상세
	public void educationBoardDeleteData(Map<String, Object> param); 					//교육 게시판 삭제
	public void educationBoardUpdateData(Map<String, Object> param);					//교육 게시판 수정
	
	/**
	 * 자유 게시판 Service Interface
	 * 
	 * **/
	
	public Map<String, Object> freedomBoardListData(Map<String, Object> param); 		//자유 게시판 리스트
	public void freedomBoardInsertData(Map<String, Object> param);						//자유 게시판 등록
	public Map<String, Object> freedomBoardDetailData(Map<String, Object> param);		//자유 게시판 상세
	public void freedomBoardReplyInsertData(Map<String, Object> param);					//자유 게시판 답변 등록
	public void freedomBoardDeleteData(Map<String, Object> param); 						//자유 게시판 삭제
	public void freedomBoardUpdateData(Map<String, Object> param);						//자유 게시판 수정
	
	/**
	 * 기술문의 게시판 Service Interface
	 * 
	 * **/
	
	public Map<String, Object> technologyBoardListData(Map<String, Object> param); 		//기술문의 게시판 리스트
	public void technologyBoardInsertData(Map<String, Object> param);					//기술문의 게시판 등록
	public Map<String, Object> technologyBoardDetailData(Map<String, Object> param);	//기술문의 게시판 상세
	public void technologyBoardReplyInsertData(Map<String, Object> param);				//기술문의 게시판 답변 등록
	public void technologyBoardDeleteData(Map<String, Object> param); 					//기술문의 게시판 삭제
	public void technologyBoardUpdateData(Map<String, Object> param);					//기술문의 게시판 수정
	
	
	

}
