package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

@MapperScan
public interface BoMemberMapper {

	//직원 목록
	public List memberList(Map<String, Object> param);
	
	//직원 상세
	public List memberContent(Map<String, Object> param);
	
	//직원 가입
	public void memberInsert(Map<String, Object> param);
	
	//직원 수정
	public int memberUpdate(Map<String, Object> param);
	
	//직원 비밀번호 초기화
	public int memberPasswdClear(Map<String, Object> param);
	
	//직원 탈퇴 복구
	public void outMember(Map<String, Object> param);
	
}
