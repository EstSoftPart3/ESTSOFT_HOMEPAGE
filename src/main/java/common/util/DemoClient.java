package common.util;
/*package est.common.comm;

import java.io.BufferedInputStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.Properties;

import vavs.util.Base64;
import vavs.util.SymmetricCipher;

*//**
 * 작성자 : 윤두영 작성일 : 20150623 HISTORY : RTClient 와 RTServer 통합본 국민은행 이체확인 전문 전송 응답
 * 시 개별부 오류코드 없을 경우 timeout 로직과 동일하게 처리
 * 
 * 
 *//*

public class DemoClient {

	private String enc = "";
	private String key = "hash326-81-01064";
	private Properties prop = null;
	private InputStream input = null;
	private OutputStream output = null;
	private InputStreamReader isr = null;
	private BufferedInputStream br = null;

	private String SENDDATA = "";
	private String RECVDATA = "";

	public DemoClient() {

		InitConfig();
		RECVDATA = "";
	}

	private void InitConfig() {

		try {

			String config_dir_Path = System.getProperty("user.dir") + File.separator + "conf" + File.separator;
			String config_File_Path = config_dir_Path + "corpInfoFile.properties";

			File confFile = new File(config_File_Path);

			if (!confFile.exists()) {

				System.out.println("config 파일 없습니다. 프로그램을 종료합니다!!!");
				System.out.println("config 파일 위치 : " + config_File_Path);
				System.exit(0);
			} else {

				System.out.println("configFile READ");
				FileInputStream input = new FileInputStream(confFile);
				prop = new Properties();
				prop.load(input);
				System.out.println(prop);
			}

			enc = prop.getProperty("enc");
			key = prop.getProperty("key");

		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	*//**
	 * 사용법 String senddata 송신할 데이터 String recvdata 수신할 데이터
	 * 
	 * 함수명 sendrecv(String data) : 세틀뱅크로 송신 (IP 및 PORT는 config에서 세팅함) return 값 :
	 * 세틀에서 수신한 데이터
	 * 
	 * DemoClient dm = new DemoClient(); recvdata = dm.sendrecv(senddata);
	 * 
	 * 
	 *//*

	public static void main(String args[]) {

		String senddata = "";
		
		// 개시 1000 100
//		senddata = "SETTLEBNK41000313 0231000100100000120181218170607                   12345678910012345678912345678                                                                                                                                                                                                        ";
		senddata = "         4100****    01110001001      201812210730031234                                                                                                                                                                                                                                                    ";
		
		// 자금이체 2000/100
//		senddata = "SETTLEBNK41000313 0232000100195001120181218170607                   12345678910012345678912345678                                                                                                                                                                                                        ";
		
		String recvdata = "";

		System.out.println("송신데이터 : " + senddata);
		DemoClient dm = new DemoClient();
		recvdata = dm.sendrecv(senddata);
		System.out.println("수신데이터 : " + recvdata);

	}

	private String sendrecv(String data) {

		boolean result = false;

		Socket socket;
		String server_ip = prop.getProperty("server_ip");
		int server_port = Integer.parseInt(prop.getProperty("server_port"));

		try {
			socket = new Socket(server_ip, server_port);

			if (socket != null) {
				input = socket.getInputStream();
				output = socket.getOutputStream();
				isr = new InputStreamReader(input);
				br = new BufferedInputStream(input);

				result = send(data);
			}

			if (result != true) {

			} else {

				receive();

				if (RECVDATA == null || "".equals(RECVDATA)) {
					System.out.println("수신오류");
				}

			}

			socket.close();
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return RECVDATA;
	}

	public boolean send(String sendData) {

		String enData = "";
		try {
			// logger.info("변환전송신[" + sendData.getBytes().length + "][" + sendData + "]");
			 System.out.println("변환전송신[" + sendData.getBytes().length + "][" + sendData + "]");

			BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(output));

			if (enc.equals("1")) {
				byte enDataByte[] = base64Encoding(seedEncrypt(sendData, key));
				enData = new String(enDataByte);
			} else {
				enData = sendData;
			}

			int len = enData.getBytes().length;
			String mlen = Integer.toString(len);

			for (int i = 0; i < (4 - mlen.length()); i++) {
				mlen = "0" + mlen;
			}
			String sendEncData = mlen + enData;
			
			System.out.println("변환후송신[" + sendEncData.getBytes().length + "][" + sendEncData + "]");

			bw.write(sendEncData);
			bw.flush();

		} catch (IOException ioe) {
			System.out.println("송신 오류: " + ioe.getMessage());
			ioe.printStackTrace();
			return false;
		}
		return true;
	}

	public int receive() {

		int bytesRead = 0;
		String str = null;
		byte[] bRecvLen = new byte[4];

		int mlen = 0;

		try {
			bytesRead = Read(br, bRecvLen, 4);
			str = new String(bRecvLen);
			mlen = Integer.parseInt(str.substring(0, 4)); // 전문길이

			byte[] bRecv = new byte[mlen];

			
			 * if (enc.equals("0")) mlen -= LEN_SIZE;
			 

			if ((bytesRead = Read(br, bRecv, mlen)) < 0) {
				System.out.println("Read = '" + bytesRead + "'");
				return bytesRead;
			}
			// str = String.valueOf(bRecv);
			str = new String(bRecv);

			byte buffer[] = str.getBytes();

			if (enc.equals("1")) { // 암호화
				byte deDataByte[] = seedDecrypt(base64Decoding(buffer), key); // Decoding..
				RECVDATA = new String(deDataByte);
			} else { // 비암호화
				RECVDATA = str;
			}
		} catch (NumberFormatException ex) {
			System.out.println(ex);
			RECVDATA = null;
		}

		return bytesRead;
	}

	public int Read(BufferedInputStream br, byte[] bRecv, int len) {

		int iLen = 0;
		int iLeft = len;

		if (br == null)
			return -1;

		try {

			while (iLeft > 0) {
				iLen = br.read(bRecv, len - iLeft, iLeft);

				if (iLen >= 0) {
					iLeft -= iLen;
				} else
					return -1;
			}
		} catch (IOException ioe) {
			System.out.println("receive error = " + ioe.getMessage());
		}

		return (len - iLeft);
	}

	public byte[] seedDecrypt(byte[] data, String key) {
		return SymmetricCipher.SEED_CBC_DECRYPT(data, key.getBytes());
	}

	*//**
	 * SEED 암호화
	 * 
	 * @param data 암호화 처리용 데이터
	 * @param key  키값
	 * @return seed encrypt 처리된 데이터
	 *//*
	public byte[] seedEncrypt(String data, String key) {
		return SymmetricCipher.SEED_CBC_ENCRYPT(data.getBytes(), key.getBytes());
	}

	*//**
	 * Base64 Decoding
	 * 
	 * @param enData 인코딩 데이터
	 * @return 디코딩 데이터
	 *//*
	public byte[] base64Decoding(byte[] enData) {
		return Base64.base64Decode(enData);
	}

	*//**
	 * Base64 Encoding
	 * 
	 * @param deData 입력 데이터
	 * @return 인코딩 데이터
	 *//*
	public byte[] base64Encoding(byte[] deData) {
		return Base64.base64Encode(deData);
	}

	public String getSENDDATA() {
		return SENDDATA;
	}

	public void setSENDDATA(String sENDDATA) {
		SENDDATA = sENDDATA;
	}

	public String getRECVDATA() {
		return RECVDATA;
	}

	public void setRECVDATA(String rECVDATA) {
		RECVDATA = rECVDATA;
	}

}*/