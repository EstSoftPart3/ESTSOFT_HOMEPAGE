<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_head.jspf"%>
<style>
	.hm-hello { display: flex; align-items: baseline; flex-wrap: wrap; gap: 10px; margin-bottom: 12px; }
	.hm-hello b { font-size: 18px; } .hm-hello .ml-auto { font-size: 12px; }
	.hm-kpis { display: grid; grid-template-columns: repeat(auto-fit, minmax(170px, 1fr)); gap: 10px; margin-bottom: 12px; }
	.hm-kpi { display: block; background: #fff; border: 1px solid rgba(17,17,17,.1); border-radius: 10px; padding: 10px 12px; color: #111; }
	.hm-kpi:hover, .hm-kpi:focus { border-color: #0b6e8a; text-decoration: none; color: #111; }
	.hm-kpi span { color: #5f6b75; font-size: 12px; } .hm-kpi b { display: block; font-size: 24px; font-variant-numeric: tabular-nums; line-height: 1.3; }
	.hm-kpi small { color: #5f6b75; } .hm-kpi.warn b { color: #7a5600; } .hm-kpi.bad b { color: #a32020; }
	/* 홈 격자: 스마트폰 위젯처럼 가로 8칸 × 세로 칸(60px), 위젯마다 가로×세로(--w, --h). 빈 곳은 뒤 위젯이 채운다(dense).
	   내용이 칸보다 많으면 위젯 안에서 스크롤. 좁은 창은 4칸으로 줄이고(넓은 위젯은 4칸으로), 폰 너비는 한 줄에 하나·높이는 내용만큼 */
	.hm-grid { display: grid; grid-template-columns: repeat(8, minmax(0, 1fr)); grid-auto-rows: 60px; grid-auto-flow: row dense; gap: 12px; }
	.hm-grid > .hm-card { grid-column: span var(--w, 4); grid-row: span var(--h, 3); display: flex; flex-direction: column; }
	.hm-grid > .hm-card.hm-off { display: none; }
	.hm-card { background: #fff; border: 1px solid rgba(17,17,17,.1); border-radius: 10px; overflow: hidden; min-width: 0; min-height: 0; }
	.hm-card header { display: flex; align-items: center; gap: 6px; padding: 8px 12px; border-bottom: 1px solid rgba(17,17,17,.08); font-weight: 700; flex: none; white-space: nowrap; overflow: hidden; }
	.hm-card header a { font-weight: 400; font-size: 12px; margin-left: auto; }
	.hm-card .hm-body { padding: 6px 12px 10px; flex: 1; min-height: 0; overflow: auto; }
	@media (max-width: 1199px) { .hm-grid { grid-template-columns: repeat(4, minmax(0, 1fr)); } .hm-grid > .hm-card { grid-column: span min(var(--w, 4), 4); } }
	@media (max-width: 767px) { .hm-grid { grid-template-columns: 1fr; grid-auto-rows: auto; } .hm-grid > .hm-card { grid-column: 1 / -1; grid-row: auto; } .hm-card .hm-body { overflow: visible; } }
	/* 오른쪽 가운데 반투명 「위젯」 탭 → 위젯 메뉴(보이기·순서·크기·초기화, 바뀌면 바로 저장) */
	#hmWgTab { position: fixed; right: 0; top: 50%; transform: translateY(-50%); z-index: 1040; border: 0; background: rgba(11,110,138,.55); color: #fff; border-radius: 8px 0 0 8px; padding: 12px 6px; writing-mode: vertical-rl; font-weight: 700; letter-spacing: 2px; box-shadow: 0 2px 8px rgba(0,0,0,.15); }
	#hmWgTab:hover, #hmWgTab:focus { background: rgba(11,110,138,.85); }
	#hmWg { position: fixed; right: 0; top: 50%; transform: translateY(-50%); z-index: 1045; width: 360px; max-width: 100vw; max-height: 90vh; display: none; flex-direction: column; background: rgba(255,255,255,.93); backdrop-filter: blur(8px); border: 1px solid rgba(17,17,17,.12); border-right: 0; border-radius: 10px 0 0 10px; box-shadow: -6px 0 24px rgba(0,0,0,.15); }
	#hmWg.open { display: flex; }
	#hmWg > header { display: flex; align-items: center; padding: 8px 12px; border-bottom: 1px solid rgba(17,17,17,.08); font-weight: 700; }
	#hmWg > header span { flex: 1; } #hmWg > header button { border: 0; background: none; font-size: 18px; line-height: 1; color: #5f6b75; }
	#hmWg ul { list-style: none; margin: 0; padding: 4px 8px; overflow-y: auto; flex: 1; }
	#hmWg li.wg { display: flex; align-items: center; gap: 6px; padding: 5px 4px; border-bottom: 1px dashed rgba(17,17,17,.1); }
	#hmWg li.wg .g { color: #9aa4ac; cursor: grab; letter-spacing: -2px; }
	#hmWg li.wg .nm { flex: 1; margin: 0; font-weight: 400; cursor: pointer; }
	#hmWg li.wg.off .nm { color: #9aa4ac; text-decoration: line-through; }
	#hmWg li.wg.drag { opacity: .4; }
	#hmWg .sz { border: 1px solid #ccd3d8; border-radius: 4px; background: #fff; padding: 0 8px; font-size: 11px; font-weight: 700; color: #0b6e8a; }
	#hmWg .sz[aria-expanded=true] { background: #0b6e8a; color: #fff; border-color: #0b6e8a; }
	#hmWg li.pk { padding: 4px 4px 8px; }
	.hm-pk .t { display: flex; justify-content: space-between; font-size: 11px; color: #5f6b75; margin-bottom: 4px; } .hm-pk .t b { color: #0b6e8a; font-size: 13px; }
	.hm-pk .m { display: grid; grid-template-columns: repeat(8, 22px); grid-auto-rows: 16px; gap: 3px; }
	.hm-pk .m button { border: 1px solid #d5dbe0; border-radius: 3px; background: #f7f9fa; padding: 0; }
	.hm-pk .m button.min { background: #cfe6ee; border-color: #9cc9d6; } .hm-pk .m button.on { background: #0b6e8a; border-color: #0b6e8a; }
	#hmWg > footer { display: flex; align-items: center; gap: 6px; padding: 8px 12px; border-top: 1px solid rgba(17,17,17,.08); font-size: 11px; color: #5f6b75; }
	.hm-card .table { margin: 0; font-size: 12.5px; }
	.hm-todo { list-style: none; margin: 0; padding: 0; }
	.hm-todo li { display: flex; align-items: center; gap: 8px; padding: 6px 0; border-bottom: 1px dashed rgba(17,17,17,.12); flex-wrap: wrap; }
	.hm-todo li:last-child { border-bottom: 0; } .hm-todo li > a.go { margin-left: auto; font-size: 12px; }
	.hm-link { color: #0b6e8a; font-weight: 700; }
	.hm-money { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; } .hm-money a { display: block; background: #fafbfc; border-radius: 8px; padding: 6px 10px; color: #111; }
	.hm-money span { color: #5f6b75; font-size: 11.5px; } .hm-money b { display: block; font-size: 16px; font-variant-numeric: tabular-nums; }
	.hm-empty { color: #8a949c; padding: 8px 0; }
	/* 일정 캘린더 */
	.hm-cal-chips { display: flex; flex-wrap: wrap; gap: 6px; margin: 4px 0 8px; }
	.hm-cal-chip { display: inline-flex; align-items: center; gap: 5px; border: 1px solid rgba(17,17,17,.15); background: #fff; border-radius: 999px; padding: 2px 10px; font-size: 12px; font-weight: 700; color: #444; }
	.hm-cal-chip i { width: 10px; height: 10px; border-radius: 50%; display: inline-block; }
	.hm-cal-chip[aria-pressed=false] { opacity: .45; text-decoration: line-through; }
	.hm-cal-chip .cnt { font-weight: 400; color: #5f6b75; }
	#hmKpiCard .hm-kpis { margin: 4px 0 0; }
	#hmCalendar { font-size: 12px; min-width: 0; }
	/* 개인 할 일: 흰 바탕 보라 테두리(업무 일정과 구분), 완료는 회색 취소선 */
	#hmCalendar .fc-event.hm-my { font-weight: 700; }
	#hmCalendar .fc-event.hm-my.done { color: #9aa4ac !important; border-color: #cfd5da !important; text-decoration: line-through; }
	.hm-hover-tm { position: absolute; z-index: 1050; display: none; pointer-events: none; background: #333; color: #fff; font-size: 11px; font-weight: 700; padding: 1px 6px; border-radius: 4px; }
	#hmWeek ul { list-style: none; margin: 0; padding: 0; }
	#hmWeek li { display: flex; gap: 6px; align-items: flex-start; padding: 4px 0; border-bottom: 1px dashed rgba(17,17,17,.1); font-size: 12px; }
	#hmWeek li.day { color: #0b6e8a; font-weight: 700; font-size: 11.5px; border: 0; padding: 6px 0 0; }
	#hmWeek li.day.today::after { content: ' 오늘'; color: #b8860b; }
	#hmWeek li a { color: #111; } #hmWeek li.done a { color: #9aa4ac; text-decoration: line-through; }
	#hmWeek li small { display: block; color: #5f6b75; }
	#hmWeek li input[type=checkbox] { width: 16px; height: 16px; flex: none; cursor: pointer; accent-color: #5b3fa8; }
	#hmWeek .hm-empty { padding: 8px 0; }
	.hm-tk .form-row-x { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; }
	.hm-tk label.hm-dow { font-weight: 400; margin: 0 4px 0 0; }
	#hmCalendar .fc-toolbar { margin-bottom: 6px; } #hmCalendar .fc-toolbar h2 { font-size: 16px; }
	#hmCalendar .fc-event { cursor: pointer; font-size: 11px; line-height: 1.3; padding: 0 2px; }
	#hmCalendar .fc-day-grid .fc-row { min-height: 0 !important; }
	/* 일정이 꽉 차도 빈 곳을 눌러 할 일을 등록할 수 있게 칸 아래에 빈 줄을 남긴다(주·일의 종일 줄은 넉넉히) */
	#hmCalendar .fc-day-grid .fc-content-skeleton { padding-bottom: 14px; }
	#hmCalendar .fc-agenda-view .fc-day-grid .fc-content-skeleton { padding-bottom: 20px; }
	#hmCalendar .fc-day-number { font-size: 11px; padding: 1px 4px !important; }
	/* 업무 화면 상세 팝업을 홈 위에 그대로 띄우는 투명 틀(include_top 의 ?popup=1) */
	.hm-pop { position: fixed; top: 0; left: 0; width: 100%; height: 100%; border: 0; z-index: 1060; background: transparent; }
	.hm-pop-wait { position: fixed; inset: 0; z-index: 1059; background: rgba(0,0,0,.25); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 700; }
	@media (max-width: 991px) { .hm-money { grid-template-columns: 1fr; } }
	#hmWg .mv { border: 1px solid #ccd3d8; border-radius: 4px; background: #fff; padding: 0 5px; font-size: 10px; line-height: 16px; color: #5f6b75; }
	#hmWgBtn { display: none; }
	@media (max-width: 767px) {
		#hmWgTab { display: none !important; }
		#hmWgBtn { display: inline-block; margin-left: auto; }
		.hm-hello .ml-auto { margin-left: 0 !important; width: 100%; }
		#hmWg .mv, #hmWg .sz { min-width: 34px; min-height: 34px; font-size: 13px; }
		.hm-pk .m { grid-template-columns: repeat(8, 1fr); grid-auto-rows: 28px; gap: 4px; }
	}
</style>
<link rel="stylesheet" href="/resources/bo/plugins/fullcalendar/main.min.css">
<link rel="stylesheet" href="/resources/bo/plugins/fullcalendar-daygrid/main.min.css">
<link rel="stylesheet" href="/resources/bo/plugins/fullcalendar-timegrid/main.min.css">

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_open.jspf"%>
				<div class="card-body">
					<div class="hm-hello"><b><c:out value="${loginInfo.loginInfo[0].emplyNm}"/>님, 안녕하세요</b><span class="text-muted" id="hmToday"></span>
						<button type="button" class="btn btn-sm btn-outline-secondary" id="hmWgBtn" aria-controls="hmWg">⚙ 위젯</button>
						<span class="ml-auto text-muted">열 때 한 번 불러와요 · <a href="/admin/home.do">새로고침</a></span></div>
					<div class="hm-grid" id="hmCards">
						<div class="hm-card" id="hmKpiCard" data-key="KPI"><header>숫자 한눈에 보기</header><div class="hm-body"><div class="hm-kpis" id="hmKpis"></div></div></div>
						<div class="hm-card" id="hmTodoCard" data-key="TODO"><header>확인할 일 <span class="hm-pill" id="hmTodoCnt">…</span></header><div class="hm-body"><ul class="hm-todo" id="hmTodo"></ul></div></div>
					</div>
				</div>
			<%@ include file="/WEB-INF/jsp/bo/boinclude/page_close.jspf"%>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/page_script.jspf"%>
	<script src="/resources/bo/plugins/fullcalendar/main.min.js"></script>
	<script src="/resources/bo/plugins/fullcalendar-daygrid/main.min.js"></script>
	<script src="/resources/bo/plugins/fullcalendar-timegrid/main.min.js"></script>
	<script src="/resources/bo/plugins/fullcalendar-interaction/main.min.js"></script>
	<script src="/resources/bo/plugins/fullcalendar/locales/ko.js" charset="utf-8"></script>
	<script src="/resources/common/staff-vacation.js?v=20261126b"></script>
	<script>
	// 서버가 넣은 것: cards(열 수 있는 카드), journals(내 결재 차례), memos(최근 메모)
	var HOME = ${homeJson};
	var today = moment().startOf('day');
	var PHONE = window.matchMedia && matchMedia('(max-width: 767px)').matches;
	var URL = {
		staff: '/admin/staff/openStaffList.do', deploy: '/admin/deploy/openDeployList.do', intv: '/admin/hr/openInterviewList.do', trainee: '/admin/hr/openTraineeList.do',
		pay: '/admin/pay/openPayList.do', journal: '/admin/lab/openJournalList.do', eqp: '/admin/equipment/openEquipmentList.do', member: '/admin/member/memberList.do', lab: '/admin/lab/openLabManage.do'
	};
	function can(k) { return HOME.cards.indexOf(k) >= 0; }
	// 직원 이름은 직원관리 권한이 있으면 인사카드로, 없으면 투입현황으로
	function staffHref(sq) { return can('STAFF') ? URL.staff + '?STAFF_SQ=' + sq : URL.deploy; }
	function link(text, href, cls) { return $('<a>').attr('href', href).addClass(cls || 'hm-link').text(text); }
	function pill(text, tone) { return $('<span class="hm-pill">').addClass(tone || '').text(text); }

	// KPI 는 카드 순서대로 자리를 잡고, 데이터가 오면 채운다
	var kpiSlots = {};
	function kpiSlot(key) { return kpiSlots[key] = $('<a class="hm-kpi">').attr('href', '#').append($('<span>').text('…')).append('<b>…</b><small>&nbsp;</small>').appendTo('#hmKpis'); }
	function kpi(key, label, value, sub, href, tone) {
		kpiSlots[key].attr('href', href).removeClass('warn bad').addClass(tone || '').attr('aria-label', label + ' ' + value);
		kpiSlots[key].children('span').text(label); kpiSlots[key].children('b').text(value); kpiSlots[key].children('small').text(sub || ' ');
	}

	// 확인할 일. order 로 줄 순서를 고정한다(응답이 오는 순서와 무관)
	var todos = [], pending = 0;
	function todo(order, tag, tone, $text, href, go) { todos.push({ o: order, $li: $('<li>').append(pill(tag, tone)).append($text).append(link(go + ' ›', href, 'go')) }); }
	function paintTodo() {
		var $u = $('#hmTodo').empty();
		todos.sort(function(a, b) { return a.o - b.o; }).forEach(function(t) { $u.append(t.$li); });
		if (!todos.length && !pending) $u.append('<li class="hm-empty">오늘 확인할 일이 없습니다.</li>');
		$('#hmTodoCnt').text(pending ? '…' : todos.length).toggleClass('bad', todos.length > 0);
	}
	function card(key, title, href) {
		var $c = $('<div class="hm-card">').attr('data-key', key).append($('<header>').append(document.createTextNode(title)).append(href ? link(title + ' 열기 ›', href, '') : ''));
		var $b = $('<div class="hm-body">').append('<div class="hm-empty">불러오는 중…</div>').appendTo($c);
		$c.appendTo('#hmCards');
		return $b;
	}
	function table(head, rows) {
		var $t = $('<table class="table table-sm">').append($('<thead>').append($('<tr>').append(head.map(function(h) { return $('<th>').text(h); }))));
		var $b = $('<tbody>').appendTo($t);
		rows.forEach(function(r) { $b.append($('<tr>').append(r.map(function(c) { return $('<td>').append(c); }))); });
		return $t;
	}
	// 카드 하나의 데이터. 실패해도 다른 카드는 그린다
	function fetch(url, done) {
		pending++;
		$.post(url).done(function(res) { try { done(res); } catch (e) { console.error(e); } }).always(function() { pending--; paintTodo(); });
	}

	// 바로가기는 화면 탭으로 연다(대시보드가 탭 안에 있어도 맨 위 창의 탭). Ctrl·Shift·가운데 클릭은 브라우저 그대로
	function openTab(href, e) {
		var w = null;
		try { w = window.top.BO_OPEN ? window.top : null; } catch (x) {}
		if (!w || !href || href === '#' || e.button || e.ctrlKey || e.metaKey || e.shiftKey || e.altKey) return false;
		w.BO_OPEN(href);
		return true;
	}
	$(document).on('click', '#hmKpis a, #hmCards a', function(e) { if (openTab($(this).attr('href'), e)) e.preventDefault(); });

	// ── 일정 캘린더: 각 카드가 불러온 목록의 날짜를 모은다(그 화면 권한이 있는 일정만) ──
	var CAL_KIND = {
		INTV_NEW: ['신입면접', '#0b6e8a'], INTV_EXP: ['경력면접', '#d6336c'], DEPLOY_IN: ['투입', '#2f7d32'], DEPLOY_OUT: ['철수', '#c62828'], PROB: ['수습 해제', '#b8860b'],
		EDU: ['교육 시작', '#6b3fa0'], AVAIL: ['인터뷰', '#9c6ad6'], JOIN: ['입사', '#1565c0'], LEAVE: ['퇴사', '#78858f'],
		PAY: ['급여 지급', '#d35400'], RC_INTV: ['모집 인터뷰', '#e8590c'], RC_CLOSE: ['모집 마감', '#795548'], MY: ['내 할 일', '#8e6fd8'], VAC: ['휴가', '#2e9e6a']
	};
	// 카드(권한) → 그 카드가 넣는 일정 종류. 모두 우리 시스템에 등록된 정보(구글 캘린더 일정은 넣지 않는다)
	var CAL_SRC = { STAFF: ['JOIN', 'LEAVE', 'VAC'], DEPLOY: ['DEPLOY_IN', 'DEPLOY_OUT', 'PROB'], INTV: ['INTV_NEW', 'INTV_EXP'], TRAINEE: ['EDU', 'AVAIL'], PAY: ['PAY'], RECRUIT: ['RC_INTV', 'RC_CLOSE'] };
	var calEvents = [], calOff = {}, calendar = null, calTimer = null;
	function store(k, v) { try { if (v === undefined) return localStorage.getItem(k); localStorage.setItem(k, v); } catch (e) { return null; } }
	try { calOff = JSON.parse(store('hmCalOff') || '{}') || {}; } catch (e) { calOff = {}; }
	// date: yyyy-MM-dd(뒤는 무시), time: HH:mm 이면 시간 일정, info: 팝업에 보일 [[이름, 값]]
	// pop: 업무 화면의 상세 팝업 주소(그 화면이 주소로 상세를 여는 것: 인사카드 ?STAFF_SQ, 투입 ?open, 면접 ?INTV_SQ, 교육생 ?TRN_SQ, 모집 ?open). 없으면 홈 요약 팝업
	// last: 여러 날 일정의 마지막 날(yyyy-MM-dd, 그날 포함)
	function calAdd(kind, date, title, href, time, info, pop, last) {
		if (!date || !/^\d{4}-\d{2}-\d{2}/.test(date)) return;
		var t = /^\d{2}:\d{2}$/.test(time || '') ? time : null;
		var end = last && last > date.substr(0, 10) ? moment(last).add(1, 'days').format('YYYY-MM-DD') : null; // 달력의 끝은 다음 날(포함 안 함)
		calEvents.push({ kind: kind, start: date.substr(0, 10) + (t ? 'T' + t : ''), end: end, allDay: !t, name: title, title: CAL_KIND[kind][0] + ' ' + title, url: href, info: info || [], pop: pop || null });
		clearTimeout(calTimer);
		calTimer = setTimeout(calPaint, 50);
	}
	function calShown() { return calEvents.filter(function(e) { return !calOff[e.kind]; }); }
	function calPaint() {
		$('#hmCalChips .hm-cal-chip').each(function() {
			var k = $(this).data('k');
			$(this).attr('aria-pressed', !calOff[k]).find('.cnt').text(k === 'MY' ? tasks.length : calEvents.filter(function(e) { return e.kind === k; }).length);
		});
		if (!calendar) return;
		calendar.removeAllEvents();
		var evs = calShown().map(function(e) {
			return { title: e.title, start: e.start, end: e.end || undefined, allDay: e.allDay, editable: false, backgroundColor: CAL_KIND[e.kind][1], borderColor: CAL_KIND[e.kind][1], textColor: '#fff', extendedProps: { ev: e } };
		});
		if (!calOff.MY) {
			var v = calendar.view;
			myOccs(moment(v.activeStart), moment(v.activeEnd).subtract(1, 'days')).forEach(function(o) {
				var t = o.t, timed = t.ALL_DAY === 'N';
				evs.push({ title: (t.RPT_CD !== 'NONE' ? '↻ ' : '') + t.TITLE, allDay: !timed, editable: true,
					start: o.occ + (timed ? 'T' + t.START_TM : ''), end: timed ? o.end + 'T' + t.END_TM : moment(o.end).add(1, 'days').format('YYYY-MM-DD'),
					backgroundColor: '#fff', borderColor: CAL_KIND.MY[1], textColor: '#5b3fa8', classNames: o.done ? ['hm-my', 'done'] : ['hm-my'], extendedProps: { task: o } });
			});
		}
		calendar.addEventSource(evs);
	}

	// ── 개인 할 일(나만 보임). 반복 회차는 여기서 펼친다: 서버에는 규칙·회차별 완료(DONE_DTS)·빠진 날(SKIP_DTS)만 ──
	var tasks = HOME.tasks || [];
	function ymd(m) { return moment(m).format('YYYY-MM-DD'); }
	function csv(s) { return s ? String(s).split(',') : []; }
	// [from, to](날짜, 끝 포함)에 걸치는 회차들: { t, occ: 회차 시작일, end: 회차 끝날, len: 기간 일수-1, done }
	function myOccs(from, to) {
		var out = [];
		tasks.forEach(function(t) {
			var S = moment(t.START_DT), len = moment(t.END_DT).diff(S, 'days'), skip = csv(t.SKIP_DTS), until = t.RPT_UNTIL ? moment(t.RPT_UNTIL) : null, days = [];
			if (t.RPT_CD === 'NONE') { if (!S.isAfter(to) && !S.clone().add(len, 'days').isBefore(from)) days.push(S); }
			else for (var d = moment.max(S, from.clone().subtract(len, 'days')); !d.isAfter(to) && !(until && d.isAfter(until)); d.add(1, 'days')) {
				var hit = t.RPT_CD === 'DAY' || (t.RPT_CD === 'WEEK' && (t.RPT_DOW || '').indexOf(String(d.day())) >= 0) || (t.RPT_CD === 'MONTH' && d.date() === S.date());
				if (hit && skip.indexOf(ymd(d)) < 0) days.push(d.clone());
			}
			days.forEach(function(d) { out.push({ t: t, occ: ymd(d), end: ymd(d.clone().add(len, 'days')), len: len, done: csv(t.DONE_DTS).indexOf(ymd(d)) >= 0 }); });
		});
		return out;
	}
	// 서버 응답 {result}|{error}. 실패하면 알리고 reject
	function api(url, data) {
		var dfd = $.Deferred();
		$.post(url, data).done(function(r) { if (r && r.error) { bootbox.alert(r.error); dfd.reject(); } else dfd.resolve(r ? r.result : null); })
			.fail(function() { bootbox.alert('저장하지 못했습니다. 잠시 뒤 다시 시도해 주세요.'); dfd.reject(); });
		return dfd.promise();
	}
	function taskReload() { return api('/admin/my/taskListData.do').done(function(list) { tasks = list || []; calPaint(); weekList(); }); }
	function taskParams(t) {
		var p = {};
		['TASK_SQ', 'TITLE', 'START_DT', 'END_DT', 'ALL_DAY', 'START_TM', 'END_TM', 'MEMO', 'RPT_CD', 'RPT_DOW', 'RPT_UNTIL'].forEach(function(k) { p[k] = t[k] == null ? '' : t[k]; });
		return p;
	}
	// 반복 할 일을 고치거나 옮기거나 지울 때 범위(구글 캘린더와 같음)
	function askScope(title, done, cancel) {
		var $m = $('<div>').append([['ONE', '이 날만'], ['AFTER', '이 날부터 이후 모두'], ['ALL', '반복 전체']].map(function(s, i) {
			return $('<div class="form-check">').append($('<label class="form-check-label">').append($('<input type="radio" name="hmScope" class="form-check-input">').val(s[0]).prop('checked', !i)).append(' ' + s[1]));
		}));
		bootbox.dialog({ title: title, message: $m, size: 'small', onEscape: function() { if (cancel) cancel(); }, buttons: {
			cancel: { label: '취소', className: 'btn-sm btn-secondary', callback: function() { if (cancel) cancel(); } },
			ok: { label: '확인', className: 'btn-sm btn-primary', callback: function() { done($m.find('input:checked').val()); } } } });
	}
	// 회차 o 에 p(새 값)를 범위대로 저장. ONE: 그 회차를 빼고 따로 1건, AFTER: 원래 반복을 전날에 끝내고 새 반복, ALL: 원래 것을 같은 만큼 옮겨 고침
	function saveScope(o, p, scope) {
		var t = o.t;
		if (scope === 'AFTER' && o.occ === t.START_DT) scope = 'ALL';
		if (scope === 'ONE') {
			p.TASK_SQ = ''; p.RPT_CD = 'NONE';
			return api('/admin/my/markTaskData.do', { TASK_SQ: t.TASK_SQ, OCC: o.occ, act: 'SKIP' }).then(function() { return api('/admin/my/saveTaskData.do', p); });
		}
		if (scope === 'AFTER') {
			var old = taskParams(t);
			old.RPT_UNTIL = moment(o.occ).subtract(1, 'days').format('YYYY-MM-DD');
			p.TASK_SQ = '';
			return api('/admin/my/saveTaskData.do', old).then(function() { return api('/admin/my/saveTaskData.do', p); });
		}
		var shift = moment(p.START_DT).diff(moment(o.occ), 'days'), span = moment(p.END_DT).diff(moment(p.START_DT), 'days');
		p.TASK_SQ = t.TASK_SQ;
		p.START_DT = moment(t.START_DT).add(shift, 'days').format('YYYY-MM-DD');
		p.END_DT = moment(p.START_DT).add(span, 'days').format('YYYY-MM-DD');
		return api('/admin/my/saveTaskData.do', p);
	}
	function deleteScope(o, scope) {
		var t = o.t;
		if (scope === 'AFTER' && o.occ === t.START_DT) scope = 'ALL';
		if (scope === 'ONE') return api('/admin/my/markTaskData.do', { TASK_SQ: t.TASK_SQ, OCC: o.occ, act: 'SKIP' });
		if (scope === 'AFTER') { var old = taskParams(t); old.RPT_UNTIL = moment(o.occ).subtract(1, 'days').format('YYYY-MM-DD'); return api('/admin/my/saveTaskData.do', old); }
		return api('/admin/my/deleteTaskData.do', { TASK_SQ: t.TASK_SQ });
	}
	// 등록·수정 창. o: 고칠 회차(없으면 새로), sel: 새로 만들 때 끌어 고른 { START_DT, END_DT, ALL_DAY, START_TM, END_TM }
	function openTask(o, sel) {
		var t = o ? $.extend({}, o.t, { START_DT: o.occ, END_DT: o.end }) : $.extend({ RPT_CD: 'NONE', ALL_DAY: 'Y' }, sel);
		function inp(type, k) { return $('<input class="form-control form-control-sm">').attr({ type: type, name: k }).val(t[k] || ''); }
		function row(label, $c) { return $('<div class="form-group row mb-2">').append($('<label class="col-12 col-md-3 col-form-label col-form-label-sm">').text(label)).append($('<div class="col-12 col-md-9 form-row-x">').append($c)); }
		var $all = $('<label class="mb-0"><input type="checkbox" name="ALL_DAY"> 종일</label>');
		$all.find('input').prop('checked', t.ALL_DAY !== 'N');
		var $rpt = $('<select class="form-control form-control-sm" name="RPT_CD" style="width:auto">').append([['NONE', '반복 없음'], ['DAY', '매일'], ['WEEK', '매주'], ['MONTH', '매월 (같은 날)']].map(function(r) { return $('<option>').val(r[0]).text(r[1]); })).val(t.RPT_CD || 'NONE');
		var dow0 = t.RPT_DOW || String(moment(t.START_DT).day());
		var $dow = $('<span class="hm-dows">').append('일월화수목금토'.split('').map(function(c, i) {
			return $('<label class="hm-dow">').append($('<input type="checkbox">').val(i).prop('checked', dow0.indexOf(String(i)) >= 0)).append(' ' + c);
		}));
		var $f = $('<form class="hm-tk" autocomplete="off">').append(
			row('제목', inp('text', 'TITLE').attr({ maxlength: 100, required: true })),
			row('기간', [inp('date', 'START_DT').css('width', 'auto'), '~', inp('date', 'END_DT').css('width', 'auto'), $all]),
			row('시간', [inp('time', 'START_TM').css('width', 'auto'), '~', inp('time', 'END_TM').css('width', 'auto')]).addClass('hm-tm'),
			row('반복', [$rpt, $dow]),
			row('반복 끝', [inp('date', 'RPT_UNTIL').css('width', 'auto'), $('<small class="text-muted">').text('비우면 계속')]).addClass('hm-until'),
			row('메모', $('<textarea class="form-control form-control-sm" name="MEMO" rows="3" maxlength="2000">').val(t.MEMO || '')));
		function sync() {
			var allDay = $all.find('input').prop('checked'), r = $rpt.val();
			$f.find('.hm-tm').toggle(!allDay);
			$dow.toggle(r === 'WEEK');
			$f.find('.hm-until').toggle(r !== 'NONE');
		}
		$f.on('change', sync); sync();
		var rpt = o && o.t.RPT_CD !== 'NONE';
		var buttons = {};
		if (o) buttons.del = { label: '삭제', className: 'btn-sm btn-outline-danger mr-auto', callback: function() {
			if (rpt) askScope('반복 할 일 삭제', function(s) { deleteScope(o, s).always(taskReload); });
			else bootbox.confirm('이 할 일을 지울까요?', function(ok) { if (ok) deleteScope(o, 'ALL').always(taskReload); });
		} };
		// 완료는 이 회차만(반복 할 일도 다른 회차는 그대로)
		if (o) buttons.done = { label: o.done ? '완료 취소' : '✓ 완료', className: 'btn-sm btn-outline-success', callback: function() {
			api('/admin/my/markTaskData.do', { TASK_SQ: o.t.TASK_SQ, OCC: o.occ, act: o.done ? 'UNDONE' : 'DONE' }).always(taskReload);
		} };
		buttons.close = { label: '닫기', className: 'btn-sm btn-secondary' };
		buttons.save = { label: '저장', className: 'btn-sm btn-primary', callback: function() {
			var p = {};
			$f.serializeArray().forEach(function(x) { p[x.name] = x.value; });
			p.ALL_DAY = $all.find('input').prop('checked') ? 'Y' : 'N';
			p.RPT_DOW = $dow.find('input:checked').map(function() { return this.value; }).get().join('');
			if (!$.trim(p.TITLE)) { bootbox.alert('제목을 입력해 주세요.'); return false; }
			if (!p.END_DT) p.END_DT = p.START_DT;
			if (p.ALL_DAY === 'N' && (!p.START_TM || !p.END_TM)) { bootbox.alert('시작·끝 시간을 넣거나 종일을 켜 주세요.'); return false; }
			if (!o) api('/admin/my/saveTaskData.do', p).always(taskReload);
			else if (rpt) askScope('반복 할 일 수정', function(s) { saveScope(o, p, s).always(taskReload); });
			else { p.TASK_SQ = o.t.TASK_SQ; api('/admin/my/saveTaskData.do', p).always(taskReload); }
		} };
		bootbox.dialog({ title: o ? '할 일 수정' : '할 일 등록', message: $f, onEscape: true, buttons: buttons });
		setTimeout(function() { $f.find('[name=TITLE]').focus(); }, 300);
	}
	// 달력에서 끌어 옮기거나 끝을 늘였을 때
	function taskMoved(info) {
		var o = info.event.extendedProps.task, ev = info.event, s = moment(ev.start), e = ev.end ? moment(ev.end) : null, p = taskParams(o.t);
		p.ALL_DAY = ev.allDay ? 'Y' : 'N';
		p.START_DT = s.format('YYYY-MM-DD');
		if (ev.allDay) { p.END_DT = e ? e.clone().subtract(1, 'days').format('YYYY-MM-DD') : p.START_DT; p.START_TM = p.END_TM = ''; }
		else { e = e || s.clone().add(1, 'hours'); p.START_TM = s.format('HH:mm'); p.END_DT = e.format('YYYY-MM-DD'); p.END_TM = e.format('HH:mm'); }
		if (o.t.RPT_CD === 'NONE') { api('/admin/my/saveTaskData.do', p).fail(info.revert).done(taskReload); return; }
		askScope('반복 할 일 옮기기', function(sc) { saveScope(o, p, sc).fail(info.revert).always(taskReload); }, info.revert);
	}
	// 오른쪽 「이번 주 할 일」(달력이 보이는 주와 상관없이 이번 주 일~토). 기간 할 일은 이번 주에 걸친 첫날 아래 한 번
	function weekList() {
		var $w = $('#hmWeek');
		if (!$w.length) return;
		var from = today.clone().day(0), to = from.clone().add(6, 'days');
		var list = myOccs(from, to).map(function(o) { return $.extend({ day: moment.max(moment(o.occ), from) }, o); })
			.sort(function(a, b) { return (ymd(a.day) + (a.t.START_TM || '')).localeCompare(ymd(b.day) + (b.t.START_TM || '')); });
		$('#hmWeekCard .cnt').text(list.filter(function(o) { return o.done; }).length + ' / ' + list.length);
		var $u = $w.find('ul').empty(), last = null;
		if (!list.length) $u.append('<li class="hm-empty">이번 주 할 일이 없습니다. 달력 빈 칸을 누르거나 끌어서 등록해요.</li>');
		list.forEach(function(o) {
			if (ymd(o.day) !== last) { last = ymd(o.day); $u.append($('<li class="day">').toggleClass('today', o.day.isSame(today, 'day')).text(o.day.format('D') + ' (' + '일월화수목금토'.charAt(o.day.day()) + ')')); }
			var t = o.t, sub = [];
			if (t.ALL_DAY === 'N') sub.push(t.START_TM + '~' + t.END_TM);
			if (o.len) {
				var n = o.len + 1, m = today.diff(moment(o.occ), 'days') + 1;
				sub.push(moment(o.occ).format('M/D') + ' ~ ' + moment(o.end).format('M/D') + ' · ' + (m >= 1 && m <= n ? n + '일 중 ' + m + '일째' : n + '일'));
			}
			if (t.RPT_CD !== 'NONE') sub.push('반복');
			if (t.MEMO) sub.push('메모 있음');
			$u.append($('<li>').toggleClass('done', o.done).append(
				$('<input type="checkbox" class="mt-1">').attr('aria-label', t.TITLE + ' 완료').prop('checked', o.done).on('change', function() {
					api('/admin/my/markTaskData.do', { TASK_SQ: t.TASK_SQ, OCC: o.occ, act: this.checked ? 'DONE' : 'UNDONE' }).always(taskReload);
				}),
				$('<span>').append($('<a href="#">').text(t.TITLE).on('click', function(e) { e.preventDefault(); openTask(o); })).append(sub.length ? $('<small>').text(sub.join(' · ')) : '')));
		});
	}
	function dayText(d) { return moment(d).format('M월 D일') + ' (' + '일월화수목금토'.charAt(moment(d).day()) + ')'; }
	// 일정 팝업: 업무 화면의 상세 팝업을 홈 위에 그대로 띄운다(그 화면을 ?embed=1&popup=1 로 투명하게 열어 팝업만 보이게).
	// 그 화면에서 상세를 못 찾으면(기간 밖 등) 홈 요약 팝업으로 대신한다
	function calPop(e) {
		if (!e.pop) return calSummary(e);
		var $wait = $('<div class="hm-pop-wait" role="status">불러오는 중…</div>').appendTo('body');
		var $f = $('<iframe class="hm-pop" title="상세">').attr('src', e.pop + (e.pop.indexOf('?') < 0 ? '?' : '&') + 'embed=1&popup=1').appendTo('body');
		function done() { $(window).off('message.hmpop'); $f.remove(); $wait.remove(); }
		$(window).on('message.hmpop', function(m) {
			var d = m.originalEvent.data, src = m.originalEvent.source;
			if (!d || !d.boPopup || src !== $f[0].contentWindow) return;
			if (d.boPopup === 'open') { $wait.remove(); $f[0].focus(); }
			else if (d.boPopup === 'close') done();
			else if (d.boPopup === 'empty') { done(); calSummary(e); }
		});
	}
	function calSummary(e) {
		var $t = $('<table class="table table-sm mb-0">');
		[['종류', CAL_KIND[e.kind][0]], ['일시', dayText(e.start) + (e.allDay ? '' : ' ' + e.start.substr(11, 5))]].concat(e.info).forEach(function(r) {
			if (r[1]) $t.append($('<tr>').append($('<th style="width:90px">').text(r[0])).append($('<td>').text(r[1])));
		});
		bootbox.dialog({ title: e.title, message: $t, onEscape: true, backdrop: true, buttons: {
			open: { label: '화면에서 열기', className: 'btn-sm btn-outline-primary', callback: function() { if (e.url && !openTab(e.url, {})) location.href = e.url; } },
			close: { label: '닫기', className: 'btn-sm btn-secondary' } } });
	}
	function calCard() {
		var kinds = ['MY']; // 내 할 일은 누구나
		Object.keys(CAL_SRC).forEach(function(k) { if (can(k)) kinds = kinds.concat(CAL_SRC[k]); });
		var $chips = $('<div class="hm-cal-chips" id="hmCalChips">');
		kinds.forEach(function(k) {
			$chips.append($('<button type="button" class="hm-cal-chip">').data('k', k).attr('title', '눌러서 ' + CAL_KIND[k][0] + ' 일정 끄기·켜기')
				.append($('<i>').css('background', CAL_KIND[k][1])).append(document.createTextNode(CAL_KIND[k][0] + ' ')).append('<span class="cnt">…</span>')
				.on('click', function() { calOff[k] = !calOff[k]; store('hmCalOff', JSON.stringify(calOff)); calPaint(); }));
		});
		var $el = $('<div id="hmCalendar">');
		var $add = $('<button type="button" class="btn btn-sm btn-outline-secondary py-0 ml-auto" id="hmTaskAdd">＋ 할 일</button>').on('click', function() { openTask(null, { START_DT: today.format('YYYY-MM-DD'), END_DT: today.format('YYYY-MM-DD') }); });
		// 직원관리 권한이 있으면 직원을 골라 휴가 등록(인사카드 휴가 탭과 같은 창)
		var $vac = can('STAFF') ? $('<button type="button" class="btn btn-sm btn-outline-success py-0 ml-1" id="hmVacAdd">＋ 휴가</button>').on('click', function() { vacForm({ saved: vacLoad }); }) : null;
		var $c = $('<div class="hm-card" id="hmCalCard" data-key="CAL">').append($('<header>').text('📅 일정').append($add).append($vac))
			.append($('<div class="hm-body">').append($chips).append($el));
		// 이번 주 할 일은 따로 위젯(달력을 작게 해도 안 깨지게)
		var $week = $('<div class="hm-card" id="hmWeekCard" data-key="WEEK">').append($('<header>').append('이번 주 할 일 ').append('<span class="hm-pill cnt">…</span>'))
			.append($('<div class="hm-body" id="hmWeek">').append('<ul>'));
		$('#hmCards').prepend($c, $week);
		calendar = new FullCalendar.Calendar($el[0], {
			plugins: ['dayGrid', 'timeGrid', 'interaction'], selectable: true, editable: false,
			// 빈 칸을 누르거나 끌어 고르면 할 일 등록(여러 날·시간대), 내 할 일만 끌어 옮기고 끝을 늘인다
			select: function(i) {
				var s = moment(i.start), e = moment(i.end);
				calendar.unselect();
				if (i.allDay) openTask(null, { START_DT: s.format('YYYY-MM-DD'), END_DT: e.subtract(1, 'days').format('YYYY-MM-DD'), ALL_DAY: 'Y' });
				else openTask(null, { START_DT: s.format('YYYY-MM-DD'), END_DT: e.format('YYYY-MM-DD'), ALL_DAY: 'N', START_TM: s.format('HH:mm'), END_TM: e.format('HH:mm') });
			},
			eventDrop: taskMoved, eventResize: taskMoved,
			locales: window.FullCalendarLocales ? [FullCalendarLocales.ko] : [], locale: 'ko',
			// 폰: list 플러그인이 없어 월 보기 고정, 주·일 버튼은 뺀다
			// 변경 반영으로 다시 읽었으면 보던 날짜에서 연다
			defaultDate: (function() { try { var d = sessionStorage.getItem('hmCalDate'); sessionStorage.removeItem('hmCalDate'); return d || undefined; } catch (x) { return undefined; } })(),
			defaultView: !PHONE && ['dayGridMonth', 'timeGridWeek', 'timeGridDay'].indexOf(store('hmCalView')) >= 0 ? store('hmCalView') : 'dayGridMonth',
			header: PHONE ? { left: 'prev,next', center: 'title', right: 'today' } : { left: 'prev,next today', center: 'title', right: 'dayGridMonth,timeGridWeek,timeGridDay' },
			buttonText: { today: '오늘', month: '월', week: '주', day: '일' },
			height: 'auto', nowIndicator: true, minTime: '08:00:00', maxTime: '20:00:00', slotDuration: '01:00:00', snapDuration: '00:30:00',
			// 월 보기 행 높이를 폭에 비례해 강제하지 않게(일정 수만큼만, 빈 주는 날짜 숫자 줄만): monthMode 는 auto 여도 폭÷aspectRatio 를 6주로 나눠 넣는다
			aspectRatio: 50,
			datesRender: function(info) { if (!PHONE) store('hmCalView', info.view.type); /* 폰은 월 고정이라 PC 에서 고른 보기를 덮지 않는다 */ clearTimeout(calTimer); calTimer = setTimeout(calPaint, 0); },
			eventClick: function(info) {
				info.jsEvent.preventDefault();
				if (info.event.extendedProps.task) openTask(info.event.extendedProps.task); else calPop(info.event.extendedProps.ev);
			}
		});
		calendar.render();
		calPaint();
		weekList();
		// 주·일 보기: 마우스 자리의 시:분을 커서 옆에(끌어 고르기와 같은 30분 단위, 08~20시)
		var $tip = $('<div class="hm-hover-tm" aria-hidden="true">').appendTo('body');
		$el.on('mousemove', '.fc-time-grid', function(e) {
			var r = $(this).find('.fc-slats')[0].getBoundingClientRect(), f = (e.clientY - r.top) / r.height;
			if (f < 0 || f >= 1) return $tip.hide();
			var m = 8 * 60 + Math.floor(f * 12 * 2) * 30;
			$tip.text(('0' + Math.floor(m / 60)).slice(-2) + ':' + ('0' + m % 60).slice(-2)).css({ left: e.pageX + 14, top: e.pageY + 10 }).show();
		}).on('mouseleave', '.fc-time-grid', function() { $tip.hide(); });
		if (can('RECRUIT')) {
			fetch('/admin/recruit/listData.do', function(res) {
				var d = res.result || {}, rc = {};
				(d.recruits || []).forEach(function(r) {
					rc[r.RECRUIT_SQ] = r;
					if (r.STATUS_CD !== 'CLOSED') calAdd('RC_CLOSE', r.CLOSE_DT, r.CLIENT_NM || '모집', '/admin/recruit/openRecruitList.do?open=' + r.RECRUIT_SQ, null, [['사업', r.PRJ_NM], ['등급·인원', r.GRADE_TXT]], '/admin/recruit/openRecruitList.do?open=' + r.RECRUIT_SQ);
				});
				(d.applies || []).forEach(function(a) {
					var r = rc[a.RECRUIT_SQ] || {};
					if (['INTV', 'INTV_SUB', 'INTV_CHK'].indexOf(a.STEP_CD) >= 0 && a.INTV_DT) calAdd('RC_INTV', a.INTV_DT, a.STAFF_NM + ' · ' + (r.CLIENT_NM || ''), '/admin/recruit/openRecruitList.do?open=' + a.RECRUIT_SQ, a.INTV_DT.substr(11, 5), [['장소', a.INTV_PLACE], ['사업', r.PRJ_NM]], '/admin/recruit/openRecruitList.do?open=' + a.RECRUIT_SQ);
				});
			});
		}
	}

	// ── 위젯 배치(스마트폰 홈처럼): 홈은 가로 8칸 × 세로 칸, 위젯마다 가로×세로 크기·보이기·순서.
	//    오른쪽 가운데 「위젯」 메뉴에서만 바꾸고 바뀌면 바로 내 계정에 저장(목록 '보기' 저장 표를 홈 주소로 1건). 초기화는 그 1건을 지운다 ──
	var COLS = 8, ROWS = 8;
	// 기본 순서·크기[가로, 세로]·최소 크기(이보다 작으면 내용이 깨진다)
	var WG = {
		CAL: { nm: '📅 일정', size: [6, 7], min: [4, 5] }, WEEK: { nm: '이번 주 할 일', size: [2, 7], min: [1, 2] },
		KPI: { nm: '숫자 한눈에 보기', size: [8, 2], min: [1, 2] }, UPD: { nm: '🔔 최근 업데이트', size: [8, 3], min: [2, 2] },
		TODO: { nm: '확인할 일', size: [4, 3], min: [1, 2] }, DEPLOY: { nm: '철수 임박·대기', size: [4, 4], min: [2, 2] },
		INTV: { nm: '이번 주 면접', size: [4, 4], min: [2, 2] }, TRAINEE: { nm: '교육생 주차별', size: [4, 3], min: [1, 2] },
		PAY: { nm: '급여', size: [4, 2], min: [2, 2] }, MEMO: { nm: '최근 메모', size: [8, 4], min: [2, 2] }
	};
	var LAYOUT_ORDER = Object.keys(WG);
	var layoutSq = HOME.layout ? HOME.layout.VW_SQ : null, layoutSaved = {};
	try { layoutSaved = HOME.layout ? JSON.parse(HOME.layout.CONF) || {} : {}; } catch (e) { layoutSaved = {}; }
	function cards() { return $('#hmCards').children('.hm-card'); }
	function wg(k) { return WG[k] || { nm: k, size: [4, 3], min: [1, 2] }; }
	function sizeOf($c) { return [+$c.attr('data-w'), +$c.attr('data-h')]; }
	function sizeSet($c, s) {
		var m = wg($c.attr('data-key')).min;
		var w = Math.min(COLS, Math.max(m[0], +s[0] || 4)), h = Math.min(ROWS, Math.max(m[1], +s[1] || 3));
		$c.attr({ 'data-w': w, 'data-h': h }).css({ '--w': w, '--h': h });
	}
	function layoutNow() {
		var c = { v: 2, order: [], size: {}, off: {} };
		cards().each(function() { var k = $(this).attr('data-key'); c.order.push(k); c.size[k] = sizeOf($(this)); if ($(this).hasClass('hm-off')) c.off[k] = true; });
		return c;
	}
	function layoutApply(c) {
		c = c || {};
		var by = {};
		cards().each(function() { by[$(this).attr('data-key')] = $(this); });
		(c.order || []).concat(LAYOUT_ORDER).forEach(function(k) { if (by[k]) { $('#hmCards').append(by[k]); delete by[k]; } });
		cards().each(function() {
			var $c = $(this), k = $c.attr('data-key'), s = c.size && c.size[k];
			// 예전 저장(4칸 중 span, 넓게/좁게)은 가로 ×2 로 읽고 세로는 기본값
			if (!s && c.span && k in c.span) s = [c.span[k] * 2, wg(k).size[1]];
			if (!s && c.wide && k in c.wide) s = [c.wide[k] ? 8 : 4, wg(k).size[1]];
			sizeSet($c, s || wg(k).size);
			$c.toggleClass('hm-off', !!(c.off && c.off[k]));
		});
		if (calendar) calendar.updateSize();
	}
	// 연달아 저장해도 앞 저장이 받은 VW_SQ 로 덮어쓰게 한 줄로 보낸다(처음 두 번이 둘 다 새 건이 되면 같은 이름 오류)
	var layoutQ = $.Deferred().resolve().promise();
	function layoutSave(c) {
		function run() {
			return api('/admin/my/saveViewPresetData.do', { page: '/admin/home.do', vwSq: layoutSq || '', nm: '홈 배치', conf: JSON.stringify(c) }).done(function(sq) {
				if (sq && typeof sq !== 'object') layoutSq = sq;
				layoutSaved = c;
			});
		}
		return layoutQ = layoutQ.then(run, run);
	}
	function layoutChanged() { if (calendar) calendar.updateSize(); layoutSave(layoutNow()); }

	// 위젯 메뉴: 한 줄 = ⠿⠿(끌기·↑↓) · 보이기 체크 · 이름 · 크기 칩(누르면 칸 격자를 훑어 고름)
	function wgMenu() {
		var $u = $('#hmWg ul').empty();
		cards().each(function() {
			var $c = $(this), k = $c.attr('data-key'), s = sizeOf($c), id = 'hmWgOn' + k;
			$u.append($('<li class="wg" draggable="true">').attr('data-key', k).toggleClass('off', $c.hasClass('hm-off')).append(
				$('<span class="g" tabindex="0" role="button" title="끌어서 순서 바꾸기 (↑↓ 키로도)">⠿⠿</span>').attr('aria-label', wg(k).nm + ' 순서 옮기기'),
				$('<input type="checkbox">').attr({ id: id, title: '홈에 보이기' }).prop('checked', !$c.hasClass('hm-off')),
				$('<label class="nm">').attr('for', id).text(wg(k).nm),
				$('<button type="button" class="mv" data-d="-1">▲</button>').attr('aria-label', wg(k).nm + ' 위로'),
				$('<button type="button" class="mv" data-d="1">▼</button>').attr('aria-label', wg(k).nm + ' 아래로'),
				$('<button type="button" class="sz" aria-expanded="false">').attr('aria-label', wg(k).nm + ' 크기 ' + s[0] + '×' + s[1] + ' 바꾸기').text(s[0] + '×' + s[1])));
		});
	}
	function wgPicker($li) {
		var k = $li.attr('data-key'), $c = cards().filter('[data-key="' + k + '"]'), m = wg(k).min, now = sizeOf($c);
		var $t = $('<b>').text(now[0] + ' × ' + now[1]), $m = $('<div class="m">');
		function paint(w, h) { $m.children().each(function() { var x = $(this).data('x'), y = $(this).data('y'); $(this).toggleClass('on', x <= w && y <= h).toggleClass('min', x <= m[0] && y <= m[1]); }); $t.text(w + ' × ' + h); }
		for (var y = 1; y <= ROWS; y++) for (var x = 1; x <= COLS; x++) {
			$m.append($('<button type="button">').data({ x: x, y: y }).attr('aria-label', x + ' × ' + y));
		}
		$m.on('mouseover focusin', 'button', function() { paint(Math.max(m[0], $(this).data('x')), Math.max(m[1], $(this).data('y'))); })
			.on('mouseleave', function() { var s = sizeOf($c); paint(s[0], s[1]); })
			.on('click', 'button', function() {
				sizeSet($c, [$(this).data('x'), $(this).data('y')]);
				layoutChanged();
				var s = sizeOf($c);
				$li.find('.sz').text(s[0] + '×' + s[1]);
				paint(s[0], s[1]);
			});
		paint(now[0], now[1]);
		return $('<li class="pk">').append($('<div class="hm-pk">').append($('<div class="t">').append('<span>칸을 훑어 크기 고르기 (가로 × 세로)</span>', $t), $m,
			$('<div class="small text-muted mt-1">').text('가로 1~' + COLS + ' · 세로 1~' + ROWS + ' · 이 위젯 최소 ' + m[0] + '×' + m[1] + ' (연한 칸)')));
	}
	function widgetsInit() {
		if (!$('#hmKpis').children().length) $('#hmKpiCard').remove(); // 숫자 카드 권한이 하나도 없으면
		layoutApply(layoutSaved);
		var $tab = $('<button type="button" id="hmWgTab" aria-controls="hmWg" aria-expanded="false" title="위젯 배치">⚙ 위젯</button>').appendTo('body');
		var $p = $('<div id="hmWg" role="dialog" aria-label="위젯 배치">').append(
			$('<header>').append('<span>⚙ 위젯 배치</span>', $('<button type="button" aria-label="닫기">×</button>').on('click', function() { open(false); })),
			'<ul>',
			$('<footer>').append($('<button type="button" class="btn btn-sm btn-outline-danger py-0">↺ 초기화</button>').on('click', reset), '<span class="ml-auto">바꾸면 바로 저장돼요</span>')).appendTo('body');
		function open(on) {
			if (on) wgMenu();
			$p.toggleClass('open', on); $tab.attr('aria-expanded', on).toggle(!on);
			if (on) $p.find('ul .g').first().focus(); else $tab.focus();
		}
		function reset() {
			bootbox.confirm('홈 배치를 처음 상태(모두 보이기, 기본 순서·크기)로 되돌릴까요?', function(ok) {
				if (!ok) return;
				(layoutSq ? api('/admin/my/deleteViewPresetData.do', { page: '/admin/home.do', vwSq: layoutSq }) : $.Deferred().resolve().promise()).done(function() {
					layoutSq = null; layoutSaved = {};
					layoutApply({}); wgMenu();
				});
			});
		}
		$tab.on('click', function() { open(true); });
		$('#hmWgBtn').on('click', function() { open(!$p.hasClass('open')); });
		$(document).on('keydown', function(e) { if (e.key === 'Escape' && $p.hasClass('open') && !$('.modal.show').length) open(false); });
		$(document).on('mousedown', function(e) { if ($p.hasClass('open') && !$(e.target).closest('#hmWg, #hmWgTab, #hmWgBtn, .modal, .bootbox').length) open(false); });
		var $u = $p.find('ul'), drag = null;
		function card(k) { return cards().filter('[data-key="' + k + '"]'); }
		// 메뉴 순서 = 홈 순서
		function syncOrder() { $u.children('li.wg').each(function() { $('#hmCards').append(card($(this).attr('data-key'))); }); layoutChanged(); }
		$u.on('change', 'input[type=checkbox]', function() {
			var $li = $(this).closest('li');
			card($li.attr('data-key')).toggleClass('hm-off', !this.checked);
			$li.toggleClass('off', !this.checked);
			layoutChanged();
		});
		$u.on('click', '.sz', function() {
			var $li = $(this).closest('li'), was = $(this).attr('aria-expanded') === 'true';
			$u.children('li.pk').remove(); $u.find('.sz').attr('aria-expanded', false);
			if (!was) { $li.after(wgPicker($li)); $(this).attr('aria-expanded', true); }
		});
		$u.on('dragstart', 'li.wg', function(e) { $u.children('li.pk').remove(); $u.find('.sz').attr('aria-expanded', false); drag = $(this).addClass('drag'); e.originalEvent.dataTransfer.effectAllowed = 'move'; e.originalEvent.dataTransfer.setData('text/plain', 'hm-wg'); });
		$u.on('dragover', 'li.wg', function(e) {
			if (!drag || drag.is(this)) return;
			e.preventDefault();
			if (drag.index() < $(this).index()) $(this).after(drag); else $(this).before(drag);
		});
		$u.on('drop', function(e) { if (drag) e.preventDefault(); });
		$u.on('dragend', 'li.wg', function() { if (drag) { drag.removeClass('drag'); drag = null; syncOrder(); } });
		$u.on('keydown', '.g', function(e) {
			var $li = $(this).closest('li');
			$u.children('li.pk').remove(); $u.find('.sz').attr('aria-expanded', false);
			if (e.key === 'ArrowUp' && $li.prev().length) $li.prev().before($li); else if (e.key === 'ArrowDown' && $li.next().length) $li.next().after($li); else return;
			e.preventDefault(); $(this).focus(); syncOrder();
		});
		// ▲▼: 끌기·키 없이(폰) 한 칸씩 옮긴다
		$u.on('click', '.mv', function() {
			var $li = $(this).closest('li'), up = $(this).attr('data-d') === '-1';
			$u.children('li.pk').remove(); $u.find('.sz').attr('aria-expanded', false);
			if (up && $li.prev('li.wg').length) $li.prev().before($li); else if (!up && $li.next('li.wg').length) $li.next().after($li); else return;
			$(this).focus(); syncOrder();
		});
	}

	$(function() {
		$('#hmToday').text(today.format('YYYY년 M월 D일') + ' (' + '일월화수목금토'.charAt(today.day()) + ')');
		if (can('STAFF')) staffCard();
		if (can('DEPLOY')) deployCard();
		if (can('INTV')) interviewCard();
		if (can('TRAINEE')) traineeCard();
		if (can('PAY')) payCard();
		if (can('JOURNAL')) journalTodo();
		if (can('EQP')) equipmentTodo();
		if (can('MEMBER')) memberTodo();
		if (HOME.memos.length) memoCard();
		updateCard();
		calCard();
		widgetsInit();
		paintTodo();
	});
	// 홈 위 팝업이나 다른 탭에서 저장·삭제하면(include_bottom 이 boChangedAt 을 남김) 다시 읽는다.
	// 팝업·확인창이 열려 있거나 홈이 가려져 있으면(탭 전환·창 최소화) 닫히거나 보일 때까지 기다리고, 보던 달력 날짜는 그대로
	var stale = false;
	window.addEventListener('storage', function(e) { if (e.key === 'boChangedAt') stale = true; });
	setInterval(function() {
		if (!stale || document.hidden || !window.innerWidth || $('.hm-pop, .modal.show').length) return;
		try { if (calendar) sessionStorage.setItem('hmCalDate', moment(calendar.getDate()).format('YYYY-MM-DD')); } catch (x) {}
		location.reload();
	}, 1000);

	// 최근 주요 업데이트 5건(모든 관리자, 자잘한 수정은 업데이트 내역 화면에서). 줄을 누르면 상세 팝업, 피드백 반영이면 요청자 표시
	function updateCard() {
		var $c = $('<div class="hm-card wide" id="hmUpdCard" data-key="UPD">').append($('<header>').text('🔔 주요 업데이트').append(link('전체 보기 ›', '/admin/update/openUpdateList.do', '')));
		var $b = $('<div class="hm-body">').appendTo($c);
		$c.prependTo('#hmCards');
		if (!HOME.updates.length) { $b.append('<div class="hm-empty">아직 주요 업데이트가 없습니다.</div>'); return; }
		$b.append(table(['배포일', '분류', '내용', '화면', '피드백'], HOME.updates.map(function(u) {
			return [u.DEPLOY_DT.substr(5), BO_FB.updPill(u.KIND_CD), $('<a href="#" class="hm-link">').text(u.TITLE).on('click', function(e) { e.preventDefault(); e.stopPropagation(); BO_UPDATE(u.UPD_SQ); }),
				u.SCREENS || '', u.FB_SQ ? pill('💬 ' + (u.FB_EMPLY_NM || '요청'), 'warn') : ''];
		})));
	}

	function staffCard() {
		kpiSlot('staff');
		fetch('/admin/staff/staffListData.do', function(res) {
			var work = (res.list || []).filter(function(r) { return r.STATUS_CD === 'WORK'; });
			var reg = work.filter(function(r) { return r.ORG_NM === '정규직'; }).length, free = work.filter(function(r) { return r.ORG_NM === '프리'; }).length;
			kpi('staff', '재직 인원', work.length, '정규직 ' + reg + ' · 프리 ' + free, URL.staff);
			(res.list || []).forEach(function(r) {
				var info = [['소속', r.ORG_NM], ['부서', r.DEPT_NM], ['직급', r.POSITION_NM], ['입사일', r.JOIN_DT], ['퇴사일', r.LEAVE_DT]];
				var sp = can('STAFF') ? URL.staff + '?STAFF_SQ=' + r.STAFF_SQ : null; // 인사카드 팝업
				calAdd('JOIN', r.JOIN_DT, r.STAFF_NM, staffHref(r.STAFF_SQ), null, info, sp);
				calAdd('LEAVE', r.LEAVE_DT, r.STAFF_NM, staffHref(r.STAFF_SQ), null, info, sp);
			});
		});
		vacLoad();
	}
	// 휴가 일정(앞뒤 1년). 등록·수정 뒤에는 휴가만 다시 불러온다. 기간 미정은 오늘까지
	function vacLoad() {
		calEvents = calEvents.filter(function(e) { return e.kind !== 'VAC'; });
		$.post('/admin/staff/vacationRangeData.do', { FROM: moment().subtract(1, 'years').format('YYYY-MM-DD'), TO: moment().add(1, 'years').format('YYYY-MM-DD') }).done(function(res) {
			(res.list || []).forEach(function(v) {
				var info = [['직원', v.STAFF_NM + (v.ORG_NM ? ' · ' + v.ORG_NM : '')], ['기간', vacPeriod(v)], ['종류', vacTypeName(v.VAC_CD)], ['구분', v.PAID_YN === 'Y' ? '유급' : '무급'], ['메모', v.MEMO]];
				calAdd('VAC', v.START_DT, v.STAFF_NM + ' ' + vacTypeName(v.VAC_CD) + (v.PAID_YN === 'Y' ? '' : '(무급)'), staffHref(v.STAFF_SQ), null, info,
					URL.staff + '?STAFF_SQ=' + v.STAFF_SQ, v.END_DT || today.format('YYYY-MM-DD'));
			});
			calPaint();
		});
	}

	// 투입현황 화면(deploy_list.jsp)의 투입·대기·철수 임박 기준과 같다
	function deployCard() {
		kpiSlot('active'); kpiSlot('idle');
		var $b = card('DEPLOY', '철수 임박·대기', URL.deploy);
		fetch('/admin/deploy/deployListData.do', function(res) {
			var d = res.data;
			var empType = hrCodeMap('HR_EMP_TYPE');
			d.all.forEach(function(x) {
				var who = x.STAFF_NM + (x.CLIENT_NM ? ' (' + x.CLIENT_NM + ')' : '');
				var info = [['고객사', x.CLIENT_NM], ['프로젝트', x.PRJ_NM], ['형태', empType[x.EMP_TYPE_CD] || x.EMP_TYPE_CD], ['근무지역', x.WORK_AREA],
					['투입기간', (x.START_DT || '') + ' ~ ' + (x.END_DT || '미정')], ['수습해제일', x.PROB_END_DT]];
				var dp = URL.deploy + '?open=' + x.DEPLOY_SQ; // 투입 상세 팝업
				calAdd('DEPLOY_IN', x.START_DT, who, staffHref(x.STAFF_SQ), null, info, dp);
				calAdd('DEPLOY_OUT', x.END_DT, who, staffHref(x.STAFF_SQ), null, info, dp);
				if (x.EMP_TYPE_CD === 'PROBATION') calAdd('PROB', x.PROB_END_DT, x.STAFF_NM, staffHref(x.STAFF_SQ), null, info, dp);
			});
			function deps(sq) { return d.all.filter(function(x) { return x.STAFF_SQ === sq; }); }
			function active(x) { return !moment(x.START_DT).isAfter(today) && (!x.END_DT || !moment(x.END_DT).isBefore(today)); }
			var activeCnt = d.current.filter(function(r) { return r.STATE === 'ACTIVE'; }).length;
			var idle = d.staff.map(function(s) {
				var ds = deps(s.STAFF_SQ);
				if (ds.some(active)) return null;
				var last = ds[ds.length - 1];
				if (last && /^EXTERNAL/.test(last.EMP_TYPE_CD)) return null;
				var future = ds.filter(function(x) { return moment(x.START_DT).isAfter(today); })[0];
				var past = ds.filter(function(x) { return x.END_DT && moment(x.END_DT).isBefore(today); }).pop();
				var since = past ? moment(past.END_DT).add(1, 'days') : moment(s.JOIN_DT, 'YYYY-MM-DD', true);
				return { s: s, future: future, days: since.isValid() ? today.diff(since, 'days') : 0 };
			}).filter(Boolean);
			var waiting = idle.filter(function(i) { return !i.future; }).sort(function(a, b) { return b.days - a.days; });
			var limit = moment().add(1, 'month').endOf('month');
			var ending = d.all.filter(function(x) { return active(x) && x.END_DT && !moment(x.END_DT).isAfter(limit); }).sort(function(a, b) { return a.END_DT.localeCompare(b.END_DT); });
			var soon = ending.filter(function(x) { return moment(x.END_DT).diff(today, 'days') <= 14; });
			var prob = d.all.filter(function(x) { return x.EMP_TYPE_CD === 'PROBATION' && x.PROB_END_DT && active(x) && moment(x.PROB_END_DT).diff(today, 'days') >= 0 && moment(x.PROB_END_DT).diff(today, 'days') <= 30; });

			kpi('active', '투입 중', activeCnt, '철수 임박 ' + ending.length, URL.deploy);
			kpi('idle', '대기', waiting.length, waiting.length ? '최장 대기 ' + waiting[0].days + '일' : '대기 없음', URL.deploy + '?page=IDLE', waiting.length ? 'warn' : '');
			if (soon.length) todo(2, '철수 임박', 'bad', $('<span>').append(soon.slice(0, 4).map(function(x, i) {
				return $('<span>').append(i ? ', ' : '').append(link(x.STAFF_NM, staffHref(x.STAFF_SQ))).append(' D-' + moment(x.END_DT).diff(today, 'days') + (x.CLIENT_NM ? ' (' + x.CLIENT_NM + ')' : ''));
			})).append(soon.length > 4 ? ' 외 ' + (soon.length - 4) + '명' : ''), URL.deploy + '?page=ENDING', '투입현황 · 철수 임박');
			if (prob.length) todo(3, '수습 해제', 'rent', $('<span>').append(prob.map(function(x, i) {
				return $('<span>').append(i ? ', ' : '').append(link(x.STAFF_NM, staffHref(x.STAFF_SQ))).append(' 수습(D-' + moment(x.PROB_END_DT).diff(today, 'days') + ')');
			})), URL.deploy, '투입현황');

			var rows = ending.slice(0, 5).map(function(x) {
				var n = moment(x.END_DT).diff(today, 'days');
				return [link(x.STAFF_NM, staffHref(x.STAFF_SQ)), x.CLIENT_NM || '', '철수 ' + moment(x.END_DT).format('MM-DD'), pill('D-' + n, n <= 14 ? 'bad' : 'warn')];
			}).concat(waiting.slice(0, 5).map(function(i) {
				return [link(i.s.STAFF_NM, staffHref(i.s.STAFF_SQ)), '—', '대기', pill('대기 ' + i.days + '일', 'warn')];
			})).concat(idle.filter(function(i) { return i.future; }).slice(0, 3).map(function(i) {
				return [link(i.s.STAFF_NM, staffHref(i.s.STAFF_SQ)), i.future.CLIENT_NM || '', moment(i.future.START_DT).format('MM-DD') + ' 투입 예정', pill(moment(i.future.START_DT).diff(today, 'days') + '일 뒤', 'rent')];
			}));
			$b.empty().append(rows.length ? table(['성명', '고객사', '상태', '남은 기간'], rows) : '<div class="hm-empty">철수 임박·대기 인원이 없습니다.</div>');
		});
	}

	function interviewCard() {
		kpiSlot('intv');
		var $b = card('INTV', '이번 주 면접', URL.intv);
		fetch('/admin/hr/interviewListData.do', function(res) {
			var hire = hrCodeMap('HR_HIRE'), rt = hrCodeMap('HR_ROUTE'), at = hrCodeMap('HR_ATTEND'), rs = hrCodeMap('HR_RESULT'), nt = hrCodeMap('HR_NOTICE'), jn = hrCodeMap('HR_JOIN');
			(res.list || []).forEach(function(r) {
				calAdd(r.HIRE_CD === 'EXP' ? 'INTV_EXP' : 'INTV_NEW', r.INTV_DT, r.APLY_NM, URL.intv + '?INTV_SQ=' + r.INTV_SQ, r.INTV_TM, [
					['구분', hire[r.HIRE_CD] || r.HIRE_CD], ['나이', r.AGE], ['연락처', r.PHONE], ['경로', (rt[r.APLY_ROUTE] || r.APLY_ROUTE || '') + (r.REFERRER ? ' (' + r.REFERRER + ')' : '')],
					['참석', at[r.ATTEND_ST] || r.ATTEND_ST], ['결과', rs[r.RESULT_ST] || r.RESULT_ST], ['합격통보', nt[r.NOTICE_ST] || r.NOTICE_ST], ['입사', jn[r.JOIN_ST] || r.JOIN_ST], ['출근일', r.JOIN_DT],
					['메모', (r.MEMO || '').split('\n')[0]]], URL.intv + '?INTV_SQ=' + r.INTV_SQ);
			});
			var from = moment().startOf('isoWeek').format('YYYY-MM-DD'), to = moment().endOf('isoWeek').format('YYYY-MM-DD'), d = today.format('YYYY-MM-DD');
			var list = (res.list || []).filter(function(r) { return r.INTV_DT >= from && r.INTV_DT <= to; })
				.sort(function(a, b) { return (a.INTV_DT + (a.INTV_TM || '')).localeCompare(b.INTV_DT + (b.INTV_TM || '')); });
			var route = hrCodeMap('HR_ROUTE'), attend = hrCodeMap('HR_ATTEND'), result = hrCodeMap('HR_RESULT');
			kpi('intv', '이번 주 면접', list.length, '오늘 ' + list.filter(function(r) { return r.INTV_DT === d; }).length, URL.intv);
			$b.empty().append(list.length ? table(['일자', '시간', '이름', '경로', '참석', '결과'], list.slice(0, 8).map(function(r) {
				return [moment(r.INTV_DT).format('MM-DD') + ' (' + '일월화수목금토'.charAt(moment(r.INTV_DT).day()) + ')', r.INTV_TM || '', link(r.APLY_NM, URL.intv + '?INTV_SQ=' + r.INTV_SQ),
					(route[r.APLY_ROUTE] || r.APLY_ROUTE || '') + (r.REFERRER ? ' (' + r.REFERRER + ')' : ''),
					r.ATTEND_ST ? pill(attend[r.ATTEND_ST] || r.ATTEND_ST, r.ATTEND_ST === 'ATTEND' ? 'ok' : '') : pill('미입력'),
					r.RESULT_ST ? pill(result[r.RESULT_ST] || r.RESULT_ST, r.RESULT_ST === 'PASS' ? 'ok' : r.RESULT_ST === 'FAIL' ? 'bad' : 'warn') : ''];
			})) : '<div class="hm-empty">이번 주 면접이 없습니다.</div>');
			if (list.length > 8) $b.append($('<div class="small">').append(link('… ' + (list.length - 8) + '건 더', URL.intv)));
		});
	}

	// 교육생관리 화면의 주차 기준: 옮긴 주차, 없으면 시작일이 있으면 1주차
	function traineeCard() {
		kpiSlot('trainee');
		var $b = card('TRAINEE', '교육생 주차별', URL.trainee);
		fetch('/admin/hr/traineeListData.do', function(res) {
			var ing = (res.list || []).filter(function(r) { return r.STATUS_CD === 'ING'; });
			var stNm = { ING: '교육진행중', END: '교육종료', DROP: '중도이탈' }, iv = hrCodeMap('HR_INTERVIEW');
			function tInfo(r) { return [['상태', stNm[r.STATUS_CD] || r.STATUS_CD], ['교육 시작', r.EDU_START_DT], ['인터뷰', iv[r.INTERVIEW_YN] || r.INTERVIEW_YN], ['인터뷰 가능일', r.INTERVIEW_AVAIL], ['나이', r.AGE], ['메모', (r.MEMO || '').split('\n')[0]]]; }
			(res.list || []).forEach(function(r) { calAdd('EDU', r.EDU_START_DT, r.TRN_NM, URL.trainee, null, tInfo(r), URL.trainee + '?TRN_SQ=' + r.TRN_SQ); });
			ing.forEach(function(r) { calAdd('AVAIL', r.INTERVIEW_AVAIL, r.TRN_NM, URL.trainee, null, tInfo(r), URL.trainee + '?TRN_SQ=' + r.TRN_SQ); });
			var weeks = [['1', '1주차'], ['2', '2주차'], ['3', '3주차'], ['OVER', '3주차 초과'], ['NONE', '시작일 없음']];
			// 주차마다 한 줄: 주차(인원) + 교육생 이름(교육 시작 순). 이름을 누르면 교육생 상세
			var by = {};
			ing.slice().sort(function(a, b) { return (a.EDU_START_DT || '9').localeCompare(b.EDU_START_DT || '9'); }).forEach(function(r) {
				var w = r.EDU_WEEK || (r.EDU_START_DT ? '1' : 'NONE');
				(by[w] = by[w] || []).push(r);
			});
			kpi('trainee', '교육 진행', ing.length, '3주차 초과 ' + (by.OVER || []).length, URL.trainee, by.OVER ? 'warn' : '');
			var known = weeks.map(function(w) { return w[0]; });
			var rows = weeks.concat(Object.keys(by).filter(function(k) { return known.indexOf(k) < 0; }).map(function(k) { return [k, k + '주차']; }))
				.filter(function(w) { return by[w[0]]; });
			$b.empty().append(rows.length ? $('<ul class="hm-todo">').append(rows.map(function(w) {
				return $('<li>').append(pill(w[1] + ' ' + by[w[0]].length + '명', w[0] === 'OVER' ? 'warn' : w[0] === 'NONE' ? '' : 'rent'))
					.append($('<span>').append(by[w[0]].map(function(r, i) { return $('<span>').append(i ? ', ' : '').append(link(r.TRN_NM, URL.trainee + '?TRN_SQ=' + r.TRN_SQ)); })));
			})) : '<div class="hm-empty">교육 중인 교육생이 없습니다.</div>');
		});
	}

	// 급여관리를 여는 것과 같다(작성중인 달은 열 때 투입 기준으로 다시 계산된다)
	function payCard() {
		var ym = moment().format('YYYY-MM'), label = moment().format('M월'), href = URL.pay + '?ym=' + ym;
		var $b = card('PAY', label + ' 급여', URL.pay);
		// 달력: 지난 3달~이번 달 급여의 지급일(이번 달 급여는 보통 다음 달에 지급). 지급일은 급여관리에서 정하고, 없으면 익월 15일
		fetch('/admin/pay/payDatesData.do?FROM=' + moment().subtract(3, 'months').format('YYYY-MM') + '&TO=' + ym, function(res) {
			(res.result || []).forEach(function(p) {
				var m = moment(p.YM + '-01');
				calAdd('PAY', p.PAY_DT, m.format('M월') + ' 급여', URL.pay + '?ym=' + p.YM, null, [['급여 달', m.format('YYYY년 M월')], ['상태', p.CLOSED ? '마감' : '작성중']]);
			});
		});
		fetch('/admin/pay/monthData.do?YM=' + ym, function(res) {
			if (!res.result) { $b.html('<div class="hm-empty">급여를 불러오지 못했습니다.</div>'); return; }
			var r = res.result, rows = r.rows || [];
			function sum(k) { return rows.reduce(function(s, x) { return s + Number(x[k] || 0); }, 0); }
			var flags = rows.filter(function(x) { return x.FLAGS && x.FLAGS.length; }).length;
			$b.closest('.hm-card').children('header').children('a').first().before(pill(r.closed ? '마감' : '작성중', r.closed ? 'ok' : 'warn'));
			$b.empty().addClass('hm-money').append([['지급 합계', 'PAY_TOTAL'], ['실매출', 'REAL_SALE'], ['영업이익', 'PROFIT']].map(function(k) {
				return $('<a>').attr('href', href).append($('<span>').text(k[0])).append($('<b>').text(dpWonText(sum(k[1]))));
			}));
			if (!r.closed && flags) todo(1, '급여', 'warn', $('<span>').text(label + ' 급여 작성중 · 확인 필요 ' + flags + '건' + (r.PAY_DT ? ' · 지급일 ' + moment(r.PAY_DT).format('MM-DD') : '')), href + '&flag=1', '급여관리 · 확인 필요');
		});
	}
	function dpWonText(v) { return Number(v || 0).toLocaleString('ko-KR'); }

	function journalTodo() {
		var j = HOME.journals;
		if (!j.length) return;
		todo(4, '연구일지', 'warn', $('<span>').append('내 결재 차례 ' + j.length + '건: ').append(j.slice(0, 3).map(function(x, i) {
			return $('<span>').append(i ? ', ' : '').append(link((x.PRJ_NM || '') + ' ' + x.YM, URL.journal + '#j=' + x.JRN_SQ));
		})), j.length === 1 ? URL.journal + '#j=' + j[0].JRN_SQ : URL.journal, '연구일지');
	}

	// 장비대장 화면의 알림·검토 필요 기준과 같다
	function equipmentTodo() {
		fetch('/admin/equipment/equipmentListData.do', function(res) {
			var rows = res.result.list || [];
			var left = rows.filter(function(r) { return r.STATUS_CD === 'RENT' && r.STAFF_STATUS === 'LEFT'; }).length;
			var sign = rows.filter(function(r) { return r.SIGN_WAIT === 'Y'; }).length;
			var review = rows.filter(function(r) { return r.REVIEW_OPEN > 0 || r.REVIEW_NODATE > 0 || r.REVIEW_NOEND > 0; }).length;
			if (!left && !sign && !review) return;
			var $t = $('<span>');
			[[left, '퇴사자 미반납', '?alert=left'], [sign, '증서 서명 대기', '?alert=sign'], [review, '검토 필요', '?tab=REVIEW']].filter(function(x) { return x[0]; }).forEach(function(x, i) {
				$t.append(i ? ' · ' : '').append(link(x[1] + ' ' + x[0], URL.eqp + x[2]));
			});
			todo(5, '장비', left ? 'bad' : 'warn', $t, URL.eqp, '장비대장');
		});
	}

	// 계정관리 화면의 미발급 재직자·정리 필요 기준과 같다
	function memberTodo() {
		fetch('/admin/member/memberListData.do', function(res) {
			var d = res.result || {};
			var fix = (d.accounts || []).filter(function(a) { return !(a.DEL_YN === 'Y' || a.USE_YN === 'N') && (!a.EMPLY_ID || (a.EMPLY_AUTH_TYP_CD !== '1' && a.EMPLY_AUTH_TYP_CD !== '2')); }).length;
			var pend = (d.pending || []).length;
			if (!fix && !pend) return;
			var $t = $('<span>');
			[[pend, '계정 미발급 재직자', '?tab=pending'], [fix, '정리 필요', '?tab=fix']].filter(function(x) { return x[0]; }).forEach(function(x, i) {
				$t.append(i ? ' · ' : '').append(link(x[1] + ' ' + x[0], URL.member + x[2]));
			});
			todo(6, '계정', '', $t, URL.member, '계정관리');
		});
	}

	// 메모가 달린 대상으로 간다. 교육생·투입은 목록까지만
	function memoHref(m) {
		switch (m.TARGET_CD) {
			case 'STAFF': return URL.staff + '?STAFF_SQ=' + m.TARGET_SQ;
			case 'INTV': return URL.intv + '?INTV_SQ=' + m.TARGET_SQ;
			case 'EQP': return URL.eqp + '?EQP_SQ=' + m.TARGET_SQ;
			case 'LAB_TEAM': return URL.lab + '#t=' + m.TARGET_SQ;
			case 'TRAINEE': return URL.trainee;
			default: return URL.deploy;
		}
	}
	function memoCard() {
		var NM = { STAFF: '직원', DEPLOY: '투입', INTV: '면접', TRAINEE: '교육생', EQP: '장비', LAB_TEAM: '연구팀' };
		var $b = card('MEMO', '최근 메모', null, true);
		$b.empty().append(table(['화면', '대상', '내용', '작성자', '일시'], HOME.memos.map(function(m) {
			return [NM[m.TARGET_CD] || m.TARGET_CD, link(m.TARGET_NM || '#' + m.TARGET_SQ, memoHref(m)), $('<span class="td-cut">').text(m.CONTENT.replace(/\s+/g, ' ')), m.EMPLY_NM || '', m.REG_DT];
		})));
	}
	</script>
</body>
</html>
