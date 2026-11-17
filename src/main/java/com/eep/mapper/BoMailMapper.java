package com.eep.mapper;

import java.util.List;
import java.util.Map;

/** 메일 설정: 보내는 계정, 메일별 계정·받는 사람, 변경 이력. 표는 sql/mail_conf.sql */
public interface BoMailMapper {
	public List<Map<String, Object>> selectAccounts();							//계정 전부 (APP_PW_ENC 포함, 서비스 밖으로 내보내지 않는다)
	public Map<String, Object> selectAccountOfUse(String useCd);				//그 메일이 쓰는 계정 (APP_PW_ENC 포함)
	public int insertAccount(Map<String, Object> param);						//→ ACC_SQ
	public int updateAccount(Map<String, Object> param);						//APP_PW_ENC 가 null 이면 비밀번호는 그대로, RESET_VERIFIED 면 연결 확인 지움
	public int updateVerified(Map<String, Object> param);						//ACC_SQ, VERIFIED_YN, VERIFY_MSG
	public List<Map<String, Object>> selectUses();								//USE_CD, ACC_SQ, TO_LIST
	public int updateUse(Map<String, Object> param);							//USE_CD, ACC_SQ, TO_LIST, EMPLY_ID
	public List<Map<String, Object>> selectUsers();								//받는 사람·보내는 계정 고르기용 계정 목록
	public List<Map<String, Object>> selectUserMails(List<String> ids);			//EMPLY_ID → EMPLY_NM, EMPLY_EMAIL
	public String selectMyMail(String emplyId);
	public int insertHist(Map<String, Object> param);							//TARGET, SUMMARY, EMPLY_ID
	public List<Map<String, Object>> selectHist();								//최근 200건
}
