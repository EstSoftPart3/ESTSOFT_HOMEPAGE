package com.eep.bo.board.service;

import java.util.Map;

import com.eep.bo.board.vo.BoBoardVo;

public interface BoBoardService {

	public Map<String, Object> boardListData(Map<String, Object> param);
	
	/*BoBoardVo getBoardDetail(BoBoardVo BoBoardVo) throws Exception;*/
	
	/**
	 * 공지사항 Service Interface
	 * 
	 * **/
	
	public Map<String, Object> noticeBoardListData(Map<String, Object> param); 		//공지시항 리스트
	public void noticeBoardInsertData(Map<String, Object> param);					//공지사항 등록
	public Map<String, Object> noticeBoardDetailData(Map<String, Object> param);	//공지사항 상세
	public void noticeBoardDeleteData(Map<String, Object> param); 					//공지사항 삭제
	public void noticeBoardUpdateData(Map<String, Object> param);					//공지사항 수정
	
	/**
	 * 교육 Service Interface
	 * 
	 * **/
	
	public Map<String, Object> educationBoardListData(Map<String, Object> param); 		//교육 리스트
	public void educationBoardInsertData(Map<String, Object> param);					//교육 등록
	public Map<String, Object> educationBoardDetailData(Map<String, Object> param);		//교육 상세
	public void educationBoardDeleteData(Map<String, Object> param); 					//교육 삭제
	public void educationBoardUpdateData(Map<String, Object> param);					//교육 수정
	
	
	

}
