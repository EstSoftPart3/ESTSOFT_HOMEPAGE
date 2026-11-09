-- 장비대장 검토 필요 탭. 날짜를 알 수 없는 옛 이력을 확정해 목록에서 뺀다.
-- 되돌리기: ALTER TABLE TB_EEP_EQP_RENT_H DROP COLUMN REVIEW_DONE_YN;
ALTER TABLE TB_EEP_EQP_RENT_H ADD COLUMN REVIEW_DONE_YN char(1) NOT NULL DEFAULT 'N' COMMENT '날짜가 비어 있어도 이대로 확정';
