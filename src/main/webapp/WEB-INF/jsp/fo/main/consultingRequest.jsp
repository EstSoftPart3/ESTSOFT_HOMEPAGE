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
                    	업무 분석부터 시스템 구축·운영까지 고객과 함께 고민합니다.
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
                                    <label for="subject">제목 *</label>
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="form-floating">
                                    <input type="text" class="form-control" id="name" placeholder="Your Name">
                                    <label for="name">문의자명(기업명) *</label>
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="form-floating">
                                    <input type="email" class="form-control" id="email" placeholder="Your Email">
                                    <label for="email">이메일 *</label>
                                </div>
                            </div>
                            
                            <div class="col-12">
                                <div class="form-floating">
                                    <textarea class="form-control" placeholder="Leave a message here" id="message" style="height: 250px"></textarea>
                                    <label for="message">문의 내용 *</label>
                                </div>
                            </div>
                            <%-- 사람에게 안 보이는 칸: 봇이 채우면 서버가 버린다 --%>
                            <input type="text" id="hp" tabindex="-1" autocomplete="off" aria-hidden="true" style="position:absolute;left:-9999px;width:1px;height:1px;">
                            <div class="col-12 text-start">
                                <div class="fo-consent">
                                    <b>개인정보 수집·이용 안내</b>
                                    <ul>
                                        <li>수집 항목: 문의자명(기업명), 이메일</li>
                                        <li>이용 목적: 컨설팅 문의 확인과 답변</li>
                                        <li>보관 기간: 답변을 마친 뒤 지체 없이 파기</li>
                                        <li>동의하지 않을 수 있으며, 이 경우 문의를 보낼 수 없습니다.</li>
                                    </ul>
                                </div>
                                <label class="mt-2"><input type="checkbox" id="agree"> [필수] 개인정보 수집·이용에 동의합니다</label>
                            </div>
                            <div class="col-12">
                                <button class="btn btn-primary px-5" type="button" id="sendBtn" onclick="fn_consult();">문의 보내기</button>
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
    <script>
    function fn_consult() {
    	var d = { subject: $('#subject').val(), name: $('#name').val(), email: $('#email').val(), message: $('#message').val(), hp: $('#hp').val(), agree: $('#agree').is(':checked') ? 'Y' : '' };
    	if (!$.trim(d.subject) || !$.trim(d.name) || !$.trim(d.email) || !$.trim(d.message)) { bootbox.alert('* 표시한 칸을 모두 적어 주세요.'); return; }
    	if (!d.agree) { bootbox.alert('개인정보 수집·이용에 동의해 주세요.'); return; }
    	var $b = $('#sendBtn').prop('disabled', true);
    	$.post('/eep/consultRequest.do', d).done(function (res) {
    		$b.prop('disabled', false);
    		if (res.error) { bootbox.alert(res.error); return; }
    		$('#subject,#name,#email,#message').val(''); $('#agree').prop('checked', false);
    		bootbox.alert('문의가 접수되었습니다. 확인 후 이메일로 연락드리겠습니다.');
    	}).fail(function () { $b.prop('disabled', false); bootbox.alert('보내지 못했습니다. 잠시 뒤 다시 시도해 주세요.'); });
    }
    </script>
    
</body>

</html>