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
					<h3 class="card-title bTitle"><b>확정 일정 분류별 보기</b></h3>
				</div>

				<div class="card-body">

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
								<div class="col-md-2 col-6 mb-2">
									<button type="button" class="btn btn-sm btn-primary btn-block" onclick="loadList();"><i class="fas fa-search"></i> 조회</button>
								</div>
								<div class="col-md-6 col-6 mb-2 text-right">
									<a href="/admin/calendar/openCalendarSync.do" class="btn btn-sm btn-outline-secondary"><i class="fas fa-download"></i> 일정 가져오기·분류</a>
								</div>
							</div>
						</div>
					</div>

					<div class="cal-panel">
						<div class="cate-tabs" id="cateTabs" role="tablist" aria-label="분류"></div>
						<div class="table-responsive">
							<table class="table table-sm table-hover cal-table mb-0">
								<thead>
									<tr>
										<th style="width:150px;">일시</th>
										<th>제목</th>
										<th style="width:130px;">분류</th>
										<th style="width:110px;">확정</th>
									</tr>
								</thead>
								<tbody id="evtBody"></tbody>
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
	var current = '';

	$(function() {
		var today = moment();
		$('#fromDt').val(today.clone().startOf('month').format('YYYY-MM-DD'));
		$('#toDt').val(today.clone().endOf('month').format('YYYY-MM-DD'));
		loadList();
	});

	$(document).on('click', '.cate-tab', function() {
		current = $(this).data('cate');
		loadList();
	});

	function loadList() {
		$.post('/admin/calendar/eventListData.do', { fromDt: $('#fromDt').val(), toDt: $('#toDt').val(), cateCd: current }, function(res) {
			if (res.error) { bootbox.alert(res.error); return; }
			renderTabs(res.counts);
			renderList(res.list);
		});
	}

	function renderTabs(counts) {
		var map = {}, total = 0;
		(counts || []).forEach(function(c) { map[c.CATE_CD] = c.CNT; total += c.CNT; });
		var $tabs = $('#cateTabs').empty();
		var tabs = [['', '전체', total]];
		$.each(CATES, function(k, v) { tabs.push([k, v, map[k] || 0]); });
		tabs.forEach(function(t) {
			$('<button type="button" class="cate-tab" role="tab">').attr('data-cate', t[0]).attr('aria-selected', t[0] === current)
				.toggleClass('active', t[0] === current)
				.append($('<span>').text(t[1])).append($('<span class="cnt">').text(t[2])).appendTo($tabs);
		});
	}

	function when(e) {
		if (e.ALL_DAY_YN === 'Y') {
			var s = e.START_DT.substr(0, 10), t = e.END_DT ? e.END_DT.substr(0, 10) : s;
			return s + (s === t ? '' : ' ~ ' + t.substr(5)) + ' <span class="badge badge-light">종일</span>';
		}
		return e.START_DT + (e.END_DT ? ' ~ ' + e.END_DT.substr(11) : '');
	}

	function renderList(list) {
		var $body = $('#evtBody').empty();
		if (!list || !list.length) {
			$body.append('<tr><td colspan="4" class="cal-empty">이 기간에 확정된 일정이 없습니다.</td></tr>');
			return;
		}
		list.forEach(function(e) {
			var cate = CATES[e.CATE_CD] || e.CATE_CD;
			if (e.SUB_CATE_CD && SUBS[e.SUB_CATE_CD]) cate += ' · ' + SUBS[e.SUB_CATE_CD];
			var $tr = $('<tr>');
			$tr.append('<td class="text-nowrap small">' + when(e) + '</td>');
			$('<td>').append($('<div class="cal-title">').text(e.EVT_TITLE || '(제목 없음)'))
				.append(e.EVT_LOC ? $('<div class="small text-muted">').text(e.EVT_LOC) : null).appendTo($tr);
			$('<td>').append($('<span class="cate-badge">').text(cate)).appendTo($tr);
			$('<td class="small text-muted">').text(e.CONFIRM_EMPLY_ID).append('<br>').append(document.createTextNode(e.CONFIRM_DT)).appendTo($tr);
			$body.append($tr);
		});
	}
	</script>
</body>
</html>
