package common.base.vo;

import java.util.Date;
	
/**
 * 공통_프로그램_마스터 Base Value Object
 * 
 * @author seunghyun kim
 * @since 2019.05.13
 *
 */
public class ProgrmMOutVo extends BaseVo{
	Long progrmSq;				// 프로그램_순번
	String usrAuthTcd;			// 사용자_권한_유형코드
	String progrmTcd;			// 프로그램_유형코드
	String svrProgrmId;			// 서버_프로그램_ID
	String clntProgrmId;		// 클라이언트_프로그램_ID
	String scrId;				// 화면_ID
	String scrNm;				// 화면_명
	String scrFilePath;			// 화면_파일_경로
	String progrmNm;			// 공통_프로그램_영문_명
	String progrmEngNm;			// 공통_프로그램_영문_명
	String progrmUri;			// 공통_프로그램_식별자
	String progrmDescrptn;		// 공통_프로그램_설명
	String useYn;				// 사용_여부
	String delYn;				// 삭제_여부
	Date createDt;				// 생성_일시
	Long createUsrSq;			// 생성_사용자_순번
	Date updtDt;				// 수정_일시
	Long updtUsrSq;				// 수정_사용자_순번
	
	
	/**
	 * 프로그램_순번 getter
	 */
 	public Long getProgrmSq(){
 		return this.progrmSq;
 	}

	/**
	 * 프로그램_순번 setter
	 */
 	public void setProgrmSq(Long progrmSq){
 		this.progrmSq = progrmSq;
 	}
	
	/**
	 * 사용자_권한_유형코드 getter
	 */
 	public String getUsrAuthTcd(){
 		return this.usrAuthTcd;
 	}

	/**
	 * 사용자_권한_유형코드 setter
	 */
 	public void setUsrAuthTcd(String usrAuthTcd){
 		this.usrAuthTcd = usrAuthTcd;
 	}
	
	/**
	 * 프로그램_유형코드 getter
	 */
 	public String getProgrmTcd(){
 		return this.progrmTcd;
 	}

	/**
	 * 프로그램_유형코드 setter
	 */
 	public void setProgrmTcd(String progrmTcd){
 		this.progrmTcd = progrmTcd;
 	}
	
	/**
	 * 서버_프로그램_ID getter
	 */
 	public String getSvrProgrmId(){
 		return this.svrProgrmId;
 	}

	/**
	 * 서버_프로그램_ID setter
	 */
 	public void setSvrProgrmId(String svrProgrmId){
 		this.svrProgrmId = svrProgrmId;
 	}
	
	/**
	 * 클라이언트_프로그램_ID getter
	 */
 	public String getClntProgrmId(){
 		return this.clntProgrmId;
 	}

	/**
	 * 클라이언트_프로그램_ID setter
	 */
 	public void setClntProgrmId(String clntProgrmId){
 		this.clntProgrmId = clntProgrmId;
 	}
	
	/**
	 * 화면_ID getter
	 */
 	public String getScrId(){
 		return this.scrId;
 	}

	/**
	 * 화면_ID setter
	 */
 	public void setScrId(String scrId){
 		this.scrId = scrId;
 	}
	
	/**
	 * 화면_명 getter
	 */
 	public String getScrNm(){
 		return this.scrNm;
 	}

	/**
	 * 화면_명 setter
	 */
 	public void setScrNm(String scrNm){
 		this.scrNm = scrNm;
 	}
	
	/**
	 * 화면_파일_경로 getter
	 */
 	public String getScrFilePath(){
 		return this.scrFilePath;
 	}

	/**
	 * 화면_파일_경로 setter
	 */
 	public void setScrFilePath(String scrFilePath){
 		this.scrFilePath = scrFilePath;
 	}
	
	/**
	 * 공통_프로그램_영문_명 getter
	 */
 	public String getProgrmNm(){
 		return this.progrmNm;
 	}

	/**
	 * 공통_프로그램_영문_명 setter
	 */
 	public void setProgrmNm(String progrmNm){
 		this.progrmNm = progrmNm;
 	}
	
	/**
	 * 공통_프로그램_영문_명 getter
	 */
 	public String getProgrmEngNm(){
 		return this.progrmEngNm;
 	}

	/**
	 * 공통_프로그램_영문_명 setter
	 */
 	public void setProgrmEngNm(String progrmEngNm){
 		this.progrmEngNm = progrmEngNm;
 	}
	
	/**
	 * 공통_프로그램_식별자 getter
	 */
 	public String getProgrmUri(){
 		return this.progrmUri;
 	}

	/**
	 * 공통_프로그램_식별자 setter
	 */
 	public void setProgrmUri(String progrmUri){
 		this.progrmUri = progrmUri;
 	}
	
	/**
	 * 공통_프로그램_설명 getter
	 */
 	public String getProgrmDescrptn(){
 		return this.progrmDescrptn;
 	}

	/**
	 * 공통_프로그램_설명 setter
	 */
 	public void setProgrmDescrptn(String progrmDescrptn){
 		this.progrmDescrptn = progrmDescrptn;
 	}
	
	/**
	 * 사용_여부 getter
	 */
 	public String getUseYn(){
 		return this.useYn;
 	}

	/**
	 * 사용_여부 setter
	 */
 	public void setUseYn(String useYn){
 		this.useYn = useYn;
 	}
	
	/**
	 * 삭제_여부 getter
	 */
 	public String getDelYn(){
 		return this.delYn;
 	}

	/**
	 * 삭제_여부 setter
	 */
 	public void setDelYn(String delYn){
 		this.delYn = delYn;
 	}
	
	/**
	 * 생성_일시 getter
	 */
 	public Date getCreateDt(){
 		return this.createDt;
 	}

	/**
	 * 생성_일시 setter
	 */
 	public void setCreateDt(Date createDt){
 		this.createDt = createDt;
 	}
	
	/**
	 * 생성_사용자_순번 getter
	 */
 	public Long getCreateUsrSq(){
 		return this.createUsrSq;
 	}

	/**
	 * 생성_사용자_순번 setter
	 */
 	public void setCreateUsrSq(Long createUsrSq){
 		this.createUsrSq = createUsrSq;
 	}
	
	/**
	 * 수정_일시 getter
	 */
 	public Date getUpdtDt(){
 		return this.updtDt;
 	}

	/**
	 * 수정_일시 setter
	 */
 	public void setUpdtDt(Date updtDt){
 		this.updtDt = updtDt;
 	}
	
	/**
	 * 수정_사용자_순번 getter
	 */
 	public Long getUpdtUsrSq(){
 		return this.updtUsrSq;
 	}

	/**
	 * 수정_사용자_순번 setter
	 */
 	public void setUpdtUsrSq(Long updtUsrSq){
 		this.updtUsrSq = updtUsrSq;
 	}
 	
 	@Override
	public String toString() {
		String variableString = "\n-------------------- ProgrmMOutVo --------------------\n";
		variableString += "progrmSq = " + progrmSq + "			[프로그램_순번]\n";
		variableString += "usrAuthTcd = " + usrAuthTcd + "			[사용자_권한_유형코드]\n";
		variableString += "progrmTcd = " + progrmTcd + "			[프로그램_유형코드]\n";
		variableString += "svrProgrmId = " + svrProgrmId + "			[서버_프로그램_ID]\n";
		variableString += "clntProgrmId = " + clntProgrmId + "			[클라이언트_프로그램_ID]\n";
		variableString += "scrId = " + scrId + "			[화면_ID]\n";
		variableString += "scrNm = " + scrNm + "			[화면_명]\n";
		variableString += "scrFilePath = " + scrFilePath + "			[화면_파일_경로]\n";
		variableString += "progrmNm = " + progrmNm + "			[공통_프로그램_영문_명]\n";
		variableString += "progrmEngNm = " + progrmEngNm + "			[공통_프로그램_영문_명]\n";
		variableString += "progrmUri = " + progrmUri + "			[공통_프로그램_식별자]\n";
		variableString += "progrmDescrptn = " + progrmDescrptn + "			[공통_프로그램_설명]\n";
		variableString += "useYn = " + useYn + "			[사용_여부]\n";
		variableString += "delYn = " + delYn + "			[삭제_여부]\n";
		variableString += "createDt = " + createDt + "			[생성_일시]\n";
		variableString += "createUsrSq = " + createUsrSq + "			[생성_사용자_순번]\n";
		variableString += "updtDt = " + updtDt + "			[수정_일시]\n";
		variableString += "updtUsrSq = " + updtUsrSq + "			[수정_사용자_순번]\n";
		variableString += "------------------------------------------------\n";
		
		return variableString;
	}
 	
 	
}