<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<style>
	.eq-no { font-family: Consolas, monospace; font-size: 12px; white-space: nowrap; }
	.eq-pill { display: inline-block; padding: 0 8px; border-radius: 10px; font-size: 11px; font-weight: 600; white-space: nowrap; background: #eef1f4; color: #444; }
	.eq-pill.warn { background: #fff5dc; color: #7a5600; }
	.au-layout { display: grid; grid-template-columns: 170px minmax(0, 1fr); gap: 14px; align-items: start; }
	.au-round { display: flex; justify-content: space-between; gap: 6px; width: 100%; padding: 6px 10px; border: 1px solid rgba(17,17,17,.12); border-radius: 6px; background: #fff; font-size: 13px; margin-bottom: 6px; }
	.au-round.active { border-color: #0b6e8a; font-weight: 700; }
	.au-bar { height: 8px; background: #eef1f4; border-radius: 4px; overflow: hidden; }
	.au-bar i { display: block; height: 100%; background: #0b6e8a; }
	#body select { width: 96px; height: 26px; padding: 0 4px; font-size: 12px; }
	.au-tools { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; }
	.au-tools .btn-group .btn[aria-pressed="true"] { background: #0b6e8a; border-color: #0b6e8a; color: #fff; }
	.au-bulk { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; background: #e3f6fb; border: 1px solid #9fd3e3; border-radius: 6px; padding: 6px 10px; margin: 6px 0; font-size: 13px; }
	.au-note { display: block; font-size: 11px; color: #555; max-width: 260px; white-space: normal; }
	.au-chk-col { width: 34px; text-align: center; }
	@media (max-width: 768px) { .au-layout { grid-template-columns: 1fr; } }
</style>

<body class="hold-transition sidebar-mini">

	<div class="wrapper">

		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>

		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header d-flex align-items-center">
					<h3 class="card-title bTitle mr-auto"><b>전수조사</b></h3>
					<label for="newYm" class="sr-only">조사 월</label>
					<input type="month" id="newYm" class="form-control form-control-sm mr-2" style="width:160px;">
					<button type="button" class="btn btn-sm btn-primary" onclick="createRound();"><i class="fas fa-plus"></i> 새 회차</button>
				</div>

				<div class="card-body">
					<div class="au-layout">
						<div id="rounds" role="group" aria-label="조사 회차"></div>
						<div class="cal-panel">
							<div class="cal-panel-head">
								<span id="title">회차를 골라 주세요</span>
								<span class="au-tools">
									<label for="q" class="sr-only">이름·장비번호 검색</label>
									<input type="search" id="q" class="form-control form-control-sm" style="width:180px;" placeholder="이름·장비번호 검색">
									<span class="btn-group btn-group-sm" role="group" aria-label="보기">
										<button type="button" class="btn btn-outline-secondary" data-view="person" aria-pressed="true">사람별</button>
										<button type="button" class="btn btn-outline-secondary" data-view="equipment" aria-pressed="false">장비별</button>
									</span>
									<button type="button" class="btn btn-sm btn-outline-secondary" id="btnNone" aria-pressed="false" onclick="noneOnly = !noneOnly; render();">미응답만</button>
									<button type="button" class="btn btn-sm btn-outline-secondary" onclick="downloadCsv();">엑셀 내려받기</button>
									<button type="button" class="btn btn-sm btn-primary" id="btnClose" onclick="closeRound();" hidden>회차 마감</button>
								</span>
							</div>
							<div class="px-3 pt-2"><div class="au-bar" role="img" id="barWrap" aria-label="진행률"><i id="bar" style="width:0"></i></div><div class="small text-muted my-1" id="summary"></div>
								<div class="au-bulk" id="bulk" hidden role="group" aria-label="선택한 장비 결과 바꾸기">
									<b id="bulkCnt"></b>
									<span>결과를</span>
									<button type="button" class="btn btn-sm btn-outline-primary" data-result="OK">확인</button>
									<button type="button" class="btn btn-sm btn-outline-danger" data-result="BAD">이상</button>
									<button type="button" class="btn btn-sm btn-outline-secondary" data-result="NONE">미응답</button>
									<span>으로</span>
									<button type="button" class="btn btn-sm btn-link ml-auto" id="bulkClear">선택 해제</button>
								</div>
							</div>
							<div class="table-responsive px-3">
								<table class="table table-sm cal-table mb-0">
									<thead><tr><th class="au-chk-col" id="chkHead"><input type="checkbox" id="chkAll" aria-label="보이는 장비 모두 선택"></th><th>사용자·위치</th><th>장비번호</th><th>구분</th><th>모델</th><th>결과</th><th>입력</th><th>메모</th></tr></thead>
									<tbody id="body"></tbody>
								</table>
							</div>
							<div class="small text-muted px-3 py-2">계정이 연결된 직원은 홈페이지의 내 장비에서 직접 응답합니다. 게스트와 보관 장비는 담당자가 수기로 확인해 입력합니다.</div>
						</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>

	<script>
	var TYPE = hrCodeMap('EQP_TYPE');
	var RESULT = { NONE: '미응답', OK: '확인', BAD: '이상' };
	var rounds = [], current = null, rows = [], noneOnly = false, view = 'person', picked = {};
	// 전수조사 권한만 있어도 열리는 주소(/admin/equipment/*udit*)로 장비대장과 같은 장비 메모를 쓴다
	var MEMO_API = hrMemoApi('/admin/equipment/', 'audit');

	$(function() {
		$('#newYm').val(moment().format('YYYY-MM'));
		$('[data-view]').on('click', function() { view = $(this).data('view'); render(); });
		$('#q').on('input', render);
		$('#chkAll').on('change', function() { var on = this.checked; visible().forEach(function(r) { if (on) picked[r.EQP_SQ] = true; else delete picked[r.EQP_SQ]; }); render(); });
		$('#body').on('change', '.au-chk', function() { if (this.checked) picked[this.value] = true; else delete picked[this.value]; paintBulk(); });
		$('#bulk [data-result]').on('click', function() { saveMany($(this).data('result')); });
		$('#bulkClear').on('click', function() { picked = {}; render(); });
		loadRounds();
	});

	/** 미응답만·검색을 거친 지금 보이는 행 */
	function visible() {
		var q = $.trim($('#q').val()).toLowerCase();
		return rows.filter(function(r) {
			return (!noneOnly || r.RESULT_CD === 'NONE') && (!q || [r.HOLDER_NM, r.EQP_NO, r.DEPT_NM, r.MODEL_NM].join(' ').toLowerCase().indexOf(q) >= 0);
		});
	}

	function pickedSqs() {
		return visible().filter(function(r) { return picked[r.EQP_SQ]; }).map(function(r) { return r.EQP_SQ; });
	}

	function paintBulk() {
		var open = current && current.STATUS_CD === 'OPEN', n = pickedSqs().length, vis = visible().length;
		$('#bulk').prop('hidden', !open || !n);
		$('#bulkCnt').text('선택 ' + n + '대');
		$('#chkAll').prop('checked', !!vis && n === vis).prop('indeterminate', n > 0 && n < vis);
	}

	function saveMany(result) {
		var sqs = pickedSqs();
		if (!sqs.length) return;
		$('#bulk button').prop('disabled', true);
		var done = function() { $('#bulk button').prop('disabled', false); };
		hrPost('/admin/equipment/saveAuditResultsData.do', $.param({ AUDIT_SQ: current.AUDIT_SQ, RESULT_CD: result, EQP_SQ: sqs }, true), function(res) {
			done();
			picked = {};
			hrToast(res.result + '대를 ' + RESULT[result] + '(으)로 바꿨습니다');
			loadDetail();
		}, done);
	}

	function hrToast(msg) {
		var $t = $('#auToast');
		if (!$t.length) $t = $('<div id="auToast" role="status" aria-live="polite" style="position:fixed;right:18px;bottom:18px;z-index:2000;background:#222;color:#fff;font-size:13px;padding:8px 14px;border-radius:6px;display:none;">').appendTo('body');
		$t.text(msg).stop(true, true).fadeIn(100).delay(1500).fadeOut(300);
	}

	function loadRounds(pick) {
		hrPost('/admin/equipment/auditListData.do', {}, function(res) {
			rounds = res.result || [];
			var $r = $('#rounds').empty();
			if (!rounds.length) $r.append('<div class="small text-muted">회차가 없습니다.</div>');
			var want = pick || (current && current.AUDIT_SQ) || (rounds[0] && rounds[0].AUDIT_SQ);
			rounds.forEach(function(x) {
				$r.append($('<button type="button" class="au-round">').toggleClass('active', x.AUDIT_SQ === want).attr('aria-pressed', x.AUDIT_SQ === want).append($('<span>').text(x.AUDIT_YM)).append($('<span class="eq-pill">').toggleClass('warn', x.STATUS_CD === 'OPEN').text(x.STATUS_CD === 'OPEN' ? '진행' : '마감'))
					.on('click', function() { loadRounds(x.AUDIT_SQ); }));
			});
			current = rounds.filter(function(x) { return x.AUDIT_SQ === want; })[0] || null;
			if (current) loadDetail();
		});
	}

	function loadDetail() {
		hrPost('/admin/equipment/auditDetailData.do', { AUDIT_SQ: current.AUDIT_SQ }, function(res) { rows = res.result || []; render(); });
	}

	function createRound() {
		var ym = $('#newYm').val();
		bootbox.confirm(ym + ' 회차를 만들까요? 지금의 대여 현황으로 조사 대상을 만듭니다.', function(ok) {
			if (ok) hrPost('/admin/equipment/createAuditData.do', { AUDIT_YM: ym }, function(res) { loadRounds(res.result); });
		});
	}

	function closeRound() {
		var none = rows.filter(function(r) { return r.RESULT_CD === 'NONE'; }).length;
		bootbox.confirm((none ? '미응답 ' + none + '대가 남아 있습니다. ' : '') + current.AUDIT_YM + ' 회차를 마감할까요? 마감하면 고칠 수 없습니다.', function(ok) {
			if (ok) hrPost('/admin/equipment/closeAuditData.do', { AUDIT_SQ: current.AUDIT_SQ }, function() { loadRounds(current.AUDIT_SQ); });
		});
	}

	function render() {
		if (!current) return;
		var open = current.STATUS_CD === 'OPEN', n = { NONE: 0, OK: 0, BAD: 0 };
		rows.forEach(function(r) { n[r.RESULT_CD]++; });
		var done = rows.length ? Math.round((n.OK + n.BAD) * 100 / rows.length) : 0;
		$('#title').text(current.AUDIT_YM + ' 전수조사');
		$('#summary').text('대상 ' + rows.length + '대 · 확인 ' + n.OK + ' · 이상 ' + n.BAD + ' · 미응답 ' + n.NONE);
		$('#bar').css('width', done + '%');
		$('#barWrap').attr('aria-label', '진행률 ' + done + '퍼센트');
		$('#btnClose').prop('hidden', !open);
		$('#btnNone').attr('aria-pressed', noneOnly).toggleClass('active', noneOnly);
		$('[data-view]').each(function() { $(this).attr('aria-pressed', $(this).data('view') === view); });
		$('#chkHead').toggle(open);
		var list = visible(), byPerson = view === 'person';
		if (!byPerson) list = list.slice().sort(function(a, b) { return a.EQP_NO.localeCompare(b.EQP_NO); });
		var $b = $('#body').empty(), last = null;
		if (!list.length) $b.append('<tr><td colspan="8" class="cal-empty">해당하는 장비가 없습니다.</td></tr>');
		list.forEach(function(r) {
			var key = r.HOLDER_NM || '보관 장비', $who = $('<td>');
			if (!byPerson || key !== last) {
				$who.append($('<b>').text(key));
				if (r.DEPT_NM) $who.append($('<span class="small text-muted">').text(' ' + r.DEPT_NM));
				if (r.STATUS_CD === 'RENT' && r.GUEST_YN === 'Y') $who.append(' <span class="eq-pill warn">수기 확인</span>');
			}
			last = key;
			var $chk = open ? $('<td class="au-chk-col">').append($('<input type="checkbox" class="au-chk">').val(r.EQP_SQ).prop('checked', !!picked[r.EQP_SQ]).attr('aria-label', r.EQP_NO + ' 선택')) : null;
			$b.append($('<tr>').append($chk).append($who).append($('<td class="eq-no">').text(r.EQP_NO)).append($('<td>').text(TYPE[r.TYPE_CD] || r.TYPE_CD)).append($('<td>').text(r.MODEL_NM || ''))
				.append($('<td>').append(resultControl(r, open))).append($('<td class="small text-muted">').text(r.RESPONSE_CD ? (r.RESPONSE_CD === 'SELF' ? '본인' : '담당자') + ' · ' + r.CHECK_DT : ''))
				.append($('<td>').append(memoCell(r))));
		});
		paintBulk();
	}

	function resultControl(r, open) {
		if (!open) return document.createTextNode(RESULT[r.RESULT_CD]);
		var $s = $('<select class="form-control form-control-sm">').attr('aria-label', r.EQP_NO + ' 결과');
		$.each(RESULT, function(k, v) { $s.append($('<option>').val(k).text(v)); });
		return $s.val(r.RESULT_CD).on('change', function() { save(r, this.value, r.NOTE || ''); });
	}

	function save(r, result, note) {
		hrPost('/admin/equipment/saveAuditResultData.do', { AUDIT_SQ: current.AUDIT_SQ, EQP_SQ: r.EQP_SQ, RESULT_CD: result, NOTE: note }, loadDetail, loadDetail);
	}

	/** 다른 목록과 같은 공통 메모(💬 건수 → 메모 창). 직원이 내 장비에서 응답하며 남긴 글은 아래에 그대로 보인다 */
	function memoCell(r) {
		var $c = $('<div>').append(hrMemoBtn(MEMO_API, r.EQP_SQ, r.MEMO_CNT, r.EQP_NO, loadDetail));
		if (r.NOTE) $c.append($('<span class="au-note">').text('응답 메모: ' + r.NOTE));
		return $c;
	}

	function csvCell(v) {
		var s = v === undefined || v === null ? '' : String(v);
		if (/^[=+\-@\t\r]/.test(s)) s = "'" + s; // 엑셀이 수식으로 실행하지 않게 한다
		return '"' + s.replace(/"/g, '""') + '"';
	}

	function downloadCsv() {
		if (!current) return;
		var head = ['사용자·위치', '장비번호', '구분', '모델', '결과', '입력', '응답 메모', '장비 메모 건수'];
		var lines = [head.map(csvCell).join(',')].concat(rows.map(function(r) {
			return [r.HOLDER_NM, r.EQP_NO, TYPE[r.TYPE_CD], r.MODEL_NM, RESULT[r.RESULT_CD], r.RESPONSE_CD === 'SELF' ? '본인' : r.RESPONSE_CD ? '담당자' : '', r.NOTE, r.MEMO_CNT].map(csvCell).join(',');
		}));
		var a = document.createElement('a');
		a.href = URL.createObjectURL(new Blob(['﻿' + lines.join('\r\n')], { type: 'text/csv;charset=utf-8' }));
		a.download = '전수조사_' + current.AUDIT_YM + '.csv';
		a.click();
		URL.revokeObjectURL(a.href);
	}
	</script>
</body>
</html>
