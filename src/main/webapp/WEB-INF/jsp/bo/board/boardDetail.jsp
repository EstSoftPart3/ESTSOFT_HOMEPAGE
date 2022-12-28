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
		               		<li class="nav-item"><a class="sTitle" href="#" data-toggle="tab"><b>공지시항 상세 페이지</b></a></li>
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

								<label class="col-form-label sTitle LabelStyle" style="text-align: center;">내용</label>
					 			<div class="form-group row">
 
                    				<div class="col-sm-6">
                      					<div id="toolbar-container" style="display:none"></div>
                      					<div id="naverEditor" style="border: 1px solid #efefef;min-height:500px;padding:20px;">
                      					</div>
                    				</div>	
					 			</div>

					 			<div class="form-group row">
                    				
                    				<div class="col-sm-6" style="text-align:right">
                    					<button type="button" class="btn btn-info sTitle" onclick="boardList();">리스트로 돌아가기</button>
                    					<button type="button" class="btn btn-info sTitle" onclick="fn_SubBrdUpdatePage();">수정</button>
                    					<button type="button" class="btn btn-info sTitle" onclick="boardDelete();">삭제</button>
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
	

   //네이버 에디터 임포트
   var oEditors = [];
   
   $(function(){
      nhn.husky.EZCreator.createInIFrame({
         oAppRef: oEditors,
         elPlaceHolder: "editor",
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
				 castStr = castStr.replaceAll("true","false"); //Table 수정 금지

	        	 document.getElementById('naverEditor').innerHTML=castStr;
	        	 $('#brdTtl').val(brdTtl);
	        	 $('#brdWrtr').val(brdWrtr);
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
   
  
   function boardDelete() {
   
	   
	   if(confirm('정말 삭제 하시겠습니까?')) {
		   
		   $.ajax({
	           type: "post",
	           url: "boardDeleteData",
	           data: {
	        	   brdTypCd : brdTypCd,
	        	   brdSq : brdSq,

	           },
	           success: function(data) {
	        	   bootbox.alert({
						 message: "삭제 되었습니다.",
						 locale: 'kr',
						 callback: function() {
							 
							 	if(brdTypCd == 'NT'){
							 		location.href='/admin/board/boardList?brdTypCd=NT';
							 	}else{
							 		location.href='/admin/board/boardList?brdTypCd=FA';
							 	}
							 
						 		
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
   
   function boardList() {
	   location.href='/admin/board/notice/openNoticeBoardList.do';
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