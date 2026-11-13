-- 투입현황 내근직 (2026-11-13): 내근직으로 켠 투입 건이 있는 사람은 투입 현황·대기·철수 임박에서 빠지고 내근직 탭에만 보인다. 급여 계산과는 무관
-- 되돌리기: ALTER TABLE TB_EEP_DEPLOY_R DROP COLUMN OFFICE_YN;

ALTER TABLE TB_EEP_DEPLOY_R ADD COLUMN IF NOT EXISTS OFFICE_YN char(1) NOT NULL DEFAULT 'N' COMMENT '내근직(투입현황 내근직 탭에만 보임)';
