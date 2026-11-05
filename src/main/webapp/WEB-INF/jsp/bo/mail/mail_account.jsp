<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>

<body class="hold-transition sidebar-mini">

	<div class="wrapper">

		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>

		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header">
					<h3 class="card-title bTitle"><b>메일계정 관리</b></h3>
				</div>

				<div class="card-body">

					<div class="cal-panel">
						<div class="cal-panel-head"><span><i class="fas fa-plus"></i> 계정 추가</span></div>
						<div class="cal-panel-body">
							<form id="addForm" onsubmit="addAccount(); return false;">
								<div class="form-row">
									<div class="col-md-4 mb-2">
										<label for="mailAddr">Gmail 주소</label>
										<input type="email" id="mailAddr" class="form-control form-control-sm" maxlength="190" autocomplete="off" required placeholder="example@gmail.com">
									</div>
									<div class="col-md-3 mb-2">
										<label for="acctUse">용도</label>
										<input type="text" id="acctUse" class="form-control form-control-sm" maxlength="100" autocomplete="off" required placeholder="예: 연구개발">
									</div>
									<div class="col-md-3 mb-2">
										<label for="appPw">앱 비밀번호 16자리</label>
										<input type="password" id="appPw" class="form-control form-control-sm" autocomplete="new-password" required>
									</div>
									<div class="col-md-2 mb-2 d-flex align-items-end">
										<button type="submit" id="addBtn" class="btn btn-sm btn-dark btn-block">로그인 확인 후 추가</button>
									</div>
								</div>
							</form>
							<small class="text-muted">Google 계정 → 보안 → 2단계 인증을 켠 뒤 앱 비밀번호를 발급해 입력합니다. 로그인 비밀번호는 쓸 수 없습니다.</small>
						</div>
					</div>

					<div class="cal-panel">
						<div class="cal-panel-head"><span><i class="fas fa-envelope"></i> 등록된 계정</span></div>
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0">
								<thead>
									<tr>
										<th scope="col">Gmail 주소</th><th scope="col">용도</th><th scope="col">등록자</th><th scope="col">등록일</th><th scope="col">삭제</th>
									</tr>
								</thead>
								<tbody id="acctBody"></tbody>
							</table>
						</div>
					</div>

					<small class="text-muted">삭제해도 Google 쪽 앱 비밀번호는 남습니다. 더 쓰지 않으면 Google 계정에서도 폐기해 주세요.</small>

				</div>
			</section>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>

	<script>
	$(load);

	function load() {
		$.post('/admin/mail/mailAccountListData.do', function(res) { render(res.list); }, 'json')
			.fail(function() { message('목록을 불러오지 못했습니다.'); });
	}

	function message(text) {
		$('#acctBody').empty().append($('<tr>').append($('<td colspan="5" class="cal-empty">').text(text)));
	}

	// 입력값이 들어가므로 모두 text() 로 넣는다
	function render(list) {
		if (!list || !list.length) return message('등록된 계정이 없습니다.');
		var $body = $('#acctBody').empty();
		list.forEach(function(r) {
			var $tr = $('<tr>');
			[r.MAIL_ADDR, r.ACCT_USE, r.RGST_EMPLY_ID, r.RGST_DT].forEach(function(v) { $tr.append($('<td>').text(v)); });
			var $del = $('<button type="button" class="btn btn-xs btn-outline-danger">').text('삭제')
				.on('click', function() { removeAccount(r); });
			$tr.append($('<td>').append($del));
			$body.append($tr);
		});
	}

	function addAccount() {
		var $btn = $('#addBtn').prop('disabled', true).text('확인 중...');
		$.post('/admin/mail/saveMailAccountData.do', {
			MAIL_ADDR: $('#mailAddr').val(),
			ACCT_USE: $('#acctUse').val(),
			APP_PW: $('#appPw').val()
		}, function(res) {
			if (res.error) return alert(res.error);
			$('#addForm')[0].reset();
			load();
		}, 'json').fail(function() { alert('추가에 실패했습니다.'); })
			.always(function() {
				$('#appPw').val('');
				$btn.prop('disabled', false).text('로그인 확인 후 추가');
			});
	}

	function removeAccount(r) {
		if (!confirm(r.MAIL_ADDR + ' 계정을 삭제할까요?')) return;
		$.post('/admin/mail/deleteMailAccountData.do', { MAIL_ACCT_SQ: r.MAIL_ACCT_SQ }, load, 'json')
			.fail(function() { alert('삭제에 실패했습니다.'); });
	}
	</script>
</body>
</html>
