package com.eep.mapper;

import java.util.List;
import java.util.Map;

/** 계정별 구글 연동. 표는 sql/google_link.sql */
public interface BoGoogleLinkMapper {
	public List<Map<String, Object>> selectLinks(Map<String, Object> param);		//EMPLY_ID → SERVICE_CD, ACCOUNT, REG_DT (토큰 제외)
	public String selectRefresh(Map<String, Object> param);						//EMPLY_ID, SERVICE_CD → REFRESH_ENC
	public int saveLink(Map<String, Object> param);								//EMPLY_ID, SERVICE_CD, REFRESH_ENC, ACCOUNT
	public int deleteLink(Map<String, Object> param);							//EMPLY_ID, SERVICE_CD
}
