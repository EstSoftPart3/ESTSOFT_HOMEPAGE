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
                    <h1 class="display-4 mb-3 animated slideInDown menu" style="font-weight: 700;">입사지원</h1>
                    
                    <p class="animated slideInDown IBM">
                    	저희 이에스티소프트는 성실함과 책임감으로 무장하고 있으며,
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
        	<center>
         	<div class="col-lg-7 col-md-6 wow fadeInUp " data-wow-delay="0.5s">
        			      
                   <div class="col-lg-6">
                    	<h4 class="display-3" style="font-size:30px;"><b>입사지원</b></h1>
                   </div>
                
                    <form>
                        <div class="row g-3">
                            <div class="col-12">
                                <div class="form-floating">
                                    <input type="text" class="form-control" id="name" placeholder="name" autocomplete="off" value="">
                                    <label for="name">성명</label>
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="form-floating">
                                    <input type="text" class="form-control" id="handphone" placeholder="handphone" autocomplete="off" value="">
                                    <label for="handphone">휴대폰</label>
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="form-floating">
                                    <input type="email" class="form-control" id="email" placeholder="email" autocomplete="off" value="">
                                    <label for="email">이메일</label>
                                </div>
                            </div>
                            
                            <div class="col-12">
                                <div class="form-floating">
                                    <textarea class="form-control" placeholder="Leave a message here" id="content" style="height: 250px"></textarea>
                                    <label for="content">자기소개(간략히)</label>
                                </div>
                            </div>
                            <div class="col-12">
                            	※ 개인정보 수집 및 이용동의
                            	<input type="checkbox" id="box1">
                            </div>
                             <div class="col-12">
                                <div class="form-floating">
                                    <textarea class="form-control" style="height: 150px;font-size:11px;">
1. 수집하는 개인정보 항목

​[입사지원-입사지원서 작성]

- 필수 : 이름(영문이름, 한문이름), 국적, 주소, 연락처(이메일주소, 핸드폰번호), 병역사항, 학력(학위구분, 재학기간, 전공, 전공학점), 공인외국어시험 성적, 경력사항, 자격증, 교육이수사항, 학내외활동, 역량기술서, 자기소개서

- 선택 : 없음 

[홈페이지 이용-자동생성]

접속기록(IP주소, 접속시간), 세션 쿠키 정보



2. 수집 및 이용 목적

​정보주체의 개인정보에 대한 처리(수집, 이용 등) 목적은 다음과 같습니다.

- 인재 채용 전형의 진행 및 전형 단계별 안내

 

3. 개인정보의 보유 및 이용 기간

1) 기초연은 법령에 따른 개인정보 보유∙이용기간 또는 정보주체로부터 개인정보를 수집시에 동의받은 개인정보 보유∙이용기간 내에서 개인정보를 처리∙보유하며, 개인정보의 처리 목적이 달성된 후에는 해당 정보를 지체 없이 파기 합니다. 

2) 개인정보 처리 및 보유 기간은 다음과 같으며, 아래 각 항목에 대하여 정보주체가 명시적으로 파기 요청을 하는 경우 지체없이 파기합니다.

- 입사 지원 정보 : 준영구 

​단, 통신비밀보호법의 규정에 의하여 정보주체의 인터넷 로그기록 및 접속지 추적자료는 3개월간 별도 보관합니다.


4. 동의를 거부할 권리 및 동의 거부에 따른 불이익

귀하는 개인정보의 수집‧이용에 동의를 거부할 권리가 있습니다. 그러나 동의를 거부할 경우 원활한 채용전형 진행을 할 수 없어 채용 및 선발전형에 지원이 제한될 수 있습니다.
                                    
                                    
                                    
                                    
                                    </textarea>
                                    
                                </div>
                            </div>
                            
                            <div class="col-12">
                                <button class="btn btn-secondary btn-lg" type="button" onclick="fn_sendmail();">입사지원</button>
                            </div>
                        </div>
                    </form>
                </div>
                
                </center>
                
            </div>   
        	            
        </div>
    </div>
    <!-- End -->
    
    <script>
    	function fn_sendmail(){
    		
    		//성명
    		var name 		= $("#name").val();
    		//휴대폰
    		var handphone 	= $("#handphone").val();
    		//이메일
    		var email 		= $("#email").val();
    		//자기소개
    		var content 	= $("#content").val();
    		
    		
    		if(name == ""){
    			alert("성명을 입력해 주세요.");
    			return false;
    		}
    		else if(handphone == ""){
    			alert("휴대폰 번호를 입력해 주세요.");
    			return false;
    		}
    		else if(email == ""){
    			alert("이메일 주소를 입력해 주세요.");
    			return false;
    		}
    		else if(content == ""){
    			alert("자기소개를 간략히 입력해 주세요.");
    			return false;
    		} else if (!$("input:checked[id='box1']").is(":checked")){ 
    			alert("개인정보 수집 및 이용동의에 체크해 주셔야 입사지원이 가능합니다.");
    			return false;
    		} else {
    			
    			
    			 if (!confirm("확인버튼을 누르면 입사지원이 완료 됩니다. 확인버튼을 클릭 후 잠시만 기달려주세요.")) {
    				 	return false;
    			 } else {
   			    	var params = {
   	    					name : name,
   	    					handphone : handphone,
   	    					email : email,
   	    					content : content
   	    			}
   	    				
   	    			$.ajax({
   	    				url: "/eep/sendmail.do",
   	    				type: "post",
   	    				data: params,
   	    				success: function(data){
   	    					alert("입시지원 되었습니다. 감사합니다.");
   	    		    		$("#name").val('');
   	    		    		$("#handphone").val('');
   	    		    		$("#email").val('');
   	    		    		$("#content").val('');
   	    		    		
   	    		    		$("input:checkbox[id='box1']").prop("checked", false);
   	    				}
   	    			});   			
    			 }

    		}
    		
    	}
    </script>
    
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