-- 직원관리(인사카드). 원본은 구글드라이브 '2. 인사관리/01. 인사 관리.xlsx' 의 재직자·퇴사자 시트이고,
-- 당분간 엑셀과 병행한다. 엑셀 -> 이 테이블 이관은 sql/staff_export.ps1 + sql/staff_import.py (전체 교체).
-- 로그인 계정(TB_EEP_EMPLY_M)과는 별개다. 주민번호·계좌번호는 common.util.RrnCipher 로 암호화해 저장한다.
CREATE TABLE IF NOT EXISTS TB_EEP_HR_STAFF_M (
	  STAFF_SQ      int NOT NULL AUTO_INCREMENT
	, STATUS_CD     varchar(10)  NOT NULL DEFAULT 'WORK' COMMENT 'WORK 재직, LEFT 퇴사'
	, SEQ_NO        varchar(20)  NULL COMMENT '엑셀 NO'
	, ORG_NM        varchar(50)  NULL COMMENT '소속'
	, DEPT_NM       varchar(100) NULL COMMENT '부서'
	, POSITION_NM   varchar(50)  NULL COMMENT '직급'
	, STAFF_NM      varchar(50)  NOT NULL COMMENT '성명'
	, RRN_ENC       varchar(255) NULL COMMENT '주민등록번호(암호화)'
	, PHONE         varchar(50)  NULL
	, EMAIL         varchar(200) NULL
	, ADDR          varchar(500) NULL COMMENT '상세주소(시도)'
	, STATION       varchar(200) NULL COMMENT '인근지하철역'
	, JOIN_DT       varchar(20)  NULL COMMENT '입사일자 yyyy-MM-dd (날짜가 아니면 글자 그대로)'
	, LEAVE_DT      varchar(20)  NULL COMMENT '퇴사일자'
	, HS_NM         varchar(200) NULL, HS_MAJOR varchar(200) NULL, HS_GRAD varchar(50) NULL
	, UNIV_NM       varchar(200) NULL, UNIV_MAJOR varchar(200) NULL, UNIV_GRAD varchar(50) NULL
	, FINAL_EDU     varchar(50)  NULL
	, MIL_IN_DT     varchar(50)  NULL, MIL_OUT_DT varchar(50) NULL, MIL_EXEMPT varchar(200) NULL
	, EDU_NM        varchar(500) NULL, EDU_START_DT varchar(50) NULL, EDU_END_DT varchar(50) NULL, EDU_ORG varchar(200) NULL
	, CERT_DT       varchar(50)  NULL COMMENT '정보처리기사 취득일'
	, BANK_NM       varchar(50)  NULL
	, ACCOUNT_ENC   varchar(255) NULL COMMENT '계좌번호(암호화)'
	, DOC_REG varchar(20) NULL, DOC_ID varchar(20) NULL, DOC_GRAD varchar(20) NULL, DOC_BANK varchar(20) NULL, DOC_PHOTO varchar(20) NULL
	, DOC_HI varchar(20) NULL, DOC_CONTRACT varchar(20) NULL, DOC_BIZ varchar(20) NULL, DOC_EI varchar(20) NULL, DOC_SEC varchar(20) NULL
	, DOC_EDU varchar(20) NULL, DOC_NEP varchar(20) NULL, DOC_PRIV varchar(20) NULL, DOC_CRIME varchar(20) NULL, DOC_MIL varchar(20) NULL
	, EMG_REL1 varchar(50) NULL, EMG_TEL1 varchar(50) NULL, EMG_REL2 varchar(50) NULL, EMG_TEL2 varchar(50) NULL
	, PREV_CAREER varchar(500) NULL, HOBBY varchar(200) NULL, LANG_SKILL varchar(200) NULL, SPECIALTY varchar(200) NULL
	, MEMO text NULL COMMENT '비고'
	, SCORE varchar(50) NULL, GAPIL_YN varchar(20) NULL, AUTO_APLY_YN varchar(20) NULL, GRADE_NM varchar(50) NULL
	, REAL_CAREER varchar(100) NULL, WISH_PRICE varchar(200) NULL
	, SK_FE varchar(500) NULL, SK_BE varchar(500) NULL, WORK_DOMAIN varchar(500) NULL, WISH_LOC varchar(500) NULL
	, ETC1 varchar(500) NULL, SK_LANG varchar(500) NULL, REPORT varchar(500) NULL, SK_FW varchar(500) NULL, SK_DB varchar(500) NULL
	, SK_IDE varchar(500) NULL, SK_VCS varchar(500) NULL, ETC2 varchar(500) NULL, EXPERTISE varchar(500) NULL, SK_OS varchar(500) NULL
	, UPDT_EMPLY_ID varchar(50)  NULL
	, UPDT_DT       datetime     NULL
	, PRIMARY KEY (STAFF_SQ)
	, KEY IX_STAFF_STATUS (STATUS_CD)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='직원 인사카드';
