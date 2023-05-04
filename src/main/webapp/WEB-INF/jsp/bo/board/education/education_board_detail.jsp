<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>


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
	    		
	    			<input type="hidden">
	    			<input type="hidden">
	    			
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
                      					<input type="text" class="form-control sTitle classname" readonly >
                    				</div>
					 			</div>

								<label class="col-form-label sTitle LabelStyle" style="text-align: center;">작성자</label>
					 			<div class="form-group row">
					 				
                    				<div class="col-sm-4">
                      					<input type="text" class="form-control sTitle classname" readonly >
                    				</div>
					 			</div>
					 			
					 			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">강사</label>
					 			<div class="form-group row">
					 				
                    				<div class="col-sm-4">
                      					<input type="text" class="form-control sTitle classname" readonly >
                    				</div>
					 			</div>
					 			
					 			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">교육일</label>
					 			<div class="form-group row">
					 				
                    				<div class="col-sm-4">
                      					<input type="text" class="form-control sTitle classname" readonly >
                    				</div>
					 			</div>
					 			
					 			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">등록일</label>
					 			<div class="form-group row">
					 				
                    				<div class="col-sm-4">
                      					<input type="text" class="form-control sTitle classname" readonly >
                    				</div>
					 			</div>
					 			
					 			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">수정일</label>
					 			<div class="form-group row">
					 				
                    				<div class="col-sm-4">
                      					<input type="text" class="form-control sTitle classname" readonly >
                    				</div>
					 			</div>
					 			
					 			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">사용유무</label>
					 			<div class="form-group row">
					 				
                    				<div class="col-sm-4">
                      					<input type="text" class="form-control sTitle classname" readonly >
                    				</div>
					 			</div>
					 			
					 			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">삭제유무</label>
					 			<div class="form-group row">
					 				
                    				<div class="col-sm-4">
                      					<input type="text" class="form-control sTitle classname" readonly >
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

								<!-- <label class="col-form-label sTitle LabelStyle" style="text-align: center;">내용</label>
					 			<div class="form-group row">
 
                    				<div class="col-sm-6">
                      					<div id="toolbar-container" style="display:none"></div>
                      					<div id="naverEditor" style="border: 1px solid #efefef;min-height:500px;padding:20px;">
                      					</div>
                      					<textarea rows="20" cols="40" id="naverEditor" name="naverEditor" readonly ></textarea>
                    				</div>	
					 			</div> -->

					 			<div class="form-group row">
                    				
                    				<div class="col-sm-4" style="text-align:right">
                    					<button type="button" class="btn btn-primary sTitle">리스트로 돌아가기</button>
                    					<button type="button" class="btn btn-info sTitle">수정</button>
                    					<button type="button" class="btn btn-danger sTitle">삭제</button>
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
   
</script>
 
 
 
</body>
</html>