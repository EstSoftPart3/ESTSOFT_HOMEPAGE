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
	                	<h3 class="card-title bTitle"><b>자유 게시판 목록</b></h3>
	                	
		                <div class="card-tools">
		                  
		                  <div class="input-group input-group-sm" style="width: 800px;">
							
							<select class="custom-select bTitle" id="reOption">
	                          <option value="">-- 답글/원본 --</option>
	                          <option value="Orign">원본만</option>
	                          <option value="Rply">답글만</option>
	                        </select>
							
							<select class="custom-select bTitle" id="useSearchOption">
	                          <option value="">-- 사용여부 --</option>
	                          <option value="Y">사용O</option>
	                          <option value="N">사용X</option>
	                        </select>
							
							<select class="custom-select bTitle" id="delSearchOption">
	                          <option value="">-- 삭제여부 --</option>
	                          <option value="N">삭제X</option>
	                          <option value="Y">삭제O</option>
	                        </select>
							
		                    <select class="custom-select bTitle" id="searchOption">
	                          <option value="">-- 검색옵션 --</option>
	                          <option value="T">제목</option>
	                          <option value="W">작성자</option>
	                          <option value="C">내용</option>
	                          <option value="TWC">제목+작성자+내용</option>
	                        </select>
		                    <input type="text" name="table_search" id="searchKeyword" class="form-control float-right bTitle" placeholder="검색어" style="width:600px;" >
		
		                    <div class="input-group-append">
		                      <button type="button" data-action="memberSearch" data-id="search-id" class="btn btn-default" id="searchBtn"><i class="fas fa-search"></i></button>&nbsp;&nbsp;&nbsp;
		                    </div>
		                    <button type="button" class="btn btn-info sTitle" onclick="freedomBoardInsert();">게시판 작성</button>
		                  </div>
		                </div>
	              	
	              	</div>
					 
					 <div class="form-group row" >
                
					 	<div class="card-body" style="background-color:#ffffff;">
					 		<div class="col-sm-12">
					 			<div id="freedomBoardList" style="font-size:12px;"></div>
					 		</div>
					 	</div>
					 		
					 </div>
	    			
	    		</section>
		
	</div>
<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
<script type="text/javascript">
 		
        $(document).ready(function() {
        	freedomBoardList();
        });
        
        /* 게시판 입력 */
        function freedomBoardInsert() {
     	   
     	   location.href = "/admin/board/freedom/openFreedomBoardInsert.do";
        }
        
        $("#reOption").on("change", function(){
        	var reOption = $("#reOption :selected").val();
        	freedomBoardList();
        });
        
        $("#useSearchOption").on("change", function(){
        	var useSearchOption = $("#useSearchOption :selected").val();
        	freedomBoardList();
        });
        
        $("#delSearchOption").on("change", function(){
        	var delSearchOption = $("#delSearchOption :selected").val();
        	freedomBoardList();
        });
        
        $("#searchBtn").on('click', function(){

   			var searchOption = $("#searchOption :selected").val();
			var searchKeyword = $("#searchKeyword").val();
		
		   	 if(isEmpty(searchOption)) {
		   		bootbox.alert({
						 message: "검색 옵션을 선택해주세요",
						 locale: 'kr',
						 callback: function() {
						 		$("#searchOption").focus();
					     } });
					 return;
		   	 }else if(isEmpty(searchKeyword)) {
			   		bootbox.alert({
						 message: "검색어를 입력하세요.",
						 locale: 'kr',
						 callback: function() {
						 		$("#searchKeyword").focus();
					     } });
					 return;
		   	 }else{
		   		freedomBoardList();
			 }
		});
        
        /* 게시판 리스트 */
        function freedomBoardList(){
     	   
        	var reOption = $("#reOption :selected").val();
        	var useSearchOption = $("#useSearchOption :selected").val();
			var delSearchOption = $("#delSearchOption :selected").val();
   			var searchOption = $("#searchOption :selected").val();
			var searchKeyword = $("#searchKeyword").val();
     	  	
     	  	let params = {
     			searchOption : searchOption,
     			searchKeyword : searchKeyword,
     			reOption : reOption,
     			useSearchOption : useSearchOption,
     			delSearchOption : delSearchOption
     		}
        	
     	   $("#freedomBoardList").jsGrid({
     		   locale:"ko",
     	       height: "700px",
     	       width: "100%",
     	       inserting: false,
     	       editing: false,
     	       sorting: false,
     	       paging: false,
     	       autoload: true,
     	       pageSize: 10,
     	       gridview : true,
     	      
     	       deleteConfirm: "정말 삭제 하시겠습니까?",
     	       controller: {
     	           loadData: function (filter) {
     	        	   var d = $.Deferred();
     	               $.ajax({
     	      	    	 type: "post",
     	    	    	 url: "/admin/board/freedom/freedomBoardListData.do",
     	    	         data: params,
     	    	         dataType: "json"
     	    	      }).done(function(response) {
     	    	    	 //d.resolve(response.boardData.boardInfo);
     	    	    	 
     	    	    	 d.resolve($.map(response.freedomBoardData.freedomBoardInfo, function (item, itemIndex) {
                              
     	    	    		 var rSize = response.freedomBoardData.freedomBoardInfo.length - itemIndex;
     		    	    		    	    		 
     	    	    		 return $.extend(item, { "Index": rSize }); 
     	    	    		 
                          }));
     	    	    	 
     	    	      });
     	               return d.promise();
     	           }
     	       },
     	       fields: [
     	    	   { name: "brdSq", title: "글번호", type: "number", width: 10, align: "center", },
     	    	   { name: "brdTtl", title:"제목", type: "text", width: 100,align:"center",width:100 , visible: true},
     	    	   { name: "brdRegDt"	,title:"작성일", type: "text", width: 30,align:"center" ,width:30, visible: true},
     	    	   { name: "brdWrtr"	,title:"작성자", type: "text", width: 30,align:"center" ,width:30, visible: true}
     	    	   /* { name: "brdCntnt"	,title:"내용", type: "text", width: 150,align:"center" ,width:100, visible: true},
     	    	   { name: "brdRegDt",id:"brdTitle", title:"제목", type: "text", width: 300,align:"left", visible: true, key:true},
     	    	   { name: "brdUpdtDt",title:"게시판종류", type: "text", width: 200,align:"center",width:100 , visible: false},
     	    	   { name: "regMbrSq",title:"등록회원순번", type: "text", width: 200,align:"center",width:100 , visible: false},
     	    	   { name: "regDt",title:"등록일시", type: "text", width: 200,align:"center",width:100 , visible: true},
     	    	   { name: "updtMbrSq",title:"수정회원순번", type: "text", width: 200,align:"center",width:100 , visible: false},
     	    	   { name: "updtDt",title:"수정일시", type: "text", width: 200,align:"center",width:100 , visible: false},
     	    	   { name: "delYn",title:"삭제여부", type: "text", width: 200,align:"center",width:100 , visible: false} */
     	       ],
     	       rowClick: function(args) {
     	       	   var getData = args.item.brdSq;
     	           fn_SubBrdPage(getData);
     	       }

     	   });
     		   /* $("#noticeBoardList").jsGrid("fieldOption", "1", "visible", true);
     		   $("#noticeBoardList").jsGrid("fieldOption", "2", "visible", false); */
        }
        
        function fn_SubBrdPage(getData) {
     	   /* var brdTypCd = $('#brdTypCd').val(); */
     	   location.href='/admin/board/freedom/openFreedomBoardDetail.do?brdSq='+getData;
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