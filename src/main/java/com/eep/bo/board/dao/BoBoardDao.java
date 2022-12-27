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
	 * 공지시항 DAO
	 * 
	 * **/

	//공지시항 리스트
	public Map<String, Object> noticeBoardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
				
		System.out.println("param :" + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> boardInfo = BoBoardMapper.noticeBoardListData(param);
		
		result.put("noticeBoardInfo", boardInfo);
				
		return result;
	}
	
	//공지시항 등록
	public void noticeBoardInsertData(Map<String, Object> param){
		
		System.out.println("DATA = " + param);
		BoBoardMapper.noticeBoardInsertData(param);
		
	}
	
	//공지시항 상세
	public Map<String, Object> noticeBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		//System.out.println("DATA = " + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> noticeBoardDetailData = BoBoardMapper.noticeBoardDetailData(param);
		
		result.put("noticeBoardDetailData", noticeBoardDetailData);
		
		return result;
	}
		
		
	 	/*게시판 - 상세 조회 */
/*	    public BoBoardVo getBoardDetail(BoBoardVo BoBoardVo) throws Exception { 
	        return (BoBoardVo) selectOne("boBoardMapper.boBoardDetail", BoBoardVo);
	    }*/
	 
/*	    *//** 게시판 - 그룹 번호 조회 *//*
	    public int getBoardReRef(BoBoardVo BoBoardVo) throws Exception { 
	        return sqlSession.selectOne(NAMESPACE + ".getBoardReRef", BoBoardVo);
	    }
	    
	    *//** 게시판 - 등록 *//*
	    public int insertBoard(BoBoardVo BoBoardVo) throws Exception {
	        return sqlSession.insert(NAMESPACE + ".insertBoard", BoBoardVo);
	    }
	 
	    *//** 게시판 - 삭제 *//*
	    public int deleteBoard(BoBoardVo BoBoardVo) throws Exception { 
	        return sqlSession.delete(NAMESPACE + ".deleteBoard", BoBoardVo);
	    }
	 
	    *//** 게시판 - 수정 *//*
	    public int updateBoard(BoBoardVo BoBoardVo) throws Exception { 
	        return sqlSession.update(NAMESPACE + ".updateBoard", BoBoardVo);
	    }
	    
	    *//** 게시판 - 답글 정보  조회 *//*
	    public BoBoardVo getBoardReplyInfo(BoBoardVo BoBoardVo) throws Exception {
	        return sqlSession.selectOne(NAMESPACE + ".getBoardReplyInfo", BoBoardVo);
	    }
	    
	    *//** 게시판 - 답글의 순서 수정 *//*
	    public int updateBoardReSeq(BoBoardVo BoBoardVo) throws Exception { 
	        return sqlSession.update(NAMESPACE + ".updateBoardReSeq", BoBoardVo);
	    }
	    
	    *//** 게시판 - 답글 등록 *//*
	    public int insertBoardReply(BoBoardVo BoBoardVo) throws Exception {
	        return sqlSession.insert(NAMESPACE + ".insertBoardReply", BoBoardVo);
	    }*/
	
}
