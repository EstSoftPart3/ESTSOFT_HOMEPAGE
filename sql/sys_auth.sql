-- 시스템 공통 메뉴와 권한. 코드에서 쓰지 않던 TB_EEP_MENU 를 메뉴 원본으로 쓴다.
-- 되돌리기: DROP TABLE TB_EEP_USER_ROLE_R, TB_EEP_ROLE_MENU_R, TB_EEP_ROLE_M; ALTER TABLE TB_EEP_MENU DROP COLUMN ICON_NM, DROP COLUMN SORT_NO, DROP COLUMN USE_YN, DROP COLUMN AUTH_PATTERN, DROP COLUMN NEW_WIN_YN;

ALTER TABLE TB_EEP_MENU
	  MODIFY MENU_URL varchar(200) NULL
	, ADD COLUMN ICON_NM varchar(50) NULL COMMENT 'Font Awesome 클래스'
	, ADD COLUMN SORT_NO int NOT NULL DEFAULT 0
	, ADD COLUMN USE_YN char(1) NOT NULL DEFAULT 'Y'
	, ADD COLUMN AUTH_PATTERN varchar(1000) NULL COMMENT '이 메뉴로 허용할 /admin 경로(Ant 패턴, 쉼표 구분)'
	, ADD COLUMN NEW_WIN_YN char(1) NOT NULL DEFAULT 'N';

-- EMPLY_ID 와 조인하므로 기존 계정 테이블의 문자셋에 맞춘다
CREATE TABLE TB_EEP_ROLE_M (
	  ROLE_SQ   int NOT NULL AUTO_INCREMENT
	, ROLE_CD   varchar(30)  NOT NULL
	, ROLE_NM   varchar(50)  NOT NULL
	, ROLE_DESC varchar(200) NULL
	, SYSTEM_YN char(1)      NOT NULL DEFAULT 'N' COMMENT 'Y 는 삭제 불가'
	, SORT_NO   int          NOT NULL DEFAULT 0
	, PRIMARY KEY (ROLE_SQ)
	, UNIQUE KEY UK_ROLE_CD (ROLE_CD)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

CREATE TABLE TB_EEP_ROLE_MENU_R (
	  ROLE_SQ   int NOT NULL
	, MENU_CODE varchar(50) NOT NULL
	, PRIMARY KEY (ROLE_SQ, MENU_CODE)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- EMPLY_SQ 가 비어 있는 계정이 있어 로그인 아이디로 연결한다
CREATE TABLE TB_EEP_USER_ROLE_R (
	  EMPLY_ID     varchar(50) NOT NULL
	, ROLE_SQ      int         NOT NULL
	, REG_EMPLY_ID varchar(50) NULL
	, REG_DT       datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP
	, PRIMARY KEY (EMPLY_ID, ROLE_SQ)
	, KEY IX_USER_ROLE_ROLE (ROLE_SQ)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

INSERT INTO TB_EEP_MENU (MENU_CODE, MENU_NM, REL_CODE, MENU_DEPTH, MENU_URL, ICON_NM, SORT_NO, AUTH_PATTERN, NEW_WIN_YN, FRST_REGISTER, FRST_REG_DT, LAST_UPDT_DT) VALUES
	  ('M001', '계정 및 권한', NULL, '1', NULL, 'fa-user-shield', 10, NULL, 'N', 'system', NOW(), NOW())
	, ('M00001', '계정관리', 'M001', '2', '/admin/member/memberList.do', NULL, 1, '/admin/member/**', 'N', 'system', NOW(), NOW())
	, ('M00002', '메뉴 관리', 'M001', '2', '/admin/system/menu/openMenuManage.do', NULL, 2, '/admin/system/menu/**', 'N', 'system', NOW(), NOW())
	, ('C00002', '권한 관리', 'M001', '2', '/admin/system/role/openRoleManage.do', NULL, 3, '/admin/system/role/**', 'N', 'system', NOW(), NOW())
	, ('B001', '게시판', NULL, '1', NULL, 'fa-table', 20, NULL, 'N', 'system', NOW(), NOW())
	, ('B00001', '공지사항 게시판', 'B001', '2', '/admin/board/notice/openNoticeBoardList.do', NULL, 1, '/admin/board/notice/**', 'N', 'system', NOW(), NOW())
	, ('B00002', '자유 게시판', 'B001', '2', '/admin/board/freedom/openFreedomBoardList.do', NULL, 2, '/admin/board/freedom/**', 'N', 'system', NOW(), NOW())
	, ('B00003', '기술문의 게시판', 'B001', '2', '/admin/board/technology/openTechnologyBoardList.do', NULL, 3, '/admin/board/technology/**', 'N', 'system', NOW(), NOW())
	, ('B00004', '교육일정 게시판', 'B001', '2', '/admin/board/education/openEducationBoardList.do', NULL, 4, '/admin/board/education/**', 'N', 'system', NOW(), NOW())
	, ('H001', '직원', NULL, '1', NULL, 'fa-edit', 30, NULL, 'N', 'system', NOW(), NOW())
	, ('H00001', '면접관리', 'H001', '2', '/admin/hr/openInterviewList.do', NULL, 1, '/admin/hr/*nterview*', 'N', 'system', NOW(), NOW())
	, ('H00002', '교육생관리', 'H001', '2', '/admin/hr/openTraineeList.do', NULL, 2, '/admin/hr/*rainee*,/admin/hr/interviewListData.do', 'N', 'system', NOW(), NOW())
	, ('H00003', '직원관리', 'H001', '2', '/admin/staff/openStaffList.do', NULL, 3, '/admin/staff/**,/admin/equipment/staffEquipmentData.do', 'N', 'system', NOW(), NOW())
	, ('L001', '연구소', NULL, '1', NULL, 'fa-flask', 40, NULL, 'N', 'system', NOW(), NOW())
	, ('L00001', '연구일지', 'L001', '2', '/admin/lab/openJournalList.do', NULL, 1, '/admin/lab/*ournal*,/admin/lab/*roject*,/admin/lab/monthMembersData.do,/admin/lab/optionsData.do', 'N', 'system', NOW(), NOW())
	, ('L00002', '연구소 관리', 'L001', '2', '/admin/lab/openLabManage.do', NULL, 2, '/admin/lab/openLabManage.do,/admin/lab/*eam*,/admin/lab/saveApprovalData.do,/admin/lab/saveResearcherData.do,/admin/lab/saveSignData.do,/admin/lab/optionsData.do', 'N', 'system', NOW(), NOW())
	, ('E001', '장비', NULL, '1', NULL, 'fa-laptop', 50, NULL, 'N', 'system', NOW(), NOW())
	, ('E00001', '장비대장', 'E001', '2', '/admin/equipment/openEquipmentList.do', NULL, 1, '/admin/equipment/*quipment*,/admin/equipment/suggestNoData.do,/admin/equipment/*Rent*,/admin/equipment/*Issue*,/admin/equipment/*FileData.do,/admin/equipment/saveSealData.do,/admin/equipment/*ertificate*,/admin/equipment/uploadSignedData.do', 'N', 'system', NOW(), NOW())
	, ('E00002', '전수조사', 'E001', '2', '/admin/equipment/openAuditList.do', NULL, 2, '/admin/equipment/*udit*,/admin/equipment/addIssueData.do', 'N', 'system', NOW(), NOW())
	, ('T001', '업무툴', NULL, '1', NULL, 'fa-briefcase', 60, NULL, 'N', 'system', NOW(), NOW())
	, ('T00001', '캘린더 일정 가져오기·분류', 'T001', '2', '/admin/calendar/openCalendarSync.do', NULL, 1, '/admin/calendar/openCalendarSync.do,/admin/calendar/saveConfData.do,/admin/calendar/oauth*,/admin/calendar/calendarListData.do,/admin/calendar/fetchEventsData.do,/admin/calendar/tmpListData.do,/admin/calendar/confirmData.do', 'N', 'system', NOW(), NOW())
	, ('T00002', '확정 일정 분류별 보기', 'T001', '2', '/admin/calendar/openCalendarList.do', NULL, 2, '/admin/calendar/openCalendarList.do,/admin/calendar/eventListData.do', 'N', 'system', NOW(), NOW())
	, ('T00003', '여행 대화 사전', 'T001', '2', '/travel/index.html', NULL, 3, NULL, 'Y', 'system', NOW(), NOW())
	, ('J001', '배치', NULL, '1', NULL, 'fa-clock', 70, NULL, 'N', 'system', NOW(), NOW())
	, ('J00001', '신입면접', 'J001', '2', '/admin/batch/openInterviewBatch.do', NULL, 1, '/admin/batch/**', 'N', 'system', NOW(), NOW())
	, ('C001', '공통코드관리', NULL, '1', NULL, 'fa-file', 80, NULL, 'N', 'system', NOW(), NOW())
	, ('C00001', '공통코드', 'C001', '2', '/admin/code/openCodeBoardList.do', NULL, 1, '/admin/code/**', 'N', 'system', NOW(), NOW())
ON DUPLICATE KEY UPDATE MENU_NM = VALUES(MENU_NM), REL_CODE = VALUES(REL_CODE), MENU_DEPTH = VALUES(MENU_DEPTH), MENU_URL = VALUES(MENU_URL), ICON_NM = VALUES(ICON_NM), SORT_NO = VALUES(SORT_NO), AUTH_PATTERN = VALUES(AUTH_PATTERN), NEW_WIN_YN = VALUES(NEW_WIN_YN), LAST_UPDT_DT = NOW();

INSERT INTO TB_EEP_ROLE_M (ROLE_CD, ROLE_NM, ROLE_DESC, SYSTEM_YN, SORT_NO) VALUES
	  ('SUPER', '슈퍼관리자', '모든 메뉴와 권한 설정', 'Y', 1)
	, ('SYS', '시스템 운영자', '계정, 공통코드, 배치', 'N', 2)
	, ('HR', '인사 담당자', '면접, 교육생, 직원', 'N', 3)
	, ('LAB', '연구소 담당자', '연구일지, 연구소 관리', 'N', 4)
	, ('MGMT', '경영지원 담당자', '장비, 캘린더', 'N', 5)
	, ('BOARD', '게시판 운영자', '게시판 전체', 'N', 6);

INSERT INTO TB_EEP_ROLE_MENU_R (ROLE_SQ, MENU_CODE)
SELECT R.ROLE_SQ, M.MENU_CODE
FROM TB_EEP_ROLE_M R
JOIN TB_EEP_MENU M ON (R.ROLE_CD = 'SYS' AND M.MENU_CODE IN ('M00001', 'C00001', 'J00001'))
	OR (R.ROLE_CD = 'HR' AND M.MENU_CODE IN ('H00001', 'H00002', 'H00003'))
	OR (R.ROLE_CD = 'LAB' AND M.MENU_CODE IN ('L00001', 'L00002'))
	OR (R.ROLE_CD = 'MGMT' AND M.MENU_CODE IN ('E00001', 'E00002', 'T00001', 'T00002'))
	OR (R.ROLE_CD = 'BOARD' AND M.MENU_CODE IN ('B00001', 'B00002', 'B00003', 'B00004'));

-- 지금 관리자 화면을 쓰는 계정이 배포 뒤에도 그대로 쓰도록 슈퍼관리자로 넣는다
INSERT INTO TB_EEP_USER_ROLE_R (EMPLY_ID, ROLE_SQ, REG_EMPLY_ID)
SELECT DISTINCT E.EMPLY_ID, R.ROLE_SQ, 'system'
FROM TB_EEP_EMPLY_M E
JOIN TB_EEP_ROLE_M R ON R.ROLE_CD = 'SUPER'
WHERE E.EMPLY_AUTH_TYP_CD = '2' AND IFNULL(E.DEL_YN, 'N') = 'N' AND E.EMPLY_ID IS NOT NULL AND E.EMPLY_ID <> '';
