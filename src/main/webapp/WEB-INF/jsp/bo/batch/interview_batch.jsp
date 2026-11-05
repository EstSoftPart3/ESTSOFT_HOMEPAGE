<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>

<body class="hold-transition sidebar-mini">

	<div class="wrapper">

		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>

		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header">
					<h3 class="card-title bTitle"><b>신입면접 배치</b></h3>
				</div>

				<div class="card-body">

					<div class="cal-panel">
						<div class="cal-panel-head">
							<span><i class="fas fa-calendar-alt"></i> iCal 주소</span>
							<button type="button" id="runBtn" class="btn btn-sm btn-dark" onclick="runNow();">선택한 주소로 지금 실행</button>
						</div>
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0">
								<thead>
									<tr>
										<th scope="col" style="width:60px;">선택</th><th scope="col">이름</th><th scope="col" style="width:110px;">매일 09:00 자동</th><th scope="col" style="width:110px;">등록일</th><th scope="col" style="width:70px;">삭제</th>
									</tr>
								</thead>
								<tbody id="icalBody"></tbody>
							</table>
						</div>
						<div class="cal-panel-body">
							<div class="form-row">
								<div class="col-md-3 mb-2">
									<label for="icalNm">이름</label>
									<input type="text" id="icalNm" class="form-control form-control-sm" maxlength="100" placeholder="예: 인터뷰 일정">
								</div>
								<div class="col-md-7 mb-2">
									<label for="icalUrl">iCal 형식의 비공개 주소</label>
									<input type="password" id="icalUrl" class="form-control form-control-sm" autocomplete="new-password" placeholder="https://calendar.google.com/calendar/ical/.../private-.../basic.ics">
								</div>
								<div class="col-md-2 mb-2 d-flex align-items-end">
									<button type="button" class="btn btn-sm btn-dark btn-block" onclick="saveIcal();">추가</button>
								</div>
							</div>
							<small class="text-muted">구글 캘린더 → 설정 → 해당 캘린더 → 캘린더 통합 → iCal 형식의 비공개 주소. 새 주소는 자동 실행이 꺼진 상태로 추가됩니다.</small>
						</div>
					</div>

					<div class="cal-panel">
						<div class="cal-panel-head"><span><i class="fas fa-history"></i> 실행 이력 (최근 30회) · 면접관리 해당 주 기준</span></div>
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0">
								<thead>
									<tr>
										<th scope="col">실행 시각</th><th scope="col">구분</th><th scope="col">주소</th><th scope="col">결과</th><th scope="col">대상 주</th>
										<th scope="col">읽음</th><th scope="col">추가</th><th scope="col">수정</th><th scope="col">변경 없음</th><th scope="col">제외</th><th scope="col">실패</th><th scope="col">상세</th>
									</tr>
								</thead>
								<tbody id="logBody"></tbody>
							</table>
						</div>
					</div>

				</div>
			</section>
		</div>

		<div class="modal fade" id="detailModal" tabindex="-1" role="dialog" aria-labelledby="detailTitle" aria-hidden="true">
			<div class="modal-dialog modal-xl modal-dialog-scrollable" role="document">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title" id="detailTitle">실행 상세</h5>
						<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
					</div>
					<div class="modal-body p-0">
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0">
								<thead>
									<tr><th scope="col">처리</th><th scope="col">면접일</th><th scope="col">시간</th><th scope="col">이름</th><th scope="col">일정 제목</th><th scope="col">사유</th></tr>
								</thead>
								<tbody id="detailBody"></tbody>
							</table>
						</div>
					</div>
				</div>
			</div>
		</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>

	<script>
	var STATUS = { OK: ['성공', 'badge-success'], WARN: ['일부 실패', 'badge-warning'], FAIL: ['실패', 'badge-danger'] };
	var RESULT = { INSERT: ['추가', 'badge-success'], UPDATE: ['수정', 'badge-info'], SAME: ['변경 없음', 'badge-secondary'], EXCL: ['제외', 'badge-light'], SKIP: ['실패', 'badge-danger'] };

	$(function() {
		$.getJSON('/admin/batch/icalListData.do', function(res) { renderIcal(res.list); })
			.fail(function() { emptyRow('#icalBody', 5, '주소 목록을 불러오지 못했습니다.'); });
		$.getJSON('/admin/batch/interviewBatchLogData.do', function(res) { renderLog(res.list); })
			.fail(function() { emptyRow('#logBody', 12, '이력을 불러오지 못했습니다.'); });
	});

	function emptyRow(body, cols, text) {
		$(body).empty().append($('<tr>').append($('<td class="cal-empty">').attr('colspan', cols).text(text)));
	}

	function badge(map, code) {
		var b = map[code] || [code, 'badge-secondary'];
		return $('<span class="badge">').addClass(b[1]).text(b[0]);
	}

	// 사용자 입력과 일정 제목이 들어가므로 모두 text() 로 넣는다
	function renderIcal(list) {
		if (!list || !list.length) return emptyRow('#icalBody', 5, '등록된 주소가 없습니다. 아래에서 추가해 주세요.');
		var selected = $('input[name=icalSel]:checked').val();
		var $body = $('#icalBody').empty();
		list.forEach(function(r, i) {
			var label = r.ICAL_NM + ' 선택';
			var $radio = $('<input type="radio" name="icalSel">').val(r.ICAL_SQ).attr('aria-label', label)
				.prop('checked', selected ? String(r.ICAL_SQ) === selected : i === 0);
			var $auto = $('<input type="checkbox">').attr('aria-label', r.ICAL_NM + ' 자동 실행').prop('checked', r.AUTO_YN === 'Y')
				.on('change', function() { setAuto(r.ICAL_SQ, this.checked); });
			var $del = $('<button type="button" class="btn btn-xs btn-outline-danger">삭제</button>').on('click', function() { removeIcal(r); });
			$body.append($('<tr>').append($('<td>').append($radio), $('<td class="cal-title">').text(r.ICAL_NM), $('<td>').append($auto), $('<td>').text(r.REG_DT), $('<td>').append($del)));
		});
	}

	function renderLog(list) {
		if (!list || !list.length) return emptyRow('#logBody', 12, '아직 실행 이력이 없습니다.');
		var $body = $('#logBody').empty();
		list.forEach(function(r) {
			var $tr = $('<tr>');
			[r.START_DT, r.TRIGGER_CD === 'AUTO' ? '자동' : '수동', r.ICAL_NM || '-'].forEach(function(v) { $tr.append($('<td>').text(v)); });
			$tr.append($('<td>').append(badge(STATUS, r.STATUS_CD)));
			$tr.append($('<td>').text(r.FROM_DT + ' ~ ' + r.TO_DT));
			[r.READ_CNT, r.INSERT_CNT, r.UPDATE_CNT, r.SAME_CNT, r.EXCL_CNT, r.SKIP_CNT].forEach(function(v) { $tr.append($('<td>').text(v)); });
			$tr.append($('<td>').append($('<button type="button" class="btn btn-xs btn-outline-dark">보기</button>').on('click', function() { openDetail(r); })));
			$body.append($tr);
			var note = r.ERROR_MSG || r.SKIP_DETAIL;
			if (note) {
				$body.append($('<tr>').append($('<td colspan="12" class="small text-muted" style="white-space:pre-line;">').text(note)));
			}
		});
	}

	function openDetail(r) {
		$('#detailTitle').text('실행 상세 · ' + r.START_DT + (r.ICAL_NM ? ' · ' + r.ICAL_NM : ''));
		emptyRow('#detailBody', 6, '불러오는 중입니다.');
		$('#detailModal').modal('show');
		$.getJSON('/admin/batch/interviewBatchDetailData.do', { logSq: r.BATCH_LOG_SQ }, function(res) {
			if (!res.list || !res.list.length) return emptyRow('#detailBody', 6, r.ERROR_MSG || '상세 내역이 없습니다. 기능 추가 전 실행이거나 대상 주에 일정이 없었습니다.');
			var $body = $('#detailBody').empty();
			res.list.forEach(function(d) {
				$body.append($('<tr>').append(
					$('<td>').append(badge(RESULT, d.RESULT_CD)),
					$('<td>').text(d.INTV_DT || ''), $('<td>').text(d.INTV_TM || ''), $('<td class="cal-title">').text(d.APLY_NM || ''),
					$('<td>').text(d.EVT_TITLE || ''), $('<td>').text(d.REASON || '')));
			});
		}).fail(function() { emptyRow('#detailBody', 6, '상세 내역을 불러오지 못했습니다.'); });
	}

	function runNow() {
		var sq = $('input[name=icalSel]:checked').val();
		if (!sq) return alert('실행할 주소를 선택해 주세요.');
		var $btn = $('#runBtn').prop('disabled', true).text('실행 중...');
		$.post('/admin/batch/runInterviewBatchData.do', { icalSq: sq }, function(res) {
			if (res.error) return alert(res.error);
			renderLog(res.list);
		}, 'json').fail(function() { alert('실행 요청에 실패했습니다.'); })
			.always(function() { $btn.prop('disabled', false).text('선택한 주소로 지금 실행'); });
	}

	function saveIcal() {
		$.post('/admin/batch/saveIcalData.do', { name: $('#icalNm').val(), url: $('#icalUrl').val() }, function(res) {
			if (res.error) return alert(res.error);
			$('#icalNm, #icalUrl').val('');
			renderIcal(res.list);
		}, 'json').fail(function() { alert('저장에 실패했습니다.'); });
	}

	function setAuto(sq, auto) {
		$.post('/admin/batch/autoIcalData.do', { icalSq: sq, auto: auto }, function(res) { renderIcal(res.list); }, 'json')
			.fail(function() { alert('변경에 실패했습니다.'); $.getJSON('/admin/batch/icalListData.do', function(res) { renderIcal(res.list); }); });
	}

	function removeIcal(r) {
		if (!confirm(r.ICAL_NM + ' 주소를 삭제할까요? 지난 실행 이력은 그대로 남습니다.')) return;
		$.post('/admin/batch/deleteIcalData.do', { icalSq: r.ICAL_SQ }, function(res) { renderIcal(res.list); }, 'json')
			.fail(function() { alert('삭제에 실패했습니다.'); });
	}
	</script>
</body>
</html>
