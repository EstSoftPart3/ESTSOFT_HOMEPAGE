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
    <div class="container-fluid hero-header bg-light ">
        <div class="container py-5">
            <div class="row g-5 align-items-center">
                <div class="col-lg-6">
                    <h1 class="display-4 mb-3 animated slideInDown"> <span class="menu" style="font-weight: 700;"><b>컨설팅</b></h1>
                    
                    <p class="animated slideInDown IBM">
                    	50여 명의 정직원 모두 성살함과 책임감으로 무장하고 있으며,
                    	<br>
						프로젝트 진행 시 소통이 뛰어난 진정한 전문가 그룹입니다.
					</p>
					
					<nav aria-label="breadcrumb animated slideInDown">
                        <ol class="breadcrumb mb-0 menu">
                            <li class="breadcrumb-item active" aria-current="page"><a href="/eep/consultPage.do">컨설팅</a></li>
                            <li class="breadcrumb-item"><a href="/eep/consultRequestPage.do">컨설팅 의뢰</a></li>
                        </ol>
                    </nav>
                    
                </div>
                <div class="col-lg-6 animated fadeIn">
                    <img class="img-fluid animated pulse infinite" style="animation-duration: 3s;border-radius: 5%;" src="/resources/fo/img/blog-post-3.jpg" alt="">
                </div>
            </div>
        </div>
    </div>
    <!-- Header End -->


    <!-- Start -->
    <div class="container-xxl py-5">
        <div class="container">
        
        	<div class="col-lg-12 text-lg-start IBM" style="display:none">
                <a class="btn btn-primary py-3 px-4" href="">컨설팅</a>
                <a class="btn btn-primary py-3 px-4" href="" style="background-color:#cccccc;color:#000000;"><b>컨설팅 의뢰</b></a>
            </div>
        	
        	 <div class="row g-5 align-items-center IBM">
        	 
        	 	
        	 
                <div class="col-lg-6 wow fadeInUp" data-wow-delay="0.1s">
                    <img class="img-fluid" src="/resources/fo/img/c0001_1.png" alt="">
                    <img class="img-fluid" src="/resources/fo/img/c0001_2.png" alt="">
                </div>
                <div class="col-lg-6 wow fadeInUp" data-wow-delay="0.5s">
                	
                	<p class="fs-5 mb-0"><b>[ 미술품 경매 - 딜링아트 ]</b></p>
                	
                	<br>
                
                	<div class="h-100">
                        <p class="mb-2">
                        	<b>
                        		CONSULTING
                        	</b>
                        </p>
                        
                        <p>
                        	미술품 경매 시스템 구축에 있어 효과적인 온라인 판매를 위한 UI/UX 구성하고,
                        	<br>
                        	경매 현황을 차트롤 구현함으로써 경매의 참여 효과를 높이도록 하고,
                        	<br>
                        	미술작품의 효과적인 전시를 위해 핀터레스트 방식 UI를 설계하였습니다.
                        	<br>
                        	일반 구매과 경매를 같이 혼용하여 같은 페이지에 전시함으로 해서
                        	<br>
                        	지속적인 구매효과를 증대 시키도록 UI 컨설팅 하였습니다.
						</p>
                        
                    </div>
                    
                    <div class="h-100">
                        <p class="mb-2">
                        	<b>
                        		SUMMARY
                        	</b>
                        </p>
                        
                        <p>
                        	온라인 미술품 경매 시스템 구축
						</p>
                        
                    </div>
                    
                    <div class="h-100">
                        <p class="mb-2">
                        	<b>
                        		ROLE
                        	</b>
                        </p>
                        
                        <p>
                        	기획, 분석/설계, 구축, 운영
						</p>
                        
                    </div>
                    
                    <div class="h-100">
                        <p class="mb-2">
                        	<b>
                        		TECHNICAL
                        	</b>
                        </p>
                        
                        <p>
                        	<b>Platform</b>
                        	<br>
 							1)  Cloud 기반의 유연성과 확장성을 고려한 시스템인프라 구축.
 							<br>
 							2)  다양한 종류 및 환경의 데이터를 취합 및 가공할  수 있는 시스템 설계/구축.
 							<br>
 							3)  핀터레스트 방식의 UI/UX구성
 							<br>

						</p>
                        
                    </div>
                    
                     
                    
                </div>
                
             </div>
             
             
        	 <div class="row g-5 align-items-center IBM" style="padding-top:150px;">
        	 
        	 	
        	 
                <div class="col-lg-6 wow fadeInUp text-center" data-wow-delay="0.1s">
                    <img class="img-fluid" src="/resources/fo/img/c0002_1.png" alt="">
                </div>
                <div class="col-lg-6 wow fadeInUp" data-wow-delay="0.5s">
                	
                	<p class="fs-5 mb-0"><b>[ 에듀테크 기업 교육플랫폼 프로젝트 ]</b></p>
                	
                	<br>
                
                	<div class="h-100">
                        <p class="mb-2">
                        	<b>
                        		CONSULTING
                        	</b>
                        </p>
                        
                        <p>
                        	IOT BIG DATA를 분석하여 학습효과를 증대시키고,
                        	<br>
                        	학습 진도별 행동분석 및 진단을 통해 학습자의 효율적인 관리 
                        	<br> 
                        	시스템을 구성하도록 컨설팅 하였습니다.
						</p>
                        
                    </div>
                    
                    <div class="h-100">
                        <p class="mb-2">
                        	<b>
                        		SUMMARY
                        	</b>
                        </p>
                        
                        <p>
                        	학습자의 학습내용을 관리하고 분석하여 진단결과를 관리, 분석, 진단, 
                        	<br>
                        	솔루션을 제공하여 효율적인 학습결과를 제공하는 교육서비스 플랫폼 구축

						</p>
                        
                    </div>
                    
                    <div class="h-100">
                        <p class="mb-2">
                        	<b>
                        		ROLE
                        	</b>
                        </p>
                        
                        <p>
                        	기획,분석/설계, 구축
						</p>
                        
                    </div>
                    
                    <div class="h-100">
                        <p class="mb-2">
                        	<b>
                        		TECHNICAL
                        	</b>
                        </p>
                        
                        <p>
                        	<b>I.O.T</b>
                        	<br>
 							1)  Cloud 기반의 유연성과 확장성을 고려한 시스템 인프라 구축.
 							<br>
 							2)  IoT를 통하여 다양한 방식으로 수집된 데이터를 효율적으로 취합 및 활용이 
 							<br>
 							&nbsp;&nbsp;&nbsp;&nbsp;가능한 미들웨어 시스템 구축

 							<br>

						</p>
                        
                    </div>
                    
                     
                    
                </div>
                
             </div>
             
             
             <div class="row g-5 align-items-center IBM" style="padding-top:150px;">
        	 
        	 	
        	 
                <div class="col-lg-6 wow fadeInUp text-center" data-wow-delay="0.1s">
                    <img class="img-fluid" src="/resources/fo/img/c0003_1.png" alt="">
                    <img class="img-fluid" src="/resources/fo/img/c0003_2.png" alt="">
                </div>
                <div class="col-lg-6 wow fadeInUp" data-wow-delay="0.5s">
                	
                	<p class="fs-5 mb-0"><b>[ 스마트시티 TEST BED 구축 프로젝트 ]</b></p>
                	
                	<br>
                
                	<div class="h-100">
                        <p class="mb-2">
                        	<b>
                        		CONSULTING
                        	</b>
                        </p>
                        
                        <p>
                        	학습자의 행동 팬턴을 분석하여 제공하는 전반적인 UI 및 하드웨어 설치 및
                        	<br>
                        	네트워크 구축 , 보안까지 컨설팅 하였습니다.
						</p>
                        
                    </div>
                    
                    <div class="h-100">
                        <p class="mb-2">
                        	<b>
                        		SUMMARY
                        	</b>
                        </p>
                        
                        <p>
                        	오프라인 기숙학원을 기반으로 IoT, Smart Band 등을 활용하여 
                        	<br>
                        	학생의 데이터를 수집 활용하여 효과적인 학습관리를 제공하는 스마트캠퍼스 구축


						</p>
                        
                    </div>
                    
                    <div class="h-100">
                        <p class="mb-2">
                        	<b>
                        		ROLE
                        	</b>
                        </p>
                        
                        <p>
                        	기획, 분석/설계, 구축, 운영

						</p>
                        
                    </div>
                    
                    <div class="h-100">
                        <p class="mb-2">
                        	<b>
                        		TECHNICAL
                        	</b>
                        </p>
                        
                        <p>
                        	<b>I.O.T</b>
                        	<br>
 							1)  Cloud 기반의 유연성과 확장성을 고려한 시스템 인프라 구축.
 							<br>
 							2)  IoT를 통하여 다양한 방식으로 수집된 데이터를 효율적으로 취합 및 활용이 
 							<br>
 							&nbsp;&nbsp;&nbsp;&nbsp;가능한 미들웨어 시스템 구축

 							<br>

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