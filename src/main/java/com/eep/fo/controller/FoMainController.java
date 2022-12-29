package com.eep.fo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import common.base.controller.BaseController;

@Controller
public class FoMainController extends BaseController {

	//메인 페이지
	@RequestMapping(value = "/eep/mainPage.do")
	public ModelAndView openFoMainPage() { 
		
		ModelAndView mv = new ModelAndView("/index");
		return mv;
	}
	
	//회사연혁
	@RequestMapping(value = "/eep/historyPage.do")
	public ModelAndView openFoHistoryPage() { 
		
		ModelAndView mv = new ModelAndView("/history");
		return mv;
	}
	
	//조직도
	@RequestMapping(value = "/eep/organizationPage.do")
	public ModelAndView openFoOrganizationPage() { 
		
		ModelAndView mv = new ModelAndView("/organization");
		return mv;
	}
	
	
	//CEO 인사말
	@RequestMapping(value = "/eep/ceoPage.do")
	public ModelAndView openFoCeoPage() { 
		
		ModelAndView mv = new ModelAndView("/ceo");
		return mv;
	}
	
	
	//자격인증
	@RequestMapping(value = "/eep/certiPage.do")
	public ModelAndView openFoCertiPage() { 
		ModelAndView mv = new ModelAndView("/certification");
		return mv;
	}
	
	//사업분야
	@RequestMapping(value = "/eep/businessPage.do")
	public ModelAndView openFoBusinessPage() { 
		ModelAndView mv = new ModelAndView("/business");
		return mv;
	}
	
	//컨설팅
	@RequestMapping(value = "/eep/consultPage.do")
	public ModelAndView openFoConsultPage() { 
		ModelAndView mv = new ModelAndView("/consulting");
		return mv;
	}
	
	//컨설팅 의뢰
	@RequestMapping(value = "/eep/consultRequestPage.do")
	public ModelAndView openFoConsultRequestPage() { 
		ModelAndView mv = new ModelAndView("/consultingRequest");
		return mv;
	}
	
	//채용정보
	@RequestMapping(value = "/eep/employmentInfoPage.do")
	public ModelAndView openFoEmploymentInfoPage() { 
		ModelAndView mv = new ModelAndView("/employmentInfo");
		return mv;
	}
	
	//입사지원
	@RequestMapping(value = "/eep/employmentRequestPage.do")
	public ModelAndView openFoEmploymentRequstPage() { 
		ModelAndView mv = new ModelAndView("/employmentRequest");
		return mv;
	}
	
	//FAQ(자주하는 질문)
	@RequestMapping(value = "/eep/faqPage.do")
	public ModelAndView openFoFaqPage() { 
		ModelAndView mv = new ModelAndView("/faq");
		return mv;
	}
	
	//오시는길
	@RequestMapping(value = "/eep/mapPage.do")
	public ModelAndView openFoMapPage() { 
		ModelAndView mv = new ModelAndView("/map");
		return mv;
	}
	
	//게시판 리스트
	@RequestMapping(value = "/eep/boardList.do")
	public ModelAndView openFoBoardListPage() { 
		ModelAndView mv = new ModelAndView("/boardList");
		return mv;
	}
	
	//게시판 리스트
	@RequestMapping(value = "/eep/boardContent.do")
	public ModelAndView openFoBoardContentPage() { 
		ModelAndView mv = new ModelAndView("/boardContent");
		return mv;
	}
	
	//게시판 수정
	@RequestMapping(value = "/eep/boardUpdate.do")
	public ModelAndView openFoBoardUpdatePage() { 
		ModelAndView mv = new ModelAndView("/boardUpdate");
		return mv;
	}
	
	//게시판 입력
	@RequestMapping(value = "/eep/boardReg.do")
	public ModelAndView openFoBoardRedPage() { 
		ModelAndView mv = new ModelAndView("/boardReg");
		return mv;
	}
}
