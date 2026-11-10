<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/deploy/deploy_common.jspf"%>
<style>
	.pt-drop { border: 2px dashed #b8c2ca; border-radius: 6px; padding: 12px; color: #5f6b75; cursor: pointer; }
	.pt-drop.is-over { border-color: #16a0c4; background: #e3f6fb; }
	.pt-drop.done { border-color: #17692f; background: #e6f6ea; color: #17692f; }
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
						<div class="pt-drop" id="drop" tabindex="0" role="button" aria-label="사업자등록증 첨부">
							<b>사업자등록증</b> 파일(PDF·JPG·PNG, 5MB)을 끌어 놓거나 눌러서 고르면 파란 칸을 자동으로 채웁니다. 확인 후 저장하세요.
							<span id="fileInfo" class="d-block small mt-1"></span>
						</div>
						<input type="file" id="licenseFile" accept=".pdf,.jpg,.jpeg,.png" hidden>
						<div class="hr-section">사업자 정보</div>
						<div class="form-row" id="bizFields"></div>
						<div class="form-row">
							<div class="col-md-3 mb-2"><span class="d-block small text-muted mb-1">구분 *</span>
								<div class="form-check form-check-inline"><input class="form-check-input" type="checkbox" id="f_SALE_YN" name="SALE_YN" value="Y"><label class="form-check-label" for="f_SALE_YN">매출처</label></div>
								<div class="form-check form-check-inline"><input class="form-check-input" type="checkbox" id="f_BUY_YN" name="BUY_YN" value="Y"><label class="form-check-label" for="f_BUY_YN">매입처</label></div>
							</div>
						</div>
						<div class="hr-section">담당자</div>
						<div class="form-row" id="mgrFields"></div>
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
	var rows = [], tab = '', file = null, editing = null;

	$(function() {
		hrBuildFields('#bizFields', BIZ);
		hrBuildFields('#mgrFields', MGR);
		$('#f_PARTNER_NM').prop('required', true);
		$('#f_BIZ_NO').attr({ pattern: '\\d{3}-\\d{2}-\\d{5}', placeholder: '000-00-00000' });
		$('#keyword').on('input', render);
		$('#drop').on('click', function() { $('#licenseFile').click(); })
			.on('keydown', function(e) { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); $('#licenseFile').click(); } })
			.on('dragover', function(e) { e.preventDefault(); $(this).addClass('is-over'); })
			.on('dragleave', function() { $(this).removeClass('is-over'); })
			.on('drop', function(e) { e.preventDefault(); $(this).removeClass('is-over'); var f = e.originalEvent.dataTransfer.files[0]; if (f) readLicense(f); });
		$('#licenseFile').on('change', function() { if (this.files[0]) readLicense(this.files[0]); });
		$('#partnerForm input').on('input', function() { $(this).removeClass('pt-auto'); });
		load();
	});

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
		file = null;
		$('#partnerForm')[0].reset();
		$('#partnerForm .pt-auto').removeClass('pt-auto');
		hrFillForm('#partnerForm', BIZ.concat(MGR), r || { USE_YN: 'Y' });
		$('[name=PARTNER_SQ]').val(r ? r.PARTNER_SQ : '');
		$('#f_SALE_YN').prop('checked', !!r && r.SALE_YN === 'Y');
		$('#f_BUY_YN').prop('checked', !!r && r.BUY_YN === 'Y');
		$('#formTitle').text(r ? '거래처 수정' : '거래처 등록');
		$('#btnDelete').toggle(!!r).prop('disabled', !!r && Number(r.USE_CNT) > 0);
		$('#drop').removeClass('done');
		$('#fileInfo').empty();
		if (r && r.FILE_NM) $('#fileInfo').append('첨부됨: ').append($('<a target="_blank" rel="noopener">').attr('href', '/admin/partner/partnerFile.do?PARTNER_SQ=' + r.PARTNER_SQ).text(r.FILE_NM).on('click', function(e) { e.stopPropagation(); }));
		$('#formModal').modal('show');
	}

	function readLicense(f) {
		file = f;
		$('#fileInfo').text(f.name + ' 읽는 중…');
		var fd = new FormData();
		fd.append('file', f);
		$.ajax({ url: '/admin/partner/readLicenseData.do', type: 'POST', data: fd, processData: false, contentType: false }).done(function(res) {
			if (res.error) { file = null; $('#fileInfo').text(''); bootbox.alert(res.error); return; }
			var fields = res.result.fields, n = 0;
			$.each(fields, function(k, v) { var $el = $('#partnerForm [name=' + k + ']'); if ($el.length) { $el.val(v).addClass('pt-auto'); n++; } });
			$('#drop').addClass('done');
			$('#fileInfo').text('✓ ' + f.name + (n ? ' · 파란 칸 ' + n + '개를 채웠습니다' : ' · 첨부만 했습니다') + (res.result.warning ? ' · ' + res.result.warning : ''));
		}).fail(function() { file = null; $('#fileInfo').text(''); });
	}

	function savePartner() {
		var fd = new FormData($('#partnerForm')[0]);
		if (file) fd.append('file', file);
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
