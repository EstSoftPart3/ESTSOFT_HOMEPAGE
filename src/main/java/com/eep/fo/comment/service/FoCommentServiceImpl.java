package com.eep.fo.comment.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.eep.fo.board.service.FoBoardService;
import com.eep.fo.comment.dao.FoCommentDao;

@Service
public class FoCommentServiceImpl implements FoCommentService{
	
	@Autowired
	private FoCommentDao FoCommentDao;
	
	/**
	 *  댓글 관련 ServiceImpl
	 */
	
	//댓글 리스트
	public Map<String, Object> commentList(Map<String, Object> param){
		Map<String, Object> result = new HashMap<>();
		
		result = FoCommentDao.commentListData(param);
		
		return result;
	}

	//댓글 등록
	@Override
	public int commentInsert(Map<String, Object> param) {
		
		int result = FoCommentDao.commentInsert(param);
		
		return result;
	}
	
	//댓글 수정
	@Override
	public int commentUpdate(Map<String, Object> param) {
		
		int result = FoCommentDao.commentUpdate(param);
		
		return result;
	}

	@Override
	public int commentDelete(Map<String, Object> param) {
		
		int result = FoCommentDao.commentDelete(param);
		
		return result;
	}
}
