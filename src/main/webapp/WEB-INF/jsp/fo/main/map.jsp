<%@ page session="false" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
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
                    <h1 class="display-4 mb-3 animated slideInDown menu" style="font-weight: 700;">고객센터</h1>
                     <p class="animated slideInDown IBM">
                    	50여 명의 정직원 모두 성살함과 책임감으로 무장하고 있으며,
                    	<br>
						프로젝트 진행 시 소통이 뛰어난 진정한 전문가 그룹입니다.
					</p>
					
					<nav aria-label="breadcrumb animated slideInDown">
                        <ol class="breadcrumb mb-0 menu">
                            <li class="breadcrumb-item active" aria-current="page"><a href="/eep/faqPage.do">자주하는 질문</a></li>
                            <li class="breadcrumb-item"><a href="/eep/mapPage.do">오시는길</a></li>
                        </ol>
                    </nav>
                    
                </div>
                <div class="col-lg-6 animated fadeIn">
                    <img class="img-fluid animated pulse infinite" style="animation-duration: 3s;border-radius: 5%;" src="/resources/fo/img/4220129.jpg" alt="">
                </div>
            </div>
        </div>
    </div>
    <!-- Header End -->


    <!-- FAQs Start -->
    <div class="container-xxl py-5 menu">
        <div class="container">
            <div class="text-center mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 500px;">
                <h1 class="display-3" style="font-size:30px;">오시는길 </h1>
            </div>
            <div class="row justify-content-center">
                
                	    <!-- * 카카오맵 - 지도퍼가기 -->
								<!-- 1. 지도 노드 -->
								<div id="daumRoughmapContainer1669358842124" class="root_daum_roughmap root_daum_roughmap_landing"></div>
								
								<!--
									2. 설치 스크립트
									* 지도 퍼가기 서비스를 2개 이상 넣을 경우, 설치 스크립트는 하나만 삽입합니다.
								-->
								<script charset="UTF-8" class="daum_roughmap_loader_script" src="https://ssl.daumcdn.net/dmaps/map_js_init/roughmapLoader.js"></script>

								<!-- 3. 실행 스크립트 -->
								<script charset="UTF-8">
									new daum.roughmap.Lander({
										"timestamp" : "1669358842124",
										"key" : "2cqto",
										"mapWidth" : "900",
										"mapHeight" : "500"
									}).render();
								</script>
                
            </div>
        </div>
    </div>
    <!-- FAQs Start -->
    
    <%@ include file="/WEB-INF/include/footer.jspf" %>
</body>

</html>