package com.sample.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Repository;

import com.sample.vo.BoardSampleVo;

import common.dao.AbstractDAO;

@Repository("sampleBoardDao")
public class SampleBoardDao extends AbstractDAO {

	//샘플 게시판 리스트 목록 + 페이징 비동기식
	@SuppressWarnings(value = "unchecked")
	public List<BoardSampleVo> sampleBoardAjaxPagingList(BoardSampleVo Vo) throws Exception{
		Map<String, Object> paramMap = Vo.toMap();
		
		System.out.println("sampleBoardAjaxPagingList_DATA_INFO[boardSampleVo]" + Vo);
		System.out.println("sampleBoardAjaxPagingList_DATA_INFO[paramMap]" + paramMap);

		
		return selectList("sampleBoard.sampleBoardAjaxPagingList", paramMap);
	}

	
}
