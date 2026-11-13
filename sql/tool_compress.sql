-- 업무툴 > 파일 용량 줄이기 메뉴(2026-11-13). 권한은 권한관리에서 준다(슈퍼관리자는 바로 보임)
-- 되돌리기: DELETE FROM TB_EEP_ROLE_MENU_R WHERE MENU_CODE = 'T00004'; DELETE FROM TB_EEP_MENU WHERE MENU_CODE = 'T00004';
INSERT INTO TB_EEP_MENU (MENU_CODE, MENU_NM, REL_CODE, MENU_DEPTH, MENU_URL, ICON_NM, SORT_NO, USE_YN, AUTH_PATTERN, NEW_WIN_YN, FRST_REGISTER, FRST_REG_DT, LAST_UPDT_DT)
SELECT 'T00004', '파일 용량 줄이기', 'T001', '2', '/admin/tool/openCompress.do', NULL,
	(SELECT IFNULL(MAX(M.SORT_NO), 0) + 1 FROM TB_EEP_MENU M WHERE M.REL_CODE = 'T001'), 'Y',
	'/admin/tool/openCompress.do,/admin/tool/compressData.do', 'N', 'system', NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM TB_EEP_MENU WHERE MENU_CODE = 'T00004' OR MENU_URL = '/admin/tool/openCompress.do');
