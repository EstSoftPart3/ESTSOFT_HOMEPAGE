package com.eep.fo.login.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.eep.fo.login.dao.FoLoginDao;

@Service
public class FoLoginServiceImpl implements FoLoginService{

	@Autowired
	private FoLoginDao FoLoginDao;

	
	@Override
	public Map<String, Object> loginAdminData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = FoLoginDao.loginAdminData(param);
		
		return result;
	}
	
}
