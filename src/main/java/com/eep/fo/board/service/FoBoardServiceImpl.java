package com.eep.fo.board.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.eep.fo.board.dao.FoBoardDao;

@Service
public class FoBoardServiceImpl implements FoBoardService{

	@Autowired
	private FoBoardDao FoBoardDao;
	
	/**
	 * 메인 게시판 출력용  ServiceImpl
	 * 
	 * **/
	
	//메인 공지사항 게시판 리스트
	@Override
	public Map<String, Object> mainNoticeList(){
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardDao.mainNoticeList();
		
		return result;
	}
	
	//메인 기술지원 게시판 리스트
	@Override
	public Map<String, Object> mainTechnologyList(){
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardDao.mainTechnologyList();
		
		return result;
	}
	
	//메인 교육지원 게시판 리스트
	@Override
	public Map<String, Object> mainEductaionList(){
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardDao.mainEductaionList();
		
		return result;
	}
	
	/**
	 * 공지사항 게시판 ServiceImpl
	 * 
	 * **/
	
	//공지사항 게시판 리스트
	@Override
	public Map<String, Object> noticeBoardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardDao.noticeBoardListData(param);
		
		return result;
	}
	
	//공지시항 게시판 등록
	@Override
	public void noticeBoardInsertData(Map<String, Object> param){
		FoBoardDao.noticeBoardInsertData(param);
	}
	
	//공지시항 게시판 상세
	@Override
	public Map<String, Object> noticeBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardDao.noticeBoardDetailData(param);
		
		return result;
	}
	
	//공지사항 게시판 삭제
	@Override
	public void noticeBoardDeleteData(Map<String, Object> param){
		FoBoardDao.noticeBoardDeleteData(param);
	}
	
	//공지사항 게시판 수정
	@Override
	public void noticeBoardUpdateData(Map<String, Object> param){
		FoBoardDao.noticeBoardUpdateData(param);
	}
	
	//공지사항 게시판 개수
	@Override
	public int noticeBoardListCountData(Map<String, Object> param){

		int result = FoBoardDao.noticeBoardListCountData(param);
		
		return result;
	}
	
	/**
	 * 교육일정 게시판 ServiceImpl
	 * 
	 * **/
	
	//교육일정 게시판 리스트
	@Override
	public Map<String, Object> educationBoardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardDao.educationBoardListData(param);
		
		return result;
	}
	
	//교육일정 게시판 등록
	@Override
	public void educationBoardInsertData(Map<String, Object> param){
		FoBoardDao.educationBoardInsertData(param);
	}
	
	//교육일정 게시판 상세
	@Override
	public Map<String, Object> educationBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardDao.educationBoardDetailData(param);
		
		return result;
	}
	
	//교육일정 게시판 삭제
	@Override
	public void educationBoardDeleteData(Map<String, Object> param){
		FoBoardDao.educationBoardDeleteData(param);
	}
	
	//교육일정 게시판 수정
	@Override
	public void educationBoardUpdateData(Map<String, Object> param){
		FoBoardDao.educationBoardUpdateData(param);
	}
	
	//교육일정 게시판 개수
	@Override
	public int educationBoardListCountData(Map<String, Object> param){

		int result = FoBoardDao.educationBoardListCountData(param);
		
		return result;
	}
	
	/**
	 * 자유 게시판 ServiceImpl
	 * 
	 * **/
	
	//자유 게시판 리스트
	@Override
	public Map<String, Object> freedomBoardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardDao.freedomBoardListData(param);
		
		return result;
	}
	
	//자유 게시판 등록
	@Override
	public void freedomBoardInsertData(Map<String, Object> param){
		FoBoardDao.freedomBoardInsertData(param);
	}
	
	//교육 게시판 상세
	@Override
	public Map<String, Object> freedomBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoBoardDao.freedomBoardDetailData(param);
		
		return result;
	}
	
	//자유 게시판 답변 등록
	@Override
	public void freedomBoardReplyInsertData(Map<String, Object> param){
		
		FoBoardDao.freedomBoardReplyInsertUpdateData(param);
		
		FoBoardDao.freedomBoardReplyInsertData(param);
	}

	//자유 게시판 삭제
	@Override
	public void freedomBoardDeleteData(Map<String, Object> param){
		FoBoardDao.freedomBoardDeleteData(param);
	}
	
	//자유 게시판 수정
	@Override
	public void freedomBoardUpdateData(Map<String, Object> param){
		FoBoardDao.freedomBoardUpdateData(param);
	}
	
	//자유 게시판 개수
	@Override
	public int freedomBoardListCountData(Map<String, Object> param){

		int result = FoBoardDao.freedomBoardListCountData(param);
		
		return result;
	}
	
}
