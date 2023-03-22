<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%
	String brdSq = request.getParameter("brdSq"); 
	String brdReReef = request.getParameter("brdReReef");
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
        	<input type="hidden" name="brdWrtrSq" id="brdWrtrSq" value="">
	    	<input type="hidden" name="brdSq" id="brdSq" value="<%=brdSq%>">
  		    <input type="hidden" name="brdReRep" id="brdReRep" value="">
  			<input type="hidden" name="brdReLev" id="brdReLev" value="">
  			<input type="hidden" name="brdReOrd" id="brdReOrd" value="">
            <div class="text-center mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 500px;">
                <h1 class="display-3" style="font-size:20px;">자유게시판 내용보기 </h1>
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

          <!-- 댓글 리스트 -->
        <div class="text-left mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 900px;">
             <h1 class="display-3" style="font-size:14px;"><b>※ 댓글 리스트</b></h1>
        </div>
         <div id="commentList">
         </div>
         
         <!-- 댓글 입력 -->
         <div class="text-left mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 900px;padding-top:30px;">
             <h1 class="display-3" style="font-size:14px;"><b>※ 댓글 입력</b></h1>
        </div>
		<table class="table table-bordered" style="max-width: 900px;font-size:15px;border-color:#ced4da" align="center">
			<tr>
				<td style="width:90%">
					<textarea class="form-control" id="commentTextarea" rows="7" style="font-size:12px;height:70px;"></textarea>
				</td>
				<td style="vertical-align: middle;border-right-style: none;">
					<button type="button" class="btn btn-secondary btn-lg" onclick="commentInsert();">확인</button>
				</td>
			</tr>
		</table>
		
		
        </div>
		
         <div class="col-12 text-center" style="padding-top:15px;">
         	 <button type="button" class="btn btn-secondary btn-sm" onclick="freedomBoardList();">리스트</button>
         	 <button type="button" class="btn btn-secondary btn-sm" onclick="freedomBoardRplyInsertPage();">답글</button>
	         <button type="button" class="btn btn-secondary btn-sm" onclick="freedomUpdatePage();">수정</button>
	         <button type="button" class="btn btn-secondary btn-sm" onclick="freedomBoardDelete();">삭제</button>
         </div>
         
       
    </div>
    <!-- FAQs Start -->
    
    <%@ include file="/WEB-INF/include/footer.jspf" %>
    
    <script>
   	   var emplyAuthTypCd = "<c:out value = '${loginInfo.loginInfo[0].emplyAuthTypCd}'/>";
   	   var emplySq = "<c:out value = '${loginInfo.loginInfo[0].emplySq}'/>"; //직원순번
	   var brdSq       = $('#brdSq').val();   //공지사항 순번
	   var dataContent = {};				  //데이터 처리 리스트
	   var commentList = {};				  //댓글 리스트
	   
	   $(document).ready(function(){

		   freedomBoardDetailData(brdSq);
			commentListData(brdSq); //댓글 조회
	   });
	   
	   function freedomBoardDetailData(brdSq) {
			
			$.ajax({
		           type: "post",
		           url: "/eep/board/freedom/freedomBoardDetailData.do",
		           data: {
		        	   brdSq : brdSq
		            },
		           success: function(data) {
		        	    
		        	 dataContent = data.freedomBoardDetailData.freedomBoardDetailData[0];

		        	 var brdWrtrSq 	= dataContent.emplySq;
		        	 var brdCntnt 	= dataContent.brdCntnt;
		        	 var brdTtl 	= dataContent.brdTtl;
		        	 var brdWrtr 	= dataContent.brdWrtr;
		        	 var brdReRep 	= dataContent.brdReRep;
		        	 var brdReLev 	= dataContent.brdReLev;
		        	 var brdReOrd 	= dataContent.brdReOrd;
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
		        	 $('#brdReRep').val(brdReRep);
		        	 $('#brdReLev').val(brdReLev);
		        	 $('#brdReOrd').val(brdReOrd);
		        	 $('#brdRegDt').val(brdRegDt);
		        	 $('#brdWrtrSq').val(brdWrtrSq);
		        	

		           },
		           error: function(error) {
		        	   var errorJson = JSON.stringify(error);
		               console.log(errorJson);
		           }
			})
		}
	   
	  
	   function freedomBoardDelete() {
		   
		   var brdWrtrSq = $('#brdWrtrSq').val();
		   
	    	if(emplySq == brdWrtrSq){
	    		
	    		if(confirm('정말 삭제 하시겠습니까?')) {
	    			
				   $.ajax({
			           type: "post",
			           url: "/eep/board/freedom/freedomBoardDeleteData.do",
			           data: {
			        	   brdSq : brdSq,
			           },
			           success: function(data) {
			        	   bootbox.alert({
								 message: "삭제 되었습니다.",
								 locale: 'kr',
								 callback: function() {
									 location.href='/eep/board/freedom/openFreedomBoardList.do';	
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
					 message: "다른 계정의 게시판은 삭제 할 수 없습니다.",
					 locale: 'kr',
					 callback: function() {
						 return;
				     } });
	    	}

	   }
	   
	   function freedomBoardList() {

		   location.href='/eep/board/freedom/openFreedomBoardList.do';
	   }
	   
	   function freedomUpdatePage() {
		   
		   	var brdWrtrSq = $('#brdWrtrSq').val();
		   
	    	if(emplySq == brdWrtrSq){
	    		location.href='/eep/board/freedom/openFreedomBoardUpdate.do?brdSq='+brdSq;
	    	}else{
	    		bootbox.alert({
					 message: "다른 계정의 게시판은 수정 할 수 없습니다.",
					 locale: 'kr',
					 callback: function() {
						 return;
				     } });
				 
	    	}
		   
		}
	   
		function freedomBoardRplyInsertPage() {
			   
			var brdReRep = $('#brdReRep').val();
	   	 	var brdReLev = $('#brdReLev').val();
	   	 	var brdReOrd = $('#brdReOrd').val();
			
		   	location.href='/eep/board/freedom/openFeedomBoardReplyInsert.do?brdSq='+brdSq+'&brdReRep='+brdReRep+'&brdReLev='+brdReLev+'&brdReOrd='+brdReOrd;
		}
	   
		//Input Box Null Check
	   function isEmpty(str){
	       
	       if(typeof str == "undefined" || str == null || str == "")
	           return true;
	       else
	           return false ;
	   }
		
		//댓글 조회
		function commentListData(brdSq){
			
			$.ajax({
				type: "post",
				url: "/eep/comment/commentListData.do",
				data:{
					brdSq : brdSq
				},
				success : function(data){
					commentList = data.commentData.commentInfo;
					var body = $("#commentList");
					body.empty();
					var str = "";
					if(commentList.length > 0){
						for(i = 0; i < commentList.length; i++){
							var cmmntSq 		= commentList[i].cmmntSq; 		//댓글 번호
							var cmmntEmplySq 	= commentList[i].emplySq;		//작성자 번호
							var cmmntCntnt 		= commentList[i].cmmntCntnt;	//댓글 내용
							var cmmntRegDt 		= commentList[i].cmmntRegDt.toString();	//댓글 작성일
							var cmmntNm 		= commentList[i].emplyNm;		//작성자 이름
							var cmmntUpdtDt		= commentList[i].cmmntUpdtDt;	//수정 날짜
							console.log(cmmntSq);
							str += '<table class="table table-bordered" style="max-width: 900px;font-size:14px;border-color:#ced4da" align="center">';
							str += '<tr style="background-color:#efefef;">';
							str += '<td colspan="3">';
							str += '<div style="float:left;width:80%">';
							str += '작성자 : ' + cmmntNm;
							str += '</div>';
							str += '<div style="float:left">';
							//수정 날짜가 존재할 시 수정일로 표기
							if(cmmntUpdtDt == null){
								str += '작성일 : ' + cmmntRegDt.substr(0, 4) + '년' + cmmntRegDt.substr(5, 2) + '월' + cmmntRegDt.substr(8, 2) + '일';
							}else{
								str += '수정일 : ' + cmmntUpdtDt.substr(0, 4) + '년' + cmmntUpdtDt.substr(5, 2) + '월' + cmmntUpdtDt.substr(8, 2) + '일';
							}
							str += '</div>';
							str += '</td>';
							str += '</tr>';
							str += '<tr>';
							str += '<td colspan="2" style="height:70px;width:90%">';
							//작성자일 경우 바로 수정 가능
							if(cmmntEmplySq == emplySq){
								str += '<textarea class="form-control" id="commentTextarea' + cmmntSq + '" rows="7" style="font-size:12px;height:70px;">';
								str += cmmntCntnt;
								str += '</textarea>'
							}else{
								str += cmmntCntnt;
							}
							str += '</td>';
							str += '<td style="vertical-align: middle;text-align:center;">';
							//작성자, 최고관리자일 경우 수정, 삭제 버튼 생성
							if(cmmntEmplySq == emplySq){
								str += '<button type="button" class="btn btn-secondary btn-sm" onclick="commentUpdate('+ cmmntSq + ');">수정</button>';
								str += '<br><br>';
								str += '<button type="button" class="btn btn-secondary btn-sm" onclick="commentDelete('+ cmmntSq + ');">삭제</button>';
							}
							str += '</td>';
							str += '</tr>';
							str += '</table>';
							str += '<br>';
						}
					}else {
						str += '<table class="table table-bordered" style="max-width: 900px;font-size:14px;border-color:#ced4da" align="center">';
						str += "<tr>";
		                str += "<td colspan='4'>등록된 글이 존재하지 않습니다.</td>";
		                str += "<tr>";
		                str += '</table>';
					}
					
					body.html(str);
					
					console.log("ajax 조회 성공");
				}
			})
		}
		
		//댓글 등록
		function commentInsert(){
			
			var cmmntCntnt = $('#commentTextarea').val();
			
			if(emplySq == null){
				bootbox.alert({
					 message: "로그인 후 사용가능합니다.",
					 locale: 'kr',
					 callback: function() {
					 		//$("#searchOption").focus();
				     } });
				return false;
			}
			if(cmmntCntnt == null || cmmntCntnt == ''){
				bootbox.alert({
					 message: "댓글을 입력해주세요.",
					 locale: 'kr',
					 callback: function() {
					 		$("#commentTextarea").focus();
				     } });
				return false;
			}
			
			$.ajax({
				type: "post",
				url: "/eep/comment/commentInsert.do",
				data:{
					brdSq : brdSq			//게시글 번호
					,emplySq : emplySq		//작성자 번호
					,cmmntCntnt : cmmntCntnt	//댓글 내용
				},
				success : function(data){
					if(data == 1){
						bootbox.alert({
							 message: "댓글 입력이 완료됬습니다.",
							 locale: 'kr',
							 callback: function() {
							 		//$("#commentTextarea").focus();
								 	location.reload();
						     } });	
					}else{
						bootbox.alert({
							 message: "댓글 입력 중 오류사항이 발생했습니다. 관리자에게 문의하세요.",
							 locale: 'kr',
							 callback: function() {
							 		//$("#commentTextarea").focus();
						     } });
						return false;
					}
					
				}
			}) 
			
			
		}
		
		//댓글 수정
		//response cmmntSq 댓글 번호
		function commentUpdate(param){
			cmmntCntnt = $('#commentTextarea' + param).val();
			
			if(cmmntCntnt == null || cmmntCntnt == ''){
				bootbox.alert({
					 message: "수정할 내용을 입력해주세요.",
					 locale: 'kr',
					 callback: function() {
					 		$("#commentTextarea").focus();
				     } });
				return false;
			}else{
				//변경 사항이 있는지 확인
				for(i = 0; i < commentList.length; i++){
					if(commentList[i].cmmntSq == param){
						if(commentList[i].cmmntCntnt == cmmntCntnt){
							bootbox.alert({
								 message: "수정할 내용이 없습니다. 수정사항을 입력해주세요.",
								 locale: 'kr',
								 callback: function() {
								 		//$("#commentTextarea").focus();
							     } });
							
							return false;
						}
					}
				}
			}
				
			
			
			
			if(confirm('정말 수정하시겠습니까?')){
				$.ajax({
					type: "post",
					url: "/eep/comment/commentUpdate.do",
					data:{
						cmmntSq : param				//댓글 번호
						,brdSq : brdSq				//게시글 번호
						,emplySq : emplySq			//작성자 번호
						,cmmntCntnt : cmmntCntnt	//댓글 내용
					},
					success : function(data){
						if(data == 2){
							bootbox.alert({
								 message: "댓글 수정이 완료됬습니다.",
								 locale: 'kr',
								 callback: function() {
								 		//$("#commentTextarea").focus();
									 	location.reload();
							     } });
							
						}else{
							bootbox.alert({
								 message: "댓글 수정 중 오류사항이 발생했습니다. 관리자에게 문의하세요.",
								 locale: 'kr',
								 callback: function() {
								 		//$("#commentTextarea").focus();
							     } });
							return false;
						}
						
					}
				})
			}
			
			
		}
		
		//댓글 삭제
		//response cmmntSq 댓글 번호
		function commentDelete(param){
			cmmntCntnt = $('#commentTextarea' + param).val();
			
			if(confirm('정말 삭제하시겠습니까?')){
				$.ajax({
					type: "post",
					url: "/eep/comment/commentDelete.do",
					data:{
						cmmntSq : param				//댓글 번호
						,brdSq : brdSq				//게시글 번호
						,emplySq : emplySq			//작성자 번호
						,cmmntCntnt : cmmntCntnt	//댓글 내용
						},
					success : function(data){
						if(data == 2){
							bootbox.alert({
								 message: "댓글 삭제이 완료됬습니다.",
								 locale: 'kr',
								 callback: function() {
								 		//$("#commentTextarea").focus();
										location.reload();
							     } });
							
						}else{
							bootbox.alert({
								 message: "댓글 삭제 중 오류사항이 발생했습니다. 관리자에게 문의하세요.",
								 locale: 'kr',
								 callback: function() {
								 		//$("#commentTextarea").focus();
							     } });
							return false;
						}
						
					}
				})
			}
		}

    </script>
    
    
</body>

</html>