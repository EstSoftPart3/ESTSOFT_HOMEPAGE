package com.sample.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.sample.vo.BoardSampleVo;



public interface SampleBoardService {
	
	//샘플 게시판 목록 리스트 + 페이징 비동기식
	public List<BoardSampleVo> sampleBoardAjaxPagingList(BoardSampleVo Vo) throws Exception;


}
