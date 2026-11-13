<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<style>
	#dpHead th, #dpBody td { white-space: nowrap; }
	#dpHead th[draggable] { cursor: grab; user-select: none; }
	#dpHead th.dragging { opacity: .4; }
	#dpHead th.drop-l { box-shadow: inset 3px 0 0 #0b6e8a; }
	#dpHead th.drop-r { box-shadow: inset -3px 0 0 #0b6e8a; }
	#dpHead th:focus { outline: 2px solid #16d5ff; outline-offset: -2px; }
	tr.dp-edit td { background: #fff8e3; padding: 4px; }
	tr.dp-edit td:last-child, #dpHead th:last-child { position: sticky; right: 0; background: #fff8e3; }
	#dpHead th:last-child { background: #fafbfc; }
	tr.dp-edit .form-control { height: 26px; padding: 0 4px; font-size: 12px; min-width: 84px; }
	tr.dp-edit input[type=date] { min-width: 125px; }
	tr.dp-edit .is-invalid { box-shadow: 0 0 0 2px #e2a5a5; }
	tr.dp-hist:hover td { background: #eef9fc; }
	.pl-changed { font-weight: 700; }
	.dp-gantt { min-width: 960px; }
	.dp-g-row { display: grid; grid-template-columns: 170px 1fr; border-bottom: 1px solid rgba(17,17,17,.06); align-items: center; min-height: 34px; }
	.dp-g-who { padding: 0 12px; display: flex; gap: 6px; align-items: center; }
	.dp-g-head { display: grid; grid-template-columns: repeat(12, 1fr); font-size: 11.5px; color: #444; font-weight: 700; }
	.dp-g-head span { padding: 6px 0 6px 5px; } .dp-g-head .now { color: #0b6e8a; }
	.dp-g-track { position: relative; height: 34px; background: repeating-linear-gradient(90deg, transparent 0, transparent calc(8.3333% - 1px), #eef1f4 calc(8.3333% - 1px), #eef1f4 8.3333%); }
	.dp-b { position: absolute; top: 7px; height: 20px; border-radius: 4px; background: #9fd8e8; color: #06323e; font-size: 11px; line-height: 20px; padding: 0 7px; overflow: hidden; white-space: nowrap; font-weight: 700; }
	.dp-b.soon { background: #f6d27c; color: #4f3800; } .dp-b.urgent { background: #eda3a3; color: #5a1010; } .dp-b.past { background: #d7dde2; color: #444; }
	.dp-b.open { background: linear-gradient(90deg, #9fd8e8 80%, rgba(159,216,232,.15)); }
	.dp-today { position: absolute; top: 0; bottom: 0; width: 2px; background: #0b6e8a; z-index: 2; }
	.dp-views { display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 12px; }
	.dp-views button { border: 1px solid rgba(17,17,17,.15); background: #fff; border-radius: 999px; padding: 6px 14px; font-weight: 700; font-size: 13px; color: #444; }
	.dp-views button b { margin-left: 5px; }
	.dp-views button.warn b { color: #7a5600; } .dp-views button.bad b { color: #a32020; }
	.dp-views button[aria-selected=true] { background: #111; border-color: #111; color: #fff; } .dp-views button[aria-selected=true] b { color: #fff; }
	.dp-prj { border: 1px solid #b9dbe6; background: #f3fbfd; color: #0b6e8a; border-radius: 10px; padding: 0 8px; font-size: 11.5px; font-weight: 700; }
	.dp-prj.zero { opacity: .45; }
	.dp-far { color: #7a5600; font-size: 11px; font-weight: 700; margin-left: 4px; }
	.dp-want { color: #0b6e8a; }
	/* 급여 칸 묶음(급여 권한만): 투입 칸과 구분되는 회색 바탕, 묶음 첫 칸 머리에 접기·펴기 */
	th.dp-pay-h { background: #eceef1 !important; color: #222; }
	td.dp-pay { background: #f7f8fa; }
	td.dp-pay.a { background: #eefaf8; } td.dp-pay.d { background: #fdf3ec; } td.dp-pay.p { background: #f6f1fc; }
	td.dp-pay.edit { text-decoration: underline dotted rgba(11,110,138,.6); text-underline-offset: 3px; cursor: pointer; }
	.dp-pay-tog { border: 0; background: #111; color: #fff; border-radius: 999px; padding: 1px 10px; font-size: 11.5px; font-weight: 700; white-space: nowrap; }
	.dp-pay-band { border: 0; border-radius: 8px; padding: 0 6px; font-size: 11px; font-weight: 700; color: #fff; margin-left: 4px; }
	.dp-pay-band.a { background: #0e7c86; } .dp-pay-band.d { background: #b4531a; } .dp-pay-band.p { background: #6b3fa0; }
	.dp-pay-x { border: 0; background: none; padding: 0 0 0 3px; color: inherit; font-size: 10px; }
	#altView td { white-space: nowrap; vertical-align: middle; }
	#altView tr.dp-child td { background: #f4fafc; font-size: 12px; }
	#altView tr.dp-child td:first-child { padding-left: 24px; color: #0b6e8a; font-weight: 700; }
	#altView tr.dp-form td { background: #fff8e3; }
	#altView tr.dp-form .form-control { height: 26px; padding: 0 4px; font-size: 12px; display: inline-block; width: auto; min-width: 90px; margin: 2px 2px; }
	.prj-item { border: 1px solid rgba(17,17,17,.1); border-left: 4px solid #b9dbe6; border-radius: 8px; overflow: hidden; margin-bottom: 12px; }
	.prj-item.now { border-left-color: #0b6e8a; } .prj-item.plan { border-left-color: #e0a800; }
	.prj-head { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; padding: 8px 12px; background: #fafcfd; border-bottom: 1px solid rgba(17,17,17,.08); }
	.prj-head .t { font-weight: 700; font-size: 14px; }
	.prj-head .when { margin-left: auto; font-weight: 700; font-variant-numeric: tabular-nums; }
	.prj-head .when span { color: #8a949c; font-weight: 400; margin-left: 4px; }
	.prj-src { font-size: 10.5px; border: 1px solid #d5dbe0; color: #5f6b75; border-radius: 8px; padding: 0 6px; }
	.prj-meta { display: grid; grid-template-columns: 90px 1fr 90px 1fr; font-size: 12.5px; }
	.prj-meta div { padding: 5px 12px; border-bottom: 1px solid rgba(17,17,17,.08); }
	.prj-meta .k { background: #f6f8fa; color: #5f6b75; font-weight: 700; font-size: 11.5px; }
	.prj-env { width: 100%; border-collapse: collapse; table-layout: fixed; font-size: 12px; }
	.prj-env th { background: #eef4f7; color: #33505c; font-size: 11px; padding: 4px; text-align: center; border-right: 1px solid #dbe6ec; border-bottom: 1px solid #dbe6ec; }
	.prj-env th.grp { background: #dfeef4; color: #0b6e8a; }
	.prj-env td { text-align: center; padding: 5px; border-right: 1px solid rgba(17,17,17,.08); white-space: normal; vertical-align: top; }
	.prj-env th:last-child, .prj-env td:last-child { border-right: 0; }
	.prj-tag { display: inline-block; background: #f1f4f6; border-radius: 4px; padding: 0 5px; margin: 1px; font-size: 11.5px; }
	.prj-sk { display: inline-flex; gap: 4px; align-items: center; border: 1px solid #d5dbe0; background: #fff; border-radius: 6px; padding: 1px 7px; font-size: 11.5px; margin: 1px; }
	.prj-sk em { font-style: normal; color: #8a949c; font-size: 10.5px; }
	.prj-pv { display: flex; flex-wrap: wrap; gap: 3px; align-items: center; padding: 4px 12px; }
	.prj-pv .k { width: 78px; color: #8a949c; font-size: 11px; font-weight: 700; }
	/* 급여관리와 같은 목록: 체크 칩, 고정 머리글, 위 스크롤, 정렬, 두 줄 */
	.pl-chks { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; padding: 10px 14px; }
	.pl-scroll { max-height: 70vh; overflow: auto; }
	#dpHead th { position: sticky; top: 0; z-index: 3; background: #fafbfc; box-shadow: 0 1px 0 rgba(17,17,17,.1); }
	#dpHead th:last-child { right: 0; z-index: 4; }
	.pl-sort { background: none; border: 0; padding: 0 0 0 3px; color: #9aa4ac; font-size: 10px; cursor: pointer; }
	.pl-sort.on { color: #0b6e8a; }
	.pl-btn { border: 1px solid #b9dbe6; background: #f3fbfd; color: #0b6e8a; border-radius: 10px; padding: 0 7px; font-size: 11.5px; font-weight: 700; }
	.pl-btn.zero { opacity: .55; font-weight: 400; }
	#dpBody tr.dp-sub td { background: #fff8e8; font-size: 12px; }
	#dpBody tr.dp-sub td[data-c=EMP_TYPE_CD]::before { content: '└ '; color: #8a949c; }
	/* 단가 강조: 매출단가 연두, 계약단가 주황 */
	#dpHead th[data-c=SALE_PRICE], #dpBody td[data-c=SALE_PRICE] { background-color: #e7f6ec; color: #17692f; font-weight: 700; }
	#dpHead th[data-c=COST_PRICE], #dpBody td[data-c=COST_PRICE] { background-color: #fff1e2; color: #8a4b00; font-weight: 700; }
	#dpHead th[data-c=SALE_PRICE] { box-shadow: inset 0 3px 0 #2e9e57; } #dpHead th[data-c=COST_PRICE] { box-shadow: inset 0 3px 0 #d9822b; }
	/* 같은 달 다른 계약이 있는 사람: 왼쪽 주황 띠 + 성명 앞 작은 화살표 */
	#dpBody tr.dp-dup > td:first-child { box-shadow: inset 4px 0 0 #e0a800; }
	.pl-dup-arrow { border: 0; background: none; padding: 0 4px 0 0; color: #b07d00; font-size: 11px; cursor: pointer; }
	.pl-dup-arrow:focus { outline: 2px solid #16d5ff; border-radius: 3px; }
	.dp-sub-mark { color: #8a949c; }
	.pl-feed .it { border: 1px solid rgba(17,17,17,.1); border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; white-space: pre-wrap; }
	.pl-feed .who { font-size: 11.5px; color: #5f6b75; display: flex; gap: 8px; align-items: center; white-space: normal; }
</style>
<%@ include file="/WEB-INF/jsp/bo/deploy/deploy_common.jspf"%>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header d-flex align-items-center">
					<h3 class="card-title bTitle"><b>투입현황</b></h3>
					<div class="ml-auto d-flex align-items-center" style="gap:6px" id="ymBox">
						<label class="mb-0 small text-muted" for="ym">기준월</label>
						<button type="button" class="btn btn-sm btn-outline-secondary" id="prevYm" aria-label="이전 달">◀</button>
						<input type="month" id="ym" class="form-control form-control-sm" style="width:150px">
						<button type="button" class="btn btn-sm btn-outline-secondary" id="nextYm" aria-label="다음 달">▶</button>
					</div>
					<button type="button" class="btn btn-sm btn-primary ml-2" id="btnAdd"><i class="fas fa-plus"></i> 추가</button>
				</div>
				<div class="card-body">
					<div class="dp-views" id="views" role="tablist" aria-label="보기"></div>
					<div id="secretBox" class="mb-2" hidden><label class="dp-secret-chip"><input type="checkbox" class="dp-secret-chk" id="showSecret" checked> 🔒 시크릿 <b id="secretCnt"></b></label></div>
					<div class="cal-panel" id="altPanel" style="display:none"><div class="table-responsive" id="altView"></div></div>
					<div class="cal-panel" id="mainPanel">
						<div class="d-flex flex-wrap align-items-center pr-3">
							<div class="pl-chks" id="chks" role="group" aria-label="고용형태"></div>
							<div class="btn-group btn-group-sm ml-auto" role="group" aria-label="보기">
								<button type="button" class="btn btn-outline-secondary active" data-view="table">표</button>
								<button type="button" class="btn btn-outline-secondary" data-view="timeline">타임라인</button>
							</div>
						</div>
						<div class="dp-bar">
							<input type="search" id="keyword" class="form-control form-control-sm" style="width:180px" placeholder="성명·프로젝트·고객사" aria-label="검색">
							<select class="form-control form-control-sm dp-filter" style="width:auto" data-field="CLIENT_NM" aria-label="고객사"></select>
							<select class="form-control form-control-sm dp-filter" style="width:auto" data-field="SALE_PARTNER_NM" aria-label="매출처"></select>
							<select class="form-control form-control-sm dp-filter" style="width:auto" data-field="WORK_AREA" aria-label="근무지역"></select>
							<select class="form-control form-control-sm dp-filter" style="width:auto" data-field="GRADE_CD" aria-label="등급"></select>
							<div class="ml-auto"><button type="button" class="btn btn-sm btn-outline-secondary" id="btnResetCols">컬럼 순서 초기화</button></div>
						</div>
						<div id="tableView">
								<div class="pl-scroll" id="mainScroll">
								<table class="table table-sm cal-table mb-0">
									<thead id="dpHead"></thead>
									<tbody id="dpBody"></tbody>
								</table>
							</div>
							<div class="small text-muted px-3 py-2">
								기준월에 걸친 투입 건을 보여 줍니다. 한 달에 두 건 이상이면 최근 건이 윗줄, 나머지는 └ 줄입니다. 칸을 누르면 바로 고치고 수정이력에 남습니다(되돌리기는 ✎ 이력에서).
								머리글을 좌우로 끌면 순서가 바뀌고 이 계정에 저장됩니다(머리글에서 Alt+←/→ 도 됩니다). <b>추가</b>를 누르면 맨 아래에 입력 행이 생깁니다: Tab 이동, Enter 저장 후 다음 행, Esc 취소.
								<span class="dp-pay-only">매출단가 옆 ⓘ 를 누르면 그 투입 건의 월별 단가·급여 이력이 보입니다.</span>
							</div>
						</div>
						<div id="timelineView" class="table-responsive" style="display:none"></div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="detailModal" tabindex="-1" role="dialog" aria-labelledby="detailTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="detailTitle">투입 상세</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<form id="detailForm" onsubmit="saveDetail(); return false;">
					<input type="hidden" name="DEPLOY_SQ"><input type="hidden" name="STAFF_SQ">
					<div class="modal-body">
						<div class="form-row" id="detailFields"></div>
						<div class="custom-control custom-switch mb-2"><input type="checkbox" class="custom-control-input" id="dOffice"><label class="custom-control-label" for="dOffice">내근직 <span class="small text-muted">· 켜고 저장하면 투입 현황·대기·철수 임박에서 빠지고 내근직 탭에만 보입니다</span></label></div>
						<div class="custom-control custom-switch mb-1"><input type="checkbox" class="custom-control-input" id="dRest"><label class="custom-control-label" for="dRest">휴직 <span class="small text-muted">· 켜고 기간을 넣어 저장하면 휴직이 끝날 때까지 다른 탭에서 빠지고 휴직 탭에만 보입니다</span></label></div>
						<div class="d-none align-items-center mb-2 ml-4" style="gap:6px" id="dRestDates">
							<label class="mb-0 small text-muted" for="dRestFrom">휴직 기간</label>
							<input type="date" class="form-control form-control-sm" style="width:160px" id="dRestFrom" aria-label="휴직 시작일">
							<span>~</span>
							<input type="date" class="form-control form-control-sm" style="width:160px" id="dRestTo" aria-label="휴직 종료일(비우면 미정)">
							<span class="small text-muted">종료일을 비우면 미정</span>
						</div>
						<div class="hr-section">투입 이력 <span class="small text-muted font-weight-normal dp-pay-only">기간 옆 ⓘ 를 누르면 그 건의 월별 단가·급여가 보입니다</span></div>
						<table class="table table-sm cal-table mb-0">
							<thead><tr><th>기간</th><th>형태</th><th>고객사</th><th>프로젝트</th><th>지역</th><th>등급</th></tr></thead>
							<tbody id="histBody"></tbody>
						</table>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-sm btn-outline-danger mr-auto" onclick="deleteDetail();">삭제</button>
						<button type="button" class="btn btn-sm btn-outline-warning" onclick="leaveDeploy();">철수 처리</button>
						<button type="button" class="btn btn-sm btn-outline-secondary" onclick="nextDeploy();">철수 후 다음 투입 등록</button>
						<button type="submit" class="btn btn-sm btn-primary">저장</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>

	<script>
	var COLS = [['STAFF_NM', '성명'], ['EMP_TYPE_CD', '형태'], ['HOME_AREA', '거주지역'], ['WORK_AREA', '근무지역'], ['SALE_PARTNER_NM', '매출처'], ['BUY_PARTNER_NM', '매입처'], ['SALE_PRICE', '매출단가', true], ['COST_PRICE', '계약단가', true],
		['CLIENT_NM', '고객사'], ['PRJ_NM', '프로젝트'],['GRADE_CD', '등급'], ['START_DT', '투입일'], ['END_DT', '철수일'], ['REMAIN', '남은 기간'], ['TENURE', '근속'], ['PRJ', '프로젝트 이력'],
		['MEMOS', '메모'], ['HIST', '이력']];
	var data = null, order = [], view = 'table', drag = null, page = 'ACTIVE', prjCache = {};
	// 관리자 홈 바로가기: ?page=IDLE(대기 현황) · ENDING(철수 임박)
	var pageParam = /[?&]page=(IDLE|ENDING|OFFICE|REST)\b/.exec(location.search);
	if (pageParam) page = pageParam[1];
	// 기준월과 체크 칩(급여관리와 같은 구분). [키, 이름, 고용형태들]
	var ym = moment().format('YYYY-MM'), sortKey = 'REMAIN', sortDir = 1;
	// 고용형태 공통코드(HR_EMP_TYPE) 순서·이름대로 칩 하나씩. 코드에 없는 형태는 '코드 없음'
	var CHIPS = hrAllCodes('HR_EMP_TYPE').map(function(c) { return [c.CD, c.NM, [c.CD]]; }).concat([['_NONE', '코드 없음', []]]), checked = {};
	CHIPS.forEach(function(c) { checked[c[0]] = true; });
	function chipOf(type) { var c = CHIPS.filter(function(c) { return c[2].indexOf(type) >= 0; })[0]; return c ? c[0] : '_NONE'; }
	// 칸 바로 수정: 화면 칸 → [저장 칸, 입력 종류]
	var EDIT = { EMP_TYPE_CD: ['EMP_TYPE_CD', { code: 'HR_EMP_TYPE' }], GRADE_CD: ['GRADE_CD', { code: 'HR_DEPLOY_GRADE' }], SALE_PARTNER_NM: ['SALE_PARTNER_SQ', 'SALE_YN'], BUY_PARTNER_NM: ['BUY_PARTNER_SQ', 'BUY_YN'],
		CLIENT_NM: ['CLIENT_NM'], PRJ_NM: ['PRJ_NM'], WORK_AREA: ['WORK_AREA'], START_DT: ['START_DT', 'date'], END_DT: ['END_DT', 'date'], SALE_PRICE: ['SALE_PRICE'], COST_PRICE: ['COST_PRICE'] };
	var FIELD_NM = { EMP_TYPE_CD: '형태', SALE_PARTNER_SQ: '매출처', BUY_PARTNER_SQ: '매입처', CLIENT_NM: '고객사', PRJ_NM: '프로젝트', WORK_AREA: '근무지역', GRADE_CD: '등급', START_DT: '투입일', END_DT: '철수일',
		PROB_END_DT: '수습해제일', SALE_PRICE: '매출단가', COST_PRICE: '계약단가', MEMO: '메모', OFFICE_YN: '내근직', REST_FROM_DT: '휴직 시작일', REST_TO_DT: '휴직 종료일', NEW: '등록', DELETE: '삭제' };
	var today = moment().startOf('day'), YM = moment().format('YYYY-MM');
	var SIDO = { '서울특별시': '서울', '서울시': '서울', '부산광역시': '부산', '대구광역시': '대구', '인천광역시': '인천', '광주광역시': '광주', '대전광역시': '대전', '울산광역시': '울산', '세종특별자치시': '세종',
		'경기도': '경기', '강원도': '강원', '강원특별자치도': '강원', '충청북도': '충북', '충청남도': '충남', '전라북도': '전북', '전북특별자치도': '전북', '전라남도': '전남', '경상북도': '경북', '경상남도': '경남', '제주특별자치도': '제주' };

	$(function() {
		// 매출·매입 현황의 팝업에서 열 때: ?open=투입번호(상세) · ?add=1(투입 추가) · ?view=timeline
		load(function() {
			var q = location.search, o = /[?&]open=(\d+)\b/.exec(q), x = o && data.all.filter(function(d) { return d.DEPLOY_SQ === +o[1]; })[0];
			if (/[?&]view=timeline\b/.test(q)) $('[data-view=timeline]').click();
			if (x) openDetail(x); else if (/[?&]add=1\b/.test(q)) $('#btnAdd').click();
		});
		$('#views').on('click', 'button', function() { page = $(this).attr('data-page'); render(); });
		$('#showSecret').on('change', function() { render(); });
		$('#keyword').on('input', render);
		$(document).on('change', '.dp-filter', render);
		$('[data-view]').on('click', function() { view = $(this).data('view'); $('[data-view]').removeClass('active'); $(this).addClass('active'); render(); });
		$('#btnAdd').on('click', function() { if (view !== 'table') $('[data-view=table]').click(); addRow(true); });
		$('#btnResetCols').on('click', function() { saveOrder(''); order = defaultOrder(); arrangeAll(); });
		$('#ym').val(ym).on('change', function() { if (this.value) { ym = this.value; loadPay(render); } });
		$('#prevYm, #nextYm').on('click', function() { ym = moment(ym + '-01').add(this.id === 'prevYm' ? -1 : 1, 'months').format('YYYY-MM'); $('#ym').val(ym); loadPay(render); });
	});

	function load(after) {
		hrPost('/admin/deploy/deployListData.do', {}, function(res) {
			data = res.data;
			hrSetCodes(data.codes);
			var saved = (data.columns || []).filter(function(k) { return visibleCols().some(function(c) { return c[0] === k; }); });
			order = saved.concat(defaultOrder().filter(function(k) { return saved.indexOf(k) < 0; }));
			$('.dp-pay-only').toggle(!!data.canPay);
			$('#staffList').remove();
			var $dl = $('<datalist id="staffList">').appendTo('body');
			data.staff.forEach(function(s) { $dl.append($('<option>').val(staffLabel(s))); });
			// 시크릿 계정에게만 서버가 secretViewer 와 시크릿 행(SECRET)을 준다
			$('#secretBox').prop('hidden', !data.secretViewer);
			$('#secretCnt').text(data.staff.filter(function(s) { return s.SECRET; }).length);
			fillFilters();
			loadPay(function() { render(); if (after) after(); });
		});
	}

	// ── 급여 칸 묶음: 기준월 급여(급여관리와 같은 데이터·같은 시크릿 규칙)를 사람 단위로 표 오른쪽에 붙인다. 급여 권한이 있을 때만 ──
	var pay = { by: {}, closed: false }, payOpen = false, payBand = {};
	try { payOpen = localStorage.getItem('dpPay') === 'on'; } catch (e) {}
	// 급여관리와 같은 칸. 정산은 합계만(칸별 정산은 급여 상세에서)
	var PAY_ALLOW = [['MEAL_AMT', '식대'], ['RESEARCH_AMT', '연구비'], ['DRIVE_AMT', '운전보조'], ['CHILD_AMT', '자녀보육'], ['BONUS_AMT', '상여'], ['FUEL_AMT', '유류비']];
	var PAY_DED = [['NP_AMT', '국민연금'], ['HI_AMT', '건강보험'], ['LTC_AMT', '장기요양'], ['EI_AMT', '고용보험'], ['ACC_AMT', '산재'], ['IT_AMT', '소득세'], ['LIT_AMT', '지방소득세'], ['_SETTLE', '정산'], ['MUTUAL_AMT', '상조회비'], ['ETC_DED', '기타공제']];
	var PAY_PL = [['REAL_SALE', '실매출'], ['BUY', '기타'], ['FEE', '수수료'], ['COMPANY', '회사부담']];
	var PAY_OWN = ['REGULAR', 'PROBATION', 'SPECIAL', 'BIZ', 'EMP_INS'];
	function loadPay(done) {
		var want = ym;
		if (!data.canPay) return done();
		hrPost('/admin/pay/monthData.do', { YM: want }, function(res) {
			if (want !== ym) return; // 그사이 달을 또 바꿨으면 나중 응답이 그린다
			pay = { by: {}, closed: !!res.result.closed };
			res.result.rows.forEach(function(r) { pay.by[r.STAFF_SQ] = r; });
			done();
		}, function() { pay = { by: {}, closed: false }; done(); });
	}
	// [칸 키, 머리글, 칸 색, 머리글 띠(수당·공제·손익 펼치기)]
	function payCols() {
		if (!data.canPay) return [];
		if (!payOpen) return [['P_TOG'], ['P_NET', 'Σ 실지급'], ['P_PROFIT', 'Σ 영업이익'], ['P_FLAG', '확인'], ['P_LINK', '메모·이력']];
		var c = [['P_TOG'], ['P_BASE_AMT', '기본'], ['P_DAYS', '근무기간']];
		if (payBand.a) PAY_ALLOW.forEach(function(x) { c.push(['P_' + x[0], x[1], 'a']); });
		c.push(['P_PAY_TOTAL', 'Σ 지급계', 'a', ['a', '수당']]);
		if (payBand.d) PAY_DED.forEach(function(x) { c.push(['P_' + x[0], x[1], 'd']); });
		c.push(['P_DED_TOTAL', 'Σ 공제계', 'd', ['d', '공제']], ['P_NET', 'Σ 실지급'], ['P_DELTA', 'Σ 전월대비']);
		if (payBand.p) PAY_PL.forEach(function(x) { c.push(['P_' + x[0], x[1], 'p']); });
		return c.concat([['P_PROFIT', 'Σ 영업이익', 'p', ['p', '손익']], ['P_FLAG', '확인 사항'], ['P_LINK', '메모·이력']]);
	}
	function payKeys() { return payCols().map(function(c) { return c[0]; }); }
	function payUrl(sq, tab) { return '/admin/pay/openPayList.do?ym=' + ym + '&open=' + sq + (tab ? '&tab=' + tab : ''); }
	function payHeads() {
		return payCols().map(function(c) {
			var $th = $('<th class="dp-pay-h">').attr('data-c', c[0]).toggleClass('dp-num', /^P_(?!DAYS|FLAG|LINK|TOG)/.test(c[0]));
			if (c[0] === 'P_TOG') return $th.append($('<button type="button" class="dp-pay-tog">').attr('aria-expanded', payOpen)
				.text('급여 · ' + Number(ym.substring(5)) + '월 ' + (pay.closed ? '마감' : '작성중') + (payOpen ? ' ▾ 접기' : ' ▸ 펼치기'))
				.on('click', function() { payOpen = !payOpen; try { localStorage.setItem('dpPay', payOpen ? 'on' : 'off'); } catch (e) {} dpHide(); render(); }));
			$th.text(c[1]);
			if (c[3]) $th.append($('<button type="button" class="dp-pay-band">').addClass(c[3][0]).attr('aria-expanded', !!payBand[c[3][0]])
				.text(c[3][1] + (payBand[c[3][0]] ? ' ▾' : ' ▸')).on('click', function() { payBand[c[3][0]] = !payBand[c[3][0]]; render(); }));
			return $th;
		});
	}
	// 사람 한 명의 급여 칸들. 급여 행이 없는 사람(그 달 급여 없음)은 빈 칸
	function payCells(sq) {
		var r = pay.by[sq];
		return payCols().map(function(c) {
			var k = c[0], f = k.substring(2), $td = $('<td class="dp-pay">').attr('data-c', k).addClass(c[2] || '');
			if (!r) return $td;
			if (k === 'P_TOG') return $td.append($('<a class="pl-btn" target="_blank" rel="noopener">').attr({ href: payUrl(sq), 'aria-label': r.STAFF_NM + ' 급여 상세(새 탭)', title: '급여 상세' }).text('💰'));
			if (k === 'P_DAYS') { var d = r.DETAILS.filter(function(x) { return PAY_OWN.indexOf(x.DEPLOY_TYPE) >= 0; }).reduce(function(s, x) { return s + Number(x.WORK_DAYS || 0); }, 0); return $td.addClass('dp-num').text(d ? d + '일' : '대기'); }
			if (k === 'P_DELTA') return $td.addClass('dp-num').text(r.DELTA_PCT === undefined ? '' : (r.DELTA_PCT > 0 ? '+' : '') + r.DELTA_PCT + '%').toggleClass('text-danger', Math.abs(r.DELTA_PCT || 0) >= 10);
			if (k === 'P_PROFIT') return r.OFFICE ? $td.addClass('dp-num text-muted').attr('title', '내근직은 영업이익에서 뺍니다').text('내근 제외') : $td.addClass('dp-num font-weight-bold').toggleClass('text-danger', Number(r.PROFIT) < 0).text(dpWon(r.PROFIT));
			if (k === 'P_FLAG') return payFlags($td, r);
			if (k === 'P_LINK') return $td.append($('<a class="pl-btn" target="_blank" rel="noopener">').toggleClass('zero', !Number(r.MEMO_CNT)).attr({ href: payUrl(sq, 3), 'aria-label': r.STAFF_NM + ' 급여 메모 ' + Number(r.MEMO_CNT || 0) + '건(새 탭)' }).text('💬' + (Number(r.MEMO_CNT) ? ' ' + r.MEMO_CNT : '')))
				.append(' ').append($('<a class="pl-btn" target="_blank" rel="noopener">').toggleClass('zero', !Number(r.CHG_CNT)).attr({ href: payUrl(sq, 4), 'aria-label': r.STAFF_NM + ' 급여 수정이력 ' + Number(r.CHG_CNT || 0) + '건(새 탭)' }).text('✎' + (Number(r.CHG_CNT) ? ' ' + r.CHG_CNT : '')));
			$td.addClass('dp-num');
			if (f === '_SETTLE') return $td.text(dpWon(['NP_SETTLE', 'HI_SETTLE', 'EI_SETTLE', 'LTC_SETTLE', 'IT_SETTLE', 'LIT_SETTLE'].reduce(function(s, x) { return s + Number(r[x] || 0); }, 0))).attr('title', '정산 합계 · 칸별 정산은 급여 상세에서');
			if (/TOTAL$|^NET$/.test(f)) $td.addClass('font-weight-bold');
			// 급여관리처럼 기본·수당·공제 칸은 눌러 바로 고친다(수정이력 저장). 마감된 달은 보기만
			var editable = !pay.closed && (f === 'BASE_AMT' || PAY_ALLOW.concat(PAY_DED).some(function(x) { return x[0] === f; }));
			if (!editable) return $td.text(dpWon(r[f]));
			return hrEditable($td.addClass('edit'), { url: '/admin/pay/saveFieldData.do', key: { YM: ym, STAFF_SQ: sq }, field: f, label: r.STAFF_NM + ' ' + (c[1] || f),
				show: function() { return dpWon(r[f]); }, value: function() { return r[f]; }, saved: function() { loadPay(render); } });
		});
	}
	// 확인 사항: 접으면 건수(올리면 목록), 펼치면 급여관리와 같은 칩과 ✕
	function payFlags($td, r) {
		if (!r.FLAGS.length) return $td;
		if (!payOpen) {
			var $n = $('<span class="dp-pill" tabindex="0">').addClass(r.FLAGS.some(function(f) { return /공제없음|대장차/.test(f.K); }) ? 'bad' : 'warn').text(r.FLAGS.length).attr('aria-label', '확인 사항 ' + r.FLAGS.map(function(f) { return f.K; }).join(', '));
			dpHover($n, $n, function() { return '<div class="dp-card sm"><div class="dp-card-top">확인 사항 ' + r.FLAGS.length + '건</div><div class="dp-sec">' + r.FLAGS.map(function(f) { return dpLine(f.K, '') + '<div><span class="dp-mute" style="white-space:normal">' + dpEsc(f.D) + '</span><span></span></div>'; }).join('') + '</div></div>'; });
			return $td.append($n);
		}
		return $td.append(r.FLAGS.map(function(f) {
			var $p = dpFlag(f), bonus = f.K === '상여', what = bonus ? '이번 달 상여 제외' : '확인 완료(숨김)';
			if (!pay.closed) $p.append($('<button type="button" class="dp-pay-x">').attr({ title: what, 'aria-label': r.STAFF_NM + ' ' + f.K + ' ' + what }).text('✕').on('click', function(e) {
				e.stopPropagation(); dpHide();
				function send() { hrPost('/admin/pay/ackData.do', { YM: ym, STAFF_SQ: r.STAFF_SQ, FLAG_K: f.K }, function() { loadPay(render); }); }
				if (!bonus) return send();
				bootbox.confirm(r.STAFF_NM + '의 ' + dpYmLabel(ym) + ' 상여 ' + dpWon(r.BONUS_AMT) + '원을 뺄까요? 수정이력과 급여 상세의 상여 탭에 제외로 남습니다.', function(ok) { if (ok) send(); });
			}));
			return $p;
		}));
	}

	function visibleCols() { return COLS.filter(function(c) { return !c[2] || data.canPay; }); }
	function defaultOrder() { return visibleCols().map(function(c) { return c[0]; }); }
	function colLabel(k) { var c = COLS.filter(function(x) { return x[0] === k; })[0]; return c[1] + (c[2] ? ' 🔒' : ''); }
	function staffLabel(s) { return s.STAFF_NM + (s.JOIN_DT ? ' (' + s.JOIN_DT + ')' : ''); }
	function typeName(cd) { return hrCodeName('HR_EMP_TYPE', cd); }

	function remain(r) {
		if (r.STATE === 'WAIT') return { text: '대기 ' + today.diff(moment(r.END_DT), 'days') + '일', tone: 'warn', days: -1 };
		if (r.STATE === 'FUTURE' || moment(r.START_DT).isAfter(today)) return { text: moment(r.START_DT).diff(today, 'days') + '일 뒤 투입', tone: 'rent', days: 9998 };
		if (!r.END_DT) return { text: '미정', tone: '', days: 9999 };
		if (moment(r.END_DT).isBefore(today)) return { text: moment(r.END_DT).format('M/D') + ' 철수', tone: '', days: -2 };
		var d = moment(r.END_DT).diff(today, 'days');
		return { text: 'D-' + d, tone: d <= 14 ? 'bad' : d <= 30 ? 'warn' : '', days: d };
	}

	function tenure(joinDt) {
		var from = moment(joinDt, 'YYYY-MM-DD', true);
		if (!from.isValid() || today.isBefore(from)) return '';
		var m = today.diff(from, 'months');
		return (m >= 12 ? Math.floor(m / 12) + '년 ' : '') + (m % 12) + '개월';
	}

	function fillFilters() {
		var labels = { CLIENT_NM: '고객사', SALE_PARTNER_NM: '매출처', WORK_AREA: '지역', GRADE_CD: '등급' };
		$('.dp-filter').each(function() {
			var $s = $(this), f = $s.data('field'), keep = $s.val();
			var vals = data.all.map(function(r) { return r[f]; }).filter(Boolean).filter(function(v, i, a) { return a.indexOf(v) === i; }).sort();
			$s.empty().append($('<option value="">').text(labels[f] + ' 전체'));
			vals.forEach(function(v) { $s.append($('<option>').val(v).text(v)); });
			$s.val(keep || '');
		});
	}

	function showSecret(r) { return !r.SECRET || $('#showSecret').prop('checked'); }
	function secretFirst(a, b) { return (b.SECRET ? 1 : 0) - (a.SECRET ? 1 : 0); }

	function filtered() {
		var kw = $.trim($('#keyword').val()).toLowerCase();
		return data.current.filter(function(r) {
			if (r.STATE !== 'ACTIVE' || !showSecret(r) || away(r.STAFF_SQ)) return false;
			return matches(r, kw);
		}).sort(function(a, b) { return secretFirst(a, b) || remain(a).days - remain(b).days || String(a.STAFF_NM).localeCompare(String(b.STAFF_NM), 'ko'); });
	}

	function matches(r, kw, anyChip) {
		if (!anyChip && !checked[chipOf(r.EMP_TYPE_CD)]) return false;
		var ok = true;
		$('.dp-filter').each(function() { if ($(this).val() && r[$(this).data('field')] !== $(this).val()) ok = false; });
		return ok && (!kw || [r.STAFF_NM, r.PRJ_NM, r.CLIENT_NM].some(function(v) { return v && String(v).toLowerCase().indexOf(kw) >= 0; }));
	}

	// 기준월에 걸친 투입을 사람별로 묶는다. 최근 건이 윗줄(top), 나머지는 └ 줄
	function monthGroups(anyChip) {
		var first = moment(ym + '-01'), last = first.clone().endOf('month'), kw = $.trim($('#keyword').val()).toLowerCase(), by = {}, keys = [];
		data.all.forEach(function(x) {
			if (moment(x.START_DT).isAfter(last) || (x.END_DT && moment(x.END_DT).isBefore(first)) || !showSecret(x) || away(x.STAFF_SQ)) return;
			if (!by[x.STAFF_SQ]) { by[x.STAFF_SQ] = []; keys.push(x.STAFF_SQ); }
			by[x.STAFF_SQ].push(x);
		});
		return keys.map(function(k) {
			var rows = by[k].slice().sort(function(a, b) { return b.START_DT.localeCompare(a.START_DT); });
			// 수습도 정규직이다. 같은 달 수습·정규 건이 함께 있으면 정규 건 한 줄만 보인다(수습 D-n 은 형태 칸에)
			if (dpProbReg(rows.map(function(x) { return x.EMP_TYPE_CD; }))) rows = rows.filter(function(x) { return x.EMP_TYPE_CD !== 'PROBATION'; });
			return { top: rows[0], rows: rows };
		}).filter(function(g) { return g.rows.some(function(x) { return matches(x, kw, anyChip); }); });
	}

	function counts(list) { var m = {}; (list || []).forEach(function(c) { m[c.STAFF_SQ] = Number(c.CNT); }); return m; }

	var SORT = {
		REMAIN: function(g) { return remain(g.top).days; }, TENURE: function(g) { return g.top.JOIN_DT || ''; },
		HOME_AREA: function(g) { return area(g.top.HOME_ADDR); }, EMP_TYPE_CD: function(g) { return typeLabel(g.top); },
		MEMOS: function(g) { return counts(data.memoCounts)[g.top.STAFF_SQ] || 0; }, HIST: function(g) { return counts(data.chgCounts)[g.top.STAFF_SQ] || 0; },
		PRJ: function(g) { return staffOf(g.top.STAFF_SQ).PRJ_CNT || 0; }
	};
	function sortVal(g) { var v = SORT[sortKey] ? SORT[sortKey](g) : g.top[sortKey]; return v === undefined || v === null ? '' : v; }
	function sortGroups(list) {
		return list.sort(function(a, b) {
			var x = sortVal(a), y = sortVal(b);
			return secretFirst(a.top, b.top) || sortDir * (typeof x === 'number' && typeof y === 'number' ? x - y : String(x).localeCompare(String(y), 'ko', { numeric: true }))
				|| String(a.top.STAFF_NM).localeCompare(String(b.top.STAFF_NM), 'ko');
		});
	}

	function renderChips(groups) {
		boChips('#chks', CHIPS.map(function(c) {
			var n = groups.filter(function(g) { return g.rows.some(function(x) { return chipOf(x.EMP_TYPE_CD) === c[0]; }); }).length;
			return { k: c[0], name: c[1], n: n, hide: c[0] === '_NONE' && !n };
		}), checked, render);
	}

	// ── 탭: 투입 현황 · 대기 현황 · 철수 임박 ──

	function staffOf(sq) { return data.staff.filter(function(s) { return s.STAFF_SQ === sq; })[0] || {}; }
	function depsOf(sq) { return data.all.filter(function(x) { return x.STAFF_SQ === sq; }); }
	function isActive(x) { return !moment(x.START_DT).isAfter(today) && (!x.END_DT || !moment(x.END_DT).isBefore(today)); }

	// 내근직: 내근직으로 켠 투입 건이 하나라도 있는 사람. 투입 현황·대기·철수 임박에서 빠지고 내근직 탭에만 보인다
	function isOffice(sq) { return data.all.some(function(x) { return x.STAFF_SQ === sq && x.OFFICE_YN === 'Y'; }); }
	// 휴직: 휴직 기간이 끝나지 않은(예정 포함) 투입 건. 있으면 다른 탭에서 모두 빠지고 휴직 탭에만 보인다. 종료일이 지나면 원래 목록으로
	function restOf(sq) { return data.all.filter(function(x) { return x.STAFF_SQ === sq && x.REST_FROM_DT && (!x.REST_TO_DT || !moment(x.REST_TO_DT).isBefore(today)); }).pop(); }
	function away(sq) { return isOffice(sq) || !!restOf(sq); }
	function restList() {
		return data.staff.filter(function(s) { return showSecret(s) && restOf(s.STAFF_SQ); }).map(function(s) { return { s: s, x: restOf(s.STAFF_SQ) }; })
			.sort(function(a, b) { return secretFirst(a.s, b.s) || String(a.x.REST_FROM_DT).localeCompare(String(b.x.REST_FROM_DT)); });
	}
	// 재직자 가운데 내근직. 기간이 끝난 건이어도 보인다. 시크릿 규칙(칩·맨 위 고정)은 다른 탭과 같다
	function officeList() {
		return data.staff.filter(function(s) { return showSecret(s) && isOffice(s.STAFF_SQ) && !restOf(s.STAFF_SQ); }).map(function(s) {
			return { s: s, x: depsOf(s.STAFF_SQ).filter(function(x) { return x.OFFICE_YN === 'Y'; }).pop() };
		}).sort(function(a, b) { return secretFirst(a.s, b.s) || String(a.s.STAFF_NM).localeCompare(String(b.s.STAFF_NM), 'ko'); });
	}

	// 재직인데 진행 중인 투입이 없는 사람. 철수일이 오늘인 건은 끝난 것으로 본다(철수 처리하면 바로 대기로). 외부업체·내근직은 뺀다
	function idleList() {
		function goingOn(x) { return !moment(x.START_DT).isAfter(today) && (!x.END_DT || moment(x.END_DT).isAfter(today)); }
		return data.staff.filter(function(s) { return showSecret(s) && !away(s.STAFF_SQ); }).map(function(s) {
			var deps = depsOf(s.STAFF_SQ);
			if (deps.some(goingOn)) return null;
			var last = deps[deps.length - 1];
			if (last && /^EXTERNAL/.test(last.EMP_TYPE_CD)) return null;
			var future = deps.filter(function(x) { return moment(x.START_DT).isAfter(today); })[0];
			var past = deps.filter(function(x) { return x.END_DT && !moment(x.END_DT).isAfter(today); }).pop();
			var kind = future ? 'FUTURE' : past ? 'WAIT' : 'NONE';
			var since = kind === 'WAIT' ? moment(past.END_DT).add(1, 'days') : moment(s.JOIN_DT, 'YYYY-MM-DD', true);
			return { s: s, kind: kind, future: future, last: past || last, days: since.isValid() ? today.diff(since, 'days') : 0 };
		}).filter(Boolean).sort(function(a, b) { return secretFirst(a.s, b.s) || (a.kind === 'FUTURE') - (b.kind === 'FUTURE') || b.days - a.days; });
	}

	// 철수일이 이번 달 또는 다음 달인 진행 중 투입
	function endingList() {
		var limit = moment().add(1, 'month').endOf('month');
		return data.all.filter(function(x) { return showSecret(x) && !away(x.STAFF_SQ) && isActive(x) && x.END_DT && !moment(x.END_DT).isAfter(limit); }).map(function(x) {
			var next = depsOf(x.STAFF_SQ).filter(function(y) { return y.DEPLOY_SQ !== x.DEPLOY_SQ && y.START_DT > x.END_DT; })[0];
			return { x: x, next: next };
		}).sort(function(a, b) { return secretFirst(a.x, b.x) || a.x.END_DT.localeCompare(b.x.END_DT); });
	}

	function area(addr) {
		var t = $.trim(addr || '').split(/\s+/);
		if (!t[0]) return '';
		return (SIDO[t[0]] || t[0].replace(/(특별시|광역시|특별자치시|특별자치도|도)$/, '')) + (t[1] ? ' ' + t[1].replace(/[,()]/g, '') : '');
	}
	function farFrom(home, work) {
		var h = area(home).split(' ')[0], w = $.trim(work || '').split(/\s+/)[0];
		w = SIDO[w] || w;
		var known = $.map(SIDO, function(v) { return v; });
		return h && known.indexOf(w) >= 0 && h !== w;
	}

	function renderViews(idle, ending, office, rest) {
		var active = data.current.filter(function(r) { return r.STATE === 'ACTIVE' && showSecret(r) && !away(r.STAFF_SQ); }).length;
		$('#views').empty().append([['ACTIVE', '투입 현황', active, ''], ['IDLE', '대기 현황', idle.length, 'warn'], ['ENDING', '철수 임박', ending.length, 'bad'], ['OFFICE', '내근직', office.length, ''], ['REST', '휴직', rest.length, '']].map(function(v) {
			return $('<button type="button" role="tab">').addClass(v[3]).attr({ 'data-page': v[0], 'aria-selected': page === v[0] }).text(v[1]).append($('<b>').text(v[2]));
		}));
	}

	function render() {
		var idle = idleList(), ending = endingList(), office = officeList(), rest = restList(), showYm = page === 'ACTIVE' && view === 'table';
		renderViews(idle, ending, office, rest);
		$('#ymBox').toggleClass('d-flex', showYm).toggleClass('d-none', !showYm);
		$('#mainPanel').toggle(page === 'ACTIVE');
		$('#altPanel').toggle(page !== 'ACTIVE');
		$('#btnAdd').toggle(page === 'ACTIVE');
		if (page === 'IDLE') return renderIdle(idle);
		if (page === 'ENDING') return renderEnding(ending);
		if (page === 'OFFICE') return renderOffice(office);
		if (page === 'REST') return renderRest(rest);
		renderChips(monthGroups(true));
		$('#tableView').toggle(view === 'table');
		$('#timelineView').toggle(view === 'timeline');
		if (view === 'timeline') renderTimeline(filtered()); else renderTable(sortGroups(monthGroups()));
	}

	// ── 표 ──

	function renderTable(groups) {
		var $h = $('<tr>');
		visibleCols().forEach(function(c) {
			var on = sortKey === c[0];
			var $th = $('<th>').attr('data-c', c[0]).toggleClass('dp-num', !!c[2]).text(colLabel(c[0]))
				.append($('<button type="button" class="pl-sort">').toggleClass('on', on).attr('aria-label', c[1] + ' 정렬').text(on ? (sortDir > 0 ? '▲' : '▼') : '↕')
					.on('click', function(e) { e.stopPropagation(); if (sortKey === c[0]) sortDir = -sortDir; else { sortKey = c[0]; sortDir = 1; } render(); }));
			$h.append($th);
		});
		$h.append(payHeads()).append($('<th data-c="_ACT">').append('<span class="sr-only">작업</span>'));
		$('#dpHead').empty().append($h);
		bindDrag();
		var $b = $('#dpBody').empty();
		if (!groups.length) boEmpty($b, moment(ym + '-01').format('YYYY년 M월') + '에 걸친 투입이 없습니다. 체크나 기준월을 바꿔 보세요.');
		groups.forEach(function(g) { var open = isOpen(g); g.rows.forEach(function(r, i) { if (!i || open) $b.append(viewRow(r, g, i > 0).toggleClass('dp-dup', g.rows.length > 1)); }); });
		arrangeAll();
	}

	// 사람 단위 칸(성명·근속·거주지역·이력 등)은 윗줄에만, 계약 단위 칸은 줄마다
	var PERSON = ['STAFF_NM', 'TENURE', 'HOME_AREA', 'PRJ', 'MEMOS', 'HIST'];

	// 정규·수습은 '정규'로, 입사일부터 3개월(수습 기간) 안이면 '정규(수습 D-n)'
	function typeLabel(r) {
		var t = r.EMP_TYPE_CD;
		if (t !== 'REGULAR' && t !== 'PROBATION') return typeName(t);
		var join = moment(r.JOIN_DT, 'YYYY-MM-DD', true), d = join.isValid() ? join.add(3, 'months').diff(today, 'days') : -1;
		return typeName('REGULAR') + (d > 0 ? '(수습 D-' + d + ')' : '');
	}

	function viewRow(r, g, child) {
		var $tr = $('<tr>').toggleClass('dp-secret', !!r.SECRET).toggleClass('dp-sub', !!child), rm = remain(r);
		// 급여관리처럼: 사람 단위 칸은 윗줄 하나로 합치고(rowspan), └ 줄에는 계약 칸만 둔다
		var span = !child && isOpen(g) ? g.rows.length : 1;
		visibleCols().forEach(function(c) {
			var $td = $('<td>').attr('data-c', c[0]), v = r[c[0]];
			if (PERSON.indexOf(c[0]) >= 0) { if (child) return; $td.attr('rowspan', span); }
			if (c[0] === 'REMAIN' && child) $td.append($('<span class="dp-pill">').addClass(rm.tone).text(rm.text)).append(dpInfoBtn(r.STAFF_NM + ' 투입 상세', function() { openDetail(r); }));
			else if (c[0] === 'STAFF_NM') $td.append(dupArrow(g)).append(r.SECRET ? $('<span title="시크릿">').text('🔒 ') : '').append($('<button type="button" class="dp-name">').text(r.STAFF_NM).on('click', function() { openDetail(r); }));
			else if (c[0] === 'MEMOS') $td.append(countBtn('💬', counts(data.memoCounts)[r.STAFF_SQ], r.STAFF_NM + ' 메모', function() { memoPopup(r); }));
			else if (c[0] === 'HIST') $td.append(countBtn('✎', counts(data.chgCounts)[r.STAFF_SQ], r.STAFF_NM + ' 수정이력', function() { historyPopup(r); }));
			else if (EDIT[c[0]]) editCell($td, r, c);
			else if (c[0] === 'EMP_TYPE_CD') $td.text(typeName(v));
			else if (c[2]) $td.addClass('dp-num').text(v ? dpWon(v) : '').append(c[0] === 'SALE_PRICE' ? dpInfoBtn(r.STAFF_NM + ' 단가·급여 이력', function() { payHistory(r); }) : '');
			else if (c[0] === 'REMAIN') $td.append($('<span class="dp-pill">').addClass(rm.tone).text(rm.text));
			else if (c[0] === 'TENURE') $td.text(tenure(r.JOIN_DT));
			else if (c[0] === 'HOME_AREA') $td.text(area(r.HOME_ADDR));
			else if (c[0] === 'WORK_AREA') $td.text(v || '').append(farFrom(r.HOME_ADDR, v) ? $('<span class="dp-far">원거리</span>') : '');
			else if (c[0] === 'PRJ') $td.append(prjBtn(r.STAFF_SQ, r.STAFF_NM));
			else if (c[0] === 'CLIENT_NM' && r.STATE === 'WAIT') $td.addClass('dp-mute').text('—');
			else $td.text(v || '');
			$tr.append($td);
		});
		// 급여는 사람 단위: 윗줄에만 두고 └ 줄까지 합친다
		if (!child) payCells(r.STAFF_SQ).forEach(function($td) { $tr.append($td.attr('rowspan', span)); });
		$tr.append($('<td data-c="_ACT">'));
		return $tr;
	}

	// 고객사 직접계약 입력·수정 팝업: 종류(공통코드 HR_CLIENT_DIRECT)와 금액, 우리 매출 계산 줄
	function directPopup(r) {
		var sale = Number(r.SALE_PRICE || 0), $cd = $('<select class="form-control form-control-sm" id="dirCd">').append('<option value="">종류 선택</option>');
		hrAllCodes('HR_CLIENT_DIRECT').forEach(function(c) { $cd.append($('<option>').val(c.CD).text(c.NM)); });
		var $amt = $('<input class="form-control form-control-sm text-right" id="dirAmt" inputmode="numeric">').val(r.CLIENT_DIRECT_AMT ? Number(r.CLIENT_DIRECT_AMT).toLocaleString('ko-KR') : '');
		var $calc = $('<div class="small p-2 mt-2" style="background:#f6f8fa;border-radius:6px">');
		function amt() { return Number(String($amt.val()).replace(/[^0-9]/g, '')) || 0; }
		function paint() { $calc.html('매출단가 ' + dpWon(sale) + ' − 직접계약 ' + dpWon(amt()) + ' = <b>우리 매출 ' + dpWon(sale - amt()) + '</b>'); }
		$cd.val(r.CLIENT_DIRECT_CD || '');
		$amt.on('input', paint);
		function send(cd, a) { hrPost('/admin/deploy/saveDirectData.do', { DEPLOY_SQ: r.DEPLOY_SQ, CLIENT_DIRECT_CD: cd, CLIENT_DIRECT_AMT: a }, function() { $('#dpInfo').modal('hide'); load(); }); }
		var $box = $('<div>').append($('<label class="small text-muted mb-1" for="dirCd">').text('종류')).append($cd)
			.append($('<label class="small text-muted mb-1 mt-2" for="dirAmt">').text('금액')).append($amt).append($calc)
			.append($('<div class="d-flex mt-3" style="gap:6px">')
				.append(r.CLIENT_DIRECT_AMT ? $('<button type="button" class="btn btn-sm btn-outline-danger mr-auto">직접계약 없음으로</button>').on('click', function() { send('', ''); }) : $('<span class="mr-auto">'))
				.append($('<button type="button" class="btn btn-sm btn-primary">저장</button>').on('click', function() {
					if (!$cd.val()) { $cd.focus(); return; }
					send($cd.val(), amt());
				})));
		paint();
		$('#dpInfo').one('shown.bs.modal', function() { ($cd.val() ? $amt : $cd).focus(); });
		// 공통 팝업을 이 팝업만 좁게 쓰고, 닫으면 원래 너비로
		var $dlg = $('#dpInfo .modal-dialog').css('max-width', '420px');
		$('#dpInfo').one('hidden.bs.modal', function() { $dlg.css('max-width', ''); });
		dpInfo(r.STAFF_NM + ' · 고객사 직접계약', $box);
	}

	// 칸 하나 바로 수정. 저장되면 다시 불러온다(이력 건수·두 줄 묶음이 바뀔 수 있어서)
	function editCell($td, r, c) {
		var e = EDIT[c[0]], field = e[0], type = e[1] === 'SALE_YN' || e[1] === 'BUY_YN' ? partnerOptions(e[1], r[field]) : e[1];
		if (c[2]) $td.addClass('dp-num');
		hrEditable($td, { url: '/admin/deploy/saveFieldData.do', key: { DEPLOY_SQ: r.DEPLOY_SQ }, field: field, type: type, label: r.STAFF_NM + ' ' + c[1],
			show: function() { return r[c[0]]; }, value: function() { return r[field]; }, saved: function() { load(); },
			paint: function($c, v) {
				if (c[0] === 'EMP_TYPE_CD') $c.text(typeLabel(r));
				else if (c[0] === 'SALE_PRICE') {
					// 급여관리와 같은 모양: 기준월에 일부만 근무하면 일할(월 금액 취소선 + 일할 금액), 직접계약은 🤝 에만
					var net = Number(v || 0) - Number(r.CLIENT_DIRECT_AMT || 0), m = moment(ym + '-01'), last = m.clone().endOf('month'), total = last.date();
					var from = moment.max(moment(r.START_DT), m), to = r.END_DT ? moment.min(moment(r.END_DT), last) : last, days = Math.max(0, to.diff(from, 'days') + 1);
					// shortcut: 일할 버림 단위를 1,000원으로 본다(급여관리 기준값 기본), 기준값을 바꾸면 이 화면 일할 금액만 천 원 단위로 보인다
					dpSaleFill($c, r, net, days, total, Math.floor(net * days / total / 1000) * 1000, function() { directPopup(r); }).append(dpInfoBtn(r.STAFF_NM + ' 단가·급여 이력', function() { payHistory(r); }));
				}
				else if (c[2]) $c.text(v ? dpWon(v) : '');
				else if (c[0] === 'WORK_AREA') $c.text(v || '').append(farFrom(r.HOME_ADDR, v) ? $('<span class="dp-far">원거리</span>') : '');
				else $c.text(v || '');
			} });
	}

	// 같은 달 다른 계약 줄은 기본으로 접고, 성명 앞 작은 화살표로 사람별로 편다
	var openDup = {};
	function isOpen(g) { return !!openDup[g.top.STAFF_SQ]; }

	// 다른 계약이 있으면 성명 앞에 ▸/▾. 마우스를 올리면 건별 기간과 사이 공백일
	function dupArrow(g) {
		if (g.rows.length < 2) return '';
		var open = isOpen(g);
		var $p = $('<button type="button" class="pl-dup-arrow">').attr({ 'aria-expanded': open, 'aria-label': g.top.STAFF_NM + ' 다른 계약 ' + (g.rows.length - 1) + '건 ' + (open ? '접기' : '펼치기') }).text(open ? '▾' : '▸')
			.on('click', function() { openDup[g.top.STAFF_SQ] = !open; dpHide(); render(); });
		dpHover($p, $p, function() {
			var asc = g.rows.slice().reverse(), lines = [];
			asc.forEach(function(x, i) {
				lines.push(dpLine(typeName(x.EMP_TYPE_CD) + ' · ' + [x.CLIENT_NM, x.PRJ_NM].filter(Boolean).join(' '), x.START_DT + ' ~ ' + (x.END_DT || '미정')));
				var next = asc[i + 1];
				if (next && x.END_DT) {
					var gap = moment(next.START_DT).diff(moment(x.END_DT), 'days') - 1;
					if (gap > 0) lines.push('<div><span class="dp-mute">공백 ' + moment(x.END_DT).add(1, 'days').format('M/D') + '~' + moment(next.START_DT).subtract(1, 'days').format('M/D') + ' ' + gap + '일</span><span></span></div>');
				}
			});
			return '<div class="dp-card sm"><div class="dp-card-top">' + dpEsc(g.top.STAFF_NM) + ' · ' + dpEsc(moment(ym + '-01').format('M월')) + ' 투입 ' + g.rows.length + '건</div><div class="dp-sec">' + lines.join('') + '</div></div>';
		});
		return $p;
	}

	function countBtn(icon, n, label, open) {
		n = Number(n || 0);
		return $('<button type="button" class="pl-btn">').toggleClass('zero', !n).attr('aria-label', label + ' ' + n + '건').text(icon + (n ? ' ' + n : '')).on('click', open);
	}

	// ── 메모 (쌓기만, 본인 것만 삭제) · 수정이력 (되돌리기는 여기서만) ──

	function memoPopup(r) {
		var $box = $('<div>');
		function draw(first) {
			hrPost('/admin/deploy/memoListData.do', { STAFF_SQ: r.STAFF_SQ }, function(res) {
				var $f = $('<div class="pl-feed">');
				res.result.list.forEach(function(m) {
					var $who = $('<div class="who">').append($('<b>').text(m.EMPLY_NM || m.EMPLY_ID)).append($('<span>').text(m.REG_DT));
					if (m.EMPLY_ID === res.result.me) $who.append($('<button type="button" class="btn btn-sm btn-link p-0 ml-auto text-danger">삭제</button>').on('click', function() {
						hrPost('/admin/deploy/deleteMemoData.do', { MEMO_SQ: m.MEMO_SQ }, function() { draw(); load(); });
					}));
					$f.append($('<div class="it">').append($who).append($('<div>').text(m.CONTENT)));
				});
				if (!res.result.list.length) $f.append('<div class="text-muted small mb-2">메모가 없습니다.</div>');
				var $ta = $('<textarea class="form-control form-control-sm enter-send" rows="2" maxlength="1000" aria-label="메모 입력" placeholder="메모 입력 · Enter 등록, Shift+Enter 줄바꿈 (작성자·일시는 자동)">');
				var $add = $('<button type="button" class="btn btn-sm btn-primary mt-1">남기기</button>').on('click', function() {
					if (!$.trim($ta.val())) { $ta.focus(); return; }
					$add.prop('disabled', true);
					hrPost('/admin/deploy/saveMemoData.do', { STAFF_SQ: r.STAFF_SQ, CONTENT: $ta.val() }, function() { draw(); load(); }, function() { $add.prop('disabled', false); });
				});
				$ta.on('enter-send', function() { if (!$add.prop('disabled')) $add.click(); });
				$box.empty().append($f).append($ta).append($('<div class="text-right">').append($add));
				if (first) { $('#dpInfo').one('shown.bs.modal', function() { $ta.focus(); }); dpInfo(r.STAFF_NM + ' 투입 메모', $box); } else $ta.focus();
			});
		}
		draw(true);
	}

	function histVal(field, v) {
		if (v === null || v === undefined || v === '') return '—';
		if (field === 'SALE_PRICE' || field === 'COST_PRICE') return dpWon(v);
		if (field === 'EMP_TYPE_CD') return typeName(v);
		if (field === 'SALE_PARTNER_SQ' || field === 'BUY_PARTNER_SQ') { var p = data.partners.filter(function(x) { return String(x.PARTNER_SQ) === String(v); })[0]; return p ? p.PARTNER_NM : '#' + v; }
		return v;
	}

	function historyPopup(r) {
		var $box = $('<div>');
		function draw(first) {
			hrPost('/admin/deploy/changeListData.do', { STAFF_SQ: r.STAFF_SQ }, function(res) {
				var $t = $('<table class="table table-sm cal-table mb-0">').append('<thead><tr><th>일시</th><th>누가</th><th>칸</th><th>전 → 후</th><th>사유</th><th></th></tr></thead>');
				var $b = $('<tbody>').appendTo($t);
				res.result.forEach(function(h) {
					var $act = $('<td>');
					if (h.REVERTED_YN === 'Y') $act.append('<span class="dp-pill">되돌림됨</span>');
					else if (h.FIELD_NM !== 'NEW' && h.FIELD_NM !== 'DELETE' && h.DEPLOY_NM != null) $act.append($('<button type="button" class="btn btn-sm btn-outline-secondary">↶ 되돌리기</button>').on('click', function() {
						bootbox.confirm((FIELD_NM[h.FIELD_NM] || h.FIELD_NM) + ' 을(를) ' + histVal(h.FIELD_NM, h.BEFORE_VAL) + ' 으로 되돌릴까요?', function(ok) {
							if (ok) hrPost('/admin/deploy/revertData.do', { CHG_SQ: h.CHG_SQ, STAFF_SQ: r.STAFF_SQ }, function() { draw(); load(); });
						});
					}));
					$b.append($('<tr>').toggleClass('text-muted', h.REVERTED_YN === 'Y').append($('<td>').text(h.REG_DT)).append($('<td>').text(h.EMPLY_NM || h.EMPLY_ID || ''))
						.append($('<td>').text(FIELD_NM[h.FIELD_NM] || h.FIELD_NM))
						.append($('<td>').text(h.FIELD_NM === 'NEW' ? histVal('', h.AFTER_VAL) : h.FIELD_NM === 'DELETE' ? histVal('', h.BEFORE_VAL) : histVal(h.FIELD_NM, h.BEFORE_VAL) + ' → ' + histVal(h.FIELD_NM, h.AFTER_VAL)))
						.append($('<td>').text(h.REASON || '')).append($act));
				});
				if (!res.result.length) boEmpty($b, '수정이력이 없습니다.');
				$box.empty().append($('<div class="table-responsive" style="max-height:60vh">').append($t));
				if (first) dpInfo(r.STAFF_NM + ' 투입 수정이력', $box);
			});
		}
		draw(true);
	}

	function arrange($tr) {
		order.concat(payKeys(), ['_ACT']).forEach(function(k) { var $c = $tr.children('[data-c="' + k + '"]'); if ($c.length) $tr.append($c); });
	}
	function arrangeAll() { $('#dpHead tr, #dpBody tr').each(function() { arrange($(this)); }); }

	function saveOrder(val) { $.post('/admin/deploy/saveColumnsData.do', { ORDER: val }); }

	function move(from, to, after) {
		order.splice(order.indexOf(from), 1);
		order.splice(order.indexOf(to) + (after ? 1 : 0), 0, from);
		arrangeAll();
		saveOrder(order.join(','));
	}

	function bindDrag() {
		$('#dpHead th').each(function() {
			var th = this, c = $(th).attr('data-c');
			if (c === '_ACT' || /^P_/.test(c)) return; // 급여 칸 묶음은 순서 고정
			$(th).attr({ draggable: true, tabindex: 0, title: '끌어서 순서 변경 (Alt+←/→)' });
			function after(e) { var r = th.getBoundingClientRect(); return e.originalEvent.clientX > r.left + r.width / 2; }
			function clear() { $('#dpHead th').removeClass('drop-l drop-r dragging'); }
			$(th).on('dragstart', function(e) { drag = c; e.originalEvent.dataTransfer.setData('text/plain', c); e.originalEvent.dataTransfer.effectAllowed = 'move'; $(th).addClass('dragging'); })
				.on('dragover', function(e) { if (!drag || drag === c) return; e.preventDefault(); clear(); $(th).addClass(after(e) ? 'drop-r' : 'drop-l'); })
				.on('drop', function(e) { e.preventDefault(); if (drag && drag !== c) move(drag, c, after(e)); clear(); })
				.on('dragend', function() { drag = null; clear(); })
				.on('keydown', function(e) {
					if (!e.altKey || (e.key !== 'ArrowLeft' && e.key !== 'ArrowRight')) return;
					e.preventDefault();
					var next = order[order.indexOf(c) + (e.key === 'ArrowRight' ? 1 : -1)];
					if (next) { move(c, next, e.key === 'ArrowRight'); th.focus(); }
				});
		});
	}

	// ── 맨 아래 입력 행 ──

	function partnerOptions(kind, keep) {
		return { list: [['', kind === 'SALE_YN' ? '매출처' : '매입처']].concat(data.partners.filter(function(p) { return p[kind] === 'Y' && (p.USE_YN === 'Y' || String(p.PARTNER_SQ) === String(keep)); })
			.map(function(p) { return [String(p.PARTNER_SQ), p.PARTNER_NM]; })) };
	}

	function addRow(focus, preset) {
		preset = preset || {};
		var $tr = $('<tr class="dp-edit">'), inputs = {};
		function put(k, $c) { inputs[k] = $c.attr('aria-label', colLabel(k)); return $c; }
		visibleCols().forEach(function(c) {
			var $td = $('<td>').attr('data-c', c[0]), k = c[0];
			if (k === 'STAFF_NM') $td.append(put(k, $('<input class="form-control" list="staffList" placeholder="성명 검색" autocomplete="off">').val(preset.STAFF_LABEL || '')));
			else if (k === 'EMP_TYPE_CD') $td.append(put(k, hrControl({ code: 'HR_EMP_TYPE' }, preset.EMP_TYPE_CD)));
			else if (k === 'GRADE_CD') $td.append(put(k, hrControl({ code: 'HR_DEPLOY_GRADE' }, preset.GRADE_CD)));
			else if (k === 'SALE_PARTNER_NM') $td.append(put(k, hrControl(partnerOptions('SALE_YN'), '')));
			else if (k === 'BUY_PARTNER_NM') $td.append(put(k, hrControl(partnerOptions('BUY_YN'), '')));
			else if (c[2]) $td.append(put(k, $('<input class="form-control dp-num" inputmode="numeric" placeholder="0">')));
			else if (k === 'START_DT' || k === 'END_DT') $td.append(put(k, $('<input class="form-control" type="date">')));
			else if (k === 'REMAIN' || k === 'TENURE' || k === 'HOME_AREA' || k === 'PRJ') $td.append('<span class="dp-mute">자동</span>');
			else $td.append(put(k, $('<input class="form-control">')));
			$tr.append($td);
		});
		var $act = $('<td data-c="_ACT" class="text-nowrap">')
			.append($('<button type="button" class="btn btn-sm btn-primary">저장</button>').on('click', function() { save(false); }))
			.append(' ').append($('<button type="button" class="btn btn-sm btn-outline-secondary">취소</button>').on('click', function() { $tr.remove(); }));
		$tr.append($act).find('select').addClass('form-control');
		function staffSq() {
			var v = $.trim(inputs.STAFF_NM.val());
			var hit = data.staff.filter(function(s) { return staffLabel(s) === v; });
			if (!hit.length) hit = data.staff.filter(function(s) { return s.STAFF_NM === v; });
			return hit.length === 1 ? hit[0].STAFF_SQ : null;
		}
		function save(next) {
			$tr.find('.is-invalid').removeClass('is-invalid');
			var sq = staffSq();
			if (!sq) { inputs.STAFF_NM.addClass('is-invalid').focus(); bootbox.alert('성명은 목록에서 골라 주세요. 같은 이름이 있으면 입사일이 붙은 항목을 고릅니다.'); return; }
			var p = { STAFF_SQ: sq, EMP_TYPE_CD: inputs.EMP_TYPE_CD.val(), GRADE_CD: inputs.GRADE_CD.val(), SALE_PARTNER_SQ: inputs.SALE_PARTNER_NM.val(), BUY_PARTNER_SQ: inputs.BUY_PARTNER_NM.val(),
				CLIENT_NM: inputs.CLIENT_NM.val(), PRJ_NM: inputs.PRJ_NM.val(), WORK_AREA: inputs.WORK_AREA.val(), START_DT: inputs.START_DT.val(), END_DT: inputs.END_DT.val() };
			if (data.canPay) { p.SALE_PRICE = inputs.SALE_PRICE.val(); p.COST_PRICE = inputs.COST_PRICE.val(); }
			if (!p.EMP_TYPE_CD) { inputs.EMP_TYPE_CD.addClass('is-invalid').focus(); return; }
			if (!p.START_DT) { inputs.START_DT.addClass('is-invalid').focus(); return; }
			if (p.END_DT && p.END_DT < p.START_DT) { inputs.END_DT.addClass('is-invalid').focus(); return; }
			hrPost('/admin/deploy/saveDeployData.do', p, function() {
				load(function() { if (next) addRow(true); });
			});
		}
		$tr.on('keydown', function(e) {
			if (e.key === 'Escape') $tr.remove();
			else if (e.key === 'Enter' && e.target.tagName !== 'BUTTON') { e.preventDefault(); save(true); }
		});
		$('#dpBody').append($tr);
		arrange($tr);
		if (focus) inputs.STAFF_NM.focus();
	}

	// ── 상세 팝업 ──

	function detailFields() {
		var f = [['STAFF_NM', '성명', 3], ['EMP_TYPE_CD', '고용형태', 3, { code: 'HR_EMP_TYPE' }], ['GRADE_CD', '투입등급', 3, { code: 'HR_DEPLOY_GRADE' }], ['WORK_AREA', '근무지역', 3],
			['CLIENT_NM', '고객사', 3], ['PRJ_NM', '프로젝트', 3], ['SALE_PARTNER_SQ', '매출처', 3, { values: {} }], ['BUY_PARTNER_SQ', '매입처', 3, { values: {} }],
			['START_DT', '투입일', 3, 'date'], ['END_DT', '철수일', 3, 'date'], ['PROB_END_DT', '수습해제일', 3, 'date']];
		if (data.canPay) f.push(['SALE_PRICE', '월 매출단가 🔒', 3], ['COST_PRICE', '월 계약단가 🔒', 3]);
		f.push(['MEMO', '메모', 12]);
		return f;
	}

	function openDetail(r) {
		$('#detailFields').empty();
		hrBuildFields('#detailFields', detailFields());
		[['SALE_PARTNER_SQ', 'SALE_YN'], ['BUY_PARTNER_SQ', 'BUY_YN']].forEach(function(x) {
			var $s = $('#detailForm [name=' + x[0] + ']').empty();
			partnerOptions(x[1], r[x[0]]).list.forEach(function(o) { $s.append($('<option>').val(o[0]).text(o[1])); });
		});
		hrFillForm('#detailForm', detailFields(), r);
		$('#detailForm [name=DEPLOY_SQ]').val(r.DEPLOY_SQ);
		$('#detailForm [name=STAFF_SQ]').val(r.STAFF_SQ);
		$('#detailForm [name=STAFF_NM]').prop('readonly', true);
		$('#detailTitle').text(r.STAFF_NM + ' 투입 상세');
		$('#dOffice').prop('checked', r.OFFICE_YN === 'Y');
		$('#dRest').prop('checked', !!r.REST_FROM_DT);
		$('#dRestFrom').val(r.REST_FROM_DT || ''); $('#dRestTo').val(r.REST_TO_DT || '');
		$('#dRestDates').toggleClass('d-none', !r.REST_FROM_DT).toggleClass('d-flex', !!r.REST_FROM_DT);
		var $hb = $('#histBody').empty();
		data.all.filter(function(x) { return x.STAFF_SQ === r.STAFF_SQ; }).slice().reverse().forEach(function(x) {
			var $tr = $('<tr class="dp-hist" tabindex="0">').toggleClass('font-weight-bold', x.DEPLOY_SQ === r.DEPLOY_SQ)
				.append($('<td>').text(x.START_DT + ' ~ ' + (x.END_DT || '미정')).append(data.canPay ? dpInfoBtn('단가·급여 이력', function() { payHistory(x); }) : ''))
				.append($('<td>').text(typeName(x.EMP_TYPE_CD)))
				.append($('<td>').text(x.CLIENT_NM || '')).append($('<td>').text(x.PRJ_NM || '')).append($('<td>').text(x.WORK_AREA || '')).append($('<td>').text(x.GRADE_CD || ''))
				.on('click', function() { openDetail(x); });
			$hb.append($tr);
		});
		$('#detailModal').modal('show');
	}

	// 투입 건 하나의 월별 단가·급여 이력 표
	function payHistory(x) {
		var title = x.STAFF_NM ? x.STAFF_NM + ' · ' : '';
		title += [x.CLIENT_NM, x.PRJ_NM].filter(Boolean).join(' · ') || '투입';
		hrPost('/admin/pay/deployHistoryData.do', { STAFF_SQ: x.STAFF_SQ, DEPLOY_SQ: x.DEPLOY_SQ }, function(res) {
			var h = res.result, months = (h.MONTHS || []).slice().reverse(), shared = months.some(function(m) { return m.SHARED; });
			var $box = $('<div>').append($('<div class="small text-muted mb-2">').text('투입 ' + x.START_DT + ' ~ ' + (x.END_DT || '미정') + ' · 현재 단가 ' + dpWon(x.SALE_PRICE) + ' / ' + dpWon(x.COST_PRICE)));
			if (!months.length) {
				$box.append('<div class="text-muted py-3">급여 기록이 없습니다. 급여관리에서 그 달을 열면 만들어집니다.</div>');
			} else {
				var cols = [['PAY_YM', '월'], ['_DAYS', '근무일'], ['SALE_PRICE', '매출단가'], ['COST_PRICE', '계약단가'], ['REAL_SALE', '실매출'], ['PAY', '지급계'], ['DED', '공제계'], ['NET', '실지급'], ['PROFIT', '영업이익']];
				var $t = $('<table class="table table-sm cal-table mb-0">').append($('<thead>').append($('<tr>').append(cols.map(function(c) { return $('<th>').toggleClass('dp-num', c[0] !== 'PAY_YM').text(c[1]); }))));
				var $b = $('<tbody>').appendTo($t);
				months.forEach(function(m, i) {
					var prev = months[i + 1], changed = prev && (prev.SALE_PRICE !== m.SALE_PRICE || prev.COST_PRICE !== m.COST_PRICE);
					$b.append($('<tr>').append(cols.map(function(c) {
						if (c[0] === 'PAY_YM') return $('<td>').text(m.PAY_YM + (m.SHARED ? ' *' : ''));
						if (c[0] === '_DAYS') return $('<td class="dp-num">').text(m.WORK_DAYS + '/' + m.TOTAL_DAYS);
						return $('<td class="dp-num">').toggleClass('font-weight-bold', c[0] === 'PROFIT').toggleClass('text-danger', c[0] === 'PROFIT' && m.PROFIT < 0)
							.toggleClass('pl-changed', changed && /PRICE/.test(c[0])).text(m[c[0]] === null || m[c[0]] === undefined ? '—' : dpWon(m[c[0]]));
					})));
				});
				$b.append($('<tr class="font-weight-bold" style="background:#f6f8fa">').append('<td>누적</td><td></td><td></td><td></td>')
					.append($('<td class="dp-num">').text(dpWon(h.SALE))).append($('<td class="dp-num">').text(dpWon(h.PAY))).append('<td></td><td></td>')
					.append($('<td class="dp-num">').toggleClass('text-danger', h.PROFIT < 0).text(dpWon(h.PROFIT))));
				$box.append($('<div class="table-responsive" style="max-height:60vh">').append($t));
				$box.append($('<div class="small text-muted mt-2">').text('굵은 단가는 전달과 달라진 달입니다.' + (shared ? ' * 표시는 같은 달에 다른 투입 건이 함께 있어 이 건의 기본만 보입니다(공제는 사람 단위).' : '')));
			}
			dpInfo(title, $box);
		});
	}

	function saveDetail() {
		var p = {};
		$('#detailForm').serializeArray().forEach(function(x) { p[x.name] = x.value; });
		delete p.STAFF_NM;
		p.OFFICE_YN = $('#dOffice').prop('checked') ? 'Y' : 'N';
		p.REST_YN = $('#dRest').prop('checked') ? 'Y' : 'N';
		p.REST_FROM_DT = p.REST_YN === 'Y' ? $('#dRestFrom').val() : '';
		p.REST_TO_DT = p.REST_YN === 'Y' ? $('#dRestTo').val() : '';
		if (p.REST_YN === 'Y' && !p.REST_FROM_DT) { $('#dRestFrom').focus(); return; }
		hrPost('/admin/deploy/saveDeployData.do', p, function() { $('#detailModal').modal('hide'); load(); });
	}

	// 철수 처리: 철수일(기본 오늘)을 넣고 대기 현황 탭으로 옮겨 보여 준다. 철수일이 오늘이면 그날부터 대기로 본다
	function leaveDeploy() {
		var sq = $('#detailForm [name=DEPLOY_SQ]').val(), name = $('#detailForm [name=STAFF_NM]').val();
		bootbox.prompt({ title: name + ' 철수 처리 · 철수일', inputType: 'date', value: today.format('YYYY-MM-DD'), callback: function(v) {
			if (!v) return;
			hrPost('/admin/deploy/saveFieldData.do', { DEPLOY_SQ: sq, FIELD: 'END_DT', VALUE: v }, function() {
				$('#detailModal').modal('hide');
				if (!moment(v).isAfter(today)) page = 'IDLE';
				load();
			});
		} });
	}

	// ── 휴직 ──

	$(document).on('change', '#dRest', function() {
		$('#dRestDates').toggleClass('d-none', !this.checked).toggleClass('d-flex', this.checked);
		if (this.checked && !$('#dRestFrom').val()) $('#dRestFrom').val(today.format('YYYY-MM-DD'));
	});

	function renderRest(list) {
		var $t = $('<table class="table table-sm cal-table mb-0">').append('<thead><tr><th>성명</th><th>형태</th><th>직급·소속</th><th>휴직 기간</th><th>복귀</th><th>프로젝트</th><th>근속</th><th>프로젝트 이력</th></tr></thead>');
		var $b = $('<tbody>').appendTo($t);
		if (!list.length) boEmpty($b, '휴직 중인 사람이 없습니다. 투입 상세 팝업에서 휴직을 켜고 기간을 넣으면 여기에만 보입니다.');
		list.forEach(function(it) {
			var s = it.s, x = it.x, back = x.REST_TO_DT ? moment(x.REST_TO_DT).add(1, 'days') : null;
			var left = back ? back.diff(today, 'days') : null, plan = moment(x.REST_FROM_DT).isAfter(today);
			$b.append($('<tr>').toggleClass('dp-secret', !!s.SECRET)
				.append($('<td>').append(s.SECRET ? $('<span title="시크릿">').text('🔒 ') : '').append($('<button type="button" class="dp-name">').text(s.STAFF_NM).on('click', function() { openDetail(x); })))
				.append($('<td>').text(typeLabel(x))).append($('<td>').text([s.POSITION_NM, s.DEPT_NM || s.ORG_NM].filter(Boolean).join(' · ')))
				.append($('<td>').text(x.REST_FROM_DT + ' ~ ' + (x.REST_TO_DT || '미정')).append(plan ? $('<span class="dp-pill rent ml-1">').text('예정') : ''))
				.append($('<td>').append($('<span class="dp-pill">').addClass(left !== null && left <= 14 ? 'warn' : '').text(back ? back.format('YYYY-MM-DD') + ' (D-' + left + ')' : '미정')))
				.append($('<td>').text([x.CLIENT_NM, x.PRJ_NM].filter(Boolean).join(' '))).append($('<td>').text(tenure(s.JOIN_DT))).append($('<td>').append(prjBtn(s.STAFF_SQ, s.STAFF_NM))).append(payCells(s.STAFF_SQ)));
		});
		$('#altView').empty().append(withPay($t));
	}

	// ── 내근직 ──

	function renderOffice(list) {
		var $t = $('<table class="table table-sm cal-table mb-0">').append('<thead><tr><th>성명</th><th>형태</th><th>직급·소속</th><th>업무</th><th>근무지역</th><th>시작일</th><th>근속</th><th>프로젝트 이력</th></tr></thead>');
		var $b = $('<tbody>').appendTo($t);
		if (!list.length) boEmpty($b, '내근직이 없습니다. 투입 상세 팝업에서 내근직을 켜면 여기에만 보입니다.');
		list.forEach(function(it) {
			var s = it.s, x = it.x;
			$b.append($('<tr>').toggleClass('dp-secret', !!s.SECRET)
				.append($('<td>').append(s.SECRET ? $('<span title="시크릿">').text('🔒 ') : '').append($('<button type="button" class="dp-name">').text(s.STAFF_NM).on('click', function() { openDetail(x); })))
				.append($('<td>').text(typeLabel(x))).append($('<td>').text([s.POSITION_NM, s.DEPT_NM || s.ORG_NM].filter(Boolean).join(' · ')))
				.append($('<td>').text([x.CLIENT_NM, x.PRJ_NM].filter(Boolean).join(' '))).append($('<td>').text(x.WORK_AREA || ''))
				.append($('<td>').text(x.START_DT || '')).append($('<td>').text(tenure(s.JOIN_DT))).append($('<td>').append(prjBtn(s.STAFF_SQ, s.STAFF_NM))).append(payCells(s.STAFF_SQ)));
		});
		$('#altView').empty().append(withPay($t));
	}

	// 대기·내근직·휴직 표에도 같은 급여 칸 묶음(머리글)
	function withPay($t) { $t.find('thead tr').first().append(payHeads()); return $t; }

	function deleteDetail() {
		bootbox.confirm('이 투입 건을 삭제할까요? 마감 전 달의 급여에서도 빠집니다.', function(ok) {
			if (!ok) return;
			hrPost('/admin/deploy/deleteDeployData.do', { DEPLOY_SQ: $('#detailForm [name=DEPLOY_SQ]').val() }, function() { $('#detailModal').modal('hide'); load(); });
		});
	}

	function nextDeploy() {
		var sq = Number($('#detailForm [name=STAFF_SQ]').val()), s = data.staff.filter(function(x) { return x.STAFF_SQ === sq; })[0];
		$('#detailModal').modal('hide');
		if (view !== 'table') $('[data-view=table]').click();
		addRow(true, { STAFF_LABEL: s ? staffLabel(s) : '', EMP_TYPE_CD: $('#detailForm [name=EMP_TYPE_CD]').val(), GRADE_CD: $('#detailForm [name=GRADE_CD]').val() });
	}

	// ── 대기 현황 ──

	function regionCell(addr) { return $('<td>').text(area(addr)); }
	function wantCell(s) { return $('<td class="dp-want">').text(s.WISH_LOC || ''); }

	function renderIdle(list) {
		var KIND = { WAIT: ['대기', 'warn'], NONE: ['이력 없음', ''], FUTURE: ['투입 예정', 'rent'] };
		var $t = $('<table class="table table-sm cal-table mb-0">').append('<thead><tr><th>성명</th><th>구분</th><th>직급·소속</th><th>거주지역</th><th>희망지역</th><th>입사일</th><th>대기 기간</th><th>프로젝트 이력</th><th><span class="sr-only">작업</span></th></tr></thead>');
		var $b = $('<tbody>').appendTo($t);
		if (!list.length) boEmpty($b, '대기 중인 직원이 없습니다.');
		list.forEach(function(it) {
			var s = it.s, k = KIND[it.kind];
			var wait = it.kind === 'FUTURE' ? moment(it.future.START_DT).diff(today, 'days') + '일 뒤 투입' : it.days + '일' + (it.kind === 'NONE' ? ' (입사 후)' : '');
			var $tr = $('<tr>').toggleClass('dp-secret', !!s.SECRET).append($('<td>').append($('<button type="button" class="dp-name">').text(s.STAFF_NM).on('click', function() { if (it.last || it.future) openDetail(it.future || it.last); })))
				.append($('<td>').append($('<span class="dp-pill">').addClass(k[1]).text(k[0])))
				.append($('<td>').text([s.POSITION_NM, s.DEPT_NM || s.ORG_NM].filter(Boolean).join(' · ')))
				.append(regionCell(s.ADDR)).append(wantCell(s)).append($('<td>').text(s.JOIN_DT || ''))
				.append($('<td>').append($('<span>').toggleClass('text-danger font-weight-bold', it.kind !== 'FUTURE' && it.days > 14).text(wait)))
				.append($('<td>').append(prjBtn(s.STAFF_SQ, s.STAFF_NM)))
				.append($('<td class="text-nowrap">').append(it.kind === 'FUTURE'
					? $('<button type="button" class="btn btn-sm btn-outline-secondary">투입 수정</button>').on('click', function() { openDetail(it.future); })
					: $('<button type="button" class="btn btn-sm btn-primary">+ 투입 등록</button>').on('click', function() { regForm($tr, s, it.last, 9); })));
			$b.append($tr.append(payCells(s.STAFF_SQ)));
			if (it.kind === 'FUTURE') $b.append(childRow('└ 투입 예정', it.future, 9, 'D-' + moment(it.future.START_DT).diff(today, 'days')));
		});
		$('#altView').empty().append(withPay($t));
	}

	// 예정·다음 투입을 한 줄로
	function childRow(label, x, span, badge) {
		var bits = [['형태', typeName(x.EMP_TYPE_CD)], ['매출처', x.SALE_PARTNER_NM], ['근무지역', x.WORK_AREA], ['기간', x.START_DT + ' ~ ' + (x.END_DT || '미정')], ['등급', x.GRADE_CD]];
		var $td = $('<td>').attr('colspan', span - 1).append($('<span class="dp-pill rent">').text(badge)).append(' ')
			.append($('<b>').text([x.CLIENT_NM, x.PRJ_NM].filter(Boolean).join(' · ') || '투입'));
		bits.forEach(function(b) { if (b[1]) $td.append($('<span class="dp-mute">').text(' · ' + b[0] + ' ')).append(document.createTextNode(b[1])); });
		return $('<tr class="dp-child">').append($('<td>').text(label)).append($td);
	}

	// 그 줄 아래 투입 등록 입력 줄. 마지막 투입 값으로 미리 채운다
	function regForm($after, s, last, span, startDt) {
		$after.nextAll('tr.dp-form').first().filter(function() { return $(this).data('for') === s.STAFF_SQ; }).remove();
		last = last || {};
		var f = {
			EMP_TYPE_CD: hrControl({ code: 'HR_EMP_TYPE' }, last.EMP_TYPE_CD).attr('aria-label', '형태'),
			SALE_PARTNER_SQ: hrControl(partnerOptions('SALE_YN'), last.SALE_PARTNER_SQ ? String(last.SALE_PARTNER_SQ) : '').attr('aria-label', '매출처'),
			BUY_PARTNER_SQ: hrControl(partnerOptions('BUY_YN'), last.BUY_PARTNER_SQ ? String(last.BUY_PARTNER_SQ) : '').attr('aria-label', '매입처'),
			CLIENT_NM: $('<input class="form-control" placeholder="고객사" aria-label="고객사">'),
			PRJ_NM: $('<input class="form-control" placeholder="프로젝트" aria-label="프로젝트">'),
			WORK_AREA: $('<input class="form-control" placeholder="근무지역" aria-label="근무지역">'),
			GRADE_CD: hrControl({ code: 'HR_DEPLOY_GRADE' }, last.GRADE_CD).attr('aria-label', '등급'),
			START_DT: $('<input class="form-control" type="date" aria-label="투입일">').val(startDt || ''),
			END_DT: $('<input class="form-control" type="date" aria-label="철수일">')
		};
		if (data.canPay) {
			f.SALE_PRICE = $('<input class="form-control" inputmode="numeric" placeholder="매출단가" aria-label="매출단가">');
			f.COST_PRICE = $('<input class="form-control" inputmode="numeric" placeholder="계약단가" aria-label="계약단가">');
		}
		var $td = $('<td>').attr('colspan', span).append($('<b class="mr-2">').text(s.STAFF_NM + ' 투입 등록'));
		$.each(f, function(k, $c) { $td.append($c.addClass('form-control')); });
		var $tr = $('<tr class="dp-form">').data('for', s.STAFF_SQ).append($td);
		function save() {
			var p = { STAFF_SQ: s.STAFF_SQ };
			$.each(f, function(k, $c) { p[k] = $c.val(); });
			if (!p.EMP_TYPE_CD) { f.EMP_TYPE_CD.focus(); return; }
			if (!p.START_DT) { f.START_DT.focus(); return; }
			hrPost('/admin/deploy/saveDeployData.do', p, function() { load(); });
		}
		$td.append($('<button type="button" class="btn btn-sm btn-primary ml-1">저장</button>').on('click', save))
			.append($('<button type="button" class="btn btn-sm btn-outline-secondary ml-1">취소</button>').on('click', function() { $tr.remove(); }));
		$tr.on('keydown', function(e) { if (e.key === 'Escape') $tr.remove(); else if (e.key === 'Enter' && e.target.tagName !== 'BUTTON') { e.preventDefault(); save(); } });
		$after.after($tr);
		f.EMP_TYPE_CD.focus();
	}

	// ── 철수 임박 ──

	function renderEnding(list) {
		var thisM = moment().format('YYYY-MM');
		var $t = $('<table class="table table-sm cal-table mb-0">').append('<thead><tr><th>성명</th><th>형태</th><th>거주지역</th><th>근무지역</th><th>희망지역</th><th>고객사 · 프로젝트</th><th>철수일</th><th>남은 기간</th><th>프로젝트 이력</th><th><span class="sr-only">작업</span></th></tr></thead>');
		var $b = $('<tbody>').appendTo($t);
		if (!list.length) boEmpty($b, '이번 달·다음 달 철수 예정자가 없습니다.');
		list.forEach(function(it) {
			var x = it.x, s = staffOf(x.STAFF_SQ), d = moment(x.END_DT).diff(today, 'days');
			var $tr = $('<tr>').toggleClass('dp-secret', !!x.SECRET).append($('<td>').append($('<button type="button" class="dp-name">').text(x.STAFF_NM).on('click', function() { openDetail(x); })))
				.append($('<td>').text(typeName(x.EMP_TYPE_CD))).append(regionCell(x.HOME_ADDR))
				.append($('<td>').text(x.WORK_AREA || '').append(farFrom(x.HOME_ADDR, x.WORK_AREA) ? $('<span class="dp-far">원거리</span>') : ''))
				.append($('<td class="dp-want">').text(x.WISH_LOC || ''))
				.append($('<td>').text([x.CLIENT_NM, x.PRJ_NM].filter(Boolean).join(' · ')))
				.append($('<td>').text(x.END_DT).append(x.END_DT.substring(0, 7) === thisM ? ' <span class="dp-pill bad">이번 달</span>' : ' <span class="dp-pill warn">다음 달</span>'))
				.append($('<td>').append($('<span class="dp-pill">').addClass(d <= 14 ? 'bad' : 'warn').text('D-' + d)))
				.append($('<td>').append(prjBtn(x.STAFF_SQ, x.STAFF_NM)));
			var $act = $('<td class="text-nowrap">').append($('<button type="button" class="btn btn-sm btn-outline-secondary">연장</button>').on('click', function() { extendForm($tr, x); }));
			if (!it.next) $act.append(' ').append($('<button type="button" class="btn btn-sm btn-primary">다음 투입 등록</button>')
				.on('click', function() { regForm($tr, s.STAFF_SQ ? s : { STAFF_SQ: x.STAFF_SQ, STAFF_NM: x.STAFF_NM }, x, 10, moment(x.END_DT).add(1, 'days').format('YYYY-MM-DD')); }));
			$b.append($tr.append($act));
			if (it.next) $b.append(childRow('└ 다음 투입', it.next, 10, moment(it.next.START_DT).format('M/D') + ' 시작 · 공백 ' + Math.max(0, moment(it.next.START_DT).diff(moment(x.END_DT), 'days') - 1) + '일'));
		});
		$('#altView').empty().append($t);
	}

	function extendForm($after, x) {
		$after.next('tr.dp-form').remove();
		var $end = $('<input class="form-control" type="date" aria-label="새 철수일">').attr('min', x.END_DT);
		var $memo = $('<input class="form-control" placeholder="메모(선택)" aria-label="연장 메모" style="min-width:220px">');
		var $td = $('<td colspan="10">').append($('<b class="mr-2">').text(x.STAFF_NM + ' 연장')).append($('<span class="dp-mute">').text('철수일 ' + x.END_DT + ' → ')).append($end);
		var $sale, $cost;
		if (data.canPay) {
			$sale = $('<input class="form-control" inputmode="numeric" aria-label="연장 매출단가">').attr('placeholder', '매출단가 ' + dpWon(x.SALE_PRICE));
			$cost = $('<input class="form-control" inputmode="numeric" aria-label="연장 계약단가">').attr('placeholder', '계약단가 ' + dpWon(x.COST_PRICE));
			$td.append($sale).append($cost);
		}
		$td.append($memo);
		$memo.on('keydown', function(e) { if (e.key === 'Enter' && !e.originalEvent.isComposing) { e.preventDefault(); save(); } });
		var $tr = $('<tr class="dp-form">');
		function save() {
			if (!$end.val() || $end.val() <= x.END_DT) { $end.focus(); bootbox.alert('새 철수일은 지금 철수일(' + x.END_DT + ') 뒤여야 합니다.'); return; }
			hrPost('/admin/deploy/extendDeployData.do', { DEPLOY_SQ: x.DEPLOY_SQ, END_DT: $end.val(), SALE_PRICE: $sale ? $sale.val() : '', COST_PRICE: $cost ? $cost.val() : '', MEMO: $memo.val() }, function() { load(); });
		}
		$td.append($('<button type="button" class="btn btn-sm btn-primary ml-1">연장 저장</button>').on('click', save))
			.append($('<button type="button" class="btn btn-sm btn-outline-secondary ml-1">취소</button>').on('click', function() { $tr.remove(); }))
			.append($('<span class="dp-mute small ml-2">').text('다음 달 이후로 연장하면 투입 현황으로 옮겨집니다'));
		$tr.append($td).on('keydown', function(e) { if (e.key === 'Escape') $tr.remove(); else if (e.key === 'Enter' && e.target.tagName !== 'BUTTON') { e.preventDefault(); save(); } });
		$after.after($tr);
		$end.focus();
	}

	// ── 프로젝트 이력: 📂 숫자, 마우스 올리면 많이 쓴 기술 미리보기, 클릭하면 팝업 ──

	var SKILL_COLS = [['LANG_NM', '언어'], ['FRAMEWORK_NM', 'FRAMEWORK'], ['DBMS_NM', 'DBMS'], ['IND_NM', '산업']];
	var ENV_COLS = [['IND_NM', '산업'], ['APP_NM', '응용'], ['MACHINE_NM', '기종'], ['OS_NM', 'O.S'], ['LANG_NM', '언어'], ['DBMS_NM', 'DBMS'], ['TOOL_NM', 'TOOL'], ['FRAMEWORK_NM', 'FRAMEWORK'], ['ETC_NM', '기타']];

	// 같은 고객사·프로젝트에서 기간이 겹치거나 바로 이어지는 투입 건(정규+외부 계약, 수습→정규)은 한 프로젝트로 묶는다. s·e 는 시작·종료 칸 이름
	function mergeDeps(list, s, e) {
		var out = [];
		list.slice().sort(function(a, b) { return String(a[s]).localeCompare(String(b[s])); }).forEach(function(x) {
			var key = (x.CLIENT_NM || '') + '|' + (x.PRJ_NM || '');
			var g = out.filter(function(o) { return o._key === key && (!o[e] || !moment(x[s]).isAfter(moment(o[e]).add(1, 'days'))); })[0];
			if (!g) { out.push($.extend({ _key: key, TYPES: [x.EMP_TYPE_CD] }, x)); return; }
			if (g.TYPES.indexOf(x.EMP_TYPE_CD) < 0) g.TYPES.push(x.EMP_TYPE_CD);
			g[e] = !g[e] || !x[e] ? null : x[e] > g[e] ? x[e] : g[e];
		});
		return out;
	}
	// 수습은 정규로 보고 겹치는 형태 이름은 한 번만
	function typesText(types) { return types.map(function(t) { return typeName(t === 'PROBATION' ? 'REGULAR' : t); }).filter(function(v, i, a) { return a.indexOf(v) === i; }).join('·'); }
	function prjCount(sq) { return Number(staffOf(sq).PRJ_CNT || 0) + mergeDeps(depsOf(sq), 'START_DT', 'END_DT').length; }
	function prjLoad(sq) {
		if (!prjCache[sq]) prjCache[sq] = $.post('/admin/deploy/projectHistoryData.do', { STAFF_SQ: sq }).then(function(res) {
			var items = res.result || [];
			return items.filter(function(it) { return it.SRC !== 'DEPLOY'; }).concat(mergeDeps(items.filter(function(it) { return it.SRC === 'DEPLOY'; }), 'START', 'END'))
				.sort(function(a, b) { return (!b.END) - (!a.END) || String(b.START).localeCompare(String(a.START)); });
		});
		return prjCache[sq];
	}
	function tokens(v) { return String(v || '').split(/[,/·\n]+/).map(function(t) { return $.trim(t); }).filter(Boolean); }
	// 칸마다 기술별 프로젝트 수
	function skillCount(items, col) {
		var c = {};
		items.forEach(function(it) { tokens(it[col]).filter(function(t, i, a) { return a.indexOf(t) === i; }).forEach(function(t) { c[t] = (c[t] || 0) + 1; }); });
		return Object.keys(c).sort(function(a, b) { return c[b] - c[a]; }).map(function(k) { return [k, c[k]]; });
	}
	function ymDot(v) { return v ? String(v).substring(0, 7).replace('-', '.') : ''; }
	function months(it) {
		var s = moment(String(it.START).substring(0, 7) + '-01'), e = it.END ? moment(String(it.END).substring(0, 7) + '-01') : moment().startOf('month');
		var m = e.diff(s, 'months') + 1;
		return m > 0 ? (m >= 12 ? Math.floor(m / 12) + '년 ' : '') + (m % 12 ? m % 12 + '개월' : '') : '';
	}
	function career(items) {
		var first = items.map(function(i) { return String(i.START || ''); }).filter(Boolean).sort()[0];
		if (!first) return '';
		var m = moment().diff(moment(first.substring(0, 7) + '-01'), 'months');
		return '경력 ' + (m >= 12 ? Math.floor(m / 12) + '년 ' : '') + (m % 12) + '개월';
	}

	function prjBtn(sq, name) {
		var n = prjCount(sq), $b = $('<button type="button" class="dp-prj">').toggleClass('zero', !n).attr('aria-label', name + ' 프로젝트 이력 ' + n + '건').text('📂 ' + n);
		if (!n) return $b.prop('disabled', true);
		$b.on('click', function(e) { e.stopPropagation(); dpHide(); prjPopup(sq, name); });
		dpHover($b, $b, function() {
			return prjLoad(sq).then(function(items) {
				var rows = SKILL_COLS.map(function(c) {
					var top = skillCount(items, c[0]).slice(0, 3);
					return top.length ? '<div class="prj-pv"><span class="k">' + c[1] + '</span>' + top.map(function(t) { return '<span class="prj-sk">' + dpEsc(t[0]) + ' <em>' + t[1] + '</em></span>'; }).join('') + '</div>' : '';
				}).join('');
				var recent = items[0];
				return '<div class="dp-card sm"><div class="dp-card-top">많이 쓴 기술<span>프로젝트 ' + items.length + '건 · ' + dpEsc(career(items)) + '</span></div>'
					+ (rows || '<div class="dp-sec"><div><span class="dp-mute">수행이력에 입력된 기술이 없습니다</span></div></div>')
					+ (recent ? '<div class="dp-sec"><div><span class="dp-mute">최근 ' + dpEsc([recent.CLIENT_NM, recent.PRJ_NM].filter(Boolean).join(' ')) + ' (' + ymDot(recent.START) + '~' + (ymDot(recent.END) || '진행중') + ') · 클릭하면 전체</span></div></div>' : '') + '</div>';
			});
		});
		return $b;
	}

	function prjPopup(sq, name) {
		prjLoad(sq).then(function(items) {
			var $box = $('<div>');
			var top = [];
			['LANG_NM', 'FRAMEWORK_NM', 'DBMS_NM', 'OS_NM', 'TOOL_NM', 'ETC_NM'].forEach(function(c) { top = top.concat(skillCount(items, c)); });
			top.sort(function(a, b) { return b[1] - a[1]; });
			if (top.length) $box.append($('<div class="mb-3">').append('<span class="dp-mute small mr-2">많이 쓴 기술</span>').append(top.slice(0, 10).map(function(t) { return $('<span class="prj-sk">').text(t[0] + ' ').append($('<em>').text(t[1])); })));
			items.forEach(function(it) {
				var now = !it.END && !moment(String(it.START)).isAfter(today), plan = moment(String(it.START)).isAfter(today);
				var $it = $('<div class="prj-item">').toggleClass('now', now).toggleClass('plan', plan);
				var $h = $('<div class="prj-head">').append($('<span class="t">').text(it.PRJ_NM || '(프로젝트명 없음)'));
				if (it.CLIENT_NM) $h.append($('<span class="dp-pill rent">').text(it.CLIENT_NM));
				if (it.ROLE_NM || it.EMP_TYPE_CD) $h.append($('<span class="dp-pill">').text(it.ROLE_NM || (it.TYPES ? typesText(it.TYPES) : typeName(it.EMP_TYPE_CD))));
				$h.append($('<span class="prj-src">').text(it.SRC === 'DEPLOY' ? '사내 투입' : '수행이력'));
				$h.append($('<span class="when">').text(ymDot(it.START) + ' ~ ' + (it.END ? ymDot(it.END) : plan ? '예정' : '진행중')).append($('<span>').text(months(it))));
				$it.append($h);
				$it.append($('<div class="prj-meta">').append('<div class="k">업무단</div>').append($('<div>').text(it.WORK_NM || '—'))
					.append('<div class="k">근무지역</div>').append($('<div>').text(it.WORK_AREA || '—')));
				if (it.SRC === 'PRJ') {
					var $env = $('<table class="prj-env">').append('<thead><tr><th class="grp" colspan="2">개발분야</th><th class="grp" colspan="7">개발환경</th></tr></thead>');
					$env.find('thead').append($('<tr>').append(ENV_COLS.map(function(c) { return $('<th>').text(c[1]); })));
					$env.append($('<tbody>').append($('<tr>').append(ENV_COLS.map(function(c) {
						var t = tokens(it[c[0]]);
						return $('<td>').append(t.length ? t.map(function(x) { return $('<span class="prj-tag">').text(x); }) : $('<span class="dp-mute">').text('—'));
					}))));
					$it.append($env);
				}
				$box.append($it);
			});
			if (!items.length) $box.append('<div class="text-muted py-3">프로젝트 이력이 없습니다. 인사카드의 영업정보/수행이력 탭에서 입력할 수 있습니다.</div>');
			dpInfo(name + ' · 프로젝트 이력 ' + items.length + '건' + (career(items) ? ' · ' + career(items) : ''), $box);
		});
	}

	// ── 타임라인: 지난 5달 ~ 앞으로 6달 ──

	function renderTimeline(list) {
		var start = moment().startOf('month').subtract(5, 'months'), end = start.clone().add(12, 'months'), span = end.diff(start, 'days');
		function pct(d) { return Math.max(0, Math.min(100, d.diff(start, 'days') / span * 100)); }
		var $g = $('<div class="dp-gantt">'), $head = $('<div class="dp-g-head">');
		for (var i = 0; i < 12; i++) {
			var m = start.clone().add(i, 'months');
			$head.append($('<span>').toggleClass('now', m.isSame(today, 'month')).text((m.month() === 0 || i === 0 ? m.format('YY.') : '') + (m.month() + 1) + '월'));
		}
		$g.append($('<div class="dp-g-row">').append('<div class="dp-g-who dp-mute">성명</div>').append($head));
		var seen = {};
		list.forEach(function(r) {
			if (seen[r.STAFF_SQ]) return;
			seen[r.STAFF_SQ] = 1;
			var $track = $('<div class="dp-g-track">').append($('<i class="dp-today">').css('left', pct(today) + '%'));
			data.all.filter(function(x) { return x.STAFF_SQ === r.STAFF_SQ; }).forEach(function(x) {
				var s = moment(x.START_DT), e = x.END_DT ? moment(x.END_DT).add(1, 'days') : end.clone();
				if (!e.isAfter(start) || !s.isBefore(end)) return;
				var d = x.END_DT ? moment(x.END_DT).diff(today, 'days') : 9999;
				var cls = x.END_DT && d < 0 ? 'past' : d <= 14 ? 'urgent' : d <= 30 ? 'soon' : x.END_DT ? '' : 'open';
				$track.append($('<div class="dp-b">').addClass(cls).css({ left: pct(s) + '%', width: (pct(e) - pct(s)) + '%' })
					.attr('title', (x.CLIENT_NM || '') + ' ' + (x.PRJ_NM || '') + ' ' + x.START_DT + ' ~ ' + (x.END_DT || '미정'))
					.text((x.CLIENT_NM || '') + (x.PRJ_NM ? ' · ' + x.PRJ_NM : '') + (x.END_DT ? '' : ' (철수일 미정)')));
			});
			$g.append($('<div class="dp-g-row">').append($('<div class="dp-g-who">').append($('<button type="button" class="dp-name">').text(r.STAFF_NM).on('click', function() { openDetail(r); }))
				.append($('<span class="dp-pill">').text(typeName(r.EMP_TYPE_CD)))).append($track));
		});
		if (!list.length) $g.append('<div class="text-center text-muted py-4">해당하는 투입이 없습니다.</div>');
		$('#timelineView').empty().append($g);
	}
	</script>
</body>
</html>
