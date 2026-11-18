<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/system/system_style.jspf"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_open.jspf"%>
				<div class="card-header"><h3 class="card-title bTitle"><b>메뉴 관리</b></h3></div>
				<div class="card-body">
					<div class="sys-split">
						<div class="cal-panel">
							<div class="cal-panel-head"><span>메뉴 구조 <small id="sortMsg" class="sys-pill info" role="status"></small></span><span>
								<button type="button" class="btn btn-sm btn-outline-secondary" onclick="foldAll(true);" title="모두 접으면 최상위 순서만 쉽게 바꿀 수 있습니다"><i class="fas fa-compress-alt" aria-hidden="true"></i> 모두 접기</button>
								<button type="button" class="btn btn-sm btn-outline-secondary" onclick="foldAll(false);"><i class="fas fa-expand-alt" aria-hidden="true"></i> 모두 펴기</button>
								<button type="button" class="btn btn-sm btn-outline-secondary" onclick="newMenu(true);"><i class="fas fa-plus" aria-hidden="true"></i> 그룹</button>
								<button type="button" class="btn btn-sm btn-primary" onclick="newMenu(false);"><i class="fas fa-plus" aria-hidden="true"></i> 메뉴</button>
							</span></div>
							<div class="cal-panel-body sys-tree" id="tree"></div>
						</div>
						<div class="cal-panel">
							<div class="cal-panel-head"><span id="formTitle">메뉴를 선택해 주세요</span></div>
							<form id="menuForm" class="cal-panel-body" onsubmit="saveMenu(); return false;" hidden>
								<input type="hidden" name="MENU_CODE" id="fCode">
								<div class="form-row">
									<div class="col-md-8 mb-2"><label for="fName">이름 *</label><input id="fName" name="MENU_NM" class="form-control form-control-sm" maxlength="50" required></div>
									<div class="col-md-4 mb-2"><label for="fParent">상위 메뉴</label><select id="fParent" name="REL_CODE" class="form-control form-control-sm" aria-describedby="parentHelp"></select></div>
									<div class="col-12 mb-2"><small id="parentHelp" class="form-text text-muted mt-0" role="status"></small></div>
									<div class="col-12 mb-2 only-item"><label for="fUrl">화면 주소 <small>(비워 두면 하위 메뉴를 담는 그룹·묶음, 3단계는 필수)</small></label><input id="fUrl" name="MENU_URL" class="form-control form-control-sm sys-mono" maxlength="200" placeholder="/admin/업무/openList.do"></div>
									<div class="col-12 mb-2 only-item"><label for="fPattern">접근 경로 (쉼표로 구분, 데이터 요청 주소까지 포함)</label><textarea id="fPattern" name="AUTH_PATTERN" rows="3" class="form-control form-control-sm sys-mono" maxlength="1000" placeholder="/admin/업무/**"></textarea></div>
									<div class="col-12 mb-2 only-icon"><label id="iconLabel">아이콘</label><input type="hidden" id="fIcon" name="ICON_NM"><input type="search" id="iconSearch" class="form-control form-control-sm mb-2" placeholder="분류 또는 영문 이름으로 검색 (예: 장비, user)" aria-label="아이콘 검색" maxlength="30" autocomplete="off"><div id="iconGrid" class="sys-icons" role="radiogroup" aria-labelledby="iconLabel"></div></div>
									<div class="col-md-3 mb-2"><label for="fSort">순서</label><input id="fSort" name="SORT_NO" type="number" min="0" class="form-control form-control-sm" required></div>
									<div class="col-md-4 mb-2"><label for="fUse">표시</label><select id="fUse" name="USE_YN" class="form-control form-control-sm"><option value="Y">사용</option><option value="N">숨김</option></select></div>
									<div class="col-md-4 mb-2 only-item"><label for="fNew">열기</label><select id="fNew" name="NEW_WIN_YN" class="form-control form-control-sm"><option value="N">현재 창</option><option value="Y">새 창</option></select></div>
								</div>
								<div class="text-right mb-2">
									<button type="button" class="btn btn-sm btn-outline-danger" id="delBtn" onclick="deleteMenu();">삭제</button>
									<button type="submit" class="btn btn-sm btn-primary">저장</button>
								</div>
							</form>
						</div>
					</div>
				</div>
			<%@ include file="/WEB-INF/jsp/bo/boinclude/page_close.jspf"%>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/page_script.jspf"%>
	<script src="/resources/bo/plugins/jquery-ui/jquery-ui.min.js"></script>
	<script>
	var menus = [], selected = null, savedOrder = '', draggedAt = 0, sortMsgTimer, clean = '';
	var ICON_GROUPS = [
		['사람·조직', 'user-shield users user-tie id-card sitemap building user user-check user-cog user-graduate user-plus users-cog address-book address-card handshake'],
		['업무·문서', 'briefcase tasks clipboard-list file file-alt folder table edit book book-open archive inbox clipboard clipboard-check file-contract file-signature file-pdf file-excel folder-open pen paperclip stamp print'],
		['일정', 'calendar-alt clock calendar calendar-check calendar-plus bell history hourglass-half stopwatch'],
		['소통', 'bullhorn comments envelope comment-dots paper-plane question-circle info-circle phone at'],
		['경영·재무', 'chart-bar chart-line coins credit-card file-invoice-dollar won-sign wallet receipt money-check-alt piggy-bank chart-pie chart-area balance-scale award medal'],
		['장비·기술', 'laptop server database flask graduation-cap cogs shield-alt globe desktop mobile-alt keyboard hdd microchip network-wired wifi code terminal bug robot cloud tools wrench plug cube cubes key lock'],
		['기타', 'home map-marker-alt plane car star flag tag tags list th-large']
	].map(function(g) { return [g[0], g[1].split(' ').map(function(n) { return 'fa-' + n; })]; });

	$(load);

	function load(keep) {
		hrPost('/admin/system/menu/menuListData.do', {}, function(res) {
			menus = res.result;
			renderTree();
			renderParents();
			if (keep) select(menus.filter(function(m) { return m.MENU_CODE === keep; })[0], true);
		});
	}

	function groups() { return menus.filter(function(m) { return !m.REL_CODE; }); }
	function childrenOf(code) { return menus.filter(function(m) { return m.REL_CODE === code; }); }
	function isFolder(m) { return m.REL_CODE && !m.MENU_URL; }

	// 접은 그룹·묶음(이 브라우저에 기억). 접힌 곳 안으로는 끌어 넣을 수 없어 최상위 순서만 바꿀 때 편하다
	var folded = {};
	try { folded = JSON.parse(localStorage.getItem('menuFold') || '{}') || {}; } catch (e) {}
	function foldBtn(code, name) {
		return $('<button type="button" class="sys-fold">').attr({ 'aria-expanded': !folded[code], 'aria-label': name + (folded[code] ? ' 펴기' : ' 접기') })
			.html(folded[code] ? '<i class="fas fa-chevron-right" aria-hidden="true"></i>' : '<i class="fas fa-chevron-down" aria-hidden="true"></i>')
			.on('click', function() { setFold(code, !folded[code]); });
	}
	function setFold(code, on) {
		if (on) folded[code] = 1; else delete folded[code];
		try { localStorage.setItem('menuFold', JSON.stringify(folded)); } catch (e) {}
		renderTree();
	}
	function foldAll(on) {
		folded = {};
		if (on) menus.forEach(function(m) { if (!m.MENU_URL) folded[m.MENU_CODE] = 1; });
		setFold('', false);
	}

	function renderTree() {
		var $t = $('#tree').empty();
		groups().forEach(function(g) {
			// 최상위 화면 메뉴는 하위가 없다
			if (g.MENU_URL) { $t.append($('<div class="sys-group">').append(node(g, 'sys-node-group'))); return; }
			$t.append($('<div class="sys-group">').toggleClass('folded', !!folded[g.MENU_CODE]).append(node(g, 'sys-node-group'), foldBtn(g.MENU_CODE, g.MENU_NM), itemList(g.MENU_CODE, 'lv2')));
		});
		// cancel: 기본값이 button 드래그를 막는다. 놓을 자리에 '몇 단계·어느 메뉴 안'을 보이고, 놓을 수 없는 자리면 놓아도 되돌린다
		var drag = { axis: 'y', cancel: '.sys-fold', distance: 5, tolerance: 'pointer', placeholder: 'sys-drop', start: markDrop, change: markDrop, over: markDrop, stop: dropped };
		// 그룹을 다른 그룹 안에 놓으면 하위 메뉴째 2단계 묶음이 된다. 그룹끼리 순서는 이름 줄 위에서만 바꿔야 그룹 안쪽에 놓을 수 있다
		$t.sortable($.extend({ items: '> .sys-group', handle: '> .sys-node-group', toleranceElement: '> .sys-node-group', connectWith: '.sys-items.lv2' }, drag));
		// 화면 메뉴·묶음은 최상위(#tree)로도 옮길 수 있다
		$t.find('.sys-items').sortable($.extend({ items: '> .sys-node-item, > .sys-sub', connectWith: '.sys-items, #tree' }, drag));
		savedOrder = treeOrder();
	}

	/** 끌고 있는 메뉴가 놓일 단계와 그 아래 깊이로 놓을 수 있는지 판단해 자리 표시에 적는다 */
	var dropBad = false;
	function markDrop(e, ui) {
		var $n = ui.item.is('.sys-node') ? ui.item : ui.item.find('.sys-node').first();
		var $p = ui.placeholder, $list = $p.parent(), m = byCode($n.attr('data-code')) || {};
		var depth = $list.is('#tree') ? 1 : $list.hasClass('lv2') ? 2 : 3;
		function height(code) { var k = childrenOf(code); return 1 + (k.length ? Math.max.apply(null, k.map(function(c) { return height(c.MENU_CODE); })) : 0); }
		var deepest = depth + height(m.MENU_CODE) - 1, under = $list.prev('.sys-node').find('span').first().text();
		dropBad = deepest > 3 || (depth === 3 && !m.MENU_URL);
		var label = depth === 1 ? '↕ 최상위(1단계) 순서' : '→ "' + under + '" 안 ' + depth + '단계';
		if (dropBad) label += ' — 놓을 수 없음' + (m.MENU_URL ? '' : '(하위까지 3단계를 넘거나 주소 없는 묶음은 3단계 불가)');
		$p.attr({ 'data-depth': depth, 'data-label': label }).toggleClass('bad', dropBad);
	}
	function dropped(e, ui) {
		if (dropBad) {
			dropBad = false;
			draggedAt = Date.now();
			refreshTree('그 자리에는 놓을 수 없어 되돌렸습니다');
			return;
		}
		saveOrder();
	}

	function itemList(parent, level) {
		var $list = $('<div class="sys-items">').addClass(level);
		childrenOf(parent).forEach(function(m) {
			$list.append(isFolder(m) ? $('<div class="sys-sub">').toggleClass('folded', !!folded[m.MENU_CODE]).append(node(m, 'sys-node-folder'), foldBtn(m.MENU_CODE, m.MENU_NM), itemList(m.MENU_CODE, 'lv3')) : node(m, 'sys-node-item'));
		});
		return $list;
	}

	function treeOrder() {
		return $('#tree .sys-node').map(function() {
			return $(this).attr('data-code') + ':' + ($(this).closest('.sys-items').prev('.sys-node').attr('data-code') || '');
		}).get().join(',');
	}

	function saveOrder() {
		draggedAt = Date.now();
		var order = treeOrder();
		if (order === savedOrder) return;
		hrPost('/admin/system/menu/sortMenuData.do', { MENU_ORDER: order }, function() { refreshTree('순서를 저장했습니다'); }, function() { refreshTree('저장하지 못해 되돌렸습니다'); });
	}

	// 수정 중인 폼 내용은 두고 드래그로 바뀐 순서와 소속만 맞춘다
	function refreshTree(msg) {
		var parent = $('#fParent').val(), wasClean = $('#menuForm').serialize() === clean;
		hrPost('/admin/system/menu/menuListData.do', {}, function(res) {
			menus = res.result;
			if (selected) selected = menus.filter(function(m) { return m.MENU_CODE === selected.MENU_CODE; })[0] || null;
			renderTree();
			renderParents();
			$('#fParent').val(selected ? selected.REL_CODE || '' : parent);
			if (selected) $('#fSort').val(selected.SORT_NO);
			applyKind();
			if (wasClean) clean = $('#menuForm').serialize(); // 드래그로 바뀐 위치·순서는 이미 저장된 값이다
			$('#sortMsg').text(msg);
			clearTimeout(sortMsgTimer);
			sortMsgTimer = setTimeout(function() { $('#sortMsg').empty(); }, 2500);
		});
	}

	function renderIcons() {
		var current = $('#fIcon').val(), q = $.trim($('#iconSearch').val()).toLowerCase(), $grid = $('#iconGrid').empty();
		var known = ICON_GROUPS.some(function(g) { return g[1].indexOf(current) >= 0; });
		// 2단계는 아이콘을 비우면 동그라미(묶음은 폴더)로 표시된다
		var base = $('#fParent').val() ? [['기본', ['']]] : [];
		// 목록에 없는 기존 값도 저장 때 사라지지 않게 보여 준다
		base.concat(current && !known ? [['현재 아이콘', [current]]] : []).concat(ICON_GROUPS).forEach(function(g) {
			var names = g[1].filter(function(n) { return !q || g[0].indexOf(q) >= 0 || n.indexOf(q) >= 0; });
			if (!names.length) return;
			$grid.append($('<div class="sys-icon-cat">').text(g[0]));
			names.forEach(function(name) {
				$grid.append($('<button type="button" class="sys-icon" role="radio">').attr({ title: name || '기본', 'aria-label': name || '기본 아이콘', 'aria-checked': name === current }).toggleClass('on', name === current)
					.append($('<i aria-hidden="true">').addClass(name ? 'fas ' + name : 'far fa-circle'))
					.on('click', function() {
						$('#fIcon').val(name);
						$('#iconGrid .sys-icon').removeClass('on').attr('aria-checked', false);
						$(this).addClass('on').attr('aria-checked', true);
					}));
			});
		});
		if (!$grid.children().length) $grid.append('<div class="sys-icon-cat text-muted">검색 결과가 없습니다.</div>');
	}

	$('#iconSearch').on('input', renderIcons).on('keydown', function(e) { if (e.key === 'Enter') e.preventDefault(); });

	function node(m, cls) {
		// 드래그를 놓을 때 뒤따르는 click 으로 폼이 열리지 않게 한다
		var $b = $('<button type="button" class="sys-node">').addClass(cls).attr('data-code', m.MENU_CODE).toggleClass('on', !!selected && selected.MENU_CODE === m.MENU_CODE).on('click', function() { if (Date.now() - draggedAt > 300) select(m); });
		$b.append('<i class="fas fa-grip-vertical sys-grip" aria-hidden="true"></i>');
		if (cls === 'sys-node-group') $b.append($('<i class="fas fa-fw" aria-hidden="true">').addClass(m.ICON_NM || 'fa-folder'));
		if (cls !== 'sys-node-group' && m.ICON_NM) $b.append($('<i class="fas fa-fw" aria-hidden="true">').addClass(m.ICON_NM));
		else if (cls === 'sys-node-folder') $b.append('<i class="far fa-folder-open" aria-hidden="true"></i>');
		$b.append($('<span>').text(m.MENU_NM));
		if (m.USE_YN === 'N') $b.append('<span class="sys-pill">숨김</span>');
		// 화면이 하나도 없는 그룹·묶음은 왼쪽 메뉴에 나오지 않는다
		else if (!m.MENU_URL && !hasScreen(m.MENU_CODE)) $b.append('<span class="sys-pill" title="아래에 화면 메뉴가 없어 왼쪽 메뉴에 보이지 않습니다">비어 있음</span>');
		else if (hiddenAbove(m)) $b.append('<span class="sys-pill" title="상위 메뉴가 숨김이라 왼쪽 메뉴에 보이지 않습니다">상위 숨김</span>');
		return $b;
	}

	function byCode(code) { return menus.filter(function(m) { return m.MENU_CODE === code; })[0]; }
	function hasScreen(code) { return childrenOf(code).some(function(c) { return c.USE_YN !== 'N' && (c.MENU_URL || hasScreen(c.MENU_CODE)); }); }
	function hiddenAbove(m) { for (var p = byCode(m.REL_CODE); p; p = byCode(p.REL_CODE)) if (p.USE_YN === 'N') return true; return false; }
	function nameOf(code) { var m = byCode(code); return m ? m.MENU_NM : '없음 (최상위)'; }

	function renderParents() {
		var $p = $('#fParent').empty().append('<option value="">없음 (최상위)</option>');
		// 이름이 같은 숨김 메뉴(옛 '연구소' 등)와 헷갈리지 않게 표시한다
		function label(m) { return m.MENU_NM + (m.USE_YN === 'N' ? ' (숨김)' : ''); }
		groups().forEach(function(g) {
			$p.append($('<option>').val(g.MENU_CODE).text(label(g)));
			childrenOf(g.MENU_CODE).filter(isFolder).forEach(function(f) { $p.append($('<option>').val(f.MENU_CODE).text('└ ' + label(f))); });
		});
	}

	/** 고를 수 없는 상위 메뉴는 목록에서 비활성으로 두고 이유를 아래에 적는다 */
	function limitParents() {
		var code = $('#fCode').val(), screen = !!$.trim($('#fUrl').val()), kids = code ? childrenOf(code) : [];
		var deep = kids.some(function(k) { return childrenOf(k.MENU_CODE).length; }), why = [];
		$('#fParent option').each(function() {
			var v = this.value, sub = !!(byCode(v) || {}).REL_CODE, off = false;
			if (!v) off = false;                                   // 최상위는 그룹이든 화면 메뉴든 된다
			else if (screen && kids.length) off = true;            // (서버 검사와 같다) 하위가 있는 메뉴는 주소를 가질 수 없다
			else if (v === code || (byCode(v) || {}).REL_CODE === code) off = true; // 자기 자신·자기 아래
			else if (sub) off = kids.length > 0;                   // 묶음 아래에는 화면 메뉴만(4단계 방지)
			else off = deep;                                       // 하위에 묶음이 있으면 그룹으로만 남는다
			this.disabled = off && this.value !== ($('#fParent').val() || '');
		});
		if (kids.length) why.push('하위 메뉴 ' + kids.length + '개가 함께 옮겨집니다' + (deep ? '. 하위에 묶음이 있어 다른 메뉴 아래로는 옮길 수 없습니다.' : ', 묶음(└) 아래로는 옮길 수 없습니다.'));
		$('#parentHelp').text(why.join(' '));
	}

	function applyKind() {
		var parent = $('#fParent').val(), group = !parent;
		var depth3 = menus.some(function(m) { return m.MENU_CODE === parent && m.REL_CODE; });
		// 최상위도 화면 주소를 넣으면 그룹 없이 바로 열리는 화면 메뉴가 된다
		$('.only-icon').prop('hidden', depth3);
		$('#fUrl').prop('required', depth3);
		if (group && !$('#fIcon').val() && !$.trim($('#fUrl').val())) $('#fIcon').val('fa-folder');
		limitParents();
		renderIcons();
	}
	$('#fParent').on('change', applyKind);
	$('#fUrl').on('input', limitParents);

	function fill(m, title) {
		$('#menuForm').prop('hidden', false);
		$('#formTitle').text(title);
		$('#fCode').val(m.MENU_CODE || '');
		$('#fName').val(m.MENU_NM || '');
		$('#fParent').val(m.REL_CODE || '');
		$('#fUrl').val(m.MENU_URL || '');
		$('#fPattern').val(m.AUTH_PATTERN || '');
		$('#fIcon').val(m.ICON_NM || '');
		$('#iconSearch').val('');
		$('#fSort').val(m.SORT_NO === undefined ? 0 : m.SORT_NO);
		$('#fUse').val(m.USE_YN || 'Y');
		$('#fNew').val(m.NEW_WIN_YN || 'N');
		$('#delBtn').prop('hidden', !m.MENU_CODE);
		applyKind();
		clean = $('#menuForm').serialize();
		$('#fName').focus();
	}

	/** 고치던 내용이 있으면 버리기 전에 묻는다 */
	function leave(then) {
		if ($('#menuForm').prop('hidden') || $('#menuForm').serialize() === clean) { then(); return; }
		bootbox.confirm('저장하지 않은 수정 내용이 있습니다. 버리고 넘어갈까요?', function(ok) { if (ok) then(); });
	}

	function select(m, force) {
		if (!m) return;
		if (!force && selected && selected.MENU_CODE === m.MENU_CODE) return;
		(force ? function(f) { f(); } : leave)(function() {
			selected = m;
			renderTree();
			fill(m, m.REL_CODE ? '메뉴 수정' : '그룹 수정');
		});
	}

	function newMenu(group) { leave(function() { startNew(group); }); }

	function startNew(group) {
		selected = null;
		renderTree();
		var parent = group ? '' : (groups()[0] || {}).MENU_CODE;
		var siblings = menus.filter(function(m) { return (m.REL_CODE || '') === (parent || ''); });
		var next = siblings.reduce(function(max, m) { return Math.max(max, m.SORT_NO); }, 0) + (group ? 10 : 1);
		fill({ REL_CODE: parent, SORT_NO: next }, group ? '새 그룹' : '새 메뉴');
	}

	function saveMenu() {
		var old = byCode($('#fCode').val()), parent = $('#fParent').val() || '', ask = [];
		// 위치가 바뀌거나 화면 주소가 지워지는 저장은 한 번 확인한다(잘못 바꾸면 왼쪽 메뉴에서 사라진다)
		if (old && (old.REL_CODE || '') !== parent) ask.push('위치를 "' + nameOf(old.REL_CODE) + '" → "' + nameOf(parent) + '" 로 옮깁니다' + (childrenOf(old.MENU_CODE).length ? ' (하위 메뉴 ' + childrenOf(old.MENU_CODE).length + '개 포함).' : '.'));
		if (old && old.MENU_URL && !$.trim($('#fUrl').val())) ask.push('화면 주소를 비우면 하위 메뉴를 담는 묶음이 되고, 접근 경로도 지워집니다.');
		if (old && old.USE_YN !== 'N' && $('#fUse').val() === 'N' && childrenOf(old.MENU_CODE).length) ask.push('숨기면 하위 메뉴 ' + childrenOf(old.MENU_CODE).length + '개도 왼쪽 메뉴에서 사라집니다.');
		if (!ask.length) { doSave(); return; }
		bootbox.confirm($('<div>').text(ask.join(' ') + ' 저장할까요?').html(), function(ok) { if (ok) doSave(); });
	}

	function doSave() {
		hrPost('/admin/system/menu/saveMenuData.do', $('#menuForm').serialize(), function() {
			var code = $('#fCode').val();
			clean = $('#menuForm').serialize();
			if (code) selected = null; // load 가 같은 메뉴를 다시 채우게
			load(code);
			if (!code) { selected = null; $('#menuForm').prop('hidden', true); $('#formTitle').text('저장했습니다'); }
		});
	}

	function deleteMenu() {
		bootbox.confirm($('#fName').val() + '을(를) 삭제할까요? 권한에 연결된 내용도 함께 지워집니다.', function(ok) {
			if (!ok) return;
			hrPost('/admin/system/menu/deleteMenuData.do', { MENU_CODE: $('#fCode').val() }, function() {
				selected = null;
				$('#menuForm').prop('hidden', true);
				$('#formTitle').text('메뉴를 선택해 주세요');
				load();
			});
		});
	}
	</script>
</body>
</html>
