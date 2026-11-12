package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

/** 경영지원 - 법인카드 */
@MapperScan
public interface BoCardMapper {

	public int ensureSchema();

	public List<Map<String, Object>> selectCodes();

	public int countManager(String emplyId);
	public List<Map<String, Object>> selectStaffs();
	public Map<String, Object> selectStaff(Map<String, Object> param);
	public int grantCardRole(Map<String, Object> param);

	public List<Map<String, Object>> selectCards(Map<String, Object> param);
	public int insertCard(Map<String, Object> param);
	public int updateCard(Map<String, Object> param);

	public List<Map<String, Object>> selectUses(Map<String, Object> param);
	public int insertUse(Map<String, Object> param);
	public int updateUse(Map<String, Object> param);
	public int deleteUse(Map<String, Object> param);
	public int updateSettleUse(Map<String, Object> param);
	public int closeUses(Map<String, Object> param);
	public int reopenUses(Map<String, Object> param);
}
