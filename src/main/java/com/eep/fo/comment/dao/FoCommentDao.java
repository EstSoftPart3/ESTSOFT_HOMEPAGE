package com.eep.fo.comment.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.eep.mapper.FoCommentMapper;

@Repository
public class FoCommentDao {

	@Autowired
	private FoCommentMapper FoCommentMapper;
	
	/**
	 * 댓글 관련 DAO
	 */
	
	//댓글 목록 불러오기
	public Map<String, Object> commentListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		@SuppressWarnings("unchecked")
		List<Map<String,Object>> commentInfo = FoCommentMapper.commentListData(param);
		
		result.put("commentInfo", commentInfo);
		
		return result;
	}
	
	//댓글 등록
	public int commentInsert(Map<String, Object> param) {
		
		int result = FoCommentMapper.commentWorkData(param);
		
		return result;
	}
	
	//댓글 수정
	public int commentUpdate(Map<String, Object> param) {
		
		//쿼리문 내에서 같은 SEQ 번호가 있을 시 수정
		int result = FoCommentMapper.commentWorkData(param);
		
		return result;
	}
	
	//댓글 삭제
		public int commentDelete(Map<String, Object> param) {
			
		//쿼리문 내에서 같은 SEQ 번호가 있을 시 수정
		int result = FoCommentMapper.commentWorkData(param);
		
		return result;
	}
}
