package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

/** 장비관리 Mapper. 표는 sql/equipment.sql */
@MapperScan
public interface BoEquipmentMapper {

	public List<Map<String, Object>> selectEquipmentList();
	public List<Map<String, Object>> selectStaffOptions();
	public List<String> selectActiveNos(Map<String, Object> param);
	public int insertEquipment(Map<String, Object> param);
	public int updateEquipmentField(Map<String, Object> param);
	public int deleteEquipment(Map<String, Object> param);				//대여이력이 없는 장비만
	public int updateEquipmentRented(Map<String, Object> param);		//보관중 -> 대여중
	public int updateEquipmentDisposed(Map<String, Object> param);		//STATUS_CD 로 폐기·분실

	public List<Map<String, Object>> selectRentList(Map<String, Object> param);
	public int insertRent(Map<String, Object> param);
	public int updateRentField(Map<String, Object> param);
	public int closeRent(Map<String, Object> param);					//RENT_SQ 반납
	public int updateEquipmentReturned(Map<String, Object> param);		//RENT_SQ 의 장비를 보관중으로
	public int insertIssueByRent(Map<String, Object> param);
	public int closeRentByEquipment(Map<String, Object> param);			//분실 처리 때 진행 중 대여를 닫는다

	public List<Map<String, Object>> selectIssueList(Map<String, Object> param);
	public int insertIssue(Map<String, Object> param);
	public int closeIssue(Map<String, Object> param);

	public List<Map<String, Object>> selectFileList(Map<String, Object> param);
	public int insertFile(Map<String, Object> param);
	public int deleteFile(Map<String, Object> param);

	public List<Map<String, Object>> selectStaffEquipment(Map<String, Object> param);

	public Map<String, Object> selectOpenAudit();
	public List<Map<String, Object>> selectAuditList();
	public int insertAudit(Map<String, Object> param);
	public int insertAuditDetail(Map<String, Object> param);
	public List<Map<String, Object>> selectAuditDetail(Map<String, Object> param);
	public int updateAuditResult(Map<String, Object> param);			//담당자 입력. 진행 중 회차만
	public int updateAuditSelf(Map<String, Object> param);				//본인 응답. 진행 중 회차의 본인 행만
	public int closeAudit(Map<String, Object> param);
	public int updateLastCheck(Map<String, Object> param);

	public List<Map<String, Object>> selectGroupRents(Map<String, Object> param);
	public Map<String, Object> selectSign(Map<String, Object> param);
	public int insertSign(Map<String, Object> param);
	public String selectSeal();
	public int saveSeal(Map<String, Object> param);

	public Map<String, Object> selectStaffByLogin(Map<String, Object> param);
	public List<Map<String, Object>> selectMyRents(Map<String, Object> param);
}
