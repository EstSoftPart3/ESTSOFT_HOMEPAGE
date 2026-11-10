package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

@MapperScan
public interface BoDeployMapper {

	/**
	 * 직원 - 투입현황·급여관리·매출/매입처 Mapper Interface
	 *
	 * **/

	public List<Map<String, Object>> selectCodes();								//HR_EMP_TYPE, HR_DEPLOY_GRADE
	public List<Map<String, Object>> selectStaffOptions();						//재직·대기 직원
	public String selectPref(Map<String, Object> param);						//EMPLY_ID, PREF_KEY
	public int savePref(Map<String, Object> param);								//EMPLY_ID, PREF_KEY, PREF_VAL
	public int deletePref(Map<String, Object> param);							//EMPLY_ID, PREF_KEY

	public List<Map<String, Object>> selectPartnerList();						//파일 내용 제외
	public Map<String, Object> selectPartnerFile(Map<String, Object> param);	//PARTNER_SQ 의 FILE_NM, FILE_TYPE, FILE_DATA
	public int countBizNo(Map<String, Object> param);							//BIZ_NO, 자기 PARTNER_SQ 제외
	public int countPartnerUse(Map<String, Object> param);						//PARTNER_SQ 를 쓰는 투입 건 수
	public int insertPartner(Map<String, Object> param);
	public int updatePartner(Map<String, Object> param);
	public int deletePartner(Map<String, Object> param);

	public List<Map<String, Object>> selectDeployList();						//전체 투입 건 + 직원·거래처 이름
	public int insertDeploy(Map<String, Object> param);
	public int updateDeploy(Map<String, Object> param);
	public int deleteDeploy(Map<String, Object> param);
	public int countDeployClosed(Map<String, Object> param);					//DEPLOY_SQ 가 들어간 마감 월 수

	public String selectClosed(Map<String, Object> param);						//PAY_YM 의 CLOSED_YN
	public int saveClosed(Map<String, Object> param);							//PAY_YM, CLOSED_YN, EMPLY_ID
	public List<Map<String, Object>> selectPayrollRows(Map<String, Object> param);		//YM 또는 YEAR, STAFF_SQ
	public List<Map<String, Object>> selectPayrollDetails(Map<String, Object> param);	//YM 또는 YEAR, STAFF_SQ
	public int savePayrollDetail(Map<String, Object> param);
	public int deletePayrollDetailsExcept(Map<String, Object> param);			//YM, KEEP(유지할 DEPLOY_SQ 목록)
	public int insertPayroll(Map<String, Object> param);						//YM, STAFF_SQ, EMP_TYPE_CD, BASE_AMT, MEAL_AMT, BONUS_AMT
	public int updatePayrollAuto(Map<String, Object> param);					//위 칸을 다시 계산한 값으로
	public int deleteEmptyPayroll(Map<String, Object> param);					//YM, KEEP(유지할 STAFF_SQ) 외 입력 없는 행
	public int updatePayrollField(Map<String, Object> param);					//YM, STAFF_SQ, FIELD(서비스의 허용 목록), VALUE, MANUAL_FIELDS
	public int updatePayrollDeductions(Map<String, Object> param);				//대장의 공제 칸과 LEDGER_PAY
	public int insertPayrollChange(Map<String, Object> param);
	public List<Map<String, Object>> selectLedgerCodes();						//SRC_CD, LEDGER_CD, STAFF_SQ
	public int saveLedgerCode(Map<String, Object> param);
}
