package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

/** 경영지원 - 법인카드 */
@MapperScan
public interface BoCardMapper {

	public int ensureSchema();

	public List<Map<String, Object>> selectCodes();

	public List<Map<String, Object>> selectCards(Map<String, Object> param);
	public int insertCard(Map<String, Object> param);
	public int updateCard(Map<String, Object> param);

	public List<Map<String, Object>> selectMonthUses(Map<String, Object> param);
	public int insertUse(Map<String, Object> param);
	public int updateUse(Map<String, Object> param);
	public int deleteUse(Map<String, Object> param);
	public int updateMerchant(Map<String, Object> param);

	public Map<String, Object> selectSettle(Map<String, Object> param);
	public int upsertSettle(Map<String, Object> param);
}
