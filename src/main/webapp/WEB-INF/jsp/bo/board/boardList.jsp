<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>

<%-- <%
	//게시판 타입 : 공지사항 (NT), 일반(GN)
	String brdTypCd = request.getParameter("brdTypCd"); 
	
	String brdName; 
	
	if(brdTypCd.equals("NT")) {
		brdName = "공지사항"; 
	} else {
		brdName = "자주하는질문"; 
	}

%> --%>


<body class="hold-transition sidebar-mini">

	<div class="wrapper">
	
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		
		 <div class="content-wrapper">
		    
		     	<!-- Main content -->
	    		<section class="content">
	    			<%-- <input type="hidden" name="brdTypCd" id="brdTypCd" value="<%=brdTypCd%>"> --%>
	    			
	    			<div class="card-header p-2" style="border: 1px solid rgba(0,0,0,.125);background-color:#efefef">
	                 	<ul class="nav nav-pills">
		               		<%-- <li class="nav-item"><a class="sTitle" href="#" data-toggle="tab"><b><%=brdName%></b></a></li> --%>
		               	</ul>
					 </div>
					 
					 <div class="card">
					 
					 	<div class="card-body" style="background-color:#ffffff;">
					 		<div class="col-sm-9">
					 			<div id="boardList" style="font-size:12px;"></div>
					 		</div>
					 	</div>
					 	
					 	<div class="form-group row" >
                    		<div class="col-sm-9" style="text-align:right;right:15px;">
                    			<button type="button" class="btn btn-info sTitle" onclick="boardInput();">입력</button>
					    	</div>
                    	</div>
					 		
					 </div>
	    			
	    		</section>
	    		
		 </div>
		
	</div>
<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
<script type="text/javascript">
 		
        $(document).ready(function() {
     	   boardList();
        });
        
        /* 게시판 입력 */
        function boardInput() {
     	   var brdTypCd = $('#brdTypCd').val();
     	   console.log("brdTypCd :"+brdTypCd);
     	   
     	   location.href = "/admin/board/boardWrite?brdTypCd="+brdTypCd;
        }
        
        
        /* 게시판 리스트 */
        function boardList(){
        
     	   var brdTypCd = $('#brdTypCd').val();
     	   
     	   console.log("brdTypCd :"+brdTypCd);
     	   
     	  
     	  
     	   
     	   let params = {
     			brdTypCd : brdTypCd
     		}
     	   
     	   $("#boardList").jsGrid({
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
     	    	    	 url: "/admin/board/boardListData.do",
     	    	         data: params,
     	    	         dataType: "json"
     	    	      }).done(function(response) {
     	    	    	 //d.resolve(response.boardData.boardInfo);
     	    	    	
     	    	    	 
     	    	    	 d.resolve($.map(response.boardData.boardInfo, function (item, itemIndex) {
                              
     	    	    		 var rSize = response.boardData.boardInfo.length - itemIndex;
     		    	    		    	    		 
     	    	    		 return $.extend(item, { "Index": rSize });
                          }));
     	    	    	 
     	    	      });
     	               return d.promise();
     	           }
     	       },
     	       fields: [
     	    	   
     	    	   { name: "brdSq", title: "글번호", type: "number", width: 30, align: "center", },
     	    	   { name: "brdTtl",title:"제목", type: "text", width: 200,align:"center",width:100 , visible: true},
     	    	   { name: "brdCntnt"	,title:"내용", type: "text", width: 150,align:"center" ,width:100, visible: true},
     	    	   { name: "brdWrtr"	,title:"작성자", type: "text", width: 150,align:"center" ,width:100, visible: true}/* ,
     	    	   { name: "brdTitle",id:"brdTitle", title:"제목", type: "text", width: 300,align:"left", visible: true, key:true},
     	    	   { name: "brdTypCd",title:"게시판종류", type: "text", width: 200,align:"center",width:100 , visible: false},
     	    	   { name: "regMbrSq",title:"등록회원순번", type: "text", width: 200,align:"center",width:100 , visible: false},
     	    	   { name: "regDt",title:"등록일시", type: "text", width: 200,align:"center",width:100 , visible: true},
     	    	   { name: "updtMbrSq",title:"수정회원순번", type: "text", width: 200,align:"center",width:100 , visible: false},
     	    	   { name: "updtDt",title:"수정일시", type: "text", width: 200,align:"center",width:100 , visible: false},
     	    	   { name: "delYn",title:"삭제여부", type: "text", width: 200,align:"center",width:100 , visible: false} */
     	       ],
     	       rowClick: function(args) {
     	           //console.log(args)
     	       	   var getData = args.item.brdSq;
     	       	   console.log("getData :"+getData);
     	           fn_SubBrdPage(getData);

                }
     	       
     	      

     	   });
     	   
      		if(brdTypCd == "FA") {
     		   
     		   $("#boardList").jsGrid("fieldOption", "1", "visible", true);
     		   $("#boardList").jsGrid("fieldOption", "2", "visible", false);
     	   }
        
        }
        
        function fn_SubBrdPage(getData) {
     	   var brdTypCd = $('#brdTypCd').val();
     	   location.href='/admin/board/boardDetail?brdSq='+getData+'&brdTypCd='+brdTypCd;
     	}
    
</script>

</body>
</html>