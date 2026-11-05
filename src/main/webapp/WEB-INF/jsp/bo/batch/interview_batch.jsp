<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>

<%-- 비밀값 칸을 type=password 로 두면 브라우저가 계정 비밀번호를 자동으로 채운다. 글자 칸에 가림 처리만 한다 --%>
<style>.secret-input { -webkit-text-security: disc; }</style>

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
							<span><i class="fas fa-layer-group"></i> 가져오기 세트 (면접 일정 iCal + 이력서 드라이브)</span>
							<button type="button" id="runBtn" class="btn btn-sm btn-dark" onclick="runNow();">선택한 세트로 지금 실행</button>
						</div>
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0">
								<thead>
									<tr>
										<th scope="col">선택</th><th scope="col">이름</th><th scope="col">iCal 캘린더</th><th scope="col">이력서 폴더</th><th scope="col">드라이브 계정</th><th scope="col">매일 09:00 자동</th><th scope="col">관리</th>
									</tr>
								</thead>
								<tbody id="icalBody"></tbody>
							</table>
						</div>
						<div class="cal-panel-body">
							<div class="form-row">
								<div class="col-md-2 mb-2">
									<label for="icalNm">이름</label>
									<input type="text" id="icalNm" class="form-control form-control-sm" maxlength="100" autocomplete="off" placeholder="예: 인터뷰 일정">
								</div>
								<div class="col-md-4 mb-2">
									<label for="icalUrl">iCal 형식의 비공개 주소</label>
									<input type="text" id="icalUrl" class="form-control form-control-sm secret-input" autocomplete="off" placeholder="https://calendar.google.com/calendar/ical/.../private-.../basic.ics">
								</div>
								<div class="col-md-4 mb-2">
									<label for="icalFolder">이력서 폴더 주소</label>
									<input type="text" id="icalFolder" class="form-control form-control-sm" autocomplete="off" placeholder="https://drive.google.com/drive/folders/...">
								</div>
								<div class="col-md-2 mb-2 d-flex align-items-end">
									<button type="button" id="icalSave" class="btn btn-sm btn-dark btn-block" onclick="saveIcal();">세트 추가</button>
									<button type="button" id="icalCancel" class="btn btn-sm btn-outline-secondary ml-1" onclick="resetForm();" hidden>취소</button>
								</div>
							</div>
							<small class="text-muted">iCal: 구글 캘린더 → 설정 → 해당 캘린더 → 캘린더 통합 → iCal 형식의 비공개 주소. 폴더 구조: 년도/월/일/이름/이력서.pdf. 새 세트는 자동 실행이 꺼진 상태로 추가됩니다.</small>
						</div>
					</div>

					<div class="cal-panel">
						<div class="cal-panel-head">
							<span><i class="fab fa-google"></i> 구글 앱 설정 (모든 세트 공통) <span id="clientBadge" class="badge badge-warning">확인 중</span></span>
						</div>
						<div class="cal-panel-body">
							<div class="form-row">
								<div class="col-md-5 mb-2">
									<label for="driveClientId">OAuth 클라이언트 ID</label>
									<input type="text" id="driveClientId" class="form-control form-control-sm" autocomplete="off" placeholder="....apps.googleusercontent.com">
								</div>
								<div class="col-md-5 mb-2">
									<label for="driveClientSecret">클라이언트 시크릿 <small id="secretTail" class="text-muted"></small></label>
									<input type="text" id="driveClientSecret" class="form-control form-control-sm secret-input" autocomplete="off">
								</div>
								<div class="col-md-2 mb-2 d-flex align-items-end">
									<button type="button" class="btn btn-sm btn-dark btn-block" onclick="saveClient();">저장</button>
								</div>
							</div>
							<small class="text-muted">승인된 리디렉션 URI: <code id="driveRedirect"></code></small>
						</div>
					</div>

					<div class="cal-panel">
						<div class="cal-panel-head"><span><i class="fas fa-history"></i> 실행 이력 (최근 30회) · 면접관리 해당 주 기준</span></div>
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0">
								<thead>
									<tr>
										<th scope="col">실행 시각</th><th scope="col">구분</th><th scope="col">세트</th><th scope="col">결과</th><th scope="col">대상 주</th>
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
	var editingSq = null, clientReady = false;

	$(function() {
		loadIcal();
		$.getJSON('/admin/batch/interviewBatchLogData.do', function(res) { renderLog(res.list); })
			.fail(function() { emptyRow('#logBody', 12, '이력을 불러오지 못했습니다.'); });
		loadClient();
		var result = /[?&]drive=(\w+)/.exec(location.search);
		if (result) {
			alert({ ok: '구글 드라이브를 연결했습니다.', noclient: '구글 앱 설정의 클라이언트 ID와 시크릿을 먼저 저장해 주세요.' }[result[1]] || '구글 드라이브 연결에 실패했습니다. 구글 앱 설정과 리디렉션 URI를 확인해 주세요.');
			history.replaceState(null, '', location.pathname);
		}
	});

	function loadIcal() {
		$.getJSON('/admin/batch/icalListData.do', function(res) { renderIcal(res.list); })
			.fail(function() { emptyRow('#icalBody', 7, '세트 목록을 불러오지 못했습니다.'); });
	}

	function loadClient() {
		$.getJSON('/admin/batch/driveStatusData.do', function(res) {
			var d = res.drive;
			clientReady = !!d.clientReady;
			$('#driveRedirect').text(res.redirectUri);
			$('#driveClientId').val(d.clientId || '');
			$('#secretTail').text(d.secretTail ? '저장됨 ' + d.secretTail : '');
			$('#driveClientSecret').attr('placeholder', d.secretTail ? '바꿀 때만 입력' : 'GOCSPX-...');
			$('#clientBadge').removeClass('badge-warning badge-success').addClass(clientReady ? 'badge-success' : 'badge-warning').text(clientReady ? '설정됨' : '설정 필요');
		}).fail(function() { $('#clientBadge').text('확인 실패'); });
	}

	function saveClient() {
		$.post('/admin/batch/saveDriveConfData.do', { clientId: $('#driveClientId').val(), clientSecret: $('#driveClientSecret').val() }, function(res) {
			if (res.error) return alert(res.error);
			$('#driveClientSecret').val('');
			loadClient();
		}, 'json').fail(function() { alert('저장에 실패했습니다.'); });
	}

	function emptyRow(body, cols, text) {
		$(body).empty().append($('<tr>').append($('<td class="cal-empty">').attr('colspan', cols).text(text)));
	}

	function badge(map, code) {
		var b = map[code] || [code, 'badge-secondary'];
		return $('<span class="badge">').addClass(b[1]).text(b[0]);
	}

	function driveCell(r) {
		var $cell = $('<td>');
		if (r.DRIVE_CONNECTED) $cell.append($('<span class="badge badge-success mr-1">').text(r.DRIVE_ACCOUNT || '연결됨'));
		else $cell.append($('<span class="badge badge-warning mr-1">').text('연결 필요'));
		return $cell.append($('<a class="btn btn-xs btn-outline-dark">').attr('href', '/admin/batch/driveStart.do?icalSq=' + r.ICAL_SQ).text(r.DRIVE_CONNECTED ? '다시 연결' : '구글 계정 연결'));
	}

	// 사용자 입력과 일정 제목이 들어가므로 모두 text() 로 넣는다
	function renderIcal(list) {
		if (!list || !list.length) return emptyRow('#icalBody', 7, '등록된 세트가 없습니다. 아래에서 추가해 주세요.');
		var selected = $('input[name=icalSel]:checked').val();
		var $body = $('#icalBody').empty();
		list.forEach(function(r, i) {
			var $radio = $('<input type="radio" name="icalSel">').val(r.ICAL_SQ).attr('aria-label', r.ICAL_NM + ' 선택')
				.prop('checked', selected ? String(r.ICAL_SQ) === selected : i === 0);
			var $folder = r.DRIVE_FOLDER_ID
				? $('<a target="_blank" rel="noopener">').attr('href', 'https://drive.google.com/drive/folders/' + encodeURIComponent(r.DRIVE_FOLDER_ID)).text(r.DRIVE_FOLDER_ID)
				: $('<span class="text-muted">').text('미설정');
			var $auto = $('<input type="checkbox">').attr('aria-label', r.ICAL_NM + ' 자동 실행').prop('checked', r.AUTO_YN === 'Y')
				.on('change', function() { setAuto(r.ICAL_SQ, this.checked); });
			var $edit = $('<button type="button" class="btn btn-xs btn-outline-dark mr-1">수정</button>').on('click', function() { editIcal(r); });
			var $del = $('<button type="button" class="btn btn-xs btn-outline-danger">삭제</button>').on('click', function() { removeIcal(r); });
			$body.append($('<tr>').append($('<td>').append($radio), $('<td class="cal-title">').text(r.ICAL_NM), $('<td>').text(r.ICAL_MASK),
				$('<td>').append($folder), driveCell(r), $('<td>').append($auto), $('<td>').append($edit, $del)));
		});
	}

	function editIcal(r) {
		editingSq = r.ICAL_SQ;
		$('#icalNm').val(r.ICAL_NM);
		$('#icalUrl').val('').attr('placeholder', '저장됨: ' + r.ICAL_MASK + ' (바꿀 때만 입력)');
		$('#icalFolder').val(r.DRIVE_FOLDER_ID || '');
		$('#icalSave').text('세트 저장');
		$('#icalCancel').prop('hidden', false);
		$('#icalNm').focus();
	}

	function resetForm() {
		editingSq = null;
		$('#icalNm, #icalUrl, #icalFolder').val('');
		$('#icalUrl').attr('placeholder', 'https://calendar.google.com/calendar/ical/.../private-.../basic.ics');
		$('#icalSave').text('세트 추가');
		$('#icalCancel').prop('hidden', true);
	}

	function saveIcal() {
		var data = { name: $('#icalNm').val(), url: $('#icalUrl').val(), folder: $('#icalFolder').val() };
		if (editingSq) data.icalSq = editingSq;
		$.post('/admin/batch/saveIcalData.do', data, function(res) {
			if (res.error) return alert(res.error);
			resetForm();
			renderIcal(res.list);
		}, 'json').fail(function() { alert('저장에 실패했습니다.'); });
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
		var sq = $('input[name=icalSel]:checked').val();
		if (!sq) return alert('실행할 세트를 선택해 주세요.');
		var $btn = $('#runBtn').prop('disabled', true).text('실행 중...');
		$.post('/admin/batch/runInterviewBatchData.do', { icalSq: sq }, function(res) {
			if (res.error) return alert(res.error);
			renderLog(res.list);
		}, 'json').fail(function() { alert('실행 요청에 실패했습니다.'); })
			.always(function() { $btn.prop('disabled', false).text('선택한 세트로 지금 실행'); });
	}

	function setAuto(sq, auto) {
		$.post('/admin/batch/autoIcalData.do', { icalSq: sq, auto: auto }, function(res) { renderIcal(res.list); }, 'json')
			.fail(function() { alert('변경에 실패했습니다.'); loadIcal(); });
	}

	function removeIcal(r) {
		if (!confirm(r.ICAL_NM + ' 세트를 삭제할까요? 드라이브 연결도 함께 지워지고, 지난 실행 이력은 그대로 남습니다.')) return;
		$.post('/admin/batch/deleteIcalData.do', { icalSq: r.ICAL_SQ }, function(res) { renderIcal(res.list); }, 'json')
			.fail(function() { alert('삭제에 실패했습니다.'); });
	}
	</script>
</body>
</html>
