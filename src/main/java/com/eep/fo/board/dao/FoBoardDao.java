package com.eep.fo.board.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.eep.mapper.FoBoardMapper;

@Repository
public class FoBoardDao {

	@Autowired
	private FoBoardMapper FoBoardMapper;
	
	/**
	 * 메인 게시판 출력용 DAO
	 * 
	 * **/

	//메인 게시판 공지시항 게시판 리스트
	public Map<String, Object> mainNoticeList(){
		
		Map<String, Object> result = new HashMap<>();

		@SuppressWarnings("unchecked")
		List<Map<String, Object>> boardInfo = FoBoardMapper.mainNoticeList();
		
		result.put("mainNoticeBoardInfo", boardInfo);
				
		return result;
	}
	
	//메인 게시판 기술지원 게시판 리스트
	public Map<String, Object> mainTechnologyList(){
		
		Map<String, Object> result = new HashMap<>();

		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> boardInfo = FoBoardMapper.mainTechnologyList();
		
		result.put("mainTechnologyBoardInfo", boardInfo);
				
		return result;
	}
	
	//메인 게시판 교육일정 게시판 리스트
	public Map<String, Object> mainEductaionList(){
		
		Map<String, Object> result = new HashMap<>();

		@SuppressWarnings("unchecked")
		List<Map<String, Object>> boardInfo = FoBoardMapper.mainEductaionList();
		
		result.put("mainEducationBoardInfo", boardInfo);
				
		return result;
	}
	
	/**
	 * 공지시항 게시판 DAO
	 * 
	 * **/

	//공지시항 게시판 리스트
	public Map<String, Object> noticeBoardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
				
		System.out.println("param :" + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> boardInfo = FoBoardMapper.noticeBoardListData(param);
		
		result.put("noticeBoardInfo", boardInfo);
				
		return result;
	}
	
	//공지시항 게시판 등록
	public void noticeBoardInsertData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		FoBoardMapper.noticeBoardInsertData(param);
		
	}
	
	//공지시항 게시판 상세
	public Map<String, Object> noticeBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		//System.out.println("DATA = " + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> noticeBoardDetailData = FoBoardMapper.noticeBoardDetailData(param);
		
		result.put("noticeBoardDetailData", noticeBoardDetailData);
		
		return result;
	}
	
	//공지사항 게시판 삭제
	public void noticeBoardDeleteData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		FoBoardMapper.noticeBoardDeleteData(param);
		
	}
	
	//공지사항 수정
	public void noticeBoardUpdateData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		FoBoardMapper.noticeBoardUpdateData(param);
		
	}
	
	//공지사항 게시판 개수
	public int noticeBoardListCountData(Map<String, Object> param){

		System.out.println("param :" + param);
		
		@SuppressWarnings("unchecked")
		int result = FoBoardMapper.noticeBoardListCountData(param);

		return result;
	}
	
	/**
	 * 교육일정 게시판 DAO
	 * 
	 * **/

	//교육일정 게시판 리스트
	public Map<String, Object> educationBoardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
				
		System.out.println("param :" + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> boardInfo = FoBoardMapper.educationBoardListData(param);
		
		result.put("educationBoardInfo", boardInfo);
				
		return result;
	}
	
	//교육일정 게시판 등록
	public void educationBoardInsertData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		FoBoardMapper.educationBoardInsertData(param);
		
	}
	
	//교육일정 게시판 상세
	public Map<String, Object> educationBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		//System.out.println("DATA = " + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> educationBoardDetailData = FoBoardMapper.educationBoardDetailData(param);
		
		result.put("educationBoardDetailData", educationBoardDetailData);
		
		return result;
	}
	
	//교육일정 게시판 삭제
	public void educationBoardDeleteData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		FoBoardMapper.educationBoardDeleteData(param);
		
	}
	
	//교육일정 수정
	public void educationBoardUpdateData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		FoBoardMapper.educationBoardUpdateData(param);
		
	}
	
	//교육일정 게시판 개수
	public int educationBoardListCountData(Map<String, Object> param){

		System.out.println("param :" + param);
		
		@SuppressWarnings("unchecked")
		int result = FoBoardMapper.educationBoardListCountData(param);

		return result;
	}
}
