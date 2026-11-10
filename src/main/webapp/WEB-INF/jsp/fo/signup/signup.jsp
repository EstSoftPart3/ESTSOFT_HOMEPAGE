<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>직원 가입 신청</title>
	<link rel="icon" href="/resources/img/favicon.ico">
	<link rel="stylesheet" href="/resources/bo/plugins/fontawesome-free/css/all.min.css">
	<link rel="stylesheet" href="/resources/bo/dist/css/adminlte.min.css">
	<style>
		.su-steps { display:flex; gap:4px; margin-bottom:14px; }
		.su-steps span { flex:1; height:4px; border-radius:2px; background:#dde4ea; }
		.su-steps span.on { background:#0b6e8a; }
		.su-title { font-size:18px; font-weight:700; margin-bottom:12px; }
		.su-sub { font-size:13px; color:#5a6670; }
		.su-error { font-size:13px; color:#a32020; min-height:20px; margin-bottom:6px; }
		.su-pick { display:flex; gap:10px; align-items:flex-start; border:1px solid #dde4ea; border-radius:6px; padding:10px 12px; margin-bottom:8px; cursor:pointer; font-weight:400; width:100%; }
		.su-pick.on { border-color:#0b6e8a; background:#f2f8fe; }
		.su-pick.off { opacity:.6; cursor:not-allowed; }
		.su-pick b { display:block; }
		.su-pick small { color:#5a6670; }
		.su-tag { margin-left:auto; font-size:11px; font-weight:600; padding:0 7px; border-radius:9px; background:#fdf0d3; color:#8a5a00; white-space:nowrap; }
		.su-mail { background:#dff3e7; color:#1d7044; padding:8px 10px; border-radius:4px; font-size:13px; margin-bottom:12px; word-break:break-all; }
		.su-timer { color:#a32020; font-variant-numeric:tabular-nums; }
		.su-secret { font:600 18px Consolas,monospace; background:#f2f8fe; padding:12px; text-align:center; letter-spacing:.05em; border-radius:4px; word-break:break-all; }
		.su-warn { background:#fdf0d3; color:#8a5a00; padding:8px 10px; border-radius:4px; font-size:13px; margin:10px 0; }
		.su-kv { display:grid; grid-template-columns:72px 1fr; gap:4px; margin-bottom:10px; font-size:14px; word-break:break-all; }
		.su-kv span:nth-child(odd) { color:#5a6670; }
		.btn-ink { background:#111; color:#fff; font-weight:600; }
		.btn-ink:hover { background:#0b6e8a; color:#fff; }
	</style>
</head>
<body class="hold-transition login-page">
<div class="login-box">
	<div class="login-logo" style="font-size:20px"><a href="/eep/mainPage.do"><img alt="" src="/resources/img/logo.png" style="width:72px;height:72px"><br><b>직원 가입 신청</b></a></div>
	<div class="card"><div class="card-body login-card-body">
		<div class="su-steps" aria-hidden="true"><span class="on" id="bar1"></span><span id="bar2"></span><span id="bar3"></span></div>

		<form id="step1" novalidate>
			<div class="su-title">본인 확인</div>
			<div class="form-group"><label for="name">이름</label><input type="text" id="name" class="form-control" maxlength="50" autocomplete="name"></div>
			<div class="form-group"><label for="joinDt">입사일</label>
				<div class="input-group">
					<input type="text" id="joinDt" class="form-control" maxlength="10" inputmode="numeric" placeholder="예: 2024-03-02" autocomplete="off">
					<div class="input-group-append">
						<button type="button" class="btn btn-default" id="joinBtn" aria-label="달력에서 입사일 선택"><i class="far fa-calendar-alt" aria-hidden="true"></i></button>
					</div>
					<%-- 달력만 쓰는 숨은 입력. 화면에 그려져 있어야 showPicker 가 동작한다 --%>
					<input type="date" id="joinPick" tabindex="-1" aria-hidden="true" style="position:absolute;right:0;bottom:0;width:1px;height:1px;opacity:0;pointer-events:none;border:0">
				</div>
			</div>
			<div class="form-group"><label for="birth">생년월일 6자리</label><input type="text" id="birth" class="form-control" maxlength="6" inputmode="numeric" placeholder="예: 900101"></div>
			<div class="form-group"><label for="phone">전화번호</label><input type="tel" id="phone" class="form-control" maxlength="13" inputmode="tel" placeholder="010-0000-0000"></div>
			<div class="su-error" id="err1" role="alert"></div>
			<button type="submit" class="btn btn-ink btn-block" id="matchBtn">다음</button>
			<p class="mt-3 mb-0 text-center"><a href="/eep/login/loginPage.do">로그인으로 돌아가기</a></p>
		</form>

		<form id="step1b" class="d-none" novalidate>
			<div class="su-title">본인 정보를 확인해 주세요</div>
			<p class="su-sub">입력한 정보와 일치하는 직원입니다. 본인을 선택해 주세요.</p>
			<div id="picks"></div>
			<div class="su-error" id="err1b" role="alert"></div>
			<div class="row">
				<div class="col-5"><button type="button" class="btn btn-default btn-block" id="backBtn">이전</button></div>
				<div class="col-7"><button type="submit" class="btn btn-ink btn-block" id="pickBtn">본인이 맞습니다</button></div>
			</div>
			<p class="su-sub mt-3 mb-0">목록에 본인이 없으면 인사 담당자에게 문의해 주세요.</p>
		</form>

		<form id="stepMail" class="d-none" novalidate>
			<div class="su-title">회사 메일 입력</div>
			<p class="su-sub">회사에서 받은 gmail 주소를 입력해 주세요. 이 주소로 인증번호를 보내고, 앞부분이 로그인 아이디가 됩니다.</p>
			<div class="form-group"><label for="companyMail">회사 메일</label><input type="email" id="companyMail" class="form-control" maxlength="200" autocomplete="email" placeholder="예: hong.gd@gmail.com"></div>
			<div class="su-kv"><span>아이디</span><span id="idPreview">-</span></div>
			<div class="su-error" id="errMail" role="alert"></div>
			<div class="row">
				<div class="col-5"><button type="button" class="btn btn-default btn-block" id="mailBackBtn">이전</button></div>
				<div class="col-7"><button type="submit" class="btn btn-ink btn-block" id="mailBtn">인증번호 받기</button></div>
			</div>
		</form>

		<form id="step2" class="d-none" novalidate>
			<div class="su-title">이메일 인증</div>
			<div class="su-mail">인증번호를 보냈습니다.<br><b id="maskedMail"></b></div>
			<div class="form-group">
				<label for="code">인증번호 6자리 <span class="su-timer" id="timer"></span></label>
				<input type="text" id="code" class="form-control" maxlength="6" inputmode="numeric" autocomplete="one-time-code">
			</div>
			<div class="su-error" id="err2" role="alert"></div>
			<button type="submit" class="btn btn-ink btn-block" id="verifyBtn">확인</button>
			<button type="button" class="btn btn-link btn-block" id="resendBtn">인증번호 다시 받기</button>
			<p class="su-sub mb-0">메일을 받을 수 없으면 인사 담당자에게 문의해 주세요.</p>
		</form>

		<div id="step3" class="d-none">
			<div class="su-title">가입이 완료되었습니다</div>
			<div class="su-kv"><span>이름</span><span id="doneName"></span><span>아이디</span><span id="doneId"></span></div>
			<label for="donePw">초기 비밀번호</label>
			<input type="text" id="donePw" class="su-secret form-control" readonly style="height:auto">
			<button type="button" class="btn btn-default btn-block mt-2" id="copyBtn">복사</button>
			<div class="su-warn">이 화면을 벗어나면 다시 볼 수 없습니다.</div>
			<a class="btn btn-ink btn-block" href="/eep/login/loginPage.do">로그인하러 가기</a>
		</div>
	</div></div>
</div>
<script src="/resources/bo/plugins/jquery/jquery.min.js"></script>
<script>
(function() {
	var FAIL = '요청을 처리하지 못했습니다. 잠시 후 다시 시도해 주세요.';
	var picked = null, tick = null, joined = false, mailAddr = null;
	// 서버 BoMemberService.companyEmail 과 같은 규칙. 앞부분이 아이디가 된다
	var COMPANY_MAIL = /^[a-z0-9._-]{2,50}@gmail\.com$/;

	function show(id, bar) {
		$('#step1,#step1b,#stepMail,#step2,#step3').addClass('d-none');
		$('#' + id).removeClass('d-none');
		$('#bar1').toggleClass('on', bar >= 1);
		$('#bar2').toggleClass('on', bar >= 2);
		$('#bar3').toggleClass('on', bar >= 3);
	}
	function post(url, data, $err, $btn, done) {
		$err.text('');
		$btn.prop('disabled', true);
		$.post(url, data, function(res) {
			$btn.prop('disabled', false);
			if (res.error) { $err.text(res.error); return; }
			done(res.result);
		}).fail(function() { $btn.prop('disabled', false); $err.text(FAIL); });
	}
	function restart(msg) {
		clearInterval(tick);
		$('#code').val('');
		show('step1', 1);
		$('#err1').text(msg);
	}

	// 오늘 이후 입사일은 입력·선택할 수 없다. toISOString 은 UTC 라 시차를 보정한다
	var today = new Date();
	today.setMinutes(today.getMinutes() - today.getTimezoneOffset());
	var TODAY = today.toISOString().slice(0, 10), pick = document.getElementById('joinPick');
	pick.max = TODAY;

	// 숫자만 쳐도 2024-03-02 형태가 되게 하이픈을 넣는다
	$('#joinDt').on('input', function() {
		var d = this.value.replace(/[^0-9]/g, '').slice(0, 8);
		this.value = d.length > 6 ? d.slice(0, 4) + '-' + d.slice(4, 6) + '-' + d.slice(6) : d.length > 4 ? d.slice(0, 4) + '-' + d.slice(4) : d;
	});
	$('#joinBtn').on('click', function() {
		if (validDate($('#joinDt').val())) { pick.value = $('#joinDt').val(); }
		try { pick.showPicker(); } catch (e) { $('#joinDt').focus(); }
	});
	$(pick).on('change', function() { if (this.value) { $('#joinDt').val(this.value); } });

	function validDate(s) {
		var m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(s);
		if (!m || s > TODAY) { return false; }
		var d = new Date(+m[1], m[2] - 1, +m[3]);
		return d.getFullYear() === +m[1] && d.getMonth() === m[2] - 1 && d.getDate() === +m[3];
	}

	$('#step1').on('submit', function(e) {
		e.preventDefault();
		var name = $.trim($('#name').val()), joinDt = $('#joinDt').val(), birth = $.trim($('#birth').val()), phone = $('#phone').val().replace(/[^0-9]/g, '');
		var $err = $('#err1');
		if (!name) { $err.text('이름을 입력해 주세요.'); $('#name').focus(); return; }
		if (!validDate(joinDt)) { $err.text('입사일을 2024-03-02 형식으로 입력하거나 달력에서 선택해 주세요.'); $('#joinDt').focus(); return; }
		if (!/^\d{6}$/.test(birth)) { $err.text('생년월일 6자리를 입력해 주세요.'); $('#birth').focus(); return; }
		if (phone.length < 9) { $err.text('전화번호를 확인해 주세요.'); $('#phone').focus(); return; }
		post('/eep/signup/matchData.do', { NAME: name, JOIN_DT: joinDt, BIRTH: birth, PHONE: phone }, $err, $('#matchBtn'), renderPicks);
	});

	function renderPicks(rows) {
		var $box = $('#picks').empty(), selectable = 0;
		picked = null;
		rows.forEach(function(r) {
			var info = [r.ORG_NM, r.DEPT_NM, r.POSITION_NM].filter(Boolean).join(' · ');
			var $radio = $('<input type="radio" name="staff">').val(r.STAFF_SQ).prop('disabled', r.JOINED);
			var $label = $('<label class="su-pick">').toggleClass('off', r.JOINED).append($radio, $('<span>').append($('<b>').text(r.STAFF_NM), $('<small>').text(info)));
			if (r.JOINED) { $label.append($('<span class="su-tag">가입됨</span>')); } else { selectable++; }
			$box.append($label);
		});
		$box.find('input').on('change', function() {
			picked = this.value;
			$box.find('.su-pick').removeClass('on');
			$(this).closest('.su-pick').addClass('on');
			$('#err1b').text('');
		});
		var $only = $box.find('input:enabled');
		if ($only.length === 1) { $only.prop('checked', true).trigger('change'); }
		joined = selectable === 0;
		$('#pickBtn').text(joined ? '로그인하러 가기' : '본인이 맞습니다');
		$('#err1b').text(joined ? '이미 가입된 계정이 있습니다.' : '');
		show('step1b', 1);
	}

	$('#backBtn').on('click', function() { show('step1', 1); });

	function sendCode($err, $btn, done) {
		post('/eep/signup/sendCodeData.do', { STAFF_SQ: picked, COMPANY_EMAIL: mailAddr }, $err, $btn, function(r) {
			$('#maskedMail').text(r.EMAIL);
			startTimer(r.SECONDS);
			lockResend(r.RESEND_SECONDS);
			done();
		});
	}
	$('#step1b').on('submit', function(e) {
		e.preventDefault();
		if (joined) { location.href = '/eep/login/loginPage.do'; return; }
		if (!picked) { $('#err1b').text('본인을 선택해 주세요.'); return; }
		show('stepMail', 2);
		$('#companyMail').focus();
	});

	$('#companyMail').on('input', function() {
		var v = $.trim(this.value).toLowerCase();
		$('#idPreview').text(COMPANY_MAIL.test(v) ? v.split('@')[0] : '-');
	});
	$('#mailBackBtn').on('click', function() { show('step1b', 1); });
	$('#stepMail').on('submit', function(e) {
		e.preventDefault();
		var v = $.trim($('#companyMail').val()).toLowerCase();
		if (!COMPANY_MAIL.test(v)) { $('#errMail').text('회사 메일은 @gmail.com 주소만 쓸 수 있습니다.'); $('#companyMail').focus(); return; }
		mailAddr = v;
		sendCode($('#errMail'), $('#mailBtn'), function() { show('step2', 2); $('#code').focus(); });
	});
	$('#resendBtn').on('click', function() {
		sendCode($('#err2'), $('#resendBtn'), function() { $('#code').val('').focus(); });
	});

	function startTimer(seconds) {
		clearInterval(tick);
		var end = Date.now() + seconds * 1000;
		function draw() {
			var left = Math.max(0, Math.ceil((end - Date.now()) / 1000));
			$('#timer').text(('0' + Math.floor(left / 60)).slice(-2) + ':' + ('0' + left % 60).slice(-2));
			if (left === 0) { restart('입력 시간이 지났습니다. 처음부터 다시 진행해 주세요.'); }
		}
		draw();
		tick = setInterval(draw, 1000);
	}
	function lockResend(seconds) {
		var $btn = $('#resendBtn').prop('disabled', true);
		setTimeout(function() { $btn.prop('disabled', false); }, seconds * 1000);
	}

	$('#step2').on('submit', function(e) {
		e.preventDefault();
		var code = $.trim($('#code').val());
		if (!/^\d{6}$/.test(code)) { $('#err2').text('인증번호 6자리를 입력해 주세요.'); return; }
		$('#err2').text('');
		$('#verifyBtn').prop('disabled', true);
		$.post('/eep/signup/verifyData.do', { CODE: code }, function(res) {
			$('#verifyBtn').prop('disabled', false);
			if (res.error) {
				// 횟수 초과·만료면 서버의 진행 상태가 지워졌으므로 처음으로 돌아간다
				if (res.error.indexOf('처음부터') >= 0) { restart(res.error); } else { $('#err2').text(res.error); }
				return;
			}
			clearInterval(tick);
			$('#doneName').text(res.result.EMPLY_NM);
			$('#doneId').text(res.result.EMPLY_ID);
			$('#donePw').val(res.result.PASSWORD);
			show('step3', 3);
		}).fail(function() { $('#verifyBtn').prop('disabled', false); $('#err2').text(FAIL); });
	});

	$('#copyBtn').on('click', function() {
		var $btn = $(this), pw = document.getElementById('donePw');
		function ok() { $btn.text('복사했습니다'); }
		if (navigator.clipboard) {
			navigator.clipboard.writeText(pw.value).then(ok);
		} else {
			pw.select();
			document.execCommand('copy');
			ok();
		}
	});

	$('#name').focus();
})();
</script>
</body>
</html>
