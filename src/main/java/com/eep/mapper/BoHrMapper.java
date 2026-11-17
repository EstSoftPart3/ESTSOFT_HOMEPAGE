package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

@MapperScan
public interface BoHrMapper {

	/**
	 * 업무툴 - 면접·교육생 관리 Mapper Interface
	 *
	 * **/

	public List<Map<String, Object>> selectHrCodeList();						//공통코드 중 HR_ 그룹 전체(GRP, CD, NM)
	public List<Map<String, Object>> selectIntvList();							//면접자 전체 목록(교육생 등록 여부 포함)
	public int insertIntv(Map<String, Object> param);							//면접자 등록
	public int updateIntv(Map<String, Object> param);							//면접자 수정
	public int deleteIntv(Map<String, Object> param);							//면접자 삭제
	public Map<String, Object> selectIntvResume(Map<String, Object> param);		//면접자 이력서 찾기용 면접일자·이름·파일 ID
	public int updateIntvResume(Map<String, Object> param);						//캘린더로 올린 이력서 파일 ID
	public int countIntvSameDay(Map<String, Object> param);						//같은 면접일·이름 면접자 수(이력서 폴더를 같이 씀)
	public int insertTraineeFromIntv(Map<String, Object> param);				//면접자 -> 교육생 등록

	public List<Map<String, Object>> selectTraineeList();						//교육생 전체 목록
	public int updateTraineeWeek(Map<String, Object> param);					//교육생 주차 보정값 저장
	public int insertTrainee(Map<String, Object> param);						//교육생 등록
	public int updateTrainee(Map<String, Object> param);						//교육생 수정
	public int updateTraineeField(Map<String, Object> param);					//교육생 칸 하나 수정
	public int updateIntvField(Map<String, Object> param);						//면접자 칸 하나 수정
	public int clearIntvReferrer(Map<String, Object> param);					//면접자 추천자명 지우기
	public int updateTraineeSkill(Map<String, Object> param);					//교육생 기술 평가 한 칸 수정
	public int deleteTrainee(Map<String, Object> param);						//교육생 삭제
	public String selectTraineeStatus(Map<String, Object> param);				//TRN_SQ 의 지금 상태. 없으면 null
	public String selectPersonName(Map<String, Object> param);					//TRN_SQ 면 교육생 이름, 아니면 INTV_SQ 면접자 이름

}
