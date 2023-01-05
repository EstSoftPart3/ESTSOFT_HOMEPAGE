<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%
	String brdSq = request.getParameter("brdSq"); 
%>
<!DOCTYPE html>
<html lang="en">

<head>
   <%@ include file="/WEB-INF/include/header.jspf" %>
</head>

<style type="text/css">

th, td {
  border: 0px solid #e9ecef;
 }

</style>

<body>
    <!-- Spinner Start -->
    <div id="spinner"
        class="show bg-white position-fixed translate-middle w-100 vh-100 top-50 start-50 d-flex align-items-center justify-content-center">
        <div class="spinner-grow text-primary" role="status"></div>
    </div>
    <!-- Spinner End -->


    <!-- Navbar Start -->
   	<%@ include file="/WEB-INF/include/navbar.jspf" %>
    <!-- Navbar End -->


    <!-- Header Start -->
    <div class="container-fluid hero-header bg-light py-5 mb-5">
        <div class="container py-5">
            <div class="row g-5 align-items-center">
                <div class="col-lg-6">
                    <h1 class="display-4 mb-3 animated slideInDown">EST COMMUNITY</h1>
                     <p class="animated slideInDown IBM">
                    	50여 명의 정직원 모두 성살함과 책임감으로 무장하고 있으며,
                    	<br>
						프로젝트 진행 시 소통이 뛰어난 진정한 전문가 그룹입니다.
					</p>
					
					<nav aria-label="breadcrumb animated slideInDown">
                        <ol class="breadcrumb mb-0 menu">
                            <li class="breadcrumb-item"><a href="#">공지사항</a></li>
                            <li class="breadcrumb-item"><a href="#">자유게시판</a></li>
                            <li class="breadcrumb-item"><a href="#">기술문의</a></li>
                            <li class="breadcrumb-item"><a href="#">교육일정</a></li>
                        </ol>
                    </nav>
                    
                </div>
                <div class="col-lg-6 animated fadeIn">
                    <img class="img-fluid animated pulse infinite" style="animation-duration: 3s;border-radius: 5%;" src="/resources/fo/team/t13.jpg" alt="">
                </div>
            </div>
        </div>
    </div>
    <!-- Header End -->


    <!--Start -->
    <div class="container-xxl py-5 menu">
        <div class="container">
	    	<input type="hidden" name="brdSq" id="brdSq" value="<%=brdSq%>">
            <div class="text-center mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 500px;">
                <h1 class="display-3" style="font-size:20px;">공지사항 내용보기 </h1>
            </div>
           
           <table class="table table-bordered" style="max-width: 900px;font-size:15px;border-color:#ced4da" align="center">
		  	
				<tr style="text-align:center;background-color:#ffffff;">
					<td style="width:15%;background-color:#efefef;">
						<b>제목</b>
					</td>
					<td style="text-align:left;">
						<input style="border:0 solid black; width:800px;" type="text" id="brdTtl" name="brdTtl" readonly>
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td style="width:15%;background-color:#efefef;">
						<b>작성자</b>
					</td>
					<td style="text-align:left;">
						<input style="border:0 solid black; width:800px;" type="text" id="brdWrtr" name="brdWrtr" readonly>
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td style="width:15%;background-color:#efefef;">
						<b>작성일</b>
					</td>
					<td style="text-align:left;">
						<input style="border:0 solid black; width:800px;" type="text" id="brdRegDt" name="brdRegDt" readonly>
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td style="width:15%;background-color:#efefef;vertical-align: middle;">
						<b>내용</b>
					</td>
					<td style="text-align:left;">
					<div id="toolbar-container" style="z-index:9999"></div>
                    
					<textarea class="form-control" id="naverEditor" name="naverEditor" rows="7" style="height:350px; width: 100%;">
					
					</textarea>
					</td>
				</tr>
				
				
			</tbody>
		</table>
		
		<br>

        </div>
        
         <div class="col-12 text-center" style="padding-top:15px;">
         	 <button type="button" class="btn btn-secondary btn-sm" onclick="noticBoardList();">리스트</button>
	         <button type="button" class="btn btn-secondary btn-sm" onclick="noticeUpdatePage();">수정</button>
	         <button type="button" class="btn btn-secondary btn-sm" onclick="noticeBoardDelete();">삭제</button>
         </div>
    </div>
    <!-- FAQs Start -->
    
    <%@ include file="/WEB-INF/include/footer.jspf" %>
    
    <script>
   	   var emplyAuthTypCd = "<c:out value = '${loginInfo.loginInfo[0].emplyAuthTypCd}'/>";
	   var emplySq     = $('#emplySq').val(); //직원순번
	   var brdSq       = $('#brdSq').val();   //공지사항 순번
	   var dataContent = {};				  //데이터 처리 리스트
	   
	   $(document).ready(function(){

			noticeboardDetailtData(brdSq);
			
	   });
	   
	   function noticeboardDetailtData(brdSq) {
			
			$.ajax({
		           type: "post",
		           url: "/eep/board/notice/noticeBoardDetailData.do",
		           data: {
		        	   brdSq : brdSq
		            },
		           success: function(data) {
		        	    
		        	 dataContent = data.noticeBoardDetailData.noticeBoardDetailData[0];

		        	 var brdCntnt 	= dataContent.brdCntnt;
		        	 var brdTtl 	= dataContent.brdTtl;
		        	 var brdWrtr 	= dataContent.brdWrtr;
		        	 var brdRegDt 	= dataContent.brdRegDt;

		        	 //네이버 에디터 적용 전 유효성 체크 반영
					 var castStr = brdCntnt;

					 castStr = castStr.replaceAll("&lt;","<");
					 castStr = castStr.replaceAll("&gt;",">");
					 castStr = castStr.replaceAll("&amp;lt;","<");
					 castStr = castStr.replaceAll("&amp;gt;",">");
					 castStr = castStr.replaceAll("&amp;nbsp;"," ");
					 castStr = castStr.replaceAll("&amp;amp;","&");
					 castStr = castStr.replaceAll("\\","");
					 
					 
					  //네이버 에디터 임포트
					   var oEditors = [];
					   
					   $(function(){
					      nhn.husky.EZCreator.createInIFrame({
					         oAppRef: oEditors,
					         elPlaceHolder: "naverEditor",
					         //SmartEditor2Skin.html 파일이 존재하는 경로
					         sSkinURI: "/resources/navereditor/SmartEditor2Skin.html",  
					         htParams : {
					             // 툴바 사용 여부 (true:사용/ false:사용하지 않음)
					             bUseToolbar : false,             
					             // 입력창 크기 조절바 사용 여부 (true:사용/ false:사용하지 않음)
					             bUseVerticalResizer : false,     
					             // 모드 탭(Editor | HTML | TEXT) 사용 여부 (true:사용/ false:사용하지 않음)
					             bUseModeChanger : false,         
					             fOnBeforeUnload : function(){
					                  
					             }
					         }, 
					         fOnAppLoad : function(){
					             //textarea 내용을 에디터상에 바로 뿌려주고자 할때 사용
					             //내용초기화
					             oEditors.getById["naverEditor"].exec("SET_IR", [""]);
					           	 //DB내용 표현
					             oEditors.getById["naverEditor"].exec("PASTE_HTML", [castStr]);
					           	 //수정 불가 지정
					             oEditors.getById["naverEditor"].exec("DISABLE_WYSIWYG");
					           	 //UI 비활성화
					             oEditors.getById["naverEditor"].exec("DISABLE_ALL_UI");

					         },
					         fCreator: "createSEditor2"
					       })
					   });
					 
		        	 /* document.getElementById('naverEditor').innerHTML=castStr; */
		        	 $('#brdTtl').val(brdTtl);
		        	 $('#brdWrtr').val(brdWrtr);
		        	 $('#brdRegDt').val(brdRegDt);
		           },
		           error: function(error) {
		        	   var errorJson = JSON.stringify(error);
		               console.log(errorJson);
		           }
			})
		}
	   
	  
	   function noticeBoardDelete() {
			
	    	if(emplyAuthTypCd == '2'){
	    		if(confirm('정말 삭제 하시겠습니까?')) {
	    			
				   $.ajax({
			           type: "post",
			           url: "/eep/board/notice/noticeBoardDeleteData.do",
			           data: {
			        	   brdSq : brdSq,
			           },
			           success: function(data) {
			        	   bootbox.alert({
								 message: "삭제 되었습니다.",
								 locale: 'kr',
								 callback: function() {
									 location.href='/eep/board/notice/openNoticeBoardList.do';	
							     } });
					   },
			           error: function(error) {
			        	   var errorJson = JSON.stringify(error);
			               console.log(errorJson);
			           }
				   })
					   
				   }else{
					   return false;
			   }
	    	}else{
	    		bootbox.alert({
					 message: "해당 권한이 없습니다.",
					 locale: 'kr',
					 callback: function() {
						 return;
				     } });
	    	}

	   }
	   
	   function noticBoardList() {
		   
		   location.href='/eep/board/notice/openNoticeBoardList.do';
	   }
	   
		 //Input Box Null Check
	   function isEmpty(str){
	       
	       if(typeof str == "undefined" || str == null || str == "")
	           return true;
	       else
	           return false ;
	   }

	   function noticeUpdatePage() {
			
	    	if(emplyAuthTypCd == '2'){
	    		location.href='/eep/board/notice/openNoticeBoardUpdate.do?brdSq='+brdSq;
	    	}else{
	    		bootbox.alert({
					 message: "해당 권한이 없습니다.",
					 locale: 'kr',
					 callback: function() {
						 return;
				     } });
				 
	    	}
		   
		}
    </script>
    
    
</body>

</html>