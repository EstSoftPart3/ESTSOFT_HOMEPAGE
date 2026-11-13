-- 투입현황 휴직 (2026-11-13): 휴직 기간이 끝나지 않은 사람은 다른 탭에서 빠지고 휴직 탭에만 보인다. 종료일이 지나면 원래 목록으로. 급여 계산과는 무관
-- 되돌리기: ALTER TABLE TB_EEP_DEPLOY_R DROP COLUMN REST_FROM_DT, DROP COLUMN REST_TO_DT;

ALTER TABLE TB_EEP_DEPLOY_R ADD COLUMN IF NOT EXISTS REST_FROM_DT char(10) NULL COMMENT '휴직 시작일(비면 휴직 아님)';
ALTER TABLE TB_EEP_DEPLOY_R ADD COLUMN IF NOT EXISTS REST_TO_DT char(10) NULL COMMENT '휴직 종료일(비면 미정)';
