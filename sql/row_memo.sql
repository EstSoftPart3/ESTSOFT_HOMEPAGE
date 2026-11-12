-- 목록 메모(직원·면접·교육생·장비·연구팀). 쌓기만 하고 본인 것만 지운다. 화면은 BoMemoController·hrMemoFeed
-- 2026-11-12 옛 비고(직원·면접)·참고사항(교육생)·특이사항(장비)·비고(연구팀)·장비 이슈(TB_EEP_EQP_ISSUE_H)를 문맥 단위로 나눠 옮겼다(EMPLY_ID = 'MIGRATED').
-- 옛 MEMO 컬럼과 이슈 표는 되돌리기용으로 지우지 않고 더 쓰지 않는다.
-- 되돌리기: DROP TABLE TB_EEP_ROW_MEMO_R; (앱도 이전 버전으로)
CREATE TABLE IF NOT EXISTS TB_EEP_ROW_MEMO_R (
	  MEMO_SQ   bigint      NOT NULL AUTO_INCREMENT
	, TARGET_CD varchar(20) NOT NULL COMMENT 'STAFF 직원, INTV 면접, TRAINEE 교육생, EQP 장비, LAB_TEAM 연구팀'
	, TARGET_SQ int         NOT NULL
	, CONTENT   text        NOT NULL
	, EMPLY_ID  varchar(50) NOT NULL COMMENT '작성자. MIGRATED 는 옛 비고·특이사항·이슈에서 옮긴 것(화면에 기존 기록, 아무도 못 지움)'
	, REG_DT    datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP
	, PRIMARY KEY (MEMO_SQ)
	, KEY IX_ROW_MEMO_TARGET (TARGET_CD, TARGET_SQ)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='목록 메모';
