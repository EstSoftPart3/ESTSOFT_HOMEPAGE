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
							<span><i class="fas fa-cog"></i> 가져오기 설정</span>
							<button type="button" id="runBtn" class="btn btn-sm btn-dark" onclick="runNow();">지금 실행</button>
						</div>
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0">
								<thead>
									<tr><th scope="col">선택</th><th scope="col">이름</th><th scope="col">iCal 캘린더</th><th scope="col">이력서 폴더</th><th scope="col">구글 계정</th><th scope="col">자동 09:00</th><th scope="col">삭제</th></tr>
								</thead>
								<tbody id="icalBody"></tbody>
							</table>
						</div>
						<div class="cal-panel-body">
							<div class="form-row">
								<div class="col-md-3 mb-2">
									<label for="icalNm">이름</label>
									<input type="text" id="icalNm" class="form-control form-control-sm" maxlength="100" autocomplete="off">
								</div>
								<div class="col-md-5 mb-2">
									<label for="icalUrl">iCal 비공개 주소</label>
									<input type="text" id="icalUrl" class="form-control form-control-sm" data-secret="1" autocomplete="off">
								</div>
								<div class="col-md-4 mb-2">
									<label for="icalFolder">이력서 폴더 주소</label>
									<input type="text" id="icalFolder" class="form-control form-control-sm" autocomplete="off">
								</div>
								<div class="col-md-3 mb-2">
									<label for="driveClientId">OAuth 클라이언트 ID</label>
									<input type="text" id="driveClientId" class="form-control form-control-sm" autocomplete="off">
								</div>
								<div class="col-md-2 mb-2">
									<label for="driveClientSecret">클라이언트 시크릿</label>
									<input type="text" id="driveClientSecret" class="form-control form-control-sm" data-secret="1" autocomplete="off">
								</div>
								<div class="col-md-4 mb-2">
									<label for="driveAccount">연결된 구글 계정</label>
									<div class="input-group input-group-sm">
										<input type="text" id="driveAccount" class="form-control" readonly>
										<div class="input-group-append">
											<button type="button" id="driveConnect" class="btn btn-outline-dark" onclick="connectDrive();">연결</button>
										</div>
									</div>
								</div>
								<div class="col-md-3 mb-2 d-flex align-items-end">
									<button type="button" class="btn btn-sm btn-dark flex-fill" onclick="saveAll();">저장</button>
									<button type="button" class="btn btn-sm btn-outline-secondary flex-fill ml-1" onclick="newSet();">새로 추가</button>
								</div>
							</div>
							<small class="text-muted">리디렉션 URI: <code id="driveRedirect"></code> · 클라이언트 ID와 시크릿은 모든 줄에 공통 적용됩니다.</small>
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
	var sets = [], selectedSq = null, drive = {};
	var MASKED = '#icalUrl, #icalFolder, #driveClientId, #driveClientSecret';

	$(function() {
		$.when($.getJSON('/admin/batch/driveStatusData.do'), $.getJSON('/admin/batch/icalListData.do')).done(function(status, list) {
			drive = status[0].drive;
			$('#driveRedirect').text(status[0].redirectUri);
			renderIcal(list[0].list);
		}).fail(function() { emptyRow('#icalBody', 7, '설정을 불러오지 못했습니다.'); });
		$.getJSON('/admin/batch/interviewBatchLogData.do', function(res) {
			renderLog(res.list);
			var pre = res.pre || {};
			$('#preStatus').text('스케줄러 확인 ' + (pre.lastCheck || '대기 중') + ' · 오늘 면접 ' + ((pre.todayTimes || []).join(', ') || '없음') + ' (각 10분 전 실행)');
		})
			.fail(function() { emptyRow('#logBody', 12, '이력을 불러오지 못했습니다.'); });

		// 가려진 값은 누르면 비우고, 아무것도 안 넣고 나오면 다시 가려 보여 준다. 그대로 두면 저장해도 바뀌지 않는다
		$(MASKED).on('focus', function() {
			if (this.value && this.value === $(this).data('mask')) this.value = '';
			if ($(this).data('secret')) $(this).addClass('secret-typing');
		}).on('blur', function() {
			if (!this.value) { this.value = $(this).data('mask') || ''; $(this).removeClass('secret-typing'); }
		});

		var result = /[?&]drive=(\w+)/.exec(location.search);
		if (result) {
			alert({ ok: '구글 드라이브를 연결했습니다.', noclient: '클라이언트 ID와 시크릿을 먼저 저장해 주세요.' }[result[1]] || '구글 드라이브 연결에 실패했습니다. 클라이언트 ID, 시크릿과 리디렉션 URI를 확인해 주세요.');
			history.replaceState(null, '', location.pathname);
		}
	});

	function emptyRow(body, cols, text) {
		$(body).empty().append($('<tr>').append($('<td class="cal-empty">').attr('colspan', cols).text(text)));
	}

	function badge(map, code) {
		var b = map[code] || [code, 'badge-secondary'];
		return $('<span class="badge">').addClass(b[1]).text(b[0]);
	}

	function setMasked(selector, mask) {
		$(selector).data('mask', mask || '').val(mask || '').removeClass('secret-typing');
	}

	// 고른 줄의 저장값을 입력 칸에 가려서 보여 준다
	function fillForm() {
		var r = sets.filter(function(s) { return s.ICAL_SQ === selectedSq; })[0] || {};
		$('#icalNm').val(r.ICAL_NM || '');
		setMasked('#icalUrl', r.ICAL_MASK);
		setMasked('#icalFolder', r.FOLDER_MASK);
		setMasked('#driveClientId', drive.clientMask);
		setMasked('#driveClientSecret', drive.secretMask);
		$('#driveAccount').val(r.DRIVE_CONNECTED ? (r.DRIVE_ACCOUNT || '연결됨') : '연결 안 됨');
		$('#driveConnect').text(r.DRIVE_CONNECTED ? '다시 연결' : '연결');
	}

	// 사용자 입력과 일정 제목이 들어가므로 모두 text() 로 넣는다
	function renderIcal(list) {
		sets = list || [];
		if (!sets.some(function(s) { return s.ICAL_SQ === selectedSq; })) selectedSq = sets.length ? sets[0].ICAL_SQ : null;
		fillForm();
		if (!sets.length) return emptyRow('#icalBody', 7, '등록된 설정이 없습니다. 아래 칸을 입력하고 저장해 주세요.');
		var $body = $('#icalBody').empty();
		sets.forEach(function(r) {
			var $radio = $('<input type="radio" name="icalSel">').attr('aria-label', r.ICAL_NM + ' 선택').prop('checked', r.ICAL_SQ === selectedSq)
				.on('change', function() { selectedSq = r.ICAL_SQ; fillForm(); });
			var $auto = $('<input type="checkbox">').attr('aria-label', r.ICAL_NM + ' 자동 실행').prop('checked', r.AUTO_YN === 'Y')
				.on('change', function() { setAuto(r.ICAL_SQ, this.checked); });
			var $del = $('<button type="button" class="btn btn-xs btn-outline-danger">삭제</button>').on('click', function() { removeIcal(r); });
			var $account = r.DRIVE_CONNECTED ? $('<span>').text(r.DRIVE_ACCOUNT || '연결됨') : $('<span class="badge badge-warning">').text('연결 필요');
			$body.append($('<tr>').append($('<td>').append($radio), $('<td class="cal-title">').text(r.ICAL_NM), $('<td>').text(r.ICAL_MASK),
				$('<td>').text(r.FOLDER_MASK || '-'), $('<td>').append($account), $('<td>').append($auto), $('<td>').append($del)));
		});
	}

	function newSet() {
		selectedSq = null;
		$('input[name=icalSel]').prop('checked', false);
		fillForm();
		$('#icalNm').focus();
	}

	function changed(selector) {
		var $el = $(selector), value = $el.val();
		return value === $el.data('mask') ? '' : value;
	}

	function saveAll() {
		var data = { name: $('#icalNm').val(), url: changed('#icalUrl'), folder: changed('#icalFolder'), clientId: changed('#driveClientId'), clientSecret: changed('#driveClientSecret') };
		if (selectedSq) data.icalSq = selectedSq;
		$.post('/admin/batch/saveIcalData.do', data, function(res) {
			if (res.error) return alert(res.error);
			drive = res.drive;
			if (!selectedSq && res.list.length) selectedSq = res.list[res.list.length - 1].ICAL_SQ;
			renderIcal(res.list);
			alert('저장했습니다.');
		}, 'json').fail(function() { alert('저장에 실패했습니다.'); });
	}

	function connectDrive() {
		if (!selectedSq) return alert('새 설정은 먼저 저장한 뒤 연결해 주세요.');
		location.href = '/admin/batch/driveStart.do?icalSq=' + selectedSq;
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
		if (!selectedSq) return alert('실행할 줄을 선택해 주세요.');
		var $btn = $('#runBtn').prop('disabled', true).text('실행 중...');
		$.post('/admin/batch/runInterviewBatchData.do', { icalSq: selectedSq }, function(res) {
			if (res.error) return alert(res.error);
			renderLog(res.list);
		}, 'json').fail(function() { alert('실행 요청에 실패했습니다.'); })
			.always(function() { $btn.prop('disabled', false).text('지금 실행'); });
	}

	function setAuto(sq, auto) {
		$.post('/admin/batch/autoIcalData.do', { icalSq: sq, auto: auto }, function(res) { renderIcal(res.list); }, 'json')
			.fail(function() {
				alert('변경에 실패했습니다.');
				$.getJSON('/admin/batch/icalListData.do', function(res) { renderIcal(res.list); });
			});
	}

	function removeIcal(r) {
		if (!confirm(r.ICAL_NM + ' 설정을 삭제할까요? 구글 계정 연결도 함께 지워지고, 지난 실행 이력은 그대로 남습니다.')) return;
		$.post('/admin/batch/deleteIcalData.do', { icalSq: r.ICAL_SQ }, function(res) { renderIcal(res.list); }, 'json')
			.fail(function() { alert('삭제에 실패했습니다.'); });
	}
	</script>
</body>
</html>
