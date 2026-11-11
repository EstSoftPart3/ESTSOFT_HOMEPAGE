<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/board/board_style.jspf"%>

<body class="hold-transition sidebar-mini">

	<div class="wrapper">

		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>

		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-body">
					<nav class="brd-crumb" aria-label="경로"><a href="/admin/board/openBoardManage.do">게시판 관리</a> › <a id="crumbBoard" href="#"></a> › <span id="crumbNo"></span></nav>

					<article class="cal-panel">
						<header class="brd-head">
							<h2 class="brd-title" id="title">불러오는 중…</h2>
							<div class="brd-meta" id="meta"></div>
						</header>
						<div class="brd-extra" id="extra" hidden></div>
						<%-- 외부 사용자가 쓴 글도 있어 스크립트 없이(sandbox) 보여 준다 --%>
						<iframe class="brd-body" id="body" title="본문" sandbox="allow-same-origin allow-popups allow-popups-to-escape-sandbox"></iframe>
						<footer class="brd-bar">
							<a class="btn btn-sm btn-outline-secondary" id="btnList" href="#"><i class="fas fa-arrow-left"></i> 목록</a>
							<span class="mr-auto"></span>
							<a class="btn btn-sm btn-outline-secondary" id="btnReply" href="#" hidden><i class="fas fa-reply"></i> 답글</a>
							<button type="button" class="btn btn-sm btn-outline-secondary" id="btnBlind" hidden><i class="fas fa-eye-slash"></i> <span></span></button>
							<a class="btn btn-sm btn-dark" id="btnEdit" href="#"><i class="fas fa-pen"></i> 수정</a>
							<button type="button" class="btn btn-sm btn-outline-danger" id="btnDelete"><i class="fas fa-trash-alt"></i> 삭제</button>
						</footer>
					</article>

					<section class="cal-panel" id="thread" hidden>
						<div class="cal-panel-head" id="threadHead"></div>
						<div class="list-group list-group-flush" id="threadList"></div>
					</section>
				</div>
			</section>
		</div>
	</div>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/board/board_common.jspf"%>
<script>
	var B = boardOf('<c:out value="${board}"/>'), brdSq = boardParam('brdSq');

	$('#crumbBoard').text(B.name).attr('href', boardUrl(B.key, 'List'));
	$('#crumbNo').text(brdSq + '번');
	$('#btnList').attr('href', boardUrl(B.key, 'List'));
	$('#btnEdit').attr('href', boardUrl(B.key, 'Update') + '?brdSq=' + encodeURIComponent(brdSq));
	$('#btnReply').prop('hidden', !B.reply).attr('href', boardUrl(B.key, 'ReplyInsert') + '?brdSq=' + encodeURIComponent(brdSq));

	function fail(msg) { bootbox.alert(msg || '처리하지 못했습니다. 다시 로그인한 뒤 시도해 주세요.'); }

	$.post(boardData(B.key, 'DetailData'), { brdSq: brdSq }, null, 'json').done(function(res) {
		var r = ((res[B.key + 'BoardDetailData'] || {})[B.key + 'BoardDetailData'] || [])[0];
		if (!r) { $('#title').text('글을 찾을 수 없습니다.'); $('.brd-bar .btn').not('#btnList').prop('hidden', true); return; }
		document.title = r.brdTtl;
		$('#title').text(r.brdTtl).append(r.useYn === 'N' ? ' <span class="cate-badge">미사용</span>' : '').append(r.delYn === 'Y' ? ' <span class="cate-badge brd-red">삭제됨</span>' : '')
			.append(r.blindYn === 'Y' ? ' <span class="cate-badge brd-blind">블라인드</span>' : '');
		$('#btnBlind').prop('hidden', false).attr('data-val', r.blindYn === 'Y' ? 'N' : 'Y').find('span').text(r.blindYn === 'Y' ? '블라인드 해제' : '블라인드');
		$('#meta').empty().append([['작성자', r.brdWrtr], ['등록', r.brdRegDt], ['수정', r.brdUpdtDt]].filter(function(m) { return m[1]; })
			.map(function(m) { return $('<span>').text(m[0] + ' ' + m[1]); }));
		if (B.extra) $('#extra').prop('hidden', false).empty().append(B.extra.map(function(e) { return $('<span>').append($('<b>').text(e[1])).append(document.createTextNode(' ' + (r[e[0]] || '-'))); }));
		boardFrame(document.getElementById('body'), boardHtml(r.brdCntnt));
		if (B.reply) loadThread(r);
	}).fail(function() { fail(); });

	// 원글·답글은 같은 BRD_RE_REF 로 묶여 있고, 목록 데이터가 이미 원글 → 답글 순서다
	function loadThread(cur) {
		$.post(boardData(B.key, 'ListData'), {}, null, 'json').done(function(res) {
			var all = ((res[B.key + 'BoardData'] || {})[B.key + 'BoardInfo'] || []);
			var rows = all.filter(function(x) { return String(x.brdReRep) === String(cur.brdReRep); });
			if (rows.length < 2) return;
			$('#threadHead').text('이 글의 답글 ' + (rows.length - 1));
			$('#threadList').empty().append(rows.map(function(x) {
				var on = String(x.brdSq) === String(cur.brdSq);
				return $('<a class="list-group-item list-group-item-action brd-thread">').toggleClass('active-row', on).attr('aria-current', on ? 'page' : null)
					.attr('href', boardUrl(B.key, 'Detail') + '?brdSq=' + encodeURIComponent(x.brdSq))
					.append($('<span class="t">').text((x.brdReLev > 0 ? '   '.repeat(x.brdReLev - 1) + '└ ' : '') + x.brdTtl).toggleClass('text-muted', x.delYn === 'Y'))
					.append($('<span class="m">').text(x.brdWrtr + ' · ' + (x.brdRegDt || '').substring(5, 10)));
			}));
			$('#thread').prop('hidden', false);
		});
	}

	$('#btnBlind').on('click', function() {
		$.post('/admin/board/boardFlagData.do', { field: 'blind', value: $(this).attr('data-val'), brdSq: brdSq }, null, 'json').done(function(res) {
			if (res.error) fail(res.error); else location.reload();
		}).fail(function() { fail(); });
	});

	$('#btnDelete').on('click', function() {
		bootbox.confirm({ message: '이 글을 삭제할까요? 삭제한 글은 수정 화면에서 되살릴 수 있습니다.', locale: 'kr', buttons: { confirm: { label: '삭제', className: 'btn-danger' }, cancel: { label: '취소' } }, callback: function(ok) {
			if (!ok) return;
			$.post(boardData(B.key, 'DeleteData'), { brdSq: brdSq }).done(function() { location.href = boardUrl(B.key, 'List'); }).fail(function() { fail('삭제하지 못했습니다.'); });
		} });
	});
</script>
</body>
</html>
