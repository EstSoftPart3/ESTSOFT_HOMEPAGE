<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<style>
	.lab-open { background: none; border: 0; padding: 0; color: #0b6e8a; font-weight: 600; text-decoration: underline; cursor: pointer; }
	.lab-info th { width: 110px; background: #f3f6f8; font-weight: 600; }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header"><h3 class="card-title bTitle"><b>월간 연구일지</b></h3></div>
				<div class="card-body">
					<div class="cal-panel">
						<div class="cal-panel-body">
							<div class="form-row align-items-end">
								<div class="col-md-5 col-12 mb-2"><label for="fPrj">과제</label><select id="fPrj" class="form-control form-control-sm"></select></div>
								<div class="col-md-3 col-6 mb-2"><label for="fStatus">상태</label><select id="fStatus" class="form-control form-control-sm"></select></div>
								<div class="col-md-4 col-6 mb-2 text-right"><button type="button" class="btn btn-sm btn-primary" onclick="openNew();"><i class="fas fa-plus"></i> 일지 작성</button></div>
							</div>
						</div>
						<div class="table-responsive px-3">
							<table class="table table-sm table-hover cal-table mb-0">
								<thead><tr><th>대상 월</th><th>과제</th><th>작성자</th><th>상태</th><th>PDF</th></tr></thead>
								<tbody id="listBody"></tbody>
							</table>
						</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="newModal" tabindex="-1" role="dialog" aria-labelledby="newTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<form class="modal-content" onsubmit="createJournal(); return false;">
				<div class="modal-header">
					<h5 class="modal-title" id="newTitle">일지 작성</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<div class="form-group"><label for="newPrj">과제</label><select id="newPrj" class="form-control form-control-sm" required></select></div>
					<div class="form-group"><label for="newYm">대상 월</label><input type="month" id="newYm" class="form-control form-control-sm" required></div>
				</div>
				<div class="modal-footer"><button type="submit" class="btn btn-sm btn-primary">만들기</button></div>
			</form>
		</div>
	</div>

	<div class="modal fade" id="detailModal" tabindex="-1" role="dialog" aria-labelledby="detailTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="detailTitle">월간 연구일지</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<table class="table table-sm table-bordered lab-info"><tbody id="infoBody"></tbody></table>
					<div class="form-group"><label for="content">연구 내용</label><textarea id="content" rows="12" class="form-control form-control-sm"></textarea></div>
					<div id="uploadState" role="status"></div>
					<h6 class="mt-3">처리 이력</h6>
					<div class="table-responsive">
						<table class="table table-sm cal-table mb-0">
							<thead><tr><th>일시</th><th>처리</th><th>처리자</th><th>메모</th></tr></thead>
							<tbody id="historyBody"></tbody>
						</table>
					</div>
				</div>
				<div class="modal-footer" id="detailActions"></div>
			</div>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>
	<script>
	var STATUS = { DRAFT: '작성 중', SUBMITTED: '제출', MANAGER_OK: '부서장 확인', CEO_OK: '대표 확인' };
	var ACTION = { CREATE: '작성 시작', SAVE: '저장', SUBMIT: '제출', APPROVE_MANAGER: '부서장 확인', APPROVE_CEO: '대표 확인', REJECT: '반려', UPLOAD: '드라이브 업로드' };
	var rows = [], current = null;

	function drawList() {
		var prj = $('#fPrj').val(), st = $('#fStatus').val();
		var $b = $('#listBody').empty(), list = rows.filter(function(r) { return (!prj || String(r.PRJ_SQ) === prj) && (!st || r.STATUS_CD === st); });
		if (!list.length) $b.append('<tr><td colspan="5" class="text-center text-muted">일지가 없습니다.</td></tr>');
		list.forEach(function(r) {
			var pdf = r.PDF_LINK ? $('<a target="_blank" rel="noopener">열기</a>').attr('href', r.PDF_LINK) : r.UPLOAD_ERR ? $('<span class="text-danger">업로드 실패</span>') : '';
			$('<tr>').append($('<td>').append($('<button type="button" class="lab-open">').text(r.YM).click(function() { openDetail(r.JRN_SQ); })),
				$('<td>').text(r.PRJ_NM), $('<td>').text(r.WRITER_NM || ''), $('<td>').text(STATUS[r.STATUS_CD]), $('<td>').append(pdf)).appendTo($b);
		});
	}

	function load() {
		hrPost('/admin/lab/journalListData.do', {}, function(res) { rows = res.result; drawList(); });
	}

	function openNew() {
		var d = new Date();
		$('#newYm').val(d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2));
		$('#newModal').modal('show');
	}

	function createJournal() {
		hrPost('/admin/lab/createJournalData.do', { PRJ_SQ: $('#newPrj').val(), YM: $('#newYm').val() }, function(res) {
			$('#newModal').modal('hide');
			load();
			openDetail(res.result);
		});
	}

	function actionButton(label, cls, fn) {
		return $('<button type="button" class="btn btn-sm">').addClass(cls).text(label).click(function() {
			$('#detailActions button').prop('disabled', true);
			fn();
		});
	}

	function refresh() { load(); openDetail(current); }

	function post(url, data, done) {
		hrPost(url, $.extend({ JRN_SQ: current }, data), done || refresh, refresh);
	}

	function openDetail(sq) {
		current = sq;
		hrPost('/admin/lab/journalDetailData.do', { JRN_SQ: sq }, function(res) {
			var r = res.result, j = r.journal, draft = j.STATUS_CD === 'DRAFT';
			var info = [['상태', STATUS[j.STATUS_CD]], ['대상 월', j.YM], ['작성자', j.WRITER_NM], ['연구주제', j.PRJ_NM], ['연구장소', j.PLACE], ['연구기간', j.PERIOD], ['연구인원', r.members || '그 달에 소속된 연구원이 없습니다']];
			var $i = $('#infoBody').empty();
			info.forEach(function(x) { $('<tr>').append($('<th scope="row">').text(x[0]), $('<td>').text(x[1] || '')).appendTo($i); });
			$('#content').val(j.CONTENT || '').prop('readOnly', !draft);

			var $u = $('#uploadState').empty();
			if (j.PDF_LINK) $u.append($('<a target="_blank" rel="noopener" class="btn btn-sm btn-outline-primary">드라이브에서 PDF 열기</a>').attr('href', j.PDF_LINK));
			else if (j.UPLOAD_ERR) $u.append($('<div class="alert alert-danger py-1 small mb-0">').text('업로드 실패: ' + j.UPLOAD_ERR));

			var $h = $('#historyBody').empty();
			r.history.forEach(function(h) {
				$('<tr>').append($('<td>').text(h.REG_DT), $('<td>').text(ACTION[h.ACTION_CD] || h.ACTION_CD), $('<td>').text((h.ACTOR_NM || '') + ' (' + h.ACTOR_ID + ')'), $('<td>').text(h.NOTE || '')).appendTo($h);
			});

			var $a = $('#detailActions').empty();
			if (draft) {
				$a.append(actionButton('저장', 'btn-outline-secondary', function() { post('/admin/lab/saveJournalData.do', { CONTENT: $('#content').val() }); }),
					actionButton('제출', 'btn-primary', function() { post('/admin/lab/submitJournalData.do', { CONTENT: $('#content').val() }); }));
			}
			if (r.canApprove) {
				$a.append(actionButton('반려', 'btn-outline-danger', function() {
					bootbox.prompt({ title: '반려 사유', inputType: 'textarea', callback: function(note) {
						if (note === null) { refresh(); return; }
						post('/admin/lab/rejectJournalData.do', { NOTE: note });
					} });
				}), actionButton(j.STATUS_CD === 'SUBMITTED' ? '부서장 확인' : '대표 확인', 'btn-primary', function() {
					post('/admin/lab/approveJournalData.do', {}, function(ok) {
						if (ok.result.uploadError) bootbox.alert('결재는 끝났지만 PDF 업로드에 실패했습니다. ' + $('<div>').text(ok.result.uploadError).html());
						refresh();
					});
				}));
			}
			if (j.STATUS_CD === 'CEO_OK' && !j.PDF_LINK) {
				$a.append(actionButton('업로드 다시 시도', 'btn-primary', function() { post('/admin/lab/uploadJournalData.do', {}); }));
			}
			$('#detailModal').modal('show');
		});
	}

	$.each($.extend({ '': '전체' }, STATUS), function(k, v) { $('#fStatus').append($('<option>').val(k).text(v)); });
	$('#fPrj, #fStatus').change(drawList);
	hrPost('/admin/lab/optionsData.do', {}, function(res) {
		$('#fPrj').append('<option value="">전체</option>');
		$('#newPrj').append('<option value=""></option>');
		res.result.projects.forEach(function(p) { $('#fPrj, #newPrj').append($('<option>').val(p.PRJ_SQ).text(p.PRJ_NM)); });
		load();
	});
	</script>
</body>
</html>
