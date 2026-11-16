-- 피드백 코멘트·기획서 변경 로그(2026-11-16). 코멘트를 남기면 접수로 돌아가고, 다음 처리 때 Claude 가 코멘트까지 반영해 기획서를 다시 만든다(tools/FbDb.java)
-- 되돌리기: DROP TABLE TB_EEP_FEEDBACK_LOG;
CREATE TABLE IF NOT EXISTS TB_EEP_FEEDBACK_LOG (
	  LOG_SQ    int          NOT NULL AUTO_INCREMENT
	, FB_SQ     int          NOT NULL
	, LOG_CD    varchar(10)  NOT NULL COMMENT 'COMMENT 코멘트, SPEC 기획서 작성·변경'
	, CONTENT   text         NULL COMMENT '코멘트 내용'
	, PLAN_TXT  text         NULL COMMENT 'SPEC: 그때의 바꿀 것'
	, EST_TXT   varchar(100) NULL COMMENT 'SPEC: 그때의 예상 시간'
	, SPEC_HTML mediumtext   NULL COMMENT 'SPEC: 그때의 기획서(예전 기획서 다시 보기)'
	, EMPLY_ID  varchar(50)  NOT NULL COMMENT '코멘트 쓴 사람, 기획서는 CLAUDE'
	, REG_DT    datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP
	, PRIMARY KEY (LOG_SQ)
	, KEY IX_FEEDBACK_LOG_FB (FB_SQ)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='피드백 코멘트·기획서 변경 로그';

-- 이미 붙어 있는 기획서를 첫 로그로(한 번만)
INSERT INTO TB_EEP_FEEDBACK_LOG (FB_SQ, LOG_CD, PLAN_TXT, EST_TXT, SPEC_HTML, EMPLY_ID, REG_DT)
SELECT F.FB_SQ, 'SPEC', F.PLAN_TXT, F.EST_TXT, F.SPEC_HTML, 'CLAUDE', IFNULL(F.ACT_DT, NOW())
FROM TB_EEP_FEEDBACK_M F
WHERE F.SPEC_HTML IS NOT NULL AND NOT EXISTS (SELECT 1 FROM TB_EEP_FEEDBACK_LOG L WHERE L.FB_SQ = F.FB_SQ AND L.LOG_CD = 'SPEC');
