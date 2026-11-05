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

	/** 클라이언트 설정이 올바르지 않으면 null */
	String driveAuthUrl(String redirectUri, String state);

	/** @return refresh token 을 받아 그 세트에 저장했으면 true */
	boolean connectDrive(int icalSq, String redirectUri, String code);
}
