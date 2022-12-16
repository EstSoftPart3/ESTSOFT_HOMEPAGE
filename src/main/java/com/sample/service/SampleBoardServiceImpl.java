package com.sample.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.sample.dao.SampleBoardDao;
import com.sample.vo.BoardSampleVo;

@Service(value = "sampleBoardService")
public class SampleBoardServiceImpl implements SampleBoardService{
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Resource(name = "sampleBoardDao")
	SampleBoardDao sampleBoardDao;

	//샘플 게시판 리스트 + 페이징 비동기식
	@Override
	public List<BoardSampleVo> sampleBoardAjaxPagingList( BoardSampleVo Vo) throws Exception{
		
		List<BoardSampleVo>list = new ArrayList<BoardSampleVo>();
		
		try {
			list = sampleBoardDao.sampleBoardAjaxPagingList(Vo);
		}catch(Exception e) {
			e.printStackTrace();
			log.info("DATA_FAILURE_LOG[sampleBoardAjaxPagingList]_____[" + e.getMessage() + "]");
		}finally {
			
		}
		
		return list;
	}

	
}
