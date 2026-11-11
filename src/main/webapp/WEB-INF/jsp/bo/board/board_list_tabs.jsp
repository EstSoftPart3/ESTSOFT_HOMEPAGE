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
	.brd-bulk { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; padding: 8px 14px; background: #eef9fc; border-top: 1px solid #d6eef5; border-bottom: 1px solid #d6eef5; font-size: 13px; }
	#boardTable tbody tr:hover { background: #f4fbfd; }
	#boardTable tr.is-deleted td { color: #adb5bd; }
	#boardTable tr.is-blind .cal-title a { color: #6f42c1; }
	#boardTable .cal-title a { color: inherit; }
	#boardTable .chk { width: 36px; text-align: center; }
	#boardTable .custom-switch { padding-left: 2.25rem; min-height: 1.2rem; display: inline-block; }
	.brd-blind .custom-control-input:checked ~ .custom-control-label::before { background: #6f42c1; border-color: #6f42c1; }
	.brd-del .custom-control-input:checked ~ .custom-control-label::before { background: #dc3545; border-color: #dc3545; }
	.cate-badge.blind { background: #f3eefc; color: #6f42c1; }
	.brd-pop { position: fixed; z-index: 1060; width: 380px; max-width: calc(100vw - 32px); background: #fff; border: 1px solid #d0d4d9; border-radius: 8px; box-shadow: 0 8px 24px rgba(0,0,0,.15); padding: 12px 14px; font-size: 13px; pointer-events: none; }
	.brd-pop b { display: block; margin-bottom: 2px; word-break: break-word; }
	.brd-pop .m { color: #6c757d; font-size: 11px; margin-bottom: 6px; }
	.brd-pop .c { color: #333; white-space: pre-line; word-break: break-word; max-height: 240px; overflow: hidden; }
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
							<div class="btn-group btn-group-sm" role="group" aria-label="블라인드" data-filter="blind">
								<button type="button" class="btn btn-outline-secondary active" data-val="">블라인드 포함</button>
								<button type="button" class="btn btn-outline-secondary" data-val="Y">블라인드만</button>
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
						<div class="brd-bulk" id="bulk" hidden>
							<b id="bulkCount"></b>
							<button type="button" class="btn btn-sm btn-dark" data-bulk="blind" data-val="Y"><i class="fas fa-eye-slash"></i> 블라인드</button>
							<button type="button" class="btn btn-sm btn-outline-secondary" data-bulk="blind" data-val="N">블라인드 해제</button>
							<button type="button" class="btn btn-sm btn-outline-danger" data-bulk="del" data-val="Y"><i class="fas fa-trash-alt"></i> 삭제</button>
							<button type="button" class="btn btn-sm btn-link" id="bulkClear">선택 해제</button>
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
	<div class="brd-pop" id="pop" hidden role="tooltip"></div>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/board/board_common.jspf"%>
<script>
	var PAGE_SIZE = 20;
	var tab = '<c:out value="${tab}"/>' || 'notice';
	var rows = {}, filter = { use: '', del: 'N', blind: '' }, search = { opt: 'TWC', kw: '' }, page = 1, picked = {};
	var board = boardOf, url = boardUrl;

	function load() {
		$('#boardBody').html('<tr><td class="cal-empty" colspan="9">불러오는 중…</td></tr>');
		$.when.apply($, BOARDS.map(function(b) {
			return $.post(boardData(b.key, 'ListData'), {}, null, 'json').then(function(res) {
				rows[b.key] = ((res[b.key + 'BoardData'] || {})[b.key + 'BoardInfo'] || []).map(function(r) { r._text = boardPlain(boardHtml(r.brdCntnt)); return r; });
			});
		})).done(render).fail(function() {
			$('#boardBody').html('<tr><td class="cal-empty" colspan="9">목록을 불러오지 못했습니다. 새로고침해 주세요.</td></tr>');
		});
	}

	function has(v) { return (v || '').toLowerCase().indexOf(search.kw.toLowerCase()) >= 0; }
	function find(sq) { return (rows[tab] || []).filter(function(r) { return String(r.brdSq) === String(sq); })[0]; }

	function visible(key) {
		return (rows[key] || []).filter(function(r) {
			if (filter.use && r.useYn !== filter.use) return false;
			if (filter.del && (r.delYn || 'N') !== filter.del) return false;
			if (filter.blind && (r.blindYn || 'N') !== filter.blind) return false;
			if (!search.kw) return true;
			return (search.opt.indexOf('T') >= 0 && has(r.brdTtl)) || (search.opt.indexOf('W') >= 0 && has(r.brdWrtr)) || (search.opt.indexOf('C') >= 0 && has(r._text));
		});
	}

	function sw(kind, r) {
		var on = (kind === 'blind' ? r.blindYn : r.delYn) === 'Y', id = kind + '_' + r.brdSq;
		return $('<td class="text-center">').append($('<div class="custom-control custom-switch">').addClass('brd-' + kind)
			.append($('<input type="checkbox" class="custom-control-input">').attr({ id: id, 'data-flag': kind, 'data-sq': r.brdSq }).prop('checked', on))
			.append($('<label class="custom-control-label">').attr('for', id).append($('<span class="sr-only">').text(kind === 'blind' ? '블라인드' : '삭제'))));
	}

	function render() {
		$('#tabs').empty().append(BOARDS.map(function(b) {
			var on = b.key === tab;
			return $('<button type="button" class="cate-tab" role="tab">').attr('data-tab', b.key).attr('aria-selected', on).toggleClass('active', on)
				.append($('<span>').text(b.name)).append($('<span class="cnt">').text(visible(b.key).length));
		}));
		$('#writeLabel').text(board(tab).name);

		var cols = [['brdSq', '번호', 70], ['brdTtl', '제목']].concat(board(tab).extra || [], [['brdRegDt', '작성일'], ['brdWrtr', '작성자']]);
		var list = visible(tab), pages = Math.max(1, Math.ceil(list.length / PAGE_SIZE));
		page = Math.min(page, pages);
		var shown = list.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);
		var allOn = shown.length > 0 && shown.every(function(r) { return picked[r.brdSq]; });

		$('#boardHead').empty()
			.append($('<th class="chk">').append($('<input type="checkbox" id="chkAll" aria-label="이 페이지 전체 선택">').prop('checked', allOn)))
			.append(cols.map(function(c) { return $('<th>').text(c[1]).addClass(c[0] === 'brdTtl' ? '' : 'text-center').css('width', c[0] === 'brdTtl' ? '' : (c[2] || 130) + 'px'); }))
			.append('<th class="text-center" style="width:80px">블라인드</th><th class="text-center" style="width:64px">삭제</th>');

		var $body = $('#boardBody').empty();
		if (!list.length) $body.append($('<tr>').append($('<td class="cal-empty">').attr('colspan', cols.length + 3).text(search.kw ? '검색 결과가 없습니다.' : '글이 없습니다.')));
		shown.forEach(function(r) {
			var $tr = $('<tr>').attr('data-sq', r.brdSq).toggleClass('is-deleted', r.delYn === 'Y').toggleClass('is-blind', r.blindYn === 'Y');
			$tr.append($('<td class="chk">').append($('<input type="checkbox" class="pick">').attr('aria-label', r.brdSq + '번 선택').attr('data-sq', r.brdSq).prop('checked', !!picked[r.brdSq])));
			cols.forEach(function(c) {
				var $td = $('<td>');
				if (c[0] === 'brdTtl') {
					var $a = $('<a class="brd-link">').attr('href', url(tab, 'Detail') + '?brdSq=' + encodeURIComponent(r.brdSq)).attr('data-sq', r.brdSq).text(r.brdTtl || '(제목 없음)');
					$td.addClass('cal-title');
					if (r.brdReLev > 0) $td.append($('<span class="text-muted">').text('  '.repeat(r.brdReLev - 1) + '└ '));
					$td.append($a);
					if (r.blindYn === 'Y') $td.append(' <span class="cate-badge blind">블라인드</span>');
					if (r.delYn === 'Y') $td.append(' <span class="cate-badge">삭제됨</span>');
					else if (r.useYn === 'N') $td.append(' <span class="cate-badge">미사용</span>');
				} else $td.addClass('text-center').text(r[c[0]] == null ? '' : r[c[0]]);
				$tr.append($td);
			});
			$body.append($tr.append(sw('blind', r)).append(sw('del', r)));
		});

		var $p = $('#pager').empty();
		if (pages > 1) for (var i = 1; i <= pages; i++) $p.append($('<button type="button" class="btn btn-sm">').toggleClass('btn-primary', i === page).toggleClass('btn-light', i !== page).attr('data-page', i).text(i));
		renderBulk();
	}

	function pickedIds() { return Object.keys(picked).filter(function(k) { return picked[k]; }); }
	function renderBulk() { var n = pickedIds().length; $('#bulk').prop('hidden', !n); $('#bulkCount').text(n + '개 선택'); }

	// 서버에 저장하고, 성공하면 내려받은 목록의 값도 바꿔 다시 그린다
	function setFlag(field, value, ids, done) {
		$.post('/admin/board/boardFlagData.do', { field: field, value: value, brdSq: ids.join(',') }, null, 'json').done(function(res) {
			if (res.error) { bootbox.alert(res.error); done && done(false); return; }
			ids.forEach(function(sq) {
				var r = find(sq); if (!r) return;
				if (field === 'blind') r.blindYn = value; else { r.delYn = value; r.useYn = value === 'Y' ? 'N' : 'Y'; }
			});
			done && done(true); render();
		}).fail(function() { bootbox.alert('저장하지 못했습니다. 다시 로그인한 뒤 시도해 주세요.'); done && done(false); });
	}

	$('#tabs').on('click', '.cate-tab', function() {
		tab = $(this).attr('data-tab'); page = 1; picked = {}; render();
		// 상세 화면의 「목록」이 이 주소로 돌아오므로 보던 탭이 유지된다
		history.replaceState(null, '', url(tab, 'List'));
	});
	$('[data-filter] .btn').on('click', function() {
		$(this).addClass('active').siblings().removeClass('active');
		filter[$(this).parent().attr('data-filter')] = $(this).attr('data-val'); page = 1; render();
	});
	$('#searchForm').on('submit', function(e) { e.preventDefault(); search = { opt: $('#searchOption').val(), kw: $.trim($('#searchKeyword').val()) }; page = 1; render(); });
	$('#pager').on('click', 'button', function() { page = Number($(this).attr('data-page')); render(); window.scrollTo(0, 0); });
	$('#btnWrite').on('click', function() { location.href = url(tab, 'Insert'); });

	$('#boardBody').on('change', '.pick', function() { picked[$(this).attr('data-sq')] = this.checked; render(); });
	$('#boardHead').on('change', '#chkAll', function() {
		var on = this.checked;
		$('#boardBody .pick').each(function() { picked[$(this).attr('data-sq')] = on; });
		render();
	});
	$('#bulkClear').on('click', function() { picked = {}; render(); });

	$('#boardBody').on('change', '[data-flag]', function() {
		var $c = $(this), field = $c.attr('data-flag'), value = this.checked ? 'Y' : 'N';
		$c.prop('disabled', true);
		setFlag(field, value, [$c.attr('data-sq')], function(ok) { if (!ok) $c.prop({ checked: !$c.prop('checked'), disabled: false }); });
	});

	$('#bulk').on('click', '[data-bulk]', function() {
		var field = $(this).attr('data-bulk'), value = $(this).attr('data-val'), ids = pickedIds();
		var go = function() { setFlag(field, value, ids, function(ok) { if (ok) picked = {}; }); };
		if (field !== 'del') return go();
		bootbox.confirm({ message: ids.length + '개 글을 삭제할까요? 삭제한 글은 「삭제 포함」에서 스위치로 되살릴 수 있습니다.', locale: 'kr',
			buttons: { confirm: { label: '삭제', className: 'btn-danger' }, cancel: { label: '취소' } }, callback: function(ok) { if (ok) go(); } });
	});

	// 제목에 마우스를 올리면 본문 앞부분을 보여 준다
	var popTimer = null;
	$('#boardBody').on('mouseenter focus', '.brd-link', function() {
		var a = this, r = find($(a).attr('data-sq'));
		if (!r) return;
		clearTimeout(popTimer);
		popTimer = setTimeout(function() {
			var text = $.trim((r._text || '').replace(/ /g, ' ').replace(/\n{3,}/g, '\n\n'));
			$('#pop').empty().append($('<b>').text(r.brdTtl)).append($('<div class="m">').text([r.brdWrtr, r.brdRegDt].filter(Boolean).join(' · ')))
				.append($('<div class="c">').text(text ? (text.length > 300 ? text.substring(0, 300) + '…' : text) : '(내용 없음)')).prop('hidden', false);
			var box = a.getBoundingClientRect(), $p = $('#pop'), h = $p.outerHeight();
			var top = box.bottom + 6 + h > window.innerHeight ? box.top - h - 6 : box.bottom + 6;
			$p.css({ left: Math.min(box.left, window.innerWidth - $p.outerWidth() - 16), top: Math.max(8, top) });
		}, 250);
	}).on('mouseleave blur', '.brd-link', function() { clearTimeout(popTimer); $('#pop').prop('hidden', true); });
	$(window).on('scroll', function() { $('#pop').prop('hidden', true); });

	load();
</script>
</body>
</html>
