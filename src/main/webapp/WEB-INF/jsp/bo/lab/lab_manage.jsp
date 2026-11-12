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
	.lab-pick { max-height: 220px; overflow-y: auto; }
	/* 결재라인: 넓은 화면은 한 줄, 좁은 화면은 위아래 카드 */
	.lab-appr { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 8px; }
	.lab-appr .ar { display: grid; grid-template-columns: auto 64px minmax(110px, 160px) minmax(160px, 240px) 1fr auto; align-items: center; gap: 10px; padding: 10px 12px; border: 1px solid #ced4da; border-radius: 8px; background: #fff; }
	.lab-appr .ar.fixed { display: flex; background: #eef1f4; }
	.lab-appr .ar.dragging { opacity: .45; }
	.lab-appr .ar.over { border: 2px dashed #0b6e8a; background: #e3f6fb; }
	.lab-appr .no { color: #0a4a78; font-weight: 700; }
	.lab-move { display: flex; align-items: center; gap: 2px; }
	.lab-move button { background: none; border: 0; color: #495057; padding: 4px 6px; min-width: 32px; min-height: 32px; }
	.lab-move .hdl { cursor: grab; letter-spacing: -3px; font-size: 18px; }
	.lab-sign { border: 1px dashed #868e96; border-radius: 6px; padding: 6px 10px; min-height: 58px; display: flex; flex-wrap: wrap; align-items: center; gap: 4px 10px; }
	.lab-sign img { max-width: 140px; max-height: 50px; }
	.lab-sign small { color: #495057; }
	.lab-sign.drop { border: 2px solid #0b6e8a; background: #e3f6fb; }
	.lab-sign.none { border-style: solid; background: #fff8f8; }
	.lab-sign .warn { color: #b02a37; font-weight: 700; }
	.lab-sign canvas { width: 100%; max-width: 300px; height: 110px; border: 1px solid #adb5bd; border-radius: 6px; background: #fff; touch-action: none; }
	.lab-add { width: 100%; min-height: 44px; border: 1px dashed #0b6e8a; border-radius: 8px; background: #fff; color: #0b6e8a; font-weight: 700; }
	#labToast { position: fixed; right: 18px; bottom: 18px; z-index: 2000; background: #222; color: #fff; font-size: 13px; padding: 8px 14px; border-radius: 6px; display: none; }
	@media (max-width: 767px) {
		.lab-appr .ar { display: flex; flex-wrap: wrap; }
		.lab-appr .ar > label, .lab-appr .ar > .lab-sign { flex: 1 1 100%; }
		.lab-appr .ar .lab-del { margin-left: auto; }
	}
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
								<thead><tr><th>연구팀</th><th>연구 분야</th><th>연구원</th><th>결재라인</th><th>과제</th><th>사용</th><th>메모</th></tr></thead>
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
						<div class="form-group col-md-4"><label for="ROLE_CD">역할</label><select id="ROLE_CD" class="form-control form-control-sm"></select></div>
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

	<div id="labToast" role="status" aria-live="polite"></div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>
	<script>
	var TABS = ['기본 정보', '연구원', '소속 현황', '결재라인'];
	// 비고는 메모로 옮겼다. 목록 💬 버튼과 기본 정보 아래 메모 칸에서 쌓는다
	var MEMO_API = hrMemoApi('/admin/lab/', 'team');
	// 연구원 역할(공통코드 LAB_ROLE). HEAD(연구소장)는 마감 권한과 이어져 코드값을 바꾸면 안 된다
	var ROLE = hrCodeMap('LAB_ROLE');
	$(function() { hrFillSelect('#ROLE_CD', 'LAB_ROLE'); });
	var teams = [], staff = [], accounts = [], detail = null, tab = 0, year = new Date().getFullYear(), picked = null, line = [], dragFrom = null;

	function toast(msg) { $('#labToast').text(msg).stop(true).fadeIn(100).delay(1500).fadeOut(300); }

	// ── 목록 ──
	function drawList() {
		var name = $('#fName').val().trim().toLowerCase(), use = $('#fUse').val();
		var list = teams.filter(function(t) { return (!name || t.TEAM_NM.toLowerCase().indexOf(name) >= 0) && (!use || t.USE_YN === use); });
		var $b = $('#listBody').empty();
		if (!list.length) $b.append('<tr><td colspan="7" class="text-center text-muted">연구팀이 없습니다.</td></tr>');
		list.forEach(function(t) {
			$('<tr>').append($('<td>').append($('<a class="lab-open">').attr('href', '#t=' + t.TEAM_SQ).text(t.TEAM_NM)), $('<td>').text(t.FIELD_NM || ''), $('<td>').text(t.RSCH_CNT + '명'),
				$('<td>').text(t.APPR_LINE || '미지정'), $('<td>').text(t.PRJ_CNT + '건'), $('<td>').text(t.USE_YN === 'Y' ? '사용' : '미사용'),
				$('<td>').append(hrMemoBtn(MEMO_API, t.TEAM_SQ, t.MEMO_CNT, t.TEAM_NM, loadList))).appendTo($b);
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
		[['연구팀명', t.TEAM_NM], ['연구 분야', t.FIELD_NM], ['소재지', t.PLACE], ['사용 여부', t.USE_YN === 'Y' ? '사용' : '미사용']].forEach(function(r) {
			$('<tr>').append($('<th scope="row">').text(r[0]), $('<td style="white-space:pre-line;">').text(r[1] || '')).appendTo($t);
		});
		$b.append($('<table class="table table-sm table-bordered lab-info mb-0">').append($t));
		$b.append('<div class="hr-section">메모</div>');
		hrMemoFeed($('<div>').appendTo($b), MEMO_API, t.TEAM_SQ, loadList);
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
				$('<td>').text(ROLE[r.ROLE_CD] || r.ROLE_CD), $('<td>').text(r.START_DT), $('<td>').text(r.END_DT || '소속 중'), $('<td>').append(cardLink(r.STAFF_SQ))).appendTo($t);
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

	// ── 결재라인: 목록에서 바로 순서 변경·추가·삭제, 바꾸면 바로 저장 ──
	function drawApproval($b) {
		var $ol = $('<ol class="lab-appr">').appendTo($b);
		$ol.append('<li class="ar fixed"><b class="no">작성</b><span>연구팀 작성자가 작성·제출</span></li>');
		line.forEach(function(s, i) { $ol.append(stepRow(s, i)); });
		$ol.append($('<li>').append($('<button type="button" class="lab-add">+ 결재자 추가</button>').click(function() {
			line.push({ STEP_NM: '', EMPLY_ID: '' });
			drawTeam();
			$('.lab-appr .ar').eq(line.length).find('input').focus();
		})));
		$ol.append('<li class="ar fixed"><b class="no">마감</b><span><b>연구소장 마감</b> 결재가 모두 끝나면 연구소장이 마감 → 잠금 · PDF 업로드 · 연구원 메일</span></li>');
	}

	function stepRow(s, i) {
		var $li = $('<li class="ar">').attr('data-i', i);
		var $hdl = $('<button type="button" class="hdl" title="끌어서 순서 변경">&#8942;&#8942;</button>').attr('aria-label', (i + 1) + '단계 끌어서 이동');
		$hdl.on('mousedown touchstart', function() { $li.attr('draggable', 'true'); });
		$li.append($('<span class="lab-move">').append($hdl,
			$('<button type="button" aria-label="위로">&#9650;</button>').attr('aria-label', (i + 1) + '단계 위로').prop('disabled', i === 0).click(function() { moveStep(i, i - 1); }),
			$('<button type="button">&#9660;</button>').attr('aria-label', (i + 1) + '단계 아래로').prop('disabled', i === line.length - 1).click(function() { moveStep(i, i + 1); })));
		$li.append($('<b class="no">').text((i + 1) + '단계'));
		var nameId = 'stepNm' + i, accId = 'stepAcc' + i;
		$li.append($('<label class="mb-0">').attr('for', nameId).append('<small class="d-block">단계명</small>',
			$('<input class="form-control form-control-sm" maxlength="50" placeholder="부서장">').attr('id', nameId).val(s.STEP_NM).on('change', function() { s.STEP_NM = this.value.trim(); saveLine(); })));
		var $sel = $('<select class="form-control form-control-sm"><option value="">결재자 선택</option></select>').attr('id', accId);
		accounts.forEach(function(a) { $sel.append($('<option>').val(a.EMPLY_ID).text(a.EMPLY_NM + ' (' + a.EMPLY_ID + ')')); });
		$li.append($('<label class="mb-0">').attr('for', accId).append('<small class="d-block">결재자 (관리자 계정)</small>',
			$sel.val(s.EMPLY_ID).on('change', function() { s.EMPLY_ID = this.value; s.SIGN_IMG = null; saveLine(); })));
		$li.append(signCell(s));
		$li.append($('<button type="button" class="btn btn-sm btn-outline-danger lab-del">삭제</button>').attr('aria-label', (i + 1) + '단계 삭제').click(function() {
			bootbox.confirm((i + 1) + '단계(' + (s.STEP_NM || '이름 없음') + ')를 결재라인에서 뺄까요?', function(ok) { if (ok) { line.splice(i, 1); saveLine(true); } });
		}));
		// 줄 끌기. 파일을 끌어오는 것은 서명 칸이 받는다
		$li.on('dragstart', function(e) { dragFrom = i; e.originalEvent.dataTransfer.setData('text/plain', 'step'); $li.addClass('dragging'); });
		$li.on('dragend', function() { $li.removeClass('dragging').removeAttr('draggable'); $('.lab-appr .over').removeClass('over'); });
		$li.on('dragover', function(e) { if (dragFrom === null) return; e.preventDefault(); $('.lab-appr .over').removeClass('over'); $li.addClass('over'); });
		$li.on('drop', function(e) { if (dragFrom === null) return; e.preventDefault(); var from = dragFrom; dragFrom = null; moveStep(from, i); });
		return $li;
	}

	function moveStep(from, to) {
		if (to < 0 || to >= line.length || from === to) { drawTeam(); return; }
		line.splice(to, 0, line.splice(from, 1)[0]);
		saveLine(true);
	}

	/** 모든 줄에 단계명과 결재자가 있을 때만 저장한다 */
	function saveLine(redraw) {
		dragFrom = null;
		if (redraw) drawTeam();
		if (line.some(function(s) { return !s.STEP_NM || !s.EMPLY_ID; })) { toast('단계명과 결재자를 모두 고르면 저장됩니다'); return; }
		var data = { TEAM_SQ: detail.team.TEAM_SQ, STEP_NM: line.map(function(s) { return s.STEP_NM; }), EMPLY_ID: line.map(function(s) { return s.EMPLY_ID; }) };
		hrPost('/admin/lab/saveApprovalData.do', $.param(data, true), function() { toast('결재라인을 저장했습니다'); reload(); }, reload);
	}

	// ── 서명: 본인 줄에서만. 이미지를 끌어다 놓거나, 파일을 고르거나, 직접 그린다 ──
	function signCell(s) {
		var mine = s.EMPLY_ID && s.EMPLY_ID === detail.me, $c = $('<div class="lab-sign">');
		if (!s.EMPLY_ID) return $c.append('<small>결재자를 고르세요</small>');
		if (s.SIGN_IMG) $c.append($('<img>').attr({ src: s.SIGN_IMG, alt: (s.EMPLY_NM || s.EMPLY_ID) + ' 서명' }));
		if (!mine) {
			if (!s.SIGN_IMG) $c.addClass('none').append('<span class="warn">서명 미등록</span><small>본인이 로그인해 자기 줄에서 등록</small>');
			return $c;
		}
		var $file = $('<input type="file" accept="image/png,image/jpeg" class="d-none">').on('change', function() { if (this.files[0]) fileToSign(this.files[0]); this.value = ''; });
		$c.append($('<small>').append(s.SIGN_IMG ? '내 서명 · 바꾸려면 ' : '내 서명을 등록하세요 · ', '이미지를 끌어다 놓거나 ',
			$('<a href="#">파일 선택</a>').click(function(e) { e.preventDefault(); $file.click(); }), ' · ',
			$('<a href="#">직접 그리기</a>').click(function(e) { e.preventDefault(); drawPad($c); })), $file);
		$c.on('dragover', function(e) {
			if ([].indexOf.call(e.originalEvent.dataTransfer.types || [], 'Files') < 0) return;
			e.preventDefault(); e.stopPropagation(); $c.addClass('drop');
		});
		$c.on('dragleave', function() { $c.removeClass('drop'); });
		$c.on('drop', function(e) {
			var f = e.originalEvent.dataTransfer.files[0];
			if (!f) return;
			e.preventDefault(); e.stopPropagation(); $c.removeClass('drop');
			fileToSign(f);
		});
		return $c;
	}

	// 큰 사진도 서명 칸 크기의 PNG 로 줄여서 저장한다
	function fileToSign(file) {
		if (!/^image\/(png|jpeg)$/.test(file.type)) { bootbox.alert('PNG 나 JPG 이미지만 올릴 수 있습니다.'); return; }
		if (file.size > 5 * 1024 * 1024) { bootbox.alert('5MB 이하 이미지만 올릴 수 있습니다.'); return; }
		var url = URL.createObjectURL(file), img = new Image();
		img.onload = function() {
			var c = document.createElement('canvas'), s;
			c.width = 440; c.height = 176;
			s = Math.min(c.width / img.width, c.height / img.height, 1);
			c.getContext('2d').drawImage(img, (c.width - img.width * s) / 2, (c.height - img.height * s) / 2, img.width * s, img.height * s);
			URL.revokeObjectURL(url);
			saveSign(c.toDataURL('image/png'));
		};
		img.onerror = function() { URL.revokeObjectURL(url); bootbox.alert('이미지를 읽지 못했습니다.'); };
		img.src = url;
	}

	function drawPad($c) {
		var canvas = $('<canvas width="440" height="160" aria-label="마우스나 터치로 서명하는 영역" role="img">')[0], ctx = canvas.getContext('2d'), down = false, drawn = false;
		function at(e) { var b = canvas.getBoundingClientRect(); return [(e.clientX - b.left) * canvas.width / b.width, (e.clientY - b.top) * canvas.height / b.height]; }
		canvas.addEventListener('pointerdown', function(e) { down = true; canvas.setPointerCapture(e.pointerId); var p = at(e); ctx.lineWidth = 2.5; ctx.lineCap = 'round'; ctx.strokeStyle = '#111'; ctx.beginPath(); ctx.moveTo(p[0], p[1]); });
		canvas.addEventListener('pointermove', function(e) { if (!down) return; var p = at(e); ctx.lineTo(p[0], p[1]); ctx.stroke(); drawn = true; });
		canvas.addEventListener('pointerup', function() { down = false; });
		canvas.addEventListener('pointercancel', function() { down = false; });
		$c.empty().append(canvas, $('<span class="d-flex flex-wrap" style="gap:6px;">').append(
			$('<button type="button" class="btn btn-sm btn-outline-secondary">지우기</button>').click(function() { ctx.clearRect(0, 0, canvas.width, canvas.height); drawn = false; }),
			$('<button type="button" class="btn btn-sm btn-outline-secondary">취소</button>').click(drawTeam),
			$('<button type="button" class="btn btn-sm btn-primary">저장</button>').click(function() { if (!drawn) { bootbox.alert('서명을 그려 주세요.'); return; } saveSign(canvas.toDataURL('image/png')); })));
	}

	function saveSign(img) {
		hrPost('/admin/lab/saveSignData.do', { IMG: img }, function() { toast('서명을 등록했습니다'); reload(); });
	}

	function reload(then) {
		hrPost('/admin/lab/teamDetailData.do', { TEAM_SQ: detail.team.TEAM_SQ }, function(res) { setDetail(res.result); drawTeam(); if (then) then(); });
	}

	function setDetail(d) {
		detail = d;
		line = d.line.map(function(s) { return $.extend({}, s); });
	}

	// ── 팝업 ──
	function openTeam(t) {
		$('#teamTitle').text(t ? '연구팀 수정' : '연구팀 등록');
		['TEAM_SQ', 'TEAM_NM', 'FIELD_NM', 'PLACE'].forEach(function(f) { $('#' + f).val(t && t[f] || ''); });
		$('#USE_YN').val(t ? t.USE_YN : 'Y');
		$('#teamModal').modal('show');
	}

	function saveTeam() {
		var data = {}, isNew = !$('#TEAM_SQ').val();
		['TEAM_SQ', 'TEAM_NM', 'FIELD_NM', 'PLACE', 'USE_YN'].forEach(function(f) { data[f] = $('#' + f).val(); });
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

	// ── 화면 전환 ──
	function showCurrent() {
		var m = /^#t=(\d+)(?:&tab=(\d))?/.exec(location.hash);
		$('.lab-view').hide();
		if (!m) { $('#viewList').show(); loadList(); return; }
		tab = m[2] ? Number(m[2]) : 0;
		$('#viewTeam').show();
		hrPost('/admin/lab/teamDetailData.do', { TEAM_SQ: m[1] }, function(res) { setDetail(res.result); drawTeam(); });
	}

	$(window).on('hashchange', showCurrent);
	$('#fUse').on('change', drawList);
	$('#fName').on('input', drawList);
	$('#pickSearch').on('input', drawPick);
	hrPost('/admin/lab/optionsData.do', {}, function(res) {
		staff = res.result.staff;
		accounts = res.result.accounts;
		showCurrent();
	});
	</script>
</body>
</html>
