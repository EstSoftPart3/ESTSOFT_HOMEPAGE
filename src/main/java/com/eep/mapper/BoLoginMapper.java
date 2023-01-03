package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

import com.eep.bo.login.vo.LoginVo;

@MapperScan
public interface BoLoginMapper {
	
	/**
	 * 로그인 Mapper Interface
	 * 
	 * **/

	public List loginAdminData(Map<String, Object> param);						//공지사항 게시판 리스트

}
