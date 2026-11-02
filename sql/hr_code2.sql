-- 추천자명, 외국어 코드화, 상세 코드 순서 (2026-11-02). hr_code.sql 뒤에 한 번만 실행한다
-- 외국어: LANG 은 코드를 쉼표로 이어 저장(EN,JA), 원문은 LANG_NOTE 로 옮긴다
-- 되돌리기: LANG = LANG_NOTE 로 되돌리고 추가한 칸과 HR_LANG 그룹을 지운다. 추천자명을 비고로 되돌리는 것은 다시 이관해야 한다
SET NAMES utf8mb4;

ALTER TABLE TB_EEP_HR_INTV_M
	ADD COLUMN REFERRER VARCHAR(100) NULL AFTER APLY_ROUTE,
	ADD COLUMN LANG_NOTE VARCHAR(500) NULL AFTER LANG;
ALTER TABLE TB_EEP_HR_TRAINEE_M ADD COLUMN LANG_NOTE VARCHAR(500) NULL AFTER LANG;
ALTER TABLE TB_EEP_COMN_DTL_CD_S ADD COLUMN COMN_DTL_CD_ORD INT NULL AFTER COMN_DTL_CD_NM;

START TRANSACTION;

-- 기존 HR_ 코드는 등록 순서대로 10, 20, ... 을 준다
UPDATE TB_EEP_COMN_DTL_CD_S D
JOIN (
	SELECT S.COMN_DTL_CD_SQ AS SQ, ROW_NUMBER() OVER (PARTITION BY S.COMN_CD_SQ ORDER BY S.COMN_DTL_CD_SQ) * 10 AS ORD_NO
	FROM TB_EEP_COMN_DTL_CD_S S
	JOIN TB_EEP_COMN_CD_M C ON C.COMN_CD_SQ = S.COMN_CD_SQ
	WHERE C.COMN_CD LIKE 'HR\_%'
) X ON X.SQ = D.COMN_DTL_CD_SQ
SET D.COMN_DTL_CD_ORD = X.ORD_NO;

SET @g := (SELECT MAX(COMN_CD_SQ) + 1 FROM TB_EEP_COMN_CD_M);
SET @d := (SELECT MAX(COMN_DTL_CD_SQ) FROM TB_EEP_COMN_DTL_CD_S);
INSERT INTO TB_EEP_COMN_CD_M (COMN_CD_SQ, COMN_CD, COMN_CD_NM, REG_EMPLY_SQ, REG_DT, USE_YN, DEL_YN)
VALUES (@g, 'HR_LANG', '면접·교육 외국어', 1, NOW(), 'Y', 'N');
INSERT INTO TB_EEP_COMN_DTL_CD_S (COMN_DTL_CD_SQ, COMN_CD_SQ, COMN_DTL_CD, COMN_DTL_CD_NM, COMN_DTL_CD_ORD, REG_EMPLY_SQ, REG_DT, USE_YN, DEL_YN) VALUES
	(@d:=@d+1, @g, 'EN', '영어',         10,  1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g, 'JA', '일본어',       20,  1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g, 'ZH', '중국어',       30,  1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g, 'HI', '힌디어',       40,  1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g, 'PT', '포르투갈어',   50,  1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g, 'RU', '러시아어',     60,  1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g, 'DE', '독일어',       70,  1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g, 'ID', '인도네시아어', 80,  1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g, 'FR', '프랑스어',     90,  1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g, 'VI', '베트남어',     100, 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g, 'ES', '스페인어',     110, 1, NOW(), 'Y', 'N');

-- 추천자: hr_code.sql 이 비고에 남긴 [원본 지원방법] 에서 이름만 옮기고 표시는 지운다
UPDATE TB_EEP_HR_INTV_M
SET REFERRER = TRIM(REPLACE(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(MEMO, '[원본 지원방법] ', -1), '\n', 1), '_추천', ''), ' 소개', '')),
	MEMO = NULLIF(REGEXP_REPLACE(MEMO, '\n?\\[원본 지원방법\\] [^\n]*', ''), '')
WHERE MEMO LIKE '%[원본 지원방법]%';

-- 외국어 원문은 수준 칸으로 옮긴 뒤, 원문에 나온 언어로 코드를 만든다
UPDATE TB_EEP_HR_INTV_M SET LANG_NOTE = IF(LANG IN ('없음', 'X'), NULL, LANG);
UPDATE TB_EEP_HR_TRAINEE_M SET LANG_NOTE = IF(LANG IN ('없음', 'X'), NULL, LANG);

UPDATE TB_EEP_HR_INTV_M SET LANG = NULLIF(CONCAT_WS(',',
	IF(LANG_NOTE REGEXP '영어|토익|토플|오픽|OPIc', 'EN', NULL),
	IF(LANG_NOTE REGEXP '일본어|JLPT', 'JA', NULL),
	IF(LANG_NOTE REGEXP '중국|HSK', 'ZH', NULL),
	IF(LANG_NOTE LIKE '%힌디어%', 'HI', NULL),
	IF(LANG_NOTE LIKE '%포르투갈어%', 'PT', NULL),
	IF(LANG_NOTE LIKE '%러시아어%', 'RU', NULL),
	IF(LANG_NOTE LIKE '%독일어%', 'DE', NULL),
	IF(LANG_NOTE LIKE '%인도네시아어%', 'ID', NULL),
	IF(LANG_NOTE LIKE '%프랑스어%', 'FR', NULL),
	IF(LANG_NOTE LIKE '%베트남어%', 'VI', NULL),
	IF(LANG_NOTE LIKE '%스페인어%', 'ES', NULL)), '');

UPDATE TB_EEP_HR_TRAINEE_M SET LANG = NULLIF(CONCAT_WS(',',
	IF(LANG_NOTE REGEXP '영어|토익|토플|오픽|OPIc', 'EN', NULL),
	IF(LANG_NOTE REGEXP '일본어|JLPT', 'JA', NULL),
	IF(LANG_NOTE REGEXP '중국|HSK', 'ZH', NULL),
	IF(LANG_NOTE LIKE '%힌디어%', 'HI', NULL),
	IF(LANG_NOTE LIKE '%포르투갈어%', 'PT', NULL),
	IF(LANG_NOTE LIKE '%러시아어%', 'RU', NULL),
	IF(LANG_NOTE LIKE '%독일어%', 'DE', NULL),
	IF(LANG_NOTE LIKE '%인도네시아어%', 'ID', NULL),
	IF(LANG_NOTE LIKE '%프랑스어%', 'FR', NULL),
	IF(LANG_NOTE LIKE '%베트남어%', 'VI', NULL),
	IF(LANG_NOTE LIKE '%스페인어%', 'ES', NULL)), '');

COMMIT;
