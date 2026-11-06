-- 직원 비밀번호를 bcrypt 해시로 저장한다 (운영 반영 2026-11-06).
-- bcrypt 해시는 60자라 기존 varchar(50) 에 들어가지 않는다.
ALTER TABLE TB_EEP_EMPLY_M MODIFY EMPLY_PW varchar(100);

-- 기존 평문 값은 이 SQL 로 바꿀 수 없다. 서버에서 행마다 bcrypt 해시를 만들어
-- UPDATE TB_EEP_EMPLY_M SET EMPLY_PW = '<$2a$10$...>' WHERE EMPLY_ID = ? AND EMPLY_PW = ?
-- 로 한 번 바꿨다. jbcrypt 0.4 는 $2a$ 접두어만 읽으므로 python bcrypt 의 $2b$ 는 $2a$ 로 바꿔 넣는다.
-- 비밀번호가 비어 있는 계정은 바꾸지 않았고, 로그인할 수 없다.
