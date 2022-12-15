package common.base.service;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import common.base.dao.CommonDao;

@Service("commonService")
public class CommonServiceImpl implements CommonService {

	Logger log = Logger.getLogger(this.getClass());

	@Resource(name = "commonDao")
	private CommonDao commonDao;

	/**
	 * 
	 * 공통 페이지 오픈
	 * 
	 * @param request	레퀘스트 객체
	 * @param viewNm	JSP view file명.(.jsp 제외). 우선순위 가장 높음.
	 * @param scrid		스크린 아이디. 프로그램 아이디보다 우선순위 높음
	 * @param progrmId	프로그램 아이디. 우선순위 가장 낮음.
	 * @return
	 */
//	@Override
//	@SuppressWarnings("unchecked")
//	public Map<String,Object> getViewPageName(HttpServletRequest request, HttpServletResponse response, String viewNm, String scrId, String progrmId) {
//		
//		String viewFileName = null;
//		String errCd = null;
//		String errMsg = null;
//		boolean isLogin = false; //테스트 완료 후 "false"로 변경
//		
//		HttpSession session = request.getSession();
//		
//		Map<String,Object> rsltMap = new HashMap<String,Object>();
//		
//		if(session.getAttribute(SldConst.IS_LOGIN) != null) {
//			isLogin = (boolean) session.getAttribute(SldConst.IS_LOGIN);
//		}
//		
//		if(isLogin) {
//			
//			if ( viewNm != null && viewNm.length() > 0 ) {
//				// JSP view file명.(.jsp 제외). 우선순위 가장 높음.
//				viewFileName = viewNm;
//				
//				
//				// TODO : 프로그램에서 화면파일명만이 아닌 전체 경로가 기재되면 필요없음.
////				List<String> pageList = (List<String>) session.getAttribute(SldConst.VIEW_NM_LIST);
////				for ( int ii = 0 ; ii < pageList.size() ; ii ++ ) {
////					String pageNm = pageList.get(ii);
////					if ( pageNm.contains(viewNm)) {
////						viewFileName = pageNm;
////						break;
////					}
////				}
//				
//			} else {
//				
//				// TODO : SldConst.USR_AUTH_TCD 세션값으로 SldConst.SCR_ID_MAP, SldConst.PROGRAM_ID_MAP 세팅 필요
////				try {
////					ProgrmMOutVo progrmVo = null;
////					
////					if ( scrId != null && scrId.length() > 0 ) {
////						// 스크린 ID로 JSP 파일 조회
////						Map<String, ProgrmMOutVo> scrMap  = (Map<String, ProgrmMOutVo>)session.getAttribute(SldConst.SCR_ID_MAP);
////						progrmVo = scrMap.get(scrId);
////						viewFileName = progrmVo.getScrFilePath();
////					} else if ( progrmId != null && progrmId.length() > 0 ) {
////						// 프로그램 ID로 JSP 파일 조회
////						Map<String, ProgrmMOutVo> progrmMap  = (Map<String, ProgrmMOutVo>)session.getAttribute(SldConst.PROGRAM_ID_MAP);
////						progrmVo = progrmMap.get(progrmId);
////						viewFileName = progrmVo.getScrFilePath();
////					} else {
////						errCd = SldConst.SYS_ERROR_TCD04; 
////						errMsg = SldConst.SYS_ERROR_MSG04;
////					}
////					
////				} catch ( Exception e ) {
////					log.error("viewFileName:" + viewFileName);
////				} finally {
//					log.debug("viewFileName:" + viewFileName);
//					log.debug("scrId:" + scrId);
//					log.debug("progrmId:" + progrmId);
////				}
//				
//			}
//			
//		}else {
//			if ( viewNm != null && viewNm.length() > 0 ) {
//				// JSP view file명.(.jsp 제외). 우선순위 가장 높음.
//				viewFileName = viewNm;
//			}else {
//				errCd = SldConst.SYS_ERROR_TCD04; 
//				errMsg = SldConst.SYS_ERROR_MSG04;
//			}
//		}
//		
//		log.debug("Open Page Information ============================");
//		log.debug("isLogin  : " + isLogin);
//		log.debug("viewNm   : " + viewNm);
//		log.debug("scrId    : " + scrId);
//		log.debug("progrmId : " + progrmId);
//		log.debug("Final viewFileName : " + viewFileName);
//		log.debug("==================================================");
//		
//		if( viewFileName.endsWith(".jsp")) {
//			viewFileName = viewFileName.replace(".jsp", "");
//		}
//		
//		rsltMap.put("viewFileName", viewFileName);
//		rsltMap.put("errCd", errCd);
//		rsltMap.put("errMsg", errMsg);
//		
//		return rsltMap;
//	}
	
}
