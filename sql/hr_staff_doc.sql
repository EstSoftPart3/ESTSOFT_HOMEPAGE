-- 직원관리 서류 첨부 (2026-11-06). 파일은 구글 드라이브 '2. 인사관리/<구분>/(입사일) 성명/00. 입사관련서류' 에 있고 여기에는 연결만 둔다.
ALTER TABLE TB_EEP_HR_STAFF_M ADD COLUMN IF NOT EXISTS DRIVE_FOLDER_ID varchar(100) NULL COMMENT '드라이브의 사람 폴더 ID' AFTER SK_OS;

CREATE TABLE IF NOT EXISTS TB_EEP_HR_STAFF_DOC_R (
	  DOC_SQ        int NOT NULL AUTO_INCREMENT
	, STAFF_SQ      int NOT NULL
	, DOC_CD        varchar(20)  NOT NULL COMMENT 'DOC_BANK 등 인사카드 서류 칸'
	, FILE_ID       varchar(100) NOT NULL COMMENT '구글 드라이브 파일 ID'
	, FILE_NM       varchar(300) NULL
	, MIME_TYPE     varchar(100) NULL
	, WEB_LINK      varchar(500) NULL
	, REG_EMPLY_ID  varchar(50)  NULL
	, REG_DT        datetime     NULL
	, PRIMARY KEY (DOC_SQ)
	, UNIQUE KEY UX_STAFF_DOC_FILE (STAFF_SQ, DOC_CD, FILE_ID)
	, KEY IX_STAFF_DOC_STAFF (STAFF_SQ)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='직원 서류 파일(구글 드라이브) 연결';
