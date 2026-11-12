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

	void deleteAccount(int sq);

	void deleteLoginTokens(int sq);

	void deletePrefs(String emplyId);

	void deleteUserRoles(String emplyId);

	int linkStaff(Map<String, Object> param);

	List<Map<String, Object>> searchStaff(String keyword);

	List<Map<String, Object>> selectSignupStaff(Map<String, Object> param);

	int countStaffCompanyEmail(Map<String, Object> param);

	void updateStaffCompanyEmail(Map<String, Object> param);

	int retireOldStaffAccounts(Map<String, Object> param);

	String selectStaffRrn(int staffSq);

	void unlinkStaff(String emplyId);

	String selectPasswordHash(String emplyId);

	void changePassword(Map<String, Object> param);

	void touchLogin(String emplyId);

	/** 시크릿 (sql/secret.sql) */

	String selectSecretYn(int sq);

	int updateSecretYn(Map<String, Object> param);
}
