package com.eep.fo.comment.service;

import java.util.Map;

public interface FoCommentService {

	/**
	 * 댓글 관련 Service
	 */
	
	//댓글 리스트
	public Map<String, Object> commentList(Map<String, Object> param);
	//댓글 등록
	public int commentInsert(Map<String, Object> param);
	//댓글 수정
	public int commentUpdate(Map<String, Object> param);
	//댓글 삭제
	public int commentDelete(Map<String, Object> param);
}
