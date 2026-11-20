<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_head.jspf"%>
<link rel="stylesheet" href="/resources/bo/plugins/fullcalendar/main.min.css">
<link rel="stylesheet" href="/resources/bo/plugins/fullcalendar-daygrid/main.min.css">
<link rel="stylesheet" href="/resources/bo/plugins/fullcalendar-timegrid/main.min.css">
<style>
	#calView { position: relative; padding: 0 14px 14px; }
	/* 일정: 연한 바탕 + 왼쪽 굵은 띠(결과 색), 진한 글씨 */
	#calView .fc-event { cursor: pointer; font-size: 13px; line-height: 1.4; color: #212529 !important; border-width: 0 0 0 4px !important; border-radius: 4px; box-shadow: 0 1px 2px rgba(0,0,0,.15); padding: 1px 3px; }
	#calView .fc-event .fc-time { color: #495057; font-weight: 600; font-size: 12px; }
	#calView .fc-event .ic-name { font-weight: 700; }
	#calView .fc-day-grid-event .fc-content { white-space: normal; }
	/* 이름 아래 작은 한 줄: 지원대상 · 지원방법 · 추천자. 칸 높이는 그대로 두고,
	   주별은 시간을 왼쪽 시간축이 보여 주므로 일정 안 시간은 빼고(툴팁에는 있음) 이름 1줄 + 작은 줄 1줄(넘치면 말줄임)이 1시간 일정에 들어가게 한다.
	   좁아져 줄어든 일정은 마우스를 올리면 그 일정만 넓게 펼쳐 다 보인다 */
	#calView .ic-sub { display: block; font-size: 11px; line-height: 15px; font-weight: 400; color: #495057; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
	#calView .ic-name { word-break: keep-all; }
	#calView .fc-time-grid-event .fc-content { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
	#calView .fc-time-grid-event .fc-time { display: none; }
	#calView .fc-time-grid-event:hover { z-index: 10 !important; bottom: auto !important; min-height: 44px; min-width: 170px; box-shadow: 0 4px 12px rgba(0,0,0,.3); }
	#calView .fc-time-grid-event:hover .fc-content, #calView .fc-time-grid-event:hover .ic-sub { white-space: normal; max-height: none; }
	#calView .fc-event.ic-cancel { background: #f8f9fa !important; border: 1px dashed #adb5bd !important; border-left-width: 4px !important; }
	#calView .fc-event.ic-cancel .ic-name { text-decoration: line-through; color: #6c757d; }
	.ic-badge, .ic-chip { display: inline-block; font-size: 11px; font-weight: 700; line-height: 16px; padding: 0 5px; margin-right: 3px; border-radius: 3px; color: #fff; vertical-align: 1px; white-space: nowrap; }
	.ic-chip { border-radius: 8px; margin: 0 0 0 3px; }
	.ic-NEW { background: #0d6efd; } .ic-EXP { background: #6f42c1; }
	.ic-ATTEND { background: #198754; } .ic-CANCEL, .ic-ABSENT { background: #6c757d; } .ic-CHANGE { background: #0dcaf0; color: #212529; }
	.ic-PASS { background: #198754; } .ic-FAIL { background: #dc3545; } .ic-HOLD { background: #fd7e14; }
	.ic-chip.ic-ATTEND { background: #fff; color: #198754; box-shadow: inset 0 0 0 1px #198754; }
	.ic-chip.ic-st { background: #fff; color: #6c757d; box-shadow: inset 0 0 0 1px currentColor; }
	.ic-st.t-good { color: #198754; } .ic-st.t-bad { color: #dc3545; } .ic-st.t-warn { color: #d9480f; } .ic-st.t-info { color: #0a7ea4; }
	#calView.is-file-over { outline: 2px dashed #28a745; outline-offset: -4px; }
	.ic-drop { position: absolute; z-index: 5; pointer-events: none; border: 2px dashed #28a745; background: rgba(40,167,69,.12); border-radius: 4px; color: #1e7e34; font-size: 12px; font-weight: 700; display: flex; align-items: center; justify-content: center; }
	#editForm .ic-auto { background: #e8f5e9; }
	/* 면접결과 기록(칩): 모집관리 인터뷰 기록과 같은 모양 */
	.in-kv { display: grid; grid-template-columns: 110px 1fr; gap: 8px 10px; align-items: start; }
	.in-kv > label { margin: 0; padding-top: 3px; font-size: 13px; font-weight: 700; }
	.in-help { grid-column: 1 / -1; font-size: 11.5px; color: #868e96; }
	.in-chip { border: 1px solid #ced4da; background: #fff; border-radius: 999px; padding: 2px 12px; font-size: 12.5px; }
	.in-chip[aria-pressed=true] { background: #0b6e8a; border-color: #0b6e8a; color: #fff; font-weight: 700; }
	.in-kv.editing .in-chip:not(.in-add) { border-color: #fa5252; color: #c92a2a; } .in-kv.editing .in-chip:not(.in-add)::after { content: ' ✕'; }
	@media (max-width: 575px) { .in-kv { grid-template-columns: 1fr; } .in-kv > label { padding-top: 6px; } }
	/* 대시보드: 전체 칸(기존) 아래에 신입·경력 단계 막대와 지원방법별 표 */
	.dash-sec { font-size: 12px; font-weight: 700; color: #333; margin: 12px 0 6px; padding-top: 10px; border-top: 1px solid #eef2f5; }
	.dash-split { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 10px; }
	.dash-card { border: 1px solid #e3edf2; border-radius: 8px; padding: 10px 12px; }
	.dash-card-head { display: flex; align-items: baseline; gap: 8px; margin-bottom: 6px; }
	.dash-card-head b { font-size: 18px; }
	.dash-card-head .small { color: #666; }
	.dash-step { display: grid; grid-template-columns: 56px 1fr 92px; align-items: center; gap: 6px; font-size: 12px; margin: 4px 0; }
	.dash-bar { height: 10px; background: #eef3f6; border-radius: 5px; overflow: hidden; }
	.dash-bar > i { display: block; height: 100%; border-radius: 5px; }
	.dash-step .v { text-align: right; white-space: nowrap; } .dash-step .v small { color: #777; }
	.dash-route th, .dash-route td { font-size: 12px; text-align: right; white-space: nowrap; } .dash-route th:first-child, .dash-route td:first-child { text-align: left; }
	.dash-route tr.dash-total td { font-weight: 700; border-top: 2px solid #dee2e6; }
</style>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_open.jspf"%>
				<div class="card-header">
					<h3 class="card-title bTitle"><b>면접 관리</b></h3>
				</div>

				<div class="card-body">
					<div class="cal-panel">
						<div class="cal-panel-body">
							<div class="form-row align-items-end">
								<div class="col-md-1 col-6 mb-2" data-keep>
									<label for="yearSel">연도</label>
									<select id="yearSel" class="form-control form-control-sm"></select>
								</div>
								<div class="col-md-1 col-6 mb-2" data-keep>
									<label for="monthSel">월</label>
									<select id="monthSel" class="form-control form-control-sm hr-filter-input"></select>
								</div>
								<div class="col-md-2 col-6 mb-2" data-keep>
									<label for="weekSel">주차</label>
									<select id="weekSel" class="form-control form-control-sm hr-filter-input"></select>
								</div>
								<div class="col-md-3 col-6 mb-2">
									<label for="keyword">검색 (이름·연락처·메모, 모든 연도)</label>
									<input type="search" id="keyword" class="form-control form-control-sm">
								</div>
								<div class="col-md-1 col-6 mb-2"><label for="fHire">구분</label><select id="fHire" class="form-control form-control-sm hr-filter-input"></select></div>
								<div class="col-md-2 col-6 mb-2"><label for="fRoute">경로</label><select id="fRoute" class="form-control form-control-sm hr-filter-input"></select></div>
								<div class="col-md-1 col-6 mb-2"><label for="fAttend">참석</label><select id="fAttend" class="form-control form-control-sm hr-filter-input"></select></div>
								<div class="col-md-1 col-6 mb-2"><label for="fNotice">통보</label><select id="fNotice" class="form-control form-control-sm hr-filter-input"></select></div>
								<div class="col-md-1 col-6 mb-2"><label for="fJoin">입사</label><select id="fJoin" class="form-control form-control-sm hr-filter-input"></select></div>
								<div class="col-12 mb-2 text-right">
									<%-- 대시보드는 검색 필터와 함께 위에 고정된다 --%>
									<button type="button" class="btn btn-sm btn-outline-primary" id="btnDash"><i class="fas fa-chart-bar" aria-hidden="true"></i> 대시보드</button>
									<button type="button" class="btn btn-sm btn-outline-secondary" onclick="resetFilters();"><i class="fas fa-undo"></i> 필터 초기화</button>
								</div>
							</div>
						</div>
					</div>

					<div class="cal-panel">
						<div class="d-flex justify-content-between align-items-center flex-wrap pr-3">
							<div class="cate-tabs" id="tabs" role="tablist" aria-label="면접 결과"></div>
							<div class="d-flex align-items-center" style="gap:6px;">
								<div class="btn-group btn-group-sm" id="viewSwitch" role="group" aria-label="보기 전환">
									<button type="button" class="btn btn-outline-secondary" data-view="list"><i class="fas fa-list"></i> 목록</button>
									<button type="button" class="btn btn-outline-secondary" data-view="cal"><i class="far fa-calendar-alt"></i> 캘린더</button>
								</div>
							</div>
						</div>
						<div id="calView" style="display:none;">
							<div class="small text-muted mb-1" style="font-size:11.5px;">빈 시간을 누르면 새 면접자를, 이력서 PDF를 시간 칸에 끌어 놓으면 이력서 내용을 채워 새 면접자 창을 열어요. 일정을 끌면 면접일시가 바로 바뀌어요.</div>
							<div id="calendar"></div>
						</div>
						<div class="table-responsive" id="listView">
							<table data-no-card class="table table-sm table-hover cal-table mb-0">
								<thead id="listHead"></thead>
								<tbody id="listBody"></tbody>
							</table>
						</div>
					</div>
					<%-- 대시보드는 위 버튼 → 팝업. 내용은 숨긴 자리에서 계속 그려 두고 팝업에 옮겨 보인다 --%>
					<div id="dashBox" hidden>
						<div class="hr-dash-title" id="dashTitle"></div>
						<div class="hr-dash-cond" id="dashCond"></div>
						<div class="hr-dash" id="dashStats"></div>
						<div class="dash-sec">신입 · 경력</div>
						<div class="dash-split" id="dashSplit"></div>
						<div class="dash-sec">지원방법별</div>
						<div class="table-responsive"><table class="table table-sm dash-route mb-2"><thead><tr><th>지원방법</th><th>신입</th><th>경력</th><th>예정</th><th>참석</th><th>합격</th><th>출근확정</th><th>합격률</th></tr></thead><tbody id="dashRoute"></tbody></table></div>
						<div class="text-right">
							<button type="button" class="btn btn-sm btn-outline-primary" id="btnCopyDash" onclick="copyDash();"><i class="far fa-copy"></i> <span>보고 내용 복사</span></button>
						</div>
					</div>
				</div>
			<%@ include file="/WEB-INF/jsp/bo/boinclude/page_close.jspf"%>

	<div class="modal fade" id="editModal" tabindex="-1" role="dialog" aria-labelledby="editTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="editTitle">면접자</h5>
					<%-- 파일이 있으면 보기(채운 버튼), 없으면 등록(테두리 버튼). 닫기 바로 왼쪽에 붙인다 --%>
					<div class="ml-auto d-flex align-items-center" style="gap:6px;">
						<button type="button" class="btn btn-sm ic-doc" id="btnDocRESUME" data-kind="RESUME"></button>
						<button type="button" class="btn btn-sm ic-doc" id="btnDocPORTFOLIO" data-kind="PORTFOLIO"></button>
						<button type="button" class="btn btn-sm ic-doc" id="btnDocPROFILE" data-kind="PROFILE"></button>
						<button type="button" class="btn btn-sm btn-outline-success bg-white" id="btnNote" onclick="noteDialog(editing);">📝 면접결과</button>
						<input type="file" id="docFile" class="d-none" accept="application/pdf,.pdf" aria-label="파일 선택">
					</div>
					<button type="button" class="close" style="margin-left:.5rem;" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<form id="editForm" onsubmit="saveEdit(); return false;">
					<div class="modal-body"><div class="form-row" id="editFields"></div></div>
					<div class="modal-footer">
						<button type="button" class="btn btn-sm btn-outline-danger mr-auto" id="btnDelete" onclick="deleteEdit();">삭제</button>
						<button type="button" class="btn btn-sm btn-outline-primary" id="btnTrainee" onclick="toTrainee();">교육생으로 등록</button>
					<button type="button" class="btn btn-sm btn-outline-primary" id="btnWait" onclick="toWait();">대기자로 등록</button>
					<span class="small text-muted align-self-center" id="waitDone" style="display:none;">대기자로 등록됨 (직원관리 대기 탭)</span>
						<button type="submit" class="btn btn-sm btn-primary">저장</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/page_script.jspf"%>
	<script src="/resources/bo/plugins/fullcalendar/main.min.js"></script>
	<script src="/resources/bo/plugins/fullcalendar/locales-all.min.js"></script>
	<script src="/resources/bo/plugins/fullcalendar-daygrid/main.min.js"></script>
	<script src="/resources/bo/plugins/fullcalendar-timegrid/main.min.js"></script>
	<script src="/resources/bo/plugins/fullcalendar-interaction/main.min.js"></script>

	<script>
	// 면접시간 선택지: 09:00 ~ 18:00, 30분 간격. 이전에 다른 값으로 넣은 시간은 hrControl·hrFillForm 이 선택지에 덧붙인다
	var TIME_VALUES = { '': '' };
	for (var m = 9 * 60; m <= 18 * 60; m += 30) {
		var hhmm = ('0' + Math.floor(m / 60)).slice(-2) + ':' + ('0' + (m % 60)).slice(-2);
		TIME_VALUES[hhmm] = hhmm;
	}
	var SECTIONS = [
		['기본정보', [
			['APLY_NM', '이름 *', 3], ['HIRE_CD', '구분', 2, { code: 'HR_HIRE' }], ['GENDER', '성별', 2, { code: 'HR_GENDER' }], ['AGE', '나이', 2], ['PHONE', '연락처', 3],
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
			['NOTICE_ST', '합격통보', 4, { code: 'HR_NOTICE' }], ['JOIN_ST', '입사여부', 4, { code: 'HR_JOIN' }], ['JOIN_DT', '출근일자', 4, 'date']
		]]
	];
	// 비고는 메모로 옮겼다. 목록 💬 버튼과 상세 창 아래 메모 칸에서 쌓는다
	var MEMO_API = hrMemoApi('/admin/hr/', 'interview');
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
		codeCol('구분', 75, 'HIRE_CD', 'HR_HIRE'),
		{ t: '이름', w: 140, sort: true, field: 'APLY_NM', v: function(r) { return r.APLY_NM; },
			show: function(r) { return r.APLY_NM + (r.GENDER ? ' (' + hrCodeName('HR_GENDER', r.GENDER) + (r.AGE ? ', ' + r.AGE : '') + ')' : '') + (r.TRN_SQ ? ' · 교육생' : ''); } },
		textCol('연락처', 120, 'PHONE'),
		codeCol('경로', 130, 'APLY_ROUTE', 'HR_ROUTE', function(r) { return hrCodeName('HR_ROUTE', r.APLY_ROUTE) + (r.REFERRER ? ' (' + r.REFERRER + ')' : ''); }),
		codeCol('참석', 80, 'ATTEND_ST', 'HR_ATTEND'),
		codeCol('결과', 80, 'RESULT_ST', 'HR_RESULT'),
		codeCol('통보', 90, 'NOTICE_ST', 'HR_NOTICE'),
		codeCol('입사', 90, 'JOIN_ST', 'HR_JOIN'),
		textCol('출근일', 135, 'JOIN_DT', true, 'date'),
		{ t: '메모', w: 70, memo: true, v: function(r) { return r.MEMO_CNT; } }
	];
	var NONE = '__NONE';
	// 결과는 탭, 이름·연락처·메모는 검색, 날짜는 연도로 찾으므로 필터에서 뺀다
	var FILTERS = [['#fHire', 'HIRE_CD', 'HR_HIRE'], ['#fRoute', 'APLY_ROUTE', 'HR_ROUTE'], ['#fAttend', 'ATTEND_ST', 'HR_ATTEND'], ['#fNotice', 'NOTICE_ST', 'HR_NOTICE'], ['#fJoin', 'JOIN_ST', 'HR_JOIN']];
	// 목록 칸 색. 코드 없는 값은 색을 넣지 않는다
	var TONES = {
		ATTEND_ST: { ATTEND: 'good', CANCEL: 'mute', ABSENT: 'bad', CHANGE: 'warn' },
		RESULT_ST: { PASS: 'good', FAIL: 'bad', HOLD: 'warn', CANCEL: 'mute' },
		NOTICE_ST: { WAIT: 'mute', NOTIFIED: 'info', REPLY_WAIT: 'warn', CONFIRM: 'good', REJECT: 'bad' },
		JOIN_ST: { JOIN: 'good', REJECT: 'bad', JOIN_CANCEL: 'bad', NO_REPLY: 'warn', UNDECIDED: 'mute' },
		JOIN_DT: {}
	};
	// 쓸 필요 없는 칸은 회색, 써야 하는데 비어 있는 칸은 노란색
	function toneOf(r, field) {
		if (field !== 'ATTEND_ST') {
			if (r.ATTEND_ST !== 'ATTEND') return 'mute';
			if (field !== 'RESULT_ST') {
				if (r.RESULT_ST === 'HOLD') return 'warn';
				if (r.RESULT_ST !== 'PASS') return 'mute';
			}
		}
		if (field === 'JOIN_DT') return r.JOIN_DT ? 'good' : r.JOIN_ST === 'JOIN' ? 'warn' : 'mute';
		return r[field] ? TONES[field][r[field]] : 'warn';
	}
	function paintTones($tr, r) {
		COLS.forEach(function(c, i) {
			if (TONES[c.field]) $tr.children().eq(i).attr('data-tone', toneOf(r, c.field) || null);
		});
	}
	var rows = [], shown = [], current = '', editing = null, sortCol = 0, sortDir = -1;

	$(function() {
		load();
		$('#yearSel').on('change', function() { fillWeeks(); render(); });
		$('#monthSel').on('change', fillWeeks);
		$('#keyword').on('input', render);
	});

	// 월~일 한 주는 날짜가 더 많이 든 달의 주차다. 목요일이 든 달과 같다
	function monthWeeks(y, mon) {
		var thu = moment([y, mon - 1, 1]), weeks = [];
		thu.add((4 - thu.day() + 7) % 7, 'days');
		while (thu.month() === mon - 1) {
			weeks.push([thu.clone().subtract(3, 'days'), thu.clone().add(3, 'days')]);
			thu.add(7, 'days');
		}
		return weeks;
	}

	// 처음 보여 줄 주의 목요일(그 주가 속한 달을 정한다). 주말이면 지난주다
	function startThu() {
		var d = moment();
		if (d.isoWeekday() > 5) d.subtract(7, 'days');
		return d.isoWeekday(4);
	}

	// 주가 다른 달에 걸치면 달까지 적는다
	function weekRange(w) {
		var format = w[0].month() === w[1].month() ? 'D일' : 'M월 D일';
		return w[0].format(format) + '~' + w[1].format(format);
	}

	function fillWeeks() {
		var y = $('#yearSel').val(), mon = $('#monthSel').val();
		var $w = $('#weekSel').empty().append('<option value="">전체</option>').prop('disabled', !y || !mon);
		if (y && mon) monthWeeks(+y, +mon).forEach(function(w, i) {
			$w.append($('<option>').val(w[0].format('YYYY-MM-DD') + '|' + w[1].format('YYYY-MM-DD')).text((i + 1) + '주차(' + weekRange(w) + ')'));
		});
	}

	function inWeek(dt, week) {
		var w = week.split('|');
		return !!dt && dt >= w[0] && dt <= w[1];
	}

	// 보고 제목과 그 밖의 검색 조건. 검색어가 있으면 render 처럼 연도·월·주차를 보지 않는다
	function dashTitle() {
		var kw = $.trim($('#keyword').val()), y = $('#yearSel').val(), mon = $('#monthSel').val(), week = $('#weekSel').val();
		// 주차 옵션 "1주차(2일~8일)" 의 기간은 제목 끝으로 보낸다: 2026년 11월 1주차 신입 채용현황(2일~8일)
		var wk = (!kw && week ? $('#weekSel option:selected').text() : '').match(/^([^(]*)(\(.*\))?$/) || ['', '', ''];
		var title = kw ? '' : [y && y + '년', mon && +mon + '월', wk[1]].filter(Boolean).join(' ');
		var conds = kw ? ['검색어: ' + kw] : [];
		// 구분은 제목(신입/경력 채용현황)에 넣으므로 조건 줄에서는 뺀다
		var hire = { NEW: '신입 ', EXP: '경력 ' }[$('#fHire').val()] || '';
		FILTERS.forEach(function(f) {
			if (f[0] !== '#fHire' && $(f[0]).val()) conds.push($('label[for=' + f[0].substr(1) + ']').text() + ': ' + $(f[0]).find('option:selected').text());
		});
		return { title: (title || '전체 기간') + ' ' + hire + '채용현황' + (wk[2] || ''), conds: conds.join(' / ') };
	}

	// 코드별 인원. 코드가 없거나 지워진 값은 미입력으로 묶어 합계를 맞춘다
	function breakdown(list, field, grp) {
		if (!list.length) return '';
		var parts = [], counted = 0;
		(HR_CODES[grp] || []).forEach(function(o) {
			var n = list.filter(function(r) { return r[field] === o.CD; }).length;
			counted += n;
			if (n) parts.push(o.NM + n);
		});
		if (list.length > counted) parts.push('미입력' + (list.length - counted));
		return parts.join(', ');
	}

	// 메모(위가 첫 메모)의 첫 줄만 쓴다. 가져오기 때 붙은 [원본 …] 메모는 건너뛴다
	function rosterLine(r, i) {
		var who = [hrCodeName('HR_GENDER', r.GENDER), r.AGE].filter(Boolean).join(',');
		var info = [who, r.PHONE, hrCodeName('HR_ROUTE', r.APLY_ROUTE)].filter(Boolean).join(', ');
		var memo = (r.MEMO || '').split('\n').map(function(l) { return $.trim(l); }).filter(function(l) { return l && l.indexOf('[원본 ') !== 0; })[0];
		return (i + 1) + '. ' + r.APLY_NM + (info ? '(' + info + ')' : '') + '\n비고 : ' + (memo || '없음');
	}

	function dashCounts(list) {
		var pass = list.filter(function(r) { return r.RESULT_ST === 'PASS'; });
		var absent = list.filter(function(r) { return r.ATTEND_ST !== 'ATTEND'; });
		// 출근일이 있으면 출근확정이다
		var joined = list.filter(function(r) { return r.JOIN_DT; });
		var passJoined = pass.filter(function(r) { return r.JOIN_DT; }).length;
		return {
			total: list.length,
			attend: list.length - absent.length,
			attendDetail: breakdown(absent, 'ATTEND_ST', 'HR_ATTEND'),
			pass: pass.length,
			detail: [passJoined && '출근확정' + passJoined, breakdown(pass.filter(function(r) { return !r.JOIN_DT; }), 'JOIN_ST', 'HR_JOIN')].filter(Boolean).join(', '),
			hold: list.filter(function(r) { return r.RESULT_ST === 'HOLD'; }).length,
			join: joined.length,
			joinNames: joined.map(function(r) { return r.APLY_NM; }).join(', '),
			roster: joined.map(rosterLine).join('\n\n')
		};
	}

	function dashText(s, t) {
		function withDetail(n, detail) { return n + (detail ? '(' + detail + ')' : ''); }
		return [t.title].concat(t.conds ? ['(' + t.conds + ')'] : [], ['예정 : ' + s.total, '참석 : ' + withDetail(s.attend, s.attendDetail), '합격 : ' + withDetail(s.pass, s.detail), '보류 : ' + s.hold]).join('\n') + '\n\n' + (s.roster ? '출근확정 :\n' + s.roster : '출근확정 : 0');
	}

	// 보고 복사: 구분을 골랐으면 그 구분 하나, 아니면 신입·경력(구분 없는 사람이 있으면 '구분 없음'도) 블록을 차례로 — 블록마다 기존 문구 그대로, 제목만 「… 신입 채용현황」
	function dashReport(list, t) {
		if ($('#fHire').val()) return dashText(dashCounts(list), t);
		var codes = HR_CODES.HR_HIRE || [];
		var groups = codes.map(function(o) { return [o.NM, list.filter(function(r) { return r.HIRE_CD === o.CD; })]; });
		var noHire = list.filter(function(r) { return !codes.some(function(o) { return o.CD === r.HIRE_CD; }); });
		if (noHire.length) groups.push(['구분 없음', noHire]);
		return groups.map(function(g) { return dashText(dashCounts(g[1]), { title: t.title.replace('채용현황', g[0] + ' 채용현황'), conds: t.conds }); }).join('\n\n\n');
	}

	function pct(n, of) { return of ? Math.round(n * 100 / of) + '%' : '-'; }
	function withRate(rate, detail) { return [rate, detail].filter(Boolean).join(' · '); }

	// 예정 → 참석 → 합격 → 출근확정 막대. 비율은 바로 앞 단계 대비(참석률·합격률·확정률)
	function dashCard(name, list) {
		var s = dashCounts(list), $c = $('<div class="dash-card">');
		$('<div class="dash-card-head">').append($('<span>').text(name), $('<b>').text(s.total + '명'),
			$('<span class="small">').text('보류 ' + s.hold + (s.total ? ' · 최종 확정률 ' + pct(s.join, s.total) : ''))).appendTo($c);
		[['예정', s.total, '', '#6c8ebf'], ['참석', s.attend, pct(s.attend, s.total), '#0d6efd'], ['합격', s.pass, pct(s.pass, s.attend), '#198754'], ['출근확정', s.join, pct(s.join, s.pass), '#6f42c1']].forEach(function(st) {
			$('<div class="dash-step">').append($('<span>').text(st[0]),
				$('<div class="dash-bar">').append($('<i>').css({ width: (s.total ? st[1] * 100 / s.total : 0) + '%', background: st[3] })),
				$('<span class="v">').text(st[1] + ' ').append($('<small>').text(st[2]))).appendTo($c);
		});
		return $c;
	}

	function renderDash() {
		var s = dashCounts(shown), t = dashTitle(), $box = $('#dashStats').empty();
		$('#dashTitle').text(t.title);
		$('#dashCond').text(t.conds);
		[['예정', s.total], ['참석', s.attend, withRate(s.total && '참석률 ' + pct(s.attend, s.total), s.attendDetail)], ['합격', s.pass, withRate(s.attend && '합격률 ' + pct(s.pass, s.attend), s.detail)],
			['보류', s.hold], ['출근확정', s.join, withRate(s.pass && '확정률 ' + pct(s.join, s.pass), s.joinNames)]].forEach(function(t) {
			$('<div class="hr-dash-item">').append($('<div class="hr-dash-label">').text(t[0])).append($('<div class="hr-dash-num">').text(t[1]))
				.append($('<div class="hr-dash-sub">').text(t[2] || '')).appendTo($box);
		});
		// 신입·경력 나눠 보기. 구분이 비어 있는 면접자가 있으면 '구분 없음' 칸을 더한다
		var $split = $('#dashSplit').empty();
		(HR_CODES.HR_HIRE || []).forEach(function(o) { $split.append(dashCard(o.NM, shown.filter(function(r) { return r.HIRE_CD === o.CD; }))); });
		var noHire = shown.filter(function(r) { return !(HR_CODES.HR_HIRE || []).some(function(o) { return o.CD === r.HIRE_CD; }); });
		if (noHire.length) $split.append(dashCard('구분 없음', noHire));
		// 지원방법별: 인원이 있는 경로만, 맨 아래 합계
		var $route = $('#dashRoute').empty(), groups = (HR_CODES.HR_ROUTE || []).map(function(o) { return [o.NM, shown.filter(function(r) { return r.APLY_ROUTE === o.CD; })]; });
		groups.push(['미입력', shown.filter(function(r) { return !(HR_CODES.HR_ROUTE || []).some(function(o) { return o.CD === r.APLY_ROUTE; }); })]);
		groups.filter(function(g) { return g[1].length; }).concat(shown.length ? [['합계', shown, true]] : []).forEach(function(g) {
			var c = dashCounts(g[1]), hire = function(cd) { return g[1].filter(function(r) { return r.HIRE_CD === cd; }).length; };
			$('<tr>').toggleClass('dash-total', !!g[2]).append([g[0], hire('NEW'), hire('EXP'), c.total, c.attend, c.pass, c.join, pct(c.pass, c.attend)].map(function(v) { return $('<td>').text(v); })).appendTo($route);
		});
		if (!shown.length) $route.append('<tr><td colspan="8" class="text-center text-muted">검색 조건에 맞는 면접자가 없습니다</td></tr>');
	}

	$('#btnDash').on('click', function() {
		var $box = $('#dashBox'), $inner = $box.children().detach();
		bootbox.dialog({ title: '<i class="fas fa-chart-bar"></i> 대시보드 (검색 기준)', message: $inner, size: 'large', onEscape: true })
			.on('hidden.bs.modal', function() { $box.append($inner); });
	});

	// http 로 접속해도 되도록 clipboard API 대신 execCommand 를 쓴다
	function copyDash() {
		var $btn = $('#btnCopyDash'), $t = $('<textarea aria-hidden="true" style="position:fixed;top:0;left:-9999px;">').val(dashReport(shown, dashTitle())).appendTo($btn.closest('.modal-body')[0] || 'body'); // 팝업 안에서는 팝업이 초점을 붙잡아 body 칸은 고를 수 없다
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
		$m.val(startThu().format('MM'));
		FILTERS.forEach(function(f) {
			var $s = $(f[0]).empty().append('<option value="">전체</option>').append($('<option>').val(NONE).text('값 없음'));
			(HR_CODES[f[2]] || []).forEach(function(o) { $s.append($('<option>').val(o.CD).text(o.NM)); });
		});
		var $title = $('<tr>'), $new = $('<tr class="hr-new">');
		COLS.forEach(function(c, i) {
			if (c.memo) { $new.append('<th></th>'); $title.append($('<th>').attr('data-col', i).text(c.t)); return; }
			var $add = hrControl(c.type === 'textarea' ? 'text' : c.type, c.field === 'INTV_DT' ? moment().format('YYYY-MM-DD') : c.field === 'APLY_ROUTE' ? firstRoute() : c.field === 'HIRE_CD' ? 'NEW' : '')
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
			$('.hr-new-input[name=HIRE_CD]').val('NEW');
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
			var years = {}, sel = $('#yearSel').val(), thu = startThu(), thisYear = thu.format('YYYY');
			rows.forEach(function(r) { if (r.INTV_DT) years[r.INTV_DT.substr(0, 4)] = 1; });
			years[thisYear] = 1;
			var $y = $('#yearSel').empty().append('<option value="">전체</option>');
			Object.keys(years).sort().reverse().forEach(function(y) { $y.append($('<option>').val(y).text(y + '년')); });
			$y.val(sel === null ? thisYear : sel);
			if (sel === null) {
				fillWeeks();
				$('#weekSel').val(thu.clone().subtract(3, 'days').format('YYYY-MM-DD') + '|' + thu.clone().add(3, 'days').format('YYYY-MM-DD'));
			}
			render();
			// 관리자 홈 바로가기: ?INTV_SQ= 면 처음 한 번 그 사람 상세 창을 연다
			var linked = sel === null && /[?&]INTV_SQ=(\d+)/.exec(location.search);
			var row = linked && rows.filter(function(r) { return String(r.INTV_SQ) === linked[1]; })[0];
			if (row) openEdit(row);
		});
	}

	function render() {
		var year = $('#yearSel').val(), month = $('#monthSel').val(), week = $('#weekSel').val(), kw = $.trim($('#keyword').val()).toLowerCase();
		// 검색어가 있으면 연도·월과 상관없이 찾는다
		var base = rows.filter(function(r) {
			if (kw) return [r.APLY_NM, r.PHONE, r.MEMO].join(' ').toLowerCase().indexOf(kw) >= 0;
			// 주차는 앞뒤 달 날짜를 포함할 수 있어 연도·월 대신 기간으로 본다
			if (week) return inWeek(r.INTV_DT, week);
			return (!year || (r.INTV_DT || '').substr(0, 4) === year) && (!month || (r.INTV_DT || '').substr(5, 2) === month);
		}).filter(passFilters);
		shown = base;
		renderDash();
		markSort();
		var $tabs = $('#tabs').empty(), test = TABS[0][2];
		TABS.forEach(function(t) {
			if (t[0] === current) test = t[2];
			hrTab(t[0], t[1], base.filter(t[2]).length, t[0] === current).appendTo($tabs);
		});
		renderCal(test);
		var $body = $('#listBody').empty(), list = sortRows(base.filter(test));
		if (!list.length) { boEmpty($body, '조건에 맞는 면접자가 없습니다.'); return; }
		list.forEach(function(r) {
			var $tr = $('<tr>');
			COLS.forEach(function(c) {
				var $td = $('<td class="small">').appendTo($tr);
				if (c.memo) return $td.append(hrMemoBtn(MEMO_API, r.INTV_SQ, r.MEMO_CNT, r.APLY_NM, load));
				hrEditable($td, {
					url: '/admin/hr/saveInterviewFieldData.do', key: { INTV_SQ: r.INTV_SQ }, field: c.field, type: c.type, label: r.APLY_NM + ' ' + c.t,
					value: function() { return r[c.field]; },
					show: function() { return (c.show || c.v)(r); },
					saved: function(val) {
						r[c.field] = val;
						if (c.field === 'APLY_ROUTE' && val !== 'REFERRAL') r.REFERRER = null;
						paintTones($tr, r);
						renderDash();
					}
				});
			});
			$('<td>').append($('<button type="button" class="btn btn-xs btn-outline-secondary">상세</button>').on('click', function() { openEdit(r); })).appendTo($tr);
			paintTones($tr, r);
			$body.append($tr);
		});
	}

	function openEdit(row) {
		editing = row;
		pending = {};
		hrFillForm('#editForm', FIELDS, row);
		paintDocs();
		$('#editForm .ic-auto').removeClass('ic-auto');
		toggleReferrer();
		$('#editTitle').text('면접자 상세 · 순번 ' + (row.SEQ_NO || '-'));
		$('#btnDelete').show();
		// 경력직은 교육생 과정 없이 바로 직원관리 대기자로 간다
		$('#btnTrainee').toggle(!row.TRN_SQ && row.HIRE_CD !== 'EXP');
		$('#btnWait').toggle(row.HIRE_CD === 'EXP' && !row.WAIT_STAFF_SQ);
		$('#waitDone').toggle(!!row.WAIT_STAFF_SQ);
		paintNoteBtn();
		if (!$('#editMemo').length) $('<div class="mt-2" id="editMemoBox"><div class="hr-section">메모</div><div id="editMemo"></div></div>').insertAfter('#editFields');
		$('#editMemoBox').show();
		hrMemoFeed($('#editMemo'), MEMO_API, row.INTV_SQ, load);
		$('#editModal').modal('show');
	}

	// 캘린더에서 새 면접자: 누른(놓은) 날짜·시간과 이력서에서 읽은 값을 채운 상세 창. 저장을 눌러야 등록된다
	// 새 면접자 창에서 고른 파일 { RESUME, PORTFOLIO }. 저장에 성공하면 그 면접자의 드라이브 폴더에 올린다
	var pending = {};
	// [이름, 목록 YN 칸, 확장자]. 프로필은 대기자로 등록할 때 수행이력을 읽는 워드(SKILL INVENTORY 표)
	var DOCS = { RESUME: ['이력서', 'RESUME_YN', 'pdf'], PORTFOLIO: ['포트폴리오', 'PORTFOLIO_YN', 'pdf'], PROFILE: ['프로필', 'PROFILE_YN', 'docx'] };

	function paintDocs() {
		$.each(DOCS, function(kind, d) {
			var has = editing[d[1]] === 'Y', picked = pending[kind];
			$('#btnDoc' + kind).toggleClass('btn-primary', has).toggleClass('btn-outline-primary bg-white', !has).attr('title', picked ? picked.name : '')
				.html(has ? '<i class="far ' + (d[2] === 'docx' ? 'fa-file-word' : 'fa-file-pdf') + '"></i> ' + d[0] + ' 보기' : '<i class="fas fa-upload"></i> ' + d[0] + (picked ? ' 선택됨' : ' 등록'));
		});
	}

	$(document).on('click', '.ic-doc', function() {
		var kind = $(this).data('kind');
		if (editing[DOCS[kind][1]] === 'Y') {
			window.open('/admin/hr/interviewResumeFile.do?INTV_SQ=' + editing.INTV_SQ + '&KIND=' + kind, '_blank', 'noopener');
			return;
		}
		$('#docFile').data('kind', kind).attr('accept', DOCS[kind][2] === 'docx' ? '.docx' : 'application/pdf,.pdf').val('').click();
	});
	$(document).on('change', '#docFile', function() {
		var file = this.files[0], kind = $(this).data('kind'), ext = DOCS[kind][2];
		if (!file) return;
		if (!new RegExp('\\.' + ext + '$', 'i').test(file.name)) { bootbox.alert('<b>' + DOCS[kind][0] + '은(는) ' + ext.toUpperCase() + ' 파일만 올릴 수 있습니다</b>'); return; }
		// 이미 저장된 면접자는 바로 올리고, 새 면접자는 저장할 때 올린다
		if (editing.INTV_SQ) uploadDocs(editing.INTV_SQ, [[kind, file]], editing);
		else { pending[kind] = file; paintDocs(); }
	});

	// file: 끌어 놓은 이력서
	function openNew(dt, tm, fields, file) {
		fields = fields || {};
		editing = {};
		pending = file ? { RESUME: file } : {};
		paintDocs();
		hrFillForm('#editForm', FIELDS, $.extend({ APLY_TARGET: '이에스티', HIRE_CD: 'NEW', APLY_ROUTE: fields.APLY_ROUTE || (fields.APLY_NM ? '' : firstRoute()) }, fields, { INTV_DT: dt, INTV_TM: tm }));
		$('#editForm .ic-auto').removeClass('ic-auto');
		var auto = Object.keys(fields);
		auto.forEach(function(k) { $('#editForm [name=' + k + '], #editForm [data-multi=' + k + ']').addClass('ic-auto'); });
		toggleReferrer();
		$('#editTitle').text('새 면접자' + (auto.length ? ' · 이력서에서 ' + auto.length + '칸 채움(초록 칸)' : ''));
		$('#btnDelete, #btnTrainee, #btnWait, #waitDone, #editMemoBox, #btnNote').hide();
		$('#editModal').modal('show');
	}

	// ── 캘린더 보기 ──
	var calendar = null, view = 'list';
	try { view = localStorage.getItem('hrIntvView') === 'cal' ? 'cal' : 'list'; } catch (e) {}

	$(document).on('click', '#viewSwitch button', function() {
		view = $(this).data('view');
		try { localStorage.setItem('hrIntvView', view); } catch (e) {}
		render();
	});

	// 결과가 정해지면 색으로, 취소·불참은 점선으로 보인다
	function eventClass(r) {
		if (r.ATTEND_ST === 'CANCEL' || r.ATTEND_ST === 'ABSENT') return 'ic-cancel';
		return '';
	}
	// [바탕, 왼쪽 띠] 결과별. 결과 전은 파랑
	function eventColor(r) {
		return { PASS: ['#e8f5ec', '#198754'], FAIL: ['#fbe9eb', '#dc3545'], HOLD: ['#fff3e6', '#fd7e14'] }[r.RESULT_ST] || ['#e7f1ff', '#0d6efd'];
	}
	function esc(s) { return $('<div>').text(s || '').html(); }
	// 이름 아래 줄: 지원대상, 지원방법, 추천자명(있을 때만, 지원방법이 이미 '추천·소개'라 앞말 없이). 빈 값은 빼다
	function eventSubs(r) {
		return [r.APLY_TARGET, hrCodeName('HR_ROUTE', r.APLY_ROUTE), r.REFERRER].map(function(s) { return $.trim(s || ''); }).filter(Boolean);
	}
	// 일정 안: [신입/경력 배지] 이름 (참석)(결과) — 코드마다 색이 다르다. 그 아래 작은 한 줄
	function eventHtml(r) {
		function chip(cls, grp, cd) { return cd ? '<span class="' + cls + ' ic-' + esc(cd) + '">' + esc(hrCodeName(grp, cd)) + '</span>' : ''; }
		var subs = eventSubs(r);
		// 합격이면 뒤에 통보 상태·입사 답변을 테두리 칩으로(목록 칸과 같은 색 기준 TONES)
		function st(field, grp) { return r[field] ? '<span class="ic-chip ic-st t-' + (TONES[field][r[field]] || 'mute') + '">' + esc(hrCodeName(grp, r[field])) + '</span>' : ''; }
		return chip('ic-badge', 'HR_HIRE', r.HIRE_CD) + '<span class="ic-name">' + esc(r.APLY_NM) + '</span>' + chip('ic-chip', 'HR_ATTEND', r.ATTEND_ST) + chip('ic-chip', 'HR_RESULT', r.RESULT_ST)
			+ (r.RESULT_ST === 'PASS' ? st('NOTICE_ST', 'HR_NOTICE') + st('JOIN_ST', 'HR_JOIN') : '')
			+ (subs.length ? '<span class="ic-sub">' + esc(subs.join(' · ')) + '</span>' : '');
	}

	// 연도·월·주차를 바꾸면 캘린더가 그 주(주별)나 그 달(월별)로 간다. 값이 그대로면 사용자가 넘긴 화면을 둔다
	var calKey = null, phone = window.matchMedia && matchMedia('(max-width: 767px)').matches;
	function calGoto() {
		var y = $('#yearSel').val(), mon = $('#monthSel').val(), week = $('#weekSel').val(), key = [y, mon, week].join('|');
		if (key === calKey) return;
		calKey = key;
		if (week) {
			// 폰 일별: 고른 주에 오늘이 있으면 오늘부터(주 첫날 월요일이 아니라)
			var w = week.split('|'), today = moment().format('YYYY-MM-DD');
			calendar.changeView(phone ? 'timeGridDay' : 'timeGridWeek', phone && today >= w[0] && today <= (w[1] || w[0]) ? today : w[0]);
			return;
		}
		if (y && mon) calendar.changeView('dayGridMonth', y + '-' + mon + '-01');
		else if (y) calendar.changeView('dayGridMonth', y + '-' + (y === moment().format('YYYY') ? moment().format('MM') : '01') + '-01');
	}

	// 반대로 캘린더를 화살표·오늘·주별·월별로 넘기면 위의 연도·월·주차(와 통계)를 그 화면에 맞춘다
	function calSync(v) {
		if (calKey === null) return; // 처음 그릴 때는 위 필터가 캘린더를 정한다
		var y, mon, week = '';
		if (v.type === 'timeGridWeek' || v.type === 'timeGridDay') { // 폰 일별도 그 날이 든 주차로(아니면 주차가 풀려 월별로 튐)
			var thu = v.type === 'timeGridDay' ? moment(v.currentStart).isoWeekday(4) : moment(v.currentStart).add(3, 'days').isoWeekday(4); // 주차는 목요일이 든 달
			y = thu.format('YYYY'); mon = thu.format('MM');
			week = thu.clone().subtract(3, 'days').format('YYYY-MM-DD') + '|' + thu.clone().add(3, 'days').format('YYYY-MM-DD');
		} else {
			y = moment(v.currentStart).format('YYYY'); mon = moment(v.currentStart).format('MM');
		}
		var key = [y, mon, week].join('|');
		if (key === calKey) return;
		calKey = key;
		if (!$('#yearSel option').filter(function() { return this.value === y; }).length) $('#yearSel').append($('<option>').val(y).text(y + '년'));
		$('#yearSel').val(y);
		$('#monthSel').val(mon);
		fillWeeks();
		$('#weekSel').val(week);
		setTimeout(render, 0); // 캘린더가 날짜 칸을 다 그린 뒤 일정·목록·통계를 다시 그린다
	}

	// 캘린더 안 일정은 날짜 칸이 거르므로 검색어·필터·탭만 적용한다
	function renderCal(test) {
		var isCal = view === 'cal';
		$('#viewSwitch button').each(function() { $(this).toggleClass('active', $(this).data('view') === view).attr('aria-pressed', $(this).data('view') === view); });
		$('#calView').toggle(isCal);
		$('#listView').toggle(!isCal);
		if (!isCal) return;
		if (!calendar) calendar = makeCalendar();
		calGoto();
		var kw = $.trim($('#keyword').val()).toLowerCase();
		var list = rows.filter(function(r) { return r.INTV_DT && (!kw || [r.APLY_NM, r.PHONE, r.MEMO].join(' ').toLowerCase().indexOf(kw) >= 0); }).filter(passFilters).filter(test);
		calendar.batchRendering(function() {
			calendar.getEvents().forEach(function(e) { e.remove(); });
			list.forEach(function(r) {
				// [구분] 이름 · 참석 · 결과. 정해지지 않은 값은 뺀다
			var title = (r.HIRE_CD ? '[' + hrCodeName('HR_HIRE', r.HIRE_CD) + '] ' : '') + [r.APLY_NM, hrCodeName('HR_ATTEND', r.ATTEND_ST), hrCodeName('HR_RESULT', r.RESULT_ST)].filter(Boolean).join(' · ');
			var color = eventColor(r);
			calendar.addEvent({ id: String(r.INTV_SQ), title: title, start: r.INTV_DT + (r.INTV_TM ? 'T' + r.INTV_TM : ''),
					allDay: !r.INTV_TM, backgroundColor: color[0], borderColor: color[1], textColor: '#212529', classNames: [eventClass(r)], extendedProps: { row: r } });
			});
		});
	}

	function makeCalendar() {
		// 폰: list 플러그인이 없어 하루 시간표로 시작(주별 5열은 375px 에서 안 읽힘), 툴바 짧게
		var c = new FullCalendar.Calendar(document.getElementById('calendar'), {
			plugins: ['dayGrid', 'timeGrid', 'interaction'],
			locale: 'ko',
			header: phone ? { left: 'prev,next today', center: 'title', right: 'timeGridDay,dayGridMonth' } : { left: 'prev,next today', center: 'title', right: 'timeGridWeek,dayGridMonth' },
			buttonText: { week: '주별', month: '월별', day: '일별' },
			defaultView: phone ? 'timeGridDay' : 'timeGridWeek',
			hiddenDays: [0, 6],
			minTime: '09:00:00', maxTime: '19:00:00', slotDuration: '00:30:00',
			defaultTimedEventDuration: '01:00',
			height: 'auto', nowIndicator: true,
			slotEventOverlap: false, // 같은 시간 일정은 겹치지 않고 나란히 — 작은 줄이 가려지지 않게
			editable: true, eventDurationEditable: false,
			datesRender: function(info) { calSync(info.view); },
			dateClick: function(info) { openNew(moment(info.date).format('YYYY-MM-DD'), info.allDay ? '' : moment(info.date).format('HH:mm')); },
			eventRender: function(info) {
				var r = info.event.extendedProps.row; // 말줄임으로 잘린 글은 마우스를 올리면 다 보인다
				$(info.el).attr('title', [(r.INTV_TM ? r.INTV_TM + ' ' : '') + info.event.title].concat(eventSubs(r)).join('\n')).find('.fc-title').html(eventHtml(r));
			},
			eventClick: function(info) { openEdit(info.event.extendedProps.row); },
			eventDrop: function(info) { moveEvent(info); }
		});
		c.render();
		return c;
	}

	// 놓는 순간 면접일자·시간을 저장한다. 실패하면 제자리로 되돌린다
	function moveEvent(info) {
		var r = info.event.extendedProps.row, dt = moment(info.event.start).format('YYYY-MM-DD'), tm = info.event.allDay ? '' : moment(info.event.start).format('HH:mm');
		var url = '/admin/hr/saveInterviewFieldData.do';
		hrPost(url, { INTV_SQ: r.INTV_SQ, FIELD: 'INTV_DT', VALUE: dt }, function() {
			r.INTV_DT = dt;
			hrPost(url, { INTV_SQ: r.INTV_SQ, FIELD: 'INTV_TM', VALUE: tm }, function() { r.INTV_TM = tm; render(); }, function() { render(); });
		}, function() { info.revert(); });
	}

	// ── 이력서 PDF 끌어 놓기 ── 놓은 위치의 날짜 칸과 30분 칸을 찾는다(주간 보기만 시간까지)
	function slotAt(x, y) {
		function hit(el) { var b = el.getBoundingClientRect(); return x >= b.left && x <= b.right && y >= b.top && y <= b.bottom; }
		var day = $('#calendar td.fc-day[data-date]').filter(function() { return hit(this); })[0];
		if (!day) return null;
		var slat = $('#calendar .fc-slats tr[data-time]').filter(function() { return hit(this); })[0];
		return { day: day, slat: slat, date: day.getAttribute('data-date'), time: slat ? slat.getAttribute('data-time').substr(0, 5) : '' };
	}

	function showDrop(s) {
		var $box = $('#calView'), base = $box[0].getBoundingClientRect(), d = s.day.getBoundingClientRect();
		var top = s.slat ? s.slat.getBoundingClientRect().top : d.top, height = s.slat ? s.slat.getBoundingClientRect().height * 2 : d.height;
		var $mark = $box.find('.ic-drop');
		if (!$mark.length) $mark = $('<div class="ic-drop" aria-hidden="true">').appendTo($box);
		$mark.css({ left: d.left - base.left, width: d.width, top: top - base.top, height: height }).text((s.time || moment(s.date).format('M/D')) + '에 등록');
	}

	function hasFiles(e) { var t = e.originalEvent.dataTransfer && e.originalEvent.dataTransfer.types; return !!t && $.inArray('Files', t) >= 0; }

	$(document).on('dragover', '#calView', function(e) {
		if (!hasFiles(e)) return;
		e.preventDefault();
		var s = slotAt(e.originalEvent.clientX, e.originalEvent.clientY);
		$('#calView').addClass('is-file-over');
		if (s) showDrop(s); else $('#calView .ic-drop').remove();
	});
	$(document).on('dragleave', '#calView', function(e) {
		if (e.originalEvent.relatedTarget && $.contains(this, e.originalEvent.relatedTarget)) return;
		$('#calView').removeClass('is-file-over').find('.ic-drop').remove();
	});
	$(document).on('drop', '#calView', function(e) {
		if (!hasFiles(e)) return;
		e.preventDefault();
		$('#calView').removeClass('is-file-over').find('.ic-drop').remove();
		var s = slotAt(e.originalEvent.clientX, e.originalEvent.clientY), file = e.originalEvent.dataTransfer.files[0];
		if (!s) { bootbox.alert('캘린더의 날짜·시간 칸 위에 놓아 주세요.'); return; }
		if (!file || !/\.pdf$/i.test(file.name)) { bootbox.alert('<b>PDF만 올릴 수 있습니다</b><br>이력서 PDF 파일을 끌어 놓아 주세요.'); return; }
		var fd = new FormData();
		fd.append('file', file);
		$.ajax({ url: '/admin/hr/readInterviewResumeData.do', type: 'POST', data: fd, processData: false, contentType: false }).done(function(res) {
			if (res.error) { bootbox.alert($('<div>').text(res.error).html()); return; }
			openNew(s.date, s.time, res.fields, file);
		});
	});

	function saveEdit() {
		var data = hrFormData('#editForm');
		if (editing.INTV_SQ) data.push({ name: 'INTV_SQ', value: editing.INTV_SQ });
		var files = $.map(pending, function(f, kind) { return [[kind, f]]; });
		hrPost('/admin/hr/saveInterviewData.do', data, function(res) {
			$('#editModal').modal('hide');
			if (files.length && res.INTV_SQ) uploadDocs(res.INTV_SQ, files);
			load();
		});
	}

	// 면접자는 이미 저장됐으므로 파일 올리기가 실패해도 안내만 한다. 같은 이름 폴더를 두 번 만들지 않게 하나씩 차례로 올린다.
	// row: 열려 있는 상세 창의 면접자(올린 뒤 버튼을 '보기'로 바꾼다)
	function uploadDocs(intvSq, files, row) {
		var msgs = [];
		(function next(i) {
			if (i >= files.length) { bootbox.alert(msgs.join('<br>')); load(); return; }
			var kind = files[i][0], label = DOCS[kind][0], fd = new FormData();
			fd.append('INTV_SQ', intvSq);
			fd.append('KIND', kind);
			fd.append('file', files[i][1]);
			$.ajax({ url: '/admin/hr/uploadInterviewResumeData.do', type: 'POST', data: fd, processData: false, contentType: false }).done(function(res) {
				msgs.push(res.error ? label + '를 드라이브에 올리지 못했습니다. ' + $('<div>').text(res.error).html() : label + '를 드라이브에 올렸습니다.');
				if (!res.error && row) { row[DOCS[kind][1]] = 'Y'; if (editing === row) paintDocs(); }
			}).fail(function() { msgs.push(label + '를 드라이브에 올리지 못했습니다.'); }).always(function() { next(i + 1); });
		})(0);
	}

	function deleteEdit() {
		bootbox.confirm($('<div>').text(editing.APLY_NM).html() + ' 면접자를 삭제할까요? 되돌릴 수 없습니다.<br><small class="text-muted">드라이브의 이력서 이름 폴더와 비게 되는 날짜 폴더는 휴지통으로 갑니다(30일 안에 되살릴 수 있음).</small>', function(ok) {
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

	// 경력직: 교육생을 거치지 않고 직원관리 대기 탭에 소속 '경력직' 카드로 들어간다
	// 면접결과 기록·이력서·프로필(워드 수행이력)로 대기 카드의 빈 칸을 서버가 채운다. 면접결과 보고 문구는 비고로 들어간다
	function toWait() {
		var row = editing, has = noteOf(row), docs = [row.PROFILE_YN === 'Y' && '프로필(수행이력)', row.RESUME_YN === 'Y' && '이력서', !$.isEmptyObject(has) && '면접결과'].filter(Boolean);
		bootbox.confirm($('<div>').text(row.APLY_NM).html() + ' 님을 직원관리 대기자(소속: 경력직)로 등록할까요?'
			+ '<br><small class="text-muted">' + (docs.length ? docs.join(' · ') + '에서 읽은 값으로 대기 카드의 빈 칸을 자동으로 채워요.' : '등록된 프로필·이력서·면접결과가 없어 이름·연락처만 들어가요.') + '</small>', function(ok) {
			if (ok) hrPost('/admin/hr/waitFromInterviewData.do', { INTV_SQ: row.INTV_SQ, REPORT: $.isEmptyObject(has) ? '' : noteReport(row, has) }, function(res) {
				$('#editModal').modal('hide');
				load();
				bootbox.alert('대기자로 등록했습니다. 직원관리의 대기 탭에서 확인해 주세요.' + (res.driveNote ? '<br><small class="text-muted">' + $('<div>').text(res.driveNote).html() + '</small>' : ''));
			});
		});
	}

	// ── 면접결과 기록(칩) ── 모집관리 인터뷰 기록과 같은 방식: 칩을 눌러 고르고(여러 개 항목은 여러 번), 없는 예시는 ＋ 로 추가
	// [키, 공통코드(HR_INTV_…, 없으면 글 칸), 이름, 여러 개]. 글 칸은 면접 칸 값으로 먼저 채운다(prefill)
	var NOTE_EXP = [['sched', 'SCHED', '일정'], ['addr', null, '거주지'], ['station', null, '가까운 역'], ['area', 'AREA', '출근 가능 지역', true], ['areaNote', null, '출근지 메모'],
		['domain', 'DOMAIN', '업무단', true], ['work', 'WORK', '업무 형태', true], ['pos', 'POS', '포지션', true], ['hs', null, '고등학교 · 졸업'], ['univ', null, '대학교 · 졸업'],
		['score', 'SCORE', '점수'], ['fe', 'FE', '프론트', true], ['be', 'BE', '백엔드', true], ['db', 'DB', 'DB', true], ['fw', 'FW', '프레임워크', true], ['sp', 'SP', '특수', true],
		['grade', 'GRADE', '지원등급'], ['years', null, '연차'], ['price', null, '희망 단가'], ['pers', 'PERS', '성격', true], ['comm', 'COMM', '소통'], ['pay', null, '급여'],
		['auto', 'AUTO', '자동지원'], ['cert', 'CERT', '정보처리기사'], ['certDt', null, '취득년월'], ['verdict', 'VERDICT', '종합']];
	var NOTE_NEW = [['sched', 'SCHED', '입사 가능'], ['school', null, '학교 · 전공'], ['major', 'MAJOR', '전공'], ['train', 'TRAIN', '교육 이수', true], ['tech', 'TECH', '기술 이해도'],
		['fe', 'FE', '프론트', true], ['be', 'BE', '백엔드', true], ['atti', 'ATTI', '태도', true], ['comm', 'COMM', '소통'], ['will', 'WILL', '입사 의지'], ['area', 'AREA', '근무 가능 지역', true], ['verdict', 'VERDICT', '종합']];
	function noteCats(row) { return row.HIRE_CD === 'EXP' ? NOTE_EXP : NOTE_NEW; }
	function noteOf(row) { try { return JSON.parse(row.INTV_NOTE || '{}') || {}; } catch (e) { return {}; } }
	function noteSummary(row, n) {
		return [n.verdict && '종합 ' + n.verdict, n.score && '점수 ' + n.score, n.tech && '기술 ' + n.tech, n.grade, n.price, n.comm && '소통 ' + n.comm].filter(Boolean).join(' · ');
	}
	function paintNoteBtn() {
		var n = noteOf(editing), s = noteSummary(editing, n);
		$('#btnNote').show().toggleClass('btn-success', !$.isEmptyObject(n)).toggleClass('btn-outline-success bg-white', $.isEmptyObject(n)).attr('title', s || '면접결과를 칩으로 기록해요');
	}
	function nv(x) { return $.isArray(x) ? x.join(', ') : (x || ''); }
	// 보고 문구. 경력직은 기존 메신저 양식([이름 면접결과] -일정 : …) 그대로, 신입은 같은 모양의 요약
	function noteReport(row, n) {
		var L = ['[' + row.APLY_NM + ' 면접결과]', ''];
		if (row.HIRE_CD === 'EXP') {
			L.push('-일정 : ' + nv(n.sched), '-거주지 : ' + nv(n.addr), '-출근지 : ' + [nv(n.station), nv(n.area)].filter(Boolean).join(' > ') + (n.areaNote ? ' (' + n.areaNote + ')' : ''),
				'-업무단 : ' + [nv(n.domain), nv(n.work), nv(n.pos)].filter(Boolean).join(' / '), '-나온고등학교, 졸업년도 : ' + nv(n.hs), '-나온대학교 ,졸업년도 : ' + nv(n.univ), '',
				'-점수 : ' + nv(n.score), '-주요 스킬셋 : ', '    - 프론트 : ' + nv(n.fe), '    - 백엔드 : ' + nv(n.be), '    - DB : ' + nv(n.db), '    - 프레임워크 : ' + nv(n.fw), '    - 특수 : ' + nv(n.sp),
				'    - 지원등급/연차 : ' + [nv(n.grade), nv(n.years)].filter(Boolean).join(' / ') + (n.price ? ' , ' + n.price : ''), '',
				'- 성격 : ' + nv(n.pers), '- 소통 : ' + nv(n.comm), '- 급여 : ' + nv(n.pay), '- 자동지원여부 : ' + nv(n.auto), '- 종합 : ' + nv(n.verdict), '',
				'- 기타 :', '1. 정보처리기사 여부 / 취득년월 : ' + [nv(n.cert), nv(n.certDt)].filter(Boolean).join(' '));
		} else {
			NOTE_NEW.forEach(function(c) { L.push('-' + c[2] + ' : ' + nv(n[c[0]])); });
		}
		if (n.memo) L.push('', '- 메모 :', n.memo);
		return L.join('\n');
	}
	function noteDialog(row) {
		var cats = noteCats(row), n = $.extend({}, noteOf(row)), editingCodes = false;
		var pre = { addr: row.ADDR, station: row.STATION, univ: row.EDU, school: row.EDU };
		cats.forEach(function(c) { if (c[3]) n[c[0]] = $.isArray(n[c[0]]) ? n[c[0]] : []; else if (n[c[0]] == null) n[c[0]] = c[1] ? '' : (pre[c[0]] || ''); });
		var $k = $('<div class="in-kv">');
		var $edit = $('<button type="button" class="btn btn-sm btn-link p-0">✎ 예시 빼기</button>').on('click', function() { editingCodes = !editingCodes; $k.toggleClass('editing', editingCodes); $(this).text(editingCodes ? '✓ 다 뺐어요' : '✎ 예시 빼기'); });
		$k.append($('<div class="in-help">').text((row.HIRE_CD === 'EXP' ? '경력직' : '신입') + ' 면접 결과를 칩으로 골라요(다시 누르면 풀림). 없는 예시는 「＋」로 추가하면 다음부터 고를 수 있어요. ').append($edit));
		cats.forEach(function(c) {
			var key = c[0], $g;
			if (!c[1]) {
				$g = $('<input type="text" class="form-control form-control-sm" maxlength="300">').val(n[key]).on('input', function() { n[key] = $.trim(this.value); });
			} else {
				$g = $('<span class="d-flex flex-wrap" style="gap:4px" role="group">').attr('aria-label', c[2]);
				var paint = function() {
					var list = (HR_CODES['HR_INTV_' + c[1]] || []).map(function(x) { return x.NM; });
					(c[3] ? n[key] : n[key] ? [n[key]] : []).forEach(function(x) { if (list.indexOf(x) < 0) list.push(x); }); // 목록에서 빠진 지난 값도 고른 채로
					$g.empty();
					list.forEach(function(x) {
						var on = c[3] ? n[key].indexOf(x) >= 0 : n[key] === x;
						$g.append($('<button type="button" class="in-chip">').attr('aria-pressed', on).text(x).on('click', function() {
							if (editingCodes) return bootbox.confirm('「' + x + '」 예시를 ' + c[2] + ' 목록에서 뺄까요? 이미 남긴 기록은 그대로예요.', function(ok) {
								if (ok) hrPost('/admin/hr/interviewCodeData.do', { KIND: c[1], ACT: 'DEL', NM: x }, function(res) { hrSetCodes(res.result); paint(); });
							});
							if (c[3]) { var i = n[key].indexOf(x); if (i >= 0) n[key].splice(i, 1); else n[key].push(x); } else n[key] = on ? '' : x;
							paint();
						}));
					});
					$g.append($('<button type="button" class="in-chip in-add" title="예시 추가">＋</button>').on('click', function() {
						bootbox.prompt({ title: c[2] + ' 예시 추가', callback: function(x) {
							x = $.trim(x || '');
							if (x) hrPost('/admin/hr/interviewCodeData.do', { KIND: c[1], ACT: 'ADD', NM: x }, function(res) {
								hrSetCodes(res.result);
								if (c[3]) { if (n[key].indexOf(x) < 0) n[key].push(x); } else n[key] = x;
								paint();
							});
						} });
					}));
				};
				paint();
			}
			$k.append($('<label>').text(c[2]).append(c[3] ? $('<small class="d-block text-muted font-weight-normal">').text('여러 개') : '')).append($g);
		});
		var $memo = $('<textarea rows="3" class="form-control form-control-sm" maxlength="3000" placeholder="그 밖에 (예: 약간 말투가 딱딱함, 단가 높음)">').val(n.memo || '');
		$k.append('<label>메모</label>').append($memo);
		function collect() {
			n.memo = $.trim($memo.val());
			var out = {};
			$.each(n, function(k, x) { if ($.isArray(x) ? x.length : x) out[k] = x; }); // 빈 칸은 저장하지 않는다
			return out;
		}
		var dlg = bootbox.dialog({ title: '📝 ' + $('<div>').text(row.APLY_NM).html() + ' 면접결과 (' + (row.HIRE_CD === 'EXP' ? '경력' : '신입') + ')', message: $k, size: 'large', onEscape: true, buttons: {
			copy: { label: '보고 내용 복사', className: 'btn-sm btn-outline-primary mr-auto', callback: function() {
				var $t = $('<textarea aria-hidden="true" style="position:fixed;top:0;left:-9999px;">').val(noteReport(row, collect())).appendTo(dlg.find('.modal-body'));
				$t[0].select();
				var ok = false;
				try { ok = document.execCommand('copy'); } catch (e) {}
				$t.remove();
				hrToast(ok ? '보고 내용을 복사했어요.' : '복사하지 못했어요.');
				return false;
			} },
			cancel: { label: '닫기', className: 'btn-sm btn-outline-secondary' },
			ok: { label: '기록 저장', className: 'btn-sm btn-primary', callback: function() {
				var out = collect(), json = $.isEmptyObject(out) ? '' : JSON.stringify(out);
				hrPost('/admin/hr/saveInterviewNoteData.do', { INTV_SQ: row.INTV_SQ, INTV_NOTE: json }, function() {
					row.INTV_NOTE = json;
					if (editing === row) paintNoteBtn();
					dlg.modal('hide');
					hrToast('면접결과를 저장했어요.');
					load();
				});
				return false;
			} } } });
	}

	</script>
</body>
</html>
