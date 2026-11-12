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
	#body input { height: 26px; font-size: 12px; min-width: 160px; }
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
								<span>
									<select id="view" class="form-control form-control-sm d-inline-block" style="width:110px;" aria-label="보기"><option value="person">사람별</option><option value="equipment">장비별</option></select>
									<button type="button" class="btn btn-sm btn-outline-secondary" id="btnNone" aria-pressed="false" onclick="noneOnly = !noneOnly; render();">미응답만</button>
									<button type="button" class="btn btn-sm btn-outline-secondary" onclick="downloadCsv();">엑셀 내려받기</button>
									<button type="button" class="btn btn-sm btn-primary" id="btnClose" onclick="closeRound();" hidden>회차 마감</button>
								</span>
							</div>
							<div class="px-3 pt-2"><div class="au-bar" role="img" id="barWrap" aria-label="진행률"><i id="bar" style="width:0"></i></div><div class="small text-muted my-1" id="summary"></div></div>
							<div class="table-responsive px-3">
								<table class="table table-sm cal-table mb-0">
									<thead><tr><th>사용자·위치</th><th>장비번호</th><th>구분</th><th>모델</th><th>결과</th><th>입력</th><th>이번 달 메모</th><th>장비 메모</th></tr></thead>
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
	var rounds = [], current = null, rows = [], noneOnly = false;

	$(function() {
		$('#newYm').val(moment().format('YYYY-MM'));
		$('#view').on('change', render);
		loadRounds();
	});

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
		var list = rows.filter(function(r) { return !noneOnly || r.RESULT_CD === 'NONE'; }), byPerson = $('#view').val() === 'person';
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
			$b.append($('<tr>').append($who).append($('<td class="eq-no">').text(r.EQP_NO)).append($('<td>').text(TYPE[r.TYPE_CD] || r.TYPE_CD)).append($('<td>').text(r.MODEL_NM || ''))
				.append($('<td>').append(resultControl(r, open))).append($('<td class="small text-muted">').text(r.RESPONSE_CD ? (r.RESPONSE_CD === 'SELF' ? '본인' : '담당자') + ' · ' + r.CHECK_DT : ''))
				.append($('<td>').append(open ? noteControl(r) : document.createTextNode(r.NOTE || ''))).append($('<td>').append(issueCell(r, open))));
		});
	}

	function resultControl(r, open) {
		if (!open) return document.createTextNode(RESULT[r.RESULT_CD]);
		var $s = $('<select class="form-control form-control-sm">').attr('aria-label', r.EQP_NO + ' 결과');
		$.each(RESULT, function(k, v) { $s.append($('<option>').val(k).text(v)); });
		return $s.val(r.RESULT_CD).on('change', function() { save(r, this.value, r.NOTE || ''); });
	}

	function noteControl(r) {
		return $('<input class="form-control form-control-sm">').attr('aria-label', r.EQP_NO + ' 메모').val(r.NOTE || '').on('change', function() { save(r, r.RESULT_CD, this.value); });
	}

	function save(r, result, note) {
		hrPost('/admin/equipment/saveAuditResultData.do', { AUDIT_SQ: current.AUDIT_SQ, EQP_SQ: r.EQP_SQ, RESULT_CD: result, NOTE: note }, loadDetail, loadDetail);
	}

	function issueCell(r, open) {
		// 장비 메모는 장비대장에서 본다. 여기서는 건수와 이번 달 메모를 장비 메모로 남기는 버튼만
		var $c = $('<div>');
		if (r.MEMO_CNT > 0) $c.append($('<span class="eq-pill">').text('💬 ' + r.MEMO_CNT));
		if (open && r.RESULT_CD === 'BAD' && r.NOTE) $c.append($('<button type="button" class="btn btn-sm btn-outline-primary ml-1">').text('장비 메모로 남기기').on('click', function() {
			hrPost('/admin/equipment/addIssueData.do', { EQP_SQ: r.EQP_SQ, CONTENT: r.NOTE }, loadDetail);
		}));
		return $c;
	}

	function csvCell(v) {
		var s = v === undefined || v === null ? '' : String(v);
		if (/^[=+\-@\t\r]/.test(s)) s = "'" + s; // 엑셀이 수식으로 실행하지 않게 한다
		return '"' + s.replace(/"/g, '""') + '"';
	}

	function downloadCsv() {
		if (!current) return;
		var head = ['사용자·위치', '장비번호', '구분', '모델', '결과', '입력', '이번 달 메모', '장비 메모 건수'];
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
