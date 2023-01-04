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
                    	50여 명의 정직원 모두 성살함과 책임감으로 무장하고 있으며,
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
           				<option value="W">작성자</option>
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
					<th class="text-center">작성자</th>
					<th class="text-center">입력일</th>
				</tr>
			</thead>
			<tbody>
				
			</tbody>
		</table>
		
		<div class="row justify-content-center" style="padding-top:15px; margin: 0 auto;">
			<ul class="pagination pagination-sm" id="pages">
								
			</ul>
		</div>

		<div class="col-12 text-center" style="padding-top:15px;">
        	<button type="button" class="btn btn-secondary btn-sm" onclick="noticeBoardInsert();">게시판 작성</button>
         </div>

        </div>
    </div>
    <!-- FAQs Start -->
    
    <%@ include file="/WEB-INF/include/footer.jspf" %>
    
     <script>
		
     var emplyAuthTypCd = "<c:out value = '${loginInfo.loginInfo[0].emplyAuthTypCd}'/>";
     var emplyId = "<c:out value = '${loginInfo.loginInfo[0].emplyId}'/>";

     //첫 로딩시 리승트 호출
     $(document).ready(function() {
   	   	noticeBoardList(1);
     });
     
     //검색 바인딩
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
									"<td style='text-align:left;'><a style='text-decoration-line: none;' href='javascript:noticeDetail(" + value.brdSq + ")'>" + 
										value.brdTtl +
									"</td>" +
									"<td>" +
										value.brdWrtr +
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
	 			
	 			//페이징 처리 -> Ajax로 자료 불러오는 것과 동시에 처리해야함
				var boardPager = data.boardPager;
				var ul = $("#pages");
				ul.empty();			
				//현재 블록이 1보다 클 경우에 이전과 처음 버튼을 생성한다
				if(boardPager.curBlock > 1) {
						
					ul.append(
					"<li class='page-item'><a class='page-link' href='javascript:noticeBoardList(1)'>[처음]</a></li>" +
					"<li class='page-item'><a class='page-link' href='javascript:noticeBoardList(" + boardPager.prevPage + ")'>[이전]</a></li>"
					);
				}
				//페이지 넘버가 시작번호부터 끝번호까지 계속 증가하면서 하나씩 만든다 (예: [1] [2] [3] [4] [5])
				for(var pageNum = boardPager.curBlock*10-9; pageNum <= boardPager.blockEnd; pageNum++){
					//현재 페이지와 같을 경우에는 하이퍼링크를 제거한다		
					if(pageNum == boardPager.curPage){
						ul.append(
						"<li class='page-link' style='background: lightblue;'>[" + pageNum + "]</span></li>"
						);
					//그 외에는 하이퍼링크를 넣는다	
					} else {
						ul.append(
						"<li class='page-item'><a class='page-link' href='javascript:noticeBoardList(" + pageNum + ")'>[" + pageNum + "]</a></li>"
						);
					}
				}
				
				//현재 블록이 전체 블록보다 작을때에는 다음 버튼과 끝 버튼을 넣는다
				if(boardPager.curBlock <= boardPager.totBlock){
					ul.append(
					"<li class='page-item'><a class='page-link' href='javascript:noticeBoardList(" + boardPager.nextPage + ")'>[다음]</a></li>" +
					"<li class='page-item'><a class='page-link' href='javascript:noticeBoardList(" + boardPager.totPage + ")'>[끝]</a></li>"
					);
				}

	         },
		     error: function(error) {
		     	   var errorJson = JSON.stringify(error);
		            console.log(errorJson);
		     }
 	   })
    }

    /* 게시판 입력 */
    function noticeBoardInsert() {
    	var emplyAuthTypCd = $("#emplyAuthTypCd").val();
		
    	if(emplyAuthTypCd == '2'){
    		location.href = "/eep/board/notice/openNoticeBoardInsert.do";
    	}else{
    		bootbox.alert({
				 message: "해당 권한이 없습니다.",
				 locale: 'kr',
				 callback: function() {
					 return;
			     } });
			 
    	}
    	
 	   	
    }
    
    
    function noticeDetail(brdSq) {
    	
    	if(isEmpty(emplyId)){
    		bootbox.alert({
				 message: "로그인 상태에만 가능한 기능입니다.",
				 locale: 'kr',
				 callback: function() {
					 return;
			 } });
    	}else{
    		 location.href = "/eep/board/notice/openNoticeBoardDetail.do?brdSq="+brdSq;

    	}

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