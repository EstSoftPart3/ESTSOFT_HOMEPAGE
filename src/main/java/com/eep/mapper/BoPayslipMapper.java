package com.eep.mapper;

import java.util.List;
import java.util.Map;

/** 급여명세서: 보내는 메일 설정, 설정 이력, 발송 이력. 표는 sql/payslip.sql */
public interface BoPayslipMapper {
	public List<Map<String, Object>> selectStaffInfo();							//STAFF_SQ, 이름·직급·부서·입사일·개인 메일·주민번호(암호문)
	public String selectEmplyEmail(Map<String, Object> param);					//EMPLY_ID 의 계정 메일(시험 발송 받는 곳)
	public Map<String, Object> selectConf();									//설정 한 벌 (APP_PW_ENC 포함, 서비스 밖으로 내보내지 않는다)
	public int updateConfAccount(Map<String, Object> param);					//계정 칸. APP_PW_ENC 가 null 이면 비밀번호는 그대로
	public int updateConfBody(Map<String, Object> param);						//SUBJECT, BODY
	public int updateConfVerified(Map<String, Object> param);					//VERIFIED_YN
	public int insertConfHist(Map<String, Object> param);						//KIND_CD, SUMMARY, SUBJECT, BODY, EMPLY_ID
	public List<Map<String, Object>> selectConfHist();							//최근 50건 (본문 제외)
	public Map<String, Object> selectConfHistOne(Map<String, Object> param);	//HIST_SQ 의 SUBJECT, BODY
	public int insertLog(Map<String, Object> param);							//YM, STAFF_SQ, CHANNEL, TO_ADDR, RESULT, ERROR_MSG, EMPLY_ID
	public List<Map<String, Object>> selectLastLogs(Map<String, Object> param);	//YM → 사람별 마지막 발송
	public List<Map<String, Object>> selectLogs(Map<String, Object> param);		//YM, STAFF_SQ
}
