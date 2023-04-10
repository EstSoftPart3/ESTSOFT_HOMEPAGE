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
    <div class="container-fluid hero-header bg-light">
        <div class="container py-5">
            <div class="row g-5 align-items-center">
                <div class="col-lg-6">
                    <h1 class="display-4 mb-3 animated slideInDown menu" style="font-weight: 700;">CEO 인사말</h1>
                    <p class="animated slideInDown IBM"> 
                    	저희 이에스티소프트는 성실함과 책임감으로 무장하고 있으며,
                    	<br>
						프로젝트 진행 시 소통이 뛰어난 진정한 전문가 그룹입니다.
					</p>
                </div>
                <div class="col-lg-6 animated fadeIn">
                    <img class="img-fluid animated pulse infinite" style="animation-duration: 3s;border-radius: 5%;" src="/resources/fo/img/est000.png" alt="">
                </div>
            </div>
        </div>
    </div>
    <!-- Header End -->


    <!-- CEO Start -->
    <div class="container-xxl py-5">
        <div class="container">
            <div class="row g-5 align-items-center">
              
              <div class="col-lg-2">
              </div>	
            	
               <div class="col-lg-9 wow fadeInUp" data-wow-delay="0.5s">
                    <div class="h-100">
                                               
                        <p class="IBM">
                        	<b>
                        		㈜이에스티소프트는 e-Biz 구현을 위한 IT Consulting, System Integration 전문 회사로 다양한 서비스 기반의 최적화된 솔루션을 보유하고 있으며,
                        		<br> 
								다수의 고객과 관련 기업에 웹 서비스 및  솔루션 등을 구축, 운영하고 있습니다.
							</b>
                        </p>
                        <p class="IBM">
                        	<b>
                        		단순한 소프트웨어 개발사가 아닌, 고객의 믿음과 신뢰를 바탕으로 한  전략적인 비즈니스 파트너가 될 수 있도록 끊임없이 노력하고 있으며,
                        		<br> 
                        		고객의 비즈니스 환경에 맞는 최적의 방법론을 제시하고 고도의 기술력을 제공하여  고객과 함께 성장하는 기업이 되겠습니다
							</b>
                        </p>
                        
                        <p class="IBM">
                        	<b>
                        		아울러 인재존중경영을 경영이념으로 구성원의 창의성과 자율을 존중하고, 개개인의 잠재 능력을 최대한 계발하고 발휘할 수 있도록 하며,
                        		<br> 
                        		사업의 근본이 되는 인간을 최우선으로 생각하고, 고객과 구성원 모두에게 최고의 가치를 제공함으로써 인간의 행복을 극대화하는 기업이 되고자 합니다.
							</b>
                        </p>
                        
                         <p class="IBM text-right">
                        	<b>
                        		CEO 임은수
							</b>
                        </p>
                       
                       
                       
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- CEO End -->
    
    <!-- TEAM Start -->
    <!--
    <div class="container-xxl bg-light">
        <div class="container py-5">
            <div class="text-center mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 500px;">
                 <p class="text-primary fs-5 mb-5"></p>
            </div>
            <div class="row g-3">
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                        <img src="/resources/fo/team/t7.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                        <img src="/resources/fo/team/t8.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.3s">
                    <div class="bg-white text-center p-3">
                        <img src="/resources/fo/team/t9.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                        <img src="/resources/fo/team/t10.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                        <img src="/resources/fo/team/t1.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                        <img src="/resources/fo/team/t2.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                        <img src="/resources/fo/team/t10.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                        <img src="/resources/fo/team/t11.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.3s">
                    <div class="bg-white text-center p-3">
                        <img src="/resources/fo/team/t12.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                        <img src="/resources/fo/team/t13.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                        <img src="/resources/fo/team/t14.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                        <img src="/resources/fo/team/t15.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
               
            </div>
        </div>
    </div>
    -->
    <!--TEAM End -->
    <!-- 
    <div class="container-xxl bg-light">
        <div class="container py-5">
             <div class="row g-3">
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                        <img src="/resources/fo/img/O001.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                        <img src="/resources/fo/img/O002.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.3s">
                    <div class="bg-white text-center p-3">
                        <img src="/resources/fo/img/O003.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                        <img src="/resources/fo/img/O004.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                        <img src="/resources/fo/img/O005.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                        <img src="/resources/fo/img/O006.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                        <img src="/resources/fo/img/O007.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.1s">
                    <div class="bg-white text-center p-3">
                        <img src="/resources/fo/img/O008.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.3s">
                    <div class="bg-white text-center p-3">
                        <img src="/resources/fo/img/O009.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                        <img src="/resources/fo/img/O010.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                        <img src="/resources/fo/img/O011.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
                
                 <div class="col-6 col-md-2 wow fadeIn" data-wow-delay="0.5s">
                   <div class="bg-white text-center p-3">
                        <img src="/resources/fo/img/O012.jpg" style="width:200px;height:150px;">
                    </div>
                </div>
               
            </div>
        </div>
    </div>
	-->

    
    <%@ include file="/WEB-INF/include/footer.jspf" %>
    
</body>

</html>