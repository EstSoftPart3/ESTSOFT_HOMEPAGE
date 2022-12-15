package common.base.vo;

import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import common.util.CommonUtils;
import common.util.ObjectConvertUtil;

/*import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter*/
public class BaseVo {
	
	protected static final int MAX_VARIABLE_LENGTH = 30;
	
	// Start DB Row Number
	protected int start;
	
	// End DB Row Number
	protected int end;
	
	// 프로그램 ID
	protected String ProgrmId;
	
	// 화면 ID
	protected String scrId;
		
	// 화면 경로
	protected String viewNm;
	
	// 응답코드
	protected String rcvCd;
	
	// 응답메시지
	protected String rcvMsg;
	

	public Object toListMap() {
		Object obj = null;
		
		return obj;
	}
	
	public Object toList() {
		Object obj = null;
		
		return obj;
	}
	
	protected String getSpaces(int count) {
		String spaces = "";
		
		if ( count > MAX_VARIABLE_LENGTH ) {
			
		} else {
			int cnt = MAX_VARIABLE_LENGTH - count;
			
			while(cnt > 0) {
				spaces += " ";
				cnt--;
			}
		}
		
		return spaces;
	}
	
	/**
	 * 
	 * 1. 객체를 맵으로 변환
	 * 2. 객체의 카멜 타입의 변수를 언더바 대문자로 바꾸어 맵의 키로 변환
	 * 
	 * @return
	 */
	public Map<String, Object> toMap() {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		toMap(this, returnMap);
		
		return returnMap;
	}
	
	/**
	 * 
	 * BaseVo까지 recursive로 호출.
	 * 
	 * @param vo
	 * @param returnMap
	 * @throws ClassNotFoundException 
	 */
	@SuppressWarnings({ "unchecked" })
	protected void toMap(Object vo, Map<String, Object> returnMap) {
		Map<String, Object> planeMap = ObjectConvertUtil.convertObjectToMap(vo);
		
		Set<String> keySet = planeMap.keySet();
		Iterator<String> keyiterator = keySet.iterator();
		while(keyiterator.hasNext()) {
			String key = keyiterator.next();
			String convertKey = ObjectConvertUtil.convertCamelToUnderscore(key).toUpperCase();
			
			returnMap.put(convertKey, planeMap.get(key));
		}
//		
//		Field[] fields = vo.getClass().getDeclaredFields();
//		Field field = null;
//		boolean isBaseVo = false;
//		try{
//			field = vo.getClass().getDeclaredField("MAX_VARIABLE_LENGTH");
//		} catch ( NoSuchFieldException e ) {
//			isBaseVo = true;
//		}
//		
//		if ( isBaseVo ) {
//			Object superCls = vo.getClass().getSuperclass();
//			toMap(superCls, returnMap) ;
//		}
	}

	/**
	 * 
	 * 1. 객체를 맵으로 변환 - 변수명을 키로 사용
	 * 2. 맵 키: 객체의 변수, 맵 값: 객체의 변수의 값
	 * 
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public Map<String, Object> toPlaneMap() {
		Map<String, Object> returnMap = ObjectConvertUtil.convertObjectToMap(this);
		
		return returnMap;
	}
	
	@SuppressWarnings({ "rawtypes" })
	@Override
	public String toString() {
		
		StringBuilder sb = new StringBuilder();
		
		sb.append("\nClass[" +  this.getClass().getName() + "]\n");
		
		Object obj = this;
		
		sb.append("------------------- class fields --------------\n");
		
		// class fields
		Field[] fieldArray = obj.getClass().getDeclaredFields();
		
		for ( int ii = 0 ; ii < fieldArray.length ; ii ++ ) {
			fieldArray[ii].setAccessible(true);
			String variableName = fieldArray[ii].getName();
			String variableValue;
			try {
				if ( fieldArray[ii].get(obj) instanceof List ) {
					List list = (List) fieldArray[ii].get(obj);
					String prefix = "\t\t\t";
					String clsNm = fieldArray[ii].get(obj).getClass().getName();
					if ( list != null && list.size() > 0 ) {
						clsNm = list.get(0).getClass().getName();
					}
					variableValue = "[List]\n" + CommonUtils.getListString(list, prefix, clsNm);
				} else {
					variableValue = fieldArray[ii].get(obj) + "";
				}
			} catch (IllegalArgumentException | IllegalAccessException e) {
				continue;
			}
			
			sb.append(variableName);
			
			if ( MAX_VARIABLE_LENGTH > variableName.length() ) {
				int index = variableName.length();
				while ( MAX_VARIABLE_LENGTH > index ) {
					sb.append(" ");
					index++;
				}
			}
			
			sb.append(" = ");
			sb.append(variableValue);
			sb.append("\n");
		}
		
		sb.append("\n-------------- super class fields --------------\n");
		// super class fields
		Field[] superFieldArray = obj.getClass().getSuperclass().getDeclaredFields();
		
		for ( int ii = 0 ; ii < superFieldArray.length ; ii ++ ) {
			String variableName = superFieldArray[ii].getName();
			String variableValue;
			
			try {
				if ( superFieldArray[ii].get(obj) instanceof List ) {
					List list = (List) superFieldArray[ii].get(obj);
					String prefix = "\t\t\t";
					String clsNm = superFieldArray[ii].get(obj).getClass().getName();
					if ( list != null && list.size() > 0 ) {
						clsNm = list.get(0).getClass().getName();
					}
					variableValue = "[List]\n" + CommonUtils.getListString(list, prefix, clsNm);
				} else {
					variableValue = superFieldArray[ii].get(obj) + "";
				}
			} catch (IllegalArgumentException | IllegalAccessException e) {
				continue;
			}
			
			if ( !"MAX_VARIABLE_LENGTH".equals(variableName) ) {
				sb.append(variableName);
				
				if ( MAX_VARIABLE_LENGTH > variableName.length() ) {
					int index = variableName.length();
					while ( MAX_VARIABLE_LENGTH > index ) {
						sb.append(" ");
						index++;
					}
				}
				
				sb.append(" = ");
				sb.append(variableValue);
				sb.append("\n");
			}
		}
		
		sb.append("\n-------------- ancient class fields --------------\n");
		// ancient class fields
		Field[] ancientFieldArray = obj.getClass().getSuperclass().getSuperclass().getDeclaredFields();
		
		for ( int ii = 0 ; ii < ancientFieldArray.length ; ii ++ ) {
			String variableName = ancientFieldArray[ii].getName();
			String variableValue;
			
			try {
				if ( ancientFieldArray[ii].get(obj) instanceof List ) {
					List list = (List) ancientFieldArray[ii].get(obj);
					String prefix = "\t\t\t";
					String clsNm = ancientFieldArray[ii].get(obj).getClass().getName();
					if ( list != null && list.size() > 0 ) {
						clsNm = list.get(0).getClass().getName();
					}
					variableValue = "[List]\n" + CommonUtils.getListString(list, prefix, clsNm);
				} else {
					variableValue = ancientFieldArray[ii].get(obj) + "";
				}
			} catch (IllegalArgumentException | IllegalAccessException e) {
				continue;
			}
			
			if ( !"MAX_VARIABLE_LENGTH".equals(variableName) ) {
				sb.append(variableName);
				
				if ( MAX_VARIABLE_LENGTH > variableName.length() ) {
					int index = variableName.length();
					while ( MAX_VARIABLE_LENGTH > index ) {
						sb.append(" ");
						index++;
					}
				}
				
				sb.append(" = ");
				sb.append(variableValue);
				sb.append("\n");
			}
		}
		
		return sb.toString();
	}

//	/**
//	 * 
//	 * 부모 클래스의 변수와 값을 얻기 위해 recursive 호출
//	 * 
//	 * @param sb
//	 * @param obj
//	 */
//	protected void toString(StringBuilder sb, Object obj) {
//		Field[] fieldArray = obj.getClass().getDeclaredFields();
//		
//		for ( int ii = 0 ; ii < fieldArray.length ; ii ++ ) {
////			fieldArray[ii].setAccessible(true);
//			String variableName = fieldArray[ii].getName();
//			String variableValue;
//			try {
//				variableValue = fieldArray[ii].get(obj) + "";
//			} catch (IllegalArgumentException | IllegalAccessException e) {
////				sb.append(e.getStackTrace());
////				e.printStackTrace();
//				continue;
//			}
//			
//			sb.append(variableName);
//			
//			if ( MAX_VARIABLE_LENGTH > variableName.length() ) {
//				int index = variableName.length();
//				while ( MAX_VARIABLE_LENGTH > index ) {
//					sb.append(" ");
//					index++;
//				}
//			}
//			
//			sb.append(" = ");
//			sb.append(variableValue);
//			sb.append("\n");
//		}
//		
//	}
	
}
