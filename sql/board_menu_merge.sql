-- 게시판 메뉴 4개를 「게시판 관리」 하나로 합친다. 화면 안에서 탭으로 게시판을 고른다.
-- 되돌리기: sys_auth.sql 의 B00001~B00004 행을 다시 넣고 UPDATE TB_EEP_MENU SET USE_YN = 'Y' WHERE MENU_CODE IN ('B00002', 'B00003', 'B00004');

-- 자유·기술문의·교육일정만 갖고 있던 역할도 합친 메뉴를 쓰게 한다
INSERT IGNORE INTO TB_EEP_ROLE_MENU_R (ROLE_SQ, MENU_CODE)
SELECT DISTINCT ROLE_SQ, 'B00001' FROM TB_EEP_ROLE_MENU_R WHERE MENU_CODE IN ('B00002', 'B00003', 'B00004');

UPDATE TB_EEP_MENU
SET MENU_NM = '게시판 관리', MENU_URL = '/admin/board/openBoardManage.do', AUTH_PATTERN = '/admin/board/**', LAST_UPDT_DT = NOW()
WHERE MENU_CODE = 'B00001';

UPDATE TB_EEP_MENU SET USE_YN = 'N', LAST_UPDT_DT = NOW() WHERE MENU_CODE IN ('B00002', 'B00003', 'B00004');
