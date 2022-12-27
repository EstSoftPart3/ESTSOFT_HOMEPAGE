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
                    <h1 class="display-4 mb-3 animated slideInDown">EST Organization</h1>
                    <p class="animated slideInDown IBM">
                    	50여 명의 정직원 모두 성살함과 책임감으로 무장하고 있으며,
                    	<br>
						프로젝트 진행 시 소통이 뛰어난 진정한 전문가 그룹입니다.
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
        <div class="container text-center">
          
           
               <img src="/resources/fo/img/orgin.png" style="width:70%">
           
          
    		
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