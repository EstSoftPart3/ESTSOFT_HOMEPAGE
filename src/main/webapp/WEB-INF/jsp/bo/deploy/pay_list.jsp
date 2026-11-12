<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/deploy/deploy_common.jspf"%>
<style>
	/* 펼치는 묶음 색: 수당 청록, 공제 주황, 손익 보라. 버튼·색 띠·칸이 같은 색이다 */
	#lHead th, #lBody td { white-space: nowrap; }
	.pl-ledger .x-allow, .pl-ledger .x-ded, .pl-ledger .x-pl { display: none; }
	.pl-ledger.show-allow .x-allow, .pl-ledger.show-ded .x-ded, .pl-ledger.show-pl .x-pl { display: table-cell; }
	.pl-ledger.show-pl .pl-stub { display: none; }
	.pl-ledger .x-allow, .pl-ledger .c-allow { background: #dff5f3 !important; }
	.pl-ledger .x-ded, .pl-ledger .c-ded { background: #fdeadb !important; }
	.pl-ledger .x-pl, .pl-ledger .pl-stub { background: #efe6fa !important; }
	.pl-ledger .pl-stub { min-width: 44px; padding: 0; }
	.pl-bands th { background: #fff !important; border: 0 !important; padding: 0 !important; }
	.pl-bands th.band { color: #fff; font-size: 11.5px; text-align: center; padding: 3px 6px !important; cursor: pointer; }
	.pl-bands th.band:focus { outline: 2px solid #16d5ff; outline-offset: -2px; }
	.pl-bands th.allow { background: #0e7c86 !important; } .pl-bands th.ded { background: #b4531a !important; } .pl-bands th.pl { background: #6b3fa0 !important; }
	.btn.t-allow { border-color: #0e7c86; color: #0e7c86; font-weight: 700; } .show-allow .btn.t-allow { background: #0e7c86; color: #fff; }
	.btn.t-ded { border-color: #b4531a; color: #b4531a; font-weight: 700; } .show-ded .btn.t-ded { background: #b4531a; color: #fff; }
	.btn.t-pl { border-color: #6b3fa0; color: #6b3fa0; font-weight: 700; } .show-pl .btn.t-pl { background: #6b3fa0; color: #fff; }
	.pl-manual { background: #fff8e3 !important; }
	/* 고칠 수 있는 칸(점선 밑줄, 올리면 ✎)과 자동 계산 칸(회색)을 구분한다 */
	#lBody td.hr-cell, .pl-key-edit { text-decoration: underline dotted rgba(11,110,138,.6); text-underline-offset: 3px; cursor: text; }
	#lBody td.hr-cell:hover, #lBody td.hr-cell:focus { outline: 1px solid #0b6e8a; outline-offset: -2px; }
	#lBody td.hr-cell:hover::before { content: '✎ '; color: #0b6e8a; font-size: 10px; }
	/* 자동 계산 칸: 회색 글씨 + 옅은 빗금, 머리글에 Σ. 묶음 색 배경 위에 무늬만 겹친다 */
	/* 자동 계산 칸은 머리글의 작은 계산기 버튼으로 표시한다(올리면 계산식, 누르면 계산 기준값) */
	.pl-calc-btn { border: 1px solid #c9d3da; background: #fff; border-radius: 4px; padding: 0 3px; margin-right: 3px; font-size: 11px; line-height: 16px; cursor: pointer; vertical-align: middle; }
	.pl-calc-btn:hover, .pl-calc-btn:focus { border-color: #0b6e8a; background: #eef9fc; outline: none; box-shadow: 0 0 0 2px rgba(22,213,255,.35); }
	#kpiToggle { font-size: 12px; font-weight: 700; color: #5f6b75; }
	/* 시크릿 행: 시크릿 계정에게만 보이고 맨 위에 옅은 보라 */
	#lBody tr.pl-secret td { background-color: #f4effc; }
	.pl-chip.secret.on { border-color: #6b3fa0; background: #f4effc; color: #6b3fa0; }
	/* 체크 칩: 진짜 체크박스라 공통 Shift+클릭 범위 선택을 받는다 */
	.pl-chks { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; padding: 10px 14px; }
	.pl-chip { display: inline-flex; gap: 6px; align-items: center; padding: 4px 10px; border-radius: 999px; border: 1px solid rgba(17,17,17,.15); font-weight: 700; font-size: 12.5px; color: #444; cursor: pointer; user-select: none; margin: 0; background: #fff; }
	.pl-chip input { margin: 0; cursor: pointer; }
	.pl-chip .cnt { background: rgba(17,17,17,.08); border-radius: 999px; padding: 0 7px; font-size: 11px; }
	.pl-chip.on { border-color: #0b6e8a; background: #eef9fc; color: #0b6e8a; }
	.pl-chip.alert.on { border-color: #a32020; background: #fdeaea; color: #a32020; }
	.pl-top { overflow-x: auto; overflow-y: hidden; height: 12px; }
	.pl-top div { height: 1px; }
	.pl-scroll { max-height: 70vh; overflow: auto; }
	.pl-scroll thead th { position: sticky; top: 0; z-index: 3; box-shadow: 0 1px 0 rgba(17,17,17,.1); }
	.pl-sort { background: none; border: 0; padding: 0 0 0 3px; color: #9aa4ac; font-size: 10px; cursor: pointer; }
	.pl-sort.on { color: #0b6e8a; }
	#lBody tr.pl-child td { background: #fff8e8; font-size: 12px; }
	/* 체크한 사람: 줄 위아래 진한 파란 테두리 + 옅은 파란 바탕(보기용, 저장 안 함) */
	#lBody tr.pl-picked > td { box-shadow: inset 0 2px 0 #1d4ed8, inset 0 -2px 0 #1d4ed8; background-color: #eef4ff; }
	#lBody tr.pl-picked > td:first-child { box-shadow: inset 3px 0 0 #1d4ed8, inset 0 2px 0 #1d4ed8, inset 0 -2px 0 #1d4ed8; }
	.pl-pick-col { width: 28px; text-align: center; }
	/* 매출단가 강조(투입현황과 같게)와 일할 표시 */
	#lHead th.pl-sale, #lBody td.pl-sale { background-color: #e7f6ec; color: #17692f; font-weight: 700; }
	#lHead th.pl-sale { box-shadow: inset 0 3px 0 #2e9e57; }
	#pickCnt { font-size: 12px; font-weight: 700; color: #1d4ed8; }
	/* 외부 매입: 매입처에 주는 돈(급여 아님) */
	#lBody td.pl-buy, #lBody tr.pl-other td.dp-num { color: #8a4b00 !important; }
	/* 돈 흐름 카드: 외부(고객사 직접)·급여·기타·수수료 */
	.pl-flow { width: 470px; max-width: 92vw; background: #fff; border: 1px solid #dfe5ea; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,0,0,.18); overflow: hidden; font-size: 13px; color: #15191d; }
	.pl-flow .top { padding: 11px 15px; display: flex; justify-content: space-between; align-items: baseline; border-bottom: 1px solid #dfe5ea; } .pl-flow .top b { font-size: 14.5px; } .pl-flow .top span { color: #5f6b75; font-size: 12px; }
	.pl-flow .sec { padding: 11px 15px; } .pl-flow .sec-t { font-size: 11.5px; font-weight: 700; color: #5f6b75; margin-bottom: 7px; }
	.pl-flow .bar { display: flex; height: 12px; border-radius: 6px; overflow: hidden; margin-bottom: 8px; } .pl-flow .bar i { display: block; }
	.pl-flow .ln { display: grid; grid-template-columns: 1fr auto; gap: 1px 10px; padding: 6px 0; border-top: 1px dashed #edf0f2; } .pl-flow .ln:first-of-type { border-top: 0; }
	.pl-flow .ln .w { font-weight: 700; } .pl-flow .ln .a { font-weight: 700; text-align: right; font-variant-numeric: tabular-nums; } .pl-flow .ln .h { grid-column: 1 / -1; color: #5f6b75; font-size: 12px; white-space: normal; }
	.pl-flow .to { color: #5f6b75; font-size: 12px; font-weight: 400; margin-left: 6px; }
	.pl-flow .tot { display: flex; justify-content: space-between; align-items: baseline; padding: 10px 15px; background: #111; color: #fff; font-weight: 700; } .pl-flow .tot b { font-size: 17px; font-variant-numeric: tabular-nums; }
	.fl-tag { display: inline-block; border-radius: 10px; padding: 0 7px; font-size: 11px; font-weight: 700; margin-right: 4px; }
	.fl-DIR { background: #e6f4e3; color: #2f6b2f; } .fl-PAY { background: #e3f4f9; color: #0b6e8a; } .fl-ETC { background: #fdf0dd; color: #8a4b00; } .fl-FEE { background: #f1e9fa; color: #6b3fa0; }
	.fb-DIR { background: #7cc27a; } .fb-PAY { background: #4fb3cf; } .fb-ETC { background: #e7a24a; } .fb-FEE { background: #a57bd6; }
	#dpInfoBody .pl-flow { width: 100%; box-shadow: none; }
	/* 중복계약: 왼쪽 주황 띠 + 펼치는 버튼 */
	#lBody tr.pl-dup > td:first-child { box-shadow: inset 4px 0 0 #e0a800; }
	.pl-dup-arrow { border: 0; background: none; padding: 0 4px 0 0; color: #b07d00; font-size: 11px; cursor: pointer; }
	.pl-dup-arrow:focus { outline: 2px solid #16d5ff; border-radius: 3px; }
	/* 수습기간 열: 접으면 좁게(수습 중이면 점만), 펴면 기간 */
	.pl-prob-btn { border: 0; background: none; padding: 0; color: #0b6e8a; font-weight: 700; font-size: 12px; cursor: pointer; white-space: nowrap; }
	#lBody td.pl-prob { color: #5f6b75; font-size: 12px; text-align: center; }
	#ledger:not(.show-prob) #lBody td.pl-prob .full, #ledger.show-prob #lBody td.pl-prob .dot { display: none; }
	#lBody td.pl-prob .dot { color: #0b6e8a; }
	#lBody td.pl-type { color: #444; }
	#lBody tr.pl-child td.pl-type::before { content: '└ '; color: #8a949c; }
	.pl-btn { border: 1px solid #b9dbe6; background: #f3fbfd; color: #0b6e8a; border-radius: 10px; padding: 0 7px; font-size: 11.5px; font-weight: 700; }
	.pl-btn.zero { opacity: .55; font-weight: 400; }
	.pl-x { border: 0; background: none; padding: 0 0 0 3px; color: inherit; opacity: .6; font-size: 11px; }
	.pl-x:hover, .pl-x:focus { opacity: 1; }
	.pl-two { display: grid; grid-template-columns: 1fr 1fr; border: 1px solid rgba(17,17,17,.08); border-radius: 8px; overflow: hidden; }
	.pl-two > div + div { border-left: 1px solid rgba(17,17,17,.08); }
	.pl-line { display: flex; justify-content: space-between; align-items: center; padding: 3px 14px; font-variant-numeric: tabular-nums; min-height: 28px; }
	.pl-line.h { background: #fafbfc; font-weight: 700; border-bottom: 1px solid rgba(17,17,17,.06); }
	.pl-line.t { font-weight: 700; border-top: 1px solid rgba(17,17,17,.08); background: #f6f8fa; }
	.pl-line .hr-cell { min-width: 110px; text-align: right; }
	.pl-netbar { display: flex; justify-content: space-between; align-items: center; padding: 10px 14px; background: #111; color: #fff; font-weight: 700; border-radius: 8px; margin-top: 10px; }
	.pl-netbar b { font-size: 19px; font-variant-numeric: tabular-nums; }
	.pl-card th { width: 15%; background: #f6f8fa; color: #5f6b75; font-weight: 600; }
	.pl-feed .it { border: 1px solid rgba(17,17,17,.1); border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; white-space: pre-wrap; }
	.pl-feed .who { font-size: 11.5px; color: #5f6b75; display: flex; gap: 8px; align-items: center; white-space: normal; }
	@media (max-width: 900px) { .pl-two { grid-template-columns: 1fr; } }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header d-flex flex-wrap align-items-center" style="gap:8px">
					<h3 class="card-title bTitle"><b>급여관리</b></h3>
					<div class="ml-auto d-flex align-items-center flex-wrap" style="gap:6px">
						<button type="button" class="btn btn-sm btn-outline-secondary" id="prevYm" aria-label="이전 달">◀</button>
						<input type="month" id="ym" class="form-control form-control-sm" style="width:150px" aria-label="급여 월">
						<button type="button" class="btn btn-sm btn-outline-secondary" id="nextYm" aria-label="다음 달">▶</button>
						<label class="mb-0 small text-muted" for="payDt">지급일자</label>
						<input type="date" id="payDt" class="form-control form-control-sm" style="width:150px">
						<span class="dp-pill" id="status"></span>
						<button type="button" class="btn btn-sm btn-outline-secondary" id="btnImport">공제 불러오기</button>
						<button type="button" class="btn btn-sm btn-primary" id="btnClose"></button>
					</div>
				</div>
				<div class="card-body">
					<button type="button" class="btn btn-link p-0 mb-1" id="kpiToggle" aria-controls="kpis"></button>
					<div class="dp-kpis" id="kpis"></div>
					<div class="cal-panel pl-ledger" id="ledger">
						<div class="d-flex flex-wrap align-items-center pr-3">
							<div class="pl-chks" id="chks" role="group" aria-label="보기 구분"></div>
							<div class="ml-auto d-flex align-items-center" style="gap:6px">
								<span id="pickCnt" role="status"></span>
								<button type="button" class="btn btn-sm t-allow" data-t="show-allow" aria-pressed="false">수당 펼치기</button>
								<button type="button" class="btn btn-sm t-ded" data-t="show-ded" aria-pressed="false">공제 펼치기</button>
								<button type="button" class="btn btn-sm t-pl" data-t="show-pl" aria-pressed="false">손익 펼치기</button>
							</div>
						</div>
						<div class="pl-top" id="topScroll" aria-hidden="true"><div></div></div>
						<div class="pl-scroll" id="mainScroll">
							<table class="table table-sm cal-table mb-0">
								<thead id="lHead"></thead>
								<tbody id="lBody"></tbody>
							</table>
						</div>
						<div class="small text-muted px-3 py-2"><span class="pl-key-edit">점선 밑줄 칸</span>은 눌러서 고칠 수 있고, 머리글에 🧮 가 있는 칸은 자동 계산입니다(🧮 에 올리면 계산식, 누르면 계산 기준값을 고칩니다. 기본·식대 말고는 칸을 직접 고칠 수 없습니다)(형태·고객사·프로젝트·근무기간·매출단가는 투입현황에서 고칩니다). 칸을 누르면 바로 고치고 수정이력에 남습니다(되돌리기는 ✎ 이력에서). 노란 칸은 자동계산을 사람이 고친 값입니다. 색 띠나 같은 색 버튼으로 칸을 펼칩니다. 확인 사항 ✕ 는 확인 완료로 숨깁니다.</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="detailModal" tabindex="-1" role="dialog" aria-labelledby="detailTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="detailTitle">직원 상세</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="cate-tabs" id="detailTabs" role="tablist" aria-label="상세 구분"></div>
				<div class="modal-body pt-0" id="detailBody"></div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="importModal" tabindex="-1" role="dialog" aria-labelledby="importTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="importTitle">공제 불러오기</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<label for="importFiles" class="small">급여대장·사업소득대장 파일(.xls)을 함께 골라 주세요. 사번·코드로 직원을 연결하고, 공제만 반영합니다. 지급액은 대조만 합니다.</label>
					<input type="file" id="importFiles" class="form-control-file" accept=".xls,.xlsx" multiple>
					<div id="importResult" class="mt-3"></div>
				</div>
				<div class="modal-footer"><button type="button" class="btn btn-sm btn-primary" id="btnApply" disabled>반영</button></div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="reopenModal" tabindex="-1" role="dialog" aria-labelledby="reopenTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="reopenTitle">마감 해제</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<form onsubmit="reopen(); return false;">
					<div class="modal-body"><label for="reopenReason">해제 사유 (이력에 남습니다)</label><textarea id="reopenReason" class="form-control form-control-sm" rows="3" required></textarea></div>
					<div class="modal-footer"><button type="submit" class="btn btn-sm btn-primary">해제</button></div>
				</form>
			</div>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>

	<script>
	var TYPE_NM = hrCodeMap('HR_EMP_TYPE');
	// 체크 칩: [키, 이름, 고용형태들]. 고용형태는 공통코드(HR_EMP_TYPE) 순서·이름대로, 코드에 없는 형태는 '코드 없음'
	var CHIPS = [['_FLAG', '확인 필요']].concat(hrAllCodes('HR_EMP_TYPE').map(function(c) { return [c.CD, c.NM, [c.CD]]; })).concat([['_NONE', '코드 없음', []]]);
	var ALLOW = [['MEAL_AMT', '식대'], ['RESEARCH_AMT', '연구비'], ['DRIVE_AMT', '운전보조'], ['CHILD_AMT', '자녀보육'], ['BONUS_AMT', '상여'], ['FUEL_AMT', '유류비']];
	var DED = [['NP_AMT', '국민연금'], ['HI_AMT', '건강보험'], ['LTC_AMT', '장기요양'], ['EI_AMT', '고용보험'], ['ACC_AMT', '산재'], ['IT_AMT', '소득세'], ['LIT_AMT', '지방소득세'], ['_SETTLE', '정산'], ['MUTUAL_AMT', '상조회비'], ['ETC_DED', '기타공제']];
	var SETTLES = ['NP_SETTLE', 'HI_SETTLE', 'EI_SETTLE', 'LTC_SETTLE', 'IT_SETTLE', 'LIT_SETTLE'];
	// 자동 계산 칸: 머리글 🧮 에 마우스를 올리면 계산식, 누르면 계산 기준값. [계산식 줄들, 쓰는 기준값]
	var CALC = {
		BASE_AMT: [['계약 단가 = 이 계약으로 이번 달 나가는 금액', '정규 = 계약단가 − 식대', '수습 = 수습급여 (입사 첫 달·수습해제 달은 일할)', '그 외 = (계약단가 ÷ 월 일수) × 근무일수', '다른 계약(정규 직원의 기타·외부 계약) 줄은 매입처에 주는 돈 · 우리 급여·명세서에 안 들어감', '칸을 눌러 고치면 노란 칸(수기)으로 고정'], ['PROBATION_PAY', 'MEAL', 'PRORATE_UNIT']],
		MEAL_AMT: [['정규 = 식대', '수습 = 0 (수습해제 달은 해제 뒤 날짜만 일할)', '칸을 눌러 고치면 노란 칸(수기)으로 고정'], ['MEAL']],
		PAY_TOTAL: [['지급계 = 기본 + 수당 칸 합']], DED_TOTAL: [['공제계 = 공제 칸 + 정산 칸 합']], _SETTLE: [['정산 = 국민연금·건강·고용·장기요양·소득세·지방소득세 정산 합', '칸별 정산은 성명을 눌러 상세에서 고칩니다']],
		NET: [['실지급 = 지급계 − 공제계']], DELTA_PCT: [['전월대비 = (이번 달 실지급 − 전월 실지급) ÷ 전월 실지급']],
		REAL_SALE: [['실매출 = (매출단가 ÷ 월 일수) × 근무일수'], ['PRORATE_UNIT']],
		COMPANY: [['회사부담 = 4대보험 회사분 + 퇴직금 적립 (정규·수습만)', '퇴직금 적립 = (기본 + 식대 + 연구비 + 유류비 + 상여) ÷ 10']],
		BUY: [['기타 = 본인 계약이 있는 사람에게 함께 걸린 기타계약·외부기타 몫 (업체에 주는 돈, 급여 아님)', '= (계약단가 ÷ 월 일수) × 근무일수'], ['PRORATE_UNIT']],
		FEE: [['수수료 = 본인 계약이 있는 사람에게 함께 걸린 외부수수료(MCS) 몫 (업체에 주는 돈, 급여 아님)', '= (계약단가 ÷ 월 일수) × 근무일수'], ['PRORATE_UNIT']],
		PROFIT: [['영업이익 = 실매출 − 지급계 − 회사부담 − 기타 − 수수료']]
	};
	var PARAMS = [];
	var LABEL = { CLOSE: '마감', REOPEN: '마감 해제', MEMO: '메모', BONUS: '상여 적용', BONUS_EXCLUDE: '상여 제외' };
	DP_PAY.concat(DP_DED).forEach(function(d) { LABEL[d[0]] = d[1]; });
	var ym = moment().format('YYYY-MM'), rows = [], monthClosed = false, shown = {}, checked = {}, sortKey = 'STAFF_NM', sortDir = 1, detailTab = 0, detailRow = null;
	CHIPS.forEach(function(c) { checked[c[0]] = true; });
	// 행 체크: 보기용 표시. 서버에 저장하지 않고 달을 바꾸면 풀린다
	var picked = {}, pickedYm = ym;
	function paintPicked() {
		var n = Object.keys(picked).length, $boxes = $('#lBody .pl-pick');
		$('#pickCnt').text(n ? '✔ ' + n + '명 체크' : '');
		$('#pickAll').prop({ checked: $boxes.length > 0 && $boxes.filter(':checked').length === $boxes.length, indeterminate: $boxes.filter(':checked').length > 0 && $boxes.filter(':not(:checked)').length > 0 });
	}
	$(document).on('change', '#lBody .pl-pick', function() {
		if (this.checked) picked[this.value] = true; else delete picked[this.value];
		$('#lBody tr[data-sq="' + this.value + '"]').toggleClass('pl-picked', this.checked);
		paintPicked();
	});
	$(document).on('change', '#pickAll', function() { var on = this.checked; $('#lBody .pl-pick').each(function() { if (this.checked !== on) $(this).prop('checked', on).trigger('change'); }); });

	$(function() {
		$('#ym').val(ym).on('change', function() { if (this.value) { ym = this.value; load(); } });
		$('#prevYm').on('click', function() { step(-1); });
		$('#nextYm').on('click', function() { step(1); });
		$('#payDt').on('change', function() { if (this.value) hrPost('/admin/pay/payDateData.do', { YM: ym, PAY_DT: this.value }, function() {}); });
		$('#btnClose').on('click', function() {
			if (monthClosed) { $('#reopenReason').val(''); $('#reopenModal').modal('show'); return; }
			bootbox.confirm(dpYmLabel(ym) + ' 급여를 마감할까요? 마감하면 금액을 고칠 수 없습니다.', function(ok) {
				if (ok) hrPost('/admin/pay/closeData.do', { YM: ym, CLOSE: true }, load);
			});
		});
		$('#btnImport').on('click', function() { $('#importFiles').val(''); $('#importResult').empty(); $('#btnApply').prop('disabled', true); $('#importModal').modal('show'); });
		$('#importFiles').on('change', preview);
		$('#btnApply').on('click', apply);
		$('#chks').on('change', 'input.pl-chk', function() { checked[this.value] = this.checked; render(); });
		$('#chks').on('click', '#chkAll', function() {
			var all = CHIPS.every(function(c) { return checked[c[0]]; });
			CHIPS.forEach(function(c) { checked[c[0]] = !all; });
			render();
		});
		// 위 스크롤 막대와 표 스크롤을 서로 맞춘다
		$('#topScroll').on('scroll', function() { $('#mainScroll').scrollLeft(this.scrollLeft); });
		$('#mainScroll').on('scroll', function() { $('#topScroll').scrollLeft(this.scrollLeft); });
		$('#detailTabs').on('click', '.cate-tab', function() { detailTab = +$(this).attr('data-tab'); renderDetail(); });
		// 위쪽 합계 카드 접기. 이 브라우저에만 기억한다
		var kpiOpen = true;
		try { kpiOpen = localStorage.getItem('payKpi') !== 'off'; } catch (e) {}
		function paintKpi() { $('#kpis').toggle(kpiOpen); $('#kpiToggle').attr('aria-expanded', kpiOpen).text(kpiOpen ? '합계 ▾ 접기' : '합계 ▸ 펼치기'); }
		$('#kpiToggle').on('click', function() { kpiOpen = !kpiOpen; try { localStorage.setItem('payKpi', kpiOpen ? 'on' : 'off'); } catch (e) {} paintKpi(); });
		paintKpi();
		load();
		loadParams();
	});

	function step(d) { ym = moment(ym + '-01').add(d, 'months').format('YYYY-MM'); $('#ym').val(ym); load(); }

	function load(after) {
		hrPost('/admin/pay/monthData.do', { YM: ym }, function(res) {
			rows = res.result.rows;
			monthClosed = res.result.closed;
			// 시크릿 계정에게만 서버가 secretViewer 와 시크릿 행(SECRET)을 준다
			if (res.result.secretViewer && CHIPS[0][0] !== '_SECRET') { CHIPS.unshift(['_SECRET', '🔒 시크릿']); checked._SECRET = true; }
			$('#payDt').val(res.result.PAY_DT || '');
			render();
			if (after) after();
		});
	}

	function sum(list, k) { return list.reduce(function(s, r) { return s + Number(r[k] || 0); }, 0); }
	function isManual(r, f) { return (',' + (r.MANUAL_FIELDS || '') + ',').indexOf(',' + f + ',') >= 0; }
	function typeOf(d) { return d.DEPLOY_TYPE || ''; }
	function chipOf(type) { var c = CHIPS.filter(function(c) { return c[2] && c[2].indexOf(type) >= 0; })[0]; return c ? c[0] : '_NONE'; }
	function typesOf(r) { return [r.EMP_TYPE_CD].concat(r.DETAILS.map(typeOf)).filter(Boolean); }
	function visible(r) {
		if (r.SECRET) return !!checked._SECRET;
		if (checked._FLAG && r.FLAGS.length) return true;
		return typesOf(r).some(function(t) { return checked[chipOf(t)]; });
	}
	// 중복계약 줄은 기본으로 접는다. 사람별로 누른 상태가 '모두 접기/펼치기'보다 우선
	// 같은 달 다른 계약 줄은 기본으로 접고, 성명 앞 작은 화살표로 사람별로 편다
	var openDup = {};
	function isOpen(r) { return !!openDup[r.STAFF_SQ]; }
	// 수습기간 열 접기. 이 브라우저에 기억한다
	var probOpen = false;
	try { probOpen = localStorage.getItem('payProb') === 'on'; } catch (e) {}
	$(document).on('click', '#probToggle', function() { probOpen = !probOpen; try { localStorage.setItem('payProb', probOpen ? 'on' : 'off'); } catch (e) {} render(); });
	// 체크한 형태의 계약이 윗줄. 둘 다면 정규·수습 먼저
	function contracts(r) {
		var ds = r.DETAILS.slice(), sal = ds.filter(function(d) { var t = typeOf(d) || r.EMP_TYPE_CD; return t === 'REGULAR' || t === 'PROBATION'; });
		// 수습→정규 전환은 한 계약: 최근 건 하나로 묶고 기간·일수는 합친다
		if (dpProbReg(sal.map(typeOf))) {
			sal.sort(function(a, b) { return String(a.START_DT).localeCompare(String(b.START_DT)); });
			var last = sal[sal.length - 1];
			ds = ds.filter(function(d) { return sal.indexOf(d) < 0; }).concat($.extend({}, last, { START_DT: sal[0].START_DT, WORK_DAYS: sum(sal, 'WORK_DAYS'), BASE_AMT: sum(sal, 'BASE_AMT'), REAL_SALE: sum(sal, 'REAL_SALE') }));
		}
		// 우리 계약이 늘 윗줄, 다른 계약(매입)은 아래 └ 줄
		function score(d) { var t = typeOf(d) || r.EMP_TYPE_CD; return (isOther(r, d) ? 4 : 0) + (checked[chipOf(t)] ? 0 : 2) + (t === 'REGULAR' || t === 'PROBATION' ? 0 : 1); }
		return ds.sort(function(a, b) { return score(a) - score(b); });
	}
	function period(d) {
		if (!Number(d.WORK_DAYS)) return '대기';
		var first = moment(ym + '-01'), last = first.clone().endOf('month');
		var s = moment(d.START_DT).isAfter(first) ? moment(d.START_DT) : first, e = d.END_DT && moment(d.END_DT).isBefore(last) ? moment(d.END_DT) : last;
		return s.format('MM/DD') + '~' + e.format('MM/DD') + ' (' + d.WORK_DAYS + '일)';
	}

	var SORT = {
		STAFF_NM: function(r) { return r.STAFF_NM; }, DUP: function(r) { return contracts(r).length; }, TYPE: function(r) { return TYPE_NM[r.EMP_TYPE_CD] || ''; },
		CLIENT: function(r) { return (contracts(r)[0] || {}).CLIENT_NM || ''; }, PRJ: function(r) { return (contracts(r)[0] || {}).PRJ_NM || ''; },
		PERIOD: function(r) { return (contracts(r)[0] || {}).START_DT || ''; }, FLAGS: function(r) { return r.FLAGS.length; }
	};
	function sortVal(r) { var f = SORT[sortKey]; var v = f ? f(r) : r[sortKey]; return v === undefined || v === null ? '' : v; }

	function render() {
		$('#status').text(monthClosed ? '마감' : '작성중').attr('class', 'dp-pill ' + (monthClosed ? 'ok' : 'warn'));
		$('#btnClose').text(monthClosed ? '마감 해제' : '마감');
		$('#btnImport').prop('disabled', monthClosed);
		var list = rows.filter(visible);
		var kp = [['지급 합계', sum(list, 'PAY_TOTAL')], ['공제 합계', sum(list, 'DED_TOTAL')], ['실지급 합계', sum(list, 'NET')], ['기타 합계', sum(list, 'BUY')], ['수수료 합계', sum(list, 'FEE')], ['영업이익', sum(list, 'PROFIT')], ['확인 필요', list.filter(function(r) { return r.FLAGS.length; }).length, 'bad']];
		$('#kpis').empty().append(kp.map(function(k) { return $('<div class="dp-kpi">').addClass(k[2] || '').append($('<span>').text(k[0])).append($('<b>').text(dpWon(k[1]))); }));
		renderChips();
		renderLedger(list);
	}

	function renderChips() {
		var all = CHIPS.every(function(c) { return checked[c[0]]; });
		var $c = $('#chks').empty().append($('<button type="button" class="btn btn-sm btn-outline-secondary" id="chkAll">').text(all ? '☑ 전체 해제' : '☐ 전체 선택'));
		CHIPS.forEach(function(c) {
			var n = c[0] === '_SECRET' ? rows.filter(function(r) { return r.SECRET; }).length : c[0] === '_FLAG' ? rows.filter(function(r) { return r.FLAGS.length; }).length : rows.filter(function(r) { return typesOf(r).some(function(t) { return chipOf(t) === c[0]; }); }).length;
			if (c[0] === '_NONE' && !n) return;
			$c.append($('<label class="pl-chip">').toggleClass('on', !!checked[c[0]]).toggleClass('alert', c[0] === '_FLAG').toggleClass('secret', c[0] === '_SECRET')
				.append($('<input type="checkbox" class="pl-chk">').val(c[0]).prop('checked', !!checked[c[0]])).append($('<span>').text(c[1])).append($('<span class="cnt">').text(n)));
		});
	}

	// 자동 계산 머리글의 작은 계산기 버튼
	function calcBtn(key, text) {
		var c = CALC[key], $b = $('<button type="button" class="pl-calc-btn">').attr('aria-label', text + ' 계산식 보기 · 누르면 계산 기준값').text('🧮');
		dpHover($b, $b, function() {
			var ps = (c[1] || []).map(function(k) { return PARAMS.filter(function(p) { return p.PARAM_K === k; })[0]; }).filter(Boolean);
			return '<div class="dp-card sm"><div class="dp-card-top">' + dpEsc(text) + '<span>자동 계산 항목</span></div><div class="dp-sec">'
				+ c[0].map(function(l) { return '<div><span style="white-space:normal">' + dpEsc(l) + '</span></div>'; }).join('') + '</div>'
				+ (ps.length ? '<div class="dp-sec"><div class="s"><span>쓰는 기준값</span><span></span></div>' + ps.map(function(p) { return dpLine(p.NM, dpWon(p.PARAM_V)); }).join('') + '</div>' : '')
				+ '<div class="dp-sec"><div><span class="dp-mute">누르면 계산 기준값을 보고 고칩니다</span><span></span></div></div></div>';
		});
		return $b.on('click', function(e) { e.stopPropagation(); dpHide(); paramPopup(text, c); });
	}

	// 계산 기준값 창: 고치면 마감 안 된 달을 열 때 다시 계산된다(마감된 달은 그대로)
	function paramPopup(text, c) {
		var $box = $('<div>').append($('<div class="small mb-2">').append($('<b>').text(text + ' 계산식')).append(c[0].map(function(l) { return $('<div class="text-muted">').text(l); })));
		var $t = $('<table class="table table-sm cal-table mb-1">').append('<thead><tr><th>계산 기준값</th><th class="dp-num">값</th><th>마지막 수정</th><th></th></tr></thead>'), $b = $('<tbody>').appendTo($t);
		PARAMS.forEach(function(p) {
			var $in = $('<input class="form-control form-control-sm text-right" inputmode="numeric" style="width:130px;display:inline-block">').attr('aria-label', p.NM).val(Number(p.PARAM_V).toLocaleString('ko-KR'));
			var $save = $('<button type="button" class="btn btn-sm btn-primary">저장</button>').on('click', function() {
				bootbox.confirm(p.NM + '을(를) ' + dpWon(p.PARAM_V) + ' → ' + $in.val() + ' 으로 바꿀까요? 마감 안 된 달을 열 때 다시 계산되고, 마감된 달은 그대로입니다.', function(ok) {
					if (ok) hrPost('/admin/pay/saveParamData.do', { PARAM_K: p.PARAM_K, PARAM_V: $in.val() }, function() { loadParams(function() { $('#dpInfo').modal('hide'); load(); }); });
				});
			});
			$in.on('keydown', function(e) { if (e.key === 'Enter') { e.preventDefault(); $save.click(); } });
			$b.append($('<tr>').toggleClass('table-info', (c[1] || []).indexOf(p.PARAM_K) >= 0).append($('<td>').text(p.NM)).append($('<td class="dp-num">').append($in))
				.append($('<td class="small text-muted">').text(p.UPDT_DT ? (p.EMPLY_NM || p.UPDT_EMPLY_ID) + ' · ' + p.UPDT_DT : '기본값')).append($('<td>').append($save)));
		});
		$b.append('<tr class="text-muted"><td>퇴직금 적립 비율</td><td class="dp-num">1/10</td><td class="small" colspan="2">고정 · 바꾸면 마감된 달의 영업이익까지 바뀌어 막아 두었습니다</td></tr>');
		dpInfo('🧮 계산 기준값', $box.append($t).append('<div class="small text-muted">파란 줄은 이 칸 계산에 쓰는 값입니다. 바꾼 내용은 수정이력(직원 없음)에 남습니다.</div>'));
	}

	function loadParams(done) { hrPost('/admin/pay/paramData.do', {}, function(res) { PARAMS = res.result || []; if (done) done(); }); }

	function sortTh(text, key, cls) {
		var on = sortKey === key;
		return $('<th>').addClass(cls || '').text(text).prepend(CALC[key] ? calcBtn(key, text) : '').append($('<button type="button" class="pl-sort">').toggleClass('on', on).attr('aria-label', text + ' 정렬').text(on ? (sortDir > 0 ? '▲' : '▼') : '↕')
			.on('click', function() { if (sortKey === key) sortDir = -sortDir; else { sortKey = key; sortDir = 1; } render(); }));
	}

	function renderLedger(list) {
		if (pickedYm !== ym) { picked = {}; pickedYm = ym; }
		var bands = $('<tr class="pl-bands">').append('<th colspan="9"></th>')
			.append(band('show-allow', 'allow', '수당', ALLOW.length)).append(band('show-ded', 'ded', '공제', DED.length)).append('<th colspan="2"></th>')
			.append(band('show-pl', 'pl', '손익', 5)).append('<th colspan="3"></th>');
		var $h = $('<tr>').append($('<th class="pl-pick-col">').append($('<input type="checkbox" id="pickAll" aria-label="보이는 사람 모두 체크">')))
			.append(sortTh('성명', 'STAFF_NM')).append(sortTh('형태', 'TYPE')).append(sortTh('고객사', 'CLIENT')).append(sortTh('프로젝트', 'PRJ'))
			.append(sortTh('근무기간', 'PERIOD')).append($('<th>').append($('<button type="button" class="pl-prob-btn" id="probToggle">').attr('aria-expanded', probOpen).text(probOpen ? '수습기간 ▾' : '수습 ▸')))
			.append(sortTh('매출단가', 'SALE_PRICE', 'dp-num pl-sale')).append(sortTh('계약 단가', 'BASE_AMT', 'dp-num'));
		ALLOW.forEach(function(a) { $h.append(sortTh(a[1], a[0], 'dp-num x-allow')); });
		$h.append(sortTh('지급계', 'PAY_TOTAL', 'dp-num c-allow pl-calc-h'));
		DED.forEach(function(a) { $h.append(a[0] === '_SETTLE' ? $('<th class="dp-num x-ded pl-calc-h">').text(a[1]).prepend(calcBtn('_SETTLE', a[1])) : sortTh(a[1], a[0], 'dp-num x-ded')); });
		$h.append(sortTh('공제계', 'DED_TOTAL', 'dp-num c-ded pl-calc-h')).append(sortTh('실지급', 'NET', 'dp-num pl-calc-h')).append(sortTh('전월대비', 'DELTA_PCT', 'dp-num pl-calc-h')).append('<th class="pl-stub"></th>');
		[['실매출', 'REAL_SALE'], ['기타', 'BUY'], ['수수료', 'FEE'], ['회사부담', 'COMPANY'], ['영업이익', 'PROFIT']].forEach(function(t) { $h.append(sortTh(t[0], t[1], 'dp-num x-pl pl-calc-h')); });
		$h.append(sortTh('확인 사항', 'FLAGS')).append('<th>메모</th><th>이력</th>');
		$('#lHead').empty().append(bands).append($h);
		var $b = $('#lBody').empty();
		list.sort(function(a, b) {
			var x = sortVal(a), y = sortVal(b);
			return (b.SECRET ? 1 : 0) - (a.SECRET ? 1 : 0) || sortDir * (typeof x === 'number' && typeof y === 'number' ? x - y : String(x).localeCompare(String(y), 'ko', { numeric: true }));
		});
		if (!list.length) $b.append('<tr><td colspan="40" class="text-center text-muted py-4">해당하는 급여가 없습니다. 체크를 바꾸거나, 투입현황에 투입을 등록하면 자동으로 생깁니다.</td></tr>');
		list.forEach(function(r) {
			// 다른 계약(정규 직원의 기타·외부 계약)은 우리 급여가 아니다: 줄을 따로 두고 지급계·실지급도 그 줄에 따로 보인다
			var cs = contracts(r), dup = cs.length > 1, open = dup && isOpen(r), own = cs.filter(function(d) { return !isOther(r, d); }), span = open ? Math.max(1, own.length) : 1;
			function rs($td) { return $td.attr('rowspan', span); }
			function rsAll($td) { return $td.attr('rowspan', open ? cs.length : 1); }
			var $tr = $('<tr>').attr('data-sq', r.STAFF_SQ).toggleClass('pl-picked', !!picked[r.STAFF_SQ]).toggleClass('pl-secret', !!r.SECRET).toggleClass('pl-dup', dup)
				.append(rsAll($('<td class="pl-pick-col">')).append($('<input type="checkbox" class="pl-pick">').val(r.STAFF_SQ).prop('checked', !!picked[r.STAFF_SQ]).attr('aria-label', r.STAFF_NM + ' 체크')))
				.append(rsAll($('<td>')).append(dupArrow(r, cs)).append(r.SECRET ? $('<span title="시크릿">').text('🔒 ') : '').append($('<button type="button" class="dp-name">').text(r.STAFF_NM).on('click', function() { openDetail(r); })));
			contractCells(r, cs[0] || {}, true).forEach(function($td) { $tr.append($td); });
			$tr.append(own.length > 1 ? $('<td class="dp-num">').text(dpWon((cs[0] || {}).BASE_AMT)).prepend(baseHowBtn(r)) : cell(r, 'BASE_AMT', ''));
			ALLOW.forEach(function(a) { $tr.append(rs(cell(r, a[0], 'x-allow'))); });
			$tr.append(rs($('<td class="dp-num c-allow font-weight-bold pl-calc">').text(dpWon(r.PAY_TOTAL))));
			DED.forEach(function(a) { $tr.append(rs(a[0] === '_SETTLE' ? $('<td class="dp-num x-ded pl-calc">').text(dpWon(SETTLES.reduce(function(s, k) { return s + Number(r[k] || 0); }, 0))).attr('title', '정산 합계 · 칸별 정산은 성명을 눌러 상세에서 고칩니다') : cell(r, a[0], 'x-ded'))); });
			$tr.append(rs($('<td class="dp-num c-ded font-weight-bold pl-calc">').text(dpWon(r.DED_TOTAL)))).append(rs($('<td class="dp-num font-weight-bold pl-calc">').text(dpWon(r.NET))))
				.append(rs($('<td class="dp-num pl-calc">').text(r.DELTA_PCT === undefined ? '' : (r.DELTA_PCT > 0 ? '+' : '') + r.DELTA_PCT + '%').toggleClass('text-danger', Math.abs(r.DELTA_PCT || 0) >= 10)))
				.append(rs($('<td class="pl-stub">')))
				.append(rs($('<td class="dp-num x-pl pl-calc">').text(dpWon(r.REAL_SALE)))).append(rs($('<td class="dp-num x-pl pl-calc pl-buy">').text(Number(r.BUY) ? dpWon(r.BUY) : '—'))).append(rs($('<td class="dp-num x-pl pl-calc pl-buy">').text(Number(r.FEE) ? dpWon(r.FEE) : '—'))).append(rs($('<td class="dp-num x-pl pl-calc">').text(dpWon(r.COMPANY)))).append(rs($('<td class="dp-num x-pl font-weight-bold pl-calc">').text(dpWon(r.PROFIT))))
				.append(rs($('<td>')).append(r.FLAGS.map(function(f) { return flagChip(r, f); })))
				.append(rs($('<td>')).append(countBtn('💬', r.MEMO_CNT, r.STAFF_NM + ' 메모', function() { memoPopup(r); })))
				.append(rs($('<td>')).append(countBtn('✎', r.CHG_CNT, r.STAFF_NM + ' 수정이력', function() { historyPopup(r); })));
			$b.append($tr);
			if (open) cs.slice(1).forEach(function(d) {
				var $c = $('<tr class="pl-child pl-dup">').attr('data-sq', r.STAFF_SQ).toggleClass('pl-picked', !!picked[r.STAFF_SQ]).toggleClass('pl-secret', !!r.SECRET).append(contractCells(r, d, false));
				if (!isOther(r, d)) { $b.append($c.append($('<td class="dp-num">').text(dpWon(d.BASE_AMT)))); return; }
				// 다른 계약 줄: 계약 단가·지급계·실지급만, 수당·공제·손익 칸은 비운다
				$c.addClass('pl-other').append($('<td class="dp-num">').text(dpWon(d.BASE_AMT)).attr('title', '다른 계약 · 매입처에 주는 돈(우리 급여 아님, 급여명세서 없음)'));
				ALLOW.forEach(function() { $c.append('<td class="x-allow"></td>'); });
				$c.append($('<td class="dp-num c-allow font-weight-bold">').text(dpWon(d.BASE_AMT)));
				DED.forEach(function() { $c.append('<td class="x-ded"></td>'); });
				$c.append('<td class="c-ded"></td>').append($('<td class="dp-num font-weight-bold">').text(dpWon(d.BASE_AMT))).append('<td></td><td class="pl-stub"></td><td class="x-pl"></td><td class="x-pl"></td><td class="x-pl"></td><td class="x-pl"></td><td class="x-pl"></td><td></td><td></td><td></td>');
				$b.append($c);
			});
		});
		applyBands();
		$('#ledger').toggleClass('show-prob', probOpen);
		paintPicked();
		// 두 번째 머리글 줄은 색 띠 아래에 붙고, 위 스크롤 막대 길이는 표 너비에 맞춘다
		$('#lHead tr').eq(1).children().css('top', $('#lHead tr').eq(0).outerHeight());
		$('#topScroll div').width($('#mainScroll table').outerWidth());
		$('#topScroll').toggle($('#mainScroll table').outerWidth() > $('#mainScroll').innerWidth());
	}

	function contractCells(r, d, top) {
		var t = typeOf(d) || r.EMP_TYPE_CD, prob = probation(r, t);
		return [$('<td class="pl-type">').text(prob ? '정규' + (prob.left > 0 ? '(수습 D-' + prob.left + ')' : '') : (TYPE_NM[t] || t || '')), $('<td>').text(d.CLIENT_NM || ''),
			$('<td>').text(d.PRJ_NM || '').append(d.DEPLOY_SQ ? dpInfoBtn(r.STAFF_NM + ' 투입 정보', function() { deployInfo(r, d); }) : ''),
			$('<td>').text(d.DEPLOY_SQ ? period(d) : ''),
			$('<td class="pl-prob">').append(prob && prob.inMonth ? [$('<span class="full">').text(prob.from.format('YY/MM/DD') + '~' + prob.to.format('YY/MM/DD')), $('<span class="dot">').attr('title', '수습 ' + prob.from.format('YY/MM/DD') + '~' + prob.to.format('YY/MM/DD')).text('●')] : ''),
			saleCell(d)];
	}

	// 매출단가: 투입현황과 같은 모양(dpSaleFill). 급여의 건별 매출단가는 이미 직접계약을 뺀 값이고 일할 금액은 저장된 실매출
	function saleCell(d) {
		var $td = $('<td class="dp-num pl-sale">'), net = Number(d.SALE_PRICE || 0);
		if (!net && !Number(d.CLIENT_DIRECT_AMT)) return $td;
		return dpSaleFill($td, d, net, Number(d.WORK_DAYS || 0), Number(d.TOTAL_DAYS || 0), Number(d.REAL_SALE || 0));
	}

	// 다른 계약: 정규·수습 직원에게 함께 걸린 기타·외부 계약(매입처에 주는 돈). 우리 급여·급여명세서에 들어가지 않는다
	// 본인 계약(급여로 본인에게): 정규·수습·특고프리·사업자프리·고용보험알바. 그 밖(기타계약·외부)은 업체 몫
	var OWN = ['REGULAR', 'PROBATION', 'SPECIAL', 'BIZ', 'EMP_INS'];
	function isOwnT(t) { return OWN.indexOf(t) >= 0; }
	function isFeeT(t) { return String(t || '').indexOf('EXTERNAL_MCS') === 0; }
	function isOther(r, d) { var t = typeOf(d) || r.EMP_TYPE_CD; return !isOwnT(t) && r.DETAILS.some(function(x) { return isOwnT(typeOf(x)); }); }

	// 수습도 정규직이다. 수습 기간 = 입사일부터 3개월(마지막 날은 3개월 되는 날 전날). inMonth: 이 달과 겹침, left: 오늘부터 남은 날
	function probation(r, t) {
		if (t !== 'REGULAR' && t !== 'PROBATION') return null;
		var from = moment(r.JOIN_DT, 'YYYY-MM-DD', true);
		if (!from.isValid()) return t === 'PROBATION' ? { left: 0, inMonth: false } : null;
		var to = from.clone().add(3, 'months').subtract(1, 'days'), first = moment(ym + '-01');
		return { from: from, to: to, left: to.diff(moment().startOf('day'), 'days') + 1, inMonth: !to.isBefore(first) && !from.isAfter(first.clone().endOf('month')) };
	}

	// 다른 계약이 있으면 성명 앞에 ▸/▾. 마우스를 올리면 건별 계약
	function dupArrow(r, cs) {
		if (cs.length < 2) return '';
		var open = isOpen(r);
		var $p = $('<button type="button" class="pl-dup-arrow">').attr({ 'aria-expanded': open, 'aria-label': r.STAFF_NM + ' 다른 계약 ' + (cs.length - 1) + '건 ' + (open ? '접기' : '펼치기') }).text(open ? '▾' : '▸')
			.on('click', function() { openDup[r.STAFF_SQ] = !open; dpHide(); render(); });
		dpHover($p, $p, function() {
			return '<div class="dp-card sm"><div class="dp-card-top">중복계약 ' + cs.length + '건</div><div class="dp-sec">' + cs.map(function(d) {
				return dpLine((TYPE_NM[typeOf(d)] || '') + ' · ' + [d.CLIENT_NM, d.PRJ_NM].filter(Boolean).join(' '), dpWon(d.BASE_AMT)) + '<div><span class="dp-mute">' + dpEsc(period(d)) + '</span><span></span></div>';
			}).join('') + '</div></div>';
		});
		return $p;
	}

	function countBtn(icon, n, label, open) {
		n = Number(n || 0);
		return $('<button type="button" class="pl-btn">').toggleClass('zero', !n).attr('aria-label', label + ' ' + n + '건').text(icon + (n ? ' ' + n : '')).on('click', open);
	}

	function flagChip(r, f) {
		var $p = dpFlag(f);
		// 상여 칩의 ✕ 는 이번 달 상여 제외, 그 밖의 칩은 확인 완료(숨김)
		var bonus = f.K === '상여', what = bonus ? '이번 달 상여 제외' : '확인 완료(숨김)';
		if (!monthClosed) $p.append($('<button type="button" class="pl-x">').attr({ title: what, 'aria-label': r.STAFF_NM + ' ' + f.K + ' ' + what }).text('✕').on('click', function(e) {
			e.stopPropagation(); dpHide();
			function send() { hrPost('/admin/pay/ackData.do', { YM: ym, STAFF_SQ: r.STAFF_SQ, FLAG_K: f.K }, function() { load(); }); }
			if (!bonus) return send();
			bootbox.confirm(r.STAFF_NM + '의 ' + dpYmLabel(ym) + ' 상여 ' + dpWon(r.BONUS_AMT) + '원을 뺄까요? 수정이력과 상세의 상여 탭에 제외로 남습니다.', function(ok) { if (ok) send(); });
		}));
		return $p;
	}

	// 급여대장에 없는 투입 정보만 보인다
	function deployInfo(r, d) {
		dpInfo(r.STAFF_NM + ' 투입 정보', [['고객사 · 프로젝트', [d.CLIENT_NM, d.PRJ_NM].filter(Boolean).join(' · ')], ['매출처', d.SALE_PARTNER_NM], ['매입처', d.BUY_PARTNER_NM], ['근무지역', d.WORK_AREA], ['투입등급', d.GRADE_CD],
			['투입기간', (d.START_DT || '') + ' ~ ' + (d.END_DT || '미정')], ['수습해제일', d.PROB_END_DT], ['월 계약단가', d.COST_PRICE ? dpWon(d.COST_PRICE) : ''], ['메모', d.MEMO]]);
	}

	function band(t, cls, label, span) {
		return $('<th class="band" tabindex="0" role="button">').addClass(cls).attr({ 'data-t': t, 'data-span': span, 'data-label': label });
	}

	function applyBands() {
		$('#ledger [data-t]').each(function() {
			var t = $(this).attr('data-t'), on = !!shown[t];
			if (this.tagName === 'TH') $(this).attr({ colspan: on ? +$(this).attr('data-span') + (t === 'show-pl' ? 0 : 1) : 1, 'aria-expanded': on }).text($(this).attr('data-label') + (on ? ' ▾ 접기' : ' ▸'));
			else $(this).attr('aria-pressed', on).text($(this).text().replace(on ? '펼치기' : '접기', on ? '접기' : '펼치기'));
			$('#ledger').toggleClass(t, on);
		});
		$('#topScroll div').width($('#mainScroll table').outerWidth());
		$('#topScroll').toggle($('#mainScroll table').outerWidth() > $('#mainScroll').innerWidth());
	}

	$(document).on('click keydown', '#ledger [data-t]', function(e) {
		if (e.type === 'keydown' && e.key !== 'Enter' && e.key !== ' ') return;
		e.preventDefault();
		var t = $(this).attr('data-t');
		shown[t] = !shown[t];
		applyBands();
	});

	function cell(r, f, cls) {
		var $td = $('<td class="dp-num">').addClass(cls).toggleClass('pl-manual', isManual(r, f));
		// 기본 칸은 앞에 🧮: 올리면 이 사람의 계산 과정, 누르면 같은 내용을 창으로(칸 수정은 숫자를 누를 때)
		function paint($c, v) { $c.text(v || ''); if (f === 'BASE_AMT' && (r.BASE_HOW || []).length) $c.prepend(baseHowBtn(r)); }
		if (monthClosed) { paint($td, dpWon(r[f])); return $td; }
		return hrEditable($td, { url: '/admin/pay/saveFieldData.do', key: { YM: ym, STAFF_SQ: r.STAFF_SQ }, field: f, label: r.STAFF_NM + ' ' + (LABEL[f] || f), paint: paint,
			show: function() { return dpWon(r[f]); }, value: function() { return r[f]; }, saved: function() { load(function() { if (detailRow) refreshDetail(); }); } });
	}

	// 🧮 돈 흐름: 이 사람 몫으로 나가는 돈을 갈래별로(외부=고객사 직접, 급여, 기타, 수수료)와 총액까지
	var FLOW_NM = { DIR: '외부', PAY: '급여', ETC: '기타', FEE: '수수료' };
	function flowLines(r) {
		var out = [], cs = contracts(r), ownBase = 0, first = true;
		r.DETAILS.forEach(function(d) {
			if (!Number(d.CLIENT_DIRECT_AMT)) return;
			var nm = (hrAllCodes('HR_CLIENT_DIRECT').filter(function(c) { return c.CD === d.CLIENT_DIRECT_CD; })[0] || {}).NM || d.CLIENT_DIRECT_CD || '';
			out.push({ k: 'DIR', name: '고객사 직접계약' + (nm ? '(' + nm + ')' : ''), to: '고객사 → 본인', amt: Number(d.CLIENT_DIRECT_AMT), how: '우리 장부 밖 · 고객사가 본인에게 바로 지급' });
		});
		cs.forEach(function(d) { if (!isOther(r, d)) ownBase += Number(d.BASE_AMT || 0); });
		var extra = Number(r.PAY_TOTAL || 0) - ownBase; // 식대·수당·상여(첫 급여 줄에 붙인다)
		cs.forEach(function(d) {
			var t = typeOf(d) || r.EMP_TYPE_CD, k = isOther(r, d) ? (isFeeT(t) ? 'FEE' : 'ETC') : 'PAY', nm = TYPE_NM[t] || t || '', amt = Number(d.BASE_AMT || 0), how = d.HOW || dpWon(amt);
			var vendor = (/\(([^)]+)\)/.exec(nm) || [])[1] || d.BUY_PARTNER_NM || nm;
			if (k === 'PAY' && first) { if (extra) { how += ' + 식대·수당 ' + dpWon(extra); amt += extra; } first = false; }
			out.push({ k: k, name: nm, to: k === 'PAY' ? '이에스티 → 본인' : '이에스티 → ' + vendor, amt: amt, how: how + (k === 'PAY' ? ' · 급여명세서 있음' : ' · 급여명세서 없음') });
		});
		return out;
	}
	function flowCard(r) {
		var ls = flowLines(r), tot = ls.reduce(function(s, l) { return s + l.amt; }, 0);
		return '<div class="pl-flow"><div class="top"><b>' + dpEsc(r.STAFF_NM + ' · ' + dpYmLabel(ym) + ' 돈 흐름') + '</b><span>계약 ' + ls.length + '갈래</span></div>'
			+ '<div class="sec"><div class="sec-t">이 사람 몫으로 나가는 돈</div><div class="bar">' + ls.map(function(l) { return '<i class="fb-' + l.k + '" style="width:' + (tot ? l.amt * 100 / tot : 0) + '%"></i>'; }).join('') + '</div>'
			+ ls.map(function(l) {
				return '<div class="ln"><span class="w"><span class="fl-tag fl-' + l.k + '">' + FLOW_NM[l.k] + '</span>' + dpEsc(l.name) + '<span class="to">' + dpEsc(l.to) + '</span></span><span class="a">' + dpWon(l.amt) + '</span><span class="h">' + dpEsc(l.how) + '</span></div>';
			}).join('') + '</div><div class="tot"><span>총액 (본인 기준 한 달)</span><b>' + dpWon(tot) + '</b></div></div>';
	}
	function baseHowBtn(r) {
		var $b = $('<button type="button" class="pl-calc-btn">').attr('aria-label', r.STAFF_NM + ' 돈 흐름 보기').text('🧮');
		dpHover($b, $b, function() { return flowCard(r); });
		return $b.on('click', function(e) { e.stopPropagation(); dpHide(); dpInfo(r.STAFF_NM + ' 돈 흐름', $(flowCard(r))); });
	}

	// ── 메모 (쌓기만, 본인 것만 삭제) ──

	function memoView($box, r, done) {
		hrPost('/admin/pay/memoListData.do', { STAFF_SQ: r.STAFF_SQ, YM: ym }, function(res) {
			var $f = $('<div class="pl-feed">');
			res.result.list.forEach(function(m) {
				var $who = $('<div class="who">').append($('<b>').text(m.EMPLY_NM || m.EMPLY_ID)).append($('<span>').text(m.REG_DT));
				if (m.EMPLY_ID === res.result.me) $who.append($('<button type="button" class="btn btn-sm btn-link p-0 ml-auto text-danger">삭제</button>').on('click', function() {
					hrPost('/admin/pay/deleteMemoData.do', { MEMO_SQ: m.MEMO_SQ }, function() { memoView($box, r, done); load(); });
				}));
				$f.append($('<div class="it">').append($who).append($('<div>').text(m.CONTENT)));
			});
			if (!res.result.list.length) $f.append('<div class="text-muted small mb-2">이 달 메모가 없습니다.</div>');
			var $ta = $('<textarea class="form-control form-control-sm enter-send" rows="2" maxlength="1000" aria-label="메모 입력" placeholder="메모 입력 · Enter 등록, Shift+Enter 줄바꿈 (작성자·일시는 자동)">');
			var $add = $('<button type="button" class="btn btn-sm btn-primary mt-1">남기기</button>').on('click', function() {
				if (!$.trim($ta.val())) { $ta.focus(); return; }
				$add.prop('disabled', true);
				hrPost('/admin/pay/saveMemoData.do', { YM: ym, STAFF_SQ: r.STAFF_SQ, CONTENT: $ta.val() }, function() { memoView($box, r, function() { $box.find('textarea').focus(); }); load(); }, function() { $add.prop('disabled', false); });
			});
			$ta.on('enter-send', function() { if (!$add.prop('disabled')) $add.click(); });
			$box.empty().append($f).append($ta).append($('<div class="text-right">').append($add));
			if (done) done();
		});
	}
	function memoPopup(r) { var $box = $('<div>'); memoView($box, r, function() { dpInfo(r.STAFF_NM + ' · ' + dpYmLabel(ym) + ' 메모', $box); }); }

	// ── 수정이력 (되돌리기는 여기서만) ──

	function historyView($box, r, done) {
		hrPost('/admin/pay/changeListData.do', { STAFF_SQ: r.STAFF_SQ, YM: ym }, function(res) {
			var $t = $('<table class="table table-sm cal-table mb-0">').append('<thead><tr><th>일시</th><th>누가</th><th>칸</th><th class="dp-num">전 → 후</th><th>사유</th><th></th></tr></thead>');
			var $b = $('<tbody>').appendTo($t);
			res.result.forEach(function(h) {
				var amount = !!(DP_PAY.concat(DP_DED).some(function(d) { return d[0] === h.FIELD_NM; }));
				var $act = $('<td>');
				if (h.REVERTED_YN === 'Y') $act.append('<span class="dp-pill">되돌림됨</span>');
				else if (amount && !monthClosed) $act.append($('<button type="button" class="btn btn-sm btn-outline-secondary">↶ 되돌리기</button>').on('click', function() {
					bootbox.confirm((LABEL[h.FIELD_NM] || h.FIELD_NM) + ' 을(를) ' + dpWon(h.BEFORE_VAL) + ' 으로 되돌릴까요?', function(ok) {
						if (ok) hrPost('/admin/pay/revertData.do', { CHG_SQ: h.CHG_SQ }, function() { load(); historyView($box, r); });
					});
				}));
				$b.append($('<tr>').toggleClass('text-muted', h.REVERTED_YN === 'Y').append($('<td>').text(h.REG_DT)).append($('<td>').text(h.EMPLY_NM || h.EMPLY_ID || ''))
					.append($('<td>').text(LABEL[h.FIELD_NM] || h.FIELD_NM)).append($('<td class="dp-num">').text(h.BEFORE_VAL === null && h.AFTER_VAL === null ? '' : dpWon(h.BEFORE_VAL) + ' → ' + dpWon(h.AFTER_VAL)))
					.append($('<td>').text(h.REASON || '')).append($act));
			});
			if (!res.result.length) $b.append('<tr><td colspan="6" class="text-center text-muted py-3">이 달 수정이력이 없습니다.</td></tr>');
			$box.empty().append($('<div class="table-responsive">').append($t));
			if (monthClosed) $box.append('<div class="small text-muted mt-2">마감된 달은 되돌릴 수 없습니다.</div>');
			if (done) done();
		});
	}
	function historyPopup(r) { var $box = $('<div>'); historyView($box, r, function() { dpInfo(r.STAFF_NM + ' · ' + dpYmLabel(ym) + ' 수정이력', $box); }); }

	// ── 직원 상세 팝업 ──

	var DETAIL_TABS = ['이번 달 명세', '월별 내역', '상여', '메모', '수정이력'];
	function openDetail(r) { detailRow = r; detailTab = 0; renderDetail(); $('#detailModal').modal('show'); }
	function refreshDetail() { detailRow = rows.filter(function(x) { return x.STAFF_SQ === detailRow.STAFF_SQ; })[0] || detailRow; renderDetail(); }
	$(document).on('hidden.bs.modal', '#detailModal', function() { detailRow = null; });

	function renderDetail() {
		var r = detailRow;
		$('#detailTitle').text(r.STAFF_NM + ' · ' + dpYmLabel(ym) + (monthClosed ? ' 마감' : ' 작성중'));
		$('#detailTabs').empty().append(DETAIL_TABS.map(function(t, i) { return hrTab(i, t, i === 3 ? Number(r.MEMO_CNT || 0) : i === 4 ? Number(r.CHG_CNT || 0) : '', detailTab === i); }));
		var $body = $('#detailBody').empty();
		if (detailTab === 3) return memoView($body, r);
		if (detailTab === 4) return historyView($body, r);
		hrPost('/admin/pay/detailData.do', { STAFF_SQ: r.STAFF_SQ, YM: ym }, function(res) {
			var d = res.result;
			if (detailTab === 0) renderSlip($body, r, d.card);
			else if (detailTab === 1) renderYear($body, d.year);
			else renderBonus($body, d.bonus);
		});
	}

	function renderSlip($body, r, c) {
		$body.append('<div class="font-weight-bold mb-1">인적사항</div>').append($('<table class="table table-sm table-bordered pl-card mb-3">')
			.append($('<tr>').append('<th>성명</th>').append($('<td>').text(c.STAFF_NM || '')).append('<th>생년월일</th>').append($('<td>').text(c.BIRTH_DT || '')))
			.append($('<tr>').append('<th>직급</th>').append($('<td>').text(c.POSITION_NM || '')).append('<th>입사일</th>').append($('<td>').text(c.JOIN_DT || '')))
			.append($('<tr>').append('<th>지급일자</th>').append($('<td>').text($('#payDt').val() || '')).append('<th>부서</th>').append($('<td>').text(c.DEPT_NM || c.ORG_NM || ''))));
		function line(f, label) {
			var $v = $('<span>').toggleClass('pl-manual', isManual(r, f));
			if (monthClosed) $v.text(dpWon(r[f])); else hrEditable($v, { url: '/admin/pay/saveFieldData.do', key: { YM: ym, STAFF_SQ: r.STAFF_SQ }, field: f, label: label,
				show: function() { return dpWon(r[f]); }, value: function() { return r[f]; }, saved: function() { load(refreshDetail); } });
			return $('<div class="pl-line">').append($('<span>').text(label)).append($v);
		}
		var $pay = $('<div>').append('<div class="pl-line h"><span>지급</span></div>');
		DP_PAY.forEach(function(x) { $pay.append(line(x[0], x[1])); });
		$pay.append($('<div class="pl-line t">').append('<span>지급 합계</span>').append($('<span>').text(dpWon(r.PAY_TOTAL))));
		var $ded = $('<div>').append('<div class="pl-line h"><span>공제</span></div>');
		DP_DED.forEach(function(x) { $ded.append(line(x[0], x[1])); });
		$ded.append($('<div class="pl-line t">').append('<span>공제 합계</span>').append($('<span>').text(dpWon(r.DED_TOTAL))));
		$body.append($('<div class="pl-two">').append($pay).append($ded))
			.append($('<div class="pl-netbar">').append('<span>실지급액</span>').append($('<b>').text(dpWon(r.NET))));
	}

	function renderYear($body, year) {
		var $t = $('<table class="table table-sm cal-table mb-0">').append('<thead><tr><th>월</th><th class="dp-num">근무일</th><th class="dp-num">계약단가</th><th class="dp-num">지급계</th><th class="dp-num">공제계</th><th class="dp-num">실지급</th><th class="dp-num">영업이익</th></tr></thead>');
		var $b = $('<tbody>').appendTo($t);
		(year || []).slice().sort(function(a, b) { return b.PAY_YM.localeCompare(a.PAY_YM); }).forEach(function(m) {
			$b.append($('<tr>').toggleClass('font-weight-bold', m.PAY_YM === ym).append($('<td>').text(Number(m.PAY_YM.substring(5)) + '월'))
				.append($('<td class="dp-num">').text(m.WORK_DAYS + '/' + m.TOTAL_DAYS)).append($('<td class="dp-num">').text(dpWon(m.COST_PRICE)))
				.append($('<td class="dp-num">').text(dpWon(m.PAY_TOTAL))).append($('<td class="dp-num">').text(dpWon(m.DED_TOTAL))).append($('<td class="dp-num">').text(dpWon(m.NET)))
				.append($('<td class="dp-num">').text(dpWon(m.PROFIT))));
		});
		if (!(year || []).length) $b.append('<tr><td colspan="7" class="text-center text-muted py-3">올해 급여 기록이 없습니다.</td></tr>');
		$body.append($('<div class="table-responsive">').append($t));
	}

	function renderBonus($body, bonus) {
		var paid = bonus.filter(function(b) { return b.STATUS === '지급'; }), plan = bonus.filter(function(b) { return b.STATUS === '예정'; }), now = bonus.filter(function(b) { return b.STATUS === '이번 달'; });
		$body.append($('<div class="mb-2">').append($('<span class="dp-pill ok">').text('지급 누계 ' + dpWon(paid.reduce(function(s, b) { return s + Number(b.AMT || 0); }, 0))))
			.append($('<span class="dp-pill warn">').text('이번 달 ' + dpWon(now.reduce(function(s, b) { return s + Number(b.AMT || 0); }, 0))))
			.append($('<span class="dp-pill">').text('예정 ' + plan.length + '건')));
		var $t = $('<table class="table table-sm cal-table mb-0">').append('<thead><tr><th>지급월</th><th>상여</th><th>근거</th><th class="dp-num">금액</th><th>상태</th><th>비고</th></tr></thead>');
		var $b = $('<tbody>').appendTo($t), TONE = { '지급': 'ok', '이번 달': 'warn', '제외': 'bad', '미달': 'bad' };
		bonus.forEach(function(b) {
			var off = b.STATUS === '제외' || b.STATUS === '미달';
			$b.append($('<tr>').toggleClass('pl-manual', b.STATUS === '이번 달').toggleClass('text-muted', off).append($('<td>').text(b.YM)).append($('<td>').text(b.LABEL || ''))
				.append($('<td class="small">').text(b.BASIS || '')).append($('<td class="dp-num">').append(off ? $('<s>').text(dpWon(b.AMT)) : dpWon(b.AMT)))
				.append($('<td>').append($('<span class="dp-pill">').addClass(TONE[b.STATUS] || '').text(b.STATUS))).append($('<td class="small">').text(b.NOTE || '')));
		});
		if (!bonus.length) $b.append('<tr><td colspan="6" class="text-center text-muted py-3">상여 내역이 없습니다. 상여는 직원관리에서 켭니다.</td></tr>');
		$body.append($('<div class="table-responsive">').append($t));
	}

	// ── 공제 불러오기 ──

	var importRows = [];
	function preview() {
		var fd = new FormData();
		fd.append('YM', ym);
		$.each(this.files, function(i, f) { fd.append('files', f); });
		if (!this.files.length) return;
		$('#importResult').html('<div class="text-muted">읽는 중…</div>');
		$.ajax({ url: '/admin/pay/importPreviewData.do', type: 'POST', data: fd, processData: false, contentType: false }).done(function(res) {
			if (res.error) { $('#importResult').empty(); bootbox.alert(res.error); return; }
			importRows = res.result.rows;
			var staff = rows.map(function(r) { return [r.STAFF_SQ, r.STAFF_NM]; });
			var need = importRows.filter(function(r) { return !r.STAFF_SQ; }).length, diff = importRows.filter(function(r) { return r.STAFF_SQ && r.SYSTEM_PAY !== null && r.SYSTEM_PAY !== undefined && r.SYSTEM_PAY !== r.LEDGER_PAY; }).length;
			var $sum = $('<div class="mb-2">').append(res.result.files.map(function(f) { return $('<span class="dp-pill ok">').text((f.KIND === 'PAY' ? '급여대장 ' : '사업소득대장 ') + f.COUNT + '명 · 합계 검증 통과'); }))
				.append($('<span class="dp-pill">').text('반영 ' + (importRows.length - need))).append(need ? $('<span class="dp-pill bad">').text('직원 연결 필요 ' + need) : '').append(diff ? $('<span class="dp-pill warn">').text('지급액 차이 ' + diff) : '');
			var $tb = $('<tbody>');
			importRows.forEach(function(r, i) {
				var $res;
				if (!r.STAFF_SQ) {
					$res = $('<select class="form-control form-control-sm" style="min-width:140px">').attr({ 'data-link': i, 'aria-label': r.LEDGER_NM + ' 직원 선택' }).append('<option value="">건너뜀</option>');
					staff.forEach(function(s) { $res.append($('<option>').val(s[0]).text(s[1])); });
				} else if (r.SYSTEM_PAY === null || r.SYSTEM_PAY === undefined) {
					$res = $('<span class="dp-pill warn">').text('이번 달 급여 행 없음 · 새로 만듦');
				} else if (r.SYSTEM_PAY !== r.LEDGER_PAY) {
					$res = $('<span class="dp-pill warn">').text((r.LEDGER_PAY > r.SYSTEM_PAY ? '+' : '') + dpWon(r.LEDGER_PAY - r.SYSTEM_PAY) + ' 차이');
				} else {
					$res = $('<span class="dp-pill ok">').text('일치');
				}
				$tb.append($('<tr>').append($('<td>').text(r.LEDGER_NM)).append($('<td>').text(r.SRC_CD === 'PAY' ? '급여' : '사업소득')).append($('<td>').text(r.LEDGER_CD))
					.append($('<td class="dp-num">').text(dpWon(r.LEDGER_PAY))).append($('<td class="dp-num">').text(dpWon(r.SYSTEM_PAY))).append($('<td class="dp-num">').text(dpWon(r.LEDGER_DED)))
					.append($('<td class="dp-num">').text(dpWon(r.LEDGER_NET))).append($('<td>').append($res)));
			});
			$('#importResult').empty().append($sum).append($('<div class="table-responsive" style="max-height:50vh">').append($('<table class="table table-sm cal-table mb-0">')
				.append('<thead><tr><th>성명</th><th>대장</th><th>사번·코드</th><th class="dp-num">대장 지급</th><th class="dp-num">시스템 지급</th><th class="dp-num">공제계</th><th class="dp-num">차인지급</th><th>결과</th></tr></thead>').append($tb)))
				.append('<div class="small text-muted mt-2">공제만 반영합니다. 예술/특고인 경비는 공제가 아니어서 넣지 않습니다. 고른 직원 연결은 다음 달부터 자동으로 씁니다.</div>');
			$('#btnApply').prop('disabled', false).text((importRows.length - need) + '건 반영');
			$('#importResult select').on('change', function() {
				var n = importRows.length - need + $('#importResult select').filter(function() { return this.value; }).length;
				$('#btnApply').text(n + '건 반영');
			});
		}).fail(function() { $('#importResult').empty(); });
	}

	function apply() {
		var p = { YM: ym };
		$('#importResult [data-link]').each(function() { if (this.value) p['LINK_' + $(this).attr('data-link')] = this.value; });
		$('#btnApply').prop('disabled', true);
		hrPost('/admin/pay/importApplyData.do', p, function(res) {
			$('#importModal').modal('hide');
			bootbox.alert(res.result + '명의 공제를 반영했습니다.');
			load();
		}, function() { $('#btnApply').prop('disabled', false); });
	}

	function reopen() {
		hrPost('/admin/pay/closeData.do', { YM: ym, CLOSE: false, REASON: $('#reopenReason').val() }, function() { $('#reopenModal').modal('hide'); load(); });
	}
	</script>
</body>
</html>
