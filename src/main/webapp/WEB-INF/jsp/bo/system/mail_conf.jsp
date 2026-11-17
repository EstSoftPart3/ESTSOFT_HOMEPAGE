<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_head.jspf"%>
<style>
	#mcBody td { white-space: nowrap; vertical-align: middle; }
	#mcBody tr.mc-grp td { background: #f6f8fa; font-weight: 700; color: #495057; }
	.mc-sum { display: flex; flex-wrap: wrap; gap: 6px; padding: 10px 14px; }
	.mc-sum span { border: 1px solid rgba(17,17,17,.15); background: #fff; border-radius: 999px; padding: 2px 12px; font-size: 12.5px; font-weight: 700; }
	.mc-st { display: inline-flex; align-items: center; gap: 5px; font-size: 12.5px; }
	.mc-st:before { content: ""; width: 8px; height: 8px; border-radius: 50%; background: currentColor; }
	.mc-st.ok { color: #1e7e34; } .mc-st.bad { color: #c82333; } .mc-st.warn { color: #b8860b; }
	.mc-acc { font-size: 11px; border-radius: 3px; padding: 0 6px; background: #e9ecef; margin-right: 4px; }
	.mc-chip { display: inline-flex; align-items: center; gap: 4px; background: #e7f1ff; color: #0b5ed7; border-radius: 10px; padding: 0 8px; margin: 1px 3px 1px 0; font-size: 12px; }
	.mc-chip.ext { background: #f1f3f5; color: #495057; }
	.mc-chip.miss { background: #fdecea; color: #c82333; }
	.mc-chip button { border: 0; background: none; padding: 0 0 0 2px; color: inherit; opacity: .6; line-height: 1; }
	.mc-auto { color: #6c757d; }
	.mc-sec { font-weight: 700; font-size: 13px; margin: 2px 0 8px; }
	.mc-sec + .mc-box, .mc-sec + div { margin-bottom: 14px; }
	.mc-box { border: 1px solid rgba(17,17,17,.12); border-radius: 6px; padding: 10px; background: #fafbfc; }
	.mc-form { display: grid; grid-template-columns: 110px 1fr; gap: 7px 10px; align-items: center; }
	.mc-form > label { margin: 0; color: #5f6b75; font-weight: 400; font-size: 12.5px; }
	.mc-hint { background: #fff8e1; border: 1px solid #ffe08a; border-radius: 4px; padding: 5px 8px; font-size: 12px; color: #7a5b00; margin-top: 8px; }
	.mc-to { display: flex; flex-wrap: wrap; align-items: center; gap: 2px; border: 1px solid #ced4da; border-radius: 4px; padding: 4px 6px; background: #fff; min-height: 32px; }
	.mc-to input { border: 0; outline: 0; flex: 1; min-width: 160px; font-size: 13px; }
	#mcPick .table-responsive { max-height: 46vh; }
	#mcPickBody tr { cursor: pointer; }
	#mcPickBody tr.dim td { color: #adb5bd; cursor: default; }
	@media (max-width: 768px) { .mc-form { grid-template-columns: 1fr; } }
</style>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_open.jspf"%>
				<div class="card-header d-flex flex-wrap align-items-center" style="gap:8px">
					<h3 class="card-title bTitle"><b>메일 설정</b></h3>
					<span class="small text-muted">홈페이지가 보내는 메일마다 보내는 계정과 받는 사람을 정합니다 · 슈퍼관리자 전용</span>
					<div class="ml-auto d-flex" style="gap:6px">
						<button type="button" class="btn btn-sm btn-outline-secondary" id="btnHist">변경 이력</button>
						<button type="button" class="btn btn-sm btn-outline-secondary" id="btnVerifyAll">전체 연결 확인</button>
					</div>
				</div>
				<div class="card-body">
					<div class="cal-panel">
						<div class="mc-sum" id="mcSum"></div>
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0">
								<thead><tr><th>메일</th><th>언제</th><th>보내는 계정</th><th>연결 상태</th><th>받는 사람</th><th></th></tr></thead>
								<tbody id="mcBody"></tbody>
							</table>
						</div>
						<div class="small text-muted px-3 py-2">연결 상태는 그 계정의 마지막 연결 확인 결과입니다(로그인 실패로 못 보내면 '실패'로 바뀝니다). 회색 받는 사람은 화면 데이터로 정해져 여기서 바꾸지 않습니다.</div>
					</div>
				</div>
			<%@ include file="/WEB-INF/jsp/bo/boinclude/page_close.jspf"%>

	<div class="modal fade" id="mcModal" tabindex="-1" role="dialog" aria-labelledby="mcTitle" aria-hidden="true" data-backdrop="static">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="mcTitle"></h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<div class="modal-body">
					<div id="mcEdit">
						<div class="mc-sec">📤 보내는 계정</div>
						<div class="mc-box">
							<div class="mc-form">
								<label for="mAcc">계정</label><div class="d-flex align-items-center" style="gap:8px"><select id="mAcc" class="form-control form-control-sm" style="max-width:340px"></select><span id="mAccSt"></span></div>
								<label for="mAccNm">계정 이름 *</label><input id="mAccNm" class="form-control form-control-sm" maxlength="50" placeholder="예: 기본, 급여, 연구소">
								<label for="mFromNm">보내는 이름 *</label><input id="mFromNm" class="form-control form-control-sm" maxlength="100">
								<label for="mFromAddr">Gmail 주소 *</label><div class="d-flex" style="gap:6px"><input id="mFromAddr" type="email" class="form-control form-control-sm" maxlength="200"><button type="button" class="btn btn-sm btn-outline-secondary" id="btnPickFrom">👤 계정에서 고르기</button></div>
								<label for="mPw">앱 비밀번호</label>
								<div>
									<input id="mPw" type="password" class="form-control form-control-sm" maxlength="40" autocomplete="new-password" style="max-width:320px">
									<details class="small text-muted mt-1"><summary>발급 방법</summary>Google 계정 로그인 비밀번호가 아니라 <b>앱 비밀번호 16자리</b>입니다. 보내는 Gmail 계정으로 로그인 → Google 계정 관리 → 보안 → 2단계 인증 켜기 → 「앱 비밀번호」에서 새로 만들기 → 나온 16자리를 붙여 넣습니다. 저장하면 암호화해 보관하고 화면에 다시 보이지 않습니다.</details>
								</div>
								<label for="mReply">답장 받을 주소</label><input id="mReply" type="email" class="form-control form-control-sm" maxlength="200" placeholder="비우면 보내는 주소">
								<label for="mBcc">숨은 참조</label><input id="mBcc" type="email" class="form-control form-control-sm" maxlength="200" placeholder="선택 · 보낸 메일 사본을 받을 주소">
								<label for="mContact">담당자 연락처</label><input id="mContact" class="form-control form-control-sm" maxlength="100" placeholder="급여 메일 본문의 {담당자 연락처}">
							</div>
							<div class="mc-hint" id="mShare" hidden></div>
						</div>
						<div class="mc-sec">📥 받는 사람</div>
						<div id="mToWrap">
							<div class="mc-to" id="mTo"><input id="mToInput" aria-label="받는 주소 입력" placeholder="주소 입력 후 Enter"></div>
							<button type="button" class="btn btn-sm btn-outline-secondary mt-2" id="btnPickTo">👤 계정에서 고르기</button>
						</div>
						<div id="mToAuto" class="mc-auto" hidden></div>
					</div>
					<div id="mcPick" hidden>
						<div class="d-flex mb-2" style="gap:6px"><input id="mcPickQ" class="form-control form-control-sm" placeholder="이름·아이디·메일 검색" aria-label="계정 검색"></div>
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0"><thead><tr><th></th><th>이름</th><th>아이디</th><th>권한</th><th>메일</th></tr></thead><tbody id="mcPickBody"></tbody></table>
						</div>
					</div>
				</div>
				<div class="modal-footer" id="mcFootEdit">
					<span class="small text-muted mr-auto">연결 확인·시험 메일은 먼저 저장합니다</span>
					<button type="button" class="btn btn-sm btn-outline-secondary" id="btnVerify">연결 확인</button>
					<button type="button" class="btn btn-sm btn-outline-secondary" id="btnTest">시험 메일</button>
					<button type="button" class="btn btn-sm btn-primary" id="btnSave">저장</button>
				</div>
				<div class="modal-footer" id="mcFootPick" hidden>
					<span class="small text-muted mr-auto" id="mcPickCnt"></span>
					<button type="button" class="btn btn-sm btn-outline-secondary" id="btnPickCancel">취소</button>
					<button type="button" class="btn btn-sm btn-primary" id="btnPickOk">넣기</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="mcHist" tabindex="-1" role="dialog" aria-labelledby="mcHistTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="mcHistTitle">변경 이력</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<div class="modal-body">
					<div class="table-responsive" style="max-height:60vh">
						<table class="table table-sm cal-table mb-0"><thead><tr><th>일시</th><th>누가</th><th>메일·계정</th><th>내용</th></tr></thead><tbody id="mcHistBody"></tbody></table>
					</div>
				</div>
			</div>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/page_script.jspf"%>
	<script>
	var data = null, cur = null, to = [], users = null, pickMode = null, picked = {};

	$(function() {
		load();
		$('#mcBody').on('click', '.mc-edit', function() { open($(this).attr('data-use')); });
		$('#mAcc').on('change', function() { fillAccount(this.value); });
		$('#mToInput').on('keydown', function(e) {
			if ((e.key === 'Enter' || e.key === ',') && !e.originalEvent.isComposing) { e.preventDefault(); addTyped(); }
		}).on('blur', addTyped);
		$('#mTo').on('click', 'button', function() { var v = $(this).attr('data-v'); to = to.filter(function(t) { return t.V !== v; }); paintTo(); });
		$('#btnPickTo').on('click', function() { pick('to'); });
		$('#btnPickFrom').on('click', function() { pick('from'); });
		$('#btnPickCancel').on('click', closePick);
		$('#btnPickOk').on('click', pickOk);
		$('#mcPickQ').on('input', paintPick);
		$('#mcPickBody').on('click', 'tr:not(.dim)', function(e) {
			var id = $(this).attr('data-id');
			if (pickMode === 'from') picked = {};
			if (picked[id] && pickMode === 'to') delete picked[id]; else picked[id] = true;
			paintPick();
		});
		$('#btnSave').on('click', function() { save(function() { bootbox.alert('저장했습니다.'); }); });
		$('#btnVerify').on('click', function() {
			var $b = $(this).prop('disabled', true).text('확인 중…');
			function done() { $b.prop('disabled', false).text('연결 확인'); }
			save(function(accSq) { hrPost('/admin/system/mail/verifyData.do', { ACC_SQ: accSq }, function() { done(); reload(); bootbox.alert('Gmail 연결을 확인했습니다.'); }, function() { done(); reload(); }); }, done);
		});
		$('#btnTest').on('click', function() {
			var $b = $(this).prop('disabled', true).text('보내는 중…');
			function done() { $b.prop('disabled', false).text('시험 메일'); }
			save(function() { hrPost('/admin/system/mail/testData.do', { USE_CD: cur.USE_CD }, function(res) { done(); reload(); bootbox.alert(res.result + ' 로 시험 메일을 보냈습니다.'); }, function() { done(); reload(); }); }, done);
		});
		$('#btnVerifyAll').on('click', function() {
			var $b = $(this).prop('disabled', true).text('확인 중…');
			hrPost('/admin/system/mail/verifyData.do', {}, function(res) {
				$b.prop('disabled', false).text('전체 연결 확인'); load();
				bootbox.alert(res.result.length ? '연결 확인 실패: ' + res.result.join(', ') + '. 표의 연결 상태에서 이유를 볼 수 있습니다.' : '모든 계정이 연결됐습니다.');
			}, function() { $b.prop('disabled', false).text('전체 연결 확인'); load(); });
		});
		$('#btnHist').on('click', openHist);
		$('#mcModal').on('hidden.bs.modal', load);
	});

	function load(after) {
		hrPost('/admin/system/mail/confData.do', {}, function(res) { data = res.result; render(); if (typeof after === 'function') after(); });
	}
	// 팝업을 연 채 다시 불러온다(연결 상태만 새로)
	function reload() { load(function() { if (cur) $('#mAccSt').empty().append(stOf(acc($('#mAcc').val()))); }); }

	function acc(sq) { return data.accounts.filter(function(a) { return String(a.ACC_SQ) === String(sq); })[0]; }
	function stOf(a) {
		if (!a) return $('<span class="mc-st warn">').text('새 계정');
		if (a.VERIFIED_YN === 'Y') return $('<span class="mc-st ok">').text('연결됨').append($('<span class="small text-muted ml-1">').text(a.VERIFIED_DT || ''));
		return a.VERIFY_MSG ? $('<span class="mc-st bad">').text('실패 · ' + a.VERIFY_MSG) : $('<span class="mc-st warn">').text('확인 안 함');
	}
	function chip(t, removable) {
		var cls = t.MISSING ? 'miss' : t.ID ? '' : 'ext', label = t.ID ? (t.NM + (t.EMAIL ? ' · ' + t.EMAIL : '') + (t.MISSING ? ' · ' + t.MISSING : '')) : t.EMAIL;
		var $c = $('<span class="mc-chip">').addClass(cls).text(label);
		if (removable) $c.append($('<button type="button" aria-label="빼기">').attr('data-v', t.V).text('✕'));
		return $c;
	}

	function render() {
		var ok = 0, $b = $('#mcBody').empty(), grp = null;
		data.uses.forEach(function(u) {
			var a = acc(u.ACC_SQ);
			if (a && a.VERIFIED_YN === 'Y') ok++;
			if (u.GRP !== grp) { grp = u.GRP; $b.append($('<tr class="mc-grp">').append($('<td colspan="6">').text(grp))); }
			$b.append($('<tr>')
				.append($('<td>').text(u.NM)).append($('<td class="text-muted">').text(u.WHEN))
				.append($('<td>').append($('<span class="mc-acc">').text(a ? a.ACC_NM : '?')).append(document.createTextNode(a ? a.FROM_ADDR || '' : '')))
				.append($('<td>').append(stOf(a)))
				.append($('<td>').append(u.AUTO_TO ? $('<span class="mc-auto">').text(u.AUTO_TO) : (u.TO || []).map(function(t) { return chip(t, false); })))
				.append($('<td>').append($('<button type="button" class="btn btn-sm btn-outline-secondary py-0 mc-edit">').attr('data-use', u.USE_CD).text('설정'))));
		});
		$('#mcSum').empty().append($('<span>').text('메일 ' + data.uses.length)).append($('<span class="mc-st ok">').text('정상 ' + ok)).append($('<span class="mc-st bad">').text('문제 ' + (data.uses.length - ok)));
		$('#btnHist').text('변경 이력 ' + data.histCnt);
	}

	function open(use) {
		cur = data.uses.filter(function(u) { return u.USE_CD === use; })[0];
		$('#mcTitle').text(cur.NM + ' · 메일 설정');
		$('#mAcc').empty().append(data.accounts.map(function(a) { return $('<option>').val(a.ACC_SQ).text(a.ACC_NM + ' · ' + (a.FROM_ADDR || '주소 없음')); }))
			.append($('<option value="NEW">').text('+ 새 계정 추가')).val(cur.ACC_SQ);
		fillAccount(cur.ACC_SQ);
		to = (cur.TO || []).slice();
		$('#mToWrap').prop('hidden', !!cur.AUTO_TO);
		$('#mToAuto').prop('hidden', !cur.AUTO_TO).text((cur.AUTO_TO || '') + ' (자동, 여기서 바꾸지 않음)');
		paintTo();
		closePick();
		$('#mcModal').modal('show');
	}

	function fillAccount(sq) {
		var a = acc(sq), isNew = !a;
		$('#mAccNm').val(a ? a.ACC_NM : '');
		$('#mFromNm').val(a ? a.FROM_NM || '' : '주식회사 이에스티소프트');
		$('#mFromAddr').val(a ? a.FROM_ADDR || '' : '');
		$('#mReply').val(a ? a.REPLY_TO || '' : ''); $('#mBcc').val(a ? a.BCC || '' : ''); $('#mContact').val(a ? a.CONTACT || '' : '');
		$('#mPw').val('').attr('placeholder', a && a.HAS_PW ? '저장됨 · 바꿀 때만 입력' : a && a.SERVER ? '비우면 서버 설정 파일 계정으로 보냅니다' : '앱 비밀번호 16자리');
		$('#mFromAddr').prop('readonly', !!(a && a.SERVER)).attr('title', a && a.SERVER ? '앱 비밀번호를 넣으면 주소를 바꿀 수 있습니다' : '');
		$('#mAccSt').empty().append(stOf(a));
		var n = a ? a.USE_CNT - (String(cur.ACC_SQ) === String(sq) ? 1 : 0) : 0;
		$('#mShare').prop('hidden', !a || n < 1).text('이 계정은 다른 메일 ' + n + '종도 같이 씁니다. 여기서 계정 칸을 고치면 그 메일들도 모두 바뀝니다.');
		if (a && a.SERVER) $('#mShare').prop('hidden', false).text('지금은 서버 설정 파일의 계정(' + a.FROM_ADDR + ')으로 보냅니다. 다른 Gmail 로 보내려면 앱 비밀번호와 주소를 넣으세요.' + (n ? ' 다른 메일 ' + n + '종도 같이 바뀝니다.' : ''));
	}
	// 서버 설정 계정은 앱 비밀번호를 넣어야 주소를 고칠 수 있다
	$(document).on('input', '#mPw', function() { var a = acc($('#mAcc').val()); if (a && a.SERVER) $('#mFromAddr').prop('readonly', !this.value); });

	function paintTo() {
		var $t = $('#mTo'); $t.find('.mc-chip').remove();
		to.forEach(function(t) { chip(t, true).insertBefore('#mToInput'); });
	}
	function addTyped() {
		var v = $('#mToInput').val().trim().replace(/,$/, '');
		if (!v) return;
		if (!/^[^@\s<>",]+@[^@\s<>",]+\.[^@\s<>",]+$/.test(v)) { bootbox.alert('주소 형식을 확인해 주세요: ' + v); return; }
		if (!to.some(function(t) { return t.V === v; })) to.push({ V: v, EMAIL: v });
		$('#mToInput').val(''); paintTo();
	}

	// ── 계정에서 고르기: to 는 여러 명, from 은 한 명(그 메일을 Gmail 주소 칸에) ──
	function pick(mode) {
		pickMode = mode; picked = {};
		if (mode === 'to') to.forEach(function(t) { if (t.ID) picked[t.ID] = true; });
		function show() {
			$('#mcEdit, #mcFootEdit').prop('hidden', true); $('#mcPick, #mcFootPick').prop('hidden', false);
			$('#mcTitle').text(mode === 'to' ? '받는 사람 고르기' : '보내는 계정 고르기');
			$('#mcPickQ').val(''); paintPick(); $('#mcPickQ').focus();
		}
		if (users) show(); else hrPost('/admin/system/mail/usersData.do', {}, function(res) { users = res.result; show(); });
	}
	function closePick() {
		$('#mcEdit, #mcFootEdit').prop('hidden', false); $('#mcPick, #mcFootPick').prop('hidden', true);
		if (cur) $('#mcTitle').text(cur.NM + ' · 메일 설정');
	}
	function paintPick() {
		var q = $('#mcPickQ').val().trim().toLowerCase(), $b = $('#mcPickBody').empty(), used = data.accounts.map(function(a) { return (a.FROM_ADDR || '').toLowerCase(); });
		users.filter(function(u) { return !q || [u.EMPLY_NM, u.EMPLY_ID, u.EMAIL].join(' ').toLowerCase().indexOf(q) >= 0; }).forEach(function(u) {
			var on = !!picked[u.EMPLY_ID], dim = !u.EMAIL;
			var box = $('<input tabindex="-1">').attr({ type: pickMode === 'to' ? 'checkbox' : 'radio', 'aria-label': u.EMPLY_NM }).prop({ checked: on, disabled: dim });
			var mail = $('<td>').text(u.EMAIL || '메일 없음');
			if (pickMode === 'from' && u.EMAIL && used.indexOf(u.EMAIL.toLowerCase()) >= 0) mail.append($('<span class="mc-st ok ml-1">').text('이미 등록'));
			$b.append($('<tr>').attr('data-id', u.EMPLY_ID).toggleClass('dim', dim).toggleClass('table-active', on)
				.append($('<td>').append(box)).append($('<td>').text(u.EMPLY_NM)).append($('<td>').text(u.EMPLY_ID)).append($('<td>').text(u.ROLE_NMS || '직원')).append(mail));
		});
		if (!$b.children().length) boEmpty($b, '찾는 계정이 없습니다.');
		$('#mcPickCnt').text(Object.keys(picked).length + '명 선택');
	}
	function pickOk() {
		var sel = users.filter(function(u) { return picked[u.EMPLY_ID]; });
		if (pickMode === 'to') {
			// 직접 입력한 주소는 두고, 계정 칩은 고른 것으로 바꾼다
			to = to.filter(function(t) { return !t.ID; }).concat(sel.map(function(u) { return { V: u.EMPLY_ID, ID: u.EMPLY_ID, NM: u.EMPLY_NM, EMAIL: u.EMAIL }; }));
			paintTo();
		} else if (sel.length) {
			if ($('#mAcc').val() !== 'NEW' && acc($('#mAcc').val()).SERVER && !$('#mPw').val()) $('#mFromAddr').prop('readonly', false);
			$('#mFromAddr').val(sel[0].EMAIL);
			if (!$('#mAccNm').val()) $('#mAccNm').val(sel[0].EMPLY_NM);
		}
		closePick();
	}

	function save(after, failed) {
		addTyped();
		hrPost('/admin/system/mail/saveData.do', {
			USE_CD: cur.USE_CD, ACC_SQ: $('#mAcc').val(), ACC_NM: $('#mAccNm').val(), FROM_NM: $('#mFromNm').val(), FROM_ADDR: $('#mFromAddr').val(), APP_PW: $('#mPw').val(),
			REPLY_TO: $('#mReply').val(), BCC: $('#mBcc').val(), CONTACT: $('#mContact').val(), TO_LIST: to.map(function(t) { return t.V; }).join(',')
		}, function(res) {
			var accSq = res.result;
			load(function() {
				cur = data.uses.filter(function(u) { return u.USE_CD === cur.USE_CD; })[0];
				$('#mAcc').empty().append(data.accounts.map(function(a) { return $('<option>').val(a.ACC_SQ).text(a.ACC_NM + ' · ' + (a.FROM_ADDR || '주소 없음')); }))
					.append($('<option value="NEW">').text('+ 새 계정 추가')).val(accSq);
				fillAccount(accSq);
				to = (cur.TO || []).slice(); paintTo();
				if (after) after(accSq);
			});
		}, failed);
	}

	function openHist() {
		hrPost('/admin/system/mail/histData.do', {}, function(res) {
			var $b = $('#mcHistBody').empty();
			res.result.forEach(function(h) { $b.append($('<tr>').append($('<td>').text(h.REG_DT)).append($('<td>').text(h.EMPLY_NM || h.EMPLY_ID)).append($('<td>').text(h.TARGET)).append($('<td>').text(h.SUMMARY))); });
			if (!res.result.length) boEmpty($b, '아직 바꾼 기록이 없습니다.');
			$('#mcHist').modal('show');
		});
	}
	</script>
</body>
</html>
