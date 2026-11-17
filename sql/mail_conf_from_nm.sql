-- 메일 설정: 보내는 이름을 계정이 아니라 메일마다 정한다(MailConfService). mail_conf.sql 다음에 실행.
-- 비어 있으면 계정의 FROM_NM 을 쓴다. 지금 값은 각 메일이 쓰는 계정의 이름으로 채운다.
-- 되돌리기: ALTER TABLE TB_EEP_MAIL_USE_M DROP COLUMN FROM_NM;

ALTER TABLE TB_EEP_MAIL_USE_M ADD COLUMN IF NOT EXISTS FROM_NM varchar(100) NULL COMMENT '보내는 사람 이름(비면 계정 이름)' AFTER ACC_SQ;

UPDATE TB_EEP_MAIL_USE_M U JOIN TB_EEP_MAIL_ACCOUNT_M A ON A.ACC_SQ = U.ACC_SQ SET U.FROM_NM = A.FROM_NM WHERE U.FROM_NM IS NULL;

SELECT USE_CD, ACC_SQ, FROM_NM FROM TB_EEP_MAIL_USE_M;
