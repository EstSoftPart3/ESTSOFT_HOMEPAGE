-- 경력직 면접자를 바로 대기자(직원관리 대기 탭)로 등록할 때 어느 면접자의 카드인지 기억한다 (2026-11-17)
-- 되돌리기: ALTER TABLE TB_EEP_HR_STAFF_M DROP KEY UX_STAFF_INTV, DROP COLUMN INTV_SQ;
ALTER TABLE TB_EEP_HR_STAFF_M
	ADD COLUMN INTV_SQ int NULL COMMENT '경력직 면접자에서 만든 대기 카드의 면접자 번호',
	ADD UNIQUE KEY UX_STAFF_INTV (INTV_SQ);
