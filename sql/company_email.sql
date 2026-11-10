-- 인사정보에 회사 메일을 따로 둔다. 기존 EMAIL 은 개인 메일(급여명세서·인사 서류)로 쓴다
-- 회사 메일은 로그인 아이디·가입 인증·업무 연락에 쓰고 @gmail.com 주소만 받는다
-- 되돌리기: ALTER TABLE TB_EEP_HR_STAFF_M DROP COLUMN COMPANY_EMAIL;
ALTER TABLE TB_EEP_HR_STAFF_M
	ADD COLUMN COMPANY_EMAIL varchar(200) NULL COMMENT '회사 메일(@gmail.com). 아이디·업무 연락용' AFTER EMAIL;
