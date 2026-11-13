<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/system/system_style.jspf"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_open.jspf"%>
				<div class="card-header"><h3 class="card-title bTitle"><b>권한 관리</b></h3></div>
				<div class="card-body">
					<div class="sys-split">
						<div class="cal-panel">
							<div class="cal-panel-head"><span>권한</span><button type="button" class="btn btn-sm btn-primary" onclick="openRole();"><i class="fas fa-plus" aria-hidden="true"></i> 추가</button></div>
							<div class="sys-roles" id="roles"></div>
						</div>
						<div class="cal-panel">
							<div class="cal-panel-head"><span id="roleTitle"></span><span id="roleTools"></span></div>
							<div class="cate-tabs" id="tabs" role="tablist" aria-label="권한 설정"></div>
							<div class="cal-panel-body" id="tabBody"></div>
						</div>
					</div>
				</div>
			<%@ include file="/WEB-INF/jsp/bo/boinclude/page_close.jspf"%>

	<div class="modal fade" id="roleModal" tabindex="-1" role="dialog" aria-labelledby="roleModalTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="roleModalTitle">권한</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<form id="roleForm" onsubmit="saveRole(); return false;">
					<input type="hidden" name="ROLE_SQ" id="rSq">
					<div class="modal-body">
						<div class="mb-2"><label for="rName">권한명 *</label><input id="rName" name="ROLE_NM" class="form-control form-control-sm" maxlength="50" required></div>
						<div class="mb-2"><label for="rDesc">설명</label><input id="rDesc" name="ROLE_DESC" class="form-control form-control-sm" maxlength="200"></div>
					</div>
					<div class="modal-footer"><button type="submit" class="btn btn-sm btn-primary">저장</button></div>
				</form>
			</div>
		</div>
	</div>

	<datalist id="adminList"></datalist>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/page_script.jspf"%>
	<script>
	var data = null, current = null, tab = 'menu', dirty = false;

	$(function() { load(); });

	$(window).on('beforeunload', function() { if (dirty) return '저장하지 않은 변경이 있습니다.'; });

	function load() {
		hrPost('/admin/system/role/roleListData.do', {}, function(res) {
			data = res.result;
			if (current) current = data.roles.filter(function(r) { return r.ROLE_SQ === current.ROLE_SQ; })[0];
			current = current || data.roles[0];
			$('#adminList').empty();
			data.admins.forEach(function(a) { $('#adminList').append($('<option>').val(a.EMPLY_ID).text(a.EMPLY_NM)); });
			render();
		});
	}

	function isSuper(r) { return r.ROLE_CD === 'SUPER'; }
	function items() { return data.menus.filter(function(m) { return m.MENU_URL; }); }
	function groups() { return data.menus.filter(function(m) { return !m.REL_CODE; }); }
	function childrenOf(code) { return data.menus.filter(function(m) { return m.REL_CODE === code; }); }
	function menuCodes(r) { return data.roleMenus.filter(function(x) { return x.ROLE_SQ === r.ROLE_SQ; }).map(function(x) { return x.MENU_CODE; }); }
	function users(r) { return data.roleUsers.filter(function(x) { return x.ROLE_SQ === r.ROLE_SQ; }); }

	function render() {
		var $r = $('#roles').empty();
		data.roles.forEach(function(r) {
			var count = isSuper(r) ? '전체 메뉴' : menuCodes(r).length + '개 메뉴';
			$('<button type="button" class="sys-role">').toggleClass('on', r === current).attr('aria-pressed', r === current)
				.append($('<span class="sys-role-name">').append($('<span>').text(r.ROLE_NM)).append(r.SYSTEM_YN === 'Y' ? '<span class="sys-pill info">시스템</span>' : ''))
				.append($('<small>').text(count + ' · ' + users(r).length + '명'))
				.on('click', function() { pick(r); }).appendTo($r);
		});
		$('#roleTitle').text(current.ROLE_NM + (current.ROLE_DESC ? ' · ' + current.ROLE_DESC : ''));
		var $tools = $('#roleTools').empty();
		$('<button type="button" class="btn btn-sm btn-outline-secondary">수정</button>').on('click', function() { openRole(current); }).appendTo($tools);
		if (current.SYSTEM_YN !== 'Y') $('<button type="button" class="btn btn-sm btn-outline-danger ml-1">삭제</button>').on('click', deleteRole).appendTo($tools);
		var $tabs = $('#tabs').empty();
		$tabs.append(hrTab('menu', '메뉴 권한', isSuper(current) ? items().length : menuCodes(current).length, tab === 'menu'));
		$tabs.append(hrTab('user', '사용자', users(current).length, tab === 'user'));
		$tabs.append(hrTab('all', '전체 보기', data.roles.length, tab === 'all'));
		$tabs.find('.cate-tab').on('click', function() { var next = $(this).attr('data-tab'); guard(function() { tab = next; render(); }); });
		({ menu: renderMenus, user: renderUsers, all: renderAll })[tab]();
	}

	function guard(next) {
		if (!dirty) { next(); return; }
		bootbox.confirm('저장하지 않은 메뉴 권한이 있습니다. 버리고 이동할까요?', function(ok) { if (ok) { dirty = false; next(); } });
	}

	function pick(r) { guard(function() { current = r; render(); }); }

	function renderMenus() {
		var $b = $('#tabBody').empty(), locked = isSuper(current), have = menuCodes(current);
		if (locked) $b.append('<div class="small text-muted mb-2">슈퍼관리자는 항상 모든 메뉴를 사용합니다.</div>');
		var $tree = $('<div>').appendTo($b), syncs = [];
		function syncAll() { syncs.forEach(function(sync) { sync(); }); }
		// 그룹·묶음 체크박스는 하위 화면 일괄 선택용이고 저장되는 것은 화면 메뉴뿐이다
		function branch(g, level) {
			var $box = $('<input type="checkbox">').prop('disabled', locked);
			var $group = $('<label class="sys-check group">').addClass('lv' + level).append($box).append($('<span>').text(g.MENU_NM)).appendTo($tree);
			var $children = $();
			childrenOf(g.MENU_CODE).forEach(function(m) {
				if (!m.MENU_URL) { $children = $children.add(branch(m, level + 1)); return; }
				var $c = $('<input type="checkbox" class="menu-box">').val(m.MENU_CODE).prop({ disabled: locked, checked: locked || have.indexOf(m.MENU_CODE) >= 0 });
				var $label = $('<label class="sys-check item">').addClass('lv' + (level + 1)).append($c).append($('<span>').text(m.MENU_NM));
				if (m.USE_YN === 'N') $label.append('<span class="sys-pill">숨김</span>');
				$tree.append($label);
				$c.on('change', function() { dirty = true; syncAll(); });
				$children = $children.add($c);
			});
			syncs.push(function() {
				var on = $children.filter(':checked').length;
				$box.prop({ checked: on > 0 && on === $children.length, indeterminate: on > 0 && on < $children.length });
			});
			$box.on('change', function() { $children.prop('checked', this.checked); dirty = true; syncAll(); });
			if (!$children.length) $group.remove();
			return $children;
		}
		groups().forEach(function(g) { branch(g, 1); });
		syncAll();
		if (!locked) {
			$('<div class="text-right mb-2">').append($('<button type="button" class="btn btn-sm btn-primary">저장</button>').on('click', saveMenus)).appendTo($b);
		}
	}

	function saveMenus() {
		var codes = $('.menu-box:checked').map(function() { return this.value; }).get().join(',');
		hrPost('/admin/system/role/saveRoleMenuData.do', { ROLE_SQ: current.ROLE_SQ, MENU_CODES: codes }, function() { dirty = false; load(); });
	}

	function renderUsers() {
		var $b = $('#tabBody').empty(), list = users(current);
		var $input = $('<input class="form-control form-control-sm" list="adminList" autocomplete="off" aria-label="추가할 관리자 아이디" placeholder="관리자 이름 또는 아이디 검색">');
		var $add = $('<button type="button" class="btn btn-sm btn-primary ml-1 text-nowrap">추가</button>').on('click', function() { addUser($input.val()); });
		$input.on('keydown', function(e) { if (e.key === 'Enter') { e.preventDefault(); addUser($input.val()); } });
		$('<div class="d-flex mb-2" style="max-width:420px">').append($input).append($add).appendTo($b);
		var $body = $('<tbody>');
		$('<div class="table-responsive">').append($('<table class="table table-sm table-hover cal-table mb-2">').append('<thead><tr><th>이름</th><th>아이디</th><th>이메일</th><th>추가일</th><th></th></tr></thead>').append($body)).appendTo($b);
		if (!list.length) boEmpty($body, '아직 이 권한을 가진 사용자가 없습니다.');
		list.forEach(function(u) {
			$('<tr>').append($('<td>').text(u.EMPLY_NM || '')).append($('<td class="sys-mono">').text(u.EMPLY_ID)).append($('<td>').text(u.EMPLY_EMAIL || '')).append($('<td>').text(u.REG_DT || ''))
				.append($('<td class="text-right">').append($('<button type="button" class="btn btn-xs btn-outline-danger">제외</button>').attr('aria-label', (u.EMPLY_NM || u.EMPLY_ID) + ' 제외').on('click', function() { removeUser(u); }))).appendTo($body);
		});
		$b.append('<div class="small text-muted mb-2">계정관리에서 관리자로 지정된 사용 중인 계정만 추가할 수 있습니다.</div>');
		$input.focus();
	}

	function addUser(id) {
		id = $.trim(id);
		if (!id) return;
		hrPost('/admin/system/role/addRoleUserData.do', { ROLE_SQ: current.ROLE_SQ, EMPLY_ID: id }, load);
	}

	function removeUser(u) {
		bootbox.confirm((u.EMPLY_NM || u.EMPLY_ID) + '님을 ' + current.ROLE_NM + '에서 제외할까요?', function(ok) {
			if (ok) hrPost('/admin/system/role/removeRoleUserData.do', { ROLE_SQ: current.ROLE_SQ, EMPLY_ID: u.EMPLY_ID }, load);
		});
	}

	function renderAll() {
		var $head = $('<tr>').append('<th>메뉴</th>'), $body = $('<tbody>');
		data.roles.forEach(function(r) { $head.append($('<th>').text(r.ROLE_NM)); });
		function rows(g, deep) {
			var children = childrenOf(g.MENU_CODE);
			if (!children.length) return;
			$('<tr class="group">').append($('<td>').attr('colspan', data.roles.length + 1).text(g.MENU_NM)).appendTo($body);
			children.forEach(function(m) {
				if (!m.MENU_URL) { rows(m, true); return; }
				var $tr = $('<tr>').append($('<td>').toggleClass('sys-lv3', deep).text(m.MENU_NM));
				data.roles.forEach(function(r) {
					var yes = isSuper(r) || menuCodes(r).indexOf(m.MENU_CODE) >= 0;
					$tr.append($('<td>').append(yes ? '<i class="fas fa-check sys-yes" aria-label="허용"></i>' : '<span class="sys-no" aria-label="없음">–</span>'));
				});
				$body.append($tr);
			});
		}
		groups().forEach(function(g) { rows(g, false); });
		$('#tabBody').empty().append($('<div class="table-responsive mb-2">').append($('<table class="table table-sm cal-table sys-matrix mb-0">').append($('<thead>').append($head)).append($body)));
	}

	function openRole(r) {
		$('#roleModalTitle').text(r ? '권한 수정' : '권한 추가');
		$('#rSq').val(r ? r.ROLE_SQ : '');
		$('#rName').val(r ? r.ROLE_NM : '');
		$('#rDesc').val(r ? r.ROLE_DESC || '' : '');
		$('#roleModal').modal('show');
	}
	$('#roleModal').on('shown.bs.modal', function() { $('#rName').focus(); });

	function saveRole() {
		hrPost('/admin/system/role/saveRoleData.do', $('#roleForm').serialize(), function() { $('#roleModal').modal('hide'); load(); });
	}

	function deleteRole() {
		bootbox.confirm(current.ROLE_NM + ' 권한을 삭제할까요? 메뉴 연결과 사용자 연결도 함께 지워집니다.', function(ok) {
			if (!ok) return;
			hrPost('/admin/system/role/deleteRoleData.do', { ROLE_SQ: current.ROLE_SQ }, function() { current = null; dirty = false; load(); });
		});
	}
	</script>
</body>
</html>
