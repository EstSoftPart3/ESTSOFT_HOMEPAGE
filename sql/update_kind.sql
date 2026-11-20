-- 업데이트 내역 분류·중요도(2026-11-20, plans/update-kind-spec.html)
-- KIND_CD: NEW 새 기능, UI 화면 개선, FIX 오류 수정, PROC 프로세스·운영 변경. MAJOR_YN: Y 면 「주요 변경」 카드, N 이면 날짜별 묶음에 접힘
-- 앞으로는 tools/FbDb.java update 의 @@KIND·@@MAJOR 로 들어간다
-- 되돌리기: ALTER TABLE TB_EEP_UPDATE_H DROP COLUMN KIND_CD, DROP COLUMN MAJOR_YN;
ALTER TABLE TB_EEP_UPDATE_H
	  ADD COLUMN KIND_CD  varchar(10) NOT NULL DEFAULT 'UI' COMMENT 'NEW 새 기능, UI 화면 개선, FIX 오류 수정, PROC 프로세스·운영' AFTER TITLE
	, ADD COLUMN MAJOR_YN char(1)     NOT NULL DEFAULT 'N' COMMENT 'Y 주요 변경(카드), N 자잘한 변경(묶음)' AFTER KIND_CD;

-- 2026-11-13~11-20 에 쌓인 1~100번 분류(초안을 사용자가 화면에서 확인)
UPDATE TB_EEP_UPDATE_H SET KIND_CD = 'NEW' WHERE UPD_SQ IN (1, 2, 4, 6, 8, 17, 21, 25, 30, 33, 34, 36, 37, 38, 46, 48, 49, 59, 61, 65, 69, 70, 79, 87, 89, 93, 98, 99);
UPDATE TB_EEP_UPDATE_H SET KIND_CD = 'FIX' WHERE UPD_SQ IN (19, 31, 35, 44, 45, 53, 54, 60, 64, 73, 84, 88, 90, 94, 96);
UPDATE TB_EEP_UPDATE_H SET KIND_CD = 'PROC' WHERE UPD_SQ IN (9, 15, 16, 23, 24, 26, 40, 41, 51, 52, 55, 92, 100);
UPDATE TB_EEP_UPDATE_H SET MAJOR_YN = 'Y' WHERE UPD_SQ IN (1, 3, 4, 12, 17, 21, 24, 25, 36, 37, 38, 41, 46, 48, 61, 65, 70, 79, 83, 93);
