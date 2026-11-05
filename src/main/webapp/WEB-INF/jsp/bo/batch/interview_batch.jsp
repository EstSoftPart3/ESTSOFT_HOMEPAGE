<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

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
							<span><i class="fas fa-clock"></i> 매일 09:00 · 인터뷰 일정 캘린더 → 면접관리(해당 주)</span>
							<button type="button" id="runBtn" class="btn btn-sm btn-dark" onclick="runNow();">지금 실행</button>
						</div>
						<div class="cal-panel-body">
							<div class="form-row">
								<div class="col-md-10 mb-2">
									<label for="icalUrl">iCal 비공개 주소
										<c:choose>
											<c:when test="${urlReady}"><span class="badge badge-success">설정됨</span></c:when>
											<c:otherwise><span class="badge badge-warning">설정 필요</span></c:otherwise>
										</c:choose>
									</label>
									<input type="password" id="icalUrl" class="form-control form-control-sm" autocomplete="new-password"
										placeholder="${urlReady ? '저장됨 - 바꿀 때만 입력' : 'https://calendar.google.com/calendar/ical/.../basic.ics'}">
								</div>
								<div class="col-md-2 mb-2 d-flex align-items-end">
									<button type="button" class="btn btn-sm btn-dark btn-block" onclick="saveUrl();">저장</button>
								</div>
							</div>
							<small class="text-muted">est.supprt 계정 구글 캘린더 → 설정 → 인터뷰 일정 → 일정 통합 → 비공개 주소(iCal 형식)</small>
						</div>
					</div>

					<div class="cal-panel">
						<div class="cal-panel-head"><span><i class="fas fa-history"></i> 실행 이력 (최근 30회)</span></div>
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0">
								<thead>
									<tr>
										<th scope="col">실행 시각</th><th scope="col">구분</th><th scope="col">결과</th><th scope="col">대상 주</th>
										<th scope="col">읽음</th><th scope="col">추가</th><th scope="col">수정</th><th scope="col">변경 없음</th><th scope="col">제외</th><th scope="col">해석 실패</th>
									</tr>
								</thead>
								<tbody id="logBody"></tbody>
							</table>
						</div>
					</div>

				</div>
			</section>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>

	<script>
	var STATUS = { OK: ['성공', 'badge-success'], WARN: ['일부 제외', 'badge-warning'], FAIL: ['실패', 'badge-danger'] };

	$(function() {
		$.getJSON('/admin/batch/interviewBatchLogData.do', function(res) { render(res.list); })
			.fail(function() { message('이력을 불러오지 못했습니다.'); });
	});

	function message(text) {
		$('#logBody').empty().append($('<tr>').append($('<td colspan="10" class="cal-empty">').text(text)));
	}

	// 일정 제목이 들어가므로 모두 text() 로 넣는다
	function render(list) {
		if (!list || !list.length) return message('아직 실행 이력이 없습니다.');
		var $body = $('#logBody').empty();
		list.forEach(function(r) {
			var st = STATUS[r.STATUS_CD] || [r.STATUS_CD, 'badge-secondary'];
			var $tr = $('<tr>');
			[r.START_DT, r.TRIGGER_CD === 'AUTO' ? '자동' : '수동'].forEach(function(v) { $tr.append($('<td>').text(v)); });
			$tr.append($('<td>').append($('<span class="badge">').addClass(st[1]).text(st[0])));
			$tr.append($('<td>').text(r.FROM_DT + ' ~ ' + r.TO_DT));
			[r.READ_CNT, r.INSERT_CNT, r.UPDATE_CNT, r.SAME_CNT, r.EXCL_CNT, r.SKIP_CNT].forEach(function(v) { $tr.append($('<td>').text(v)); });
			$body.append($tr);
			var detail = r.ERROR_MSG || r.SKIP_DETAIL;
			if (detail) {
				$body.append($('<tr>').append($('<td colspan="10" class="small text-muted" style="white-space:pre-line;">').text(detail)));
			}
		});
	}

	function runNow() {
		var $btn = $('#runBtn').prop('disabled', true).text('실행 중...');
		$.post('/admin/batch/runInterviewBatchData.do', function(res) { render(res.list); }, 'json')
			.fail(function() { alert('실행 요청에 실패했습니다.'); })
			.always(function() { $btn.prop('disabled', false).text('지금 실행'); });
	}

	function saveUrl() {
		$.post('/admin/batch/saveInterviewBatchUrlData.do', { url: $('#icalUrl').val() }, function(res) {
			if (res.error) return alert(res.error);
			location.reload();
		}, 'json').fail(function() { alert('저장에 실패했습니다.'); });
	}
	</script>
</body>
</html>
