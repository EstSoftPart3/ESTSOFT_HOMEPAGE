<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/deploy/deploy_common.jspf"%>
<style>
	#bList td { vertical-align: middle; }
	.bn-steps input, .bn-steps select { min-width: 0; }
	.bn-rule { padding: 10px 14px; font-size: 12.5px; margin-bottom: 12px; }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header d-flex align-items-center">
					<h3 class="card-title bTitle"><b>상여관리</b></h3>
					<button type="button" class="btn btn-sm btn-primary ml-auto" id="btnNew">+ 상여 항목 등록</button>
				</div>
				<div class="card-body">
					<div class="cal-panel bn-rule">모든 상여는 <b>기준일</b>부터 <b>n개월</b>을 채우면(만근·근속 조건) <b>달성한 달의 익월 급여</b> 상여 칸에 들어갑니다. 여기서는 조건만 정하고, 누구에게 줄지는 <b>직원관리</b> 목록의 상여 칩으로 켭니다.</div>
					<div class="cal-panel">
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0">
								<thead><tr><th>사용</th><th>상여 항목</th><th>기준일</th><th>지급 단계 (n개월 → 금액)</th><th class="dp-num">합계</th><th>받는 사람</th><th>사람별 금액</th><th class="dp-num">적용 인원</th><th></th></tr></thead>
								<tbody id="bList"></tbody>
							</table>
						</div>
						<div class="small text-muted px-3 py-2">사용을 끄면 다음 계산부터 빠집니다(마감된 달은 그대로). 켠 직원이 있는 항목은 지울 수 없어 사용을 끕니다.</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="bModal" tabindex="-1" role="dialog" aria-labelledby="bTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="bTitle">상여 항목</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<form id="bForm" onsubmit="save(); return false;">
					<div class="modal-body">
						<div class="form-row">
							<div class="form-group col-md-6"><label for="bNm">상여 항목 이름</label><input id="bNm" class="form-control form-control-sm" maxlength="50" required></div>
							<div class="form-group col-md-6"><label for="bTarget">받는 사람</label>
								<select id="bTarget" class="form-control form-control-sm"><option value="SELF">본인</option><option value="REFERRER">추천인 (기준일은 추천한 인재 것)</option></select></div>
							<div class="form-group col-md-6"><label for="bBase">기준일</label>
								<select id="bBase" class="form-control form-control-sm"><option value="JOIN">입사일</option><option value="CONTRACT">계약(투입) 시작일</option><option value="JOIN_OR_CONTRACT">입사일 또는 계약 시작일 (정규·수습은 입사일)</option></select></div>
							<div class="form-group col-md-6 d-flex align-items-end" style="gap:16px">
								<div class="custom-control custom-switch"><input type="checkbox" class="custom-control-input" id="bUse"><label class="custom-control-label" for="bUse">사용</label></div>
								<div class="form-check"><input type="checkbox" class="form-check-input" id="bPer"><label class="form-check-label" for="bPer">직원관리에서 사람마다 금액을 바꿀 수 있음</label></div>
							</div>
						</div>
						<div class="font-weight-bold mb-1">지급 단계 <span class="small text-muted font-weight-normal">· 달성한 달의 익월 급여</span></div>
						<table class="table table-sm table-bordered bn-steps mb-1">
							<thead><tr><th style="width:30%">기준일부터 (개월, 0 = 계약 시)</th><th style="width:30%">조건</th><th class="dp-num">금액</th><th style="width:44px"></th></tr></thead>
							<tbody id="bSteps"></tbody>
						</table>
						<div class="d-flex justify-content-between align-items-center"><button type="button" class="btn btn-sm btn-outline-secondary" id="btnStep">+ 단계 추가</button><b id="bSum"></b></div>
						<div class="small text-muted mt-2">만근 = 기준일부터 달성일 전날까지 매일 근무(투입 기간, 정규·수습은 재직 기간). 근속 = 달성일 전날 근무 중. 못 채우면 지급하지 않고 급여관리에 '만근미달' 칩이 뜹니다.</div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-sm btn-outline-danger mr-auto" id="btnDel">삭제</button>
						<button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">취소</button>
						<button type="submit" class="btn btn-sm btn-primary">저장</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>

	<script>
	var items = [], applies = [], editing = null;

	$(function() {
		$('#btnNew').on('click', function() { edit(null); });
		$('#btnStep').on('click', function() { stepRow({ m: '', c: 'FULL', a: '' }); sum(); });
		$('#bSteps').on('input change', 'input, select', sum);
		$('#btnDel').on('click', del);
		load();
	});

	function load() {
		hrPost('/admin/bonus/bonusListData.do', {}, function(res) { items = res.result.items; applies = res.result.applies; render(); });
	}

	function render() {
		var $b = $('#bList').empty();
		if (!items.length) $b.append('<tr><td colspan="9" class="text-center text-muted py-4">상여 항목이 없습니다.</td></tr>');
		items.forEach(function(b) {
			var steps = dpSteps(b.STEPS), on = b.USE_YN === 'Y', id = 'use' + b.BONUS_SQ;
			var $sw = $('<div class="custom-control custom-switch">').append($('<input type="checkbox" class="custom-control-input">').attr('id', id).prop('checked', on).on('change', function() {
				var box = this;
				hrPost('/admin/bonus/useBonusData.do', { BONUS_SQ: b.BONUS_SQ, USE_YN: box.checked ? 'Y' : 'N' }, load, function() { box.checked = !box.checked; });
			})).append($('<label class="custom-control-label">').attr('for', id).append($('<span class="sr-only">').text(b.BONUS_NM + ' 사용')));
			var n = Number(b.APPLY_CNT || 0);
			$b.append($('<tr>').toggleClass('text-muted', !on).append($('<td>').append($sw)).append($('<td>').append($('<b>').text(b.BONUS_NM)))
				.append($('<td>').text(dpBaseText(b))).append($('<td>').text(steps.map(dpStepText).join(' · ')))
				.append($('<td class="dp-num">').text(dpWon(steps.reduce(function(s, x) { return s + x.a; }, 0))))
				.append($('<td>').append(b.TARGET_CD === 'REFERRER' ? $('<span class="dp-pill warn">').text('추천인') : '본인'))
				.append($('<td>').append(b.PER_AMT_YN === 'Y' ? $('<span class="dp-pill ok">').text('가능') : $('<span class="dp-mute">').text('—')))
				.append($('<td class="dp-num">').append($('<button type="button" class="btn btn-sm btn-link p-0">').text(n + '명').prop('disabled', !n).attr('aria-label', b.BONUS_NM + ' 적용 인원 ' + n + '명').on('click', function() { who(b); })))
				.append($('<td>').append($('<button type="button" class="btn btn-sm btn-outline-secondary">수정</button>').on('click', function() { edit(b); }))));
		});
	}

	// 적용 인원 명단
	function who(b) {
		var list = applies.filter(function(a) { return a.BONUS_SQ === b.BONUS_SQ; });
		dpInfo(b.BONUS_NM + ' · 적용 ' + list.length + '명', list.map(function(a) {
			return [a.STAFF_NM, [a.AMT !== null && a.AMT !== undefined ? dpWon(a.AMT) + '원' : '', a.REFERRER_NM ? '추천인 ' + a.REFERRER_NM : (b.TARGET_CD === 'REFERRER' ? '추천인 미지정' : ''), (a.EMPLY_NM || a.EMPLY_ID) + ' · ' + a.REG_DT].filter(Boolean).join(' · ')];
		}));
	}

	function edit(b) {
		editing = b;
		$('#bTitle').text(b ? '상여 항목 수정 · ' + b.BONUS_NM : '상여 항목 등록');
		$('#bNm').val(b ? b.BONUS_NM : '');
		$('#bBase').val(b ? b.BASE_CD : 'JOIN');
		$('#bTarget').val(b ? b.TARGET_CD : 'SELF');
		$('#bUse').prop('checked', b ? b.USE_YN === 'Y' : true);
		$('#bPer').prop('checked', !!b && b.PER_AMT_YN === 'Y');
		$('#bSteps').empty();
		(b ? dpSteps(b.STEPS) : [{ m: 3, c: 'FULL', a: '' }]).forEach(stepRow);
		$('#btnDel').toggle(!!b);
		sum();
		$('#bModal').modal('show');
	}

	function stepRow(s) {
		var $c = $('<select class="form-control form-control-sm" aria-label="조건">');
		$.each(DP_COND, function(k, v) { $c.append($('<option>').val(k).text(v)); });
		$('#bSteps').append($('<tr>').append($('<td>').append($('<input type="number" class="form-control form-control-sm" min="0" max="120" required aria-label="개월">').val(s.m)))
			.append($('<td>').append($c.val(s.c)))
			.append($('<td>').append($('<input class="form-control form-control-sm text-right" inputmode="numeric" required aria-label="금액">').val(s.a === '' ? '' : Number(s.a).toLocaleString('ko-KR'))))
			.append($('<td>').append($('<button type="button" class="btn btn-sm btn-outline-secondary" aria-label="단계 빼기">−</button>').on('click', function() {
				if ($('#bSteps tr').length > 1) { $(this).closest('tr').remove(); sum(); }
			}))));
	}

	function steps() {
		return $('#bSteps tr').map(function() {
			var $i = $(this).find('input, select');
			return $i.eq(0).val() + ':' + $i.eq(1).val() + ':' + String($i.eq(2).val()).replace(/[^0-9]/g, '');
		}).get();
	}

	function sum() {
		var t = 0;
		$('#bSteps tr').each(function() { t += Number(String($(this).find('input').eq(1).val()).replace(/[^0-9]/g, '')) || 0; });
		$('#bSum').text('합계 ' + dpWon(t));
	}

	function save() {
		hrPost('/admin/bonus/saveBonusData.do', { BONUS_SQ: editing ? editing.BONUS_SQ : '', BONUS_NM: $('#bNm').val(), BASE_CD: $('#bBase').val(), TARGET_CD: $('#bTarget').val(),
			STEPS: steps().join(','), PER_AMT_YN: $('#bPer').is(':checked') ? 'Y' : 'N', USE_YN: $('#bUse').is(':checked') ? 'Y' : 'N' }, function() { $('#bModal').modal('hide'); load(); });
	}

	function del() {
		bootbox.confirm(editing.BONUS_NM + ' 항목을 지울까요?', function(ok) {
			if (ok) hrPost('/admin/bonus/deleteBonusData.do', { BONUS_SQ: editing.BONUS_SQ }, function() { $('#bModal').modal('hide'); load(); });
		});
	}
	</script>
</body>
</html>
