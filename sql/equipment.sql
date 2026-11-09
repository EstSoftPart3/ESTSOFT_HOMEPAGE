-- 장비관리. 원본은 구글드라이브 '3. 장비 관리/장비관리대장.xlsx' 이고, 이관은 src/test/java/com/eep/bo/equipment/EquipmentLedgerImport.java 로 만든 SQL 을 한 번 넣는다.
-- 되돌리기: DROP TABLE TB_EEP_EQP_SEAL_M, TB_EEP_EQP_SIGN_H, TB_EEP_EQP_FILE_R, TB_EEP_EQP_AUDIT_D, TB_EEP_EQP_AUDIT_M, TB_EEP_EQP_ISSUE_H, TB_EEP_EQP_RENT_H, TB_EEP_EQP_M; ALTER TABLE TB_EEP_HR_STAFF_M DROP KEY UK_STAFF_EMPLY_ID, DROP COLUMN EMPLY_ID;

CREATE TABLE TB_EEP_EQP_M (
	  EQP_SQ         int NOT NULL AUTO_INCREMENT
	, EQP_NO         varchar(40)  NOT NULL COMMENT '관리번호. 폐기·분실 장비의 번호는 다시 쓸 수 있다'
	, TYPE_CD        varchar(10)  NOT NULL COMMENT 'NB 노트북, MT 모니터, DT 데스크탑, MU 마우스, KB 키보드'
	, BRAND_NM       varchar(100) NULL
	, MODEL_NM       varchar(200) NULL
	, SERIAL_NO      varchar(200) NULL COMMENT '빈 값과 같은 값이 있어 유일하지 않다'
	, CPU_SPEC       varchar(100) NULL
	, MEM_SPEC       varchar(100) NULL
	, SSD_SPEC       varchar(100) NULL
	, HDD_SPEC       varchar(100) NULL
	, LAN_YN         varchar(10)  NULL
	, ETC_TXT        varchar(200) NULL
	, STATUS_CD      varchar(10)  NOT NULL DEFAULT 'STOCK' COMMENT 'RENT 대여중, STOCK 보관중, DISPOSED 폐기, LOST 분실'
	, LOCATION_NM    varchar(100) NULL COMMENT '보관 위치'
	, AUDIT_EXCL_YN  char(1)      NOT NULL DEFAULT 'N' COMMENT '영구 대여 등 전수조사 제외'
	, DISPOSE_DT     date         NULL
	, DISPOSE_REASON varchar(500) NULL
	, LAST_CHECK_DT  date         NULL
	, LAST_CHECK_NM  varchar(50)  NULL
	, MEMO           text         NULL COMMENT '특이사항. 장비 비밀번호는 적지 않는다'
	, ACTIVE_NO      varchar(40)  AS (IF(STATUS_CD IN ('RENT', 'STOCK'), EQP_NO, NULL)) VIRTUAL COMMENT '보유 장비 안에서만 번호가 유일하도록 하는 값'
	, UPDT_EMPLY_ID  varchar(50)  NULL
	, UPDT_DT        datetime     NULL
	, PRIMARY KEY (EQP_SQ)
	, UNIQUE KEY UK_EQP_ACTIVE_NO (ACTIVE_NO)
	, KEY IX_EQP_NO (EQP_NO)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='장비';

CREATE TABLE TB_EEP_EQP_RENT_H (
	  RENT_SQ          int NOT NULL AUTO_INCREMENT
	, EQP_SQ           int NOT NULL
	, STAFF_SQ         int NULL COMMENT '직원 외 사용자는 NULL'
	, HOLDER_NM        varchar(100) NOT NULL
	, START_DT         date NULL COMMENT '옛 대장에 날짜가 없는 줄은 NULL'
	, END_DT           date NULL
	, OPEN_YN          char(1) NOT NULL DEFAULT 'Y' COMMENT '진행 중 대여'
	, PURPOSE_NM       varchar(300) NULL
	, PROJECT_NM       varchar(200) NULL
	, HANDOVER_NM      varchar(100) NULL COMMENT '인계자'
	, RENT_GROUP       varchar(36)  NULL COMMENT '함께 빌려 한 번에 서명하는 묶음. 이관분은 NULL(서명 대상 아님)'
	, RETURN_FORMAT_YN char(1) NULL
	, RETURN_LABEL_YN  char(1) NULL
	, OPEN_EQP_SQ      int AS (IF(OPEN_YN = 'Y', EQP_SQ, NULL)) VIRTUAL COMMENT '장비당 진행 중 대여 1건'
	, REG_EMPLY_ID     varchar(50) NULL
	, REG_DT           datetime NULL
	, PRIMARY KEY (RENT_SQ)
	, UNIQUE KEY UK_RENT_OPEN (OPEN_EQP_SQ)
	, KEY IX_RENT_EQP (EQP_SQ)
	, KEY IX_RENT_STAFF (STAFF_SQ)
	, KEY IX_RENT_GROUP (RENT_GROUP)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='장비 대여이력';

CREATE TABLE TB_EEP_EQP_ISSUE_H (
	  ISSUE_SQ     int NOT NULL AUTO_INCREMENT
	, EQP_SQ       int NOT NULL
	, CONTENT      varchar(2000) NOT NULL
	, OPEN_DT      date NOT NULL
	, CLOSE_DT     date NULL
	, CLOSE_NOTE   varchar(500) NULL
	, REG_EMPLY_ID varchar(50) NULL
	, PRIMARY KEY (ISSUE_SQ)
	, KEY IX_ISSUE_EQP (EQP_SQ, CLOSE_DT)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='장비 이슈';

CREATE TABLE TB_EEP_EQP_AUDIT_M (
	  AUDIT_SQ     int NOT NULL AUTO_INCREMENT
	, AUDIT_YM     char(7) NOT NULL COMMENT 'yyyy-MM'
	, STATUS_CD    varchar(10) NOT NULL DEFAULT 'OPEN' COMMENT 'OPEN 진행, CLOSED 마감'
	, CLOSE_DT     datetime NULL
	, REG_EMPLY_ID varchar(50) NULL
	, PRIMARY KEY (AUDIT_SQ)
	, UNIQUE KEY UK_AUDIT_YM (AUDIT_YM)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='장비 전수조사 회차';

CREATE TABLE TB_EEP_EQP_AUDIT_D (
	  AUDIT_SQ       int NOT NULL
	, EQP_SQ         int NOT NULL
	, STAFF_SQ       int NULL
	, HOLDER_NM      varchar(100) NULL COMMENT '회차를 만든 시점의 사용자 또는 위치'
	, GUEST_YN       char(1) NOT NULL DEFAULT 'Y' COMMENT '로그인 계정과 연결되지 않아 담당자가 수기 확인'
	, RESULT_CD      varchar(10) NOT NULL DEFAULT 'NONE' COMMENT 'NONE 미응답, OK 확인, BAD 이상'
	, NOTE           varchar(1000) NULL
	, RESPONSE_CD    varchar(10) NULL COMMENT 'SELF 본인, ADMIN 담당자'
	, CHECK_EMPLY_ID varchar(50) NULL
	, CHECK_DT       datetime NULL
	, PRIMARY KEY (AUDIT_SQ, EQP_SQ)
	, KEY IX_AUDIT_D_STAFF (STAFF_SQ)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='장비 전수조사 결과';

CREATE TABLE TB_EEP_EQP_FILE_R (
	  FILE_SQ      int NOT NULL AUTO_INCREMENT
	, EQP_SQ       int NOT NULL
	, DOC_CD       varchar(20) NOT NULL COMMENT 'RECEIPT 영수증, ETC 기타'
	, FILE_ID      varchar(200) NOT NULL
	, FILE_NM      varchar(300) NOT NULL
	, WEB_LINK     varchar(500) NULL
	, REG_EMPLY_ID varchar(50) NULL
	, REG_DT       datetime NULL
	, PRIMARY KEY (FILE_SQ)
	, KEY IX_FILE_EQP (EQP_SQ)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='장비 첨부(구글 드라이브 링크)';

CREATE TABLE TB_EEP_EQP_SIGN_H (
	  SIGN_SQ     int NOT NULL AUTO_INCREMENT
	, RENT_GROUP  varchar(36) NOT NULL
	, SIGN_TP     varchar(10) NOT NULL COMMENT 'SCREEN 화면 서명, UPLOAD 서명본 파일'
	, DOC_TEXT    mediumtext NULL COMMENT '서명 시점의 증서 내용. 장 사이는 폼피드'
	, SIGN_IMG    mediumtext NULL COMMENT '서명 이미지 data URL'
	, FILE_ID     varchar(200) NULL
	, FILE_NM     varchar(300) NULL
	, WEB_LINK    varchar(500) NULL
	, SIGNER_ID   varchar(50) NULL COMMENT '화면 서명: 본인 계정 또는 입회 담당자, 업로드: 담당자'
	, SIGNER_KIND varchar(10) NOT NULL COMMENT 'SELF 본인 로그인, GUEST 담당자 화면'
	, SIGN_DT     datetime NOT NULL
	, SIGN_IP     varchar(100) NULL
	, PRIMARY KEY (SIGN_SQ)
	, UNIQUE KEY UK_SIGN_GROUP (RENT_GROUP)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='장비 대여증서 서명';

CREATE TABLE TB_EEP_EQP_SEAL_M (
	  SEAL_ID       tinyint NOT NULL DEFAULT 1
	, SEAL_IMG      mediumtext NOT NULL COMMENT '임대인 직인 data URL. 공개 저장소라 소스에 두지 않는다'
	, UPDT_EMPLY_ID varchar(50) NULL
	, UPDT_DT       datetime NULL
	, PRIMARY KEY (SEAL_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='대여증서 직인';

-- 인사카드와 로그인 계정 연결. 비어 있으면 게스트로 처리한다
ALTER TABLE TB_EEP_HR_STAFF_M ADD COLUMN EMPLY_ID varchar(50) NULL COMMENT '로그인 계정(TB_EEP_EMPLY_M.EMPLY_ID)', ADD UNIQUE KEY UK_STAFF_EMPLY_ID (EMPLY_ID);

-- 이메일이 양쪽에서 한 건씩만 맞는 사람만 연결한다. 나머지는 인사카드의 '로그인 계정' 칸에서 지정한다
UPDATE TB_EEP_HR_STAFF_M s
JOIN (SELECT EMPLY_EMAIL, MIN(EMPLY_ID) AS EMPLY_ID FROM TB_EEP_EMPLY_M WHERE EMPLY_EMAIL IS NOT NULL AND EMPLY_EMAIL <> '' GROUP BY EMPLY_EMAIL HAVING COUNT(*) = 1) e ON e.EMPLY_EMAIL = s.EMAIL
JOIN (SELECT EMAIL FROM TB_EEP_HR_STAFF_M WHERE EMAIL IS NOT NULL AND EMAIL <> '' GROUP BY EMAIL HAVING COUNT(*) = 1) u ON u.EMAIL = s.EMAIL
SET s.EMPLY_ID = e.EMPLY_ID;
