package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

@MapperScan
public interface BoMailMapper {

	/**
	 * 업무툴 - 메일계정 관리 Mapper Interface
	 *
	 * **/

	public List<Map<String, Object>> selectAcctList();			//메일 계정 목록(비밀번호 제외)
	public int insertAcct(Map<String, Object> param);			//메일 계정 등록
	public int deleteAcct(Map<String, Object> param);			//메일 계정 삭제

}
