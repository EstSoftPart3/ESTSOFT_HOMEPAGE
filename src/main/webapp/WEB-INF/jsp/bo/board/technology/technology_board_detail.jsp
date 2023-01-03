<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>

<%
	String brdSq = request.getParameter("brdSq");
	String brdReReef = request.getParameter("brdReReef");
%>

<body class="hold-transition sidebar-mini">

<style>
	.editable-container,
	.toolbar-container {
		position: relative;
		border: 1px solid #ddd;
		background: #eee;
	}

	.toolbar-container {
		padding: 1em;
	}

	.editable-container {
		padding: 3em;
		overflow-y: scroll;
		max-height: 500px;
	}

	.editable-container .document-editor__editable.ck-editor__editable {
		min-height: 21cm;
		padding: 2em;
		border: 1px #D3D3D3 solid;
		border-radius: var(--ck-border-radius);
		background: white;
		box-shadow: 0 0 5px rgba(0, 0, 0, 0.1);
	}
</style>

	<div class="wrapper">
	
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		
		 <div class="content-wrapper">
		    
		     	<!-- Main content -->
	    		<section class="content">
	    		
	    			<input type="hidden" name="emplySq" id="emplySq" value="${loginInfo.loginInfo[0].emplySq}">
	    			<input type="hidden" name="brdSq" id="brdSq" value="<%=brdSq%>">
	    			<input type="hidden" name="brdReRep" id="brdReRep" value="">
	    			<input type="hidden" name="brdReLev" id="brdReLev" value="">
	    			<input type="hidden" name="brdReOrd" id="brdReOrd" value="">
	    			
	    			<div class="card-header p-2" style="border: 1px solid rgba(0,0,0,.125);background-color:#efefef">
	                 	<ul class="nav nav-pills">
		               		<li class="nav-item"><a class="sTitle" href="#" data-toggle="tab"><b>기술문의 게시판 상세 페이지</b></a></li>
		               	</ul>
					 </div>
					 
					 <div class="card">
					 
					 	<div class="card-body" style="background-color:#ffffff;">
					 	
					 		<div class="col-md-12" style="padding-left:50px;">
					 		
					 			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">제목</label>
					 			<div class="form-group row">
					 				
                    				<div class="col-sm-4">
                      					<input type="text" class="form-control sTitle classname"  id="brdTtl" name="brdTtl" readonly >
                    				</div>
					 			</div>

								<label class="col-form-label sTitle LabelStyle" style="text-align: center;">작성자</label>
					 			<div class="form-group row">
					 				
                    				<div class="col-sm-4">
                      					<input type="text" class="form-control sTitle classname"  id="brdWrtr" name="brdWrtr" readonly >
                    				</div>
					 			</div>
					 			
					 			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">등록일</label>
					 			<div class="form-group row">
					 				
                    				<div class="col-sm-4">
                      					<input type="text" class="form-control sTitle classname"  id="brdRegDt" name="brdRegDt" readonly >
                    				</div>
					 			</div>
					 			
					 			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">수정일</label>
					 			<div class="form-group row">
					 				
                    				<div class="col-sm-4">
                      					<input type="text" class="form-control sTitle classname"  id="brdUpdtDt" name="brdUpdtDt" readonly >
                    				</div>
					 			</div>
					 			
					 			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">사용유무</label>
					 			<div class="form-group row">
					 				
                    				<div class="col-sm-4">
                      					<input type="text" class="form-control sTitle classname"  id="useYn" name="useYn" readonly >
                    				</div>
					 			</div>
					 			
					 			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">삭제유무</label>
					 			<div class="form-group row">
					 				
                    				<div class="col-sm-4">
                      					<input type="text" class="form-control sTitle classname"  id="delYn" name="delYn" readonly >
                    				</div>
					 			</div>

								<div class="form-group row">
					 			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">내용</label>
                    				<div class="col-sm-12">
                      					<!-- <input type="text" class="form-control sTitle classname"  id="brdContent" name="brdContent" value=""> -->
                    					<div id="toolbar-container" style="z-index:9999"></div>
                    					<textarea rows="20" cols="40" id="naverEditor" name="naverEditor"></textarea>
                    				</div>            				
					 			</div>

					 			<div class="form-group row">
                    				
                    				<div class="col-sm-4" style="text-align:right">
                    					<button type="button" class="btn btn-primary sTitle" onclick="technologyBoardList();">리스트로 돌아가기</button>
                    					<button type="button" class="btn btn-primary sTitle" onclick="technologyBoardRplyInsertPage();">답글</button>
                    					<button type="button" class="btn btn-info sTitle" onclick="technologyUpdatePage();">수정</button>
                    					<button type="button" class="btn btn-danger sTitle" onclick="technologyBoardDelete();">삭제</button>
                    				</div>
                    				
                    			</div>
					 		</div>
					 	</div>


					 </div>
					
	    		</section>
	    		
		 </div>
		
	</div>

   
   <%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
   
   <script>
	

 


   var emplySq     = $('#emplySq').val(); //직원순번
   var brdSq       = $('#brdSq').val();   //공지사항 순번
   var dataContent = {};				  //데이터 처리 리스트
   
   $(document).ready(function(){

	   technologyBoardDetailData(brdSq);
		
   });
   
   function technologyBoardDetailData(brdSq) {
		
		$.ajax({
	           type: "post",
	           url: "/admin/board/technology/technologyBoardDetailData.do",
	           data: {
	        	   brdSq : brdSq
	            },
	           success: function(data) {
	        	    
	        	 dataContent = data.technologyBoardDetailData.technologyBoardDetailData[0];

	        	 var brdCntnt 	= dataContent.brdCntnt;
	        	 var brdTtl 	= dataContent.brdTtl;
	        	 var brdWrtr 	= dataContent.brdWrtr;
	        	 var brdReRep 	= dataContent.brdReRep;
	        	 var brdReLev 	= dataContent.brdReLev;
	        	 var brdReOrd 	= dataContent.brdReOrd;
	        	 var brdRegDt	= dataContent.brdRegDt;
	        	 var brdUpdtDt	= dataContent.brdUpdtDt;
	        	 var useYn 		= dataContent.useYn;
	        	 var delYn 		= dataContent.delYn;
	        	 
	        	 

	        	 
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
	        	 $('#useYn').val(useYn);
	        	 $('#delYn').val(delYn);
	        	 //수정 이력 없을 시 유효성 체크
	        	 if(isEmpty(brdUpdtDt)){
	        		 $('#brdUpdtDt').val("최근 수정한 이력 없음");
	        	 }else{
	        		 $('#brdUpdtDt').val(brdUpdtDt);
	        	 }

	        	 

	           },
	           error: function(error) {
	        	   var errorJson = JSON.stringify(error);
	               console.log(errorJson);
	           }
		})
	}
   
  
   function technologyBoardDelete() {
   
	   
	   if(confirm('정말 삭제 하시겠습니까?')) {
		   
		   $.ajax({
	           type: "post",
	           url: "/admin/board/technology/technologyBoardDeleteData.do",
	           data: {
	        	   brdSq : brdSq,
	           },
	           success: function(data) {
	        	   bootbox.alert({
						 message: "삭제 되었습니다.",
						 locale: 'kr',
						 callback: function() {
							 location.href='/admin/board/technology/openTechnologyBoardList.do';	
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
	   
	  
   }
   
   function technologyBoardList() {
	   location.href='/admin/board/technology/openTechnologyBoardList.do';
   }
   
	 //Input Box Null Check
   function isEmpty(str){
       
       if(typeof str == "undefined" || str == null || str == "")
           return true;
       else
           return false ;
   }
	 
	 
   function technologyUpdatePage() {
	   
	   location.href='/admin/board/technology/openTechnologyBoardUpdate.do?brdSq='+brdSq;
	}
   
	function technologyBoardRplyInsertPage() {
	   
		var brdReRep = $('#brdReRep').val();
   	 	var brdReLev = $('#brdReLev').val();
   	 	var brdReOrd = $('#brdReOrd').val();
		
	   	location.href='/admin/board/technology/openTechnologyBoardReplyInsert.do?brdSq='+brdSq+'&brdReRep='+brdReRep+'&brdReLev='+brdReLev+'&brdReOrd='+brdReOrd;
	}
	 
   
   </script>
 
 
 
</body>
</html>