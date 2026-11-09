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
							<div class="cal-panel-head"><span>메뉴 구조</span><span>
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
									<div class="col-md-4 mb-2"><label for="fParent">상위 그룹</label><select id="fParent" name="REL_CODE" class="form-control form-control-sm"></select></div>
									<div class="col-12 mb-2 only-item"><label for="fUrl">화면 주소 *</label><input id="fUrl" name="MENU_URL" class="form-control form-control-sm sys-mono" maxlength="200" placeholder="/admin/업무/openList.do"></div>
									<div class="col-12 mb-2 only-item"><label for="fPattern">접근 경로 (쉼표로 구분, 데이터 요청 주소까지 포함)</label><textarea id="fPattern" name="AUTH_PATTERN" rows="3" class="form-control form-control-sm sys-mono" maxlength="1000" placeholder="/admin/업무/**"></textarea></div>
									<div class="col-md-5 mb-2 only-group"><label for="fIcon">아이콘</label><input id="fIcon" name="ICON_NM" class="form-control form-control-sm sys-mono" maxlength="50" placeholder="fa-folder"></div>
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
	<script>
	var menus = [], selected = null;

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

	function renderTree() {
		var $t = $('#tree').empty();
		groups().forEach(function(g) {
			$t.append(node(g, 'sys-node-group'));
			menus.filter(function(m) { return m.REL_CODE === g.MENU_CODE; }).forEach(function(m) { $t.append(node(m, 'sys-node-item')); });
		});
	}

	function node(m, cls) {
		var $b = $('<button type="button" class="sys-node">').addClass(cls).toggleClass('on', !!selected && selected.MENU_CODE === m.MENU_CODE).on('click', function() { select(m); });
		if (cls === 'sys-node-group') $b.append($('<i class="fas fa-fw" aria-hidden="true">').addClass(m.ICON_NM || 'fa-folder'));
		$b.append($('<span>').text(m.MENU_NM));
		if (m.USE_YN === 'N') $b.append('<span class="sys-pill">숨김</span>');
		return $b;
	}

	function renderParents() {
		var $p = $('#fParent').empty().append('<option value="">없음 (그룹)</option>');
		groups().forEach(function(g) { $p.append($('<option>').val(g.MENU_CODE).text(g.MENU_NM)); });
	}

	function applyKind() {
		var group = !$('#fParent').val();
		$('.only-item').prop('hidden', group);
		$('.only-group').prop('hidden', !group);
		$('#fUrl').prop('required', !group);
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
		$('#fIcon').val(m.ICON_NM || '');
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
