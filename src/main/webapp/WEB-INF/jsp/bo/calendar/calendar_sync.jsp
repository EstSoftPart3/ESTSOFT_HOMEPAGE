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
					<h3 class="card-title bTitle"><b>캘린더 일정 가져오기·분류</b></h3>
				</div>

				<div class="card-body">

					<!-- 구글 연동 설정 -->
					<div class="cal-panel">
						<div class="cal-panel-head" data-toggle="collapse" data-target="#confBox" role="button" aria-expanded="${!confReady}">
							<span><i class="fas fa-key"></i> 구글 연동 설정</span>
							<c:choose>
								<c:when test="${confReady}"><span class="badge badge-success">설정됨</span></c:when>
								<c:otherwise><span class="badge badge-warning">설정 필요</span></c:otherwise>
							</c:choose>
						</div>
						<div id="confBox" class="collapse ${confReady ? '' : 'show'}">
							<div class="cal-panel-body">
								<div class="form-row">
									<div class="col-md-5 mb-2">
										<label for="clientId">OAuth 클라이언트 ID</label>
										<input type="text" id="clientId" class="form-control form-control-sm" value="<c:out value='${clientId}'/>" autocomplete="off">
									</div>
									<div class="col-md-5 mb-2">
										<label for="clientSecret">클라이언트 시크릿</label>
										<input type="password" id="clientSecret" class="form-control form-control-sm" autocomplete="new-password"
											placeholder="${confReady ? '저장됨 - 바꿀 때만 입력' : ''}">
									</div>
									<div class="col-md-2 mb-2 d-flex align-items-end">
										<button type="button" class="btn btn-sm btn-dark btn-block" onclick="saveConf();">저장</button>
									</div>
								</div>
								<small class="text-muted">구글 콘솔의 승인된 리디렉션 URI: <code id="redirectUri"></code></small>
							</div>
						</div>
					</div>

					<!-- 조회 조건 -->
					<div class="cal-panel">
						<div class="cal-panel-body">
							<div class="form-row align-items-end">
								<div class="col-md-2 col-6 mb-2">
									<label for="fromDt">시작일</label>
									<input type="date" id="fromDt" class="form-control form-control-sm">
								</div>
								<div class="col-md-2 col-6 mb-2">
									<label for="toDt">종료일</label>
									<input type="date" id="toDt" class="form-control form-control-sm">
								</div>
								<div class="col-md-4 mb-2">
									<label for="calId">캘린더</label>
									<select id="calId" class="form-control form-control-sm">
										<option value="primary">기본 캘린더</option>
									</select>
								</div>
								<div class="col-md-2 col-6 mb-2">
									<button type="button" id="btnFetch" class="btn btn-sm btn-primary btn-block" onclick="fetchEvents();">
										<i class="fas fa-download"></i> 조회
									</button>
								</div>
								<div class="col-md-2 col-6 mb-2 text-md-right">
									<span id="googleState" class="small text-muted"></span>
								</div>
							</div>
						</div>
					</div>

					<!-- 임시 일정 + 1차 분류 -->
					<div class="cal-panel">
						<div class="cal-panel-head">
							<span><i class="fas fa-list"></i> 가져온 일정 <small id="tmpSummary" class="text-muted"></small></span>
							<span>
								<button type="button" class="btn btn-sm btn-outline-secondary" onclick="toggleAll(true);">미확정 전체 선택</button>
								<button type="button" class="btn btn-sm btn-success" onclick="confirmSelected();"><i class="fas fa-check"></i> 선택 확정</button>
							</span>
						</div>
						<div class="table-responsive">
							<table class="table table-sm table-hover cal-table mb-0">
								<thead>
									<tr>
										<th style="width:36px;"><input type="checkbox" id="chkAll" onclick="toggleAll(this.checked);" aria-label="전체 선택"></th>
										<th style="width:150px;">일시</th>
										<th>제목</th>
										<th style="width:150px;">분류</th>
										<th style="width:100px;">세부</th>
										<th style="width:80px;">상태</th>
									</tr>
								</thead>
								<tbody id="tmpBody">
									<tr><td colspan="6" class="cal-empty">기간을 정하고 조회를 눌러 주세요.</td></tr>
								</tbody>
							</table>
						</div>
					</div>

				</div>
			</section>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>

	<script>
	var CATES = { <c:forEach items="${categories}" var="c" varStatus="s">"${c.key}":"${c.value}"${s.last ? '' : ','}</c:forEach> };
	var SUBS = { <c:forEach items="${subCategories}" var="c" varStatus="s">"${c.key}":"${c.value}"${s.last ? '' : ','}</c:forEach> };
	var CONF_READY = ${confReady};
	var GOOGLE_LOGIN = ${googleLogin};

	$(function() {
		$('#redirectUri').text(location.origin + '/admin/calendar/oauthCallback.do');

		var q = new URLSearchParams(location.search);
		var today = moment();
		$('#fromDt').val(q.get('fromDt') || today.clone().startOf('month').format('YYYY-MM-DD'));
		$('#toDt').val(q.get('toDt') || today.clone().endOf('month').format('YYYY-MM-DD'));
		if (q.get('gerr')) {
			bootbox.alert('구글 로그인이 취소되었거나 확인에 실패했습니다. 다시 시도해 주세요.');
		}

		renderGoogleState();
		if (GOOGLE_LOGIN) {
			loadCalendars(q.get('calId'));
		}
		if (q.get('auto') && GOOGLE_LOGIN) {
			fetchEvents();
		} else {
			loadTmp();
		}
	});

	function renderGoogleState() {
		$('#googleState').html(GOOGLE_LOGIN
			? '<i class="fas fa-check-circle text-success"></i> 구글 연결됨'
			: '<i class="fas fa-info-circle"></i> 조회 시 구글 로그인');
	}

	function saveConf() {
		$.post('/admin/calendar/saveConfData.do', { clientId: $('#clientId').val(), clientSecret: $('#clientSecret').val() }, function(res) {
			if (res.error) { bootbox.alert(res.error); return; }
			bootbox.alert('저장했습니다.', function() { location.reload(); });
		});
	}

	function loadCalendars(selected) {
		$.post('/admin/calendar/calendarListData.do', function(res) {
			if (!res.calendars) return;
			var $sel = $('#calId').empty();
			res.calendars.forEach(function(c) {
				$('<option>').val(c.primary ? 'primary' : c.id).text(c.summary + (c.primary ? ' (기본)' : '')).appendTo($sel);
			});
			if (selected) $sel.val(selected);
		});
	}

	function googleLogin() {
		location.href = '/admin/calendar/oauthStart.do?' + $.param({ fromDt: $('#fromDt').val(), toDt: $('#toDt').val(), calId: $('#calId').val() });
	}

	function fetchEvents() {
		if (!CONF_READY) {
			bootbox.alert('먼저 구글 연동 설정(클라이언트 ID·시크릿)을 저장해 주세요.');
			$('#confBox').collapse('show');
			return;
		}
		var $btn = $('#btnFetch').prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> 가져오는 중');
		$.post('/admin/calendar/fetchEventsData.do', { fromDt: $('#fromDt').val(), toDt: $('#toDt').val(), calId: $('#calId').val() })
			.done(function(res) {
				if (res.needLogin) { googleLogin(); return; }
				if (res.error) { bootbox.alert(res.error); return; }
				renderTmp(res.list);
			})
			.fail(function() { bootbox.alert('일정을 가져오지 못했습니다. 잠시 후 다시 시도해 주세요.'); })
			.always(function() { $btn.prop('disabled', false).html('<i class="fas fa-download"></i> 조회'); });
	}

	function loadTmp() {
		$.post('/admin/calendar/tmpListData.do', function(res) { renderTmp(res.list, true); });
	}

	function cateSelect(value) {
		var html = '<select class="form-control form-control-sm cate">';
		$.each(CATES, function(k, v) { html += '<option value="' + k + '"' + (k === value ? ' selected' : '') + '>' + v + '</option>'; });
		return html + '</select>';
	}

	function subSelect(cate, value) {
		var html = '<select class="form-control form-control-sm sub"' + (cate === 'INTERVIEW' ? '' : ' disabled') + '><option value="">-</option>';
		$.each(SUBS, function(k, v) { html += '<option value="' + k + '"' + (k === value ? ' selected' : '') + '>' + v + '</option>'; });
		return html + '</select>';
	}

	function when(e) {
		if (e.ALL_DAY_YN === 'Y') {
			var s = e.START_DT.substr(0, 10), t = e.END_DT ? e.END_DT.substr(0, 10) : s;
			return s + (s === t ? '' : ' ~ ' + t.substr(5)) + ' <span class="badge badge-light">종일</span>';
		}
		return e.START_DT + (e.END_DT ? ' ~ ' + e.END_DT.substr(11) : '');
	}

	function renderTmp(list, initial) {
		var $body = $('#tmpBody').empty();
		$('#chkAll').prop('checked', false);
		if (!list || !list.length) {
			$body.append('<tr><td colspan="6" class="cal-empty">' + (initial ? '기간을 정하고 조회를 눌러 주세요.' : '이 기간에 가져올 일정이 없습니다.') + '</td></tr>');
			$('#tmpSummary').text('');
			return;
		}
		var done = 0;
		list.forEach(function(e) {
			var confirmed = e.CONFIRM_YN === 'Y';
			if (confirmed) done++;
			var $tr = $('<tr>').attr('data-sq', e.EVT_TMP_SQ).toggleClass('is-confirmed', confirmed);
			$tr.append('<td><input type="checkbox" class="chk" aria-label="선택"></td>');
			$tr.append('<td class="text-nowrap small">' + when(e) + '</td>');
			$('<td>').append($('<div class="cal-title">').text(e.EVT_TITLE || '(제목 없음)'))
				.append(e.EVT_LOC ? $('<div class="small text-muted">').text(e.EVT_LOC) : null).appendTo($tr);
			$tr.append('<td>' + cateSelect(e.CATE_CD) + '</td>');
			$tr.append('<td>' + subSelect(e.CATE_CD, e.SUB_CATE_CD) + '</td>');
			$tr.append('<td>' + (confirmed ? '<span class="badge badge-success">확정됨</span>' : '<span class="badge badge-secondary">미확정</span>') + '</td>');
			$body.append($tr);
		});
		$('#tmpSummary').text('총 ' + list.length + '건 · 확정 ' + done + '건');
	}

	// 분류를 바꾸면 세부 구분 활성/비활성, 해당 행 자동 선택
	$(document).on('change', '#tmpBody .cate', function() {
		var $tr = $(this).closest('tr');
		var isInterview = this.value === 'INTERVIEW';
		$tr.find('.sub').prop('disabled', !isInterview);
		if (!isInterview) $tr.find('.sub').val('');
		$tr.find('.chk').prop('checked', true);
	});
	$(document).on('change', '#tmpBody .sub', function() {
		$(this).closest('tr').find('.chk').prop('checked', true);
	});

	function toggleAll(on) {
		$('#tmpBody tr').each(function() {
			var $tr = $(this);
			$tr.find('.chk').prop('checked', on && !$tr.hasClass('is-confirmed'));
		});
	}

	function confirmSelected() {
		var items = [];
		$('#tmpBody tr').each(function() {
			var $tr = $(this);
			if (!$tr.find('.chk').prop('checked')) return;
			items.push({ EVT_TMP_SQ: Number($tr.data('sq')), CATE_CD: $tr.find('.cate').val(), SUB_CATE_CD: $tr.find('.sub').val() || null });
		});
		if (!items.length) { bootbox.alert('확정할 일정을 선택해 주세요.'); return; }
		bootbox.confirm(items.length + '건을 확정할까요? 이미 확정된 일정은 지금 분류로 덮어씁니다.', function(ok) {
			if (!ok) return;
			$.ajax({ url: '/admin/calendar/confirmData.do', type: 'POST', contentType: 'application/json', data: JSON.stringify(items) })
				.done(function(res) {
					if (res.error) { bootbox.alert(res.error); return; }
					renderTmp(res.list);
					bootbox.alert(items.length + '건을 확정했습니다.');
				})
				.fail(function() { bootbox.alert('확정하지 못했습니다. 잠시 후 다시 시도해 주세요.'); });
		});
	}
	</script>
</body>
</html>
