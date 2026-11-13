-- 피드백·업데이트 내역(2026-11-13, plans/feedback-spec.html, plans/update-history-spec.html)
-- 두 메뉴(U00001·U00002)는 BoSystemService.OPEN_MENUS 라 권한 설정 없이 모든 관리자에게 열린다. 진행·보류·반려는 SUPER·SYS 권한만.
-- 되돌리기: DROP TABLE TB_EEP_FEEDBACK_M, TB_EEP_UPDATE_H; DELETE FROM TB_EEP_MENU WHERE MENU_CODE IN ('U00001', 'U00002'); 공통코드 FB_KIND·FB_STATUS 삭제
CREATE TABLE IF NOT EXISTS TB_EEP_FEEDBACK_M (
	  FB_SQ         int          NOT NULL AUTO_INCREMENT
	, SCREEN_NM     varchar(100) NULL COMMENT '보낼 때 열려 있던 화면 탭 이름'
	, SCREEN_URL    varchar(300) NULL
	, KIND_CD       varchar(20)  NOT NULL COMMENT '공통코드 FB_KIND'
	, CONTENT       text         NOT NULL
	, EMPLY_ID      varchar(50)  NOT NULL COMMENT '요청자'
	, REG_DT        datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP
	, STATUS_CD     varchar(20)  NOT NULL DEFAULT 'NEW' COMMENT '공통코드 FB_STATUS: NEW 접수, REVIEW 검토 대기, ING 진행 중, DONE 반영, HOLD 보류, REJECT 반려'
	, PLAN_TXT      text         NULL COMMENT 'Claude 기획서의 바꿀 것(진행 창에 미리 채움)'
	, EST_TXT       varchar(100) NULL COMMENT '예상 소요 시간'
	, SPEC_HTML     mediumtext   NULL COMMENT 'Claude 기획서 HTML(스크립트 없이 iframe sandbox 로 보임)'
	, DEV_NOTE      text         NULL COMMENT '진행할 때 적은 개발 반영 내용. Claude 는 이대로 개발'
	, REJECT_REASON text         NULL
	, ACT_EMPLY_ID  varchar(50)  NULL COMMENT '진행·보류·반려한 사람'
	, ACT_DT        datetime     NULL
	, UPD_SQ        int          NULL COMMENT '반영된 업데이트 내역'
	, SEEN_YN       char(1)      NOT NULL DEFAULT 'Y' COMMENT '요청자가 마지막 상태 변경을 봤는지(N 이면 피드백 버튼에 숫자)'
	, PRIMARY KEY (FB_SQ)
	, KEY IX_FEEDBACK_EMPLY (EMPLY_ID)
	, KEY IX_FEEDBACK_STATUS (STATUS_CD)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='관리자 피드백';

CREATE TABLE IF NOT EXISTS TB_EEP_UPDATE_H (
	  UPD_SQ       int          NOT NULL AUTO_INCREMENT
	, TITLE        varchar(200) NOT NULL
	, SCREENS      varchar(200) NULL COMMENT '바뀐 화면 이름(쉼표)'
	, CHANGED_TXT  text         NULL COMMENT '수정한 것(줄마다 한 항목)'
	, TESTS_TXT    text         NULL COMMENT '테스트할 것'
	, CAUTIONS_TXT text         NULL COMMENT '주의할 것'
	, SPEC_HTML    mediumtext   NULL COMMENT '바뀐 화면 목업 HTML'
	, COMMIT_ID    varchar(40)  NULL
	, FB_SQ        int          NULL COMMENT '피드백 반영이면 그 피드백'
	, DEPLOY_DT    datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP
	, PRIMARY KEY (UPD_SQ)
	, KEY IX_UPDATE_DT (DEPLOY_DT)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='업데이트 내역. 배포할 때 한 건씩 쌓는다';

INSERT INTO TB_EEP_COMN_CD_M (COMN_CD, COMN_CD_NM, USE_YN, DEL_YN, REG_DT)
SELECT V.CD, V.NM, 'Y', 'N', DATE_FORMAT(NOW(), '%Y-%m-%d')
FROM (SELECT 'FB_KIND' CD, '피드백 종류' NM UNION ALL SELECT 'FB_STATUS', '피드백 상태') V
WHERE NOT EXISTS (SELECT 1 FROM TB_EEP_COMN_CD_M C WHERE C.COMN_CD = V.CD AND C.DEL_YN = 'N');

INSERT INTO TB_EEP_COMN_DTL_CD_S (COMN_CD_SQ, COMN_DTL_CD, COMN_DTL_CD_NM, COMN_DTL_CD_ORD, USE_YN, DEL_YN, REG_DT)
SELECT C.COMN_CD_SQ, V.CD, V.NM, V.ORD, 'Y', 'N', DATE_FORMAT(NOW(), '%Y-%m-%d')
FROM (
	          SELECT 'FB_KIND' GRP, 'INCONV' CD, '불편' NM, 1 ORD
	UNION ALL SELECT 'FB_KIND', 'BUG', '오류', 2
	UNION ALL SELECT 'FB_KIND', 'NEW', '새 기능', 3
	UNION ALL SELECT 'FB_STATUS', 'NEW', '접수', 1
	UNION ALL SELECT 'FB_STATUS', 'REVIEW', '검토 대기', 2
	UNION ALL SELECT 'FB_STATUS', 'ING', '진행 중', 3
	UNION ALL SELECT 'FB_STATUS', 'DONE', '반영', 4
	UNION ALL SELECT 'FB_STATUS', 'HOLD', '보류', 5
	UNION ALL SELECT 'FB_STATUS', 'REJECT', '반려', 6
) V
JOIN TB_EEP_COMN_CD_M C ON C.COMN_CD = V.GRP AND C.DEL_YN = 'N'
WHERE NOT EXISTS (SELECT 1 FROM TB_EEP_COMN_DTL_CD_S D WHERE D.COMN_CD_SQ = C.COMN_CD_SQ AND D.COMN_DTL_CD = V.CD AND D.DEL_YN = 'N');

INSERT INTO TB_EEP_MENU (MENU_CODE, MENU_NM, REL_CODE, MENU_DEPTH, MENU_URL, ICON_NM, SORT_NO, USE_YN, AUTH_PATTERN, NEW_WIN_YN, FRST_REGISTER, FRST_REG_DT, LAST_UPDT_DT)
SELECT V.CD, V.NM, 'C001', '2', V.URL, NULL, V.ORD, 'Y', V.PAT, 'N', 'system', NOW(), NOW()
FROM (
	          SELECT 'U00001' CD, '업데이트 내역' NM, '/admin/update/openUpdateList.do' URL, '/admin/update/**' PAT, 5 ORD
	UNION ALL SELECT 'U00002', '피드백', '/admin/feedback/openFeedbackList.do', '/admin/feedback/**', 6
) V
WHERE NOT EXISTS (SELECT 1 FROM TB_EEP_MENU M WHERE M.MENU_CODE = V.CD);
