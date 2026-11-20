<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_head.jspf"%>
<style>
	.ul-bar { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; padding: 10px 14px; border-bottom: 1px solid rgba(17,17,17,.06); }
	.ul-sep { width: 1px; height: 20px; background: rgba(17,17,17,.12); margin: 0 4px; }
	.ul-sec { display: flex; align-items: center; gap: 8px; padding: 14px 14px 8px; font-weight: 800; font-size: 14px; }
	.ul-sec .cnt { background: rgba(17,17,17,.08); border-radius: 999px; padding: 0 8px; font-size: 11.5px; }
	.ul-sec small { font-weight: 400; color: #8a949c; }
	.ul-cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 10px; padding: 0 14px 6px; }
	.ul-card { border: 1px solid rgba(17,17,17,.12); border-radius: 10px; padding: 10px 12px; background: #fff; cursor: pointer; display: flex; flex-direction: column; gap: 4px; min-width: 0; }
	.ul-card:hover, .ul-card:focus { border-color: #0b6e8a; box-shadow: 0 2px 8px rgba(11,110,138,.12); outline: none; }
	.ul-top { display: flex; gap: 6px; align-items: center; font-size: 11.5px; color: #5f6b75; white-space: nowrap; }
	.ul-cut { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
	.ul-card .ul-t { font-weight: 800; font-size: 14px; color: #111; }
	.ul-card .ul-s { font-size: 12.5px; color: #444; }
	.ul-card .ul-scr { font-size: 11.5px; color: #8a949c; }
	.ul-edit { margin-left: auto; border: 0; background: none; color: #8a949c; padding: 0 4px; line-height: 1; }
	.ul-edit:hover { color: #0b6e8a; }
	.ul-day { display: flex; align-items: center; gap: 8px; padding: 8px 14px; border-top: 1px solid rgba(17,17,17,.06); cursor: pointer; white-space: nowrap; overflow: hidden; }
	.ul-day:hover, .ul-day:focus { background: #f4fafc; outline: none; }
	.ul-day .ul-d { font-weight: 800; min-width: 104px; }
	.ul-day .ul-peek { color: #8a949c; font-size: 12.5px; min-width: 0; }
	.ul-body { padding: 0 14px 8px 30px; }
	.ul-tbl { width: 100%; font-size: 13px; }
	.ul-tbl td { padding: 5px 8px; border-top: 1px solid rgba(17,17,17,.06); white-space: nowrap; }
	.ul-tbl tr { cursor: pointer; } .ul-tbl tr:hover { background: #f4fafc; }
	.ul-tbl td.ul-wide { max-width: 0; width: 60%; }
	.ul-tbl td.ul-scr { max-width: 0; width: 30%; color: #8a949c; }
	@media (max-width: 767px) {
		.ul-body { padding-left: 14px; }
		.ul-tbl td.ul-scr, .ul-tbl td.ul-cmt { display: none; }
		.ul-day .ul-d { min-width: 0; }
	}
</style>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_open.jspf"%>
				<div class="card-header d-flex align-items-center">
					<h3 class="card-title bTitle"><b>업데이트 내역</b></h3>
					<span class="small text-muted ml-3">크게 바뀐 것은 위 카드로, 자잘한 수정은 날짜별로 접혀 있어요 · 누르면 바뀐 화면과 수정·테스트·주의 내용</span>
				</div>
				<div class="card-body">
					<div class="cal-panel">
						<div class="ul-bar" id="ulBar"></div>
						<div class="ul-sec" id="ulMajorHead"></div>
						<div class="ul-cards" id="ulMajor"></div>
						<div class="ul-sec" id="ulMinorHead"></div>
						<div id="ulMinor"></div>
					</div>
				</div>
			<%@ include file="/WEB-INF/jsp/bo/boinclude/page_close.jspf"%>

	<div class="modal fade" id="ukModal" tabindex="-1" role="dialog" aria-labelledby="ukTitle">
		<div class="modal-dialog modal-sm" role="document"><div class="modal-content">
			<div class="modal-header"><h5 class="modal-title" id="ukTitle">분류 고치기</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기">×</button></div>
			<div class="modal-body">
				<div class="small text-muted mb-2 ul-cut" id="ukName"></div>
				<div id="ukKinds" class="mb-2"></div>
				<label class="mb-0"><input type="checkbox" id="ukMajor"> ⭐ 주요 변경(위 카드로 보임)</label>
			</div>
			<div class="modal-footer"><button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">취소</button><button type="button" class="btn btn-sm btn-primary" id="ukSave">저장</button></div>
		</div></div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/page_script.jspf"%>
	<script>
	window.BO_UPDATE_PAGE = true;
	var list = [], canAct = false, kinds = { NEW: true, UI: true, FIX: true, PROC: true }, fbOnly = false, open = {}, editing = null;
	var KIND = BO_FB.updKind, DAY = '일월화수목금토';

	$(function() {
		load(true);
		$('#ukSave').on('click', saveKind);
	});
	// 탭을 다시 열면 새로 불러온다(bo-tabs.js)
	window.addEventListener('bo-tab-shown', function() { load(false); });

	function load(first) {
		hrPost('/admin/update/listData.do', {}, function(res) {
			list = (res.result && res.result.list) || [];
			canAct = !!(res.result && res.result.canAct);
			// 이 화면을 열면 메뉴의 N 을 지운다(맨 위 창에서도)
			if (list.length) { BO_UPDATE_SEEN(list[0].UPD_SQ); try { window.top.$('aside .fb-new').remove(); } catch (e) {} }
			// 처음엔 가장 최근 날짜 묶음만 펼친다
			if (first && list.length) open[list[0].DEPLOY_DT] = true;
			render();
			var q = first && /[?&]UPD_SQ=(\d+)/.exec(location.search);
			if (q) BO_UPDATE(+q[1]);
		});
	}

	function kindOf(u) { return KIND[u.KIND_CD] ? u.KIND_CD : 'UI'; }

	function render() {
		var base = list.filter(function(u) { return !fbOnly || u.FB_SQ; });
		boChips('#ulBar', Object.keys(KIND).map(function(k) {
			return { k: k, name: KIND[k][0], n: base.filter(function(u) { return kindOf(u) === k; }).length };
		}), kinds, render);
		$('#ulBar').append('<span class="ul-sep"></span>').append($('<label class="pl-chip">').toggleClass('on', fbOnly)
			.append($('<input type="checkbox">').prop('checked', fbOnly).on('change', function() { fbOnly = this.checked; render(); }))
			.append('<span>💬 피드백 반영만</span>').append($('<span class="cnt">').text(list.filter(function(u) { return u.FB_SQ; }).length)));

		var rows = base.filter(function(u) { return kinds[kindOf(u)]; });
		var major = rows.filter(function(u) { return u.MAJOR_YN === 'Y'; }), minor = rows.filter(function(u) { return u.MAJOR_YN !== 'Y'; });

		$('#ulMajorHead').empty().append('⭐ 주요 변경').append(major.length ? $('<span class="cnt">').text(major.length) : '').append($('<small>').text('새 화면·큰 개편'));
		var $m = $('#ulMajor').empty();
		if (!major.length) $m.append($('<div class="cal-empty">').text(list.length ? '고른 분류에 주요 변경이 없습니다.' : '아직 업데이트 내역이 없습니다. 다음 배포부터 쌓입니다.'));
		major.forEach(function(u) {
			$m.append($('<div class="ul-card" tabindex="0" role="button">').on('click keydown', go(u))
				.append($('<div class="ul-top">').append(BO_FB.updPill(kindOf(u))).append($('<span>').text(day(u.DEPLOY_DT)))
					.append(u.FB_SQ ? $('<span class="fb-pill warn">').text('💬 ' + (u.FB_EMPLY_NM || '요청')) : '').append(editBtn(u)))
				.append($('<div class="ul-t ul-cut">').text(u.TITLE))
				.append(u.SUMMARY ? $('<div class="ul-s ul-cut">').text(u.SUMMARY) : '')
				.append(u.SCREENS ? $('<div class="ul-scr ul-cut">').text(u.SCREENS) : ''));
		});

		$('#ulMinorHead').empty().append('자잘한 변경').append(minor.length ? $('<span class="cnt">').text(minor.length) : '').append($('<small>').text('날짜를 누르면 펼쳐져요'));
		var $n = $('#ulMinor').empty(), days = [];
		minor.forEach(function(u) { if (days.indexOf(u.DEPLOY_DT) < 0) days.push(u.DEPLOY_DT); });
		if (!days.length && list.length) $n.append($('<div class="cal-empty">').text('고른 분류에 자잘한 변경이 없습니다.'));
		days.forEach(function(d) {
			var items = minor.filter(function(u) { return u.DEPLOY_DT === d; }), on = !!open[d];
			var by = Object.keys(KIND).map(function(k) { var c = items.filter(function(u) { return kindOf(u) === k; }).length; return c ? KIND[k][0] + ' ' + c : ''; }).filter(Boolean).join(' · ');
			$n.append($('<div class="ul-day" tabindex="0" role="button">').attr('aria-expanded', on).on('click keydown', function(e) {
				if (e.type === 'keydown' && e.key !== 'Enter') return;
				open[d] = !on; render();
			}).append($('<span>').text(on ? '▾' : '▸')).append($('<span class="ul-d">').text(day(d))).append($('<span class="fb-pill">').text(items.length + '건'))
				.append($('<span class="ul-peek ul-cut">').text(by + (on ? '' : '  —  ' + items.map(function(u) { return u.TITLE; }).join(' / ')))));
			if (!on) return;
			var $t = $('<tbody>');
			items.forEach(function(u) {
				$t.append($('<tr tabindex="0">').on('click keydown', go(u))
					.append($('<td>').append(BO_FB.updPill(kindOf(u))))
					.append($('<td class="ul-wide">').append($('<div class="ul-cut">').text(u.TITLE)))
					.append($('<td class="ul-scr">').append($('<div class="ul-cut">').text(u.SCREENS || '')))
					.append($('<td class="ul-cmt">').append(u.FB_SQ ? $('<span class="fb-pill warn">').text('💬 ' + (u.FB_EMPLY_NM || '요청')) : ''))
					.append($('<td>').append(editBtn(u))));
			});
			$n.append($('<div class="ul-body">').append($('<table class="ul-tbl">').append($t)));
		});
	}

	function day(d) { return d.substr(5).replace('-', '/') + ' (' + DAY.charAt(moment(d).day()) + ')'; }

	function go(u) {
		return function(e) { if (e.type === 'keydown' && e.key !== 'Enter') return; BO_UPDATE(u.UPD_SQ); };
	}

	// 분류 고치기: 슈퍼관리자·시스템 운영자에게만 ✎
	function editBtn(u) {
		if (!canAct) return '';
		return $('<button type="button" class="ul-edit" title="분류 고치기" aria-label="분류 고치기">✎</button>').on('click keydown', function(e) {
			e.stopPropagation();
			if (e.type === 'keydown') return;
			editing = u;
			$('#ukName').text(u.TITLE);
			$('#ukKinds').empty().append(Object.keys(KIND).map(function(k) {
				return $('<label class="pl-chip mr-1 mb-1">').toggleClass('on', kindOf(u) === k).append($('<input type="radio" name="ukKind">').val(k).prop('checked', kindOf(u) === k)
					.on('change', function() { $('#ukKinds .pl-chip').removeClass('on'); $(this).parent().addClass('on'); })).append($('<span>').text(KIND[k][0]));
			}));
			$('#ukMajor').prop('checked', u.MAJOR_YN === 'Y');
			$('#ukModal').modal('show');
		});
	}

	function saveKind() {
		var k = $('#ukKinds input:checked').val(), m = $('#ukMajor').prop('checked') ? 'Y' : 'N';
		hrPost('/admin/update/kindData.do', { UPD_SQ: editing.UPD_SQ, KIND_CD: k, MAJOR_YN: m }, function(res) {
			if (res.error) return;
			editing.KIND_CD = k; editing.MAJOR_YN = m;
			$('#ukModal').modal('hide');
			render();
		});
	}
	</script>
</body>
</html>
