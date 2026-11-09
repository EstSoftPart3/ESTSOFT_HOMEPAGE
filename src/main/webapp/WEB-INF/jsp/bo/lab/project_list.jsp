<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header"><h3 class="card-title bTitle"><b>연구과제</b></h3></div>
				<div class="card-body">
					<div class="cal-panel">
						<div class="cal-panel-body text-right">
							<button type="button" class="btn btn-sm btn-primary" onclick="openForm();"><i class="fas fa-plus"></i> 과제 등록</button>
						</div>
						<div class="table-responsive px-3">
							<table class="table table-sm table-hover cal-table mb-0 text-nowrap">
								<thead><tr><th>과제명</th><th>연구기간</th><th>연구장소</th><th>부서장</th><th>대표</th><th>드라이브</th><th><span class="sr-only">수정</span></th></tr></thead>
								<tbody id="listBody"></tbody>
							</table>
						</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="formModal" tabindex="-1" role="dialog" aria-labelledby="formTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<form class="modal-content" onsubmit="save(); return false;">
				<div class="modal-header">
					<h5 class="modal-title" id="formTitle">연구과제</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<input type="hidden" id="PRJ_SQ">
					<div class="form-group"><label for="PRJ_NM">과제명</label><input id="PRJ_NM" class="form-control form-control-sm" maxlength="200" required></div>
					<div class="form-row">
						<div class="form-group col-6"><label for="START_DT">연구 시작일</label><input type="date" id="START_DT" class="form-control form-control-sm" required></div>
						<div class="form-group col-6"><label for="END_DT">연구 종료일</label><input type="date" id="END_DT" class="form-control form-control-sm" required></div>
					</div>
					<div class="form-group"><label for="PLACE">연구장소</label><input id="PLACE" class="form-control form-control-sm" maxlength="200" required></div>
					<div class="form-row">
						<div class="form-group col-6"><label for="MANAGER_EMPLY_ID">결재자: 부서장</label><select id="MANAGER_EMPLY_ID" class="form-control form-control-sm approver" required></select></div>
						<div class="form-group col-6"><label for="CEO_EMPLY_ID">결재자: 대표</label><select id="CEO_EMPLY_ID" class="form-control form-control-sm approver" required></select></div>
					</div>
					<div class="form-group">
						<label for="DRIVE_FOLDER_ID">드라이브 과제 폴더 (주소 또는 ID)</label>
						<input id="DRIVE_FOLDER_ID" class="form-control form-control-sm" required aria-describedby="folderHelp">
						<small id="folderHelp" class="form-text text-muted">대표 확인이 끝나면 PDF 가 이 폴더의 <b>02. 연구일지</b> 에 올라갑니다.</small>
					</div>
				</div>
				<div class="modal-footer"><button type="submit" class="btn btn-sm btn-primary">저장</button></div>
			</form>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>
	<script>
	var FIELDS = ['PRJ_SQ', 'PRJ_NM', 'START_DT', 'END_DT', 'PLACE', 'MANAGER_EMPLY_ID', 'CEO_EMPLY_ID', 'DRIVE_FOLDER_ID'];

	function load() {
		hrPost('/admin/lab/projectListData.do', {}, function(res) {
			var $b = $('#listBody').empty();
			if (!res.result.length) $b.append('<tr><td colspan="7" class="text-center text-muted">등록된 과제가 없습니다.</td></tr>');
			res.result.forEach(function(r) {
				$('<tr>').append($('<td>').text(r.PRJ_NM), $('<td>').text(r.START_DT + ' ~ ' + r.END_DT), $('<td>').text(r.PLACE),
					$('<td>').text(r.MANAGER_NM || r.MANAGER_EMPLY_ID), $('<td>').text(r.CEO_NM || r.CEO_EMPLY_ID),
					$('<td>').append($('<a target="_blank" rel="noopener">폴더 열기</a>').attr('href', 'https://drive.google.com/drive/folders/' + encodeURIComponent(r.DRIVE_FOLDER_ID))),
					$('<td class="text-right">').append($('<button type="button" class="btn btn-sm btn-outline-secondary">수정</button>').click(function() { openForm(r); }))
				).appendTo($b);
			});
		});
	}

	function openForm(r) {
		FIELDS.forEach(function(f) { $('#' + f).val(r && r[f] || ''); });
		$('#formModal').modal('show');
	}

	function save() {
		var data = {};
		FIELDS.forEach(function(f) { data[f] = $('#' + f).val(); });
		hrPost('/admin/lab/saveProjectData.do', data, function() { $('#formModal').modal('hide'); load(); });
	}

	hrPost('/admin/lab/optionsData.do', {}, function(res) {
		var $s = $('.approver').append('<option value=""></option>');
		res.result.accounts.forEach(function(a) { $s.append($('<option>').val(a.EMPLY_ID).text(a.EMPLY_NM + ' (' + a.EMPLY_ID + ')')); });
		load();
	});
	</script>
</body>
</html>
