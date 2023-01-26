package com.eep.fo.main.controller;

import java.util.HashMap;
import java.util.Map;

import javax.mail.internet.MimeMessage;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.eep.fo.board.service.FoBoardService;

import common.base.controller.BaseController;

@Controller
public class FoMainController extends BaseController {
	
	
	
	@Autowired
	private FoBoardService FoBoardService;
	
	//메인 페이지
	@RequestMapping(value = "/eep/mainPage.do")
	public ModelAndView openFoMainPage() { 
		
		ModelAndView mv = new ModelAndView("/fo/main/index");
		
		Map<String, Object> noticeData = new HashMap<>();
		Map<String, Object> technologyeData = new HashMap<>();
		Map<String, Object> educationData = new HashMap<>();
		
		noticeData = FoBoardService.mainNoticeList();
		technologyeData = FoBoardService.mainTechnologyList();
		educationData = FoBoardService.mainEductaionList();
									
		mv.addObject("noticeData", noticeData);
		mv.addObject("technologyData", technologyeData);
		mv.addObject("educationData", educationData);
		
		return mv;
	}
	
	//회사연혁
	@RequestMapping(value = "/eep/historyPage.do")
	public ModelAndView openFoHistoryPage() { 
		
		ModelAndView mv = new ModelAndView("/fo/main/history");
		return mv;
	}
	
	//조직도
	@RequestMapping(value = "/eep/organizationPage.do")
	public ModelAndView openFoOrganizationPage() { 
		
		ModelAndView mv = new ModelAndView("/fo/main/organization");
		return mv;
	}
	
	
	//CEO 인사말
	@RequestMapping(value = "/eep/ceoPage.do")
	public ModelAndView openFoCeoPage() { 
		
		ModelAndView mv = new ModelAndView("/fo/main/ceo");
		return mv;
	}
	
	
	//자격인증
	@RequestMapping(value = "/eep/certiPage.do")
	public ModelAndView openFoCertiPage() { 
		ModelAndView mv = new ModelAndView("/fo/main/certification");
		return mv;
	}
	
	//사업분야
	@RequestMapping(value = "/eep/businessPage.do")
	public ModelAndView openFoBusinessPage() { 
		ModelAndView mv = new ModelAndView("/fo/main/business");
		return mv;
	}
	
	//컨설팅
	@RequestMapping(value = "/eep/consultPage.do")
	public ModelAndView openFoConsultPage() { 
		ModelAndView mv = new ModelAndView("/fo/main/consulting");
		return mv;
	}
	
	//컨설팅 의뢰
	@RequestMapping(value = "/eep/consultRequestPage.do")
	public ModelAndView openFoConsultRequestPage() { 
		ModelAndView mv = new ModelAndView("/fo/main/consultingRequest");
		return mv;
	}
	
	//채용정보
	@RequestMapping(value = "/eep/employmentInfoPage.do")
	public ModelAndView openFoEmploymentInfoPage() { 
		ModelAndView mv = new ModelAndView("/fo/main/employmentInfo");
		return mv;
	}
	
	//입사지원
	@RequestMapping(value = "/eep/employmentRequestPage.do")
	public ModelAndView openFoEmploymentRequstPage() { 
		ModelAndView mv = new ModelAndView("/fo/main/employmentRequest");
		return mv;
	}
	
	//FAQ(자주하는 질문)
	@RequestMapping(value = "/eep/faqPage.do")
	public ModelAndView openFoFaqPage() { 
		ModelAndView mv = new ModelAndView("/fo/main/faq");
		return mv;
	}
	
	//오시는길
	@RequestMapping(value = "/eep/mapPage.do")
	public ModelAndView openFoMapPage() { 
		ModelAndView mv = new ModelAndView("/fo/main/map");
		return mv;
	}
	
	//게시판 리스트
	@RequestMapping(value = "/eep/boardList.do")
	public ModelAndView openFoBoardListPage() { 
		ModelAndView mv = new ModelAndView("/fo/board/boardList");
		return mv;
	}
	
	//게시판 리스트
	@RequestMapping(value = "/eep/boardContent.do")
	public ModelAndView openFoBoardContentPage() { 
		ModelAndView mv = new ModelAndView("/fo/board/boardContent");
		return mv;
	}
	
	//게시판 수정
	@RequestMapping(value = "/eep/boardUpdate.do")
	public ModelAndView openFoBoardUpdatePage() { 
		ModelAndView mv = new ModelAndView("/fo/board/boardUpdate");
		return mv;
	}
	
	//게시판 입력
	@RequestMapping(value = "/eep/boardReg.do")
	public ModelAndView openFoBoardRedPage() { 
		ModelAndView mv = new ModelAndView("/fo/board/boardReg");
		return mv;
	}
	
	
	@Autowired
	private JavaMailSender mailSender;

	@RequestMapping(value = "/eep/sendmail.do", method = RequestMethod.POST)
	public String sendmail(@RequestParam("email")String email, @RequestParam("name")String name, @RequestParam("handphone")String handphone, @RequestParam("content")String content) throws Exception {
	//public String sendmail() throws Exception {
		
		
		
//		String setfrom = "isonaki@naver.com"; //보내는 사람
//		String settitle = name+"-입사지원"; // 제목
//		String setcontent = "지금도 테스트중 입니다."; // 내용
		
		
		String setfrom = email; //보내는 사람
		String settitle = "(주)이에스티소프트 홈페이지 입사지원이 있습니다. [지원자 : '" + name + "']"; // 제목
		String tomail = "est.part2@gmail.com"; // 받을 주소
		//String setcontent = "성명 :"+name+"\n 전화번호 : "+handphone+"\n"+content; // 내용
		
		String setcontent = "<!DOCTYPE HTML PUBLIC \\\"-//W3C//DTD XHTML 1.0 Transitional //EN\\\" \\\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\\\">" +
				"<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:o=\"urn:schemas-microsoft-com:office:office\">\r\n" + 
				"<head>\r\n" + 
				"<!--[if gte mso 9]>\r\n" + 
				"<xml>\r\n" + 
				"  <o:OfficeDocumentSettings>\r\n" + 
				"    <o:AllowPNG/>\r\n" + 
				"    <o:PixelsPerInch>96</o:PixelsPerInch>\r\n" + 
				"  </o:OfficeDocumentSettings>\r\n" + 
				"</xml>\r\n" + 
				"<![endif]-->\r\n" + 
				"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\r\n" + 
				"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\r\n" + 
				"<meta name=\"x-apple-disable-message-reformatting\">\r\n" + 
				"<!--[if !mso]><!-->\r\n" + 
				"<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\r\n" + 
				"<!--<![endif]-->\r\n" + 
				"<title></title>\r\n" + 
				"<style type=\"text/css\">\r\n" + 
				"      @media only screen and (min-width: 620px) {\r\n" + 
				"  .u-row {\r\n" + 
				"    width: 600px !important;\r\n" + 
				"  }\r\n" + 
				"  .u-row .u-col {\r\n" + 
				"    vertical-align: top;\r\n" + 
				"  }\r\n" + 
				"  .u-row .u-col-100 {\r\n" + 
				"    width: 600px !important;\r\n" + 
				"  }\r\n" + 
				"}\r\n" + 
				"@media (max-width: 620px) {\r\n" + 
				"  .u-row-container {\r\n" + 
				"    max-width: 100% !important;\r\n" + 
				"    padding-left: 0px !important;\r\n" + 
				"    padding-right: 0px !important;\r\n" + 
				"  }\r\n" + 
				"  .u-row .u-col {\r\n" + 
				"    min-width: 320px !important;\r\n" + 
				"    max-width: 100% !important;\r\n" + 
				"    display: block !important;\r\n" + 
				"  }\r\n" + 
				"  .u-row {\r\n" + 
				"    width: 100% !important;\r\n" + 
				"  }\r\n" + 
				"  .u-col {\r\n" + 
				"    width: 100% !important;\r\n" + 
				"  }\r\n" + 
				"  .u-col > div {\r\n" + 
				"    margin: 0 auto;\r\n" + 
				"  }\r\n" + 
				"}\r\n" + 
				"body {\r\n" + 
				"  margin: 0;\r\n" + 
				"  padding: 0;\r\n" + 
				"}\r\n" + 
				"table,\r\n" + 
				"tr,\r\n" + 
				"td {\r\n" + 
				"  vertical-align: top;\r\n" + 
				"  border-collapse: collapse;\r\n" + 
				"}\r\n" + 
				"p {\r\n" + 
				"  margin: 0;\r\n" + 
				"}\r\n" + 
				".ie-container table,\r\n" + 
				".mso-container table {\r\n" + 
				"  table-layout: fixed;\r\n" + 
				"}\r\n" + 
				"* {\r\n" + 
				"  line-height: inherit;\r\n" + 
				"}\r\n" + 
				"a[x-apple-data-detectors='true'] {\r\n" + 
				"  color: inherit !important;\r\n" + 
				"  text-decoration: none !important;\r\n" + 
				"}\r\n" + 
				"table, td { color: #000000; } @media (max-width: 480px) { #u_content_image_1 .v-container-padding-padding { padding: 30px 10px 10px !important; } #u_content_image_1 .v-src-width { width: auto !important; } #u_content_image_1 .v-src-max-width { max-width: 64% !important; } #u_content_heading_2 .v-container-padding-padding { padding: 30px 10px !important; } #u_content_heading_2 .v-font-size { font-size: 24px !important; } #u_content_heading_1 .v-container-padding-padding { padding: 40px 10px 10px !important; } #u_content_heading_3 .v-container-padding-padding { padding: 40px 10px 10px !important; } #u_content_text_3 .v-container-padding-padding { padding: 0px 10px 10px !important; } #u_content_text_8 .v-container-padding-padding { padding: 10px 10px 30px !important; } #u_content_text_9 .v-container-padding-padding { padding: 30px 10px !important; } }\r\n" + 
				"</style>\r\n" + 
				"<!--[if !mso]><!-->\r\n" + 
				"<link href=\"https://fonts.googleapis.com/css?family=Open+Sans:400,700&display=swap\" rel=\"stylesheet\" type=\"text/css\">\r\n" + 
				"<!--<![endif]-->\r\n" + 
				"</head>\r\n" + 
				"<body class=\"clean-body u_body\" style=\"margin: 0;padding: 0;-webkit-text-size-adjust: 100%;background-color: #ecf0f1;color: #000000\">\r\n" + 
				"<!--[if IE]><div class=\"ie-container\"><![endif]-->\r\n" + 
				"<!--[if mso]><div class=\"mso-container\"><![endif]-->\r\n" + 
				"<table style=\"border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;min-width: 320px;Margin: 0 auto;background-color: #ecf0f1;width:100%\" cellpadding=\"0\" cellspacing=\"0\">\r\n" + 
				"<tbody>\r\n" + 
				"<tr style=\"vertical-align: top\">\r\n" + 
				"	<td style=\"word-break: break-word;border-collapse: collapse !important;vertical-align: top\">\r\n" + 
				"		<!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td align=\"center\" style=\"background-color: #ecf0f1;\"><![endif]-->\r\n" + 
				"		<div class=\"u-row-container\" style=\"padding: 0px;background-color: transparent\">\r\n" + 
				"			<div class=\"u-row\" style=\"Margin: 0 auto;min-width: 320px;max-width: 600px;overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;\">\r\n" + 
				"				<div style=\"border-collapse: collapse;display: table;width: 100%;height: 100%;background-color: transparent;\">\r\n" + 
				"					<!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding: 0px;background-color: transparent;\" align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width:600px;\"><tr style=\"background-color: transparent;\"><![endif]-->\r\n" + 
				"					<!--[if (mso)|(IE)]><td align=\"center\" width=\"600\" style=\"background-color: #cddaf7;width: 600px;padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;\" valign=\"top\"><![endif]-->\r\n" + 
				"					<div class=\"u-col u-col-100\" style=\"max-width: 320px;min-width: 600px;display: table-cell;vertical-align: top;\">\r\n" + 
				"						<div style=\"background-color: #cddaf7;height: 100%;width: 100% !important;\">\r\n" + 
				"							<!--[if (!mso)&(!IE)]><!-->\r\n" + 
				"							<div style=\"box-sizing: border-box; height: 100%; padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;\">\r\n" + 
				"								<!--<![endif]-->\r\n" + 
				"								<table id=\"u_content_image_1\" style=\"font-family:'Open Sans',sans-serif;\" role=\"presentation\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" border=\"0\">\r\n" + 
				"								<tbody>\r\n" + 
				"								<tr>\r\n" + 
				"									<td class=\"v-container-padding-padding\" style=\"overflow-wrap:break-word;word-break:break-word;padding:40px 10px 10px;font-family:'Open Sans',sans-serif;\" align=\"left\">\r\n" + 
				"										<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">\r\n" + 
				"										<tr>\r\n" + 
				"											<td style=\"padding-right: 0px;padding-left: 0px;\" align=\"center\">\r\n" + 
				"												<img align=\"center\" border=\"0\" src=\"https://cdn.templates.unlayer.com/assets/1672640418885-head.png\" alt=\"image\" title=\"image\" style=\"outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;clear: both;display: inline-block !important;border: none;height: auto;float: none;width: 45%;max-width: 261px;\" width=\"261\" class=\"v-src-width v-src-max-width\"/>\r\n" + 
				"											</td>\r\n" + 
				"										</tr>\r\n" + 
				"										</table>\r\n" + 
				"									</td>\r\n" + 
				"								</tr>\r\n" + 
				"								</tbody>\r\n" + 
				"								</table>\r\n" + 
				"								<table id=\"u_content_heading_2\" style=\"font-family:'Open Sans',sans-serif;\" role=\"presentation\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" border=\"0\">\r\n" + 
				"								<tbody>\r\n" + 
				"								<tr>\r\n" + 
				"									<td class=\"v-container-padding-padding\" style=\"overflow-wrap:break-word;word-break:break-word;padding:20px 15px 40px;font-family:'Open Sans',sans-serif;\" align=\"left\">\r\n" + 
				"										<h1 class=\"v-font-size\" style=\"margin: 0px; color: #00214d; line-height: 120%; text-align: center; word-wrap: break-word; font-weight: normal; font-family: 'Open Sans',sans-serif; font-size: 35px;\"><strong>(주)이에스티소프트의 입사 지원자가 있습니다 !</strong></h1>\r\n" + 
				"									</td>\r\n" + 
				"								</tr>\r\n" + 
				"								</tbody>\r\n" + 
				"								</table>\r\n" + 
				"								<!--[if (!mso)&(!IE)]><!-->\r\n" + 
				"							</div>\r\n" + 
				"							<!--<![endif]-->\r\n" + 
				"						</div>\r\n" + 
				"					</div>\r\n" + 
				"					<!--[if (mso)|(IE)]></td><![endif]-->\r\n" + 
				"					<!--[if (mso)|(IE)]></tr></table></td></tr></table><![endif]-->\r\n" + 
				"				</div>\r\n" + 
				"			</div>\r\n" + 
				"		</div>\r\n" + 
				"		<div class=\"u-row-container\" style=\"padding: 0px;background-color: transparent\">\r\n" + 
				"			<div class=\"u-row\" style=\"Margin: 0 auto;min-width: 320px;max-width: 600px;overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;\">\r\n" + 
				"				<div style=\"border-collapse: collapse;display: table;width: 100%;height: 100%;background-color: transparent;\">\r\n" + 
				"					<!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding: 0px;background-color: transparent;\" align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width:600px;\"><tr style=\"background-color: transparent;\"><![endif]-->\r\n" + 
				"					<!--[if (mso)|(IE)]><td align=\"center\" width=\"600\" style=\"background-color: #f8f7f7;width: 600px;padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;border-radius: 0px;-webkit-border-radius: 0px; -moz-border-radius: 0px;\" valign=\"top\"><![endif]-->\r\n" + 
				"					<div class=\"u-col u-col-100\" style=\"max-width: 320px;min-width: 600px;display: table-cell;vertical-align: top;\">\r\n" + 
				"						<div style=\"background-color: #f8f7f7;height: 100%;width: 100% !important;border-radius: 0px;-webkit-border-radius: 0px; -moz-border-radius: 0px;\">\r\n" + 
				"							<!--[if (!mso)&(!IE)]><!-->\r\n" + 
				"							<div style=\"box-sizing: border-box; height: 100%; padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;border-radius: 0px;-webkit-border-radius: 0px; -moz-border-radius: 0px;\">\r\n" + 
				"								<!--<![endif]-->\r\n" + 
				"								<table id=\"u_content_heading_1\" style=\"font-family:'Open Sans',sans-serif;\" role=\"presentation\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" border=\"0\">\r\n" + 
				"								<tbody>\r\n" + 
				"								<tr>\r\n" + 
				"									<td class=\"v-container-padding-padding\" style=\"overflow-wrap:break-word;word-break:break-word;padding:60px 10px 15px 50px;font-family:'Open Sans',sans-serif;\" align=\"left\">\r\n" + 
				"										<h3 class=\"v-font-size\" style=\"margin: 0px; color: #385cdf; line-height: 120%; text-align: left; word-wrap: break-word; font-weight: normal; font-family: 'Open Sans',sans-serif; font-size: 18px;\"><strong>성명 : " + name + "<br/><br/>전화번호 : "+ handphone +"<br/><br/>이메일 : " + email + "</strong></h3>\r\n" + 
				"									</td>\r\n" + 
				"								</tr>\r\n" + 
				"								</tbody>\r\n" + 
				"								</table>\r\n" + 
				"								<table id=\"u_content_heading_3\" style=\"font-family:'Open Sans',sans-serif;\" role=\"presentation\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" border=\"0\">\r\n" + 
				"								<tbody>\r\n" + 
				"								<tr>\r\n" + 
				"									<td class=\"v-container-padding-padding\" style=\"overflow-wrap:break-word;word-break:break-word;padding:60px 10px 15px 50px;font-family:'Open Sans',sans-serif;\" align=\"left\">\r\n" + 
				"										<h1 class=\"v-font-size\" style=\"margin: 0px; color: #385cdf; line-height: 120%; text-align: left; word-wrap: break-word; font-weight: normal; font-family: 'Open Sans',sans-serif; font-size: 22px;\"><strong>자기 소개 : </strong></h1>\r\n" + 
				"									</td>\r\n" + 
				"								</tr>\r\n" + 
				"								</tbody>\r\n" + 
				"								</table>\r\n" + 
				"								<table id=\"u_content_text_3\" style=\"font-family:'Open Sans',sans-serif;\" role=\"presentation\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" border=\"0\">\r\n" + 
				"								<tbody>\r\n" + 
				"								<tr>\r\n" + 
				"									<td class=\"v-container-padding-padding\" style=\"overflow-wrap:break-word;word-break:break-word;padding:0px 50px 30px;font-family:'Open Sans',sans-serif;\" align=\"left\">\r\n" + 
				"										<div style=\"line-height: 160%; text-align: justify; word-wrap: break-word;\">\r\n" + 
				"											<p style=\"line-height: 160%; font-size: 11px;\">\r\n" + 
				"												<textarea style=\"width: 100%;\r\n" + 
				"																  height: 500px;\r\n" + 
				"																  padding: 10px;\r\n" + 
				"																  box-sizing: border-box;\r\n" + 
				"																  border: solid 0px #1E90FF;\r\n" + 
				"																  border-radius: 5px;\r\n" + 
				"																  font-size: 11px;\r\n" + 
				"																  resize: none; \" readonly disabled>" + content + 
				"												</textarea>\r\n" + 
				"											</p>\r\n" + 
				"										</div>\r\n" + 
				"									</td>\r\n" + 
				"								</tr>\r\n" + 
				"								</tbody>\r\n" + 
				"								</table>\r\n" + 
				"								<!--[if (!mso)&(!IE)]><!-->\r\n" + 
				"							</div>\r\n" + 
				"							<!--<![endif]-->\r\n" + 
				"						</div>\r\n" + 
				"					</div>\r\n" + 
				"					<!--[if (mso)|(IE)]></td><![endif]-->\r\n" + 
				"					<!--[if (mso)|(IE)]></tr></table></td></tr></table><![endif]-->\r\n" + 
				"				</div>\r\n" + 
				"			</div>\r\n" + 
				"		</div>\r\n" + 
				"		<div class=\"u-row-container\" style=\"padding: 0px;background-color: transparent\">\r\n" + 
				"			<div class=\"u-row\" style=\"Margin: 0 auto;min-width: 320px;max-width: 600px;overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;\">\r\n" + 
				"				<div style=\"border-collapse: collapse;display: table;width: 100%;height: 100%;background-color: transparent;\">\r\n" + 
				"					<!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding: 0px;background-color: transparent;\" align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width:600px;\"><tr style=\"background-color: transparent;\"><![endif]-->\r\n" + 
				"					<!--[if (mso)|(IE)]><td align=\"center\" width=\"600\" style=\"width: 600px;padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;border-radius: 0px;-webkit-border-radius: 0px; -moz-border-radius: 0px;\" valign=\"top\"><![endif]-->\r\n" + 
				"					<div class=\"u-col u-col-100\" style=\"max-width: 320px;min-width: 600px;display: table-cell;vertical-align: top;\">\r\n" + 
				"						<div style=\"height: 100%;width: 100% !important;border-radius: 0px;-webkit-border-radius: 0px; -moz-border-radius: 0px;\">\r\n" + 
				"							<!--[if (!mso)&(!IE)]><!-->\r\n" + 
				"							<div style=\"box-sizing: border-box; height: 100%; padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;border-radius: 0px;-webkit-border-radius: 0px; -moz-border-radius: 0px;\">\r\n" + 
				"								<!--<![endif]-->\r\n" + 
				"								<table id=\"u_content_text_8\" style=\"font-family:'Open Sans',sans-serif;\" role=\"presentation\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" border=\"0\">\r\n" + 
				"								<tbody>\r\n" + 
				"								<tr>\r\n" + 
				"									<td class=\"v-container-padding-padding\" style=\"overflow-wrap:break-word;word-break:break-word;padding:10px 100px 60px;font-family:'Open Sans',sans-serif;\" align=\"left\">\r\n" + 
				"										<div style=\"color: #000000; line-height: 170%; text-align: center; word-wrap: break-word;\">\r\n" + 
				"											<br><p style=\"font-size: 14px; line-height: 170%;\">\r\n" + 
				"												UNSUBSCRIBE | PRIVACY POLICY | WEB\r\n" + 
				"											</p>\r\n" + 
				"											<p style=\"font-size: 14px; line-height: 170%;\">\r\n" + 
				"											</p>\r\n" + 
				"											<br><p style=\"font-size: 14px; line-height: 170%; text-align: left;\">\r\n" + 
				"												<span style=\"font-size: 12px; line-height: 20.4px;\">MUTUAL : 주식회사 이에스티소프트 대표 - 임은수</span><br/><span style=\"font-size: 12px; line-height: 20.4px;\">ADDRESS : 서울특별시 영등포구 당산로28길 4(당산동3가) 송암빌딩 3층</span><br/><span style=\"font-size: 12px; line-height: 20.4px;\">SERVICE : 월요일 - 금요일 AM 09:00 - PM 18:00</span><br/><span style=\"font-size: 12px; line-height: 20.4px;\">TEL : +82 070-7794-1123</span><br/><span style=\"font-size: 12px; line-height: 20.4px;\">FEX : +82 02-2069-1123</span><br/><span style=\"font-size: 12px; line-height: 20.4px;\">Copyright © 주식회사 이에스티소프트 Co., Ltd. All Rights Reserved.</span>\r\n" + 
				"											</p>\r\n" + 
				"										</div>\r\n" + 
				"									</td>\r\n" + 
				"								</tr>\r\n" + 
				"								</tbody>\r\n" + 
				"								</table>\r\n" + 
				"								<!--[if (!mso)&(!IE)]><!-->\r\n" + 
				"							</div>\r\n" + 
				"							<!--<![endif]-->\r\n" + 
				"						</div>\r\n" + 
				"					</div>\r\n" + 
				"					<!--[if (mso)|(IE)]></td><![endif]-->\r\n" + 
				"					<!--[if (mso)|(IE)]></tr></table></td></tr></table><![endif]-->\r\n" + 
				"				</div>\r\n" + 
				"			</div>\r\n" + 
				"		</div>\r\n" + 
				"		<div class=\"u-row-container\" style=\"padding: 0px;background-color: #ffffff\">\r\n" + 
				"			<div class=\"u-row\" style=\"Margin: 0 auto;min-width: 320px;max-width: 600px;overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;\">\r\n" + 
				"				<div style=\"border-collapse: collapse;display: table;width: 100%;height: 100%;background-color: transparent;\">\r\n" + 
				"					<!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding: 0px;background-color: #ffffff;\" align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width:600px;\"><tr style=\"background-color: transparent;\"><![endif]-->\r\n" + 
				"					<!--[if (mso)|(IE)]><td align=\"center\" width=\"600\" style=\"width: 600px;padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;border-radius: 0px;-webkit-border-radius: 0px; -moz-border-radius: 0px;\" valign=\"top\"><![endif]-->\r\n" + 
				"					<div class=\"u-col u-col-100\" style=\"max-width: 320px;min-width: 600px;display: table-cell;vertical-align: top;\">\r\n" + 
				"						<div style=\"height: 100%;width: 100% !important;border-radius: 0px;-webkit-border-radius: 0px; -moz-border-radius: 0px;\">\r\n" + 
				"							<!--[if (!mso)&(!IE)]><!-->\r\n" + 
				"							<div style=\"box-sizing: border-box; height: 100%; padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;border-radius: 0px;-webkit-border-radius: 0px; -moz-border-radius: 0px;\">\r\n" + 
				"								<!--<![endif]-->\r\n" + 
				"								<table id=\"u_content_text_9\" style=\"font-family:'Open Sans',sans-serif;\" role=\"presentation\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" border=\"0\">\r\n" + 
				"								<tbody>\r\n" + 
				"								<tr>\r\n" + 
				"									<td class=\"v-container-padding-padding\" style=\"overflow-wrap:break-word;word-break:break-word;padding:30px 60px;font-family:'Open Sans',sans-serif;\" align=\"left\">\r\n" + 
				"										<div style=\"color: #000000; line-height: 140%; text-align: center; word-wrap: break-word;\">\r\n" + 
				"											<p style=\"font-size: 14px; line-height: 140%;\">\r\n" + 
				"												<span style=\"text-decoration: underline; font-size: 14px; line-height: 19.6px;\"></span>\r\n" + 
				"											</p>\r\n" + 
				"										</div>\r\n" + 
				"									</td>\r\n" + 
				"								</tr>\r\n" + 
				"								</tbody>\r\n" + 
				"								</table>\r\n" + 
				"								<!--[if (!mso)&(!IE)]><!-->\r\n" + 
				"							</div>\r\n" + 
				"							<!--<![endif]-->\r\n" + 
				"						</div>\r\n" + 
				"					</div>\r\n" + 
				"					<!--[if (mso)|(IE)]></td><![endif]-->\r\n" + 
				"					<!--[if (mso)|(IE)]></tr></table></td></tr></table><![endif]-->\r\n" + 
				"				</div>\r\n" + 
				"			</div>\r\n" + 
				"		</div>\r\n" + 
				"		<!--[if (mso)|(IE)]></td></tr></table><![endif]-->\r\n" + 
				"	</td>\r\n" + 
				"</tr>\r\n" + 
				"</tbody>\r\n" + 
				"</table>\r\n" + 
				"<!--[if mso]></div><![endif]-->\r\n" + 
				"<!--[if IE]></div><![endif]-->\r\n" + 
				"</body>\r\n" + 
				"</html>";

		try {
			MimeMessage message = mailSender.createMimeMessage();
			MimeMessageHelper messageHelper = new MimeMessageHelper(message,true, "UTF-8");

			messageHelper.setFrom(setfrom); // 보내는사람 (필수)
			messageHelper.setTo(tomail); // 받는사람 이메일
			messageHelper.setSubject(settitle); // 메일제목은
			//messageHelper.setText(setcontent); // 메일 내용
			message.setContent(setcontent,"text/html; charset=UTF-8"); // HTML 형식

			mailSender.send(message);
			
		} catch (Exception e) {
			System.out.println(e);
		}
		
		return "redirect:/eep/mainPage.do";
	}
	
	
}
