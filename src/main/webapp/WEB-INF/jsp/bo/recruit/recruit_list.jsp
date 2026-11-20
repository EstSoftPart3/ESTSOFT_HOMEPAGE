<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/bo/boinclude/page_head.jspf"%>
<%-- 모집 관리(plans/deploy-recruit-split-spec.html). 왼쪽 모집(5가지 보기) + 오른쪽 대기자 패널, 대기자를 모집에 끌어 놓으면 지원 --%>
<style>
	.rc-top { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; margin-bottom: 10px; }
	.rc-views { display: inline-flex; gap: 4px; margin-left: auto; }
	.rc-views button { border: 1px solid rgba(17,17,17,.15); background: #fff; border-radius: 999px; padding: 3px 11px; font-size: 12.5px; font-weight: 700; color: #444; }
	.rc-views button[aria-pressed=true] { background: #111; border-color: #111; color: #fff; }
	.rc-lay { display: flex; gap: 0; align-items: stretch; min-height: 480px; }
	.rc-main { flex: 1 1 auto; min-width: 320px; overflow: auto; padding-right: 10px; }
	.rc-grip { flex: none; width: 10px; cursor: col-resize; background: linear-gradient(90deg, transparent 4px, #d5dbe0 4px, #d5dbe0 6px, transparent 6px); }
	.rc-grip:hover, .rc-grip:focus { background: linear-gradient(90deg, transparent 3px, #0b6e8a 3px, #0b6e8a 7px, transparent 7px); outline: none; }
	.rc-side { flex: none; width: 380px; min-width: 260px; max-width: 70%; padding-left: 10px; overflow: auto; }
	.rc-side h3, .rc-main h3 { font-size: 14px; font-weight: 800; margin: 0 0 8px; display: flex; gap: 6px; align-items: center; flex-wrap: wrap; }
	.rc-cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 10px; }
	.rc-card { border: 1px solid rgba(17,17,17,.12); border-radius: 10px; padding: 10px 12px; background: #fff; cursor: pointer; position: relative; }
	.rc-card:hover { border-color: #0b6e8a; }
	.rc-card.miss { border: 2px solid #ffc078; background: #fffaf0; }
	.rc-card.done { opacity: .62; }
	.rc-card.over, tr.over td, .rc-bcol.over { outline: 3px dashed #0b6e8a; outline-offset: -3px; background: #eef9fc; }
	.rc-card .cl { font-weight: 800; font-size: 15px; margin-top: 4px; }
	.rc-card .pj { color: #495057; font-size: 12.5px; margin-bottom: 6px; }
	.rc-card dl { display: grid; grid-template-columns: 62px 1fr; gap: 2px 6px; font-size: 12px; margin: 0; }
	.rc-card dt { color: #868e96; font-weight: 600; } .rc-card dd { margin: 0; }
	.rc-q { color: #e67700; font-weight: 700; }
	.rc-pill { display: inline-block; border-radius: 999px; padding: 0 8px; font-size: 11px; font-weight: 700; background: #f1f3f5; color: #495057; white-space: nowrap; }
	.rc-pill.OPEN { background: #e7f5ff; color: #1864ab; } .rc-pill.APPLY { background: #edf2ff; color: #4c3fd0; } .rc-pill.FILLED { background: #d3f9d8; color: #2b8a3e; } .rc-pill.CLOSED { background: #e9ecef; color: #495057; }
	.rc-pill.warn { background: #fff3bf; color: #e67700; } .rc-pill.bad { background: #ffe3e3; color: #c92a2a; }
	.rc-sk { display: inline-block; background: #f1f4f6; border-radius: 4px; padding: 0 5px; margin: 1px 2px 1px 0; font-size: 11px; }
	.rc-prog { height: 5px; background: #eef1f4; border-radius: 3px; margin-top: 8px; overflow: hidden; } .rc-prog i { display: block; height: 100%; background: #4c6ef5; }
	.rc-mini { display: flex; justify-content: space-between; font-size: 11.5px; color: #5f6b75; margin-top: 3px; }
	.rc-app { display: flex; gap: 6px; align-items: center; font-size: 12px; margin-top: 4px; }
	.rc-app b { min-width: 46px; }
	.rc-step { border: 0; border-radius: 999px; padding: 0 8px; font-size: 11px; font-weight: 700; background: #edf2ff; color: #364fc7; white-space: nowrap; }
	.rc-step.DOC { background: #f1f3f5; color: #495057; } .rc-step.INTV, .rc-step.INTV_WAIT { background: #fff4e6; color: #d9480f; } .rc-step.JOIN_WAIT { background: #e6fcf5; color: #087f5b; }
	.rc-step.JOIN { background: #d3f9d8; color: #2b8a3e; } .rc-step.DROP { background: #ffe3e3; color: #c92a2a; text-decoration: line-through; }
	.rc-stepper { display: inline-flex; border: 1px solid #dee2e6; border-radius: 999px; overflow: hidden; flex-wrap: wrap; }
	.rc-stepper button { border: 0; border-left: 1px solid #fff; background: #fff; padding: 2px 9px; font-size: 11.5px; color: #868e96; }
	.rc-stepper button:first-child { border-left: 0; } .rc-stepper button.past { background: #d3f9d8; color: #2b8a3e; font-weight: 700; } .rc-stepper button.now { background: #0b6e8a; color: #fff; font-weight: 800; }
	.rc-who { border: 0; background: none; padding: 0; color: inherit; text-align: left; cursor: pointer; }
	.rc-who:hover b, .rc-who:focus b { color: #0b6e8a; text-decoration: underline; }
	.rc-pop { position: fixed; top: 0; left: 0; width: 100%; height: 100%; border: 0; z-index: 1060; background: transparent; }
	.rc-pop-wait { position: fixed; inset: 0; z-index: 1059; background: rgba(0,0,0,.25); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 700; }
	.rc-menu { position: absolute; z-index: 1060; background: #fff; border: 1px solid #ccd3d9; border-radius: 8px; box-shadow: 0 6px 18px rgba(0,0,0,.15); padding: 4px; min-width: 150px; }
	.rc-menu button { display: block; width: 100%; text-align: left; border: 0; background: none; padding: 4px 10px; border-radius: 6px; font-size: 12.5px; }
	.rc-menu button:hover, .rc-menu button:focus { background: #f1f4f6; } .rc-menu button.cur { font-weight: 800; color: #0b6e8a; }
	.rc-board { display: grid; grid-template-columns: repeat(4, minmax(200px, 1fr)); gap: 10px; }
	.rc-bcol { background: #f8f9fa; border-radius: 10px; padding: 8px; min-height: 200px; }
	.rc-bcol .rc-card { margin-bottom: 8px; }
	.rc-cal { width: 100%; table-layout: fixed; border-collapse: collapse; font-size: 11.5px; }
	.rc-cal th { text-align: center; background: #f6f8fa; padding: 4px; } .rc-cal td { vertical-align: top; height: 82px; border: 1px solid #eef1f4; padding: 3px; }
	.rc-cal td.out { background: #fafbfc; color: #adb5bd; } .rc-cal td.today { background: #eef9fc; }
	.rc-cal .ev { display: block; border-radius: 4px; padding: 0 4px; margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; cursor: pointer; }
	.rc-cal .ev.close { background: #ffe3e3; color: #c92a2a; } .rc-cal .ev.intv { background: #fff4e6; color: #d9480f; } .rc-cal .ev.start { background: #d3f9d8; color: #2b8a3e; } .rc-cal .ev.reg { background: #e7f5ff; color: #1864ab; }
	.rc-tl { display: grid; grid-template-columns: 160px 1fr; gap: 5px 8px; align-items: center; font-size: 12px; min-width: 640px; }
	.rc-tl .mon { display: grid; font-weight: 700; color: #868e96; } .rc-tl .trk { position: relative; height: 16px; background: #f1f3f5; border-radius: 4px; }
	.rc-tl .bar { position: absolute; top: 0; bottom: 0; background: #ffd8a8; border-radius: 4px; cursor: pointer; } .rc-tl .bar.open { border-right: 2px dashed #d9480f; }
	.rc-tl .bar.FILLED { background: #b2f2bb; } .rc-tl .bar.pp { top: 5px; bottom: 5px; background: #96f2d7; } .rc-tl .now { position: absolute; top: -2px; bottom: -2px; width: 2px; background: #0b6e8a; }
	#ppTable td { vertical-align: top; font-size: 12px; }
	#ppTable tr[draggable=true] td:first-child { cursor: grab; }
	#ppTable tr.off td { opacity: .55; } #ppTable .sub { color: #868e96; font-size: 11px; }
	.rc-ver { display: inline-block; border: 1px solid #ced4da; border-radius: 6px; padding: 0 5px; font-size: 10.5px; margin: 1px 2px 1px 0; color: #495057; background: #fff; text-decoration: none !important; }
	.rc-ver.EDIT { border-color: #b197fc; color: #6741d9; background: #f3f0ff; }
	.rc-find { position: relative; margin-bottom: 8px; }
	.rc-find-list { position: absolute; left: 0; right: 0; top: 34px; z-index: 30; background: #fff; border: 1px solid #c9ced6; border-radius: 8px; box-shadow: 0 8px 20px rgba(0,0,0,.12); max-height: 320px; overflow: auto; }
	.rc-find-list .it { display: flex; gap: 6px; padding: 6px 10px; border-bottom: 1px solid #f1f3f5; font-size: 12px; cursor: grab; align-items: center; flex-wrap: wrap; }
	.rc-kv { display: grid; grid-template-columns: 110px 1fr; gap: 6px 10px; align-items: center; font-size: 13px; }
	.rc-kv > label { margin: 0; font-weight: 700; color: #495057; font-size: 12.5px; } .rc-kv > label.q { color: #e67700; }
	.rc-kv .form-control { height: 30px; font-size: 13px; }
	.rc-kv > .rc-sec { grid-column: 1 / -1; margin: 8px 0 0; }
	.rc-kv > .rc-sec:first-child { margin-top: 0; }
	.rc-raw { font: 12px/1.7 ui-monospace, Consolas, monospace; white-space: pre-wrap; background: #fafbfc; border: 1px solid #e9ecef; border-radius: 8px; padding: 8px 10px; max-height: 240px; overflow: auto; }
	.rc-sec { border-top: 1px solid #eef1f4; padding-top: 10px; margin-top: 12px; } .rc-sec h4 { font-size: 13px; font-weight: 800; margin-bottom: 8px; display: flex; gap: 6px; align-items: center; }
	.rc-opt { display: flex; gap: 8px; align-items: center; border: 1px solid #dee2e6; border-radius: 8px; padding: 7px 10px; margin-bottom: 6px; cursor: pointer; font-size: 13px; }
	.rc-opt.on { border-color: #0b6e8a; background: #eef9fc; }
	.rc-note { font-size: 11.5px; color: #868e96; }
	.rc-chips .pl-chip { margin-bottom: 0; }
	.rc-drop-hint { border: 1px dashed #c9ced6; border-radius: 8px; padding: 10px; text-align: center; color: #868e96; font-size: 12px; margin-top: 6px; }
	.rc-wayb { border: 1px solid #ced4da; background: #fff; border-radius: 999px; padding: 2px 12px; font-size: 12.5px; margin-right: 4px; }
	.rc-wayb[aria-pressed=true] { background: #0b6e8a; border-color: #0b6e8a; color: #fff; font-weight: 700; }
	.rc-join2 { background: #fff9db; border: 1px solid #ffe066; border-radius: 8px; padding: 10px; }
	@media (max-width: 900px) { .rc-lay { flex-direction: column; } .rc-side { width: auto !important; max-width: none; padding-left: 0; } .rc-grip { display: none; } }
	.rc-add { border: 1px dashed #0b6e8a; background: #fff; color: #0b6e8a; border-radius: 999px; padding: 1px 10px; font-size: 11.5px; font-weight: 700; margin-top: 6px; }
	.rc-pick { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; width: 100%; text-align: left; border: 1px solid #dee2e6; background: #fff; border-radius: 8px; padding: 8px 10px; margin-bottom: 6px; font-size: 13px; }
	.rc-pick:hover, .rc-pick:focus { border-color: #0b6e8a; background: #eef9fc; }
	@media (max-width: 767px) {
		.rc-views { flex-wrap: wrap; margin-left: 0; }
		.rc-add { padding: 6px 14px; font-size: 13px; }
		.rc-cal { font-size: 10px; } .rc-cal th { padding: 2px 0; } .rc-cal td { height: auto; min-height: 44px; padding: 1px; }
		.rc-cal .ev { font-size: 0; height: 6px; padding: 0; margin-top: 1px; } /* 폰: 일정은 색 띠만, 누르면 상세 */
		.rc-board-wrap::before, .rc-tl-wrap::before { content: '← 가로로 넘겨 보세요 →'; display: inline-block; position: sticky; left: 8px; font-size: 11px; color: #868e96; margin: 4px 0; }
	}
</style>
<%@ include file="/WEB-INF/jsp/bo/boinclude/page_open.jspf"%>
<div class="card-header d-flex align-items-center flex-wrap" style="gap:6px">
	<h3 class="card-title bTitle mr-auto"><b>모집 관리</b></h3>
	<button type="button" class="btn btn-sm btn-primary" id="addBtn">+ 모집 등록</button>
</div>
<div class="card-body">
	<div class="rc-top">
		<div id="stChips" class="rc-chips d-flex flex-wrap align-items-center" style="gap:4px" role="group" aria-label="모집 상태"></div>
		<input type="search" id="rcFind" class="form-control form-control-sm" style="width:200px" placeholder="고객사·사업명·기술 찾기" aria-label="모집 찾기">
		<div class="rc-views" role="group" aria-label="보기">
			<button type="button" data-view="card" aria-pressed="true">▦ 카드</button><button type="button" data-view="table" aria-pressed="false">☰ 표</button><button type="button" data-view="board" aria-pressed="false">▥ 상태 보드</button><button type="button" data-view="cal" aria-pressed="false">📅 달력</button><button type="button" data-view="tl" aria-pressed="false">▬ 타임라인</button>
		</div>
	</div>
	<div class="rc-lay">
		<div class="rc-main" id="rcMain"><div class="text-muted p-3">불러오는 중…</div></div>
		<div class="rc-grip" id="rcGrip" role="separator" aria-orientation="vertical" aria-label="모집·대기자 너비 조절 (←→)" tabindex="0" title="끌어서 너비 조절"></div>
		<div class="rc-side" id="rcSide">
			<h3>대기자 <span id="ppCnt" class="text-muted"></span></h3>
			<div id="ppChips" class="rc-chips d-flex flex-wrap align-items-center mb-2" style="gap:4px" role="group" aria-label="대기자 구분"></div>
			<div class="rc-find">
				<input type="search" id="ppFind" class="form-control form-control-sm" placeholder="🔍 전체 직원에서 찾기 (투입 중 포함)" aria-label="전체 직원에서 찾기" autocomplete="off">
				<div class="rc-find-list" id="ppFindList" hidden></div>
			</div>
			<div class="tbl-scroll"><!-- 없으면 ui-table.js 가 .rc-side 를 스크롤 상자로 보고 그 앞(가로 flex)에 위 스크롤바를 끼워 넣어 가운데 빈 영역이 생긴다 -->
			<table class="table table-sm" id="ppTable">
				<thead><tr><th scope="col">성명</th><th scope="col">상태</th><th scope="col">프로필</th><th scope="col">지원 중</th></tr></thead>
				<tbody id="ppBody"></tbody>
			</table>
			</div>
			<div class="rc-note">사람을 잡아 왼쪽 모집에 놓으면 지원 창이 떠요. 프로필(수행이력 버전)이 없는 사람은 끌리지 않아요.</div>
		</div>
	</div>
</div>
<%@ include file="/WEB-INF/jsp/bo/boinclude/page_close.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/boinclude/page_script.jspf"%>
<script>
var PATH = location.pathname, D = null, VIEW = 'card', ST_CHK = { OPEN: true, APPLY: true, FILLED: true, CLOSED: false, MISS: false }, PP_CHK = { WAIT: true, FUTURE: true, SOON: true };
var STATUS = { OPEN: '모집중', APPLY: '지원 진행', FILLED: '충원 완료', CLOSED: '마감' };
var STEPS = [['DOC', '서류검토'], ['INTV_WAIT', '인터뷰대기'], ['INTV', '인터뷰확정'], ['JOIN_WAIT', '투입대기'], ['JOIN', '투입확정']];
var STEP_NM = { DROP: '탈락·취소' }; STEPS.forEach(function(s) { STEP_NM[s[0]] = s[1]; });
var WAY = { FACE: '대면', VIDEO: '화상', PHONE: '전화' };
var MISS = [['CLIENT_NM', '고객사'], ['PRJ_NM', '사업명'], ['GRADE_TXT', '등급·인원'], ['START_DT', '투입 시작'], ['WORK_AREA', '근무지'], ['SALE_PARTNER_SQ', '매출처'], ['PRICE_TXT', '단가']];
var FIELDS = [['CLIENT_NM', '고객사'], ['PRJ_NM', '사업명'], ['GRADE_TXT', '등급·인원', '예: 중급 2 · 고급 1'], ['HEAD_CNT', '정원(명)', '', 'number'], ['START_DT', '투입 시작', '', 'date'], ['END_DT', '투입 종료', '비우면 미정', 'date'],
	['PERIOD_TXT', '기간 원문'], ['WORK_AREA', '근무지'], ['PRICE_TXT', '단가 🔒'], ['SKILLS', '요구 기술', '쉼표로'], ['PREFER', '우대'], ['SALE_PARTNER_SQ', '매출처', '', 'partner'], ['MGR_NM', '담당'], ['CLOSE_DT', '지원 마감', '', 'date'], ['MEMO', '메모', '', 'textarea']];
// 상세 칸 묶음: 이 칸 앞에 섹션 제목을 넣는다
var SECTION_AT = { CLIENT_NM: '사업 정보', START_DT: '기간·근무지', PRICE_TXT: '조건', SALE_PARTNER_SQ: '거래처·마감' };
var calMonth = null;

function ls(k, v) { try { if (v === undefined) return localStorage.getItem('flt:' + PATH + ':' + k); localStorage.setItem('flt:' + PATH + ':' + k, v); } catch (e) { return null; } }
function today() { var d = new Date(); return d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2); }
function days(a, b) { return Math.round((new Date(b) - new Date(a)) / 86400000); }
function md(d) { return d ? d.substring(5, 10).replace('-', '/') : ''; }
function esc(s) { return $('<div>').text(s == null ? '' : s).html(); }
function notes(list) { if (list && list.length) bootbox.alert({ title: '알림', message: $('<ul class="mb-0 pl-3">').append(list.map(function(n) { return $('<li>').text(n); })) }); }

$(function() {
	VIEW = ls('view') || 'card';
	var w = parseInt(ls('split'), 10);
	if (w > 200) $('#rcSide').css('width', w + 'px');
	$('.rc-views').on('click', 'button', function() { VIEW = $(this).data('view'); ls('view', VIEW); render(); });
	$('#rcFind').on('input', render);
	$('#addBtn').on('click', function() { pasteDialog(); });
	grip();
	findBox();
	hrDriveGear('RECRUIT');
	// 투입현황 대기 현황의 「지원 중 모집」 링크(?open=모집번호)는 그 모집 상세를 연다
	load(function() { var m = /[?&]open=(\d+)/.exec(location.search); if (m) detail(m[1]); });
});

function load(after) {
	hrPost('/admin/recruit/listData.do', {}, function(res) {
		D = res.result;
		hrSetCodes(D.codes);
		people();
		render();
		if (after) after();
	});
}

// ── 좌우 너비(보기 저장의 flt: 값으로 계정별 저장) ──
function grip() {
	var $g = $('#rcGrip'), $s = $('#rcSide'), startX, startW;
	function set(w) { w = Math.max(260, Math.min(w, $('.rc-lay').width() - 330)); $s.css('width', w + 'px'); ls('split', Math.round(w)); }
	$g.on('mousedown', function(e) {
		startX = e.pageX; startW = $s.outerWidth(); e.preventDefault();
		$(document).on('mousemove.rcg', function(m) { set(startW - (m.pageX - startX)); }).on('mouseup.rcg', function() { $(document).off('.rcg'); });
	}).on('keydown', function(e) {
		if (e.key === 'ArrowLeft') { set($s.outerWidth() + 30); e.preventDefault(); } else if (e.key === 'ArrowRight') { set($s.outerWidth() - 30); e.preventDefault(); }
	});
}

// ── 계산 ──
function appsOf(sq) { return D.applies.filter(function(a) { return String(a.RECRUIT_SQ) === String(sq); }); }
function profilesOf(staffSq) { return D.profiles.filter(function(p) { return String(p.STAFF_SQ) === String(staffSq); }); }
function staffOf(sq) { return D.staff.filter(function(s) { return String(s.STAFF_SQ) === String(sq); })[0]; }
function partnerName(sq) { var p = D.partners.filter(function(x) { return String(x.PARTNER_SQ) === String(sq); })[0]; return p ? p.PARTNER_NM : ''; }
function missing(r) {
	return MISS.filter(function(m) {
		var v = r[m[0]];
		if (m[0] === 'PRICE_TXT') return v !== '🔒' && (!v || /미정/.test(v));
		return v === null || v === undefined || v === '';
	});
}
// 사람 상태: FUTURE 투입 예정, SOON 철수 임박(30일 안), ACTIVE 투입 중, WAIT 대기
function personState(staffSq) {
	var rows = D.current.filter(function(c) { return String(c.STAFF_SQ) === String(staffSq); }), t = today();
	var fut = rows.filter(function(c) { return c.STATE === 'FUTURE'; })[0];
	if (fut) return { k: 'FUTURE', label: '투입 예정 D-' + days(t, fut.START_DT), row: fut };
	var act = rows.filter(function(c) { return c.STATE === 'ACTIVE'; }).sort(function(a, b) { return String(a.END_DT || '9').localeCompare(String(b.END_DT || '9')); })[0];
	if (act) {
		var left = act.END_DT ? days(t, act.END_DT) : null;
		return left !== null && left <= 30 ? { k: 'SOON', label: '철수 D-' + left, row: act } : { k: 'ACTIVE', label: '투입 중', row: act };
	}
	var last = rows[0], s = staffOf(staffSq), from = last && last.END_DT ? last.END_DT : s && s.JOIN_DT;
	return { k: 'WAIT', label: '대기' + (from ? ' ' + Math.max(0, days(from, t)) + '일' : ''), row: last };
}
function activeAppsOfStaff(staffSq) { return D.applies.filter(function(a) { return String(a.STAFF_SQ) === String(staffSq) && ['DOC', 'INTV_WAIT', 'INTV', 'JOIN_WAIT'].indexOf(a.STEP_CD) >= 0; }); }
function recruitOf(sq) { return D.recruits.filter(function(r) { return String(r.RECRUIT_SQ) === String(sq); })[0]; }

// ── 대기자 패널 ──
function verChips(staffSq) {
	var ps = profilesOf(staffSq);
	if (!ps.length) return $('<span class="rc-pill bad">프로필 없음</span>').attr('title', '인사카드 › 수행이력에서 버전을 저장해야 지원할 수 있어요');
	return $('<span>').append(ps.slice(0, 4).map(function(p) {
		return $('<a class="rc-ver">').addClass(p.VER_KIND).attr({ href: '/admin/recruit/profileWord.do?STAFF_SQ=' + staffSq + '&VER_NO=' + p.VER_NO, title: p.REG_DT + ' · 프로젝트 ' + (p.PRJ_CNT || 0) + '건 · 눌러서 워드 받기' })
			.text((p.VER_KIND === 'EDIT' ? '가필 v' : '순정 v') + p.VER_NO).on('click', function(e) { e.stopPropagation(); });
	}));
}
function people() {
	var cnt = { WAIT: 0, FUTURE: 0, SOON: 0 }, rows = [];
	D.staff.forEach(function(s) {
		var st = personState(s.STAFF_SQ);
		if (cnt[st.k] !== undefined) cnt[st.k]++;
		if (PP_CHK[st.k]) rows.push({ s: s, st: st });
	});
	boChips('#ppChips', [{ k: 'WAIT', name: '대기', n: cnt.WAIT }, { k: 'FUTURE', name: '투입 예정', n: cnt.FUTURE }, { k: 'SOON', name: '철수 임박', n: cnt.SOON }], PP_CHK, people);
	var $b = $('#ppBody').empty();
	rows.sort(function(a, b) { return ['WAIT', 'SOON', 'FUTURE'].indexOf(a.st.k) - ['WAIT', 'SOON', 'FUTURE'].indexOf(b.st.k) || String(a.s.STAFF_NM).localeCompare(b.s.STAFF_NM); });
	rows.forEach(function(x) { $b.append(personRow(x.s, x.st)); });
	if (!rows.length) boEmpty($b, '고른 구분에 해당하는 사람이 없습니다.');
	$('#ppCnt').text(rows.length);
}
function personRow(s, st) {
	var has = profilesOf(s.STAFF_SQ).length > 0, apps = activeAppsOfStaff(s.STAFF_SQ);
	var $tr = $('<tr>').attr({ draggable: has, 'data-staff': s.STAFF_SQ }).toggleClass('off', !has);
	$tr.append($('<td>').append(nameEl(s, has)).append($('<div class="sub">').text([s.POSITION_NM, s.DEPT_NM, s.WISH_LOC ? s.WISH_LOC + ' 희망' : ''].filter(Boolean).join(' · '))));
	$tr.append($('<td>').append($('<span class="rc-pill">').addClass(st.k === 'SOON' ? 'warn' : st.k === 'FUTURE' ? 'FILLED' : '').text(st.label)).append(st.row && st.k !== 'WAIT' ? $('<div class="sub">').text(st.row.CLIENT_NM || '') : ''));
	$tr.append($('<td>').append(verChips(s.STAFF_SQ)));
	$tr.append($('<td>').append(apps.map(function(a) {
		var r = recruitOf(a.RECRUIT_SQ);
		return $('<div class="sub">').append($('<a href="#">').text((r ? r.CLIENT_NM || '(고객사)' : '') + ' · ' + STEP_NM[a.STEP_CD] + (a.INTV_DT && a.STEP_CD === 'INTV' ? ' 🎤' + md(a.INTV_DT) : '')).on('click', function(e) { e.preventDefault(); detail(a.RECRUIT_SQ); }));
	})));
	dragSource($tr, s.STAFF_SQ, has);
	return $tr;
}
// 이름을 누르면 인사카드를 이 화면 위에 띄운다(홈 일정 팝업과 같은 ?embed=1&popup=1 틀). 닫으면 다시 불러와 프로필을 새로 그린다
function nameEl(s, has) {
	var $b = $('<b>').text((has ? '⠿ ' : '🚫 ') + s.STAFF_NM);
	if (!D.canStaff) return $b;
	return $('<button type="button" class="rc-who">').attr('title', has ? '인사카드 열기' : '인사카드 › 수행이력에서 프로필 등록').append($b)
		.on('click', function(e) { e.stopPropagation(); staffPop(s.STAFF_SQ, !has); });
}
function staffPop(sq, career) {
	var $wait = $('<div class="rc-pop-wait" role="status">인사카드 불러오는 중…</div>').appendTo('body');
	var $f = $('<iframe class="rc-pop" title="인사카드">').attr('src', '/admin/staff/openStaffList.do?STAFF_SQ=' + sq + (career ? '&TAB=CAREER' : '') + '&embed=1&popup=1').appendTo('body');
	function done() { $(window).off('message.rcpop'); $f.remove(); $wait.remove(); }
	$(window).off('message.rcpop').on('message.rcpop', function(m) {
		var d = m.originalEvent.data;
		if (!d || !d.boPopup || m.originalEvent.source !== $f[0].contentWindow) return;
		if (d.boPopup === 'open') { $wait.remove(); $f[0].focus(); }
		else if (d.boPopup === 'close') { done(); load(); }
		else if (d.boPopup === 'empty') { done(); bootbox.alert('인사카드를 열 수 없어요(퇴사자이거나 직원관리 권한이 없음).'); }
	});
}
function dragSource($el, staffSq, ok) {
	if (!ok && D.canStaff) { $el.on('click', function() { staffPop(staffSq, true); }); return; }
	if (!ok) { $el.on('click', function() { bootbox.alert('저장된 수행이력 프로필이 없어 지원할 수 없어요. 인사카드 › 수행이력에서 「새 버전으로 저장」을 먼저 해 주세요.'); }); return; }
	$el.attr('draggable', true).on('dragstart', function(e) { e.originalEvent.dataTransfer.setData('text/plain', 'staff:' + staffSq); e.originalEvent.dataTransfer.effectAllowed = 'copy'; });
}
function dropTarget($el, recruitSq) {
	$el.on('dragover', function(e) { if (!dragKind(e)) return; e.preventDefault(); $el.addClass('over'); })
		.on('dragleave drop', function() { $el.removeClass('over'); })
		.on('drop', function(e) {
			var v = e.originalEvent.dataTransfer.getData('text/plain') || '';
			if (v.indexOf('staff:') !== 0) return;
			e.preventDefault();
			applyDialog(recruitSq, v.substring(6));
		});
}
function dragKind(e) { var t = e.originalEvent.dataTransfer.types; return t && [].indexOf.call(t, 'text/plain') >= 0; }

// 전체 직원에서 찾기(투입 중 포함)
function findBox() {
	var $in = $('#ppFind'), $list = $('#ppFindList');
	$in.on('input focus', function() {
		var q = $.trim($in.val());
		$list.empty().prop('hidden', !q);
		if (!q || !D) return;
		D.staff.filter(function(s) { return String(s.STAFF_NM).indexOf(q) >= 0; }).slice(0, 30).forEach(function(s) {
			var st = personState(s.STAFF_SQ), has = profilesOf(s.STAFF_SQ).length > 0;
			var $it = $('<div class="it">').append(nameEl(s, has)).append($('<span class="rc-pill">').toggleClass('FILLED', st.k === 'ACTIVE').text(st.label))
				.append($('<span class="rc-note">').text(st.row && st.k !== 'WAIT' ? (st.row.CLIENT_NM || '') + (st.row.END_DT ? ' · ~' + st.row.END_DT : '') : '')).append($('<div style="width:100%">').append(verChips(s.STAFF_SQ)));
			dragSource($it, s.STAFF_SQ, has);
			$list.append($it);
		});
		if (!$list.children().length) $list.append('<div class="it text-muted">찾는 직원이 없습니다(재직·대기 직원만)</div>');
	});
	$(document).on('click', function(e) { if (!$(e.target).closest('.rc-find').length) $list.prop('hidden', true); });
	$in.on('keydown', function(e) { if (e.key === 'Escape') { $in.val(''); $list.prop('hidden', true); } });
}

// ── 모집 목록 ──
function filtered() {
	var q = $.trim($('#rcFind').val()).toLowerCase();
	return D.recruits.filter(function(r) {
		if (ST_CHK.MISS && !missing(r).length) return false;
		if (!ST_CHK[r.STATUS_CD]) return false;
		return !q || [r.CLIENT_NM, r.PRJ_NM, r.SKILLS, r.WORK_AREA, r.SALE_PARTNER_NM].join(' ').toLowerCase().indexOf(q) >= 0;
	});
}
function render() {
	if (!D) return;
	var cnt = { MISS: 0 };
	D.recruits.forEach(function(r) { cnt[r.STATUS_CD] = (cnt[r.STATUS_CD] || 0) + 1; if (missing(r).length) cnt.MISS++; });
	boChips('#stChips', Object.keys(STATUS).map(function(k) { return { k: k, name: STATUS[k], n: cnt[k] || 0 }; }).concat(['<span class="mx-1 text-muted">|</span>', { k: 'MISS', name: '⚠ 확인 필요만', n: cnt.MISS, cls: 'alert' }]), ST_CHK, render);
	$('.rc-views button').each(function() { $(this).attr('aria-pressed', $(this).data('view') === VIEW); });
	var list = filtered(), $m = $('#rcMain').empty();
	$m.append($('<h3>').text('모집 ' + list.length));
	if (!D.recruits.length) { $m.append('<div class="cal-empty p-4 text-center text-muted">모집이 없습니다. 「+ 모집 등록」에 고객사 요청 원문을 붙여 넣어 등록해 주세요.</div>'); return; }
	({ card: viewCards, table: viewTable, board: viewBoard, cal: viewCal, tl: viewTimeline })[VIEW]($m, list);
}

function gradeLine(r) { return (r.GRADE_TXT || (r.HEAD_CNT ? r.HEAD_CNT + '명' : '')); }
function period(r) { return r.START_DT ? r.START_DT + ' ~ ' + (r.END_DT || '(미정)') : (r.PERIOD_TXT || ''); }
function joinedCnt(r) { return appsOf(r.RECRUIT_SQ).filter(function(a) { return a.STEP_CD === 'JOIN'; }).length; }
function closeLeft(r) { return r.CLOSE_DT ? days(today(), r.CLOSE_DT) : null; }
function stepSummary(r) {
	var c = {};
	appsOf(r.RECRUIT_SQ).forEach(function(a) { if (a.STEP_CD !== 'DROP') c[a.STEP_CD] = (c[a.STEP_CD] || 0) + 1; });
	return STEPS.filter(function(s) { return c[s[0]]; }).map(function(s) { return s[1] + ' ' + c[s[0]]; }).join(' · ');
}
function q(v) { return v === null || v === undefined || v === '' ? $('<span class="rc-q">? 미입력</span>') : document.createTextNode(v); }

function card(r, compact) {
	var miss = missing(r), apps = appsOf(r.RECRUIT_SQ), head = Number(r.HEAD_CNT || 0), joined = joinedCnt(r), left = closeLeft(r);
	var $c = $('<div class="rc-card" tabindex="0" role="button">').attr('data-sq', r.RECRUIT_SQ).toggleClass('miss', miss.length > 0).toggleClass('done', r.STATUS_CD === 'FILLED' || r.STATUS_CD === 'CLOSED');
	var $top = $('<div class="d-flex align-items-center flex-wrap" style="gap:4px">').append($('<span class="rc-pill">').addClass(r.STATUS_CD).text(STATUS[r.STATUS_CD]));
	if (miss.length) $top.append($('<span class="rc-pill warn">').text('⚠ 확인 필요 ' + miss.length).attr('title', miss.map(function(m) { return m[1]; }).join(', ')));
	if (left !== null && r.STATUS_CD !== 'CLOSED') $top.append($('<span class="rc-pill">').toggleClass('bad', left <= 3).text(left >= 0 ? '마감 D-' + left : '마감 지남'));
	$top.append($('<span class="ml-auto rc-note">').text(md(r.REG_D)));
	$c.append($top).append($('<div class="cl">').append(q(r.CLIENT_NM))).append($('<div class="pj">').append(r.PRJ_NM ? document.createTextNode(r.PRJ_NM) : $('<span class="rc-q">사업명 — 못 읽음</span>')));
	if (!compact) {
		var $dl = $('<dl>');
		function row(k, v) { $dl.append($('<dt>').text(k)).append($('<dd>').append(v)); }
		row('등급·인원', $('<b>').append(q(gradeLine(r))));
		row('투입', q(period(r)));
		row('근무지', q(r.WORK_AREA));
		row('단가', r.PRICE_TXT === '🔒' ? '🔒 권한자만' : q(r.PRICE_TXT));
		if (r.SKILLS) row('기술', $('<span>').append(String(r.SKILLS).split(/[,/·]/).filter(function(s) { return $.trim(s); }).map(function(s) { return $('<span class="rc-sk">').text($.trim(s)); })));
		row('매출처', r.SALE_PARTNER_SQ ? document.createTextNode(r.SALE_PARTNER_NM || partnerName(r.SALE_PARTNER_SQ)) : $('<span class="rc-q">').text('? ' + (r.SALE_PARTNER_TXT ? '"' + r.SALE_PARTNER_TXT + '" — 거래처 목록에 없음' : '미입력')));
		if (Number(r.FILE_CNT)) row('첨부', '📎' + r.FILE_CNT);
		$c.append($dl);
	}
	$c.append($('<div class="rc-prog">').append($('<i>').css({ width: (head ? Math.min(100, joined * 100 / head) : 0) + '%', background: r.STATUS_CD === 'FILLED' ? '#2f9e44' : '' })));
	$c.append($('<div class="rc-mini">').append($('<span>').text('지원 ' + apps.filter(function(a) { return a.STEP_CD !== 'DROP'; }).length + ' · 충원 ' + joined + '/' + (head || '?'))).append($('<span>').text(stepSummary(r))));
	apps.filter(function(a) { return a.STEP_CD !== 'DROP'; }).forEach(function(a) {
		$c.append($('<div class="rc-app">').append($('<b>').text(a.STAFF_NM)).append(stepChip(a)));
	});
	$c.append(addBtn(r.RECRUIT_SQ));
	$c.on('click', function(e) { if (!$(e.target).closest('button, a').length) detail(r.RECRUIT_SQ); }).on('keydown', function(e) { if (e.key === 'Enter' && e.target === this) detail(r.RECRUIT_SQ); });
	dropTarget($c, r.RECRUIT_SQ);
	return $c;
}

function viewCards($m, list) {
	var $g = $('<div class="rc-cards">');
	list.forEach(function(r) { $g.append(card(r)); });
	$m.append($g);
	if (!list.length) $m.append('<div class="text-muted p-3">고른 조건에 맞는 모집이 없습니다.</div>');
}
function viewTable($m, list) {
	var $t = $('<table class="table table-sm table-hover" id="rcTable" data-no-card>').append('<thead><tr><th scope="col">상태</th><th scope="col">확인</th><th scope="col">고객사</th><th scope="col">사업명</th><th scope="col">등급·인원</th><th scope="col">투입</th><th scope="col">근무지</th><th scope="col">단가</th><th scope="col">기술</th><th scope="col">매출처</th><th scope="col">지원/충원</th><th scope="col">진행</th><th scope="col">마감</th><th scope="col">등록일</th></tr></thead>');
	var $b = $('<tbody>').appendTo($t);
	list.forEach(function(r) {
		var miss = missing(r), left = closeLeft(r), apps = appsOf(r.RECRUIT_SQ).filter(function(a) { return a.STEP_CD !== 'DROP'; });
		var $tr = $('<tr style="cursor:pointer">').on('click', function(e) { if (!$(e.target).closest('button, a').length) detail(r.RECRUIT_SQ); });
		$tr.append($('<td>').append($('<span class="rc-pill">').addClass(r.STATUS_CD).text(STATUS[r.STATUS_CD])));
		$tr.append($('<td>').append(miss.length ? $('<span class="rc-pill warn">').text('⚠ ' + miss.length) : ''));
		[r.CLIENT_NM, r.PRJ_NM, gradeLine(r), period(r), r.WORK_AREA, r.PRICE_TXT, r.SKILLS, r.SALE_PARTNER_NM || r.SALE_PARTNER_TXT].forEach(function(v) { $tr.append($('<td>').append(q(v))); });
		$tr.append($('<td>').text(apps.length + ' · ' + joinedCnt(r) + '/' + (r.HEAD_CNT || '?')));
		$tr.append($('<td>').append(apps.map(function(a) { return $('<div class="text-nowrap">').append(document.createTextNode(a.STAFF_NM + ' ')).append(stepChip(a)); })).append(addBtn(r.RECRUIT_SQ)));
		$tr.append($('<td>').text(left === null ? '' : left >= 0 ? 'D-' + left : '지남'));
		$tr.append($('<td>').text(r.REG_D || ''));
		dropTarget($tr, r.RECRUIT_SQ);
		$b.append($tr);
	});
	if (!list.length) boEmpty($b, '고른 조건에 맞는 모집이 없습니다.');
	$m.append($('<div class="table-responsive">').append($t));
}
// 상태 보드: 칸 사이로 끌면 모집 상태가 바뀐다
function viewBoard($m, list) {
	var $g = $('<div class="rc-board">');
	Object.keys(STATUS).forEach(function(k) {
		var items = list.filter(function(r) { return r.STATUS_CD === k; });
		var $col = $('<div class="rc-bcol">').append($('<div class="mb-2">').append($('<span class="rc-pill">').addClass(k).text(STATUS[k] + ' ' + items.length)));
		items.forEach(function(r) {
			var $c = card(r, true).attr('draggable', true).on('dragstart', function(e) { e.originalEvent.dataTransfer.setData('text/plain', 'recruit:' + r.RECRUIT_SQ); });
			$col.append($c);
		});
		$col.on('dragover', function(e) { e.preventDefault(); $col.addClass('over'); }).on('dragleave drop', function() { $col.removeClass('over'); }).on('drop', function(e) {
			var v = e.originalEvent.dataTransfer.getData('text/plain') || '';
			if (v.indexOf('recruit:') !== 0) return;
			e.preventDefault();
			hrPost('/admin/recruit/statusData.do', { RECRUIT_SQ: v.substring(8), STATUS_CD: k }, function() { load(); });
		});
		$g.append($col);
	});
	$m.append($('<div class="rc-note mb-2">').text('모집 카드를 옆 칸으로 끌면 상태가 바뀌어요. 대기자를 카드에 놓으면 지원이에요.')).append($('<div class="rc-board-wrap" style="overflow:auto">').append($g));
}
// 달력: 등록·마감·인터뷰·투입 시작
function viewCal($m, list) {
	var base = calMonth || today().substring(0, 7), y = +base.substring(0, 4), mo = +base.substring(5, 7);
	var first = new Date(y, mo - 1, 1), start = new Date(first); start.setDate(1 - ((first.getDay() + 6) % 7));
	var ev = {};
	function add(d, cls, text, sq) { if (!d) return; d = d.substring(0, 10); (ev[d] = ev[d] || []).push({ cls: cls, text: text, sq: sq }); }
	list.forEach(function(r) {
		add(r.REG_D, 'reg', '● ' + (r.CLIENT_NM || '모집') + ' 등록', r.RECRUIT_SQ);
		add(r.CLOSE_DT, 'close', '⏰ ' + (r.CLIENT_NM || '') + ' 마감', r.RECRUIT_SQ);
		add(r.START_DT, 'start', '▶ ' + (r.CLIENT_NM || '') + ' 투입', r.RECRUIT_SQ);
		appsOf(r.RECRUIT_SQ).forEach(function(a) { if (a.INTV_DT && a.STEP_CD !== 'DROP') add(a.INTV_DT, 'intv', '🎤 ' + (r.CLIENT_NM || '') + ' · ' + a.STAFF_NM + ' ' + a.INTV_DT.substring(11, 16), r.RECRUIT_SQ); });
	});
	var $nav = $('<div class="d-flex align-items-center mb-2" style="gap:6px">')
		.append($('<button type="button" class="btn btn-sm btn-outline-secondary" aria-label="이전 달">‹</button>').on('click', function() { var d = new Date(y, mo - 2, 1); calMonth = d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2); render(); }))
		.append($('<b>').text(y + '년 ' + mo + '월'))
		.append($('<button type="button" class="btn btn-sm btn-outline-secondary" aria-label="다음 달">›</button>').on('click', function() { var d = new Date(y, mo, 1); calMonth = d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2); render(); }))
		.append($('<button type="button" class="btn btn-sm btn-link">이번 달</button>').on('click', function() { calMonth = null; render(); }));
	var $t = $('<table class="rc-cal">').append('<thead><tr><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th>토</th><th>일</th></tr></thead>'), $b = $('<tbody>').appendTo($t), t = today();
	for (var w = 0; w < 6; w++) {
		var $tr = $('<tr>');
		for (var i = 0; i < 7; i++) {
			var d = new Date(start); d.setDate(start.getDate() + w * 7 + i);
			var key = d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2);
			var $td = $('<td>').toggleClass('out', d.getMonth() !== mo - 1).toggleClass('today', key === t).append($('<div>').text(d.getDate()));
			(ev[key] || []).forEach(function(e) { $td.append($('<span class="ev">').addClass(e.cls).text(e.text).attr('title', e.text).on('click', function() { detail(e.sq); })); });
			$tr.append($td);
		}
		$b.append($tr);
		if (d.getMonth() !== mo - 1 && w >= 4) break;
	}
	$m.append($nav).append($t);
}
// 타임라인: 이번 달부터 6개월, 모집 투입 기간 막대 + 철수 임박 인원
function viewTimeline($m, list) {
	var t = today(), from = new Date(+t.substring(0, 4), +t.substring(5, 7) - 1, 1), to = new Date(from); to.setMonth(to.getMonth() + 6);
	var span = to - from;
	function pos(d) { return Math.max(0, Math.min(100, (new Date(d) - from) * 100 / span)); }
	var $g = $('<div class="rc-tl">'), $mon = $('<div class="mon">').css('grid-template-columns', 'repeat(6, 1fr)');
	for (var i = 0; i < 6; i++) { var d = new Date(from); d.setMonth(d.getMonth() + i); $mon.append($('<span>').text((d.getMonth() + 1) + '월')); }
	$g.append('<span></span>').append($mon);
	list.forEach(function(r) {
		var $trk = $('<span class="trk">').append($('<i class="now">').css('left', pos(t) + '%'));
		if (r.START_DT) {
			var l = pos(r.START_DT), rr = r.END_DT ? pos(r.END_DT) : 100;
			$trk.append($('<i class="bar">').addClass(r.STATUS_CD).toggleClass('open', !r.END_DT).css({ left: l + '%', width: Math.max(1, rr - l) + '%' }).attr('title', period(r)).on('click', function() { detail(r.RECRUIT_SQ); }));
		}
		var $nm = $('<b class="text-truncate">').text(r.CLIENT_NM || '(고객사)').attr('title', (r.CLIENT_NM || '') + ' ' + (r.PRJ_NM || '')).css('cursor', 'pointer').on('click', function() { detail(r.RECRUIT_SQ); });
		dropTarget($trk, r.RECRUIT_SQ);
		$g.append($nm).append($trk);
	});
	D.staff.forEach(function(s) {
		var st = personState(s.STAFF_SQ);
		if (st.k !== 'SOON' || !st.row || !st.row.END_DT) return;
		var $trk = $('<span class="trk" style="background:none">').append($('<i class="bar pp">').css({ left: 0, width: pos(st.row.END_DT) + '%' }).attr('title', s.STAFF_NM + ' 철수 ' + st.row.END_DT));
		$g.append($('<span class="text-success">').text(s.STAFF_NM + ' 철수')).append($trk);
	});
	$m.append($('<div class="rc-tl-wrap" style="overflow:auto">').append($g)).append('<div class="rc-note mt-2">주황 막대: 모집 투입 기간(점선 끝은 종료 미정) · 초록 얇은 막대: 30일 안에 철수하는 사람</div>');
}

// ── 지원 단계 ──
function stepChip(a) {
	var label = STEP_NM[a.STEP_CD] + (a.STEP_CD === 'INTV' && a.INTV_DT ? ' ' + md(a.INTV_DT) : '') + ' ▾';
	return $('<button type="button" class="rc-step">').addClass(a.STEP_CD).text(label).attr('aria-label', a.STAFF_NM + ' 진행 단계 ' + STEP_NM[a.STEP_CD] + ' 바꾸기').on('click', function(e) {
		e.stopPropagation();
		stepMenu($(this), a);
	});
}
function stepMenu($at, a) {
	$('.rc-menu').remove();
	var $menu = $('<div class="rc-menu" role="menu">');
	STEPS.concat([['DROP', '✕ 탈락·취소']]).forEach(function(s) {
		$menu.append($('<button type="button" role="menuitem">').toggleClass('cur', s[0] === a.STEP_CD).text((s[0] === a.STEP_CD ? '● ' : '') + s[1]).on('click', function() { $menu.remove(); changeStep(a, s[0]); }));
	});
	var o = $at.offset();
	$menu.css({ left: o.left, top: o.top + $at.outerHeight() + 2 }).appendTo('body');
	$menu.find('button').first().focus();
	setTimeout(function() { $(document).one('click', function() { $menu.remove(); }); });
	$menu.on('keydown', function(e) { if (e.key === 'Escape') { $menu.remove(); $at.focus(); } });
}
function stepper(a) {
	var idx = STEPS.map(function(s) { return s[0]; }).indexOf(a.STEP_CD);
	var $s = $('<span class="rc-stepper" role="group">').attr('aria-label', a.STAFF_NM + ' 진행 단계');
	STEPS.forEach(function(s, i) {
		$s.append($('<button type="button">').toggleClass('past', idx > i).toggleClass('now', idx === i).attr('aria-pressed', idx === i)
			.text((idx > i ? '✓ ' : idx === i ? '● ' : '') + s[1] + (s[0] === 'INTV' && a.INTV_DT && idx >= i ? ' ' + md(a.INTV_DT) + ' ' + a.INTV_DT.substring(11, 16) : ''))
			.on('click', function() { if (s[0] !== a.STEP_CD || s[0] === 'INTV' || s[0] === 'JOIN') changeStep(a, s[0]); }));
	});
	return $s;
}
function changeStep(a, step) {
	if (step === 'INTV') return interviewDialog(a);
	if (step === 'JOIN') return joinDialog(a);
	if (step === a.STEP_CD) return;
	function send(del, reason) {
		hrPost('/admin/recruit/stepData.do', { APPLY_SQ: a.APPLY_SQ, STEP_CD: step, DEL_DEPLOY: del ? 'Y' : 'N', REASON: reason || '' }, function(res) { notes(res.result); reload(); });
	}
	function ask(del) {
		if (step !== 'DROP') return send(del);
		bootbox.prompt({ title: a.STAFF_NM + ' 탈락·취소 사유 (선택)', inputType: 'text', callback: function(v) { if (v !== null) send(del, v); } });
	}
	if (a.STEP_CD === 'JOIN' && a.DEPLOY_SQ) {
		bootbox.dialog({ title: '투입확정을 되돌려요', message: '투입현황에 만든 「투입 예정」도 지울까요? 이미 투입일이 지나 투입 중이면 지우지 않아요.', onEscape: true, buttons: {
			cancel: { label: '취소', className: 'btn-sm btn-outline-secondary' },
			keep: { label: '남기고 바꾸기', className: 'btn-sm btn-outline-primary', callback: function() { ask(false); } },
			del: { label: '지우고 바꾸기', className: 'btn-sm btn-danger', callback: function() { ask(true); } } } });
		return;
	}
	ask(false);
}
function reload() { var open = $('#rcDetail').data('sq'); load(function() { if (open) detail(open); }); }

// ── 모집 상세 ──
function detail(sq) {
	hrPost('/admin/recruit/detailData.do', { RECRUIT_SQ: sq }, function(res) {
		// 다시 열 때(저장 뒤 reload)는 애니메이션 없이 바꿔 끼운다: fade 를 빼면 동기로 닫혀 hidden 이 새 팝업보다 먼저 끝나 modal-open 이 지워지지 않는다
		var $old = $('#rcDetailModal'), swap = $old.hasClass('show'), top = $old.scrollTop();
		if (swap) $old.removeClass('fade').modal('hide');
		bootbox.hideAll();
		var r = res.result.recruit, miss = missing(r), apps = appsOf(sq);
		var $f = $('<div id="rcDetail">').data('sq', sq);
		var $head = $('<div class="d-flex align-items-center flex-wrap mb-2" style="gap:6px">');
		var $st = $('<select class="form-control form-control-sm" style="width:auto" aria-label="모집 상태">');
		$.each(STATUS, function(k, v) { $st.append($('<option>').val(k).text(v)); });
		$st.val(r.STATUS_CD).on('change', function() { hrPost('/admin/recruit/statusData.do', { RECRUIT_SQ: sq, STATUS_CD: this.value }, reload); });
		$head.append($st);
		if (miss.length) $head.append($('<span class="rc-pill warn">').text('⚠ 확인 필요 ' + miss.length));
		$head.append($('<span class="rc-note">').text(r.REG_D + ' 등록 · ' + (r.REG_EMPLY_ID || '')));
		$f.append($head);
		var $form = fieldForm(r, miss);
		$f.append($form);
		// 원문: 글자를 끌어 선택하면 넣을 칸을 고른다
		var $raw = $('<div class="rc-raw" tabindex="0">').text(r.RAW_TEXT || '(원문 없음)');
		$f.append($('<div class="rc-sec">').append('<h4>등록 원문 (그대로 보관)</h4>').append($raw).append('<div class="rc-note mt-1">글자를 끌어 선택하면 넣을 칸을 고르는 메뉴가 떠요.</div>'));
		rawPicker($raw, $form);
		// 드라이브 폴더
		var $fold = $('<div class="d-flex align-items-center" style="gap:6px">');
		if (r.FOLDER_ID) $fold.append('📁 ').append($('<a target="_blank" rel="noopener">').attr('href', 'https://drive.google.com/drive/folders/' + r.FOLDER_ID).text('드라이브에서 열기 ↗'));
		else $fold.append('<span class="text-warning">폴더 없음</span>').append($('<button type="button" class="btn btn-sm btn-outline-primary">폴더 만들기</button>').on('click', function() { hrPost('/admin/recruit/folderData.do', { RECRUIT_SQ: sq }, reload); }));
		$f.append($('<div class="rc-sec">').append('<h4>드라이브 폴더</h4>').append($fold));
		// 첨부
		var $files = $('<table class="table table-sm mb-1">'), $fb = $('<tbody>').appendTo($files);
		res.result.files.forEach(function(x) {
			$fb.append($('<tr>').append($('<td>').append($('<a target="_blank" rel="noopener">').attr('href', x.FILE_URL || '#').text('📄 ' + x.FILE_NM)))
				.append($('<td class="rc-note">').text(Math.max(1, Math.round((x.FILE_SIZE || 0) / 1024)) + 'KB · ' + x.REG_DT + ' ' + (x.REG_EMPLY_ID || '')))
				.append($('<td class="text-right">').append($('<button type="button" class="btn btn-sm btn-link text-danger p-0" aria-label="첨부 지우기">🗑</button>').on('click', function() {
					bootbox.confirm(x.FILE_NM + ' 을(를) 지울까요? 드라이브에서는 휴지통으로 가요.', function(ok) { if (ok) hrPost('/admin/recruit/deleteFileData.do', { RECRUIT_SQ: sq, FILE_SQ: x.FILE_SQ }, reload); });
				}))));
		});
		var $up = $('<input type="file" multiple class="d-none">').on('change', function() { uploadFiles(sq, this.files, reload); });
		var $drop = $('<div class="rc-drop-hint" tabindex="0" role="button">📎 여기에 파일을 끌어 놓거나 눌러서 고르기</div>').on('click keydown', function(e) { if (e.type === 'click' || e.key === 'Enter') $up.click(); })
			.on('dragover', function(e) { e.preventDefault(); }).on('drop', function(e) { e.preventDefault(); uploadFiles(sq, e.originalEvent.dataTransfer.files, reload); });
		$f.append($('<div class="rc-sec">').append($('<h4>').text('첨부 ' + res.result.files.length)).append($files).append($drop).append($up));
		// 지원자
		var $ap = $('<div>');
		apps.forEach(function(a) { $ap.append(applyRow(a)); });
		if (!apps.length) $ap.append('<div class="rc-note">아직 지원자가 없어요. 오른쪽 대기자를 이 모집 카드에 끌어 놓으면 지원돼요.</div>');
		var $apDrop = $('<div class="rc-drop-hint">⠿ 대기자를 여기에 끌어 놓아도 지원돼요</div>');
		dropTarget($apDrop, sq);
		$f.append($('<div class="rc-sec">').append($('<h4>').text('지원자 ' + apps.filter(function(a) { return a.STEP_CD !== 'DROP'; }).length)).append($ap).append($apDrop));
		// 이력
		var $log = $('<details class="rc-sec">').append($('<summary class="small font-weight-bold">').text('변경 이력 ' + res.result.logs.length));
		res.result.logs.forEach(function(l) { $log.append($('<div class="small">').text(l.REG_DT + ' · ' + (l.EMPLY_ID || '') + ' · ' + l.SUMMARY)); });
		$f.append($log);
		var $dlg = bootbox.dialog({ title: (r.CLIENT_NM || '(고객사 미입력)') + ' · ' + (r.PRJ_NM || ''), message: $f, size: 'large', onEscape: true, backdrop: true, animate: !swap, buttons: {
			del: { label: '모집 삭제', className: 'btn-sm btn-outline-danger mr-auto', callback: function() {
				bootbox.confirm('이 모집을 지울까요? 드라이브 폴더는 그대로 남아요.', function(ok) { if (ok) hrPost('/admin/recruit/deleteData.do', { RECRUIT_SQ: sq }, function() { bootbox.hideAll(); load(); }); });
				return false;
			} },
			close: { label: '닫기', className: 'btn-sm btn-outline-secondary' },
			save: { label: '저장', className: 'btn-sm btn-primary', callback: function() {
				var data = $.extend({ RECRUIT_SQ: sq }, formData($form));
				hrPost('/admin/recruit/saveData.do', data, function(res2) { notes(res2.result.notes); hrToast('저장했습니다.'); reload(); });
				return false;
			} } } }).attr('id', 'rcDetailModal');
		if (swap) $dlg.scrollTop(top);
	});
}
function applyRow(a) {
	var $r = $('<div class="d-flex align-items-center flex-wrap mb-2" style="gap:8px">').toggleClass('text-muted', a.STEP_CD === 'DROP');
	$r.append($('<b style="min-width:56px">').text(a.STAFF_NM));
	$r.append($('<span class="rc-ver">').addClass(String(a.VER_LABEL || '').indexOf('가필') === 0 ? 'EDIT' : '').text(a.VER_LABEL || '-'));
	if (a.STEP_CD === 'DROP') $r.append($('<span class="rc-step DROP">').text('탈락·취소')).append($('<span class="rc-note">').text(a.DROP_REASON || ''))
		.append($('<button type="button" class="btn btn-sm btn-link p-0">되살리기</button>').on('click', function() { changeStep(a, 'DOC'); }));
	else $r.append(stepper(a)).append($('<button type="button" class="btn btn-sm btn-link text-danger p-0">✕ 탈락·취소</button>').on('click', function() { changeStep(a, 'DROP'); }));
	if (a.FILE_ID) $r.append($('<a target="_blank" rel="noopener" title="모집 폴더에 저장된 프로필 워드">').attr('href', 'https://drive.google.com/file/d/' + a.FILE_ID + '/view').text('📄 ' + (a.FILE_NM || '워드')));
	else $r.append($('<button type="button" class="btn btn-sm btn-outline-warning py-0">📄 드라이브에 다시 저장</button>').on('click', function() { hrPost('/admin/recruit/wordData.do', { APPLY_SQ: a.APPLY_SQ }, reload); }));
	if (a.INTV_DT && a.STEP_CD !== 'DROP') $r.append($('<span class="rc-note">').text('🎤 ' + a.INTV_DT + ' · ' + (WAY[a.INTV_WAY] || '') + (a.INTV_PLACE ? ' · ' + a.INTV_PLACE : '')));
	if (a.DEPLOY_SQ) $r.append($('<a href="/admin/deploy/openDeployList.do" target="_blank" rel="noopener">투입현황 보기 ↗</a>'));
	if (a.DRAFT && a.STEP_CD === 'JOIN_WAIT') $r.append($('<button type="button" class="btn btn-sm btn-link p-0">투입확정 임시 저장 이어서 ›</button>').on('click', function() { joinDialog(a); }));
	return $r;
}

// 칸 입력 폼(상세·등록 공통). 못 읽은 칸은 주황
function fieldForm(r, miss) {
	var missKeys = (miss || []).map(function(m) { return m[0]; }), $k = $('<div class="rc-kv">');
	FIELDS.forEach(function(f) {
		var id = 'rf_' + f[0], v = r[f[0]], $c;
		if (SECTION_AT[f[0]]) $k.append($('<div class="hr-section rc-sec">').text(SECTION_AT[f[0]]));
		if (f[0] === 'PRICE_TXT' && !D.canPay) { $k.append($('<label>').text('단가')).append($('<span class="text-muted">').text('🔒 급여 권한자만 보고 고쳐요')); return; }
		if (f[3] === 'partner') {
			$c = $('<select class="form-control form-control-sm">').append('<option value="">(고르기)</option>');
			D.partners.filter(function(p) { return p.USE_YN === 'Y' && p.SALE_YN !== 'N'; }).forEach(function(p) { $c.append($('<option>').val(p.PARTNER_SQ).text(p.PARTNER_NM)); });
			$c.val(v || '');
			var $wrap = $('<div class="d-flex align-items-center flex-wrap" style="gap:6px">').append($c.css('width', 'auto').attr({ id: id, name: f[0] }));
			if (r.SALE_PARTNER_TXT && !v) $wrap.append($('<span class="rc-q small">').text('원문: "' + r.SALE_PARTNER_TXT + '" — 목록에 없음'));
			$wrap.append('<a href="/admin/partner/openPartnerList.do" target="_blank" rel="noopener" class="small">+ 새 거래처로 등록 ↗</a>');
			$wrap.append($('<input type="hidden" name="SALE_PARTNER_TXT">').val(r.SALE_PARTNER_TXT || ''));
			$k.append($('<label>').attr('for', id).toggleClass('q', missKeys.indexOf(f[0]) >= 0).text(f[1])).append($wrap);
			return;
		}
		$c = f[3] === 'textarea' ? $('<textarea rows="2" class="form-control form-control-sm">') : $('<input class="form-control form-control-sm">').attr('type', f[3] || 'text');
		$c.attr({ id: id, name: f[0], placeholder: f[2] || '' }).val(v == null ? '' : v);
		$k.append($('<label>').attr('for', id).toggleClass('q', missKeys.indexOf(f[0]) >= 0).text(f[1])).append($c);
	});
	return $k;
}
function formData($form) {
	var d = {};
	$form.find('[name]').each(function() { d[this.name] = $.trim($(this).val()); });
	return d;
}
// 원문에서 고른 글자를 칸에 넣는 작은 메뉴
function rawPicker($raw, $form) {
	$raw.on('mouseup keyup', function() {
		var sel = window.getSelection ? String(window.getSelection()) : '';
		$('.rc-menu').remove();
		sel = $.trim(sel);
		if (!sel || sel.length > 300) return;
		var $menu = $('<div class="rc-menu" role="menu">').append($('<div class="rc-note px-2">').text('"' + sel.substring(0, 20) + '" 넣을 칸'));
		FIELDS.forEach(function(f) {
			var $in = $form.find('[name=' + f[0] + ']');
			if (!$in.length || $in.is('select') || $in.attr('type') === 'hidden') return;
			$menu.append($('<button type="button" role="menuitem">').text(f[1]).on('click', function() {
				var v = sel;
				if ($in.attr('type') === 'date') { var m = sel.match(/(\d{4})\D+(\d{1,2})\D+(\d{1,2})/); if (!m) { bootbox.alert('날짜 칸에는 2026-12-01 같은 날짜를 골라 주세요.'); return; } v = m[1] + '-' + ('0' + m[2]).slice(-2) + '-' + ('0' + m[3]).slice(-2); }
				$in.val(v).addClass('is-valid').closest('.rc-kv').find('label[for=' + $in.attr('id') + ']').removeClass('q');
				$menu.remove();
			}));
		});
		var rect = window.getSelection().getRangeAt(0).getBoundingClientRect();
		$menu.css({ left: rect.left + window.scrollX, top: rect.bottom + window.scrollY + 4 }).appendTo('body');
		setTimeout(function() { $(document).one('mousedown', function(e) { if (!$(e.target).closest('.rc-menu').length) $menu.remove(); }); });
	});
}
function uploadFiles(sq, files, done) {
	files = [].slice.call(files || []);
	(function next(i) {
		if (i >= files.length) { if (done) done(); return; }
		var fd = new FormData();
		fd.append('RECRUIT_SQ', sq);
		fd.append('file', files[i]);
		hrToast(files[i].name + ' 올리는 중…');
		$.ajax({ url: '/admin/recruit/uploadData.do', type: 'POST', data: fd, processData: false, contentType: false }).done(function(res) {
			if (res.error) { if (res.error.indexOf('[연동 필요:') !== 0) bootbox.alert(files[i].name + ': ' + res.error); }
			next(i + 1);
		}).fail(function() { next(i + 1); });
	})(0);
}

// ── + 모집 등록(원문 붙여 넣기) ──
function pasteDialog() {
	var $f = $('<div>'), $ta = $('<textarea class="form-control" rows="7" aria-label="원문 붙여 넣기" placeholder="메일·카톡·문서 원문을 그대로 붙여 넣어 주세요.&#10;예) [모집] 신한금융그룹 책무이행시스템 초급 1명&#10;기간: 12월 초 ~ 6개월&#10;근무지: 을지로 상주">');
	var $res = $('<div class="mt-2 p-2" style="border:1px dashed #bac8ff;border-radius:8px;background:#f8f9ff">').append('<div class="rc-note">붙여 넣으면 바로 읽어서 아래에 채워요. 고쳐서 저장하면 돼요.</div>');
	var $files = $('<input type="file" multiple class="form-control-file form-control-sm" aria-label="첨부 파일">'), $form = null, timer;
	$f.append('<div class="small font-weight-bold mb-1">원문 붙여 넣기</div>').append($ta).append($res)
		.append($('<div class="mt-2 small">').append('<b>첨부</b> ').append($files).append('<div class="rc-note">저장한 뒤 모집 드라이브 폴더의 「첨부」에 올라가요.</div>'));
	function parse() {
		hrPost('/admin/recruit/parseData.do', { RAW_TEXT: $ta.val() }, function(res) {
			var r = res.result, miss = missing(r);
			$form = fieldForm(r, miss);
			$res.empty().append($('<div class="small font-weight-bold mb-2">').text('읽은 결과' + (miss.length ? ' · ⚠ 못 읽은 칸 ' + miss.length + ' (주황, 그대로 저장해도 돼요)' : ''))).append($form);
		});
	}
	$ta.on('input', function() { clearTimeout(timer); timer = setTimeout(parse, 400); });
	bootbox.dialog({ title: '+ 모집 등록', message: $f, size: 'large', onEscape: true, buttons: {
		cancel: { label: '취소', className: 'btn-sm btn-outline-secondary' },
		ok: { label: '등록 · 드라이브 폴더 만들기', className: 'btn-sm btn-primary', callback: function() {
			if (!$.trim($ta.val())) { $ta.focus(); return false; }
			var data = $.extend({ RAW_TEXT: $ta.val() }, $form ? formData($form) : {});
			hrPost('/admin/recruit/saveData.do', data, function(res) {
				var sq = res.result.RECRUIT_SQ, files = $files[0].files;
				bootbox.hideAll();
				notes(res.result.notes);
				uploadFiles(sq, files, function() { load(function() { detail(sq); }); });
			});
			return false;
		} } } }).on('shown.bs.modal', function() { $ta.focus(); });
}

// ── 「＋ 지원자 추가」: 끌어 놓기 대신 대기자 패널과 같은 사람 중에서 골라 applyDialog 로 ──
function addBtn(recruitSq) {
	return $('<button type="button" class="rc-add">＋ 지원자 추가</button>').on('click', function(e) { e.stopPropagation(); pickApplicant(recruitSq); });
}
function pickApplicant(recruitSq) {
	var applied = appsOf(recruitSq).map(function(a) { return String(a.STAFF_SQ); });
	var $find = $('<input type="search" class="form-control form-control-sm mb-2" placeholder="이름 찾기 (비우면 대기자만)" aria-label="지원자 이름 찾기">'), $list = $('<div style="max-height:55vh;overflow:auto">');
	var dlg = bootbox.dialog({ title: '지원자 고르기', message: $('<div>').append($find).append($list), onEscape: true, buttons: { cancel: { label: '닫기', className: 'btn-secondary' } } });
	function paint() {
		var q = $.trim($find.val());
		var rows = D.staff.filter(function(s) { return applied.indexOf(String(s.STAFF_SQ)) < 0 && (q ? String(s.STAFF_NM).indexOf(q) >= 0 : PP_CHK[personState(s.STAFF_SQ).k]); });
		$list.empty();
		rows.slice(0, 50).forEach(function(s) {
			var st = personState(s.STAFF_SQ), has = profilesOf(s.STAFF_SQ).length > 0;
			$list.append($('<button type="button" class="rc-pick">').prop('disabled', !has).append($('<b>').text((has ? '' : '🚫 ') + s.STAFF_NM))
				.append($('<span class="rc-pill">').addClass(st.k === 'SOON' ? 'warn' : st.k === 'FUTURE' ? 'FILLED' : '').text(st.label))
				.append($('<span class="rc-note">').text(has ? [s.POSITION_NM, s.DEPT_NM].filter(Boolean).join(' · ') : '프로필 없음'))
				.on('click', function() { /* 앞 창이 다 닫힌 뒤 열어야 body.modal-open 이 안 지워져 스크롤된다 */ dlg.one('hidden.bs.modal', function() { applyDialog(recruitSq, s.STAFF_SQ); }).modal('hide'); }));
		});
		if (!rows.length) $list.append('<div class="text-muted p-2">고를 사람이 없습니다.</div>');
	}
	$find.on('input', paint);
	paint();
}

// ── 지원 창 ──
function applyDialog(recruitSq, staffSq) {
	var r = recruitOf(recruitSq), s = staffOf(staffSq), ps = profilesOf(staffSq), st = personState(staffSq);
	if (!r || !s) return;
	if (appsOf(recruitSq).some(function(a) { return String(a.STAFF_SQ) === String(staffSq); })) { bootbox.alert(s.STAFF_NM + ' 님은 이미 이 모집에 지원했어요.'); return; }
	if (!ps.length) { bootbox.alert('저장된 수행이력 프로필이 없어 지원할 수 없어요. 인사카드 › 수행이력에서 버전을 저장해 주세요.'); return; }
	var $f = $('<div>'), pick = String(ps[0].VER_NO);
	if (st.k === 'ACTIVE' || st.k === 'SOON') $f.append($('<div class="alert alert-warning py-1 px-2 small">').text('현재 ' + (st.row.CLIENT_NM || '') + ' 투입 중' + (st.row.END_DT ? '(~' + st.row.END_DT + ')' : '') + '이에요. 그래도 지원할까요?'));
	if (st.k === 'FUTURE') $f.append($('<div class="alert alert-info py-1 px-2 small">').text((st.row.CLIENT_NM || '') + ' 투입 예정(' + st.row.START_DT + ')인 사람이에요.'));
	$f.append('<div class="small mb-1">함께 보낼 수행이력 프로필</div>');
	function opt(val, html, sub, preview) {
		var $o = $('<div class="rc-opt" role="radio" tabindex="0">').attr('aria-checked', pick === val).toggleClass('on', pick === val).append($('<b>').text(html)).append($('<span class="rc-note">').text(sub));
		if (preview) $o.append($('<a class="ml-auto small">').attr('href', preview).text('미리보기(워드)').on('click', function(e) { e.stopPropagation(); }));
		$o.on('click keydown', function(e) { if (e.type === 'keydown' && e.key !== 'Enter' && e.key !== ' ') return; e.preventDefault(); pick = val; $f.find('.rc-opt').removeClass('on').attr('aria-checked', false); $o.addClass('on').attr('aria-checked', true); paintName(); });
		return $o;
	}
	ps.forEach(function(p, i) { $f.append(opt(String(p.VER_NO), (p.VER_KIND === 'EDIT' ? '가필 v' : '순정 v') + p.VER_NO, p.REG_DT + ' · 프로젝트 ' + (p.PRJ_CNT || 0) + '건' + (i === 0 ? ' · 최신' : ''), '/admin/recruit/profileWord.do?STAFF_SQ=' + staffSq + '&VER_NO=' + p.VER_NO)); });
	$f.append(opt('GEN', '✨ 이 모집에 맞춰 가필 새로 생성', r.SKILLS ? '요구 기술(' + r.SKILLS + ') 순으로 정리해 새 가필 버전을 만들어요' : '요구 기술이 비어 있어 최근 순으로 만들어요'));
	var $name = $('<div class="rc-note mt-2">');
	function paintName() {
		var p = ps.filter(function(x) { return String(x.VER_NO) === pick; })[0];
		$name.text('📁 …/' + (r.CLIENT_NM || '') + '_' + (r.PRJ_NM || '') + ' / ' + s.STAFF_NM + '_수행이력_' + (pick === 'GEN' ? '가필v(새 번호)' : (p.VER_KIND === 'EDIT' ? '가필v' : '순정v') + p.VER_NO) + '.docx');
	}
	paintName();
	$f.append($name);
	bootbox.dialog({ title: s.STAFF_NM + ' → ' + (r.CLIENT_NM || '모집') + ' 지원', message: $f, onEscape: true, buttons: {
		cancel: { label: '취소', className: 'btn-sm btn-outline-secondary' },
		ok: { label: '지원 · 드라이브에 저장', className: 'btn-sm btn-primary', callback: function() {
			hrPost('/admin/recruit/applyData.do', { RECRUIT_SQ: recruitSq, STAFF_SQ: staffSq, VER: pick }, function(res) { bootbox.hideAll(); notes(res.result.notes); hrToast(s.STAFF_NM + ' 지원을 등록했어요.'); load(); });
			return false;
		} } } });
}

// ── 인터뷰 일정 ──
function interviewDialog(a) {
	var r = recruitOf(a.RECRUIT_SQ) || {}, cur = a.INTV_DT || '', way = a.INTV_WAY || 'FACE';
	var $d = $('<input type="date" class="form-control form-control-sm" id="ivD">').val(cur ? cur.substring(0, 10) : '');
	var $s = $('<input type="time" class="form-control form-control-sm" id="ivS" step="600">').val(cur ? cur.substring(11, 16) : '14:00');
	var $e = $('<input type="time" class="form-control form-control-sm" id="ivE" step="600" aria-label="끝 시각">').val(a.INTV_END_DT ? a.INTV_END_DT.substring(11, 16) : '');
	var $w = $('<span role="group" aria-label="방식">');
	$.each(WAY, function(k, v) { $w.append($('<button type="button" class="rc-wayb">').attr('aria-pressed', k === way).text(v).on('click', function() { way = k; $w.find('button').attr('aria-pressed', false); $(this).attr('aria-pressed', true); })); });
	var $p = $('<input class="form-control form-control-sm" id="ivP" maxlength="300">').val(a.INTV_PLACE || r.WORK_AREA || '');
	var $with = $('<input class="form-control form-control-sm" id="ivW" maxlength="200" placeholder="선택">').val(a.INTV_WITH || '');
	var $k = $('<div class="rc-kv">').append('<label for="ivD">일시</label>').append($('<div class="d-flex align-items-center" style="gap:4px">').append($d).append($s).append('~').append($e))
		.append('<label>방식</label>').append($w).append('<label for="ivP">장소</label>').append($p).append('<label for="ivW">동행</label>').append($with)
		.append('<label>알림</label>').append('<span class="small">✉ 저장하면 본인 회사 메일로 자동 발송 · 바꾸거나 취소해도 다시 보내요</span>');
	bootbox.dialog({ title: '🎤 ' + a.STAFF_NM + ' · ' + (r.CLIENT_NM || '') + ' 인터뷰 일정', message: $k, onEscape: true, buttons: {
		later: { label: '나중에', className: 'btn-sm btn-outline-secondary', callback: function() {
			if (a.STEP_CD === 'DOC') hrPost('/admin/recruit/stepData.do', { APPLY_SQ: a.APPLY_SQ, STEP_CD: 'INTV_WAIT' }, reload); // 일정을 비우면 인터뷰대기에 머문다
		} },
		ok: { label: '일정 저장', className: 'btn-sm btn-primary', callback: function() {
			if (!$d.val() || !$s.val()) { bootbox.alert('날짜와 시작 시각을 넣어 주세요.'); return false; }
			hrPost('/admin/recruit/interviewData.do', { APPLY_SQ: a.APPLY_SQ, INTV_DT: $d.val() + ' ' + $s.val(), INTV_END_DT: $e.val() ? $d.val() + ' ' + $e.val() : '', INTV_WAY: way, INTV_PLACE: $p.val(), INTV_WITH: $with.val() },
				function(res) { bootbox.hideAll(); notes(res.result); reload(); });
			return false;
		} } } });
}

// ── 투입확정(항상 확인·추가 입력) ──
function joinDialog(a) {
	var r = recruitOf(a.RECRUIT_SQ) || {}, draft = {};
	try { draft = JSON.parse(a.DRAFT || '{}') || {}; } catch (e) { draft = {}; }
	var st = personState(a.STAFF_SQ), last = st.row || {};
	var grade = hrAllCodes('HR_DEPLOY_GRADE').filter(function(c) { return String(r.GRADE_TXT || '').indexOf(c.NM) === 0; })[0];
	function v(k, def) { return draft[k] !== undefined && draft[k] !== '' ? draft[k] : def; }
	function partnerSel(name, val, kind) {
		var $s = $('<select class="form-control form-control-sm">').attr({ name: name, id: 'jn_' + name }).append('<option value=""></option>');
		D.partners.filter(function(p) { return p.USE_YN === 'Y' && p[kind] !== 'N'; }).forEach(function(p) { $s.append($('<option>').val(p.PARTNER_SQ).text(p.PARTNER_NM)); });
		return $s.val(val || '');
	}
	function inp(name, val, type) { return $('<input class="form-control form-control-sm">').attr({ name: name, id: 'jn_' + name, type: type || 'text' }).val(val == null ? '' : val); }
	var $k1 = $('<div class="rc-kv">')
		.append('<label for="jn_CLIENT_NM">고객사</label>').append(inp('CLIENT_NM', v('CLIENT_NM', r.CLIENT_NM)))
		.append('<label for="jn_PRJ_NM">프로젝트</label>').append(inp('PRJ_NM', v('PRJ_NM', r.PRJ_NM)))
		.append('<label for="jn_GRADE_CD">등급</label>').append(hrControl({ code: 'HR_DEPLOY_GRADE' }, v('GRADE_CD', grade ? grade.CD : '')).attr({ name: 'GRADE_CD', id: 'jn_GRADE_CD' }))
		.append('<label for="jn_SALE_PARTNER_SQ">매출처</label>').append(partnerSel('SALE_PARTNER_SQ', v('SALE_PARTNER_SQ', r.SALE_PARTNER_SQ), 'SALE_YN'))
		.append('<label for="jn_WORK_AREA">근무지역</label>').append(inp('WORK_AREA', v('WORK_AREA', r.WORK_AREA)))
		.append('<label for="jn_START_DT">투입일 *</label>').append($('<div class="d-flex align-items-center" style="gap:4px">').append(inp('START_DT', v('START_DT', r.START_DT), 'date')).append('~').append(inp('END_DT', v('END_DT', r.END_DT), 'date').attr('aria-label', '철수일')));
	var way = v('WORK_WAY', '상주'), $way = $('<span role="group" aria-label="근무 방식">');
	['상주', '재택', '혼합'].forEach(function(w) { $way.append($('<button type="button" class="rc-wayb">').attr('aria-pressed', w === way).text(w).on('click', function() { way = w; $way.find('button').attr('aria-pressed', false); $(this).attr('aria-pressed', true); })); });
	var $k2 = $('<div class="rc-kv">')
		.append('<label for="jn_EMP_TYPE_CD">형태 *</label>').append($('<div class="d-flex align-items-center" style="gap:6px">').append(hrControl({ code: 'HR_EMP_TYPE' }, v('EMP_TYPE_CD', last.EMP_TYPE_CD || '')).attr({ name: 'EMP_TYPE_CD', id: 'jn_EMP_TYPE_CD' }).css('width', 'auto')).append(last.EMP_TYPE_CD ? '<span class="rc-note">지난 투입 값 제안</span>' : ''))
		.append('<label for="jn_BUY_PARTNER_SQ">매입처</label>').append($('<div class="d-flex align-items-center" style="gap:6px">').append(partnerSel('BUY_PARTNER_SQ', v('BUY_PARTNER_SQ', last.BUY_PARTNER_SQ), 'BUY_YN').css('width', 'auto')).append('<span class="rc-note">프리·외주일 때</span>'));
	if (D.canPay) {
		$k2.append('<label for="jn_SALE_PRICE">매출단가 🔒</label>').append($('<div class="d-flex align-items-center" style="gap:6px">').append(inp('SALE_PRICE', v('SALE_PRICE', '')).attr('inputmode', 'numeric').css('width', '160px')).append($('<span class="rc-note">').text(r.PRICE_TXT ? "모집 단가 '" + r.PRICE_TXT + "' 참고" : '')))
			.append('<label for="jn_COST_PRICE">계약단가 🔒</label>').append($('<div class="d-flex align-items-center" style="gap:6px">').append(inp('COST_PRICE', v('COST_PRICE', '')).attr('inputmode', 'numeric').css('width', '160px')).append($('<span class="rc-note">').text(last.COST_PRICE ? '지난 투입 ' + Number(last.COST_PRICE).toLocaleString() : '')));
	}
	$k2.append('<label>근무 방식</label>').append($way).append('<label for="jn_MEMO">메모</label>').append(inp('MEMO', v('MEMO', '')).attr('placeholder', '계약 조건·특이사항'));
	var $f = $('<div>').append('<div class="small mb-2">투입현황에 <b>투입 예정</b>으로 등록하기 전에 확인·추가 입력을 받아요.</div>')
		.append('<div class="small font-weight-bold mb-1">① 모집에서 채운 값 <span class="rc-note font-weight-normal">— 확인만, 고쳐도 돼요</span></div>').append($k1)
		.append('<div class="small font-weight-bold mt-3 mb-1" style="color:#e67700">② 추가 입력 <span class="rc-note font-weight-normal">— 모집 정보로는 정해지지 않는 값</span></div>').append($('<div class="rc-join2">').append($k2))
		.append($('<div class="rc-note mt-1">').text('* 는 꼭 입력. ' + (D.canPay ? '🔒 단가는 급여 권한자에게만 보여요.' : '단가는 급여 권한자만 넣을 수 있어 비워 둔 채 등록돼요(투입현황에서 권한자가 넣어요).')));
	function data(draftYn) {
		var d = { APPLY_SQ: a.APPLY_SQ, DRAFT: draftYn ? 'Y' : 'N', WORK_WAY: way };
		$f.find('[name]').each(function() { d[this.name] = $.trim($(this).val()); });
		if (d.SALE_PRICE) d.SALE_PRICE = d.SALE_PRICE.replace(/[^\d]/g, '');
		if (d.COST_PRICE) d.COST_PRICE = d.COST_PRICE.replace(/[^\d]/g, '');
		return d;
	}
	bootbox.dialog({ title: '✅ ' + a.STAFF_NM + ' 투입확정', message: $f, size: 'large', onEscape: true, buttons: {
		cancel: { label: '취소', className: 'btn-sm btn-outline-secondary' },
		draft: { label: '임시 저장', className: 'btn-sm btn-outline-primary', callback: function() { hrPost('/admin/recruit/joinData.do', data(true), function() { bootbox.hideAll(); hrToast('임시 저장했어요(투입대기).'); reload(); }); return false; } },
		ok: { label: '투입확정 · 투입 예정 등록', className: 'btn-sm btn-primary', callback: function() {
			var d = data(false);
			if (!d.EMP_TYPE_CD || !d.START_DT) { bootbox.alert('형태와 투입일을 넣어 주세요.'); return false; }
			hrPost('/admin/recruit/joinData.do', d, function(res) {
				bootbox.hideAll();
				hrToast(a.STAFF_NM + ' 투입확정 · 투입현황에 투입 예정으로 등록했어요.');
				var others = res.result.others || [];
				if (!others.length) return reload();
				bootbox.confirm({ title: '다른 모집 ' + others.length + '건 진행 중', message: $('<div>').append('<p class="mb-1">같은 사람이 다른 모집에서도 진행 중이에요. 모두 취소할까요?</p>').append($('<ul class="mb-0">').append(others.map(function(o) { return $('<li>').text((o.CLIENT_NM || '') + ' ' + (o.PRJ_NM || '') + ' · ' + STEP_NM[o.STEP_CD]); }))),
					buttons: { confirm: { label: '모두 취소', className: 'btn-sm btn-danger' }, cancel: { label: '그대로 두기', className: 'btn-sm btn-outline-secondary' } },
					callback: function(yes) {
						if (!yes) return reload();
						(function next(i) { if (i >= others.length) return reload(); hrPost('/admin/recruit/stepData.do', { APPLY_SQ: others[i].APPLY_SQ, STEP_CD: 'DROP', REASON: '다른 모집 투입확정' }, function() { next(i + 1); }, function() { next(i + 1); }); })(0);
					} });
			});
			return false;
		} } } });
}

</script>
</body>
</html>
