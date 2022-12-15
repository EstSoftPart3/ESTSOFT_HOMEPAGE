package common.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.ByteBuffer;
import java.security.AlgorithmParameters;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.InvalidParameterSpecException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Random;
import java.util.UUID;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;
import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.json.simple.JSONObject;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.amazonaws.ClientConfiguration;
import com.amazonaws.Protocol;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.PutObjectRequest;


@SuppressWarnings("all")
public class CommonUtils {
	
	private static final Logger log = Logger.getLogger(CommonUtils.class);
	private static final int MAX_VARIABLE_LENGTH = 30;
	
	public static String getRandomString(){
		return UUID.randomUUID().toString().replaceAll("-", "");
	}
	
	public static void printMap(Map<String,Object> map){
		Iterator<Entry<String,Object>> iterator = map.entrySet().iterator();
		Entry<String,Object> entry = null;
		log.debug("--------------------printMap--------------------\n");
		
		while(iterator.hasNext()){
			entry = iterator.next();
			String key = entry.getKey();
			
			StringBuilder sb = new StringBuilder();
			if ( MAX_VARIABLE_LENGTH > key.length() ) {
				int index = key.length();
				while ( MAX_VARIABLE_LENGTH > index ) {
					sb.append(" ");
					index++;
				}
			}
			
			log.debug("key : " + key + sb.toString() + ",\tvalue : " + entry.getValue());
		}
		log.debug("");
		log.debug("------------------------------------------------\n");
	}
	
	public static void printList(List<Map<String,Object>> list){
		Iterator<Entry<String,Object>> iterator = null;
		Entry<String,Object> entry = null;
		log.debug("--------------------printList--------------------\n");
		int listSize = list.size();
		for(int i=0; i<listSize; i++){
			log.debug("list index : "+i);
			iterator = list.get(i).entrySet().iterator();
			while(iterator.hasNext()){
				entry = iterator.next();
				log.debug("key : "+entry.getKey()+",\tvalue : "+entry.getValue());
			}
			log.debug("\n");
		}
		log.debug("------------------------------------------------\n");
	}
	
	/**
	 * 
	 * 리스트의 내용을 문자열로 가져옴
	 * 
	 * @param list		문자열로 가져올 리스트
	 * @param prefix	출력 시 문자열 앞에 붙을 값
	 * @param clsNm		리스트의 Generic 클래스명
	 * @return
	 */
	@SuppressWarnings("rawtypes")
	public static String getListString(List list, String prefix, String clsNm){
		StringBuilder sb = new StringBuilder();
		
		sb.append(prefix).append("--------------------").append(clsNm).append("--------------------\n");
		
		for (int ii = 0; ii < list.size(); ii++) {
			sb.append(prefix).append("list index : " + ii).append("\n");
			sb.append(prefix).append("list values -------------------------------" + list.get(ii));
			sb.append(prefix).append("\n");
		}
		
		sb.append(prefix).append("------------------------------------------------\n");
		
		return sb.toString();
	}
	
	/**
	 * AES 256 사용법
	 * String key = "secret key"; // 키
	 * String encrypted = CommonUtils.encryptAES256("Hello, World!", key); //암호화하기
	 * String dncrypted = CommonUtils.decryptAES256(encrypted, key)); //복호화하기 
	 */
	
	/**
	 * AES 256 으로 암호화 한다.
	 * @param msg
	 * @param key
	 * @return
	 * @throws NoSuchAlgorithmException
	 * @throws InvalidKeySpecException
	 * @throws NoSuchPaddingException
	 * @throws InvalidKeyException
	 * @throws InvalidParameterSpecException
	 * @throws UnsupportedEncodingException
	 * @throws BadPaddingException
	 * @throws IllegalBlockSizeException
	 */
	public static String encryptAES256(String msg, String key) throws NoSuchAlgorithmException, InvalidKeySpecException, NoSuchPaddingException, InvalidKeyException, InvalidParameterSpecException, UnsupportedEncodingException, BadPaddingException, IllegalBlockSizeException {
		SecureRandom random = new SecureRandom();
		byte bytes[] = new byte[20];
		random.nextBytes(bytes);
		byte[] saltBytes = bytes;
		
		// Password-Based Key Derivation function 2
		SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
		// 70000번 해시하여 256 bit 길이의 키를 만든다.
		PBEKeySpec spec = new PBEKeySpec(key.toCharArray(), saltBytes, 70000, 128);
		
		SecretKey secretKey = factory.generateSecret(spec);
		SecretKeySpec secret = new SecretKeySpec(secretKey.getEncoded(), "AES");
		
		// 알고리즘/모드/패딩
		// CBC : Cipher Block Chaining Mode
		Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
		cipher.init(Cipher.ENCRYPT_MODE, secret);
		AlgorithmParameters params = cipher.getParameters();
		// Initial Vector(1단계 암호화 블록용)
		byte[] ivBytes = params.getParameterSpec(IvParameterSpec.class).getIV();
		
		byte[] encryptedTextBytes = cipher.doFinal(msg.getBytes("UTF-8"));
		
		byte[] buffer = new byte[saltBytes.length + ivBytes.length + encryptedTextBytes.length];
		System.arraycopy(saltBytes, 0, buffer, 0, saltBytes.length);
        System.arraycopy(ivBytes, 0, buffer, saltBytes.length, ivBytes.length);
	    System.arraycopy(encryptedTextBytes, 0, buffer, saltBytes.length + ivBytes.length, encryptedTextBytes.length);
	    
		return Base64.getEncoder().encodeToString(buffer);
	}
	
	/**
	 * 위에서 암호화된 내용을 복호화 한다.
	 * @param msg
	 * @param key
	 * @return
	 * @throws NoSuchPaddingException
	 * @throws NoSuchAlgorithmException
	 * @throws InvalidKeySpecException
	 * @throws InvalidAlgorithmParameterException
	 * @throws InvalidKeyException
	 * @throws BadPaddingException
	 * @throws IllegalBlockSizeException
	 */
	public static String decryptAES256(String msg, String key) throws NoSuchPaddingException, NoSuchAlgorithmException, InvalidKeySpecException, InvalidAlgorithmParameterException, InvalidKeyException, BadPaddingException, IllegalBlockSizeException {
		Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
		ByteBuffer buffer = ByteBuffer.wrap(Base64.getDecoder().decode(msg));
		
		byte[] saltBytes = new byte[20];
		buffer.get(saltBytes, 0, saltBytes.length);
		byte[] ivBytes = new byte[cipher.getBlockSize()];
		buffer.get(ivBytes, 0, ivBytes.length);
		byte[] encryoptedTextBytes = new byte[buffer.capacity() - saltBytes.length - ivBytes.length];
		buffer.get(encryoptedTextBytes);
		
		SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
		PBEKeySpec spec = new PBEKeySpec(key.toCharArray(), saltBytes, 70000, 128);
		
		SecretKey secretKey = factory.generateSecret(spec);
		SecretKeySpec secret = new SecretKeySpec(secretKey.getEncoded(), "AES");
		
		cipher.init(Cipher.DECRYPT_MODE, secret, new IvParameterSpec(ivBytes));
		
		byte[] decryptedTextBytes = cipher.doFinal(encryoptedTextBytes);
		return new String(decryptedTextBytes);
	}
	
	/**
     * Map을 json으로 변환한다.
     *
     * @param map Map<String, Object>.
     * @return JSONObject.
     */
    @SuppressWarnings("unchecked")
	public static JSONObject getJsonStringFromMap( Map<String, Object> map ) {
        JSONObject jsonObject = new JSONObject();
        for( Map.Entry<String, Object> entry : map.entrySet() ) {
            String key = entry.getKey();
            Object value = entry.getValue();
            jsonObject.put(key, value);
        }
        
        return jsonObject;
    }
    
    /**
     * Map을 json으로 변환한다.
     *
     * @param map Map<String, Object>.
     * @return JSONObject.
     */
    @SuppressWarnings("unchecked")
	public static JSONObject getJsonStringFromList( List<Map<String,Object>> listMap ) {
        JSONObject jsonObject = new JSONObject();
        
        for(int i=0; i<listMap.size(); i++) {
        	Map<String,Object> map = listMap.get(i);
        	for( Map.Entry<String, Object> entry : map.entrySet() ) {
                String key = entry.getKey();
                Object value = entry.getValue();
                jsonObject.put(key, value);
            }
        }
        
        return jsonObject;
    }
    
    /**
     * S3 업로드 API
     *
     * @param map Map<String, Object>.
     * @return StringBuffer.
     */
    private static String bucketNm = "eduhash-upload"; // 버킷명
	private static String accessKey = "AKIAI3ZWXVNITEP44JFQ"; // 엑세스 키
	private static String secretKey = "RhHPpp5khRv+mzhbn/fqMJKtKUXdz/hyjo+lPgk1"; // 보안 엑세스 키
	private static AmazonS3 conn;
    
	public static List<Map<String,Object>> parseInsertFileInfo(Map<String,Object> map, HttpServletRequest request) throws Exception{
		
		MultipartHttpServletRequest multipartHttpServletRequest = (MultipartHttpServletRequest)request;
    	Iterator<String> iterator = multipartHttpServletRequest.getFileNames();
    	
    	MultipartFile multipartFile = null;
    	File file = null;
    	String fileName = null;
    	String fileExt = null;
    	
    	AWSCredentials credentials = new BasicAWSCredentials(accessKey, secretKey);
		ClientConfiguration clientConfig = new ClientConfiguration();
		clientConfig.setProtocol(Protocol.HTTP);
		conn = new AmazonS3Client(credentials, clientConfig);
		conn.setEndpoint("s3.ap-northeast-2.amazonaws.com"); // 엔드포인트 설정 [ 아시아 태평양 서울 ]
    	
    	List<Map<String,Object>> list = new ArrayList<Map<String,Object>>();
        Map<String, Object> listMap = null; 
        
        while(iterator.hasNext()){
        	
        	long time = System.currentTimeMillis(); 
        	SimpleDateFormat dayTime = new SimpleDateFormat("yyyyMMddHHmmssSSS"); 
        	String strDT = dayTime.format(new Date(time)); 
        	
        	multipartFile = multipartHttpServletRequest.getFile(iterator.next());
        	file = new File(multipartFile.getOriginalFilename());
        	
        	log.debug("################### file = " + multipartFile.getOriginalFilename());
        	
        	file.getParentFile().mkdirs(); // correct!
        	file.mkdirs(); // correct!
        	if (!file.exists()) {
        	    file.createNewFile();
        	} 
        	multipartFile.transferTo(file);
        	
        	if(!multipartFile.isEmpty()){
        		fileName = multipartFile.getOriginalFilename();
        		fileExt = fileName.substring(fileName.lastIndexOf("."));
        		
        		log.debug("FILE_NM : " + multipartFile.getName());
        		log.debug("LGCL_FILE_NM : " + fileName);
        		log.debug("PHSC_FILE_NM : " + strDT + fileExt);
        		
        		listMap = new HashMap<String,Object>();
        		listMap.put("FILE_NM", multipartFile.getName());
        		listMap.put("LGCL_FILE_NM", fileName);
        		listMap.put("PHSC_FILE_NM", strDT + fileExt);
        		list.add(listMap);
        		
        		// 파일 업로드를 위한 request 객체를 생성 하였다.
                PutObjectRequest putObjectRequest =
        	        // request 객체 안에 BUCKET_NAME + "생성 될 폴더 이름", 파일 원본이름, File 바이너리 데이터 를 설정하였다.
        	        new PutObjectRequest(bucketNm+"/upload", strDT + fileExt, file);

                // Access List 를 설정 하는 부분이다. 공개 조회가 가능 하도록 public Read 로 설정 하였다.
                putObjectRequest.setCannedAcl(CannedAccessControlList.PublicRead);

                // 실제로 업로드 할 액션이다.
                conn.putObject(putObjectRequest);
        	}
        }
		return list;
	}
	
	/**
     * 네이버 검색엔진 API
     *
     * @param map Map<String, Object>.
     * @return StringBuffer.
     */
    public static StringBuffer searchNaverAPI( Map<String, Object> map )
    {
    	
    	String clientId = "O3mK4V2EdqfjCogJKCgs";//애플리케이션 클라이언트 아이디값";
        String clientSecret = "4ab3MvPwnK";//애플리케이션 클라이언트 시크릿값";
        StringBuffer response = new StringBuffer();
        
        try {
            String text = URLEncoder.encode(map.get("searchKeywrd").toString(), "UTF-8");
            String apiURL = "https://openapi.naver.com/v1/search/local?query="+ text; // json 결과
            //String apiURL = "https://openapi.naver.com/v1/search/local.xml?query="+ text; // xml 결과
            URL url = new URL(apiURL);
            HttpURLConnection con = (HttpURLConnection)url.openConnection();
            con.setRequestMethod("GET");
            con.setRequestProperty("X-Naver-Client-Id", clientId);
            con.setRequestProperty("X-Naver-Client-Secret", clientSecret);
            int responseCode = con.getResponseCode();
            BufferedReader br;
            if(responseCode==200) { // 정상 호출
                br = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));
            } else {  // 에러 발생
                br = new BufferedReader(new InputStreamReader(con.getErrorStream(), "UTF-8"));
            }
            String inputLine;
            while ((inputLine = br.readLine()) != null) {
                response.append(inputLine);
            }
            br.close();
            System.out.println(response.toString());
        } catch (Exception e) {
            System.out.println(e);
        }
        
        return response;
    }
    
    /**
     * 이메일 인증 번호 랜덤 생성
     *
     * @param map Map<String, Object>.
     * @return StringBuffer.
     */
    public static String getTempKey()
    {
    	int size = 8;	
    	
    	Random ran = new Random();
        StringBuffer sb = new StringBuffer();
        
        int num = 0;
        
        do {
            num = ran.nextInt(75) + 48;
            
            if((num >= 48 && num <= 57) || (num >= 65 && num <= 90) || (num >= 97 && num <= 122)) {
                sb.append((char)num);
            }else {
                continue;
            }
        } while (sb.length() < size);
        
        return sb.toString();

    }

    /**
     * S3 업로드 API NoMap
     * 네이버스마트에디터2 업로드
     *
     * @param HttpServletRequest
     * @return StringBuffer
     */
    public static List<Map<String,Object>> parseInsertFileInfoNoMap(HttpServletRequest request) throws Exception{
		
		MultipartHttpServletRequest multipartHttpServletRequest = (MultipartHttpServletRequest)request;
    	Iterator<String> iterator = multipartHttpServletRequest.getFileNames();
    	
    	MultipartFile multipartFile = null;
    	File file = null;
    	String fileName = null;
    	String fileExt = null;
    	
    	AWSCredentials credentials = new BasicAWSCredentials(accessKey, secretKey);
		ClientConfiguration clientConfig = new ClientConfiguration();
		clientConfig.setProtocol(Protocol.HTTP);
		conn = new AmazonS3Client(credentials, clientConfig);
		conn.setEndpoint("s3.ap-northeast-2.amazonaws.com"); // 엔드포인트 설정 [ 아시아 태평양 서울 ]
    	
    	List<Map<String,Object>> list = new ArrayList<Map<String,Object>>();
        Map<String, Object> listMap = null; 
        
        while(iterator.hasNext()){
        	
        	long time = System.currentTimeMillis(); 
        	SimpleDateFormat dayTime = new SimpleDateFormat("yyyyMMddHHmmssSSS"); 
        	String strDT = dayTime.format(new Date(time)); 
        	
        	multipartFile = multipartHttpServletRequest.getFile(iterator.next());
        	file = new File(multipartFile.getOriginalFilename());
        	
        	log.debug("################### file = " + multipartFile.getOriginalFilename());
        	
        	//file.getParentFile().mkdirs(); // correct!
        	file.mkdirs(); // correct!
        	if (!file.exists()) {
        	    file.createNewFile();
        	} 
        	multipartFile.transferTo(file);
        	
        	if(!multipartFile.isEmpty()){
        		fileName = multipartFile.getOriginalFilename();
        		fileExt = fileName.substring(fileName.lastIndexOf("."));
        		
        		log.debug("FILE_NM : " + multipartFile.getName());
        		log.debug("LGCL_FILE_NM : " + fileName);
        		log.debug("PHSC_FILE_NM : " + strDT + fileExt);
        		
        		listMap = new HashMap<String,Object>();
        		listMap.put("FILE_NM", multipartFile.getName());
        		listMap.put("LGCL_FILE_NM", fileName);
        		listMap.put("PHSC_FILE_NM", strDT + fileExt);
        		list.add(listMap);
        		
        		// 파일 업로드를 위한 request 객체를 생성 하였다.
                PutObjectRequest putObjectRequest =
        	        // request 객체 안에 BUCKET_NAME + "생성 될 폴더 이름", 파일 원본이름, File 바이너리 데이터 를 설정하였다.
        	        new PutObjectRequest(bucketNm+"/upload/editor", strDT + fileExt, file);

                // Access List 를 설정 하는 부분이다. 공개 조회가 가능 하도록 public Read 로 설정 하였다.
                putObjectRequest.setCannedAcl(CannedAccessControlList.PublicRead);

                // 실제로 업로드 할 액션이다.
                conn.putObject(putObjectRequest);
        	}
        }
		return list;
	}
}
