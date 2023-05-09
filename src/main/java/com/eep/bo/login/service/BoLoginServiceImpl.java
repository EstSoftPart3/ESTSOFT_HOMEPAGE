package com.eep.bo.login.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.eep.bo.login.dao.BoLoginDao;

@Service
public class BoLoginServiceImpl implements BoLoginService{

	@Autowired
	private BoLoginDao BoLoginDao;

	
	@Override
	public Map<String, Object> loginAdminData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoLoginDao.loginAdminData(param);
		
		return result;
	}
	
}
