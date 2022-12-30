<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>

<style type="text/css">
	#toolbar-container{ position: sticky; top: 185px;}
</style>

<body class="hold-transition sidebar-mini">

	
	<div class="wrapper">
	
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		
		 <div class="content-wrapper">
		    
		     	<!-- Main content -->
	    		<section class="content">

	    			<input type="hidden" name="emplySq" id="emplySq" value="1">
	    			
	    			<div class="card-header p-2" style="border: 1px solid rgba(0,0,0,.125);background-color:#efefef">
	                 	<ul class="nav nav-pills">
		               		<li class="nav-item"><a class="sTitle" href="#" data-toggle="tab"><b>자유 게시판 등록</b></a></li>
		               	</ul>
					 </div>
					 
					 <div class="card">
					 
					 	<div class="card-body" style="background-color:#ffffff;">
					 	
					 		<div class="col-md-9" style="padding-left:50px;">
		
					 			<div class="form-group row">
					 				<label class="col-form-label sTitle LabelStyle" style="text-align: center;">제&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;목</label>
                    				<div class="col-sm-5">
                      						<input type="text" class="form-control sTitle classname"  id="brdTtl" name="brdTtl" value="">
                    				</div>
					 			</div>
					 			
					 			<div class="form-group row">
					 				<label class="col-form-label sTitle LabelStyle" style="text-align: center;">작성자</label>
                    				<div class="col-sm-5">
                      						<input type="text" class="form-control sTitle classname"  id="brdWrtr" name="brdWrtr" value="관리자" readonly>
                    				</div>
                    				
					 			</div>
					 			
					 			<div class="form-group row">
					 				<label class="col-form-label sTitle LabelStyle" style="text-align: center;">사용여부</label>
                    				<div class="col-sm-3">
                      					<div style="padding-left:10px;float:left;">
											<input type="radio" id="z1" name="useYn" class="useYn" value="Y" checked>
											<label for="z1" class="col-form-label sTitle">사용함</label>
										</div>
                      					<div style="padding-left:10px;float:left;">
                      						<input type="radio" id="z2" name="useYn" class="useYn" value="N">
											<label for="z2" class="col-form-label sTitle">사용안함</label>
										</div>
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
                    				<div class="col-sm-6" style="text-align:right">
                      						<button type="button" class="btn btn-primary sTitle" onclick="freedomBoardList();">리스트로 돌아가기</button>
                      						<button type="button" class="btn btn-info sTitle" onclick="freedomBoardInsert();">저장</button>
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
   
   
   
   function freedomBoardInsert() {
	
	var emplySq     = '1'     							//회원 순번
	var brdTypCd 	= 'FD'  							//게시판 구분 코드
   	var brdTtl  	= $("#brdTtl").val();  				//게시판 제목
   	var brdWrtr  	= $("#brdWrtr").val();  			//게시판 작성자
   	var useYn = $("input[name='useYn']:checked").val(); //사용여부
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
   	 if(brdCntnt == "<p>&nbsp;</p>") {
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
	           url: "/admin/board/freedom/freedomBoardInsertData.do",
	           data: {
	        	   emplySq : emplySq,
	        	   brdTypCd : brdTypCd,
	        	   brdTtl : brdTtl,
	        	   brdCntnt : brdCntnt,
	        	   brdWrtr : brdWrtr,
	        	   useYn : useYn
	           },
	           success: function(data) {
	        	   bootbox.alert({
						 message: "게시글이 저장 되었습니다.",
						 locale: 'kr',
						 callback: function() {
							 		location.href='/admin/board/freedom/openFreedomBoardList.do';
					     } });
			   },
	           error: function(error) {
	        	   var errorJson = JSON.stringify(error);
	               console.log(errorJson);
	           }
		})
	}
   
   function freedomBoardList() {
	   location.href='/admin/board/freedom/openFreedomBoardList.do';
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