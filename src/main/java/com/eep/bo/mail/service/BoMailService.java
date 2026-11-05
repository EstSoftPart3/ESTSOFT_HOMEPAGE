package com.eep.bo.mail.service;

import java.util.List;
import java.util.Map;

public interface BoMailService {

	/**
	 * 업무툴 - 메일계정 관리 Service
	 *
	 * **/

	List<Map<String, Object>> AcctList();							//메일 계정 목록(비밀번호 제외)
	void AcctAdd(Map<String, Object> param, String emplyId);		//Gmail 로그인 확인 후 등록
	void AcctDelete(Map<String, Object> param);						//메일 계정 삭제

}
