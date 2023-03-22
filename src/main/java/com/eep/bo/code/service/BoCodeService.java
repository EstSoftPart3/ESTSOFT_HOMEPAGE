package com.eep.bo.code.service;

import java.util.Map;

public interface BoCodeService {

	/**
	 * 코드관리 게시판 Service Interface
	 * 
	 * **/
	
	public Map<String, Object> CodeList(Map<String, Object> param); 		//공통코드 게시판 리스트
	public int CodeInsert(Map<String, Object> param);						//공통코드 게시판 등록
	public int CodeUpdate(Map<String, Object> param);						//공통코드 게시판 수정
	public int CodeDelete(Map<String, Object> param);						//공통코드 게시판 삭제
	public Map<String, Object> SubCodeList(Map<String, Object> param);		//공통서브코드 게시판 리스트
	public int SubCodeInsert(Map<String, Object> param);					//공통서브코드 게시판 입력
	public int SubCodeUpdate(Map<String, Object> param);					//공통서브코드 게시판 수정
	public int SubCodeDelete(Map<String, Object> param);					//공통서브코드 게시판 삭제
	
}
