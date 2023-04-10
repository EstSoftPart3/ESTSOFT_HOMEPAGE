<%@ page session="false" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html lang="en">

<head>
   <%@ include file="/WEB-INF/include/header.jspf" %>
   
    <style type="text/css">
      	
		.theadTh {
			height : 40px;
			font-size : 12px;
			font-weight:bold;
			background-color:#efefef;
			
		}
		
		tbody > tr > td {
			height : 40px;
			font-size : 12px;
			background-color:#ffffff;
			text-align : center;
			vertical-align: middle;
		}
		
		.tdColor {
			background-color:#efefef;
		}
		
		th, td {
   		 border: 0px solid #e9ecef;
		}
		
  	</style>
   
</head>

<body>
    <!-- Spinner Start -->
    <div id="spinner"
        class="show bg-white position-fixed translate-middle w-100 vh-100 top-50 start-50 d-flex align-items-center justify-content-center">
        <div class="spinner-grow text-primary" role="status"></div>
    </div>
    <!-- Spinner End -->


    <!-- Navbar Start -->
   	<%@ include file="/WEB-INF/include/navbar.jspf" %>
    <!-- Navbar End -->


    <!-- Header Start -->
    <div class="container-fluid hero-header bg-light py-5 mb-5">
        <div class="container py-5">
            <div class="row g-5 align-items-center">
                <div class="col-lg-6">
                    <h1 class="display-4 mb-3 animated slideInDown">EST COMMUNITY</h1>
                     <p class="animated slideInDown IBM">
                    	저희 이에스티소프트는 성실함과 책임감으로 무장하고 있으며,
                    	<br>
						프로젝트 진행 시 소통이 뛰어난 진정한 전문가 그룹입니다.
					</p>
					
					<nav aria-label="breadcrumb animated slideInDown">
                        <ol class="breadcrumb mb-0 menu">
                            <li class="breadcrumb-item"><a href="#">공지사항</a></li>
                            <li class="breadcrumb-item"><a href="#">자유게시판</a></li>
                            <li class="breadcrumb-item"><a href="#">기술문의</a></li>
                            <li class="breadcrumb-item"><a href="#">교육일정</a></li>
                        </ol>
                    </nav>
                    
                </div>
                <div class="col-lg-6 animated fadeIn">
                    <img class="img-fluid animated pulse infinite" style="animation-duration: 3s;border-radius: 5%;" src="/resources/fo/team/t13.jpg" alt="">
                </div>
            </div>
        </div>
    </div>
    <!-- Header End -->


    <!-- Start -->
    <div class="container-xxl py-5 menu">
        <div class="container">
            <div class="text-center mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 500px;">
                <h1 class="display-3" style="font-size:20px;">공지사항 리스트</h1>
            </div>
           <table style="width:100%;max-width: 900px;" align="center">	
           	<tr>
           		<td style="text-align:left;border:0px;width:170px;">
           			
           			<select class="form-select" name="searchOption" id="searchOption" style="font-size:12px;">
           				<option value="">- 선택 -</option>
           				<option value="T">제목</option>
           				<option value="C">내용</option>
           				<option value="W">내용</option>
           				<option value="TCW">제목+내용+작성자</option>
           			</select>
           			
           		</td>
           		<td style="border:0px;width:70%">
           			<input type="text" class="form-control" id="searchKeyword" placeholder="검색할 내용을 입력하세요" style="font-size:12px;">
           		</td>
           		<td style="border:0px;">
           			<button type="button" class="form-control btn-secondary" style="font-size:12px" id="searchBtn">검색</button>
           		</td>
           	</tr>
           </table>
           
           <table class="table table-bordered" style="max-width: 900px;border-color:#ced4da" align="center" id="board">
		  	<thead>
		  		<tr class="theadTh">
					<th class="text-center">번호</th>
					<th class="text-center" style="width:70%">제목</th>
					<th class="text-center">입력일</th>
				</tr>
			</thead>
			<tbody>
				
			</tbody>
		</table>
		
			<div class="col-12 text-center" style="padding-top:15px;">
         	 	<button type="button" class="btn btn-secondary btn-sm" onclick="fn_Reg_move();">게시판 작성</button>
         	 </div>
           
        </div>
    </div>
    <!-- FAQs Start -->
    
    <%@ include file="/WEB-INF/include/footer.jspf" %>
    
     <script>
		
     $(document).ready(function() {
   	   	noticeBoardList(1);
     });
     
	$("#searchBtn").on('click', function(){

  		var searchOption = $("#searchOption :selected").val();
		var searchKeyword = $("#searchKeyword").val();

	   	 if(isEmpty(searchOption)) {
	   		bootbox.alert({
					 message: "검색 옵션을 선택해주세요.",
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
			noticeBoardList(1);
		 }
	});
	
	/* 게시판 리스트 */
    function noticeBoardList(curPage){

		var searchOption = $("#searchOption :selected").val();
		var searchKeyword = $("#searchKeyword").val();
 	  	
 	  	let params = {
 			searchOption : searchOption,
 			searchKeyword : searchKeyword,
 			curPage : curPage,
 		}
    	
 	   	$.ajax({
 	    	 type: "post",
	    	 url: "/eep/board/notice/noticeBoardListData.do",
	         data: params,
	         dataType: "json",
	         success: function(data) {
	        	 
	        	var List = data.noticeBoardData.noticeBoardInfo;
	        	var body = $("#board>tbody");
	 			body.empty();
	 			
	 			if(List.length > 0) {

	 				List.forEach(value => {

						
		                //현재 값을 가지고 와서 append(태그넣기)를 사용하여서 tbody안에 넣어줍니다.
						body.append(
								"<tr>" + 
									"<td>" +
										value.brdSq +
									"</td>" +
									"<td style='text-align:left;'>" +
										value.brdTtl +
									"</td>" +
									"<td>" +
										value.brdRegDt +
									"</td>" +
								"</tr>"
									
									
									/* "<td class='bno'>" + value.bno + "</td>" +
									"<td id='detail'><a href='/erp/sample/sampleBoardDetail.do?bno=" + value.bno + "'>" + value.title + "</td>" +
									/* "<td>" + value.content + "</td>" +
									"<td>" + value.writer + "</td>" +
									"<td>" + returnDate + "</td>" +
									"<td>" + value.viewcnt + "</td>" +
									"<td><button class='btn btn-primary btn-sm' onclick='showDetail(`" + value.title + "`,`" + value.content + "`,`" + value.writer + "`)'>바로보기</button></td>" +
								"</tr>"  */
								);
							});
				
				} else {
					body.append("<tr>" + "<td colspan='8'>조회 결과가 없습니다</td>" + "</tr>"); 
				}
	         },
		     error: function(error) {
		     	   var errorJson = JSON.stringify(error);
		            console.log(errorJson);
		     }
 	   })
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