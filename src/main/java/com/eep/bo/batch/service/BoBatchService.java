package com.eep.bo.batch.service;

import java.util.List;
import java.util.Map;

public interface BoBatchService {

	/** 스케줄러 진입점. 자동 실행으로 지정한 주소를 읽는다. AOP 프록시여도 잡히도록 인터페이스에 둔다 */
	void runInterviewScheduled();

	/** 선택한 주소로 해당 주 면접 일정을 면접관리에 반영하고 실행 이력을 돌려준다 */
	Map<String, Object> runInterview(int icalSq);

	List<Map<String, Object>> interviewLogList();

	List<Map<String, Object>> interviewLogDetail(int logSq);

	/** 등록된 iCal 주소 목록. 비공개 주소 값은 돌려주지 않는다 */
	List<Map<String, Object>> icalList();

	void saveIcal(String name, String url);

	void deleteIcal(int icalSq);

	void setIcalAuto(int icalSq, boolean auto);

	/** 이력서 드라이브 연결 상태. 시크릿과 토큰은 돌려주지 않는다 */
	Map<String, Object> driveStatus();

	void saveDriveConf(String clientId, String clientSecret, String folder);

	/** 클라이언트가 설정되지 않았으면 null */
	String driveAuthUrl(String redirectUri, String state);

	/** @return refresh token 을 받아 저장했으면 true */
	boolean connectDrive(String redirectUri, String code);
}
