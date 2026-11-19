/*
 * 목록 화면 '보기' 저장 (BO, jQuery·ui-table.js 뒤에 읽는다)
 * - 표 위 '보기: 이름 ▾' 로 칸 순서·틀고정·필터 접기(ui-table.js 가 이 브라우저에 기억하는 값), 머리글 정렬, 체크 칩 상태를 이름 붙여 계정에 저장해 골라 쓴다
 * - 지금 표가 고른 보기와 달라지면 '● 바뀜' 과 [💾 저장] 이 보인다. 계정·화면마다 5개, 순정(기본 보기)은 지우거나 덮어쓸 수 없다
 * - 마지막에 쓴 보기는 다음 접속 때(다른 PC 라도) 자동 적용. 칸 순서·틀고정은 이 브라우저 저장값을 바꾼 뒤 화면을 한 번 다시 읽어 적용한다
 * 서버: BoMyController /admin/my/*ViewPresetData.do, 표 TB_EEP_VIEW_PRESET_R
 */
(function ($) {
	if (!$ || !document.querySelector('.content-wrapper')) return;
	var PATH = location.pathname, PEND = 'vw-apply:' + PATH, GUARD = 'vw-reload:' + PATH;
	var LS = /^(col|frz|flt):/;
	var data = null, cur = null, base = null, ready = false;

	function ss(k, v) { try { if (v === undefined) return sessionStorage.getItem(k); if (v === null) sessionStorage.removeItem(k); else sessionStorage.setItem(k, v); } catch (e) { return null; } }
	function tables() { return [].filter.call(document.querySelectorAll('.content-wrapper table.table'), function (t) { return !t.closest('.modal'); }); }
	function txt(c) { return [].map.call(c.childNodes, function (x) { return x.nodeType === 3 ? x.nodeValue : x.tagName === 'BUTTON' ? '' : x.textContent; }).join('').replace(/\s+/g, ' ').trim(); }

	// ── 지금 상태 ──
	function lsNow() {
		var out = {};
		try {
			for (var i = 0; i < localStorage.length; i++) {
				var k = localStorage.key(i);
				if (LS.test(k) && k.indexOf(':' + PATH + ':') === k.indexOf(':')) out[k] = localStorage.getItem(k);
			}
		} catch (e) { /* 저장소를 못 쓰면 칸 설정은 빼고 저장 */ }
		return out;
	}
	// 체크 칩: 칩 줄(부모의 부모)마다 번호를 매겨 값별 체크 상태
	function chipsNow() {
		var out = {}, boxes = [];
		[].forEach.call(document.querySelectorAll('.content-wrapper input.pl-chk'), function (b) {
			if (b.closest('.modal')) return;
			var g = b.closest('label').parentNode, gi = boxes.indexOf(g);
			if (gi < 0) { boxes.push(g); gi = boxes.length - 1; }
			out[gi + '|' + b.value] = b.checked;
		});
		return out;
	}
	function sortNow() {
		var out = [];
		tables().forEach(function (t, i) {
			var th = t.tHead && t.tHead.querySelector('th[aria-sort]');
			if (th) out.push({ t: i, c: txt(th), d: th.getAttribute('aria-sort') });
		});
		return out;
	}
	function snap() { return { ls: lsNow(), chips: chipsNow(), sort: sortNow() }; }
	function same(a, b) {
		function canon(o) { return JSON.stringify(o, function (k, v) { return v && typeof v === 'object' && !Array.isArray(v) ? Object.keys(v).sort().reduce(function (r, x) { r[x] = v[x]; return r; }, {}) : v; }); }
		return canon(a) === canon(b);
	}

	// ── 적용 ──
	function writeLs(ls) {
		try {
			Object.keys(lsNow()).forEach(function (k) { localStorage.removeItem(k); });
			Object.keys(ls || {}).forEach(function (k) { if (LS.test(k) && k.indexOf(':' + PATH + ':') === k.indexOf(':')) localStorage.setItem(k, ls[k]); });
		} catch (e) { /* 저장소를 못 쓰면 칩·정렬만 적용 */ }
	}
	// 칩은 하나 누를 때마다 화면이 다시 그려지므로 하나씩 다시 찾아 누른다
	function applyChips(want, done, n) {
		n = n || 0;
		var now = chipsNow(), k = Object.keys(want || {}).filter(function (x) { return x in now && now[x] !== want[x]; })[0];
		if (!k || n > 60) return done();
		var gi = +k.split('|')[0], v = k.slice(k.indexOf('|') + 1), boxes = [], hit = null;
		[].forEach.call(document.querySelectorAll('.content-wrapper input.pl-chk'), function (b) {
			if (b.closest('.modal')) return;
			var g = b.closest('label').parentNode;
			if (boxes.indexOf(g) < 0) boxes.push(g);
			if (boxes.indexOf(g) === gi && b.value === v) hit = b;
		});
		if (hit) hit.click();
		setTimeout(function () { applyChips(want, done, n + 1); }, 80);
	}
	function applySort(list) {
		(list || []).forEach(function (s) {
			var t = tables()[s.t], th = t && t.tHead && [].filter.call(t.tHead.rows[0].cells, function (c) { return txt(c) === s.c && c.classList.contains('th-sort'); })[0];
			if (!th) return;
			th.click();
			if (s.d === 'descending') th.click();
		});
	}
	// 표에 줄이 그려진 뒤 칩·정렬을 맞추고, 그 상태를 '바뀌지 않은' 기준으로 삼는다
	function settle(conf) {
		var tries = 0;
		(function wait() {
			var rows = tables().some(function (t) { return [].some.call(t.tBodies[0] ? t.tBodies[0].rows : [], function (r) { return r.cells.length > 1; }); });
			if (!rows && tries++ < 40) return setTimeout(wait, 250);
			applyChips(conf && conf.chips, function () {
				applySort(conf && conf.sort);
				setTimeout(function () { base = snap(); ready = true; paint(); }, 400);
			});
		})();
	}
	function find(sq) { return data && sq != null ? data.list.filter(function (v) { return String(v.VW_SQ) === String(sq); })[0] || null : null; }
	function confOf(v) { try { return JSON.parse(v.CONF); } catch (e) { return null; } }
	// 고른 보기로: 이 브라우저 칸 설정이 다르면 바꿔 쓰고 다시 읽는다(한 번만)
	function choose(sq) {
		var v = find(sq), conf = v && confOf(v);
		post('useViewPresetData.do', { vwSq: v ? v.VW_SQ : '' }, function () {
			ss(PEND, v ? String(v.VW_SQ) : '0');
			writeLs(conf ? conf.ls : {});
			ss(GUARD, null);
			location.reload();
		});
	}

	// ── 서버 ──
	function post(url, d, ok) {
		d.page = PATH;
		return $.post('/admin/my/' + url, d, function (r) {
			if (r && r.error) return toast(r.error, true);
			if (ok) ok(r ? r.result : null);
		}, 'json').fail(function () { toast('보기를 저장하지 못했습니다. 잠시 뒤 다시 시도해 주세요.', true); });
	}

	// ── 화면 ──
	var $bar, $btn, $save, $menu, $pop;
	function build() {
		$bar = $('<div class="vw-bar">');
		$btn = $('<button type="button" class="vw-btn" aria-haspopup="true" aria-expanded="false">').appendTo($bar);
		$save = $('<button type="button" class="vw-save" hidden>💾 저장</button>').appendTo($bar);
		$menu = $('<div class="vw-menu" role="menu" hidden>').appendTo($bar);
		$pop = $('<div class="vw-pop" role="dialog" aria-label="보기 저장" hidden>'
			+ '<label><input type="radio" name="vwHow" value="over"> 지금 보기에 덮어쓰기 <b class="vw-pop-nm"></b></label>'
			+ '<label><input type="radio" name="vwHow" value="new"> 새 이름으로 저장</label>'
			+ '<input type="text" class="form-control form-control-sm vw-pop-in" maxlength="30" placeholder="보기 이름 (예: 내 담당만)">'
			+ '<div class="vw-pop-act"><button type="button" class="btn btn-sm btn-outline-secondary vw-cancel">취소</button> <button type="button" class="btn btn-sm btn-primary vw-ok">저장</button></div></div>').appendTo($bar);
		$btn.on('click', function () { openMenu($menu.prop('hidden')); });
		$save.on('click', function () { openPop(true); });
		$menu.on('click', '[data-sq]', function (e) {
			if ($(e.target).closest('.vw-del').length) return;
			openMenu(false);
			choose($(this).attr('data-sq') || null);
		}).on('click', '.vw-del', function () {
			var v = find($(this).closest('[data-sq]').attr('data-sq'));
			if (!v || !confirm("'" + v.NM + "' 보기를 지울까요?")) return;
			post('deleteViewPresetData.do', { vwSq: v.VW_SQ }, function () {
				data.list = data.list.filter(function (x) { return x !== v; });
				if (cur === v) cur = null;
				paintMenu();
				paint();
				toast('지웠습니다');
			});
		});
		$menu.on('click', '.vw-col button', function (e) {
			// 메뉴를 다시 그리면 누른 버튼이 문서에서 빠져 '바깥 클릭' 으로 닫히므로 위로 올리지 않는다
			e.stopPropagation();
			var ci = +$(this).closest('.vw-col').attr('data-ci'), d = +$(this).attr('data-d'), t = colTable();
			if (!t) return;
			window.boCols.move(t, ci, d);
			paintMenu();
			paint();
			$menu.find('.vw-col[data-ci="' + ci + '"] button[data-d="' + d + '"]').trigger('focus');
		});
		$pop.on('change', 'input[name=vwHow]', function () { $pop.find('.vw-pop-in').prop('disabled', this.value !== 'new').trigger(this.value === 'new' ? 'focus' : 'blur'); });
		$pop.on('click', '.vw-cancel', function () { openPop(false); });
		$pop.on('click', '.vw-ok', function () { doSave(false); });
		$pop.on('keydown', '.vw-pop-in', function (e) { if (e.key === 'Enter') doSave(false); });
		// 바깥 클릭·Esc 로 닫기
		$(document).on('click', function (e) { if (!$(e.target).closest('.vw-bar').length) { openMenu(false); openPop(false); } });
		$(document).on('keydown', function (e) { if (e.key === 'Escape') { openMenu(false); openPop(false); } });
	}
	function openMenu(on) { $menu.prop('hidden', !on); $btn.attr('aria-expanded', on); if (on) { openPop(false); paintMenu(); } }
	function openPop(on) {
		$pop.prop('hidden', !on);
		if (!on) return;
		openMenu(false);
		$pop.find('.vw-pop-nm').text(cur ? "'" + cur.NM + "'" : '');
		$pop.find('input[value=over]').prop('disabled', !cur).prop('checked', !!cur);
		$pop.find('input[value=new]').prop('checked', !cur);
		$pop.find('.vw-pop-in').val('').prop('disabled', !!cur);
		if (!cur) $pop.find('.vw-pop-in').trigger('focus');
	}
	function doSave(drop) {
		var over = $pop.find('input[value=over]').prop('checked'), nm = $.trim($pop.find('.vw-pop-in').val());
		if (!over && !nm) return toast('보기 이름을 입력해 주세요.', true);
		var conf = JSON.stringify(snap());
		post('saveViewPresetData.do', { vwSq: over && cur ? cur.VW_SQ : '', nm: nm, conf: conf, drop: drop ? 'Y' : '' }, function (r) {
			if (r && r.full) {
				if (confirm('보기는 화면마다 ' + 5 + '개까지예요. 가장 오래된 \'' + r.full.NM + '\' 보기를 지우고 저장할까요?')) doSave(true);
				return;
			}
			post('viewPresetData.do', {}, function (d) {
				data = d;
				cur = find(r);
				base = snap();
				openPop(false);
				paint();
				toast('저장했습니다');
			});
		});
	}
	function paintMenu() {
		$menu.empty().append($('<button type="button" role="menuitemradio" data-sq="">').toggleClass('ck', !cur).text('순정 (기본 보기)').append('<small>처음 상태</small>'));
		if (data.list.length) $menu.append('<hr>');
		data.list.forEach(function (v) {
			$menu.append($('<div role="menuitemradio" tabindex="0" class="vw-item">').attr('data-sq', v.VW_SQ).toggleClass('ck', cur === v)
				.append($('<span>').text(v.NM)).append($('<button type="button" class="vw-del" aria-label="이 보기 지우기">✕</button>')));
		});
		$menu.append('<div class="vw-note">표를 바꾼 뒤 💾 저장 · 화면마다 5개까지</div>');
		// 칸 순서 ▲▼ (머리글 끌기를 못 하는 폰용, 폰 카드에는 앞 4칸이 보인다). 저장은 ui-table.js 의 칸 순서 저장값 그대로
		var t = colTable(), cols = t && window.boCols && window.boCols.list(t);
		if (!cols || cols.length < 2) return;
		var $c = $('<div class="vw-cols">').append('<div class="vw-cols-h">칸 순서 <small>폰 카드에는 앞 4칸</small></div>');
		cols.forEach(function (c, i) {
			$c.append($('<div class="vw-col">').attr('data-ci', c.ci).toggleClass('vw-col-top', i < 4)
				.append($('<span>').text(c.name || '(이름 없는 칸)'))
				.append($('<button type="button" data-d="-1" aria-label="앞으로">▲</button>').prop('disabled', !i))
				.append($('<button type="button" data-d="1" aria-label="뒤로">▼</button>').prop('disabled', i === cols.length - 1)));
		});
		$menu.append('<hr>').append($c);
	}
	function colTable() { return $bar && $bar.parent('.frz-bar').prop('_t'); }
	function paint() {
		if (!$bar) return;
		var dirty = ready && base && !same(snap(), base), t = '보기: ' + (cur ? cur.NM : '순정') + (dirty ? ' ● 바뀜' : '') + ' ▾';
		if ($btn.text() !== t) $btn.text(t);
		$btn.toggleClass('dirty', dirty).toggleClass('on', !!cur);
		$save.prop('hidden', !dirty);
	}
	// 표 위 '📌 틀고정' 줄 왼쪽에 둔다. 표를 다시 그려 그 줄이 바뀌면 다시 넣는다
	function place() {
		var fb = [].filter.call(document.querySelectorAll('.content-wrapper .frz-bar'), function (b) { return b.offsetParent && !b.closest('.modal'); })[0];
		if (!fb || ($bar[0].parentNode === fb && fb.firstChild === $bar[0])) return;
		fb.insertBefore($bar[0], fb.firstChild);
	}
	function toast(msg, err) {
		var $t = $('<div class="vw-toast" role="status">').toggleClass('err', !!err).text(msg).appendTo(document.body);
		setTimeout(function () { $t.remove(); }, err ? 3500 : 1800);
	}

	var css = document.createElement('style');
	css.textContent = '.vw-bar{position:relative;display:flex;gap:4px;align-items:center;margin-right:auto}'
		+ '.vw-btn,.vw-save{border:1px solid #ccd3d9;background:#fff;border-radius:6px;padding:0 8px;font-size:11.5px;line-height:20px;color:#5f6b75;white-space:nowrap}'
		+ '.vw-btn.on{border-color:#0b6e8a;color:#0b6e8a;background:#eef9fc;font-weight:700}.vw-btn.dirty{border-color:#e0a800;background:#fff8e3;color:#8a6200;font-weight:700}'
		+ '.vw-save{border-color:#0b6e8a;background:#0b6e8a;color:#fff;font-weight:700}.vw-save[hidden],.vw-menu[hidden],.vw-pop[hidden]{display:none}'
		+ '.vw-menu,.vw-pop{position:absolute;left:0;top:24px;z-index:21;background:#fff;border:1px solid #ccd3d9;border-radius:8px;box-shadow:0 6px 18px rgba(0,0,0,.12);padding:4px;min-width:230px}'
		+ '.vw-menu>button,.vw-item{display:flex;width:100%;gap:8px;align-items:center;border:0;background:none;text-align:left;padding:5px 8px 5px 24px;border-radius:6px;font-size:12.5px;position:relative;cursor:pointer}'
		+ '.vw-menu>button:hover,.vw-item:hover{background:#f1f4f6}.vw-menu .ck::before{content:"✓";position:absolute;left:8px;color:#0b6e8a;font-weight:700}'
		+ '.vw-menu small{color:#8a949c;margin-left:auto}.vw-menu hr{margin:4px 0;border-top:1px solid #eef0f2}.vw-item span{flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}'
		+ '.vw-del{border:0;background:none;color:#9aa4ac;font-size:11px;padding:0 4px}.vw-del:hover{color:#c0392b}.vw-note{font-size:11px;color:#8a949c;padding:4px 8px 2px}'
		+ '.vw-pop{padding:10px 12px;min-width:280px;font-size:12.5px}.vw-pop label{display:block;margin:0 0 6px;font-weight:400}.vw-pop-in{margin:0 0 8px}.vw-pop-act{text-align:right}'
		+ '.vw-toast{position:fixed;left:50%;bottom:28px;transform:translateX(-50%);z-index:3100;background:#1f2d33;color:#fff;border-radius:8px;padding:8px 16px;font-size:13px;box-shadow:0 6px 18px rgba(0,0,0,.2)}.vw-toast.err{background:#b23b2f}'
		+ '.vw-cols{max-height:50vh;overflow:auto;padding:0 4px 2px}.vw-cols-h{font-size:12px;font-weight:700;color:#5f6b75;padding:2px 4px 4px}.vw-cols-h small{font-weight:400;color:#8a949c;margin-left:4px}'
		+ '.vw-col{display:flex;align-items:center;gap:2px;padding:1px 4px;border-radius:6px;font-size:12.5px}.vw-col span{flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.vw-col-top span{font-weight:700}'
		+ '.vw-col button{border:1px solid #ccd3d9;background:#fff;border-radius:4px;font-size:10px;line-height:18px;width:24px;padding:0;color:#5f6b75}.vw-col button:disabled{color:#d0d5da}'
		// 폰: 누르는 것 36px 이상, 메뉴는 화면 폭 안에
		+ '@media (max-width:767px){.vw-btn,.vw-save{min-height:36px;padding:0 12px}.vw-menu,.vw-pop{top:40px;max-width:calc(100vw - 32px)}.vw-menu>button,.vw-item{min-height:36px}.vw-del{min-width:36px;min-height:36px}.vw-col button{width:36px;height:36px}}';
	document.head.appendChild(css);

	// ── 시작 ──
	$(function () {
		var waited = 0;
		(function start() {
			// 목록 표(틀고정 줄이 붙은 표)가 있는 화면에서만
			if (!document.querySelector('.content-wrapper .frz-bar')) { if (waited++ < 40) setTimeout(start, 250); return; }
			post('viewPresetData.do', {}, function (d) {
				data = d || { list: [] };
				var pend = ss(PEND), sq = pend !== null ? (pend === '0' ? null : pend) : data.last;
				ss(PEND, null);
				cur = find(sq);
				var conf = cur && confOf(cur);
				// 마지막에 쓴 보기의 칸 설정이 이 브라우저와 다르면 바꿔 쓰고 한 번 다시 읽는다(다른 PC 에서 고른 보기)
				if (conf && !same(lsNow(), conf.ls || {}) && !ss(GUARD)) {
					ss(GUARD, '1');
					ss(PEND, String(cur.VW_SQ));
					writeLs(conf.ls);
					location.reload();
					return;
				}
				ss(GUARD, null);
				build();
				place();
				paint();
				settle(conf);
				setInterval(function () { place(); paint(); }, 700);
			});
		})();
	});
})(window.jQuery);
