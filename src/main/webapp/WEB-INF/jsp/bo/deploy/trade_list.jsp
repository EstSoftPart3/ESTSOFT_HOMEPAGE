<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/deploy/deploy_common.jspf"%>
<style>
	.tr-chip { display: inline-flex; align-items: center; gap: 4px; border: 1px solid #ced4da; border-radius: 999px; padding: 2px 10px; font-size: 12.5px; background: #fff; cursor: pointer; margin: 0; user-select: none; }
	.tr-chip input { margin: 0; }
	.tr-chip.on { border-color: #0b6e8a; background: #e3f6fb; color: #084f64; font-weight: 700; }
	.tr-table td, .tr-table th { white-space: nowrap; }
	.tr-table td.item { max-width: 420px; overflow: hidden; text-overflow: ellipsis; }
	.tr-amt { background: none; border: 0; padding: 0; color: inherit; border-bottom: 1px dotted #8a949c; font-variant-numeric: tabular-nums; }
	.tr-partner { margin-bottom: 18px; }
	.tr-partner > h5 { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; font-size: 16px; font-weight: 700; margin: 0 0 8px; }
	.tr-partner > h5 small { color: #495057; font-weight: 400; }
	.tr-inv { border: 1px solid #ced4da; border-radius: 8px; margin-bottom: 8px; background: #fff; overflow: hidden; }
	.tr-inv.issued { border-color: #17692f; background: #f6fbf7; }
	.tr-inv.over, .tr-new.over { outline: 2px dashed #0b6e8a; outline-offset: -2px; background: #e3f6fb; }
	.tr-inv-h { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; padding: 6px 10px; background: #f3f6f8; font-size: 13px; }
	.tr-inv.issued .tr-inv-h { background: #e6f6ea; }
	.tr-inv-h .sum { margin-left: auto; font-variant-numeric: tabular-nums; }
	.tr-inv-h .sum b { font-size: 14px; }
	.tr-inv table { margin: 0; }
	.tr-inv td { padding: 3px 8px; vertical-align: middle; white-space: nowrap; border-top: 1px solid #eef1f4; }
	.tr-inv td.item { white-space: normal; width: 100%; }
	.tr-inv tr.dragging { opacity: .4; }
	.tr-inv tr.over td { border-top: 2px solid #0b6e8a; }
	.tr-move button { background: none; border: 0; color: #495057; min-width: 26px; min-height: 26px; padding: 0 4px; }
	.tr-move .hdl { cursor: grab; letter-spacing: -3px; font-size: 16px; }
	.tr-cut { background: none; border: 1px dashed #adb5bd; border-radius: 4px; color: #495057; font-size: 11px; padding: 0 6px; }
	.tr-new { border: 1px dashed #adb5bd; border-radius: 8px; padding: 8px; text-align: center; color: #6c757d; font-size: 12.5px; }
	.tr-cp { background: none; border: 0; padding: 0 3px; margin-left: 2px; color: #8a949c; font-size: 12px; line-height: 1; min-width: 20px; min-height: 20px; }
	.tr-cp:hover, .tr-cp:focus { color: #0b6e8a; outline: 2px solid #16d5ff; border-radius: 3px; }
	#trToast { position: fixed; right: 18px; bottom: 18px; z-index: 2000; background: #222; color: #fff; font-size: 13px; padding: 8px 14px; border-radius: 6px; display: none; }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header d-flex align-items-center">
					<h3 class="card-title bTitle"><b id="pageTitle"></b></h3>
					<span class="ml-auto d-flex" style="gap:6px;">
						<button type="button" class="btn btn-sm btn-outline-secondary" id="btnExcel" style="display:none;"><i class="fas fa-file-excel"></i> 엑셀 다운로드</button>
						<button type="button" class="btn btn-sm btn-primary" id="btnAdd" onclick="openForm(null);"><i class="fas fa-plus"></i> <span id="btnAddText">일반 건 등록</span></button>
					</span>
				</div>
				<div class="card-body">
					<div class="dp-kpis" id="kpis"></div>
					<div class="cal-panel">
						<div class="dp-bar">
							<button type="button" class="btn btn-sm btn-outline-secondary" onclick="moveMonth(-1);" aria-label="이전 달">&#9664;</button>
							<label for="ym" class="sr-only">기준월</label><input type="month" id="ym" class="form-control form-control-sm" style="width:150px">
							<button type="button" class="btn btn-sm btn-outline-secondary" onclick="moveMonth(1);" aria-label="다음 달">&#9654;</button>
							<label for="fPartner" class="sr-only">거래처</label><select id="fPartner" class="form-control form-control-sm" style="width:170px"></select>
							<span id="chips" class="d-inline-flex flex-wrap" style="gap:6px;"></span>
							<span class="ml-auto"><input type="search" id="keyword" class="form-control form-control-sm" style="width:190px" placeholder="품목·거래처" aria-label="검색"></span>
						</div>
						<div class="cate-tabs" id="tabs" role="tablist" aria-label="보기"></div>

						<div id="paneList">
							<div class="table-responsive">
								<table class="table table-sm table-hover cal-table tr-table mb-0">
									<thead><tr><th>구분</th><th>거래처</th><th>품목</th><th>기간</th><th class="dp-num">공급가액</th><th class="dp-num">세액</th><th class="dp-num">합계금액</th><th class="only-sale">세금계산서</th><th>메모</th><th><span class="sr-only">작업</span></th></tr></thead>
									<tbody id="listBody"></tbody>
									<tfoot id="listFoot"></tfoot>
								</table>
							</div>
							<div class="small text-muted px-3 py-2">투입 건은 투입현황에서 자동으로 나옵니다(마감한 달은 급여관리 금액, 아니면 단가 일할). 금액을 누르면 이 달 금액만 고칠 수 있습니다. 일반 건은 품목을 눌러 고칩니다.</div>
						</div>

						<div id="paneInv" style="display:none;" class="px-3 pb-3">
							<div class="dp-bar px-0">
								<label for="sortKey" class="mb-0">정렬</label>
								<select id="sortKey" class="form-control form-control-sm" style="width:150px">
									<option value="">지금 순서 그대로</option><option value="ITEM_NM">품목 이름순</option><option value="STAFF_NM">성명순</option><option value="AMT">금액 큰 순</option><option value="START_DT">시작일순</option>
								</select>
								<label for="perInv" class="mb-0">한 장에</label>
								<input type="number" id="perInv" class="form-control form-control-sm" style="width:70px" min="1" max="99" value="4"><span>행씩</span>								<span class="small text-muted">거래처마다 「다시 묶기」를 누르면 이 설정으로 묶습니다. 묶은 뒤에는 행을 끌거나 ▲▼, 「나누기」「위와 합치기」로 장마다 행 수를 바꿉니다. 바꾸면 바로 저장됩니다.</span>
							</div>
							<div id="invBody"></div>
						</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="formModal" tabindex="-1" role="dialog" aria-labelledby="formTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<form class="modal-content" onsubmit="saveForm(); return false;">
				<div class="modal-header">
					<h5 class="modal-title" id="formTitle">일반 건 등록</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<input type="hidden" id="TRADE_SQ">
					<div class="form-row">
						<div class="form-group col-7"><label for="PARTNER_SQ">거래처</label><select id="PARTNER_SQ" class="form-control form-control-sm" required></select>
							<label for="PARTNER_NM" class="sr-only">거래처 이름 직접 입력</label><input id="PARTNER_NM" class="form-control form-control-sm mt-1" maxlength="200" placeholder="거래처 이름 직접 입력" style="display:none;"></div>
						<div class="form-group col-5"><label for="TYPE_NM">구분</label><input id="TYPE_NM" class="form-control form-control-sm" maxlength="50" list="typeList" required placeholder="임대료, 장비, 용역…"><datalist id="typeList"></datalist></div>
					</div>
					<div class="form-group"><label for="ITEM_NM">품목</label><input id="ITEM_NM" class="form-control form-control-sm" maxlength="300" required></div>
					<div class="form-row">
						<div class="form-group col-4"><label for="START_DT">시작일</label><input type="date" id="START_DT" class="form-control form-control-sm"></div>
						<div class="form-group col-4"><label for="END_DT">종료일</label><input type="date" id="END_DT" class="form-control form-control-sm"></div>
						<div class="form-group col-4"><label for="AMT">공급가액</label><input id="AMT" class="form-control form-control-sm text-right" inputmode="numeric" required></div>
					</div>
					<div class="form-group mb-0"><label for="MEMO">메모</label><input id="MEMO" class="form-control form-control-sm" maxlength="500"></div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-sm btn-outline-danger mr-auto" id="btnDelete" onclick="deleteForm();">삭제</button>
					<button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">취소</button>
					<button type="submit" class="btn btn-sm btn-primary">저장</button>
				</div>
			</form>
		</div>
	</div>

	<div id="trToast" role="status" aria-live="polite"></div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>
	<script>
	var KIND = '${kind}', SALE = KIND === 'SALE', BASE = '/admin/trade/' + KIND.toLowerCase() + '/';
	// 세금계산서 메뉴: 매출 건의 묶음만 보인다(내역·등록은 매출·매입 현황에서)
	var INV_ONLY = '${invoiceOnly}' === 'true', invOff = {};
	var lines = [], partners = [], tab = INV_ONLY ? 1 : 0, typeOff = {}, inv = {}, drag = null;

	function toast(msg) { $('#trToast').text(msg).stop(true, true).fadeIn(100).delay(1500).fadeOut(300); }
	function ymNow() { return $('#ym').val(); }
	function vat(a) { return a < 0 ? -Math.floor(-a / 10) : Math.floor(a / 10); }
	function md(d) { return d ? Number(d.substring(5, 7)) + '/' + Number(d.substring(8, 10)) : ''; }
	function period(l) { return l.START_DT || l.END_DT ? md(l.START_DT) + '-' + md(l.END_DT) : ''; }
	// 등록된 거래처는 번호, 직접 입력한 곳은 이름으로 묶는다
	function pKey(l) { return l.PARTNER_SQ ? String(l.PARTNER_SQ) : 'n:' + (l.PARTNER_NM || ''); }
	// 누르면 그 값만 복사한다(홈택스에 붙여 넣기용). 금액은 쉼표 없는 숫자
	function cp(v, label) {
		return $('<button type="button" class="tr-cp" title="복사">&#10697;</button>').attr('aria-label', label + ' ' + v + ' 복사').click(function(e) { e.stopPropagation(); copyText(String(v), label + ' 복사: ' + v); });
	}
	function pName(l) { return l.PARTNER_NM || (SALE ? '매출처 미지정' : '매입처 미지정'); }
	function sum(list) { return list.reduce(function(a, l) { return a + Number(l.AMT || 0); }, 0); }
	function issued(g) { return g.length > 0 && g.every(function(l) { return !!l.ISSUE_DT; }); }
	function typePill(l) { return $('<span class="dp-pill">').addClass(l.SRC_CD === 'D' ? 'rent' : '').text(l.TYPE_NM); }

	function shown() {
		var p = $('#fPartner').val(), q = $('#keyword').val().trim().toLowerCase();
		return lines.filter(function(l) {
			return !typeOff[l.TYPE_NM] && (!p || pKey(l) === p) && (!q || ((l.ITEM_NM || '') + ' ' + pName(l)).toLowerCase().indexOf(q) >= 0);
		});
	}

	// ── 불러오기 ──
	function load(keepTab) {
		hrPost(BASE + 'listData.do', { YM: ymNow() }, function(res) {
			lines = res.result.lines;
			partners = res.result.partners;
			$('#typeList').empty().append(res.result.types.map(function(t) { return $('<option>').val(t); }));
			var cur = $('#fPartner').val(), seen = {};
			$('#fPartner').empty().append('<option value="">거래처 전체</option>');
			lines.slice().sort(function(a, b) { return pName(a).localeCompare(pName(b), 'ko'); }).forEach(function(l) {
				if (!seen[pKey(l)]) { seen[pKey(l)] = 1; $('#fPartner').append($('<option>').val(pKey(l)).text(pName(l))); }
			});
			$('#fPartner').val(seen[cur] ? cur : '');
			buildInv();
			draw();
		});
	}

	function moveMonth(d) {
		var m = moment(ymNow() + '-01').add(d, 'months');
		$('#ym').val(m.format('YYYY-MM'));
		load();
	}

	function draw() {
		var list = shown(), groups = [], done = 0;
		Object.keys(inv).forEach(function(p) { inv[p].forEach(function(g) { groups.push(g); if (issued(g)) done++; }); });
		var s = sum(list);
		$('#kpis').empty().append(kpi('건수', list.length + '건'), kpi('공급가액', dpWon(s)), kpi('세액', dpWon(vat(s))), kpi('합계금액', dpWon(s + vat(s))),
			SALE ? kpi('세금계산서', groups.length + '장 · 발급 ' + done + '장', done < groups.length ? 'warn' : '') : '');
		if (INV_ONLY) {
			// 미발급·발급 완료 칩으로 계산서를 거른다
			var $c = $('#chips').empty();
			[['todo', '미발급', groups.length - done], ['done', '발급 완료', done]].forEach(function(x) {
				var $i = $('<input type="checkbox" class="tr-chk">').prop('checked', !invOff[x[0]]).on('change', function() { invOff[x[0]] = !this.checked; draw(); });
				$c.append($('<label class="tr-chip">').toggleClass('on', !invOff[x[0]]).append($i, document.createTextNode(x[1] + ' ' + x[2])));
			});
			$('#tabs, #paneList').hide();
			$('#paneInv').show();
			drawInv();
			return;
		}
		drawChips();
		// 매입관리는 매입 건을 한눈에 보는 목록만 둔다(세금계산서 묶음은 매출관리에만)
		if (!SALE) { $('#tabs, .only-sale').hide(); drawList(list); return; }
		var $t = $('#tabs').empty(), left = groups.length - done;
		[['내역', lines.length ? '(' + lines.length + ')' : ''], ['세금계산서', left ? '(미발급 ' + left + ')' : '']].forEach(function(x, i) {
			$('<button type="button" class="cate-tab" role="tab">').toggleClass('active', i === tab).attr('aria-selected', i === tab ? 'true' : 'false').text(x[0] + x[1]).click(function() { tab = i; draw(); }).appendTo($t);
		});
		$('#paneList').toggle(tab === 0);
		$('#paneInv').toggle(tab === 1);
		if (tab === 0) drawList(list); else drawInv();
	}

	function kpi(k, v, cls) { return $('<div class="dp-kpi">').addClass(cls || '').append($('<span>').text(k), $('<b>').text(v)); }

	// 구분 칩: 투입 + 일반 건의 구분들. 맨 앞은 전체 선택/해제
	function drawChips() {
		var cnt = {}, names = [];
		lines.forEach(function(l) { if (!cnt[l.TYPE_NM]) { cnt[l.TYPE_NM] = 0; names.push(l.TYPE_NM); } cnt[l.TYPE_NM]++; });
		names.sort(function(a, b) { return (b === '투입') - (a === '투입') || a.localeCompare(b, 'ko'); });
		var allOn = names.every(function(n) { return !typeOff[n]; }), $c = $('#chips').empty();
		if (names.length > 1) $c.append($('<button type="button" class="btn btn-sm btn-outline-secondary py-0">').text(allOn ? '☑ 전체 해제' : '☐ 전체 선택').click(function() {
			names.forEach(function(n) { typeOff[n] = allOn; });
			draw();
		}));
		names.forEach(function(n) {
			var $i = $('<input type="checkbox">').prop('checked', !typeOff[n]).on('change', function() { typeOff[n] = !this.checked; draw(); });
			$c.append($('<label class="tr-chip">').toggleClass('on', !typeOff[n]).append($i, document.createTextNode(n + ' ' + cnt[n])));
		});
	}

	// ── 내역 ──
	function invLabel(l) {
		if (l.INV_NO === null || l.INV_NO === undefined) return $('<span class="dp-mute">').text('묶기 전');
		return $('<span class="dp-pill">').addClass(l.ISSUE_DT ? 'ok' : 'warn').text('#' + l.INV_NO + (l.ISSUE_DT ? ' 발급 ' + md(l.ISSUE_DT) : ' 미발급'));
	}

	function drawList(list) {
		var $b = $('#listBody').empty();
		if (!list.length) boEmpty($b, '이 달에 해당하는 건이 없습니다.');
		list.slice().sort(function(a, b) { return pName(a).localeCompare(pName(b), 'ko') || String(a.ITEM_NM).localeCompare(String(b.ITEM_NM), 'ko'); }).forEach(function(l) {
			var a = Number(l.AMT || 0), $amt = $('<td class="dp-num">'), $item = $('<td class="item">').attr('title', l.ITEM_NM);
			if (l.SRC_CD === 'D') {
				$item.text(l.ITEM_NM);
				if (l.AMT_FIXED !== null && l.AMT_FIXED !== undefined) $amt.append($('<span class="dp-was">').text(dpWon(l.CALC_AMT)));
				$amt.append($('<button type="button" class="tr-amt">').text(dpWon(a)).attr({ title: l.HOW, 'aria-label': l.ITEM_NM + ' 금액 ' + dpWon(a) + ' 고치기' }).click(function() { editAmount(l); }));
			} else {
				$item.append($('<button type="button" class="dp-name">').text(l.ITEM_NM).click(function() { openForm(l); }));
				$amt.text(dpWon(a));
			}
			$('<tr>').toggleClass('dp-secret', !!l.SECRET).append($('<td>').append(typePill(l)), $('<td>').text(pName(l)), $item, $('<td>').text(period(l)), $amt,
				$('<td class="dp-num">').text(dpWon(vat(a))), $('<td class="dp-num">').text(dpWon(a + vat(a))), SALE ? $('<td>').append(invLabel(l)) : '', $('<td>').text(l.MEMO || ''),
				$('<td>').append(l.SRC_CD === 'M' ? $('<button type="button" class="btn btn-sm btn-outline-danger py-0">삭제</button>').attr('aria-label', l.ITEM_NM + ' 삭제').click(function() { deleteTrade(l.SRC_SQ, l.ITEM_NM); }) : '')).appendTo($b);
		});
		var s = sum(list);
		$('#listFoot').empty().append(list.length ? $('<tr class="font-weight-bold">').append('<td colspan="4">합계</td>', $('<td class="dp-num">').text(dpWon(s)), $('<td class="dp-num">').text(dpWon(vat(s))), $('<td class="dp-num">').text(dpWon(s + vat(s))), '<td colspan="3"></td>') : '');
	}

	function editAmount(l) {
		bootbox.prompt({ title: l.ITEM_NM + ' · 이 달 공급가액 (비우면 계산 금액 ' + dpWon(l.CALC_AMT) + ' 으로 돌아갑니다)', value: String(l.AMT), callback: function(v) {
			if (v === null) return;
			hrPost(BASE + 'amountData.do', { YM: ymNow(), KEY: l.KEY, AMT: v }, function() { toast('금액을 저장했습니다'); load(); });
		} });
	}

	// ── 일반 건 팝업 ──
	function openForm(l) {
		$('#formTitle').text((l ? '일반 건 수정' : '일반 건 등록') + ' · ' + dpYmLabel(ymNow()));
		var $p = $('#PARTNER_SQ').empty().append('<option value=""></option>');
		partners.filter(function(p) { return (l && String(p.PARTNER_SQ) === pKey(l)) || (p.USE_YN === 'Y' && (SALE ? p.SALE_YN : p.BUY_YN) === 'Y'); })
			.forEach(function(p) { $p.append($('<option>').val(p.PARTNER_SQ).text(p.PARTNER_NM)); });
		$p.append('<option value="__new">직접 입력… (거래처로 등록하지 않은 곳)</option>');
		$('#TRADE_SQ').val(l ? l.SRC_SQ : '');
		var typed = l && !l.PARTNER_SQ, f = $('#fPartner').val();
		$p.val(typed ? '__new' : l ? pKey(l) : (/^\d+$/.test(f) ? f : ''));
		$('#PARTNER_NM').val(typed ? l.PARTNER_NM : '');
		$p.trigger('change');
		$('#TYPE_NM').val(l ? l.TYPE_NM : '');
		$('#ITEM_NM').val(l ? l.ITEM_NM : '');
		$('#START_DT').val(l && l.START_DT || '');
		$('#END_DT').val(l && l.END_DT || '');
		$('#AMT').val(l ? l.AMT : '');
		$('#MEMO').val(l && l.MEMO || '');
		$('#btnDelete').toggle(!!l);
		$('#formModal').modal('show');
	}

	function saveForm() {
		var data = { YM: ymNow() };
		['TRADE_SQ', 'PARTNER_SQ', 'PARTNER_NM', 'TYPE_NM', 'ITEM_NM', 'START_DT', 'END_DT', 'AMT', 'MEMO'].forEach(function(f) { data[f] = $('#' + f).val(); });
		if (data.PARTNER_SQ === '__new') data.PARTNER_SQ = ''; else data.PARTNER_NM = '';
		hrPost(BASE + 'saveData.do', data, function() { $('#formModal').modal('hide'); toast('저장했습니다'); load(); });
	}

	function deleteForm() { deleteTrade($('#TRADE_SQ').val(), $('#ITEM_NM').val()); }

	function deleteTrade(sq, name) {
		bootbox.confirm($('<div>').text('「' + name + '」 건을 삭제할까요? 되돌릴 수 없습니다.').html(), function(ok) {
			if (ok) hrPost(BASE + 'deleteData.do', { TRADE_SQ: sq }, function() { $('#formModal').modal('hide'); toast('삭제했습니다'); load(); });
		});
	}

	// ── 세금계산서 묶음: inv[거래처] = [[건, 건], [건]] ──
	function chunk(list, n) { var out = []; for (var i = 0; i < list.length; i += n) out.push(list.slice(i, i + n)); return out; }
	function perInv() { return Math.max(1, Math.min(99, parseInt($('#perInv').val(), 10) || 4)); }
	function byKey(k) {
		return function(a, b) {
			if (k === 'AMT') return Number(b.AMT) - Number(a.AMT);
			return String(a[k] || '').localeCompare(String(b[k] || ''), 'ko') || String(a.ITEM_NM).localeCompare(String(b.ITEM_NM), 'ko');
		};
	}

	// 저장된 묶음 그대로. 한 번도 묶지 않은 거래처는 품목순 N행씩 보여 주고(저장 전), 새로 생긴 건은 맨 끝 장으로
	function buildInv() {
		inv = {};
		var by = {};
		lines.forEach(function(l) { (by[pKey(l)] = by[pKey(l)] || []).push(l); });
		Object.keys(by).forEach(function(p) {
			var has = function(l) { return l.INV_NO !== null && l.INV_NO !== undefined; };
			var saved = by[p].filter(has).sort(function(a, b) { return a.INV_NO - b.INV_NO || a.SORT_NO - b.SORT_NO; });
			var fresh = by[p].filter(function(l) { return !has(l); }).sort(byKey('ITEM_NM')), list = [], last = null;
			saved.forEach(function(l) { if (l.INV_NO !== last) { list.push([]); last = l.INV_NO; } list[list.length - 1].push(l); });
			inv[p] = saved.length ? (fresh.length ? list.concat([fresh]) : list) : chunk(fresh, perInv());
		});
	}

	function savePartner(p, msg, then) {
		inv[p] = inv[p].filter(function(g) { return g.length; });
		var items = [];
		inv[p].forEach(function(g, i) { g.forEach(function(l, j) { items.push(l.KEY + ':' + (i + 1) + ':' + j); }); });
		drawInv();
		hrPost(BASE + 'layoutData.do', $.param({ YM: ymNow(), ITEM: items }, true), function() {
			inv[p].forEach(function(g, i) { g.forEach(function(l, j) { l.INV_NO = i + 1; l.SORT_NO = j; }); });
			if (msg) toast(msg);
			if (then) then(); else draw();
		}, load);
	}

	function regroup(p) {
		var locked = inv[p].filter(issued), free = [].concat.apply([], inv[p].filter(function(g) { return !issued(g); })), k = $('#sortKey').val();
		if (k) free.sort(byKey(k));
		inv[p] = locked.concat(chunk(free, perInv()));
		savePartner(p, perInv() + '행씩 다시 묶었습니다');
	}

	function locate(p, l) { for (var i = 0; i < inv[p].length; i++) { var j = inv[p][i].indexOf(l); if (j >= 0) return [i, j]; } return null; }

	// ▲▼: 장 안에서는 자리 바꾸기, 장의 끝에서는 이웃 장으로 넘어간다
	function moveBy(p, l, d) {
		var at = locate(p, l), g = inv[p][at[0]], j = at[1], n = inv[p][at[0] + d];
		if (j + d >= 0 && j + d < g.length) { g[j] = g[j + d]; g[j + d] = l; }
		else if (n && !issued(n)) { g.splice(j, 1); if (d < 0) n.push(l); else n.unshift(l); }
		else return;
		savePartner(p, '순서를 저장했습니다', function() { draw(); $('[data-key="' + l.KEY + '"] .' + (d < 0 ? 'up' : 'down')).focus(); });
	}

	// 끌어다 놓기: target 은 장(배열) 또는 null(새 장), tj 는 그 장 안에서 끼워 넣을 자리
	function dropTo(p, target, tj) {
		if (!drag || drag.p !== p || (target && issued(target))) return;
		var l = drag.l, at = locate(p, l), src = inv[p][at[0]];
		src.splice(at[1], 1);
		if (!target) inv[p].push([l]);
		else target.splice(src === target && at[1] < tj ? tj - 1 : tj, 0, l);
		drag = null;
		savePartner(p, '묶음을 저장했습니다');
	}

	function copyText(text, msg) {
		function fallback() { var $t = $('<textarea style="position:fixed;top:-1000px;">').val(text).appendTo('body'); $t[0].select(); document.execCommand('copy'); $t.remove(); toast(msg); }
		if (navigator.clipboard && window.isSecureContext) navigator.clipboard.writeText(text).then(function() { toast(msg); }, fallback);
		else fallback();
	}

	function setIssue(p, g, on) {
		var go = function() {
			hrPost(BASE + 'issueData.do', $.param({ YM: ymNow(), KEY: g.map(function(l) { return l.KEY; }), ON: on ? 'Y' : 'N' }, true), function() { toast(on ? '발급 완료로 표시했습니다' : '발급을 취소했습니다'); load(); });
		};
		// 묶음이 저장돼 있어야 발급 표시가 된다
		if (on && g.some(function(l) { return l.INV_NO === null || l.INV_NO === undefined; })) savePartner(p, null, go); else go();
	}

	// 지금 탭에 보이는 거래처(거래처 필터 적용), 화면과 같은 순서
	function invKeys() {
		var f = $('#fPartner').val();
		return Object.keys(inv).filter(function(p) { return !f || p === f; }).sort(function(a, b) { return pName(inv[a][0][0]).localeCompare(pName(inv[b][0][0]), 'ko'); });
	}

	// 보이는 계산서 전체를 한 번에 복사한다. 제목 → [거래처] → 장마다 '번호. 금액' 한 줄, 빈 줄, 품목·기간·공급가액(탭 구분)
	function copyAll() {
		var out = [dpYmLabel(ymNow()) + ' 세금계산서 발급 건'], n = 0;
		invKeys().forEach(function(p) {
			out.push('', '[' + pName(inv[p][0][0]) + ']');
			inv[p].forEach(function(g, i) {
				var s = sum(g);
				n++;
				out.push('', (i + 1) + '. 공급가액 ' + dpWon(s) + ' · 세액 ' + dpWon(vat(s)) + ' · 합계 ' + dpWon(s + vat(s)) + (issued(g) ? ' · 발급 완료 ' + g[0].ISSUE_DT : ''), '');
				g.forEach(function(l) { out.push(l.ITEM_NM + '\t' + period(l) + '\t' + l.AMT); });
			});
		});
		if (!n) { toast('복사할 계산서가 없습니다'); return; }
		copyText(out.join('\n'), '계산서 ' + n + '장을 복사했습니다');
	}

	function drawInv() {
		var $b = $('#invBody').empty(), keys = invKeys();
		if (!keys.length) $b.append('<p class="text-muted">이 달에 해당하는 건이 없습니다.</p>');
		keys.forEach(function(p) {
			var groups = inv[p], all = [].concat.apply([], groups), s = sum(all), done = groups.filter(issued).length;
			function hidden(g) { return invOff[issued(g) ? 'done' : 'todo']; }
			if (groups.every(hidden)) return;
			var unsaved = all.some(function(l) { return l.INV_NO === null || l.INV_NO === undefined; });
			var $p = $('<div class="tr-partner">').appendTo($b);
			$p.append($('<h5>').append($('<span>').text(pName(all[0])),
				$('<small>').text('계산서 ' + groups.length + '장 · ' + all.length + '행 · 공급가액 ' + dpWon(s) + ' · 발급 ' + done + '/' + groups.length + (unsaved ? ' · 자동 묶음(저장 전)' : '')),
				// 어느 거래처에서 눌러도 지금 보이는 계산서 전체를 복사한다
				$('<button type="button" class="btn btn-sm btn-primary ml-auto">전체 복사</button>').attr('aria-label', '보이는 계산서 전체 복사').click(copyAll),
				$('<button type="button" class="btn btn-sm btn-outline-secondary">다시 묶기</button>').attr('aria-label', pName(all[0]) + ' 다시 묶기').click(function() {
					bootbox.confirm('발급 전인 ' + pName(all[0]) + ' 건을 ' + ($('#sortKey').val() ? $('#sortKey option:selected').text() + '으로 정렬해 ' : '') + perInv() + '행씩 다시 묶을까요? 손으로 맞춘 묶음은 바뀝니다.', function(ok) { if (ok) regroup(p); });
				})));
			groups.forEach(function(g, i) { if (!hidden(g)) $p.append(invCard(p, g, i)); });
			var $new = $('<div class="tr-new">끌어온 행을 여기에 놓으면 새 계산서 한 장이 됩니다</div>').appendTo($p);
			$new.on('dragover', function(e) { if (drag && drag.p === p) { e.preventDefault(); $new.addClass('over'); } }).on('dragleave', function() { $new.removeClass('over'); })
				.on('drop', function(e) { e.preventDefault(); dropTo(p, null, 0); });
		});
	}

	function invCard(p, g, i) {
		var lock = issued(g), s = sum(g), prev = inv[p][i - 1];
		var $c = $('<div class="tr-inv">').toggleClass('issued', lock), $h = $('<div class="tr-inv-h">').appendTo($c);
		$h.append($('<b>').text('계산서 ' + (i + 1)), $('<span class="dp-mute">').text(g.length + '행'));
		if (lock) $h.append($('<span class="dp-pill ok">').text('발급 완료 ' + g[0].ISSUE_DT));
		$h.append($('<span class="sum">').append('공급가액 ', $('<b>').text(dpWon(s)), cp(s, '공급가액'), ' · 세액 ' + dpWon(vat(s)), cp(vat(s), '세액'), ' · 합계 ', $('<b>').text(dpWon(s + vat(s))), cp(s + vat(s), '합계금액')));
		if (!lock && prev && !issued(prev)) $h.append($('<button type="button" class="btn btn-sm btn-outline-secondary py-0">위와 합치기</button>').click(function() {
			inv[p][i - 1] = prev.concat(g);
			inv[p].splice(i, 1);
			savePartner(p, '두 장을 합쳤습니다');
		}));
		$h.append($('<button type="button" class="btn btn-sm btn-outline-secondary py-0">복사</button>').attr('aria-label', '계산서 ' + (i + 1) + ' 품목 복사').click(function() {
			copyText(g.map(function(l) { return l.ITEM_NM + '\t' + period(l) + '\t' + l.AMT; }).join('\n'), '품목·기간·공급가액을 복사했습니다');
		}));
		$h.append($('<button type="button" class="btn btn-sm py-0">').addClass(lock ? 'btn-outline-secondary' : 'btn-primary').text(lock ? '발급 취소' : '발급 완료').click(function() { setIssue(p, g, !lock); }));
		var $t = $('<tbody>');
		g.forEach(function(l, j) {
			var $r = $('<tr>').attr('data-key', l.KEY), $mv = $('<td class="tr-move">');
			if (!lock) {
				var $hdl = $('<button type="button" class="hdl" title="끌어서 옮기기" tabindex="-1" aria-hidden="true">&#8942;&#8942;</button>').on('mousedown touchstart', function() { $r.attr('draggable', 'true'); });
				$mv.append($hdl, $('<button type="button" class="up">&#9650;</button>').attr('aria-label', l.ITEM_NM + ' 위로').click(function() { moveBy(p, l, -1); }),
					$('<button type="button" class="down">&#9660;</button>').attr('aria-label', l.ITEM_NM + ' 아래로').click(function() { moveBy(p, l, 1); }));
				$r.on('dragstart', function(e) { drag = { p: p, l: l }; e.originalEvent.dataTransfer.setData('text/plain', l.KEY); $r.addClass('dragging'); })
					.on('dragend', function() { drag = null; $r.removeClass('dragging').removeAttr('draggable'); $('.tr-inv .over, .tr-new.over').removeClass('over'); })
					.on('dragover', function(e) { if (drag && drag.p === p) { e.preventDefault(); $('.tr-inv tr.over').removeClass('over'); $r.addClass('over'); } })
					.on('drop', function(e) { e.preventDefault(); e.stopPropagation(); dropTo(p, g, j); });
			}
			$r.append($mv, $('<td>').append(typePill(l)), $('<td class="item">').text(l.ITEM_NM).append(cp(l.ITEM_NM, '품목')), $('<td>').text(period(l)).append(period(l) ? cp(period(l), '기간') : ''),
				$('<td class="dp-num">').text(dpWon(l.AMT)).append(cp(l.AMT, '공급가액')),
				$('<td>').append(!lock && j > 0 ? $('<button type="button" class="tr-cut">나누기</button>').attr({ title: '이 행부터 새 계산서로', 'aria-label': l.ITEM_NM + ' 부터 새 계산서로 나누기' }).click(function() {
					inv[p].splice(i, 1, g.slice(0, j), g.slice(j));
					savePartner(p, '계산서를 나눴습니다');
				}) : ''));
			$t.append($r);
		});
		$c.append($('<table class="table table-sm">').append($t));
		// 장의 빈 곳에 놓으면 그 장 맨 끝으로
		if (!lock) $c.on('dragover', function(e) { if (drag && drag.p === p) { e.preventDefault(); } }).on('drop', function(e) { e.preventDefault(); dropTo(p, g, g.length); });
		return $c;
	}

	$('#pageTitle').text(INV_ONLY ? '세금계산서' : SALE ? '매출관리' : '매입관리');
	if (INV_ONLY) $('#btnAdd, #keyword').hide();
	$('#btnAddText').text(SALE ? '일반 건 등록' : '매입 건 등록');
	$('#btnExcel').toggle(SALE).click(function() { if (ymNow()) location.href = BASE + 'excel.do?YM=' + encodeURIComponent(ymNow()); });
	$('#PARTNER_SQ').on('change', function() { var typed = this.value === '__new'; $('#PARTNER_NM').toggle(typed).prop('required', typed); if (typed) $('#PARTNER_NM').focus(); });
	try { if (localStorage.getItem('tradePerInv')) $('#perInv').val(localStorage.getItem('tradePerInv')); } catch (e) {}
	$('#perInv').on('change', function() { try { localStorage.setItem('tradePerInv', perInv()); } catch (e) {} });
	// 계산서는 지난달 것을 끊으므로 지난달부터 연다
	$('#ym').val(moment().subtract(1, 'months').format('YYYY-MM')).on('change', function() { if (ymNow()) load(); });
	$('#fPartner').on('change', draw);
	$('#keyword').on('input', draw);
	load();
	</script>
</body>
</html>
