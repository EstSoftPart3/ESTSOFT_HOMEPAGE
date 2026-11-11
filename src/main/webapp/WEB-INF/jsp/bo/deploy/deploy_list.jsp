<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<style>
	#dpHead th, #dpBody td { white-space: nowrap; }
	#dpHead th[draggable] { cursor: grab; user-select: none; }
	#dpHead th.dragging { opacity: .4; }
	#dpHead th.drop-l { box-shadow: inset 3px 0 0 #0b6e8a; }
	#dpHead th.drop-r { box-shadow: inset -3px 0 0 #0b6e8a; }
	#dpHead th:focus { outline: 2px solid #16d5ff; outline-offset: -2px; }
	tr.dp-edit td { background: #fff8e3; padding: 4px; }
	tr.dp-edit td:last-child, #dpHead th:last-child { position: sticky; right: 0; background: #fff8e3; }
	#dpHead th:last-child { background: #fafbfc; }
	tr.dp-edit .form-control { height: 26px; padding: 0 4px; font-size: 12px; min-width: 84px; }
	tr.dp-edit input[type=date] { min-width: 125px; }
	tr.dp-edit .is-invalid { box-shadow: 0 0 0 2px #e2a5a5; }
	tr.dp-hist:hover td { background: #eef9fc; }
	.pl-changed { font-weight: 700; }
	.dp-gantt { min-width: 960px; }
	.dp-g-row { display: grid; grid-template-columns: 170px 1fr; border-bottom: 1px solid rgba(17,17,17,.06); align-items: center; min-height: 34px; }
	.dp-g-who { padding: 0 12px; display: flex; gap: 6px; align-items: center; }
	.dp-g-head { display: grid; grid-template-columns: repeat(12, 1fr); font-size: 11.5px; color: #444; font-weight: 700; }
	.dp-g-head span { padding: 6px 0 6px 5px; } .dp-g-head .now { color: #0b6e8a; }
	.dp-g-track { position: relative; height: 34px; background: repeating-linear-gradient(90deg, transparent 0, transparent calc(8.3333% - 1px), #eef1f4 calc(8.3333% - 1px), #eef1f4 8.3333%); }
	.dp-b { position: absolute; top: 7px; height: 20px; border-radius: 4px; background: #9fd8e8; color: #06323e; font-size: 11px; line-height: 20px; padding: 0 7px; overflow: hidden; white-space: nowrap; font-weight: 700; }
	.dp-b.soon { background: #f6d27c; color: #4f3800; } .dp-b.urgent { background: #eda3a3; color: #5a1010; } .dp-b.past { background: #d7dde2; color: #444; }
	.dp-b.open { background: linear-gradient(90deg, #9fd8e8 80%, rgba(159,216,232,.15)); }
	.dp-today { position: absolute; top: 0; bottom: 0; width: 2px; background: #0b6e8a; z-index: 2; }
</style>
<%@ include file="/WEB-INF/jsp/bo/deploy/deploy_common.jspf"%>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header d-flex align-items-center">
					<h3 class="card-title bTitle"><b>투입현황</b></h3>
					<button type="button" class="btn btn-sm btn-primary ml-auto" id="btnAdd"><i class="fas fa-plus"></i> 추가</button>
				</div>
				<div class="card-body">
					<div class="dp-kpis" id="kpis"></div>
					<div class="cal-panel">
						<div class="d-flex flex-wrap align-items-center pr-3">
							<div class="cate-tabs" id="tabs" role="tablist" aria-label="고용형태"></div>
							<div class="btn-group btn-group-sm ml-auto" role="group" aria-label="보기">
								<button type="button" class="btn btn-outline-secondary active" data-view="table">표</button>
								<button type="button" class="btn btn-outline-secondary" data-view="timeline">타임라인</button>
							</div>
						</div>
						<div class="dp-bar">
							<input type="search" id="keyword" class="form-control form-control-sm" style="width:180px" placeholder="성명·프로젝트·고객사" aria-label="검색">
							<select class="form-control form-control-sm dp-filter" style="width:auto" data-field="CLIENT_NM" aria-label="고객사"></select>
							<select class="form-control form-control-sm dp-filter" style="width:auto" data-field="SALE_PARTNER_NM" aria-label="매출처"></select>
							<select class="form-control form-control-sm dp-filter" style="width:auto" data-field="WORK_AREA" aria-label="근무지역"></select>
							<select class="form-control form-control-sm dp-filter" style="width:auto" data-field="GRADE_CD" aria-label="등급"></select>
							<div class="ml-auto"><button type="button" class="btn btn-sm btn-outline-secondary" id="btnResetCols">컬럼 순서 초기화</button></div>
						</div>
						<div id="tableView">
							<div class="table-responsive">
								<table class="table table-sm cal-table mb-0">
									<thead id="dpHead"></thead>
									<tbody id="dpBody"></tbody>
								</table>
							</div>
							<div class="small text-muted px-3 py-2">
								머리글을 좌우로 끌면 순서가 바뀌고 이 계정에 저장됩니다(머리글에서 Alt+←/→ 도 됩니다). <b>추가</b>를 누르면 맨 아래에 입력 행이 생깁니다: Tab 이동, Enter 저장 후 다음 행, Esc 취소.
								<span class="dp-pay-only">매출단가 옆 ⓘ 를 누르면 그 투입 건의 월별 단가·급여 이력이 보입니다.</span>
							</div>
						</div>
						<div id="timelineView" class="table-responsive" style="display:none"></div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="detailModal" tabindex="-1" role="dialog" aria-labelledby="detailTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="detailTitle">투입 상세</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<form id="detailForm" onsubmit="saveDetail(); return false;">
					<input type="hidden" name="DEPLOY_SQ"><input type="hidden" name="STAFF_SQ">
					<div class="modal-body">
						<div class="form-row" id="detailFields"></div>
						<div class="hr-section">투입 이력 <span class="small text-muted font-weight-normal dp-pay-only">기간 옆 ⓘ 를 누르면 그 건의 월별 단가·급여가 보입니다</span></div>
						<table class="table table-sm cal-table mb-0">
							<thead><tr><th>기간</th><th>형태</th><th>고객사</th><th>프로젝트</th><th>지역</th><th>등급</th></tr></thead>
							<tbody id="histBody"></tbody>
						</table>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-sm btn-outline-danger mr-auto" onclick="deleteDetail();">삭제</button>
						<button type="button" class="btn btn-sm btn-outline-secondary" onclick="nextDeploy();">철수 후 다음 투입 등록</button>
						<button type="submit" class="btn btn-sm btn-primary">저장</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>

	<script>
	var COLS = [['STAFF_NM', '성명'], ['EMP_TYPE_CD', '형태'], ['SALE_PARTNER_NM', '매출처'], ['BUY_PARTNER_NM', '매입처'], ['SALE_PRICE', '매출단가', true], ['COST_PRICE', '계약단가', true],
		['CLIENT_NM', '고객사'], ['PRJ_NM', '프로젝트'], ['WORK_AREA', '지역'], ['GRADE_CD', '등급'], ['START_DT', '투입일'], ['END_DT', '철수일'], ['REMAIN', '남은 기간'], ['TENURE', '근속']];
	var data = null, order = [], tab = '', kpi = '', view = 'table', drag = null;
	var today = moment().startOf('day'), YM = moment().format('YYYY-MM');

	$(function() {
		load();
		$('#keyword').on('input', render);
		$(document).on('change', '.dp-filter', render);
		$('[data-view]').on('click', function() { view = $(this).data('view'); $('[data-view]').removeClass('active'); $(this).addClass('active'); render(); });
		$('#btnAdd').on('click', function() { if (view !== 'table') $('[data-view=table]').click(); addRow(true); });
		$('#btnResetCols').on('click', function() { saveOrder(''); order = defaultOrder(); arrangeAll(); });
	});

	function load(after) {
		hrPost('/admin/deploy/deployListData.do', {}, function(res) {
			data = res.data;
			hrSetCodes(data.codes);
			var saved = (data.columns || []).filter(function(k) { return visibleCols().some(function(c) { return c[0] === k; }); });
			order = saved.concat(defaultOrder().filter(function(k) { return saved.indexOf(k) < 0; }));
			$('.dp-pay-only').toggle(!!data.canPay);
			$('#staffList').remove();
			var $dl = $('<datalist id="staffList">').appendTo('body');
			data.staff.forEach(function(s) { $dl.append($('<option>').val(staffLabel(s))); });
			fillFilters();
			render();
			if (after) after();
		});
	}

	function visibleCols() { return COLS.filter(function(c) { return !c[2] || data.canPay; }); }
	function defaultOrder() { return visibleCols().map(function(c) { return c[0]; }); }
	function colLabel(k) { var c = COLS.filter(function(x) { return x[0] === k; })[0]; return c[1] + (c[2] ? ' 🔒' : ''); }
	function staffLabel(s) { return s.STAFF_NM + (s.JOIN_DT ? ' (' + s.JOIN_DT + ')' : ''); }
	function typeName(cd) { return hrCodeName('HR_EMP_TYPE', cd); }

	function remain(r) {
		if (r.STATE === 'WAIT') return { text: '대기 ' + today.diff(moment(r.END_DT), 'days') + '일', tone: 'warn', days: -1 };
		if (r.STATE === 'FUTURE') return { text: moment(r.START_DT).diff(today, 'days') + '일 뒤 투입', tone: 'rent', days: 9998 };
		if (!r.END_DT) return { text: '미정', tone: '', days: 9999 };
		var d = moment(r.END_DT).diff(today, 'days');
		return { text: 'D-' + d, tone: d <= 14 ? 'bad' : d <= 30 ? 'warn' : '', days: d };
	}

	function tenure(joinDt) {
		var from = moment(joinDt, 'YYYY-MM-DD', true);
		if (!from.isValid() || today.isBefore(from)) return '';
		var m = today.diff(from, 'months');
		return (m >= 12 ? Math.floor(m / 12) + '년 ' : '') + (m % 12) + '개월';
	}

	function fillFilters() {
		var labels = { CLIENT_NM: '고객사', SALE_PARTNER_NM: '매출처', WORK_AREA: '지역', GRADE_CD: '등급' };
		$('.dp-filter').each(function() {
			var $s = $(this), f = $s.data('field'), keep = $s.val();
			var vals = data.current.map(function(r) { return r[f]; }).filter(Boolean).filter(function(v, i, a) { return a.indexOf(v) === i; }).sort();
			$s.empty().append($('<option value="">').text(labels[f] + ' 전체'));
			vals.forEach(function(v) { $s.append($('<option>').val(v).text(v)); });
			$s.val(keep || '');
		});
	}

	function kpiTest(key, r) {
		var rm = remain(r);
		return { ACTIVE: r.STATE === 'ACTIVE', D14: r.STATE === 'ACTIVE' && rm.days >= 0 && rm.days <= 14, D30: r.STATE === 'ACTIVE' && rm.days >= 0 && rm.days <= 30,
			NEW: moment(r.START_DT).format('YYYY-MM') === YM, WAIT: r.STATE === 'WAIT' }[key];
	}

	function filtered() {
		var kw = $.trim($('#keyword').val()).toLowerCase();
		return data.current.filter(function(r) {
			if (tab && r.EMP_TYPE_CD !== tab) return false;
			if (kpi && !kpiTest(kpi, r)) return false;
			var ok = true;
			$('.dp-filter').each(function() { if ($(this).val() && r[$(this).data('field')] !== $(this).val()) ok = false; });
			return ok && (!kw || [r.STAFF_NM, r.PRJ_NM, r.CLIENT_NM].some(function(v) { return v && String(v).toLowerCase().indexOf(kw) >= 0; }));
		}).sort(function(a, b) { return remain(a).days - remain(b).days || String(a.STAFF_NM).localeCompare(String(b.STAFF_NM), 'ko'); });
	}

	function render() {
		var cur = data.current;
		var kpis = [['ACTIVE', '투입 중', ''], ['D14', '14일 내 철수', 'bad'], ['D30', '30일 내 철수', 'warn'], ['NEW', '이번 달 신규 투입', ''], ['WAIT', '대기', 'warn']];
		$('#kpis').empty().append(kpis.map(function(k) {
			return $('<button type="button" class="dp-kpi">').addClass(k[2]).toggleClass('active', kpi === k[0]).attr('aria-pressed', kpi === k[0])
				.append($('<span>').text(k[1])).append($('<b>').text(cur.filter(function(r) { return kpiTest(k[0], r); }).length))
				.on('click', function() { kpi = kpi === k[0] ? '' : k[0]; render(); });
		}));
		$('#tabs').empty().append(hrTab('', '전체', cur.length, tab === ''));
		(HR_CODES.HR_EMP_TYPE || []).forEach(function(c) {
			var n = cur.filter(function(r) { return r.EMP_TYPE_CD === c.CD; }).length;
			if (n) $('#tabs').append(hrTab(c.CD, c.NM, n, tab === c.CD));
		});
		$('#tabs .cate-tab').off('click').on('click', function() { tab = $(this).attr('data-tab'); render(); });
		$('#tableView').toggle(view === 'table');
		$('#timelineView').toggle(view === 'timeline');
		if (view === 'timeline') renderTimeline(filtered()); else renderTable(filtered());
	}

	// ── 표 ──

	function renderTable(list) {
		var $h = $('<tr>');
		visibleCols().forEach(function(c) { $h.append($('<th>').attr('data-c', c[0]).toggleClass('dp-num', !!c[2]).text(colLabel(c[0]))); });
		$h.append($('<th data-c="_ACT">').append('<span class="sr-only">작업</span>'));
		$('#dpHead').empty().append($h);
		bindDrag();
		var $b = $('#dpBody').empty();
		if (!list.length) $b.append($('<tr>').append($('<td class="text-center text-muted py-4">').attr('colspan', order.length + 1).text('해당하는 투입이 없습니다.')));
		list.forEach(function(r) { $b.append(viewRow(r)); });
		arrangeAll();
	}

	function viewRow(r) {
		var $tr = $('<tr>'), rm = remain(r);
		visibleCols().forEach(function(c) {
			var $td = $('<td>').attr('data-c', c[0]), v = r[c[0]];
			if (c[0] === 'STAFF_NM') $td.append($('<button type="button" class="dp-name">').text(r.STAFF_NM).on('click', function() { openDetail(r); }));
			else if (c[0] === 'EMP_TYPE_CD') $td.text(typeName(v));
			else if (c[2]) $td.addClass('dp-num').text(v ? dpWon(v) : '').append(c[0] === 'SALE_PRICE' ? dpInfoBtn(r.STAFF_NM + ' 단가·급여 이력', function() { payHistory(r); }) : '');
			else if (c[0] === 'REMAIN') $td.append($('<span class="dp-pill">').addClass(rm.tone).text(rm.text));
			else if (c[0] === 'TENURE') $td.text(tenure(r.JOIN_DT));
			else if (c[0] === 'CLIENT_NM' && r.STATE === 'WAIT') $td.addClass('dp-mute').text('—');
			else $td.text(v || '');
			$tr.append($td);
		});
		$tr.append($('<td data-c="_ACT">'));
		return $tr;
	}

	function arrange($tr) {
		order.concat(['_ACT']).forEach(function(k) { var $c = $tr.children('[data-c="' + k + '"]'); if ($c.length) $tr.append($c); });
	}
	function arrangeAll() { $('#dpHead tr, #dpBody tr').each(function() { arrange($(this)); }); }

	function saveOrder(val) { $.post('/admin/deploy/saveColumnsData.do', { ORDER: val }); }

	function move(from, to, after) {
		order.splice(order.indexOf(from), 1);
		order.splice(order.indexOf(to) + (after ? 1 : 0), 0, from);
		arrangeAll();
		saveOrder(order.join(','));
	}

	function bindDrag() {
		$('#dpHead th').each(function() {
			var th = this, c = $(th).attr('data-c');
			if (c === '_ACT') return;
			$(th).attr({ draggable: true, tabindex: 0, title: '끌어서 순서 변경 (Alt+←/→)' });
			function after(e) { var r = th.getBoundingClientRect(); return e.originalEvent.clientX > r.left + r.width / 2; }
			function clear() { $('#dpHead th').removeClass('drop-l drop-r dragging'); }
			$(th).on('dragstart', function(e) { drag = c; e.originalEvent.dataTransfer.setData('text/plain', c); e.originalEvent.dataTransfer.effectAllowed = 'move'; $(th).addClass('dragging'); })
				.on('dragover', function(e) { if (!drag || drag === c) return; e.preventDefault(); clear(); $(th).addClass(after(e) ? 'drop-r' : 'drop-l'); })
				.on('drop', function(e) { e.preventDefault(); if (drag && drag !== c) move(drag, c, after(e)); clear(); })
				.on('dragend', function() { drag = null; clear(); })
				.on('keydown', function(e) {
					if (!e.altKey || (e.key !== 'ArrowLeft' && e.key !== 'ArrowRight')) return;
					e.preventDefault();
					var next = order[order.indexOf(c) + (e.key === 'ArrowRight' ? 1 : -1)];
					if (next) { move(c, next, e.key === 'ArrowRight'); th.focus(); }
				});
		});
	}

	// ── 맨 아래 입력 행 ──

	function partnerOptions(kind, keep) {
		return { list: [['', kind === 'SALE_YN' ? '매출처' : '매입처']].concat(data.partners.filter(function(p) { return p[kind] === 'Y' && (p.USE_YN === 'Y' || String(p.PARTNER_SQ) === String(keep)); })
			.map(function(p) { return [String(p.PARTNER_SQ), p.PARTNER_NM]; })) };
	}

	function addRow(focus, preset) {
		preset = preset || {};
		var $tr = $('<tr class="dp-edit">'), inputs = {};
		function put(k, $c) { inputs[k] = $c.attr('aria-label', colLabel(k)); return $c; }
		visibleCols().forEach(function(c) {
			var $td = $('<td>').attr('data-c', c[0]), k = c[0];
			if (k === 'STAFF_NM') $td.append(put(k, $('<input class="form-control" list="staffList" placeholder="성명 검색" autocomplete="off">').val(preset.STAFF_LABEL || '')));
			else if (k === 'EMP_TYPE_CD') $td.append(put(k, hrControl({ code: 'HR_EMP_TYPE' }, preset.EMP_TYPE_CD)));
			else if (k === 'GRADE_CD') $td.append(put(k, hrControl({ code: 'HR_DEPLOY_GRADE' }, preset.GRADE_CD)));
			else if (k === 'SALE_PARTNER_NM') $td.append(put(k, hrControl(partnerOptions('SALE_YN'), '')));
			else if (k === 'BUY_PARTNER_NM') $td.append(put(k, hrControl(partnerOptions('BUY_YN'), '')));
			else if (c[2]) $td.append(put(k, $('<input class="form-control dp-num" inputmode="numeric" placeholder="0">')));
			else if (k === 'START_DT' || k === 'END_DT') $td.append(put(k, $('<input class="form-control" type="date">')));
			else if (k === 'REMAIN' || k === 'TENURE') $td.append('<span class="dp-mute">자동</span>');
			else $td.append(put(k, $('<input class="form-control">')));
			$tr.append($td);
		});
		var $act = $('<td data-c="_ACT" class="text-nowrap">')
			.append($('<button type="button" class="btn btn-sm btn-primary">저장</button>').on('click', function() { save(false); }))
			.append(' ').append($('<button type="button" class="btn btn-sm btn-outline-secondary">취소</button>').on('click', function() { $tr.remove(); }));
		$tr.append($act).find('select').addClass('form-control');
		function staffSq() {
			var v = $.trim(inputs.STAFF_NM.val());
			var hit = data.staff.filter(function(s) { return staffLabel(s) === v; });
			if (!hit.length) hit = data.staff.filter(function(s) { return s.STAFF_NM === v; });
			return hit.length === 1 ? hit[0].STAFF_SQ : null;
		}
		function save(next) {
			$tr.find('.is-invalid').removeClass('is-invalid');
			var sq = staffSq();
			if (!sq) { inputs.STAFF_NM.addClass('is-invalid').focus(); bootbox.alert('성명은 목록에서 골라 주세요. 같은 이름이 있으면 입사일이 붙은 항목을 고릅니다.'); return; }
			var p = { STAFF_SQ: sq, EMP_TYPE_CD: inputs.EMP_TYPE_CD.val(), GRADE_CD: inputs.GRADE_CD.val(), SALE_PARTNER_SQ: inputs.SALE_PARTNER_NM.val(), BUY_PARTNER_SQ: inputs.BUY_PARTNER_NM.val(),
				CLIENT_NM: inputs.CLIENT_NM.val(), PRJ_NM: inputs.PRJ_NM.val(), WORK_AREA: inputs.WORK_AREA.val(), START_DT: inputs.START_DT.val(), END_DT: inputs.END_DT.val() };
			if (data.canPay) { p.SALE_PRICE = inputs.SALE_PRICE.val(); p.COST_PRICE = inputs.COST_PRICE.val(); }
			if (!p.EMP_TYPE_CD) { inputs.EMP_TYPE_CD.addClass('is-invalid').focus(); return; }
			if (!p.START_DT) { inputs.START_DT.addClass('is-invalid').focus(); return; }
			if (p.END_DT && p.END_DT < p.START_DT) { inputs.END_DT.addClass('is-invalid').focus(); return; }
			hrPost('/admin/deploy/saveDeployData.do', p, function() {
				load(function() { if (next) addRow(true); });
			});
		}
		$tr.on('keydown', function(e) {
			if (e.key === 'Escape') $tr.remove();
			else if (e.key === 'Enter' && e.target.tagName !== 'BUTTON') { e.preventDefault(); save(true); }
		});
		$('#dpBody').append($tr);
		arrange($tr);
		if (focus) inputs.STAFF_NM.focus();
	}

	// ── 상세 팝업 ──

	function detailFields() {
		var f = [['STAFF_NM', '성명', 3], ['EMP_TYPE_CD', '고용형태', 3, { code: 'HR_EMP_TYPE' }], ['GRADE_CD', '투입등급', 3, { code: 'HR_DEPLOY_GRADE' }], ['WORK_AREA', '근무지역', 3],
			['CLIENT_NM', '고객사', 3], ['PRJ_NM', '프로젝트', 3], ['SALE_PARTNER_SQ', '매출처', 3, { values: {} }], ['BUY_PARTNER_SQ', '매입처', 3, { values: {} }],
			['START_DT', '투입일', 3, 'date'], ['END_DT', '철수일', 3, 'date'], ['PROB_END_DT', '수습해제일', 3, 'date']];
		if (data.canPay) f.push(['SALE_PRICE', '월 매출단가 🔒', 3], ['COST_PRICE', '월 계약단가 🔒', 3]);
		f.push(['MEMO', '메모', 12]);
		return f;
	}

	function openDetail(r) {
		$('#detailFields').empty();
		hrBuildFields('#detailFields', detailFields());
		[['SALE_PARTNER_SQ', 'SALE_YN'], ['BUY_PARTNER_SQ', 'BUY_YN']].forEach(function(x) {
			var $s = $('#detailForm [name=' + x[0] + ']').empty();
			partnerOptions(x[1], r[x[0]]).list.forEach(function(o) { $s.append($('<option>').val(o[0]).text(o[1])); });
		});
		hrFillForm('#detailForm', detailFields(), r);
		$('#detailForm [name=DEPLOY_SQ]').val(r.DEPLOY_SQ);
		$('#detailForm [name=STAFF_SQ]').val(r.STAFF_SQ);
		$('#detailForm [name=STAFF_NM]').prop('readonly', true);
		$('#detailTitle').text(r.STAFF_NM + ' 투입 상세');
		var $hb = $('#histBody').empty();
		data.all.filter(function(x) { return x.STAFF_SQ === r.STAFF_SQ; }).slice().reverse().forEach(function(x) {
			var $tr = $('<tr class="dp-hist" tabindex="0">').toggleClass('font-weight-bold', x.DEPLOY_SQ === r.DEPLOY_SQ)
				.append($('<td>').text(x.START_DT + ' ~ ' + (x.END_DT || '미정')).append(data.canPay ? dpInfoBtn('단가·급여 이력', function() { payHistory(x); }) : ''))
				.append($('<td>').text(typeName(x.EMP_TYPE_CD)))
				.append($('<td>').text(x.CLIENT_NM || '')).append($('<td>').text(x.PRJ_NM || '')).append($('<td>').text(x.WORK_AREA || '')).append($('<td>').text(x.GRADE_CD || ''))
				.on('click', function() { openDetail(x); });
			$hb.append($tr);
		});
		$('#detailModal').modal('show');
	}

	// 투입 건 하나의 월별 단가·급여 이력 표
	function payHistory(x) {
		var title = x.STAFF_NM ? x.STAFF_NM + ' · ' : '';
		title += [x.CLIENT_NM, x.PRJ_NM].filter(Boolean).join(' · ') || '투입';
		hrPost('/admin/pay/deployHistoryData.do', { STAFF_SQ: x.STAFF_SQ, DEPLOY_SQ: x.DEPLOY_SQ }, function(res) {
			var h = res.result, months = (h.MONTHS || []).slice().reverse(), shared = months.some(function(m) { return m.SHARED; });
			var $box = $('<div>').append($('<div class="small text-muted mb-2">').text('투입 ' + x.START_DT + ' ~ ' + (x.END_DT || '미정') + ' · 현재 단가 ' + dpWon(x.SALE_PRICE) + ' / ' + dpWon(x.COST_PRICE)));
			if (!months.length) {
				$box.append('<div class="text-muted py-3">급여 기록이 없습니다. 급여관리에서 그 달을 열면 만들어집니다.</div>');
			} else {
				var cols = [['PAY_YM', '월'], ['_DAYS', '근무일'], ['SALE_PRICE', '매출단가'], ['COST_PRICE', '계약단가'], ['REAL_SALE', '실매출'], ['PAY', '지급계'], ['DED', '공제계'], ['NET', '실지급'], ['PROFIT', '영업이익']];
				var $t = $('<table class="table table-sm cal-table mb-0">').append($('<thead>').append($('<tr>').append(cols.map(function(c) { return $('<th>').toggleClass('dp-num', c[0] !== 'PAY_YM').text(c[1]); }))));
				var $b = $('<tbody>').appendTo($t);
				months.forEach(function(m, i) {
					var prev = months[i + 1], changed = prev && (prev.SALE_PRICE !== m.SALE_PRICE || prev.COST_PRICE !== m.COST_PRICE);
					$b.append($('<tr>').append(cols.map(function(c) {
						if (c[0] === 'PAY_YM') return $('<td>').text(m.PAY_YM + (m.SHARED ? ' *' : ''));
						if (c[0] === '_DAYS') return $('<td class="dp-num">').text(m.WORK_DAYS + '/' + m.TOTAL_DAYS);
						return $('<td class="dp-num">').toggleClass('font-weight-bold', c[0] === 'PROFIT').toggleClass('text-danger', c[0] === 'PROFIT' && m.PROFIT < 0)
							.toggleClass('pl-changed', changed && /PRICE/.test(c[0])).text(m[c[0]] === null || m[c[0]] === undefined ? '—' : dpWon(m[c[0]]));
					})));
				});
				$b.append($('<tr class="font-weight-bold" style="background:#f6f8fa">').append('<td>누적</td><td></td><td></td><td></td>')
					.append($('<td class="dp-num">').text(dpWon(h.SALE))).append($('<td class="dp-num">').text(dpWon(h.PAY))).append('<td></td><td></td>')
					.append($('<td class="dp-num">').toggleClass('text-danger', h.PROFIT < 0).text(dpWon(h.PROFIT))));
				$box.append($('<div class="table-responsive" style="max-height:60vh">').append($t));
				$box.append($('<div class="small text-muted mt-2">').text('굵은 단가는 전달과 달라진 달입니다.' + (shared ? ' * 표시는 같은 달에 다른 투입 건이 함께 있어 이 건의 기본만 보입니다(공제는 사람 단위).' : '')));
			}
			dpInfo(title, $box);
		});
	}

	function saveDetail() {
		var p = {};
		$('#detailForm').serializeArray().forEach(function(x) { p[x.name] = x.value; });
		delete p.STAFF_NM;
		hrPost('/admin/deploy/saveDeployData.do', p, function() { $('#detailModal').modal('hide'); load(); });
	}

	function deleteDetail() {
		bootbox.confirm('이 투입 건을 삭제할까요? 마감 전 달의 급여에서도 빠집니다.', function(ok) {
			if (!ok) return;
			hrPost('/admin/deploy/deleteDeployData.do', { DEPLOY_SQ: $('#detailForm [name=DEPLOY_SQ]').val() }, function() { $('#detailModal').modal('hide'); load(); });
		});
	}

	function nextDeploy() {
		var sq = Number($('#detailForm [name=STAFF_SQ]').val()), s = data.staff.filter(function(x) { return x.STAFF_SQ === sq; })[0];
		$('#detailModal').modal('hide');
		if (view !== 'table') $('[data-view=table]').click();
		addRow(true, { STAFF_LABEL: s ? staffLabel(s) : '', EMP_TYPE_CD: $('#detailForm [name=EMP_TYPE_CD]').val(), GRADE_CD: $('#detailForm [name=GRADE_CD]').val() });
	}

	// ── 타임라인: 지난 5달 ~ 앞으로 6달 ──

	function renderTimeline(list) {
		var start = moment().startOf('month').subtract(5, 'months'), end = start.clone().add(12, 'months'), span = end.diff(start, 'days');
		function pct(d) { return Math.max(0, Math.min(100, d.diff(start, 'days') / span * 100)); }
		var $g = $('<div class="dp-gantt">'), $head = $('<div class="dp-g-head">');
		for (var i = 0; i < 12; i++) {
			var m = start.clone().add(i, 'months');
			$head.append($('<span>').toggleClass('now', m.isSame(today, 'month')).text((m.month() === 0 || i === 0 ? m.format('YY.') : '') + (m.month() + 1) + '월'));
		}
		$g.append($('<div class="dp-g-row">').append('<div class="dp-g-who dp-mute">성명</div>').append($head));
		var seen = {};
		list.forEach(function(r) {
			if (seen[r.STAFF_SQ]) return;
			seen[r.STAFF_SQ] = 1;
			var $track = $('<div class="dp-g-track">').append($('<i class="dp-today">').css('left', pct(today) + '%'));
			data.all.filter(function(x) { return x.STAFF_SQ === r.STAFF_SQ; }).forEach(function(x) {
				var s = moment(x.START_DT), e = x.END_DT ? moment(x.END_DT).add(1, 'days') : end.clone();
				if (!e.isAfter(start) || !s.isBefore(end)) return;
				var d = x.END_DT ? moment(x.END_DT).diff(today, 'days') : 9999;
				var cls = x.END_DT && d < 0 ? 'past' : d <= 14 ? 'urgent' : d <= 30 ? 'soon' : x.END_DT ? '' : 'open';
				$track.append($('<div class="dp-b">').addClass(cls).css({ left: pct(s) + '%', width: (pct(e) - pct(s)) + '%' })
					.attr('title', (x.CLIENT_NM || '') + ' ' + (x.PRJ_NM || '') + ' ' + x.START_DT + ' ~ ' + (x.END_DT || '미정'))
					.text((x.CLIENT_NM || '') + (x.PRJ_NM ? ' · ' + x.PRJ_NM : '') + (x.END_DT ? '' : ' (철수일 미정)')));
			});
			$g.append($('<div class="dp-g-row">').append($('<div class="dp-g-who">').append($('<button type="button" class="dp-name">').text(r.STAFF_NM).on('click', function() { openDetail(r); }))
				.append($('<span class="dp-pill">').text(typeName(r.EMP_TYPE_CD)))).append($track));
		});
		if (!list.length) $g.append('<div class="text-center text-muted py-4">해당하는 투입이 없습니다.</div>');
		$('#timelineView').empty().append($g);
	}
	</script>
</body>
</html>
