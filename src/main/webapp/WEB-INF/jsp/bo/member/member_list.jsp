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
	.ac-filled { background: #dff3f9 !important; }
	.ac-roles { display: grid; grid-template-columns: repeat(auto-fill, minmax(190px, 1fr)); gap: 6px; }
	.ac-role { display: flex; gap: 8px; align-items: flex-start; margin: 0; padding: 7px 9px; border: 1px solid rgba(17,17,17,.12); border-radius: 7px; font-size: 13px; font-weight: 600 !important; color: #222 !important; cursor: pointer; }
	.ac-role input { margin-top: 3px; }
	.ac-role small { display: block; font-weight: 400; color: #666; font-size: 11px; line-height: 1.35; }
	.ac-role.on { border-color: #0b6e8a; background: #dff3f9; }
	.ac-role.lock { opacity: .6; cursor: not-allowed; }
	.ac-role:focus-within { outline: 2px solid #16d5ff; outline-offset: 1px; }
	.ac-results { border: 1px solid rgba(17,17,17,.12); border-radius: 6px; max-height: 230px; overflow-y: auto; margin-top: 4px; font-size: 12px; }
	.ac-result { display: grid; grid-template-columns: 90px 110px minmax(0, 1.4fr) 110px minmax(0, 1fr) 96px; gap: 8px; align-items: center; padding: 5px 8px; cursor: pointer; }
	.ac-result > span { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
	.ac-result:hover, .ac-result.active { background: #dff3f9; }
	.ac-result[aria-disabled=true] { color: #999; cursor: not-allowed; background: none; }
	.ac-result-head { font-weight: 600; color: #666; cursor: default; background: #fafbfc !important; }
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
						<div id="bulkBar" class="px-3 pt-2" hidden>
							<b id="bulkCount" class="mr-2"></b>
							<button type="button" class="btn btn-xs btn-outline-secondary" onclick="bulk('SUSPEND');">전체 사용중지</button>
							<button type="button" class="btn btn-xs btn-outline-danger" onclick="bulk('RETIRE');">전체 퇴사</button>
							<button type="button" class="btn btn-xs btn-danger" onclick="bulk('DELETE');">전체 삭제</button>
						</div>
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
				<input type="hidden" name="STAFF_SQ" id="cStaffSq">
				<input type="hidden" name="COPY_RRN" id="cCopyRrn">
				<div class="cate-tabs" id="cardTabs" role="tablist" aria-label="계정 카드 구분"></div>
				<div class="modal-body">
					<div class="ac-pane" data-pane="basic">
					<div class="mb-2">
						<label for="cStaffSearch">연결 직원</label>
						<div id="staffChosen" class="d-flex align-items-center flex-wrap" style="gap:6px" hidden></div>
						<div id="staffSearchBox">
							<input id="cStaffSearch" class="form-control form-control-sm" autocomplete="off" maxlength="50" role="combobox" aria-expanded="false" aria-controls="staffResults" placeholder="이름·메일·전화번호로 직원 검색">
							<div id="staffResults" class="ac-results" role="listbox" aria-label="직원 검색 결과" hidden></div>
						</div>
						<div id="staffNote" class="d-flex align-items-center small mt-1" style="gap:6px" hidden><span class="sys-pill info">인사카드에서 불러옴</span><span class="text-muted">저장을 눌러야 반영됩니다</span><button type="button" class="btn btn-xs btn-outline-secondary" onclick="undoStaff();">되돌리기</button></div>
					</div>
					<div class="form-row">
						<div class="col-md-4 mb-2"><label for="cId">아이디 *</label><input id="cId" name="EMPLY_ID" class="form-control form-control-sm sys-mono" maxlength="50" required></div>
						<div class="col-md-4 mb-2"><label for="cName">이름 *</label><input id="cName" name="EMPLY_NM" class="form-control form-control-sm" maxlength="50" required></div>
						<div class="col-md-4 mb-2"><label for="cSex">성별</label><select id="cSex" name="EMPLY_SEX_TYP_CD" class="form-control form-control-sm"></select></div>
						<div class="col-md-6 mb-2"><label for="cEmail">회사 메일</label><input id="cEmail" name="EMPLY_EMAIL" type="email" class="form-control form-control-sm" maxlength="200"></div>
						<div class="col-md-6 mb-2"><label for="cPhone">휴대전화</label><input id="cPhone" name="EMPLY_PH_NUM" class="form-control form-control-sm" maxlength="50"></div>
						<div class="col-md-8 mb-2"><label for="cAddr">주소</label><input id="cAddr" name="EMPLY_HOME_ADDR" class="form-control form-control-sm" maxlength="500"></div>
						<div class="col-md-4 mb-2"><label for="cRrn">주민등록번호 (바꿀 때만 전체 입력)</label><input id="cRrn" name="EMPLY_RRN" class="form-control form-control-sm" maxlength="14" autocomplete="off"></div>
					</div>
					</div>
					<div class="ac-pane" data-pane="role" hidden>
						<div class="mb-2"><span id="cKind" class="sys-pill info"></span> <span class="small text-muted">권한이 없으면 직원 계정, 하나라도 있으면 관리자 계정입니다</span></div>
						<div id="cType" class="ac-roles mb-2" role="group" aria-label="계정 권한"></div>
					</div>
					<div class="ac-pane" data-pane="pw" hidden>
						<div class="d-flex align-items-center flex-wrap" style="gap:8px"><span id="cPw"></span><button type="button" class="btn btn-sm btn-outline-secondary" onclick="resetPw();"><i class="fas fa-key" aria-hidden="true"></i> 초기 비밀번호 재발급</button><span class="small text-muted" id="cLogin"></span></div>
					</div>
					<div class="ac-pane" data-pane="secret" hidden>
						<div class="custom-control custom-switch mb-2"><input type="checkbox" class="custom-control-input" id="cSecret"><label class="custom-control-label font-weight-bold" for="cSecret">🔒 시크릿 계정</label></div>
						<div class="small text-muted">켜면 이 계정에 연결된 직원의 투입현황·급여관리 행과 합계·건수·엑셀이 시크릿이 아닌 사람에게 모두 빠집니다. 시크릿 계정끼리는 서로 보입니다. 이 탭은 슈퍼관리자에게만 보이고, 바로 저장됩니다.</div>
						<div class="small mt-2" id="cSecretNote"></div>
					</div>
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
					<input type="search" id="iSearch" class="form-control form-control-sm mb-2" placeholder="재직자 이름·회사 메일 검색" aria-label="재직자 검색">
					<div class="table-responsive" style="max-height:52vh;overflow-y:auto">
						<table class="table table-sm cal-table mb-0"><thead><tr><th><input type="checkbox" id="iAll" aria-label="발급 가능한 재직자 전체 선택"></th><th>이름</th><th>소속</th><th>회사 메일</th><th>아이디</th><th>확인</th></tr></thead><tbody id="issueRows"></tbody></table>
					</div>
				</div>
				<div id="manualPick" class="form-row" hidden>
					<div class="col-md-4 mb-2"><label for="mId">아이디 *</label><input id="mId" class="form-control form-control-sm sys-mono" maxlength="50"></div>
					<div class="col-md-4 mb-2"><label for="mName">이름 *</label><input id="mName" class="form-control form-control-sm" maxlength="50"></div>
					<div class="col-md-4 mb-2"><label for="mEmail">이메일</label><input id="mEmail" type="email" class="form-control form-control-sm" maxlength="200"></div>
				</div>
			</div>
			<div class="modal-footer"><span class="small text-muted mr-auto">아이디는 회사 메일 @ 앞부분입니다. 직접 적은 회사 메일은 인사정보에도 저장됩니다. 초기 비밀번호는 발급 직후 한 번만 표시합니다.</span><button type="button" class="btn btn-sm btn-primary" id="issueBtn" onclick="issue();">발급</button></div>
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
	hrFillSelect('#cSex', 'MEM_GENDER', ['', '']);
	var data = { accounts: [], pending: [], roles: [] }, tab = 'staff', leftOnly = false, card = null, pendingPick = null, done = [];
	var linked = null, staffRows = [], staffActive = -1, staffTimer = null, staffSeq = 0;
	var TABS = [['staff', '직원 계정'], ['admin', '관리자 계정'], ['pending', '미발급 재직자'], ['inactive', '중지·퇴사'], ['fix', '정리 필요']];

	$(load);
	$('#keyword, #pwFilter').on('input change', render);

	function load() {
		hrPost('/admin/member/memberListData.do', {}, function(res) {
			data = res.result;
			$('#iRole').empty().append('<option value="">권한 선택</option>');
			data.roles.filter(function(r) { return r.GRANTABLE === 'Y'; }).forEach(function(r) { $('#iRole').append($('<option>').val(r.ROLE_SQ).text(r.ROLE_NM)); });
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
		if (tab === 'pending') return data.pending.filter(function(s) { return !q || has(s.STAFF_NM, q) || has(s.COMPANY_EMAIL, q); });
		return data.accounts.filter(function(a) {
			if (leftOnly ? !isLeft(a) : kindOf(a) !== tab) return false;
			if (pw && (a.PW_INIT_YN === 'N' ? 'N' : 'Y') !== pw) return false;
			return !q || has(a.EMPLY_NM, q) || has(a.EMPLY_ID, q) || has(a.EMPLY_EMAIL, q);
		});
	}

	function render() {
		var count = {}, left = data.accounts.filter(isLeft).length, noMail = data.pending.filter(function(s) { return !idOf(s.COMPANY_EMAIL); }).length;
		data.accounts.forEach(function(a) { var k = kindOf(a); count[k] = (count[k] || 0) + 1; });
		count.pending = data.pending.length;
		var $a = $('#alerts').empty();
		if (left) $('<button type="button">').toggleClass('on', leftOnly).attr('aria-pressed', leftOnly).text('퇴사한 직원의 사용 중 계정 ' + left + '건').on('click', function() { leftOnly = !leftOnly; render(); }).appendTo($a);
		if (noMail) $('<span>').text('회사 메일을 입력해야 발급할 수 있는 재직자 ' + noMail + '명').appendTo($a);
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
	function pwPill(a) { return a.PW_INIT_YN !== 'N' ? pill('초기 비밀번호', 'warn') : pill('변경 완료', 'ok'); }
	function typeText(a) { return a.EMPLY_AUTH_TYP_CD === '1' ? '직원' : a.EMPLY_AUTH_TYP_CD === '2' ? '관리자' : '미지정'; }

	function head(cols) { $('#listHead').html('<tr>' + cols.map(function(c) { return '<th>' + c + '</th>'; }).join('') + '</tr>'); $('#bulkBar').prop('hidden', true); }
	function empty(cols, msg) { $('#listBody').empty().append($('<tr>').append($('<td class="cal-empty">').attr('colspan', cols).text(msg))); }

	function renderAccounts() {
		var admin = tab === 'admin' && !leftOnly, cols = ['<input type="checkbox" id="pickAll" aria-label="보이는 계정 전체 선택">', '이름', '아이디', '구분'].concat(admin ? ['권한'] : []).concat(['이메일', '연결 직원', '비밀번호', '최근 로그인', '상태']);
		head(cols);
		var rows = shown();
		if (!rows.length) { empty(cols.length, '해당하는 계정이 없습니다.'); return; }
		var $b = $('#listBody').empty();
		rows.forEach(function(a) {
			var $tr = $('<tr>').append($('<td>').append($('<input type="checkbox" class="acc-pick">').val(a.EMPLY_SQ).attr('aria-label', (a.EMPLY_NM || a.EMPLY_ID || '') + ' 선택')))
				.append($('<td>').append($('<button type="button" class="ac-link">').text(a.EMPLY_NM || '(이름 없음)').on('click', function() { openCard(a.EMPLY_SQ); })))
				.append($('<td class="sys-mono">').text(a.EMPLY_ID || '-')).append($('<td>').text(typeText(a)));
			if (admin) $tr.append($('<td>').append(a.ROLE_NMS ? pill(a.ROLE_NMS, 'info') : pill('권한 없음', 'warn')));
			$tr.append($('<td>').text(a.EMPLY_EMAIL || '')).append($('<td>').append(staffPill(a))).append($('<td>').append(pwPill(a))).append($('<td>').text(a.LAST_LOGIN_DT || '-')).append($('<td>').append(statusPill(a))).appendTo($b);
		});
	}

	function picked() { return $('.acc-pick:checked').map(function() { return this.value; }).get(); }
	function updateBulk() { var n = picked().length; $('#bulkBar').prop('hidden', !n); $('#bulkCount').text(n + '개 선택'); }
	$('#listHead').on('change', '#pickAll', function() { $('.acc-pick').prop('checked', this.checked); updateBulk(); });
	$('#listBody').on('change', '.acc-pick', updateBulk);

	var ACTION_MSG = {
		SUSPEND: '선택한 계정 {n}개를 사용중지할까요?',
		RETIRE: '선택한 계정 {n}개를 퇴사 처리할까요? 로그인이 막히며 나중에 복구할 수 있습니다.',
		DELETE: '선택한 계정 {n}개를 삭제할까요? 권한·인사카드 연결도 함께 지워지며 되돌릴 수 없습니다.'
	};

	function bulk(action) {
		var sqs = picked();
		bootbox.confirm(ACTION_MSG[action].replace('{n}', sqs.length), function(ok) {
			if (ok) hrPost('/admin/member/setStatusData.do', $.param({ EMPLY_SQ: sqs, ACTION: action }, true), load);
		});
	}

	function renderPending() {
		head(['이름', '소속', '부서', '회사 메일', '아이디', '']);
		var rows = shown();
		if (!rows.length) { empty(6, '계정이 없는 재직자가 없습니다.'); return; }
		var $b = $('#listBody').empty();
		rows.forEach(function(s) {
			var id = idOf(s.COMPANY_EMAIL), $mail = $('<td>').text(s.COMPANY_EMAIL || ''), $id = $('<td class="sys-mono">'), $act = $('<td class="text-right">');
			function paint(id, err) {
				$id.text(id || '-');
				$act.empty().append(err ? pill(err, 'bad') : $('<button type="button" class="btn btn-xs btn-outline-primary">발급</button>').attr('aria-label', s.STAFF_NM + ' 계정 발급').on('click', function() { openIssue(s.STAFF_SQ); }));
			}
			// 회사 메일이 없으면 여기서 적는다. 발급할 때 인사정보에도 저장된다
			function check() { var v = $.trim(s.TYPED_EMAIL || ''), t = typedId(v); paint(t, !v ? '회사 메일 없음' : !t ? '@gmail.com 주소만' : idTaken(t) ? '아이디 중복' : null); }
			if (id) paint(id);
			else {
				$mail.append($('<input class="form-control form-control-sm" maxlength="200" placeholder="회사 메일(@gmail.com) 입력">').attr('aria-label', s.STAFF_NM + ' 회사 메일').val(s.TYPED_EMAIL || '').on('input', function() { s.TYPED_EMAIL = this.value; check(); }));
				check();
			}
			$('<tr>').append($('<td>').text(s.STAFF_NM)).append($('<td>').text(s.ORG_NM || '')).append($('<td>').text(s.DEPT_NM || '')).append($mail).append($id).append($act).appendTo($b);
		});
	}

	function idOf(email) { var m = /^([^@\s]+)@[^@\s]+$/.exec($.trim(email || '')); return m ? m[1] : null; }
	// 직접 적는 회사 메일은 서버 규칙(BoMemberService.COMPANY_EMAIL)과 같게 @gmail.com 만 받는다
	function typedId(email) { var v = $.trim(email || '').toLowerCase(); return /^[a-z0-9._-]{2,50}@gmail\.com$/.test(v) ? v.split('@')[0] : null; }
	function idTaken(id) { return data.accounts.some(function(a) { return String(a.EMPLY_ID || '').toLowerCase() === id; }); }

	// ── 계정 카드 ──

	function openCard(sq) {
		hrPost('/admin/member/memberCardData.do', { EMPLY_SQ: sq }, function(res) {
			card = res.result;
			$('#cardTitle').text((card.EMPLY_NM || '이름 없음') + ' · ' + typeText(card) + ' 계정');
			$('#cSq').val(card.EMPLY_SQ);
			fillCard();
			paintRoles();
			$('#cPw').empty().append(pwPill(card));
			$('#cLogin').text('최근 로그인 ' + (card.LAST_LOGIN_DT || '-'));
			paintStatus();
			$('#cSecret').prop('checked', card.SECRET_YN === 'Y');
			$('#cSecretNote').text(card.STAFF_SQ ? '' : '연결된 직원이 없어 숨길 투입·급여가 없습니다.');
			showPane('basic');
			$('#cardModal').modal('show');
		});
	}

	// 기본정보·권한정보·비밀번호는 한 폼이라 저장은 함께, 시크릿은 서버가 허락한 사람에게만 탭이 생긴다
	function showPane(key) {
		var tabs = [['basic', '기본정보'], ['role', '권한정보'], ['pw', '비밀번호']].concat(data.canSecret ? [['secret', '🔒 시크릿']] : []);
		$('#cardTabs').empty().append(tabs.map(function(t) { return hrTab(t[0], t[1], '', t[0] === key); }));
		$('.ac-pane').each(function() { $(this).prop('hidden', $(this).attr('data-pane') !== key); });
	}
	$('#cardTabs').on('click', '.cate-tab', function() { showPane($(this).attr('data-tab')); });
	// 다른 탭에서 저장했는데 기본정보 칸이 비었으면 그 탭을 열어 브라우저가 칸을 가리킬 수 있게 한다
	document.getElementById('cardForm').addEventListener('invalid', function() { showPane('basic'); }, true);
	$('#cSecret').on('change', function() {
		var box = this;
		hrPost('/admin/member/setSecretData.do', { EMPLY_SQ: card.EMPLY_SQ, SECRET_YN: box.checked ? 'Y' : 'N' }, function() { card.SECRET_YN = box.checked ? 'Y' : 'N'; }, function() { box.checked = !box.checked; });
	});

	function fillCard() {
		$('#cId').val(card.EMPLY_ID || ''); $('#cName').val(card.EMPLY_NM || ''); $('#cSex').val(card.EMPLY_SEX_TYP_CD || '');
		$('#cEmail').val(card.EMPLY_EMAIL || ''); $('#cPhone').val(card.EMPLY_PH_NUM || ''); $('#cAddr').val(card.EMPLY_HOME_ADDR || ''); $('#cRrn').val(card.EMPLY_RRN || '');
		$('#cardForm .ac-filled').removeClass('ac-filled');
		$('#cCopyRrn').val('');
		$('#staffNote').prop('hidden', true);
		linked = card.STAFF_SQ ? { STAFF_SQ: card.STAFF_SQ, STAFF_NM: card.STAFF_NM, STATUS_CD: card.STAFF_STATUS } : null;
		paintLink(false);
	}

	// ── 직원 검색 ──

	function paintLink(searching) {
		$('#cStaffSq').val(linked ? linked.STAFF_SQ : '');
		$('#cStaffSearch').val('');
		closeResults();
		var $c = $('#staffChosen').empty().prop('hidden', !linked || searching);
		$('#staffSearchBox').prop('hidden', !!linked && !searching);
		if (!linked) return;
		$c.append($('<b>').text(linked.STAFF_NM)).append(linked.STATUS_CD === 'WORK' ? pill('재직', 'info') : pill('퇴사', 'bad'))
			.append($('<button type="button" class="btn btn-xs btn-outline-secondary">변경</button>').on('click', function() { paintLink(true); $('#cStaffSearch').focus(); }))
			.append($('<button type="button" class="btn btn-xs btn-outline-secondary">연결 해제</button>').on('click', function() { linked = null; paintLink(false); }));
	}

	function closeResults() { staffRows = []; staffActive = -1; $('#staffResults').prop('hidden', true).empty(); $('#cStaffSearch').attr('aria-expanded', 'false').removeAttr('aria-activedescendant'); }

	function selectable(s) { return !s.EMPLY_ID || s.EMPLY_ID === card.EMPLY_ID; }

	function renderResults(rows) {
		staffRows = rows;
		staffActive = -1;
		var $r = $('#staffResults').empty().prop('hidden', false);
		$('#cStaffSearch').attr('aria-expanded', 'true');
		if (!rows.length) { $r.append('<div class="p-2 text-muted">검색 결과가 없습니다.</div>'); return; }
		var $h = $('<div class="ac-result ac-result-head" role="presentation">');
		['이름', '주민번호', '회사 메일', '전화번호', '소속', '상태'].forEach(function(t) { $h.append($('<span>').text(t)); });
		$r.append($h);
		rows.forEach(function(s, i) {
			var ok = selectable(s), org = [s.ORG_NM, s.DEPT_NM].filter(Boolean).join(' ');
			var $row = $('<div class="ac-result" role="option">').attr({ id: 'staffOpt' + i, 'aria-selected': 'false', 'aria-disabled': !ok })
				.append($('<span>').append($('<b>').text(s.STAFF_NM))).append($('<span class="sys-mono">').text(s.RRN || '-')).append($('<span>').text(s.COMPANY_EMAIL || '-')).append($('<span>').text(s.PHONE || '-')).append($('<span>').text(org || '-'))
				.append($('<span>').append(!ok ? pill('다른 계정 연결') : s.STATUS_CD === 'WORK' ? pill('재직', 'info') : pill('퇴사', 'bad')));
			if (ok) $row.on('mousedown', function(e) { e.preventDefault(); chooseStaff(s); });
			$r.append($row);
		});
	}

	function moveActive(step) {
		var n = staffRows.length, i = staffActive;
		for (var k = 0; k < n; k++) {
			i = (i + step + n) % n;
			if (selectable(staffRows[i])) {
				staffActive = i;
				$('#staffResults .ac-result').removeClass('active').attr('aria-selected', 'false');
				var $o = $('#staffOpt' + i).addClass('active').attr('aria-selected', 'true');
				$o[0].scrollIntoView({ block: 'nearest' });
				$('#cStaffSearch').attr('aria-activedescendant', 'staffOpt' + i);
				return;
			}
		}
	}

	function chooseStaff(s) {
		linked = s;
		[['#cName', s.STAFF_NM], ['#cSex', s.SEX_CD], ['#cEmail', s.COMPANY_EMAIL], ['#cPhone', s.PHONE], ['#cAddr', s.ADDR], ['#cRrn', s.RRN]].forEach(function(f) {
			if (f[1]) $(f[0]).val(f[1]).addClass('ac-filled');
		});
		$('#cCopyRrn').val(s.RRN ? 'Y' : '');
		$('#staffNote').prop('hidden', false);
		paintLink(false);
	}

	function undoStaff() { fillCard(); }

	// 결과 목록의 스크롤바를 눌러도 입력칸 포커스가 빠져 목록이 닫히지 않게 한다
	$('#staffResults').on('mousedown', function(e) { e.preventDefault(); });

	$('#cStaffSearch').on('input', function() {
		clearTimeout(staffTimer);
		var q = $.trim(this.value), seq = ++staffSeq;
		if (!q) { closeResults(); return; }
		staffTimer = setTimeout(function() {
			hrPost('/admin/member/searchStaffData.do', { KEYWORD: q }, function(res) { if (seq === staffSeq) renderResults(res.result); });
		}, 250);
	}).on('keydown', function(e) {
		if (e.key === 'Enter') { e.preventDefault(); if (staffActive >= 0) chooseStaff(staffRows[staffActive]); }
		else if (e.key === 'ArrowDown' || e.key === 'ArrowUp') { e.preventDefault(); if (staffRows.length) moveActive(e.key === 'ArrowDown' ? 1 : -1); }
		else if (e.key === 'Escape' && !$('#staffResults').prop('hidden')) { e.preventDefault(); e.stopPropagation(); closeResults(); }
	}).on('blur', closeResults);

	// 줄 수 없는 권한은 잠그고 이유를 보여 준다. 판단은 서버가 권한 관리의 메뉴 매핑으로 한다
	function paintRoles() {
		var have = String(card.ROLE_SQS || '').split(','), self = card.EMPLY_ID === data.me, $t = $('#cType').empty();
		data.roles.forEach(function(r) {
			var on = have.indexOf(String(r.ROLE_SQ)) >= 0, locked = self || r.GRANTABLE !== 'Y', id = 'role_' + r.ROLE_SQ;
			$('<label class="ac-role">').attr('for', id).toggleClass('on', on).toggleClass('lock', locked)
				.append($('<input type="checkbox" class="role-box">').attr('id', id).val(r.ROLE_SQ).prop({ checked: on, disabled: locked }))
				.append($('<span>').append(locked ? '<i class="fas fa-lock" aria-hidden="true"></i> ' : '').append(document.createTextNode(r.ROLE_NM))
					.append($('<small>').text(self ? '내 계정의 권한은 바꿀 수 없습니다' : locked ? r.LOCK_REASON : (r.ROLE_DESC || ''))))
				.appendTo($t);
		});
		updateKind();
	}

	function updateKind() {
		$('.ac-role').each(function() { $(this).toggleClass('on', $(this).find('.role-box').prop('checked')); });
		$('#cKind').text($('.role-box:checked').length ? '관리자 계정' : '직원 계정');
	}
	$('#cType').on('change', '.role-box', updateKind);

	function paintStatus() {
		var $b = $('#cStatusBtns').empty();
		function btn(label, action, cls, msg) { $('<button type="button" class="btn btn-sm mr-1">').addClass(cls).text(label).on('click', function() { confirmStatus(action, msg); }).appendTo($b); }
		if (card.USE_YN === 'N') btn('사용 재개', 'RESUME', 'btn-outline-secondary', '이 계정의 사용을 재개할까요?');
		else btn('사용중지', 'SUSPEND', 'btn-outline-secondary', '이 계정을 중지할까요? 다음 요청부터 관리자 화면 사용과 로그인이 막힙니다.');
		if (card.DEL_YN === 'Y') btn('퇴사 취소', 'RESTORE', 'btn-outline-secondary', '퇴사 처리를 취소할까요?');
		else btn('퇴사 처리', 'RETIRE', 'btn-outline-danger', '이 계정을 퇴사 처리할까요? 로그인이 막히며 나중에 복구할 수 있습니다.');
		btn('삭제', 'DELETE', 'btn-danger', '이 계정을 삭제할까요? 권한·인사카드 연결도 함께 지워지며 되돌릴 수 없습니다.');
	}

	function confirmStatus(action, msg) {
		bootbox.confirm(msg, function(ok) { if (ok) hrPost('/admin/member/setStatusData.do', { EMPLY_SQ: card.EMPLY_SQ, ACTION: action }, afterChange); });
	}

	function afterChange() { $('#cardModal').modal('hide'); load(); }

	function saveCard() {
		// 잠긴 권한도 체크 상태 그대로 보내야 서버가 바뀐 것으로 보지 않는다
		var roles = $('.role-box:checked').map(function() { return this.value; }).get();
		hrPost('/admin/member/saveMemberData.do', $('#cardForm').serialize() + '&ROLE_SQS=' + encodeURIComponent(roles.join(',')), afterChange);
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
		$('#iRole').val('');
		buildRows();
		applyKind();
		$('#issueModal').modal('show');
	}

	function buildRows() {
		var $b = $('#issueRows').empty();
		data.pending.forEach(function(s) {
			var fixed = idOf(s.COMPANY_EMAIL), id = fixed || typedId(s.TYPED_EMAIL);
			var $box = $('<input type="checkbox" class="pick">').val(s.STAFF_SQ).prop({ disabled: !id, checked: !!id && pendingPick === s.STAFF_SQ }).attr('aria-label', s.STAFF_NM + ' 선택');
			var $id = $('<input class="form-control form-control-sm sys-mono row-id" maxlength="50">').val(id || '').prop('disabled', !id).attr('aria-label', s.STAFF_NM + ' 아이디');
			var $mail = fixed ? s.COMPANY_EMAIL : $('<input class="form-control form-control-sm row-mail" maxlength="200" placeholder="회사 메일(@gmail.com) 입력">').attr('aria-label', s.STAFF_NM + ' 회사 메일').val(s.TYPED_EMAIL || '')
				.on('input', function() { s.TYPED_EMAIL = this.value; var t = typedId(this.value); $id.val(t || '').prop('disabled', !t); $box.prop({ disabled: !t, checked: !!t }); checkRows(); });
			$('<tr>').attr('data-q', (s.STAFF_NM + ' ' + (s.COMPANY_EMAIL || '')).toLowerCase())
				.append($('<td>').append($box)).append($('<td>').text(s.STAFF_NM)).append($('<td>').text(s.ORG_NM || '')).append($('<td>').append($mail)).append($('<td>').append($id)).append($('<td class="row-state">')).appendTo($b);
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
			if ($id.prop('disabled')) { $r.removeClass('has-error'); $state.append(pill($.trim($r.find('.row-mail').val() || '') ? '@gmail.com 주소만' : '회사 메일 없음', 'bad')); return; }
			var bad = !/^[a-z0-9._-]{2,50}$/.test(id) ? '형식 오류' : taken[id] ? '아이디 중복' : (picked && used[id]) ? '선택 안에서 중복' : null;
			if (picked) used[id] = true;
			$r.toggleClass('has-error', !!bad && picked);
			$state.append(bad ? pill(bad, 'bad') : pill('가능', 'ok'));
		});
		updateIssueBtn();
	}
	$('#issueRows').on('input change', '.row-id, .pick', checkRows);

	$('#iSearch').on('input', function() { var q = $.trim(this.value).toLowerCase(); $('#issueRows tr').each(function() { $(this).toggle($(this).attr('data-q').indexOf(q) >= 0); }); });
	// 팝업에서 적은 회사 메일을 목록에도 보여 준다
	$('#issueModal').on('hidden.bs.modal', function() { if (tab === 'pending') render(); });
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
		var sqs = [], ids = [], mails = [];
		$('#issueRows tr').each(function() { if ($(this).find('.pick').prop('checked')) { sqs.push($(this).find('.pick').val()); ids.push($.trim($(this).find('.row-id').val())); mails.push($.trim($(this).find('.row-mail').val() || '')); } });
		var d = { STAFF_SQ: sqs, EMPLY_ID: ids, COMPANY_EMAIL: mails, TYPE_CD: admin ? '2' : '1' };
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
		var rows = tab === 'pending' && !leftOnly ? [['이름', '소속', '부서', '회사 메일']].concat(shown().map(function(s) { return [s.STAFF_NM, s.ORG_NM, s.DEPT_NM, s.COMPANY_EMAIL]; }))
			: [['이름', '아이디', '구분', '권한', '이메일', '비밀번호', '최근 로그인']].concat(shown().map(function(a) { return [a.EMPLY_NM, a.EMPLY_ID, typeText(a), a.ROLE_NMS, a.EMPLY_EMAIL, a.PW_INIT_YN !== 'N' ? '초기' : '변경 완료', a.LAST_LOGIN_DT]; }));
		var url = URL.createObjectURL(new Blob(['﻿' + rows.map(function(r) { return r.map(cell).join(','); }).join('\r\n')], { type: 'text/csv;charset=utf-8' }));
		$('<a>').attr({ href: url, download: '계정목록.csv' })[0].click();
		URL.revokeObjectURL(url);
	}
	</script>
</body>
</html>
