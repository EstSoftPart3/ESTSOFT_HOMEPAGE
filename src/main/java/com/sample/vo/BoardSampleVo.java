package com.sample.vo;

import java.sql.Timestamp;
import java.util.List;

import common.base.vo.BaseVo;

public class BoardSampleVo extends BaseVo{
	
	/*
	 * 샘플게시판 VO
	 */
	
    private int bno;    	     //게시글번호
    private String title;        //제목
    private String content;      //내용
    private String writer;       //작성자
    private Timestamp regdate;   //작성일자
    private int viewcnt;         //조회수

    /*
     * 검색어 VO
     */
    
    private String keyword;       //검색어
    private String keywordOption; //검색어 옵션

    /*
     * 기본생성자
     */
    
	public BoardSampleVo() {}

	/*
	 * getter, setter, field, toString
	 */
	
	
	public int getBno() {
		return bno;
	}

	public void setBno(int bno) {
		this.bno = bno;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public String getWriter() {
		return writer;
	}

	public void setWriter(String writer) {
		this.writer = writer;
	}

	public Timestamp getRegdate() {
		return regdate;
	}

	public void setRegdate(Timestamp regdate) {
		this.regdate = regdate;
	}

	public int getViewcnt() {
		return viewcnt;
	}

	public void setViewcnt(int viewcnt) {
		this.viewcnt = viewcnt;
	}

	public String getKeyword() {
		return keyword;
	}

	public void setKeyword(String keyword) {
		this.keyword = keyword;
	}

	public String getKeywordOption() {
		return keywordOption;
	}

	public void setKeywordOption(String keywordOption) {
		this.keywordOption = keywordOption;
	}
		
}


