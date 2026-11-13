/*
 * 관리자 화면 탭(작업표시줄). 기획: plans/bo-screen-tabs-spec.html
 * - 처음 연 화면이 첫 탭이 되고, 왼쪽 메뉴로 여는 화면은 iframe 탭으로 띄워 둔 채 숨겼다 보인다(입력·필터·스크롤 유지)
 * - 탭 목록·순서는 localStorage 에 남겨 새로고침 때 되살린다(내용은 새로 불러온다)
 * - 탭 안 화면은 include_top 이 html.in-tab 을 붙여 상단·왼쪽 메뉴를 숨긴다
 */
(function () {
	var bar = document.getElementById('boTabs');
	if (!bar || window.top !== window.self) return;
	window.BO_TABS = true;
	var MAX = 10, KEY = 'boTabs';
	// trail: 본 탭 순서(뒤로 = 직전 탭). 탭마다 stack: 그 탭 안에서 지나온 주소(뒤로 = 탭 안 이전 화면).
	// history.back() 은 iframe 들이 기록을 함께 써서 다른 탭이 뒤로 갈 수 있어 직접 기록한다
	var tabs = [], active = null, selfTab = null, trail = [], backBtn = document.getElementById('boBack');
	var frames = document.createElement('div');
	frames.className = 'bo-frames';
	document.body.appendChild(frames);

	function link(url) { var a = document.createElement('a'); a.href = url; return a; }
	function keyOf(url) { return link(url).pathname; }
	function fullOf(url) { var a = link(url); return a.pathname + a.search; }
	function menuLinks() { return [].filter.call(document.querySelectorAll('aside a.nav-link'), function (a) { return a.getAttribute('href') && a.getAttribute('href') !== '#'; }); }
	function menuName(url) { var k = keyOf(url), a = menuLinks().filter(function (x) { return x.pathname === k; })[0]; return a ? a.textContent.trim() : null; }
	function find(url) { var k = keyOf(url); return tabs.filter(function (t) { return keyOf(t.url) === k; })[0]; }
	function save() {
		try { localStorage.setItem(KEY, JSON.stringify(tabs.map(function (t) { return { url: t.url, title: t.title }; }))); } catch (e) {}
	}

	// 저장 안 한 입력: 열린 팝업, 고치는 중인 칸, 쓰다 만 메모
	function dirty(t) {
		try {
			var d = t.self ? document : t.frame && t.frame.contentDocument;
			if (!d) return false;
			return !!d.querySelector('.modal.show, .hr-cell .form-control') || [].some.call(d.querySelectorAll('textarea.enter-send'), function (x) { return x.value.trim(); });
		} catch (e) { return false; }
	}

	function toast(msg) {
		[].forEach.call(document.querySelectorAll('.bo-tab-toast'), function (x) { x.remove(); });
		var el = document.createElement('div');
		el.className = 'bo-tab-toast';
		el.setAttribute('role', 'status');
		el.textContent = msg;
		document.body.appendChild(el);
		setTimeout(function () { el.remove(); }, 3500);
	}

	function render() {
		bar.innerHTML = '';
		var sel = document.createElement('select');
		sel.className = 'form-control form-control-sm bo-tab-select';
		sel.setAttribute('aria-label', '열린 화면 ' + tabs.length + '개');
		tabs.forEach(function (t, i) {
			var wrap = document.createElement('span'), b = document.createElement('button'), x = document.createElement('button');
			wrap.className = 'bo-tab' + (t === active ? ' on' : '') + (dirty(t) ? ' dot' : '');
			wrap.tab = t;
			b.type = 'button';
			b.className = 't';
			b.setAttribute('role', 'tab');
			b.setAttribute('aria-selected', t === active);
			b.title = t.title;
			b.textContent = t.title;
			b.onclick = function () { activate(t); };
			wrap.appendChild(b);
			if (tabs.length > 1) {
				x.type = 'button';
				x.className = 'x';
				x.setAttribute('aria-label', t.title + ' 닫기');
				x.textContent = '✕';
				x.onclick = function (e) { e.stopPropagation(); close(t); };
				wrap.appendChild(x);
			}
			bar.appendChild(wrap);
			var o = document.createElement('option');
			o.value = i;
			o.textContent = t.title;
			o.selected = t === active;
			sel.appendChild(o);
		});
		sel.onchange = function () { activate(tabs[this.value]); };
		bar.appendChild(sel);
		var on = bar.querySelector('.bo-tab.on');
		if (on && on.scrollIntoView) on.scrollIntoView({ block: 'nearest', inline: 'nearest' });
		paintBack();
	}

	function backTarget() {
		if (active && active.stack && active.stack.length > 1) return { inTab: true, title: menuName(active.stack[active.stack.length - 2]) || '이전 화면' };
		var prev = trail.slice(0, -1).reverse().filter(function (x) { return tabs.indexOf(x) >= 0; })[0];
		return prev ? { tab: prev, title: prev.title } : null;
	}

	function paintBack() {
		if (!backBtn) return;
		var b = backTarget();
		backBtn.disabled = !b;
		backBtn.title = b ? '뒤로가기: ' + b.title + (b.inTab ? ' (이 탭 안)' : '') : '뒤로 갈 화면이 없습니다';
		backBtn.setAttribute('aria-label', backBtn.title);
	}

	function back() {
		var b = backTarget();
		if (!b) return;
		if (b.inTab) {
			active.stack.pop();
			active.backing = true;
			active.frame.contentWindow.location.replace(active.stack[active.stack.length - 1]);
			return;
		}
		trail.pop();
		while (trail.length && trail[trail.length - 1] !== b.tab) trail.pop();
		activate(b.tab, true);
	}

	function markMenu(url) {
		var k = keyOf(url);
		var path = [];
		menuLinks().forEach(function (a) {
			var on = a.pathname === k;
			a.classList.toggle('bo-current', on);
			if (on) a.setAttribute('aria-current', 'page'); else a.removeAttribute('aria-current');
			if (on) for (var li = a.closest('.has-treeview'); li; li = li.parentElement.closest('.has-treeview')) path.push(li);
		});
		// 탭을 바꾸면 페이지를 새로 그리지 않으므로, 그 화면이 든 그룹만 펼치고 나머지는 접는다(include_left 의 첫 화면 처리와 같다)
		if (!path.length) return;
		[].forEach.call(document.querySelectorAll('aside .has-treeview'), function (li) {
			var open = path.indexOf(li) >= 0, sub = li.querySelector(':scope > .nav-treeview');
			li.classList.toggle('menu-open', open);
			li.children[0].classList.toggle('bo-parent', open);
			if (sub) sub.style.display = open ? 'block' : 'none';
		});
	}

	function frameOf(t) {
		if (t.frame) return t.frame;
		var f = document.createElement('iframe');
		f.className = 'bo-frame';
		f.title = t.title;
		f.src = t.url;
		f.onload = function () {
			try {
				var w = f.contentWindow, p = w.location.pathname;
				// 로그인이 끊겼거나 관리자 화면이 아니면 탭 하나가 아니라 전체를 그 화면으로
				if (p.indexOf('/admin/') !== 0 || !w.document.querySelector('.content-wrapper')) { location.href = w.location.href; return; }
				t.url = p + w.location.search;
				if (t.backing) t.backing = false;
				else if (!t.stack) t.stack = [t.url];
				else if (t.stack[t.stack.length - 1] !== t.url) t.stack.push(t.url);
				t.title = menuName(t.url) || t.title;
				f.title = t.title;
				if (t === active) { history.replaceState(null, '', t.url); markMenu(t.url); }
				render();
				save();
			} catch (e) {}
		};
		frames.appendChild(f);
		t.frame = f;
		return f;
	}

	function activate(t, fromBack) {
		if (!t) return;
		if (!fromBack) { trail = trail.filter(function (x) { return x !== t; }); trail.push(t); }
		active = t;
		t.seen = Date.now();
		[].forEach.call(frames.children, function (f) { f.classList.remove('on'); });
		if (t.self) {
			document.body.classList.remove('bo-in-frame');
		} else {
			frameOf(t).classList.add('on');
			document.body.classList.add('bo-in-frame');
		}
		history.replaceState(null, '', t.url);
		markMenu(t.url);
		render();
		save();
	}

	function remove(t) {
		var i = tabs.indexOf(t);
		if (i < 0) return;
		tabs.splice(i, 1);
		trail = trail.filter(function (x) { return x !== t; });
		if (t.frame) { t.frame.remove(); t.frame = null; t.stack = null; }
		if (t === active) activate(tabs[i] || tabs[i - 1]);
		else { render(); save(); }
	}

	function close(t) {
		if (tabs.length < 2) return;
		if (!dirty(t)) return remove(t);
		var msg = t.title + ' 화면을 닫을까요? 저장하지 않은 입력이 있습니다. 닫으면 사라집니다.';
		if (window.bootbox) bootbox.confirm({ message: msg, locale: 'ko', callback: function (ok) { if (ok) remove(t); } });
		else if (confirm(msg)) remove(t);
	}

	function open(url, title) {
		var t = find(url);
		if (!t && selfTab && keyOf(selfTab.url) === keyOf(url)) { t = selfTab; tabs.splice(tabs.indexOf(active) + 1, 0, t); }
		if (!t) {
			t = { url: fullOf(url) + link(url).hash, title: title || menuName(url) || '화면' };
			tabs.splice(tabs.indexOf(active) + 1, 0, t);
			// 많으면 가장 오래 안 본 탭부터 닫는다(쓰던 입력이 있는 탭은 건너뜀)
			var extra = tabs.length - MAX, closed = [];
			tabs.slice().sort(function (a, b) { return (a.seen || 0) - (b.seen || 0); }).forEach(function (x) {
				if (extra > 0 && x !== t && x !== active && !dirty(x)) { closed.push(x.title); remove(x); extra--; }
			});
			if (closed.length) toast('탭은 ' + MAX + '개까지라 오래 안 본 ' + closed.join(', ') + ' 탭을 닫았습니다.');
		}
		activate(t);
	}

	// ── 시작: 지금 화면이 첫 탭, 저장된 탭은 목록만 되살린다 ──
	var here = location.pathname + location.search;
	selfTab = { url: here, title: menuName(here) || ((document.querySelector('.bTitle') || {}).textContent || '').trim() || '화면', self: true };
	var saved = [];
	try { saved = JSON.parse(localStorage.getItem(KEY) || '[]') || []; } catch (e) {}
	saved.forEach(function (s) {
		if (!s || typeof s.url !== 'string' || s.url.indexOf('/admin/') !== 0) return;
		if (keyOf(s.url) === keyOf(here)) { if (tabs.indexOf(selfTab) < 0) tabs.push(selfTab); return; }
		if (!find(s.url)) tabs.push({ url: s.url, title: menuName(s.url) || s.title || '화면' });
	});
	if (tabs.indexOf(selfTab) < 0) tabs.push(selfTab);
	while (tabs.length > MAX) tabs.splice(tabs[0] === selfTab ? 1 : 0, 1);
	activate(selfTab);

	// 왼쪽 메뉴: 새 탭(이미 있으면 그 탭). Ctrl·Shift·가운데 클릭·새 창 메뉴는 브라우저 그대로
	document.addEventListener('click', function (e) {
		var a = e.target.closest && e.target.closest('aside a.nav-link');
		if (!a || a.getAttribute('href') === '#' || !a.getAttribute('href') || a.target === '_blank' || e.button || e.ctrlKey || e.metaKey || e.shiftKey || e.altKey) return;
		if (a.pathname.indexOf('/admin/') !== 0) return;
		e.preventDefault();
		open(a.href, a.textContent.trim());
		if (document.body.classList.contains('sidebar-open')) { var p = document.querySelector('[data-widget="pushmenu"]'); if (p) p.click(); }
	});

	// 다른 화면(관리자 홈 대시보드)이 탭으로 열 때. 같은 화면 탭이 있으면 주소의 조건(?·#)으로 다시 연다.
	// 그 탭에 저장하지 않은 입력이 있거나 첫 탭(지금 창)이면 조건은 버리고 탭만 보인다
	window.BO_OPEN = function (url) {
		var t = find(url), full = fullOf(url) + link(url).hash;
		if (t && !t.self) {
			if (!t.frame) t.url = full;
			else if (t.url !== full && !dirty(t)) t.frame.contentWindow.location.href = full;
		}
		open(full);
	};

	if (backBtn) backBtn.addEventListener('click', back);

	// 가운데 버튼으로 닫기
	bar.addEventListener('auxclick', function (e) {
		var w = e.target.closest('.bo-tab');
		if (w && e.button === 1) { e.preventDefault(); close(w.tab); }
	});

	// 오른쪽 클릭 메뉴
	var menu = null;
	function hideMenu() { if (menu) { menu.remove(); menu = null; } }
	bar.addEventListener('contextmenu', function (e) {
		var w = e.target.closest('.bo-tab');
		if (!w) return;
		e.preventDefault();
		hideMenu();
		var t = w.tab;
		menu = document.createElement('div');
		menu.className = 'bo-tab-menu';
		menu.setAttribute('role', 'menu');
		[['↻ 새로고침', function () { if (t.self) location.reload(); else { activate(t); frameOf(t).contentWindow.location.reload(); } }],
			['⧉ 새 창으로 열기', function () { window.open(t.url, '_blank', 'noopener'); }],
			null,
			['✕ 닫기', function () { close(t); }, tabs.length < 2],
			['다른 탭 모두 닫기', function () { tabs.slice().forEach(function (x) { if (x !== t) close(x); }); }, tabs.length < 2],
			['오른쪽 탭 모두 닫기', function () { tabs.slice(tabs.indexOf(t) + 1).forEach(close); }, tabs.indexOf(t) === tabs.length - 1]
		].forEach(function (m) {
			if (!m) { menu.appendChild(document.createElement('hr')); return; }
			var b = document.createElement('button');
			b.type = 'button';
			b.setAttribute('role', 'menuitem');
			b.textContent = m[0];
			b.disabled = !!m[2];
			b.onclick = function () { hideMenu(); m[1](); };
			menu.appendChild(b);
		});
		document.body.appendChild(menu);
		menu.style.left = Math.min(e.clientX, window.innerWidth - menu.offsetWidth - 8) + 'px';
		menu.style.top = e.clientY + 'px';
		menu.querySelector('button:not([disabled])').focus();
	});
	document.addEventListener('click', function (e) { if (menu && !menu.contains(e.target)) hideMenu(); });
	document.addEventListener('keydown', function (e) { if (e.key === 'Escape') hideMenu(); });

	// 쓰던 입력 표시(노란 점)
	setInterval(function () {
		[].forEach.call(bar.querySelectorAll('.bo-tab'), function (w) { w.classList.toggle('dot', dirty(w.tab)); });
	}, 1500);
})();
