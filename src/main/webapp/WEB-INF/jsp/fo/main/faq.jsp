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
                <h1 class="display-3" style="font-size:30px;">자주하는 질문</h1>
            </div>
            <div class="row justify-content-center">
                <div class="col-lg-10">
                
                                    
                    <div class="accordion" id="accordionExample">
                    
                      <div class="accordion-item wow fadeInUp" data-wow-delay="0.1s">
                            <h2 class="accordion-header" id="headingOne">
                                <button class="accordion-button" type="button" data-bs-toggle="collapse"
                                    data-bs-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                                    	Q.컨설팅 의뢰는 어떻게 하나요?
                                </button>
                            </h2>
                            <div id="collapseOne" class="accordion-collapse collapse show" aria-labelledby="headingOne"
                                data-bs-parent="#accordionExample">
                                <div class="accordion-body" style="padding-left:20px;">
                                   	A.컨설팅 의뢰는 상단 메뉴 컨설팅에서 컨설팅 의뢰를 해주시면 담당직원이 유선으로 연락드립니다.
                                </div>
                            </div>
                        </div>
                        
                        <div class="accordion-item wow fadeInUp" data-wow-delay="0.2s">
                            <h2 class="accordion-header" id="headingTwo">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
                                    data-bs-target="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo">
                                    	Q.신입사원(프로그램머) 대상 교육이 있을까요?
                                </button>
                            </h2>
                            <div id="collapseTwo" class="accordion-collapse collapse" aria-labelledby="headingTwo"
                                data-bs-parent="#accordionExample">
                                <div class="accordion-body" style="padding-left:20px;">
                                   A.On the Job Training(OJT)를 기본 2주간 진행 하고 있으며, 사원별 Case By Case Training을 하고 있습니다.
                                </div>
                            </div>
                        </div>
                        
                        <div class="accordion-item wow fadeInUp" data-wow-delay="0.3s">
                            <h2 class="accordion-header" id="headingThree">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
                                    data-bs-target="#collapseThree" aria-expanded="false" aria-controls="collapseThree">
                                    Q.SI란 무엇인가요?
                                </button>
                            </h2>
                            <div id="collapseThree" class="accordion-collapse collapse" aria-labelledby="headingThree"
                                data-bs-parent="#accordionExample">
                                <div class="accordion-body" style="padding-left:20px;">
                                    A.SI이란, 기업의 가치를 극대화시키는 정보시스템의 통합 구축으로 시스템의 기획 및 설계, 최적의 하드웨어 선정에서 발주 및 조달, 사용자의 필요에 맞춘 응용 소프트웨어의 개발, 시스템의 유지·보수 등을 포함한 시스템통합(system integration) 구축을 말합니다..
                                </div>
                            </div>
                        </div>
                    
                    </div>
                    
                </div>
            </div>
        </div>
    </div>
    <!-- FAQs Start -->
    
    <%@ include file="/WEB-INF/include/footer.jspf" %>
</body>

</html>