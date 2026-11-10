<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/system/system_style.jspf"%>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header"><h3 class="card-title bTitle"><b>메뉴 관리</b></h3></div>
				<div class="card-body">
					<div class="sys-split">
						<div class="cal-panel">
							<div class="cal-panel-head"><span>메뉴 구조 <small id="sortMsg" class="sys-pill info" role="status"></small></span><span>
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
									<div class="col-md-4 mb-2"><label for="fParent">상위 메뉴</label><select id="fParent" name="REL_CODE" class="form-control form-control-sm"></select></div>
									<div class="col-12 mb-2 only-item"><label for="fUrl">화면 주소 <small>(2단계에서 비워 두면 하위 메뉴를 담는 묶음)</small></label><input id="fUrl" name="MENU_URL" class="form-control form-control-sm sys-mono" maxlength="200" placeholder="/admin/업무/openList.do"></div>
									<div class="col-12 mb-2 only-item"><label for="fPattern">접근 경로 (쉼표로 구분, 데이터 요청 주소까지 포함)</label><textarea id="fPattern" name="AUTH_PATTERN" rows="3" class="form-control form-control-sm sys-mono" maxlength="1000" placeholder="/admin/업무/**"></textarea></div>
									<div class="col-12 mb-2 only-group"><label id="iconLabel">아이콘</label><input type="hidden" id="fIcon" name="ICON_NM"><input type="search" id="iconSearch" class="form-control form-control-sm mb-2" placeholder="분류 또는 영문 이름으로 검색 (예: 장비, user)" aria-label="아이콘 검색" maxlength="30" autocomplete="off"><div id="iconGrid" class="sys-icons" role="radiogroup" aria-labelledby="iconLabel"></div></div>
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
			</section>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>
	<script src="/resources/bo/plugins/jquery-ui/jquery-ui.min.js"></script>
	<script>
	var menus = [], selected = null, savedOrder = '', draggedAt = 0, sortMsgTimer;
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
			if (keep) select(menus.filter(function(m) { return m.MENU_CODE === keep; })[0]);
		});
	}

	function groups() { return menus.filter(function(m) { return !m.REL_CODE; }); }
	function childrenOf(code) { return menus.filter(function(m) { return m.REL_CODE === code; }); }
	function isFolder(m) { return m.REL_CODE && !m.MENU_URL; }

	function renderTree() {
		var $t = $('#tree').empty();
		groups().forEach(function(g) {
			$t.append($('<div class="sys-group">').append(node(g, 'sys-node-group'), itemList(g.MENU_CODE, 'lv2')));
		});
		// cancel: 기본값이 button 드래그를 막는다
		var drag = { axis: 'y', cancel: '', distance: 5, tolerance: 'pointer', placeholder: 'sys-drop', forcePlaceholderSize: true, stop: saveOrder };
		$t.sortable($.extend({ items: '.sys-group', handle: '.sys-node-group' }, drag));
		$t.find('.sys-items').sortable($.extend({ items: '> .sys-node-item, > .sys-sub', connectWith: '.sys-items' }, drag));
		savedOrder = treeOrder();
	}

	function itemList(parent, level) {
		var $list = $('<div class="sys-items">').addClass(level);
		childrenOf(parent).forEach(function(m) {
			$list.append(isFolder(m) ? $('<div class="sys-sub">').append(node(m, 'sys-node-folder'), itemList(m.MENU_CODE, 'lv3')) : node(m, 'sys-node-item'));
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
		var parent = $('#fParent').val();
		hrPost('/admin/system/menu/menuListData.do', {}, function(res) {
			menus = res.result;
			if (selected) selected = menus.filter(function(m) { return m.MENU_CODE === selected.MENU_CODE; })[0] || null;
			renderTree();
			renderParents();
			$('#fParent').val(selected ? selected.REL_CODE || '' : parent);
			if (selected) $('#fSort').val(selected.SORT_NO);
			applyKind();
			$('#sortMsg').text(msg);
			clearTimeout(sortMsgTimer);
			sortMsgTimer = setTimeout(function() { $('#sortMsg').empty(); }, 2500);
		});
	}

	function renderIcons() {
		var current = $('#fIcon').val(), q = $.trim($('#iconSearch').val()).toLowerCase(), $grid = $('#iconGrid').empty();
		var known = ICON_GROUPS.some(function(g) { return g[1].indexOf(current) >= 0; });
		// 목록에 없는 기존 값도 저장 때 사라지지 않게 보여 준다
		(current && !known ? [['현재 아이콘', [current]]] : []).concat(ICON_GROUPS).forEach(function(g) {
			var names = g[1].filter(function(n) { return !q || g[0].indexOf(q) >= 0 || n.indexOf(q) >= 0; });
			if (!names.length) return;
			$grid.append($('<div class="sys-icon-cat">').text(g[0]));
			names.forEach(function(name) {
				$grid.append($('<button type="button" class="sys-icon" role="radio">').attr({ title: name, 'aria-label': name, 'aria-checked': name === current }).toggleClass('on', name === current)
					.append($('<i class="fas" aria-hidden="true">').addClass(name))
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
		if (cls === 'sys-node-folder') $b.append('<i class="far fa-folder-open" aria-hidden="true"></i>');
		$b.append($('<span>').text(m.MENU_NM));
		if (m.USE_YN === 'N') $b.append('<span class="sys-pill">숨김</span>');
		return $b;
	}

	function renderParents() {
		var $p = $('#fParent').empty().append('<option value="">없음 (그룹)</option>');
		groups().forEach(function(g) {
			$p.append($('<option>').val(g.MENU_CODE).text(g.MENU_NM));
			childrenOf(g.MENU_CODE).filter(isFolder).forEach(function(f) { $p.append($('<option>').val(f.MENU_CODE).text('└ ' + f.MENU_NM)); });
		});
	}

	function applyKind() {
		var parent = $('#fParent').val(), group = !parent;
		$('.only-item').prop('hidden', group);
		$('.only-group').prop('hidden', !group);
		$('#fUrl').prop('required', menus.some(function(m) { return m.MENU_CODE === parent && m.REL_CODE; }));
	}
	$('#fParent').on('change', applyKind);

	function fill(m, title) {
		$('#menuForm').prop('hidden', false);
		$('#formTitle').text(title);
		$('#fCode').val(m.MENU_CODE || '');
		$('#fName').val(m.MENU_NM || '');
		$('#fParent').val(m.REL_CODE || '');
		$('#fUrl').val(m.MENU_URL || '');
		$('#fPattern').val(m.AUTH_PATTERN || '');
		$('#fIcon').val(m.ICON_NM || 'fa-folder');
		$('#iconSearch').val('');
		renderIcons();
		$('#fSort').val(m.SORT_NO === undefined ? 0 : m.SORT_NO);
		$('#fUse').val(m.USE_YN || 'Y');
		$('#fNew').val(m.NEW_WIN_YN || 'N');
		$('#delBtn').prop('hidden', !m.MENU_CODE);
		applyKind();
		$('#fName').focus();
	}

	function select(m) {
		if (!m) return;
		selected = m;
		renderTree();
		fill(m, m.REL_CODE ? '메뉴 수정' : '그룹 수정');
	}

	function newMenu(group) {
		selected = null;
		renderTree();
		var parent = group ? '' : (groups()[0] || {}).MENU_CODE;
		var siblings = menus.filter(function(m) { return (m.REL_CODE || '') === (parent || ''); });
		var next = siblings.reduce(function(max, m) { return Math.max(max, m.SORT_NO); }, 0) + (group ? 10 : 1);
		fill({ REL_CODE: parent, SORT_NO: next }, group ? '새 그룹' : '새 메뉴');
	}

	function saveMenu() {
		hrPost('/admin/system/menu/saveMenuData.do', $('#menuForm').serialize(), function() {
			var code = $('#fCode').val();
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
