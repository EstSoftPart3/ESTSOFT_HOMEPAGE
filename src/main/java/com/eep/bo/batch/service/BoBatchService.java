package com.eep.bo.batch.service;

import java.util.List;
import java.util.Map;

public interface BoBatchService {

	/** 스케줄러 진입점. AOP 프록시여도 잡히도록 인터페이스에 둔다 */
	void runInterviewScheduled();

	/** 해당 주 면접 일정을 면접관리에 반영하고 실행 이력을 돌려준다 */
	Map<String, Object> runInterview(String triggerCd);

	List<Map<String, Object>> interviewLogList();

	boolean icalUrlReady();

	void saveIcalUrl(String url);
}
