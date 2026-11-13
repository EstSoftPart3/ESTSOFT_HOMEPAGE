<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<style>
	.cp-drop { border: 2px dashed #b9dbe6; border-radius: 12px; background: #f3fbfd; padding: 34px 16px; text-align: center; color: #0b6e8a; cursor: pointer; transition: background .15s, border-color .15s; }
	.cp-drop.over { background: #dff3f9; border-color: #0b6e8a; }
	.cp-drop:focus { outline: 2px solid #16d5ff; outline-offset: 2px; }
	.cp-drop b { display: block; font-size: 16px; margin-bottom: 4px; }
	.cp-drop small { color: #5f6b75; }
	.cp-sum { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
	.cp-chip { border: 1px solid rgba(17,17,17,.15); border-radius: 999px; padding: 2px 12px; font-weight: 700; font-size: 12.5px; }
	.cp-chip.good { border-color: #0b6e8a; color: #0b6e8a; }
	#cpBody td { vertical-align: middle; }
	.cp-num { text-align: right; font-variant-numeric: tabular-nums; }
	/* 상태: 대기 · 올리는 중(막대 %) · 줄이는 중(줄무늬 흐름) · 완료 · 원본 그대로 · 오류 */
	.cp-st { min-width: 210px; }
	.cp-st .msg { display: flex; align-items: center; gap: 6px; font-weight: 700; font-size: 12.5px; }
	.cp-st.wait .msg { color: #8a949c; font-weight: 400; } .cp-st.up .msg, .cp-st.work .msg { color: #0b6e8a; }
	.cp-st.ok .msg { color: #17692f; } .cp-st.same .msg { color: #7a5600; } .cp-st.err .msg { color: #a32020; }
	.cp-bar { height: 6px; border-radius: 3px; background: #e3edf1; overflow: hidden; margin-top: 4px; }
	.cp-bar i { display: block; height: 100%; width: 0; background: #0b6e8a; border-radius: 3px; transition: width .2s; }
	.cp-st.work .cp-bar i, .cp-prog.run .cp-bar i { background-image: repeating-linear-gradient(45deg, rgba(255,255,255,.35) 0 8px, transparent 8px 16px); background-size: 23px 23px; animation: cp-flow .8s linear infinite; }
	.cp-st.work .cp-bar i { width: 100%; }
	@keyframes cp-flow { to { background-position: 23px 0; } }
	#cpBody tr.busy td { background: #eef9fc; }
	.cp-prog { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; font-weight: 700; color: #0b6e8a; }
	.cp-prog .cp-bar { flex: 1; height: 10px; margin: 0; } .cp-prog .cp-bar i { background-color: #0b6e8a; }
	@media (prefers-reduced-motion: reduce) { .cp-bar i { animation: none !important; transition: none; } .fa-spin { animation: none; } }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header">
					<h3 class="card-title bTitle"><b>파일 용량 줄이기</b></h3>
				</div>
				<div class="card-body">
					<div class="cal-panel">
						<div class="cal-panel-body">
							<div class="cp-drop" id="cpDrop" tabindex="0" role="button" aria-label="파일을 끌어다 놓거나 눌러서 고르기">
								<b>파일을 여기에 끌어다 놓거나, 눌러서 고르세요 (여러 개 가능)</b>
								<small>PDF 는 글자는 그대로 두고 안의 사진·스캔만 줄이고, 사진(JPG·PNG)은 긴 변 2000px 로 줄여요. 한 파일 50MB 까지 · 파일은 서버에 남지 않아요.</small>
							</div>
							<input type="file" id="cpFile" multiple hidden>
						</div>
					</div>
					<div class="cal-panel">
						<div class="cal-panel-body">
							<div class="cp-sum mb-2">
								<span class="cp-chip" id="cpCount">0개</span>
								<span class="cp-chip good" id="cpSaved">줄어든 용량 0KB</span>
								<button type="button" class="btn btn-sm btn-primary ml-auto" id="cpAll" disabled><i class="fas fa-download"></i> 모두 받기</button>
								<button type="button" class="btn btn-sm btn-outline-secondary" id="cpClear">목록 비우기</button>
							</div>
							<div class="cp-prog" id="cpProg" hidden role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-label="전체 진행">
								<span id="cpProgText"></span><div class="cp-bar"><i></i></div>
							</div>
							<table class="table table-sm cal-table mb-0">
								<thead><tr><th>파일</th><th class="cp-num">원본</th><th class="cp-num">압축</th><th class="cp-num">줄어듦</th><th>상태</th><th></th></tr></thead>
								<tbody id="cpBody"><tr class="cp-empty"><td colspan="6" class="text-center text-muted py-4">아직 고른 파일이 없습니다.</td></tr></tbody>
							</table>
						</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>

	<script>
	var queue = [], running = 0, saved = 0, done = [], total = 0, finished = 0, gen = 0;

	function size(n) { return n >= 1048576 ? (n / 1048576).toFixed(1) + 'MB' : Math.max(1, Math.round(n / 1024)) + 'KB'; }

	// 상태 칸 그리기. kind: wait·up·work·ok·same·err, pct 는 올리는 중의 %
	var ICON = { wait: 'far fa-clock', up: 'fas fa-cloud-upload-alt', work: 'fas fa-spinner fa-spin', ok: 'fas fa-check-circle', same: 'fas fa-minus-circle', err: 'fas fa-times-circle' };
	function status(it, kind, text, pct) {
		it.$st.attr('class', 'cp-st ' + kind).empty().append($('<div class="msg">').append($('<i aria-hidden="true">').addClass(ICON[kind])).append($('<span>').text(text)));
		if (kind === 'up' || kind === 'work') it.$st.append($('<div class="cp-bar">').append($('<i>').css('width', kind === 'up' ? (pct || 0) + '%' : '')));
		it.$st.closest('tr').toggleClass('busy', kind === 'up' || kind === 'work');
	}

	// 전체 진행: 끝난 개수 / 고른 개수
	function progress() {
		var pct = total ? Math.round(finished / total * 100) : 0, run = finished < total;
		$('#cpProg').prop('hidden', !total).toggleClass('run', run).attr('aria-valuenow', pct);
		$('#cpProgText').text(run ? finished + ' / ' + total + ' 처리 중' : total + '개 모두 끝났습니다');
		$('#cpProg .cp-bar i').css('width', pct + '%');
	}

	function add(files) {
		$('#cpBody .cp-empty').remove();
		$.each(files, function(i, f) {
			var $st = $('<td>'), $after = $('<td class="cp-num">'), $pct = $('<td class="cp-num">'), $get = $('<td class="text-right">');
			$('#cpBody').append($('<tr>').append($('<td>').text(f.name), $('<td class="cp-num">').text(size(f.size)), $after, $pct, $st, $get));
			var it = { f: f, $st: $st, $after: $after, $pct: $pct, $get: $get, gen: gen };
			status(it, 'wait', '대기');
			queue.push(it);
			total++;
		});
		$('#cpCount').text(total + '개');
		progress();
		next();
	}

	function finish(it, kind, text) {
		status(it, kind, text);
		if (it.gen !== gen) return false;
		finished++;
		progress();
		return true;
	}

	// 서버 부담을 줄이려고 2개씩 차례로 보낸다
	function next() {
		while (running < 2 && queue.length) send(queue.shift());
	}

	function send(it) {
		running++;
		var fd = new FormData(), xhr = new XMLHttpRequest();
		fd.append('file', it.f);
		xhr.open('POST', '/admin/tool/compressData.do');
		xhr.responseType = 'blob';
		status(it, 'up', '올리는 중 0%', 0);
		xhr.upload.onprogress = function(e) {
			if (!e.lengthComputable) return;
			var p = Math.round(e.loaded / e.total * 100);
			if (p < 100) status(it, 'up', '올리는 중 ' + p + '%', p); else status(it, 'work', '줄이는 중…');
		};
		xhr.upload.onload = function() { status(it, 'work', '줄이는 중…'); };
		xhr.onload = function() {
			running--;
			if (xhr.status !== 200) {
				var r = new FileReader();
				r.onload = function() { finish(it, 'err', xhr.status === 400 ? r.result : '실패했습니다 (' + xhr.status + ')'); };
				r.readAsText(xhr.response);
			} else {
				var before = +xhr.getResponseHeader('X-Before'), after = +xhr.getResponseHeader('X-After'), name = decodeURIComponent(xhr.getResponseHeader('X-Name') || it.f.name);
				var url = URL.createObjectURL(xhr.response), $a = $('<a class="btn btn-sm btn-outline-primary">').attr({ href: url, download: name }).text('받기');
				it.$after.text(size(after));
				it.$pct.text(after < before ? Math.round((1 - after / before) * 100) + '%' : '—');
				if (!finish(it, after < before ? 'ok' : 'same', after < before ? '완료' : '줄일 수 없음 · 원본 그대로')) { URL.revokeObjectURL(url); next(); return; }
				it.$get.append($a);
				saved += before - after;
				done.push($a[0]);
				$('#cpSaved').text('줄어든 용량 ' + size(saved));
				$('#cpAll').prop('disabled', false);
			}
			next();
		};
		xhr.onerror = function() { running--; finish(it, 'err', '연결이 끊겼습니다'); next(); };
		xhr.send(fd);
	}

	$(function() {
		var $d = $('#cpDrop');
		$d.on('click', function() { $('#cpFile').click(); })
			.on('keydown', function(e) { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); $('#cpFile').click(); } })
			.on('dragover dragenter', function(e) { e.preventDefault(); $d.addClass('over'); })
			.on('dragleave drop', function() { $d.removeClass('over'); })
			.on('drop', function(e) { e.preventDefault(); add(e.originalEvent.dataTransfer.files); });
		$('#cpFile').on('change', function() { add(this.files); this.value = ''; });
		// 브라우저가 여러 파일 받기를 막지 않게 조금씩 띄워서 누른다
		$('#cpAll').on('click', function() { done.forEach(function(a, i) { setTimeout(function() { a.click(); }, i * 400); }); });
		$('#cpClear').on('click', function() {
			done.forEach(function(a) { URL.revokeObjectURL(a.href); });
			// 처리 중이던 파일은 끝나도 이번 목록 건수·받기에 넣지 않는다(gen 이 바뀜)
			done = []; saved = 0; queue = []; total = 0; finished = 0; gen++;
			progress();
			$('#cpBody').html('<tr class="cp-empty"><td colspan="6" class="text-center text-muted py-4">아직 고른 파일이 없습니다.</td></tr>');
			$('#cpCount').text('0개'); $('#cpSaved').text('줄어든 용량 0KB'); $('#cpAll').prop('disabled', true);
		});
		// 화면 밖에 떨어뜨려 파일이 브라우저에서 열리는 것을 막는다
		$(document).on('dragover drop', function(e) { if (!$(e.target).closest('#cpDrop').length) e.preventDefault(); });
	});
	</script>
</body>
</html>
