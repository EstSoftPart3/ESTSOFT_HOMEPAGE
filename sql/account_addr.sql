-- 직원 인사카드 주소(500자)를 계정에 불러올 수 있도록 늘린다.
-- 되돌리기: 50자를 넘는 주소가 없을 때 ALTER TABLE TB_EEP_EMPLY_M MODIFY EMPLY_HOME_ADDR varchar(50) NULL;
ALTER TABLE TB_EEP_EMPLY_M MODIFY EMPLY_HOME_ADDR varchar(500) NULL;
