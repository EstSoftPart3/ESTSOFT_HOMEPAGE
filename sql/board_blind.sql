-- 게시글 블라인드: 홈페이지(외부)에서 제목·내용을 가리고 상세를 막는다. 관리자 게시판 관리 목록의 스위치로 켠다.
-- 되돌리기: ALTER TABLE TB_EEP_BRD_M DROP COLUMN BLIND_YN;
ALTER TABLE TB_EEP_BRD_M ADD COLUMN BLIND_YN char(1) NOT NULL DEFAULT 'N' COMMENT '블라인드 여부' AFTER DEL_YN;
