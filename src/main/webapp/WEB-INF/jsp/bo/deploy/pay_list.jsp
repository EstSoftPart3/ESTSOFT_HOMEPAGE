<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/deploy/deploy_common.jspf"%>
<style>
	/* 펼치는 묶음 색: 수당 청록, 공제 주황, 손익 보라. 버튼·색 띠·칸이 같은 색이다 */
	#lHead th, #lBody td { white-space: nowrap; }
	.pl-ledger .x-allow, .pl-ledger .x-ded, .pl-ledger .x-pl { display: none; }
	.pl-ledger.show-allow .x-allow, .pl-ledger.show-ded .x-ded, .pl-ledger.show-pl .x-pl { display: table-cell; }
	.pl-ledger.show-pl .pl-stub { display: none; }
	.pl-ledger .x-allow, .pl-ledger .c-allow { background: #dff5f3 !important; }
	.pl-ledger .x-ded, .pl-ledger .c-ded { background: #fdeadb !important; }
	.pl-ledger .x-pl, .pl-ledger .pl-stub { background: #efe6fa !important; }
	.pl-ledger .pl-stub { min-width: 44px; padding: 0; }
	.pl-bands th { background: #fff !important; border: 0 !important; padding: 0 !important; }
	.pl-bands th.band { color: #fff; font-size: 11.5px; text-align: center; padding: 3px 6px !important; cursor: pointer; }
	.pl-bands th.band:focus { outline: 2px solid #16d5ff; outline-offset: -2px; }
	.pl-bands th.allow { background: #0e7c86 !important; } .pl-bands th.ded { background: #b4531a !important; } .pl-bands th.pl { background: #6b3fa0 !important; }
	.btn.t-allow { border-color: #0e7c86; color: #0e7c86; font-weight: 700; } .show-allow .btn.t-allow { background: #0e7c86; color: #fff; }
	.btn.t-ded { border-color: #b4531a; color: #b4531a; font-weight: 700; } .show-ded .btn.t-ded { background: #b4531a; color: #fff; }
	.btn.t-pl { border-color: #6b3fa0; color: #6b3fa0; font-weight: 700; } .show-pl .btn.t-pl { background: #6b3fa0; color: #fff; }
	.pl-manual { background: #fff8e3 !important; }
	.pl-split { display: grid; grid-template-columns: 210px minmax(0, 1fr); gap: 12px; align-items: start; }
	.pl-people { max-height: 75vh; overflow-y: auto; }
	.pl-people button { display: flex; justify-content: space-between; width: 100%; border: 0; border-bottom: 1px solid rgba(17,17,17,.06); background: #fff; padding: 7px 12px; text-align: left; }
	.pl-people button.on { background: #dff3f9; font-weight: 700; }
	.pl-two { display: grid; grid-template-columns: 1fr 1fr; }
	.pl-two > div + div { border-left: 1px solid rgba(17,17,17,.08); }
	.pl-line { display: flex; justify-content: space-between; align-items: center; padding: 3px 14px; font-variant-numeric: tabular-nums; min-height: 28px; }
	.pl-line.h { background: #fafbfc; font-weight: 700; border-bottom: 1px solid rgba(17,17,17,.06); }
	.pl-line.t { font-weight: 700; border-top: 1px solid rgba(17,17,17,.08); background: #f6f8fa; }
	.pl-line .hr-cell { min-width: 110px; text-align: right; }
	.pl-netbar { display: flex; justify-content: space-between; align-items: center; padding: 10px 14px; background: #111; color: #fff; font-weight: 700; }
	.pl-netbar b { font-size: 19px; font-variant-numeric: tabular-nums; }
	@media (max-width: 900px) { .pl-split, .pl-two { grid-template-columns: 1fr; } }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header d-flex flex-wrap align-items-center" style="gap:8px">
					<h3 class="card-title bTitle"><b>급여관리</b></h3>
					<div class="btn-group btn-group-sm" role="group" aria-label="보기">
						<button type="button" class="btn btn-outline-secondary active" data-view="ledger">월 급여대장</button>
						<button type="button" class="btn btn-outline-secondary" data-view="staff">직원별</button>
					</div>
					<div class="ml-auto d-flex align-items-center" style="gap:6px">
						<button type="button" class="btn btn-sm btn-outline-secondary" id="prevYm" aria-label="이전 달">◀</button>
						<input type="month" id="ym" class="form-control form-control-sm" style="width:150px" aria-label="급여 월">
						<button type="button" class="btn btn-sm btn-outline-secondary" id="nextYm" aria-label="다음 달">▶</button>
						<span class="dp-pill" id="status"></span>
						<button type="button" class="btn btn-sm btn-outline-secondary" id="btnImport">공제 불러오기</button>
						<button type="button" class="btn btn-sm btn-primary" id="btnClose"></button>
					</div>
				</div>
				<div class="card-body">
					<div class="dp-kpis" id="kpis"></div>
					<div id="ledgerView">
						<div class="cal-panel pl-ledger" id="ledger">
							<div class="d-flex flex-wrap align-items-center pr-3">
								<div class="cate-tabs" id="tabs" role="tablist" aria-label="구분"></div>
								<div class="ml-auto d-flex" style="gap:6px">
									<button type="button" class="btn btn-sm t-allow" data-t="show-allow" aria-pressed="false">수당 펼치기</button>
									<button type="button" class="btn btn-sm t-ded" data-t="show-ded" aria-pressed="false">공제 펼치기</button>
									<button type="button" class="btn btn-sm t-pl" data-t="show-pl" aria-pressed="false">손익 펼치기</button>
								</div>
							</div>
							<div class="table-responsive">
								<table class="table table-sm cal-table mb-0">
									<thead id="lHead"></thead>
									<tbody id="lBody"></tbody>
								</table>
							</div>
							<div class="small text-muted px-3 py-2">색 띠나 같은 색 버튼을 누르면 그 색 칸이 펼쳐집니다. 칸을 누르면 바로 고칩니다. 노란 칸은 자동계산을 사람이 고친 값이고, 빈칸으로 저장하면 자동값으로 돌아갑니다.</div>
						</div>
					</div>
					<div id="staffView" style="display:none">
						<div class="pl-split">
							<div class="cal-panel">
								<div class="p-2"><input type="search" class="form-control form-control-sm" id="peopleKw" placeholder="성명" aria-label="직원 검색"></div>
								<div class="pl-people" id="people"></div>
							</div>
							<div id="staffDetail"></div>
						</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="importModal" tabindex="-1" role="dialog" aria-labelledby="importTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="importTitle">공제 불러오기</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<label for="importFiles" class="small">급여대장·사업소득대장 파일(.xls)을 함께 골라 주세요. 사번·코드로 직원을 연결하고, 공제만 반영합니다. 지급액은 대조만 합니다.</label>
					<input type="file" id="importFiles" class="form-control-file" accept=".xls,.xlsx" multiple>
					<div id="importResult" class="mt-3"></div>
				</div>
				<div class="modal-footer"><button type="button" class="btn btn-sm btn-primary" id="btnApply" disabled>반영</button></div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="reopenModal" tabindex="-1" role="dialog" aria-labelledby="reopenTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="reopenTitle">마감 해제</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<form onsubmit="reopen(); return false;">
					<div class="modal-body"><label for="reopenReason">해제 사유 (이력에 남습니다)</label><textarea id="reopenReason" class="form-control form-control-sm" rows="3" required></textarea></div>
					<div class="modal-footer"><button type="submit" class="btn btn-sm btn-primary">해제</button></div>
				</form>
			</div>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>

	<script>
	var TYPE_NM = { REGULAR: '정규', PROBATION: '수습', SPECIAL: '특고프리', BIZ: '사업자프리', EMP_INS: '고용보험알바', ETC: '기타계약', EXTERNAL: '외부업체' };
	var GROUPS = [['', '전체'], ['_FLAG', '확인 필요'], ['REGULAR,PROBATION', '정규·수습'], ['SPECIAL', '특고프리'], ['BIZ,EMP_INS,ETC', '사업자·기타'], ['EXTERNAL', '외부업체']];
	var ALLOW = [['MEAL_AMT', '식대'], ['RESEARCH_AMT', '연구비'], ['DRIVE_AMT', '운전보조'], ['CHILD_AMT', '자녀보육'], ['BONUS_AMT', '상여'], ['FUEL_AMT', '유류비']];
	var DED = [['NP_AMT', '국민연금'], ['HI_AMT', '건강보험'], ['LTC_AMT', '장기요양'], ['EI_AMT', '고용보험'], ['ACC_AMT', '산재'], ['IT_AMT', '소득세'], ['LIT_AMT', '지방소득세'], ['_SETTLE', '정산'], ['MUTUAL_AMT', '상조회비'], ['ETC_DED', '기타공제']];
	var SETTLES = ['NP_SETTLE', 'HI_SETTLE', 'EI_SETTLE', 'LTC_SETTLE', 'IT_SETTLE', 'LIT_SETTLE'];
	var ym = moment().format('YYYY-MM'), rows = [], closed = false, group = '', view = 'ledger', shown = {}, picked = null;

	$(function() {
		$('#ym').val(ym).on('change', function() { if (this.value) { ym = this.value; load(); } });
		$('#prevYm').on('click', function() { step(-1); });
		$('#nextYm').on('click', function() { step(1); });
		$('[data-view]').on('click', function() { view = $(this).data('view'); $('[data-view]').removeClass('active'); $(this).addClass('active'); render(); });
		$('#peopleKw').on('input', renderPeople);
		$('#btnClose').on('click', function() {
			if (closed) { $('#reopenReason').val(''); $('#reopenModal').modal('show'); return; }
			bootbox.confirm(dpYmLabel(ym) + ' 급여를 마감할까요? 마감하면 금액을 고칠 수 없습니다.', function(ok) {
				if (ok) hrPost('/admin/pay/closeData.do', { YM: ym, CLOSE: true }, load);
			});
		});
		$('#btnImport').on('click', function() { $('#importFiles').val(''); $('#importResult').empty(); $('#btnApply').prop('disabled', true); $('#importModal').modal('show'); });
		$('#importFiles').on('change', preview);
		$('#btnApply').on('click', apply);
		load();
	});

	function step(d) { ym = moment(ym + '-01').add(d, 'months').format('YYYY-MM'); $('#ym').val(ym); load(); }

	function load() {
		hrPost('/admin/pay/monthData.do', { YM: ym }, function(res) {
			rows = res.result.rows;
			closed = res.result.closed;
			render();
		});
	}

	function sum(list, k) { return list.reduce(function(s, r) { return s + Number(r[k] || 0); }, 0); }
	function inGroup(r) { return !group || (group === '_FLAG' ? r.FLAGS.length > 0 : group.split(',').indexOf(r.EMP_TYPE_CD) >= 0); }
	function clients(r) { return r.DETAILS.map(function(d) { return d.CLIENT_NM || ''; }).filter(function(v, i, a) { return v && a.indexOf(v) === i; }).join('·'); }
	function projects(r) { return r.DETAILS.map(function(d) { return d.PRJ_NM || ''; }).filter(function(v, i, a) { return v && a.indexOf(v) === i; }).join('·'); }
	function isManual(r, f) { return (',' + (r.MANUAL_FIELDS || '') + ',').indexOf(',' + f + ',') >= 0; }

	function render() {
		$('#status').text(closed ? '마감' : '작성중').attr('class', 'dp-pill ' + (closed ? 'ok' : 'warn'));
		$('#btnClose').text(closed ? '마감 해제' : '마감');
		$('#btnImport').prop('disabled', closed);
		var kp = [['지급 합계', sum(rows, 'PAY_TOTAL')], ['공제 합계', sum(rows, 'DED_TOTAL')], ['실지급 합계', sum(rows, 'NET')], ['영업이익', sum(rows, 'PROFIT')], ['확인 필요', rows.filter(function(r) { return r.FLAGS.length; }).length, 'bad']];
		$('#kpis').empty().append(kp.map(function(k) { return $('<div class="dp-kpi">').addClass(k[2] || '').append($('<span>').text(k[0])).append($('<b>').text(dpWon(k[1]))); }));
		$('#ledgerView').toggle(view === 'ledger');
		$('#staffView').toggle(view === 'staff');
		if (view === 'ledger') renderLedger(); else renderPeople();
	}

	// ── 월 급여대장 ──

	function renderLedger() {
		$('#tabs').empty().append(GROUPS.map(function(g) { return hrTab(g[0], g[1], rows.filter(function(r) { var keep = group; group = g[0]; var ok = inGroup(r); group = keep; return ok; }).length, group === g[0]); }));
		$('#tabs .cate-tab').on('click', function() { group = $(this).attr('data-tab'); renderLedger(); });
		var bands = $('<tr class="pl-bands">').append('<th colspan="7"></th>')
			.append(band('show-allow', 'allow', '수당', ALLOW.length)).append(band('show-ded', 'ded', '공제', DED.length)).append('<th colspan="2"></th>')
			.append(band('show-pl', 'pl', '손익', 3)).append('<th></th>');
		var $h = $('<tr>').append(['성명', '형태', '고객사', '프로젝트', '근무일', '매출단가', '기본'].map(function(t, i) { return $('<th>').toggleClass('dp-num', i >= 4).text(t); }));
		ALLOW.forEach(function(a) { $h.append($('<th class="dp-num x-allow">').text(a[1])); });
		$h.append('<th class="dp-num c-allow">지급계</th>');
		DED.forEach(function(a) { $h.append($('<th class="dp-num x-ded">').text(a[1])); });
		$h.append('<th class="dp-num c-ded">공제계</th><th class="dp-num">실지급</th><th class="dp-num">전월대비</th><th class="pl-stub"></th>');
		['실매출', '회사부담', '영업이익'].forEach(function(t) { $h.append($('<th class="dp-num x-pl">').text(t)); });
		$h.append('<th>확인 사항</th>');
		$('#lHead').empty().append(bands).append($h);
		var $b = $('#lBody').empty(), list = rows.filter(inGroup);
		if (!list.length) $b.append('<tr><td colspan="40" class="text-center text-muted py-4">해당하는 급여가 없습니다. 투입현황에 투입을 등록하면 자동으로 생깁니다.</td></tr>');
		list.forEach(function(r) {
			var $tr = $('<tr>')
				.append($('<td>').append($('<button type="button" class="dp-name">').text(r.STAFF_NM).on('click', function() { picked = r.STAFF_SQ; $('[data-view=staff]').click(); })))
				.append($('<td>').text(TYPE_NM[r.EMP_TYPE_CD] || r.EMP_TYPE_CD)).append($('<td>').text(clients(r)).append(r.DETAILS.length > 1 ? $('<span class="dp-pill ml-1">').text(r.DETAILS.length + '건') : ''))
				.append($('<td>').text(projects(r)).append(r.DETAILS.length ? dpInfoBtn(r.STAFF_NM + ' 투입 정보', function() { deployInfo(r); }) : '')).append($('<td class="dp-num">').text(r.WORK_DAYS + '/' + r.TOTAL_DAYS)).append($('<td class="dp-num">').text(dpWon(r.SALE_PRICE)))
				.append(cell(r, 'BASE_AMT', ''));
			ALLOW.forEach(function(a) { $tr.append(cell(r, a[0], 'x-allow')); });
			$tr.append($('<td class="dp-num c-allow font-weight-bold">').text(dpWon(r.PAY_TOTAL)));
			DED.forEach(function(a) { $tr.append(a[0] === '_SETTLE' ? $('<td class="dp-num x-ded">').text(dpWon(SETTLES.reduce(function(s, k) { return s + Number(r[k] || 0); }, 0))).attr('title', '정산 칸은 직원별 화면에서 고칩니다') : cell(r, a[0], 'x-ded')); });
			$tr.append($('<td class="dp-num c-ded font-weight-bold">').text(dpWon(r.DED_TOTAL))).append($('<td class="dp-num font-weight-bold">').text(dpWon(r.NET)))
				.append($('<td class="dp-num">').text(r.DELTA_PCT === undefined ? '' : (r.DELTA_PCT > 0 ? '+' : '') + r.DELTA_PCT + '%').toggleClass('text-danger', Math.abs(r.DELTA_PCT || 0) >= 10))
				.append('<td class="pl-stub"></td>')
				.append($('<td class="dp-num x-pl">').text(dpWon(r.REAL_SALE))).append($('<td class="dp-num x-pl">').text(dpWon(r.COMPANY))).append($('<td class="dp-num x-pl font-weight-bold">').text(dpWon(r.PROFIT)))
				.append($('<td>').append(r.FLAGS.map(dpFlag)));
			$b.append($tr);
		});
		applyBands();
	}

	// 급여대장에 없는 투입 정보만 보인다 (고객사·프로젝트·근무일·매출단가는 표에 있다)
	function deployInfo(r) {
		var $box = $('<div>');
		r.DETAILS.forEach(function(d, i) {
			$box.append($('<div class="font-weight-bold mb-1">').toggleClass('mt-3', i > 0).text([d.CLIENT_NM, d.PRJ_NM].filter(Boolean).join(' · ') || '투입 ' + (i + 1)));
			$box.append($('<table class="table table-sm mb-0">').append([['매출처', d.SALE_PARTNER_NM], ['매입처', d.BUY_PARTNER_NM], ['근무지역', d.WORK_AREA], ['투입등급', d.GRADE_CD],
				['투입기간', (d.START_DT || '') + ' ~ ' + (d.END_DT || '미정')], ['수습해제일', d.PROB_END_DT], ['월 계약단가', d.COST_PRICE ? dpWon(d.COST_PRICE) : ''], ['메모', d.MEMO]]
				.map(function(x) { return $('<tr>').append($('<th class="text-muted font-weight-normal" style="width:140px">').text(x[0])).append($('<td>').text(x[1] || '—')); })));
		});
		dpInfo(r.STAFF_NM + ' 투입 정보', $box);
	}

	function band(t, cls, label, span) {
		return $('<th class="band" tabindex="0" role="button">').addClass(cls).attr({ 'data-t': t, 'data-span': span, 'data-label': label });
	}

	function applyBands() {
		$('#ledger [data-t]').each(function() {
			var t = $(this).attr('data-t'), on = !!shown[t];
			if (this.tagName === 'TH') $(this).attr({ colspan: on ? +$(this).attr('data-span') + (t === 'show-pl' ? 0 : 1) : 1, 'aria-expanded': on }).text($(this).attr('data-label') + (on ? ' ▾ 접기' : ' ▸'));
			else $(this).attr('aria-pressed', on).text($(this).text().replace(on ? '펼치기' : '접기', on ? '접기' : '펼치기'));
			$('#ledger').toggleClass(t, on);
		});
	}

	$(document).on('click keydown', '#ledger [data-t]', function(e) {
		if (e.type === 'keydown' && e.key !== 'Enter' && e.key !== ' ') return;
		e.preventDefault();
		var t = $(this).attr('data-t');
		shown[t] = !shown[t];
		applyBands();
	});

	function cell(r, f, cls) {
		var $td = $('<td class="dp-num">').addClass(cls).toggleClass('pl-manual', isManual(r, f));
		if (closed) return $td.text(dpWon(r[f]));
		return hrEditable($td, { url: '/admin/pay/saveFieldData.do', key: { YM: ym, STAFF_SQ: r.STAFF_SQ }, field: f, label: r.STAFF_NM + ' ' + f,
			show: function() { return dpWon(r[f]); }, value: function() { return r[f]; }, saved: function() { load(); } });
	}

	// ── 직원별 ──

	function renderPeople() {
		var kw = $.trim($('#peopleKw').val());
		if (!picked && rows.length) picked = rows[0].STAFF_SQ;
		$('#people').empty().append(rows.filter(function(r) { return !kw || r.STAFF_NM.indexOf(kw) >= 0; }).map(function(r) {
			return $('<button type="button">').toggleClass('on', r.STAFF_SQ === picked).append($('<span>').text(r.STAFF_NM)).append($('<span class="dp-pill">').text(TYPE_NM[r.EMP_TYPE_CD] || ''))
				.on('click', function() { picked = r.STAFF_SQ; renderPeople(); });
		}));
		var r = rows.filter(function(x) { return x.STAFF_SQ === picked; })[0];
		if (!r) { $('#staffDetail').html('<div class="text-muted p-4">이 달에 급여 행이 있는 직원이 없습니다.</div>'); return; }
		function line(f, label) {
			var $v = $('<span>').toggleClass('pl-manual', isManual(r, f));
			if (closed) $v.text(dpWon(r[f])); else hrEditable($v, { url: '/admin/pay/saveFieldData.do', key: { YM: ym, STAFF_SQ: r.STAFF_SQ }, field: f, label: label,
				show: function() { return dpWon(r[f]); }, value: function() { return r[f]; }, saved: function() { load(); } });
			return $('<div class="pl-line">').append($('<span>').text(label)).append($v);
		}
		var $pay = $('<div>').append('<div class="pl-line h"><span>지급</span></div>');
		DP_PAY.forEach(function(d) { $pay.append(line(d[0], d[1])); });
		$pay.append($('<div class="pl-line t">').append('<span>지급 합계</span>').append($('<span>').text(dpWon(r.PAY_TOTAL))));
		var $ded = $('<div>').append('<div class="pl-line h"><span>공제</span></div>');
		DP_DED.forEach(function(d) { $ded.append(line(d[0], d[1])); });
		$ded.append($('<div class="pl-line t">').append('<span>공제 합계</span>').append($('<span>').text(dpWon(r.DED_TOTAL))));
		var $stub = $('<div class="cal-panel">')
			.append($('<div class="cal-panel-head">').append($('<span>').append($('<b>').text(r.STAFF_NM)).append(' ').append($('<span class="dp-pill">').text(TYPE_NM[r.EMP_TYPE_CD] || ''))
				.append($('<span class="dp-mute small ml-2">').text([clients(r), projects(r), r.JOIN_DT ? '입사 ' + r.JOIN_DT : ''].filter(Boolean).join(' · '))))
				.append($('<span class="dp-pill">').addClass(closed ? 'ok' : 'warn').text(dpYmLabel(ym) + ' ' + (closed ? '마감' : '작성중'))))
			.append($('<div class="pl-two">').append($pay).append($ded))
			.append($('<div class="pl-netbar">').append('<span>실지급액</span>').append($('<b>').text(dpWon(r.NET))));
		var $hist = $('<div class="cal-panel">').append($('<div class="cal-panel-head">').text(ym.substring(0, 4) + '년 월별 내역'))
			.append('<div class="table-responsive"><table class="table table-sm cal-table mb-0"><thead><tr><th>월</th><th class="dp-num">근무일</th><th class="dp-num">계약단가</th><th class="dp-num">지급계</th><th class="dp-num">공제계</th><th class="dp-num">실지급</th><th class="dp-num">영업이익</th><th>확인 사항</th></tr></thead><tbody id="yearBody"></tbody></table></div>');
		var plan = (r.BONUS_PLAN || []).map(function(b) { return $('<span class="dp-pill">').addClass(b.YM < ym ? 'ok' : b.YM === ym ? 'warn' : '').text(b.LABEL + ' ' + b.YM + (b.YM === ym ? ' · 이번 달' : b.YM < ym ? ' 지급' : ' 예정')); });
		var $bonus = $('<div class="cal-panel">').append($('<div class="cal-panel-head">').text('상여 일정 (입사일 기준, 정규·수습)'))
			.append($('<div class="p-3">').append(plan.length ? plan : $('<span class="dp-mute">').text('자동 상여 대상이 아닙니다. 연차수당·인재추천은 상여 칸에 직접 넣습니다.')));
		$('#staffDetail').empty().append($stub).append($hist).append($bonus);
		hrPost('/admin/pay/staffYearData.do', { STAFF_SQ: r.STAFF_SQ, YEAR: ym.substring(0, 4) }, function(res) {
			$('#yearBody').empty().append(res.result.map(function(m) {
				return $('<tr>').toggleClass('font-weight-bold', m.PAY_YM === ym).append($('<td>').text(Number(m.PAY_YM.substring(5)) + '월'))
					.append($('<td class="dp-num">').text(m.WORK_DAYS + '/' + m.TOTAL_DAYS)).append($('<td class="dp-num">').text(dpWon(m.COST_PRICE)))
					.append($('<td class="dp-num">').text(dpWon(m.PAY_TOTAL))).append($('<td class="dp-num">').text(dpWon(m.DED_TOTAL))).append($('<td class="dp-num">').text(dpWon(m.NET)))
					.append($('<td class="dp-num">').text(dpWon(m.PROFIT))).append($('<td>').text(m.MEMO || ''));
			}));
		});
	}

	// ── 공제 불러오기 ──

	var importRows = [];
	function preview() {
		var fd = new FormData();
		fd.append('YM', ym);
		$.each(this.files, function(i, f) { fd.append('files', f); });
		if (!this.files.length) return;
		$('#importResult').html('<div class="text-muted">읽는 중…</div>');
		$.ajax({ url: '/admin/pay/importPreviewData.do', type: 'POST', data: fd, processData: false, contentType: false }).done(function(res) {
			if (res.error) { $('#importResult').empty(); bootbox.alert(res.error); return; }
			importRows = res.result.rows;
			var staff = rows.map(function(r) { return [r.STAFF_SQ, r.STAFF_NM]; });
			var need = importRows.filter(function(r) { return !r.STAFF_SQ; }).length, diff = importRows.filter(function(r) { return r.STAFF_SQ && r.SYSTEM_PAY !== null && r.SYSTEM_PAY !== undefined && r.SYSTEM_PAY !== r.LEDGER_PAY; }).length;
			var $sum = $('<div class="mb-2">').append(res.result.files.map(function(f) { return $('<span class="dp-pill ok">').text((f.KIND === 'PAY' ? '급여대장 ' : '사업소득대장 ') + f.COUNT + '명 · 합계 검증 통과'); }))
				.append($('<span class="dp-pill">').text('반영 ' + (importRows.length - need))).append(need ? $('<span class="dp-pill bad">').text('직원 연결 필요 ' + need) : '').append(diff ? $('<span class="dp-pill warn">').text('지급액 차이 ' + diff) : '');
			var $tb = $('<tbody>');
			importRows.forEach(function(r, i) {
				var $res;
				if (!r.STAFF_SQ) {
					$res = $('<select class="form-control form-control-sm" style="min-width:140px">').attr({ 'data-link': i, 'aria-label': r.LEDGER_NM + ' 직원 선택' }).append('<option value="">건너뜀</option>');
					staff.forEach(function(s) { $res.append($('<option>').val(s[0]).text(s[1])); });
				} else if (r.SYSTEM_PAY === null || r.SYSTEM_PAY === undefined) {
					$res = $('<span class="dp-pill warn">').text('이번 달 급여 행 없음 · 새로 만듦');
				} else if (r.SYSTEM_PAY !== r.LEDGER_PAY) {
					$res = $('<span class="dp-pill warn">').text((r.LEDGER_PAY > r.SYSTEM_PAY ? '+' : '') + dpWon(r.LEDGER_PAY - r.SYSTEM_PAY) + ' 차이');
				} else {
					$res = $('<span class="dp-pill ok">').text('일치');
				}
				$tb.append($('<tr>').append($('<td>').text(r.LEDGER_NM)).append($('<td>').text(r.SRC_CD === 'PAY' ? '급여' : '사업소득')).append($('<td>').text(r.LEDGER_CD))
					.append($('<td class="dp-num">').text(dpWon(r.LEDGER_PAY))).append($('<td class="dp-num">').text(dpWon(r.SYSTEM_PAY))).append($('<td class="dp-num">').text(dpWon(r.LEDGER_DED)))
					.append($('<td class="dp-num">').text(dpWon(r.LEDGER_NET))).append($('<td>').append($res)));
			});
			$('#importResult').empty().append($sum).append($('<div class="table-responsive" style="max-height:50vh">').append($('<table class="table table-sm cal-table mb-0">')
				.append('<thead><tr><th>성명</th><th>대장</th><th>사번·코드</th><th class="dp-num">대장 지급</th><th class="dp-num">시스템 지급</th><th class="dp-num">공제계</th><th class="dp-num">차인지급</th><th>결과</th></tr></thead>').append($tb)))
				.append('<div class="small text-muted mt-2">공제만 반영합니다. 예술/특고인 경비는 공제가 아니어서 넣지 않습니다. 고른 직원 연결은 다음 달부터 자동으로 씁니다.</div>');
			$('#btnApply').prop('disabled', false).text((importRows.length - need) + '건 반영');
			$('#importResult select').on('change', function() {
				var n = importRows.length - need + $('#importResult select').filter(function() { return this.value; }).length;
				$('#btnApply').text(n + '건 반영');
			});
		}).fail(function() { $('#importResult').empty(); });
	}

	function apply() {
		var p = { YM: ym };
		$('#importResult [data-link]').each(function() { if (this.value) p['LINK_' + $(this).attr('data-link')] = this.value; });
		$('#btnApply').prop('disabled', true);
		hrPost('/admin/pay/importApplyData.do', p, function(res) {
			$('#importModal').modal('hide');
			bootbox.alert(res.result + '명의 공제를 반영했습니다.');
			load();
		}, function() { $('#btnApply').prop('disabled', false); });
	}

	function reopen() {
		hrPost('/admin/pay/closeData.do', { YM: ym, CLOSE: false, REASON: $('#reopenReason').val() }, function() { $('#reopenModal').modal('hide'); load(); });
	}
	</script>
</body>
</html>
