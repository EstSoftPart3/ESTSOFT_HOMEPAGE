package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

@MapperScan
public interface BoBatchMapper {

	/**
	 * 배치 Mapper Interface
	 *
	 * **/

	public int alterIntvForBatch();												//면접자 테이블에 일정 ID 칸 추가(있으면 그대로)
	public int createBatchLogTable();											//실행 이력 테이블 생성(있으면 그대로)
	public Map<String, Object> selectIntvByGcalId(Map<String, Object> param);	//일정 ID 로 면접자 찾기
	public Map<String, Object> selectIntvToLink(Map<String, Object> param);		//아직 일정과 연결 안 된 같은 이름·날짜의 면접자 찾기
	public int insertBatchIntv(Map<String, Object> param);						//면접자 등록
	public int updateBatchIntv(Map<String, Object> param);						//일정·빈 칸 반영
	public int insertBatchLog(Map<String, Object> param);						//실행 이력 저장
	public List<Map<String, Object>> selectBatchLogList(Map<String, Object> param);	//최근 실행 이력

}
