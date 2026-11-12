package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

/** 영업 > 업체 - 매출관리·매입관리 */
@MapperScan
public interface BoTradeMapper {

	public int ensureSchema();

	public List<Map<String, Object>> selectPartners();
	public List<String> selectTypes(Map<String, Object> param);
	public List<Map<String, Object>> selectDeployLines(Map<String, Object> param);
	public List<Map<String, Object>> selectTrades(Map<String, Object> param);
	public List<Map<String, Object>> selectLines(Map<String, Object> param);
	public String selectIssueDt(Map<String, Object> param);
	public String selectTradeYm(Map<String, Object> param);

	public int insertTrade(Map<String, Object> param);
	public int updateTrade(Map<String, Object> param);
	public int deleteTrade(Map<String, Object> param);
	public int deleteLine(Map<String, Object> param);
	public int upsertLayout(Map<String, Object> param);
	public int upsertAmt(Map<String, Object> param);
	public int updateIssue(Map<String, Object> param);
}
