<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<style>
	.ul-chks { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; padding: 10px 14px; }
	.ul-chks button { border: 1px solid rgba(17,17,17,.15); background: #fff; border-radius: 999px; padding: 4px 12px; font-weight: 700; font-size: 12.5px; color: #444; }
	.ul-chks button.on { border-color: #0b6e8a; background: #eef9fc; color: #0b6e8a; }
	.ul-chks .cnt { background: rgba(17,17,17,.08); border-radius: 999px; padding: 0 7px; font-size: 11px; margin-left: 4px; }
	#ulBody tr { cursor: pointer; }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header d-flex align-items-center">
					<h3 class="card-title bTitle"><b>업데이트 내역</b></h3>
					<span class="small text-muted ml-3">배포할 때마다 한 건씩 쌓입니다 · 줄을 누르면 바뀐 화면과 수정·테스트·주의 내용</span>
				</div>
				<div class="card-body">
					<div class="cal-panel">
						<div class="ul-chks" id="chks" role="tablist" aria-label="보기"></div>
						<table class="table table-sm table-hover cal-table mb-0">
							<thead><tr><th>배포일</th><th>내용</th><th>화면</th><th>피드백</th><th>커밋</th></tr></thead>
							<tbody id="ulBody"></tbody>
						</table>
					</div>
				</div>
			</section>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>
	<script>
	window.BO_UPDATE_PAGE = true;
	var list = [], view = 'ALL';
	var VIEWS = [['ALL', '전체', function() { return true; }], ['FB', '💬 피드백 반영', function(u) { return !!u.FB_SQ; }],
		['MONTH', '이번 달', function(u) { return u.DEPLOY_DT.substr(0, 7) === moment().format('YYYY-MM'); }]];

	$(function() {
		hrPost('/admin/update/listData.do', {}, function(res) {
			list = res.result || [];
			// 이 화면을 열면 메뉴의 N 을 지운다(맨 위 창에서도)
			if (list.length) { BO_UPDATE_SEEN(list[0].UPD_SQ); try { window.top.$('aside .fb-new').remove(); } catch (e) {} }
			render();
			var q = /[?&]UPD_SQ=(\d+)/.exec(location.search);
			if (q) BO_UPDATE(+q[1]);
		});
		$('#chks').on('click', 'button', function() { view = $(this).data('v'); render(); });
	});

	function render() {
		$('#chks').empty().append(VIEWS.map(function(v) {
			var n = list.filter(v[2]).length;
			return $('<button type="button" role="tab">').attr({ 'data-v': v[0], 'aria-selected': view === v[0] }).toggleClass('on', view === v[0]).text(v[1]).append(n ? $('<span class="cnt">').text(n) : '');
		}));
		var test = VIEWS.filter(function(v) { return v[0] === view; })[0][2], $b = $('#ulBody').empty(), rows = list.filter(test);
		if (!rows.length) boEmpty($b, '아직 업데이트 내역이 없습니다. 다음 배포부터 쌓입니다.');
		rows.forEach(function(u) {
			$b.append($('<tr tabindex="0">').on('click keydown', function(e) { if (e.type === 'keydown' && e.key !== 'Enter') return; BO_UPDATE(u.UPD_SQ); })
				.append($('<td>').text(u.DEPLOY_DT)).append($('<td>').append($('<span class="td-cut">').text(u.TITLE))).append($('<td>').text(u.SCREENS || ''))
				.append($('<td>').append(u.FB_SQ ? $('<span class="fb-pill warn">').text('💬 ' + (u.FB_EMPLY_NM || '요청')) : '—'))
				.append($('<td>').text(u.COMMIT_ID || '')));
		});
	}
	</script>
</body>
</html>
