package com.eep.bo.board.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.eep.bo.board.dao.BoBoardDao;

@Service
public class BoBoardServiceImpl implements BoBoardService {

	@Autowired
	private BoBoardDao BoBoardDao;
 
    /** 게시판 - 목록 조회 *//*
    @Override
    public List<BoBoardVo> getBoardList(BoBoardVo BoBoardVo) throws Exception {

    	List<BoBoardVo> list = new ArrayList<BoBoardVo>();
    	
        list = boardDao.getBoardList(BoBoardVo);

 
        return list;
    }
 */
	
	//게시판 목록
	@Override
	public Map<String, Object> boardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardDao.boardListData(param);
		
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
		
		result = BoBoardDao.noticeBoardListData(param);
		
		return result;
	}
	
	//공지시항 게시판 등록
	@Override
	public void noticeBoardInsertData(Map<String, Object> param){
		BoBoardDao.noticeBoardInsertData(param);
	}
	
	//공지시항 게시판 상세
	@Override
	public Map<String, Object> noticeBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardDao.noticeBoardDetailData(param);
		
		return result;
	}
	
	//공지사항 게시판 삭제
	@Override
	public void noticeBoardDeleteData(Map<String, Object> param){
		BoBoardDao.noticeBoardDeleteData(param);
	}
	
	//공지사항 게시판 수정
	@Override
	public void noticeBoardUpdateData(Map<String, Object> param){
		BoBoardDao.noticeBoardUpdateData(param);
	}
	
	/**
	 * 교육 게시판 ServiceImpl
	 * 
	 * **/
	
	//교육 게시판 리스트
	@Override
	public Map<String, Object> educationBoardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardDao.educationBoardListData(param);
		
		return result;
	}
	
	//교육 게시판 등록
	@Override
	public void educationBoardInsertData(Map<String, Object> param){
		BoBoardDao.educationBoardInsertData(param);
	}
	
	//교육 게시판 상세
	@Override
	public Map<String, Object> educationBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardDao.educationBoardDetailData(param);
		
		return result;
	}
	
	//교육 게시판 삭제
	@Override
	public void educationBoardDeleteData(Map<String, Object> param){
		BoBoardDao.educationBoardDeleteData(param);
	}
	
	//교육 게시판 수정
	@Override
	public void educationBoardUpdateData(Map<String, Object> param){
		BoBoardDao.educationBoardUpdateData(param);
	}
	
	/**
	 * 자유 게시판 ServiceImpl
	 * 
	 * **/
	
	//자유 게시판 리스트
	@Override
	public Map<String, Object> freedomBoardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardDao.freedomBoardListData(param);
		
		return result;
	}
	
	//자유 게시판 등록
	@Override
	public void freedomBoardInsertData(Map<String, Object> param){
		BoBoardDao.freedomBoardInsertData(param);
	}
	
	//교육 게시판 상세
	@Override
	public Map<String, Object> freedomBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardDao.freedomBoardDetailData(param);
		
		return result;
	}
	
	//자유 게시판 답변 등록
	@Override
	public void freedomBoardReplyInsertData(Map<String, Object> param){
		
		BoBoardDao.freedomBoardReplyInsertUpdateData(param);
		
		BoBoardDao.freedomBoardReplyInsertData(param);
	}

	//자유 게시판 삭제
	@Override
	public void freedomBoardDeleteData(Map<String, Object> param){
		BoBoardDao.freedomBoardDeleteData(param);
	}
	
	//자유 게시판 수정
	@Override
	public void freedomBoardUpdateData(Map<String, Object> param){
		BoBoardDao.freedomBoardUpdateData(param);
	}
	
	/**
	 * 기술문의 게시판 ServiceImpl
	 * 
	 * **/
	
	//기술문의 게시판 리스트
	@Override
	public Map<String, Object> technologyBoardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardDao.technologyBoardListData(param);
		
		return result;
	}
	
	//기술문의 게시판 등록
	@Override
	public void technologyBoardInsertData(Map<String, Object> param){
		BoBoardDao.technologyBoardInsertData(param);
	}
	
	//기술문의 게시판 상세
	@Override
	public Map<String, Object> technologyBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardDao.technologyBoardDetailData(param);
		
		return result;
	}
	
	//기술문의 게시판 답변 등록
	@Override
	public void technologyBoardReplyInsertData(Map<String, Object> param){
		
		BoBoardDao.technologyBoardReplyInsertUpdateData(param);
		
		BoBoardDao.technologyBoardReplyInsertData(param);
	}

	//기술문의 게시판 삭제
	@Override
	public void technologyBoardDeleteData(Map<String, Object> param){
		BoBoardDao.technologyBoardDeleteData(param);
	}
	
	//기술문의 게시판 수정
	@Override
	public void technologyBoardUpdateData(Map<String, Object> param){
		BoBoardDao.technologyBoardUpdateData(param);
	}
	
	
	

	
}
