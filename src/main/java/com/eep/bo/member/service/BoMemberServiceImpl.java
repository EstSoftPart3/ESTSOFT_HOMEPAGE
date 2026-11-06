package com.eep.bo.member.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.eep.bo.member.dao.BoMemberDao;

import common.util.PasswordHasher;
import common.util.RrnCipher;

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

		@SuppressWarnings("unchecked")
		List<Map<String, Object>> rows = (List<Map<String, Object>>) result.get("memberContent");
		for (Map<String, Object> row : rows) {
			row.put("mbrRrn", RrnCipher.maskStored((String) row.get("mbrRrn")));
		}

		return result;
	}
	
	//직원정보 입력
	@Override
	public void memberInsert(Map<String, Object> param){
		param.put("mbrPasswrd", PasswordHasher.hash((String) param.get("mbrPasswrd")));
		encryptRrn(param);
		BoMemeberDao.memberInsert(param);
	}
	
	//직원정보 수정
	@Override
	public int memberUpdate(Map<String, Object> param){
		int updateState = -1;

		if (RrnCipher.isMasked((String) param.get("mbrRrn"))) {
			param.remove("mbrRrn"); // 화면에 가려 보여 준 값이 그대로 왔으면 저장값을 유지한다
		}
		encryptRrn(param);
		updateState = BoMemeberDao.memberUpdate(param);
		
		return updateState;
	}
	
	//직원 비밀번호 초기화
	@Override
	public int memberPasswdClear(Map<String, Object> param){
		int updateState = -1;

		param.put("mbrPasswrd", PasswordHasher.hash((String) param.get("mbrPasswrd")));
		updateState = BoMemeberDao.memberPasswdClear(param);
		
		return updateState;
	}

	private static void encryptRrn(Map<String, Object> param) {
		String rrn = (String) param.get("mbrRrn");
		if (rrn != null && !rrn.trim().isEmpty() && !RrnCipher.isEncrypted(rrn)) {
			param.put("mbrRrn", RrnCipher.encrypt(rrn.trim()));
		}
	}

	//직원 탈퇴 복구
	@Override
	public void outMember(Map<String, Object> param) {
		BoMemeberDao.outMember(param);
	}
	
}
