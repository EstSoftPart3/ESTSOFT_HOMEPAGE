package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;


@MapperScan
public interface BoLoginMapper {
	
	/**
	 * 로그인 Mapper Interface
	 * 
	 * **/

	public List loginAdminData(Map<String, Object> param);						//공지사항 게시판 리스트
	public int insertLoginToken(Map<String, Object> param);						//자동로그인 토큰 등록
	public Map<String, Object> selectLoginToken(Map<String, Object> param);		//유효한 토큰의 관리자 정보
	public int deleteLoginToken(Map<String, Object> param);						//자동로그인 토큰 삭제
	public int deleteExpiredLoginToken();										//만료된 토큰 정리

}
