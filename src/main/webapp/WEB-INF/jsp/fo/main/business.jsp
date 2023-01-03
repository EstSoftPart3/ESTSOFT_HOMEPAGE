<%@ page session="false" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<html lang="en">

<head>
    <%@ include file="/WEB-INF/include/header.jspf" %>
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
                    <h1 class="display-4 mb-3 animated slideInDown">EST Business</h1>
                    <p class="animated slideInDown IBM">
                    	50여 명의 정직원 모두 성살함과 책임감으로 무장하고 있으며,
                    	<br>
						프로젝트 진행 시 소통이 뛰어난 진정한 전문가 그룹입니다.
					</p>
                </div>
                <div class="col-lg-6 animated fadeIn">
                    <img class="img-fluid animated pulse infinite" style="animation-duration: 3s;border-radius: 5%;" src="/resources/fo/team/t13.jpg" alt="">
                </div>
            </div>
        </div>
    </div>
    <!-- Header End -->


    <!-- Start -->
    <div class="container-xxl py-5">
        <div class="container">
        	
        	 <div class="row g-5 align-items-center">
                <div class="col-lg-6 wow fadeInUp" data-wow-delay="0.1s">
                    <img class="img-fluid" src="/resources/fo/img/b01.jpg" style="border-radius:3%;">
                </div>
                <div class="col-lg-6 wow fadeInUp" data-wow-delay="0.5s">
                    <div class="h-100">
                        <h1 class="display-6">IT CONSULTING</h1>
                        
                        <p class="menu">
                        	기업 및 조직의 정보시스템 구축에 대한 정보전략계획 (ISP)을 수립하여 전반적인 상황인식,
                        	<br>
                        	목표선정 등 다양한 경험과 방법론을 통한 효과적인 솔루션 제공.
                        </p>
                        
                    </div>
                </div>
             </div>
             
             <div class="row g-5 align-items-center" style="padding-top:50px;">
                <div class="col-lg-6 wow fadeInUp" data-wow-delay="0.1s">
                    <img class="img-fluid" src="/resources/fo/img/b02.jpg" style="border-radius:3%;">
                </div>
                <div class="col-lg-6 wow fadeInUp" data-wow-delay="0.5s">
                    <div class="h-100">
                        <h1 class="display-6">SYSTEM INTEGRATION</h1>
                        
                        <p class="menu">
                        	기업이 필요로 하는 정보시스템에  관한 기획에서부터 개발과 구축,
                        	<br>
                        	나아가서는 운영 전략수립, BPR 등 모든 서비스를 제공.
                        </p>
                        
                    </div>
                </div>
             </div>
             
             
             <div class="row g-5 align-items-center" style="padding-top:50px;">
                <div class="col-lg-6 wow fadeInUp" data-wow-delay="0.1s">
                    <img class="img-fluid" src="/resources/fo/img/b03.jpg" style="border-radius:3%;">
                </div>
                <div class="col-lg-6 wow fadeInUp" data-wow-delay="0.5s">
                    <div class="h-100">
                        <h1 class="display-6">IT SOLUTION</h1>
                        
                        <p class="menu">
                        	다양한 기업과의 협업을 통한 솔루션 ( ERP, CRM, IoT, LMS, 그룹웨어 등) 구축 경험과  
                        	<br>
                        	노하우를 통한 안정적이고 효과적인 시스템 구축. 
                        </p>
                        
                    </div>
                </div>
             </div>
        
            
        </div>
    </div>
    <!-- End -->


    
    <%@ include file="/WEB-INF/include/footer.jspf" %>
    
</body>

</html>