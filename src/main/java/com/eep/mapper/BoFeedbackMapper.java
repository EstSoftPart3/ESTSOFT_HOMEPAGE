package com.eep.mapper;

import java.util.List;
import java.util.Map;

/** 피드백·업데이트 내역. 표는 sql/feedback_update.sql */
public interface BoFeedbackMapper {
	public int insertFeedback(Map<String, Object> param);						//SCREEN_NM, SCREEN_URL, KIND_CD, CONTENT, EMPLY_ID
	public List<Map<String, Object>> selectFeedbacks();							//전체(기획서 HTML 제외), 최근 것부터
	public Map<String, Object> selectFeedback(Map<String, Object> param);		//FB_SQ → 기획서 HTML 포함
	public int updateFeedbackAct(Map<String, Object> param);					//FB_SQ, STATUS_CD, DEV_NOTE, REJECT_REASON, ACT_EMPLY_ID (반영된 건은 안 바뀜)
	public int insertComment(Map<String, Object> param);						//FB_SQ, CONTENT, EMPLY_ID → 로그 + 접수로(반영·반려 건 제외)
	public List<Map<String, Object>> selectLogs(Map<String, Object> param);		//FB_SQ → 코멘트·기획서 변경 로그(기획서 HTML 제외)
	public Map<String, Object> selectLogSpec(Map<String, Object> param);		//LOG_SQ → 그때의 기획서
	public int countUnseen(Map<String, Object> param);							//EMPLY_ID: 상태가 바뀌었는데 안 본 내 피드백
	public int updateSeen(Map<String, Object> param);							//EMPLY_ID
	public List<Map<String, Object>> selectUpdates(Map<String, Object> param);	//LIMIT(없으면 전체), MAJOR(있으면 주요 변경만) → 기획서 HTML 제외, SUMMARY 는 수정한 것 첫 줄
	public int updateUpdateKind(Map<String, Object> param);						//UPD_SQ, KIND_CD, MAJOR_YN (sql/update_kind.sql)
	public Map<String, Object> selectUpdate(Map<String, Object> param);			//UPD_SQ → 피드백 요청자·진행자 포함
	public Integer selectLatestUpdate();
}
