package com.eep.bo.member.dao;


import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.eep.mapper.BoMemberMapper;

@Repository
public class BoMemberDao {

	@Autowired
	private BoMemberMapper BoMemberMapper;
	
	//직원정보 목록
	@SuppressWarnings("null")
	public Map<String, Object> memberList(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
				
		System.out.println("MEMBER_LIST_REQUEST = " + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> memberList = BoMemberMapper.memberList(param);
		//Map데이터를 List에 삽입
		
		 for(int z=0; z<memberList.size(); z++){
			 String mbrIdDecrypt = (String) memberList.get(z).get("mbrId");	
			 String mbrEmailDecrypt = (String) memberList.get(z).get("mbrEmail");	
			 String mbrCpNumDecrypt = (String) memberList.get(z).get("mbrPhNum");	
			 String mbrHomeAddrDecrypt = (String) memberList.get(z).get("mbrHomeAddr");	
			
			 memberList.get(z).put("mbrId", mbrIdDecrypt);
			 memberList.get(z).put("mbrEmail", mbrEmailDecrypt);
			 memberList.get(z).put("mbrPhNum", mbrCpNumDecrypt);
			 memberList.get(z).put("mbrHomeAddr", mbrHomeAddrDecrypt);
		  }
		
		result.put("memberList", memberList);
		
		return result;
	}
	
	//직원정보 상세
	public Map<String, Object> memberContent(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		System.out.println("MEMBER_CONTENT_REQUEST = " + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> memberContent = BoMemberMapper.memberContent(param);
		
		for(int z=0; z<memberContent.size(); z++){
		 	
			 String mbrIdDecrypt = (String) memberContent.get(z).get("mbrId");	
			 String mbrEmailDecrypt = (String) memberContent.get(z).get("mbrEmail");	
			 String mbrCpNumDecrypt = (String) memberContent.get(z).get("mbrPhNum");	
			 String mbrHomeAddrDecrypt = (String) memberContent.get(z).get("mbrHomeAddr");

			 memberContent.get(z).put("mbrId", mbrIdDecrypt);
			 memberContent.get(z).put("mbrEmail", mbrEmailDecrypt);
			 memberContent.get(z).put("mbrPhNum", mbrCpNumDecrypt);
			 memberContent.get(z).put("mbrHomeAddr", mbrHomeAddrDecrypt);
		  }
		
		result.put("memberContent", memberContent);
		
		return result;
	}
	
	//직원정보 입력
	public void memberInsert(Map<String, Object> param){
		
		System.out.println("MEMBER_INSERT_REQUEST = " + param);
		BoMemberMapper.memberInsert(param);
		
	}
	
	//직원정보 수정
	public int memberUpdate(Map<String, Object> param){
		
		int updateState = -1;
		
		updateState =  BoMemberMapper.memberUpdate(param);
		
		return updateState;
		
	}
	
	//직원 비밀번호 초기화
	public int memberPasswdClear(Map<String, Object> param){
		
		int updateState = -1;
		
		updateState =  BoMemberMapper.memberPasswdClear(param);
		
		return updateState;
		
	}
	
	//직원 탈퇴 복구
	public void outMember(Map<String, Object> param) {
		BoMemberMapper.outMember(param);
	}
	
}
