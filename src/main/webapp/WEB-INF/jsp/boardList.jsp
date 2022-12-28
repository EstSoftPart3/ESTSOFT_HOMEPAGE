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
                    <h1 class="display-4 mb-3 animated slideInDown">EST COMMUNITY</h1>
                     <p class="animated slideInDown IBM">
                    	50여 명의 정직원 모두 성살함과 책임감으로 무장하고 있으며,
                    	<br>
						프로젝트 진행 시 소통이 뛰어난 진정한 전문가 그룹입니다.
					</p>
					
					<nav aria-label="breadcrumb animated slideInDown">
                        <ol class="breadcrumb mb-0 menu">
                            <li class="breadcrumb-item"><a href="#">공지사항</a></li>
                            <li class="breadcrumb-item"><a href="#">자유게시판</a></li>
                            <li class="breadcrumb-item"><a href="#">기술문의</a></li>
                            <li class="breadcrumb-item"><a href="#">교육일정</a></li>
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


    <!-- FAQs Start -->
    <div class="container-xxl py-5 menu">
        <div class="container">
            <div class="text-center mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 500px;">
                <h1 class="display-3" style="font-size:20px;">공지사항 리스트</h1>
            </div>
           
           <table class="table" style="max-width: 900px;" align="center">
		  	<thead style="background-color:#efefef">
		  		<tr align="center">
					<th>번호</th>
					<th style="width:70%">제목</th>
					<th>입력일</th>
				</tr>
			</thead>
			<tbody style="font-weight:bold;">
				<tr style="text-align:center;background-color:#ffffff;">
					<td>
						10
					</td>
					<td style="text-align:left;">
						<a href="/eep/boardContent.do">본사 이전 공지</a>
					</td>
					<td>
						2022-10-20
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td>
						9
					</td>
					<td style="text-align:left;">
						2022년 직장인 건강검진 공지
					</td>
					<td>
						2022-10-20
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td>
						8
					</td>
					<td style="text-align:left;">
						본사 개발팀 딜링아트(미술품경매) 시스템 구축 완료
					</td>
					<td>
						2022-10-20
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td>
						7
					</td>
					<td style="text-align:left;">
						EST 직원 전용 공지사항을 오픈했습니다
					</td>
					<td>
						2022-10-20
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td>
						6
					</td>
					<td style="text-align:left;">
						EST 직원 전용 공지사항을 오픈했습니다
					</td>
					<td>
						2022-10-20
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td>
						5
					</td>
					<td style="text-align:left;">
						EST 직원 전용 공지사항을 오픈했습니다
					</td>
					<td>
						2022-10-20
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td>
						4
					</td>
					<td style="text-align:left;">
						EST 직원 전용 공지사항을 오픈했습니다
					</td>
					<td>
						2022-10-20
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td>
						3
					</td>
					<td style="text-align:left;">
						EST 직원 전용 공지사항을 오픈했습니다
					</td>
					<td>
						2022-10-20
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td>
						2
					</td>
					<td style="text-align:left;">
						EST 직원 전용 공지사항을 오픈했습니다
					</td>
					<td>
						2022-10-20
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td>
						1
					</td>
					<td style="text-align:left;">
						EST 직원 전용 공지사항을 오픈했습니다
					</td>
					<td>
						2022-10-20
					</td>
				</tr>
				
			</tbody>
		</table>
           
        </div>
    </div>
    <!-- FAQs Start -->
    
    <%@ include file="/WEB-INF/include/footer.jspf" %>
</body>

</html>