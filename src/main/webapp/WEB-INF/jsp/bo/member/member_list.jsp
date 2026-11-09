<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/system/system_style.jspf"%>
<style>
	.ac-link { background: none; border: 0; padding: 0; color: #0b6e8a; font-weight: 600; text-decoration: underline; white-space: nowrap; }
	.sys-pill.ok { background: #e6f6ea; color: #17692f; } .sys-pill.warn { background: #fff5dc; color: #7a5600; } .sys-pill.bad { background: #fdeaea; color: #a32020; }
	#alerts { display: flex; flex-wrap: wrap; gap: 8px; }
	#alerts > * { border: 1px solid #f0d9a0; background: #fff5dc; color: #7a5600; border-radius: 6px; padding: 3px 10px; font-size: 12px; font-weight: 600; }
	#alerts button.on { background: #7a5600; color: #fff; }
	#issueRows td { vertical-align: middle; }
	#issueRows .form-control { min-width: 130px; }
	.ac-secret { font-family: Consolas, monospace; font-size: 14px; font-weight: 700; }
	.ac-busy { opacity: .5; pointer-events: none; }
	.ac-section { font-size: 13px; font-weight: 700; color: #111; margin: 12px 0 8px; padding-top: 10px; border-top: 1px solid rgba(17,17,17,.1); }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header"><h3 class="card-title bTitle"><b>계정관리</b></h3></div>
				<div class="card-body">
					<div id="alerts" class="mb-2" role="group" aria-label="확인할 일"></div>
					<div class="cal-panel">
						<div class="cal-panel-body">
							<div class="form-row align-items-end">
								<div class="col-md-4 col-12 mb-2"><label for="keyword">검색 (이름·아이디·이메일)</label><input type="search" id="keyword" class="form-control form-control-sm" maxlength="50"></div>
								<div class="col-md-2 col-6 mb-2" id="pwFilterBox"><label for="pwFilter">비밀번호</label><select id="pwFilter" class="form-control form-control-sm"><option value="">전체</option><option value="Y">초기 비밀번호</option><option value="N">변경 완료</option></select></div>
								<div class="col-md-6 col-12 mb-2 text-right">
									<button type="button" class="btn btn-sm btn-outline-secondary" onclick="downloadCsv();"><i class="fas fa-file-excel" aria-hidden="true"></i> 엑셀 내려받기</button>
									<button type="button" class="btn btn-sm btn-primary" onclick="openIssue();"><i class="fas fa-plus" aria-hidden="true"></i> 계정 발급</button>
								</div>
							</div>
						</div>
					</div>
					<div class="cal-panel">
						<div class="cate-tabs" id="tabs" role="tablist" aria-label="계정 구분"></div>
						<div class="table-responsive px-3">
							<table class="table table-sm table-hover cal-table mb-0"><thead id="listHead"></thead><tbody id="listBody"></tbody></table>
						</div>
						<div class="small text-muted px-3 py-2">주민등록번호와 주소는 계정 카드에서만 볼 수 있습니다.</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="cardModal" tabindex="-1" role="dialog" aria-labelledby="cardTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document"><div class="modal-content">
			<div class="modal-header"><h5 class="modal-title" id="cardTitle">계정 카드</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
			<form id="cardForm" onsubmit="saveCard(); return false;">
				<input type="hidden" name="EMPLY_SQ" id="cSq">
				<div class="modal-body">
					<div class="form-row">
						<div class="col-md-4 mb-2"><label for="cId">아이디 *</label><input id="cId" name="EMPLY_ID" class="form-control form-control-sm sys-mono" maxlength="50" required></div>
						<div class="col-md-4 mb-2"><label for="cName">이름 *</label><input id="cName" name="EMPLY_NM" class="form-control form-control-sm" maxlength="50" required></div>
						<div class="col-md-4 mb-2"><label for="cSex">성별</label><select id="cSex" name="EMPLY_SEX_TYP_CD" class="form-control form-control-sm"><option value=""></option><option value="M">남</option><option value="F">여</option></select></div>
						<div class="col-md-6 mb-2"><label for="cEmail">이메일</label><input id="cEmail" name="EMPLY_EMAIL" type="email" class="form-control form-control-sm" maxlength="200"></div>
						<div class="col-md-6 mb-2"><label for="cPhone">휴대전화</label><input id="cPhone" name="EMPLY_PH_NUM" class="form-control form-control-sm" maxlength="50"></div>
						<div class="col-md-8 mb-2"><label for="cAddr">주소</label><input id="cAddr" name="EMPLY_HOME_ADDR" class="form-control form-control-sm" maxlength="50"></div>
						<div class="col-md-4 mb-2"><label for="cRrn">주민등록번호 (바꿀 때만 전체 입력)</label><input id="cRrn" name="EMPLY_RRN" class="form-control form-control-sm" maxlength="14" autocomplete="off"></div>
					</div>
					<div class="ac-section">연결·구분</div>
					<div class="form-row align-items-end">
						<div class="col-md-6 mb-2"><label for="cStaff">연결 직원</label><div class="d-flex"><select id="cStaff" class="form-control form-control-sm"></select><button type="button" class="btn btn-sm btn-outline-secondary ml-1 text-nowrap" onclick="saveLink();">연결 저장</button></div></div>
						<div class="col-md-6 mb-2"><label>계정 구분</label><div id="cType" class="d-flex align-items-center flex-wrap" style="gap:6px"></div></div>
					</div>
					<div class="ac-section">비밀번호</div>
					<div class="d-flex align-items-center flex-wrap" style="gap:8px"><span id="cPw"></span><button type="button" class="btn btn-sm btn-outline-secondary" onclick="resetPw();"><i class="fas fa-key" aria-hidden="true"></i> 초기 비밀번호 재발급</button><span class="small text-muted" id="cLogin"></span></div>
				</div>
				<div class="modal-footer"><span id="cStatusBtns" class="mr-auto"></span><button type="submit" class="btn btn-sm btn-primary">저장</button></div>
			</form>
		</div></div>
	</div>

	<div class="modal fade" id="issueModal" tabindex="-1" role="dialog" aria-labelledby="issueTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document"><div class="modal-content">
			<div class="modal-header"><h5 class="modal-title" id="issueTitle">계정 발급</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
			<div class="modal-body">
				<div class="form-row align-items-end">
					<div class="col-md-4 mb-2" role="radiogroup" aria-label="계정 구분">
						<div class="form-check form-check-inline"><input class="form-check-input" type="radio" name="kind" id="kStaff" value="1" checked><label class="form-check-label" for="kStaff">직원 계정</label></div>
						<div class="form-check form-check-inline"><input class="form-check-input" type="radio" name="kind" id="kAdmin" value="2"><label class="form-check-label" for="kAdmin">관리자 계정</label></div>
					</div>
					<div class="col-md-4 mb-2" id="roleBox" hidden><label for="iRole">권한 *</label><select id="iRole" class="form-control form-control-sm"></select></div>
					<div class="col-md-4 mb-2" id="manualToggle" hidden><div class="form-check"><input class="form-check-input" type="checkbox" id="iManual"><label class="form-check-label" for="iManual">직원 외 담당자 직접 입력</label></div></div>
				</div>
				<div id="staffPick">
					<input type="search" id="iSearch" class="form-control form-control-sm mb-2" placeholder="재직자 이름·이메일 검색" aria-label="재직자 검색">
					<div class="table-responsive" style="max-height:52vh;overflow-y:auto">
						<table class="table table-sm cal-table mb-0"><thead><tr><th><input type="checkbox" id="iAll" aria-label="발급 가능한 재직자 전체 선택"></th><th>이름</th><th>소속</th><th>이메일</th><th>아이디</th><th>확인</th></tr></thead><tbody id="issueRows"></tbody></table>
					</div>
				</div>
				<div id="manualPick" class="form-row" hidden>
					<div class="col-md-4 mb-2"><label for="mId">아이디 *</label><input id="mId" class="form-control form-control-sm sys-mono" maxlength="50"></div>
					<div class="col-md-4 mb-2"><label for="mName">이름 *</label><input id="mName" class="form-control form-control-sm" maxlength="50"></div>
					<div class="col-md-4 mb-2"><label for="mEmail">이메일</label><input id="mEmail" type="email" class="form-control form-control-sm" maxlength="200"></div>
				</div>
			</div>
			<div class="modal-footer"><span class="small text-muted mr-auto">아이디는 이메일 @ 앞부분입니다. 초기 비밀번호는 발급 직후 한 번만 표시합니다.</span><button type="button" class="btn btn-sm btn-primary" id="issueBtn" onclick="issue();">발급</button></div>
		</div></div>
	</div>

	<div class="modal fade" id="doneModal" tabindex="-1" role="dialog" aria-labelledby="doneTitle" aria-hidden="true" data-backdrop="static" data-keyboard="false">
		<div class="modal-dialog modal-lg" role="document"><div class="modal-content">
			<div class="modal-header"><h5 class="modal-title" id="doneTitle">초기 비밀번호</h5></div>
			<div class="modal-body">
				<div class="alert alert-warning py-2">이 창을 닫으면 다시 볼 수 없습니다. 직원에게 전달한 뒤 닫아 주세요.</div>
				<div class="table-responsive" style="max-height:52vh;overflow-y:auto"><table class="table table-sm cal-table mb-0"><thead><tr><th>이름</th><th>아이디</th><th>초기 비밀번호</th><th></th></tr></thead><tbody id="doneRows"></tbody></table></div>
			</div>
			<div class="modal-footer"><button type="button" class="btn btn-sm btn-outline-secondary" id="copyAll">전체 복사</button><button type="button" class="btn btn-sm btn-primary" data-dismiss="modal">전달했습니다, 닫기</button></div>
		</div></div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>
	<script>
	var data = { accounts: [], pending: [], roles: [] }, tab = 'staff', leftOnly = false, card = null, pendingPick = null, done = [];
	var TABS = [['staff', '직원 계정'], ['admin', '관리자 계정'], ['pending', '미발급 재직자'], ['inactive', '중지·퇴사'], ['fix', '정리 필요']];

	$(load);
	$('#keyword, #pwFilter').on('input change', render);

	function load() {
		hrPost('/admin/member/memberListData.do', {}, function(res) {
			data = res.result;
			$('#iRole').empty();
			data.roles.forEach(function(r) { $('#iRole').append($('<option>').val(r.ROLE_SQ).text(r.ROLE_NM)); });
			render();
		});
	}

	function kindOf(a) {
		if (a.DEL_YN === 'Y' || a.USE_YN === 'N') return 'inactive';
		if (!a.EMPLY_ID || (a.EMPLY_AUTH_TYP_CD !== '1' && a.EMPLY_AUTH_TYP_CD !== '2')) return 'fix';
		return a.EMPLY_AUTH_TYP_CD === '1' ? 'staff' : 'admin';
	}
	function isLeft(a) { return a.STAFF_STATUS === 'LEFT' && kindOf(a) !== 'inactive'; }
	function has(v, q) { return String(v || '').toLowerCase().indexOf(q) >= 0; }

	function shown() {
		var q = $.trim($('#keyword').val()).toLowerCase(), pw = $('#pwFilter').val();
		if (tab === 'pending') return data.pending.filter(function(s) { return !q || has(s.STAFF_NM, q) || has(s.EMAIL, q); });
		return data.accounts.filter(function(a) {
			if (leftOnly ? !isLeft(a) : kindOf(a) !== tab) return false;
			if (pw && a.PW_INIT_YN !== pw) return false;
			return !q || has(a.EMPLY_NM, q) || has(a.EMPLY_ID, q) || has(a.EMPLY_EMAIL, q);
		});
	}

	function render() {
		var count = {}, left = data.accounts.filter(isLeft).length, noMail = data.pending.filter(function(s) { return !idOf(s.EMAIL); }).length;
		data.accounts.forEach(function(a) { var k = kindOf(a); count[k] = (count[k] || 0) + 1; });
		count.pending = data.pending.length;
		var $a = $('#alerts').empty();
		if (left) $('<button type="button">').toggleClass('on', leftOnly).attr('aria-pressed', leftOnly).text('퇴사한 직원의 사용 중 계정 ' + left + '건').on('click', function() { leftOnly = !leftOnly; render(); }).appendTo($a);
		if (noMail) $('<span>').text('이메일이 없어 발급할 수 없는 재직자 ' + noMail + '명').appendTo($a);
		if (!left) leftOnly = false;
		var $t = $('#tabs').empty();
		TABS.forEach(function(x) { $t.append(hrTab(x[0], x[1], count[x[0]] || 0, !leftOnly && tab === x[0])); });
		$t.find('.cate-tab').on('click', function() { tab = $(this).attr('data-tab'); leftOnly = false; render(); });
		$('#pwFilterBox').toggle(tab !== 'pending' || leftOnly);
		(tab === 'pending' && !leftOnly ? renderPending : renderAccounts)();
	}

	function pill(text, cls) { return $('<span class="sys-pill">').addClass(cls || '').text(text); }
	function statusPill(a) { return a.DEL_YN === 'Y' ? pill('퇴사', 'bad') : a.USE_YN === 'N' ? pill('사용중지', 'bad') : pill('사용중', 'ok'); }
	function staffPill(a) { return !a.STAFF_SQ ? pill('미연결') : a.STAFF_STATUS === 'WORK' ? pill('재직', 'info') : pill('퇴사', 'bad'); }
	function pwPill(a) { return a.PW_INIT_YN === 'Y' ? pill('초기 비밀번호', 'warn') : pill('변경 완료', 'ok'); }
	function typeText(a) { return a.EMPLY_AUTH_TYP_CD === '1' ? '직원' : a.EMPLY_AUTH_TYP_CD === '2' ? '관리자' : '미지정'; }

	function head(cols) { $('#listHead').html('<tr>' + cols.map(function(c) { return '<th>' + c + '</th>'; }).join('') + '</tr>'); }
	function empty(cols, msg) { $('#listBody').empty().append($('<tr>').append($('<td class="cal-empty">').attr('colspan', cols).text(msg))); }

	function renderAccounts() {
		var admin = tab === 'admin' && !leftOnly, cols = ['이름', '아이디', '구분'].concat(admin ? ['권한'] : []).concat(['이메일', '연결 직원', '비밀번호', '최근 로그인', '상태']);
		head(cols);
		var rows = shown();
		if (!rows.length) { empty(cols.length, '해당하는 계정이 없습니다.'); return; }
		var $b = $('#listBody').empty();
		rows.forEach(function(a) {
			var $tr = $('<tr>').append($('<td>').append($('<button type="button" class="ac-link">').text(a.EMPLY_NM || '(이름 없음)').on('click', function() { openCard(a.EMPLY_SQ); })))
				.append($('<td class="sys-mono">').text(a.EMPLY_ID || '-')).append($('<td>').text(typeText(a)));
			if (admin) $tr.append($('<td>').append(a.ROLE_NMS ? pill(a.ROLE_NMS, 'info') : pill('권한 없음', 'warn')));
			$tr.append($('<td>').text(a.EMPLY_EMAIL || '')).append($('<td>').append(staffPill(a))).append($('<td>').append(pwPill(a))).append($('<td>').text(a.LAST_LOGIN_DT || '-')).append($('<td>').append(statusPill(a))).appendTo($b);
		});
	}

	function renderPending() {
		head(['이름', '소속', '부서', '이메일', '아이디', '']);
		var rows = shown();
		if (!rows.length) { empty(6, '계정이 없는 재직자가 없습니다.'); return; }
		var $b = $('#listBody').empty();
		rows.forEach(function(s) {
			var id = idOf(s.EMAIL);
			$('<tr>').append($('<td>').text(s.STAFF_NM)).append($('<td>').text(s.ORG_NM || '')).append($('<td>').text(s.DEPT_NM || '')).append($('<td>').text(s.EMAIL || ''))
				.append($('<td class="sys-mono">').text(id || '-'))
				.append($('<td class="text-right">').append(id ? $('<button type="button" class="btn btn-xs btn-outline-primary">발급</button>').attr('aria-label', s.STAFF_NM + ' 계정 발급').on('click', function() { openIssue(s.STAFF_SQ); }) : pill('이메일 없음', 'bad'))).appendTo($b);
		});
	}

	function idOf(email) { var m = /^([^@\s]+)@[^@\s]+$/.exec($.trim(email || '')); return m ? m[1] : null; }

	// ── 계정 카드 ──

	function openCard(sq) {
		hrPost('/admin/member/memberCardData.do', { EMPLY_SQ: sq }, function(res) {
			card = res.result;
			$('#cardTitle').text((card.EMPLY_NM || '이름 없음') + ' · ' + typeText(card) + ' 계정');
			$('#cSq').val(card.EMPLY_SQ); $('#cId').val(card.EMPLY_ID || ''); $('#cName').val(card.EMPLY_NM || ''); $('#cSex').val(card.EMPLY_SEX_TYP_CD || '');
			$('#cEmail').val(card.EMPLY_EMAIL || ''); $('#cPhone').val(card.EMPLY_PH_NUM || ''); $('#cAddr').val(card.EMPLY_HOME_ADDR || ''); $('#cRrn').val(card.EMPLY_RRN || '');
			var $s = $('#cStaff').empty().append('<option value="">연결 안 함</option>');
			if (card.STAFF_SQ) $s.append($('<option>').val(card.STAFF_SQ).text(card.STAFF_NM + ' (현재)'));
			data.pending.forEach(function(x) { $s.append($('<option>').val(x.STAFF_SQ).text(x.STAFF_NM + (x.EMAIL ? ' · ' + x.EMAIL : ''))); });
			$s.val(card.STAFF_SQ || '');
			paintType();
			$('#cPw').empty().append(pwPill(card));
			$('#cLogin').text('최근 로그인 ' + (card.LAST_LOGIN_DT || '-'));
			paintStatus();
			$('#cardModal').modal('show');
		});
	}

	function paintType() {
		var $t = $('#cType').empty().append(pill(typeText(card), 'info'));
		if (card.ROLE_NMS) $t.append(pill(card.ROLE_NMS));
		if (card.EMPLY_AUTH_TYP_CD !== '2') {
			var $role = $('<select class="form-control form-control-sm" style="width:auto" aria-label="관리자 권한">');
			data.roles.forEach(function(r) { $role.append($('<option>').val(r.ROLE_SQ).text(r.ROLE_NM)); });
			$t.append($role).append($('<button type="button" class="btn btn-sm btn-outline-primary text-nowrap">관리자로 지정</button>').on('click', function() { setType('2', $role.val()); }));
		}
		if (card.EMPLY_AUTH_TYP_CD !== '1') $t.append($('<button type="button" class="btn btn-sm btn-outline-secondary text-nowrap">직원으로 지정</button>').on('click', function() { setType('1'); }));
	}

	function setType(type, roleSq) {
		var msg = type === '2' ? '이 계정을 관리자로 지정할까요? 관리자 화면에 접속할 수 있게 됩니다.' : '이 계정을 직원으로 지정할까요? 권한이 모두 해제되고 관리자 화면에 접속할 수 없습니다.';
		bootbox.confirm(msg, function(ok) {
			if (!ok) return;
			var d = { EMPLY_SQ: card.EMPLY_SQ, TYPE_CD: type };
			if (roleSq) d.ROLE_SQ = roleSq;
			hrPost('/admin/member/setTypeData.do', d, afterChange);
		});
	}

	function paintStatus() {
		var $b = $('#cStatusBtns').empty();
		function btn(label, action, cls, msg) { $('<button type="button" class="btn btn-sm mr-1">').addClass(cls).text(label).on('click', function() { confirmStatus(action, msg); }).appendTo($b); }
		if (card.USE_YN === 'N') btn('사용 재개', 'RESUME', 'btn-outline-secondary', '이 계정의 사용을 재개할까요?');
		else btn('사용중지', 'SUSPEND', 'btn-outline-secondary', '이 계정을 중지할까요? 다음 요청부터 관리자 화면 사용과 로그인이 막힙니다.');
		if (card.DEL_YN === 'Y') btn('퇴사 취소', 'RESTORE', 'btn-outline-secondary', '퇴사 처리를 취소할까요?');
		else btn('퇴사 처리', 'RETIRE', 'btn-outline-danger', '이 계정을 퇴사 처리할까요? 로그인이 막히며 나중에 복구할 수 있습니다.');
	}

	function confirmStatus(action, msg) {
		bootbox.confirm(msg, function(ok) { if (ok) hrPost('/admin/member/setStatusData.do', { EMPLY_SQ: card.EMPLY_SQ, ACTION: action }, afterChange); });
	}

	function afterChange() { $('#cardModal').modal('hide'); load(); }

	function saveCard() { hrPost('/admin/member/saveMemberData.do', $('#cardForm').serialize(), afterChange); }

	function saveLink() {
		var d = { EMPLY_SQ: card.EMPLY_SQ };
		if ($('#cStaff').val()) d.STAFF_SQ = $('#cStaff').val();
		hrPost('/admin/member/linkStaffData.do', d, afterChange);
	}

	function resetPw() {
		bootbox.confirm('초기 비밀번호를 새로 발급할까요? 지금 비밀번호는 쓸 수 없게 됩니다.', function(ok) {
			if (ok) hrPost('/admin/member/resetPasswordData.do', { EMPLY_SQ: card.EMPLY_SQ }, function(res) { afterChange(); showDone([res.result]); });
		});
	}

	// ── 발급 ──

	function openIssue(staffSq) {
		pendingPick = staffSq || null;
		$('#kStaff').prop('checked', true);
		$('#iManual').prop('checked', false);
		$('#iSearch, #mId, #mName, #mEmail').val('');
		$('#iAll').prop('checked', false);
		buildRows();
		applyKind();
		$('#issueModal').modal('show');
	}

	function buildRows() {
		var $b = $('#issueRows').empty();
		data.pending.forEach(function(s) {
			var id = idOf(s.EMAIL);
			var $box = $('<input type="checkbox" class="pick">').val(s.STAFF_SQ).prop({ disabled: !id, checked: pendingPick === s.STAFF_SQ }).attr('aria-label', s.STAFF_NM + ' 선택');
			var $id = $('<input class="form-control form-control-sm sys-mono row-id" maxlength="50">').val(id || '').prop('disabled', !id).attr('aria-label', s.STAFF_NM + ' 아이디');
			$('<tr>').attr('data-q', (s.STAFF_NM + ' ' + (s.EMAIL || '')).toLowerCase())
				.append($('<td>').append($box)).append($('<td>').text(s.STAFF_NM)).append($('<td>').text(s.ORG_NM || '')).append($('<td>').text(s.EMAIL || '-')).append($('<td>').append($id)).append($('<td class="row-state">')).appendTo($b);
		});
		checkRows();
	}

	function applyKind() {
		var admin = $('#kAdmin').prop('checked'), manual = admin && $('#iManual').prop('checked');
		$('#roleBox, #manualToggle').prop('hidden', !admin);
		$('#staffPick').prop('hidden', manual);
		$('#manualPick').prop('hidden', !manual);
		updateIssueBtn();
	}
	$('input[name=kind], #iManual').on('change', applyKind);

	function checkRows() {
		var taken = {};
		data.accounts.forEach(function(a) { if (a.EMPLY_ID) taken[a.EMPLY_ID.toLowerCase()] = true; });
		var used = {};
		$('#issueRows tr').each(function() {
			var $r = $(this), $id = $r.find('.row-id'), id = $.trim($id.val()).toLowerCase(), picked = $r.find('.pick').prop('checked'), $state = $r.find('.row-state').empty();
			if ($id.prop('disabled')) { $state.append(pill('이메일 없음', 'bad')); return; }
			var bad = !/^[a-z0-9._-]{2,50}$/.test(id) ? '형식 오류' : taken[id] ? '아이디 중복' : (picked && used[id]) ? '선택 안에서 중복' : null;
			if (picked) used[id] = true;
			$r.toggleClass('has-error', !!bad && picked);
			$state.append(bad ? pill(bad, 'bad') : pill('가능', 'ok'));
		});
		updateIssueBtn();
	}
	$('#issueRows').on('input change', '.row-id, .pick', checkRows);

	$('#iSearch').on('input', function() { var q = $.trim(this.value).toLowerCase(); $('#issueRows tr').each(function() { $(this).toggle($(this).attr('data-q').indexOf(q) >= 0); }); });
	$('#iAll').on('change', function() { $('#issueRows tr:visible .pick:enabled').prop('checked', this.checked); checkRows(); });

	function updateIssueBtn() {
		var n = $('.pick:checked').length, manual = !$('#manualPick').prop('hidden');
		$('#issueBtn').text(manual ? '발급' : n + '명 발급').prop('disabled', !manual && (!n || $('#issueRows tr.has-error').length > 0));
	}

	function issue() {
		var admin = $('#kAdmin').prop('checked'), role = admin ? $('#iRole').val() : null, $btn = $('#issueBtn').prop('disabled', true), $body = $('#issueModal .modal-body').addClass('ac-busy');
		function finish() { $body.removeClass('ac-busy'); $btn.prop('disabled', false); updateIssueBtn(); }
		function ok(res) { finish(); $('#issueModal').modal('hide'); load(); showDone(res.result); }
		if (!$('#manualPick').prop('hidden')) {
			hrPost('/admin/member/issueManualData.do', { EMPLY_ID: $.trim($('#mId').val()), EMPLY_NM: $.trim($('#mName').val()), EMPLY_EMAIL: $.trim($('#mEmail').val()), ROLE_SQ: role }, ok, finish);
			return;
		}
		var sqs = [], ids = [];
		$('#issueRows tr').each(function() { if ($(this).find('.pick').prop('checked')) { sqs.push($(this).find('.pick').val()); ids.push($.trim($(this).find('.row-id').val())); } });
		var d = { STAFF_SQ: sqs, EMPLY_ID: ids, TYPE_CD: admin ? '2' : '1' };
		if (role) d.ROLE_SQ = role;
		hrPost('/admin/member/issueStaffData.do', $.param(d, true), ok, finish);
	}

	function showDone(list) {
		done = list;
		var $b = $('#doneRows').empty();
		list.forEach(function(c) {
			$('<tr>').append($('<td>').text(c.EMPLY_NM)).append($('<td class="sys-mono">').text(c.EMPLY_ID)).append($('<td class="ac-secret">').text(c.PASSWORD))
				.append($('<td class="text-right">').append($('<button type="button" class="btn btn-xs btn-outline-secondary">복사</button>').attr('aria-label', c.EMPLY_NM + ' 초기 비밀번호 복사').on('click', function() { copy(c.PASSWORD, this); }))).appendTo($b);
		});
		$('#doneModal').modal('show');
	}
	$('#doneModal').on('hidden.bs.modal', function() { done = []; $('#doneRows').empty(); });
	$('#copyAll').on('click', function() { copy(done.map(function(c) { return [c.EMPLY_NM, c.EMPLY_ID, c.PASSWORD].join('\t'); }).join('\n'), this); });

	function copy(text, button) {
		var label = $(button).text();
		navigator.clipboard.writeText(text).then(function() { $(button).text('복사됨'); setTimeout(function() { $(button).text(label); }, 1500); }, function() { bootbox.alert('복사하지 못했습니다. 직접 선택해 복사해 주세요.'); });
	}

	function downloadCsv() {
		function cell(v) { var s = String(v === undefined || v === null ? '' : v); if (/^[=+\-@]/.test(s)) s = "'" + s; return '"' + s.replace(/"/g, '""') + '"'; }
		var rows = tab === 'pending' && !leftOnly ? [['이름', '소속', '부서', '이메일']].concat(shown().map(function(s) { return [s.STAFF_NM, s.ORG_NM, s.DEPT_NM, s.EMAIL]; }))
			: [['이름', '아이디', '구분', '권한', '이메일', '비밀번호', '최근 로그인']].concat(shown().map(function(a) { return [a.EMPLY_NM, a.EMPLY_ID, typeText(a), a.ROLE_NMS, a.EMPLY_EMAIL, a.PW_INIT_YN === 'Y' ? '초기' : '변경 완료', a.LAST_LOGIN_DT]; }));
		var url = URL.createObjectURL(new Blob(['﻿' + rows.map(function(r) { return r.map(cell).join(','); }).join('\r\n')], { type: 'text/csv;charset=utf-8' }));
		$('<a>').attr({ href: url, download: '계정목록.csv' })[0].click();
		URL.revokeObjectURL(url);
	}
	</script>
</body>
</html>
