<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>

<body class="hold-transition sidebar-mini">

	<div class="wrapper">

		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>

		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header">
					<h3 class="card-title bTitle"><b>교육생 관리</b></h3>
				</div>

				<div class="card-body">
					<div class="cal-panel">
						<div class="cal-panel-body">
							<div class="form-row align-items-end">
								<div class="col-md-3 col-12 mb-2">
									<label for="keyword">검색 (이름·메모)</label>
									<input type="search" id="keyword" class="form-control form-control-sm">
								</div>
								<div class="col-md-1 col-6 mb-2"><label for="fGender">성별</label><select id="fGender" class="form-control form-control-sm hr-board-filter"></select></div>
								<div class="col-md-1 col-6 mb-2"><label for="fInterview">인터뷰</label><select id="fInterview" class="form-control form-control-sm hr-board-filter"></select></div>
								<div class="col-md-1 col-6 mb-2"><label for="fLocal">지방 가능</label><select id="fLocal" class="form-control form-control-sm hr-board-filter"></select></div>
								<div class="col-md-1 col-6 mb-2"><label for="fLeave">퇴사·잠수</label><select id="fLeave" class="form-control form-control-sm hr-board-filter"></select></div>
								<div class="col-md-2 col-6 mb-2">
									<label for="sortSel">정렬</label>
									<select id="sortSel" class="form-control form-control-sm hr-board-filter">
										<option value="startDesc">시작일 최신순</option>
										<option value="startAsc">시작일 오래된순</option>
										<option value="name">이름순</option>
										<option value="seq">순번순</option>
									</select>
								</div>
								<div class="col-md-3 col-12 mb-2 text-right">
									<button type="button" class="btn btn-sm btn-outline-secondary" onclick="resetFilters();"><i class="fas fa-undo"></i> 초기화</button>
									<button type="button" class="btn btn-sm btn-outline-primary" onclick="openEdit({ STATUS_CD: current });"><i class="fas fa-plus"></i> 직접 등록</button>
									<button type="button" class="btn btn-sm btn-primary" onclick="openImport();"><i class="fas fa-file-import"></i> 면접관리에서 가져오기</button>
								</div>
							</div>
						</div>
					</div>

					<div class="cal-panel">
						<div class="cate-tabs" id="tabs" role="tablist" aria-label="교육 상태"></div>
						<div class="px-3 pb-3" id="board"></div>
						<div class="small text-muted px-3 pb-2">카드의 값을 누르면 바로 수정됩니다. 교육진행중 카드는 끌어서 주차를 옮깁니다. 교육일수는 일요일을 뺀 일수이고, 연장은 기준 28일을 넘긴 일수입니다.</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="editModal" tabindex="-1" role="dialog" aria-labelledby="editTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="editTitle">교육생</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<form id="editForm" onsubmit="saveEdit(); return false;">
					<div class="modal-body">
						<div class="form-row" id="editFields"></div>
						<div id="skillArea">
							<div class="hr-section">기술 평가 <span class="small text-muted font-weight-normal">(바꾸면 바로 저장됩니다)</span></div>
							<div class="form-row" id="skillBox"></div>
						</div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-sm btn-outline-danger mr-auto" id="btnDelete" onclick="deleteEdit();">삭제</button>
						<button type="submit" class="btn btn-sm btn-primary">저장</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<div class="modal fade" id="importModal" tabindex="-1" role="dialog" aria-labelledby="importTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="importTitle">면접관리에서 가져오기</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<p class="small text-muted mb-2">입사여부가 `입사`이고 아직 교육생과 연결되지 않은 면접자입니다. 선택하면 교육진행중으로 등록됩니다.</p>
					<label for="importKeyword" class="small mb-1">이름·연락처 검색</label>
					<input type="search" id="importKeyword" class="form-control form-control-sm mb-2">
					<div class="table-responsive" style="max-height:50vh;">
						<table class="table table-sm table-hover cal-table mb-0">
							<thead><tr><th style="width:36px;"><span class="sr-only">선택</span></th><th>이름</th><th>면접일자</th><th>연락처</th><th>출근일</th><th>확인</th></tr></thead>
							<tbody id="importBody"></tbody>
						</table>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-sm btn-primary" id="btnImport" onclick="runImport();">선택한 면접자 가져오기</button>
				</div>
			</div>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>

	<script>
	var STATUS = { ING: '교육진행중', END: '교육종료', DROP: '중도이탈' };
	var WEEKS = [['1', '1주차'], ['2', '2주차'], ['3', '3주차'], ['OVER', '3주차 초과'], ['NONE', '시작일 없음']];
	var SKILLS = [['SK_JSP', 'JSP'], ['SK_THYMELEAF', 'Thymeleaf'], ['SK_VUE', 'Vue'], ['SK_REACT', 'React'], ['SK_NODE_FE', 'Node(프론트)'], ['SK_SPRING', 'Spring'], ['SK_JAVA', 'Java'], ['SK_NODE_BE', 'Node(백엔드)'], ['SK_NEXACRO', 'nexacro'], ['SK_WEBSQUARE', 'WebSquare'], ['SK_EXBUILDER', 'exBuilder']];
	var FIELDS = [
		['TRN_NM', '이름 *', 3], ['STATUS_CD', '상태', 3, { values: STATUS }], ['LEAVE_NOTE', '퇴사·잠수 표시', 2, { code: 'HR_LEAVE' }], ['GENDER', '성별', 2, { code: 'HR_GENDER' }], ['AGE', '나이', 2],
		['EDU_START_DT', '교육 시작일', 3, 'date'], ['INTERVIEW_YN', '인터뷰', 3, { code: 'HR_INTERVIEW' }], ['INTERVIEW_AVAIL', '인터뷰 가능일', 3], ['EDU', '최종학력', 3],
		['ADDR', '주소지', 6], ['STATION', '인근 지하철역', 6],
		['LANG', '외국어', 12, { multi: 'HR_LANG' }], ['LANG_NOTE', '외국어 수준', 12],
		['LOCAL_YN', '지방 가능', 4, { code: 'HR_LOCAL' }], ['EARLY_YN', '조기파견', 4, { code: 'HR_OXT' }], ['SPECIAL_YN', '특수계약', 4, { code: 'HR_OXT' }],
		['CAREER', '이전경력', 12]
	];
	// 참고사항은 메모로 옮겼다. 카드 💬 버튼과 상세 창 아래 메모 칸에서 쌓는다
	var MEMO_API = hrMemoApi('/admin/hr/', 'trainee');
	var FILTERS = [['#fGender', 'GENDER', 'HR_GENDER'], ['#fInterview', 'INTERVIEW_YN', 'HR_INTERVIEW'], ['#fLocal', 'LOCAL_YN', 'HR_LOCAL'], ['#fLeave', 'LEAVE_NOTE', 'HR_LEAVE']];
	function code(title, field, grp) {
		return { t: title, field: field, type: { code: grp }, show: function(r) { return hrCodeName(grp, r[field]); } };
	}
	function text(title, field, type) {
		return { t: title, field: field, type: type, show: function(r) { return r[field]; } };
	}
	// 카드에서 바로 고치는 칸
	var CARD_FIELDS = [
		code('성별', 'GENDER', 'HR_GENDER'),
		text('나이', 'AGE'),
		text('시작일', 'EDU_START_DT', 'date'),
		{ t: '교육 상태', field: 'STATUS_CD', type: { values: STATUS }, show: function(r) { return STATUS[r.STATUS_CD]; } },
		code('퇴사·잠수', 'LEAVE_NOTE', 'HR_LEAVE'),
		code('인터뷰', 'INTERVIEW_YN', 'HR_INTERVIEW'),
		text('가능일', 'INTERVIEW_AVAIL'),
		code('지방', 'LOCAL_YN', 'HR_LOCAL')
	];
	// 칸반에서 다시 그려야 하는 칸: 탭, 주차 열, 계산 값이 달라진다
	var RERENDER = ['STATUS_CD', 'EDU_START_DT', 'INTERVIEW_YN', 'INTERVIEW_AVAIL', 'TRN_NM'];
	var NONE = '__NONE';
	var rows = [], editing = null, current = 'ING', candidates = [];

	$(function() {
		load();
		$('#keyword').on('input', render);
		$('#importKeyword').on('input', renderImport);
		$(document).on('change', '.hr-board-filter', render);
	});

	$(document).on('click', '.cate-tab', function() { current = $(this).data('tab'); render(); });

	function load() {
		$.post('/admin/hr/traineeListData.do', function(res) {
			rows = res.list || [];
			if (!HR_CODES) {
				hrSetCodes(res.codes);
				hrBuildFields('#editFields', FIELDS);
				FILTERS.forEach(function(f) {
					var $s = $(f[0]).append('<option value="">전체</option>').append($('<option>').val(NONE).text('값 없음'));
					(HR_CODES[f[2]] || []).forEach(function(c) { $s.append($('<option>').val(c.CD).text(c.NM)); });
				});
			}
			render();
		});
	}

	function resetFilters() {
		$('#keyword').val('');
		FILTERS.forEach(function(f) { $(f[0]).val(''); });
		$('#sortSel').val('startDesc');
		render();
	}

	// 엑셀의 NETWORKDAYS.INTL(시작일, 오늘, 11) 과 같다: 일요일만 빼고 양 끝 날짜 포함
	function eduDays(start) {
		var d = moment(start, 'YYYY-MM-DD', true), today = moment().startOf('day'), cnt = 0;
		if (!d.isValid()) return null;
		for (; !d.isAfter(today); d.add(1, 'day')) { if (d.day() !== 0) cnt++; }
		return cnt;
	}

	function openDays(r) {
		var d = moment(r.INTERVIEW_AVAIL, 'YYYY-MM-DD', true);
		return r.INTERVIEW_YN === 'YES' && d.isValid() ? moment().startOf('day').diff(d, 'days') : null;
	}

	function passFilters(r) {
		var kw = $.trim($('#keyword').val()).toLowerCase();
		if (kw && [r.TRN_NM, r.MEMO].join(' ').toLowerCase().indexOf(kw) < 0) return false;
		return FILTERS.every(function(f) {
			var val = $(f[0]).val();
			return !val || (val === NONE ? !r[f[1]] : r[f[1]] === val);
		});
	}

	// 시작일·순번이 비어 있으면 어느 방향이든 뒤로 보낸다
	function sorter() {
		function by(get, dir) {
			return function(a, b) {
				var x = get(a), y = get(b);
				if (x === null || y === null) return x !== null ? -1 : y !== null ? 1 : 0;
				return dir * (x < y ? -1 : x > y ? 1 : 0);
			};
		}
		function start(r) { return r.EDU_START_DT || null; }
		switch ($('#sortSel').val()) {
			case 'startAsc': return by(start, 1);
			case 'name': return function(a, b) { return String(a.TRN_NM).localeCompare(String(b.TRN_NM), 'ko'); };
			case 'seq': return by(function(r) { return r.SEQ_NO === undefined || r.SEQ_NO === null ? null : Number(r.SEQ_NO); }, 1);
			default: return by(start, -1);
		}
	}

	// 주차를 아직 옮긴 적이 없으면 시작일이 있는 사람은 1주차로 본다
	function weekOf(r) { return r.EDU_WEEK || (r.EDU_START_DT ? '1' : 'NONE'); }

	function editableCell(r, c) {
		return hrEditable($('<span>'), {
			url: '/admin/hr/saveTraineeFieldData.do', key: { TRN_SQ: r.TRN_SQ }, field: c.field, type: c.type, label: r.TRN_NM + ' ' + c.t,
			value: function() { return r[c.field]; },
			show: function() { return c.show(r); },
			saved: function(val) {
				r[c.field] = val;
				if (RERENDER.indexOf(c.field) >= 0) setTimeout(render);
			}
		});
	}

	function cardRow(label, $cell) {
		return $('<div class="hr-card-row">').append($('<span class="hr-card-label">').text(label)).append($cell);
	}

	function card(r) {
		var ing = r.STATUS_CD === 'ING';
		var $c = $('<div class="hr-card">').data('row', r).attr('draggable', ing ? 'true' : null);
		var $head = $('<div class="hr-card-row hr-card-name-row">').append(editableCell(r, text('이름', 'TRN_NM')));
		$head.append($('<button type="button" class="btn btn-xs btn-outline-secondary">상세</button>').on('click', function() { openEdit(r); }));
		$c.append($head);
		$('<div class="hr-card-info">').text('순번 ' + (r.SEQ_NO || '-')).appendTo($c);
		if (ing) {
			var days = eduDays(r.EDU_START_DT), open = openDays(r);
			if (days !== null) $('<div class="hr-card-info">').text('교육 ' + days + '일 · 연장 ' + (days - 28) + '일').appendTo($c);
			if (open !== null) $('<div class="hr-card-info">').text('오픈 경과 ' + open + '일').appendTo($c);
			// 드래그를 못 쓸 때도 주차를 고칠 수 있게 칸으로도 둔다
			var weekType = { list: [['', '']].concat(WEEKS.slice(0, 4)) };
			$c.append(cardRow('주차', hrEditable($('<span>'), {
				url: '/admin/hr/saveTraineeFieldData.do', key: { TRN_SQ: r.TRN_SQ }, field: 'EDU_WEEK', type: weekType, label: r.TRN_NM + ' 주차',
				value: function() { return r.EDU_WEEK || ''; },
				show: function() { var w = WEEKS.filter(function(x) { return x[0] === weekOf(r); })[0]; return w ? w[1] : ''; },
				saved: function(val) { r.EDU_WEEK = val; setTimeout(render); }
			})));
		}
		CARD_FIELDS.forEach(function(f) { $c.append(cardRow(f.t, editableCell(r, f))); });
		$c.append(cardRow('메모', $('<span>').append(hrMemoBtn(MEMO_API, r.TRN_SQ, r.MEMO_CNT, r.TRN_NM, load))));
		var top = SKILLS.filter(function(s) { return r[s[0]] === '상'; }).map(function(s) { return s[1]; });
		if (top.length) $('<div class="hr-card-info">').text('기술 상: ' + top.join(', ')).appendTo($c);
		return $c;
	}

	function render() {
		var base = rows.filter(passFilters).sort(sorter());
		var $tabs = $('#tabs').empty();
		$.each(STATUS, function(k, v) { hrTab(k, v, base.filter(function(r) { return r.STATUS_CD === k; }).length, k === current).appendTo($tabs); });
		var list = base.filter(function(r) { return r.STATUS_CD === current; }), $board = $('#board').empty();
		if (current === 'ING') { renderLanes(list, $board); return; }
		// 교육종료·중도이탈은 주차가 의미 없어 카드만 나열한다
		if (!list.length) { $board.append($('<div class="cal-empty small">').text('해당하는 교육생이 없습니다.')); return; }
		var $grid = $('<div class="hr-card-grid">').appendTo($board);
		list.forEach(function(r) { $grid.append(card(r)); });
	}

	function renderLanes(list, $board) {
		var $lanes = $('<div class="hr-board">').appendTo($board);
		WEEKS.forEach(function(w) {
			var inLane = list.filter(function(r) { return weekOf(r) === w[0]; });
			// 시작일 없음 열은 대상이 있을 때만 보여 주고, 끌어다 놓을 수 없다
			if (w[0] === 'NONE' && !inLane.length) return;
			var $body = $('<div class="hr-lane-body">');
			inLane.forEach(function(r) { $body.append(card(r)); });
			if (!inLane.length) $body.append($('<div class="cal-empty small">').text('없음'));
			$('<div class="hr-lane">').attr('data-week', w[0])
				.append($('<div class="hr-lane-head">').append($('<span>').text(w[1])).append($('<span class="badge badge-light">').text(inLane.length)))
				.append($body).appendTo($lanes);
		});
	}

	// 카드 안 입력칸을 쓰는 동안에는 드래그되지 않게 한다(글자 선택과 겹친다)
	$(document).on('focusin', '.hr-card[draggable] .form-control', function() { $(this).closest('.hr-card').attr('draggable', 'false'); });
	$(document).on('focusout', '.hr-card[draggable] .form-control', function() { $(this).closest('.hr-card').attr('draggable', 'true'); });

	$(document).on('dragstart', '.hr-card', function(e) {
		e.originalEvent.dataTransfer.setData('text/plain', String($(this).data('row').TRN_SQ));
		e.originalEvent.dataTransfer.effectAllowed = 'move';
		$(this).addClass('is-dragging');
	});
	$(document).on('dragend', '.hr-card', function() {
		$(this).removeClass('is-dragging');
		$('.hr-lane').removeClass('is-over');
	});
	$(document).on('dragover', '.hr-lane:not([data-week=NONE])', function(e) {
		e.preventDefault();
		$('.hr-lane').not(this).removeClass('is-over');
		$(this).addClass('is-over');
	});
	$(document).on('drop', '.hr-lane:not([data-week=NONE])', function(e) {
		e.preventDefault();
		$('.hr-lane').removeClass('is-over');
		var sq = Number(e.originalEvent.dataTransfer.getData('text/plain')), week = $(this).attr('data-week');
		var r = rows.filter(function(x) { return Number(x.TRN_SQ) === sq; })[0];
		if (!r || weekOf(r) === week) return;
		hrPost('/admin/hr/saveTraineeFieldData.do', { TRN_SQ: sq, FIELD: 'EDU_WEEK', VALUE: week }, function() {
			r.EDU_WEEK = week;
			render();
		});
	});

	// 면접관리에서 가져오기
	function openImport() {
		$('#importKeyword').val('');
		$('#importBody').empty();
		$.post('/admin/hr/interviewListData.do', function(res) {
			candidates = (res.list || []).filter(function(r) { return r.JOIN_ST === 'JOIN' && !r.TRN_SQ; });
			renderImport();
			$('#importModal').modal('show');
		});
	}

	function renderImport() {
		var kw = $.trim($('#importKeyword').val()).toLowerCase(), $b = $('#importBody').empty();
		var list = candidates.filter(function(r) { return !kw || [r.APLY_NM, r.PHONE].join(' ').toLowerCase().indexOf(kw) >= 0; });
		if (!list.length) { $b.append($('<tr>').append($('<td class="cal-empty" colspan="6">').text('가져올 면접자가 없습니다.'))); return; }
		list.forEach(function(r) {
			// 엑셀에서 이관한 교육생은 면접자와 연결돼 있지 않아 이름으로만 중복을 알려 준다. 동명이인일 수 있어 막지는 않는다
			var dup = rows.some(function(t) { return t.TRN_NM === r.APLY_NM; });
			var $box = $('<input type="checkbox" class="hr-import-check">').val(r.INTV_SQ).attr('aria-label', r.APLY_NM + ' 선택');
			$('<tr>').append($('<td>').append($box))
				.append($('<td class="small">').text(r.APLY_NM))
				.append($('<td class="small">').text(r.INTV_DT || ''))
				.append($('<td class="small">').text(r.PHONE || ''))
				.append($('<td class="small">').text(r.JOIN_DT || ''))
				.append($('<td class="small">').append(dup ? $('<span class="badge badge-warning">').text('같은 이름 교육생 있음') : null))
				.appendTo($b);
		});
	}

	function runImport() {
		var ids = $('.hr-import-check:checked').map(function() { return this.value; }).get();
		if (!ids.length) { bootbox.alert('가져올 면접자를 선택해 주세요.'); return; }
		var done = 0, failed = 0;
		$('#btnImport').prop('disabled', true);
		// 순번이 겹치지 않게 한 명씩 차례로 등록한다
		(function next(i) {
			if (i === ids.length) {
				$('#btnImport').prop('disabled', false);
				$('#importModal').modal('hide');
				load();
				bootbox.alert(done + '명을 교육진행중으로 가져왔습니다.' + (failed ? ' 실패 ' + failed + '명은 다시 확인해 주세요.' : ''));
				return;
			}
			hrPost('/admin/hr/traineeFromInterviewData.do', { INTV_SQ: ids[i] }, function() { done++; next(i + 1); }, function() { failed++; next(i + 1); });
		})(0);
	}

	function skillSelect(r, col, label) {
		var val = r[col] || '', opts = ['', '상', '중', '하'], id = 'skill_' + col;
		var $s = $('<select class="form-control form-control-sm hr-skill-input">').attr('id', id);
		// 엑셀에서 온 다른 값도 지워지지 않게 보여 준다
		if (opts.indexOf(val) < 0) opts.push(val);
		opts.forEach(function(o) { $s.append($('<option>').val(o).text(o)); });
		$s.val(val).data({ row: r, col: col });
		return $('<div class="col-md-2 col-4 mb-2">').append($('<label>').attr('for', id).text(label)).append($s);
	}

	$(document).on('change', '.hr-skill-input', function() {
		var $s = $(this), r = $s.data('row'), col = $s.data('col');
		hrPost('/admin/hr/saveTraineeSkillData.do', { TRN_SQ: r.TRN_SQ, SKILL_COL: col, SKILL_VAL: $s.val() }, function() { r[col] = $s.val(); render(); });
	});

	function openEdit(row) {
		editing = row;
		hrFillForm('#editForm', FIELDS, row);
		$('#editTitle').text(row.TRN_SQ ? '교육생 상세 · 순번 ' + (row.SEQ_NO || '-') : '교육생 직접 등록');
		$('#btnDelete').toggle(!!row.TRN_SQ);
		// 기술 평가는 저장된 교육생에만 바로 저장할 수 있다
		$('#skillArea').toggle(!!row.TRN_SQ);
		if (!$('#editMemo').length) $('<div class="mt-2"><div class="hr-section">메모</div><div id="editMemo"></div></div>').insertAfter('#editFields');
		$('#editMemo').parent().toggle(!!row.TRN_SQ);
		if (row.TRN_SQ) hrMemoFeed($('#editMemo'), MEMO_API, row.TRN_SQ, load);
		var $box = $('#skillBox').empty();
		if (row.TRN_SQ) SKILLS.forEach(function(s) { $box.append(skillSelect(row, s[0], s[1])); });
		$('#editModal').modal('show');
	}

	function saveEdit() {
		var data = hrFormData('#editForm');
		if (editing.TRN_SQ) data.push({ name: 'TRN_SQ', value: editing.TRN_SQ });
		hrPost('/admin/hr/saveTraineeData.do', data, function() { $('#editModal').modal('hide'); load(); });
	}

	function deleteEdit() {
		bootbox.confirm(editing.TRN_NM + ' 교육생을 삭제할까요? 되돌릴 수 없습니다.', function(ok) {
			if (ok) hrPost('/admin/hr/deleteTraineeData.do', { TRN_SQ: editing.TRN_SQ }, function() { $('#editModal').modal('hide'); load(); });
		});
	}
	</script>
</body>
</html>
