-- 인사카드 여러 건 항목과 기존 학력의 구분·상태 (2026-11-09). 기존 학력·교육·비상연락 칸은 그대로 두고 추가한 건만 이 표에 넣는다.
ALTER TABLE TB_EEP_HR_STAFF_M ADD COLUMN IF NOT EXISTS HS_KIND varchar(30) NULL COMMENT '고교 학력 구분' AFTER HS_GRAD;
ALTER TABLE TB_EEP_HR_STAFF_M ADD COLUMN IF NOT EXISTS HS_STATE varchar(10) NULL COMMENT '고교 졸업·재학 등' AFTER HS_KIND;
ALTER TABLE TB_EEP_HR_STAFF_M ADD COLUMN IF NOT EXISTS UNIV_KIND varchar(30) NULL COMMENT '대학 학력 구분' AFTER UNIV_GRAD;
ALTER TABLE TB_EEP_HR_STAFF_M ADD COLUMN IF NOT EXISTS UNIV_STATE varchar(10) NULL COMMENT '대학 졸업·재학 등' AFTER UNIV_KIND;

CREATE TABLE IF NOT EXISTS TB_EEP_HR_STAFF_ITEM_R (
	  ITEM_SQ       int NOT NULL AUTO_INCREMENT
	, STAFF_SQ      int NOT NULL
	, ITEM_CD       varchar(10)  NOT NULL COMMENT 'EDU 학력, TRAIN 교육·자격, EMG 비상연락망'
	, C1            varchar(100) NULL COMMENT 'EDU 구분 / TRAIN 이름 / EMG 관계'
	, C2            varchar(200) NULL COMMENT 'EDU 학교명 / TRAIN 기관 / EMG 연락처'
	, C3            varchar(200) NULL COMMENT 'EDU 전공 / TRAIN 시작월'
	, C4            varchar(50)  NULL COMMENT 'EDU 졸업년월 / TRAIN 종료월'
	, C5            varchar(10)  NULL COMMENT 'EDU 상태'
	, REG_EMPLY_ID  varchar(50)  NULL
	, REG_DT        datetime     NULL
	, UPDT_EMPLY_ID varchar(50)  NULL
	, UPDT_DT       datetime     NULL
	, PRIMARY KEY (ITEM_SQ)
	, KEY IX_STAFF_ITEM (STAFF_SQ, ITEM_CD)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='직원 학력·교육·비상연락 추가 건';
