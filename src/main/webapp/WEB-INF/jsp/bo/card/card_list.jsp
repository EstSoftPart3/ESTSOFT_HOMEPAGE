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
	/* 정산 */
	.cd-drop { flex: 1 1 320px; border: 2px dashed #0b6e8a; border-radius: 8px; background: #e3f6fb; padding: 14px; text-align: center; color: #084f64; }
	.cd-drop.over { background: #c8ecf6; }
	.cd-stat { display: flex; flex-wrap: wrap; gap: 10px; margin: 10px 0; }
	.cd-stat div { flex: 1 1 140px; background: #fff; border: 1px solid #ced4da; border-radius: 8px; padding: 8px 12px; font-size: 13px; }
	.cd-stat b { display: block; font-size: 20px; }
	.t-MATCH { color: #1e5c33; font-weight: 700; } .t-AMBIG { color: #7a4300; font-weight: 700; } .t-EXCEL_ONLY, .t-REG_ONLY { color: #b02a37; font-weight: 700; }
	tr.r-AMBIG td { background: #fff8e6; } tr.r-EXCEL_ONLY td, tr.r-REG_ONLY td { background: #fff1f1; }
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
								<thead><tr><th>카드명</th><th>카드번호</th><th>카드사</th><th>사용자</th><th>이번 달 사용</th><th>정산</th><th>사용</th></tr></thead>
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
						<div class="form-group col-6"><label for="CARD_CO">카드사</label><input id="CARD_CO" class="form-control form-control-sm" maxlength="30" placeholder="국민카드"></div>
						<div class="form-group col-6"><label for="LAST4">카드번호 끝 4자리</label><input id="LAST4" class="form-control form-control-sm" inputmode="numeric" pattern="\d{4}" maxlength="4" required></div>
					</div>
					<div class="form-row">
						<div class="form-group col-6"><label for="STAFF_SQ">사용자 (직원)</label><select id="STAFF_SQ" class="form-control form-control-sm" required aria-describedby="staffHint"></select></div>
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
					<div class="form-row">
						<div class="form-group col-6"><label for="AMT">금액 (원, 취소는 음수)</label><input id="AMT" class="form-control form-control-sm" inputmode="numeric" required></div>
						<div class="form-group col-6"><label for="USE_DT">사용일</label><input type="date" id="USE_DT" class="form-control form-control-sm" required></div>
					</div>
					<fieldset class="form-group">
						<legend class="col-form-label pt-0" style="font-size:inherit;font-weight:700;">사용처 코드</legend>
						<div class="cd-codes" id="useCodes"></div>
					</fieldset>
					<div class="form-group mb-0"><label for="DETAIL">사용 상세 내용</label><textarea id="DETAIL" rows="3" maxlength="500" class="form-control form-control-sm" placeholder="팀 점심 (8명) · ○○식당"></textarea></div>
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
	var manager = false, staffs = [], cards = [], codes = [], codeNm = {}, codeIx = {}, card = null, uses = [], settle = null, tab = 0, ym = kstYm(0), settleYm = kstYm(-1), lastFile = null, compared = null;
	var DOW = ['일', '월', '화', '수', '목', '금', '토'];

	function kstYm(add) { var d = new Date(Date.now() + 9 * 3600000); d.setUTCDate(1); d.setUTCMonth(d.getUTCMonth() + add); return d.toISOString().slice(0, 7); }
	function kstToday() { return new Date(Date.now() + 9 * 3600000).toISOString().slice(0, 10); }
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
				$('<td>').text(c.LAST_SETTLE_YM ? c.LAST_SETTLE_YM + ' 정산 완료' : '-'), $('<td>').text(c.USE_YN === 'Y' ? '사용' : '미사용')).appendTo($b);
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
		['캘린더', '정산'].forEach(function(n, i) {
			$('<button type="button" role="tab">').attr('aria-selected', i === tab ? 'true' : 'false').text(n).click(function() { tab = i; drawCard(); }).appendTo($t);
		});
		var $b = $('<div class="cal-panel"><div class="cal-panel-body"></div></div>').appendTo($v).find('.cal-panel-body');
		if (tab === 0) drawCalendar($b); else drawSettle($b);
		$v.append($('<div class="cd-back">').append('<a class="btn btn-sm btn-outline-secondary" href="#">목록</a>'));
	}

	function loadMonth(then) {
		hrPost('/admin/card/monthUseData.do', { CARD_SQ: card.CARD_SQ, YM: ym }, function(res) {
			card = res.result.card; uses = res.result.uses; settle = res.result.settle;
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
		var $s = $('#STAFF_SQ').empty().append('<option value="">직원 선택</option>');
		staffs.forEach(function(s) {
			$s.append($('<option>').val(s.STAFF_SQ).text(s.STAFF_NM + (s.DEPT_NM ? ' · ' + s.DEPT_NM : '') + (s.STATUS_CD === 'LEFT' ? ' (퇴사)' : '') + (s.EMPLY_ID ? '' : ' (BO 계정 없음)')));
		});
		['CARD_SQ', 'CARD_NM', 'CARD_CO', 'LAST4', 'STAFF_SQ'].forEach(function(f) { $('#' + f).val(c && c[f] || ''); });
		$('#USE_YN').val(c ? c.USE_YN : 'Y');
		$('#cardModal').modal('show');
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
	function openUse(u, date, preset) {
		fillUse(u, date, preset);
		$('#useModal').modal('show');
	}

	function fillUse(u, date, preset) {
		var d = u ? u.USE_DT : date, $c = $('#useCodes').empty();
		$('#useTitle').text(d + ' (' + DOW[new Date(d + 'T00:00:00Z').getUTCDay()] + ') ' + (u ? '사용 수정' : '사용 등록'));
		$('#USE_SQ').val(u ? u.USE_SQ : '');
		$('#USE_DT').val(d);
		$('#AMT').val(u ? won(u.AMT) : preset ? won(preset.AMT) : '');
		$('#DETAIL').val(u ? u.DETAIL || '' : preset ? preset.MERCHANT || '' : '');
		codes.forEach(function(c, i) {
			$('<label>').append($('<input type="radio" name="useCd">').val(c.CD).prop('checked', u ? u.USE_CD === c.CD : i === 0), $('<span>').text(c.NM)).appendTo($c);
		});
		$('#useDelete').toggle(!!u);
		$('#useNew').toggle(!!u);
		drawDayList(d, u ? u.USE_SQ : null);
	}

	function drawDayList(date, current) {
		var list = uses.filter(function(x) { return x.USE_DT === date; }), sum = 0, $l = $('#dayList').empty();
		list.forEach(function(x) { sum += Number(x.AMT); });
		$l.append($('<div>').append(document.createTextNode('이 날 등록된 사용 ' + list.length + '건'), $('<span class="amt">').text(won(sum) + '원')));
		if (!list.length) $l.append('<div class="text-muted">아직 없습니다.</div>');
		list.forEach(function(x) {
			$('<div>').toggleClass('on', String(x.USE_SQ) === String(current)).append(chip(x.USE_CD), $('<span>').text(x.DETAIL || ''), $('<span class="amt">').text(won(x.AMT)),
				$('<button type="button" class="btn btn-sm btn-outline-secondary">').text(String(x.USE_SQ) === String(current) ? '수정 중' : '수정').prop('disabled', String(x.USE_SQ) === String(current))
					.attr('aria-label', (x.DETAIL || codeNm[x.USE_CD]) + ' 수정').click(function() { fillUse(x); })).appendTo($l);
		});
	}

	function saveUse() {
		var $b = $('#useSave').prop('disabled', true), done = function() { $b.prop('disabled', false); };
		var data = { CARD_SQ: card.CARD_SQ, USE_SQ: $('#USE_SQ').val(), USE_DT: $('#USE_DT').val(), AMT: $('#AMT').val(), USE_CD: $('input[name=useCd]:checked').val() || '', DETAIL: $('#DETAIL').val() };
		hrPost('/admin/card/saveUseData.do', data, function() {
			done();
			toast('저장했습니다');
			ym = data.USE_DT.slice(0, 7);
			loadMonth(function() {
				if (tab === 1 && lastFile) compare(lastFile);
				fillUse(null, data.USE_DT);
			});
		}, done);
	}

	function deleteUse() {
		var sq = $('#USE_SQ').val(), date = $('#USE_DT').val();
		bootbox.confirm('이 사용 내역을 삭제할까요?', function(ok) {
			if (!ok) return;
			hrPost('/admin/card/deleteUseData.do', { CARD_SQ: card.CARD_SQ, USE_SQ: sq }, function() { toast('삭제했습니다'); loadMonth(function() { fillUse(null, date); }); });
		});
	}

	// ── 정산: 엑셀을 올리면 날짜·금액이 같은 등록 건과 짝짓는다 ──
	var TYPE = { MATCH: '일치', EXCEL_ONLY: '새로 등록', REG_ONLY: '엑셀에 없음' };

	function drawSettle($b) {
		var $file = $('<input type="file" accept=".xls,.xlsx" class="d-none" id="settleFile">').on('change', function() { if (this.files[0]) compare(this.files[0]); this.value = ''; });
		var $drop = $('<div class="cd-drop">').append('카드사 이용내역 엑셀(.xls, .xlsx)을 끌어다 놓거나 ', $('<a href="#">파일 선택</a>').click(function(e) { e.preventDefault(); $file.click(); }),
			lastFile ? $('<div class="small mt-1">').text('올린 파일: ' + lastFile.name) : '', $file);
		$drop.on('dragover', function(e) { e.preventDefault(); $drop.addClass('over'); }).on('dragleave', function() { $drop.removeClass('over'); })
			.on('drop', function(e) { e.preventDefault(); $drop.removeClass('over'); var f = e.originalEvent.dataTransfer.files[0]; if (f) compare(f); });
		var $ym = $('<input type="month" class="form-control form-control-sm" id="settleYm">').val(settleYm).on('change', function() { settleYm = this.value; compared = null; if (lastFile) compare(lastFile); else drawCard(); });
		$b.append($('<div class="d-flex flex-wrap align-items-end" style="gap:12px;">').append($('<div>').append('<label for="settleYm">정산 월</label>', $ym), $drop));
		if (!compared) { $b.append('<p class="text-muted mt-3 mb-0">엑셀을 올리면 엑셀의 모든 건을 매핑합니다. 이용일·금액이 같은 등록 건에는 가맹점을 붙이고, 등록 안 된 건은 가맹점으로 사용처 코드를 추정해 새로 등록합니다.</p>'); return; }
		var r = compared, cnt = { MATCH: 0, EXCEL_ONLY: 0, REG_ONLY: 0 }, excelSum = 0;
		r.rows.forEach(function(x) { cnt[x.TYPE]++; if (x.TYPE !== 'REG_ONLY') excelSum += Number(x.AMT); });
		$b.append($('<div class="cd-stat">').append(
			$('<div>').append('엑셀 이용 건', $('<b>').text(r.excelCnt + '건'), won(excelSum) + '원'),
			$('<div>').append($('<span class="t-MATCH">').text('일치'), $('<b>').text(cnt.MATCH + '건'), '등록 건에 가맹점 붙임'),
			$('<div>').append($('<span class="t-EXCEL_ONLY">').text('새로 등록'), $('<b>').text(cnt.EXCEL_ONLY + '건'), '확정하면 추정 코드로 등록'),
			$('<div>').append($('<span class="t-REG_ONLY">').text('엑셀에 없음'), $('<b>').text(cnt.REG_ONLY + '건'), '등록에만 있음')));
		if (r.otherMonthCnt) $b.append($('<p class="small text-muted">').text('엑셀에 다른 달 이용 ' + r.otherMonthCnt + '건이 있어 대조에서 뺐습니다.'));
		if (settle) $b.append($('<div class="alert alert-info py-2">').text(settle.YM + ' 정산 완료 · ' + settle.DONE_DT + ' · 일치 ' + settle.MATCH_CNT + '/' + settle.EXCEL_CNT + '건 (다시 확정하면 덮어씁니다)'));
		var $t = $('<tbody>');
		r.rows.forEach(function(x, i) {
			var $tr = $('<tr>').addClass('r-' + x.TYPE).append($('<td>').text(x.USE_DT.slice(5)), $('<td>').text(x.TYPE === 'REG_ONLY' ? '(엑셀에 없음)' : x.MERCHANT || ''), $('<td class="text-right">').text(won(x.AMT)),
				$('<td>').append($('<span>').addClass('t-' + x.TYPE).text(TYPE[x.TYPE])));
			if (x.TYPE === 'MATCH' || x.TYPE === 'REG_ONLY') $tr.append($('<td>').append(chip(x.USE.USE_CD)), $('<td>').text(x.USE.DETAIL || ''));
			else {
				// 추정한 코드는 확정 전에 바꿀 수 있다
				var $s = $('<select class="form-control form-control-sm">').attr('aria-label', x.USE_DT + ' ' + (x.MERCHANT || '') + ' 사용처 코드');
				codes.forEach(function(c) { $s.append($('<option>').val(c.CD).text(c.NM)); });
				$s.val(x.GUESS_CD).on('change', function() { x.GUESS_CD = this.value; });
				$tr.append($('<td>').append($s), $('<td>').text(x.MERCHANT || ''));
			}
			$t.append($tr);
		});
		$b.append($('<div class="table-responsive">').append($('<table class="table table-sm cal-table mb-2"><thead><tr><th>이용일</th><th>가맹점 (엑셀)</th><th class="text-right">금액</th><th>대조</th><th>사용처 코드</th><th>사용 상세 내용</th></tr></thead></table>').append($t)));
		$b.append($('<div class="d-flex justify-content-end flex-wrap" style="gap:6px;">').append(
			$('<button type="button" class="btn btn-sm btn-outline-secondary">결과 내려받기 (CSV)</button>').click(downloadCsv),
			$('<button type="button" class="btn btn-sm btn-primary">정산 확정</button>').click(confirmSettle)));
	}

	function compare(file) {
		if (!/\.xlsx?$/i.test(file.name)) { bootbox.alert('엑셀 파일(.xls, .xlsx)만 올릴 수 있습니다.'); return; }
		lastFile = file;
		var fd = new FormData();
		fd.append('CARD_SQ', card.CARD_SQ);
		fd.append('YM', settleYm);
		fd.append('file', file);
		$.ajax({ url: '/admin/card/compareData.do', type: 'POST', data: fd, processData: false, contentType: false }).done(function(res) {
			if (res.error) { bootbox.alert(res.error); return; }
			compared = res.result;
			// 등록 창의 '이 날 등록된 사용' 이 정산 월 내역을 보도록 달력 월도 맞춘다
			hrPost('/admin/card/monthUseData.do', { CARD_SQ: card.CARD_SQ, YM: settleYm }, function(m) { settle = m.result.settle; uses = m.result.uses; ym = settleYm; drawCard(); });
		});
	}

	function confirmSettle() {
		var match = compared.rows.filter(function(x) { return x.TYPE === 'MATCH'; }), add = compared.rows.filter(function(x) { return x.TYPE === 'EXCEL_ONLY'; });
		var msg = settleYm + ' 정산을 확정할까요? 일치 ' + match.length + '건에 가맹점을 붙이고, ' + add.length + '건을 새로 등록합니다.';
		bootbox.confirm($('<div>').text(msg).html(), function(ok) {
			if (!ok) return;
			function col(list, f) { return list.map(f); }
			var data = { CARD_SQ: card.CARD_SQ, YM: settleYm, FILE_NM: lastFile ? lastFile.name : '', EXCEL_CNT: compared.excelCnt,
				USE_SQ: col(match, function(x) { return x.USE.USE_SQ; }), MERCHANT: col(match, function(x) { return x.MERCHANT || ''; }),
				NEW_DT: col(add, function(x) { return x.USE_DT; }), NEW_AMT: col(add, function(x) { return x.AMT; }), NEW_CD: col(add, function(x) { return x.GUESS_CD; }), NEW_MERCHANT: col(add, function(x) { return x.MERCHANT || ''; }) };
			hrPost('/admin/card/confirmSettleData.do', $.param(data, true), function() { toast(settleYm + ' 정산을 확정했습니다'); loadList(function() { compare(lastFile); }); });
		});
	}

	function downloadCsv() {
		var lines = [['이용일', '가맹점', '금액', '대조', '사용처 코드', '사용 상세 내용']];
		compared.rows.forEach(function(x) {
			var u = x.USE || { USE_CD: x.GUESS_CD, DETAIL: x.MERCHANT };
			lines.push([x.USE_DT, x.MERCHANT || '', x.AMT, TYPE[x.TYPE], codeNm[u.USE_CD] || u.USE_CD || '', u.DETAIL || '']);
		});
		var csv = '﻿' + lines.map(function(l) { return l.map(function(v) { return '"' + String(v).replace(/"/g, '""') + '"'; }).join(','); }).join('\r\n');
		var a = document.createElement('a');
		a.href = URL.createObjectURL(new Blob([csv], { type: 'text/csv;charset=utf-8' }));
		a.download = card.CARD_NM + '_' + settleYm + '_정산.csv';
		document.body.appendChild(a); a.click(); a.remove();
	}

	// ── 화면 전환 ──
	function showCurrent() {
		var m = /^#c=(\d+)/.exec(location.hash);
		$('.cd-view').hide();
		if (!m) { $('#viewList').show(); return; }
		var c = cards.filter(function(x) { return String(x.CARD_SQ) === m[1]; })[0];
		if (!c) { location.hash = ''; return; }
		card = c; tab = 0; compared = null; lastFile = null; ym = kstYm(0);
		$('#viewCard').show();
		loadMonth();
	}

	$(window).on('hashchange', function() { loadList(showCurrent); });
	$('#fName').on('input', drawList);
	$('#fUse').on('change', drawList);
	loadList(showCurrent);
	</script>
</body>
</html>
