package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.annotation.MapperScan;

@MapperScan
public interface BoSystemMapper {

	List<Map<String, Object>> selectActiveMenus();

	List<Map<String, Object>> selectMyGrants(String emplyId);

	List<Map<String, Object>> selectAllMenus();

	int countChildMenus(String menuCode);

	void upsertMenu(Map<String, Object> param);

	void updateMenuOrder(Map<String, Object> param);

	void deleteMenu(String menuCode);

	void deleteMenuGrants(String menuCode);

	List<Map<String, Object>> selectRoles();

	List<Map<String, Object>> selectRoleMenus();

	List<Map<String, Object>> selectRoleUsers();

	List<Map<String, Object>> selectAdminOptions();

	Map<String, Object> selectRole(int roleSq);

	void insertRole(Map<String, Object> param);

	void updateRole(Map<String, Object> param);

	void deleteRole(int roleSq);

	void deleteRoleMenus(int roleSq);

	void deleteRoleUsers(int roleSq);

	void insertRoleMenus(Map<String, Object> param);

	int countActiveAdmin(String emplyId);

	void insertRoleUser(Map<String, Object> param);

	void deleteRoleUser(Map<String, Object> param);

	int countRoleUsers(int roleSq);
}
