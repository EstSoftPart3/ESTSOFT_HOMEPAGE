<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header"><h3 class="card-title bTitle"><b>연구원</b></h3></div>
				<div class="card-body">
					<div class="cal-panel">
						<div class="cal-panel-body text-right">
							<button type="button" class="btn btn-sm btn-primary" onclick="openForm();"><i class="fas fa-plus"></i> 연구원 등록</button>
						</div>
						<div class="table-responsive px-3">
							<table class="table table-sm table-hover cal-table mb-0">
								<thead><tr><th>성명</th><th>부서</th><th>역할</th><th>소속 시작일</th><th>소속 종료일</th><th><span class="sr-only">수정</span></th></tr></thead>
								<tbody id="listBody"></tbody>
							</table>
						</div>
						<div class="small text-muted px-3 py-2">연구소에서 빠지면 소속 종료일을 입력합니다. 월간 연구일지의 연구인원은 이 소속 기간으로 자동으로 채워집니다.</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="formModal" tabindex="-1" role="dialog" aria-labelledby="formTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<form class="modal-content" onsubmit="save(); return false;">
				<div class="modal-header">
					<h5 class="modal-title" id="formTitle">연구원</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<input type="hidden" id="RSCH_SQ">
					<div class="form-group"><label for="STAFF_SQ">직원</label><select id="STAFF_SQ" class="form-control form-control-sm" required></select></div>
					<div class="form-group"><label for="ROLE_CD">역할</label>
						<select id="ROLE_CD" class="form-control form-control-sm"><option value="MEMBER">연구원</option><option value="HEAD">연구소장</option></select></div>
					<div class="form-group"><label for="START_DT">소속 시작일</label><input type="date" id="START_DT" class="form-control form-control-sm" required></div>
					<div class="form-group"><label for="END_DT">소속 종료일</label><input type="date" id="END_DT" class="form-control form-control-sm"></div>
				</div>
				<div class="modal-footer"><button type="submit" class="btn btn-sm btn-primary">저장</button></div>
			</form>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>
	<script>
	var FIELDS = ['RSCH_SQ', 'STAFF_SQ', 'ROLE_CD', 'START_DT', 'END_DT'];

	function load() {
		hrPost('/admin/lab/researcherListData.do', {}, function(res) {
			var $b = $('#listBody').empty();
			if (!res.result.length) $b.append('<tr><td colspan="6" class="text-center text-muted">등록된 연구원이 없습니다.</td></tr>');
			res.result.forEach(function(r) {
				$('<tr>').append($('<td>').text(r.STAFF_NM), $('<td>').text(r.DEPT_NM || ''), $('<td>').text(r.ROLE_CD === 'HEAD' ? '연구소장' : '연구원'),
					$('<td>').text(r.START_DT), $('<td>').text(r.END_DT || '소속 중'),
					$('<td class="text-right">').append($('<button type="button" class="btn btn-sm btn-outline-secondary">수정</button>').click(function() { openForm(r); }))
				).appendTo($b);
			});
		});
	}

	function openForm(r) {
		FIELDS.forEach(function(f) { $('#' + f).val(r && r[f] || (f === 'ROLE_CD' ? 'MEMBER' : '')); });
		$('#formModal').modal('show');
	}

	function save() {
		var data = {};
		FIELDS.forEach(function(f) { data[f] = $('#' + f).val(); });
		hrPost('/admin/lab/saveResearcherData.do', data, function() { $('#formModal').modal('hide'); load(); });
	}

	hrPost('/admin/lab/optionsData.do', {}, function(res) {
		var $s = $('#STAFF_SQ').append('<option value=""></option>');
		res.result.staff.forEach(function(s) {
			$s.append($('<option>').val(s.STAFF_SQ).text(s.STAFF_NM + (s.DEPT_NM ? ' (' + s.DEPT_NM + ')' : '') + (s.STATUS_CD === 'LEFT' ? ' - 퇴사' : '')));
		});
		load();
	});
	</script>
</body>
</html>
