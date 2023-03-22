<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>

<body class="hold-transition sidebar-mini">

<style>
	.editable-container,
	.toolbar-container {
		position: relative;
		border: 1px solid #ddd;
		background: #eee;
	}

	.toolbar-container {
		padding: 1em;
	}

	.editable-container {
		padding: 3em;
		overflow-y: scroll;
		max-height: 500px;
	}

	.editable-container .document-editor__editable.ck-editor__editable {
		min-height: 21cm;
		padding: 2em;
		border: 1px #D3D3D3 solid;
		border-radius: var(--ck-border-radius);
		background: white;
		box-shadow: 0 0 5px rgba(0, 0, 0, 0.1);
	}
	input[readonly].classname{
 		 background-color:#ffffff;
	}
	 .LabelStyle
    {
    	background-color:#efefef;
    	width:100px;
    }	
   
</style>

	<div class="wrapper">
	
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		
		 <div class="content-wrapper">
		    
		     	<!-- Main content -->
	    		<section class="content">
    			 <div class="card-header">
	               	<h3 class="card-title bTitle">직원 수정</h3>
				</div>
				
				<form class="form-horizontal" name="form_member" id="form_member">
				
				<input type="hidden" name="mbrSq" value="<c:out value="${param.mbrSqParam}" />">
				
                <div class="card-body" style="background-color:#ffffff;">
                	
                	<div class="card-body table-responsive p-0" style="overflow:hidden;">
                		<hr>
                    	<div class="form-group row">
                    		<label class="col-form-label sTitle LabelStyle" style="text-align: center;">권한</label>
                    		<div class="col-sm-3">
                    			<div class="btn-group btn-group-toggle" data-toggle="buttons">
                                   <label class="btn btn-secondary sTitle r1">
                    					<input type="radio" name="authSq"  class="authSq sTitle" autocomplete="off" value="1"> 일반
                  					</label>
                  					<label class="btn btn-secondary sTitle r2 authSqShow">
                    					<input type="radio" name="authSq" class="authSq sTitle " autocomplete="off" value="2"> 관리자
                  					</label>
                				</div>
                    		</div>
                  		</div>
	              	   <hr>
		               <div class="form-group row">
		               		<label class="col-form-label sTitle LabelStyle" style="text-align: center;">아이디</label>
                    		<div class="col-sm-3">
                      			<input type="text" class="form-control sTitle classname" id="mbrId" name="mbrId" maxlength="50" >
                      		</div>
                    	</div>
                    	<hr>
                  		<div class="form-group row">
                  			<label class="col-form-label sTitle LabelStyle" style="text-align: center;">성명</label>
                    		<div class="col-sm-3">
                    		
                    		<input type="text" class="form-control sTitle classname" id="mbrNm" name="mbrNm" maxlength="50" >
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
                                   <label class="btn btn-secondary sTitle sm">
                    					<input type="radio" name="mbrSexCd"  class="mbrSexCd sTitle" autocomplete="off" value="M"> 남
                  					</label>
                  					<label class="btn btn-secondary sTitle sf">
                    					<input type="radio" name="mbrSexCd" class="mbrSexCd sTitle" autocomplete="off" value="F"> 여
                  					</label>
                				</div>
                    		</div>
                  		</div>
                  		<hr>
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
                                   <label class="btn btn-secondary sTitle useY">
                    					<input type="radio" name="useYn" class="sTitle" autocomplete="off" value="Y"> 사용
                  					</label>
                  					<label class="btn btn-secondary sTitle useN">
                    					<input type="radio" name="useYn" class="sTitle" autocomplete="off" value="N"> 미사용
                  					</label>
                				</div>
                			</div>
                  		</div>
                  		<hr>
                  		<div class="form-group row">
		               		<label class="col-form-label sTitle LabelStyle" style="text-align: center;">비밀번호</label>
                    		<div class="col-sm-5">
                    			<button type="button" class="btn btn-primary sTitle" onclick="fn_passwdClear();">초기화</button>
                    			<span> 초기화 된 비밀번호 : a123456!</span>
                    		</div>
                  		</div>
                  		
                    </div>
                  
                </div>
                <!--card-body -->
                
                <!--card-footer -->
                <div class="card-footer" style="text-align:right">
                  <button type="button" class="btn btn-primary sTitle" onclick="history.back();">목록</button>
                  <button type="button" class="btn btn-info sTitle" onclick="memberUpdate();">수정</button>
                </div>
                
              </form>
				
    		</section>
	    		
		 </div>
		
	</div>

   
   <%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
   
   <script>
	

   var dataContent = {};
	var mbrSq = '<c:out value="${param.mbrSqParam}" />';
  
	$(document).ready(function(){
		
		memberContentData(mbrSq);
		
	});
	
	//회원 정보 호출
	function memberContentData(mbrSq) {
		
		console.log("mbrSq : "+ mbrSq);
		
		$.ajax({
	           type: "post",
	           url: "/admin/member/memberContentData.do",
	           data: {
	        	   mbrSq : mbrSq
	            },
	           success: function(data) {
	        	    
	        	 dataContent = data.memberContentData.memberContent[0];
	        	 
	        	 console.log(dataContent);
	        	 var mbrNm = dataContent.mbrNm						//이름
	        	 var mbrId = dataContent.mbrId						//아이디
	        	 var mbrEmail = dataContent.mbrEmail				//이메일
	        	 var mbrSexCdChk = dataContent.mbrSexCd			    //성별
	        	 var mbrPhNum = dataContent.mbrPhNum				//휴대폰번호
	        	 var mbrHomeAddr = dataContent.mbrHomeAddr			//집주소
	        	 var useYn = dataContent.useYn						//사용여부
	        	 var authSq = dataContent.mbrAuthCd					//권한 구분
	        	 var mbrRrn = dataContent.mbrRrn					//주민등록번호
	        	 
	        	 
	        	 if(authSq == '일반') { //직원 권한
	        		 $(":radio[name='authSq'][value='1']").attr('checked', true);
	        		 $('.r1').addClass('active');
		        	 $('.r2').removeClass('active');
		        	 $('.r3').removeClass('active');
		        	 $('.r4').removeClass('active');
		         } 
	        	 if(authSq == '관리자') {
		        	 $(":radio[name='authSq'][value='2']").attr('checked', true);
		        	 $('.r1').removeClass('active');
		        	 $('.r2').addClass('active');
		        	 $('.r3').removeClass('active');
		        	 $('.r4').removeClass('active');
				 }
	        	 
	        	 if(mbrSexCdChk == '남') { //직원 성별
	        		 $(":radio[name='mbrSexCd'][value='M']").attr('checked', true);
	        		 $('.sm').addClass('active');
		        	 $('.sf').removeClass('active');
		         } else {
		         	 $(":radio[name='mbrSexCd'][value='F']").attr('checked', true);
		         	 $('.sf').addClass('active');
		        	 $('.sm').removeClass('active');
				 }
	        	 
	        	 if(useYn == '사용중') { //직원 사용여부
	        		$(":radio[name='useYn'][value='Y']").attr('checked', true);
	        		$('.useY').addClass('active');
	        		$('.useN').removeClass('active');
	        	 } else {
	        		$(":radio[name='useYn'][value='N']").attr('checked', true);
	        		$('.useN').addClass('active');
	        		$('.useY').removeClass('active');
				 }
	        	 
	        	 $("#mbrNm").val(mbrNm); //직원 이름
	        	 $("#mbrId").val(mbrId); // 직원 아이디
	        	 $("#mbrEmail").val(mbrEmail); //직원 이메일
	        	 $("#mbrRrn").val(mbrRrn); // 직원 주민번호
	        	 $("#mbrPhNum").val(mbrPhNum); //직원 핸드폰번호
	        	 $("#mbrHomeAddr").val(mbrHomeAddr); // 직원 집주소
				
	           },
	           error: function(error) {
	        	   var errorJson = JSON.stringify(error);
	               console.log(errorJson);
	           }
		})
	}
		
	    
   //직원 수정 validation
   function memberUpdate() {
   	
	   	//권한구분
	   	var authSq = $('input[name="authSq"]:checked').val();
	   	//아이디
	   	var mbrId = $("#mbrId").val();
	   	//성명
	   	var mbrNm = $("#mbrNm").val();
	   	//이메일
	   	var mbrEmail = $("#mbrEmail").val();
	   	//주민등록번호
	   	var mbrRrn = $("#mbrRrn").val();
	   	//휴대번호
	   	var mbrPhNum = $("#mbrPhNum").val();
	   	//성별
	   	var mbrSexCd = $('input[name="mbrSexCd"]:checked').val();
	   	//사용 유무
	   	var useYn = $('input[name="useYn"]:checked').val();
	   	//주소
	   	var mbrHomeAddr = $("#mbrHomeAddr").val();
	   	
// 	   	//이메일
// 	   	if(isEmpty(mbrEmail)) {
// 	   		bootbox.alert({
// 					 message: "이메일을 입력해 주세요.",
// 					 locale: 'kr',
// 					 callback: function() {
// 					 		$("#mbrEmail").focus();
// 				     } });
// 				 return;
// 	   	}
// 	   	//휴대번호
// 	   	if(isEmpty(mbrPhNum)) {
// 	   		bootbox.alert({
// 					 message: "휴대폰 번호를 입력해 주세요.",
// 					 locale: 'kr',
// 					 callback: function() {
// 					 		$("#mbrPhNum").focus();
// 				     } });
// 				 return;
// 	   	}

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
		
		var queryString = $("form[name=form_member]").serialize();
		
		console.log(queryString);
		$.ajax({
	           type: "post",
	           url: "/admin/member/memberUpdateData.do",
	           data: queryString,
	           success: function(data) {
	        	   bootbox.alert({
						 message: "회원정보 수정이 완료 되었습니다.",
						 locale: 'kr',
						 callback: function() {
							 	memberContent();
					     } });
			   },
	           error: function(error) {
	        	   alert("수정에 실패하였습니다. 다시 시도 해주세요.");
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
   
	//회원 상세정보 이동
	function memberContent() {
		
		var mbrSq = '<c:out value="${param.mbrSqParam}" />';
		
		let param = {
			mbrSqParam : mbrSq
		}
	
		var contentUrl = "/admin/member/memberContent.do";
		postForm(contentUrl, param);
		
	}
		   		
	function postForm(path, params, method) {
	    method = method || 'post';

	    var form = document.createElement('form');
	    form.setAttribute('method', method);
	    form.setAttribute('action', path);

	    for (var key in params) {
	        if (params.hasOwnProperty(key)) {
	            var hiddenField = document.createElement('input');
	            hiddenField.setAttribute('type', 'hidden');
	            hiddenField.setAttribute('name', key);
	            hiddenField.setAttribute('value', params[key]);

	            form.appendChild(hiddenField);
	        }
	    }

	    document.body.appendChild(form);
	    form.submit();
	}

	//비밀번호 초기화
	function fn_passwdClear() {
		
		console.log("mbrSq : "+ mbrSq);
		
		$.ajax({
	           type: "post",
	           url: "/admin/member/memberPasswdClear.do",
	           data: {
	        	   mbrSq : mbrSq
	            },
	           success: function(data) {
	        	   bootbox.alert({
						 message: "비밀번호 초기화가 완료 되었습니다.",
						 locale: 'kr' 
	        	   });
			   },
	           error: function(error) {
	        	   var errorJson = JSON.stringify(error);
	               console.log(errorJson);
	           }
		})
	}

		
   </script>
 
 
 
</body>
</html>