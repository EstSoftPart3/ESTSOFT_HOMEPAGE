<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<style>
	.eq-link { background: none; border: 0; padding: 0; color: #0b6e8a; font-weight: 600; text-decoration: underline; cursor: pointer; white-space: nowrap; }
	.eq-no { font-family: Consolas, monospace; font-size: 12px; }
	.eq-pill { display: inline-block; padding: 0 8px; border-radius: 10px; font-size: 11px; font-weight: 600; white-space: nowrap; background: #eef1f4; color: #444; }
	.eq-pill.rent { background: #dff3f9; color: #0b6e8a; } .eq-pill.bad { background: #fdeaea; color: #a32020; } .eq-pill.warn { background: #fff5dc; color: #7a5600; } .eq-pill.good { background: #e6f6ea; color: #17692f; }
	#alerts { display: flex; flex-wrap: wrap; gap: 8px; }
	#alerts button { border: 1px solid #f0d9a0; background: #fff5dc; color: #7a5600; border-radius: 6px; padding: 3px 10px; font-size: 12px; font-weight: 600; }
	#alerts button.on { background: #7a5600; color: #fff; }
	.eq-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 2px 18px; }
	.eq-grid .hr-card-label { flex-basis: 70px; }
	#cardBody .table { font-size: 12px; }
	#cardBody .table td { vertical-align: middle; }
	.eq-chip { display: inline-flex; align-items: center; gap: 4px; background: #f3f6f8; border-radius: 10px; padding: 1px 4px 1px 9px; margin: 0 4px 4px 0; font-size: 12px; }
	.eq-chip button { background: none; border: 0; color: #777; padding: 0 3px; }
	.eq-busy { opacity: .5; pointer-events: none; }
	.eq-fix, #cardBody .eq-fix td { background: #fff8e3; }
	.eq-need { color: #a87900; outline: 1px solid #e0a800; outline-offset: -3px; }
	.eq-todo { background: #fff5dc; color: #7a5600; border-radius: 6px; padding: 7px 12px; font-weight: 600; font-size: 13px; }
	#labelSheet { display: none; }
	@media print {
		body * { visibility: hidden; }
		#labelSheet, #labelSheet * { visibility: visible; }
		#labelSheet { display: grid; position: absolute; left: 0; top: 0; width: 100%; grid-template-columns: repeat(2, 1fr); gap: 3mm; }
		.eq-label { border: 1px solid #000; padding: 4mm; text-align: center; font-size: 10pt; break-inside: avoid; }
		.eq-label b { display: block; font-size: 12pt; }
	}
</style>

<body class="hold-transition sidebar-mini">

	<div class="wrapper">

		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>

		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header">
					<h3 class="card-title bTitle"><b>장비대장</b></h3>
				</div>

				<div class="card-body">
					<div id="alerts" class="mb-2" role="group" aria-label="처리할 일"></div>
					<div class="cal-panel">
						<div class="cal-panel-body">
							<div class="form-row align-items-end">
								<div class="col-md-3 col-12 mb-2">
									<label for="keyword">검색 (장비번호·모델·시리얼·사용자·메모)</label>
									<input type="search" id="keyword" class="form-control form-control-sm">
								</div>
								<div class="col-md-1 col-6 mb-2"><label for="fType">구분</label><select id="fType" class="form-control form-control-sm"></select></div>
								<div class="col-md-2 col-6 mb-2"><label for="fPurpose">용도</label><select id="fPurpose" class="form-control form-control-sm"></select></div>
								<div class="col-md-6 col-12 mb-2 text-right">
									<button type="button" class="btn btn-sm btn-outline-secondary" onclick="resetFilters();"><i class="fas fa-undo"></i> 초기화</button>
									<button type="button" class="btn btn-sm btn-outline-secondary" onclick="downloadCsv();"><i class="fas fa-file-excel"></i> 엑셀 내려받기</button>
									<button type="button" class="btn btn-sm btn-outline-secondary" onclick="printLabels();"><i class="fas fa-tag"></i> 라벨 인쇄</button>
									<button type="button" class="btn btn-sm btn-outline-secondary" onclick="openSeal();"><i class="fas fa-stamp"></i> 직인 <span id="sealState"></span></button>
									<button type="button" class="btn btn-sm btn-outline-primary" onclick="openNew();"><i class="fas fa-plus"></i> 장비 등록</button>
									<button type="button" class="btn btn-sm btn-primary" onclick="openRent();"><i class="fas fa-hand-holding"></i> 대여 등록</button>
								</div>
							</div>
						</div>
					</div>

					<div class="cal-panel">
						<div class="cate-tabs" id="tabs" role="tablist" aria-label="장비 상태"></div>
						<div class="table-responsive px-3">
							<table class="table table-sm table-hover cal-table mb-0" id="focusTable" hidden>
								<thead><tr><th>장비번호</th><th>구분</th><th>모델</th><th>상태</th><th>사용자·위치</th><th id="focusLabel"></th><th><span class="sr-only">수정</span></th></tr></thead>
								<tbody id="focusBody"></tbody>
							</table>
							<table class="table table-sm table-hover cal-table mb-0" id="mainTable">
								<thead><tr><th><input type="checkbox" id="checkAll" aria-label="이 목록 모두 선택"></th><th>장비번호</th><th>구분</th><th>브랜드</th><th>모델</th><th>시리얼</th><th>상태</th><th>사용자·위치</th><th>대여일</th><th>용도</th><th>최근 점검</th><th>메모</th></tr></thead>
								<tbody id="listBody"></tbody>
							</table>
						</div>
						<div class="small text-muted px-3 py-2">브랜드, 모델, 시리얼은 칸을 누르면 바로 수정되고, 💬 로 메모를 남깁니다. 장비 비밀번호는 적지 마세요. 상태와 사용자는 대여·반납 처리로만 바뀝니다.</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<div id="labelSheet"></div>

	<div class="modal fade" id="cardModal" tabindex="-1" role="dialog" aria-labelledby="cardTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="cardTitle">장비카드</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<div class="modal-body" id="cardBody"></div>
				<div class="modal-footer" id="cardFoot"></div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="newModal" tabindex="-1" role="dialog" aria-labelledby="newTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="newTitle">장비 등록</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<form id="newForm" onsubmit="saveNew(); return false;">
					<div class="modal-body"><div class="form-row">
						<div class="col-md-4 mb-2"><label for="nType">구분 *</label><select id="nType" name="TYPE_CD" class="form-control form-control-sm" required></select></div>
						<div class="col-md-8 mb-2"><label for="nNo">장비번호 * (가장 작은 빈 번호를 제안합니다)</label><input id="nNo" name="EQP_NO" class="form-control form-control-sm" required></div>
						<div class="col-md-6 mb-2"><label for="nBrand">브랜드</label><input id="nBrand" name="BRAND_NM" class="form-control form-control-sm"></div>
						<div class="col-md-6 mb-2"><label for="nModel">모델명</label><input id="nModel" name="MODEL_NM" class="form-control form-control-sm"></div>
						<div class="col-md-6 mb-2"><label for="nSerial">시리얼</label><input id="nSerial" name="SERIAL_NO" class="form-control form-control-sm"></div>
						<div class="col-md-6 mb-2"><label for="nLoc">보관 위치</label><input id="nLoc" name="LOCATION_NM" class="form-control form-control-sm" list="locations"></div>
					</div></div>
					<div class="modal-footer"><button type="submit" class="btn btn-sm btn-primary">등록</button></div>
				</form>
			</div>
		</div>
	</div>

	<div class="modal fade" id="rentModal" tabindex="-1" role="dialog" aria-labelledby="rentTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="rentTitle">대여 등록</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<form id="rentForm" onsubmit="saveRent(); return false;">
					<div class="modal-body"><div class="form-row">
						<div class="col-12 mb-2" id="staffBox"><label for="rStaff">직원 *</label><input id="rStaff" class="form-control form-control-sm" list="staffList" autocomplete="off"><div class="small text-muted" id="staffHint"></div>
							<div class="small text-muted">대여는 직원(교육생은 직원관리 대기)에게만 합니다. 교육실·서버용처럼 사람이 아닌 곳은 대여하지 말고 보관 위치로 적어 주세요.</div></div>
						<div class="col-md-6 mb-2"><label for="rStart">대여일 *</label><input type="date" id="rStart" class="form-control form-control-sm" required></div>
						<div class="col-md-6 mb-2"><label for="rPurpose">용도</label><input id="rPurpose" class="form-control form-control-sm" list="purposes"></div>
						<div class="col-md-6 mb-2"><label for="rProject">프로젝트·현장</label><input id="rProject" class="form-control form-control-sm"></div>
						<div class="col-md-6 mb-2"><label for="rHandover">인계자</label><input id="rHandover" class="form-control form-control-sm"></div>
						<div class="col-12 mb-2"><label for="rAdd">장비 (보관중 장비를 번호나 모델로 검색해 Enter)</label><input id="rAdd" class="form-control form-control-sm" list="stockList" autocomplete="off"><div id="rPicked" class="mt-2"></div></div>
					</div></div>
					<div class="modal-footer"><button type="submit" class="btn btn-sm btn-primary">저장하고 서명 요청</button></div>
				</form>
			</div>
		</div>
	</div>

	<div class="modal fade" id="returnModal" tabindex="-1" role="dialog" aria-labelledby="returnTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="returnTitle">반납 처리</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<form id="returnForm" onsubmit="saveReturn(); return false;">
					<div class="modal-body"><div class="form-row">
						<div class="col-12 mb-2" id="returnList" role="group" aria-label="반납할 장비"></div>
						<div class="col-md-6 mb-2"><label for="tEnd">반납일 *</label><input type="date" id="tEnd" class="form-control form-control-sm" required></div>
						<div class="col-md-6 mb-2"><label for="tLoc">보관 위치</label><input id="tLoc" class="form-control form-control-sm" list="locations"></div>
						<div class="col-12 mb-2">
							<div class="form-check form-check-inline" id="formatBox"><input class="form-check-input" type="checkbox" id="tFormat"><label class="form-check-label" for="tFormat">포맷 완료</label></div>
							<div class="form-check form-check-inline"><input class="form-check-input" type="checkbox" id="tLabel"><label class="form-check-label" for="tLabel">라벨 부착 확인</label></div>
						</div>
						<div class="col-12 mb-2"><label for="tIssue">이상 내용 (입력하면 고른 장비에 메모로 남김)</label><textarea id="tIssue" rows="2" class="form-control form-control-sm"></textarea></div>
					</div></div>
					<div class="modal-footer"><button type="submit" class="btn btn-sm btn-primary">반납 완료</button></div>
				</form>
			</div>
		</div>
	</div>

	<div class="modal fade" id="disposeModal" tabindex="-1" role="dialog" aria-labelledby="disposeTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="disposeTitle">폐기·분실 처리</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<form id="disposeForm" onsubmit="saveDispose(); return false;">
					<div class="modal-body"><div class="form-row">
						<div class="col-md-6 mb-2"><label for="dStatus">구분</label><select id="dStatus" class="form-control form-control-sm"><option value="DISPOSED">폐기</option><option value="LOST">분실</option></select></div>
						<div class="col-md-6 mb-2"><label for="dDate">처리일 *</label><input type="date" id="dDate" class="form-control form-control-sm" required></div>
						<div class="col-12 mb-2"><label for="dReason">사유</label><textarea id="dReason" rows="2" class="form-control form-control-sm"></textarea></div>
						<div class="col-12 small text-muted">폐기는 보관중 장비만 가능합니다. 처리한 장비의 번호는 새 장비에 다시 쓸 수 있습니다.</div>
					</div></div>
					<div class="modal-footer"><button type="submit" class="btn btn-sm btn-danger">처리</button></div>
				</form>
			</div>
		</div>
	</div>

	<div class="modal fade" id="sealModal" tabindex="-1" role="dialog" aria-labelledby="sealTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="sealTitle">대표 직인 등록</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<div class="modal-body">
					<p class="small text-muted">대여증서의 임대인 자리에 들어갑니다. 500KB 이하의 PNG 또는 JPG 파일을 올려 주세요. 다시 올리면 바뀝니다.</p>
					<input type="file" id="sealFile" accept="image/png,image/jpeg" aria-label="직인 이미지 파일">
				</div>
			</div>
		</div>
	</div>

	<datalist id="staffList"></datalist>
	<datalist id="stockList"></datalist>
	<datalist id="locations"><option value="장비실"><option value="교육실"></datalist>
	<datalist id="purposes"><option value="프로젝트"><option value="부트캠프"><option value="연구용"><option value="재택근무용"><option value="교육용"><option value="서버용"></datalist>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>

	<script>
	var TYPE = hrCodeMap('EQP_TYPE');
	var STATUS = { RENT: '대여중', STOCK: '보관중', DISPOSED: '폐기', LOST: '분실' };
	// 특이사항·이슈는 메모로 합쳤다. 목록 💬 버튼과 장비카드 메모 칸에서 쌓는다
	var MEMO_API = hrMemoApi('/admin/equipment/', 'equipment');
	var rows = [], staff = [], tab = 'HAVE', alertKey = null, holderKey = null, opened = null, card = null, picked = [];
	// 관리자 홈 바로가기: ?alert=left|sign(알림 필터) · ?tab=REVIEW(검토 필요)
	var alertParam = /[?&]alert=(left|sign|audit)\b/.exec(location.search), tabParam = /[?&]tab=(REVIEW)\b/.exec(location.search);
	if (alertParam) alertKey = alertParam[1];
	if (tabParam) tab = tabParam[1];

	$(function() {
		hrFillSelect('#fType', 'EQP_TYPE', ['', '전체']);
		hrFillSelect('#nType', 'EQP_TYPE', ['', '']);
		$('#keyword').on('input', render);
		$('#fType, #fPurpose').on('change', render);
		$('#checkAll').on('change', function() { $('#listBody .eq-check').prop('checked', this.checked); });
		$('#rStaff').on('input', function() { var s = staffPicked(); $('#staffHint').text(s && !s.EMPLY_ID ? '홈페이지 계정과 연결되지 않아 게스트로 처리합니다. 담당자 화면에서 서명하거나 서명본을 올립니다.' : ''); });
		$('#rAdd').on('keydown change', function(e) { if (e.type === 'keydown' && e.key !== 'Enter') return; e.preventDefault(); addPicked(); });
		$('#nType').on('change', function() { if (this.value) hrPost('/admin/equipment/suggestNoData.do', { TYPE_CD: this.value }, function(res) { $('#nNo').val(res.result); }); });
		$('#sealFile').on('change', uploadSeal);
		$('#cardModal').on('hidden.bs.modal', function() { opened = null; card = null; });
		// 다른 화면의 장비번호 링크(?EQP_SQ=번호)로 오면 그 장비카드를 바로 연다
		var linked = /[?&]EQP_SQ=(\d+)/.exec(location.search);
		load(function() {
			if (linked && rows.some(function(r) { return String(r.EQP_SQ) === linked[1]; })) openCard(Number(linked[1]));
		});
	});

	$(document).on('click', '.cate-tab', function() { tab = $(this).data('tab'); $('#checkAll').prop('checked', false); render(); });

	function load(then) {
		hrPost('/admin/equipment/equipmentListData.do', {}, function(res) {
			rows = res.result.list || [];
			staff = res.result.staff || [];
			$('#sealState').text(res.result.seal ? '등록됨' : '미등록');
			var keep = $('#fPurpose').val();
			$('#fPurpose').empty().append('<option value="">전체</option>');
			rows.map(function(r) { return r.PURPOSE_NM; }).filter(Boolean).filter(function(v, i, a) { return a.indexOf(v) === i; }).sort().forEach(function(v) { $('#fPurpose').append($('<option>').val(v).text(v)); });
			$('#fPurpose').val(keep || '');
			$('#staffList').empty();
			staff.forEach(function(s) { $('#staffList').append($('<option>').val(staffLabel(s))); });
			render();
			if (then) then();
		});
	}

	function staffLabel(s) { return s.STAFF_NM + ' · ' + (s.DEPT_NM || s.ORG_NM || '소속 없음') + ' · #' + s.STAFF_SQ; }
	function staffPicked() { var v = $('#rStaff').val(); return staff.filter(function(s) { return staffLabel(s) === v; })[0]; }
	function have(r) { return r.STATUS_CD === 'RENT' || r.STATUS_CD === 'STOCK'; }
	function needsReview(r) { return r.REVIEW_OPEN > 0 || r.REVIEW_NODATE > 0 || r.REVIEW_NOEND > 0; }
	function find(sq) { return rows.filter(function(r) { return String(r.EQP_SQ) === String(sq); })[0]; }

	var ALERTS = {
		left: ['퇴사자 미반납', function(r) { return r.STATUS_CD === 'RENT' && r.STAFF_STATUS === 'LEFT'; }],
		audit: ['이번 회차 미응답', function(r) { return r.AUDIT_RESULT === 'NONE'; }],
		sign: ['증서 서명 대기', function(r) { return r.SIGN_WAIT === 'Y'; }]
	};

	function filtered() {
		var kw = $.trim($('#keyword').val()).toLowerCase(), type = $('#fType').val(), purpose = $('#fPurpose').val();
		return rows.filter(function(r) {
			if (tab === 'HAVE' && !have(r) || tab === 'RENT' && r.STATUS_CD !== 'RENT' || tab === 'STOCK' && r.STATUS_CD !== 'STOCK' || tab === 'GONE' && have(r) || tab === 'REVIEW' && !needsReview(r)) return false;
			if (type && r.TYPE_CD !== type || purpose && r.PURPOSE_NM !== purpose) return false;
			if (alertKey && !ALERTS[alertKey][1](r)) return false;
			if (holderKey && r.HOLDER_NM !== holderKey) return false;
			return !kw || [r.EQP_NO, r.MODEL_NM, r.BRAND_NM, r.SERIAL_NO, r.HOLDER_NM, r.LOCATION_NM, r.MEMO].some(function(v) { return v && String(v).toLowerCase().indexOf(kw) >= 0; });
		});
	}

	function resetFilters() {
		$('#keyword').val('');
		$('#fType, #fPurpose').val('');
		alertKey = holderKey = null;
		render();
	}

	function render() {
		var $a = $('#alerts').empty();
		Object.keys(ALERTS).forEach(function(k) {
			var n = rows.filter(ALERTS[k][1]).length;
			if (n) $a.append($('<button type="button">').toggleClass('on', alertKey === k).attr('aria-pressed', alertKey === k).text(ALERTS[k][0] + ' ' + n).on('click', function() { alertKey = alertKey === k ? null : k; if (alertKey) tab = 'HAVE'; render(); }));
		});
		if (holderKey) $a.append($('<button type="button" class="on">').text(holderKey + ' 장비만 보는 중 ✕').on('click', function() { holderKey = null; render(); }));
		var count = function(f) { return rows.filter(f).length; };
		$('#tabs').empty().append(hrTab('HAVE', '보유', count(have), tab === 'HAVE')).append(hrTab('RENT', '대여중', count(function(r) { return r.STATUS_CD === 'RENT'; }), tab === 'RENT'))
			.append(hrTab('STOCK', '보관중', count(function(r) { return r.STATUS_CD === 'STOCK'; }), tab === 'STOCK')).append(hrTab('GONE', '폐기·분실', count(function(r) { return !have(r); }), tab === 'GONE'))
			.append(hrTab('REVIEW', '검토 필요', count(needsReview), tab === 'REVIEW'));
		var list = filtered(), focus = tab === 'REVIEW', $b = $('#listBody').empty();
		$('#mainTable').prop('hidden', focus);
		$('#focusTable').prop('hidden', !focus);
		if (focus) { renderFocus(list); return; }
		if (!list.length) { $b.append('<tr><td colspan="12" class="cal-empty">해당하는 장비가 없습니다.</td></tr>'); return; }
		list.forEach(function(r) {
			var $tr = $('<tr>');
			$tr.append($('<td>').append($('<input type="checkbox" class="eq-check">').attr('aria-label', r.EQP_NO + ' 선택').val(r.EQP_SQ)));
			$tr.append($('<td>').append($('<button type="button" class="eq-link eq-no">').text(r.EQP_NO).on('click', function() { openCard(r.EQP_SQ); })));
			$tr.append($('<td>').text(TYPE[r.TYPE_CD] || r.TYPE_CD));
			$tr.append(field($('<td>'), r, 'BRAND_NM', '브랜드')).append(field($('<td>'), r, 'MODEL_NM', '모델')).append(field($('<td>'), r, 'SERIAL_NO', '시리얼'));
			$tr.append($('<td>').append(statusPill(r.STATUS_CD)));
			var $who = $('<td>');
			if (r.HOLDER_NM) {
				$who.append($('<button type="button" class="eq-link">').css('font-weight', 400).text(r.HOLDER_NM).on('click', function() { holderKey = r.HOLDER_NM; render(); }));
				if (r.STAFF_STATUS === 'LEFT') $who.append(' <span class="eq-pill bad">퇴사</span>');
				if (r.SIGN_WAIT === 'Y') $who.append(' <span class="eq-pill warn">서명 대기</span>');
			} else {
				$who.addClass('text-muted').text(r.LOCATION_NM || '');
			}
			$tr.append($who).append($('<td>').text(r.START_DT || '')).append($('<td>').text(r.PURPOSE_NM || ''));
			$tr.append($('<td>').text(r.AUDIT_EXCL_YN === 'Y' ? '조사 제외' : (r.LAST_CHECK_DT || '')));
			$tr.append($('<td>').append(hrMemoBtn(MEMO_API, r.EQP_SQ, r.MEMO_CNT, r.EQP_NO, function() { load(); })));
			$b.append($tr);
		});
	}

	// 검토 필요 탭. 고치면 조건에서 벗어나 목록에서 빠진다
	function renderFocus(list) {
		var $b = $('#focusBody').empty();
		$('#focusLabel').text('검토 사유');
		list = list.slice().sort(function(a, b) { return (b.REVIEW_OPEN > 0) - (a.REVIEW_OPEN > 0); });
		if (!list.length) { $b.append('<tr><td colspan="7" class="cal-empty">해당하는 장비가 없습니다.</td></tr>'); return; }
		list.forEach(function(r) {
			var $why = $('<td>');
			if (r.REVIEW_OPEN > 0) $why.append('<span class="eq-pill bad">대여일 없음</span> ');
			if (r.REVIEW_NODATE > 0) $why.append($('<span class="eq-pill warn">').text('날짜 없는 이력 ' + r.REVIEW_NODATE)).append(' ');
			if (r.REVIEW_NOEND > 0) $why.append($('<span class="eq-pill warn">').text('반납일 없음 ' + r.REVIEW_NOEND));
			$b.append($('<tr>').append($('<td>').append($('<button type="button" class="eq-link eq-no">').text(r.EQP_NO).on('click', function() { openCard(r.EQP_SQ); })))
				.append($('<td>').text(TYPE[r.TYPE_CD] || r.TYPE_CD)).append($('<td>').text(r.MODEL_NM || '')).append($('<td>').append(statusPill(r.STATUS_CD)))
				.append($('<td>').text(r.HOLDER_NM || r.LOCATION_NM || '')).append($why)
				.append($('<td class="text-right">').append($('<button type="button" class="btn btn-sm btn-primary">').attr('aria-label', r.EQP_NO + ' 수정').text('수정').on('click', function() { openCard(r.EQP_SQ); }))));
		});
	}

	function statusPill(s) { return $('<span class="eq-pill">').addClass(s === 'RENT' ? 'rent' : s === 'STOCK' ? '' : 'bad').text(STATUS[s] || s); }

	function field($el, r, name, label, type) {
		return hrEditable($el, { url: '/admin/equipment/saveEquipmentFieldData.do', key: { EQP_SQ: r.EQP_SQ }, field: name, type: type, label: r.EQP_NO + ' ' + label,
			show: function() { return r[name]; }, value: function() { return r[name]; }, saved: function(v) { r[name] = v; } });
	}

	function selected() { return $('#listBody .eq-check:checked').map(function() { return find(this.value); }).get(); }

	// ── 장비카드 ──
	var SPEC = [['CPU_SPEC', 'CPU'], ['MEM_SPEC', '메모리'], ['SSD_SPEC', 'SSD'], ['HDD_SPEC', 'HDD'], ['LAN_YN', 'LAN']];

	function openCard(sq) {
		opened = sq;
		hrPost('/admin/equipment/equipmentCardData.do', { EQP_SQ: sq }, function(res) { card = res.result; paintCard(); $('#cardModal').modal('show'); });
	}

	function reloadCard() { var sq = opened; load(function() { if (sq) hrPost('/admin/equipment/equipmentCardData.do', { EQP_SQ: sq }, function(res) { card = res.result; paintCard(); }); }); }

	function cardRow(r, name, label, type) {
		return $('<div class="hr-card-row">').append($('<div class="hr-card-label">').text(label)).append(field($('<div>'), r, name, label, type));
	}

	function paintCard() {
		var r = find(opened), $b = $('#cardBody').empty();
		if (!r) return;
		$('#cardTitle').empty().append($('<span class="eq-no">').text(r.EQP_NO)).append(' ').append(statusPill(r.STATUS_CD));
		var fixes = card.rents.filter(rentNeeds).length;
		if (fixes) $b.append($('<div class="eq-todo mb-2">').text('고칠 곳 ' + fixes + '건 · 노란 칸에 입력하거나 이대로 확정하세요'));
		function rents() { paintRents($b); }
		function memos() { $b.append('<div class="hr-section">메모</div>'); hrMemoFeed($('<div>').appendTo($b), MEMO_API, r.EQP_SQ, function() { load(); }); }
		function files() { paintFiles($b, r); }
		(tab === 'REVIEW' ? [rents, basic, memos, files] : [basic, rents, memos, files]).forEach(function(paint) { paint(); });
		paintFoot(r);

		function basic() {
		$b.append('<div class="hr-section">기본 정보</div>');
		var $g = $('<div class="eq-grid">').appendTo($b);
		$g.append(cardRow(r, 'EQP_NO', '장비번호')).append(cardRow(r, 'BRAND_NM', '브랜드')).append(cardRow(r, 'MODEL_NM', '모델')).append(cardRow(r, 'SERIAL_NO', '시리얼'));
		if (r.TYPE_CD === 'NB' || r.TYPE_CD === 'DT') SPEC.forEach(function(s) { $g.append(cardRow(r, s[0], s[1])); });
		$g.append(cardRow(r, 'ETC_TXT', '기타'));
		if (r.STATUS_CD === 'STOCK') $g.append(cardRow(r, 'LOCATION_NM', '보관 위치'));
		$g.append(cardRow(r, 'AUDIT_EXCL_YN', '조사 제외', { list: [['N', '대상'], ['Y', '제외 (영구 대여 등)']] }));
		if (r.DISPOSE_DT) $b.append($('<div class="small text-muted mt-1">').text(STATUS[r.STATUS_CD] + ' ' + r.DISPOSE_DT + (r.DISPOSE_REASON ? ' · ' + r.DISPOSE_REASON : '')));
		}
	}

	function paintFoot(r) {
		var $f = $('#cardFoot').empty();
		if (have(r)) $f.append($('<button type="button" class="btn btn-sm btn-outline-danger mr-auto">').text('폐기·분실 처리').on('click', function() { openDispose(r); }));
		if (!have(r)) $f.append('<span class="mr-auto"></span>');
		if (!card.rents.length) $f.append($('<button type="button" class="btn btn-sm btn-outline-danger">').text('삭제').on('click', function() { deleteCard(r); }));
		if (r.STATUS_CD === 'RENT') $f.append($('<button type="button" class="btn btn-sm btn-primary">').text('반납 처리').on('click', function() { openReturn(r); }));
		if (r.STATUS_CD === 'STOCK') $f.append($('<button type="button" class="btn btn-sm btn-primary">').text('대여 등록').on('click', function() { $('#cardModal').modal('hide'); openRent([r]); }));
		$f.append('<button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">닫기</button>');
	}

	// 검토 조건은 selectEquipmentList 의 REVIEW_* 와 같다. 비어 있어 채워야 할 칸 이름을 돌려준다
	function rentNeeds(x) {
		if (x.REVIEW_DONE_YN === 'Y') return null;
		if (x.OPEN_YN === 'Y') return x.START_DT ? null : ['START_DT'];
		if (x.END_DT) return null;
		return x.START_DT ? ['END_DT'] : ['START_DT', 'END_DT'];
	}

	function rentCell(rent, name, label, type, need) {
		return hrEditable($('<td>').toggleClass('eq-need', !!need), { url: '/admin/equipment/saveRentFieldData.do', key: { RENT_SQ: rent.RENT_SQ }, field: name, type: type, label: label,
			show: function() { return rent[name] || (need ? '날짜 입력' : ''); }, value: function() { return rent[name]; }, saved: function(v) { rent[name] = v; if (name === 'HOLDER_NM' || name === 'START_DT' || name === 'END_DT') reloadCard(); } });
	}

	function paintRents($b) {
		$b.append('<div class="hr-section">대여이력</div>');
		var $t = $('<table class="table table-sm mb-0"><thead><tr><th>사용자</th><th>대여일</th><th>반납일</th><th>용도</th><th>프로젝트·현장</th><th>인계자</th><th>증서</th><th>검토</th></tr></thead></table>');
		var $body = $('<tbody>').appendTo($t);
		if (!card.rents.length) $body.append('<tr><td colspan="8" class="text-muted text-center">대여이력이 없습니다.</td></tr>');
		card.rents.forEach(function(x) {
			var need = rentNeeds(x) || [];
			var $tr = $('<tr>').toggleClass('eq-fix', need.length > 0).append(rentCell(x, 'HOLDER_NM', '사용자')).append(rentCell(x, 'START_DT', '대여일', 'date', need.indexOf('START_DT') >= 0));
			if (x.OPEN_YN === 'Y') $tr.append($('<td>').append('<span class="eq-pill rent">사용 중</span>')); else $tr.append(rentCell(x, 'END_DT', '반납일', 'date', need.indexOf('END_DT') >= 0));
			$tr.append(rentCell(x, 'PURPOSE_NM', '용도')).append(rentCell(x, 'PROJECT_NM', '프로젝트')).append(rentCell(x, 'HANDOVER_NM', '인계자'));
			var $doc = $('<td>');
			if (x.RENT_GROUP) $doc.append($('<a target="_blank" rel="noopener">').attr('href', '/admin/equipment/certificate.do?group=' + encodeURIComponent(x.RENT_GROUP)).text(x.SIGN_DT ? '서명 완료' : '서명 대기'));
			var $check = $('<td>');
			if (need.length) $check.append($('<button type="button" class="btn btn-sm btn-outline-secondary text-nowrap">').attr('aria-label', x.HOLDER_NM + ' 이력 이대로 확정').text('이대로 확정').on('click', function() {
				hrPost('/admin/equipment/saveRentFieldData.do', { RENT_SQ: x.RENT_SQ, FIELD: 'REVIEW_DONE_YN', VALUE: 'Y' }, reloadCard);
			}));
			$body.append($tr.append($doc).append($check));
		});
		$b.append($('<div class="table-responsive">').append($t));
	}

	function paintFiles($b, r) {
		var $input = $('<input type="file" id="eqFile" class="d-none" accept="image/*,application/pdf">').on('change', function() { if (this.files[0]) uploadFile(r, this.files[0]); this.value = ''; });
		var $doc = hrFillSelect('<select id="eqDoc" class="form-control form-control-sm" style="width:90px" aria-label="첨부 종류">', 'EQP_DOC');
		$b.append($('<div class="hr-section d-flex align-items-center">').css('gap', '6px').text('첨부').append($('<span class="ml-auto">')).append($doc).append($input).append('<label for="eqFile" class="btn btn-sm btn-outline-primary mb-0">파일 추가</label>'));
		if (!card.files.length) $b.append('<div class="small text-muted">첨부가 없습니다.</div>');
		card.files.forEach(function(f) {
			$b.append($('<span class="eq-chip">').append($('<a target="_blank" rel="noopener">').attr('href', f.WEB_LINK || ('https://drive.google.com/file/d/' + f.FILE_ID + '/view')).text(f.FILE_NM))
				.append($('<button type="button">').attr('aria-label', f.FILE_NM + ' 연결 끊기').html('&times;').on('click', function() {
					bootbox.confirm(f.FILE_NM + ' 연결을 끊을까요? 드라이브의 파일은 지우지 않습니다.', function(ok) { if (ok) hrPost('/admin/equipment/deleteFileData.do', { FILE_SQ: f.FILE_SQ, EQP_SQ: r.EQP_SQ }, reloadCard); });
				})));
		});
	}

	function uploadFile(r, file) {
		if (file.size > 50 * 1024 * 1024) { bootbox.alert('50MB 이하 파일만 올릴 수 있습니다.'); return; }
		var fd = new FormData();
		fd.append('EQP_SQ', r.EQP_SQ);
		fd.append('DOC_CD', $('#eqDoc').val());
		fd.append('file', file);
		$('#cardBody').addClass('eq-busy');
		$.ajax({ url: '/admin/equipment/uploadFileData.do', type: 'POST', data: fd, processData: false, contentType: false }).done(function(res) {
			$('#cardBody').removeClass('eq-busy');
			if (res.error) { bootbox.alert(res.error); return; }
			reloadCard();
		}).fail(function() { $('#cardBody').removeClass('eq-busy'); });
	}

	function deleteCard(r) {
		bootbox.confirm(r.EQP_NO + ' 장비를 삭제할까요? 되돌릴 수 없습니다.', function(ok) {
			if (ok) hrPost('/admin/equipment/deleteEquipmentData.do', { EQP_SQ: r.EQP_SQ }, function() { $('#cardModal').modal('hide'); load(); });
		});
	}

	// ── 등록 ──
	function openNew() { $('#newForm')[0].reset(); $('#newModal').modal('show'); }

	function saveNew() {
		hrPost('/admin/equipment/insertEquipmentData.do', $('#newForm').serialize(), function(res) {
			$('#newModal').modal('hide');
			load(function() { openCard(res.result); });
		});
	}

	// ── 대여 ──
	function today() { return moment().format('YYYY-MM-DD'); }
	function stockLabel(r) { return r.EQP_NO + ' · ' + (TYPE[r.TYPE_CD] || '') + ' · ' + (r.MODEL_NM || ''); }

	function openRent(list) {
		$('#rentForm')[0].reset();
		$('#rStart').val(today());
		$('#staffHint').text('');
		$('#stockList').empty();
		rows.filter(function(r) { return r.STATUS_CD === 'STOCK'; }).forEach(function(r) { $('#stockList').append($('<option>').val(stockLabel(r))); });
		picked = (list || selected()).filter(function(r) { return r.STATUS_CD === 'STOCK'; });
		paintPicked();
		$('#rentModal').modal('show');
	}

	function addPicked() {
		var v = $('#rAdd').val(), r = rows.filter(function(x) { return x.STATUS_CD === 'STOCK' && stockLabel(x) === v; })[0];
		if (r && picked.indexOf(r) < 0) picked.push(r);
		if (r) $('#rAdd').val('');
		paintPicked();
	}

	function paintPicked() {
		var $p = $('#rPicked').empty();
		picked.forEach(function(r) {
			var $c = $('<span class="eq-chip">').append($('<span class="eq-no">').text(r.EQP_NO));
			if (r.MEMO_CNT > 0) $c.append(' ').append($('<span class="eq-pill">').text('메모 ' + r.MEMO_CNT));
			$p.append($c.append($('<button type="button">').attr('aria-label', r.EQP_NO + ' 빼기').html('&times;').on('click', function() { picked.splice(picked.indexOf(r), 1); paintPicked(); })));
		});
	}

	function saveRent() {
		var s = staffPicked();
		if (!s) { bootbox.alert('직원을 목록에서 골라 주세요.'); return; }
		if (!picked.length) { bootbox.alert('대여할 장비를 골라 주세요.'); return; }
		hrPost('/admin/equipment/rentEquipmentData.do', { EQP_SQS: picked.map(function(r) { return r.EQP_SQ; }).join(','), STAFF_SQ: s.STAFF_SQ,
			START_DT: $('#rStart').val(), PURPOSE_NM: $('#rPurpose').val(), PROJECT_NM: $('#rProject').val(), HANDOVER_NM: $('#rHandover').val() }, function(res) {
			$('#rentModal').modal('hide');
			load();
			var url = '/admin/equipment/certificate.do?group=' + encodeURIComponent(res.result.RENT_GROUP);
			if (res.result.GUEST) bootbox.alert({ message: $('<div>').append('게스트 대여로 저장했습니다. ').append($('<a target="_blank" rel="noopener">').attr('href', url).text('증서를 열어 서명받거나 서명본을 올려 주세요.')) });
			else bootbox.alert('저장했습니다. 직원이 홈페이지의 내 장비에서 서명하면 완료됩니다.');
		});
	}

	// ── 반납 ──
	function openReturn(r) {
		var same = rows.filter(function(x) { return x.STATUS_CD === 'RENT' && (r.STAFF_SQ ? x.STAFF_SQ === r.STAFF_SQ : x.HOLDER_NM === r.HOLDER_NM); });
		$('#returnForm')[0].reset();
		$('#tEnd').val(today());
		$('#returnTitle').text('반납 처리 · ' + r.HOLDER_NM);
		var $l = $('#returnList').empty(), computer = false;
		same.forEach(function(x) {
			var id = 'ret' + x.RENT_SQ;
			computer = computer || x.TYPE_CD === 'NB' || x.TYPE_CD === 'DT';
			$l.append($('<div class="form-check">').append($('<input type="checkbox" class="form-check-input">').attr('id', id).val(x.RENT_SQ).prop('checked', x.EQP_SQ === r.EQP_SQ))
				.append($('<label class="form-check-label">').attr('for', id).text(stockLabel(x))));
		});
		$('#formatBox').prop('hidden', !computer);
		$('#cardModal').modal('hide');
		$('#returnModal').modal('show');
	}

	function saveReturn() {
		var ids = $('#returnList input:checked').map(function() { return this.value; }).get().join(',');
		if (!ids) { bootbox.alert('반납할 장비를 골라 주세요.'); return; }
		hrPost('/admin/equipment/returnEquipmentData.do', { RENT_SQS: ids, END_DT: $('#tEnd').val(), LOCATION_NM: $('#tLoc').val(), RETURN_FORMAT_YN: $('#tFormat').prop('checked') ? 'Y' : 'N', RETURN_LABEL_YN: $('#tLabel').prop('checked') ? 'Y' : 'N', ISSUE: $('#tIssue').val() }, function() {
			$('#returnModal').modal('hide');
			load();
		});
	}

	// ── 폐기·분실 ──
	var disposing = null;
	function openDispose(r) {
		disposing = r;
		$('#disposeForm')[0].reset();
		$('#dDate').val(today());
		$('#dStatus').val(r.STATUS_CD === 'RENT' ? 'LOST' : 'DISPOSED');
		$('#disposeModal').modal('show');
	}

	function saveDispose() {
		hrPost('/admin/equipment/disposeEquipmentData.do', { EQP_SQ: disposing.EQP_SQ, STATUS_CD: $('#dStatus').val(), DISPOSE_DT: $('#dDate').val(), DISPOSE_REASON: $('#dReason').val() }, function() {
			$('#disposeModal').modal('hide');
			reloadCard();
		});
	}

	// ── 직인 ──
	function openSeal() { $('#sealFile').val(''); $('#sealModal').modal('show'); }

	function uploadSeal() {
		var file = this.files[0];
		if (!file) return;
		if (file.size > 500 * 1024) { bootbox.alert('500KB 이하 이미지를 올려 주세요.'); return; }
		var reader = new FileReader();
		reader.onload = function() {
			hrPost('/admin/equipment/saveSealData.do', { IMG: reader.result }, function() { $('#sealModal').modal('hide'); $('#sealState').text('등록됨'); bootbox.alert('직인을 등록했습니다.'); });
		};
		reader.readAsDataURL(file);
	}

	// ── 내려받기·라벨 ──
	function csvCell(v) {
		var s = v === undefined || v === null ? '' : String(v);
		if (/^[=+\-@\t\r]/.test(s)) s = "'" + s; // 엑셀이 수식으로 실행하지 않게 한다
		return '"' + s.replace(/"/g, '""') + '"';
	}

	function downloadCsv() {
		var head = ['장비번호', '구분', '브랜드', '모델', '시리얼', '상태', '사용자', '위치', '대여일', '용도', '최근 점검', '메모'];
		var lines = [head.map(csvCell).join(',')].concat(filtered().map(function(r) {
			return [r.EQP_NO, TYPE[r.TYPE_CD], r.BRAND_NM, r.MODEL_NM, r.SERIAL_NO, STATUS[r.STATUS_CD], r.HOLDER_NM, r.LOCATION_NM, r.START_DT, r.PURPOSE_NM, r.LAST_CHECK_DT, r.MEMO].map(csvCell).join(',');
		}));
		var a = document.createElement('a');
		a.href = URL.createObjectURL(new Blob(['﻿' + lines.join('\r\n')], { type: 'text/csv;charset=utf-8' }));
		a.download = '장비대장_' + today() + '.csv';
		a.click();
		URL.revokeObjectURL(a.href);
	}

	function printLabels() {
		var list = selected();
		if (!list.length) { bootbox.alert('라벨을 인쇄할 장비를 체크해 주세요.'); return; }
		var $s = $('#labelSheet').empty();
		list.forEach(function(r) { $s.append($('<div class="eq-label">').append($('<b>').text(r.EQP_NO)).append('이 장비는 ㈜이에스티소프트의 자산입니다.')); });
		window.print();
	}
	</script>
</body>
</html>
