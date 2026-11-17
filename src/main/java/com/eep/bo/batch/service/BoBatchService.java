package com.eep.bo.batch.service;

import java.util.List;
import java.util.Map;

public interface BoBatchService {

	/** 스케줄러 진입점. 자동 실행으로 지정한 주소를 읽는다. AOP 프록시여도 잡히도록 인터페이스에 둔다 */
	void runInterviewScheduled();

	/** 면접 10분 전 스케줄러 진입점. 1분마다 불린다 */
	void runInterviewBeforeScheduled();

	/** 스케줄러가 마지막으로 확인한 시각과 오늘 취소되지 않은 면접 시각 */
	Map<String, Object> preRunStatus();

	/** 선택한 주소로 해당 주 면접 일정을 면접관리에 반영하고 실행 이력을 돌려준다 */
	Map<String, Object> runInterview(int icalSq);

	List<Map<String, Object>> interviewLogList();

	List<Map<String, Object>> interviewLogDetail(int logSq);

	/** 가져오기 세트(iCal + 이력서 폴더 + 드라이브 계정) 목록. 비공개 주소는 가려서 주고 토큰은 돌려주지 않는다 */
	List<Map<String, Object>> icalList();

	/** icalSq 가 null 이면 새 세트. 수정할 때 url 을 비우면 기존 주소를 유지한다 */
	void saveIcal(Integer icalSq, String name, String url, String folder);

	void deleteIcal(int icalSq);

	void setIcalAuto(int icalSq, boolean auto);

	/** 공통 구글 앱 설정. 시크릿은 끝 4자리만 돌려준다 */
	Map<String, Object> driveStatus();

	void saveDriveConf(String clientId, String clientSecret);

	/** 이력서 드라이브로 그 관리자의 내 연동을 쓴다 */
	void setDriveOwner(int icalSq, String emplyId);

	/** 내 연동(시스템 관리자)의 면접 일정 설정: {ICAL_SQ, AUTO_YN, CAL_ID, CAL_NM, LEGACY_ICAL, FOLDER_MASK}. 없으면 빈 맵 */
	Map<String, Object> interviewSource();

	void saveInterviewSource(String calId, String calName, String folder);

	/** 면접 이력서 폴더 아래 년도/월/일/이름 폴더(없으면 만듦)에 PDF 를 올린다. @return 드라이브 파일 ID */
	String saveResume(String intvDt, String name, String fileName, byte[] pdf);

	/** 파일 ID 가 있으면 그 파일, 없으면 배치와 같은 규칙(날짜·이름 폴더)으로 찾은 이력서 PDF. 없으면 null */
	byte[] resumeFile(String fileId, String intvDt, String name);

	/** 면접자 이력서의 이름 폴더(없으면 PDF)를 휴지통으로 보내고 비게 된 일·월 폴더도 보낸다. @return 보낸 대상 ID, 없으면 null */
	String trashResume(String fileId, String intvDt, String name);
}
