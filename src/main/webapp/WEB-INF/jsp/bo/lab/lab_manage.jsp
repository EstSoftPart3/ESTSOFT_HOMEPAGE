<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/lab/lab_style.jspf"%>
<style>
	.lab-tl { table-layout: fixed; min-width: 760px; }
	.lab-tl th, .lab-tl td { padding: 8px 6px; }
	.lab-tl .m { text-align: center; font-size: 13px; padding: 8px 0; }
	.lab-tl .m.now { background: #343a40; color: #fff; }
	.lab-tl .c { padding: 0; vertical-align: middle; }
	.lab-tl .c div { height: 20px; }
	.bar-HEAD { background: #0a4a78; }
	.bar-MEMBER { background: #7dbbdc; }
	.lab-legend i { display: inline-block; width: 18px; height: 12px; margin: 0 5px 0 12px; }
	.lab-line { display: flex; flex-wrap: wrap; align-items: stretch; gap: 8px; }
	.lab-line > div { flex: 1 1 170px; border: 1px solid #ced4da; border-radius: 8px; padding: 16px; }
	.lab-line small { display: block; color: #495057; margin-bottom: 6px; }
	.lab-line strong { font-size: 18px; }
	.lab-line .key { border: 2px solid #0b6e8a; }
	.lab-line .auto { background: #eef1f4; }
	.lab-line img { display: block; max-width: 140px; max-height: 56px; margin-top: 8px; }
	.lab-line .none { display: block; margin-top: 8px; color: #b02a37; font-weight: 700; }
	.lab-arrow { flex: 0 0 auto !important; border: 0 !important; padding: 0 !important; align-self: center; color: #495057; }
	#signPad { display: block; width: 100%; max-width: 440px; height: 176px; margin: 0 auto; border: 1px dashed #868e96; border-radius: 6px; touch-action: none; background: #fff; }
	.lab-pick { max-height: 220px; overflow-y: auto; }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header"><h3 class="card-title bTitle"><b>연구소 관리</b></h3></div>
				<div class="card-body">
					<div class="lab-view" id="viewList">
						<div class="cal-panel">
							<div class="cal-panel-body">
								<div class="form-row align-items-end">
									<div class="col-md-3 col-6 mb-2"><label for="fName">연구팀명</label><input type="search" id="fName" class="form-control form-control-sm"></div>
									<div class="col-md-2 col-6 mb-2"><label for="fUse">사용 여부</label><select id="fUse" class="form-control form-control-sm"><option value="">전체</option><option value="Y">사용</option><option value="N">미사용</option></select></div>
									<div class="col-md-1 col-6 mb-2"><button type="button" class="btn btn-sm btn-primary btn-block" onclick="drawList();">조회</button></div>
									<div class="col-md-6 col-6 mb-2 text-right"><button type="button" class="btn btn-sm btn-primary" onclick="openTeam();"><i class="fas fa-plus"></i> 연구팀 등록</button></div>
								</div>
							</div>
						</div>
						<div class="cal-panel"><div class="table-responsive px-3">
							<table class="table table-sm table-hover cal-table mb-0">
								<thead><tr><th>연구팀</th><th>연구 분야</th><th>연구원</th><th>부서장</th><th>대표</th><th>과제</th><th>사용</th></tr></thead>
								<tbody id="listBody"></tbody>
							</table>
						</div></div>
					</div>
					<div class="lab-view" id="viewTeam" style="display:none;"></div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="teamModal" tabindex="-1" role="dialog" aria-labelledby="teamTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<form class="modal-content" onsubmit="saveTeam(); return false;">
				<div class="modal-header">
					<h5 class="modal-title" id="teamTitle">연구팀 등록</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<input type="hidden" id="TEAM_SQ">
					<div class="form-group"><label for="TEAM_NM">연구팀명</label><input id="TEAM_NM" class="form-control form-control-sm" maxlength="100" required></div>
					<div class="form-group"><label for="FIELD_NM">연구 분야</label><input id="FIELD_NM" class="form-control form-control-sm" maxlength="200"></div>
					<div class="form-group"><label for="PLACE">소재지</label><input id="PLACE" class="form-control form-control-sm" maxlength="200"></div>
					<div class="form-group"><label for="USE_YN">사용 여부</label><select id="USE_YN" class="form-control form-control-sm"><option value="Y">사용</option><option value="N">미사용</option></select></div>
					<div class="form-group mb-0"><label for="MEMO">비고</label><textarea id="MEMO" rows="3" maxlength="1000" class="form-control form-control-sm"></textarea></div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">취소</button>
					<button type="submit" class="btn btn-sm btn-primary">저장</button>
				</div>
			</form>
		</div>
	</div>

	<div class="modal fade" id="memberModal" tabindex="-1" role="dialog" aria-labelledby="memberTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<form class="modal-content" onsubmit="saveMember(); return false;">
				<div class="modal-header">
					<h5 class="modal-title" id="memberTitle">연구원 등록</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<input type="hidden" id="RSCH_SQ">
					<div class="form-group"><label for="pickSearch">직원 검색 (직원관리)</label><input type="search" id="pickSearch" class="form-control form-control-sm" placeholder="성명 또는 부서"></div>
					<div class="table-responsive lab-pick mb-3">
						<table class="table table-sm cal-table mb-0">
							<thead><tr><th style="width:50px;">선택</th><th>성명</th><th>부서</th><th>직급</th><th>직원관리</th></tr></thead>
							<tbody id="pickBody"></tbody>
						</table>
					</div>
					<div class="form-row">
						<div class="form-group col-md-4"><label for="ROLE_CD">역할</label><select id="ROLE_CD" class="form-control form-control-sm"><option value="MEMBER">연구원</option><option value="HEAD">연구소장</option></select></div>
						<div class="form-group col-md-4"><label for="START_DT">소속 시작일</label><input type="date" id="START_DT" class="form-control form-control-sm" required></div>
						<div class="form-group col-md-4"><label for="END_DT">소속 종료일</label><input type="date" id="END_DT" class="form-control form-control-sm"></div>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">취소</button>
					<button type="submit" class="btn btn-sm btn-primary">저장</button>
				</div>
			</form>
		</div>
	</div>

	<div class="modal fade" id="approvalModal" tabindex="-1" role="dialog" aria-labelledby="approvalTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<form class="modal-content" onsubmit="saveApproval(); return false;">
				<div class="modal-header">
					<h5 class="modal-title" id="approvalTitle">결재라인 수정</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<div class="form-group"><label for="MANAGER_EMPLY_ID">1단계 · 부서장 (관리자 계정)</label><select id="MANAGER_EMPLY_ID" class="form-control form-control-sm approver" required></select></div>
					<div class="form-group mb-0"><label for="CEO_EMPLY_ID">2단계 · 대표 (관리자 계정)</label><select id="CEO_EMPLY_ID" class="form-control form-control-sm approver" required></select></div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">취소</button>
					<button type="submit" class="btn btn-sm btn-primary">저장</button>
				</div>
			</form>
		</div>
	</div>

	<div class="modal fade" id="signModal" tabindex="-1" role="dialog" aria-labelledby="signTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="signTitle">내 서명 등록</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<div class="lab-tabs" role="tablist">
						<button type="button" role="tab" id="signTabFile" aria-selected="true" onclick="signMode('file');">이미지 올리기</button>
						<button type="button" role="tab" id="signTabDraw" aria-selected="false" onclick="signMode('draw');">직접 그리기</button>
					</div>
					<div class="form-group"><label>계정</label><div class="form-control-plaintext form-control-sm">${loginInfo.loginInfo[0].emplyNm} (${loginInfo.loginInfo[0].emplyId})</div></div>
					<div class="form-group" id="signFileBox"><label for="signFile">서명·도장 이미지 (PNG, JPG)</label><input type="file" id="signFile" accept="image/png,image/jpeg" class="form-control-file"></div>
					<canvas id="signPad" width="440" height="176" role="img" aria-label="서명 영역"></canvas>
					<div class="text-right mt-2"><button type="button" class="btn btn-sm btn-outline-secondary" onclick="clearPad();">지우기</button></div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">취소</button>
					<button type="button" class="btn btn-sm btn-primary" id="signSave" onclick="saveSign();">저장</button>
				</div>
			</div>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>
	<script>
	var TABS = ['기본 정보', '연구원', '소속 현황', '결재라인'];
	var teams = [], staff = [], detail = null, tab = 0, year = new Date().getFullYear(), picked = null;

	// ── 목록 ──
	function drawList() {
		var name = $('#fName').val().trim().toLowerCase(), use = $('#fUse').val();
		var list = teams.filter(function(t) { return (!name || t.TEAM_NM.toLowerCase().indexOf(name) >= 0) && (!use || t.USE_YN === use); });
		var $b = $('#listBody').empty();
		if (!list.length) $b.append('<tr><td colspan="7" class="text-center text-muted">연구팀이 없습니다.</td></tr>');
		list.forEach(function(t) {
			$('<tr>').append($('<td>').append($('<a class="lab-open">').attr('href', '#t=' + t.TEAM_SQ).text(t.TEAM_NM)), $('<td>').text(t.FIELD_NM || ''), $('<td>').text(t.RSCH_CNT + '명'),
				$('<td>').text(t.MANAGER_NM || t.MANAGER_EMPLY_ID || '미지정'), $('<td>').text(t.CEO_NM || t.CEO_EMPLY_ID || '미지정'), $('<td>').text(t.PRJ_CNT + '건'), $('<td>').text(t.USE_YN === 'Y' ? '사용' : '미사용')).appendTo($b);
		});
	}

	function loadList() {
		hrPost('/admin/lab/teamListData.do', {}, function(res) { teams = res.result; drawList(); });
	}

	// ── 상세 ──
	function actions() {
		var $a = $('<div class="lab-actions">');
		[].slice.call(arguments).forEach(function(x) { $('<button type="button" class="btn btn-sm">').addClass(x[2] || 'btn-primary').text(x[0]).click(x[1]).appendTo($a); });
		return $a;
	}

	function drawTeam() {
		var t = detail.team, $v = $('#viewTeam').empty();
		$v.append($('<div class="lab-head">').append($('<h4>').text(t.TEAM_NM)));
		var $tabs = $('<div class="lab-tabs" role="tablist">').appendTo($v);
		TABS.forEach(function(n, i) {
			$('<button type="button" role="tab">').attr('aria-selected', i === tab ? 'true' : 'false').text(n).click(function() { tab = i; drawTeam(); }).appendTo($tabs);
		});
		var $b = $('<div class="cal-panel"><div class="cal-panel-body"></div></div>').appendTo($v).find('.cal-panel-body');
		[drawInfo, drawMembers, drawTimeline, drawApproval][tab]($b);
		$v.append($('<div class="lab-back">').append('<a class="btn btn-sm btn-outline-secondary" href="#">목록</a>'));
	}

	function drawInfo($b) {
		var t = detail.team, $t = $('<tbody>');
		$b.append(actions(['수정', function() { openTeam(t); }]));
		[['연구팀명', t.TEAM_NM], ['연구 분야', t.FIELD_NM], ['소재지', t.PLACE], ['사용 여부', t.USE_YN === 'Y' ? '사용' : '미사용'], ['비고', t.MEMO]].forEach(function(r) {
			$('<tr>').append($('<th scope="row">').text(r[0]), $('<td style="white-space:pre-line;">').text(r[1] || '')).appendTo($t);
		});
		$b.append($('<table class="table table-sm table-bordered lab-info mb-0">').append($t));
	}

	function cardLink(sq) {
		return $('<a target="_blank" rel="noopener">인사카드 열기</a>').attr('href', '/admin/staff/openStaffList.do?STAFF_SQ=' + sq);
	}

	function drawMembers($b) {
		$b.append(actions(['연구원 등록', function() { openMember(); }]));
		var $t = $('<tbody>');
		if (!detail.researchers.length) $t.append('<tr><td colspan="6" class="text-center text-muted">등록된 연구원이 없습니다.</td></tr>');
		detail.researchers.forEach(function(r) {
			$('<tr>').append($('<td>').append($('<a href="#" class="lab-open">').text(r.STAFF_NM).click(function(e) { e.preventDefault(); openMember(r); })), $('<td>').text(r.DEPT_NM || ''),
				$('<td>').text(r.ROLE_CD === 'HEAD' ? '연구소장' : '연구원'), $('<td>').text(r.START_DT), $('<td>').text(r.END_DT || '소속 중'), $('<td>').append(cardLink(r.STAFF_SQ))).appendTo($t);
		});
		$b.append($('<div class="table-responsive">').append($('<table class="table table-sm table-hover cal-table mb-0"><thead><tr><th>성명</th><th>부서</th><th>역할</th><th>소속 시작일</th><th>소속 종료일</th><th>직원관리</th></tr></thead></table>').append($t)));
	}

	function drawTimeline($b) {
		var months = [], d = new Date(), thisYm = d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2);
		for (var i = 1; i <= 12; i++) months.push(year + '-' + ('0' + i).slice(-2));
		$b.append($('<div class="d-flex flex-wrap align-items-center mb-2">').append(
			$('<button type="button" class="btn btn-sm btn-outline-secondary">이전 연도</button>').click(function() { year--; drawTeam(); }),
			$('<strong class="mx-3" style="font-size:18px;">').text(year + '년'),
			$('<button type="button" class="btn btn-sm btn-outline-secondary">다음 연도</button>').click(function() { year++; drawTeam(); }),
			$('<div class="ml-auto lab-legend small"><i class="bar-HEAD"></i>연구소장<i class="bar-MEMBER"></i>연구원</div>')));
		var $h = $('<tr><th style="width:90px;">성명</th></tr>');
		months.forEach(function(m, i) { $('<th class="m">').toggleClass('now', m === thisYm).text((i + 1) + '월').appendTo($h); });
		$h.append('<th style="width:180px;">소속 기간</th>');
		var $t = $('<tbody>');
		var rows = detail.researchers.filter(function(r) { return r.START_DT.slice(0, 4) <= String(year) && (!r.END_DT || r.END_DT.slice(0, 4) >= String(year)); })
			.sort(function(a, b) { return (a.START_DT > b.START_DT) - (a.START_DT < b.START_DT); });
		if (!rows.length) $t.append('<tr><td colspan="14" class="text-center text-muted">이 해에 소속된 연구원이 없습니다.</td></tr>');
		rows.forEach(function(r) {
			var $r = $('<tr>').append($('<td>').append($('<b>').text(r.STAFF_NM)));
			months.forEach(function(m) {
				var on = r.START_DT.slice(0, 7) <= m && (!r.END_DT || r.END_DT.slice(0, 7) >= m);
				$('<td class="c">').append(on ? $('<div>').addClass('bar-' + r.ROLE_CD) : '').appendTo($r);
			});
			$r.append($('<td class="small">').text(r.START_DT + ' ~ ' + (r.END_DT || '소속 중'))).appendTo($t);
		});
		$b.append($('<div class="table-responsive">').append($('<table class="table table-sm cal-table mb-0 lab-tl">').append($('<thead>').append($h), $t)));
	}

	function approver(step, name, sign) {
		var $d = $('<div class="key">').append($('<small>').text(step), $('<strong>').text(name || '미지정'));
		return $d.append(sign ? $('<img>').attr({ src: sign, alt: (name || '') + ' 서명' }) : $('<span class="none">서명 미등록</span>'));
	}

	function drawApproval($b) {
		var t = detail.team;
		$b.append(actions(['내 서명 등록', openSign, 'btn-outline-secondary'], ['수정', openApproval]));
		$b.append($('<div class="lab-line">').append('<div><small>작성·제출</small><strong>연구팀 작성자</strong></div>', '<div class="lab-arrow" aria-hidden="true">&rarr;</div>',
			approver('1단계 · 부서장 확인', t.MANAGER_NM || t.MANAGER_EMPLY_ID, detail.managerSign), '<div class="lab-arrow" aria-hidden="true">&rarr;</div>',
			approver('2단계 · 대표 확인', t.CEO_NM || t.CEO_EMPLY_ID, detail.ceoSign), '<div class="lab-arrow" aria-hidden="true">&rarr;</div>',
			'<div class="auto"><small>자동</small><strong>잠금 · PDF 업로드</strong></div>'));
	}

	function reload(then) {
		hrPost('/admin/lab/teamDetailData.do', { TEAM_SQ: detail.team.TEAM_SQ }, function(res) { detail = res.result; drawTeam(); if (then) then(); });
	}

	// ── 팝업 ──
	function openTeam(t) {
		$('#teamTitle').text(t ? '연구팀 수정' : '연구팀 등록');
		['TEAM_SQ', 'TEAM_NM', 'FIELD_NM', 'PLACE', 'MEMO'].forEach(function(f) { $('#' + f).val(t && t[f] || ''); });
		$('#USE_YN').val(t ? t.USE_YN : 'Y');
		$('#teamModal').modal('show');
	}

	function saveTeam() {
		var data = {}, isNew = !$('#TEAM_SQ').val();
		['TEAM_SQ', 'TEAM_NM', 'FIELD_NM', 'PLACE', 'USE_YN', 'MEMO'].forEach(function(f) { data[f] = $('#' + f).val(); });
		hrPost('/admin/lab/saveTeamData.do', data, function(res) {
			$('#teamModal').modal('hide');
			if (isNew) location.hash = '#t=' + res.result; else reload();
		});
	}

	function drawPick() {
		var q = $('#pickSearch').val().trim().toLowerCase(), $b = $('#pickBody').empty();
		var list = staff.filter(function(s) { return String(s.STAFF_SQ) === String(picked) || (q && ((s.STAFF_NM || '') + ' ' + (s.DEPT_NM || '')).toLowerCase().indexOf(q) >= 0); }).slice(0, 30);
		if (!list.length) $b.append('<tr><td colspan="5" class="text-center text-muted">성명이나 부서로 검색해 주세요.</td></tr>');
		list.forEach(function(s) {
			var $radio = $('<input type="radio" name="pick">').attr('aria-label', s.STAFF_NM + ' 선택').prop('checked', String(s.STAFF_SQ) === String(picked)).on('change', function() { picked = s.STAFF_SQ; });
			$('<tr>').append($('<td>').append($radio), $('<td>').text(s.STAFF_NM + (s.STATUS_CD === 'LEFT' ? ' (퇴사)' : '')), $('<td>').text(s.DEPT_NM || ''), $('<td>').text(s.POSITION_NM || ''), $('<td>').append(cardLink(s.STAFF_SQ))).appendTo($b);
		});
	}

	function openMember(r) {
		$('#memberTitle').text(r ? '연구원 수정' : '연구원 등록');
		picked = r ? r.STAFF_SQ : null;
		$('#pickSearch').val('');
		$('#RSCH_SQ').val(r ? r.RSCH_SQ : '');
		$('#ROLE_CD').val(r ? r.ROLE_CD : 'MEMBER');
		$('#START_DT').val(r ? r.START_DT : '');
		$('#END_DT').val(r && r.END_DT || '');
		drawPick();
		$('#memberModal').modal('show');
	}

	function saveMember() {
		hrPost('/admin/lab/saveResearcherData.do', { TEAM_SQ: detail.team.TEAM_SQ, RSCH_SQ: $('#RSCH_SQ').val(), STAFF_SQ: picked || '', ROLE_CD: $('#ROLE_CD').val(), START_DT: $('#START_DT').val(), END_DT: $('#END_DT').val() }, function() {
			$('#memberModal').modal('hide');
			reload();
		});
	}

	function openApproval() {
		$('#MANAGER_EMPLY_ID').val(detail.team.MANAGER_EMPLY_ID || '');
		$('#CEO_EMPLY_ID').val(detail.team.CEO_EMPLY_ID || '');
		$('#approvalModal').modal('show');
	}

	function saveApproval() {
		hrPost('/admin/lab/saveApprovalData.do', { TEAM_SQ: detail.team.TEAM_SQ, MANAGER_EMPLY_ID: $('#MANAGER_EMPLY_ID').val(), CEO_EMPLY_ID: $('#CEO_EMPLY_ID').val() }, function() {
			$('#approvalModal').modal('hide');
			reload();
		});
	}

	// ── 서명 ──
	var pad = document.getElementById('signPad'), ctx = pad.getContext('2d'), mode = 'file', drawn = false, down = false;

	function clearPad() {
		ctx.clearRect(0, 0, pad.width, pad.height);
		drawn = false;
		$('#signFile').val('');
	}

	function signMode(m) {
		mode = m;
		clearPad();
		$('#signFileBox').toggle(m === 'file');
		$('#signTabFile').attr('aria-selected', m === 'file' ? 'true' : 'false');
		$('#signTabDraw').attr('aria-selected', m === 'draw' ? 'true' : 'false');
		$('#signPad').attr('aria-label', m === 'draw' ? '마우스나 터치로 서명하는 영역' : '서명 이미지 미리보기');
	}

	function openSign() {
		signMode('file');
		$('#signModal').modal('show');
	}

	function padPoint(e) {
		var b = pad.getBoundingClientRect();
		return [(e.clientX - b.left) * pad.width / b.width, (e.clientY - b.top) * pad.height / b.height];
	}

	pad.addEventListener('pointerdown', function(e) {
		if (mode !== 'draw') return;
		down = true;
		pad.setPointerCapture(e.pointerId);
		var p = padPoint(e);
		ctx.lineWidth = 2.5; ctx.lineCap = 'round'; ctx.strokeStyle = '#111';
		ctx.beginPath();
		ctx.moveTo(p[0], p[1]);
	});
	pad.addEventListener('pointermove', function(e) {
		if (!down) return;
		var p = padPoint(e);
		ctx.lineTo(p[0], p[1]);
		ctx.stroke();
		drawn = true;
	});
	pad.addEventListener('pointerup', function() { down = false; });
	pad.addEventListener('pointercancel', function() { down = false; });

	// 큰 사진도 서명 칸 크기의 PNG 로 줄여서 저장한다
	$('#signFile').on('change', function() {
		var file = this.files[0];
		if (!file) return;
		if (file.size > 5 * 1024 * 1024) { bootbox.alert('5MB 이하 이미지만 올릴 수 있습니다.'); this.value = ''; return; }
		var url = URL.createObjectURL(file), img = new Image();
		img.onload = function() {
			var s = Math.min(pad.width / img.width, pad.height / img.height, 1), w = img.width * s, h = img.height * s;
			ctx.clearRect(0, 0, pad.width, pad.height);
			ctx.drawImage(img, (pad.width - w) / 2, (pad.height - h) / 2, w, h);
			drawn = true;
			URL.revokeObjectURL(url);
		};
		img.onerror = function() { bootbox.alert('이미지를 읽지 못했습니다.'); URL.revokeObjectURL(url); };
		img.src = url;
	});

	function saveSign() {
		if (!drawn) { bootbox.alert('서명을 입력하거나 이미지를 골라 주세요.'); return; }
		var $b = $('#signSave').prop('disabled', true);
		hrPost('/admin/lab/saveSignData.do', { IMG: pad.toDataURL('image/png') }, function() {
			$b.prop('disabled', false);
			$('#signModal').modal('hide');
			reload();
		}, function() { $b.prop('disabled', false); });
	}

	// ── 화면 전환 ──
	function showCurrent() {
		var m = /^#t=(\d+)(?:&tab=(\d))?(&sign=1)?$/.exec(location.hash);
		$('.lab-view').hide();
		if (!m) { $('#viewList').show(); loadList(); return; }
		tab = m[2] ? Number(m[2]) : 0;
		$('#viewTeam').show();
		hrPost('/admin/lab/teamDetailData.do', { TEAM_SQ: m[1] }, function(res) {
			detail = res.result;
			drawTeam();
			if (m[3]) openSign();
		});
	}

	$(window).on('hashchange', showCurrent);
	$('#fUse').on('change', drawList);
	$('#fName').on('input', drawList);
	$('#pickSearch').on('input', drawPick);
	hrPost('/admin/lab/optionsData.do', {}, function(res) {
		staff = res.result.staff;
		$('.approver').append('<option value=""></option>');
		res.result.accounts.forEach(function(a) { $('.approver').append($('<option>').val(a.EMPLY_ID).text(a.EMPLY_NM + ' (' + a.EMPLY_ID + ')')); });
		showCurrent();
	});
	</script>
</body>
</html>
