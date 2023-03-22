package com.eep.bo.code.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.eep.mapper.BoCodeMapper;

@Repository
public class BoCodeDao {

	@Autowired
	BoCodeMapper BoCodeMapper;
	
	//공통코드 리스트
	public Map<String, Object> CodeList(Map<String, Object> param){	
		Map<String, Object> result = new HashMap<>();
		
		System.out.println("COMMON_CODE_PARAM = " + param);
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> comCodeListData = BoCodeMapper.CodeList(param);
		
		result.put("comCodeListData", comCodeListData);
		
		return result;
	}
	
	//공통코드 입력
	public int CodeInsert(Map<String, Object> param){
		return BoCodeMapper.CodeInsert(param);
	}
		
	//공통코드 수정
	public int CodeUpdate(Map<String, Object> param){
		return BoCodeMapper.CodeUpdate(param);
	}
	
	//공통코드 삭제
	public int CodeDelete(Map<String, Object> param){
		return BoCodeMapper.CodeDelete(param);
	}
		
	//공통서브코드 리스트
	public Map<String, Object> SubCodeList(Map<String, Object> param){
		Map<String, Object> result = new HashMap<>();
		
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> comSubCodeListData = BoCodeMapper.SubCodeList(param);
		
		result.put("comSubCodeListData", comSubCodeListData);
		
		return result;
	}
	
	//공통 서브코드 입력
	public int SubCodeInsert(Map<String, Object> param){
		return BoCodeMapper.SubCodeInsert(param);
	}
	
	//공통 서브코드 수정
	public int SubCodeUpdate(Map<String, Object> param){
		return BoCodeMapper.SubCodeUpdate(param);
	}
	
	//공통 서브코드 삭제
	public int SubCodeDelete(Map<String, Object> param){
		return BoCodeMapper.SubCodeDelete(param);
	}
	
}
