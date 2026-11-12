package com.eep.mapper;

import java.util.List;
import java.util.Map;

/** 목록 메모(직원·면접·교육생·장비·연구팀). 표는 sql/row_memo.sql */
public interface BoMemoMapper {
	public List<Map<String, Object>> selectMemos(Map<String, Object> param);		//TARGET_CD, TARGET_SQ
	public int insertMemo(Map<String, Object> param);							//TARGET_CD, TARGET_SQ, CONTENT, EMPLY_ID
	public int deleteMemo(Map<String, Object> param);							//MEMO_SQ, TARGET_CD, EMPLY_ID(본인 것만)
	public String selectMemoTarget(Map<String, Object> param);					//MEMO_SQ, TARGET_CD 의 TARGET_SQ
	public List<Map<String, Object>> selectMemoCounts(Map<String, Object> param);	//TARGET_CD → TARGET_SQ, CNT
}
