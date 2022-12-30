<%@ page session="false" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html lang="en">

<head>
   <%@ include file="/WEB-INF/include/header.jspf" %>
</head>

<style type="text/css">

th, td {
  border: 0px solid #e9ecef;
 }

</style>

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


    <!--Start -->
    <div class="container-xxl py-5 menu">
        <div class="container">
            <div class="text-center mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 500px;">
                <h1 class="display-3" style="font-size:20px;">공지사항 내용보기 </h1>
            </div>
           
           <table class="table table-bordered" style="max-width: 900px;font-size:15px;border-color:#ced4da" align="center">
		  	
				<tr style="text-align:center;background-color:#ffffff;">
					<td style="width:15%;background-color:#efefef;">
						<b>제목</b>
					</td>
					<td style="text-align:left;">
						본사 이전 공지
					</td>
				</tr>
				<tr style="text-align:center;background-color:#ffffff;">
					<td style="width:15%;background-color:#efefef;vertical-align: middle;">
						<b>내용</b>
					</td>
					<td style="text-align:left;">
<pre>
 ㈜이에스티소프트 본사 이전 공지
 안녕하세요. ㈜이에스티소프트 경영지원팀입니다.
 
 본사 이전 공지해 드립니다. 세부내용은 아래를 참고해 참고해주시기 바랍니다.

 일시 : 2022년 11월 28일 월요일부터
 현재주소 : 서울시 구로구 디지털로 242 현화비즈메트로 1차 1403호
 이전 후 주소 : 서울 영등포구 당산로 28길 4, 송원빌딩 3층
 
 문의사항은 오민형 이사님에게로 연락바랍니다.
</pre>
					</td>
				</tr>
				
				
			</tbody>
		</table>
		
		<br><br><br>
		<!-- 댓글 리스트 -->
		<div class="text-left mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 900px;">
             <h1 class="display-3" style="font-size:14px;"><b>※ 댓글 리스트</b></h1>
        </div>
        
		<table class="table table-bordered" style="max-width: 900px;font-size:14px;border-color:#ced4da" align="center">
			<tr style="background-color:#efefef;">
				<td colspan="3">
					<div style="float:left;width:80%">
						작성자 : 정서영
					</div>
					<div style="float:left">
						작성일 : 2023월 01월 01일
					</div>
				</td>
			</tr>
			<tr>
				<td colspan="2" style="height:70px;width:90%">
					댓글 테스트중 입니다.
				</td>
				<td style="vertical-align: middle;text-align:center;">
					<button type="button" class="btn btn-secondary btn-sm">수정</button>
					<br><br>
					<button type="button" class="btn btn-secondary btn-sm">삭제</button>
				</td>
			</tr>
		</table>
		<!-- 댓글 리스트 -->
		
		<!-- 댓글 입력 -->
		<div class="text-left mx-auto wow fadeInUp" data-wow-delay="0.1s" style="max-width: 900px;padding-top:30px;">
             <h1 class="display-3" style="font-size:14px;"><b>※ 댓글 입력</b></h1>
        </div>
		<table class="table table-bordered" style="max-width: 900px;font-size:15px;border-color:#ced4da" align="center">
			<tr>
				<td style="width:90%">
					<textarea class="form-control" id="exampleFormControlTextarea2" rows="7" style="font-size:12px;height:70px;">
					</textarea>
				</td>
				<td style="vertical-align: middle;border-right-style: none;">
					<button type="button" class="btn btn-secondary btn-lg">확인</button>
				</td>
			</tr>
		</table>
        <!-- 댓글 입력 -->
           
        </div>
        
         <div class="col-12 text-center" style="padding-top:15px;">
         	 <button type="button" class="btn btn-secondary btn-sm">답글</button>
         	 <button type="button" class="btn btn-secondary btn-sm" onclick="fn_list_move();">리스트</button>
         	 <button type="button" class="btn btn-secondary btn-sm" onclick="fn_list_update();">수정</button>
         	 <button type="button" class="btn btn-secondary btn-sm">삭제</button>
         </div>
    </div>
    <!-- FAQs Start -->
    
    <%@ include file="/WEB-INF/include/footer.jspf" %>
    
    <script>
		function fn_list_move(){
			location.href = '/eep/boardList.do';
		}
		
		function fn_list_update(){
			location.href = '/eep/boardUpdate.do';
		}
    </script>
    
    
</body>

</html>