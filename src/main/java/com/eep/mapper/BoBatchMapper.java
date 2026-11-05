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
	public int alterBatchLogForIcal();											//실행 이력에 주소 이름 칸 추가(있으면 그대로)
	public int createBatchLogDetailTable();										//실행 상세 테이블 생성(있으면 그대로)
	public int alterBatchLogDetailForResume();									//실행 상세에 이력서 처리 결과 칸 추가(있으면 그대로)
	public Map<String, Object> selectIntvResumeCheck(Map<String, Object> param);	//이력서로 채울 칸의 현재 값
	public int updateIntvFromResume(Map<String, Object> param);					//이력서 값으로 빈 칸 채우기
	public int createBatchIcalTable();											//iCal 주소 테이블 생성(있으면 그대로)
	public int moveConfIcalToList();											//설정 테이블의 주소를 목록으로 복사
	public int deleteConfIcal();												//목록으로 옮긴 설정 삭제

	public int countIntvAt(Map<String, Object> param);							//해당 일시의 취소되지 않은 면접 수
	public Map<String, Object> selectIntvByGcalId(Map<String, Object> param);	//일정 ID 로 면접자 찾기
	public Map<String, Object> selectIntvToLink(Map<String, Object> param);		//아직 일정과 연결 안 된 같은 이름·날짜의 면접자 찾기
	public int insertBatchIntv(Map<String, Object> param);						//면접자 등록
	public int updateBatchIntv(Map<String, Object> param);						//일정·빈 칸 반영

	public int insertBatchLog(Map<String, Object> param);						//실행 이력 저장
	public int insertBatchLogDetail(Map<String, Object> param);					//일정별 처리 결과 저장
	public List<Map<String, Object>> selectBatchLogList(Map<String, Object> param);	//최근 실행 이력
	public List<Map<String, Object>> selectBatchLogDetail(Map<String, Object> param);	//한 실행의 일정별 처리 결과

	public List<Map<String, Object>> selectIcalList();							//주소 목록(비공개 주소 제외)
	public List<Map<String, Object>> selectIcalAutoList();						//자동 실행 대상(비공개 주소 포함)
	public Map<String, Object> selectIcalOne(Map<String, Object> param);		//주소 한 건(비공개 주소 포함)
	public int alterIcalForDrive();												//세트에 드라이브 칸 추가(있으면 그대로)
	public int moveConfFolderToIcal();											//설정 테이블의 이력서 폴더를 세트로 복사
	public int deleteConfFolder();												//세트로 옮긴 폴더 설정 삭제
	public int updateIcal(Map<String, Object> param);							//세트 수정
	public int updateIcalDrive(Map<String, Object> param);						//세트에 드라이브 계정 연결
	public int insertIcal(Map<String, Object> param);							//주소 등록
	public int deleteIcal(Map<String, Object> param);							//주소 삭제
	public int updateIcalAuto(Map<String, Object> param);						//자동 실행 여부 변경

}
