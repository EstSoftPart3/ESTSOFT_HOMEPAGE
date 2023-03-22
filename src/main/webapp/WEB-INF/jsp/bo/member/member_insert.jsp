<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>

<style type="text/css">
	#toolbar-container{ position: sticky; top: 185px;}
	
	input[readonly].classname{
 		 background-color:#ffffff;
	}
	 .LabelStyle
    {
    	background-color:#efefef;
    	width:100px;
    }	
    
</style>

<body class="hold-transition sidebar-mini">

	
	<div class="wrapper">
	
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		
		 <div class="content-wrapper">
		    
		     	<!-- Main content -->
	    		<section class="content">
    			 <div class="card-header">
	               	<h3 class="card-title bTitle">직원 등록</h3>
				</div>
				
				<form class="form-horizontal" name="form_member" id="form_member">
				
				<!-- 아이디 중복 체크 -->
				<input type="hidden" name="id_check_sucess" id="id_check_sucess" value="N">
				<!-- 닉네임 중복 체크 --> 
				<input type="hidden" name="ncknm_check_sucess" id="ncknm_check_sucess" value="N">
                
                <div class="card-body" style="background-color:#ffffff;">
                	
                	<div class="card-body table-responsive p-0" style="overflow:hidden;">
	              	   <hr>
	              	   <div class="form-group row">
		               		<label class="col-form-label sTitle LabelStyle" style="text-align: center;">권한</label>
                    		<div class="col-sm-3">
                    			<div class="btn-group btn-group-toggle" data-toggle="buttons">
                                   <label class="btn btn-secondary sTitle r1">
                    					<input type="radio" name="mbrAuthCd"  class="authSq sTitle" autocomplete="off" value="1" checked> 일반
                  					</label>
                  					<label class="btn btn-secondary sTitle r2 authSqShow">
                    					<input type="radio" name="mbrAuthCd" class="authSq sTitle " autocomplete="off" value="2"> 관리자
                  					</label>
                				</div>
                    		</div>
                    	</div>
                    	<hr>
		               <div class="form-group row">
		               		<label class="col-form-label sTitle LabelStyle" style="text-align: center;">아이디</label>
                    		<div class="col-sm-3">
                      			<input type="text" class="form-control sTitle classname" id="mbrId" name="mbrId" autocomplete="false" maxlength="50" >
                      		</div>
                    	</div>
                    	<hr>
		                <div class="form-group row">
		               		<label class="col-form-label sTitle LabelStyle" style="text-align: center;">비밀번호</label>
                    		<div class="col-sm-3">
                      			<input type="password" class="form-control sTitle classname" id="mbrPasswrd" name="mbrPasswrd" autocomplete="false" maxlength="50" >
                      		</div>
                      		<div class="col-sm-1" style=" vertical-align: middle;">
                      			<button type="button" class="btn btn-primary sTitle" id="keyShow" style="float:left;display:none">SHOW</button>
                      		</div>
                      	</div>
                      	<hr>
                      	<div class="form-group row">
                      		<label class="col-form-label sTitle LabelStyle" style="text-align: center;">비밀번호확인</label>
                    		<div class="col-sm-3">
                      			<input type="password" class="form-control sTitle classname" id="mbrPasswrdConfirm" name="mbrPasswrdConfirm" autocomplete="false" maxlength="50" >
                    		</div>
                    		<div class="col-sm-1" style=" vertical-align: middle;">
                      			<button type="button" class="btn btn-primary sTitle" id="keyShowConfirm" style="float:left;display:none">SHOW</button>
                      		</div>
                    	</div>
                  		<hr>
                  		<div class="form-group row">
                  			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">성명</label>
                    		<div class="col-sm-3">
                      			<input type="text" class="form-control sTitle classname" id="mbrNm" name="mbrNm" autocomplete="false" maxlength="50" >
                    		</div>
                    	</div>
                    	<hr>
                    	<div class="form-group row">
                    		<label class="col-form-label sTitle LabelStyle" style="text-align: center;">주민등록번호</label>
                    		<div class="col-sm-3">
                      			<input type="text" class="form-control sTitle classname" id="mbrRrn" name="mbrRrn" maxlength="14" >
                      		</div>
                    	</div>
                    	<hr>
                    	<div class="form-group row">
                    		<label class="col-form-label sTitle LabelStyle" style="text-align: center;">성별</label>
                    		<div class="col-sm-3">
                    			<div class="btn-group btn-group-toggle" data-toggle="buttons">
                                   <label class="btn btn-secondary sTitle">
                    					<input type="radio" name="mbrSexCd"  class="mbrSexCd sTitle" autocomplete="off" value="M" checked> 남
                  					</label>
                  					<label class="btn btn-secondary sTitle">
                    					<input type="radio" name="mbrSexCd" class="mbrSexCd sTitle" autocomplete="off" value="F"> 여
                  					</label>
                				</div>
                    		</div>
                  		</div>
                  		<hr>
                  		<div class="form-group row">
                    		<label class="col-form-label sTitle LabelStyle" style="text-align: center;">이메일</label>
                    		<div class="col-sm-3">
                      			<input type="text" class="form-control sTitle classname" id="mbrEmail" name="mbrEmail" autocomplete="false" maxlength="50" >
                    		</div>
                  		</div>
                  		<hr>
                  		<div class="form-group row">
		               		<label class="col-form-label sTitle LabelStyle" style="text-align: center;">휴대폰번호</label>
                    		<div class="col-sm-3">
                      			<input type="text" class="form-control sTitle classname" id="mbrPhNum" name="mbrPhNum" autocomplete="false" maxlength="13" >
                    		</div>
                    		
                  		</div>
                  		<hr>
                  		<div class="form-group row">
		               		<label class="col-form-label sTitle LabelStyle" style="text-align: center;">집주소</label>
                    		<div class="col-sm-5">
                      			<input type="text" class="form-control sTitle classname" id="mbrHomeAddr" name="mbrHomeAddr" autocomplete="false" maxlength="150" >
                      		</div>
                  		</div>
                  		<hr>
                  		<div class="form-group row">
                    		<label class="col-form-label sTitle LabelStyle" style="text-align: center;">사용여부</label>
                    		<div class="col-sm-3">
                      			<div class="btn-group btn-group-toggle" data-toggle="buttons">
                                   <label class="btn btn-secondary sTitle">
                    					<input type="radio" name="useYn" class="mbrSexCd sTitle" autocomplete="off" checked value="Y"> 사용
                  					</label>
                  					<label class="btn btn-secondary sTitle">
                    					<input type="radio" name="useYn" class="mbrSexCd sTitle" autocomplete="off" value="N"> 미사용
                  					</label>
                				</div>
                    		</div>
                  		</div>
                  		
                    </div>
                  
                </div>
                <!--card-body -->
                
                <!--card-footer -->
                <div class="card-footer" style="text-align:right">
                  <button type="button" class="btn btn-primary sTitle" onclick="history.back();">목록</button>
                  <button type="button" class="btn btn-info sTitle" onclick="memberInsert();">등록</button>
                </div>
                
              </form>
				
    		</section>
	    		
		 </div>
		
	</div>

   
   <%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
   

  
   
   <script>
 
	   //직원 가입 validation
	   function memberInsert() {
	   	
		    //직원 권한
		   	var mbrAuthCd = $('input[name="mbrAuthCd"]:checked').val();
		   	//직원 아이디
		   	var mbrId = $("#mbrId").val();
		   	//비밀번호
		   	var mbrPasswrd = $("#mbrPasswrd").val();
		   	//비밀번호 확인
		   	var mbrPasswrdConfirm = $("#mbrPasswrdConfirm").val();
		   	//성명
		   	var mbrNm = $("#mbrNm").val();
		   	//주민등록번호
		   	var mbrRrn = $("#mbrRrn").val();
		   	//이메일
		   	var mbrEmail = $("#mbrEmail").val();
		   	//휴대번호
		   	var mbrPhNum = $("#mbrPhNum").val();
		   	//성별
		   	var mbrSexCd = $('input[name="mbrSexCd"]:checked').val();
		   	//사용 유무
		   	var useYn = $('input[name="useYn"]:checked').val();
		   	//주소
		   	var mbrHomeAddr = $("#mbrHomeAddr").val();
		   	//직원 아이디 중복 체크 유무
		   	var id_check_sucess = $("#id_check_sucess").val();
		   	
		   	//아이디
		   	if(isEmpty(mbrId)) {
		   		bootbox.alert({
						 message: "아이디를 입력해 주세요.",
						 locale: 'kr',
						 callback: function() {
						 		$("#mbrId").focus();
					     } });
					 return false;
		   	} 
		   	
		   	//비밀번호
		   	if(isEmpty(mbrPasswrd)) {
		   		bootbox.alert({
						 message: "비밀번호를 입력해 주세요.",
						 locale: 'kr',
						 callback: function() {
						 		$("#mbrPasswrd").focus();
					     } });
					 return;
		   	}
		   	
		   	//비밀번호 확인
		   	if(isEmpty(mbrPasswrdConfirm)) {
		   		bootbox.alert({
						 message: "비밀번호 확인을 입력해 주세요.",
						 locale: 'kr',
						 callback: function() {
						 		$("#mbrPasswrdConfirm").focus();
					     } });
					 return;
		   	}
		   	
		   	//비밀번호.비밀번호확인 일치 체크
		   	if(mbrPasswrd != mbrPasswrdConfirm) {
		   		bootbox.alert({
						 message: "비밀번호가 일치 하지 않습니다. <br> 비밀번호 확인을 다시 입력해 주세요.",
						 locale: 'kr',
						 callback: function() {
							 $("#mbrPasswrdConfirm").val('');	
						 } });
		   		return;
		   	}
		   	
		   	//성명
		   	if(isEmpty(mbrNm)) {
		   		bootbox.alert({
						 message: "성명을 입력해 주세요.",
						 locale: 'kr',
						 callback: function() {
						 		$("#mbrNm").focus();
					     } });
					 return;
		   	}

		   	//이메일
// 		   	if(isEmpty(mbrEmail)) {
// 		   		bootbox.alert({
// 						 message: "이메일을 입력해 주세요.",
// 						 locale: 'kr',
// 						 callback: function() {
// 						 		$("#mbrEmail").focus();
// 					     } });
// 					 return;
// 		   	}
		   	
// 		   	//휴대번호
// 		   	if(isEmpty(mbrPhNum)) {
// 		   		bootbox.alert({
// 						 message: "휴대폰 번호를 입력해 주세요.",
// 						 locale: 'kr',
// 						 callback: function() {
// 						 		$("#mbrPhNum").focus();
// 					     } });
// 					 return;
// 		   	}
		   	
		   	//주소
		   	/* if(isEmpty(mbrHomeAddr)) {
		   		bootbox.alert({
						 message: "주소를 입력해 주세요.",
						 locale: 'kr',
						 callback: function() {
						 		$("#mbrHomeAddr").focus();
					     } });
					 return;
		   	} */
		   	        				
				var queryString = $("form[name=form_member]").serialize();
				
				$.ajax({
			           type: "post",
			           url: "/admin/member/memberInsertData.do",
			           data: queryString,
			           success: function(data) {
			        		   bootbox.alert({
									 message: "직원 등록이 완료 되었습니다.",
									 locale: 'kr',
									 callback: function() {
									 		location.href='/admin/member/memberList.do';
								} });
					   },
			           error: function(error) {
			        	   alert("직원 등록이 실패하였습니다. 다시 시도 해주세요.");
			        	   var errorJson = JSON.stringify(error);
			               console.log(errorJson);
			           }
				})
		}//직원 가입 end
	   
	   	
	   //Input Box Null Check
	   function isEmpty(str){
	       
	       if(typeof str == "undefined" || str == null || str == "")
	           return true;
	       else
	           return false ;
	   }
	   
	 //비밃번호 보이기
	 $("#mbrPasswrd").on("keyup", function(event) {
		  if (event.keyCode === 13) {
		    event.preventDefault();
		  } else {
		    if (this.value) {
		      $("#keyShow").css("display", "inline-block");
		    } else {
		      $("#keyShow").hide();
		    }
		  }
	});
	
	$("#keyShow").on("click", function() {
	 if ($("#mbrPasswrd").attr("type") == "password") {
	   $("#mbrPasswrd").attr("type", "text");
	   $($(this)).text("HIDE");
	 } else {
	   $("#mbrPasswrd").attr("type", "password");
	   $($(this)).text("SHOW");
	 }
	});
	
	//비밃번호 확인 보이기
	$("#mbrPasswrdConfirm").on("keyup", function(event) {
		  if (event.keyCode === 13) {
		    event.preventDefault();
		   
		  } else {
		    if (this.value) {
		      $("#keyShowConfirm").css("display", "inline-block");
		    } else {
		      $("#keyShowConfirm").hide();
		    }
		  }
	});
	
	$("#keyShowConfirm").on("click", function() {
	 if ($("#mbrPasswrdConfirm").attr("type") == "password") {
	   $("#mbrPasswrdConfirm").attr("type", "text");
	   $($(this)).text("HIDE");
	 } else {
	   $("#mbrPasswrdConfirm").attr("type", "password");
	   $($(this)).text("SHOW");
	 }
	});
	
	//아이디, 이메일 동기화
	$("#mbrId").keyup(function() { 
		var mbrId = $("#mbrId").val();
		$("#mbrEmail").val(mbrId);
	});
   
   </script>

 		
 	 
 
</body>
</html>