/*
 * 모든 표 공통 (BO·FO)
 * - 머리글을 누르면(또는 Enter) 그 칸으로 정렬, 다시 누르면 반대로. 빈 칸은 항상 아래
 * - BO: 표를 스크롤 상자에 넣어 머리글 고정·가로 스크롤이 되게 하고, 잘린 칸은 올리면 전체 글
 * - BO: 검색필터 줄(.cal-panel-body 첫 줄)을 접고 편다. 접으면 검색어·기간·버튼만 한 줄
 * - BO: 목록 표 맨 앞 체크박스(없으면 넣음)와 체크한 줄 파란 테두리 강조
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
		if (t.tHead.querySelector('.pl-sort, [colspan], [rowspan], [draggable]') || t.tBodies[0].querySelector('[rowspan]')) return false;
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
	}

	function scrollBox(el) {
		for (var p = el.parentElement; p && p !== document.body; p = p.parentElement) if (/auto|scroll/.test(getComputedStyle(p).overflowX)) return true;
		return false;
	}

	function scan() {
		[].forEach.call(document.querySelectorAll('table.table'), function (t) {
			if (BO && pickable(t)) addPicks(t);
			if (sortable(t)) [].forEach.call(t.tHead.rows[0].cells, function (th) {
				if (th.classList.contains('th-sort') || th.querySelector('input, select, button') || !text(th)) return;
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
		});
		if (BO) { filters(); actionsTop(); }
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
			var all = a.closest('table').querySelectorAll('tbody input.tp-row');
			a.checked = all.length > 0 && [].every.call(all, function (x) { return x.checked; });
		});
	}
	document.addEventListener('change', function (e) {
		if (e.target.classList && e.target.classList.contains('tp-all')) {
			[].forEach.call(e.target.closest('table').querySelectorAll('tbody input.tp-row'), function (x) { x.checked = e.target.checked; });
		}
		if (e.target.type === 'checkbox') setTimeout(paintPicks, 0);
	});
	if (BO) {
		var css = document.createElement('style');
		css.textContent = '.tp-pick{width:30px;text-align:center;padding-left:8px!important;padding-right:4px!important}'
			+ 'tr.tp-on{outline:2px solid #2563eb;outline-offset:-2px}tr.tp-on>td{background-color:#eef4ff}';
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
