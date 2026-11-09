package com.eep.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;
import org.mybatis.spring.annotation.MapperScan;

/** 연구소 - 연구팀, 연구원, 연구과제, 월간 연구일지, 결재자 서명 */
@MapperScan
public interface BoLabMapper {

	public int ensureSchema();

	public List<Map<String, Object>> selectStaffOptions();
	public List<Map<String, Object>> selectAdminAccounts();

	public List<Map<String, Object>> selectTeams(Map<String, Object> param);
	public int insertTeam(Map<String, Object> param);
	public int updateTeam(Map<String, Object> param);
	public int updateTeamApproval(Map<String, Object> param);

	public Map<String, Object> selectLatestSign(@Param("emplyId") String emplyId);
	public int insertSign(Map<String, Object> param);

	public List<Map<String, Object>> selectResearchers(Map<String, Object> param);
	public List<Map<String, Object>> selectMonthResearchers(@Param("teamSq") Object teamSq, @Param("ym") String ym);
	public int countResearcherOverlap(Map<String, Object> param);
	public int insertResearcher(Map<String, Object> param);
	public int updateResearcher(Map<String, Object> param);

	public List<Map<String, Object>> selectProjects();
	public Map<String, Object> selectProjectOne(Map<String, Object> param);
	public int insertProject(Map<String, Object> param);
	public int updateProject(Map<String, Object> param);

	public List<Map<String, Object>> selectJournals(Map<String, Object> param);
	public Map<String, Object> selectJournalOne(Map<String, Object> param);
	public List<Map<String, Object>> selectJournalHistory(Map<String, Object> param);
	public int insertJournal(Map<String, Object> param);
	public int updateJournalContent(Map<String, Object> param);
	public int updateJournalSubmit(Map<String, Object> param);
	public int updateJournalStatus(Map<String, Object> param);
	public int updateJournalUploaded(Map<String, Object> param);
	public int updateJournalUploadError(Map<String, Object> param);
	public int insertJournalHistory(Map<String, Object> param);
}
