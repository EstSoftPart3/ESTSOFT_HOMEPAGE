<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>비밀번호 변경</title>
	<link rel="icon" href="/resources/img/favicon.ico">
	<link rel="stylesheet" href="/resources/bo/plugins/fontawesome-free/css/all.min.css">
	<link rel="stylesheet" href="/resources/bo/dist/css/adminlte.min.css">
	<style>
		.pw-hint { font-size: 12px; color: #666; }
		#pwError { font-size: 13px; color: #a32020; min-height: 20px; }
		.btn-ink { background: #111; color: #fff; font-weight: 600; }
		.btn-ink:hover { background: #0b6e8a; color: #fff; }
	</style>
</head>
<body class="hold-transition login-page">
<div class="login-box">
	<div class="login-logo" style="font-size:20px"><img alt="" src="/resources/img/logo.png" style="width:72px;height:72px"><br><b>비밀번호 변경</b></div>
	<div class="card"><div class="card-body login-card-body">
		<c:choose>
			<c:when test="${sessionScope.loginInfo.loginInfo[0].pwInitYn == 'Y'}"><p class="mb-3">초기 비밀번호로 로그인했습니다. 새 비밀번호를 설정해야 계속할 수 있습니다.</p></c:when>
			<c:otherwise><p class="mb-3"><c:out value="${sessionScope.loginInfo.loginInfo[0].emplyNm}"/>님의 비밀번호를 변경합니다.</p></c:otherwise>
		</c:choose>
		<form id="pwForm" novalidate>
			<div class="form-group"><label for="cur">현재 비밀번호</label><input type="password" id="cur" class="form-control" autocomplete="current-password" required></div>
			<div class="form-group"><label for="next">새 비밀번호</label><input type="password" id="next" class="form-control" autocomplete="new-password" required aria-describedby="pwRule"><div id="pwRule" class="pw-hint mt-1">10자 이상, 영문과 숫자 포함, 아이디와 다르게</div></div>
			<div class="form-group"><label for="again">새 비밀번호 확인</label><input type="password" id="again" class="form-control" autocomplete="new-password" required></div>
			<div id="pwError" role="alert"></div>
			<button type="submit" class="btn btn-ink btn-block" id="saveBtn">변경</button>
		</form>
		<c:if test="${sessionScope.loginInfo.loginInfo[0].pwInitYn != 'Y'}"><p class="mt-3 mb-0 text-center"><a href="${sessionScope.loginInfo.loginInfo[0].pwInitYn == 'R' ? '/eep/mainPage.do' : 'javascript:history.back()'}">돌아가기</a></p></c:if>
	</div></div>
</div>
<script src="/resources/bo/plugins/jquery/jquery.min.js"></script>
<script>
$('#pwForm').on('submit', function(e) {
	e.preventDefault();
	var next = $('#next').val(), $err = $('#pwError').text('');
	if (!$('#cur').val() || !next) { $err.text('비밀번호를 입력해 주세요.'); return; }
	if (next !== $('#again').val()) { $err.text('새 비밀번호가 서로 다릅니다.'); $('#again').focus(); return; }
	$('#saveBtn').prop('disabled', true);
	$.post('/eep/account/changePasswordData.do', { CURRENT_PW: $('#cur').val(), NEW_PW: next }, function(res) {
		$('#saveBtn').prop('disabled', false);
		if (res.error) { $err.text(res.error); return; }
		alert('비밀번호를 변경했습니다.');
		location.replace(res.result);
	}).fail(function() { $('#saveBtn').prop('disabled', false); $err.text('변경하지 못했습니다. 다시 로그인한 뒤 시도해 주세요.'); });
});
$('#cur').focus();
</script>
</body>
</html>
