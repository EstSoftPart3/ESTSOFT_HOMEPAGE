package com.eep.bo.login.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.eep.mapper.BoLoginMapper;

@Repository
public class BoLoginDao {

	@Autowired
	private BoLoginMapper BoLoginMapper;
	
	
	public Map<String, Object> loginAdminData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
				
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> loginInfo = BoLoginMapper.loginAdminData(param);
		
		result.put("loginInfo", loginInfo);
				
		return result;
	}
	
}
