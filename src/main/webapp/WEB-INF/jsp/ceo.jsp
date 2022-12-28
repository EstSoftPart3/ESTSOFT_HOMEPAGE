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
                    <h1 class="display-4 mb-3 animated slideInDown">EST CEO</h1>
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


    <!-- CEO Start -->
    <div class="container-xxl py-5">
        <div class="container">
            <div class="row g-5 align-items-center">
               <div class="col-lg-12 wow fadeInUp" data-wow-delay="0.5s">
                    <div class="h-100">
                        <h1 class="display-6">
                        	<span class="menu" style="font-size:25px;"><b>CEO 인사말</b></span>
                        </h1>
                        
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


    
    <%@ include file="/WEB-INF/include/footer.jspf" %>
    
</body>

</html>