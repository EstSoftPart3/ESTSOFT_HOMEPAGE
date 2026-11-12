/*
 * 모든 표 공통 (BO·FO)
 * - 머리글을 누르면(또는 Enter) 그 칸으로 정렬, 다시 누르면 반대로. 빈 칸은 항상 아래
 * - BO: 표를 스크롤 상자에 넣어 머리글 고정·가로 스크롤이 되게 하고, 잘린 칸은 올리면 전체 글
 * - BO: 검색필터 줄(.cal-panel-body 첫 줄)을 접고 편다. 접으면 검색어·기간·버튼만 한 줄
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
		rows.map(function (r, i) { return { r: r, k: key(text(r.cells[idx])), i: i }; }).sort(function (x, y) {
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
		if (BO) filters();
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
