<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/deploy/deploy_common.jspf"%>
<style>
	.pt-drop { display: flex; align-items: center; gap: 8px; border: 1px dashed #16a0c4; border-radius: 4px; padding: 4px 10px; background: #f3fbfd; color: #3c4a55; font-size: 12.5px; cursor: pointer; }
	.pt-drop b { color: #0b6f8a; }
	.pt-drop.is-over { background: #d8f1f8; border-style: solid; }
	.pt-drop .btn-link { margin-left: auto; padding: 0; font-size: 12px; color: #6c757d; white-space: nowrap; }
	.pt-queue { font-size: 12px; margin-top: 2px; }
	.pt-q { display: grid; grid-template-columns: 16px minmax(0, 1fr) 120px 1.2fr; gap: 6px; align-items: center; padding: 1px 10px; line-height: 24px; }
	.pt-q .nm { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
	.pt-q select { height: 22px; padding: 0 4px; font-size: 12px; }
	.pt-q .ok { color: #17692f; } .pt-q .run { color: #0b6f8a; } .pt-q .wait { color: #6c757d; } .pt-q .warn { color: #b26a00; }
	.pt-tabs { margin-top: 12px; }
	.pt-tabs .nav-link { padding: 5px 14px; font-size: 13px; }
	.pt-tabs .badge { font-size: 10px; margin-left: 3px; background: #16a0c4; color: #fff; }
	.pt-pane { padding-top: 12px; }
	.pt-fold { display: flex; align-items: center; gap: 6px; width: 100%; margin-top: 10px; padding: 8px 0 4px; border: 0; border-top: 1px solid #dee2e6; background: none; font-weight: bold; font-size: 13px; text-align: left; }
	.pt-fold small { font-weight: normal; color: #6c757d; }
	.pt-chips { display: flex; flex-wrap: wrap; gap: 6px; padding-bottom: 4px; }
	.pt-chip { position: relative; display: inline-flex; align-items: center; gap: 6px; border: 1px solid #dee2e6; border-radius: 14px; padding: 2px 4px 2px 3px; font-size: 12px; background: #fff; }
	.pt-chip.off { border-style: dashed; color: #6c757d; padding: 3px 10px; }
	.pt-chip .ic { width: 22px; height: 22px; border-radius: 11px; background: #f1f3f5; object-fit: contain; display: inline-flex; align-items: center; justify-content: center; font-size: 11px; color: #6c757d; }
	.pt-chip .x { border: 0; background: none; color: #dc3545; font-weight: bold; padding: 0 4px; line-height: 1; }
	.pt-chip .big { display: none; position: absolute; left: 0; bottom: 30px; z-index: 5; max-width: 240px; max-height: 160px; padding: 4px; background: #fff; border: 1px solid #dee2e6; border-radius: 4px; box-shadow: 0 4px 12px rgba(0,0,0,.15); }
	.pt-chip:hover .big, .pt-chip:focus-within .big { display: block; }
	#partnerForm .pt-auto { background: #e3f6fb; border-color: #7fcde0; }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header d-flex align-items-center">
					<h3 class="card-title bTitle"><b>매출/매입처 관리</b></h3>
					<button type="button" class="btn btn-sm btn-primary ml-auto" onclick="openForm(null);"><i class="fas fa-plus"></i> 등록</button>
				</div>
				<div class="card-body">
					<div class="cal-panel">
						<div class="d-flex flex-wrap align-items-center pr-3">
							<div class="cate-tabs" id="tabs" role="tablist" aria-label="구분"></div>
							<input type="search" id="keyword" class="form-control form-control-sm ml-auto" style="width:200px" placeholder="거래처명·사업자번호·담당자" aria-label="검색">
						</div>
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0">
								<thead><tr><th>거래처명</th><th>사업자번호</th><th>대표자</th><th>구분</th><th>담당자</th><th>연락처</th><th>이메일</th><th class="dp-num">투입 기록</th><th>사용</th><th><span class="sr-only">작업</span></th></tr></thead>
								<tbody id="body"></tbody>
							</table>
						</div>
						<div class="small text-muted px-3 py-2">삭제는 투입 기록이 없는 거래처만 됩니다. 기록이 있으면 사용 중지로 바꾸면 새 입력 목록에서만 빠집니다.</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="formModal" tabindex="-1" role="dialog" aria-labelledby="formTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="formTitle">거래처 등록</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<form id="partnerForm" onsubmit="savePartner(); return false;">
					<input type="hidden" name="PARTNER_SQ">
					<div class="modal-body">
						<div class="pt-drop" id="drop" tabindex="0" role="button" aria-label="서류 파일 첨부">
							<i class="fas fa-paperclip" aria-hidden="true"></i>
							<span><b>서류 끌어 놓기·선택</b> (여러 개) — 사업자등록증·로고·직인·통장사본 · PDF·JPG·PNG 5MB</span>
							<button type="button" class="btn btn-link" id="qToggle" aria-controls="queue" hidden></button>
						</div>
						<input type="file" id="docFiles" accept=".pdf,.jpg,.jpeg,.png" multiple hidden>
						<div class="pt-queue" id="queue" aria-live="polite"></div>
						<ul class="nav nav-tabs pt-tabs" role="tablist">
							<li class="nav-item"><a class="nav-link active" href="#" role="tab" data-pane="biz">사업자 정보<span class="badge"></span></a></li>
							<li class="nav-item"><a class="nav-link" href="#" role="tab" data-pane="mgr">담당자<span class="badge"></span></a></li>
							<li class="nav-item"><a class="nav-link" href="#" role="tab" data-pane="bank">계좌 정보<span class="badge"></span></a></li>
						</ul>
						<div class="pt-pane" data-pane="biz" role="tabpanel">
							<div class="form-row" id="bizFields"></div>
							<div class="form-row">
								<div class="col-md-3 mb-2"><span class="d-block small text-muted mb-1">구분 *</span>
									<div class="form-check form-check-inline"><input class="form-check-input" type="checkbox" id="f_SALE_YN" name="SALE_YN" value="Y"><label class="form-check-label" for="f_SALE_YN">매출처</label></div>
									<div class="form-check form-check-inline"><input class="form-check-input" type="checkbox" id="f_BUY_YN" name="BUY_YN" value="Y"><label class="form-check-label" for="f_BUY_YN">매입처</label></div>
								</div>
							</div>
						</div>
						<div class="pt-pane" data-pane="mgr" role="tabpanel" hidden><div class="form-row" id="mgrFields"></div></div>
						<div class="pt-pane" data-pane="bank" role="tabpanel" hidden><div class="form-row" id="bankFields"></div></div>
						<button type="button" class="pt-fold" id="chipFold" aria-controls="chips" aria-expanded="true"></button>
						<div class="pt-chips" id="chips"></div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-sm btn-outline-danger mr-auto" id="btnDelete" onclick="deletePartner();">삭제</button>
						<button type="submit" class="btn btn-sm btn-primary">저장</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>

	<script>
	var BIZ = [['PARTNER_NM', '상호 *', 3], ['BIZ_NO', '사업자등록번호', 3], ['CEO_NM', '대표자', 3], ['OPEN_DT', '개업일', 3, 'date'], ['ADDR', '사업장 주소', 6], ['BIZ_TYPE', '업태', 3], ['BIZ_ITEM', '종목', 3], ['USE_YN', '사용', 3, { values: { Y: '사용', N: '사용 중지' } }]];
	var MGR = [['MGR_NM', '이름', 3], ['MGR_POS', '부서·직책', 3], ['MGR_TEL', '전화', 3], ['MGR_HP', '휴대폰', 3], ['MGR_EMAIL', '이메일', 6, 'email'], ['TAX_EMAIL', '세금계산서 메일', 6, 'email']];
	var BANK = [['BANK_NM', '은행', 3], ['ACCOUNT_NO', '계좌번호', 3], ['ACCOUNT_HOLDER', '예금주', 6]];
	var KINDS = [['LICENSE', '사업자등록증', 'FILE_NM'], ['LOGO', '로고', 'LOGO_NM'], ['SEAL', '직인', 'SEAL_NM'], ['BANK', '통장사본', 'BANK_FILE_NM']];
	var FOLD_KEY = 'partnerChipsFolded';
	var rows = [], tab = '', editing = null;
	var docs = {}, removes = {}, queue = [], busy = false, qOpen = true, qTimer = null, qSeq = 0;

	$(function() {
		hrBuildFields('#bizFields', BIZ);
		hrBuildFields('#mgrFields', MGR);
		hrBuildFields('#bankFields', BANK);
		$('#f_PARTNER_NM').prop('required', true);
		$('#f_BIZ_NO').attr({ pattern: '\\d{3}-\\d{2}-\\d{5}', placeholder: '000-00-00000' });
		$('#keyword').on('input', render);
		$('#drop').on('click', function(e) { if (!$(e.target).closest('#qToggle').length) $('#docFiles').click(); })
			.on('keydown', function(e) { if (e.target === this && (e.key === 'Enter' || e.key === ' ')) { e.preventDefault(); $('#docFiles').click(); } })
			.on('dragover', function(e) { e.preventDefault(); $(this).addClass('is-over'); })
			.on('dragleave', function() { $(this).removeClass('is-over'); })
			.on('drop', function(e) { e.preventDefault(); $(this).removeClass('is-over'); addFiles(e.originalEvent.dataTransfer.files); });
		$('#docFiles').on('change', function() { addFiles(this.files); this.value = ''; });
		$('#qToggle').on('click', function() { qOpen = !qOpen; renderQueue(); });
		$('.pt-tabs .nav-link').on('click', function(e) { e.preventDefault(); showPane($(this).attr('data-pane')); });
		$('#chipFold').on('click', function() { var open = $(this).attr('aria-expanded') !== 'true'; try { localStorage.setItem(FOLD_KEY, open ? '' : 'Y'); } catch (x) {} renderChips(); });
		// 필수 칸이 다른 탭에 숨어 있으면 그 탭을 먼저 연다
		$('#partnerForm [type=submit]').on('click', function() { var $bad = $('#partnerForm :invalid').first(); if ($bad.length) showPane($bad.closest('.pt-pane').attr('data-pane')); });
		$('#partnerForm input').on('input', function() { $(this).removeClass('pt-auto'); });
		load();
	});

	function showPane(p) {
		$('.pt-pane').each(function() { this.hidden = $(this).attr('data-pane') !== p; });
		$('.pt-tabs .nav-link').each(function() { var on = $(this).attr('data-pane') === p; $(this).toggleClass('active', on).attr('aria-selected', on); if (on) $(this).find('.badge').text(''); });
	}

	// ── 서류 올리기: 하나씩 차례로 읽는다 ──
	function addFiles(list) {
		$.each(list, function(i, f) { queue.push({ id: ++qSeq, file: f, kind: '', state: 'wait' }); });
		qOpen = true;
		renderQueue();
		pump();
	}

	function pump() {
		if (busy) return;
		var it = queue.filter(function(q) { return q.state === 'wait'; })[0];
		if (!it) { renderQueue(); return; }
		busy = true;
		it.state = 'run';
		renderQueue();
		var fd = new FormData();
		fd.append('file', it.file);
		if (it.kind) fd.append('KIND', it.kind);
		$.ajax({ url: '/admin/partner/readDocData.do', type: 'POST', data: fd, processData: false, contentType: false }).done(function(res) {
			if (res.error) { it.state = 'err'; it.msg = res.error; return; }
			var r = res.result;
			if (!r.kind) { it.state = 'ask'; it.msg = '종류를 모르겠습니다 — 골라 주세요'; return; }
			attach(it, r.kind);
			var n = fill(r.fields);
			it.state = 'ok';
			it.msg = (n ? n + '칸 채움' : it.kind === 'LOGO' || it.kind === 'SEAL' ? '첨부함' : '첨부만 함') + (r.warning ? ' · ' + r.warning : '');
		}).fail(function() { it.state = 'err'; it.msg = '읽지 못했습니다'; }).always(function() { busy = false; pump(); });
	}

	function attach(it, kind) {
		$.each(docs, function(k, d) { if (d === it.file) delete docs[k]; });
		it.kind = kind;
		docs[kind] = it.file;
		delete removes[kind];
		renderChips();
	}

	/** 칸을 채우고 보이지 않는 탭에는 채운 수를 표시한다 */
	function fill(fields) {
		var n = 0;
		$.each(fields || {}, function(k, v) {
			var $el = $('#partnerForm [name=' + k + ']');
			if (!$el.length) return;
			$el.val(v).addClass('pt-auto');
			n++;
			var pane = $el.closest('.pt-pane');
			if (pane.prop('hidden')) { var $b = $('.pt-tabs [data-pane=' + pane.attr('data-pane') + '] .badge'); $b.text(Number($b.text() || 0) + 1); }
		});
		return n;
	}

	function renderQueue() {
		var $q = $('#queue').empty(), done = queue.filter(function(q) { return q.state === 'ok'; }).length;
		var idle = !queue.some(function(q) { return q.state === 'wait' || q.state === 'run' || q.state === 'ask'; });
		clearTimeout(qTimer);
		if (idle && qOpen && queue.length) qTimer = setTimeout(function() { qOpen = false; renderQueue(); }, 3000);
		$('#qToggle').prop('hidden', !queue.length).attr('aria-expanded', qOpen)
			.text((idle ? '✓ ' + done + '/' + queue.length + ' 완료' : '진행 ' + done + '/' + queue.length) + (qOpen ? ' ▴ 접기' : ' ▾ 펴기'));
		if (!qOpen) return;
		queue.forEach(function(it) {
			var icon = { ok: '✓', run: '…', wait: '○', ask: '!', err: '!' }[it.state];
			var cls = { ok: 'ok', run: 'run', wait: 'wait', ask: 'warn', err: 'warn' }[it.state];
			var $sel = $('<select class="form-control form-control-sm" aria-label="서류 종류">').append($('<option value="">').text('종류 선택'))
				.append(KINDS.map(function(k) { return $('<option>').val(k[0]).text(k[1]); })).val(it.kind)
				.prop('disabled', it.state === 'run' || it.state === 'wait')
				.on('change', function() { if (!this.value) return; it.kind = this.value; it.state = 'wait'; qOpen = true; renderQueue(); pump(); });
			$q.append($('<div class="pt-q">').append($('<span>').addClass(cls).text(icon)).append($('<span class="nm">').text(it.file.name).attr('title', it.file.name))
				.append($sel).append($('<span>').addClass(cls).text(it.state === 'run' ? '읽는 중…' : it.state === 'wait' ? '대기' : it.msg || '')));
		});
	}

	// ── 첨부 서류 칩 ──
	function renderChips() {
		var folded = false;
		try { folded = localStorage.getItem(FOLD_KEY) === 'Y'; } catch (x) {}
		var $c = $('#chips').empty().prop('hidden', folded), n = 0;
		KINDS.forEach(function(k) {
			var f = docs[k[0]], saved = editing && editing[k[2]] && !removes[k[0]];
			if (!f && !saved) { $c.append($('<span class="pt-chip off">').text(k[1] + ' 없음')); return; }
			n++;
			var name = f ? f.name : editing[k[2]];
			var url = f ? URL.createObjectURL(f) : '/admin/partner/partnerFile.do?PARTNER_SQ=' + editing.PARTNER_SQ + '&KIND=' + k[0];
			var img = /\.(png|jpe?g)$/i.test(name);
			var $chip = $('<span class="pt-chip">').attr('title', name)
				.append(img ? $('<img class="ic" alt="">').attr('src', url) : $('<span class="ic" aria-hidden="true">').text('PDF'))
				.append($('<a target="_blank" rel="noopener">').attr('href', url).text(k[1]))
				.append($('<button type="button" class="x">').attr('aria-label', k[1] + ' 지우기').html('&times;').on('click', function() { delete docs[k[0]]; if (saved) removes[k[0]] = true; renderChips(); }));
			if (img) $chip.append($('<img class="big" alt="">').attr('src', url));
			$c.append($chip);
		});
		$('#chipFold').attr('aria-expanded', !folded).empty().append(folded ? '▸ ' : '▾ ').append('첨부 서류 ').append($('<small>').text(n + '/4'));
	}

	function load() { hrPost('/admin/partner/partnerListData.do', {}, function(res) { rows = res.list; render(); }); }

	function inTab(r, t) { return t === 'SALE' ? r.SALE_YN === 'Y' && r.USE_YN === 'Y' : t === 'BUY' ? r.BUY_YN === 'Y' && r.USE_YN === 'Y' : t === 'STOP' ? r.USE_YN !== 'Y' : true; }

	function render() {
		var tabs = [['', '전체'], ['SALE', '매출처'], ['BUY', '매입처'], ['STOP', '사용 중지']];
		$('#tabs').empty().append(tabs.map(function(t) { return hrTab(t[0], t[1], rows.filter(function(r) { return inTab(r, t[0]); }).length, tab === t[0]); }));
		$('#tabs .cate-tab').on('click', function() { tab = $(this).attr('data-tab'); render(); });
		var kw = $.trim($('#keyword').val()).toLowerCase();
		var list = rows.filter(function(r) { return inTab(r, tab) && (!kw || [r.PARTNER_NM, r.BIZ_NO, r.MGR_NM].some(function(v) { return v && v.toLowerCase().indexOf(kw) >= 0; })); });
		var $b = $('#body').empty();
		if (!list.length) $b.append('<tr><td colspan="10" class="text-center text-muted py-4">해당하는 거래처가 없습니다.</td></tr>');
		list.forEach(function(r) {
			var used = Number(r.USE_CNT) > 0;
			$b.append($('<tr>').toggleClass('text-muted', r.USE_YN !== 'Y')
				.append($('<td>').append($('<button type="button" class="dp-name">').text(r.PARTNER_NM).on('click', function() { openForm(r); })))
				.append($('<td>').text(r.BIZ_NO || '')).append($('<td>').text(r.CEO_NM || ''))
				.append($('<td>').append(r.SALE_YN === 'Y' ? '<span class="dp-pill rent">매출</span>' : '').append(r.BUY_YN === 'Y' ? '<span class="dp-pill warn">매입</span>' : ''))
				.append($('<td>').text([r.MGR_NM, r.MGR_POS].filter(Boolean).join(' '))).append($('<td>').text(r.MGR_TEL || r.MGR_HP || '')).append($('<td>').text(r.MGR_EMAIL || ''))
				.append($('<td class="dp-num">').text(r.USE_CNT)).append($('<td>').append($('<span class="dp-pill">').addClass(r.USE_YN === 'Y' ? 'ok' : '').text(r.USE_YN === 'Y' ? '사용' : '중지')))
				.append($('<td class="text-nowrap">').append($('<button type="button" class="btn btn-sm btn-outline-secondary">수정</button>').on('click', function() { openForm(r); }))
					.append(' ').append($('<button type="button" class="btn btn-sm btn-outline-danger">삭제</button>').prop('disabled', used)
						.attr('title', used ? '투입 기록이 있어 삭제할 수 없습니다' : '').on('click', function() { editing = r; deletePartner(); }))));
		});
	}

	function openForm(r) {
		editing = r;
		docs = {}; removes = {}; queue = []; qOpen = true;
		$('#partnerForm')[0].reset();
		$('#partnerForm .pt-auto').removeClass('pt-auto');
		$('.pt-tabs .badge').text('');
		hrFillForm('#partnerForm', BIZ.concat(MGR, BANK), r || { USE_YN: 'Y' });
		$('[name=PARTNER_SQ]').val(r ? r.PARTNER_SQ : '');
		$('#f_SALE_YN').prop('checked', !!r && r.SALE_YN === 'Y');
		$('#f_BUY_YN').prop('checked', !!r && r.BUY_YN === 'Y');
		$('#formTitle').text(r ? '거래처 수정' : '거래처 등록');
		$('#btnDelete').toggle(!!r).prop('disabled', !!r && Number(r.USE_CNT) > 0);
		showPane('biz');
		renderQueue();
		renderChips();
		$('#formModal').modal('show');
	}

	function savePartner() {
		if (!$('#f_SALE_YN').prop('checked') && !$('#f_BUY_YN').prop('checked')) { showPane('biz'); bootbox.alert('매출처·매입처 중 하나 이상 골라 주세요.'); return; }
		if (busy || queue.some(function(q) { return q.state === 'wait'; })) { bootbox.alert('서류를 읽는 중입니다. 끝난 뒤 저장해 주세요.'); return; }
		var fd = new FormData($('#partnerForm')[0]);
		$.each(docs, function(k, f) { fd.append(k, f); });
		fd.append('REMOVE', Object.keys(removes).join(','));
		$.ajax({ url: '/admin/partner/savePartnerData.do', type: 'POST', data: fd, processData: false, contentType: false }).done(function(res) {
			if (res.error) { bootbox.alert(res.error); return; }
			$('#formModal').modal('hide');
			load();
		});
	}

	function deletePartner() {
		if (!editing) return;
		bootbox.confirm(editing.PARTNER_NM + ' 을(를) 삭제할까요? 되돌릴 수 없습니다.', function(ok) {
			if (!ok) return;
			hrPost('/admin/partner/deletePartnerData.do', { PARTNER_SQ: editing.PARTNER_SQ }, function() { $('#formModal').modal('hide'); load(); });
		});
	}
	</script>
</body>
</html>
