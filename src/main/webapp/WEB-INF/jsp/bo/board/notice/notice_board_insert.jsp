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

	    			<input type="hidden">
	    			
	    			<div class="card-header p-2" style="border: 1px solid rgba(0,0,0,.125);background-color:#efefef">
	                 	<ul class="nav nav-pills">
		               		<li class="nav-item"><a class="sTitle" href="#" data-toggle="tab"><b>공지사항 게시판 등록</b></a></li>
		               	</ul>
					 </div>
					 
					 <div class="card">
					 
					 	<div class="card-body" style="background-color:#ffffff;">
					 	
					 		<div class="col-md-9" style="padding-left:50px;">
		
					 			<div class="form-group row">
					 				<label class="col-form-label sTitle LabelStyle" style="text-align: center;">제&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;목</label>
                    				<div class="col-sm-5">
                      						<input type="text" class="form-control sTitle classname">
                    				</div>
					 			</div>
					 			
					 			<div class="form-group row">
					 				<label class="col-form-label sTitle LabelStyle" style="text-align: center;">작성자</label>
                    				<div class="col-sm-5">
                      						<input type="text" class="form-control sTitle classname" readonly>
                    				</div>
                    				
					 			</div>
					 			
					 			<div class="form-group row">
					 				<label class="col-form-label sTitle LabelStyle" style="text-align: center;">사용여부</label>
                    				<div class="col-sm-3">
                      					<div style="padding-left:10px;float:left;">
											<input type="radio" id="z1" name="useYn">
											<label for="z1" class="col-form-label sTitle">사용함</label>
										</div>
                      					<div style="padding-left:10px;float:left;">
                      						<input type="radio" id="z2" name="useYn">
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
                      						<button type="button" class="btn btn-primary sTitle">리스트로 돌아가기</button>
                      						<button type="button" class="btn btn-info sTitle">저장</button>
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