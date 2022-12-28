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
                    <h1 class="display-4 mb-3 animated slideInDown">EST EMPLOYMENT</h1>
                    
                    <p class="animated slideInDown IBM">
                    	50여 명의 정직원 모두 성살함과 책임감으로 무장하고 있으며,
                    	<br>
						프로젝트 진행 시 소통이 뛰어난 진정한 전문가 그룹입니다.
					</p>
					
					<nav aria-label="breadcrumb animated slideInDown">
                        <ol class="breadcrumb mb-0 menu">
                            <li class="breadcrumb-item active" aria-current="page"><a href="#">채용정보</a></li>
                            <li class="breadcrumb-item"><a href="#">입사지원</a></li>
                        </ol>
                    </nav>
                    
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
        <div class="container menu">
        
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
						웹개발자(신입,경력)
						<br>
						0명
					</td>
					<td style="vertical-align: middle;text-align:left;margin-left:100px;">
					- SI / SM 파견업무
					<br>
					- 솔루션 유지보수
					<br>
					- 시스템 개발 / 운영 및 유지보수 등
					</td>
					<td style="vertical-align: middle;">
						- 신입 / 경력 (년수 무관)
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff">
					<td>
					</td>
					<td>
					</td>
					<td>
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff">
					<td>
					</td>
					<td>
					</td>
					<td>
					</td>
				</tr>
				
			</tbody>
		</table>
        	            
        </div>
    </div>
    <!-- End -->


    
    <%@ include file="/WEB-INF/include/footer.jspf" %>
    
</body>

</html>