-- 직원 프로젝트 수행이력 (2026-11-09). 항목은 스킬 인벤토리 양식을 따른다.
CREATE TABLE IF NOT EXISTS TB_EEP_HR_STAFF_PRJ_R (
	  PRJ_SQ        int NOT NULL AUTO_INCREMENT
	, STAFF_SQ      int NOT NULL
	, PRJ_NM        varchar(300) NOT NULL COMMENT '프로젝트명(업무명)'
	, CLIENT_NM     varchar(200) NOT NULL COMMENT '고객사'
	, WORK_NM       varchar(500) NOT NULL COMMENT '업무단'
	, ROLE_NM       varchar(10)  NOT NULL COMMENT '운영, 개발, 운영/개발'
	, START_YM      char(7)      NOT NULL COMMENT 'yyyy-MM'
	, END_YM        char(7)      NULL     COMMENT 'yyyy-MM. NULL 이면 진행중'
	, IND_NM        varchar(200) NULL COMMENT '개발분야 산업'
	, APP_NM        varchar(200) NULL COMMENT '개발분야 응용'
	, MACHINE_NM    varchar(200) NULL COMMENT '기종'
	, OS_NM         varchar(200) NULL COMMENT 'O.S'
	, LANG_NM       varchar(500) NULL COMMENT '언어'
	, DBMS_NM       varchar(500) NULL COMMENT 'DBMS'
	, TOOL_NM       varchar(500) NULL COMMENT 'TOOL'
	, FRAMEWORK_NM  varchar(500) NULL COMMENT 'FRAMEWORK'
	, ETC_NM        varchar(500) NULL COMMENT '기타'
	, REG_EMPLY_ID  varchar(50)  NULL
	, REG_DT        datetime     NULL
	, UPDT_EMPLY_ID varchar(50)  NULL
	, UPDT_DT       datetime     NULL
	, PRIMARY KEY (PRJ_SQ)
	, KEY IX_STAFF_PRJ_STAFF (STAFF_SQ)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='직원 프로젝트 수행이력';
