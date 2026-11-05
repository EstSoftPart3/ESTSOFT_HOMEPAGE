package com.eep.bo.mail.dao;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.eep.mapper.BoMailMapper;

@Repository
public class BoMailDao {

	@Autowired
	BoMailMapper BoMailMapper;

	public List<Map<String, Object>> AcctList() {
		return BoMailMapper.selectAcctList();
	}

	public int AcctInsert(Map<String, Object> param) {
		return BoMailMapper.insertAcct(param);
	}

	public int AcctDelete(Map<String, Object> param) {
		return BoMailMapper.deleteAcct(param);
	}
}
