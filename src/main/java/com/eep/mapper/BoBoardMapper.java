package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

@MapperScan
public interface BoBoardMapper {

	//답변 관련 예시
	public List boardListData(Map<String, Object> param);
	
	/**
	 * 공지사항 게시판 Mapper Interface
	 * 
	 * **/

	public List noticeBoardListData(Map<String, Object> param);						//공지사항 게시판 리스트
	public void noticeBoardInsertData(Map<String, Object> param);					//공지사항 게시판 등록
	public List noticeBoardDetailData(Map<String, Object> param); 					//공지사항 게시판 상세
	public void noticeBoardDeleteData(Map<String, Object> param);   				//공지사항 게시판 삭제
	public void noticeBoardUpdateData(Map<String, Object> param);					//공지사항 게시판 수정
	
	/**
	 * 교육 게시판 Mapper Interface
	 * 
	 * **/

	public List educationBoardListData(Map<String, Object> param);					//교육 게시판 리스트
	public void educationBoardInsertData(Map<String, Object> param);				//교육 게시판 등록
	public List educationBoardDetailData(Map<String, Object> param); 				//교육 게시판 상세
	public void educationBoardDeleteData(Map<String, Object> param);    			//교육 게시판 삭제
	public void educationBoardUpdateData(Map<String, Object> param);				//교육 게시판 수정
	
	/**
	 * 자유 게시판 Mapper Interface
	 * 
	 * **/

	public List freedomBoardListData(Map<String, Object> param);					//자유 게시판 리스트
	public void freedomBoardInsertData(Map<String, Object> param);					//자유 게시판 등록
	public void freedomBoardInsertUpdateData(Map<String, Object> param);			//자유 게시판 등록
	public List freedomBoardDetailData(Map<String, Object> param); 					//자유 게시판 상세
	public void freedomBoardReplyInsertUpdateData(Map<String, Object> param); 		//자유 게시판 답변 순서 수정
	public void freedomBoardReplyInsertData(Map<String, Object> param); 			//자유 게시판 답변 등록
	public void freedomBoardDeleteData(Map<String, Object> param);   				//자유 게시판 삭제
	public void freedomBoardUpdateData(Map<String, Object> param);					//자유 게시판 수정
	
	/**
	 * 기술문의 게시판 Mapper Interface
	 * 
	 * **/

	public List technologyBoardListData(Map<String, Object> param);					//기술문의 게시판 리스트
	public void technologyBoardInsertData(Map<String, Object> param);				//기술문의 게시판 등록
	public void technologyBoardInsertUpdateData(Map<String, Object> param);			//기술문의 게시판 등록
	public List technologyBoardDetailData(Map<String, Object> param); 				//기술문의 게시판 상세
	public void technologyBoardReplyInsertUpdateData(Map<String, Object> param); 	//기술문의 게시판 답변 순서 수정
	public void technologyBoardReplyInsertData(Map<String, Object> param); 			//기술문의 게시판 답변 등록
	public void technologyBoardDeleteData(Map<String, Object> param);   			//기술문의 게시판 삭제
	public void technologyBoardUpdateData(Map<String, Object> param);				//기술문의 게시판 수정
}
