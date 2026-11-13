<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
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
	.hm-pill { display: inline-block; padding: 0 8px; border-radius: 10px; font-size: 11px; font-weight: 700; background: #eef1f4; color: #444; white-space: nowrap; }
	.hm-pill.ok { background: #e6f6ea; color: #17692f; } .hm-pill.warn { background: #fff5dc; color: #7a5600; } .hm-pill.bad { background: #fdeaea; color: #a32020; } .hm-pill.rent { background: #dff3f9; color: #0b6e8a; }
	.hm-link { color: #0b6e8a; font-weight: 700; }
	.hm-bars a { display: grid; grid-template-columns: 80px 1fr 30px; gap: 8px; align-items: center; font-size: 12.5px; padding: 3px 0; color: #111; }
	.hm-bars i { display: block; height: 14px; background: #9fd8e8; border-radius: 3px; min-width: 2px; } .hm-bars i.w { background: #f6d27c; }
	.hm-money { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; } .hm-money a { display: block; background: #fafbfc; border-radius: 8px; padding: 6px 10px; color: #111; }
	.hm-money span { color: #5f6b75; font-size: 11.5px; } .hm-money b { display: block; font-size: 16px; font-variant-numeric: tabular-nums; }
	.hm-empty { color: #8a949c; padding: 8px 0; }
	@media (max-width: 991px) { .hm-grid, .hm-money { grid-template-columns: 1fr; } }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-body">
					<div class="hm-hello"><b><c:out value="${loginInfo.loginInfo[0].emplyNm}"/>님, 안녕하세요</b><span class="text-muted" id="hmToday"></span>
						<span class="ml-auto text-muted">열 때 한 번 불러와요 · <a href="/admin/home.do">새로고침</a></span></div>
					<div class="hm-kpis" id="hmKpis"></div>
					<div class="hm-grid" id="hmCards">
						<div class="hm-card wide" id="hmTodoCard"><header>확인할 일 <span class="hm-pill" id="hmTodoCnt">…</span></header><div class="hm-body"><ul class="hm-todo" id="hmTodo"></ul></div></div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>
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
	$(document).on('click', '#hmKpis a, #hmCards a', function(e) {
		var href = $(this).attr('href'), w = null;
		try { w = window.top.BO_OPEN ? window.top : null; } catch (x) {}
		if (!w || !href || href === '#' || e.button || e.ctrlKey || e.metaKey || e.shiftKey || e.altKey) return;
		e.preventDefault();
		w.BO_OPEN(href);
	});

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
		paintTodo();
	});

	function staffCard() {
		kpiSlot('staff');
		fetch('/admin/staff/staffListData.do', function(res) {
			var work = (res.list || []).filter(function(r) { return r.STATUS_CD === 'WORK'; });
			var reg = work.filter(function(r) { return r.ORG_NM === '정규직'; }).length, free = work.filter(function(r) { return r.ORG_NM === '프리'; }).length;
			kpi('staff', '재직 인원', work.length, '정규직 ' + reg + ' · 프리 ' + free, URL.staff);
		});
	}

	// 투입현황 화면(deploy_list.jsp)의 투입·대기·철수 임박 기준과 같다
	function deployCard() {
		kpiSlot('active'); kpiSlot('idle');
		var $b = card('철수 임박·대기', URL.deploy);
		fetch('/admin/deploy/deployListData.do', function(res) {
			var d = res.data;
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
