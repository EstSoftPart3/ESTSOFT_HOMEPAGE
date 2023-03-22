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
	.dataValue {
    	background-color: #ffffff;
	}
</style>

	<div class="wrapper">
	
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		
		 <div class="content-wrapper">
		    
		     	<!-- Main content -->
	    		<section class="content">
    			 <div class="card-header">
	               	<h3 class="card-title bTitle">직원 상세정보</h3>
				</div>
				
				<form class="form-horizontal">
				
				
                <!--card-body -->
                <table class="table table-bordered">	                
					<tr class="col-form-label sTitle LabelStyle" >
						<td class="col-sm-1" align="center" >권한</td>
						<td id="authSq" class="col-sm-2 dataValue"></td>						
						<td class="col-sm-1" align="center">사용 여부</td>
						<td id="useYn" class="col-sm-2 dataValue"></td>
					</tr>
					<tr class="col-form-label sTitle LabelStyle"  >
						<td class="col-sm-1" align="center">아이디</td>
						<td id="mbrId" class="col-sm-2 dataValue"></td>						
						<td class="col-sm-1" align="center">비밀번호</td>
						<td id="mbrPasswrd" class="col-sm-2 dataValue"></td>						
												
					</tr>
					<tr class="col-form-label sTitle LabelStyle"  >
						<td class="col-sm-1" align="center">성명</td>
						<td id="mbrNm" class="col-sm-2 dataValue"></td>						
						<td class="col-sm-1" align="center">성별</td>
						<td id="mbrSexCd" class="col-sm-2 dataValue"></td>						
					</tr>	
					<tr class="col-form-label sTitle LabelStyle"  >
						<td class="col-sm-1" align="center">휴대폰 번호</td>
						<td id="mbrPhNum" class="col-sm-2 dataValue"></td>	
						<td class="col-sm-1" align="center">집 주소</td>
						<td id="mbrHomeAddr" class="col-sm-2 dataValue" ></td>						
					</tr>	
					<tr class="col-form-label sTitle LabelStyle"  >
						<td class="col-sm-1" align="center">등록일</td>
						<td id="regDt" class="col-sm-2 dataValue"></td>							
						<td class="col-sm-1" align="center">수정일</td>
						<td id="updtDt" class="col-sm-2 dataValue"></td>							
					</tr>
					<tr class="col-form-label sTitle LabelStyle"  >
						<td class="col-sm-1" align="center">주민등록번호</td>
						<td id="mbrRrn" class="col-sm-2 dataValue"></td>
						<td class="col-sm-1" align="center">이메일</td>
						<td id="mbrEmail" class="col-sm-2 dataValue" colspan="3"></td>						
					</tr>
					<tr class="col-form-label sTitle LabelStyle"  >
						<td class="col-sm-1" align="center">탈퇴 여부</td>
						<td id="delYn" class="col-sm-2 dataValue"></td>
					</tr>				
                </table>
                
                
                <!--card-footer -->
                <div class="card-footer" style="text-align:right;background-color:#ffffff">
                	
                  	<button type="button" class="btn btn-primary sTitle" onclick="location.href='/admin/member/memberList.do';">목록</button>
                  	<button type="button" class="btn btn-info sTitle" onclick="memberUpdate();">수정</button>
                  	<button type="button" class="btn btn-danger sTitle" onclick="outMember();">탈퇴 처리</button>
                  	
                </div>
                
              </form>
				
    		</section>
	    		
		 </div>
		
	</div>

   
   <%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
   
   <script>
   var dataContent = {};
   
	$(document).ready(function(){
		
		//회원순번
		var mbrSq = '<c:out value="${param.mbrSqParam}" />';
		
		memberContentData(mbrSq);
		
	});
	
	//회원 정보 호출
	function memberContentData(mbrSq) {
		
		console.log("memberContentData : "+ mbrSq);
		
		$.ajax({
	           type: "post",
	           url: "/admin/member/memberContentData.do",
	           data: {
	        	   mbrSq : mbrSq
	            },
	           success: function(data) {
	        	   
	        	 if(data){
	        		 dataContent = data.memberContentData.memberContent[0];
		        	 
		        	 var mbrNm = dataContent.mbrNm						//이름
		        	 var mbrId = dataContent.mbrId						//아이디
		        	 var mbrPasswrd = dataContent.mbrPasswrd			//비밀번호
		        	 var mbrEmail = dataContent.mbrEmail				//이메일
		        	 var mbrSexCd = dataContent.mbrSexCd				//성별
		        	 var mbrPhNum = dataContent.mbrPhNum				//휴대폰번호
		        	 var regDt = dataContent.regDt						//등록일시
		        	 var mbrHomeAddr = dataContent.mbrHomeAddr			//집주소
		        	 var useYn = dataContent.useYn						//사용여부
		        	 var authSq = dataContent.mbrAuthCd					//권한
		        	 var mbrRrn = dataContent.mbrRrn					//주민등록번호
		        	 var updtDt = dataContent.updtDt					//수정일시
		        	 var delYn = dataContent.delYn						//탈퇴여부
		        	 
		        	 $("#authSq").text(authSq);
		        	 $("#mbrNm").text(mbrNm);
		        	 $("#useYn").text(useYn);
		        	 $("#mbrId").text(mbrId);
		        	 $("#mbrEmail").text(mbrEmail);
		        	 $("#mbrSexCd").text(mbrSexCd);
		        	 $("#mbrPhNum").text(mbrPhNum);
		        	 $("#regDt").text(regDt);
		        	 $("#mbrHomeAddr").text(mbrHomeAddr);
		        	 $("#mbrRrn").text(mbrRrn);
		        	 $("#updtDt").text(updtDt);
		        	 $("#mbrPasswrd").text(mbrPasswrd);
		        	 $("#delYn").text(delYn);
	        	 } else {
	        		alert("조회에 실패하였습니다. 다시 시도 해주세요.");
	        	 }
	        	 
	           },
	           error: function(error) {
	        	   var errorJson = JSON.stringify(error);
	               console.log(errorJson);
	           }
		})
	}
	
	function memberUpdate() {
			
		var mbrSq = '<c:out value="${param.mbrSqParam}" />';
		
			let param = {
				mbrSqParam : mbrSq
			}
			
			var contentUrl = "/admin/member/memberUpdate.do";
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
	
	//직원 탈퇴 복구
	function outMember(){
		let mbrSq = '<c:out value="${param.mbrSqParam}" />';
		
		console.log(mbrSq);
		
		if(confirm('해당 직원을 탈퇴 처리 하시겠습니까?')) {
			$.ajax({
		           type: "post",
		           url: "/admin/member/outMember.do",
		           data: {
		        	      mbrSq : mbrSq,
		        	      delYn : 'Y'
		           },
		           success: function(data) {
				        	bootbox.alert({
									 message: "직원 탈퇴가 정상적으로 처리 되었습니다.",
									 locale: 'kr',
									 callback: function() {
										 	location.href="/admin/member/memberList.do";
								     } });
		           }, error: function(error) {
		        	   alert("직원 탈퇴가 실패 하였습니다. 다시 시도 해주세요.");
		        	   var errorJson = JSON.stringify(error);
		               console.log(errorJson);
		           }
			})
		} else {
			return false;
		}
		
	}
		
   </script>
 
 
 
</body>
</html>