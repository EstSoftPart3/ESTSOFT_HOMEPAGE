-- 로그인 계정이 없는 직원도 시크릿을 켤 수 있게 직원에 직접 표시한다 (2026-11-12). 계정이 연결된 직원은 계정의 SECRET_YN 을 쓴다.
ALTER TABLE TB_EEP_HR_STAFF_M ADD COLUMN IF NOT EXISTS SECRET_YN char(1) NOT NULL DEFAULT 'N' COMMENT '계정 없는 직원의 시크릿. Y 면 시크릿 계정에게만 보인다';
