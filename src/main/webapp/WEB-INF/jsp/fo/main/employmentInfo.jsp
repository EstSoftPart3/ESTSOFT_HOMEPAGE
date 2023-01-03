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
    <div class="container-fluid hero-header bg-light">
        <div class="container py-5">
            <div class="row g-5 align-items-center">
                <div class="col-lg-6">
                    <h1 class="display-4 mb-3 animated slideInDown menu" style="font-weight: 700;">채용정보</h1>
                    
                    <p class="animated slideInDown IBM">
                    	50여 명의 정직원 모두 성살함과 책임감으로 무장하고 있으며,
                    	<br>
						프로젝트 진행 시 소통이 뛰어난 진정한 전문가 그룹입니다.
					</p>
					
					<nav aria-label="breadcrumb animated slideInDown">
                        <ol class="breadcrumb mb-0 menu">
                            <li class="breadcrumb-item active" aria-current="page"><a href="/eep/employmentInfoPage.do">채용정보</a></li>
                            <li class="breadcrumb-item"><a href="/eep/employmentRequestPage.do">입사지원</a></li>
                        </ol>
                    </nav>
                    
                </div>
                <div class="col-lg-6 animated fadeIn">
                    <img class="img-fluid animated pulse infinite" style="animation-duration: 3s;border-radius: 5%;" src="/resources/fo/img/DSC03079.jpg" alt="">
                </div>
            </div>
        </div>
    </div>
    <!-- Header End -->


    <!-- Start -->
    <div class="container-xxl py-5">
        <div class="container menu">
        
         <div class="text-left mx-auto wow fadeInUp" data-wow-delay="0.1s">
                <h1 class="fs-5 mb-5"><b>내일을 만들어갈 열정과 힘이 있는 인재를  기다립니다</b></h1>
                <p class="text-primary fs-5 mb-5">
                	(주)이에스티소프트는 e-Biz 구현을 위한 IT Consulting System Integration 전문 회사로 다양한 서비스 기반의 최적화된
                	<br>
					 솔루션을 보유하고 있으며, 다수의 고객과 관련 기업에 웹 서비스 및 솔루션등을 구축, 운영하고 있습니다.
				</p>
         </div>
        
         <table class="table">
		  	<thead style="background-color:#efefef">
		  		<tr align="center" style="height:50px;">
					<th style="vertical-align: middle;">모집분야</th>
					<th style="vertical-align: middle;">담당업무</th>
					<th style="vertical-align: middle;">지원자격</th>
				</tr>
			</thead>
			<tbody style="font-weight:bold;">
				<tr style="text-align:center;background-color:#ffffff;">
					<td style="vertical-align: middle;">
						웹개발자
						<br>
						(신입,경력)
						<br>
						0명
					</td>
					<td style="vertical-align: middle;text-align:left;">
					- SI / SM 파견업무
					<br>
					- 솔루션 유지보수
					<br>
					- 시스템 개발 / 운영 및 유지보수 등
					</td>
					<td style="vertical-align: middle;text-align:left;">
						- 신입 / 경력 (년수 무관)
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff">
					<td style="vertical-align: middle;">
						클라우드 엔지니어
						<br>
						(경력)
						<br>
						0명
					</td>
					<td style="vertical-align: middle;text-align:left;">
						- 사내 시스템 인프라 운영 및 유지보수
						- 외부사업 인프라 설계 및 구축 / 운영
					</td>
					<td style="vertical-align: middle;text-align:left;">
						- 네트워크 기본 지식 보유자
						- AWS / GCP / AZURE/NAVER 등 클라우드 환경 경험자
						
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff">
					<td style="vertical-align: middle;">
						블록체인 개발자
						<br>
						(경력)
						<br>
						0명
						
					</td>
					<td style="vertical-align: middle;text-align:left;">
						- 블록체인 API연동<br>- 블록체인 인터페이스 개발
						
					</td>
					<td style="vertical-align: middle;text-align:left;">
						- 블록체인 개발 경력자<br>- 블록체인에 대한 기본이해도 보유자
						
					</td>
				</tr>
				
				<tr style="text-align:center;background-color:#ffffff">
					<td style="vertical-align: middle;">
						빅데이터 엔지니어
						<br>
						(경력)
						<br>
						0명
						
					</td>
					<td style="vertical-align: middle;text-align:left;">
						- 빅데이터 설계 및 구축 / 운영
						<br>
						- 빅데이터 솔루션 운영 및 유지보수
						
					</td>
					<td style="vertical-align: middle;text-align:left;">
						- 관련 업무 경험자
						
					</td>
				</tr>
				
			</tbody>
		</table>
        	            
        </div>
    </div>
    <!-- End -->
    
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
    <!--TEAM End -->


    
    <%@ include file="/WEB-INF/include/footer.jspf" %>
    
</body>

</html>