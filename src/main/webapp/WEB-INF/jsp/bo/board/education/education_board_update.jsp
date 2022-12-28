<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>

<%
	String brdSq = request.getParameter("brdSq"); 
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
	    		
	    			<input type="hidden" name="emplySq" id="emplySq" value="1">
	    			<input type="hidden" name="brdSq" id="brdSq" value="<%=brdSq%>">
	    			
	    			<div class="card-header p-2" style="border: 1px solid rgba(0,0,0,.125);background-color:#efefef">
	                 	<ul class="nav nav-pills">
		               		<li class="nav-item"><a class="sTitle" href="#" data-toggle="tab"><b>공지시항 수정 페이지</b></a></li>
		               	</ul>
					 </div>
					 
					 <div class="card">
					 
					 	<div class="card-body" style="background-color:#ffffff;">
					 	
					 		<div class="col-md-12" style="padding-left:50px;">
					 		
					 			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">제목</label>
					 			<div class="form-group row">
					 				
                    				<div class="col-sm-4">
                      					<input type="text" class="form-control sTitle classname"  id="brdTtl" name="brdTtl">
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
					 			
					 			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">사용여부</label>
                   				<div class="form-group row">
                     					<div style="padding-left:10px;float:left;">
										<input type="radio" id="u1" name="useYn" class="useYn" value="Y">
										<label for="u1" class="col-form-label sTitle">사용함</label>
									</div>
                     					<div style="padding-left:10px;float:left;">
                     						<input type="radio" id="u2" name="useYn" class="useYn" value="N">
										<label for="u2" class="col-form-label sTitle">사용안함</label>
									</div>
								</div>
					 			
					 			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">삭제여부</label>
                   				<div class="form-group row">
                     					<div style="padding-left:10px;float:left;">
										<input type="radio" id="d1" name="delYn" class="delYn" value="Y">
										<label for="d1" class="col-form-label sTitle">삭제함</label>
									</div>
                     					<div style="padding-left:10px;float:left;">
                     						<input type="radio" id="d2" name="delYn" class="delYn" value="N">
										<label for="d2" class="col-form-label sTitle">삭제안함</label>
									</div>
								</div>

								<label class="col-form-label sTitle LabelStyle" style="text-align: center;">내용</label>
					 			<div class="form-group row">
 
                    				<div class="col-sm-6">
                      					<div id="toolbar-container" style="display:none"></div>
                      					<!-- <div id="naverEditor" style="border: 1px solid #efefef;min-height:500px;padding:20px;">
                      					</div> -->
                      					<textarea rows="20" cols="40" id="naverEditor" name="naverEditor" readonly ></textarea>
                    				</div>	
					 			</div>

					 			<div class="form-group row">
                    				
                    				<div class="col-sm-4" style="text-align:right">
                    					<button type="button" class="btn btn-primary sTitle" onclick="noticeBoardList();">리스트로 돌아가기</button>
                    					<button type="button" class="btn btn-info sTitle" onclick="noticeUpdate();">수정</button>
                    					<button type="button" class="btn btn-danger sTitle" onclick="noticeBoardDetail();">뒤로</button>
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
	

   var oEditors = [];


   var emplySq     = $('#emplySq').val(); //직원순번
   var brdSq       = $('#brdSq').val();   //공지사항 순번
   var dataContent = {};				  //데이터 처리 리스트
   
   $(document).ready(function(){

		noticeboardDetailtData(brdSq);
		
   });
   
   function noticeboardDetailtData(brdSq) {
		
		$.ajax({
	           type: "post",
	           url: "/admin/board/notice/noticeBoardDetailData.do",
	           data: {
	        	   brdSq : brdSq
	            },
	           success: function(data) {
	        	    
	        	 dataContent = data.noticeBoardDetailData.noticeBoardDetailData[0];

	        	 var brdCntnt 	= dataContent.brdCntnt;
	        	 var brdTtl 	= dataContent.brdTtl;
	        	 var brdWrtr 	= dataContent.brdWrtr;
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
				             //내용초기화
				             oEditors.getById["naverEditor"].exec("SET_IR", [""]);
				           	 //DB내용 표현
				             oEditors.getById["naverEditor"].exec("PASTE_HTML", [castStr]);
				           	 //수정 불가 지정
				             //oEditors.getById["naverEditor"].exec("DISABLE_WYSIWYG");
				           	 //UI 비활성화
				             //oEditors.getById["naverEditor"].exec("DISABLE_ALL_UI");

				         },
				         fCreator: "createSEditor2"
				       })
				   });
				 

	        	 /* document.getElementById('naverEditor').innerHTML=castStr; */
	        	 $('#brdTtl').val(brdTtl);
	        	 $('#brdWrtr').val(brdWrtr);
	        	 $('#brdRegDt').val(brdRegDt);
	        	 
	        	 if(useYn == "Y"){
	        		 $("#u1").prop("checked", true);
	        	 }else{
	        		 $("#u2").prop("checked", true);
	        	 }
	        	 
	        	 if(delYn == "Y"){
	        		 $("#d1").prop("checked", true);
	        	 }else{
	        		 $("#d2").prop("checked", true);
	        	 }

	        	 //수정 이력 없을 시 유효성 체크
	        	 if(isEmpty(brdUpdtDt)){
	        		 $('#brdUpdtDt').val("자동 입력");
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
   
   function noticeUpdate() {
		
		var brdSq     = $("#brdSq").val();     
		var brdTtl  = $("#brdTtl").val(); 
		oEditors.getById["naverEditor"].exec("UPDATE_CONTENTS_FIELD", []);
		var brdCntnt = document.getElementById("naverEditor").value;
	    var useYn = $('input[name="useYn"]:checked').val();
	    var delYn  = $('input[name="delYn"]:checked').val();

	   	debugger;
	    
	   //잡지 제목
	   	 if(isEmpty(brdTtl)) {
	   		bootbox.alert({
					 message: "제목을 입력해 주세요.",
					 locale: 'kr',
					 callback: function() {
					 		$("#brdTtl").focus();
				     } });
				 return;
	   	 }
	   	 
	   	 //잡지 설명
	   	 if(isEmpty(brdCntnt)) {
	   		bootbox.alert({
					 message: "설명을 입력해 주세요.",
					 locale: 'kr',
					 callback: function() {
					 		$("#brdCntnt").focus();
				     } });
				 return;
	   	 }

		
		
		
		$.ajax({
	           type: "post",
	           url: "/admin/board/notice/noticeBoardUpdateData.do",
	           data: {
	        	   brdSq : brdSq,
	        	   brdTtl : brdTtl,
	        	   brdCntnt : brdCntnt,
	        	   useYn : useYn,
	        	   delYn : delYn
	           },
	           success: function(data) {
	        	   bootbox.alert({
						 message: "게시글이 수정 되었습니다.",
						 locale: 'kr',
						 callback: function() {
							 	location.href='/admin/board/notice/openNoticeBoardDetail.do?brdSq='+brdSq;
					     } });
			   },
	           error: function(error) {
	        	   var errorJson = JSON.stringify(error);
	               console.log(errorJson);
	           }
		})
	}
   
 
   
   function noticeBoardList() {
	   location.href='/admin/board/notice/openNoticeBoardList.do';
   }
   
   function noticeBoardDetail() {
	   location.href='/admin/board/notice/openNoticeBoardDetail.do?brdSq='+brdSq;
   }
   
	 //Input Box Null Check
   function isEmpty(str){
       
       if(typeof str == "undefined" || str == null || str == "")
           return true;
       else
           return false ;
   }
	 
	 
   function fn_SubBrdUpdatePage() {
	   
	   var brdSq = '<c:out value="${param.brdSq}" />';
	   var brdTypCd = '<c:out value="${param.brdTypCd}" />';
	   
	   location.href='/admin/board/boardUpdate?brdSq='+brdSq+'&brdTypCd='+brdTypCd;
	}
	 
   
   </script>
 
 
 
</body>
</html>