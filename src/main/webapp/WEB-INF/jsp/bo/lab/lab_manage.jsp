<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_head.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/lab/lab_style.jspf"%>
<style>
	.lab-tl { table-layout: fixed; min-width: 760px; }
	@media (max-width: 767px) { .lab-tl-wrap::before { content: '← 가로로 넘겨 보세요 →'; display: inline-block; position: sticky; left: 8px; font-size: 11px; color: #868e96; margin: 4px 0; } }
	.lab-tl th, .lab-tl td { padding: 8px 6px; }
	.lab-tl .m { text-align: center; font-size: 13px; padding: 8px 0; }
	.lab-tl .m.now { background: #343a40; color: #fff; }
	.lab-tl .c { padding: 0; vertical-align: middle; }
	.lab-tl .c div { height: 20px; }
	.bar-HEAD { background: #0a4a78; }
	.bar-MEMBER { background: #7dbbdc; }
	.lab-legend i { display: inline-block; width: 18px; height: 12px; margin: 0 5px 0 12px; }
	.lab-pick { max-height: 220px; overflow-y: auto; }
	/* 연구원 상세: 소속 기간 */
	.lab-cnt { display: inline-block; min-width: 22px; text-align: center; border-radius: 10px; background: #0a4a78; color: #fff; font-size: 12px; padding: 0 6px; }
	.lab-gap td { text-align: center; font-size: 12px; color: #495057; background: repeating-linear-gradient(45deg, #fafbfc, #fafbfc 6px, #f1f3f5 6px, #f1f3f5 12px); }
	.lab-period-edit td { background: #f5fbfd; }
	.lab-period-edit input, .lab-period-edit select { min-width: 120px; }
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

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_open.jspf"%>
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
			<%@ include file="/WEB-INF/jsp/bo/boinclude/page_close.jspf"%>

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

	<div class="modal fade" id="rschModal" tabindex="-1" role="dialog" aria-labelledby="rschTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="rschTitle">연구원</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body" id="rschBody"></div>
				<div class="modal-footer"><button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">닫기</button></div>
			</div>
		</div>
	</div>

	<div id="labToast" role="status" aria-live="polite"></div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/page_script.jspf"%>
	<script>
	// 순서를 바꾸면 #t=팀&tab=번호 링크가 달라진다(결재라인=3 은 연구일지 화면의 서명 안내가 쓴다)
	var TABS = ['연구과제', '연구원', '소속 현황', '결재라인', '기본 정보'];
	var JRN_STATUS = { DRAFT: '작성 중', SUBMITTED: '결재 중', APPROVED: '결재 완료', CLOSED: '마감' };
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
		if (!list.length) boEmpty($b, '연구팀이 없습니다.');
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
		[drawProjects, drawMembers, drawTimeline, drawApproval, drawInfo][tab]($b);
		$v.append($('<div class="lab-back">').append('<a class="btn btn-sm btn-outline-secondary" href="#">목록</a>'));
	}

	/** 연구과제: 진행 중인 과제가 위로. 과제를 누르면 과제 상세(연구일지 목록·업무요약·처리 이력)로 */
	function drawProjects($b) {
		var t = detail.team, now = today();
		$b.append(actions(['과제 등록', function() { location.href = '/admin/lab/openJournalList.do#new=' + t.TEAM_SQ; }]));
		var list = (detail.projects || []).slice().sort(function(a, b) { return (b.END_DT >= now) - (a.END_DT >= now) || (b.START_DT > a.START_DT ? 1 : -1); });
		var $t = $('<tbody>');
		if (!list.length) boEmpty($t, '과제가 없습니다.');
		list.forEach(function(p) {
			var on = p.END_DT >= now;
			$('<tr>').append($('<td>').append($('<a class="lab-open">').attr('href', '/admin/lab/openJournalList.do#p=' + p.PRJ_SQ).text(p.PRJ_NM)),
				$('<td>').text(p.START_DT + ' ~ ' + p.END_DT), $('<td>').text(p.JRN_CNT + '건'),
				$('<td>').append(p.LAST_YM ? [document.createTextNode(p.LAST_YM + ' '), $('<span class="lab-pill">').addClass(p.LAST_STATUS).text(JRN_STATUS[p.LAST_STATUS] || '')] : ''),
				$('<td>').append($('<span class="lab-pill">').toggleClass('SUBMITTED', on).text(on ? '진행 중' : '종료'))).appendTo($t);
		});
		$b.append($('<div class="table-responsive">').append($('<table class="table table-sm table-hover cal-table mb-0"><thead><tr><th>연구과제</th><th>기간</th><th>연구일지</th><th>최근 일지</th><th>진행</th></tr></thead></table>').append($t)));
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

	function today() { return new Date(Date.now() + 9 * 3600000).toISOString().slice(0, 10); }
	function roleName(cd) { return ROLE[cd] || { HEAD: '연구소장', MEMBER: '연구원' }[cd] || cd; }
	function isActive(p) { return !p.END_DT || p.END_DT >= today(); }

	/** 같은 직원의 소속 기간(연구원 행)을 한 사람으로 묶는다. 기간은 최근 순 */
	function persons() {
		var by = {}, out = [];
		detail.researchers.forEach(function(r) {
			if (!by[r.STAFF_SQ]) out.push(by[r.STAFF_SQ] = { STAFF_SQ: r.STAFF_SQ, STAFF_NM: r.STAFF_NM, DEPT_NM: r.DEPT_NM, periods: [] });
			by[r.STAFF_SQ].periods.push(r);
		});
		out.forEach(function(p) { p.periods.sort(function(a, b) { return a.START_DT < b.START_DT ? 1 : a.START_DT > b.START_DT ? -1 : 0; }); p.now = p.periods[0]; });
		return out.sort(function(a, b) { return (isActive(b.now) - isActive(a.now)) || a.STAFF_NM.localeCompare(b.STAFF_NM); });
	}

	function drawMembers($b) {
		$b.append(actions(['연구원 등록', function() { openMember(); }]));
		var $t = $('<tbody>'), list = persons();
		if (!list.length) boEmpty($t, '등록된 연구원이 없습니다.');
		list.forEach(function(p) {
			var on = isActive(p.now);
			$('<tr>').append($('<td>').append($('<a href="#" class="lab-open">').text(p.STAFF_NM).click(function(e) { e.preventDefault(); openPerson(p.STAFF_SQ); })), $('<td>').text(p.DEPT_NM || ''),
				$('<td>').text(roleName(p.now.ROLE_CD)),
				$('<td>').append($('<span class="lab-pill">').toggleClass('APPROVED', on).text(on ? '소속 중' : '종료'), ' ', on ? p.now.START_DT + ' ~' : '~ ' + p.now.END_DT),
				$('<td>').append($('<span class="lab-cnt">').text(p.periods.length)), $('<td>').append(cardLink(p.STAFF_SQ))).appendTo($t);
		});
		$b.append($('<div class="table-responsive">').append($('<table class="table table-sm table-hover cal-table mb-0"><thead><tr><th>성명</th><th>부서</th><th>현재 역할</th><th>현재 상태</th><th>소속 기간</th><th>직원관리</th></tr></thead></table>').append($t)));
	}

	// ── 연구원 상세: 소속 기간을 표에서 바로 추가·수정 ──
	var personSq = null, editing = null;

	function openPerson(sq) {
		personSq = sq;
		editing = null;
		drawPerson();
		$('#rschModal').modal('show');
	}

	function dayAdd(d, n) { var x = new Date(d + 'T00:00:00Z'); x.setUTCDate(x.getUTCDate() + n); return x.toISOString().slice(0, 10); }

	function drawPerson() {
		var p = persons().filter(function(x) { return String(x.STAFF_SQ) === String(personSq); })[0];
		if (!p) { $('#rschModal').modal('hide'); return; }
		$('#rschTitle').empty().append($('<span>').text(p.STAFF_NM), ' ', $('<small class="text-muted">').text(p.DEPT_NM || ''), ' ', cardLink(p.STAFF_SQ).addClass('small ml-2'));
		var $t = $('<tbody>'), rows = editing && !editing.RSCH_SQ ? [editing].concat(p.periods) : p.periods;
		rows.forEach(function(r, i) {
			var next = rows[i + 1];
			$t.append(editing && editing === r || editing && r.RSCH_SQ && editing.RSCH_SQ === r.RSCH_SQ ? periodEditRow(editing) : periodRow(r, p));
			// 기간 사이 공백(앞 기간 종료 다음 날 ~ 다음 기간 시작 전날)
			if (next && next.END_DT && r.START_DT && dayAdd(next.END_DT, 1) < r.START_DT) {
				var from = dayAdd(next.END_DT, 1), to = dayAdd(r.START_DT, -1);
				var months = (Number(to.slice(0, 4)) - Number(from.slice(0, 4))) * 12 + Number(to.slice(5, 7)) - Number(from.slice(5, 7)) + 1;
				$t.append($('<tr class="lab-gap">').append($('<td colspan="4">').text('공백 ' + from + ' ~ ' + to + ' (' + months + '개월)')));
			}
		});
		$('#rschBody').empty().append(
			$('<div class="table-responsive">').append($('<table class="table table-sm cal-table mb-2"><thead><tr><th>역할</th><th>소속 시작일</th><th>소속 종료일</th><th></th></tr></thead></table>').append($t)),
			$('<button type="button" class="lab-add">+ 소속 기간 추가</button>').prop('disabled', !!editing).click(function() { editing = { STAFF_SQ: p.STAFF_SQ, ROLE_CD: p.now.ROLE_CD, START_DT: '', END_DT: '' }; drawPerson(); $('#rschBody input[type=date]').first().focus(); }),
			$('<p class="small text-muted mt-2 mb-0">').text('다른 기간과 겹치면 저장되지 않습니다. 연구원 → 연구소장처럼 역할이 바뀌면 기간을 하나 더 넣어 나눕니다.'));
	}

	function periodRow(r, p) {
		return $('<tr>').append($('<td>').text(roleName(r.ROLE_CD)), $('<td>').text(r.START_DT), $('<td>').text(r.END_DT || '소속 중'),
			$('<td class="text-right text-nowrap">').append($('<button type="button" class="btn btn-sm btn-outline-secondary">수정</button>').prop('disabled', !!editing).click(function() { editing = $.extend({}, r); drawPerson(); }), ' ',
				$('<button type="button" class="btn btn-sm btn-outline-danger">삭제</button>').prop('disabled', !!editing).click(function() { deletePeriod(r, p); })));
	}

	function deletePeriod(r, p) {
		var msg = r.START_DT + ' ~ ' + (r.END_DT || '소속 중') + ' 기간을 지울까요?'
			+ (p.periods.length === 1 ? ' 마지막 기간이라 ' + p.STAFF_NM + ' 님이 연구원 목록에서 빠집니다.' : '')
			+ ' 이미 제출된 연구일지에는 영향이 없습니다.';
		bootbox.confirm($('<div>').text(msg).html(), function(ok) {
			if (!ok) return;
			hrPost('/admin/lab/saveResearcherData.do', { TEAM_SQ: detail.team.TEAM_SQ, RSCH_SQ: r.RSCH_SQ, DEL: 'Y' }, function() {
				toast('소속 기간을 지웠습니다');
				reload(drawPerson);
			});
		});
	}

	function periodEditRow(r) {
		var $role = $('<select class="form-control form-control-sm" aria-label="역할">');
		Object.keys($.isEmptyObject(ROLE) ? { MEMBER: 1, HEAD: 1 } : ROLE).forEach(function(cd) { $role.append($('<option>').val(cd).text(roleName(cd))); });
		$role.val(r.ROLE_CD || 'MEMBER').on('change', function() { r.ROLE_CD = this.value; });
		var $s = $('<input type="date" class="form-control form-control-sm" aria-label="소속 시작일">').val(r.START_DT).on('change', function() { r.START_DT = this.value; });
		var $e = $('<input type="date" class="form-control form-control-sm" aria-label="소속 종료일 (비우면 소속 중)">').val(r.END_DT || '').on('change', function() { r.END_DT = this.value; });
		return $('<tr class="lab-period-edit">').append($('<td>').append($role), $('<td>').append($s), $('<td>').append($e),
			$('<td class="text-right text-nowrap">').append($('<button type="button" class="btn btn-sm btn-primary">저장</button>').click(function() { savePeriod(r, $(this)); }), ' ',
				$('<button type="button" class="btn btn-sm btn-outline-secondary">취소</button>').click(function() { editing = null; drawPerson(); })));
	}

	function savePeriod(r, $btn) {
		$btn.prop('disabled', true);
		hrPost('/admin/lab/saveResearcherData.do', { TEAM_SQ: detail.team.TEAM_SQ, RSCH_SQ: r.RSCH_SQ || '', STAFF_SQ: r.STAFF_SQ, ROLE_CD: r.ROLE_CD, START_DT: r.START_DT, END_DT: r.END_DT || '' }, function() {
			editing = null;
			toast('소속 기간을 저장했습니다');
			reload(drawPerson);
		}, function() { $btn.prop('disabled', false); });
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
		// 한 사람 한 줄. 기간이 여러 개면 막대가 끊겨 공백이 보인다
		function inYear(r) { return r.START_DT.slice(0, 4) <= String(year) && (!r.END_DT || r.END_DT.slice(0, 4) >= String(year)); }
		var rows = persons().filter(function(p) { return p.periods.some(inYear); })
			.sort(function(a, b) { var x = a.periods[a.periods.length - 1].START_DT, y = b.periods[b.periods.length - 1].START_DT; return x < y ? -1 : x > y ? 1 : 0; });
		if (!rows.length) boEmpty($t, '이 해에 소속된 연구원이 없습니다.');
		rows.forEach(function(p) {
			var $r = $('<tr>').append($('<td>').append($('<b>').text(p.STAFF_NM)));
			months.forEach(function(m) {
				var r = p.periods.filter(function(x) { return x.START_DT.slice(0, 7) <= m && (!x.END_DT || x.END_DT.slice(0, 7) >= m); })[0];
				$('<td class="c">').append(r ? $('<div>').addClass('bar-' + r.ROLE_CD).attr('title', roleName(r.ROLE_CD)) : '').appendTo($r);
			});
			$r.append($('<td class="small">').text(p.periods.slice().reverse().map(function(x) { return x.START_DT + ' ~ ' + (x.END_DT || '소속 중'); }).join(' · '))).appendTo($t);
		});
		$b.append($('<div class="table-responsive lab-tl-wrap">').append($('<table class="table table-sm cal-table mb-0 lab-tl">').append($('<thead>').append($h), $t)));
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

	// ── 서명: 본인 줄에서, 슈퍼관리자는 모든 줄에서(대리 등록). 이미지를 끌어다 놓거나, 파일을 고르거나, 직접 그린다 ──
	function signCell(s) {
		var mine = s.EMPLY_ID && s.EMPLY_ID === detail.me, $c = $('<div class="lab-sign">');
		if (!s.EMPLY_ID) return $c.append('<small>결재자를 고르세요</small>');
		if (s.SIGN_IMG) $c.append($('<img>').attr({ src: s.SIGN_IMG, alt: (s.EMPLY_NM || s.EMPLY_ID) + ' 서명' }));
		if (s.SIGN_IMG && s.SIGN_REG_ID && s.SIGN_REG_ID !== s.EMPLY_ID) $c.append($('<small class="text-muted">').text('대리 등록: ' + s.SIGN_REG_ID));
		if (!mine && !detail.canSignAll) {
			if (!s.SIGN_IMG) $c.addClass('none').append('<span class="warn">서명 미등록</span><small>본인이 로그인해 자기 줄에서 등록</small>');
			return $c;
		}
		var who = mine ? '내 서명' : (s.EMPLY_NM || s.EMPLY_ID) + ' 서명(대리 등록)';
		var $file = $('<input type="file" accept="image/png,image/jpeg" class="d-none">').on('change', function() { if (this.files[0]) fileToSign(this.files[0], s); this.value = ''; });
		if (!s.SIGN_IMG && !mine) $c.addClass('none').append('<span class="warn">서명 미등록</span>');
		$c.append($('<small>').append(s.SIGN_IMG ? who + ' · 바꾸려면 ' : who + '을 등록하세요 · ', '이미지를 끌어다 놓거나 ',
			$('<a href="#">파일 선택</a>').click(function(e) { e.preventDefault(); $file.click(); }), ' · ',
			$('<a href="#">직접 그리기</a>').click(function(e) { e.preventDefault(); drawPad($c, s); })), $file);
		$c.on('dragover', function(e) {
			if ([].indexOf.call(e.originalEvent.dataTransfer.types || [], 'Files') < 0) return;
			e.preventDefault(); e.stopPropagation(); $c.addClass('drop');
		});
		$c.on('dragleave', function() { $c.removeClass('drop'); });
		$c.on('drop', function(e) {
			var f = e.originalEvent.dataTransfer.files[0];
			if (!f) return;
			e.preventDefault(); e.stopPropagation(); $c.removeClass('drop');
			fileToSign(f, s);
		});
		return $c;
	}

	// 큰 사진도 서명 칸 크기의 PNG 로 줄여서 저장한다
	function fileToSign(file, s) {
		if (!/^image\/(png|jpeg)$/.test(file.type)) { bootbox.alert('PNG 나 JPG 이미지만 올릴 수 있습니다.'); return; }
		if (file.size > 5 * 1024 * 1024) { bootbox.alert('5MB 이하 이미지만 올릴 수 있습니다.'); return; }
		var url = URL.createObjectURL(file), img = new Image();
		img.onload = function() {
			var c = document.createElement('canvas'), k;
			c.width = 440; c.height = 176;
			k = Math.min(c.width / img.width, c.height / img.height, 1);
			c.getContext('2d').drawImage(img, (c.width - img.width * k) / 2, (c.height - img.height * k) / 2, img.width * k, img.height * k);
			URL.revokeObjectURL(url);
			saveSign(c.toDataURL('image/png'), s);
		};
		img.onerror = function() { URL.revokeObjectURL(url); bootbox.alert('이미지를 읽지 못했습니다.'); };
		img.src = url;
	}

	function drawPad($c, s) {
		var canvas = $('<canvas width="440" height="160" aria-label="마우스나 터치로 서명하는 영역" role="img">')[0], ctx = canvas.getContext('2d'), down = false, drawn = false;
		function at(e) { var b = canvas.getBoundingClientRect(); return [(e.clientX - b.left) * canvas.width / b.width, (e.clientY - b.top) * canvas.height / b.height]; }
		canvas.addEventListener('pointerdown', function(e) { down = true; canvas.setPointerCapture(e.pointerId); var p = at(e); ctx.lineWidth = 2.5; ctx.lineCap = 'round'; ctx.strokeStyle = '#111'; ctx.beginPath(); ctx.moveTo(p[0], p[1]); });
		canvas.addEventListener('pointermove', function(e) { if (!down) return; var p = at(e); ctx.lineTo(p[0], p[1]); ctx.stroke(); drawn = true; });
		canvas.addEventListener('pointerup', function() { down = false; });
		canvas.addEventListener('pointercancel', function() { down = false; });
		$c.empty().append(canvas, $('<span class="d-flex flex-wrap" style="gap:6px;">').append(
			$('<button type="button" class="btn btn-sm btn-outline-secondary">지우기</button>').click(function() { ctx.clearRect(0, 0, canvas.width, canvas.height); drawn = false; }),
			$('<button type="button" class="btn btn-sm btn-outline-secondary">취소</button>').click(drawTeam),
			$('<button type="button" class="btn btn-sm btn-primary">저장</button>').click(function() { if (!drawn) { bootbox.alert('서명을 그려 주세요.'); return; } saveSign(canvas.toDataURL('image/png'), s); })));
	}

	function saveSign(img, s) {
		hrPost('/admin/lab/saveSignData.do', { IMG: img, EMPLY_ID: s.EMPLY_ID }, function() { toast('서명을 등록했습니다'); reload(); });
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
		if (!list.length) boEmpty($b, '성명이나 부서로 검색해 주세요.');
		// 이미 이 팀 연구원인 직원은 고를 수 없고 상세로 보낸다(재소속은 상세에서 기간 추가)
		var registered = {};
		detail.researchers.forEach(function(r) { registered[r.STAFF_SQ] = true; });
		list.forEach(function(s) {
			var done = registered[s.STAFF_SQ];
			var $radio = $('<input type="radio" name="pick">').attr('aria-label', s.STAFF_NM + ' 선택').prop({ checked: !done && String(s.STAFF_SQ) === String(picked), disabled: !!done }).on('change', function() { picked = s.STAFF_SQ; });
			var $last = done ? $('<td>').append('<span class="lab-pill">이미 등록됨</span> ', $('<a href="#">상세에서 기간 추가</a>').click(function(e) {
				e.preventDefault();
				$('#memberModal').one('hidden.bs.modal', function() { openPerson(s.STAFF_SQ); }).modal('hide');
			})) : $('<td>').append(cardLink(s.STAFF_SQ));
			$('<tr>').append($('<td>').append($radio), $('<td>').text(s.STAFF_NM + (s.STATUS_CD === 'LEFT' ? ' (퇴사)' : '')), $('<td>').text(s.DEPT_NM || ''), $('<td>').text(s.POSITION_NM || ''), $last).appendTo($b);
		});
	}

	/** 처음 한 번만: 직원을 고르고 첫 소속 기간을 넣는다 */
	function openMember() {
		picked = null;
		$('#pickSearch').val('');
		$('#ROLE_CD').val('MEMBER');
		$('#START_DT, #END_DT').val('');
		drawPick();
		$('#memberModal').modal('show');
	}

	function saveMember() {
		var sq = picked;
		hrPost('/admin/lab/saveResearcherData.do', { TEAM_SQ: detail.team.TEAM_SQ, RSCH_SQ: '', STAFF_SQ: sq || '', ROLE_CD: $('#ROLE_CD').val(), START_DT: $('#START_DT').val(), END_DT: $('#END_DT').val() }, function() {
			$('#memberModal').modal('hide');
			toast('연구원을 등록했습니다');
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
