-- 면접·교육생 셀렉트박스 코드화 (2026-11-02). hr_import.ps1 로 넣은 엑셀 원문 값에 한 번만 실행한다
-- 코드는 공통코드관리(TB_EEP_COMN_CD_M, TB_EEP_COMN_DTL_CD_S)의 HR_ 그룹. 코드와 다른 원문은 MEMO 끝에 [원본 항목] 으로 남긴다
-- 되돌리기: 두 HR 테이블을 비우고 hr_import.ps1 로 다시 넣은 뒤, 공통코드의 HR_ 그룹을 지운다
SET NAMES utf8mb4;
START TRANSACTION;

-- 공통코드 테이블에 자동 증가가 없을 때도 돌도록 번호를 직접 준다
SET @g := (SELECT IFNULL(MAX(COMN_CD_SQ), 0) FROM TB_EEP_COMN_CD_M);
SET @d := (SELECT IFNULL(MAX(COMN_DTL_CD_SQ), 0) FROM TB_EEP_COMN_DTL_CD_S);

INSERT INTO TB_EEP_COMN_CD_M (COMN_CD_SQ, COMN_CD, COMN_CD_NM, REG_EMPLY_SQ, REG_DT, USE_YN, DEL_YN) VALUES
	(@g+1,  'HR_GENDER',    '면접·교육 성별',       1, NOW(), 'Y', 'N'),
	(@g+2,  'HR_ROUTE',     '면접 지원방법',        1, NOW(), 'Y', 'N'),
	(@g+3,  'HR_ATTEND',    '면접 참석',            1, NOW(), 'Y', 'N'),
	(@g+4,  'HR_RESULT',    '면접 결과',            1, NOW(), 'Y', 'N'),
	(@g+5,  'HR_NOTICE',    '면접 합격통보',        1, NOW(), 'Y', 'N'),
	(@g+6,  'HR_JOIN',      '면접 입사여부',        1, NOW(), 'Y', 'N'),
	(@g+7,  'HR_LOCAL',     '면접·교육 지방 가능',  1, NOW(), 'Y', 'N'),
	(@g+8,  'HR_INTERVIEW', '교육 인터뷰',          1, NOW(), 'Y', 'N'),
	(@g+9,  'HR_OXT',       '교육 조기파견·특수계약', 1, NOW(), 'Y', 'N'),
	(@g+10, 'HR_LEAVE',     '교육 퇴사·잠수',       1, NOW(), 'Y', 'N');

INSERT INTO TB_EEP_COMN_DTL_CD_S (COMN_DTL_CD_SQ, COMN_CD_SQ, COMN_DTL_CD, COMN_DTL_CD_NM, REG_EMPLY_SQ, REG_DT, USE_YN, DEL_YN) VALUES
	(@d:=@d+1, @g+1, 'M', '남', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+1, 'F', '여', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+2, 'SARAMIN', '사람인_공고', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+2, 'JOBKOREA', '잡코리아_공고', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+2, 'SARAMIN_BOT', '사람인_챗봇', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+2, 'WORK_EXP', '일경험프로그램', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+2, 'REFERRAL', '추천·소개', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+3, 'ATTEND', '참석', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+3, 'CANCEL', '취소', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+3, 'ABSENT', '불참', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+3, 'CHANGE', '변경', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+4, 'PASS', '합격', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+4, 'FAIL', '불합격', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+4, 'HOLD', '보류', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+4, 'CANCEL', '취소', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+5, 'WAIT', '통보대기', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+5, 'NOTIFIED', '합격통보', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+5, 'REPLY_WAIT', '답변대기', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+5, 'CONFIRM', '확정', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+5, 'REJECT', '거절', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+6, 'JOIN', '입사', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+6, 'REJECT', '거절', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+6, 'JOIN_CANCEL', '입사취소', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+6, 'NO_REPLY', '무응답', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+6, 'UNDECIDED', '미정', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+7, 'YES', '가능', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+7, 'NO', '불가능', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+7, 'COND', '조건부', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+7, 'CHECK', '확인필요', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+8, 'YES', '가능', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+8, 'NO', '불가', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+9, 'O', 'O', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+9, 'T', '▲', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+9, 'X', 'X', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+10, 'QUIT', '퇴사', 1, NOW(), 'Y', 'N'),
	(@d:=@d+1, @g+10, 'GHOST', '잠수', 1, NOW(), 'Y', 'N');

-- 면접자: 원문을 먼저 MEMO 에 남기고 값을 바꾼다
UPDATE TB_EEP_HR_INTV_M SET GENDER = CASE GENDER WHEN '남' THEN 'M' WHEN '여' THEN 'F' END;

UPDATE TB_EEP_HR_INTV_M SET MEMO = CONCAT_WS('\n', MEMO, CONCAT('[원본 지원방법] ', APLY_ROUTE))
WHERE APLY_ROUTE NOT IN ('사람인_공고', '잡코리아_공고', '잡코_공고', '사람인_챗봇', '일경험프로그램');
UPDATE TB_EEP_HR_INTV_M SET APLY_ROUTE = CASE
	WHEN APLY_ROUTE IS NULL THEN NULL
	WHEN APLY_ROUTE = '사람인_공고' THEN 'SARAMIN'
	WHEN APLY_ROUTE IN ('잡코리아_공고', '잡코_공고') THEN 'JOBKOREA'
	WHEN APLY_ROUTE = '사람인_챗봇' THEN 'SARAMIN_BOT'
	WHEN APLY_ROUTE = '일경험프로그램' THEN 'WORK_EXP'
	ELSE 'REFERRAL' END;

UPDATE TB_EEP_HR_INTV_M SET ATTEND_ST = CASE ATTEND_ST
	WHEN '참여' THEN 'ATTEND' WHEN '참석' THEN 'ATTEND' WHEN '취소' THEN 'CANCEL' WHEN '불참' THEN 'ABSENT' WHEN '변경' THEN 'CHANGE' END;

UPDATE TB_EEP_HR_INTV_M SET MEMO = CONCAT_WS('\n', MEMO, CONCAT('[원본 결과] ', RESULT_ST))
WHERE RESULT_ST NOT IN ('합격', '불합격', '보류', '취소');
UPDATE TB_EEP_HR_INTV_M SET RESULT_ST = CASE
	WHEN RESULT_ST IS NULL THEN NULL
	WHEN RESULT_ST LIKE '합격%' THEN 'PASS'
	WHEN RESULT_ST = '불합격' THEN 'FAIL'
	WHEN RESULT_ST = '보류' THEN 'HOLD'
	WHEN RESULT_ST = '취소' THEN 'CANCEL' END;

UPDATE TB_EEP_HR_INTV_M SET MEMO = CONCAT_WS('\n', MEMO, CONCAT('[원본 합격통보] ', NOTICE_ST))
WHERE NOTICE_ST NOT IN ('통보대기', '합격통보', '답변대기', '확정', '거절', '발신대기');
UPDATE TB_EEP_HR_INTV_M SET NOTICE_ST = CASE
	WHEN NOTICE_ST IS NULL THEN NULL
	WHEN NOTICE_ST LIKE '수신대기%' OR NOTICE_ST = '답변대기' THEN 'REPLY_WAIT'
	WHEN NOTICE_ST = '합격통보' THEN 'NOTIFIED'
	WHEN NOTICE_ST = '확정' THEN 'CONFIRM'
	WHEN NOTICE_ST = '거절' THEN 'REJECT'
	ELSE 'WAIT' END;

UPDATE TB_EEP_HR_INTV_M SET MEMO = CONCAT_WS('\n', MEMO, CONCAT('[원본 입사여부] ', JOIN_ST))
WHERE JOIN_ST NOT IN ('입사', '거절', '입사취소', '무응답', '미정');
UPDATE TB_EEP_HR_INTV_M SET JOIN_ST = CASE
	WHEN JOIN_ST IS NULL THEN NULL
	WHEN JOIN_ST LIKE '입사취소%' OR JOIN_ST = '취소' THEN 'JOIN_CANCEL'
	WHEN JOIN_ST LIKE '입사%' THEN 'JOIN'
	WHEN JOIN_ST LIKE '거절%' THEN 'REJECT'
	WHEN JOIN_ST = '무응답' THEN 'NO_REPLY'
	ELSE 'UNDECIDED' END;

UPDATE TB_EEP_HR_INTV_M SET MEMO = CONCAT_WS('\n', MEMO, CONCAT('[원본 지방 가능] ', LOCAL_YN))
WHERE LOCAL_YN NOT IN ('가능', '지방가능', '불가능', '불가', 'X', '확인필요');
UPDATE TB_EEP_HR_INTV_M SET LOCAL_YN = CASE
	WHEN LOCAL_YN IS NULL THEN NULL
	WHEN LOCAL_YN LIKE '불가%' OR LOCAL_YN = 'X' THEN 'NO'
	WHEN LOCAL_YN LIKE '가능%' OR LOCAL_YN = '지방가능' THEN 'YES'
	WHEN LOCAL_YN = '확인필요' OR LOCAL_YN LIKE '리액트%' THEN 'CHECK'
	ELSE 'COND' END;

-- 교육생: 인터뷰와 인터뷰 가능일이 뒤바뀐 행을 먼저 제자리로. 45555 같은 값은 엑셀 날짜 번호다
UPDATE TB_EEP_HR_TRAINEE_M
SET INTERVIEW_AVAIL = CONCAT(DATE_ADD('1899-12-30', INTERVAL INTERVIEW_YN DAY), '|', IFNULL(INTERVIEW_AVAIL, ''))
WHERE INTERVIEW_YN REGEXP '^[0-9]+$';
UPDATE TB_EEP_HR_TRAINEE_M
SET INTERVIEW_YN = NULLIF(SUBSTRING_INDEX(INTERVIEW_AVAIL, '|', -1), ''), INTERVIEW_AVAIL = SUBSTRING_INDEX(INTERVIEW_AVAIL, '|', 1)
WHERE INTERVIEW_AVAIL LIKE '%|%';
UPDATE TB_EEP_HR_TRAINEE_M SET INTERVIEW_YN = INTERVIEW_AVAIL, INTERVIEW_AVAIL = NULL
WHERE INTERVIEW_YN IS NULL AND INTERVIEW_AVAIL IN ('가능', '불가');
UPDATE TB_EEP_HR_TRAINEE_M SET INTERVIEW_YN = CASE INTERVIEW_YN WHEN '가능' THEN 'YES' WHEN '불가' THEN 'NO' END;

UPDATE TB_EEP_HR_TRAINEE_M SET GENDER = CASE GENDER WHEN '남' THEN 'M' WHEN '여' THEN 'F' END;
UPDATE TB_EEP_HR_TRAINEE_M SET LEAVE_NOTE = CASE LEAVE_NOTE WHEN '퇴사' THEN 'QUIT' WHEN '잠수' THEN 'GHOST' END;
UPDATE TB_EEP_HR_TRAINEE_M SET LOCAL_YN = CASE
	WHEN LOCAL_YN IS NULL THEN NULL
	WHEN LOCAL_YN IN ('불가능', '불가', 'X') THEN 'NO'
	WHEN LOCAL_YN = '가능' THEN 'YES'
	WHEN LOCAL_YN = '확인필요' THEN 'CHECK'
	ELSE 'COND' END;
UPDATE TB_EEP_HR_TRAINEE_M SET EARLY_YN = CASE EARLY_YN WHEN 'O' THEN 'O' WHEN '▲' THEN 'T' WHEN 'X' THEN 'X' END;
UPDATE TB_EEP_HR_TRAINEE_M SET SPECIAL_YN = CASE SPECIAL_YN WHEN 'O' THEN 'O' WHEN '▲' THEN 'T' WHEN 'X' THEN 'X' END;

COMMIT;
