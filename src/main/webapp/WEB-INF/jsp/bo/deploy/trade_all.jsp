<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/deploy/deploy_common.jspf"%>
<%-- 매출·매입 현황: 투입(급여관리의 월 데이터) + 매출·매입 건(trade) 을 한 줄에. 투입·급여의 무거운 기능은 그 화면을 팝업(iframe)으로 띄워 쓴다 --%>
<style>
	.ta-views { display: inline-flex; flex-wrap: wrap; gap: 4px; }
	.ta-views button { border-radius: 999px; padding: 2px 12px; border: 1px solid #ced4da; background: #fff; font-size: 13px; }
	.ta-views button[aria-selected=true] { background: #111; color: #fff; border-color: #111; }
	.ta-views button b { margin-left: 5px; }
	.ta-scroll { max-height: 70vh; overflow: auto; }
	.ta th, .ta td { white-space: nowrap; }
	.ta thead th { position: sticky; top: 0; z-index: 3; }
	.ta .band { color: #fff; text-align: center; cursor: pointer; font-size: 11.5px; padding: 3px 6px; border-left: 2px solid #fff; }
	.ta .band:focus { outline: 2px solid #16d5ff; outline-offset: -2px; }
	.ta .b-dep { background: #4b5a67 !important; } .ta .b-sale { background: #0b6e8a !important; } .ta .b-buy { background: #a35a00 !important; } .ta .b-pay { background: #6a3fa0 !important; } .ta .b-pl { background: #17692f !important; }
	.ta td.c-sale { background: #f2fafc; } .ta td.c-buy { background: #fff9f0; } .ta td.c-pay { background: #f8f4fc; } .ta td.c-pl { background: #f1faf3; }
	.ta.hide-dep .x-dep, .ta.hide-sale .x-sale, .ta.hide-buy .x-buy, .ta.hide-pay .x-pay, .ta.hide-pl .x-pl { display: none; }
	.ta tr.ta-sub td { font-size: 12px; }
	.ta tr.ta-gen td:first-child { box-shadow: inset 4px 0 0 #a35a00; }
	.ta-amt { background: none; border: 0; padding: 0; color: inherit; border-bottom: 1px dotted #8a949c; font-variant-numeric: tabular-nums; }
	.ta td.hr-cell { text-decoration: underline dotted rgba(11,110,138,.6); text-underline-offset: 3px; cursor: text; }
	.ta-sort { background: none; border: 0; padding: 0 0 0 3px; color: #9aa4ac; font-size: 10px; }
	.ta-sort.on { color: #0b6e8a; }
	.ta-btn { border: 1px solid #b9dbe6; background: #f3fbfd; color: #0b6e8a; border-radius: 10px; padding: 0 7px; font-size: 11.5px; font-weight: 700; }
	.ta-btn.zero { opacity: .55; font-weight: 400; }
	.ta-minus { color: #a32020; }
	#frameModal .modal-dialog { max-width: 96vw; }
	#frameBox iframe { width: 100%; height: 80vh; border: 0; }
	#taToast { position: fixed; right: 18px; bottom: 18px; z-index: 2000; background: #222; color: #fff; font-size: 13px; padding: 8px 14px; border-radius: 6px; display: none; }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header d-flex flex-wrap align-items-center" style="gap:6px">
					<h3 class="card-title bTitle"><b>매출·매입 현황</b></h3>
					<div class="ml-auto d-flex align-items-center flex-wrap" style="gap:6px">
						<span class="dp-pill" id="stPay"></span><span class="dp-pill" id="stTrade"></span>
						<button type="button" class="btn btn-sm btn-outline-secondary" id="btnImport">공제 불러오기</button>
						<button type="button" class="btn btn-sm btn-outline-secondary" id="btnCsv"><i class="fas fa-file-excel"></i> 엑셀 다운로드</button>
						<button type="button" class="btn btn-sm btn-primary" id="btnDeploy"><i class="fas fa-plus"></i> 투입 추가</button>
						<button type="button" class="btn btn-sm btn-primary" id="btnSale"><i class="fas fa-plus"></i> 일반 매출</button>
						<button type="button" class="btn btn-sm btn-warning" id="btnBuy"><i class="fas fa-plus"></i> 일반 매입</button>
						<button type="button" class="btn btn-sm btn-dark" id="btnClosePay"></button>
						<button type="button" class="btn btn-sm btn-dark" id="btnCloseTrade"></button>
					</div>
				</div>
				<div class="card-body">
					<div class="dp-kpis" id="kpis"></div>
					<div class="cal-panel">
						<div class="dp-bar">
							<button type="button" class="btn btn-sm btn-outline-secondary" id="prevYm" aria-label="이전 달">◀</button>
							<label for="ym" class="sr-only">기준월</label><input type="month" id="ym" class="form-control form-control-sm" style="width:150px">
							<button type="button" class="btn btn-sm btn-outline-secondary" id="nextYm" aria-label="다음 달">▶</button>
							<div class="ta-views" id="views" role="tablist" aria-label="보기"></div>
							<div class="ml-auto"><button type="button" class="btn btn-sm btn-outline-secondary" id="btnTimeline">타임라인</button></div>
						</div>
						<div class="dp-bar pt-0" id="chks" role="group" aria-label="보기 구분"></div>
						<div class="dp-bar pt-0">
							<input type="search" id="keyword" class="form-control form-control-sm" style="width:210px" placeholder="성명·프로젝트·고객사·품목" aria-label="검색">
							<select class="form-control form-control-sm ta-filter" style="width:auto" data-f="client" aria-label="고객사"></select>
							<select class="form-control form-control-sm ta-filter" style="width:auto" data-f="partner" aria-label="거래처"></select>
							<select class="form-control form-control-sm ta-filter" style="width:auto" data-f="area" aria-label="근무지역"></select>
							<div class="ml-auto"><button type="button" class="btn btn-sm btn-outline-secondary" id="btnOpenAll">모두 펴기</button><button type="button" class="btn btn-sm btn-outline-secondary" id="btnFoldAll">모두 접기</button></div>
						</div>
						<div class="ta-scroll">
							<table class="table table-sm cal-table mb-0 ta" id="ta">
								<thead id="taHead"></thead>
								<tbody id="taBody"></tbody>
								<tfoot id="taFoot"></tfoot>
							</table>
						</div>
						<div class="small text-muted px-3 py-2">점선 밑줄 칸은 눌러서 고칩니다(실매출·매입액은 이 달 금액만, 기본급은 급여관리와 같은 값). 색 띠(투입·매출·매입·급여·손익)를 누르면 그 묶음을 접고 대표 칸 하나만 남깁니다. 성명을 누르면 투입·급여 상세가 팝업으로 열립니다. 투입현황·급여관리와 같은 데이터라 어느 쪽에서 고쳐도 서로 반영됩니다.</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="frameModal" tabindex="-1" role="dialog" aria-labelledby="frameTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header py-2">
					<h5 class="modal-title" id="frameTitle"></h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="cate-tabs" id="frameTabs" role="tablist" aria-label="상세 구분"></div>
				<div class="modal-body p-0" id="frameBox"></div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="formModal" tabindex="-1" role="dialog" aria-labelledby="formTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<form class="modal-content" onsubmit="saveForm(); return false;">
				<div class="modal-header">
					<h5 class="modal-title" id="formTitle"></h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<input type="hidden" id="TRADE_SQ">
					<div class="form-row">
						<div class="form-group col-7"><label for="PARTNER_SQ" id="partnerLabel">거래처</label><select id="PARTNER_SQ" class="form-control form-control-sm" required></select>
							<label for="PARTNER_NM" class="sr-only">거래처 이름 직접 입력</label><input id="PARTNER_NM" class="form-control form-control-sm mt-1" maxlength="200" placeholder="거래처 이름 직접 입력" style="display:none;"></div>
						<div class="form-group col-5"><label for="TYPE_NM">구분</label><input id="TYPE_NM" class="form-control form-control-sm" maxlength="50" list="typeList" required placeholder="임대료, 장비, 용역…"><datalist id="typeList"></datalist></div>
					</div>
					<div class="form-group"><label for="ITEM_NM">품목</label><input id="ITEM_NM" class="form-control form-control-sm" maxlength="300" required></div>
					<div class="form-row">
						<div class="form-group col-6"><label for="START_DT">시작일</label><input type="date" id="START_DT" class="form-control form-control-sm"></div>
						<div class="form-group col-6"><label for="END_DT">종료일</label><input type="date" id="END_DT" class="form-control form-control-sm"></div>
					</div>
					<div class="form-row">
						<div class="form-group col-4"><label for="AMT">공급가액</label><input id="AMT" class="form-control form-control-sm text-right" inputmode="numeric" required></div>
						<div class="form-group col-4"><label for="VAT">세액 (10% 자동)</label><input id="VAT" class="form-control form-control-sm text-right" readonly tabindex="-1"></div>
						<div class="form-group col-4"><label for="TOTAL">합계금액</label><input id="TOTAL" class="form-control form-control-sm text-right" readonly tabindex="-1"></div>
					</div>
					<div class="form-group"><label for="MEMO">메모</label><input id="MEMO" class="form-control form-control-sm" maxlength="500"></div>
					<div class="form-row align-items-center mb-0">
						<div class="col-auto"><label class="mb-0" for="REPEAT_ON"><input type="checkbox" id="REPEAT_ON" class="ta-chk"> 매달 반복</label></div>
						<div class="col-auto"><label for="REPEAT_UNTIL" class="mb-0">언제까지</label></div>
						<div class="col-auto"><input type="month" id="REPEAT_UNTIL" class="form-control form-control-sm" style="width:150px" disabled></div>
						<div class="col small text-muted">이 달까지 매달 같은 건을 만듭니다. 비우면 끌 때까지 계속.</div>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-sm btn-outline-danger mr-auto" id="btnDelete" onclick="deleteForm();">삭제</button>
					<button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">취소</button>
					<button type="submit" class="btn btn-sm btn-primary">저장</button>
				</div>
			</form>
		</div>
	</div>

	<div id="taToast" role="status" aria-live="polite"></div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>
	<script>
	var TYPE_NM = hrCodeMap('HR_EMP_TYPE'), FOREVER = '9999-12';
	var ym = moment().format('YYYY-MM'), pay = { rows: [], closed: false }, lines = { SALE: [], BUY: [] }, partners = [], types = { SALE: [], BUY: [] }, tradeClosed = false;
	var items = [], view = 'ALL', sortKey = 'NAME', sortDir = 1, formKind = 'SALE', today = moment().startOf('day');
	// 체크 칩: 고용형태(공통코드) + 일반 건 + 확인 필요
	var CHIPS = hrAllCodes('HR_EMP_TYPE').map(function(c) { return [c.CD, c.NM]; }).concat([['_NONE', '코드 없음'], ['_GEN', '일반 건'], ['_FLAG', '확인 필요']]), checked = {};
	CHIPS.forEach(function(c) { checked[c[0]] = true; });
	// 묶음: [키, 이름, 칸 수]. 접으면 대표 칸 하나만 남는다(투입 프로젝트 · 매출 실매출 · 매입 매입액 · 급여 실지급 · 손익 영업이익)
	var BANDS = [['dep', '투입', 5], ['sale', '매출', 4], ['buy', '매입', 2], ['pay', '급여', 4], ['pl', '손익', 3]], fold = {};
	try { fold = JSON.parse(localStorage.getItem('tradeAllFold') || '{}'); } catch (e) {}

	function toast(msg) { $('#taToast').text(msg).stop(true, true).fadeIn(100).delay(1500).fadeOut(300); }
	function num(v) { return Number(v || 0); }
	function vat(a) { return a < 0 ? -Math.floor(-a / 10) : Math.floor(a / 10); }
	function md(d) { return d ? Number(d.substring(5, 7)) + '/' + Number(d.substring(8, 10)) : ''; }
	function chipOf(t) { return TYPE_NM[t] ? t : '_NONE'; }
	function typeOf(r, d) { return (d && d.DEPLOY_TYPE) || r.EMP_TYPE_CD || ''; }
	function pName(l) { return l && l.PARTNER_NM || ''; }

	// ── 불러오기: 급여관리의 월 데이터 + 매출·매입 건 ──
	function load() {
		var left = 3;
		function done() { if (!--left) { build(); render(); } }
		hrPost('/admin/pay/monthData.do', { YM: ym }, function(res) { pay = res.result; done(); });
		['SALE', 'BUY'].forEach(function(k) {
			hrPost('/admin/trade/' + k.toLowerCase() + '/listData.do', { YM: ym }, function(res) {
				lines[k] = res.result.lines; types[k] = res.result.types; partners = res.result.partners; tradeClosed = res.result.closed;
				done();
			});
		});
	}

	// 사람 줄(급여 행 + 계약마다 매출·매입 건)과 그 밖의 건(일반 건, 급여 행에 없는 투입 건)으로 만든다
	function build() {
		var by = { SALE: {}, BUY: {} }, used = {};
		['SALE', 'BUY'].forEach(function(k) { lines[k].forEach(function(l) { by[k][l.KEY] = l; }); });
		items = pay.rows.map(function(r) {
			var cs = (r.DETAILS || []).filter(function(d) { return d.DEPLOY_SQ; }).map(function(d) {
				var key = 'D:' + d.DEPLOY_SQ;
				used[key] = true;
				return { d: d, sale: by.SALE[key], buy: by.BUY[key] };
			});
			var active = cs.some(function(c) { return num(c.d.WORK_DAYS) > 0; });
			return { staff: true, r: r, cs: cs.length ? cs : [{ d: null }], name: r.STAFF_NM, active: active, office: !!r.OFFICE,
				sale: cs.reduce(function(s, c) { return s + (c.sale ? num(c.sale.AMT) : 0); }, 0), buy: cs.reduce(function(s, c) { return s + (c.buy ? num(c.buy.AMT) : 0); }, 0),
				profit: r.OFFICE ? 0 : num(r.PROFIT), flags: (r.FLAGS || []).length,
				ending: cs.some(function(c) { var e = c.d.END_DT && moment(c.d.END_DT); return e && !e.isBefore(today) && !e.isAfter(moment().add(1, 'month').endOf('month')); }) };
		});
		var rest = {};
		['SALE', 'BUY'].forEach(function(k) {
			lines[k].forEach(function(l) {
				if (used[l.KEY]) return;
				var id = l.SRC_CD === 'M' ? k + l.KEY : l.KEY, it = rest[id] = rest[id] || { staff: false, gen: l.SRC_CD === 'M', name: l.SRC_CD === 'M' ? l.ITEM_NM : (l.STAFF_NM || l.ITEM_NM), cs: [{ d: null }], sale: 0, buy: 0 };
				it.cs[0][k === 'SALE' ? 'sale' : 'buy'] = l;
				it[k === 'SALE' ? 'sale' : 'buy'] = num(l.AMT);
				it.profit = it.sale - it.buy;
			});
		});
		Object.keys(rest).forEach(function(k) { items.push(rest[k]); });
		fillFilters();
	}

	function fieldsOf(it, f) {
		return it.cs.map(function(c) {
			if (f === 'client') return c.d && c.d.CLIENT_NM;
			if (f === 'area') return c.d && c.d.WORK_AREA;
			return [pName(c.sale) || (c.d && c.d.SALE_PARTNER_NM), pName(c.buy)];
		}).reduce(function(a, v) { return a.concat(v); }, []).filter(Boolean);
	}

	function fillFilters() {
		var labels = { client: '고객사', partner: '거래처', area: '근무지역' };
		$('.ta-filter').each(function() {
			var $s = $(this), f = $s.data('f'), keep = $s.val(), vals = {};
			items.forEach(function(it) { fieldsOf(it, f).forEach(function(v) { vals[v] = 1; }); });
			$s.empty().append($('<option value="">').text(labels[f] + ' 전체'));
			Object.keys(vals).sort(function(a, b) { return a.localeCompare(b, 'ko'); }).forEach(function(v) { $s.append($('<option>').val(v).text(v)); });
			$s.val(vals[keep] ? keep : '');
		});
	}

	var VIEWS = [['ALL', '전체', function() { return true; }], ['ACTIVE', '투입 중', function(it) { return it.staff && it.active && !it.office; }], ['ENDING', '철수 예정', function(it) { return it.staff && it.ending && !it.office; }],
		['IDLE', '대기', function(it) { return it.staff && !it.active && !it.office; }], ['OFFICE', '내근직', function(it) { return it.staff && it.office; }], ['GEN', '일반 건', function(it) { return !it.staff; }], ['PARTNER', '거래처별', null]];

	function chipShown(it) {
		if (!it.staff) return !!checked._GEN;
		if (checked._FLAG && it.flags) return true;
		return [it.r.EMP_TYPE_CD].concat(it.cs.map(function(c) { return c.d && c.d.DEPLOY_TYPE; })).filter(Boolean).some(function(t) { return checked[chipOf(t)]; });
	}

	function filtered() {
		var kw = $.trim($('#keyword').val()).toLowerCase(), fn = VIEWS.filter(function(v) { return v[0] === view; })[0][2] || function() { return true; };
		return items.filter(function(it) {
			if (!fn(it) || !chipShown(it)) return false;
			var ok = true;
			$('.ta-filter').each(function() { var v = $(this).val(); if (v && fieldsOf(it, $(this).data('f')).indexOf(v) < 0) ok = false; });
			if (!ok) return false;
			if (!kw) return true;
			return [it.name].concat(it.cs.map(function(c) { return [c.d && c.d.PRJ_NM, c.d && c.d.CLIENT_NM, pName(c.sale), pName(c.buy), c.sale && c.sale.ITEM_NM, c.buy && c.buy.ITEM_NM].join(' '); })).join(' ').toLowerCase().indexOf(kw) >= 0;
		});
	}

	var SORT = { NAME: function(it) { return it.name || ''; }, PRJ: function(it) { return (it.cs[0].d || {}).PRJ_NM || ''; }, SALE: function(it) { return it.sale; }, BUY: function(it) { return it.buy; },
		NET: function(it) { return it.staff ? num(it.r.NET) : 0; }, PROFIT: function(it) { return it.profit; } };

	// 세금계산서 장 수: 거래처 + 계산서 번호
	function invoices(list) {
		var all = {}, done = {};
		list.forEach(function(l) { if (l.INV_NO === null || l.INV_NO === undefined) return; var k = (l.PARTNER_SQ || l.PARTNER_NM) + '#' + l.INV_NO; all[k] = 1; if (l.ISSUE_DT) done[k] = 1; });
		return [Object.keys(all).length, Object.keys(done).length];
	}

	function render() {
		$('#stPay').text(pay.closed ? '급여 마감' : '급여 미마감').attr('class', 'dp-pill ' + (pay.closed ? 'ok' : 'warn'));
		$('#stTrade').text(tradeClosed ? '매출·매입 마감' : '매출·매입 미마감').attr('class', 'dp-pill ' + (tradeClosed ? 'ok' : 'warn'));
		$('#btnClosePay').text(pay.closed ? '급여 마감 해제' : '급여 마감');
		$('#btnCloseTrade').text(tradeClosed ? '매출·매입 마감 해제' : '매출·매입 마감');
		$('#btnImport').prop('disabled', !!pay.closed);
		$('#btnSale, #btnBuy').prop('disabled', tradeClosed);
		$('#views').empty().append(VIEWS.map(function(v) {
			var n = v[2] ? items.filter(v[2]).length : partnerRows().length;
			return $('<button type="button" role="tab">').attr({ 'data-v': v[0], 'aria-selected': view === v[0] }).text(v[1]).append($('<b>').text(n));
		}));
		var all = CHIPS.every(function(c) { return checked[c[0]]; });
		var $c = $('#chks').empty().append($('<button type="button" class="btn btn-sm btn-outline-secondary" id="chkAll">').text(all ? '☑ 전체 해제' : '☐ 전체 선택'));
		CHIPS.forEach(function(c) {
			var n = c[0] === '_GEN' ? items.filter(function(it) { return !it.staff; }).length : c[0] === '_FLAG' ? items.filter(function(it) { return it.flags; }).length
				: items.filter(function(it) { return it.staff && [it.r.EMP_TYPE_CD].concat(it.cs.map(function(x) { return x.d && x.d.DEPLOY_TYPE; })).filter(Boolean).some(function(t) { return chipOf(t) === c[0]; }); }).length;
			if (!n && c[0] !== '_GEN' && c[0] !== '_FLAG') return; // 이 달에 없는 고용형태 칩은 숨긴다
			$c.append($('<label class="ta-chip">').toggleClass('on', !!checked[c[0]]).toggleClass('alert', c[0] === '_FLAG')
				.append($('<input type="checkbox" class="ta-chk">').val(c[0]).prop('checked', !!checked[c[0]])).append(document.createTextNode(c[1] + ' ' + n)));
		});
		var list = filtered();
		renderKpis(list);
		if (view === 'PARTNER') renderPartners(); else renderTable(list);
	}

	function renderKpis(list) {
		var t = { sale: 0, buy: 0, pay: 0, net: 0, profit: 0, saleN: 0, buyN: 0, staff: 0, act: 0, idle: 0, office: 0, ending: 0 }, sl = [];
		list.forEach(function(it) {
			t.sale += it.sale; t.buy += it.buy; t.profit += it.profit;
			it.cs.forEach(function(c) { if (c.sale) { t.saleN++; sl.push(c.sale); } if (c.buy) t.buyN++; });
			if (!it.staff) return;
			t.staff++; t.pay += num(it.r.PAY_TOTAL); t.net += num(it.r.NET);
			if (it.office) t.office++; else if (it.active) t.act++; else t.idle++;
			if (it.ending && !it.office) t.ending++;
		});
		var inv = invoices(sl);
		function k(label, val, sub, cls) { return $('<div class="dp-kpi">').addClass(cls || '').append($('<span>').text(label), $('<b>').text(val), $('<span>').text(sub || '')); }
		$('#kpis').empty().append(k('매출 (공급가액)', dpWon(t.sale), t.saleN + '건 · 세액 ' + dpWon(vat(t.sale))), k('매입 (공급가액)', dpWon(t.buy), t.buyN + '건 · 세액 ' + dpWon(vat(t.buy))),
			k('급여 (지급계)', dpWon(t.pay), t.staff + '명 · 실지급 ' + dpWon(t.net)), k('영업이익', dpWon(t.profit), t.sale ? '이익률 ' + (t.profit * 100 / t.sale).toFixed(1) + '%' : '', t.profit < 0 ? 'bad' : ''),
			k('투입', t.act + '명', '대기 ' + t.idle + ' · 내근 ' + t.office), k('철수 예정', t.ending + '명', '이번 달·다음 달', t.ending ? 'bad' : ''), k('세금계산서', inv[0] + '장', '발급 ' + inv[1] + ' · 미발급 ' + (inv[0] - inv[1]), inv[0] > inv[1] ? 'warn' : ''));
	}

	// ── 표 ──
	function sortBtn(key) {
		var on = sortKey === key;
		return $('<button type="button" class="ta-sort">').toggleClass('on', on).attr('aria-label', '정렬').text(on ? (sortDir > 0 ? '▲' : '▼') : '↕').on('click', function(e) {
			e.stopPropagation(); if (sortKey === key) sortDir = -sortDir; else { sortKey = key; sortDir = key === 'NAME' || key === 'PRJ' ? 1 : -1; } render();
		});
	}
	function th(text, cls, key, title) { var $t = $('<th>').addClass(cls || '').text(text); if (title) $t.attr('title', title); return key ? $t.append(sortBtn(key)) : $t; }

	function renderTable(list) {
		var $bands = $('<tr>').append('<th></th>');
		BANDS.forEach(function(b) {
			$bands.append($('<th class="band" tabindex="0" role="button">').addClass('b-' + b[0]).attr({ 'data-b': b[0], colspan: fold[b[0]] ? 1 : b[2], 'aria-expanded': !fold[b[0]] }).text((fold[b[0]] ? '▸ ' : '▾ ') + b[1]));
			$('#ta').toggleClass('hide-' + b[0], !!fold[b[0]]);
		});
		$bands.append('<th colspan="3"></th>');
		var $h = $('<tr>').append(th('성명 · 품목', '', 'NAME'),
			th('형태', 'x-dep'), th('고객사', 'x-dep'), th('프로젝트', '', 'PRJ'), th('기간', 'x-dep'), th('남은 기간', 'x-dep'),
			th('매출처', 'x-sale'), th('매출단가', 'x-sale dp-num'), th('실매출', 'dp-num', 'SALE', '투입 건: 매출단가 ÷ 월 일수 × 근무일수(마감한 달은 급여관리 금액). 눌러서 이 달 금액만 고칩니다'), th('세금계산서', 'x-sale'),
			th('매입처', 'x-buy'), th('매입액', 'dp-num', 'BUY', '사업자·외부·기타 계약의 계약단가 일할, 또는 직접 넣은 매입 건'),
			th('기본', 'x-pay dp-num'), th('지급계', 'x-pay dp-num'), th('공제계', 'x-pay dp-num'), th('실지급', 'dp-num', 'NET', '지급계 − 공제계'),
			th('회사부담', 'x-pl dp-num'), th('전월대비', 'x-pl dp-num'), th('영업이익', 'dp-num', 'PROFIT', '실매출 − 지급계 − 회사부담 − 기타 − 수수료 (내근직 제외). 일반 건은 매출 − 매입'),
			th('확인 사항'), th('메모'), th('이력'));
		$('#taHead').empty().append($bands, $h);
		$h.children().css('top', $bands.outerHeight()); // 둘째 머리글 줄은 색 띠 아래에 붙는다
		list.sort(function(a, b) {
			var x = SORT[sortKey](a), y = SORT[sortKey](b);
			return (a.staff ? 0 : 1) - (b.staff ? 0 : 1) || sortDir * (typeof x === 'number' ? x - y : String(x).localeCompare(String(y), 'ko', { numeric: true }));
		});
		var $b = $('#taBody').empty(), f = { sale: 0, buy: 0, pay: 0, ded: 0, net: 0, profit: 0 };
		if (!list.length) $b.append('<tr><td colspan="22" class="text-center text-muted py-4">해당하는 건이 없습니다. 체크나 기준월을 바꿔 보세요.</td></tr>');
		list.forEach(function(it) {
			f.sale += it.sale; f.buy += it.buy; f.profit += it.profit;
			if (it.staff) { f.pay += num(it.r.PAY_TOTAL); f.ded += num(it.r.DED_TOTAL); f.net += num(it.r.NET); }
			it.cs.forEach(function(c, i) {
				var $tr = $('<tr>').toggleClass('ta-sub', i > 0).toggleClass('ta-gen', !it.staff).toggleClass('dp-secret', !!(it.r && it.r.SECRET));
				if (!i) $tr.append(nameCell(it).attr('rowspan', it.cs.length));
				contractCells(it, c).forEach(function($td) { $tr.append($td); });
				if (!i) staffCells(it).forEach(function($td) { $tr.append($td.attr('rowspan', it.cs.length)); });
				$b.append($tr);
			});
		});
		function ft(v, cls) { return $('<td class="dp-num">').addClass(cls || '').text(dpWon(v)); }
		$('#taFoot').empty().append(list.length ? $('<tr class="font-weight-bold">').append($('<td>').text('합계 (' + list.length + '건)'), '<td class="x-dep" colspan="2"></td><td></td><td class="x-dep" colspan="2"></td><td class="x-sale" colspan="2"></td>', ft(f.sale), '<td class="x-sale"></td><td class="x-buy"></td>', ft(f.buy),
			'<td class="x-pay"></td>', ft(f.pay, 'x-pay'), ft(f.ded, 'x-pay'), ft(f.net), '<td class="x-pl" colspan="2"></td>', ft(f.profit).toggleClass('ta-minus', f.profit < 0), '<td colspan="3"></td>') : '');
	}

	function nameCell(it) {
		var $td = $('<td>');
		if (it.staff) return $td.append(it.r.SECRET ? $('<span title="시크릿">').text('🔒 ') : '', $('<button type="button" class="dp-name">').text(it.name).on('click', function() { openDetail(it, 0); }));
		var c = it.cs[0], l = c.sale || c.buy;
		if (it.gen) $td.append($('<button type="button" class="dp-name">').text(it.name).on('click', function() { openForm(c.sale ? 'SALE' : 'BUY', l); }));
		else $td.text(it.name);
		return $td.append(' ', $('<span class="dp-pill">').text(it.gen ? (c.sale ? '일반 매출' : '일반 매입') : '투입'), l.REPEAT_UNTIL ? $('<span class="dp-pill rent">').text('반복' + (l.REPEAT_UNTIL === FOREVER ? '' : ' ~' + l.REPEAT_UNTIL.substring(2).replace('-', '.'))) : '');
	}

	function remain(d) {
		if (!d || !d.END_DT) return d ? { text: '미정', tone: '' } : null;
		var n = moment(d.END_DT).diff(today, 'days');
		return n < 0 ? { text: md(d.END_DT) + ' 철수', tone: '' } : { text: 'D-' + n, tone: n <= 14 ? 'bad' : n <= 30 ? 'warn' : 'ok' };
	}

	function amtCell(kind, l, cls) {
		var $td = $('<td class="dp-num">').addClass(cls);
		if (!l) return $td;
		if (l.SRC_CD !== 'D' || tradeClosed || l.ISSUE_DT) return $td.text(dpWon(l.AMT));
		if (l.AMT_FIXED !== null && l.AMT_FIXED !== undefined) $td.append($('<span class="dp-was">').text(dpWon(l.CALC_AMT)));
		return $td.append($('<button type="button" class="ta-amt">').text(dpWon(l.AMT)).attr({ title: l.HOW, 'aria-label': l.ITEM_NM + ' 금액 ' + dpWon(l.AMT) + ' 고치기' }).on('click', function() {
			bootbox.prompt({ title: l.ITEM_NM + ' · 이 달 공급가액 (비우면 계산 금액 ' + dpWon(l.CALC_AMT) + ' 으로 돌아갑니다)', value: String(l.AMT), callback: function(v) {
				if (v !== null) hrPost('/admin/trade/' + kind.toLowerCase() + '/amountData.do', { YM: ym, KEY: l.KEY, AMT: v }, function() { toast('금액을 저장했습니다'); load(); });
			} });
		}));
	}

	function invPill(l) {
		if (!l) return '';
		if (l.INV_NO === null || l.INV_NO === undefined) return $('<span class="dp-mute">').text('묶기 전');
		return $('<span class="dp-pill">').addClass(l.ISSUE_DT ? 'ok' : 'warn').text('#' + l.INV_NO + (l.ISSUE_DT ? ' 발급 ' + md(l.ISSUE_DT) : ' 미발급'));
	}

	// 계약 단위 칸: 투입 5 · 매출 4 · 매입 2
	function contractCells(it, c) {
		var d = c.d, l = c.sale || c.buy || {}, rm = remain(d), gen = !it.staff;
		var period = d ? (d.START_DT ? d.START_DT.substring(2).replace(/-/g, '.') : '') + '~' + (d.END_DT ? d.END_DT.substring(2).replace(/-/g, '.') : '') : (l.START_DT || l.END_DT ? md(l.START_DT) + '~' + md(l.END_DT) : '');
		return [
			$('<td class="x-dep">').append(d || gen ? $('<span class="dp-pill">').text(d ? (TYPE_NM[typeOf(it.r, d)] || typeOf(it.r, d)) : l.TYPE_NM) : $('<span class="dp-pill warn">').text('대기')),
			$('<td class="x-dep">').text(d ? d.CLIENT_NM || '' : ''),
			$('<td>').text(d ? d.PRJ_NM || '' : gen && !it.gen ? l.PRJ_NM || '' : '').toggleClass('dp-mute', !d),
			$('<td class="x-dep">').text(period),
			$('<td class="x-dep">').append(rm ? $('<span class="dp-pill">').addClass(rm.tone).text(rm.text) : ''),
			$('<td class="x-sale c-sale">').text(pName(c.sale) || (d && d.SALE_PARTNER_NM) || ''),
			$('<td class="x-sale c-sale dp-num">').text(d && num(d.SALE_PRICE) ? dpWon(d.SALE_PRICE) : ''),
			amtCell('SALE', c.sale, 'c-sale'),
			$('<td class="x-sale c-sale">').append(invPill(c.sale)),
			$('<td class="x-buy c-buy">').text(pName(c.buy)),
			amtCell('BUY', c.buy, 'c-buy')
		];
	}

	// 사람 단위 칸: 급여 4 · 손익 3 · 확인 사항 · 메모 · 이력
	function staffCells(it) {
		var r = it.r, out = [];
		function td(v, cls) { return $('<td class="dp-num">').addClass(cls).text(v === '' ? '' : dpWon(v)); }
		if (!it.staff) {
			out = [td('', 'x-pay c-pay'), td('', 'x-pay c-pay'), td('', 'x-pay c-pay'), td('', 'c-pay'), td('', 'x-pl c-pl'), td('', 'x-pl c-pl'), td(it.profit, 'c-pl font-weight-bold').toggleClass('ta-minus', it.profit < 0)];
			return out.concat([$('<td>'), $('<td>').text((it.cs[0].sale || it.cs[0].buy).MEMO || ''), $('<td>')]);
		}
		var $base = $('<td class="dp-num x-pay c-pay">');
		if (pay.closed) $base.text(dpWon(r.BASE_AMT));
		else hrEditable($base, { url: '/admin/pay/saveFieldData.do', key: { YM: ym, STAFF_SQ: r.STAFF_SQ }, field: 'BASE_AMT', label: r.STAFF_NM + ' 기본', show: function() { return dpWon(r.BASE_AMT); }, value: function() { return r.BASE_AMT; }, saved: function() { load(); } });
		out = [$base, td(r.PAY_TOTAL, 'x-pay c-pay'), td(r.DED_TOTAL, 'x-pay c-pay'), td(r.NET, 'c-pay font-weight-bold'), td(r.COMPANY, 'x-pl c-pl'),
			$('<td class="dp-num x-pl c-pl">').text(r.DELTA_PCT === undefined ? '' : (r.DELTA_PCT > 0 ? '+' : '') + r.DELTA_PCT + '%').toggleClass('ta-minus', Math.abs(r.DELTA_PCT || 0) >= 10),
			r.OFFICE ? $('<td class="dp-num c-pl text-muted" title="내근직은 영업이익에서 뺍니다">').text('내근 제외') : td(r.PROFIT, 'c-pl font-weight-bold').toggleClass('ta-minus', num(r.PROFIT) < 0)];
		function cnt(icon, n, label, tab) { n = num(n); return $('<button type="button" class="ta-btn">').toggleClass('zero', !n).attr('aria-label', r.STAFF_NM + ' ' + label + ' ' + n + '건').text(icon + (n ? ' ' + n : '')).on('click', function() { openDetail(it, tab); }); }
		return out.concat([$('<td>').append((r.FLAGS || []).map(dpFlag)), $('<td>').append(cnt('💬', r.MEMO_CNT, '메모', 3)), $('<td>').append(cnt('✎', r.CHG_CNT, '수정이력', 4))]);
	}

	// ── 거래처별 보기 ──
	function partnerRows() {
		var by = {};
		['SALE', 'BUY'].forEach(function(k) {
			lines[k].forEach(function(l) {
				var nm = pName(l) || '(거래처 미지정)', p = by[nm] = by[nm] || { name: nm, sale: 0, saleN: 0, buy: 0, buyN: 0, lines: [] };
				if (k === 'SALE') { p.sale += num(l.AMT); p.saleN++; p.lines.push(l); } else { p.buy += num(l.AMT); p.buyN++; }
			});
		});
		return Object.keys(by).map(function(k) { return by[k]; }).sort(function(a, b) { return (b.sale + b.buy) - (a.sale + a.buy); });
	}

	function renderPartners() {
		$('#ta').removeClass(BANDS.map(function(b) { return 'hide-' + b[0]; }).join(' '));
		$('#taHead').empty().append('<tr><th>거래처</th><th class="dp-num">매출 건수</th><th class="dp-num">매출 공급가액</th><th class="dp-num">매입 건수</th><th class="dp-num">매입 공급가액</th><th class="dp-num">차액</th><th>세금계산서</th></tr>');
		var rows = partnerRows(), $b = $('#taBody').empty(), t = { sale: 0, saleN: 0, buy: 0, buyN: 0 };
		if (!rows.length) $b.append('<tr><td colspan="7" class="text-center text-muted py-4">이 달에 매출·매입 건이 없습니다.</td></tr>');
		rows.forEach(function(p) {
			var inv = invoices(p.lines);
			t.sale += p.sale; t.saleN += p.saleN; t.buy += p.buy; t.buyN += p.buyN;
			$b.append($('<tr>').append($('<td>').append($('<button type="button" class="dp-name">').text(p.name).on('click', function() { view = 'ALL'; $('.ta-filter[data-f=partner]').val(p.name); render(); })),
				$('<td class="dp-num">').text(p.saleN || ''), $('<td class="dp-num c-sale">').text(p.saleN ? dpWon(p.sale) : ''), $('<td class="dp-num">').text(p.buyN || ''), $('<td class="dp-num c-buy">').text(p.buyN ? dpWon(p.buy) : ''),
				$('<td class="dp-num font-weight-bold">').text(dpWon(p.sale - p.buy)).toggleClass('ta-minus', p.sale < p.buy), $('<td>').append(inv[0] ? $('<span class="dp-pill">').addClass(inv[0] > inv[1] ? 'warn' : 'ok').text(inv[0] + '장 · 발급 ' + inv[1]) : '')));
		});
		$('#taFoot').empty().append(rows.length ? $('<tr class="font-weight-bold">').append('<td>합계</td>', $('<td class="dp-num">').text(t.saleN), $('<td class="dp-num">').text(dpWon(t.sale)), $('<td class="dp-num">').text(t.buyN), $('<td class="dp-num">').text(dpWon(t.buy)), $('<td class="dp-num">').text(dpWon(t.sale - t.buy)), '<td></td>') : '');
	}

	// ── 투입현황·급여관리 화면을 팝업으로 ──
	function openFrame(title, tabs, at) {
		$('#frameTitle').text(title);
		var $t = $('#frameTabs').empty().toggle(tabs.length > 1);
		function show(i) {
			$t.children().removeClass('active').attr('aria-selected', 'false').eq(i).addClass('active').attr('aria-selected', 'true');
			$('#frameBox').empty().append($('<iframe>').attr({ src: tabs[i][1], title: tabs[i][0] }));
		}
		tabs.forEach(function(x, i) { $('<button type="button" class="cate-tab" role="tab">').text(x[0]).on('click', function() { show(i); }).appendTo($t); });
		show(at || 0);
		$('#frameModal').modal('show');
	}
	// 팝업에서 고친 것이 바로 보이게 닫을 때 다시 불러온다
	$(document).on('hidden.bs.modal', '#frameModal', function() { $('#frameBox').empty(); load(); });

	// tab: 0 투입 상세 · 1 급여 명세 · 3 메모 · 4 수정이력(급여관리 상세의 탭 번호)
	function openDetail(it, tab) {
		var r = it.r, d = (it.cs.filter(function(c) { return c.d; })[0] || {}).d, payUrl = '/admin/pay/openPayList.do?embed=1&ym=' + ym + '&open=' + r.STAFF_SQ, tabs = [];
		if (d) tabs.push(['투입 상세', '/admin/deploy/openDeployList.do?embed=1&open=' + d.DEPLOY_SQ]);
		tabs.push(['급여 명세', payUrl], ['메모', payUrl + '&tab=3'], ['수정이력', payUrl + '&tab=4']);
		var want = tab === 3 ? '메모' : tab === 4 ? '수정이력' : null;
		openFrame(r.STAFF_NM + ' · ' + dpYmLabel(ym), tabs, want ? tabs.map(function(x) { return x[0]; }).indexOf(want) : 0);
	}

	// ── 일반 매출·매입 등록 팝업 ──
	function openForm(kind, l) {
		formKind = kind;
		var sale = kind === 'SALE';
		$('#formTitle').text((sale ? '일반 매출 ' : '일반 매입 ') + (l ? '수정' : '등록') + ' · ' + dpYmLabel(ym));
		$('#partnerLabel').text(sale ? '매출처' : '매입처');
		$('#typeList').empty().append(types[kind].map(function(t) { return $('<option>').val(t); }));
		var $p = $('#PARTNER_SQ').empty().append('<option value=""></option>');
		partners.filter(function(p) { return (l && p.PARTNER_SQ === l.PARTNER_SQ) || (p.USE_YN === 'Y' && (sale ? p.SALE_YN : p.BUY_YN) === 'Y'); }).forEach(function(p) { $p.append($('<option>').val(p.PARTNER_SQ).text(p.PARTNER_NM)); });
		$p.append('<option value="__new">직접 입력… (거래처로 등록하지 않은 곳)</option>');
		var typed = l && !l.PARTNER_SQ;
		$('#TRADE_SQ').val(l ? l.SRC_SQ : '');
		$p.val(typed ? '__new' : l ? String(l.PARTNER_SQ) : '');
		$('#PARTNER_NM').val(typed ? l.PARTNER_NM : '');
		$p.trigger('change');
		['TYPE_NM', 'ITEM_NM', 'START_DT', 'END_DT', 'AMT', 'MEMO'].forEach(function(f) { $('#' + f).val(l && l[f] !== null && l[f] !== undefined ? l[f] : ''); });
		var until = l && l.REPEAT_UNTIL || '';
		$('#REPEAT_ON').prop('checked', !!until);
		$('#REPEAT_UNTIL').val(until && until !== FOREVER ? until : '').prop('disabled', !until).attr('min', ym);
		$('#AMT').trigger('input');
		$('#btnDelete').toggle(!!l);
		$('#formModal').modal('show');
	}

	function saveForm() {
		var data = { YM: ym };
		['TRADE_SQ', 'PARTNER_SQ', 'PARTNER_NM', 'TYPE_NM', 'ITEM_NM', 'START_DT', 'END_DT', 'AMT', 'MEMO'].forEach(function(f) { data[f] = $('#' + f).val(); });
		if (data.PARTNER_SQ === '__new') data.PARTNER_SQ = ''; else data.PARTNER_NM = '';
		data.REPEAT_UNTIL = $('#REPEAT_ON').prop('checked') ? ($('#REPEAT_UNTIL').val() || FOREVER) : '';
		hrPost('/admin/trade/' + formKind.toLowerCase() + '/saveData.do', data, function() { $('#formModal').modal('hide'); toast('저장했습니다'); load(); });
	}

	function deleteForm() {
		var repeat = $('#REPEAT_ON').prop('checked') ? ' 매달 반복도 이 달부터 멈춥니다.' : '';
		bootbox.confirm($('<div>').text('「' + $('#ITEM_NM').val() + '」 건을 삭제할까요? 되돌릴 수 없습니다.' + repeat).html(), function(ok) {
			if (ok) hrPost('/admin/trade/' + formKind.toLowerCase() + '/deleteData.do', { TRADE_SQ: $('#TRADE_SQ').val() }, function() { $('#formModal').modal('hide'); toast('삭제했습니다'); load(); });
		});
	}

	// 보이는 표를 그대로 CSV 로(엑셀에서 열린다). 접은 칸은 빠진다
	function downloadCsv() {
		var out = [];
		$('#ta tr').each(function() {
			if ($(this).find('.band').length) return;
			var row = [];
			$(this).children(':visible').each(function() { row.push('"' + $.trim($(this).text()).replace(/[↕▲▼]/g, '').replace(/"/g, '""') + '"'); });
			out.push(row.join(','));
		});
		var a = document.createElement('a');
		a.href = URL.createObjectURL(new Blob(['﻿' + out.join('\r\n')], { type: 'text/csv;charset=utf-8' }));
		a.download = '이에스티_' + ym + '_매출매입현황.csv';
		document.body.appendChild(a); a.click(); a.remove();
	}

	$(function() {
		$('#ym').val(ym).on('change', function() { if (this.value) { ym = this.value; load(); } });
		$('#prevYm, #nextYm').on('click', function() { ym = moment(ym + '-01').add(this.id === 'prevYm' ? -1 : 1, 'months').format('YYYY-MM'); $('#ym').val(ym); load(); });
		$('#views').on('click', 'button', function() { view = $(this).attr('data-v'); render(); });
		$('#chks').on('change', 'input.ta-chk', function() { checked[this.value] = this.checked; render(); })
			.on('click', '#chkAll', function() { var all = CHIPS.every(function(c) { return checked[c[0]]; }); CHIPS.forEach(function(c) { checked[c[0]] = !all; }); render(); });
		$('#keyword').on('input', render);
		$(document).on('change', '.ta-filter', render);
		function setFold(key, on) { fold[key] = on; try { localStorage.setItem('tradeAllFold', JSON.stringify(fold)); } catch (e) {} }
		$('#taHead').on('click keydown', '.band', function(e) {
			if (e.type === 'keydown' && e.key !== 'Enter' && e.key !== ' ') return;
			e.preventDefault();
			var b = $(this).attr('data-b');
			setFold(b, !fold[b]);
			render();
			$('#taHead .band[data-b=' + b + ']').focus();
		});
		$('#btnOpenAll, #btnFoldAll').on('click', function() { var on = this.id === 'btnFoldAll'; BANDS.forEach(function(b) { setFold(b[0], on); }); render(); });
		$('#btnSale').on('click', function() { openForm('SALE', null); });
		$('#btnBuy').on('click', function() { openForm('BUY', null); });
		$('#btnCsv').on('click', downloadCsv);
		$('#btnDeploy').on('click', function() { openFrame('투입 추가 (투입현황)', [['투입현황', '/admin/deploy/openDeployList.do?embed=1&add=1']]); });
		$('#btnTimeline').on('click', function() { openFrame('타임라인 (투입현황)', [['투입현황', '/admin/deploy/openDeployList.do?embed=1&view=timeline']]); });
		$('#btnImport').on('click', function() { openFrame('공제 불러오기 (급여관리)', [['급여관리', '/admin/pay/openPayList.do?embed=1&ym=' + ym + '&import=1']]); });
		$('#btnClosePay').on('click', function() {
			if (!pay.closed) return bootbox.confirm(dpYmLabel(ym) + ' 급여를 마감할까요? 마감하면 급여 금액을 고칠 수 없습니다.', function(ok) { if (ok) hrPost('/admin/pay/closeData.do', { YM: ym, CLOSE: true }, load); });
			bootbox.prompt({ title: dpYmLabel(ym) + ' 급여 마감 해제 사유 (이력에 남습니다)', callback: function(v) { if (v === null) return; if (!$.trim(v)) return false; hrPost('/admin/pay/closeData.do', { YM: ym, CLOSE: false, REASON: v }, load); } });
		});
		$('#btnCloseTrade').on('click', function() {
			bootbox.confirm(dpYmLabel(ym) + (tradeClosed ? ' 매출·매입 마감을 해제할까요?' : ' 매출·매입을 마감할까요? 마감하면 일반 건 등록·수정·삭제와 금액 고치기가 막힙니다(세금계산서 묶기·발급 표시는 됩니다).'), function(ok) {
				if (ok) hrPost('/admin/trade/all/closeData.do', { YM: ym, CLOSE: !tradeClosed }, load);
			});
		});
		$('#PARTNER_SQ').on('change', function() { var typed = this.value === '__new'; $('#PARTNER_NM').toggle(typed).prop('required', typed); if (typed) $('#PARTNER_NM').focus(); });
		$('#REPEAT_ON').on('change', function() { $('#REPEAT_UNTIL').prop('disabled', !this.checked); });
		$('#AMT').on('input', function() { var a = Number(String(this.value).replace(/,/g, '')); var ok = this.value !== '' && !isNaN(a); $('#VAT').val(ok ? dpWon(vat(a)) : ''); $('#TOTAL').val(ok ? dpWon(a + vat(a)) : ''); });
		load();
	});
	</script>
</body>
</html>
