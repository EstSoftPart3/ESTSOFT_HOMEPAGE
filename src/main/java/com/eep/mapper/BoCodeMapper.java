package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

@MapperScan
public interface BoCodeMapper {

	//공통코드 리스트
	public List CodeList(Map<String, Object> param);
		
	//공통코드 입력
	public int CodeInsert(Map<String, Object> param);
		
	//공통코드 수정
	public int CodeUpdate(Map<String, Object> param);
		
	//공통코드 삭제
	public int CodeDelete(Map<String, Object> param);
		
	//공통 서브코드 리스트
	public List SubCodeList(Map<String, Object> param);
		
	//공통 서브코드 입력
	public int SubCodeInsert(Map<String, Object> param);
		
	//공통코드 서브코드 수정
	public int SubCodeUpdate(Map<String, Object> param);
	
	//공통코드 서브코드 삭제
	public int SubCodeDelete(Map<String, Object> param);
		
}
