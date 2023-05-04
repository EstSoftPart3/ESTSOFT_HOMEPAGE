package com.eep.bo.login.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.eep.mapper.BoLoginMapper;

@Repository
public class BoLoginDao {

	@Autowired
	private BoLoginMapper BoLoginMapper;

	
}
