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
	.hm-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
	.hm-card { background: #fff; border: 1px solid rgba(17,17,17,.1); border-radius: 10px; overflow: hidden; min-width: 0; }
	.hm-card.wide { grid-column: 1 / -1; }
	.hm-card header { display: flex; align-items: center; gap: 6px; padding: 8px 12px; border-bottom: 1px solid rgba(17,17,17,.08); font-weight: 700; }
	.hm-card header a { margin-left: auto; font-weight: 400; font-size: 12px; }
	.hm-card .hm-body { padding: 6px 12px 10px; }
	.hm-card .table { margin: 0; font-size: 12.5px; }
	.hm-todo { list-style: none; margin: 0; padding: 0; }
	.hm-todo li { display: flex; align-items: center; gap: 8px; padding: 6px 0; border-bottom: 1px dashed rgba(17,17,17,.12); flex-wrap: wrap; }
	.hm-todo li:last-child { border-bottom: 0; } .hm-todo li > a.go { margin-left: auto; font-size: 12px; }
	.hm-link { color: #0b6e8a; font-weight: 700; }
	.hm-bars a { display: grid; grid-template-columns: 80px 1fr 30px; gap: 8px; align-items: center; font-size: 12.5px; padding: 3px 0; color: #111; }
	.hm-bars i { display: block; height: 14px; background: #9fd8e8; border-radius: 3px; min-width: 2px; } .hm-bars i.w { background: #f6d27c; }
	.hm-money { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; } .hm-money a { display: block; background: #fafbfc; border-radius: 8px; padding: 6px 10px; color: #111; }
	.hm-money span { color: #5f6b75; font-size: 11.5px; } .hm-money b { display: block; font-size: 16px; font-variant-numeric: tabular-nums; }
	.hm-empty { color: #8a949c; padding: 8px 0; }
	/* 일정 캘린더 */
	.hm-cal-chips { display: flex; flex-wrap: wrap; gap: 6px; margin: 4px 0 8px; }
	.hm-cal-chip { display: inline-flex; align-items: center; gap: 5px; border: 1px solid rgba(17,17,17,.15); background: #fff; border-radius: 999px; padding: 2px 10px; font-size: 12px; font-weight: 700; color: #444; }
	.hm-cal-chip i { width: 10px; height: 10px; border-radius: 50%; display: inline-block; }
	.hm-cal-chip[aria-pressed=false] { opacity: .45; text-decoration: line-through; }
	.hm-cal-chip .cnt { font-weight: 400; color: #5f6b75; }
	#hmCalCard { margin-bottom: 12px; }
	#hmCalendar { font-size: 12px; }
	#hmCalendar .fc-toolbar { margin-bottom: 6px; } #hmCalendar .fc-toolbar h2 { font-size: 16px; }
	#hmCalendar .fc-event { cursor: pointer; font-size: 11px; line-height: 1.35; padding: 0 2px; }
	#hmCalendar .fc-day-grid .fc-row { min-height: 0 !important; }
	#hmCalendar .fc-day-grid .fc-content-skeleton { padding-bottom: 2px; }
	#hmCalendar .fc-more { font-size: 11px; font-weight: 700; color: #0b6e8a; }
	#hmCalCard.closed .hm-body { display: none; }
	/* 더보기로 펼친 날짜: 그 주 줄 바로 아래 */
	.hm-cal-day { border: 1px solid #0b6e8a; border-radius: 6px; background: #f3fbfd; margin: 2px 0 4px; padding: 6px 8px; }
	.hm-cal-day .hd { display: flex; align-items: center; gap: 8px; margin-bottom: 4px; }
	.hm-cal-day ul { list-style: none; margin: 0; padding: 0; display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 3px 10px; }
	.hm-cal-day li button { width: 100%; text-align: left; border: 0; border-left: 4px solid #999; background: #fff; padding: 2px 6px; font-size: 12px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
	@media (max-width: 991px) { .hm-grid, .hm-money { grid-template-columns: 1fr; } }
</style>
<link rel="stylesheet" href="/resources/bo/plugins/fullcalendar/main.min.css">
<link rel="stylesheet" href="/resources/bo/plugins/fullcalendar-daygrid/main.min.css">
<link rel="stylesheet" href="/resources/bo/plugins/fullcalendar-timegrid/main.min.css">

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_open.jspf"%>
				<div class="card-body">
					<div class="hm-hello"><b><c:out value="${loginInfo.loginInfo[0].emplyNm}"/>님, 안녕하세요</b><span class="text-muted" id="hmToday"></span>
						<span class="ml-auto text-muted">열 때 한 번 불러와요 · <a href="/admin/home.do">새로고침</a></span></div>
					<div class="hm-kpis" id="hmKpis"></div>
					<div class="hm-grid" id="hmCards">
						<div class="hm-card wide" id="hmTodoCard"><header>확인할 일 <span class="hm-pill" id="hmTodoCnt">…</span></header><div class="hm-body"><ul class="hm-todo" id="hmTodo"></ul></div></div>
					</div>
				</div>
			<%@ include file="/WEB-INF/jsp/bo/boinclude/page_close.jspf"%>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/page_script.jspf"%>
	<script src="/resources/bo/plugins/fullcalendar/main.min.js"></script>
	<script src="/resources/bo/plugins/fullcalendar-daygrid/main.min.js"></script>
	<script src="/resources/bo/plugins/fullcalendar-timegrid/main.min.js"></script>
	<script src="/resources/bo/plugins/fullcalendar/locales/ko.js" charset="utf-8"></script>
	<script>
	// 서버가 넣은 것: cards(열 수 있는 카드), journals(내 결재 차례), memos(최근 메모)
	var HOME = ${homeJson};
	var today = moment().startOf('day');
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
	function card(title, href, wide) {
		var $c = $('<div class="hm-card">').toggleClass('wide', !!wide).append($('<header>').append(document.createTextNode(title)).append(href ? link(title + ' 열기 ›', href, '') : ''));
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
		INTV_NEW: ['신입면접', '#0b6e8a'], INTV_EXP: ['경력면접', '#00838f'], DEPLOY_IN: ['투입', '#2f7d32'], DEPLOY_OUT: ['철수', '#c62828'], PROB: ['수습 해제', '#b8860b'],
		EDU: ['교육 시작', '#6b3fa0'], AVAIL: ['인터뷰', '#9c6ad6'], JOIN: ['입사', '#1565c0'], LEAVE: ['퇴사', '#78858f'],
		PAY: ['급여 지급', '#d35400'], RC_INTV: ['모집 인터뷰', '#e8590c'], RC_CLOSE: ['모집 마감', '#c2255c']
	};
	// 카드(권한) → 그 카드가 넣는 일정 종류. 모두 우리 시스템에 등록된 정보(구글 캘린더 일정은 넣지 않는다)
	var CAL_SRC = { STAFF: ['JOIN', 'LEAVE'], DEPLOY: ['DEPLOY_IN', 'DEPLOY_OUT', 'PROB'], INTV: ['INTV_NEW', 'INTV_EXP'], TRAINEE: ['EDU', 'AVAIL'], PAY: ['PAY'], RECRUIT: ['RC_INTV', 'RC_CLOSE'] };
	var calEvents = [], calOff = {}, calendar = null, calTimer = null, calDay = null;
	function store(k, v) { try { if (v === undefined) return localStorage.getItem(k); localStorage.setItem(k, v); } catch (e) { return null; } }
	try { calOff = JSON.parse(store('hmCalOff') || '{}') || {}; } catch (e) { calOff = {}; }
	// date: yyyy-MM-dd(뒤는 무시), time: HH:mm 이면 시간 일정, info: 팝업에 보일 [[이름, 값]]
	function calAdd(kind, date, title, href, time, info) {
		if (!date || !/^\d{4}-\d{2}-\d{2}/.test(date)) return;
		var t = /^\d{2}:\d{2}$/.test(time || '') ? time : null;
		calEvents.push({ kind: kind, start: date.substr(0, 10) + (t ? 'T' + t : ''), allDay: !t, name: title, title: CAL_KIND[kind][0] + ' ' + title, url: href, info: info || [] });
		clearTimeout(calTimer);
		calTimer = setTimeout(calPaint, 50);
	}
	function calShown() { return calEvents.filter(function(e) { return !calOff[e.kind]; }); }
	function calPaint() {
		$('#hmCalChips .hm-cal-chip').each(function() {
			var k = $(this).data('k');
			$(this).attr('aria-pressed', !calOff[k]).find('.cnt').text(calEvents.filter(function(e) { return e.kind === k; }).length);
		});
		if (!calendar) return;
		calendar.removeAllEvents();
		calendar.addEventSource(calShown().map(function(e) {
			return { title: e.title, start: e.start, allDay: e.allDay, backgroundColor: CAL_KIND[e.kind][1], borderColor: CAL_KIND[e.kind][1], textColor: '#fff', extendedProps: { ev: e } };
		}));
		calDayPanel();
	}
	function dayText(d) { return moment(d).format('M월 D일') + ' (' + '일월화수목금토'.charAt(moment(d).day()) + ')'; }
	// 일정 팝업: 화면을 넘기지 않고 홈에서 본다. 필요하면 '화면에서 열기'
	function calPop(e) {
		var $t = $('<table class="table table-sm mb-0">');
		[['종류', CAL_KIND[e.kind][0]], ['일시', dayText(e.start) + (e.allDay ? '' : ' ' + e.start.substr(11, 5))]].concat(e.info).forEach(function(r) {
			if (r[1]) $t.append($('<tr>').append($('<th style="width:90px">').text(r[0])).append($('<td>').text(r[1])));
		});
		bootbox.dialog({ title: e.title, message: $t, onEscape: true, backdrop: true, buttons: {
			open: { label: '화면에서 열기', className: 'btn-sm btn-outline-primary', callback: function() { if (e.url && !openTab(e.url, {})) location.href = e.url; } },
			close: { label: '닫기', className: 'btn-sm btn-secondary' } } });
	}
	// 월 보기 날짜 칸은 3건 + 더보기(eventLimit 은 더보기 줄까지 센다). '+n 더보기'를 누르면 그 날의 전체 일정을 그 주 줄 바로 아래에 펼치고, 다시 누르거나 접기로 닫는다
	function calDayPanel() {
		$('#hmCalDay').remove();
		if (!calDay || !calendar || calendar.view.type !== 'dayGridMonth') return;
		var $row = $('#hmCalendar .fc-day[data-date="' + calDay + '"]').closest('.fc-row');
		if (!$row.length) { calDay = null; return; }
		var list = calShown().filter(function(e) { return e.start.substr(0, 10) === calDay; }).sort(function(a, b) { return (a.allDay ? '' : a.start).localeCompare(b.allDay ? '' : b.start); });
		var $p = $('<div id="hmCalDay" class="hm-cal-day">').append($('<div class="hd">').append($('<b>').text(dayText(calDay) + ' 일정 ' + list.length + '건'))
			.append($('<button type="button" class="btn btn-sm btn-outline-secondary ml-auto">▴ 접기</button>').on('click', function() { calDay = null; calDayPanel(); })));
		var $u = $('<ul>').appendTo($p);
		list.forEach(function(e) {
			$u.append($('<li>').append($('<button type="button">').css('border-left-color', CAL_KIND[e.kind][1]).text((e.allDay ? '' : e.start.substr(11, 5) + ' ') + e.title).on('click', function() { calPop(e); })));
		});
		$p.insertAfter($row);
	}
	function calCard() {
		var kinds = [];
		Object.keys(CAL_SRC).forEach(function(k) { if (can(k)) kinds = kinds.concat(CAL_SRC[k]); });
		if (!kinds.length) return;
		var $btn = $('<button type="button" class="btn btn-sm btn-outline-secondary ml-auto" id="hmCalToggle">');
		var $chips = $('<div class="hm-cal-chips" id="hmCalChips">');
		kinds.forEach(function(k) {
			$chips.append($('<button type="button" class="hm-cal-chip">').data('k', k).attr('title', '눌러서 ' + CAL_KIND[k][0] + ' 일정 끄기·켜기')
				.append($('<i>').css('background', CAL_KIND[k][1])).append(document.createTextNode(CAL_KIND[k][0] + ' ')).append('<span class="cnt">…</span>')
				.on('click', function() { calOff[k] = !calOff[k]; store('hmCalOff', JSON.stringify(calOff)); calPaint(); }));
		});
		var $el = $('<div id="hmCalendar">');
		var $c = $('<div class="hm-card wide" id="hmCalCard">').append($('<header>').text('📅 일정').append($btn)).append($('<div class="hm-body">').append($chips).append($el));
		$c.insertBefore('#hmKpis'); // 홈 맨 위
		calendar = new FullCalendar.Calendar($el[0], {
			plugins: ['dayGrid', 'timeGrid'], locales: window.FullCalendarLocales ? [FullCalendarLocales.ko] : [], locale: 'ko',
			defaultView: ['dayGridMonth', 'timeGridWeek', 'timeGridDay'].indexOf(store('hmCalView')) >= 0 ? store('hmCalView') : 'dayGridMonth',
			header: { left: 'prev,next today', center: 'title', right: 'dayGridMonth,timeGridWeek,timeGridDay' },
			buttonText: { today: '오늘', month: '월', week: '주', day: '일' },
			height: 'auto', nowIndicator: true, minTime: '08:00:00', maxTime: '20:00:00', slotDuration: '01:00:00',
			eventLimit: 4, eventLimitText: function(n) { return '+' + n + ' 더보기'; },
			eventLimitClick: function(arg) { var d = moment(arg.date).format('YYYY-MM-DD'); calDay = calDay === d ? null : d; calDayPanel(); },
			datesRender: function(info) { store('hmCalView', info.view.type); calDay = null; $('#hmCalDay').remove(); },
			eventClick: function(info) { info.jsEvent.preventDefault(); calPop(info.event.extendedProps.ev); }
		});
		// 접기·펴기(상태 기억). 접힌 채 열면 펼칠 때 그린다
		var rendered = false;
		function setOpen(open) {
			$c.toggleClass('closed', !open);
			$btn.text(open ? '▴ 접기' : '▾ 펼치기').attr('aria-expanded', open);
			store('hmCalOpen', open ? '1' : '0');
			if (open && !rendered) { rendered = true; calendar.render(); calPaint(); } else if (open) calendar.updateSize();
		}
		$btn.on('click', function() { setOpen($c.hasClass('closed')); });
		setOpen(store('hmCalOpen') !== '0');
		if (can('RECRUIT')) {
			fetch('/admin/recruit/listData.do', function(res) {
				var d = res.result || {}, rc = {};
				(d.recruits || []).forEach(function(r) {
					rc[r.RECRUIT_SQ] = r;
					if (r.STATUS_CD !== 'CLOSED') calAdd('RC_CLOSE', r.CLOSE_DT, r.CLIENT_NM || '모집', '/admin/recruit/openRecruitList.do?open=' + r.RECRUIT_SQ, null, [['사업', r.PRJ_NM], ['등급·인원', r.GRADE_TXT]]);
				});
				(d.applies || []).forEach(function(a) {
					var r = rc[a.RECRUIT_SQ] || {};
					if (a.STEP_CD === 'INTV' && a.INTV_DT) calAdd('RC_INTV', a.INTV_DT, a.STAFF_NM + ' · ' + (r.CLIENT_NM || ''), '/admin/recruit/openRecruitList.do?open=' + a.RECRUIT_SQ, a.INTV_DT.substr(11, 5), [['장소', a.INTV_PLACE], ['사업', r.PRJ_NM]]);
				});
			});
		}
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
		paintTodo();
	});

	// 최근 업데이트 5건(모든 관리자). 줄을 누르면 상세 팝업, 피드백 반영이면 요청자 표시
	function updateCard() {
		var $c = $('<div class="hm-card wide" id="hmUpdCard">').append($('<header>').text('🔔 최근 업데이트').append(link('전체 보기 ›', '/admin/update/openUpdateList.do', '')));
		var $b = $('<div class="hm-body">').appendTo($c);
		$c.prependTo('#hmCards');
		if (!HOME.updates.length) { $b.append('<div class="hm-empty">아직 업데이트 내역이 없습니다. 다음 배포부터 쌓입니다.</div>'); return; }
		$b.append(table(['배포일', '내용', '화면', '피드백'], HOME.updates.map(function(u) {
			return [u.DEPLOY_DT.substr(5), $('<a href="#" class="hm-link">').text(u.TITLE).on('click', function(e) { e.preventDefault(); e.stopPropagation(); BO_UPDATE(u.UPD_SQ); }),
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
				calAdd('JOIN', r.JOIN_DT, r.STAFF_NM, staffHref(r.STAFF_SQ), null, info);
				calAdd('LEAVE', r.LEAVE_DT, r.STAFF_NM, staffHref(r.STAFF_SQ), null, info);
			});
		});
	}

	// 투입현황 화면(deploy_list.jsp)의 투입·대기·철수 임박 기준과 같다
	function deployCard() {
		kpiSlot('active'); kpiSlot('idle');
		var $b = card('철수 임박·대기', URL.deploy);
		fetch('/admin/deploy/deployListData.do', function(res) {
			var d = res.data;
			var empType = hrCodeMap('HR_EMP_TYPE');
			d.all.forEach(function(x) {
				var who = x.STAFF_NM + (x.CLIENT_NM ? ' (' + x.CLIENT_NM + ')' : '');
				var info = [['고객사', x.CLIENT_NM], ['프로젝트', x.PRJ_NM], ['형태', empType[x.EMP_TYPE_CD] || x.EMP_TYPE_CD], ['근무지역', x.WORK_AREA],
					['투입기간', (x.START_DT || '') + ' ~ ' + (x.END_DT || '미정')], ['수습해제일', x.PROB_END_DT]];
				calAdd('DEPLOY_IN', x.START_DT, who, staffHref(x.STAFF_SQ), null, info);
				calAdd('DEPLOY_OUT', x.END_DT, who, staffHref(x.STAFF_SQ), null, info);
				if (x.EMP_TYPE_CD === 'PROBATION') calAdd('PROB', x.PROB_END_DT, x.STAFF_NM, staffHref(x.STAFF_SQ), null, info);
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
		var $b = card('이번 주 면접', URL.intv);
		fetch('/admin/hr/interviewListData.do', function(res) {
			var hire = hrCodeMap('HR_HIRE'), rt = hrCodeMap('HR_ROUTE'), at = hrCodeMap('HR_ATTEND'), rs = hrCodeMap('HR_RESULT'), nt = hrCodeMap('HR_NOTICE'), jn = hrCodeMap('HR_JOIN');
			(res.list || []).forEach(function(r) {
				calAdd(r.HIRE_CD === 'EXP' ? 'INTV_EXP' : 'INTV_NEW', r.INTV_DT, r.APLY_NM, URL.intv + '?INTV_SQ=' + r.INTV_SQ, r.INTV_TM, [
					['구분', hire[r.HIRE_CD] || r.HIRE_CD], ['나이', r.AGE], ['연락처', r.PHONE], ['경로', (rt[r.APLY_ROUTE] || r.APLY_ROUTE || '') + (r.REFERRER ? ' (' + r.REFERRER + ')' : '')],
					['참석', at[r.ATTEND_ST] || r.ATTEND_ST], ['결과', rs[r.RESULT_ST] || r.RESULT_ST], ['합격통보', nt[r.NOTICE_ST] || r.NOTICE_ST], ['입사', jn[r.JOIN_ST] || r.JOIN_ST], ['출근일', r.JOIN_DT],
					['메모', (r.MEMO || '').split('\n')[0]]]);
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
		var $b = card('교육생 주차별', URL.trainee);
		fetch('/admin/hr/traineeListData.do', function(res) {
			var ing = (res.list || []).filter(function(r) { return r.STATUS_CD === 'ING'; });
			var stNm = { ING: '교육진행중', END: '교육종료', DROP: '중도이탈' }, iv = hrCodeMap('HR_INTERVIEW');
			function tInfo(r) { return [['상태', stNm[r.STATUS_CD] || r.STATUS_CD], ['교육 시작', r.EDU_START_DT], ['인터뷰', iv[r.INTERVIEW_YN] || r.INTERVIEW_YN], ['인터뷰 가능일', r.INTERVIEW_AVAIL], ['나이', r.AGE], ['메모', (r.MEMO || '').split('\n')[0]]]; }
			(res.list || []).forEach(function(r) { calAdd('EDU', r.EDU_START_DT, r.TRN_NM, URL.trainee, null, tInfo(r)); });
			ing.forEach(function(r) { calAdd('AVAIL', r.INTERVIEW_AVAIL, r.TRN_NM, URL.trainee, null, tInfo(r)); });
			var weeks = [['1', '1주차'], ['2', '2주차'], ['3', '3주차'], ['OVER', '3주차 초과'], ['NONE', '시작일 없음']];
			var cnt = {};
			ing.forEach(function(r) { var w = r.EDU_WEEK || (r.EDU_START_DT ? '1' : 'NONE'); cnt[w] = (cnt[w] || 0) + 1; });
			var max = Math.max.apply(null, [1].concat(weeks.map(function(w) { return cnt[w[0]] || 0; })));
			kpi('trainee', '교육 진행', ing.length, '3주차 초과 ' + (cnt.OVER || 0), URL.trainee, cnt.OVER ? 'warn' : '');
			$b.empty().addClass('hm-bars').append(weeks.filter(function(w) { return w[0] !== 'NONE' || cnt.NONE; }).map(function(w) {
				var n = cnt[w[0]] || 0;
				return $('<a>').attr({ href: URL.trainee, 'aria-label': w[1] + ' ' + n + '명' }).append($('<span>').text(w[1])).append($('<i>').toggleClass('w', w[0] === 'OVER').css('width', (n / max * 100) + '%')).append($('<b>').text(n));
			}));
		});
	}

	// 급여관리를 여는 것과 같다(작성중인 달은 열 때 투입 기준으로 다시 계산된다)
	function payCard() {
		var ym = moment().format('YYYY-MM'), label = moment().format('M월'), href = URL.pay + '?ym=' + ym;
		var $b = card(label + ' 급여', URL.pay);
		fetch('/admin/pay/monthData.do?YM=' + ym, function(res) {
			if (!res.result) { $b.html('<div class="hm-empty">급여를 불러오지 못했습니다.</div>'); return; }
			var r = res.result, rows = r.rows || [];
			calAdd('PAY', r.PAY_DT, label + ' 급여', href, null, [['상태', r.closed ? '마감' : '작성중'], ['인원', rows.length + '명']]);
			function sum(k) { return rows.reduce(function(s, x) { return s + Number(x[k] || 0); }, 0); }
			var flags = rows.filter(function(x) { return x.FLAGS && x.FLAGS.length; }).length;
			$b.closest('.hm-card').find('header').append(pill(r.closed ? '마감' : '작성중', r.closed ? 'ok' : 'warn'));
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
		var $b = card('최근 메모', null, true);
		$b.empty().append(table(['화면', '대상', '내용', '작성자', '일시'], HOME.memos.map(function(m) {
			return [NM[m.TARGET_CD] || m.TARGET_CD, link(m.TARGET_NM || '#' + m.TARGET_SQ, memoHref(m)), $('<span class="td-cut">').text(m.CONTENT.replace(/\s+/g, ' ')), m.EMPLY_NM || '', m.REG_DT];
		})));
	}
	</script>
</body>
</html>
