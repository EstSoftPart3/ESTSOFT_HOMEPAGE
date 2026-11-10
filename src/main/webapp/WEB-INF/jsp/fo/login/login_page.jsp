<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>주식회사 이에스티소프트</title>
  <!-- Tell the browser to be responsive to screen width -->
  <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="shortcut icon" href="/resources/img/favicon.ico">
  <link rel="icon" href="/resources/img/favicon.ico">

  <!-- Font Awesome -->
  <link rel="stylesheet" href="/resources/bo/plugins/fontawesome-free/css/all.min.css">
  <!-- Ionicons -->
  <link rel="stylesheet" href="https://code.ionicframework.com/ionicons/2.0.1/css/ionicons.min.css">
  <!-- icheck bootstrap -->
  <link rel="stylesheet" href="/resources/bo/plugins/icheck-bootstrap/icheck-bootstrap.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="/resources/bo/dist/css/adminlte.min.css">
  <!-- Google Font: Source Sans Pro -->
  <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700" rel="stylesheet">
  <style>
    .join-line { border-top:1px solid #dde4ea; margin:14px 0 0; padding-top:12px; text-align:center; font-size:14px; color:#5a6670; }
    .join-line a { color:#0b6e8a; font-weight:600; text-decoration:underline; text-underline-offset:2px; }
  </style>
</head>
<body class="hold-transition login-page">
<div class="login-box">
  <div class="login-logo">
  	<a href="/eep/mainPage.do" style="font-size: 20px;">
  		<img alt="" src="/resources/img/logo.png" style="width:100px; height:100px;"><br>
  		<b>주식회사&nbsp;이에스티소프트 직원 로그인</b>
    </a>
  </div>
  <!-- /.login-logo -->
  <div class="card">
    <div class="card-body login-card-body">
      <p class="login-box-msg"></p>

      <form action="#" method="post">
        <div class="input-group mb-3">
          <input type="email" class="form-control" id="emplyId"  placeholder="Admin Id" value="<c:out value='${savedId}'/>">
          <div class="input-group-append">
            <div class="input-group-text">
              <span class="fas fa-envelope"></span>
            </div>
          </div>
        </div>
        <div class="input-group mb-3">
          <input type="password" class="form-control" id="emplyPw" placeholder="Password">
          <div class="input-group-append">
            <div class="input-group-text">
              <span class="fas fa-lock"></span>
            </div>
          </div>
        </div>
        <div class="row">
          <div class="col-8">
            <div class="icheck-primary">
              <input type="checkbox" id="saveId" ${empty savedId ? '' : 'checked'}>
              <label for="saveId" style="font-weight:normal; font-size:14px;">아이디 저장</label>
            </div>
            <div class="icheck-primary">
              <input type="checkbox" id="autoLogin" ${savedAutoCheck ? 'checked' : ''}>
              <label for="autoLogin" style="font-weight:normal; font-size:14px;">자동로그인 (7일)</label>
            </div>
          </div>
          <!-- /.col -->
          <div class="col-4">
            <button type="button" class="btn btn-primary btn-block" onclick="memberLogin();">Login In</button>
          </div>
          <!-- /.col -->
        </div>
      </form>

      <p class="join-line">직원이시면 <a href="/eep/signup/page.do">여기서 가입 신청</a>하세요.</p>

      <!-- /.social-auth-links -->

    </div>
    <!-- /.login-card-body -->
  </div>
</div>
<!-- /.login-box -->

<!-- jQuery -->
<script src="/resources/bo/plugins/jquery/jquery.min.js"></script>
<!-- Bootstrap 4 -->
<script src="/resources/bo/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- AdminLTE App -->
<script src="/resources/bo/dist/js/adminlte.min.js"></script>

 <script>

  function memberLogin() {
	 var emplyId = $("#emplyId").val();
	 var emplyPw = $("#emplyPw").val();

	 if(isEmpty(emplyId)) {
	  	bootbox.alert({
			message: "아이디를 입력해 주세요.",
			locale: 'kr',
			callback: function() {
				$("#emplyId").focus();
			} });
		return;
	 }

	 if(isEmpty(emplyPw)) {
		 bootbox.alert({
			message: "비밀번호를 입력해 주세요.",
			locale: 'kr',
			callback: function() {
				$("#emplyPw").focus();
			} });
		return;
	 }


	 $.ajax({
         type: "post",
         url: "/eep/login/loginData.do",
         data: {
        	 emplyId : emplyId,
        	 emplyPw : emplyPw,
        	 saveId : $("#saveId").is(":checked") ? "Y" : "N",
        	 autoLogin : $("#autoLogin").is(":checked") ? "Y" : "N"
          },
         success: function(data) {

        	 console.log(data);
      	   	 var loginInfo = data.result.loginInfo;

      	 	if(loginInfo.length == 1 && loginInfo[0].pwInitYn == 'R') {

      	 		// 본인 가입 계정은 변경을 권고만 한다. 관리자 발급 계정(Y)은 인터셉터가 변경을 강제한다
      	 		bootbox.dialog({
      				title: "비밀번호를 변경해 주세요",
      				message: "아직 초기 비밀번호를 사용 중입니다. 계정 보호를 위해 변경을 권고합니다.",
      				closeButton: false,
      				buttons: {
      					later: { label: "다음에 하기", className: "btn-default", callback: goAfterLogin },
      					change: { label: "변경하러 가기", className: "btn-primary", callback: function() { location.href = '/eep/account/changePassword.do'; } }
      				} });

      	 	} else if(loginInfo.length == 1) {

      	 		bootbox.alert({
      				message: "로그인 성공했습니다. 메인 페이지로 되돌아갑니다.",
      				locale: 'kr',
      				callback: goAfterLogin });

      	 	} else {
      	 		bootbox.alert({
      				message: "아이디 또는 비밀번호가 올바르지 않습니다.",
      				locale: 'kr',
      				callback: function() {
      					location.href = '/eep/login/loginPage.do';
      				} });
      	 	}



         },
         error: function(error) {
      	   var errorJson = JSON.stringify(error);
             console.log(errorJson);
         }
	})

  }

  // 장비 확인이나 증서 서명이 남아 있으면 내 장비로 보낸다. 조회가 실패해도 로그인은 막지 않는다
  function goAfterLogin() {
	  $.post('/eep/equipment/pendingData.do', function(res) {
		  location.href = res.count > 0 ? '/eep/equipment/myEquipment.do' : '/eep/mainPage.do';
	  }).fail(function() { location.href = '/eep/mainPage.do'; });
  }

//Input Box Null Check
  function isEmpty(str){

      if(typeof str == "undefined" || str == null || str == "")
          return true;
      else
          return false ;
  }

 </script>

<script src="/resources/bo/plugins/bootbox/bootbox.all.min.js"></script>
<script src="/resources/bo/plugins/bootbox/bootbox.locales.js"></script>
</body>
</html>
