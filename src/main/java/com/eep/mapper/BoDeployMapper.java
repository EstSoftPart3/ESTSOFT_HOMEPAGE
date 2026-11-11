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
	public Map<String, Object> selectPartnerAttach(Map<String, Object> param);	//PARTNER_SQ, FILE_CD 의 FILE_NM, FILE_TYPE, FILE_DATA
	public int savePartnerFile(Map<String, Object> param);						//PARTNER_SQ, FILE_CD, FILE_NM, FILE_TYPE, FILE_DATA
	public int deletePartnerFile(Map<String, Object> param);					//PARTNER_SQ (+ FILE_CD 있으면 그것만)

	public List<Map<String, Object>> selectDeployList();						//전체 투입 건 + 직원·거래처 이름
	public int insertDeploy(Map<String, Object> param);
	public int updateDeploy(Map<String, Object> param);
	public int deleteDeploy(Map<String, Object> param);
	public int countDeployClosed(Map<String, Object> param);					//DEPLOY_SQ 가 들어간 마감 월 수
	public String selectPayDate(Map<String, Object> param);						//YM 의 지급일자
	public int savePayDate(Map<String, Object> param);							//YM, PAY_DT, EMPLY_ID
	public List<Map<String, Object>> selectMemoCounts(Map<String, Object> param);	//YM → STAFF_SQ, CNT
	public List<Map<String, Object>> selectChangeCounts(Map<String, Object> param);	//YM → STAFF_SQ, CNT
	public List<Map<String, Object>> selectAcks(Map<String, Object> param);			//YM → STAFF_SQ, FLAG_K
	public int saveAck(Map<String, Object> param);								//YM, STAFF_SQ, FLAG_K, EMPLY_ID
	public List<Map<String, Object>> selectMemos(Map<String, Object> param);		//STAFF_SQ (+YM)
	public int insertMemo(Map<String, Object> param);
	public int deleteMemo(Map<String, Object> param);							//MEMO_SQ, EMPLY_ID(본인 것만)
	public List<Map<String, Object>> selectChanges(Map<String, Object> param);		//STAFF_SQ (+YM)
	public Map<String, Object> selectChange(Map<String, Object> param);			//CHG_SQ
	public int markReverted(Map<String, Object> param);							//CHG_SQ
	public Map<String, Object> selectStaffCard(Map<String, Object> param);		//STAFF_SQ 인적사항 (주민번호는 서버 안에서만)
	public int updateDeployEnd(Map<String, Object> param);						//연장: DEPLOY_SQ, END_DT, (CAN_PAY 면) SALE_PRICE·COST_PRICE, MEMO 덧붙임
	public List<Map<String, Object>> selectStaffPrjs(Map<String, Object> param);	//STAFF_SQ 의 인사카드 수행이력

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
	public List<Map<String, Object>> selectStaffAcks(Map<String, Object> param);	//STAFF_SQ 의 상여 제외(✕) 달
	public List<Map<String, Object>> selectBonusList();							//상여 조건 + 켠 사람 수
	public List<Map<String, Object>> selectBonusApplies();						//직원관리에서 켠 상여 전체
	public int insertBonus(Map<String, Object> param);
	public int updateBonus(Map<String, Object> param);
	public int updateBonusUse(Map<String, Object> param);						//BONUS_SQ, USE_YN
	public int deleteBonus(Map<String, Object> param);							//켠 사람이 없을 때만 지운다
	public int saveBonusApply(Map<String, Object> param);						//BONUS_SQ, STAFF_SQ, AMT, REFERRER_SQ, EMPLY_ID
	public int deleteBonusApply(Map<String, Object> param);
	public Map<String, Object> selectDeployOne(Map<String, Object> param);		//DEPLOY_SQ
	public int insertDeployChange(Map<String, Object> param);					//DEPLOY_SQ, STAFF_SQ, FIELD, BEFORE_VAL, AFTER_VAL, REASON, EMPLY_ID
	public List<Map<String, Object>> selectDeployChanges(Map<String, Object> param);	//STAFF_SQ
	public Map<String, Object> selectDeployChange(Map<String, Object> param);		//CHG_SQ
	public int markDeployReverted(Map<String, Object> param);
	public List<Map<String, Object>> selectDeployChangeCounts();				//STAFF_SQ, CNT
	public List<Map<String, Object>> selectDeployMemos(Map<String, Object> param);	//STAFF_SQ
	public int insertDeployMemo(Map<String, Object> param);
	public int deleteDeployMemo(Map<String, Object> param);						//MEMO_SQ, EMPLY_ID(본인 것만)
	public String selectDeployMemoStaff(Map<String, Object> param);				//MEMO_SQ 의 STAFF_SQ
	public List<Map<String, Object>> selectDeployMemoCounts();					//STAFF_SQ, CNT
	public List<String> selectSecretStaff();									//시크릿 계정에 연결된 직원
	public int countSecretViewer(Map<String, Object> param);					//EMPLY_ID 가 사용 중인 시크릿 계정인지
	public String selectDeployStaff(Map<String, Object> param);					//DEPLOY_SQ 의 STAFF_SQ
	public List<Map<String, Object>> selectLedgerCodes();						//SRC_CD, LEDGER_CD, STAFF_SQ
	public int saveLedgerCode(Map<String, Object> param);
}
