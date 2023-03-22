package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

@MapperScan
public interface FoCommentMapper {
	/**
	 *댓글 관련 Mapper Interface
	 */

	public List commentListData(Map<String, Object> param); //댓글 리스트
	public int commentWorkData(Map<String, Object> param); //댓글 등록, 수정, 삭제 조건에 따라 모두 처리
}
