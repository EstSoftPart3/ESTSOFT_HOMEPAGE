package com.eep.bo.member.service;

import java.util.Map;

public interface BoMemberService {

	//직원정보 목록
	public Map<String, Object> memberList(Map<String, Object> param);
	
	//직원정보 상세	
	public Map<String, Object> memberContent(Map<String, Object> param);
	
	//직원정보 등록
	public void memberInsert(Map<String, Object> param);
	
	//직원정보 수정
	public int memberUpdate(Map<String, Object> param);
	
	//직원 비밀번호 초기화
	public int memberPasswdClear(Map<String, Object> param);
	
	//직원 탈퇴 복구
	public void outMember(Map<String, Object> param);

}
