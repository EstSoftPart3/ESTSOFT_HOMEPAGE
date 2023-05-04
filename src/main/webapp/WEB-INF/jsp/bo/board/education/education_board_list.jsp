<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>

<body class="hold-transition sidebar-mini">

	<div class="wrapper">
	
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		
		 <div class="content-wrapper">
		    
		     	<!-- Main content -->
	    		<section class="content">
	    			
					<div class="card-header">
	                	<h3 class="card-title bTitle"><b>교육일정 게시판 목록</b></h3>
	                	
		                <div class="card-tools">
		                  
		                  <div class="input-group input-group-sm" style="width: 700px;">
							
							<select class="custom-select bTitle">
	                          <option value="">-- 사용여부 --</option>
	                          <option value="Y">사용O</option>
	                          <option value="N">사용X</option>
	                        </select>
							
							<select class="custom-select bTitle">
	                          <option value="">-- 삭제여부 --</option>
	                          <option value="N">삭제X</option>
	                          <option value="Y">삭제O</option>
	                        </select>
							
		                    <select class="custom-select bTitle">
	                          <option value="">-- 검색옵션 --</option>
	                          <option value="T">제목</option>
	                          <option value="W">작성자</option>
	                          <option value="C">내용</option>
	                          <option value="I">강사</option>
	                          <option value="TWCI">제목+작성자+내용+강사</option>
	                        </select>
		                    <input type="text" name="table_search" id="searchKeyword" class="form-control float-right bTitle" placeholder="검색어" style="width:600px;" >
		
		                    <div class="input-group-append">
		                      <button type="button" data-action="memberSearch" data-id="search-id" class="btn btn-default" id="searchBtn"><i class="fas fa-search"></i></button>&nbsp;&nbsp;&nbsp;
		                    </div>
		                    <button type="button" class="btn btn-info sTitle">게시판 작성</button>
		                  </div>
		                </div>
	              	
	              	</div>
					 
					 <div class="form-group row" >
                
					 	<div class="card-body" style="background-color:#ffffff;">
					 		<div class="col-sm-12">
					 			<div id="educationBoardList" style="font-size:12px;"></div>
					 		</div>
					 	</div>
					 		
					 </div>
	    			
	    		</section>
		
	</div>
<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
<script type="text/javascript">
 		
</script>

</body>
</html>