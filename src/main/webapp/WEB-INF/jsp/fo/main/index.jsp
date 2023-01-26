<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>  
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html lang="en">

<head>
   <%@ include file="/WEB-INF/include/header.jspf" %>    
</head>

<style type="text/css">
th, td {
 border: 0px solid #e9ecef;
}	
.teamModal {
	display: none;
	z-index: 500;
	width: 100%;
	height: 100vh;
	position: fixed;
	top: 0;
	left: 0;
	background-color: rgba(0, 0, 0, 0.3);
}

.teamModal button {
	position: absolute;
	top: 3rem;
	right: 3rem;
	background: transparent;
	border: 0;
	color: #ffffff;
	font-size: 3rem;
}

.teamModalBox {
	position: relative;
	top: 40%;
	left: 50%;
	transform: translate(-50%, -20%);
	background-color: #555252;
	width: 40%;
	height: auto;
	text-align: center;
}

.teamModalBox img {
	width: 100%;
}

</style>

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
    <div class="container-fluid hero-header bg-light">
        <div class="container py-5">
            <div class="row g-5 align-items-center">
                 <div class="col-lg-6">
                    <h1 class="display-4 mb-3 animated slideInDown menu" style="font-weight: 700;">EST SOFT</h1>
                    <p class="animated slideInDown IBM">
                    	e-Biz 구현을 위한 IT Consulting, System Integration 전문 회사로 다양한 <br>
						서비스 기반의 최적화된 솔루션을 보유하고 있으며, 다수의 고객과 <br> 
						관련 기업에 웹 서비스 및 솔루션 등을 구축, 운영하고 있습니다.
					</p>
                    <!--
                    <a href="" class="btn btn-primary py-3 px-4 animated slideInDown">Explore More</a>
                    -->
                </div>
                <div class="col-lg-6 animated fadeIn">
                    <img class="img-fluid animated pulse infinite" style="animation-duration: 3s;border-radius: 5%;" src="/resources/fo/img/est000_v0.png" alt="">
                </div>
            </div>
        </div>
    </div>
    <!-- Header End -->


    <!-- Features Start -->
    <div class="container-xxl py-5! bg-light my-5" style="padding-top: 0rem !important;">
        <div class="container py-5">
            
            <div class="text-center mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 500px;">
                <h1 class="display-6">Community</h1>
                <p class= "fs-5 mb-5"></p>
            </div>
            
            <div class="row g-5 menu">
            
                <div class="col-lg-4 col-md-6 wow fadeInUp" data-wow-delay="0.1s">
                    <div class="d-flex1 align-items-start">
                        <img class="img-fluid flex-shrink-0" src="img/icon-7.png" alt="">
                        <div class="ps-4">
                            
                               <h5 class="mb-3 Gugi">NOTICE</h5>
                              
                              <table class="table table-bordered" style="border-color:#ced4da">
								   	<thead style="background-color:#efefef">
								   		<tr align="center">
											<th>제목</th>
											<th>등록일</th>
										</tr>
									</thead>
									<tbody style="font-weight:bold;">
										<c:choose>
											<c:when test="${ fn:length(noticeData.mainNoticeBoardInfo) == 0 }">
												<tr>
													<td colspan="2">조회 결과가 없습니다</td>
												</tr>
											</c:when>
											<c:otherwise>
												<c:forEach var="noticeData" items="${noticeData.mainNoticeBoardInfo}">
												<tr style="text-align:center;background-color:#ffffff">
													<td>
														<a style="text-decoration:none" 
														   href="javascript:noticeBoardList(${noticeData.brdSq})">
															<c:out value="${noticeData.brdTtl}" />
														</a>
													</td>
													<td>
														<c:out value="${noticeData.brdRegDt}" />
													</td>
												</tr>
												</c:forEach>
											</c:otherwise>
										</c:choose>
									</tbody>
							 </table>
							 
                            </span>
                        </div>
                    </div>
                </div>
               <div class="col-lg-4 col-md-6 wow fadeInUp" data-wow-delay="0.1s">
                    <div class="d-flex1 align-items-start">
                        <img class="img-fluid flex-shrink-0" src="img/icon-7.png" alt="">
                        <div class="ps-4">
                            
                               <h5 class="mb-3 Gugi">TECHNOLOGY</h5>
                              
                              <table class="table table-bordered" style="border-color:#ced4da">
								   	<thead style="background-color:#efefef">
								   		<tr align="center">
											<th>제목</th>
											<th>등록일</th>
										</tr>
									</thead>
									<tbody style="font-weight:bold;">
										<c:choose>
											<c:when test="${ fn:length(technologyData.mainTechnologyBoardInfo) == 0 }">
												<tr>
													<td colspan="2">조회 결과가 없습니다</td>
												</tr>
											</c:when>
											<c:otherwise>
												<c:forEach var="technologyData" items="${technologyData.mainTechnologyBoardInfo}">
												<tr style="text-align:center;background-color:#ffffff">
													<td>
														<a style="text-decoration:none" 
														   href="javascript:technologyBoardList(${technologyData.brdSq})">
															<c:out value="${technologyData.brdTtl}" />
														</a>
													</td>
													<td>
														<c:out value="${technologyData.brdRegDt}" />
													</td>
												</tr>
												</c:forEach>
											</c:otherwise>
										</c:choose>
									</tbody>
							 </table>
                            
                            </span>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6 wow fadeInUp" data-wow-delay="0.1s">
                    <div class="d-flex1 align-items-start">
                        <img class="img-fluid flex-shrink-0" src="img/icon-7.png" alt="">
                        <div class="ps-4">
                            
                               <h5 class="mb-3 Gugi">EDUCATION</h5>
                              
                               <table class="table table-bordered" style="border-color:#ced4da">
								   	<thead style="background-color:#efefef">
								   		<tr align="center">
											<th>제목</th>
											<th>등록일</th>
										</tr>
									</thead>
									<tbody style="font-weight:bold;">
										<c:choose>
											<c:when test="${ fn:length(educationData.mainEducationBoardInfo) == 0 }">
												<tr>
													<td colspan="2">조회 결과가 없습니다</td>
												</tr>
											</c:when>
											<c:otherwise>
												<c:forEach var="educationData" items="${educationData.mainEducationBoardInfo}">
												<tr style="text-align:center;background-color:#ffffff">
													<td>
														<a style="text-decoration:none" 
														   href="javascript:educationBoardList(${educationData.brdSq})">
															<c:out value="${educationData.brdTtl}" />
														</a>
													</td>
													<td>
														<c:out value="${educationData.brdRegDt}" />
													</td>
												</tr>
												</c:forEach>
											</c:otherwise>
										</c:choose>
									</tbody>
							 </table>
                            
                            </span>
                        </div>
                    </div>
                </div>
                
            </div>
        </div>
    </div>
    <!-- Features End -->


    <!-- Service Start -->
    <div class="container-xxl bg-light py-15 my-5 ">
        <div class="container py-5">
            <div class="text-center mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 500px;">
                <h1 class="display-6">PROJECT</h1>
                <p class="text-primary fs-5 mb-5"></p>
            </div>
            <div class="row g-4 menu">
                <div class="col-lg-4 col-md-6 wow fadeInUp" data-wow-delay="0.1s">
                    <div class="service-item bg-white p-5">
                        
                        <h5 class="mb-3">
                        	<span class="material-icons" style="font-size: 20px !important;">list_alt</span><b>컨설팅</b><br>
                       	</h5>
                        <p>
                        	- 차세대 정보시스템 설계
                        	<br>
                        	- 컨설팅 전문가, 방법론 보유
                        	<br>
                        	- UI/UX 설계
                        </p>
                        
                    </div>
                </div>
                <div class="col-lg-4 col-md-6 wow fadeInUp" data-wow-delay="0.3s">
                    <div class="service-item bg-white p-5">
                        
                        <h5 class="mb-3">
                        	<span class="material-icons" style="font-size: 20px !important;">list_alt</span><b>시스템 통합(SI)</b><br>
                       	</h5>
                        <p>
                        	전산시스템 개발 및 구축을 
                        	<br>
                        	필요로 하는 시스템 기획
                        	<br> 
                        	 시스템 개발, 시스템 구축
                        	<br>
                        </p>
                        
                    </div>
                </div>
                <div class="col-lg-4 col-md-6 wow fadeInUp" data-wow-delay="0.5s">
                   <div class="service-item bg-white p-5">
                        
                        <h5 class="mb-3">
                        	<span class="material-icons" style="font-size: 18px !important;">list_alt</span><b>클라우드</b><br>
                       	</h5>
                        
                          <p>
                        	- 차세대 정보시스템 설계
                        	<br>
                        	- 컨설팅 전문가, 방법론 보유
                        	<br>
                        	- UI/UX 설계
                        </p>
                    </div>
                </div>
                
                
               
            </div>
        </div>
    </div>
    <!-- Service End -->


    

    <!-- PARTNER Start -->
    <div class="container-xxl bg-light py-5 my-5">
        <div class="container py-5">
            <div class="text-center mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 500px;">
                <h1 class="display-6">PARTNER</h1>
                <p class="text-primary fs-5 mb-5"></p>
            </div>
            <div class="row g-3">
                <div class="col-6 col-md-3 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                        <img src="/resources/fo/logo/L3.png">
                    </div>
                </div>
                <div class="col-6 col-md-3 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                        <img src="/resources/fo/logo/L99.png">
                    </div>
                </div>
                <div class="col-6 col-md-3 wow fadeIn" data-wow-delay="0.3s">
                    <div class="bg-white text-center p-3">
                        <img src="/resources/fo/logo/L4.png">
                    </div>
                </div>
                <div class="col-6 col-md-3 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                        <img src="/resources/fo/logo/L7.png">
                    </div>
                </div>
               
            </div>
        </div>
    </div>
    <!--PARTNER End -->
    
    <!-- TEAM Start -->
    <div class="container-xxl bg-light py-5 my-5">
        <div class="container py-5">
            <div class="text-center mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 500px;">
                <h1 class="display-6">TEAM</h1>
                <p class="text-primary fs-5 mb-5"></p>
            </div>
            <div class="row g-3">
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                    	<div class="imgC">
                        	<img src="/resources/fo/team/t7.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                    	<div class="imgC">
                        	<img src="/resources/fo/team/t8.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.3s">
                    <div class="bg-white text-center p-3">
                    	<div class="imgC">
                        	<img src="/resources/fo/team/t9.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                   		<div class="imgC">
                        	<img src="/resources/fo/team/t10.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>

                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                    	<div class="imgC">
                        	<img src="/resources/fo/team/t10.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                    	<div class="imgC">
                        	<img src="/resources/fo/team/t11.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.3s">
                    <div class="bg-white text-center p-3">
                    	<div class="imgC">
                        	<img src="/resources/fo/team/t12.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                   		<div class="imgC">
                        	<img src="/resources/fo/team/t13.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                   		<div class="imgC">
                        	<img src="/resources/fo/team/t14.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                   		<div class="imgC">
                        	<img src="/resources/fo/team/t15.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                
               <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                   		<div class="imgC">
                        	<img src="/resources/fo/team/t17.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                   		<div class="imgC">
                        	<img src="/resources/fo/team/t18.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!--TEAM End -->
    
   	<!-- 팝업 될 곳 -->
	<div class="teamModal">
		<button>&times;</button>
		<div class="teamModalBox">
			<img src="" alt="">
			<!-- <p></p> -->
		</div>
	</div>
	
     <div class="container-xxl bg-light">
        <div class="container py-5">
        
        	<div class="text-center mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 500px;">
                <h1 class="display-6">OFFICE</h1>
                <p class="text-primary fs-5 mb-5"></p>
            </div>
            
             <div class="row g-3">
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                    	<div class="imgC">
                        	<img src="/resources/fo/img/O001.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                    	<div class="imgC">
                        	<img src="/resources/fo/img/O002.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.3s">
                    <div class="bg-white text-center p-3">
                   		<div class="imgC">
                        	<img src="/resources/fo/img/O003.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                   		<div class="imgC">
                        	<img src="/resources/fo/img/O004.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                   		<div class="imgC">
                        	<img src="/resources/fo/img/O005.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                   		<div class="imgC">
                        	<img src="/resources/fo/img/O006.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                    	<div class="imgC">
                        	<img src="/resources/fo/img/O007.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                    	<div class="imgC">
                        	<img src="/resources/fo/img/O008.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.3s">
                    <div class="bg-white text-center p-3">
                    	<div class="imgC">
                        	<img src="/resources/fo/img/O009.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                   		<div class="imgC">
                        	<img src="/resources/fo/img/O010.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                   		<div class="imgC">
                        	<img src="/resources/fo/img/O011.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                   		<div class="imgC">
                        	<img src="/resources/fo/img/O012.jpg" style="width:200px;height:150px;">
                        </div>
                    </div>
                </div>
               
            </div>
        </div>
    </div>



	<%@ include file="/WEB-INF/include/footer.jspf" %>
   
</body>
	<script type="text/javascript">
	
	var emplyId = "<c:out value = '${loginInfo.loginInfo[0].emplyId}'/>";
	
	function noticeBoardList(brdSq){
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
	
	function technologyBoardList(brdSq){
		if(isEmpty(emplyId)){
    		bootbox.alert({
				 message: "로그인 상태에만 가능한 기능입니다.",
				 locale: 'kr',
				 callback: function() {
					 return;
			 } });
    	}else{
    		 location.href = "/eep/board/technology/openTechnologyBoardDetail.do?brdSq="+brdSq;

    	}
	}
	
	function educationBoardList(brdSq){
		if(isEmpty(emplyId)){
    		bootbox.alert({
				 message: "로그인 상태에만 가능한 기능입니다.",
				 locale: 'kr',
				 callback: function() {
					 return;
			 } });
    	}else{
    		 location.href = "/eep/board/education/openEducationBoardDetail.do?brdSq="+brdSq;

    	}
	}

	//이미지 클릭시 해당 이미지 모달
 	$(".imgC").click(function(){
 		$(".teamModal").show();
 		// 해당 이미지 가겨오기
 		var imgSrc = $(this).children("img").attr("src");
 		var imgAlt = $(this).children("img").attr("alt");
 		$(".teamModalBox img").attr("src", imgSrc);
 		$(".teamModalBox img").attr("alt", imgAlt);
 		
    	// 해당 이미지에 alt값을 가져와 제목으로
 		//$(".modalBox p").text(imgAlt);
 	});
 	
 	//.modal안에 button을 클릭하면 .modal닫기
 	$(".teamModal button").click(function(){
 		$(".teamModal").hide();
 	});
 	
 	//.modal밖에 클릭시 닫힘
 	$(".teamModal").click(function (e) {
     if (e.target.className != "teamModal") {
       return false;
     } else {
       $(".teamModal").hide();
     }
   });
    
    //Input Box Null Check
    function isEmpty(str){
        
        if(typeof str == "undefined" || str == null || str == "")
            return true;
        else
            return false ;
    }
	
	</script>
</html>
