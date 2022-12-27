<%@ page session="false" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<html lang="en">

<head>
    <meta charset="utf-8">
    <title>EST</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <meta content="" name="keywords">
    <meta content="" name="description">

    <!-- Favicon -->
    <link href="/resources/fo/img/favicon.ico" rel="icon">

    <!-- Google Web Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Gothic+A1:wght@400;700&family=Gugi&family=IBM+Plex+Sans+KR:wght@200&family=Nanum+Gothic:wght@700&display=swap" rel="stylesheet">

	<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    

    <!-- Libraries Stylesheet -->
    <link href="/resources/fo/lib/animate/animate.min.css" rel="stylesheet">
    <link href="/resources/fo/lib/owlcarousel/assets/owl.carousel.min.css" rel="stylesheet">

    <!-- Customized Bootstrap Stylesheet -->
    <link href="/resources/fo/css/bootstrap.css" rel="stylesheet">

    <!-- Template Stylesheet -->
    <link href="/resources/fo/css/style.css" rel="stylesheet">
    
    
    
</head>

<body>
    <!-- Spinner Start -->
    <div id="spinner"
        class="show bg-white position-fixed translate-middle w-100 vh-100 top-50 start-50 d-flex align-items-center justify-content-center">
        <div class="spinner-grow text-primary" role="status"></div>
    </div>
    <!-- Spinner End -->


    <!-- Navbar Start -->
    <nav class="navbar navbar-expand-lg bg-white navbar-light sticky-top p-0 px-4 px-lg-5">
       
       <a href="/eep/mainPage.do" class="navbar-brand d-flex align-items-center">
            <h2 class="m-0 text-primary"><img src="/resources/fo/img/est_logo.png" style="height:100px;"></h2>
       </a>
        
        <button type="button" class="navbar-toggler" data-bs-toggle="collapse" data-bs-target="#navbarCollapse">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarCollapse">
            <div class="navbar-nav ms-auto py-4 py-lg-0 menu"><!--active-->
               
                <div class="nav-item dropdown">
                    <a href="#" class="nav-link dropdown-toggle" data-bs-toggle="dropdown">회사소개</a>
                    <div class="dropdown-menu shadow-sm m-0">
                        <a href="/eep/historyPage.do" class="dropdown-item">연혁</a>
                        
                    </div>
                </div>
                <a href="about.html" class="nav-item nav-link">사업분야</a>
                <a href="service.html" class="nav-item nav-link">컨설팅</a>
                <!--
				<a href="roadmap.html" class="nav-item nav-link">채용정보</a>
                <div class="nav-item dropdown">
                    <a href="#" class="nav-link dropdown-toggle" data-bs-toggle="dropdown">Pages</a>
                    <div class="dropdown-menu shadow-sm m-0">
                        <a href="feature.html" class="dropdown-item">Feature</a>
                        <a href="token.html" class="dropdown-item">Token Sale</a>
                        <a href="faq.html" class="dropdown-item">FAQs</a>
                        <a href="404.html" class="dropdown-item">404 Page</a>
                    </div>
                </div>
				-->
                <a href="contact.html" class="nav-item nav-link">고객센터</a>
				<a href="contact.html" class="nav-item nav-link">커뮤니티</a>
            </div>
          </div>
    </nav>
    <!-- Navbar End -->


    <!-- Header Start -->
    <div class="container-fluid hero-header bg-light py-5 mb-5">
        <div class="container py-5">
            <div class="row g-5 align-items-center">
                <div class="col-lg-6">
                    <h1 class="display-4 mb-3 animated slideInDown">EST History</h1>
                    <p class="animated slideInDown IBM">
                    	e-Biz 구현을 위한 IT Consulting, System Integration 전문 회사로 다양한 <br>
						서비스 기반의 최적화된 솔루션을 보유하고 있으며, 다수의 고객과 <br> 
						관련 기업에 웹 서비스 및 솔루션 등을 구축, 운영하고 있습니다.
					</p>
                </div>
                <div class="col-lg-6 animated fadeIn">
                    <img class="img-fluid animated pulse infinite" style="animation-duration: 3s;border-radius: 5%;" src="/resources/fo/team/t16.jpg" alt="">
                </div>
            </div>
        </div>
    </div>
    <!-- Header End -->


    <!-- Roadmap Start -->
    <div class="container-xxl py-5">
        <div class="container">
              <div class="owl-carousel roadmap-carousel wow fadeInUp menu" data-wow-delay="0.1s">
                <div class="roadmap-item">
                    <div class="roadmap-point"><span></span></div>
                    <h5 class="text-center"><b>2017</b></h5>
                    <span class="text-right" style="font-size:12px;">
                    	1월 “이에스티” 설립
                    	<br>
						2월 ㈜MCS consulting 컨소시엄
						<br>
						<br>
						• 삼성전자 EMS 구축
						<br>
						• 롯데물산 컨퍼런스 룸 예약 구축
						<br>
						• LG전자 VC사업부 자동차설계 파트 구축
						<br>
						• 우리 캐피탈 다이렉트 시스템 구축
						
                    </span>
                </div>
                <div class="roadmap-item">
                    <div class="roadmap-point"><span></span></div>
                    <h5 class="text-center"><b>2018</b></h5>
                    <span class="text-right" style="font-size:12px;">
                    	1월 사내연구소 설립
  						<br>
  						6월 사내벤처 “soso” 설립
 						<br>
 						7월 “에듀해시글로벌㈜”
 						<br> 
         				컨소시엄 체결11월 합작법인
         				<br>
         				“㈜베스텍글로벌” 설립
                    	<br>
                    	<br>
                    	• 롯데닷컴 LECS 나이키 더 드로우 구축
						<br>
						• 금호건설 어울림 프로젝트 구축
						<br>
						• AIA 생명 DM채널 청약 고도화 구축
						<br>
						• LG U+ 전자결제 구조개선 고도화 구축
						<br>
						• 현대 HCN 통신회계 분리 구축
						<br>
						• 롯데호텔 시스템 인사파트 구축
                    	
                    </span>
                </div>
                <div class="roadmap-item">
                    <div class="roadmap-point"><span></span></div>
                    <h5 class="text-center"><b>2019</b></h5>
                    <span class="text-right" style="font-size:12px;">
                    	10월 에듀해시글로벌㈜ 
        				컨소시엄 해지
                    	<br>
                    	<br>
                    	• CJ 구매 시스템 구축
                    	<br>
						• 우리은행 콜센터 차세대 구축
						<br>
						• NH농협 의왕센터 사내 상품몰 구축
						<br>
						• SK 하이닉스 DB 개선 구축
						<br>
						• LG화학 인사 자동화 시스템 구축
						<br>
						• 리치엔코 B2B 시스템 구축
						<br>
						• 포스코 차세대 구축
						<br>
						• 부영건설 ERP 구축
                    	
                    </span>
                </div>
                <div class="roadmap-item">
                    <div class="roadmap-point"><span></span></div>
                   <h5 class="text-center"><b>2020</b></h5>
                    <span class="text-right" style="font-size:12px;">
                    
                    1월 “㈜이에스티소프트” 법인전환
                    <br>
					1월 사내연구소설립 
                    <br>
                    <br>
                    • 환경관리공단 2차 고도화 구축
					<br>
					• 포스코 차세대 MES3.0 재압관제 파트 구축
					<br>
					• 원큐 하나로 렌탈할부 플랫폼 구축
					<br>
					• 삼성물산 단위시스템 업무프로그램 고도화 구축
					<br>
					• 농림부 LMS시스템 구축
					<br>
					• 삼성전자 DS부문 신제품코드 전환 구축
					<br>
					• 삼성SDS 커뮤니티 메신저 개발 구축
					<br>
					• 현대IFC 인사부문  구축
                    </span>
                </div>
                <div class="roadmap-item">
                   <div class="roadmap-point"><span></span></div>
                   <h5 class="text-center"><b>2021</b></h5>
                    <span class="text-right" style="font-size:12px;">
                    6월 창업기업 확인
                    <br>
					11월 성과공유기업 확인
					<br>
					12월 벤처기업 확인
                    <br>
                    <br>
                    • LG화학 CTO LIMS 구축
                    <br>
					• 공무원연금공단 디지털전환 시스템 구축
					<br>
					• 한화손해사정 Smart심사시스템 개발 구축
					<br>
					• SK네트웍스 민팃 채널 통합 구축
					<br>
					• 제주항공 리포트 시스템 개발 구축
					<br>
					• GS리테일 택배시스템 차세대 구축
					<br>
					• 오웬스그룹 그룹웨어 업무시스템 구축
					<br>
					• 우리카드 마이데이터 2단계 인바운드 프로젝트 구축
					<br>
					• 삼성SDS 웹 에디터 체험용 포탈 구축
                    
                    </span>
                </div>
                <div class="roadmap-item">
                    <div class="roadmap-point"><span></span></div>
                    <h5 class="text-center"><b>2022</b></h5>
                    <span class="text-right" style="font-size:12px;">
                        1월  ㈜맨션나인  파트너쉽
                        <br>
                        <br>
                        •  딜링아트(미술품경매)  시스템 구축
                        
                    </span>
                </div>
            </div>
        </div>
    </div>
    <!-- Roadmap End -->


    
    <!-- Footer Start -->
    <div class="container-fluid bg-light footer mt-5 pt-5 wow fadeIn" data-wow-delay="0.1s">
        
        <div class="container-fluid copyright">
            <div class="container">
                <div class="row">
                    <div class="col-md-6 text-center text-md-start mb-3 mb-md-0 menu">
                        &copy; (주)이에스티 소프트 All Right Reserved.
                    </div>
                   
                </div>
            </div>
        </div>
    </div>
    <!-- Footer End -->


    <!-- Back to Top -->
<!--     <a href="#" class="btn btn-lg btn-primary btn-lg-square rounded-circle back-to-top"><i class="bi bi-arrow-up"></i></a> -->


   <!-- JavaScript Libraries -->
    <script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="/resources/fo/lib/wow/wow.min.js"></script>
    <script src="/resources/fo/lib/easing/easing.min.js"></script>
    <script src="/resources/fo/lib/waypoints/waypoints.min.js"></script>
    <script src="/resources/fo/lib/owlcarousel/owl.carousel.min.js"></script>
    <script src="/resources/fo/lib/counterup/counterup.min.js"></script>

    <!-- Template Javascript -->
    <script src="/resources/fo/js/main.js"></script>
</body>

</html>