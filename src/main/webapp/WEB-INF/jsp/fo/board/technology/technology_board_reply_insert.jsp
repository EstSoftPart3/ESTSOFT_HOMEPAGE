<%@ page language="java" contentType="text/html;charset=UTF-8" %>

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
<%
	String brdSq = request.getParameter("brdSq"); 
	String brdReRep = request.getParameter("brdReRep"); 
	String brdReLev = request.getParameter("brdReLev"); 
	String brdReOrd = request.getParameter("brdReOrd"); 
%>
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
    	<input type="hidden" name="brdSq" id="brdSq" value="<%=brdSq%>">
		<input type="hidden" name="brdReRep" id="brdReRep" value="<%=brdReRep%>">
		<input type="hidden" name="brdReLev" id="brdReLev" value="<%=brdReLev%>">
		<input type="hidden" name="brdReOrd" id="brdReOrd" value="<%=brdReOrd%>">
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
                            <li class="breadcrumb-item">
	                            <a style="text-decoration: none;" href="/eep/board/notice/openNoticeBoardList.do">
	                            	<b>공지사항</b>
	                            </a>
                            </li>
                            <li class="breadcrumb-item">
	                            <a style="text-decoration: none;" href="/eep/board/freedom/openFreedomBoardList.do">
	                            	<b>자유게시판</b>
	                            </a>
                            </li>
                            <li class="breadcrumb-item">
	                            <a style="text-decoration: none;" href="/eep/board/technology/openTechnologyBoardList.do">
	                            	<b>기술문의</b>
	                            </a>
                            </li>
                            <li class="breadcrumb-item">
	                            <a style="text-decoration: none;" href="/eep/board/education/openEducationBoardList.do">
	                            	<b>교육일정</b>
	                            </a>
                            </li>
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
            <div class="text-center mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 500px;">
                <h1 class="display-3" style="font-size:20px;">[<%=brdSq%>]번 기술문의 게시판 답글 작성하기 </h1>
            </div>
           
           <table class="table table-bordered" style="max-width: 900px;font-size:15px;border-color:#ced4da" align="center">
		  		
				<tr style="text-align:center;background-color:#ffffff;">
					<td style="width:15%;background-color:#efefef;">
						<b>제목</b>
					</td>
					<td style="text-align:left;">
						<input type="text" class="form-control" id="brdTtl" style="font-size:12px;" value="[답글] ">
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td style="width:15%;background-color:#efefef;">
						<b>성명</b>
					</td>
					<td style="text-align:left;">
						<input type="text" class="form-control" id="brdWrtr" style="font-size:12px;" value="${loginInfo.loginInfo[0].emplyNm}" readonly>
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td style="width:15%;background-color:#efefef;">
						<b>입력일</b>
					</td>
					<td style="text-align:left;">
						<input type="text" class="form-control" id="brdRegDt" style="font-size:12px;" value="자동입력" readonly>
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td style="width:15%;background-color:#efefef;vertical-align: middle;">
						<b>내용</b>
					</td>
					<td style="text-align:left;height:250px;">
					<div id="toolbar-container" style="z-index:9999"></div>
                    
					<textarea class="form-control" id="naverEditor" name="naverEditor" rows="7" style="height:350px; width: 100%;">

					</textarea>
					</td>
				</tr>
				
				
			</tbody>
		</table>
           
        </div>
        
         <div class="col-12 text-center" style="padding-top:15px;">
         	 <button type="button" class="btn btn-secondary btn-sm" onclick="technologyBoardList();">리스트</button>
         	 <button type="button" class="btn btn-secondary btn-sm" onclick="technologyBoardInsert();">작성하기</button>
         </div>
    </div>
    <!-- FAQs Start -->
    
    <%@ include file="/WEB-INF/include/footer.jspf" %>
    
    <script>
    
    var emplySq = "<c:out value = '${loginInfo.loginInfo[0].emplySq}'/>";
    var brdSq    = $('#brdSq').val();   //순번
    var brdReRep    = $('#brdReRep').val();   
    var brdReLev    = $('#brdReLev').val();   
    var brdReOrd    = $('#brdReOrd').val();   
    
    var oEditors = [];
    
    $(function(){
        nhn.husky.EZCreator.createInIFrame({
           oAppRef: oEditors,
           elPlaceHolder: "naverEditor",
           //SmartEditor2Skin.html 파일이 존재하는 경로
           sSkinURI: "/resources/navereditor/SmartEditor2Skin.html",  
           htParams : {
               // 툴바 사용 여부 (true:사용/ false:사용하지 않음)
               bUseToolbar : true,             
               // 입력창 크기 조절바 사용 여부 (true:사용/ false:사용하지 않음)
               bUseVerticalResizer : true,     
               // 모드 탭(Editor | HTML | TEXT) 사용 여부 (true:사용/ false:사용하지 않음)
               bUseModeChanger : true,         
               fOnBeforeUnload : function(){
                    
               }
           }, 
           fOnAppLoad : function(){
               //textarea 내용을 에디터상에 바로 뿌려주고자 할때 사용
               oEditors.getById["naverEditor"].exec("PASTE_HTML", [""]);
           },
           fCreator: "createSEditor2"
         })
     });
    
    function technologyBoardInsert() {

    	var brdTypCd 	= 'FD'  							//게시판 구분 코드
       	var brdTtl  	= $("#brdTtl").val();  				//게시판 제목
       	var brdWrtr  	= $("#brdWrtr").val();  			//게시판 작성자
       	var brdReRep  	= $("#brdReRep").val();
       	var brdReLev  	= $("#brdReLev").val();
       	var brdReOrd  	= $("#brdReOrd").val();
       	
        oEditors.getById["naverEditor"].exec("UPDATE_CONTENTS_FIELD", [])
       	var brdCntnt = document.getElementById("naverEditor").value

       	 //제목
       	 if(isEmpty(brdTtl)) {
       		bootbox.alert({
    				 message: "제목을 입력해 주세요.",
    				 locale: 'kr',
    				 callback: function() {
    				 		$("#brdTitle").focus();
    			     } });
    			 return;
       	 }
    	 
         //내용
       	 if(brdCntnt == "<p>&nbsp;</p>" || brdCntnt == "" || isEmpty(brdCntnt)) {
       		bootbox.alert({
    				 message: "내용을 입력해 주세요.",
    				 locale: 'kr',
    				 callback: function() {
    					 $("#brdCntnt").focus();
    			     } });
    			 return;
       	 }

    		$.ajax({
    	           type: "post",
    	           url: "/eep/board/technology/technologyBoardReplyInsertData.do",
    	           data: {
    	        	   emplySq : emplySq,
    	        	   brdTypCd : brdTypCd,
    	        	   brdTtl : brdTtl,
    	        	   brdCntnt : brdCntnt,
    	        	   brdWrtr : brdWrtr,
    	        	   brdReRep : brdReRep,
    	        	   brdReLev : brdReLev,
    	        	   brdReOrd : brdReOrd
    	           },
    	           success: function(data) {
    	        	   bootbox.alert({
    						 message: "게시글이 저장 되었습니다.",
    						 locale: 'kr',
    						 callback: function() {
    							 		location.href='/eep/board/technology/openTechnologyBoardList.do';
    					     } });
    			   },
    	           error: function(error) {
    	        	   var errorJson = JSON.stringify(error);
    	               console.log(errorJson);
    	           }
    		})
    	}
       
       function freedomBoardList() {
    	   location.href='/eep/board/technology/openTechnologyBoardList.do';
       }
       
      //Input Box Null Check
       function isEmpty(str){
           
           if(typeof str == "undefined" || str == null || str == "")
               return true;
           else
               return false ;
       }
    
    </script>
    
    
</body>

</html>