package com.eep.bo.board.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.eep.bo.board.dao.BoBoardDao;

@Service
public class BoBoardServiceImpl implements BoBoardService {

	@Autowired
	private BoBoardDao BoBoardDao;
 
    /** 게시판 - 목록 조회 *//*
    @Override
    public List<BoBoardVo> getBoardList(BoBoardVo BoBoardVo) throws Exception {

    	List<BoBoardVo> list = new ArrayList<BoBoardVo>();
    	
        list = boardDao.getBoardList(BoBoardVo);

 
        return list;
    }
 */
	
	//게시판 목록
	@Override
	public Map<String, Object> boardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardDao.boardListData(param);
		
		return result;
	}
	
	
	/**
	 * 공지사항 ServiceImpl
	 * 
	 * **/
	
	//공지사항 리스트
	@Override
	public Map<String, Object> noticeBoardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardDao.noticeBoardListData(param);
		
		return result;
	}
	
	//공지시항 등록
	@Override
	public void noticeBoardInsertData(Map<String, Object> param){
		BoBoardDao.noticeBoardInsertData(param);
	}
	
	//공지시항 상세
	@Override
	public Map<String, Object> noticeBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardDao.noticeBoardDetailData(param);
		
		return result;
	}
	
	//공지사항 삭제
	@Override
	public void noticeBoardDeleteData(Map<String, Object> param){
		BoBoardDao.noticeBoardDeleteData(param);
	}
	
	//공지사항 수정
	@Override
	public void noticeBoardUpdateData(Map<String, Object> param){
		BoBoardDao.noticeBoardUpdateData(param);
	}
	
	/**
	 * 교육 ServiceImpl
	 * 
	 * **/
	
	//교육 리스트
	@Override
	public Map<String, Object> educationBoardListData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardDao.educationBoardListData(param);
		
		return result;
	}
	
	//교육 등록
	@Override
	public void educationBoardInsertData(Map<String, Object> param){
		BoBoardDao.educationBoardInsertData(param);
	}
	
	//교육 상세
	@Override
	public Map<String, Object> educationBoardDetailData(Map<String, Object> param){
		
		Map<String, Object> result = new HashMap<>();
		
		result = BoBoardDao.educationBoardDetailData(param);
		
		return result;
	}
	
	//교육 삭제
	@Override
	public void educationBoardDeleteData(Map<String, Object> param){
		BoBoardDao.educationBoardDeleteData(param);
	}
	
	//교육 수정
	@Override
	public void educationBoardUpdateData(Map<String, Object> param){
		BoBoardDao.educationBoardUpdateData(param);
	}
	
    /* 게시판 - 상세 조회 */
    /*@Override
    public BoBoardVo getBoardDetail(BoBoardVo BoBoardVo) throws Exception {

    	BoBoardVo = boardDao.getBoardDetail(BoBoardVo);

        return BoBoardVo;
    }*/
 
  /*  *//** 게시판 - 등록 *//*
    public BoardDto insertBoard(BoardForm boardForm) throws Exception {
 
        BoardDto boardDto = new BoardDto();
 
        int insertCnt = 0;
 
        int boardReRef = boardDao.getBoardReRef(boardForm);
        boardForm.setBoard_re_ref(boardReRef);
 
        insertCnt = boardDao.insertBoard(boardForm);
 
        List<BoardFileForm> boardFileList = getBoardFileInfo(boardForm); 
        for (BoardFileForm boardFileForm : boardFileList) {
            boardDao.insertBoardFile(boardFileForm);
        }
 
        if (insertCnt > 0) {
            boardDto.setResult("SUCCESS");
        } else {
            boardDto.setResult("FAIL");
        }
 
        return boardDto;
    }
 
   
 
    *//** 게시판 - 삭제 *//*
    public BoardDto deleteBoard(BoardForm boardForm) throws Exception {
 
        BoardDto boardDto = new BoardDto();
 
        int deleteCnt = boardDao.deleteBoard(boardForm);
 
        if (deleteCnt > 0) {
            boardDto.setResult("SUCCESS");
        } else {
            boardDto.setResult("FAIL");
        }
 
        return boardDto;
    }
 
    *//** 게시판 - 수정 *//*
    public BoardDto updateBoard(BoardForm boardForm) throws Exception {
 
        BoardDto boardDto = new BoardDto();
 
        int updateCnt = boardDao.updateBoard(boardForm);

		String deleteFile = boardForm.getDelete_file();
		if (!"".equals(deleteFile)) {

			String[] deleteFileInfo = deleteFile.split("!");

			int boardSeq = Integer.parseInt(deleteFileInfo[0]);
			int fileNo = Integer.parseInt(deleteFileInfo[1]);

			BoardFileForm deleteBoardFileForm = new BoardFileForm();
			deleteBoardFileForm.setBoard_seq(boardSeq);
			deleteBoardFileForm.setFile_no(fileNo);

			boardDao.deleteBoardFile(deleteBoardFileForm);
		}

		List<BoardFileForm> boardFileList = getBoardFileInfo(boardForm);
		for (BoardFileForm boardFileForm : boardFileList) {
			boardDao.insertBoardFile(boardFileForm);
		}
 
        if (updateCnt > 0) {
            boardDto.setResult("SUCCESS");
        } else {
            boardDto.setResult("FAIL");
        }
 
        return boardDto;
    }
 
    *//** 게시판 - 답글 등록 *//*
    public BoardDto insertBoardReply(BoardForm boardForm) throws Exception {
 
        BoardDto boardDto = new BoardDto();
 
        BoardDto boardReplayInfo = boardDao.getBoardReplyInfo(boardForm);
 
        boardForm.setBoard_seq(boardReplayInfo.getBoard_seq());
        boardForm.setBoard_re_lev(boardReplayInfo.getBoard_re_lev());
        boardForm.setBoard_re_ref(boardReplayInfo.getBoard_re_ref());
        boardForm.setBoard_re_seq(boardReplayInfo.getBoard_re_seq());
 
        int insertCnt = 0;
 
        insertCnt += boardDao.updateBoardReSeq(boardForm);
 
        insertCnt += boardDao.insertBoardReply(boardForm);
 
        if (insertCnt > 0) {
            boardDto.setResult("SUCCESS");
        } else {
            boardDto.setResult("FAIL");
        }
 
        return boardDto;
    }*/
 
	
}
