/*
 * 수행이력 공통 (jQuery·moment 뒤에 읽는다). 직원관리 인사카드의 수행이력·영업정보 탭과 투입현황의 프로젝트 이력 창이 같이 쓴다.
 * 항목: PRJ_NM, CLIENT_NM, COMPANY_NM, WORK_NM, WORK_AREA, ROLE_NM, START_YM, END_YM, IND_NM, APP_NM, MACHINE_NM, OS_NM, LANG_NM, DBMS_NM, TOOL_NM, FRAMEWORK_NM, ETC_NM, SRC(PRJ|DEPLOY)
 * - scTable(칸, 항목들, 옵션): 타임라인처럼 보이는 표
 * - scStack(칸, 항목들, 눌렀을 때): 기술 스택 종합(기간 막대 + 건수 칩)
 */
(function() {
	$('<style>').text([
		'.sc-table { width: 100%; border-collapse: collapse; font-size: 12.5px; }',
		'.sc-table th { text-align: left; color: #6b7785; font-weight: 400; padding: 6px 8px; border-bottom: 1px solid #e3e8ee; white-space: nowrap; background: #fafbfc; }',
		'.sc-table td { padding: 9px 8px; border-bottom: 1px solid #e3e8ee; vertical-align: middle; white-space: nowrap; }',
		'.sc-table .sc-yr td { background: #f7f9fb; color: #6b7785; font-weight: 700; font-size: 12px; padding: 4px 8px 4px 34px; border-bottom: 0; }',
		'.sc-table .sc-rail { width: 26px; padding: 0; position: relative; }',
		'.sc-table .sc-rail::before { content: ""; position: absolute; left: 12px; top: 0; bottom: 0; width: 2px; background: #e3e8ee; }',
		'.sc-table .sc-rail::after { content: ""; position: absolute; left: 8px; top: 50%; margin-top: -5px; width: 10px; height: 10px; border-radius: 50%; background: #c5ced8; border: 2px solid #fff; }',
		'.sc-table .sc-now .sc-rail::after { background: #0b6e8a; box-shadow: 0 0 0 3px #e8f6fa; }',
		'.sc-table .sc-now td { background: #f6fcfe; }',
		'.sc-table tr.sc-add td { background: #e6f5ec; } .sc-table tr.sc-chg td { background: #fdf1dc; } .sc-table td.sc-cell-chg { background: #fff3b0 !important; box-shadow: inset 0 0 0 1px #e0a800; }',
		'.sc-per b { display: block; } .sc-per small, .sc-work small { color: #6b7785; }',
		'.sc-nm { font-weight: 700; font-size: 13.5px; background: none; border: 0; padding: 0; color: #1c2530; text-align: left; white-space: normal; }',
		'button.sc-nm { color: #0b6e8a; text-decoration: underline; cursor: pointer; }',
		'.sc-work { white-space: normal !important; min-width: 130px; } .sc-tech { white-space: normal !important; min-width: 240px; }',
		'.sc-chip { display: inline-block; border-radius: 999px; padding: 1px 9px; margin: 2px 3px 2px 0; background: #e8f6fa; color: #0b6e8a; font-size: 12px; font-weight: 700; border: 0; }',
		'.sc-chip em { font-style: normal; font-weight: 400; opacity: .75; margin-left: 3px; }',
		'.sc-chip.gray { background: #eef1f4; color: #4a5560; } .sc-chip.on { background: #0b6e8a; color: #fff; }',
		'button.sc-chip { cursor: pointer; } button.sc-chip:focus { outline: 2px solid #16d5ff; }',
		'.sc-pill { display: inline-block; border-radius: 6px; padding: 0 7px; margin-right: 3px; font-size: 11.5px; font-weight: 700; background: #eef1f4; color: #4a5560; white-space: nowrap; }',
		'.sc-pill.cl { background: #f4effc; color: #6b3fa0; } .sc-pill.in { background: #e6f5ec; color: #1d7a4a; } .sc-pill.warn { background: #fdf1dc; color: #a36200; }',
		'.sc-act { background: none; border: 0; padding: 0 4px; color: #8a94a0; } .sc-act:hover, .sc-act:focus { color: #0b6e8a; }',
		'.sc-top { display: grid; grid-template-columns: 96px 1fr 76px; gap: 6px 8px; font-size: 12.5px; align-items: center; }',
		'.sc-bar { height: 6px; border-radius: 3px; background: #e8edf2; overflow: hidden; } .sc-bar i { display: block; height: 100%; background: #0b6e8a; border-radius: 3px; }',
		'.sc-sk { display: grid; grid-template-columns: 78px 1fr; gap: 6px 8px; align-items: start; font-size: 13px; } .sc-sk .k { color: #6b7785; padding-top: 3px; }',
		'.sc-stack { display: grid; grid-template-columns: minmax(240px, 340px) 1fr; gap: 18px; } @media (max-width: 900px) { .sc-stack { grid-template-columns: 1fr; } }'
	].join('\n')).appendTo('head');

	var TECH = [['LANG_NM', '언어'], ['FRAMEWORK_NM', '프레임워크'], ['DBMS_NM', 'DBMS'], ['TOOL_NM', 'TOOL']];
	var ENV = TECH.concat([['OS_NM', 'O.S'], ['MACHINE_NM', '기종'], ['ETC_NM', '기타']]);

	function tokens(v) { return String(v || '').split(/[,\n]/).map(function(t) { return $.trim(t); }).filter(Boolean); }
	function ymDot(v) { return v ? String(v).substring(0, 7).replace('-', '.') : ''; }
	// 시작월부터 종료월(없으면 이번 달)까지 달 수
	function months(it) {
		if (!it.START_YM) return 0;
		var s = moment(String(it.START_YM).substring(0, 7) + '-01'), e = it.END_YM ? moment(String(it.END_YM).substring(0, 7) + '-01') : moment().startOf('month');
		return Math.max(0, e.diff(s, 'months') + 1);
	}
	function span(m) { return m <= 0 ? '' : (m >= 12 ? Math.floor(m / 12) + '년' : '') + (m >= 12 && m % 12 ? ' ' : '') + (m % 12 ? m % 12 + '개월' : ''); }
	function key(it) { return String(it.PRJ_NM || '').replace(/\s/g, '') + '|' + (it.START_YM || ''); }

	window.scTokens = tokens;
	window.scSpan = span;
	window.scMonths = months;
	window.scKey = key;
	window.scEnv = ENV;
	// 첫 프로젝트 시작부터 지금까지
	window.scCareer = function(items) {
		var first = items.map(function(i) { return String(i.START_YM || ''); }).filter(Boolean).sort()[0];
		return first ? span(moment().startOf('month').diff(moment(first.substring(0, 7) + '-01'), 'months') + 1) : '';
	};
	// 칸마다 [값, 프로젝트 수, 달 수] 를 많이 쓴 순으로
	window.scCount = function(items, col) {
		var c = {};
		items.forEach(function(it) {
			tokens(it[col]).filter(function(t, i, a) { return a.indexOf(t) === i; }).forEach(function(t) { c[t] = c[t] || [t, 0, 0]; c[t][1]++; c[t][2] += months(it); });
		});
		return Object.keys(c).map(function(k) { return c[k]; }).sort(function(a, b) { return b[1] - a[1] || b[2] - a[2]; });
	};

	// o: { edit(it), copy(it), del(it), fill(it), check: true(맨 앞 체크박스, class sc-chk·값은 PRJ_SQ), marks: { 키: 'add'|'chg' }, pick: 강조할 기술(하나 또는 배열), cells: { 키: [달라진 칸] } 노란 칸 }
	window.scTable = function($box, items, o) {
		o = o || {};
		var act = o.edit || o.copy || o.del;
		var $t = $('<table class="sc-table" data-nosort>').append($('<thead>').append($('<tr>')
			.append(o.check ? '<th style="width:26px;"><span class="sr-only">선택</span></th>' : '')
			.append('<th><span class="sr-only">흐름</span></th><th>참여기간</th><th>프로젝트명</th><th>담당업무</th><th>고객사</th><th>역할</th><th>산업·응용</th><th>개발환경</th>')
			.append(act ? '<th><span class="sr-only">관리</span></th>' : '')));
		var $b = $('<tbody>').appendTo($t), cols = 8 + (o.check ? 1 : 0) + (act ? 1 : 0), year = null, picks = [].concat(o.pick || []);
		// 그 줄에서 달라진 칸이 들어 있는 td 를 노랗게
		function chg($td, it, fs) { var c = o.cells && o.cells[key(it)]; if (c && fs.some(function(f) { return c.indexOf(f) >= 0; })) $td.addClass('sc-cell-chg').attr('title', '기준 순정 버전과 다름'); return $td; }
		items.forEach(function(it) {
			var y = it.END_YM ? String(it.START_YM).substring(0, 4) : '진행중', now = !it.END_YM;
			if (y !== year) { year = y; $b.append($('<tr class="sc-yr">').append($('<td>').attr('colspan', cols).text(y))); }
			var $tr = $('<tr>').toggleClass('sc-now', now).addClass(o.marks && o.marks[key(it)] ? 'sc-' + o.marks[key(it)] : '').appendTo($b);
			if (o.check) $tr.append($('<td>').append(it.PRJ_SQ ? $('<input type="checkbox" class="sc-chk">').val(it.PRJ_SQ).attr('aria-label', it.PRJ_NM + ' 선택') : ''));
			$tr.append('<td class="sc-rail"></td>');
			$tr.append(chg($('<td class="sc-per">').append($('<b>').text(ymDot(it.START_YM) + ' ~ ' + (it.END_YM ? ymDot(it.END_YM) : '진행중'))).append($('<small>').text(span(months(it)))), it, ['START_YM', 'END_YM']));
			$tr.append($('<td>').append(o.edit ? $('<button type="button" class="sc-nm">').attr('title', '눌러서 수정').text(it.PRJ_NM || '(프로젝트명 없음)').on('click', function() { o.edit(it); })
				: $('<span class="sc-nm">').text(it.PRJ_NM || '(프로젝트명 없음)')));
			var $w = $('<td class="sc-work">').append($('<div>').text(it.WORK_NM || '')).append($('<small>').text(it.WORK_AREA || ''));
			if (it.SRC === 'DEPLOY') $w.append($('<div>').append('<span class="sc-pill in" title="투입현황에 등록된 건입니다. 프로젝트명·고객사·기간은 투입현황을 따릅니다">사내 투입 연동</span>'));
			$tr.append(chg($w, it, ['WORK_NM', 'WORK_AREA']));
			$tr.append(chg($('<td>').append(it.CLIENT_NM ? $('<span class="sc-pill cl">').text(it.CLIENT_NM) : '')
				.append(it.COMPANY_NM ? $('<div>').append($('<small style="color:#6b7785">').text(it.COMPANY_NM)) : ''), it, ['CLIENT_NM', 'COMPANY_NM']));
			$tr.append(chg($('<td>').append(tokens(it.ROLE_NM).map(function(t) { return $('<span class="sc-pill">').text(t); })), it, ['ROLE_NM']));
			$tr.append(chg($('<td>').text([tokens(it.IND_NM).join(', '), tokens(it.APP_NM).join(', ')].filter(Boolean).join(' · ') || '—'), it, ['IND_NM', 'APP_NM']));
			var $e = $('<td class="sc-tech">');
			ENV.forEach(function(c, i) {
				tokens(it[c[0]]).forEach(function(t) { $e.append($('<span class="sc-chip">').toggleClass('gray', i > 3).toggleClass('on', picks.indexOf(t) >= 0).attr('title', c[1]).text(t)); });
			});
			if (!$e.children().length) {
				$e.append('<span class="sc-pill warn">개발환경 미입력</span>');
				if (o.fill) $e.append($('<button type="button" class="btn btn-link btn-sm p-0">').text('채우기').attr('aria-label', it.PRJ_NM + ' 개발환경 채우기').on('click', function() { o.fill(it); }));
			}
			$tr.append(chg($e, it, ENV.map(function(c) { return c[0]; })));
			if (act) {
				var $a = $('<td class="text-right">');
				if (o.edit) $a.append($('<button type="button" class="sc-act">').attr({ 'aria-label': it.PRJ_NM + ' 수정', title: '수정' }).html('<i class="fas fa-pen"></i>').on('click', function() { o.edit(it); }));
				if (o.copy) $a.append($('<button type="button" class="sc-act">').attr({ 'aria-label': it.PRJ_NM + ' 복제', title: '복제해서 새 이력 만들기' }).html('<i class="far fa-copy"></i>').on('click', function() { o.copy(it); }));
				if (o.del && it.PRJ_SQ && it.SRC !== 'DEPLOY') $a.append($('<button type="button" class="sc-act">').attr({ 'aria-label': it.PRJ_NM + ' 삭제', title: '삭제' }).html('<i class="fas fa-trash"></i>').on('click', function() { o.del(it); }));
				$tr.append($a);
			}
		});
		if (!items.length) $b.append($('<tr>').append($('<td class="text-center text-muted py-4">').attr('colspan', cols).text(o.empty || '프로젝트 이력이 없습니다.')));
		return $box.append($('<div class="table-responsive">').append($t));
	};

	// 기술 스택 종합: 왼쪽은 오래 쓴 기술 5개(기간 막대), 오른쪽은 갈래별 칩(숫자는 프로젝트 수). pick(값)을 주면 칩이 버튼이 된다
	window.scStack = function($box, items, pick) {
		var all = [];
		TECH.forEach(function(c) { all = all.concat(scCount(items, c[0])); });
		if (!all.length) return $box.append('<div class="small text-muted">수행이력에 입력된 기술이 없습니다. 수행이력 탭에서 프로젝트의 개발환경을 넣으면 여기에 자동으로 모입니다.</div>');
		var top = all.slice().sort(function(a, b) { return b[2] - a[2]; }).slice(0, 5), max = top[0][2] || 1;
		var $top = $('<div class="sc-top">');
		top.forEach(function(t) { $top.append($('<span>').text(t[0])).append($('<div class="sc-bar">').append($('<i>').css('width', Math.round(t[2] / max * 100) + '%'))).append($('<span>').text(span(t[2]))); });
		var $sk = $('<div class="sc-sk">');
		function line(name, cols, gray) {
			var $d = $('<div>');
			cols.forEach(function(col) {
				scCount(items, col).forEach(function(t) {
					var $c = $(pick ? '<button type="button" class="sc-chip">' : '<span class="sc-chip">').toggleClass('gray', !!gray).text(t[0]).append($('<em>').text(t[1]));
					if (pick) $c.attr('aria-label', t[0] + ' 를 쓴 프로젝트 ' + t[1] + '건 보기').on('click', function() { pick(t[0]); });
					$d.append($c);
				});
			});
			if ($d.children().length) $sk.append($('<span class="k">').text(name)).append($d);
		}
		TECH.forEach(function(c) { line(c[1], [c[0]]); });
		line('O.S · 기종', ['OS_NM', 'MACHINE_NM'], true);
		line('산업', ['IND_NM'], true);
		line('역할', ['ROLE_NM'], true);
		return $box.append($('<div class="sc-stack">').append($top).append($sk));
	};
})();
