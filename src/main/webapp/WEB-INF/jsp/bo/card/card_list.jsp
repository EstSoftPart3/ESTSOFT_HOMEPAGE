<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<style>
	.cd-head { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; margin-bottom: 10px; }
	.cd-head h4 { margin: 0 auto 0 0; font-size: 20px; font-weight: 700; }
	.cd-no { font-family: Consolas, monospace; letter-spacing: 1px; font-size: 14px; font-weight: 400; color: #495057; }
	.cd-tabs { display: flex; gap: 2px; border-bottom: 1px solid #ced4da; margin-bottom: 12px; }
	.cd-tabs button { background: none; border: 0; border-bottom: 3px solid transparent; padding: 9px 18px; color: #495057; }
	.cd-tabs button[aria-selected="true"] { color: #0b6e8a; border-bottom-color: #0b6e8a; font-weight: 700; }
	.cd-back { display: flex; justify-content: center; margin: 18px 0 8px; }
	.cd-back .btn { min-width: 120px; }
	.cd-open { color: #0b6e8a; font-weight: 600; text-decoration: underline; }
	/* 사용처 코드 색. 글자를 늘 함께 써서 색만으로 구분하지 않는다 */
	.cc { display: inline-block; border-radius: 10px; padding: 0 7px; font-size: 11px; font-weight: 700; white-space: nowrap; }
	.cc0 { background: #ffe8cc; color: #7a3d00; } .cc1 { background: #dcecf8; color: #0a4a78; } .cc2 { background: #e3f4e8; color: #1e5c33; } .cc3 { background: #ece4f7; color: #4b2a7a; } .cc4 { background: #eef1f4; color: #343a40; }
	/* 달력 */
	.cd-mbar { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; margin-bottom: 8px; }
	.cd-mbar strong { font-size: 18px; padding: 0 6px; }
	.cd-sum { margin-left: auto; display: flex; flex-wrap: wrap; gap: 6px; align-items: center; font-size: 13px; }
	.cd-cal { display: grid; grid-template-columns: repeat(7, minmax(0, 1fr)); border-top: 1px solid #ced4da; border-left: 1px solid #ced4da; background: #fff; }
	.cd-cal > * { border-right: 1px solid #ced4da; border-bottom: 1px solid #ced4da; }
	.cd-cal .w { background: #eef1f4; font-weight: 700; text-align: center; padding: 6px; font-size: 13px; }
	.cd-cal .sun { color: #b02a37; } .cd-cal .sat { color: #0a4a78; }
	.cd-day { min-height: 92px; padding: 4px 6px; font-size: 12px; display: flex; flex-direction: column; gap: 2px; background: #fff; border-top: 0; border-left: 0; text-align: left; cursor: pointer; }
	.cd-day:hover, .cd-day:focus { background: #e3f6fb; }
	.cd-day.out { background: #fafbfc; color: #adb5bd; cursor: default; }
	.cd-day.today { outline: 2px solid #0b6e8a; outline-offset: -2px; }
	.cd-day .d { font-weight: 700; }
	.cd-day .e { display: flex; gap: 4px; align-items: center; white-space: nowrap; overflow: hidden; color: #212529; }
	.cd-day .more { color: #0b6e8a; }
	.cd-day .tot { margin-top: auto; text-align: right; font-weight: 700; color: #212529; }
	@media (max-width: 767px) {
		.cd-day { min-height: 52px; padding: 2px 3px; font-size: 11px; }
		.cd-day .e, .cd-day .more { display: none; }
	}
	/* 사용 등록 팝업 */
	.cd-codes { display: flex; flex-wrap: wrap; gap: 6px; }
	.cd-codes label { margin: 0; }
	.cd-codes input { position: absolute; opacity: 0; }
	.cd-codes span { display: inline-block; border: 1px solid #adb5bd; border-radius: 16px; padding: 4px 12px; font-size: 13px; cursor: pointer; }
	.cd-codes input:checked + span { background: #0b6e8a; border-color: #0b6e8a; color: #fff; font-weight: 700; }
	.cd-codes input:focus-visible + span { outline: 2px solid #16d5ff; outline-offset: 2px; }
	.cd-dayl { border: 1px solid #ced4da; border-radius: 6px; margin-top: 12px; }
	.cd-dayl > div { display: flex; gap: 8px; align-items: center; padding: 6px 10px; border-top: 1px solid #e5e8eb; font-size: 13px; }
	.cd-dayl > div:first-child { border-top: 0; background: #eef1f4; font-weight: 700; }
	.cd-dayl .amt { margin-left: auto; font-weight: 700; white-space: nowrap; }
	.cd-dayl .on { background: #e3f6fb; }
	/* 정산·마감 */
	.cd-bar { display: flex; flex-wrap: wrap; align-items: flex-end; gap: 10px; }
	.cd-bar label { display: block; margin-bottom: 2px; }
	.cd-bar input[type=date] { width: 150px; }
	.cd-drop { flex: 1 1 300px; border: 2px dashed #0b6e8a; border-radius: 8px; background: #e3f6fb; padding: 8px 12px; text-align: center; color: #084f64; font-size: 13px; }
	.cd-drop.over { background: #c8ecf6; }
	.cd-stat { display: flex; flex-wrap: wrap; gap: 10px; margin: 10px 0; }
	.cd-stat div { flex: 1 1 120px; background: #fff; border: 1px solid #ced4da; border-radius: 8px; padding: 8px 12px; font-size: 13px; }
	.cd-stat b { display: block; font-size: 20px; }
	.t-MATCH { color: #1e5c33; font-weight: 700; } .t-EXCEL_ONLY { color: #7a4300; font-weight: 700; } .t-REG_ONLY { color: #b02a37; font-weight: 700; } .t-NONE { color: #495057; font-weight: 700; }
	tr.r-EXCEL_ONLY td { background: #fff8e6; } tr.r-REG_ONLY td { background: #fff1f1; } tr.r-closed td { background: #f4f5f7; color: #495057; }
	.cd-set td { vertical-align: middle; }
	.cd-set input, .cd-set select { min-width: 110px; }
	.cd-set input.need { border-color: #b02a37; background: #fff6f6; }
	tr.cd-grp td { background: #eef1f4; font-weight: 700; }
	#cdToast { position: fixed; right: 18px; bottom: 18px; z-index: 2000; background: #222; color: #fff; font-size: 13px; padding: 8px 14px; border-radius: 6px; display: none; }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header"><h3 class="card-title bTitle"><b>법인카드</b></h3></div>
				<div class="card-body">
					<div class="cd-view" id="viewList">
						<div class="cal-panel">
							<div class="cal-panel-body">
								<div class="form-row align-items-end">
									<div class="col-md-3 col-6 mb-2"><label for="fName">카드명·사용자</label><input type="search" id="fName" class="form-control form-control-sm"></div>
									<div class="col-md-2 col-6 mb-2"><label for="fUse">사용 여부</label><select id="fUse" class="form-control form-control-sm"><option value="Y">사용</option><option value="N">미사용</option><option value="">전체</option></select></div>
									<div class="col-md-7 col-12 mb-2 text-right"><button type="button" class="btn btn-sm btn-primary" id="cardAdd" style="display:none;" onclick="openCard();"><i class="fas fa-plus"></i> 카드 등록</button></div>
								</div>
							</div>
						</div>
						<div class="cal-panel"><div class="table-responsive px-3">
							<table class="table table-sm table-hover cal-table mb-0">
								<thead><tr><th>카드명</th><th>카드번호</th><th>카드사</th><th>사용자</th><th>이번 달 사용</th><th>마감</th><th>사용</th></tr></thead>
								<tbody id="listBody"></tbody>
							</table>
						</div></div>
					</div>
					<div class="cd-view" id="viewCard" style="display:none;"></div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="cardModal" tabindex="-1" role="dialog" aria-labelledby="cardTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<form class="modal-content" onsubmit="saveCard(); return false;">
				<div class="modal-header">
					<h5 class="modal-title" id="cardTitle">카드 등록</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<input type="hidden" id="CARD_SQ">
					<div class="form-group"><label for="CARD_NM">카드명</label><input id="CARD_NM" class="form-control form-control-sm" maxlength="50" required placeholder="경영지원 공용"></div>
					<div class="form-row">
						<div class="form-group col-6"><label for="CARD_CO">카드사</label><input id="CARD_CO" class="form-control form-control-sm" maxlength="30" placeholder="롯데카드"></div>
						<div class="form-group col-6"><label for="LAST4">카드번호 끝 4자리</label><input id="LAST4" class="form-control form-control-sm" inputmode="numeric" pattern="\d{4}" maxlength="4" required></div>
					</div>
					<div class="form-row">
						<div class="form-group col-6"><label for="staffQ">사용자 (직원)</label>
							<input type="search" id="staffQ" class="form-control form-control-sm mb-1" placeholder="이름·부서 검색" autocomplete="off" aria-controls="STAFF_SQ">
							<select id="STAFF_SQ" class="form-control form-control-sm" required aria-label="사용자 직원 선택" aria-describedby="staffHint"></select></div>
						<div class="form-group col-6"><label for="USE_YN">사용 여부</label><select id="USE_YN" class="form-control form-control-sm"><option value="Y">사용</option><option value="N">미사용</option></select></div>
					</div>
					<small class="text-muted d-block" id="staffHint">사용자는 직원관리 명단에서 고르며, 그 직원은 로그인하면 본인 카드만 봅니다. 카드번호는 끝 4자리만 저장합니다.</small>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">취소</button>
					<button type="submit" class="btn btn-sm btn-primary">저장</button>
				</div>
			</form>
		</div>
	</div>

	<div class="modal fade" id="useModal" tabindex="-1" role="dialog" aria-labelledby="useTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<form class="modal-content" onsubmit="saveUse(); return false;">
				<div class="modal-header">
					<h5 class="modal-title" id="useTitle">사용 등록</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<input type="hidden" id="USE_SQ">
					<div class="alert alert-secondary py-2" id="useClosed" style="display:none;">마감된 건이라 고칠 수 없습니다.</div>
					<div class="form-row">
						<div class="form-group col-6"><label for="AMT">금액 (원, 취소는 음수)</label><input id="AMT" class="form-control form-control-sm" inputmode="numeric" required></div>
						<div class="form-group col-6"><label for="USE_DT">사용일</label><input type="date" id="USE_DT" class="form-control form-control-sm" required></div>
					</div>
					<fieldset class="form-group">
						<legend class="col-form-label pt-0" style="font-size:inherit;font-weight:700;">사용처 코드</legend>
						<div class="cd-codes" id="useCodes"></div>
					</fieldset>
					<div class="form-row">
						<div class="form-group col-md-7"><label for="MERCHANT">사용처 (가게 이름)</label><input id="MERCHANT" class="form-control form-control-sm" maxlength="200" placeholder="행복칼국수"></div>
						<div class="form-group col-md-5"><label for="TARGET_NM">대상 (비우면 카드 사용자)</label><input id="TARGET_NM" class="form-control form-control-sm" maxlength="100"></div>
					</div>
					<div class="form-group mb-0"><label for="DETAIL">내용</label><textarea id="DETAIL" rows="2" maxlength="500" class="form-control form-control-sm" placeholder="점심식사"></textarea></div>
					<div class="cd-dayl" id="dayList" aria-live="polite"></div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-sm btn-outline-danger mr-auto" id="useDelete" onclick="deleteUse();">삭제</button>
					<button type="button" class="btn btn-sm btn-outline-secondary" id="useNew" onclick="fillUse(null, $('#USE_DT').val());">새로 입력</button>
					<button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">닫기</button>
					<button type="submit" class="btn btn-sm btn-primary" id="useSave">저장</button>
				</div>
			</form>
		</div>
	</div>

	<div id="cdToast" role="status" aria-live="polite"></div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>
	<script>
	var manager = false, staffs = [], cards = [], codes = [], codeNm = {}, codeIx = {}, card = null, uses = [], tab = 0, ym = kstYm(0);
	// 정산은 지난달, 마감 목록은 올해를 기본 기간으로 연다
	var pFrom = kstYm(-1) + '-01', pTo = monthEnd(kstYm(-1)), pFile = null, pRes = null;
	var cFrom = kstToday().slice(0, 4) + '-01-01', cTo = kstToday(), cRes = null;
	var DOW = ['일', '월', '화', '수', '목', '금', '토'];

	function kstYm(add) { var d = new Date(Date.now() + 9 * 3600000); d.setUTCDate(1); d.setUTCMonth(d.getUTCMonth() + add); return d.toISOString().slice(0, 7); }
	function kstToday() { return new Date(Date.now() + 9 * 3600000).toISOString().slice(0, 10); }
	function monthEnd(v) { var p = v.split('-'); return new Date(Date.UTC(+p[0], +p[1], 0)).toISOString().slice(0, 10); }
	function won(n) { return Number(n || 0).toLocaleString('ko-KR'); }
	function shiftYm(v, add) { var p = v.split('-'), d = new Date(Date.UTC(+p[0], +p[1] - 1 + add, 1)); return d.toISOString().slice(0, 7); }
	function toast(msg) { $('#cdToast').text(msg).stop(true, true).fadeIn(100).delay(1500).fadeOut(300); }
	function chip(cd) { return $('<span class="cc">').addClass('cc' + ((codeIx[cd] || 0) % 5)).text(codeNm[cd] || cd); }

	// ── 목록 ──
	function drawList() {
		var q = $('#fName').val().trim().toLowerCase(), use = $('#fUse').val(), $b = $('#listBody').empty();
		var list = cards.filter(function(c) { return (!use || c.USE_YN === use) && (!q || ((c.CARD_NM || '') + ' ' + (c.HOLDER_NM || '')).toLowerCase().indexOf(q) >= 0); });
		if (!list.length) $b.append($('<tr><td colspan="7" class="text-center text-muted"></td></tr>').find('td').text(manager ? '등록된 카드가 없습니다.' : '내가 사용자로 지정된 카드가 없습니다.').end());
		list.forEach(function(c) {
			$('<tr>').append($('<td>').append($('<a class="cd-open">').attr('href', '#c=' + c.CARD_SQ).text(c.CARD_NM)), $('<td class="cd-no">').text('****-' + c.LAST4),
				$('<td>').text(c.CARD_CO || ''), $('<td>').text(c.HOLDER_NM || ''), $('<td>').text(c.MONTH_CNT + '건 · ' + won(c.MONTH_AMT) + '원'),
				$('<td>').text(c.LAST_CLOSE_YM ? c.LAST_CLOSE_YM + ' 까지 마감' : '-'), $('<td>').text(c.USE_YN === 'Y' ? '사용' : '미사용')).appendTo($b);
		});
	}

	function loadList(then) {
		hrPost('/admin/card/cardListData.do', {}, function(res) {
			cards = res.result.cards;
			codes = res.result.codes;
			manager = res.result.manager;
			staffs = res.result.staffs || [];
			$('#cardAdd').toggle(manager);
			codeNm = {}; codeIx = {};
			codes.forEach(function(c, i) { codeNm[c.CD] = c.NM; codeIx[c.CD] = i; });
			drawList();
			if (then) then();
		});
	}

	// ── 상세 ──
	function drawCard() {
		var c = card, $v = $('#viewCard').empty();
		$v.append($('<div class="cd-head">').append($('<h4>').text(c.CARD_NM + ' ').append($('<span class="cd-no">').text('****-' + c.LAST4)),
			$('<span class="text-muted">').text(c.HOLDER_NM ? '사용자 ' + c.HOLDER_NM : ''),
			manager ? $('<button type="button" class="btn btn-sm btn-outline-secondary">카드 수정</button>').click(function() { openCard(c); }) : ''));
		var $t = $('<div class="cd-tabs" role="tablist">').appendTo($v);
		['캘린더', '정산', '마감'].forEach(function(n, i) {
			// 정산에서 저장한 것이 달력에 보이도록 캘린더로 올 때는 다시 읽는다
			$('<button type="button" role="tab">').attr('aria-selected', i === tab ? 'true' : 'false').text(n).click(function() { tab = i; if (i === 0) loadMonth(); else drawCard(); }).appendTo($t);
		});
		var $b = $('<div class="cal-panel"><div class="cal-panel-body"></div></div>').appendTo($v).find('.cal-panel-body');
		if (tab === 0) drawCalendar($b); else if (tab === 1) drawSettle($b); else drawClosed($b);
		$v.append($('<div class="cd-back">').append('<a class="btn btn-sm btn-outline-secondary" href="#">목록</a>'));
	}

	function loadMonth(then) {
		hrPost('/admin/card/monthUseData.do', { CARD_SQ: card.CARD_SQ, YM: ym }, function(res) {
			card = res.result.card; uses = res.result.uses;
			drawCard();
			if (then) then();
		});
	}

	function drawCalendar($b) {
		var total = 0, byCode = {};
		uses.forEach(function(u) { total += Number(u.AMT); byCode[u.USE_CD] = (byCode[u.USE_CD] || 0) + Number(u.AMT); });
		var $sum = $('<div class="cd-sum">').append('이번 달 ', $('<b>').text(uses.length + '건 · ' + won(total) + '원'));
		codes.forEach(function(c) { if (byCode[c.CD]) $sum.append(chip(c.CD).text(c.NM + ' ' + won(byCode[c.CD]))); });
		$b.append($('<div class="cd-mbar">').append(
			$('<button type="button" class="btn btn-sm btn-outline-secondary" aria-label="이전 달">◀</button>').click(function() { ym = shiftYm(ym, -1); loadMonth(); }),
			$('<strong>').text(ym.replace('-', '년 ') + '월'),
			$('<button type="button" class="btn btn-sm btn-outline-secondary" aria-label="다음 달">▶</button>').click(function() { ym = shiftYm(ym, 1); loadMonth(); }),
			$('<button type="button" class="btn btn-sm btn-outline-secondary">오늘</button>').click(function() { ym = kstYm(0); loadMonth(); }), $sum));
		var $g = $('<div class="cd-cal">').appendTo($b), p = ym.split('-'), first = new Date(Date.UTC(+p[0], +p[1] - 1, 1)), days = new Date(Date.UTC(+p[0], +p[1], 0)).getUTCDate(), today = kstToday();
		DOW.forEach(function(d, i) { $('<div class="w">').toggleClass('sun', i === 0).toggleClass('sat', i === 6).text(d).appendTo($g); });
		for (var i = 0; i < first.getUTCDay(); i++) $('<div class="cd-day out" aria-hidden="true">').appendTo($g);
		for (var d = 1; d <= days; d++) {
			var date = ym + '-' + ('0' + d).slice(-2), list = uses.filter(function(u) { return u.USE_DT === date; }), sum = 0, dow = (first.getUTCDay() + d - 1) % 7;
			list.forEach(function(u) { sum += Number(u.AMT); });
			var $c = $('<button type="button" class="cd-day">').toggleClass('today', date === today).attr('aria-label', date + (list.length ? ' 사용 ' + list.length + '건 ' + won(sum) + '원' : ' 사용 없음') + ', 눌러서 등록')
				.append($('<span class="d">').toggleClass('sun', dow === 0).toggleClass('sat', dow === 6).text(d));
			list.slice(0, 2).forEach(function(u) { $c.append($('<span class="e">').append(chip(u.USE_CD), document.createTextNode(won(u.AMT)))); });
			if (list.length > 2) $c.append($('<span class="more">').text('+' + (list.length - 2) + '건'));
			if (list.length) $c.append($('<span class="tot">').text(won(sum)));
			$c.data('date', date).click(function() { openUse(null, $(this).data('date')); }).appendTo($g);
		}
	}

	// ── 카드 등록·수정 ──
	function openCard(c) {
		$('#cardTitle').text(c ? '카드 수정' : '카드 등록');
		['CARD_SQ', 'CARD_NM', 'CARD_CO', 'LAST4'].forEach(function(f) { $('#' + f).val(c && c[f] || ''); });
		$('#staffQ').val('');
		staffOptions(c && c.STAFF_SQ || '');
		$('#USE_YN').val(c ? c.USE_YN : 'Y');
		$('#cardModal').modal('show');
	}

	// 검색어에 맞는 직원만 남긴다. 고른 직원은 검색에 안 걸려도 남기고, 한 명만 남으면 바로 고른다
	function staffOptions(picked) {
		var q = $('#staffQ').val().trim().toLowerCase(), $s = $('#STAFF_SQ').empty().append('<option value="">직원 선택</option>');
		var list = staffs.filter(function(s) { return String(s.STAFF_SQ) === String(picked) || !q || ((s.STAFF_NM || '') + ' ' + (s.DEPT_NM || '')).toLowerCase().indexOf(q) >= 0; });
		list.forEach(function(s) {
			$s.append($('<option>').val(s.STAFF_SQ).text(s.STAFF_NM + (s.DEPT_NM ? ' · ' + s.DEPT_NM : '') + (s.STATUS_CD === 'LEFT' ? ' (퇴사)' : '') + (s.EMPLY_ID ? '' : ' (BO 계정 없음)')));
		});
		$s.val(q && list.length === 1 ? list[0].STAFF_SQ : picked || '');
	}

	function saveCard() {
		var data = {}, isNew = !$('#CARD_SQ').val();
		['CARD_SQ', 'CARD_NM', 'CARD_CO', 'LAST4', 'STAFF_SQ', 'USE_YN'].forEach(function(f) { data[f] = $('#' + f).val(); });
		hrPost('/admin/card/saveCardData.do', data, function(res) {
			$('#cardModal').modal('hide');
			if (isNew) { loadList(); location.hash = '#c=' + res.result; } else loadList(function() { loadMonth(); });
		});
	}

	// ── 사용 등록 팝업: 위는 입력, 맨 아래는 그날 등록된 다른 건 ──
	function openUse(u, date) {
		fillUse(u, date);
		$('#useModal').modal('show');
	}

	function fillUse(u, date) {
		var d = u ? u.USE_DT : date, $c = $('#useCodes').empty(), closed = !!(u && u.CLOSE_DT);
		$('#useTitle').text(d + ' (' + DOW[new Date(d + 'T00:00:00Z').getUTCDay()] + ') ' + (u ? '사용 수정' : '사용 등록'));
		$('#USE_SQ').val(u ? u.USE_SQ : '');
		$('#USE_DT').val(d);
		$('#AMT').val(u ? won(u.AMT) : '');
		['DETAIL', 'MERCHANT', 'TARGET_NM'].forEach(function(f) { $('#' + f).val(u && u[f] || ''); });
		$('#TARGET_NM').attr('placeholder', card.HOLDER_NM || '');
		codes.forEach(function(c, i) {
			$('<label>').append($('<input type="radio" name="useCd">').val(c.CD).prop('checked', u ? u.USE_CD === c.CD : i === 0), $('<span>').text(c.NM)).appendTo($c);
		});
		$('#useClosed').toggle(closed);
		$('#useModal .modal-body').find('input, textarea').not('[type=hidden]').prop('disabled', closed);
		$('#useDelete').toggle(!!u && !closed);
		$('#useSave').toggle(!closed);
		$('#useNew').toggle(!!u);
		drawDayList(d, u ? u.USE_SQ : null);
	}

	function drawDayList(date, current) {
		var list = uses.filter(function(x) { return x.USE_DT === date; }), sum = 0, $l = $('#dayList').empty();
		list.forEach(function(x) { sum += Number(x.AMT); });
		$l.append($('<div>').append(document.createTextNode('이 날 등록된 사용 ' + list.length + '건'), $('<span class="amt">').text(won(sum) + '원')));
		if (!list.length) $l.append('<div class="text-muted">아직 없습니다.</div>');
		list.forEach(function(x) {
			var on = String(x.USE_SQ) === String(current), name = [x.MERCHANT, x.DETAIL].filter(Boolean).join(' · ');
			$('<div>').toggleClass('on', on).append(chip(x.USE_CD), $('<span>').text(name + (x.CLOSE_DT ? ' (마감)' : '')), $('<span class="amt">').text(won(x.AMT)),
				$('<button type="button" class="btn btn-sm btn-outline-secondary">').text(on ? '보는 중' : x.CLOSE_DT ? '보기' : '수정').prop('disabled', on)
					.attr('aria-label', (name || codeNm[x.USE_CD]) + (x.CLOSE_DT ? ' 보기' : ' 수정')).click(function() { fillUse(x); })).appendTo($l);
		});
	}

	function saveUse() {
		var $b = $('#useSave').prop('disabled', true), done = function() { $b.prop('disabled', false); };
		var data = { CARD_SQ: card.CARD_SQ, USE_CD: $('input[name=useCd]:checked').val() || '' };
		['USE_SQ', 'USE_DT', 'AMT', 'DETAIL', 'MERCHANT', 'TARGET_NM'].forEach(function(f) { data[f] = $('#' + f).val(); });
		hrPost('/admin/card/saveUseData.do', data, function() {
			done();
			toast('저장했습니다');
			ym = data.USE_DT.slice(0, 7);
			pRes = null;
			loadMonth(function() { fillUse(null, data.USE_DT); });
		}, done);
	}

	function deleteUse() {
		var sq = $('#USE_SQ').val(), date = $('#USE_DT').val();
		bootbox.confirm('이 사용 내역을 삭제할까요?', function(ok) {
			if (!ok) return;
			hrPost('/admin/card/deleteUseData.do', { CARD_SQ: card.CARD_SQ, USE_SQ: sq }, function() { toast('삭제했습니다'); pRes = null; loadMonth(function() { fillUse(null, date); }); });
		});
	}

	// ── 정산: 기간 안에 등록한 건을 모두 보이고, 카드사 엑셀을 올리면 날짜·금액으로 대조한다 ──
	var TYPE = { MATCH: '일치', REG_ONLY: '불일치', EXCEL_ONLY: '미등록', NONE: '대조 전' };
	var TYPE_HINT = { MATCH: '', REG_ONLY: '엑셀에 없음', EXCEL_ONLY: '엑셀에만 있음 · 저장하면 등록', NONE: '' };

	function postForm(url, data, done) {
		var fd = new FormData();
		$.each(data, function(k, v) { if (v != null) fd.append(k, v); });
		$.ajax({ url: url, type: 'POST', data: fd, processData: false, contentType: false }).done(function(res) {
			if (res.error) { bootbox.alert(res.error); return; }
			done(res);
		}).fail(function() { bootbox.alert('불러오지 못했습니다. 다시 시도해 주세요.'); });
	}

	function loadPeriod() {
		postForm('/admin/card/periodData.do', { CARD_SQ: card.CARD_SQ, FROM: pFrom, TO: pTo, file: pFile }, function(res) {
			pRes = res.result;
			pRes.rows.forEach(function(x) {
				var u = x.USE;
				x.closed = !!(u && u.CLOSE_DT);
				// E 는 화면에서 고치는 값. 일치 건의 사용처는 엑셀 가맹점으로 채운다
				x.E = u ? { USE_CD: u.USE_CD, DETAIL: u.DETAIL || '', MERCHANT: u.MERCHANT || x.MERCHANT || '', TARGET_NM: u.TARGET_NM || '' }
					: { USE_CD: x.GUESS_CD, DETAIL: '', MERCHANT: x.MERCHANT || '', TARGET_NM: '' };
			});
			drawCard();
		});
	}

	function periodBar(from, to, onChange) {
		function pick(id, label, v) {
			return $('<div>').append($('<label>').attr('for', id).text(label), $('<input type="date" class="form-control form-control-sm" required>').attr('id', id).val(v));
		}
		var $bar = $('<div class="cd-bar">').append(pick('perFrom', '기간 시작', from), pick('perTo', '기간 끝', to));
		$bar.append($('<button type="button" class="btn btn-sm btn-outline-secondary">조회</button>').click(function() {
			var f = $('#perFrom').val(), t = $('#perTo').val();
			if (!f || !t || f > t) { bootbox.alert('기간을 확인해 주세요.'); return; }
			onChange(f, t);
		}));
		return $bar;
	}

	function drawSettle($b) {
		var $bar = periodBar(pFrom, pTo, function(f, t) { pFrom = f; pTo = t; pRes = null; loadPeriod(); }).appendTo($b);
		var $file = $('<input type="file" accept=".xls,.xlsx" class="d-none">').on('change', function() { if (this.files[0]) setFile(this.files[0]); this.value = ''; });
		var $drop = $('<div class="cd-drop">').append('카드사 이용내역 엑셀(.xls, .xlsx)을 끌어다 놓거나 ', $('<a href="#">파일 선택</a>').click(function(e) { e.preventDefault(); $file.click(); }), $file);
		if (pFile) $drop.append($('<div class="mt-1">').append(document.createTextNode('대조 중: ' + pFile.name + ' '), $('<a href="#">빼기</a>').click(function(e) { e.preventDefault(); pFile = null; pRes = null; loadPeriod(); })));
		$drop.on('dragover', function(e) { e.preventDefault(); $drop.addClass('over'); }).on('dragleave', function() { $drop.removeClass('over'); })
			.on('drop', function(e) { e.preventDefault(); $drop.removeClass('over'); var f = e.originalEvent.dataTransfer.files[0]; if (f) setFile(f); });
		$bar.append($drop);
		if (!pRes) { $b.append('<p class="text-muted mt-3 mb-0">불러오는 중입니다.</p>'); loadPeriod(); return; }

		var r = pRes, cnt = { MATCH: 0, REG_ONLY: 0, EXCEL_ONLY: 0, NONE: 0 }, sum = 0, noDetail = 0, closed = 0;
		r.rows.forEach(function(x) { cnt[x.TYPE]++; sum += Number(x.AMT); if (x.closed) closed++; else if (!x.E.DETAIL.trim()) noDetail++; });
		var $st = $('<div class="cd-stat">').appendTo($b);
		$st.append($('<div>').append('전체', $('<b>').text(r.rows.length + '건'), won(sum) + '원'));
		$st.append($('<div>').append($('<span class="t-MATCH">').text('일치'), $('<b>').text(cnt.MATCH + '건'), '엑셀과 맞음'));
		if (pFile) {
			$st.append($('<div>').append($('<span class="t-REG_ONLY">').text('불일치'), $('<b>').text(cnt.REG_ONLY + '건'), '엑셀에 없음'));
			$st.append($('<div>').append($('<span class="t-EXCEL_ONLY">').text('미등록'), $('<b>').text(cnt.EXCEL_ONLY + '건'), '엑셀에만 있음'));
		} else $st.append($('<div>').append($('<span class="t-NONE">').text('대조 전'), $('<b>').text(cnt.NONE + '건'), '엑셀을 올리면 대조'));
		$st.append($('<div>').append($('<span class="t-REG_ONLY">').text('내용 없음'), $('<b>').text(noDetail + '건'), '아래에서 바로 입력'));
		$st.append($('<div>').append('마감됨', $('<b>').text(closed + '건'), '수정 불가'));
		if (r.otherCnt) $b.append($('<p class="small text-muted">').text('엑셀에 기간 밖 이용 ' + r.otherCnt + '건이 있어 뺐습니다.'));
		if (!r.rows.length) { $b.append('<p class="text-muted mb-0">이 기간에 등록한 사용 내역이 없습니다.</p>'); return; }

		var $t = $('<tbody>');
		r.rows.forEach(function(x) {
			var what = x.USE_DT + ' ' + won(x.AMT) + '원 ';
			var $tr = $('<tr>').addClass(x.closed ? 'r-closed' : 'r-' + x.TYPE).append($('<td class="text-nowrap">').text(x.USE_DT),
				$('<td class="text-nowrap">').append($('<span>').addClass('t-' + x.TYPE).text(TYPE[x.TYPE]), x.closed ? ' · 마감' : '', TYPE_HINT[x.TYPE] ? $('<div class="small text-muted">').text(TYPE_HINT[x.TYPE]) : ''),
				$('<td class="text-right text-nowrap">').text(won(x.AMT)));
			if (x.closed) $tr.append($('<td>').append(chip(x.E.USE_CD)), $('<td>').text(x.E.MERCHANT), $('<td>').text(x.E.DETAIL), $('<td>').text(x.E.TARGET_NM || card.HOLDER_NM || ''));
			else {
				var $s = $('<select class="form-control form-control-sm">').attr('aria-label', what + '사용처 코드');
				codes.forEach(function(c) { $s.append($('<option>').val(c.CD).text(c.NM)); });
				$s.val(x.E.USE_CD).on('change', function() { x.E.USE_CD = this.value; });
				var field = function(f, label, max, ph) {
					return $('<input class="form-control form-control-sm">').attr({ 'aria-label': what + label, maxlength: max, placeholder: ph || '' }).val(x.E[f])
						.toggleClass('need', f === 'DETAIL' && !x.E[f].trim()).on('input', function() { x.E[f] = this.value; if (f === 'DETAIL') $(this).toggleClass('need', !this.value.trim()); });
				};
				$tr.append($('<td>').append($s), $('<td>').append(field('MERCHANT', '사용처', 200)), $('<td>').append(field('DETAIL', '내용', 500, '내용 입력')), $('<td>').append(field('TARGET_NM', '대상', 100, card.HOLDER_NM)));
			}
			$t.append($tr);
		});
		$b.append($('<div class="table-responsive">').append($('<table class="table table-sm cal-table cd-set mb-2"><thead><tr><th>사용일</th><th>상태</th><th class="text-right">금액</th><th>사용처 코드</th><th>사용처</th><th>내용</th><th>대상</th></tr></thead></table>').append($t)));
		$b.append($('<div class="d-flex justify-content-end flex-wrap" style="gap:6px;">').append(
			$('<button type="button" class="btn btn-sm btn-outline-primary">중간 저장</button>').click(function() { savePeriod(false); }),
			$('<button type="button" class="btn btn-sm btn-primary">마감</button>').click(function() { savePeriod(true); })));
	}

	function setFile(f) {
		if (!/\.xlsx?$/i.test(f.name)) { bootbox.alert('엑셀 파일(.xls, .xlsx)만 올릴 수 있습니다.'); return; }
		// 고를 때 한 번 읽어 메모리에 둔다. 디스크 파일을 그대로 쓰면 저장 뒤 다시 대조할 때 엑셀에서 열려 있거나 바뀐 파일을 브라우저가 못 읽어 요청이 실패한다
		var reader = new FileReader();
		reader.onload = function() { pFile = new File([reader.result], f.name, { type: f.type }); pRes = null; loadPeriod(); };
		reader.onerror = function() { bootbox.alert('파일을 읽지 못했습니다. 엑셀에서 열려 있으면 닫고 다시 올려 주세요.'); };
		reader.readAsArrayBuffer(f);
	}

	function savePeriod(close) {
		var open = pRes.rows.filter(function(x) { return !x.closed; }), old = open.filter(function(x) { return x.USE; }), add = open.filter(function(x) { return !x.USE; });
		var noDetail = open.filter(function(x) { return !x.E.DETAIL.trim(); }).length;
		function col(list, f) { return list.map(f); }
		function send() {
			var data = { CARD_SQ: card.CARD_SQ, FROM: pFrom, TO: pTo, CLOSE: close ? 'Y' : 'N', USE_SQ: col(old, function(x) { return x.USE.USE_SQ; }), NEW_DT: col(add, function(x) { return x.USE_DT; }), NEW_AMT: col(add, function(x) { return x.AMT; }) };
			['USE_CD', 'DETAIL', 'MERCHANT', 'TARGET_NM'].forEach(function(f) {
				data[f] = col(old, function(x) { return x.E[f]; });
				data['NEW_' + (f === 'USE_CD' ? 'CD' : f)] = col(add, function(x) { return x.E[f]; });
			});
			hrPost('/admin/card/savePeriodData.do', $.param(data, true), function(res) {
				var n = res.result;
				toast(close ? n.closed + '건을 마감했습니다' : '저장했습니다' + (n.added ? ' (새로 등록 ' + n.added + '건)' : ''));
				// 저장은 끝났으니 예전 목록을 바로 지워, 다시 불러오기가 실패해도 같은 건을 두 번 저장하지 못하게 한다
				pRes = null; cRes = null;
				drawCard();
				loadList();
			});
		}
		if (!close) { if (!open.length) { toast('저장할 건이 없습니다'); return; } send(); return; }
		if (!open.length) { bootbox.alert('마감할 건이 없습니다.'); return; }
		var msg = pFrom + ' ~ ' + pTo + ' ' + open.length + '건을 마감할까요? 마감하면 고치지 못하고 마감 탭에서 엑셀로 받을 수 있습니다.' + (noDetail ? ' 내용이 빈 건이 ' + noDetail + '건 있습니다.' : '');
		bootbox.confirm($('<div>').text(msg).html(), function(ok) { if (ok) send(); });
	}

	// ── 마감: 마감된 건을 연/월별로 보이고 경영지원 엑셀 양식으로 내려받는다 ──
	function loadClosed() {
		hrPost('/admin/card/closedData.do', { CARD_SQ: card.CARD_SQ, FROM: cFrom, TO: cTo }, function(res) { cRes = res.result.uses; drawCard(); });
	}

	function drawClosed($b) {
		var $bar = periodBar(cFrom, cTo, function(f, t) { cFrom = f; cTo = t; cRes = null; loadClosed(); }).appendTo($b);
		if (!cRes) { $b.append('<p class="text-muted mt-3 mb-0">불러오는 중입니다.</p>'); loadClosed(); return; }
		$bar.append($('<button type="button" class="btn btn-sm btn-primary ml-auto"><i class="fas fa-file-excel"></i> 엑셀 내려받기</button>').prop('disabled', !cRes.length).click(downloadExcel));
		if (manager) $bar.append($('<button type="button" class="btn btn-sm btn-outline-danger">마감 풀기</button>').prop('disabled', !cRes.length).click(reopen));
		if (!cRes.length) { $b.append('<p class="text-muted mt-3 mb-0">이 기간에 마감된 건이 없습니다. 정산 탭에서 마감하면 여기에 모입니다.</p>'); return; }
		var groups = {}, order = [], total = 0;
		cRes.forEach(function(u) { var k = u.USE_DT.slice(0, 7); if (!groups[k]) { groups[k] = []; order.push(k); } groups[k].push(u); total += Number(u.AMT); });
		$b.append($('<p class="mt-3 mb-2">').append('마감 ', $('<b>').text(cRes.length + '건 · ' + won(total) + '원')));
		var $t = $('<tbody>');
		order.forEach(function(k) {
			var sum = 0;
			groups[k].forEach(function(u) { sum += Number(u.AMT); });
			$t.append($('<tr class="cd-grp">').append($('<td colspan="7">').text(k.slice(0, 4) + '년 ' + Number(k.slice(5)) + '월 · ' + groups[k].length + '건 · ' + won(sum) + '원')));
			groups[k].forEach(function(u) {
				$t.append($('<tr>').append($('<td class="text-nowrap">').text(u.USE_DT.slice(5)), $('<td>').append(chip(u.USE_CD)), $('<td>').text(u.MERCHANT || ''), $('<td class="text-right text-nowrap">').text(won(u.AMT)),
					$('<td>').text(u.DETAIL || ''), $('<td>').text(u.TARGET_NM || card.HOLDER_NM || ''), $('<td class="text-nowrap small text-muted">').text(u.CLOSE_DT)));
			});
		});
		$b.append($('<div class="table-responsive">').append($('<table class="table table-sm cal-table mb-0"><thead><tr><th>월-일</th><th>사용처 코드</th><th>사용처</th><th class="text-right">금액</th><th>내용</th><th>대상</th><th>마감 시각</th></tr></thead></table>').append($t)));
	}

	function downloadExcel() {
		var name = '법인카드사용내역(' + (card.CARD_CO || card.CARD_NM) + ')_' + (card.HOLDER_NM || '') + '_' + cFrom + '~' + cTo, fd = new FormData();
		$.each({ CARD_SQ: card.CARD_SQ, FROM: cFrom, TO: cTo, NAME: name }, function(k, v) { fd.append(k, v); });
		fetch('/admin/card/closedExcel.do', { method: 'POST', body: fd, credentials: 'same-origin' }).then(function(r) {
			// 로그인이 풀리면 로그인 화면(HTML)이 오므로 엑셀인지 확인한다
			if (!r.ok || (r.headers.get('Content-Type') || '').indexOf('spreadsheet') < 0) throw new Error();
			return r.blob();
		}).then(function(blob) {
			var a = document.createElement('a');
			a.href = URL.createObjectURL(blob);
			a.download = name + '.xlsx';
			document.body.appendChild(a); a.click(); a.remove();
		}).catch(function() { bootbox.alert('엑셀을 받지 못했습니다. 화면을 새로 고친 뒤 다시 시도해 주세요.'); });
	}

	function reopen() {
		bootbox.confirm($('<div>').text(cFrom + ' ~ ' + cTo + ' 마감 ' + cRes.length + '건을 풀까요? 풀면 정산 탭에서 다시 고칠 수 있습니다.').html(), function(ok) {
			if (!ok) return;
			hrPost('/admin/card/reopenData.do', { CARD_SQ: card.CARD_SQ, FROM: cFrom, TO: cTo }, function(res) { toast(res.result + '건의 마감을 풀었습니다'); cRes = null; pRes = null; loadList(loadClosed); });
		});
	}

	// ── 화면 전환 ──
	function showCurrent() {
		var m = /^#c=(\d+)/.exec(location.hash);
		$('.cd-view').hide();
		if (!m) { $('#viewList').show(); return; }
		var c = cards.filter(function(x) { return String(x.CARD_SQ) === m[1]; })[0];
		if (!c) { location.hash = ''; return; }
		card = c; tab = 0; pRes = null; pFile = null; cRes = null; ym = kstYm(0);
		$('#viewCard').show();
		loadMonth();
	}

	$(window).on('hashchange', function() { loadList(showCurrent); });
	$('#staffQ').on('input', function() { staffOptions($('#STAFF_SQ').val()); }).on('keydown', function(e) { if (e.key === 'Enter') e.preventDefault(); });
	$('#fName').on('input', drawList);
	$('#fUse').on('change', drawList);
	loadList(showCurrent);
	</script>
</body>
</html>
