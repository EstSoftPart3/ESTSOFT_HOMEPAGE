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
					<h3 class="card-title bTitle"><b>면접 관리</b></h3>
				</div>

				<div class="card-body">
					<div class="cal-panel">
						<button type="button" class="cal-panel-head hr-dash-head" data-toggle="collapse" data-target="#dashBox" aria-expanded="true" aria-controls="dashBox">
							<span><i class="fas fa-chart-bar"></i> 대시보드 (검색 기준)</span>
							<i class="fas fa-chevron-up" aria-hidden="true"></i>
						</button>
						<div id="dashBox" class="collapse show">
							<div class="cal-panel-body">
								<div class="hr-dash" id="dashStats"></div>
								<div class="text-right mb-2">
									<button type="button" class="btn btn-sm btn-outline-primary" id="btnCopyDash" onclick="copyDash();"><i class="far fa-copy"></i> <span>보고 내용 복사</span></button>
								</div>
							</div>
						</div>
					</div>

					<div class="cal-panel">
						<div class="cal-panel-body">
							<div class="form-row align-items-end">
								<div class="col-md-1 col-6 mb-2">
									<label for="yearSel">연도</label>
									<select id="yearSel" class="form-control form-control-sm"></select>
								</div>
								<div class="col-md-1 col-6 mb-2">
									<label for="monthSel">월</label>
									<select id="monthSel" class="form-control form-control-sm hr-filter-input"></select>
								</div>
								<div class="col-md-2 col-6 mb-2">
									<label for="weekSel">주차</label>
									<select id="weekSel" class="form-control form-control-sm hr-filter-input"></select>
								</div>
								<div class="col-md-3 col-6 mb-2">
									<label for="keyword">검색 (이름·연락처·비고, 모든 연도)</label>
									<input type="search" id="keyword" class="form-control form-control-sm">
								</div>
								<div class="col-md-2 col-6 mb-2"><label for="fRoute">경로</label><select id="fRoute" class="form-control form-control-sm hr-filter-input"></select></div>
								<div class="col-md-1 col-6 mb-2"><label for="fAttend">참석</label><select id="fAttend" class="form-control form-control-sm hr-filter-input"></select></div>
								<div class="col-md-1 col-6 mb-2"><label for="fNotice">통보</label><select id="fNotice" class="form-control form-control-sm hr-filter-input"></select></div>
								<div class="col-md-1 col-6 mb-2"><label for="fJoin">입사</label><select id="fJoin" class="form-control form-control-sm hr-filter-input"></select></div>
								<div class="col-12 mb-2 text-right">
									<button type="button" class="btn btn-sm btn-outline-secondary" onclick="resetFilters();"><i class="fas fa-undo"></i> 필터 초기화</button>
								</div>
							</div>
						</div>
					</div>

					<div class="cal-panel">
						<div class="cate-tabs" id="tabs" role="tablist" aria-label="면접 결과"></div>
						<div class="table-responsive">
							<table class="table table-sm table-hover cal-table mb-0">
								<thead id="listHead"></thead>
								<tbody id="listBody"></tbody>
							</table>
						</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="editModal" tabindex="-1" role="dialog" aria-labelledby="editTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="editTitle">면접자</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<form id="editForm" onsubmit="saveEdit(); return false;">
					<div class="modal-body"><div class="form-row" id="editFields"></div></div>
					<div class="modal-footer">
						<button type="button" class="btn btn-sm btn-outline-danger mr-auto" id="btnDelete" onclick="deleteEdit();">삭제</button>
						<button type="button" class="btn btn-sm btn-outline-primary" id="btnTrainee" onclick="toTrainee();">교육생으로 등록</button>
						<button type="submit" class="btn btn-sm btn-primary">저장</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>

	<script>
	// 면접시간 선택지: 09:00 ~ 18:00, 30분 간격. 이전에 다른 값으로 넣은 시간은 hrControl·hrFillForm 이 선택지에 덧붙인다
	var TIME_VALUES = { '': '' };
	for (var m = 9 * 60; m <= 18 * 60; m += 30) {
		var hhmm = ('0' + Math.floor(m / 60)).slice(-2) + ':' + ('0' + (m % 60)).slice(-2);
		TIME_VALUES[hhmm] = hhmm;
	}
	var SECTIONS = [
		['기본정보', [
			['APLY_NM', '이름 *', 3], ['GENDER', '성별', 2, { code: 'HR_GENDER' }], ['AGE', '나이', 2], ['PHONE', '연락처', 5],
			['EDU', '최종학력', 4], ['HOBBY', '취미', 4], ['SPECIALTY', '특기', 4],
			['LANG', '외국어', 12, { multi: 'HR_LANG' }], ['LANG_NOTE', '외국어 수준', 12],
			['ADDR', '주소지', 6], ['STATION', '인근 지하철역', 6],
			['CAREER', '이전경력', 12]
		]],
		['면접 정보', [
			['INTV_DT', '면접일자', 4, 'date'], ['INTV_TM', '면접시간', 4, { values: TIME_VALUES }], ['APLY_TARGET', '지원대상', 4],
			['APLY_ROUTE', '지원방법', 4, { code: 'HR_ROUTE' }], ['REFERRER', '추천자명', 4], ['ATTEND_ST', '참석', 4, { code: 'HR_ATTEND' }], ['RESULT_ST', '결과', 4, { code: 'HR_RESULT' }],
			['LOCAL_YN', '지방 가능', 4, { code: 'HR_LOCAL' }], ['SALARY', '계약 예정 연봉', 8]
		]],
		['채용 진행', [
			['NOTICE_ST', '합격통보', 4, { code: 'HR_NOTICE' }], ['JOIN_ST', '입사여부', 4, { code: 'HR_JOIN' }], ['JOIN_DT', '출근일자', 4]
		]],
		['비고', [
			['MEMO', '비고', 12, 'textarea', true]
		]]
	];
	var FIELDS = [].concat.apply([], SECTIONS.map(function(s) { return s[1]; }));
	var TABS = [
		['', '전체', function() { return true; }],
		['PASS', '합격', function(r) { return r.RESULT_ST === 'PASS'; }],
		['FAIL', '불합격', function(r) { return r.RESULT_ST === 'FAIL'; }],
		['HOLD', '보류', function(r) { return r.RESULT_ST === 'HOLD'; }],
		['JOIN', '입사', function(r) { return r.JOIN_ST === 'JOIN'; }]
	];
	function codeCol(title, width, key, grp, show) {
		return { t: title, w: width, sort: true, field: key, type: { code: grp }, v: function(r) { return hrCodeName(grp, r[key]); }, show: show };
	}
	function textCol(title, width, field, sort, type) {
		return { t: title, w: width, sort: sort, field: field, type: type, v: function(r) { return r[field]; } };
	}
	// 목록 칸. field: 바로 고칠 컬럼, type: 입력 종류, sort: 제목으로 정렬. v 는 정렬 값, show 는 화면 표시(없으면 v)
	var COLS = [
		textCol('면접일자', 135, 'INTV_DT', true, 'date'),
		textCol('시간', 95, 'INTV_TM', true, { values: TIME_VALUES }),
		{ t: '이름', w: 140, sort: true, field: 'APLY_NM', v: function(r) { return r.APLY_NM; },
			show: function(r) { return r.APLY_NM + (r.GENDER ? ' (' + hrCodeName('HR_GENDER', r.GENDER) + (r.AGE ? ', ' + r.AGE : '') + ')' : '') + (r.TRN_SQ ? ' · 교육생' : ''); } },
		textCol('연락처', 120, 'PHONE'),
		codeCol('경로', 130, 'APLY_ROUTE', 'HR_ROUTE', function(r) { return hrCodeName('HR_ROUTE', r.APLY_ROUTE) + (r.REFERRER ? ' (' + r.REFERRER + ')' : ''); }),
		codeCol('참석', 80, 'ATTEND_ST', 'HR_ATTEND'),
		codeCol('결과', 80, 'RESULT_ST', 'HR_RESULT'),
		codeCol('통보', 90, 'NOTICE_ST', 'HR_NOTICE'),
		codeCol('입사', 90, 'JOIN_ST', 'HR_JOIN'),
		textCol('출근일', 100, 'JOIN_DT', true),
		textCol('비고', null, 'MEMO', false, 'textarea')
	];
	var NONE = '__NONE';
	// 결과는 탭, 이름·연락처·비고는 검색, 날짜는 연도로 찾으므로 필터에서 뺀다
	var FILTERS = [['#fRoute', 'APLY_ROUTE', 'HR_ROUTE'], ['#fAttend', 'ATTEND_ST', 'HR_ATTEND'], ['#fNotice', 'NOTICE_ST', 'HR_NOTICE'], ['#fJoin', 'JOIN_ST', 'HR_JOIN']];
	// 목록 칸 색. 코드 없는 값은 색을 넣지 않는다
	var TONES = {
		ATTEND_ST: { ATTEND: 'good', CANCEL: 'mute', ABSENT: 'bad', CHANGE: 'warn' },
		RESULT_ST: { PASS: 'good', FAIL: 'bad', HOLD: 'warn', CANCEL: 'mute' },
		NOTICE_ST: { WAIT: 'mute', NOTIFIED: 'info', REPLY_WAIT: 'warn', CONFIRM: 'good', REJECT: 'bad' },
		JOIN_ST: { JOIN: 'good', REJECT: 'bad', JOIN_CANCEL: 'bad', NO_REPLY: 'warn', UNDECIDED: 'mute' }
	};
	var rows = [], shown = [], current = '', editing = null, sortCol = 0, sortDir = -1;

	$(function() {
		load();
		$('#yearSel').on('change', function() { fillWeeks(); render(); });
		$('#monthSel').on('change', fillWeeks);
		$('#keyword').on('input', render);
	});

	// 월요일에 시작하는 달력 주. 그 달의 날짜만 담아 [시작일, 끝일] 로 돌려준다
	function monthWeeks(y, mon) {
		var last = new Date(y, mon, 0).getDate(), offset = (new Date(y, mon - 1, 1).getDay() + 6) % 7, weeks = [];
		for (var d = 1; d <= last; d++) {
			var i = Math.floor((d - 1 + offset) / 7);
			weeks[i] = weeks[i] || [d, d];
			weeks[i][1] = d;
		}
		return weeks;
	}

	function fillWeeks() {
		var y = $('#yearSel').val(), mon = $('#monthSel').val();
		var $w = $('#weekSel').empty().append('<option value="">전체</option>').prop('disabled', !y || !mon);
		if (y && mon) monthWeeks(+y, +mon).forEach(function(w, i) {
			$w.append($('<option>').val(w.join('-')).text((i + 1) + '주차 (' + (w[0] === w[1] ? w[0] : w[0] + '~' + w[1]) + '일)'));
		});
	}

	function inWeek(dt, week) {
		if (!week) return true;
		var d = +(dt || '').substr(8, 2), w = week.split('-');
		return d >= +w[0] && d <= +w[1];
	}

	function dashCounts(list) {
		function count(test) { return list.filter(test).length; }
		var pass = list.filter(function(r) { return r.RESULT_ST === 'PASS'; }), parts = [], counted = 0;
		if (pass.length) {
			// 합격자의 입사여부별 인원. 코드가 없거나 지워진 값은 미입력으로 묶어 합계를 맞춘다
			(HR_CODES.HR_JOIN || []).forEach(function(o) {
				var n = pass.filter(function(r) { return r.JOIN_ST === o.CD; }).length;
				counted += n;
				if (n) parts.push((o.CD === 'JOIN' ? '출근확정' : o.NM) + n);
			});
			if (pass.length > counted) parts.push('미입력' + (pass.length - counted));
		}
		return {
			total: list.length,
			attend: count(function(r) { return r.ATTEND_ST === 'ATTEND'; }),
			pass: pass.length,
			detail: parts.join(', '),
			hold: count(function(r) { return r.RESULT_ST === 'HOLD'; }),
			join: count(function(r) { return r.JOIN_ST === 'JOIN'; })
		};
	}

	function dashText(s) {
		return ['총원 : ' + s.total, '참석 : ' + s.attend, '합격 : ' + s.pass + (s.detail ? '(' + s.detail + ')' : ''), '보류 : ' + s.hold, '출근확정 : ' + s.join].join('\n');
	}

	function renderDash() {
		var s = dashCounts(shown), $box = $('#dashStats').empty();
		[['총원', s.total], ['참석', s.attend], ['합격', s.pass, s.detail], ['보류', s.hold], ['출근확정', s.join]].forEach(function(t) {
			$('<div class="hr-dash-item">').append($('<div class="hr-dash-label">').text(t[0])).append($('<div class="hr-dash-num">').text(t[1]))
				.append($('<div class="hr-dash-sub">').text(t[2] || '')).appendTo($box);
		});
	}

	// http 로 접속해도 되도록 clipboard API 대신 execCommand 를 쓴다
	function copyDash() {
		var $btn = $('#btnCopyDash'), $t = $('<textarea aria-hidden="true" style="position:fixed;top:0;left:-9999px;">').val(dashText(dashCounts(shown))).appendTo('body');
		$t[0].select();
		var ok = false;
		try { ok = document.execCommand('copy'); } catch (e) {}
		$t.remove();
		$btn.focus();
		if (!ok) { bootbox.alert('복사하지 못했습니다. 대시보드 숫자를 직접 옮겨 주세요.'); return; }
		var $label = $btn.find('span').text('복사했습니다');
		setTimeout(function() { $label.text('보고 내용 복사'); }, 1200);
	}

	$(document).on('click', '.cate-tab', function() { current = $(this).data('tab'); render(); });

	function firstRoute() {
		return ((HR_CODES.HR_ROUTE || [])[0] || {}).CD || '';
	}

	function buildHead() {
		var $m = $('#monthSel').append('<option value="">전체</option>');
		for (var i = 1; i <= 12; i++) $m.append($('<option>').val(('0' + i).slice(-2)).text(i + '월'));
		$m.val(moment().format('MM'));
		FILTERS.forEach(function(f) {
			var $s = $(f[0]).empty().append('<option value="">전체</option>').append($('<option>').val(NONE).text('값 없음'));
			(HR_CODES[f[2]] || []).forEach(function(o) { $s.append($('<option>').val(o.CD).text(o.NM)); });
		});
		var $title = $('<tr>'), $new = $('<tr class="hr-new">');
		COLS.forEach(function(c, i) {
			var $add = hrControl(c.type === 'textarea' ? 'text' : c.type, c.field === 'INTV_DT' ? moment().format('YYYY-MM-DD') : c.field === 'APLY_ROUTE' ? firstRoute() : '')
				.addClass('hr-new-input').attr({ name: c.field, 'aria-label': '새 면접자 ' + c.t });
			$new.append($('<th>').append($add));

			var $th = $('<th>').attr('data-col', i);
			if (c.w) $th.css('width', c.w + 'px');
			if (c.sort) $th.append($('<button type="button" class="hr-sort">').attr('data-col', i).text(c.t).append(' <span class="hr-sort-mark" aria-hidden="true"></span>'));
			else $th.text(c.t);
			$title.append($th);
		});
		$title.append('<th style="width:60px;"></th>');
		$new.append($('<th>').append('<button type="button" class="btn btn-xs btn-primary" onclick="addRow();">등록</button>'));
		$('#listHead').empty().append($title).append($new);
	}

	$(document).on('keydown', '.hr-new-input', function(e) { if (e.key === 'Enter') { e.preventDefault(); addRow(); } });

	function addRow() {
		var data = { APLY_TARGET: '이에스티' };
		$('.hr-new-input').each(function() { data[this.name] = $.trim($(this).val()); });
		hrPost('/admin/hr/saveInterviewData.do', data, function() {
			$('.hr-new-input').not('[name=INTV_DT]').val('');
			$('.hr-new-input[name=APLY_ROUTE]').val(firstRoute());
			$('.hr-new-input[name=INTV_DT]').focus();
			load();
		});
	}

	$(document).on('click', '.hr-sort', function() {
		var col = $(this).data('col');
		sortDir = col === sortCol ? -sortDir : 1;
		sortCol = col;
		render();
	});

	$(document).on('change', '.hr-filter-input', render);

	function resetFilters() {
		sortCol = 0; sortDir = -1; current = '';
		$('.hr-filter-input').val('');
		$('#keyword').val('');
		fillWeeks();
		render();
	}

	function passFilters(r) {
		return FILTERS.every(function(f) {
			var val = $(f[0]).val();
			return !val || (val === NONE ? !r[f[1]] : r[f[1]] === val);
		});
	}

	// 값이 빈 행은 정렬 방향과 상관없이 맨 뒤로 보낸다
	function sortRows(list) {
		var c = COLS[sortCol];
		return list.slice().sort(function(a, b) {
			var x = String(c.v(a) || ''), y = String(c.v(b) || '');
			if (!x || !y) return x ? -1 : y ? 1 : 0;
			return sortDir * x.localeCompare(y, 'ko', { numeric: true });
		});
	}

	function markSort() {
		$('#listHead th[aria-sort]').removeAttr('aria-sort');
		$('.hr-sort-mark').text('');
		$('#listHead tr:first th[data-col=' + sortCol + ']').attr('aria-sort', sortDir > 0 ? 'ascending' : 'descending')
			.find('.hr-sort-mark').text(sortDir > 0 ? '▲' : '▼');
	}

	function toggleReferrer() {
		$('#f_REFERRER').closest('.mb-2').toggle($('#f_APLY_ROUTE').val() === 'REFERRAL');
	}

	function load() {
		$.post('/admin/hr/interviewListData.do', function(res) {
			rows = res.list || [];
			if (!HR_CODES) {
				hrSetCodes(res.codes);
				SECTIONS.forEach(function(s) {
					$('<div class="col-12 hr-section">').text(s[0]).appendTo('#editFields');
					hrBuildFields('#editFields', s[1]);
				});
				$('#f_APLY_ROUTE').on('change', toggleReferrer);
				buildHead();
			}
			var years = {}, sel = $('#yearSel').val(), thisYear = String(new Date().getFullYear());
			rows.forEach(function(r) { if (r.INTV_DT) years[r.INTV_DT.substr(0, 4)] = 1; });
			years[thisYear] = 1;
			var $y = $('#yearSel').empty().append('<option value="">전체</option>');
			Object.keys(years).sort().reverse().forEach(function(y) { $y.append($('<option>').val(y).text(y + '년')); });
			$y.val(sel === null ? thisYear : sel);
			if (sel === null) fillWeeks();
			render();
		});
	}

	function render() {
		var year = $('#yearSel').val(), month = $('#monthSel').val(), week = $('#weekSel').val(), kw = $.trim($('#keyword').val()).toLowerCase();
		// 검색어가 있으면 연도·월과 상관없이 찾는다
		var base = rows.filter(function(r) {
			if (kw) return [r.APLY_NM, r.PHONE, r.MEMO].join(' ').toLowerCase().indexOf(kw) >= 0;
			return (!year || (r.INTV_DT || '').substr(0, 4) === year) && (!month || (r.INTV_DT || '').substr(5, 2) === month) && inWeek(r.INTV_DT, week);
		}).filter(passFilters);
		shown = base;
		renderDash();
		markSort();
		var $tabs = $('#tabs').empty(), test = TABS[0][2];
		TABS.forEach(function(t) {
			if (t[0] === current) test = t[2];
			hrTab(t[0], t[1], base.filter(t[2]).length, t[0] === current).appendTo($tabs);
		});
		var $body = $('#listBody').empty(), list = sortRows(base.filter(test));
		if (!list.length) { $body.append($('<tr>').append($('<td class="cal-empty">').attr('colspan', COLS.length + 1).text('조건에 맞는 면접자가 없습니다.'))); return; }
		list.forEach(function(r) {
			var $tr = $('<tr>');
			COLS.forEach(function(c) {
				var $td = $('<td>').addClass(c.field === 'MEMO' ? 'hr-memo' : 'small').appendTo($tr);
				hrEditable($td, {
					url: '/admin/hr/saveInterviewFieldData.do', key: { INTV_SQ: r.INTV_SQ }, field: c.field, type: c.type, label: r.APLY_NM + ' ' + c.t,
					value: function() { return r[c.field]; },
					show: function() { return (c.show || c.v)(r); },
					tone: TONES[c.field] && function() { return TONES[c.field][r[c.field]]; },
					saved: function(val) {
						r[c.field] = val;
						if (c.field === 'APLY_ROUTE' && val !== 'REFERRAL') r.REFERRER = null;
						renderDash();
					}
				});
			});
			$('<td>').append($('<button type="button" class="btn btn-xs btn-outline-secondary">상세</button>').on('click', function() { openEdit(r); })).appendTo($tr);
			$body.append($tr);
		});
	}

	function openEdit(row) {
		editing = row;
		hrFillForm('#editForm', FIELDS, row);
		toggleReferrer();
		$('#editTitle').text('면접자 상세 · 순번 ' + (row.SEQ_NO || '-'));
		$('#btnTrainee').toggle(!row.TRN_SQ);
		$('#editModal').modal('show');
	}

	function saveEdit() {
		var data = hrFormData('#editForm');
		data.push({ name: 'INTV_SQ', value: editing.INTV_SQ });
		hrPost('/admin/hr/saveInterviewData.do', data, function() { $('#editModal').modal('hide'); load(); });
	}

	function deleteEdit() {
		bootbox.confirm(editing.APLY_NM + ' 면접자를 삭제할까요? 되돌릴 수 없습니다.', function(ok) {
			if (ok) hrPost('/admin/hr/deleteInterviewData.do', { INTV_SQ: editing.INTV_SQ }, function() { $('#editModal').modal('hide'); load(); });
		});
	}

	function toTrainee() {
		bootbox.confirm(editing.APLY_NM + ' 님을 교육진행중 교육생으로 등록할까요?', function(ok) {
			if (ok) hrPost('/admin/hr/traineeFromInterviewData.do', { INTV_SQ: editing.INTV_SQ }, function() {
				$('#editModal').modal('hide');
				load();
				bootbox.alert('교육생으로 등록했습니다. 교육 시작일은 교육생 관리에서 확인해 주세요.');
			});
		});
	}

	</script>
</body>
</html>
