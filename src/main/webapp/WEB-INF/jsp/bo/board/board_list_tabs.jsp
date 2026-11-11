<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<style>
	.brd-filters { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; padding: 0 14px 12px; }
	.brd-filters .btn-group .btn { font-size: 12px; }
	.brd-search { display: flex; gap: 6px; margin-left: auto; }
	.brd-search select { width: auto; }
	.brd-search input { width: 240px; }
	#boardTable tbody tr { cursor: pointer; }
	#boardTable tbody tr:hover { background: #f4fbfd; }
	#boardTable tr.is-deleted td { color: #adb5bd; }
	.brd-pager { display: flex; justify-content: center; gap: 4px; padding: 10px 0 14px; }
	@media (max-width: 767px) { .brd-search { margin-left: 0; width: 100%; } .brd-search input { flex: 1; width: auto; } }
</style>

<body class="hold-transition sidebar-mini">

	<div class="wrapper">

		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>

		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header d-flex align-items-center">
					<h3 class="card-title bTitle"><b>게시판 관리</b></h3>
					<button type="button" class="btn btn-sm btn-primary ml-auto" id="btnWrite"><i class="fas fa-pen"></i> <span id="writeLabel"></span> 글쓰기</button>
				</div>

				<div class="card-body">
					<div class="cal-panel">
						<div class="cate-tabs" id="tabs" role="tablist" aria-label="게시판"></div>
						<div class="brd-filters">
							<div class="btn-group btn-group-sm" role="group" aria-label="사용여부" data-filter="use">
								<button type="button" class="btn btn-outline-secondary active" data-val="">전체</button>
								<button type="button" class="btn btn-outline-secondary" data-val="Y">사용</button>
								<button type="button" class="btn btn-outline-secondary" data-val="N">미사용</button>
							</div>
							<div class="btn-group btn-group-sm" role="group" aria-label="삭제여부" data-filter="del">
								<button type="button" class="btn btn-outline-secondary active" data-val="N">삭제 제외</button>
								<button type="button" class="btn btn-outline-secondary" data-val="">삭제 포함</button>
							</div>
							<form class="brd-search" id="searchForm">
								<select id="searchOption" class="form-control form-control-sm" aria-label="검색 대상">
									<option value="TWC">제목+작성자+내용</option>
									<option value="T">제목</option>
									<option value="W">작성자</option>
									<option value="C">내용</option>
								</select>
								<input type="search" id="searchKeyword" class="form-control form-control-sm" placeholder="검색어 입력 후 Enter" aria-label="검색어">
								<button type="submit" class="btn btn-sm btn-outline-secondary"><i class="fas fa-search"></i> 검색</button>
							</form>
						</div>
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0" id="boardTable">
								<thead><tr id="boardHead"></tr></thead>
								<tbody id="boardBody"></tbody>
							</table>
						</div>
						<div class="brd-pager" id="pager"></div>
					</div>
				</div>
			</section>
		</div>
	</div>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/board/board_common.jspf"%>
<script>
	var PAGE_SIZE = 20;
	var tab = '<c:out value="${tab}"/>' || 'notice';
	var rows = {}, filter = { use: '', del: 'N' }, search = { opt: 'TWC', kw: '' }, page = 1;

	var board = boardOf, url = boardUrl;

	function load() {
		$('#boardBody').html('<tr><td class="cal-empty" colspan="6">불러오는 중…</td></tr>');
		$.when.apply($, BOARDS.map(function(b) {
			return $.post(boardData(b.key, 'ListData'), {}, null, 'json').then(function(res) {
				rows[b.key] = ((res[b.key + 'BoardData'] || {})[b.key + 'BoardInfo'] || []).map(function(r) { r._text = boardPlain(r.brdCntnt); return r; });
			});
		})).done(render).fail(function() {
			$('#boardBody').html('<tr><td class="cal-empty" colspan="6">목록을 불러오지 못했습니다. 새로고침해 주세요.</td></tr>');
		});
	}

	function has(v) { return (v || '').toLowerCase().indexOf(search.kw.toLowerCase()) >= 0; }

	function visible(key) {
		return (rows[key] || []).filter(function(r) {
			if (filter.use && r.useYn !== filter.use) return false;
			if (filter.del && (r.delYn || 'N') !== filter.del) return false;
			if (!search.kw) return true;
			return (search.opt.indexOf('T') >= 0 && has(r.brdTtl)) || (search.opt.indexOf('W') >= 0 && has(r.brdWrtr)) || (search.opt.indexOf('C') >= 0 && has(r._text));
		});
	}

	function render() {
		$('#tabs').empty().append(BOARDS.map(function(b) {
			var on = b.key === tab;
			return $('<button type="button" class="cate-tab" role="tab">').attr('data-tab', b.key).attr('aria-selected', on).toggleClass('active', on)
				.append($('<span>').text(b.name)).append($('<span class="cnt">').text(visible(b.key).length));
		}));
		$('#writeLabel').text(board(tab).name);

		var cols = [['brdSq', '번호', 'text-center', 70], ['brdTtl', '제목', '']].concat(board(tab).extra || [], [['brdRegDt', '작성일'], ['brdWrtr', '작성자']]);
		$('#boardHead').empty().append(cols.map(function(c) { return $('<th>').text(c[1]).addClass(c[0] === 'brdTtl' ? '' : 'text-center').css('width', c[0] === 'brdTtl' ? '' : (c[3] || 130) + 'px'); }));

		var list = visible(tab), pages = Math.max(1, Math.ceil(list.length / PAGE_SIZE));
		page = Math.min(page, pages);
		var $body = $('#boardBody').empty();
		if (!list.length) $body.append($('<tr>').append($('<td class="cal-empty">').attr('colspan', cols.length).text(search.kw ? '검색 결과가 없습니다.' : '글이 없습니다.')));
		list.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE).forEach(function(r) {
			$body.append($('<tr>').attr('data-sq', r.brdSq).toggleClass('is-deleted', r.delYn === 'Y').append(cols.map(function(c) {
				var $td = $('<td>').text(r[c[0]] == null ? '' : r[c[0]]);
				if (c[0] === 'brdTtl') { $td.addClass('cal-title'); if (r.brdReLev > 0) $td.prepend($('<span class="text-muted">').text('  '.repeat(r.brdReLev - 1) + '└ ')); if (r.delYn === 'Y') $td.append(' <span class="cate-badge">삭제됨</span>'); if (r.useYn === 'N') $td.append(' <span class="cate-badge">미사용</span>'); }
				else $td.addClass('text-center');
				return $td;
			})));
		});

		var $p = $('#pager').empty();
		if (pages > 1) for (var i = 1; i <= pages; i++) $p.append($('<button type="button" class="btn btn-sm">').toggleClass('btn-primary', i === page).toggleClass('btn-light', i !== page).attr('data-page', i).text(i));
	}

	$('#tabs').on('click', '.cate-tab', function() {
		tab = $(this).attr('data-tab'); page = 1; render();
		// 상세 화면의 「목록」이 이 주소로 돌아오므로 보던 탭이 유지된다
		history.replaceState(null, '', url(tab, 'List'));
	});
	$('[data-filter] .btn').on('click', function() {
		$(this).addClass('active').siblings().removeClass('active');
		filter[$(this).parent().attr('data-filter')] = $(this).attr('data-val'); page = 1; render();
	});
	$('#searchForm').on('submit', function(e) { e.preventDefault(); search = { opt: $('#searchOption').val(), kw: $.trim($('#searchKeyword').val()) }; page = 1; render(); });
	$('#pager').on('click', 'button', function() { page = Number($(this).attr('data-page')); render(); window.scrollTo(0, 0); });
	$('#boardBody').on('click', 'tr[data-sq]', function() { location.href = url(tab, 'Detail') + '?brdSq=' + encodeURIComponent($(this).attr('data-sq')); });
	$('#btnWrite').on('click', function() { location.href = url(tab, 'Insert'); });

	load();
</script>
</body>
</html>
