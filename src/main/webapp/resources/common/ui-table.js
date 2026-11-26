/*
 * 모든 표 공통 (BO·FO)
 * - 머리글을 누르면(또는 Enter) 그 칸으로 정렬, 다시 누르면 반대로. 빈 칸은 항상 아래
 * - 가로로 넘치는 표는 표 위에도 가로 스크롤바(아래 것과 같이 움직임)
 * - BO: 표를 스크롤 상자에 넣어 머리글 고정·가로 스크롤이 되게 하고, 잘린 칸은 올리면 전체 글
 * - BO: 검색필터 줄(.cal-panel-body 첫 줄)을 접고 편다. 접으면 검색어·기간·버튼만 한 줄
 * - BO: 목록 표 맨 앞 체크박스(없으면 넣음)와 체크한 줄 파란 테두리 강조
 * - BO: 목록은 50줄씩, 표 끝까지 내리면 로딩 화면 뒤 50줄 더(월별 화면 제외)
 * - BO: 머리글을 끌어(또는 Alt+←/→) 칸 위치를 바꾼다. 화면·표마다 기억
 * 화면이 직접 정렬을 그리는 표(.pl-sort), 하위 줄이 있는 표, data-nosort 표는 정렬을 건드리지 않는다. 줄 합친(rowspan) 표는 메인 줄 기준으로 묶음째 정렬한다.
 */
(function () {
	var BO = !!document.querySelector('.content-wrapper');
	var NUM = /^[-+]?[\d,]*\.?\d+\s*(원|%|일|건|개월|명|개|년|시간)?$/;
	// 폰 폭(767px 이하)일 때만 카드·필터 접기를 바꾼다. 데스크톱 동작은 그대로
	var MQ = window.matchMedia ? window.matchMedia('(max-width: 767px)') : null;
	function mob() { return !!(MQ && MQ.matches); }

	function text(c) { return c ? (c.getAttribute('data-sort') || c.textContent).replace(/\s+/g, ' ').trim() : ''; }
	function key(s) { return NUM.test(s) ? parseFloat(s.replace(/[^\d.+-]/g, '')) : s; }
	function cmp(a, b) { return typeof a === 'number' && typeof b === 'number' ? a - b : String(a).localeCompare(String(b), 'ko', { numeric: true }); }

	function sortable(t) {
		if (!t || t.hasAttribute('data-nosort') || t.classList.contains('dataTable') || !t.tHead || t.tHead.rows.length !== 1 || t.tBodies.length !== 1) return false;
		// 체크 칸 머리글의 rowspan="1" 같은 1 짜리는 합친 칸이 아니다
		function span(c) { return c.rowSpan > 1 || c.colSpan > 1; }
		if (t.tHead.querySelector('.pl-sort, [draggable]:not(.th-move)') || [].some.call(t.tHead.querySelectorAll('[colspan], [rowspan]'), span)) return false;
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
		// 줄 합친(rowspan) 표: 메인 줄과 그 줄이 덮는 아래 줄을 한 묶음으로 보고, 메인 줄 값으로만 비교해 묶음째 옮긴다
		var all = [], src = [].slice.call(b.rows);
		for (var i = 0; i < src.length;) {
			var sp = Math.max.apply(null, [1].concat([].map.call(src[i].cells, function (c) { return c.rowSpan; })));
			all.push(src.slice(i, i + sp));
			i += sp;
		}
		var rows = all.filter(function (g) { return g[0].cells.length === n; });
		// 시크릿 줄(tr 의 dp-secret·pl-secret·ps-secret·st-secret-row)은 어느 칸으로 정렬해도 맨 위에 둔다
		function pin(r) { return /(^|\s)[\w-]*secret[\w-]*(\s|$)/.test(r.className) ? 0 : 1; }
		rows.map(function (g, i) { return { g: g, r: g[0], k: key(text(g[0].cells[idx])), i: i }; }).sort(function (x, y) {
			if (pin(x.r) !== pin(y.r)) return pin(x.r) - pin(y.r);
			if (x.k === '' || y.k === '') return (x.k === '') - (y.k === '') || x.i - y.i;
			return dir * cmp(x.k, y.k) || x.i - y.i;
		}).forEach(function (o) { o.g.forEach(function (r) { b.appendChild(r); }); });
		// '목록이 없습니다' 같은 줄은 아래에 그대로
		all.filter(function (g) { return g[0].cells.length !== n; }).forEach(function (g) { g.forEach(function (r) { b.appendChild(r); }); });
		if (more.has(t)) applyMore(t);
	}

	// ── 50줄씩 더 보이기 (BO 목록 표) ──
	// 줄은 화면이 전부 그려 두고, 여기서 50줄 넘는 줄을 숨겼다가 표 끝이 보이면 로딩 화면을 잠깐 띄우고 50줄을 더 보인다.
	// 월별 화면(기준월 칸이 있는 화면)·팝업 안 표·줄 합친 표·data-nomore 표는 빼고, 줄 수가 달라지면(검색·탭 바꿈) 처음 50줄로 돌아간다
	var STEP = 50, more = new WeakMap(), monthly = null, loadEl = null;

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

	// 화면을 잠그고 로딩 표시를 띄운다. 서버 호출이 0.3초 넘게 걸리는(netOn) 동안 켜 둔다
	var netN = 0, netOn = false, netTimer = null;
	function lock() {
		var on = netOn;
		if (!loadEl) {
			if (!on) return;
			loadEl = document.createElement('div');
			loadEl.className = 'bo-load';
			loadEl.setAttribute('role', 'status');
			loadEl.innerHTML = '<div class="bo-load-card"><div class="bo-load-ring"></div><div class="bo-load-txt"></div><div class="bo-load-bar"></div></div>';
			document.body.appendChild(loadEl);
			loadEl.offsetWidth; // 처음 띄울 때도 서서히 나타나게
		}
		if (on) loadEl.querySelector('.bo-load-txt').textContent = loadMsg || (netOn ? '처리 중…' : '불러오는 중…');
		loadEl.classList.toggle('on', on);
	}
	// 화면이 진행 안내(예: 2/5 올리는 중)를 로딩 카드에 대신 보이게 한다. 빈 값이면 기본 글로 돌아간다
	var loadMsg = '';
	window.boLoadText = function (t) {
		loadMsg = t || '';
		if (loadEl && loadEl.classList.contains('on')) loadEl.querySelector('.bo-load-txt').textContent = loadMsg || '처리 중…';
	};

	// ── 서버 호출 중 로딩 (BO·FO) ──
	// 저장·조회·업로드가 0.3초 넘게 걸리면 화면을 잠그고, 진행 중인 호출이 모두 끝나면 푼다. 바로 끝나는 호출에는 띄우지 않는다.
	// jQuery 호출(global:false 제외)과 fetch 를 센다. shortcut: XMLHttpRequest 를 직접 쓰는 곳(파일 줄이기 도구)은 자체 진행 표시가 있어 뺐다
	function net(d) {
		netN = Math.max(0, netN + d);
		if (netN && !netOn && !netTimer) netTimer = setTimeout(function () { netTimer = null; if (netN) { netOn = true; lock(); } }, 300);
		if (!netN) { clearTimeout(netTimer); netTimer = null; if (netOn) { netOn = false; lock(); } }
	}
	function watchNet() {
		if (window.jQuery) window.jQuery(document).on('ajaxSend', function () { net(1); }).on('ajaxComplete', function () { net(-1); });
		if (window.fetch) {
			var raw = window.fetch;
			window.fetch = function () {
				net(1);
				var p = raw.apply(this, arguments);
				p.then(function () { net(-1); }, function () { net(-1); });
				return p;
			};
		}
	}

	function loadMore(foot) {
		var t = foot.previousElementSibling, st = t && more.get(t);
		if (!st || st.show >= st.n) return;
		// 이미 받은 줄을 더 보이는 것이라 잠그지 않는다(스크롤·크기 신호만으로 저절로 로딩 창이 뜨던 원인)
		st.show += STEP;
		applyMore(t);
		// 더 보인 뒤에도 표 끝이 화면 안이면 이어서 붙인다
		setTimeout(checkMore, 0);
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
			if (BO && movable(t)) { arrange(t); mMark(t); }
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
			if (BO && (mob() || t.classList.contains('cd-on'))) card(t);
			topBar(t);
			if (BO && freezable(t)) freeze(t);
			// 카드일 때 표 위 '📌 틀고정' 은 숨긴다(같은 줄의 '보기' 는 남김)
			var fb = BO && anchor(t.closest('.tbl-scroll, .table-responsive, .pl-scroll') || t).previousElementSibling;
			if (fb && fb._t === t) fb.classList.toggle('cd-bar', t.classList.contains('cd-on'));
		});
		// 틀고정·글꼴이 자리 잡은 뒤 폭이 조금 달라져 한 번 더 잰다
		sizeTops();
		setTimeout(sizeTops, 300);
		if (BO) { filters(); pinFilter(); actionsTop(); checkMore(); }
	}

	// ── 칸 위치 이동 (BO 목록 표, plans/list-common-all-spec.html) ──
	// 머리글을 끌어 놓거나 Alt+←/→ 로 칸 순서를 바꾸고, 화면·표·머리글 구성마다 이 브라우저에 기억한다. 맨 앞 체크 칸은 그대로.
	// 머리글 두 줄·칸/줄 합친 표, 합계 줄(tfoot)·colgroup 이 있는 표, 화면이 직접 칸을 옮기는 표([draggable]), data-nocol 표는 뺀다.
	// 화면은 줄을 늘 원래 순서로 그린다. 칸마다 원래 번호(_ci)를 붙여 두고, 번호 없는 줄(새로 그린 줄)은 원래 순서로 보고 옮긴다
	function movable(t) {
		return pickable(t) && !t.hasAttribute('data-nocol') && colsOk(t) && !t.querySelector('colgroup') && !(t.tFoot && t.tFoot.rows.length)
			&& !t.tHead.querySelector('[draggable]:not(.th-move)');
	}
	function mCells(tr) {
		var cs = [].filter.call(tr.cells, function (c) { return !c.classList.contains('tp-pick'); });
		if (cs.some(function (c) { return c._ci === undefined; })) cs.forEach(function (c, i) { c._ci = i; });
		return cs;
	}
	// 머리글 글자(정렬 ▲▼ 같은 버튼 글자는 뺀다)
	function hText(th) { return [].map.call(th.childNodes, function (x) { return x.nodeType === 3 ? x.nodeValue : x.tagName === 'BUTTON' ? '' : x.textContent; }).join('').replace(/\s+/g, ' ').trim(); }
	// 글자가 없거나 같은 칸은 번호를 붙여 구분
	function mKeys(ths) {
		var seen = {};
		return ths.map(function (th, i) {
			var k = hText(th);
			if (!k || seen[k]) k += '#' + i;
			seen[k] = 1;
			return k;
		});
	}
	function mState(t) {
		var ths = mCells(t.tHead.rows[0]).slice().sort(function (a, b) { return a._ci - b._ci; }), keys = mKeys(ths), sig = keys.join('|');
		if (t._col && t._col.sig === sig) return t._col;
		for (var h = 0, i = 0; i < sig.length; i++) h = (h * 31 + sig.charCodeAt(i)) | 0;
		var s = { sig: sig, keys: keys, store: 'col:' + location.pathname + ':' + (t.id || [].indexOf.call(document.querySelectorAll('table.table'), t)) + ':' + (h >>> 0).toString(36) }, saved = null;
		try { saved = JSON.parse(localStorage.getItem(s.store)); } catch (e) { saved = null; }
		s.moved = !!saved;
		s.ord = (saved || []).map(function (k) { return keys.indexOf(k); }).filter(function (x) { return x >= 0; });
		// 저장한 순서에 없는 칸(새로 생긴 칸)은 원래 앞 칸 바로 뒤에 둔다
		keys.forEach(function (k, x) { if (s.ord.indexOf(x) < 0) s.ord.splice(x ? s.ord.indexOf(x - 1) + 1 : 0, 0, x); });
		return (t._col = s);
	}
	// 이미 그 순서면 건드리지 않는다(다시 그리기가 돌지 않게). 칸 수가 다른 줄('목록이 없습니다' 등)은 그대로
	function arrange(t) {
		var s = mState(t), n = s.ord.length;
		[].forEach.call(t.rows, function (tr) {
			if (tr.cells.length - (tr.cells[0] && tr.cells[0].classList.contains('tp-pick') ? 1 : 0) !== n) return;
			var cs = mCells(tr), by = {};
			if (cs.every(function (c, i) { return c._ci === s.ord[i]; })) return;
			cs.forEach(function (c) { by[c._ci] = c; });
			s.ord.forEach(function (ci) { if (by[ci]) tr.appendChild(by[ci]); });
		});
	}
	function mMark(t) {
		[].forEach.call(t.tHead.rows[0].cells, function (th) {
			if (th.classList.contains('th-move') || th.classList.contains('tp-pick') || th.querySelector('input, select') || !text(th)) return;
			th.classList.add('th-move');
			th.draggable = true;
			th.tabIndex = 0;
			th.title = (th.title ? th.title + ' · ' : '') + '끌어서 칸 이동(Alt+←/→)';
		});
	}
	function mMove(t, from, to, after) {
		var s = mState(t);
		s.ord.splice(s.ord.indexOf(from._ci), 1);
		s.ord.splice(s.ord.indexOf(to._ci) + (after ? 1 : 0), 0, from._ci);
		mSave(t);
	}
	function mSave(t) {
		var s = mState(t);
		s.moved = true;
		try { localStorage.setItem(s.store, JSON.stringify(s.ord.map(function (x) { return s.keys[x]; }))); } catch (e) { /* 저장 못 해도 지금 화면엔 적용 */ }
		arrange(t);
		if (freezable(t)) freeze(t);
		if (t.classList.contains('cd-on')) card(t);
	}
	// '보기' 창(bo-view.js)의 칸 순서 ▲▼ 용. 체크박스 칸은 목록에서 빼고 옮기지 않는다
	function mFixed(t, ci) { var th = mCells(t.tHead.rows[0]).filter(function (c) { return c._ci === ci; })[0]; return !th || !!th.querySelector('input[type=checkbox]'); }
	window.boCols = {
		list: function (t) {
			if (!t || !movable(t)) return null;
			var s = mState(t);
			return s.ord.filter(function (ci) { return !mFixed(t, ci); }).map(function (ci) { return { ci: ci, name: s.keys[ci].replace(/#\d+$/, '') }; });
		},
		move: function (t, ci, d) {
			var s = mState(t), pos = s.ord.map(function (x, i) { return i; }).filter(function (i) { return !mFixed(t, s.ord[i]); });
			var k = pos.indexOf(s.ord.indexOf(ci)), a = pos[k], b = pos[k + d];
			if (k < 0 || b === undefined) return;
			s.ord[a] = s.ord[b];
			s.ord[b] = ci;
			mSave(t);
		}
	};

	// ── 폰 카드 (폭 767px 이하, plans/mobile-ux-spec.html 2번) ──
	// 줄마다 칸에 머리글을 data-label 로 붙이고, 체크 칸을 뺀 앞 4칸만 보인다(첫 칸은 제목, 체크 칸은 오른쪽 위). 모양은 아래 CSS @media 안에만 있다.
	// 칸을 눌러 바로 고치는 표(.hr-cell·입력칸), 머리글 두 줄·칸/줄 합친 표, data-no-card 안의 표는 카드로 바꾸지 않고 가로 스크롤 그대로
	function cardable(t) {
		return pickable(t) && t.tHead.rows.length === 1 && rowsOk(t) && ![].some.call(t.tHead.rows[0].cells, function (c) { return c.colSpan > 1; })
			&& !t.closest('[data-no-card]') && !t.tBodies[0].querySelector('.hr-cell, input:not([type=checkbox]):not([type=hidden]), select, textarea');
	}
	function card(t) {
		var on = mob() && cardable(t);
		t.classList.toggle('cd-on', on);
		if (!on) return;
		var hc = [].slice.call(t.tHead.rows[0].cells), pk = hc[0] && hc[0].querySelector('input[type=checkbox]') ? 1 : 0, names = hc.map(hText);
		[].forEach.call(t.tBodies[0].rows, function (tr) {
			// 체크 칸을 아직 못 넣은 줄(방금 다시 그린 줄)은 한 칸 밀어서 맞춘다. 칸 수가 다른 줄('목록이 없습니다')은 그대로
			var cs = tr.cells, off = cs.length === hc.length ? 0 : pk && cs.length === hc.length - 1 ? 1 : -1;
			if (off < 0) return;
			[].forEach.call(cs, function (c, i) {
				var k = i + off - pk;
				if (c.getAttribute('data-label') !== names[i + off]) c.setAttribute('data-label', names[i + off]);
				c.classList.toggle('cd-pk', k < 0);
				c.classList.toggle('cd-1', k === 0);
				c.classList.toggle('cd-x', k >= 4);
			});
		});
	}
	if (BO) {
		var mDrag = null;
		var mClear = function () { [].forEach.call(document.querySelectorAll('.th-drop-l, .th-drop-r, .th-drag'), function (x) { x.classList.remove('th-drop-l', 'th-drop-r', 'th-drag'); }); };
		// 끌어 놓을 자리: 같은 머리글 줄의 다른 칸(체크 칸 제외). 칸의 오른쪽 절반이면 그 뒤
		var mOver = function (e) {
			var th = mDrag && e.target.closest && e.target.closest('th');
			if (!th || th === mDrag || th.parentNode !== mDrag.parentNode || th.classList.contains('tp-pick')) return null;
			var r = th.getBoundingClientRect();
			return { th: th, after: e.clientX > r.left + r.width / 2 };
		};
		document.addEventListener('dragstart', function (e) {
			var th = e.target.closest && e.target.closest('th.th-move');
			if (!th) return;
			mDrag = th;
			e.dataTransfer.effectAllowed = 'move';
			e.dataTransfer.setData('text/plain', text(th));
			th.classList.add('th-drag');
		});
		document.addEventListener('dragover', function (e) {
			var o = mOver(e);
			if (!o) return;
			e.preventDefault();
			var cls = o.after ? 'th-drop-r' : 'th-drop-l';
			if (o.th.classList.contains(cls)) return;
			[].forEach.call(document.querySelectorAll('.th-drop-l, .th-drop-r'), function (x) { x.classList.remove('th-drop-l', 'th-drop-r'); });
			o.th.classList.add(cls);
		});
		document.addEventListener('drop', function (e) {
			var o = mOver(e);
			if (!o) return;
			e.preventDefault();
			mMove(mDrag.closest('table'), mDrag, o.th, o.after);
		});
		document.addEventListener('dragend', function () { mDrag = null; mClear(); });
		document.addEventListener('keydown', function (e) {
			if (!e.altKey || (e.key !== 'ArrowLeft' && e.key !== 'ArrowRight') || !e.target.matches || !e.target.matches('th.th-move')) return;
			var th = e.target, right = e.key === 'ArrowRight', nb = right ? th.nextElementSibling : th.previousElementSibling;
			e.preventDefault();
			if (!nb || nb.classList.contains('tp-pick')) return;
			mMove(th.closest('table'), th, nb, right);
			th.focus();
		});
	}

	// ── 표 위 가로 스크롤바 (BO·FO 모든 표): 표 상자 바로 위에 같이 움직이는 가로 스크롤바를 하나 더 둔다. 아래 것은 상자 자체 스크롤바 ──
	function hBox(t) {
		for (var p = t.parentElement; p && p !== document.body; p = p.parentElement) if (/auto|scroll/.test(getComputedStyle(p).overflowX)) return p;
		return null;
	}
	// 상자 앞에 끼워 넣을 자리(위 스크롤바가 있으면 그 앞). 틀고정 바도 이 자리 앞에 둔다
	function anchor(box) { var p = box.previousElementSibling; return p && p.classList.contains('tbl-top') ? p : box; }
	function topBar(t) {
		var box = hBox(t);
		if (!box || box._top || box.closest('.modal')) return;
		var bar = document.createElement('div');
		bar.className = 'tbl-top';
		bar.setAttribute('aria-hidden', 'true');
		bar.innerHTML = '<div></div>';
		box.parentNode.insertBefore(bar, box);
		box._top = bar;
		bar._box = box;
		// 한쪽을 옮기면 다른 쪽을 맞춘다(같은 값이면 scroll 이 다시 안 나서 서로 되부르지 않는다)
		// 화면 배율에 따라 값이 소수로 어긋나 1px 안쪽 차이는 같은 것으로 본다
		bar.addEventListener('scroll', function () { if (Math.abs(box.scrollLeft - bar.scrollLeft) > 1) box.scrollLeft = bar.scrollLeft; });
		box.addEventListener('scroll', function () { if (Math.abs(bar.scrollLeft - box.scrollLeft) > 1) bar.scrollLeft = box.scrollLeft; });
	}
	// 표 폭이 상자보다 넓을 때만 보인다. 칸을 접고 펴도 맞게 클릭·창 크기 바뀔 때도 다시 잰다
	function sizeTops() {
		[].forEach.call(document.querySelectorAll('.tbl-top'), function (bar) {
			var box = bar._box;
			if (!box || !box.isConnected) { bar.remove(); return; }
			var w = box.scrollWidth, show = w > box.clientWidth + 1 && !!box.offsetParent;
			if (bar.firstChild.style.width !== w + 'px') bar.firstChild.style.width = w + 'px';
			if (bar.hidden === show) bar.hidden = !show;
			if (show && Math.abs(bar.scrollLeft - box.scrollLeft) > 1) bar.scrollLeft = box.scrollLeft;
		});
	}
	window.addEventListener('resize', sizeTops);
	document.addEventListener('click', function () { setTimeout(sizeTops, 60); });

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

	// 화면이 표를 다시 그려 고정 칸이 풀린 표: 120ms 뒤가 아니라 바로 다시 고정한다(풀렸다 붙으며 흔들리던 것)
	function frzLost(t) {
		var b = t.tBodies[0] && t.tBodies[0].rows[0];
		return !!(t._frz && t._frz.fc > 0 && t.tHead && t.tHead.rows[0] && (!t.tHead.rows[0].querySelector('.frz-c') || (b && b.cells.length > 1 && !b.querySelector('.frz-c'))) && freezable(t) && colsOk(t));
	}
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
				th.insertBefore(p, th.querySelector(':scope>.th-sum')); // 머리글 안 합계 줄(.th-sum)이 있으면 그 앞, 칸 이름 옆

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
		var box = anchor(t.closest('.tbl-scroll, .table-responsive, .pl-scroll') || t), bar = box.previousElementSibling;
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
			+ '<button type="button" role="menuitem" data-a="cols">칸 순서 처음으로 <small>머리글을 끌어 옮긴 칸</small></button>'
			+ '<button type="button" role="menuitem" data-a="off">모두 풀기</button></div>';
		box.parentNode.insertBefore(bar, box);
	}
	function fPaintBar(t) {
		var box = anchor(t.closest('.tbl-scroll, .table-responsive, .pl-scroll') || t), bar = box.previousElementSibling;
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
		item('cols').disabled = !(movable(t) && mState(t).moved);
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
		if (a === 'cols') { try { localStorage.removeItem(mState(t).store); } catch (e) { /* 저장소를 못 써도 화면은 되돌린다 */ } t._col = null; arrange(t); }
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
			if (!p || e.classList.contains('bo-act-top') || e.hasAttribute('data-bottom') || e !== p.lastElementChild || p.firstElementChild === e) return;
			if (!e.children.length || [].some.call(e.children, function (k) { return !k.matches('.btn, button'); })) return;
			// '목록' 으로 돌아가는 버튼 줄은 화면 맨 아래에 둔다
			if ([].some.call(e.children, function (k) { return k.textContent.trim() === '목록'; })) return;
			if (e.closest('.modal, table, form, .form-row, .btn-group, .input-group, .dropdown-menu, .eg-tour')) return;
			if (/sticky|fixed|absolute/.test(getComputedStyle(e).position)) return;
			var er = e.getBoundingClientRect(), pr = p.getBoundingClientRect();
			if (!er.height || er.top - pr.top < 200) return;
			e.classList.add('bo-act-top');
			p.insertBefore(e, p.firstElementChild);
		});
	}

	// ── 검색필터 고정: 화면의 첫 검색 칸(표가 없는 칸)을 내려도 위에 붙여 두고, 붙은 동안은 한 줄로 줄인다 ──
	function pinFilter() {
		if (document.querySelector('.flt-pin')) return;
		var row = [].filter.call(document.querySelectorAll('.content-wrapper .cal-panel-body > .form-row:first-child'), function (r) {
			var panel = r.closest('.cal-panel');
			return panel && !r.closest('.modal') && r.offsetParent !== null && r.querySelector('input[type=search], select') && !panel.querySelector('table');
		})[0];
		if (!row) return;
		var panel = row.closest('.cal-panel'), mark = document.createElement('div');
		panel.classList.add('flt-pin');
		panel.parentNode.insertBefore(mark, panel); // 줄어들어도 움직이지 않는 기준점(붙었는지 판단)
		function top() {
			if (document.documentElement.classList.contains('in-tab')) return 0;
			var h = document.querySelector('.main-header');
			return h ? h.getBoundingClientRect().bottom : 0;
		}
		function on() {
			var t = top();
			panel.style.top = t + 'px';
			// 폰에서는 붙이지 않는다(CSS 도 position:static)
			panel.classList.toggle('flt-stuck', !mob() && mark.getBoundingClientRect().top < t);
		}
		window.addEventListener('scroll', on, { passive: true });
		window.addEventListener('resize', on);
		on();
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
				var used = [].filter.call(row.querySelectorAll(mob() ? 'select, input[type=search]' : '.flt-more select'), function (s) { return s.tagName === 'SELECT' ? s.selectedIndex > 0 && s.value !== '' : !!s.value; }).length;
				// 폰에서 접으면 검색어까지 숨기고 이 버튼 하나만 남는다
				btn.textContent = closed ? (mob() ? '🔍 검색·필터' : '▾ 필터') + (used ? ' (' + used + '개 적용)' : '') : '▴ 접기';
				btn.setAttribute('aria-expanded', !closed);
				btn.classList.toggle('btn-warning', closed && used > 0);
			}
			// 폰에서 펴고 접은 것은 기억하지 않는다(데스크톱 저장값·보기 설정을 건드리지 않게)
			btn.addEventListener('click', function () { body.classList.toggle('flt-closed'); if (!mob()) on(body.classList.contains('flt-closed') ? '1' : '0'); paint(); });
			row.addEventListener('change', paint);
			// 처음은 접힌 상태(표를 더 많이 보이게). 화면마다 마지막 상태를 기억, 폰은 늘 접힌 채 시작
			body.classList.toggle('flt-closed', mob() || on() !== '0');
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
	// 체크 칸을 뺀 앞쪽 네 칸 글자. 칸을 옮긴 표도 같은 줄을 찾게 원래 칸 순서(_ci)로 본다
	function rowKey(tr) {
		return [].filter.call(tr.cells, function (c) { return !c.classList.contains('tp-pick'); })
			.sort(function (a, b) { return (a._ci || 0) - (b._ci || 0); }).slice(0, 4).map(text).join('|');
	}
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
			// 칸 이동: 끄는 칸은 흐리게, 놓일 자리는 파란 세로선
			+ '.table th.th-drag{opacity:.45}.table th.th-drop-l{box-shadow:inset 3px 0 0 #0b6e8a}.table th.th-drop-r{box-shadow:inset -3px 0 0 #0b6e8a}'
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
			+ '.frz-pin::before{content:"📌"}th:hover>.frz-pin,.frz-pin:focus,.frz-pin.on,.frz-show-c th>.frz-pin,.frz-rpin{opacity:1}.frz-pin.on{filter:none;color:#0b6e8a}.frz-pin:not(.on){filter:grayscale(1)}'
			// 폰(767px 이하): 목록 표 카드(cd-on, 페이지 스크롤 하나·틀고정/위 스크롤바/칸 끌기 없음), 검색필터는 고정 없이 버튼 하나로 접힘, 누르는 것 36px 이상
			+ '@media (max-width:767px){'
			+ 'table.cd-on,table.cd-on>tbody{display:block;width:100%!important;min-width:0!important}table.cd-on>thead{display:none}'
			+ '.tbl-scroll:has(>table.cd-on),.table-responsive:has(>table.cd-on),.pl-scroll:has(>table.cd-on){max-height:none!important;overflow:visible!important}'
			+ 'table.cd-on>tbody>tr:not(.more-hide){display:block;position:relative;margin:0 0 8px;padding:6px 0;border:1px solid #dfe4e8;border-radius:10px;background:#fff;overflow:hidden}'
			+ 'table.cd-on>tbody>tr.tp-on{background:#eef4ff}'
			+ 'table.cd-on>tbody>tr>td{display:block;position:relative!important;left:auto!important;top:auto!important;border:0!important;padding:2px 12px!important;white-space:normal;overflow-wrap:anywhere;text-align:left!important;width:auto!important;max-width:none!important;box-shadow:none!important}'
			+ 'table.cd-on>tbody>tr>td.frz-c{background-color:transparent}'
			+ 'table.cd-on>tbody>tr>td[data-label]{padding-left:100px!important;line-height:22px}'
			+ 'table.cd-on>tbody>tr>td[data-label]::before{content:attr(data-label);position:absolute;left:12px;top:2px;width:82px;line-height:22px;color:#8a949c;font-size:12px;font-weight:400;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}'
			+ 'table.cd-on>tbody>tr:has(>td.cd-pk)>td.cd-1{padding-right:48px!important}'
			+ 'table.cd-on>tbody>tr>td.cd-1{padding-left:12px!important;font-weight:700;font-size:14px}table.cd-on>tbody>tr>td.cd-x{display:none}'
			+ 'table.cd-on>tbody>tr>td.cd-pk{position:absolute!important;top:0!important;right:0;left:auto!important;width:44px!important;height:44px;padding:12px!important;text-align:center!important}'
			+ 'table.cd-on>tbody>tr>td.cd-pk input{width:20px;height:20px;margin:0}table.cd-on>tbody>tr>td.cd-1::before,table.cd-on>tbody>tr>td.cd-pk::before{content:none}'
			+ '.cd-on .td-cut{display:inline;max-width:none;white-space:normal;overflow:visible}'
			+ '.frz-bar.cd-bar .frz-btn,.frz-bar.cd-bar .frz-menu{display:none!important}'
			+ '.frz-btn{min-height:36px;padding:0 12px}.frz-menu{top:40px}.frz-menu button{min-height:36px}.pl-chip,.pl-all{min-height:36px}.table th.th-sort{height:36px}.tbl-more{padding:14px 12px}'
			+ '.flt-pin{position:static!important;box-shadow:none!important}'
			+ '.flt-closed>.form-row:first-child>:not(.flt-tg){display:none!important}.flt-tg{flex:1 1 100%!important;max-width:100%!important;margin:0!important}.flt-tg .btn{width:100%;min-height:36px}}'
			// 마우스가 없는 기기: 올려야 보이던 ↕·📌 를 늘 보인다
			+ '@media (hover:none){th.th-sort:not([aria-sort])::after{content:" ↕";color:#9aa4ac;font-size:10px}.frz-pin{opacity:1}}';
		document.head.appendChild(css);
	}

	var topCss = document.createElement('style');
	topCss.textContent = '.tbl-top{overflow-x:auto;overflow-y:hidden;height:13px}.tbl-top>div{height:1px}.tbl-top[hidden]{display:none}'
		// 로딩 화면(더 보이기·서버 호출 중)
		+ '.bo-load{position:fixed;top:0;right:0;bottom:0;left:0;z-index:3000;display:flex;align-items:center;justify-content:center;background:rgba(15,23,42,.32);-webkit-backdrop-filter:blur(2px);backdrop-filter:blur(2px);opacity:0;pointer-events:none;transition:opacity .15s}'
		+ '.bo-load.on{opacity:1;pointer-events:auto;cursor:progress}'
		+ '.bo-load-card{display:flex;flex-direction:column;align-items:center;gap:12px;padding:22px 32px 20px;border-radius:16px;background:#fff;box-shadow:0 12px 40px rgba(15,23,42,.25);font-weight:700;font-size:13px;color:#33505c}'
		+ '.bo-load-txt{max-width:320px;text-align:center;white-space:pre-line;overflow-wrap:anywhere}'
		+ '.bo-load-ring{width:46px;height:46px;border-radius:50%;background:conic-gradient(#16d5ff,#0b6e8a,#6b3fa0,#16d5ff);-webkit-mask:radial-gradient(farthest-side,transparent calc(100% - 6px),#000 calc(100% - 5px));mask:radial-gradient(farthest-side,transparent calc(100% - 6px),#000 calc(100% - 5px));animation:bo-spin .8s linear infinite}'
		+ '.bo-load-bar{width:150px;height:4px;border-radius:4px;background:#e6eef2;overflow:hidden}'
		+ '.bo-load-bar::after{content:"";display:block;width:40%;height:100%;border-radius:4px;background:linear-gradient(90deg,#16d5ff,#6b3fa0);animation:bo-slide .9s ease-in-out infinite}'
		+ '@keyframes bo-spin{to{transform:rotate(360deg)}}@keyframes bo-slide{from{transform:translateX(-100%)}to{transform:translateX(250%)}}'
		+ '@media (prefers-reduced-motion:reduce){.bo-load-ring{animation-duration:2.4s}.bo-load-bar::after{animation-duration:2.7s}}';
	document.head.appendChild(topCss);

	var timer = null;
	function later() {
		// 칸을 옮겨 둔 표는 화면이 줄을 다시 그리자마자 맞춘다(120ms 뒤에 하면 원래 순서가 잠깐 보인다)
		if (BO) [].forEach.call(document.querySelectorAll('table.table'), function (t) { if (t._col && t._col.moved && movable(t)) arrange(t); if (t.classList.contains('cd-on')) card(t); if (frzLost(t)) freeze(t); });
		clearTimeout(timer);
		timer = setTimeout(scan, 120);
	}

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
		// 폭이 폰↔데스크톱으로 바뀌면 카드를 다시 맞춘다
		if (BO && MQ) { if (MQ.addEventListener) MQ.addEventListener('change', scan); else MQ.addListener(scan); }
	}
	// 화면이 처음 목록을 부르기 전에 걸어 둔다(이 파일은 jQuery 바로 뒤에 읽힌다)
	watchNet();
	if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start); else start();
})();
