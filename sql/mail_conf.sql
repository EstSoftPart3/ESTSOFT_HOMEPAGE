-- 메일 설정 (2026-11-17): 보내는 계정, 메일별 계정·받는 사람, 변경 이력, 메뉴 (plans/mail-conf-spec-3.html)
-- 급여명세서의 보내는 계정(TB_EEP_PAYSLIP_MAIL_M 의 주소·앱 비밀번호 등)과 세무서 받는 주소를 옮겨 온다. 원래 표는 문구 때문에 그대로 둔다.
-- 되돌리기: DROP TABLE TB_EEP_MAIL_CONF_H, TB_EEP_MAIL_USE_M, TB_EEP_MAIL_ACCOUNT_M; DELETE FROM TB_EEP_MENU WHERE MENU_CODE = 'S00001';

CREATE TABLE IF NOT EXISTS TB_EEP_MAIL_ACCOUNT_M (
	  ACC_SQ        int NOT NULL AUTO_INCREMENT
	, ACC_NM        varchar(50) NOT NULL COMMENT '화면에 보이는 계정 이름 (기본, 급여 …)'
	, FROM_NM       varchar(100) NULL COMMENT '보내는 사람 이름'
	, FROM_ADDR     varchar(200) NULL COMMENT 'Gmail 주소'
	, APP_PW_ENC    varchar(500) NULL COMMENT '앱 비밀번호 (RrnCipher 암호화, 화면으로 내려보내지 않는다). 1번 계정이 비면 서버 설정 파일 값으로 보낸다'
	, REPLY_TO      varchar(200) NULL
	, BCC           varchar(200) NULL
	, CONTACT       varchar(100) NULL COMMENT '급여 메일 본문 {담당자 연락처}'
	, VERIFIED_YN   char(1) NOT NULL DEFAULT 'N' COMMENT '마지막 연결 확인 결과. 주소·비밀번호를 바꾸거나 로그인 실패로 못 보내면 N'
	, VERIFIED_DT   datetime NULL COMMENT '마지막 연결 확인 일시'
	, VERIFY_MSG    varchar(300) NULL COMMENT '실패 이유'
	, UPDT_EMPLY_ID varchar(50) NULL
	, UPDT_DT       datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
	, PRIMARY KEY (ACC_SQ)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='보내는 메일 계정';

CREATE TABLE IF NOT EXISTS TB_EEP_MAIL_USE_M (
	  USE_CD        varchar(20) NOT NULL COMMENT 'MailConfService 의 메일 코드'
	, ACC_SQ        int NOT NULL
	, TO_LIST       varchar(1000) NULL COMMENT '받는 사람(화면에서 정하는 메일만). 쉼표로, @ 가 있으면 주소 · 없으면 계정 아이디'
	, UPDT_EMPLY_ID varchar(50) NULL
	, UPDT_DT       datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
	, PRIMARY KEY (USE_CD)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='메일별 보내는 계정·받는 사람';

CREATE TABLE IF NOT EXISTS TB_EEP_MAIL_CONF_H (
	  HIST_SQ  bigint NOT NULL AUTO_INCREMENT
	, TARGET   varchar(100) NOT NULL COMMENT '메일 이름 또는 계정 이름'
	, SUMMARY  varchar(500) NOT NULL COMMENT '무엇을 바꿨는지. 비밀번호 값은 남기지 않는다'
	, EMPLY_ID varchar(50) NOT NULL
	, REG_DT   datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
	, PRIMARY KEY (HIST_SQ)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='메일 설정 변경 이력';

-- 1 기본: 주소·비밀번호가 비어 있으면 지금처럼 서버 설정 파일(mail.username)로 보낸다
INSERT IGNORE INTO TB_EEP_MAIL_ACCOUNT_M (ACC_SQ, ACC_NM, FROM_NM) VALUES (1, '기본', '주식회사 이에스티소프트');
-- 2 급여: 급여명세서 ⚙ 에 저장돼 있던 값 그대로
INSERT IGNORE INTO TB_EEP_MAIL_ACCOUNT_M (ACC_SQ, ACC_NM, FROM_NM, FROM_ADDR, APP_PW_ENC, REPLY_TO, BCC, CONTACT, VERIFIED_YN, VERIFIED_DT)
SELECT 2, '급여', IFNULL(FROM_NM, '주식회사 이에스티소프트'), FROM_ADDR, APP_PW_ENC, REPLY_TO, BCC, CONTACT, VERIFIED_YN, VERIFIED_DT FROM TB_EEP_PAYSLIP_MAIL_M WHERE CONF_SQ = 1;
INSERT IGNORE INTO TB_EEP_MAIL_ACCOUNT_M (ACC_SQ, ACC_NM, FROM_NM) VALUES (2, '급여', '주식회사 이에스티소프트');

INSERT IGNORE INTO TB_EEP_MAIL_USE_M (USE_CD, ACC_SQ, TO_LIST) VALUES
	  ('APPLY', 1, 'est.part2@gmail.com')
	, ('CONSULT', 1, 'est.part2@gmail.com')
	, ('SIGNUP', 1, NULL)
	, ('GRANT_REQ', 1, NULL)
	, ('GRANT', 1, NULL)
	, ('PAYSLIP', 2, NULL)
	, ('PAYSLIP_TEST', 2, NULL)
	, ('TAX', 2, (SELECT REPLACE(H.SUMMARY, ', ', ',') FROM TB_EEP_PAYSLIP_CONF_H H WHERE H.KIND_CD = 'TAX' ORDER BY H.HIST_SQ DESC LIMIT 1))
	, ('LAB_REQ', 1, NULL)
	, ('LAB_RESEND', 1, NULL)
	, ('LAB_CLOSE', 1, NULL)
	, ('LAB_CEO', 1, NULL);

-- 메뉴: 업데이트 내역과 같은 묶음의 맨 뒤. 권한 역할에 넣지 않아 슈퍼관리자만 연다
INSERT INTO TB_EEP_MENU (MENU_CODE, MENU_NM, REL_CODE, MENU_DEPTH, MENU_URL, ICON_NM, SORT_NO, USE_YN, AUTH_PATTERN, NEW_WIN_YN, FRST_REGISTER, FRST_REG_DT, LAST_UPDT_DT)
SELECT 'S00001', '메일 설정', U.REL_CODE, U.MENU_DEPTH, '/admin/system/mail/openMailConf.do', NULL,
	(SELECT IFNULL(MAX(M.SORT_NO), 0) + 1 FROM TB_EEP_MENU M WHERE M.REL_CODE = U.REL_CODE), 'Y', '/admin/system/mail/**', 'N', 'system', NOW(), NOW()
FROM TB_EEP_MENU U WHERE U.MENU_CODE = 'U00001' AND NOT EXISTS (SELECT 1 FROM TB_EEP_MENU WHERE MENU_CODE = 'S00001');

SELECT ACC_SQ, ACC_NM, FROM_ADDR, APP_PW_ENC IS NOT NULL AS HAS_PW, VERIFIED_YN FROM TB_EEP_MAIL_ACCOUNT_M;
SELECT USE_CD, ACC_SQ, TO_LIST FROM TB_EEP_MAIL_USE_M;
SELECT MENU_CODE, MENU_NM, REL_CODE, SORT_NO FROM TB_EEP_MENU WHERE MENU_CODE = 'S00001';
