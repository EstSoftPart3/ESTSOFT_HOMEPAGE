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
	
	/**
	 * 교육 게시판 Mapper Interface
	 * 
	 * **/
	
	public List educationBoardListData(Map<String, Object> param);					//교육일정 게시판 리스트
	public void educationBoardInsertData(Map<String, Object> param);				//교육일정 게시판 등록
	public List educationBoardDetailData(Map<String, Object> param); 				//교육일정 게시판 상세
	public void educationBoardDeleteData(Map<String, Object> param);   				//교육일정 게시판 삭제
	public void educationBoardUpdateData(Map<String, Object> param);				//교육일정 게시판 수정
	public int educationBoardListCountData(Map<String, Object> param);				//교육일정 게시판 개수
	
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
	public int freedomBoardListCountData(Map<String, Object> param);				//자유 게시판 개수
	
}
