package com.eep.bo.hr.service;

import java.util.List;
import java.util.Map;

public interface BoHrService {

	/**
	 * 업무툴 - 면접·교육생 관리 Service
	 * 값이 잘못되면 IllegalArgumentException(사용자에게 보여줄 메시지)을 던진다
	 *
	 * **/

	List<Map<String, Object>> CodeList();										//셀렉트박스 코드
	List<Map<String, Object>> IntvList();										//면접자 전체 목록
	void IntvSave(Map<String, Object> param);									//면접자 등록·수정
	void IntvDelete(Map<String, Object> param);									//면접자 삭제
	Map<String, Object> ReadResume(byte[] pdf, String fileName);				//이력서 PDF 에서 면접자 칸 값 읽기(저장 안 함)
	void IntvResumeSave(Object intvSq, String kind, String fileName, byte[] data);	//면접자 서류(RESUME·PORTFOLIO PDF, PROFILE DOCX)를 드라이브에 올리고 위치를 기억
	byte[] IntvResumeFile(Object intvSq, String kind);							//면접자 서류 파일. 없으면 null
	void IntvNoteSave(Object intvSq, String note, String loginId);				//면접결과 기록(칩으로 고른 값 JSON)
	List<Map<String, Object>> IntvCodeSave(String kind, String act, String name);	//면접결과 칩 예시 추가(ADD)·빼기(DEL). 바뀐 화면용 코드 전체를 돌려준다
	boolean TraineeFromIntv(Map<String, Object> param);							//면접자를 교육생으로 등록. 이미 등록돼 있으면 false
	boolean WaitFromIntv(Map<String, Object> param);							//경력직 면접자를 직원관리 대기자로 등록. 신입이거나 이미 등록돼 있으면 false

	List<Map<String, Object>> TraineeList();									//교육생 전체 목록
	void TraineeSave(Map<String, Object> param);								//교육생 등록·수정
	void TraineeFieldSave(Map<String, Object> param);							//목록·칸반에서 칸 하나 저장
	void IntvFieldSave(Map<String, Object> param);								//목록에서 칸 하나 저장
	void TraineeSkillSave(Map<String, Object> param);							//기술 평가 한 칸 수정
	void TraineeDelete(Map<String, Object> param);								//교육생 삭제

	/** 교육종료·중도이탈 전에 반납할 대여 장비가 있을 때. 화면에서 목록으로 확인받고 RETURN_YN=Y 로 다시 보낸다 */
	class NeedReturn extends RuntimeException {
		private static final long serialVersionUID = 1L;
		public final List<Map<String, Object>> rents;

		public NeedReturn(List<Map<String, Object>> rents) {
			super("반납하지 않은 대여 장비가 있습니다.");
			this.rents = rents;
		}
	}
}
