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
                    <h1 class="display-4 mb-3 animated slideInDown"> <span class="menu" style="font-weight: 700;"><b>컨설팅</b></h1>
                    
                    <p class="animated slideInDown IBM">
                    	저희 이에스티소프트는 성실함과 책임감으로 무장하고 있으며,
                    	<br>
						프로젝트 진행 시 소통이 뛰어난 진정한 전문가 그룹입니다.
					</p>
					
					<nav aria-label="breadcrumb animated slideInDown">
                        <ol class="breadcrumb mb-0 menu">
<!--                             <li class="breadcrumb-item active" aria-current="page"><a href="/eep/consultPage.do">컨설팅 사례</a></li> -->
                            <li class="breadcrumb-item"><a href="/eep/consultPage.do">컨설팅 문의</a></li>
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
        <div class="container text-center menu">
        		<center>
        		
        	      <div class="col-lg-7 col-md-6 wow fadeInUp" data-wow-delay="0.5s">
        	      
                   <div class="col-lg-6">
                    	<h4 class="display-3" style="font-size:30px;"><b>컨설팅 문의</b></h1>
                   </div>
                
                    <form>
                        <div class="row g-3">
                            <div class="col-12">
                                <div class="form-floating">
                                    <input type="text" class="form-control" id="subject" placeholder="Subject">
                                    <label for="subject">제목</label>
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="form-floating">
                                    <input type="text" class="form-control" id="name" placeholder="Your Name">
                                    <label for="name">문의자명(기업명)</label>
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="form-floating">
                                    <input type="email" class="form-control" id="email" placeholder="Your Email">
                                    <label for="email">이메일</label>
                                </div>
                            </div>
                            
                            <div class="col-12">
                                <div class="form-floating">
                                    <textarea class="form-control" placeholder="Leave a message here" id="message" style="height: 250px"></textarea>
                                    <label for="message">문의내용</label>
                                </div>
                            </div>
                            <div class="col-12">
                                <button class="btn btn-secondary btn-sm" type="button">문의하기</button>
                            </div>
                        </div>
                    </form>
                </div>
                
                </center>
                
            </div>   
              
            
        </div>
    </div>
    <!-- End -->


    
    <%@ include file="/WEB-INF/include/footer.jspf" %>
    
</body>

</html>