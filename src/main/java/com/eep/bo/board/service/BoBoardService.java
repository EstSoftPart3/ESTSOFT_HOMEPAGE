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
	//공지사항 리스트 페이지
	
	public Map<String, Object> noticeBoardListData(Map<String, Object> param);

	public void noticeBoardInsertData(Map<String, Object> param);
	
	
	

}
