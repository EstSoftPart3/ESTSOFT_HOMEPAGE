package com.eep.fo.login.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.eep.mapper.FoLoginMapper;

@Repository
public class FoLoginDao {

	@Autowired
	private FoLoginMapper FoLoginMapper;
	
	public Map<String, Object> loginAdminData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
				
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> loginInfo = FoLoginMapper.loginAdminData(param);
		
		result.put("loginInfo", loginInfo);
				
		return result;
	}
}

