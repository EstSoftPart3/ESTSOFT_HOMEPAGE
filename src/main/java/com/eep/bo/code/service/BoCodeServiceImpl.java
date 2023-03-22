package com.eep.bo.code.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.eep.bo.code.dao.BoCodeDao;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class BoCodeServiceImpl implements BoCodeService{

	@Autowired
	BoCodeDao BoCodeDao;
	
	//공통코드 리스트
	@Override
	public Map<String, Object> CodeList(Map<String, Object> param){
		Map<String, Object> result = new HashMap<>();
		result = BoCodeDao.CodeList(param);
		return result;
	}
	
	//공통코드 입력
	@Override
	public int CodeInsert(Map<String, Object> param) {
		int resultState = -1;
		resultState = BoCodeDao.CodeInsert(param);
		return resultState;
	}
	
	//공통코드 수정
	@Override
	public int CodeUpdate(Map<String, Object> param) {
		int resultState = -1;
		resultState = BoCodeDao.CodeUpdate(param);
		return resultState;
	}
	
	//공통코드 삭제
	@Override
	public int CodeDelete(Map<String, Object> param) {
		int resultState = -1;
		resultState = BoCodeDao.CodeDelete(param);
		return resultState;
	}
	
	
	//공통 서브코드 리스트
	@Override
	public Map<String, Object> SubCodeList(Map<String, Object> param){
		Map<String, Object> result = new HashMap<>();
		result = BoCodeDao.SubCodeList(param);
		return result;
	}
	
	//공통 서브코드 입력
	@Override
	public int SubCodeInsert(Map<String, Object> param) {
		int resultState = -1;
		resultState = BoCodeDao.SubCodeInsert(param);
		return resultState;
	}
	
	//공통 서브코드 수정
	@Override
	public int SubCodeUpdate(Map<String, Object> param) {
		int resultState = -1;
		resultState = BoCodeDao.SubCodeUpdate(param);
		return resultState;
	}
	//공통 서브코드 삭제
	@Override
	public int SubCodeDelete(Map<String, Object> param) {
		int resultState = -1;
		resultState = BoCodeDao.SubCodeDelete(param);
		return resultState;
	}
	
}
