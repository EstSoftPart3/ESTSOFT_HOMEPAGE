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
</head>
<body class="hold-transition login-page">
<div class="login-box">
  <div class="login-logo">
  	<img alt="" src="/resources/img/logo.png" style="width:100px; height:100px;"><br>
    <a href="#" style="font-size: 20px;"><b>주식회사&nbsp;이에스티소프트 직원 로그인</b></a>
  </div>
  <!-- /.login-logo -->
  <div class="card">
    <div class="card-body login-card-body">
      <p class="login-box-msg"></p>

      <form action="#" method="post">
        <div class="input-group mb-3">
          <input type="email" class="form-control" id="emplyId"  placeholder="Admin Id">
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
              
            </div>
          </div>
          <!-- /.col -->
          <div class="col-4">
            <button type="button" class="btn btn-primary btn-block" onclick="memberLogin();">Login In</button>
          </div>
          <!-- /.col -->
        </div>
      </form>

      
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
        	 emplyPw : emplyPw
          },
         success: function(data) {
        	 
        	 console.log(data);
      	   	 var loginInfo = data.result.loginInfo;

      	 	if(loginInfo.length == 1) {
      	 		
      	 		bootbox.alert({
      				message: "로그인 성공했습니다.",
      				locale: 'kr',
      				callback: function() {
      					location.href = '/eep/board/notice/openNoticeBoardList.do';
      				} });

      	 	} else {
      	 		bootbox.alert({
      				message: "계정이 알맞지 않습니다.",
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
