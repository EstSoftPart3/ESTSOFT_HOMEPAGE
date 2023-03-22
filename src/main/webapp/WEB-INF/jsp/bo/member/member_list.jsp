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
	                	<h3 class="card-title bTitle"><b>직원 목록</b></h3>
	                	
		                <div class="card-tools">
		                  
		                  <div class="input-group input-group-sm" style="width: 700px;">
							
		                    <select class="custom-select bTitle" id="memberGubun">
	                          <option value="" selected>-- 권한 --</option>
	                          <option value="1">일반</option>
	                          <option value="2">관리자</option>
	                        </select>
	                        
	                        <select class="custom-select bTitle" id="searchGubun">
	                          <option value="">-- 검색옵션 --</option>
	                          <option value="mbrNm">이름</option>
	                          <option value="mbrId">아이디</option>
	                          <option value="mbrEmail">이메일</option>
	                          <option value="mbrPhNum">휴대전화</option>
	                        </select>
	                        
		                    <input type="text" name="table_search" id="searchWord" class="form-control float-right bTitle" placeholder="검색어" style="width:600px;" maxlength="50" >
		
		                    <div class="input-group-append">
		                      <button type="button" data-action="memberSearch" data-id="search-id" class="btn btn-default" id="searchBtn"><i class="fas fa-search"></i></button>&nbsp;&nbsp;&nbsp;
		                    </div>
		                    <button type="button" class="btn btn-info sTitle" onclick="memberInsert();">직원 등록</button>
		                  </div>
		                </div>
	              	
	              	</div>
	              	
					 <div class="form-group row" >
                
					 	<div class="card-body" style="background-color:#ffffff;">
					 		<div class="col-sm-12">
						 		<div class="card-body table-responsive p-0 " style="height: 850px;font-size:11px;" >
									<table class="table table-bordered exportToExcel" >
										<thead>
											<tr align="center" style="background-color:#efefef;" >
												<th>권한</th>
												<th>이름</th>
												<th>아이디</th>
												<th>이메일</th>
												<th>휴대전화</th>
												<th>등록일</th>
											</tr>
										</thead>
										<tbody id="dataList" >
												                   		                    
										</tbody>
									</table>
					            </div>
					 			
					 		</div>
					 	</div>
					 		
					 </div>
	    			
	    		</section>
		
	</div>
<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
<script type="text/javascript">
 		
var dataList = {};

	$(document).ready(function(){
		searchMemberData();
	});
	
	//직원 리스트 호출
	function searchMemberData(page) {
		$.ajax({
	           type: "post",
	           url: "/admin/member/memberSearch.do",
	           data: {
	        	   delYn : 'N',
	        	   memberGubun : $("#memberGubun").val(),
	        	   searchGubun : $("#searchGubun").val(),
	        	   searchWord : $("#searchWord").val()
	           },
	           success: function(data) {
	        	   
	        	dataList = data.memberData.memberList;
	        	
	        	if(dataList){
	        	   var strHtml = '';
	        	   for(i=0; i<dataList.length; i++){
	        		   	
		        	   	strHtml += '<tr align="center" style="height:20px;">';
		        		strHtml += '<td>'+ dataList[i].mbrAuthCd + '</td>';   			        					        		
		        	   	strHtml += '<td style="cursor:pointer; color: #0000ff;"><a href="javascript:void(0)" onclick="memberContent('+ dataList[i].mbrSq +')">'+ dataList[i].mbrNm +'</td>';
		        	 	strHtml += '<td>'+ dataList[i].mbrId +'</td>';
		        	 	strHtml += '<td>'+ dataList[i].mbrEmail +'</td>';
		        	 	strHtml += '<td>'+ dataList[i].mbrPhNum +'</td>';
		        	 	strHtml += '<td>'+ dataList[i].regDt +'</td>';
		        	 	
		        	   	strHtml += '</tr>';
		           }
	        	   $("#dataList").empty();
	        	   $("#dataList").append(strHtml).trigger("create");
	        	} else {
	        		strHtml += '<tr align="center" style="height:20px;">';
	        		strHtml += '조회된 데이터가 없습니다. 다시 조회 해주세요.'
	        		strHtml += '</tr>';
	        	    $("#dataList").empty();
		        	$("#dataList").append(strHtml).trigger("create");
	        	}
			
	           },
	           error: function(error) {
	        	   var errorJson = JSON.stringify(error);
	               console.log(errorJson);
	           }
		})
	}
	
	//검색 input Box enter Key Press
	$("#searchWord").on("keydown",function(key){         
		if(key.keyCode==13) {             
			searchMemberData();   
		}     
	});
	
	//검색 클릭
	$("#searchBtn").on('click', function(){
		var memberGubun = $("#memberGubun").val(); 
		var searchGubun = $("#searchGubun").val();
	    var searchWord = $("#searchWord").val();

	    searchMemberData();
	 
	});
	
	//직원 상세정보 이동
	function memberContent(mbrSq) {
		
		let param = {
			mbrSqParam : mbrSq
		}
	
		var contentUrl = "/admin/member/memberContent.do";
		postForm(contentUrl, param);
		
	}
	
	function postForm(path, params, method) {
	    method = method || 'post';

	    var form = document.createElement('form');
	    form.setAttribute('method', method);
	    form.setAttribute('action', path);

	    for (var key in params) {
	        if (params.hasOwnProperty(key)) {
	            var hiddenField = document.createElement('input');
	            hiddenField.setAttribute('type', 'hidden');
	            hiddenField.setAttribute('name', key);
	            hiddenField.setAttribute('value', params[key]);

	            form.appendChild(hiddenField);
	        }
	    }

	    document.body.appendChild(form);
	    form.submit();
	}
	
	//직원 등록 이동
	function memberInsert() {
		location.href = '/admin/member/memberInsert.do';	
	}
	
	
    
</script>

</body>
</html>