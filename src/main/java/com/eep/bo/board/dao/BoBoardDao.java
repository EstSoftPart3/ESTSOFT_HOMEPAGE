package com.eep.bo.board.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.eep.mapper.BoBoardMapper;



@Repository
public class BoBoardDao {

	@Autowired
	private BoBoardMapper BoBoardMapper;
	
	    /*게시판 목록*/
/*		@SuppressWarnings(value = "unchecked")
	    public List<BoBoardVo> getBoardList(BoBoardVo BoBoardVo) throws Exception { 
	    	
	    	Map<String, Object> paramMap = BoBoardVo.toMap();
	    	
	    	List<BoBoardVo> out = selectList("boBoardMapper.boBoardList", paramMap);
	    		
	    	System.out.println("out : " + out);
	    	
	        return out;
	    }*/
	
	public Map<String, Object> boardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
				
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> boardInfo = BoBoardMapper.boardListData(param);
		
		result.put("boardInfo", boardInfo);
				
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
		List<Map<String, Object>> boardInfo = BoBoardMapper.noticeBoardListData(param);
		
		result.put("noticeBoardInfo", boardInfo);
				
		return result;
	}
	
	//공지시항 게시판 등록
	public void noticeBoardInsertData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		BoBoardMapper.noticeBoardInsertData(param);
		
	}
	
	//공지시항 게시판 상세
	public Map<String, Object> noticeBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		//System.out.println("DATA = " + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> noticeBoardDetailData = BoBoardMapper.noticeBoardDetailData(param);
		
		result.put("noticeBoardDetailData", noticeBoardDetailData);
		
		return result;
	}
	
	//공지사항 게시판 삭제
	public void noticeBoardDeleteData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		BoBoardMapper.noticeBoardDeleteData(param);
		
	}
	
	//공지사항 수정
	public void noticeBoardUpdateData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		BoBoardMapper.noticeBoardUpdateData(param);
		
	}
	
	/**
	 * 교육 게시판 DAO
	 * 
	 * **/

	//교육 게시판 리스트
	public Map<String, Object> educationBoardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
				
		System.out.println("param :" + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> boardInfo = BoBoardMapper.educationBoardListData(param);
		
		result.put("educationBoardInfo", boardInfo);
				
		return result;
	}
	
	//교육 게시판 등록
	public void educationBoardInsertData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		BoBoardMapper.educationBoardInsertData(param);
		
	}
	
	//교육 게시판 상세
	public Map<String, Object> educationBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		//System.out.println("DATA = " + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> educationBoardDetailData = BoBoardMapper.educationBoardDetailData(param);
		
		result.put("educationBoardDetailData", educationBoardDetailData);
		
		return result;
	}
	
	//교육 게시판 삭제
	public void educationBoardDeleteData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		BoBoardMapper.educationBoardDeleteData(param);
		
	}
	
	//교육 게시판 수정
	public void educationBoardUpdateData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		BoBoardMapper.educationBoardUpdateData(param);
		
	}

	/**
	 * 자유 게시판 DAO
	 * 
	 * **/

	//자유 게시판 리스트
	public Map<String, Object> freedomBoardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
				
		System.out.println("param :" + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> boardInfo = BoBoardMapper.freedomBoardListData(param);
		
		result.put("freedomBoardInfo", boardInfo);
				
		return result;
	}
	
	//자유 게시판 등록
	public void freedomBoardInsertData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		//원본 저장
		BoBoardMapper.freedomBoardInsertData(param);
		//원본 저장 후 BRD_RE_REF 컬럼에 원본 고유 번호 업데이트
		BoBoardMapper.freedomBoardInsertUpdateData(param);
		
		
	}
	
	//자유 게시판 상세
	public Map<String, Object> freedomBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		//System.out.println("DATA = " + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> freedomBoardDetailData = BoBoardMapper.freedomBoardDetailData(param);
		
		result.put("freedomBoardDetailData", freedomBoardDetailData);
		
		return result;
	}
	
	//자유 게시판 순서 수정
	public void freedomBoardReplyInsertUpdateData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		BoBoardMapper.freedomBoardReplyInsertUpdateData(param);
		
	}
	
	//자유 게시판 답변 등록
	public void freedomBoardReplyInsertData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		BoBoardMapper.freedomBoardReplyInsertData(param);
		
	}
		
	//자유 게시판 게시판 삭제
	public void freedomBoardDeleteData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		BoBoardMapper.freedomBoardDeleteData(param);
		
	}
	
	//자유 게시판 수정
	public void freedomBoardUpdateData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		BoBoardMapper.freedomBoardUpdateData(param);
		
	}
	
	/**
	 * 기술문의 게시판 DAO
	 * 
	 * **/

	//기술문의 게시판 리스트
	public Map<String, Object> technologyBoardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
				
		System.out.println("param :" + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> boardInfo = BoBoardMapper.technologyBoardListData(param);
		
		result.put("technologyBoardInfo", boardInfo);
				
		return result;
	}
	
	//기술문의 게시판 등록
	public void technologyBoardInsertData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		//원본 저장
		BoBoardMapper.technologyBoardInsertData(param);
		//원본 저장 후 BRD_RE_REF 컬럼에 원본 고유 번호 업데이트
		BoBoardMapper.technologyBoardInsertUpdateData(param);
		
		
	}
	
	//기술문의 게시판 상세
	public Map<String, Object> technologyBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		//System.out.println("DATA = " + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> technologyBoardDetailData = BoBoardMapper.technologyBoardDetailData(param);
		
		result.put("technologyBoardDetailData", technologyBoardDetailData);
		
		return result;
	}
	
	//기술문의 게시판 순서 수정
	public void technologyBoardReplyInsertUpdateData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		BoBoardMapper.technologyBoardReplyInsertUpdateData(param);
		
	}
	
	//기술문의 게시판 답변 등록
	public void technologyBoardReplyInsertData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		BoBoardMapper.technologyBoardReplyInsertData(param);
		
	}
		
	//기술문의 게시판 게시판 삭제
	public void technologyBoardDeleteData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		BoBoardMapper.technologyBoardDeleteData(param);
		
	}
	
	//기술문의 게시판 수정
	public void technologyBoardUpdateData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		BoBoardMapper.technologyBoardUpdateData(param);
		
	}
	
}
