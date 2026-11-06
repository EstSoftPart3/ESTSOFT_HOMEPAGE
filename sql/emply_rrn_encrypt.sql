-- 직원 주민등록번호를 AES-256-GCM 으로 암호화해 저장한다 (운영 반영 2026-11-06).
-- 저장 형식 "enc:v1:" + base64(IV 12 + 암호문 + 태그 16) 은 60자를 넘어 기존 varchar(50) 에 들어가지 않는다.
ALTER TABLE TB_EEP_EMPLY_M MODIFY EMPLY_RRN varchar(255);
ALTER TABLE old_tb_eep_emply_m MODIFY EMPLY_RRN varchar(255);

-- 기존 평문 값은 서버에서 python cryptography(AESGCM) 로 같은 형식으로 한 번 바꿨다 (common.util.RrnCipher 와 호환).
-- 키는 config/db.properties 의 rrn.key 이고 저장소에는 두지 않는다.
