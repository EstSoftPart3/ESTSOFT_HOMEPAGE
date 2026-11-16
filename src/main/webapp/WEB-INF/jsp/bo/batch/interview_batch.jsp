<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>

<%-- 비밀값 칸을 type=password 로 두면 브라우저가 계정 비밀번호를 자동으로 채운다. 입력하는 동안 글자 칸에 가림 처리만 한다 --%>
<style>.secret-typing { -webkit-text-security: disc; }</style>

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
							<span><i class="fas fa-cog"></i> 가져오기</span>
							<button type="button" id="runBtn" class="btn btn-sm btn-dark" onclick="runNow();">지금 실행</button>
						</div>
						<%-- 읽을 캘린더·이력서 폴더는 시스템 관리자가 🔗 내 연동에서 한 번 정한다. 여기서는 보기·자동 실행·지금 실행만 --%>
						<div class="cal-panel-body" id="icalBody">
							<div class="d-flex flex-wrap align-items-center" style="gap:6px 18px">
								<span><b>면접 캘린더</b> <span id="srcCal">-</span></span>
								<span><b>이력서 폴더</b> <span id="srcFolder">-</span></span>
								<span><b>공용 드라이브</b> <span id="srcDrive">-</span></span>
								<label class="mb-0"><input type="checkbox" id="srcAuto" disabled> 자동 09:00·면접 10분 전</label>
							</div>
							<small class="text-muted d-block mt-1">캘린더·이력서 폴더는 시스템 관리자가 🔗 내 연동의 「신입면접 배치가 읽을 곳」에서 정합니다.<c:if test="${superUser}"> <a href="/admin/my/openGoogleLink.do">설정하러 가기</a></c:if></small>
						</div>
					</div>

					<div class="cal-panel">
						<div class="cal-panel-head"><span><i class="fas fa-history"></i> 실행 이력</span><small id="preStatus" class="text-muted"></small></div>
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0">
								<thead>
									<tr>
										<th scope="col">실행 시각</th><th scope="col">구분</th><th scope="col">이름</th><th scope="col">결과</th><th scope="col">대상 주</th>
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
									<tr><th scope="col">처리</th><th scope="col">면접일</th><th scope="col">시간</th><th scope="col">이름</th><th scope="col">일정 제목</th><th scope="col">사유</th><th scope="col">이력서</th></tr>
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
	var selectedSq = null;

	$(function() {
		$.getJSON('/admin/batch/icalListData.do', function(res) { renderSource(res.list); })
			.fail(function() { $('#srcCal').text('설정을 불러오지 못했습니다.'); });
		$.getJSON('/admin/batch/interviewBatchLogData.do', function(res) {
			renderLog(res.list);
			var pre = res.pre || {};
			$('#preStatus').text('스케줄러 확인 ' + (pre.lastCheck || '대기 중') + ' · 오늘 면접 ' + ((pre.todayTimes || []).join(', ') || '없음') + ' (각 10분 전 실행)');
		})
			.fail(function() { emptyRow('#logBody', 12, '이력을 불러오지 못했습니다.'); });
		$('#srcAuto').on('change', function() { setAuto(selectedSq, this.checked); });
	});

	function emptyRow(body, cols, text) {
		$(body).empty().append($('<tr>').append($('<td class="cal-empty">').attr('colspan', cols).text(text)));
	}

	function badge(map, code) {
		var b = map[code] || [code, 'badge-secondary'];
		return $('<span class="badge">').addClass(b[1]).text(b[0]);
	}

	// 면접 일정 세트는 하나(첫 줄). 사용자 입력이 들어가므로 text() 로 넣는다
	function renderSource(list) {
		var r = (list || [])[0];
		selectedSq = r ? r.ICAL_SQ : null;
		$('#srcCal').text(r ? (r.ICAL_MASK ? r.ICAL_NM + ' (예전 iCal)' : r.ICAL_NM) : '미설정');
		$('#srcFolder').text(r && r.FOLDER_MASK || '미설정');
		$('#srcDrive').text(r && r.DRIVE_CONNECTED ? (r.DRIVE_ACCOUNT || '연결됨') : '미연결');
		$('#srcAuto').prop('disabled', !r).prop('checked', !!r && r.AUTO_YN === 'Y');
	}
	function renderLog(list) {
		if (!list || !list.length) return emptyRow('#logBody', 12, '아직 실행 이력이 없습니다.');
		var $body = $('#logBody').empty();
		list.forEach(function(r) {
			var $tr = $('<tr>');
			[r.START_DT, { AUTO: '자동', PRE: '면접 전' }[r.TRIGGER_CD] || '수동', r.ICAL_NM || '-'].forEach(function(v) { $tr.append($('<td>').text(v)); });
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
		emptyRow('#detailBody', 7, '불러오는 중입니다.');
		$('#detailModal').modal('show');
		$.getJSON('/admin/batch/interviewBatchDetailData.do', { logSq: r.BATCH_LOG_SQ }, function(res) {
			if (!res.list || !res.list.length) return emptyRow('#detailBody', 7, r.ERROR_MSG || '상세 내역이 없습니다. 기능 추가 전 실행이거나 대상 주에 일정이 없었습니다.');
			var $body = $('#detailBody').empty();
			res.list.forEach(function(d) {
				$body.append($('<tr>').append(
					$('<td>').append(badge(RESULT, d.RESULT_CD)),
					$('<td>').text(d.INTV_DT || ''), $('<td>').text(d.INTV_TM || ''), $('<td class="cal-title">').text(d.APLY_NM || ''),
					$('<td>').text(d.EVT_TITLE || ''), $('<td>').text(d.REASON || ''), $('<td>').text(d.RESUME_NOTE || '')));
			});
		}).fail(function() { emptyRow('#detailBody', 7, '상세 내역을 불러오지 못했습니다.'); });
	}

	function runNow() {
		if (!selectedSq) return alert('면접 캘린더가 정해지지 않았습니다. 시스템 관리자가 🔗 내 연동에서 정해 주세요.');
		var $btn = $('#runBtn').prop('disabled', true).text('실행 중...');
		$.post('/admin/batch/runInterviewBatchData.do', { icalSq: selectedSq }, function(res) {
			if (res.error) return alert(res.error);
			renderLog(res.list);
		}, 'json').fail(function() { alert('실행 요청에 실패했습니다.'); })
			.always(function() { $btn.prop('disabled', false).text('지금 실행'); });
	}

	function setAuto(sq, auto) {
		$.post('/admin/batch/autoIcalData.do', { icalSq: sq, auto: auto }, function(res) { renderSource(res.list); }, 'json')
			.fail(function() {
				alert('변경에 실패했습니다.');
				$.getJSON('/admin/batch/icalListData.do', function(res) { renderSource(res.list); });
			});
	}
	</script>
</body>
</html>
