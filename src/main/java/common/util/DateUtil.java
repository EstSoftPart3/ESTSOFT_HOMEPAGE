package common.util;

import java.text.FieldPosition;
import java.text.ParsePosition;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.sql.Timestamp;

/**
 * <pre>
 * est.common.util
 * DateUtil.java
 * </pre>
 * 
 * @Since 2019. 5. 14.
 * @Author SH KIM
 * 
 */
public class DateUtil {

	/**
	 * 
	 * Date Format 형식으로 현재 날짜 리턴
	 * 
	 * @param dateFormat yyyy 년, MM 월, dd 일 HH 24시, mm 분, ss 초 aa 오전/오후, hh 12시 ww
	 *                   년에 있어서 주(수치) DDD 년에 있어서 날(수치) F 월에 있어서 요일(수치)
	 * @return
	 */
	public static String getNowDateTime(String dateFormat) {
		SimpleDateFormat formatter = new SimpleDateFormat(dateFormat);
		return formatter.format(Calendar.getInstance().getTime());
	}

	/**
	 * 
	 * yyyy-MM-dd HH:mm:ss 형식으로 현재 날짜 리턴
	 * 
	 * @return yyyy-MM-dd HH:mm:ss
	 */
	public static String getNowDateTime() {
		SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		return formatter.format(Calendar.getInstance().getTime());
	}

	/**
	 * 8자리로 현재 날짜 리턴
	 * 
	 * @return YYYYMMDD
	 */
	public static String getNowDate() {
		SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
		return formatter.format(Calendar.getInstance().getTime());
	}

	/**
	 * <pre>
	 * 월의 마지막 일 을 구한다
	 * sDate(yyyyMMdd or yyyy-MM-dd)
	 * </pre>
	 * 
	 * @param sDate
	 * @return int day
	 * @return 0 날짜 포맷 오류 시
	 */
	public static int getLastDayOfMonth(String sDate) {
		if (sDate == null || (sDate.length() != 8 && sDate.length() != 10)
				|| (sDate.length() == 10 && sDate.indexOf("-") == -1)) {
			return 0;
		} else {
			sDate = sDate.replaceAll("-", "");
			if (sDate.length() != 8) {
				return 0;
			} else {
				Calendar cal = Calendar.getInstance();
				cal.set(Integer.parseInt(sDate.substring(0, 4)), (Integer.parseInt(sDate.substring(4, 6)) - 1), 1); // 년월일셋팅
				return cal.getActualMaximum(Calendar.DAY_OF_MONTH);
			}
		}
	}

	/**
	 * <pre>
	 * 날짜를 받아서 해당하는 요일을 숫자로 리턴한다
	 * sDate(yyyyMMdd or yyyy-MM-dd)
	 * </pre>
	 * 
	 * @param sDate
	 * @return 0 날짜 포맷 오류 시
	 * @return int 요일(1:일,2:월,3:화,4:수,5:목,6:금,7:토)
	 */
	public static int getDayOfWeek(String sDate) {
		if (sDate == null || (sDate.length() != 8 && sDate.length() != 10)
				|| (sDate.length() == 10 && sDate.indexOf("-") == -1)) {
			return 0;
		}
		sDate = sDate.replaceAll("-", "");
		Calendar cal = Calendar.getInstance();
		cal.set(Integer.parseInt(sDate.substring(0, 4)), (Integer.parseInt(sDate.substring(4, 6)) - 1),
				Integer.parseInt(sDate.substring(6, 8)));
		int nTmp = cal.get(Calendar.DAY_OF_WEEK);
		return nTmp;
	}

	/**
	 * 날자 숫자를 받아 한글 요일로 리턴한다
	 * 
	 * @param dayOfWeek
	 * @return String (1:일요일,2:월요일,3:화요일,4:수요일,5:목요일,6:금요일,7:토요일)
	 */
	public static String getDayOfWeekToKorean(int dayOfWeek) {
		String dayStrKOR = "";
		switch (dayOfWeek) {
		case 1:
			dayStrKOR = "일요일";
			break;
		case 2:
			dayStrKOR = "월요일";
			break;
		case 3:
			dayStrKOR = "화요일";
			break;
		case 4:
			dayStrKOR = "수요일";
			break;
		case 5:
			dayStrKOR = "목요일";
			break;
		case 6:
			dayStrKOR = "금요일";
			break;
		case 7:
			dayStrKOR = "토요일";
			break;
		default:
			dayStrKOR = "";
			break;
		}
		return dayStrKOR;
	}

	/**
	 * 날자 숫자를 받아 영어 요일로 리턴한다
	 * 
	 * @param dayOfWeek
	 * @return String
	 *         (1:SUNDAY,2:MONDAY,3:TUESDAY,4:WEDNESDAY,5:THURSDAY,6:FRIDAY,7:SATURDAY)
	 */
	public static String getDayOfWeekToEnglish(int dayOfWeek) {
		String dayStrKOR = "";
		switch (dayOfWeek) {
		case 1:
			dayStrKOR = "SUNDAY";
			break;
		case 2:
			dayStrKOR = "MONDAY";
			break;
		case 3:
			dayStrKOR = "TUESDAY";
			break;
		case 4:
			dayStrKOR = "WEDNESDAY";
			break;
		case 5:
			dayStrKOR = "THURSDAY";
			break;
		case 6:
			dayStrKOR = "FRIDAY";
			break;
		case 7:
			dayStrKOR = "SATURDAY";
			break;
		default:
			dayStrKOR = "";
			break;
		}
		return dayStrKOR;
	}

	/**
	 * 입력받은 날자가 몇째 주 인지 리턴한다(셋팅된 년도 기준)
	 * 
	 * @param sDate yyyyMMdd or yyyy-MM-dd
	 * @return int 주 (비교에러 -1)
	 */
	public static int getWeekOfYear(String sDate) {
		// yyyyMMdd 이거나 yyyy-MM-dd 가 아니면 0리턴
		if (sDate == null || (sDate.length() != 8 && sDate.length() != 10)
				|| (sDate.length() == 10 && sDate.indexOf("-") == -1)) {
			return -1;
		}
		sDate = sDate.replaceAll("-", "");
		String yyyy = sDate.substring(0, 4);
		String MM = sDate.substring(4, 6);
		String dd = sDate.substring(6, 8);

		Calendar cal = Calendar.getInstance();
		cal.set(Integer.parseInt(yyyy), Integer.parseInt(MM), Integer.parseInt(dd)); // 년월일셋팅

		return cal.get(Calendar.WEEK_OF_YEAR);
	}

	/**
	 * 입력받은 날자가 몇째 주 인지 리턴한다(셋팅된 월 기준)
	 * 
	 * @param sDate yyyyMMdd or yyyy-MM-dd
	 * @return int 주 (비교에러 -1)
	 */
	public static int getWeekOfMonth(String sDate) {
		// yyyyMMdd 이거나 yyyy-MM-dd 가 아니면 0리턴
		if (sDate == null || (sDate.length() != 8 && sDate.length() != 10)
				|| (sDate.length() == 10 && sDate.indexOf("-") == -1)) {
			return -1;
		}
		sDate = sDate.replaceAll("-", "");
		String yyyy = sDate.substring(0, 4);
		String MM = sDate.substring(4, 6);
		String dd = sDate.substring(6, 8);

		Calendar cal = Calendar.getInstance();
		cal.set(Integer.parseInt(yyyy), Integer.parseInt(MM), Integer.parseInt(dd)); // 년월일셋팅

		return cal.get(Calendar.WEEK_OF_MONTH);
	}

	/**
	 * 입력받은 날자가 몇째 날 인지 리턴한다(셋팅된 년 기준)
	 * 
	 * @param sDate yyyyMMdd or yyyy-MM-dd
	 * @return int 주 (비교에러 -1)
	 */
	public static int getDayOfYear(String sDate) {
		// yyyyMMdd 이거나 yyyy-MM-dd 가 아니면 0리턴
		if (sDate == null || (sDate.length() != 8 && sDate.length() != 10)
				|| (sDate.length() == 10 && sDate.indexOf("-") == -1)) {
			return -1;
		}
		sDate = sDate.replaceAll("-", "");
		String yyyy = sDate.substring(0, 4);
		String MM = sDate.substring(4, 6);
		String dd = sDate.substring(6, 8);

		Calendar cal = Calendar.getInstance();
		cal.set(Integer.parseInt(yyyy), Integer.parseInt(MM), Integer.parseInt(dd)); // 년월일셋팅

		return cal.get(Calendar.DAY_OF_YEAR);
	}

	/**
	 * 날자를 원하는 포멧으로 리턴한다
	 * 
	 * @param sDate yyyyMMdd or yyyy-MM-dd
	 * @param delim ex("-")
	 * @return String delim format 형식으로 리턴
	 */
	public static String getDateFormat(String sDate, String delim) {
		// yyyyMMdd 이거나 yyyy-MM-dd 가 아니면 0리턴
		if (sDate == null || (sDate.length() != 8 && sDate.length() != 10)
				|| (sDate.length() == 10 && sDate.indexOf("-") == -1)) {
			return "";
		}
		sDate = sDate.replaceAll("-", "");

		String yyyy = sDate.substring(0, 4);
		String MM = sDate.substring(4, 6);
		String dd = sDate.substring(6, 8);

		String dateFormat = yyyy + delim + MM + delim + dd;

		return dateFormat;

	}

	/**
	 * 시간을 원하는 포멧으로 리턴한다
	 * 
	 * @param sTime HHmmss or HH:mm:ss
	 * @return String delim format 형식으로 리턴
	 */
	public static String getTimeFormat(String sTime, String delim) {
		// hhmmss 이거나 hh:mm-ss 가 아니면 0리턴
		if (sTime == null || (sTime.length() != 6 && sTime.length() != 8)
				|| (sTime.length() == 8 && sTime.indexOf(":") == -1)) {
			return "";
		}
		sTime = sTime.replaceAll(":", "");

		String hh = sTime.substring(0, 2);
		String mm = sTime.substring(2, 4);
		String ss = sTime.substring(4, 6);

		String timeFormat = hh + delim + mm + delim + ss;

		return timeFormat;

	}

	/**
	 * 날자 및 시간을 원하는 포멧으로 리턴한다 (yyyy-MM-dd HH:mm:ss)
	 * 
	 * @param dFormat yyyy 년, MM 월, dd 일 HH 24시, mm 분, ss 초 aa 오전/오후, hh 12시 ww 년에
	 *                있어서 주(수치) DDD 년에 있어서 날(수치) F 월에 있어서 요일(수치)
	 * @return String
	 */
	public static String getDateTimeFormat(String sDateTime, String dFormat) {
		if (sDateTime == null || sDateTime.equals("")) {
			return "";
		}

		if (dFormat == null || dFormat.equals("")) {
			dFormat = "yyyy-MM-dd HH:mm:ss";
		}

		sDateTime = sDateTime.replaceAll("-", "");
		sDateTime = sDateTime.replaceAll(":", "");
		sDateTime = sDateTime.replaceAll(" ", "");
		if (sDateTime.length() != 14) {
			return "";
		} else {
			String yyyy = sDateTime.substring(0, 4);
			String MM = sDateTime.substring(4, 6);
			String dd = sDateTime.substring(6, 8);
			String hh = sDateTime.substring(8, 10);
			String mm = sDateTime.substring(10, 12);
			String ss = sDateTime.substring(12, 14);
			Calendar cal = Calendar.getInstance();
			cal.set(Integer.parseInt(yyyy), Integer.parseInt(MM) - 1, Integer.parseInt(dd), Integer.parseInt(hh),
					Integer.parseInt(mm), Integer.parseInt(ss)); // 년월일시분초셋팅
			SimpleDateFormat formatter = new SimpleDateFormat(dFormat);
			return formatter.format(cal.getTime());
		}
	}

	/**
	 * <pre>
	 * 날자 및 시간을 원하는 포멧으로 리턴한다 (yyyy-MM-dd HH:mm:ss)
	 * yyyy 년, MM 월, dd 일
	 * HH 24시, mm 분, ss 초
	 * aa 오전/오후, hh 12시
	 * ww 년에 있어서 주(수치)
	 * DDD 년에 있어서 날(수치)
	 * F 월에 있어서 요일(수치)
	 * </pre>
	 * 
	 * @param sDateTime
	 * @return String
	 */
	public static Date getDate(String sDateTime) {
		if (sDateTime == null || sDateTime.equals("")) {
			return null;
		}

		sDateTime = sDateTime.replaceAll("-", "");
		sDateTime = sDateTime.replaceAll(":", "");
		sDateTime = sDateTime.replaceAll(" ", "");
		if (sDateTime.length() != 14) {
			return null;
		} else {
			String yyyy = sDateTime.substring(0, 4);
			String MM = sDateTime.substring(4, 6);
			String dd = sDateTime.substring(6, 8);
			String hh = sDateTime.substring(8, 10);
			String mm = sDateTime.substring(10, 12);
			String ss = sDateTime.substring(12, 14);
			Calendar cal = Calendar.getInstance();
			cal.set(Integer.parseInt(yyyy), Integer.parseInt(MM), Integer.parseInt(dd), Integer.parseInt(hh),
					Integer.parseInt(mm), Integer.parseInt(ss)); // 년월일시분초셋팅
			return cal.getTime();
		}
	}

	/**
	 * 두날짜의 간격을 계산한다
	 * 
	 * @param startDate yyyyMMdd or yyyy-MM-dd
	 * @param endDate   yyyyMMdd or yyyy-MM-dd
	 * @param type      어느것을 계산할 것인가("YEAR" : 년도, "MONTH" : 월, "DAY":일)
	 * @return int 날짜간의 차이 (오류시 -1)
	 */
	public static int dateDiff(String startDate, String endDate, String type) {
		if (startDate == null || endDate == null || startDate.equals("") || endDate.equals("")
				|| (startDate.length() != 8 && startDate.length() != 10)
				|| (startDate.length() == 10 && startDate.indexOf("-") == -1)
				|| (endDate.length() != 8 && endDate.length() != 10)
				|| (endDate.length() == 10 && endDate.indexOf("-") == -1)) {
			return -1;
		}

		startDate = startDate.replaceAll("-", "");
		endDate = endDate.replaceAll("-", "");

		if ("YEAR".equals(type.toUpperCase())) {
			return Integer.parseInt(startDate.substring(0, 4)) - Integer.parseInt(endDate.substring(0, 4));
		} else if ("MONTH".equals(type.toUpperCase())) {
			return (Integer.parseInt(startDate.substring(0, 4)) - Integer.parseInt(startDate.substring(0, 4))) * 12
					+ (Integer.parseInt(endDate.substring(4, 6)) - Integer.parseInt(endDate.substring(4, 6)));
		} else if ("DAY".equals(type.toUpperCase())) {
			Calendar cal = Calendar.getInstance();
			Calendar cal2 = Calendar.getInstance();
			cal.set(Integer.parseInt(startDate.substring(0, 4)), Integer.parseInt(startDate.substring(4, 6)) - 1,
					Integer.parseInt(startDate.substring(6, 8)));
			cal2.set(Integer.parseInt(endDate.substring(0, 4)), Integer.parseInt(endDate.substring(4, 6)) - 1,
					Integer.parseInt(endDate.substring(6, 8)));
			return (int) Math.floor(Math.abs(cal2.getTime().getTime() - cal.getTime().getTime()) / 0x5265c00L);
		} else {
			return -1;
		}
	}

	/**
	 * 두 시간의 간격을 계산한다
	 * 
	 * @param startTime 시작시간(HHmmss or HH:mm-ss)
	 * @param endTime   종료시간(HHmmss or HH:mm-ss)
	 * @return int 시간차이(초단위, 오류시-1)
	 */
	public static int timeDiff(String startTime, String endTime) {
		if (startTime == null || endTime == null || startTime.equals("") || endTime.equals("")
				|| (startTime.length() != 6 && startTime.length() != 8)
				|| (startTime.length() == 8 && startTime.indexOf(":") == -1)
				|| (endTime.length() != 6 && endTime.length() != 8)
				|| (endTime.length() == 8 && endTime.indexOf(":") == -1)) {
			return -1;
		}

		startTime = startTime.replaceAll(":", "");
		endTime = endTime.replaceAll(":", "");

		int st_sec = Integer.parseInt(startTime.substring(0, 2)) * 3600
				+ Integer.parseInt(startTime.substring(2, 4)) * 60 + Integer.parseInt(startTime.substring(4, 6));
		int to_sec = Integer.parseInt(endTime.substring(0, 2)) * 3600 + Integer.parseInt(endTime.substring(2, 4)) * 60
				+ Integer.parseInt(endTime.substring(4, 6));
		return to_sec - st_sec;
	}

	/**
	 * 날Wk시간의 차이를 계산하여 같거나 작음, 큼을 리턴한다
	 * 
	 * @param startDateTime 시작날자시간(yyyy-MM-dd HH:mm:ss)
	 * @param endDateTime   종료날자시간(yyyy-MM-dd HH:mm:ss)
	 * @return int 시작날자시간이 크면 : 1, 시작날자시간이 같으면 : 0, 시작날자시간이 작으면 : -1 비교할수없으면 -99
	 */
	public static int compareTo(String startDateTime, String endDateTime) {
		if (startDateTime == null || endDateTime == null || startDateTime.equals("") || endDateTime.equals("")) {
			return -99;
		}

		startDateTime = startDateTime.replaceAll("-", "");
		startDateTime = startDateTime.replaceAll(":", "");
		startDateTime = startDateTime.replaceAll(" ", "");

		endDateTime = endDateTime.replaceAll("-", "");
		endDateTime = endDateTime.replaceAll(":", "");
		endDateTime = endDateTime.replaceAll(" ", "");

		if (startDateTime.length() != 14 || endDateTime.length() != 14) {
			return -99;
		} else {
			String sYyyy = startDateTime.substring(0, 4);
			String sMM = startDateTime.substring(4, 6);
			String sDd = startDateTime.substring(6, 8);
			String sHh = startDateTime.substring(8, 10);
			String sMm = startDateTime.substring(10, 12);
			String sSs = startDateTime.substring(12, 14);

			Calendar sCal = Calendar.getInstance();
			sCal.set(Integer.parseInt(sYyyy), Integer.parseInt(sMM), Integer.parseInt(sDd), Integer.parseInt(sHh),
					Integer.parseInt(sMm), Integer.parseInt(sSs)); // 년월일시분초셋팅

			String eYyyy = endDateTime.substring(0, 4);
			String eMM = endDateTime.substring(4, 6);
			String eDd = endDateTime.substring(6, 8);
			String eHh = endDateTime.substring(8, 10);
			String eMm = endDateTime.substring(10, 12);
			String eSs = endDateTime.substring(12, 14);

			Calendar eCal = Calendar.getInstance();
			eCal.set(Integer.parseInt(eYyyy), Integer.parseInt(eMM), Integer.parseInt(eDd), Integer.parseInt(eHh),
					Integer.parseInt(eMm), Integer.parseInt(eSs)); // 년월일시분초셋팅

			return sCal.compareTo(eCal);
		}

	}

	/**
	 * TimeMillis 를 yyyy-MM-dd HH:mm:ss 형으로 리턴
	 * 
	 * @param ltimes
	 */
	public static String milsecTotime(String ltimes) {

		String timeStampToString = (new Timestamp(Long.parseLong(ltimes))).toString();

		return timeStampToString.substring(0, 19);
	}

	/**
	 * 현재일자를 리턴한다.(형식 yyyyMMdd)
	 *
	 * @return 현재일자
	 * @throws Exception
	 */
	public static String getToday() throws Exception {
		return getDate(new Date(), "yyyyMMdd");
	}

	/**
	 * Date 타입의 날짜를 지정한 형식의 문자형 날짜로 리턴한다.
	 *
	 * @param pDate   Date 객체
	 * @param pFormat SimpleDateFormat에 정의된 날짜형식
	 * @return 변경된 날짜
	 */
	public static String getDate(Date pDate, String pFormat) throws Exception {

		if (pDate == null)
			return "";

		StringBuffer ret = new StringBuffer();
		new SimpleDateFormat(pFormat).format(pDate, ret, new FieldPosition(0));
		return ret.toString();
	}

	/**
	 * String 타입의 날짜를 지정한 형식의 Date 타입의 날짜로 리턴한다.
	 *
	 * @param strDate String 타입의 날짜
	 * @param pFormat SimpleDateFormat에 정의된 날짜형식
	 * @return 변경된 날짜
	 */
	public static Date getDate(String strDate, String pFormat) throws Exception {
		if (strDate == null)
			return null;

		return new SimpleDateFormat(pFormat).parse(strDate, new ParsePosition(0));
	}

	/**
	 * 현재 날짜에서 원하는 일수 만큼 이동된 날짜를 리턴한다.
	 *
	 * @param offset 이동할 일수( -2147483648 ~ 2147483647 )
	 * @return 변경된 날짜
	 */
	public static String getOffsetDate(int offset) throws Exception {
		Date date = new Date();
		return getOffsetDate(date, offset, "yyyyMMdd");
	}

	/**
	 * 현재 날짜에서 원하는 일수 만큼 이동된 날짜를 리턴한다.(형식 지정)
	 *
	 * @param offset 이동할 일수( -2147483648 ~ 2147483647 )
	 * @return 변경된 날짜
	 */
	public static String getOffsetDate(int offset, String pFormat) throws Exception {
		Date date = new Date();
		return getOffsetDate(date, offset, pFormat);
	}

	/**
	 * 지정된 날짜에서 원하는 일수 만큼 이동된 날짜를 리턴한다.(디폴트형식 yyyyMMdd)
	 *
	 * @param strDate 지정된 일자(String)
	 * @param offset  이동할 일수( -2147483648 ~ 2147483647 )
	 * @return 변경된 날짜
	 */
	public static String getOffsetDate(String strDate, int offset) throws Exception {
		SimpleDateFormat fmt = new SimpleDateFormat("yyyyMMdd");
		Date date = fmt.parse(strDate);
		return getOffsetDate(date, offset, "yyyyMMdd");
	}

	/**
	 * 지정된 날짜에서 원하는 일수 만큼 이동된 날짜를 리턴한다.(형식 지정)
	 *
	 * @param strDate 지정된 일자(String)
	 * @param offset  이동할 일수( -2147483648 ~ 2147483647 )
	 * @return 변경된 날짜
	 */
	public static String getOffsetDate(String strDate, int offset, String pFormat) throws Exception {
		SimpleDateFormat fmt = new SimpleDateFormat(pFormat);
		Date date = fmt.parse(strDate);
		return getOffsetDate(date, offset, pFormat);
	}

	/**
	 * 지정된 날짜에서 원하는 일수 만큼 이동된 날짜를 리턴한다.(형식 지정)
	 *
	 * @param pDate   Date 객체
	 * @param offset  이동할 일수( -2147483648 ~ 2147483647 )
	 * @param pFormat 날짜형식
	 * @return 변경된 날짜
	 */
	public static String getOffsetDate(Date pDate, int offset, String pFormat) throws Exception {
		SimpleDateFormat fmt = new SimpleDateFormat(pFormat);
		Calendar c = Calendar.getInstance();
		String ret = "";

		try {
			c.setTime(pDate);
			c.add(Calendar.DAY_OF_MONTH, offset);
			ret = fmt.format(c.getTime());
		} catch (Exception e) {
			;
		}
		return ret;
	}

}