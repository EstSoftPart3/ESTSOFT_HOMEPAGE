-- 계정별 구글 연동(내 연동). 2026-11-16
-- 캘린더 가져오기·직원 서류·장비 첨부·거래처 서류 읽기·연구일지 PDF 는 요청한 관리자의 연동으로, 면접 배치는 iCal 에서 '연결'을 누른 관리자의 연동으로 동작한다.
-- 예전 연결(회사 공용 드라이브 STAFF_DRIVE_*, iCal 별 DRIVE_TOKEN)은 모두 지워 각자 다시 연결하게 한다.
-- 되돌리기: DROP TABLE TB_EEP_GOOGLE_LINK_R; ALTER TABLE TB_EEP_BATCH_ICAL_M DROP COLUMN DRIVE_OWNER; (예전 토큰은 되살아나지 않으니 예전 앱으로 돌리면 다시 연결)
CREATE TABLE IF NOT EXISTS TB_EEP_GOOGLE_LINK_R (
	  EMPLY_ID    varchar(50)  NOT NULL
	, SERVICE_CD  varchar(20)  NOT NULL COMMENT 'DRIVE, CALENDAR'
	, REFRESH_ENC varchar(1024) NOT NULL COMMENT 'refresh token (RrnCipher 암호문)'
	, ACCOUNT     varchar(200) NULL COMMENT '연결한 구글 계정 메일'
	, REG_DT      datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP
	, PRIMARY KEY (EMPLY_ID, SERVICE_CD)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='계정별 구글 연동';

ALTER TABLE TB_EEP_BATCH_ICAL_M ADD COLUMN IF NOT EXISTS DRIVE_OWNER varchar(50) NULL COMMENT '이력서 드라이브로 쓸 연동의 관리자 아이디';

UPDATE TB_EEP_BATCH_ICAL_M SET DRIVE_TOKEN = NULL, DRIVE_ACCOUNT = NULL;

DELETE FROM TB_EEP_CAL_CONF_M WHERE CONF_KEY IN ('STAFF_DRIVE_TOKEN', 'STAFF_DRIVE_ACCOUNT');
