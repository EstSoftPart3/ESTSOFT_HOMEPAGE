/*
 * 모든 표 공통 (BO·FO)
 * - 머리글을 누르면(또는 Enter) 그 칸으로 정렬, 다시 누르면 반대로. 빈 칸은 항상 아래
 * - BO: 표를 스크롤 상자에 넣어 머리글 고정·가로 스크롤이 되게 하고, 잘린 칸은 올리면 전체 글
 * - BO: 검색필터 줄(.cal-panel-body 첫 줄)을 접고 편다. 접으면 검색어·기간·버튼만 한 줄
 * - BO: 목록 표 맨 앞 체크박스(없으면 넣음)와 체크한 줄 파란 테두리 강조
 * - BO: 목록은 50줄씩, 표 끝까지 내리면 로딩 화면 뒤 50줄 더(월별 화면 제외)
 * 화면이 직접 정렬을 그리는 표(.pl-sort), 줄 합치기(rowspan)·하위 줄이 있는 표, data-nosort 표는 건드리지 않는다.
 */
(function () {
	var BO = !!document.querySelector('.content-wrapper');
	var NUM = /^[-+]?[\d,]*\.?\d+\s*(원|%|일|건|개월|명|개|년|시간)?$/;

	function text(c) { return c ? (c.getAttribute('data-sort') || c.textContent).replace(/\s+/g, ' ').trim() : ''; }
	function key(s) { return NUM.test(s) ? parseFloat(s.replace(/[^\d.+-]/g, '')) : s; }
	function cmp(a, b) { return typeof a === 'number' && typeof b === 'number' ? a - b : String(a).localeCompare(String(b), 'ko', { numeric: true }); }

	function sortable(t) {
		if (!t || t.hasAttribute('data-nosort') || t.classList.contains('dataTable') || !t.tHead || t.tHead.rows.length !== 1 || t.tBodies.length !== 1) return false;
		// 체크 칸 머리글의 rowspan="1" 같은 1 짜리는 합친 칸이 아니다
		function span(c) { return c.rowSpan > 1 || c.colSpan > 1; }
		if (t.tHead.querySelector('.pl-sort, [draggable]') || [].some.call(t.tHead.querySelectorAll('[colspan], [rowspan]'), span) || [].some.call(t.tBodies[0].querySelectorAll('[rowspan]'), span)) return false;
		var rows = t.tBodies[0].rows;
		for (var i = 0; i < rows.length; i++) if (/child|sub|form|detail/.test(rows[i].className)) return false;
		return true;
	}

	function sortBy(th) {
		var t = th.closest('table');
		if (!sortable(t)) return;
		var dir = th.getAttribute('aria-sort') === 'ascending' ? -1 : 1, n = th.parentNode.cells.length, idx = th.cellIndex, b = t.tBodies[0];
		[].forEach.call(th.parentNode.cells, function (c) { c.removeAttribute('aria-sort'); });
		th.setAttribute('aria-sort', dir > 0 ? 'ascending' : 'descending');
		var all = [].slice.call(b.rows), rows = all.filter(function (r) { return r.cells.length === n; });
		// 시크릿 줄(tr 의 dp-secret·pl-secret·ps-secret·st-secret-row)은 어느 칸으로 정렬해도 맨 위에 둔다
		function pin(r) { return /(^|\s)[\w-]*secret[\w-]*(\s|$)/.test(r.className) ? 0 : 1; }
		rows.map(function (r, i) { return { r: r, k: key(text(r.cells[idx])), i: i }; }).sort(function (x, y) {
			if (pin(x.r) !== pin(y.r)) return pin(x.r) - pin(y.r);
			if (x.k === '' || y.k === '') return (x.k === '') - (y.k === '') || x.i - y.i;
			return dir * cmp(x.k, y.k) || x.i - y.i;
		}).forEach(function (o) { b.appendChild(o.r); });
		// '목록이 없습니다' 같은 줄은 아래에 그대로
		all.filter(function (r) { return r.cells.length !== n; }).forEach(function (r) { b.appendChild(r); });
		if (more.has(t)) applyMore(t);
	}

	// ── 50줄씩 더 보이기 (BO 목록 표) ──
	// 줄은 화면이 전부 그려 두고, 여기서 50줄 넘는 줄을 숨겼다가 표 끝이 보이면 로딩 화면을 잠깐 띄우고 50줄을 더 보인다.
	// 월별 화면(기준월 칸이 있는 화면)·팝업 안 표·줄 합친 표·data-nomore 표는 빼고, 줄 수가 달라지면(검색·탭 바꿈) 처음 50줄로 돌아간다
	var STEP = 50, more = new WeakMap(), monthly = null, busy = false, loadEl = null;

	function moreable(t) {
		if (monthly === null) monthly = [].some.call(document.querySelectorAll('.content-wrapper input[type=month]'), function (m) { return !m.closest('.modal'); });
		return !monthly && t.tBodies.length === 1 && !t.hasAttribute('data-nomore') && !t.classList.contains('dataTable') && !!t.closest('.content-wrapper') && !t.closest('.modal')
			&& ![].some.call(t.tBodies[0].querySelectorAll('[rowspan]'), function (c) { return c.rowSpan > 1; });
	}

	function applyMore(t) {
		// '목록이 없습니다' 같은 한 칸 줄은 세지 않는다
		var rows = [].filter.call(t.tBodies[0].rows, function (r) { return r.cells.length > 1; }), st = more.get(t);
		if (!st || st.n !== rows.length) more.set(t, st = { n: rows.length, show: STEP });
		rows.forEach(function (r, i) { r.classList.toggle('more-hide', i >= st.show); });
		var foot = t.nextElementSibling && t.nextElementSibling.classList.contains('tbl-more') ? t.nextElementSibling : null;
		if (rows.length <= STEP) { if (foot) foot.remove(); return; }
		if (!foot) {
			foot = document.createElement('div');
			foot.className = 'tbl-more';
			foot.setAttribute('aria-live', 'polite');
			t.parentNode.insertBefore(foot, t.nextSibling);
		}
		var left = rows.length - st.show, txt = left > 0 ? st.show + ' / ' + rows.length + '건 · 아래로 내리면 ' + Math.min(STEP, left) + '건 더 보여요' : '전체 ' + rows.length + '건을 모두 보여 드렸어요';
		if (foot.textContent !== txt) foot.textContent = txt;
		// 숨은 표(다른 탭의 표)의 안내 줄은 같이 숨긴다
		if (foot.hidden !== !t.offsetParent) foot.hidden = !t.offsetParent;
	}

	// 화면을 잠그고 로딩 표시를 띄운다
	function lock(on) {
		if (!loadEl) {
			loadEl = document.createElement('div');
			loadEl.className = 'bo-load';
			loadEl.setAttribute('role', 'status');
			loadEl.innerHTML = '<div class="bo-load-card"><div class="bo-load-ring"></div><div>불러오는 중…</div><div class="bo-load-bar"></div></div>';
			document.body.appendChild(loadEl);
			loadEl.offsetWidth; // 처음 띄울 때도 서서히 나타나게
		}
		loadEl.classList.toggle('on', on);
	}

	function loadMore(foot) {
		var t = foot.previousElementSibling, st = t && more.get(t);
		if (!st || st.show >= st.n || busy) return;
		busy = true;
		lock(true);
		setTimeout(function () {
			st.show += STEP;
			applyMore(t);
			lock(false);
			busy = false;
			// 더 보인 뒤에도 표 끝이 화면 안이면 이어서 불러온다
			setTimeout(checkMore, 0);
		}, 450);
	}

	// 안내 줄이 화면(스크롤 상자가 있으면 그 상자) 아래 끝 가까이 왔는지. IntersectionObserver 는 가려진 탭에서 안 돌아 직접 잰다
	function checkMore() {
		[].forEach.call(document.querySelectorAll('.tbl-more'), function (foot) {
			if (!foot.offsetParent) return;
			var r = foot.getBoundingClientRect(), p = foot.parentElement.getBoundingClientRect();
			if (r.top < Math.min(window.innerHeight, p.bottom) + 60) loadMore(foot);
		});
	}
	if (BO) {
		// 표 안 스크롤은 위로 전달되지 않아 캡처 단계에서 받는다
		document.addEventListener('scroll', checkMore, true);
		window.addEventListener('resize', checkMore);
	}

	function scrollBox(el) {
		for (var p = el.parentElement; p && p !== document.body; p = p.parentElement) if (/auto|scroll/.test(getComputedStyle(p).overflowX)) return true;
		return false;
	}

	function scan() {
		[].forEach.call(document.querySelectorAll('table.table'), function (t) {
			if (BO && pickable(t)) addPicks(t);
			if (sortable(t)) [].forEach.call(t.tHead.rows[0].cells, function (th) {
				if (th.classList.contains('th-sort') || th.querySelector('input, select, button:not(.frz-pin)') || !text(th)) return;
				th.classList.add('th-sort');
				th.tabIndex = 0;
				if (!th.title) th.title = '눌러서 정렬';
			});
			// 표 칸에는 max-width 가 안 먹어서, 글만 든 긴 칸은 span 으로 감싸 …로 줄인다
			if (BO) [].forEach.call(t.querySelectorAll('tbody td'), function (td) {
				if (!td.children.length && td.textContent.length > 30) td.innerHTML = '<span class="td-cut">' + td.innerHTML + '</span>';
			});
			if (BO && !t.closest('.tbl-scroll') && !scrollBox(t)) {
				var d = document.createElement('div');
				d.className = 'tbl-scroll';
				t.parentNode.insertBefore(d, t);
				d.appendChild(t);
			}
			if (BO && moreable(t)) applyMore(t);
			if (BO && freezable(t)) freeze(t);
		});
		if (BO) { filters(); actionsTop(); checkMore(); }
	}

	// ── 틀고정 (BO 목록 표, plans/table-freeze-pick-spec.html) ──
	// 머리글은 CSS 로 늘 고정. 칸: 맨 앞부터 fc 칸(기본 체크박스+옆 1칸). 줄: 체크해서 맨 윗줄로 올린 행(top) + 그 아래 fr 줄.
	// 표 위 '📌 틀고정' 메뉴와 머리글·행 앞 📌 로 바꾸고, 화면·표마다 기억한다. 머리글이 두 줄이거나 줄 합친 표, 이미 앞 칸을 고정한 표는 칸 고정을 하지 않는다
	function freezable(t) { return pickable(t) && !t.hasAttribute('data-nofrz') && !!t.offsetParent; }
	function fKey(t) { return 'frz:' + location.pathname + ':' + (t.id || [].indexOf.call(document.querySelectorAll('table.table'), t)); }
	function fState(t) {
		if (t._frz) return t._frz;
		var s = null;
		try { s = JSON.parse(localStorage.getItem(fKey(t))); } catch (e) { s = null; }
		return (t._frz = s || { fc: -1, fr: 0, top: [], pick: false, rpick: false });
	}
	function fSave(t) { try { localStorage.setItem(fKey(t), JSON.stringify(t._frz)); } catch (e) { /* 저장 못 해도 지금 화면엔 적용 */ } }
	function fBase(t) { var h = t.tHead.rows[0].cells[0]; return h && h.querySelector('input[type=checkbox]') ? 2 : 1; }
	// 칸 고정이 맞지 않는 표: 머리글 두 줄·칸 합침, 몸통 줄 합침, 화면이 이미 앞 칸을 고정
	// 줄 합친(rowspan) 표는 행을 옮기거나 줄로 고정하면 칸이 어긋나 칸·줄 고정을 모두 끈다(머리글 고정만)
	function rowsOk(t) { return ![].some.call(t.tBodies[0].querySelectorAll('[rowspan]'), function (c) { return c.rowSpan > 1; }); }
	function colsOk(t) {
		var h = t.tHead.rows[0].cells[0];
		return rowsOk(t) && t.tHead.rows.length === 1 && !t.tHead.querySelector('[colspan]') && !(h && !h.classList.contains('frz-c') && getComputedStyle(h).left !== 'auto');
	}
	// 50줄씩 보이기로 숨은 줄도 포함(고정 행은 숨어 있어도 맨 위로 올린다)
	function fAll(t) { return [].filter.call(t.tBodies[0].rows, function (r) { return r.cells.length > 1; }); }
	function fRows(t) { return fAll(t).filter(function (r) { return !r.classList.contains('more-hide'); }); }
	function fRowKey(tr) { var b = firstBox(tr); return (b && b.getAttribute('data-key')) || rowKey(tr); }

	function freeze(t) {
		var s = fState(t), body = t.tBodies[0], head = t.tHead.rows[0], cols = colsOk(t), rok = rowsOk(t);
		if (s.fc < 0) s.fc = fBase(t);
		fBar(t);
		// 맨 윗줄 고정 행을 원래 순서대로 맨 위로(이미 그 자리면 건드리지 않아 다시 그리기가 돌지 않는다)
		var top = rok ? fAll(t).filter(function (r) { return s.top.indexOf(fRowKey(r)) >= 0; }) : [];
		top.forEach(function (r, i) { if (body.rows[i] !== r) body.insertBefore(r, body.rows[i]); });
		top.forEach(function (r) { r.classList.remove('more-hide'); });
		var rows = fRows(t);
		var x = [], y = t.tHead.offsetHeight, fc = cols ? s.fc : 0;
		for (var i = 0; i < head.cells.length; i++) x.push(i ? x[i - 1] + head.cells[i - 1].offsetWidth : 0);
		[].forEach.call(t.rows, function (tr) {
			[].forEach.call(tr.cells, function (c, ci) {
				var on = ci < fc;
				c.classList.toggle('frz-c', on);
				c.classList.toggle('frz-edge', on && ci === fc - 1);
				c.style.left = on ? x[ci] + 'px' : '';
			});
		});
		var nTop = top.length, last = rok ? nTop + Math.min(s.fr, rows.length - nTop) : 0;
		rows.forEach(function (tr, i) {
			var pin = i < nTop, upto = !pin && i < last, on = pin || upto;
			tr.classList.toggle('frz-top', pin);
			tr.classList.toggle('frz-r', upto);
			tr.classList.toggle('frz-last', on && i === last - 1);
			[].forEach.call(tr.cells, function (c) { c.style.top = on ? y + 'px' : ''; });
			if (on) y += tr.offsetHeight;
			fRowPin(t, tr, rok ? s : {}, i - nTop + 1);
		});
		[].forEach.call(head.cells, function (th, ci) {
			var p = th.querySelector('.frz-pin');
			if (!cols) { if (p) p.remove(); return; }
			if (!p) {
				p = document.createElement('button');
				p.type = 'button';
				p.className = 'frz-pin';
				th.appendChild(p);
			}
			p.setAttribute('data-c', ci + 1);
			p.setAttribute('aria-label', '맨 앞부터 ' + (text(th) || (ci + 1) + '번째') + ' 칸까지 고정');
			p.classList.toggle('on', ci + 1 === s.fc);
		});
		t.classList.toggle('frz-show-c', !!s.pick);
		fPaintBar(t);
	}
	// 줄 📌 는 '줄 직접 고르기'를 켰을 때만 넣는다(행 키 글자에 섞이지 않게 글자 없는 버튼)
	function fRowPin(t, tr, s, n) {
		var c = tr.cells[0], p = c && c.querySelector('.frz-rpin');
		if (!s.rpick || n < 1) { if (p) p.remove(); return; }
		if (!p) {
			p = document.createElement('button');
			p.type = 'button';
			p.className = 'frz-pin frz-rpin';
			c.appendChild(p);
		}
		p.setAttribute('data-r', n);
		p.setAttribute('aria-label', '맨 위부터 이 줄까지 고정');
		p.classList.toggle('on', n === s.fr);
	}

	// 표 위 오른쪽 '📌 틀고정' 버튼과 메뉴
	function fBar(t) {
		var box = t.closest('.tbl-scroll, .table-responsive, .pl-scroll') || t, bar = box.previousElementSibling;
		if (bar && bar.classList.contains('frz-bar') && bar._t === t) return;
		bar = document.createElement('div');
		bar.className = 'frz-bar';
		bar._t = t;
		bar.innerHTML = '<button type="button" class="frz-btn" aria-haspopup="true" aria-expanded="false"></button>'
			+ '<div class="frz-menu" role="menu" hidden>'
			+ '<button type="button" role="menuitem" data-a="top"></button>'
			+ '<button type="button" role="menuitem" data-a="untop">맨 윗줄 고정 풀기</button><hr>'
			+ '<button type="button" role="menuitemcheckbox" data-a="base">기본 틀고정 <small>체크박스+옆 1칸</small></button>'
			+ '<button type="button" role="menuitemcheckbox" data-a="pick">칸 직접 고르기 <small>머리글 📌</small></button>'
			+ '<button type="button" role="menuitemcheckbox" data-a="rpick">줄 직접 고르기 <small>행 앞 📌</small></button><hr>'
			+ '<button type="button" role="menuitem" data-a="off">모두 풀기</button></div>';
		box.parentNode.insertBefore(bar, box);
	}
	function fPaintBar(t) {
		var box = t.closest('.tbl-scroll, .table-responsive, .pl-scroll') || t, bar = box.previousElementSibling;
		if (!bar || bar._t !== t) return;
		var s = fState(t), cols = colsOk(t), rok = rowsOk(t), checked = fRows(t).filter(function (r) { var b = firstBox(r); return b && b.checked; }).length;
		var nRows = rok ? t.tBodies[0].querySelectorAll('tr.frz-top, tr.frz-r').length : 0, fc = cols ? s.fc : 0;
		var b = bar.querySelector('.frz-btn'), txt = '📌 틀고정' + (fc || nRows ? ' · ' + [fc && fc + '칸', nRows && nRows + '줄'].filter(Boolean).join('·') : '');
		if (b.textContent !== txt) b.textContent = txt;
		b.classList.toggle('on', !!(fc || nRows));
		function item(a) { return bar.querySelector('[data-a=' + a + ']'); }
		item('top').textContent = '⬆ 체크한 행 맨 윗줄 고정' + (checked ? ' (' + checked + ')' : '');
		item('top').disabled = !checked || !rok;
		item('untop').disabled = !s.top.length;
		[['base', s.fc === fBase(t)], ['pick', s.pick], ['rpick', s.rpick]].forEach(function (x) { item(x[0]).setAttribute('aria-checked', !!x[1]); item(x[0]).classList.toggle('ck', !!x[1]); });
		item('base').disabled = item('pick').disabled = !cols;
		item('rpick').disabled = !rok;
	}
	function fMenu(bar, open) {
		var m = bar.querySelector('.frz-menu');
		m.hidden = !open;
		bar.querySelector('.frz-btn').setAttribute('aria-expanded', open);
		if (open) fPaintBar(bar._t);
	}
	function fDo(t, a) {
		var s = fState(t);
		if (a === 'top') {
			// 체크한 행: 고정 안 된 건 덧붙이고, 이미 고정된 건 푼다. 고정한 뒤 체크는 푼다
			fRows(t).forEach(function (r) {
				var b = firstBox(r);
				if (!b || !b.checked) return;
				var k = fRowKey(r), i = s.top.indexOf(k);
				if (i >= 0) s.top.splice(i, 1); else s.top.push(k);
				b.checked = false;
				b.dispatchEvent(new Event('change', { bubbles: true }));
			});
		}
		if (a === 'untop') s.top = [];
		if (a === 'base') s.fc = s.fc === fBase(t) ? 0 : fBase(t);
		if (a === 'pick') s.pick = !s.pick;
		if (a === 'rpick') s.rpick = !s.rpick;
		if (a === 'off') { s.fc = 0; s.fr = 0; s.top = []; s.pick = s.rpick = false; }
		fSave(t);
		freeze(t);
	}
	if (BO) {
		document.addEventListener('click', function (e) {
			var tg = e.target, bar = tg.closest && tg.closest('.frz-bar');
			[].forEach.call(document.querySelectorAll('.frz-bar'), function (x) { if (x !== bar) fMenu(x, false); });
			if (bar) {
				if (tg.closest('.frz-btn')) fMenu(bar, bar.querySelector('.frz-menu').hidden);
				var it = tg.closest('.frz-menu [data-a]');
				if (it && !it.disabled) { fDo(bar._t, it.getAttribute('data-a')); if (it.getAttribute('data-a') === 'top') fMenu(bar, false); }
				return;
			}
			var p = tg.closest && tg.closest('.frz-pin');
			if (!p) return;
			e.preventDefault();
			e.stopPropagation();
			var t = p.closest('table'), s = fState(t);
			if (p.hasAttribute('data-r')) { var n = +p.getAttribute('data-r'); s.fr = n === s.fr ? 0 : n; }
			else { var c = +p.getAttribute('data-c'); s.fc = c === s.fc ? 0 : c; }
			fSave(t);
			freeze(t);
		}, true);
		document.addEventListener('keydown', function (e) { if (e.key === 'Escape') [].forEach.call(document.querySelectorAll('.frz-bar'), function (x) { fMenu(x, false); }); });
		window.addEventListener('resize', function () { [].forEach.call(document.querySelectorAll('table.table'), function (t) { if (t._frz && freezable(t)) freeze(t); }); });
		// 체크하면 메뉴의 '체크한 행' 건수를 맞춘다
		document.addEventListener('change', function (e) { var t = e.target.closest && e.target.closest('table'); if (t && t._frz) fPaintBar(t); });
	}

	// ── 아래 끝 버튼 줄(중간 저장·마감·목록 등)을 그 칸의 맨 위로 ──
	// 버튼만 든 줄이 칸의 마지막이고 칸 위에서 200px 넘게 떨어져 있으면 옮긴다. 팝업·표·폼·입력칸 줄·고정 바는 그대로
	function actionsTop() {
		[].forEach.call(document.querySelectorAll('.content-wrapper div, .content-wrapper footer'), function (e) {
			var p = e.parentElement;
			if (!p || e.classList.contains('bo-act-top') || e !== p.lastElementChild || p.firstElementChild === e) return;
			if (!e.children.length || [].some.call(e.children, function (k) { return !k.matches('.btn, button'); })) return;
			if (e.closest('.modal, table, form, .form-row, .btn-group, .input-group, .dropdown-menu, .eg-tour')) return;
			if (/sticky|fixed|absolute/.test(getComputedStyle(e).position)) return;
			var er = e.getBoundingClientRect(), pr = p.getBoundingClientRect();
			if (!er.height || er.top - pr.top < 200) return;
			e.classList.add('bo-act-top');
			p.insertBefore(e, p.firstElementChild);
		});
	}

	// ── 검색필터 접기 ──
	function filters() {
		[].forEach.call(document.querySelectorAll('.content-wrapper .cal-panel-body > .form-row:first-child'), function (row, i) {
			if (row.getAttribute('data-flt') || row.closest('.modal') || !row.querySelector('input[type=search]') || !row.querySelector('select')) return;
			row.setAttribute('data-flt', '1');
			var body = row.parentNode, store = 'flt:' + location.pathname + ':' + i;
			// 검색어·기간·버튼·data-keep 칸은 접어도 남긴다
			[].forEach.call(row.children, function (c) {
				if (!c.querySelector('input[type=search], input[type=month], input[type=date], .btn, [data-keep]') && !c.hasAttribute('data-keep')) c.classList.add('flt-more');
			});
			// 접으면 라벨이 숨으므로 검색칸 안내문으로 옮긴다
			[].forEach.call(row.querySelectorAll('input[type=search]'), function (inp) {
				var l = inp.id && row.querySelector('label[for="' + inp.id + '"]');
				if (l && !inp.placeholder) inp.placeholder = l.textContent.trim();
			});
			var col = document.createElement('div'), btn = document.createElement('button');
			col.className = 'col-auto mb-2 flt-tg';
			btn.type = 'button';
			btn.className = 'btn btn-sm btn-outline-secondary';
			col.appendChild(btn);
			row.appendChild(col);
			function on(v) { try { return v === undefined ? localStorage.getItem(store) : localStorage.setItem(store, v); } catch (e) { return null; } }
			function paint() {
				var closed = body.classList.contains('flt-closed');
				var used = [].filter.call(row.querySelectorAll('.flt-more select'), function (s) { return s.selectedIndex > 0 && s.value !== ''; }).length;
				btn.textContent = closed ? '▾ 필터' + (used ? ' (' + used + '개 적용)' : '') : '▴ 접기';
				btn.setAttribute('aria-expanded', !closed);
				btn.classList.toggle('btn-warning', closed && used > 0);
			}
			btn.addEventListener('click', function () { body.classList.toggle('flt-closed'); on(body.classList.contains('flt-closed') ? '1' : '0'); paint(); });
			row.addEventListener('change', paint);
			// 처음은 접힌 상태(표를 더 많이 보이게). 화면마다 마지막 상태를 기억
			body.classList.toggle('flt-closed', on() !== '0');
			paint();
		});
	}

	// ── 체크박스·체크한 줄 강조 (BO 목록 표) ──
	// 체크박스가 없는 표는 맨 앞에 칸을 넣고, 화면이 직접 넣은 체크박스가 있는 표는 강조만 한다.
	// 표를 다시 그려도 앞쪽 칸 글자로 같은 줄을 찾아 체크를 살린다(새로고침하면 지워진다). 팝업 안 표·data-nopick 표는 빼고, 줄 합친(rowspan) 줄은 하나로 본다
	var picked = {};
	function pickable(t) {
		return !!(t.tHead && t.tHead.rows.length && t.tBodies.length === 1 && !t.hasAttribute('data-nopick') && !t.classList.contains('dataTable') && t.closest('.content-wrapper') && !t.closest('.modal'));
	}
	function firstBox(tr) { var c = tr.cells[0]; return c && c.tagName === 'TD' && c.querySelector('input[type=checkbox]'); }
	// 체크 칸을 뺀 앞쪽 네 칸 글자
	function rowKey(tr) { return [].filter.call(tr.cells, function (c) { return !c.classList.contains('tp-pick'); }).slice(0, 4).map(text).join('|'); }
	function store(t) { var i = [].indexOf.call(document.querySelectorAll('table.table'), t), k = location.pathname + ':' + (t.id || i); return picked[k] || (picked[k] = {}); }
	// 줄과 그 줄이 rowspan 으로 덮는 아래 줄들
	function block(tr) { var out = [tr], n = tr.cells[0] ? tr.cells[0].rowSpan : 1; for (var r = tr; --n > 0 && (r = r.nextElementSibling);) out.push(r); return out; }

	function addPicks(t) {
		var rows = t.tBodies[0].rows, h0 = t.tHead.rows[0].cells[0];
		// 화면이 직접 넣은 체크박스가 있으면 칸은 넣지 않는다(먼저 넣어 둔 것이 있으면 걷어 낸다)
		var own = (h0 && h0.querySelector('input[type=checkbox]:not(.tp-all)')) || [].some.call(rows, function (r) { var b = firstBox(r); return b && !b.classList.contains('tp-row'); });
		if (own) { [].forEach.call(t.querySelectorAll('.tp-pick'), function (c) { c.remove(); }); return; }
		// 아직 그리기 전(빈 표, 안내 한 줄뿐)이면 기다린다
		var hr = t.tHead.rows[0], set = store(t);
		if (!hr.querySelector('.tp-pick') && ![].some.call(rows, function (r) { return r.cells.length > 1; })) return;
		if (!hr.querySelector('.tp-pick')) {
			var th = document.createElement('th');
			th.className = 'tp-pick';
			th.setAttribute('data-c', '_PICK');
			th.rowSpan = t.tHead.rows.length;
			th.innerHTML = '<input type="checkbox" class="tp-all" aria-label="보이는 줄 전체 선택">';
			hr.insertBefore(th, hr.firstChild);
		}
		for (var i = 0, cover = 0; i < rows.length; i++) {
			var r = rows[i];
			if (cover > 0) { cover--; continue; }
			if (r.getAttribute('data-tp') === 'msg') continue;
			var pc = r.cells[0] && r.cells[0].classList.contains('tp-pick') ? r.cells[0] : null;
			if (!pc) {
				// '목록이 없습니다' 같은 한 칸 줄은 칸만 늘린다
				if (r.cells.length === 1 && r.cells[0].colSpan > 1) { r.cells[0].colSpan += 1; r.setAttribute('data-tp', 'msg'); continue; }
				pc = document.createElement('td');
				pc.className = 'tp-pick';
				pc.setAttribute('data-c', '_PICK');
				pc.rowSpan = r.cells[0] ? r.cells[0].rowSpan : 1;
				if (!/edit|form/.test(r.className)) {
					var key = rowKey(r), cb = document.createElement('input');
					cb.type = 'checkbox';
					cb.className = 'tp-row';
					cb.setAttribute('data-key', key);
					cb.setAttribute('aria-label', (key.split('|')[0] || '줄') + ' 선택');
					cb.checked = !!set[key];
					pc.appendChild(cb);
				}
				r.insertBefore(pc, r.firstChild);
			}
			cover = pc.rowSpan - 1;
		}
		paintPicks();
	}

	// 체크 상태를 줄 강조·전체 선택·기억에 맞춘다. 화면이 체크를 코드로 바꿔도(change 없이) 다음 change 때 맞춰진다
	function paintPicks() {
		[].forEach.call(document.querySelectorAll('.content-wrapper table.table > tbody > tr'), function (tr) {
			var b = firstBox(tr);
			if (!b || tr.closest('.modal')) return;
			block(tr).forEach(function (x) { x.classList.toggle('tp-on', b.checked); });
			if (b.classList.contains('tp-row')) store(tr.closest('table'))[b.getAttribute('data-key')] = b.checked;
		});
		[].forEach.call(document.querySelectorAll('input.tp-all'), function (a) {
			var all = a.closest('table').querySelectorAll('tbody tr:not(.more-hide) input.tp-row');
			a.checked = all.length > 0 && [].every.call(all, function (x) { return x.checked; });
		});
	}
	document.addEventListener('change', function (e) {
		if (e.target.classList && e.target.classList.contains('tp-all')) {
			[].forEach.call(e.target.closest('table').querySelectorAll('tbody tr:not(.more-hide) input.tp-row'), function (x) { x.checked = e.target.checked; });
		}
		if (e.target.type === 'checkbox') setTimeout(paintPicks, 0);
	});
	if (BO) {
		var css = document.createElement('style');
		css.textContent = '.tp-pick{width:30px;text-align:center;padding-left:8px!important;padding-right:4px!important}'
			+ 'tr.tp-on{outline:2px solid #2563eb;outline-offset:-2px}tr.tp-on>td{background-color:#eef4ff}'
			+ 'tr.more-hide{display:none}.tbl-more{padding:9px 12px;text-align:center;font-size:12px;color:#5f6b75}'
			+ '.bo-load{position:fixed;top:0;right:0;bottom:0;left:0;z-index:3000;display:flex;align-items:center;justify-content:center;background:rgba(15,23,42,.32);-webkit-backdrop-filter:blur(2px);backdrop-filter:blur(2px);opacity:0;pointer-events:none;transition:opacity .15s}'
			+ '.bo-load.on{opacity:1;pointer-events:auto;cursor:progress}'
			+ '.bo-load-card{display:flex;flex-direction:column;align-items:center;gap:12px;padding:22px 32px 20px;border-radius:16px;background:#fff;box-shadow:0 12px 40px rgba(15,23,42,.25);font-weight:700;font-size:13px;color:#33505c}'
			+ '.bo-load-ring{width:46px;height:46px;border-radius:50%;background:conic-gradient(#16d5ff,#0b6e8a,#6b3fa0,#16d5ff);-webkit-mask:radial-gradient(farthest-side,transparent calc(100% - 6px),#000 calc(100% - 5px));mask:radial-gradient(farthest-side,transparent calc(100% - 6px),#000 calc(100% - 5px));animation:bo-spin .8s linear infinite}'
			+ '.bo-load-bar{width:150px;height:4px;border-radius:4px;background:#e6eef2;overflow:hidden}'
			+ '.bo-load-bar::after{content:"";display:block;width:40%;height:100%;border-radius:4px;background:linear-gradient(90deg,#16d5ff,#6b3fa0);animation:bo-slide .9s ease-in-out infinite}'
			+ '@keyframes bo-spin{to{transform:rotate(360deg)}}@keyframes bo-slide{from{transform:translateX(-100%)}to{transform:translateX(250%)}}'
			+ '@media (prefers-reduced-motion:reduce){.bo-load-ring{animation-duration:2.4s}.bo-load-bar::after{animation-duration:2.7s}}'
			// 틀고정: 고정 칸 하늘색·파란 세로선, 맨 윗줄 고정 행 노란색, 줄 고정 하늘색·마지막 줄 아래 선. 화면의 줄 색(체크·시크릿 등)이 우선
			+ '.frz-bar{display:flex;justify-content:flex-end;position:relative;margin:0 0 2px}'
			+ '.frz-btn{border:1px solid #ccd3d9;background:#fff;border-radius:6px;padding:0 8px;font-size:11.5px;line-height:20px;color:#5f6b75}'
			+ '.frz-btn.on{border-color:#0b6e8a;color:#0b6e8a;background:#eef9fc;font-weight:700}'
			+ '.frz-menu{position:absolute;right:0;top:24px;z-index:20;background:#fff;border:1px solid #ccd3d9;border-radius:8px;box-shadow:0 6px 18px rgba(0,0,0,.12);padding:4px;min-width:240px}'
			+ '.frz-menu button{display:flex;width:100%;gap:8px;align-items:center;border:0;background:none;text-align:left;padding:5px 8px 5px 24px;border-radius:6px;font-size:12.5px;position:relative}'
			+ '.frz-menu button:hover:not(:disabled){background:#f1f4f6}.frz-menu button:disabled{color:#b3bac1}'
			+ '.frz-menu button.ck::before{content:"✓";position:absolute;left:8px;color:#0b6e8a;font-weight:700}'
			+ '.frz-menu small{color:#8a949c;margin-left:auto}.frz-menu hr{margin:4px 0;border-top:1px solid #eef0f2}'
			+ '.table .frz-c{position:sticky;z-index:1;background-color:#f3fbfd}.table thead .frz-c{z-index:4;background-color:#eef7fa}'
			+ '.table .frz-edge{box-shadow:inset -2px 0 0 #0b6e8a}'
			+ '.table tr.frz-top>td,.table tr.frz-r>td{position:sticky;z-index:2}.table tr.frz-top>td.frz-c,.table tr.frz-r>td.frz-c{z-index:3}'
			+ '.table tr.frz-top>td{background-color:#fff8e3}.table tr.frz-r>td{background-color:#eef9fc}'
			+ '.table tr.frz-last>td{box-shadow:inset 0 -2px 0 #0b6e8a}.table tr.frz-top.frz-last>td{box-shadow:inset 0 -2px 0 #e0a800}.table tr.frz-last>td.frz-edge{box-shadow:inset -2px -2px 0 #0b6e8a}'
			+ '.frz-pin{border:0;background:none;padding:0 2px;margin-left:3px;font-size:10px;line-height:1;color:#9aa4ac;opacity:0;vertical-align:middle;cursor:pointer}'
			+ '.frz-pin::before{content:"📌"}th:hover>.frz-pin,.frz-pin:focus,.frz-pin.on,.frz-show-c th>.frz-pin,.frz-rpin{opacity:1}.frz-pin.on{filter:none;color:#0b6e8a}.frz-pin:not(.on){filter:grayscale(1)}';
		document.head.appendChild(css);
	}

	var timer = null;
	function later() { clearTimeout(timer); timer = setTimeout(scan, 120); }

	document.addEventListener('click', function (e) {
		var th = e.target.closest && e.target.closest('th.th-sort');
		if (th && !e.target.closest('button, a, input, select, label')) sortBy(th);
	});
	document.addEventListener('keydown', function (e) {
		if ((e.key === 'Enter' || e.key === ' ') && e.target.matches && e.target.matches('th.th-sort')) { e.preventDefault(); sortBy(e.target); }
	});
	// 글이 잘린 칸은 올리면 전체 글
	document.addEventListener('mouseover', function (e) {
		var c = e.target.closest && e.target.closest('.td-cut');
		if (c && !c.title && c.scrollWidth > c.clientWidth + 1) c.title = c.textContent.replace(/\s+/g, ' ').trim();
	});

	function start() {
		scan();
		new MutationObserver(later).observe(document.body, { childList: true, subtree: true });
	}
	if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start); else start();
})();
