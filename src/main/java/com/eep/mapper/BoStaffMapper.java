package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

@MapperScan
public interface BoStaffMapper {

	/**
	 * 직원 - 직원관리(인사카드) Mapper Interface
	 *
	 * **/

	public List<Map<String, Object>> selectStaffList();							//재직·퇴사 전체 (주민번호·계좌번호는 암호문 그대로)
	public String selectStaffSecret(Map<String, Object> param);					//STAFF_SQ, COL(RRN_ENC|ACCOUNT_ENC) 의 암호문
	public int insertStaff(Map<String, Object> param);							//등록 (STATUS_CD, STAFF_NM)
	public int updateStaffField(Map<String, Object> param);						//한 칸 수정 (FIELD 는 서비스의 허용 목록)
	public int deleteStaff(Map<String, Object> param);							//삭제

	public Map<String, Object> selectStaffOne(Map<String, Object> param);		//STAFF_SQ 한 명 (암호문 포함, 서버 안에서만 쓴다)
	public int updateStaffFolder(Map<String, Object> param);					//STAFF_SQ, DRIVE_FOLDER_ID
	public List<Map<String, Object>> selectStaffDocList(Map<String, Object> param);	//STAFF_SQ 의 서류 파일
	public int insertStaffDoc(Map<String, Object> param);						//서류 파일 연결 (같은 파일·칸이면 무시)
	public int deleteStaffDoc(Map<String, Object> param);						//DOC_SQ, STAFF_SQ 연결 끊기 (드라이브 파일은 둔다)
}
