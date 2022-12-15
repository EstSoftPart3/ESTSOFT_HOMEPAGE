package common.util;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.json.simple.JSONObject;

import common.base.vo.SearchVo;

/**
 * <pre>
 * est.common.util
 * ObjectConvertUtil.java
 * </pre>
 * 
 * @Since 2019. 5. 14.
 * @Author SH KIM
 * 
 */
public class ObjectConvertUtil {

	public static void main(String args[]) {
		String camel = "testTestTESTaAaAaA";

		System.out.println(convertCamelToUnderscore(camel));
	}

	/**
	 * 
	 * Object를 Map으로 변환
	 * 
	 * @param map
	 * @param obj
	 * @return
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public static Map convertObjectToMap(Object obj) {
		Map map = new HashMap();

		Field[] fields = obj.getClass().getDeclaredFields();
		for (int i = 0; i < fields.length; i++) {
			fields[i].setAccessible(true);
			try {
				map.put(fields[i].getName(), fields[i].get(obj));
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		// 상속받은 부모 클래스 필드까지 추가
		Field[] superFields = obj.getClass().getSuperclass().getDeclaredFields();
		for (int i = 0; i < superFields.length; i++) {
			superFields[i].setAccessible(true);
			try {
				map.put(superFields[i].getName(), superFields[i].get(obj));
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		// 상속받은 조상 클래스 필드까지 추가(3depth)
		Field[] ancientFields = obj.getClass().getSuperclass().getSuperclass().getDeclaredFields();
		for (int i = 0; i < ancientFields.length; i++) {
			ancientFields[i].setAccessible(true);
			try {
				map.put(ancientFields[i].getName(), ancientFields[i].get(obj));
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		return map;
	}

	/**
	 * 
	 * Object를 JSONObject로 변환
	 * 
	 * @param map
	 * @param obj
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	public static JSONObject convertObjectToJSONObject(Object obj) {
		JSONObject json = new JSONObject();

		Field[] fields = obj.getClass().getDeclaredFields();
		for (int i = 0; i < fields.length; i++) {
			fields[i].setAccessible(true);
			try {
				json.put(fields[i].getName(), fields[i].get(obj));
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

        // 상속받은 부모 클래스 필드까지 추가
        Field[] superFields = obj.getClass().getSuperclass().getDeclaredFields();
        for(int i=0; i <superFields.length; i++){
            superFields[i].setAccessible(true);
            try{
                json.put(superFields[i].getName(), superFields[i].get(obj));
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        // 상속받은 조상 클래스 필드까지 추가(3depth)
        Field[] ancientFields = obj.getClass().getSuperclass().getSuperclass().getDeclaredFields();
        for(int i=0; i <ancientFields.length; i++){
            ancientFields[i].setAccessible(true);
            try{
                json.put(ancientFields[i].getName(), ancientFields[i].get(obj));
            }catch(Exception e){
                e.printStackTrace();
            }
        }

		return json;
	}

	/**
	 * 
	 * Map을 Object로 변환
	 * 
	 * @param map
	 * @param obj
	 * @return
	 */
	@SuppressWarnings("rawtypes")
	public static Object convertMapToObject(Map<String, Object> map, Object obj) {
		String keyAttribute = null;
		String setMethodString = "set";
		String methodString = null;
		Iterator itr = map.keySet().iterator();

		while (itr.hasNext()) {
			keyAttribute = (String) itr.next();
			methodString = setMethodString + keyAttribute.substring(0, 1).toUpperCase() + keyAttribute.substring(1);
			Method[] methods = obj.getClass().getDeclaredMethods();
			for (int i = 0; i < methods.length; i++) {
				if (methodString.equals(methods[i].getName())) {
					try {
						methods[i].invoke(obj, map.get(keyAttribute));
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			}
		}
		return obj;
	}
	
	/**
	 * 
	 * SearchVo를 Map 형태로 변환. (일반 VO변환과 다름)
	 * 
	 * @param searchVo	검색VO
	 * @return	검색키, 검색값을 가지는 Map
	 */
	public static Map<String, Object> convertSearchVoToMap(List<SearchVo> searchVo) {
		Map<String, Object> paramMap = new HashMap<String, Object>();
		
		if ( searchVo != null ) {
			for ( int ii = 0 ; ii < searchVo.size() ; ii++ ) {
				paramMap.put(searchVo.get(ii).getSearchKeyWord(), searchVo.get(ii).getSearchValue());
			}
		}
		
		return paramMap;
	}
	
	
	/**
	 * 
	 * 카멜 타입의 String을 Underscore 타입으로 변환하여 리턴
	 * 
	 * @param key
	 * @return
	 */
	public static String convertCamelToUnderscore(String camel) {
		String regex = "(?<!^|_|[A-Z])([A-Z])";
		String replacement = "_$1";

		String underscore = camel.replaceAll(regex, replacement);

		return underscore;

//		StringBuffer result = new StringBuffer();
//	    boolean begin = true;
//	    boolean lastUppercase = false;
//	    
//	    for( int i=0; i < camel.length(); i++ ) {
//	        char ch = camel.charAt(i);
//	        if( Character.isUpperCase(ch) ) {
//	            // is start?
//	            if( begin ) {
//	                result.append(ch);
//	            } else {
//	                if( lastUppercase ) {
//	                    // test if end of acronym
//	                    if( i+1<camel.length() ) {
//	                        char next = camel.charAt(i+1);
//	                        if( Character.isUpperCase(next) ) {
//	                            // acronym continues
//	                            result.append(ch);
//	                        } else {
//	                            // end of acronym
//	                            result.append('_').append(ch);
//	                        }
//	                    } else {
//	                        // acronym continues
//	                        result.append(ch);
//	                    }
//	                } else {
//	                    // last was lowercase, insert _
//	                    result.append('_').append(ch);
//	                }
//	            }
//	            lastUppercase=true;
//	        } else {
//	            result.append(Character.toUpperCase(ch));
//	            lastUppercase=false;
//	        }
//	        begin=false;
//	    }
//	    return result.toString();
	}
}