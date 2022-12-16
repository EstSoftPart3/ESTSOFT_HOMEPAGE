package common.constant;

public class CodeConstant {
	
	/* 세션 상수 */
	public static final String IS_LOGIN 				= "IS_LOGIN";			//로그인여부
	public static final String USR_SESSN_INFO 			= "USR_SESSN_INFO";	// 사용자 정보 객체
	
	/* 오류 상수 */
	public static final String ERROR_404_MESSAGE 		= "404 Not Found";		// HTTP Response Code 404 Error Message
	public static final String ERROR_500_MESSAGE 		= "500 Internal Error";	// HTTP Response Code 500 Error Message
	public static final String KEY_GEN_ERROR_MESSAGE 	= "Create Key Failed.";	// HTTP Response Code 500 Error Message
	
	/* 쿼리 상수 */
	public static final String MYSQL_ROW_NUM	 		= "ROW_NUM";			// MySQL Row number를 사용하기 위한 상수
	public static final int DEFAULT_START_NUM 			= 0;					// 리스트 기본 시작 값
	public static final int DEFAULT_END_NUM	 			= 100000;				// 리스트 기본 종료 값
	public static final int DEFAULT_END_CNT				= 20;					// 리스트 기본 갯수
	public static final int DEFAULT_QUESTION_CNT		= 20;					// 문제은행 기본 문제 갯수
	
	/* 시스템 관련 상수 */
	public static final long SYSTEM_USR_SQ	 			= 0;					// MySQL Row number를 사용하기 위한 상수
	public static final long SYSTEM_PART_SQ	 			= 0;					// 시스템 파트 순번

	/* 인터페이스 요청 타겟 관련 상수 */
	
	/* HTTP 인터페이스 API 상수 */
	
	/* S3 인터페이스 키 상수 */
	
	/* 키 생성 상수 */
	public static final String KEY_GNRTNG_DELIMITER		= "_";					// 키 생성시 구분자
	public static final String POINT_KEY_CODE			= "POINT";				// 포인트 거래 키코드
	public static final String POINT_IO_KEY_CODE		= "PIO";				// 포인트 입출 거래 키코드
	public static final String DEPOSIT_KEY_CODE			= "DEPOSIT";			// 입금 거래 키코드
	public static final String WITHDRAW_KEY_CODE		= "WITHDRAW";			// 출금 거래 키코드
	public static final String PRDCT_PURCHS_KEY_CODE	= "PURCHASE";			// 포인트 거래 키코드
	public static final String STTLUP_KEY_CODE			= "SETTLUP";			// 정산 거래 키코드
	public static final int    DEFAULT_KEY_SEQ_CNT		= 12;					// 기본 키 순번 카운트 자릿수
	
	/* 기본 분배 비율 - 설정 테이블에 값이 없을 시 상수를 읽어들임 */
	
	/* 보상 포인트 상수 */
	
	/* 공통 JSP 경로 */
	
	/* 기타 프로그램 상수 */
	
	/* 모바일 세션 관련 상수 */
	public static final int MOBILE_SESSION_TOKEN_LENGTH	= 64;					// SHA256으로 encoding한 hash 길이
	
	/* 인터셉처 처리 관련 상수 */
	public static final String IS_AUTH	 	= "IS_AUTH";	//권한여부
	public static final String MENU_INFO 	= "MENU_INFO";	//메뉴정보
	
	/* AES256 암/복호화 키값 */
	
	/* 로그인 응답 코드 */
	public static final String LOGIN_RSV_CD00 = "LOGIN_RSV_CD00"; 	// 성공적으로 로그인 되었습니다.
	public static final String LOGIN_RSV_CD01 = "LOGIN_RSV_CD01"; 	// 입력하신 email의 계정은 존재하지 않습니다.
	public static final String LOGIN_RSV_CD02 = "LOGIN_RSV_CD02"; 	// 비밀번호가 일치하지 않습니다.
	public static final String LOGIN_RSV_CD03 = "LOGIN_RSV_CD03"; 	// 유효하지 않은 권한입니다.
	
	/* 로그인 응답 메시지 */
	public static final String LOGIN_RSV_MSG00 = "성공적으로 로그인 되었습니다.";
	public static final String LOGIN_RSV_MSG01 = "입력하신 email의 계정은 존재하지 않습니다.";
	public static final String LOGIN_RSV_MSG02 = "비밀번호가 일치하지 않습니다.";
	public static final String LOGIN_RSV_MSG03 = "로그인 권한이 없습니다.";
	
	/* 유저 권한 코드 */
	
	/* 시스템 응답 코드 */
	public static final String SYS_RCV_CD01 = "SYS_RCV_CD01"; // 처리 성공
	public static final String SYS_RCV_CD02 = "SYS_RCV_CD02"; // 처리 실패
	public static final String SYS_RCV_CD03 = "SYS_RCV_CD03"; // 처리 실패
	/* 시스템 응답 메시지 */
	public static final String SYS_RCV_MSG01 = "성공적으로 처리되었습니다."; // 처리 성공
	public static final String SYS_RCV_MSG02 = "요청에 실패하였습니다."; // 처리 실패
	public static final String SYS_RCV_MSG03 = "비밀번호가 일치하지 않습니다."; // 처리 실패
	
	/* 오류 유형 코드 */
	public static final String SYS_ERROR_TCD01 = "SYS_ERROR_TCD01"; // 로그인 정보 확인에 실패하였습니다.
	public static final String SYS_ERROR_TCD02 = "SYS_ERROR_TCD02"; // 해당 메뉴에 대하여 권한이 없습니다.
	public static final String SYS_ERROR_TCD03 = "SYS_ERROR_TCD03"; // 해당 기능에 대하여 권한이 없습니다.
	public static final String SYS_ERROR_TCD04 = "SYS_ERROR_TCD04"; // 페이지가 존재하지 않습니다.
	
	/* 오류 유형 메시지 */
	public static final String SYS_ERROR_MSG01 = "로그인이 필요합니다. \n 로그인 화면으로 이동합니다.";			// 로그인 정보 없음
	public static final String SYS_ERROR_MSG02 = "해당 메뉴에 대하여 권한이 없습니다. \n 이전 페이지로 이동합니다.";	// 메뉴 권한 없음
	public static final String SYS_ERROR_MSG03 = "해당 기능에 대하여 권한이 없습니다. \n 이전 페이지로 이동합니다.";	// 프로그램 권한 없음
	public static final String SYS_ERROR_MSG04 = "페이지가 존재하지 않습니다.";		// 페이지 없음
	
}
