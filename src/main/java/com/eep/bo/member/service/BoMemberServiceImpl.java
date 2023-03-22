package com.eep.bo.member.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.eep.bo.member.dao.BoMemberDao;

@Service
public class BoMemberServiceImpl implements BoMemberService {

	@Autowired
	private BoMemberDao BoMemeberDao;
	
	//직원정보 목록
	@Override
	public Map<String, Object> memberList(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoMemeberDao.memberList(param);
		
		return result;
	}
		
	//직원정보 상세
	@Override
	public Map<String, Object> memberContent(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoMemeberDao.memberContent(param);
		
		return result;
	}
	
	//직원정보 입력
	@Override
	public void memberInsert(Map<String, Object> param){
		BoMemeberDao.memberInsert(param);
	}
	
	//직원정보 수정
	@Override
	public int memberUpdate(Map<String, Object> param){
		int updateState = -1;
		
		updateState = BoMemeberDao.memberUpdate(param);
		
		return updateState;
	}
	
	//직원 비밀번호 초기화
	@Override
	public int memberPasswdClear(Map<String, Object> param){
		int updateState = -1;
		
		updateState = BoMemeberDao.memberPasswdClear(param);
		
		return updateState;
	}

	//직원 탈퇴 복구
	@Override
	public void outMember(Map<String, Object> param) {
		BoMemeberDao.outMember(param);
	}
	
}
