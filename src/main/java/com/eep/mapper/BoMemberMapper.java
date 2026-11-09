package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

@MapperScan
public interface BoMemberMapper {

	List<Map<String, Object>> selectAccounts();

	List<Map<String, Object>> selectPendingStaff();

	Map<String, Object> selectAccount(int sq);

	Map<String, Object> selectStaffForIssue(int staffSq);

	int countId(Map<String, Object> param);

	void insertAccount(Map<String, Object> param);

	void updateAccount(Map<String, Object> param);

	void renameRoleUser(Map<String, Object> param);

	void renameStaffLink(Map<String, Object> param);

	void updatePassword(Map<String, Object> param);

	void updateStatus(Map<String, Object> param);

	void updateType(Map<String, Object> param);

	void deleteUserRoles(String emplyId);

	int linkStaff(Map<String, Object> param);

	List<Map<String, Object>> searchStaff(String keyword);

	String selectStaffRrn(int staffSq);

	void unlinkStaff(String emplyId);

	String selectPasswordHash(String emplyId);

	void changePassword(Map<String, Object> param);

	void touchLogin(String emplyId);
}
