<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_head.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/deploy/deploy_common.jspf"%>
<style>
	#listHead th, #listBody td { white-space: nowrap; }
	.st-bn { display: inline-flex; align-items: center; gap: 4px; margin: 1px 4px 1px 0; }
	.st-bn .dp-pill { cursor: pointer; margin: 0; }
	.st-bn .dp-pill:focus { outline: 2px solid #16d5ff; }
	.st-bn input { width: 92px; height: 22px; font-size: 11px; padding: 0 4px; text-align: right; }
	.st-bn select { width: 100px; height: 22px; font-size: 11px; padding: 0 2px; }
	.st-bn-toggle { background: none; border: 0; padding: 0 4px; color: #888; font-size: 11px; vertical-align: middle; }
	.st-bn-toggle:hover, .st-bn-toggle:focus { color: #0b6e8a; }
	.pl-chks { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; padding: 10px 14px 0; }
	#listBody tr.st-secret-row td { background-color: #f4effc; }
	.st-name { background: none; border: 0; padding: 0; color: #0b6e8a; font-weight: 600; text-decoration: underline; cursor: pointer; }
	.st-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 2px 18px; }
	.st-grid .hr-card-label { flex-basis: 84px; }
	.st-secret { display: flex; align-items: center; gap: 4px; flex: 1 1 auto; min-width: 0; }
	.st-eye { background: none; border: 0; padding: 0 4px; color: #888; line-height: 20px; }
	.st-eye:hover, .st-eye:focus { color: #0b6e8a; }
	.st-docs { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 4px 12px; }
	.st-chip { display: inline-block; font-size: 11px; padding: 1px 8px; border-radius: 10px; background: #eef1f4; color: #444; margin: 0 4px 4px 0; }
	.st-chip b { color: #111; }
	[data-copy]:focus { outline: 2px solid #16d5ff; outline-offset: -2px; }
	/* 서류 탭: 요약 숫자 → 종류별 묶음 → 서류 한 장씩 타일. 상태색: 파일 있음(초록)·미제출(빨강)·해당없음(회색) */
	.st-dsum { display: flex; flex-wrap: wrap; gap: 12px; font-size: 12px; font-weight: 400; color: #6b7785; }
	.st-dsum span { display: inline-flex; align-items: center; gap: 4px; } .st-dsum i { width: 8px; height: 8px; border-radius: 50%; background: var(--st-c); } .st-dsum b { color: var(--st-c); font-size: 13px; }
	.st-dbar { display: flex; height: 4px; border-radius: 2px; background: #e8edf2; overflow: hidden; margin-bottom: 12px; } .st-dbar i { background: var(--st-c); }
	.st-drop { display: flex; align-items: center; gap: 14px; border: 2px dashed #b9c6d3; border-radius: 10px; background: #f7f9fb; padding: 14px 18px; margin: 0 0 16px; cursor: pointer; color: #3a4654; transition: background .15s, border-color .15s; }
	.st-drop > i { font-size: 26px; color: #8a9bab; } .st-drop b { display: block; font-size: 13px; } .st-drop small { color: #8a96a3; font-size: 11.5px; }
	.st-drop:hover { border-color: #16a0c4; }
	.st-drop.is-over { border-color: #16a0c4; border-style: solid; background: #e3f6fb; } .st-drop.is-over > i { color: #16a0c4; }
	[data-s=file] { --st-c: #1d7a4a; --st-bg: #e7f5ec; }
	[data-s=miss] { --st-c: #c0392b; --st-bg: #fdecea; } [data-s=na] { --st-c: #8a96a3; --st-bg: #f1f3f5; }
	.st-dgroup { margin-bottom: 14px; }
	.st-dgroup h6 { display: flex; align-items: center; gap: 8px; font-size: 12.5px; font-weight: 700; color: #3a4654; margin: 0 0 8px; }
	.st-dgroup h6 i { color: #0b6e8a; width: 14px; text-align: center; } .st-dgroup h6 span { font-weight: 400; color: #8a96a3; font-size: 11.5px; }
	.st-dtiles { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 8px; align-items: start; }
	.st-doc-row { display: flex; flex-direction: column; gap: 6px; border: 1px solid #e3e8ee; border-left: 3px solid var(--st-c); border-radius: 8px; padding: 7px 8px 7px 10px; background: #fff; min-width: 0; }
	.st-doc-row[data-s=na] { background: #fafbfc; } .st-doc-row[data-s=na] .st-dname { color: #8a96a3; }
	.st-doc-row.is-over { outline: 2px dashed #16a0c4; background: #e3f6fb; }
	.st-dtop { display: flex; align-items: center; gap: 8px; } .st-dname { font-size: 13px; font-weight: 600; color: #222; flex: 1 1 auto; min-width: 0; }
	.st-dstat { cursor: pointer; } .st-dstat select { height: 24px; font-size: 12px; padding: 0 4px; }
	.st-badge { display: inline-flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 600; border-radius: 999px; padding: 2px 9px; color: var(--st-c); background: var(--st-bg); white-space: nowrap; }
	.st-files { display: flex; flex-direction: column; gap: 4px; } .st-files:empty { display: none; }
	.st-file { display: flex; align-items: center; gap: 2px; background: #f3f6f8; border-radius: 6px; padding: 3px 4px 3px 8px; min-width: 0; }
	.st-file > i { color: #6b7785; font-size: 12px; margin-right: 4px; }
	.st-file a { flex: 1 1 auto; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 12px; color: #222; }
	.st-file button { background: none; border: 0; padding: 2px 5px; color: #888; font-size: 11.5px; border-radius: 4px; white-space: nowrap; flex: none; }
	.st-file button:hover, .st-file button:focus { color: #0b6e8a; background: #e3edf3; }
	.st-file .st-dl { color: #0b6e8a; font-weight: 600; }
	.st-attach { flex: none; width: 24px; height: 24px; margin: 0; border-radius: 6px; display: inline-flex; align-items: center; justify-content: center; color: #8a96a3; font-size: 11px; cursor: pointer; }
	.st-attach:hover, .st-attach:focus-within { background: #e3edf3; color: #0b6e8a; }
	.st-busy { opacity: .5; pointer-events: none; }
	/* 자동생성 기간·최대 프로젝트: 볼륨 스위치 모양 슬라이더(--p 만큼 채움) */
	.sc-vol { display: flex; align-items: center; gap: 12px; max-width: 520px; }
	.sc-vol input[type=range] { -webkit-appearance: none; appearance: none; flex: 1 1 auto; height: 8px; border-radius: 4px; cursor: pointer;
		background: linear-gradient(90deg, #0b6e8a 0, #16a0c4 var(--p, 100%), #e3e8ee var(--p, 100%)); }
	.sc-vol input[type=range]::-webkit-slider-thumb { -webkit-appearance: none; width: 20px; height: 20px; border-radius: 50%; background: #fff; border: 3px solid #0b6e8a; box-shadow: 0 1px 4px rgba(0,0,0,.25); }
	.sc-vol input[type=range]::-moz-range-thumb { width: 16px; height: 16px; border-radius: 50%; background: #fff; border: 3px solid #0b6e8a; }
	.sc-vol input[type=range]:focus { outline: none; } .sc-vol input[type=range]:focus-visible::-webkit-slider-thumb { box-shadow: 0 0 0 4px rgba(22,160,196,.3); }
	.sc-sk.sc-gen { grid-template-columns: 96px minmax(0, 1fr); }
	.sc-num { display: inline-flex; align-items: center; gap: 4px; white-space: nowrap; font-size: 13px; font-weight: 700; color: #0b6e8a; background: #e8f6fa; border-radius: 999px; padding: 2px 10px; }
	.sc-num input { width: 52px; height: 24px; border: 1px solid #b9d9e3; border-radius: 6px; text-align: right; font-weight: 700; color: #0b6e8a; padding: 0 4px; }
	.sc-gen .sc-chip:disabled { opacity: .45; cursor: not-allowed; }
	/* 산업·역할 고르기: 고른 자리 줄 → 1단계 칩 → 펼친 2단계 */
	.sc-slots { display: flex; flex-wrap: wrap; gap: 6px; min-height: 26px; padding: 6px 8px; border: 1px dashed #c5d3de; border-radius: 8px; background: #fafcfd; margin-bottom: 6px; }
	.sc-slot { display: inline-flex; align-items: center; gap: 4px; font-size: 12px; font-weight: 600; border-radius: 999px; padding: 2px 4px 2px 10px; background: #e8f6fa; color: #0b6e8a; }
	.sc-slot[data-kind=ROLE] { background: #f1ecfa; color: #5b3b99; } .sc-slot em { font-style: normal; font-weight: 400; opacity: .75; }
	.sc-slot.sm { padding: 1px 8px; font-size: 11px; }
	.sc-slot-x, .sc-del { background: none; border: 0; padding: 0 5px; color: inherit; opacity: .7; font-size: 14px; line-height: 1; }
	.sc-slot-x:hover, .sc-del:hover { opacity: 1; color: #c0392b; }
	.sc-tree { margin-bottom: 4px; } .sc-tree-top, .sc-tree-sub { display: flex; flex-wrap: wrap; gap: 4px; align-items: center; }
	.sc-tree-k { width: 34px; font-size: 12px; color: #6b7785; }
	.sc-tree-sub { margin: 4px 0 6px 38px; padding: 6px 8px; background: #f4f7fa; border-radius: 8px; }
	.sc-del-wrap { display: inline-flex; align-items: center; }
	.sc-tree .sc-add { width: 200px; height: 26px; font-size: 12px; border-radius: 999px; }
	.sc-gen-tbl { font-size: 12.5px; } .sc-gen-tbl td { vertical-align: middle; white-space: nowrap; }
	.sc-gen-tbl tr.sc-gen-pin td { background: #fffaf0; } .sc-gen-tbl tr.sc-gen-hole td { color: #8a96a3; background: #f7f8fa; font-style: italic; }
	.sc-pin-off { opacity: .25; filter: grayscale(1); } .sc-pin-off:hover, .sc-pin-off:focus { opacity: .7; }
	.sc-ym { width: 128px; height: 26px; font-size: 12px; border: 1px solid #d5dde5; border-radius: 6px; padding: 0 4px; }
	.sc-per.sc-changed .sc-ym { background: #fff3c4; border-color: #f0c96b; }
	.sc-gen-empty { padding: 18px; text-align: center; color: #6b7785; background: #f7f9fb; border-radius: 10px; font-size: 13px; }
	#driveStatus { font-size: 12px; }
	.dm-tbl td { vertical-align: middle; } .dm-tbl select { max-width: 340px; font-size: 12px; } .dm-tbl tr.dm-miss td { color: #8a96a3; }
	.st-grid .hr-cell, .st-skill .hr-cell { overflow-wrap: anywhere; }
	.st-skill { padding: 3px 0; border-bottom: 1px solid rgba(17,17,17,.06); }
	.st-skill .hr-card-label { flex-basis: 96px; }
	.st-prj td { vertical-align: top; overflow-wrap: break-word; }
	.st-item td { white-space: pre-line; }
	.st-act { background: none; border: 0; padding: 0 4px; color: #888; }
	.st-act:hover, .st-act:focus { color: #0b6e8a; }
	.st-unset { color: #b7791f; }
	.st-dl { color: #0b6e8a; padding: 0 3px; font-size: 11px; cursor: pointer; }
	.st-group { font-size: 12px; font-weight: 700; color: #666; margin: 8px 0 6px; padding-top: 8px; border-top: 1px solid rgba(17,17,17,.08); }
	/* 인사카드 탭 공통 톤: 제목 달린 카드, 작은 회색 이름표 위에 값 */
	.st-cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(440px, 1fr)); gap: 14px; align-items: start; }
	.st-card { border: 1px solid #e3e8ee; border-radius: 10px; padding: 14px 16px; background: #fff; min-width: 0; }
	.st-card.wide { grid-column: 1 / -1; }
	.st-card > .hr-section:first-child { margin: 0 0 10px; padding: 0; border: 0; font-size: 14px; }
	.st-card .st-grid { grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 10px 14px; }
	.st-card .hr-card-row { flex-direction: column; gap: 0; margin: 0; }
	.st-card .hr-card-label, .st-card .st-grid .hr-card-label, .st-card .st-skill .hr-card-label { flex: none; font-size: 11.5px; color: #6b7785; line-height: 16px; }
	.st-card .hr-card-row .hr-cell { font-size: 13px; padding: 0; min-height: 20px; }
	.st-card .st-skill { border: 0; padding: 0; margin-bottom: 10px; }
	.st-card .st-secret { width: 100%; }
	.st-hero { display: flex; flex-wrap: wrap; gap: 10px; align-items: stretch; margin-bottom: 12px; }
	.st-stat { background: #f4f6f9; border-radius: 10px; padding: 8px 14px; }
	.st-stat small { display: block; color: #6b7785; font-size: 12px; } .st-stat b { font-size: 17px; }
	.st-hero .st-btns { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; margin-left: auto; }
	.st-dirty { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; border: 1px solid #f0d9a8; background: #fffaf0; border-radius: 10px; padding: 9px 14px; margin-bottom: 12px; font-size: 13px; }
	.st-bulk { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; background: #e8f6fa; border-radius: 8px; padding: 6px 12px; margin-bottom: 8px; font-size: 13px; }
	.st-log { font-size: 12.5px; } .st-log td { padding: 4px 8px; border-bottom: 1px solid #eef1f4; vertical-align: top; }
	.st-pick { display: grid; grid-template-columns: 92px 1fr; gap: 8px 10px; align-items: start; margin-top: 12px; padding-top: 12px; border-top: 1px solid #e3e8ee; font-size: 13px; }
	.st-pick .k { color: #6b7785; padding-top: 5px; }
	.st-pick .sc-chip { padding: 3px 11px; font-size: 12.5px; }
	.st-pick input.st-add { display: inline-block; width: 110px; height: 26px; font-size: 12px; padding: 0 8px; vertical-align: middle; border-radius: 999px; }
	#copyToast { position: fixed; right: 18px; bottom: 18px; z-index: 2000; background: #222; color: #fff; font-size: 12px; padding: 6px 12px; border-radius: 6px; display: none; }
	/* 폰: 카드 1열, 서류 줄은 2칸×2줄, 고르기 칸은 이름 위·값 아래, select 는 손가락 크기 */
	@media (max-width: 767px) {
		.st-cards { grid-template-columns: minmax(0, 1fr); }
		.st-dtiles { grid-template-columns: minmax(0, 1fr); }
		.st-pick { grid-template-columns: minmax(0, 1fr); }
		.st-pick .k { padding-top: 0; }
		.st-bn select { height: 36px; font-size: 13px; }
	}
</style>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_open.jspf"%>
				<div class="card-header">
					<h3 class="card-title bTitle"><b>직원관리</b></h3>
				</div>

				<div class="card-body">
					<div class="cal-panel">
						<div class="cal-panel-body">
							<div class="form-row align-items-end">
								<div class="col-md-3 col-12 mb-2">
									<label for="keyword">검색 (성명·연락처·메일·부서·메모)</label>
									<input type="search" id="keyword" class="form-control form-control-sm">
								</div>
								<div class="col-md-1 col-6 mb-2"><label for="fOrg">소속</label><select id="fOrg" class="form-control form-control-sm st-filter" data-field="ORG_NM"></select></div>
								<div class="col-md-2 col-6 mb-2"><label for="fDept">부서</label><select id="fDept" class="form-control form-control-sm st-filter" data-field="DEPT_NM"></select></div>
								<div class="col-md-1 col-6 mb-2"><label for="fPos">직급</label><select id="fPos" class="form-control form-control-sm st-filter" data-field="POSITION_NM"></select></div>
								<div class="col-md-2 col-6 mb-2">
									<label for="sortSel">정렬</label>
									<select id="sortSel" class="form-control form-control-sm">
										<option value="joinDesc">입사일 최신순</option>
										<option value="joinAsc">입사일 오래된순</option>
										<option value="leaveDesc">퇴사일 최신순</option>
										<option value="name">성명순</option>
										<option value="seq">NO순</option>
									</select>
								</div>
								<div class="col-md-3 col-12 mb-2 text-right">
									<button type="button" class="btn btn-sm btn-outline-secondary" onclick="resetFilters();"><i class="fas fa-undo"></i> 초기화</button>
									<button type="button" class="btn btn-sm btn-primary" onclick="openNew();"><i class="fas fa-plus"></i> 직원 등록</button>
								</div>
							</div>
							<div class="d-flex flex-wrap align-items-center justify-content-between mt-1">
								<div id="summary"></div>
								<div id="driveStatus" class="text-muted"></div>
							</div>
						</div>
					</div>

					<div class="cal-panel">
						<div class="pl-chks" id="stChks" role="group" aria-label="재직 상태"></div>
						<div class="d-flex flex-wrap align-items-center">
							<div class="btn-group btn-group-sm mx-3 mt-2 mb-2" id="orgSeg" role="group" aria-label="소속 빠른 선택"></div>
							<div class="ml-auto mr-3 d-none align-items-center" id="bonusBar" style="gap:6px">
								<label for="fBonus" class="mb-0 small text-muted">상여 항목</label>
								<select id="fBonus" class="form-control form-control-sm" style="width:170px"><option value="">전체</option></select>
							</div>
						</div>
						<div class="table-responsive px-3">
							<table data-no-card class="table table-sm table-hover cal-table mb-0">
								<thead id="listHead"></thead>
								<tbody id="listBody"></tbody>
							</table>
						</div>
						<div class="small text-muted px-3 py-2">
							칸을 누르면 바로 수정됩니다. 성명을 누르면 인사카드가 열립니다.
							<b>복사:</b> 칸 위에 마우스를 올리거나 Tab 으로 고른 뒤 <kbd>Ctrl</kbd>+<kbd>C</kbd> (맥은 <kbd>⌘</kbd>+<kbd>C</kbd>) 를 누르면 그 칸 값만 복사됩니다. 가려진 주민번호·계좌번호도 원문이 복사됩니다.
						</div>
					</div>
				</div>
			<%@ include file="/WEB-INF/jsp/bo/boinclude/page_close.jspf"%>

	<div class="modal fade" id="cardModal" tabindex="-1" role="dialog" aria-labelledby="cardTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="cardTitle">인사카드</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body" id="cardBody"></div>
				<div class="modal-footer">
					<button type="button" class="btn btn-sm btn-outline-danger mr-auto" onclick="deleteCard();">삭제</button>
					<button type="button" class="btn btn-sm btn-outline-secondary" id="btnStatus" onclick="toggleStatus();"></button>
					<button type="button" class="btn btn-sm btn-outline-secondary" id="btnWait" onclick="moveWait();"></button>
					<button type="button" class="btn btn-sm btn-primary" data-dismiss="modal">닫기</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="newModal" tabindex="-1" role="dialog" aria-labelledby="newTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="newTitle">직원 등록</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<form id="newForm" onsubmit="saveNew(); return false;">
					<div class="modal-body"><div class="form-row" id="newFields"></div></div>
					<div class="modal-footer"><button type="submit" class="btn btn-sm btn-primary">등록하고 인사카드 열기</button></div>
				</form>
			</div>
		</div>
	</div>

	<div class="modal fade" id="dmModal" tabindex="-1" role="dialog" aria-labelledby="dmTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="dmTitle">📂 드라이브에서 증명사진·이력카드 일괄 찾기</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<p class="small text-muted mb-2">지금 목록에 보이는 직원마다 <b>사람 폴더(하위 폴더 한 단계)</b>와 <b>공유 드라이브 전체</b>에서 이름이 들어간 사진·워드를 찾습니다. 찾기만 해서는 아무것도 바뀌지 않습니다.
						고른 것만 「선택 반영」 때 <b>증명사진은 서류 탭에 연결</b>, <b>이력카드 워드는 지금 수행이력에 없는 프로젝트만 추가</b>합니다(있는 줄은 그대로).</p>
					<div class="d-flex align-items-center mb-2" style="gap:8px">
						<button type="button" class="btn btn-sm btn-outline-primary" id="dmFind">찾기 시작</button>
						<span class="small text-muted" id="dmSum"></span>
						<label class="small mb-0 ml-auto"><input type="checkbox" id="dmOnlyHit" checked> 찾은 직원만 보기</label>
					</div>
					<div class="table-responsive" style="max-height:60vh;">
						<table class="table table-sm cal-table mb-0 dm-tbl" data-nomore data-no-card>
							<thead><tr><th style="width:34px;"><span class="sr-only">반영</span></th><th>직원</th><th>사람 폴더</th><th>증명사진</th><th>이력카드 워드</th><th>결과</th></tr></thead>
							<tbody id="dmBody"></tbody>
						</table>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-sm btn-primary" id="dmApply" disabled>선택 반영</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="scanModal" tabindex="-1" role="dialog" aria-labelledby="scanTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="scanTitle">드라이브에 있는 서류 연결</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<p class="small text-muted mb-2">사람 폴더와 <b>00. 입사관련서류</b> 폴더의 파일입니다. 서류 종류는 파일 이름으로 미리 골라 두었습니다. 연결하면 통장사본·신분증·등본·졸업증명·병적증명서는 글자를 읽어 빈 칸을 채웁니다.
						<a id="scanFolder" href="#" target="_blank" rel="noopener">드라이브에서 폴더 열기</a></p>
					<div class="table-responsive" style="max-height:55vh;">
						<table class="table table-sm cal-table mb-0">
							<thead><tr><th style="width:36px;"><span class="sr-only">선택</span></th><th>파일</th><th style="width:190px;">서류 종류</th></tr></thead>
							<tbody id="scanBody"></tbody>
						</table>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-sm btn-primary" id="btnLink" onclick="linkScanned();">선택한 파일 연결</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="scModal" tabindex="-1" role="dialog" aria-labelledby="scTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="scTitle">수행이력</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<form id="scForm" onsubmit="saveCareer(false); return false;">
					<div class="modal-body">
						<div class="form-row">
							<div class="col-md-6 mb-2"><label for="scPRJ_NM">프로젝트명(업무명) *</label><input id="scPRJ_NM" class="form-control form-control-sm" maxlength="300" required></div>
							<div class="col-md-3 mb-2"><label for="scCLIENT_NM">고객사</label><input id="scCLIENT_NM" class="form-control form-control-sm" maxlength="200" list="scClients" autocomplete="off"><datalist id="scClients"></datalist></div>
							<div class="col-md-3 mb-2"><label for="scCOMPANY_NM">근무회사</label><input id="scCOMPANY_NM" class="form-control form-control-sm" maxlength="200" list="scCompanies" autocomplete="off"><datalist id="scCompanies"></datalist></div>
							<div class="col-md-3 mb-2"><label for="scSTART_YM">시작월 *</label><input type="month" id="scSTART_YM" class="form-control form-control-sm" required></div>
							<div class="col-md-3 mb-2"><label for="scEND_YM">종료월 *</label><input type="month" id="scEND_YM" class="form-control form-control-sm">
								<div class="form-check mt-1"><input type="checkbox" class="form-check-input" id="scOngoing"><label class="form-check-label small" for="scOngoing">진행중</label></div></div>
							<div class="col-md-3 mb-2"><label for="scWORK_NM">업무단</label><input id="scWORK_NM" class="form-control form-control-sm" maxlength="500"></div>
							<div class="col-md-3 mb-2"><label for="scWORK_AREA">근무지</label><input id="scWORK_AREA" class="form-control form-control-sm" maxlength="200"></div>
						</div>
						<div class="small text-muted" id="scDeployNote" hidden>투입현황에 등록된 건이라 프로젝트명·고객사·기간은 투입현황에서 고칩니다. 여기서는 업무단·역할·개발환경을 보탭니다.</div>
						<div class="st-pick" id="scPick"></div>
						<div class="small text-muted mt-2">칩을 누르면 켜지고 다시 누르면 꺼집니다. 목록에 없는 값은 「＋ 직접 입력」 칸에 적고 Enter. 한 번 넣은 값은 다음부터 칩으로 나옵니다.
							<button type="button" class="btn btn-link btn-sm p-0" id="scCopyPrev">이전 프로젝트의 개발환경 복사</button></div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-sm btn-outline-danger mr-auto" id="scDelete">삭제</button>
						<button type="button" class="btn btn-sm btn-outline-secondary" id="scSaveMore">저장하고 하나 더 추가</button>
						<button type="submit" class="btn btn-sm btn-primary">저장</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<div class="modal fade" id="scVerModal" tabindex="-1" role="dialog" aria-labelledby="scVerTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="scVerTitle">수행이력 버전</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<p class="small text-muted mb-2"><b>순정</b>은 사내 기록·가져온 원본 그대로, <b>가필</b>은 ✨ 프로필 자동생성으로 만든 제출용입니다(<b>보기</b>에서 기준 순정과 달라진 칸이 노랗게 보이고, 되돌리기는 순정만). 「새 버전으로 저장」을 누를 때만 순정 버전이 생깁니다. <b>보기</b>는 그 버전의 수행이력을 읽기 전용으로 보여 주고, <b>이 버전으로</b>는 작업 중 내용을 그 버전으로 바꿉니다(옛 버전은 지워지지 않습니다).</p>
					<div class="table-responsive"><table class="table table-sm mb-0" data-nosort><thead><tr><th>버전</th><th>구분</th><th>저장한 때</th><th>저장한 사람</th><th>프로젝트</th><th>직전 버전과 달라진 점</th><th><span class="sr-only">관리</span></th></tr></thead><tbody id="scVerBody"></tbody></table></div>
					<div id="scVerView" class="mt-3"></div>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="scGenModal" tabindex="-1" role="dialog" aria-labelledby="scGenTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="scGenTitle">✨ 프로필 자동생성</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<p class="small text-muted mb-2">최신 <b>순정</b> 버전의 실제 프로젝트로만 짭니다. 없는 프로젝트는 만들지 않고, 기간은 실제 참여 기간 안에서만 줄일 수 있습니다. 순정 버전은 그대로 둡니다.</p>
					<div class="sc-sk sc-gen">
						<span class="k">필수 기술</span><div id="scGenSkills"></div>
						<span class="k"><label for="scGenMonths" class="mb-0">기간</label></span>
						<div id="scGenYears" class="sc-vol"><input type="range" id="scGenMonths" min="1" max="1200" step="1" aria-label="기간(개월)">
							<span class="sc-num"><input type="number" id="scGenY" min="0" max="100" aria-label="기간 년">년 <input type="number" id="scGenM" min="0" max="11" aria-label="기간 개월">개월 안</span></div>
						<span class="k"><label for="scGenMaxR" class="mb-0">프로젝트 횟수</label></span>
						<div id="scGenMax" class="sc-vol"><input type="range" id="scGenMaxR" min="1" max="100" step="1" aria-label="프로젝트 횟수">
							<span class="sc-num"><input type="number" id="scGenN" min="1" max="100" aria-label="프로젝트 횟수 숫자">개</span></div>
						<span class="k">정렬</span><div id="scGenSort" data-one></div>
						<span class="k">산업·역할</span>
						<div id="scGenPick">
							<div class="sc-slots" id="scGenSlots" aria-live="polite"></div>
							<div class="sc-tree" data-kind="IND"></div>
							<div class="sc-tree" data-kind="ROLE"></div>
						</div>
						<span class="k">증명사진</span><div id="scGenPhoto" data-one></div>
					</div>
					<div class="hr-section mt-3" id="scGenSum">미리보기</div>
					<div id="scGenView"></div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-outline-secondary" id="scGenWord">📄 워드로 바로 받기</button>
					<button type="button" class="btn btn-primary" id="scGenSave">가필 버전으로 저장</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="scImpModal" tabindex="-1" role="dialog" aria-labelledby="scImpTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="scImpTitle">워드에서 수행이력 가져오기</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<p class="small text-muted mb-2">이력카드 워드(.docx)의 <b>SKILL INVENTORY</b> 표를 읽어 지금 수행이력과 비교합니다. 「선택한 줄 반영」을 눌러야 저장됩니다. 같은 프로젝트는 프로젝트명과 시작월로 판단하고, 있는 프로젝트는 워드에 적힌 칸만 덮어씁니다.</p>
					<label for="scImpFile" class="sr-only">이력카드 워드 파일</label>
					<input type="file" id="scImpFile" accept=".docx" class="form-control-file mb-2">
					<div id="scImpSum" class="small mb-2"></div>
					<div class="table-responsive" style="max-height:52vh;"><table class="table table-sm mb-0" data-nosort><thead><tr><th style="width:30px;"><span class="sr-only">선택</span></th><th>상태</th><th>참여기간</th><th>프로젝트명</th><th>고객사</th><th>역할</th><th>언어</th><th>DBMS</th><th>달라진 점</th></tr></thead><tbody id="scImpBody"></tbody></table></div>
				</div>
				<div class="modal-footer"><button type="button" class="btn btn-sm btn-primary" id="scImpApply" disabled>선택한 줄 반영</button></div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="edModal" tabindex="-1" role="dialog" aria-labelledby="edTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="edTitle">수정</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<form id="edForm" onsubmit="submitEditor(); return false;">
					<div class="modal-body"><div class="form-row" id="edFields"></div></div>
					<div class="modal-footer"><button type="submit" class="btn btn-sm btn-primary">저장</button></div>
				</form>
			</div>
		</div>
	</div>

	<div id="copyToast" role="status" aria-live="polite"></div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/page_script.jspf"%>
	<script>$(function() { hrDriveGear('STAFF'); }); // 드라이브 폴더·파일 이름 규칙 ⚙</script>
	<script src="/resources/common/staff-career.js?v=20261117"></script>

	<script>
	// 공통코드 HR_STAFF_STATUS 의 이름·순서. 코드가 없을 때만 기본값
	var STATUS = hrCodeMap('HR_STAFF_STATUS');
	if ($.isEmptyObject(STATUS)) STATUS = { WORK: '재직', LEFT: '퇴사', WAIT: '대기' };
	// 인사카드 탭: [이름, 그 탭에 그릴 SECTIONS 이름]. 영업정보·수행이력·서류·메모·보유 장비·시크릿은 따로 그린다
	var CARD_TABS = [['기초정보', ['기초정보', '일자', '계좌(기업)', '비상연락망', '기타']], ['학력/교육', ['학력', '병역', '교육·자격']], ['영업정보', []], ['수행이력', []], ['서류', []], ['메모', []], ['보유 장비', []], ['🔒 시크릿', []]];
	var TAB = { SALES: 2, CAREER: 3, DOCS: 4, MEMO: 5, EQP: 6, SECRET: 7 };
	var CAN_SECRET = false; // 슈퍼관리자만. 아니면 시크릿 탭을 그리지 않는다(서버도 같은 검사)
	var SALES_TERMS = ['GRADE_NM', 'REAL_CAREER', 'WISH_PRICE', 'SCORE', 'GAPIL_YN', 'AUTO_APLY_YN', 'WISH_LOC'];
	var SALES_TEXTS = ['WORK_DOMAIN', 'EXPERTISE', 'REPORT', 'ETC1', 'ETC2'];
	// 수행이력 입력 창에서 칩으로 고르는 칸
	var SC_PICKS = [['ROLE_NM', '역할'], ['IND_NM', '산업'], ['APP_NM', '응용'], ['LANG_NM', '언어'], ['FRAMEWORK_NM', '프레임워크'], ['DBMS_NM', 'DBMS'], ['TOOL_NM', 'TOOL'], ['OS_NM', 'O.S'], ['MACHINE_NM', '기종'], ['ETC_NM', '기타']];
	var SC_TEXTS = ['PRJ_NM', 'CLIENT_NM', 'COMPANY_NM', 'START_YM', 'END_YM', 'WORK_NM', 'WORK_AREA'];
	var cardTab = 0, career = null; // career: { sq, d: 서버 상태(items·ver·dirty·logs·chips), pick: 골라 보는 기술 }
	var EDU_TYPE = { list: [['', '선택']].concat(['검정고시', '고등학교(인문계)', '고등학교(실업계)', '대학교(2~3년제)', '대학교(4년제)', '사이버·방통대·학점은행제', '대학원(석사)', '대학원(박사)'].map(function(k) { return [k, k]; })) };
	var EDU_STATE = { list: [['', '선택'], ['졸업', '졸업'], ['재학', '재학'], ['휴학', '휴학'], ['수료', '수료'], ['중퇴', '중퇴']] };
	// 여러 건 섹션. cols: [칸, 이름, 입력 종류, 필수], base: 기존 인사카드 칸(cols 순서). 기존 칸의 건은 기존 칸에, 추가한 건은 항목 표에 저장한다
	var LISTS = {
		'학력': { cd: 'EDU', title: '학력', cols: [['C1', '구분', EDU_TYPE, true], ['C2', '학교명', null, true], ['C3', '전공'], ['C4', '졸업년월', 'month'], ['C5', '상태', EDU_STATE]],
			base: [['HS_KIND', 'HS_NM', 'HS_MAJOR', 'HS_GRAD', 'HS_STATE'], ['UNIV_KIND', 'UNIV_NM', 'UNIV_MAJOR', 'UNIV_GRAD', 'UNIV_STATE']], extra: ['FINAL_EDU'] },
		'교육·자격': { cd: 'TRAIN', title: '교육·자격', cols: [['C1', '교육·자격명', null, true], ['C2', '기관'], ['C3', '시작월', 'month'], ['C4', '종료월', 'month']],
			base: [['EDU_NM', 'EDU_ORG', 'EDU_START_DT', 'EDU_END_DT']], extra: ['CERT_DT'] },
		'비상연락망': { cd: 'EMG', title: '비상연락망', cols: [['C1', '관계', null, true], ['C2', '연락처', null, true]], base: [['EMG_REL1', 'EMG_TEL1'], ['EMG_REL2', 'EMG_TEL2']] }
	};
	var items = null; // { sq, list }
	// 제출 여부는 파일 연결로 정하고, 사람은 해당없음만 고른다(옛 O·X 값은 DB 에 남아도 무시)
	var DOC_VALUES = { list: [['', '미제출'], ['-', '해당없음']] };
	var DOCS = [['DOC_REG', '주민등본'], ['DOC_ID', '신분증'], ['DOC_GRAD', '졸업증명'], ['DOC_BANK', '통장사본'], ['DOC_PHOTO', '증명사진'],
		['DOC_HI', '건보득실확인서'], ['DOC_CONTRACT', '근로계약'], ['DOC_BIZ', '사업자사실증명'], ['DOC_EI', '고용보험자격이력'], ['DOC_SEC', '보안서약서'],
		['DOC_EDU', '직무교육동의서'], ['DOC_NEP', '국민취업제도참여'], ['DOC_PRIV', '이력비공개'], ['DOC_CRIME', '범죄기록회보'], ['DOC_MIL', '병적증명서']];
	// 서류 탭 묶음: [제목, 아이콘, 설명, 서류코드들]. 여기 없는 코드는 '기타' 로 간다
	var DOC_GROUPS = [
		['신원·급여', 'fa-id-card', '본인 확인과 급여 지급', ['DOC_REG', 'DOC_ID', 'DOC_PHOTO', 'DOC_BANK']],
		['학력·경력', 'fa-graduation-cap', '학력과 경력·보험 이력', ['DOC_GRAD', 'DOC_MIL', 'DOC_HI', 'DOC_EI']],
		['계약·서약', 'fa-file-signature', '입사 때 받는 동의·서약', ['DOC_CONTRACT', 'DOC_SEC', 'DOC_EDU', 'DOC_PRIV']],
		['해당자만', 'fa-user-check', '프리·제도 참여자 등 해당될 때', ['DOC_BIZ', 'DOC_NEP', 'DOC_CRIME']]];
	var DOC_STATES = [['file', '파일 있음', 'fa-check-circle'],['miss', '미제출', 'fa-times-circle'], ['na', '해당없음', 'fa-minus-circle']];
	// 인사카드 칸: [필드, 라벨, 종류]. 종류 'secret' 은 가린 값 + 원문 보기
	var SECTIONS = [
		['기초정보', [['STAFF_NM', '성명'], ['ORG_NM', '소속'], ['DEPT_NM', '부서'], ['POSITION_NM', '직급'], ['SEQ_NO', 'NO'],
			['RRN', '주민등록번호', 'secret'], ['PHONE', '전화번호'], ['EMAIL', '개인 메일'], ['COMPANY_EMAIL', '회사 메일'], ['ADDR', '주소(시도)'], ['STATION', '인근지하철역'], ['EMPLY_ID', '로그인 계정']]],
		['일자', [['JOIN_DT', '입사일자', 'date'], ['LEAVE_DT', '퇴사일자', 'date']]],
		['학력', [['HS_NM', '고교'], ['HS_MAJOR', '고교 전공'], ['HS_GRAD', '고교 졸업'], ['UNIV_NM', '대학·대학원'], ['UNIV_MAJOR', '전공'], ['UNIV_GRAD', '졸업년월'], ['FINAL_EDU', '최종학력']]],
		['병역', [['MIL_IN_DT', '입대일'], ['MIL_OUT_DT', '전역일'], ['MIL_EXEMPT', '면제사유']]],
		['교육·자격', [['EDU_NM', '교육명'], ['EDU_START_DT', '교육 시작'], ['EDU_END_DT', '교육 종료'], ['EDU_ORG', '기관명'], ['CERT_DT', '정보처리기사']]],
		['계좌(기업)', [['BANK_NM', '은행'], ['ACCOUNT', '계좌번호', 'secret']]],
		['비상연락망', [['EMG_REL1', '관계1'], ['EMG_TEL1', '연락처1'], ['EMG_REL2', '관계2'], ['EMG_TEL2', '연락처2']]],
		['기타', [['PREV_CAREER', '이전경력'], ['HOBBY', '취미'], ['LANG_SKILL', '외국어'], ['SPECIALTY', '특기']]],
		['영업 정보', [['GRADE_NM', '등급'], ['REAL_CAREER', '실경력'], ['WISH_PRICE', '희망단가'], ['SCORE', '점수'], ['GAPIL_YN', '가필여부'], ['AUTO_APLY_YN', '자동지원여부'],
			['WORK_DOMAIN', '업무·도메인'], ['WISH_LOC', '희망 위치'], ['EXPERTISE', '전문분야'], ['REPORT', 'Report'], ['ETC1', '기타1'], ['ETC2', '기타2'], ['SK_EXTRA', '추가 기술 (직접 입력)']]]
	];
	var LABELS = {};
	SECTIONS.forEach(function(s) { s[1].forEach(function(f) { LABELS[f[0]] = f[1]; }); });
	DOCS.forEach(function(d) { LABELS[d[0]] = d[1]; });

	var rows = [], shownSt = { WORK: true }, opened = null; // shownSt: 켜 둔 재직 상태 칩
	var revealed = {}; // 'STAFF_SQ|FIELD' -> 원문. 화면을 닫으면 사라진다

	$(function() {
		// 다른 메뉴의 인사카드 링크(?STAFF_SQ=번호)로 오면 그 사람 카드를 바로 연다
		var linked = /[?&]STAFF_SQ=(\d+)/.exec(location.search);
		load(function() {
			if (linked && rows.some(function(r) { return String(r.STAFF_SQ) === linked[1]; })) openCard(Number(linked[1]));
		});
		$('#keyword').on('input', render);
		$('#sortSel, .st-filter').on('change', render);
		hrBuildFields('#newFields', [['STAFF_NM', '성명 *', 6], ['STATUS_CD', '재직 상태', 6, { values: STATUS }], ['ORG_NM', '소속', 4], ['DEPT_NM', '부서', 4],
			['POSITION_NM', '직급', 4], ['PHONE', '전화번호', 6], ['JOIN_DT', '입사일자', 6, 'date']]);
		$('#cardModal').on('hidden.bs.modal', function() { opened = null; revealed = {}; docs = null; career = null; items = null; cardTab = 0; render(); });
		careerInit();
		// 인사카드 위에 뜬 창을 닫아도 인사카드 스크롤이 유지되게 한다
		$(document).on('hidden.bs.modal', function() { if ($('.modal.show').length) $('body').addClass('modal-open'); });
		loadDrive();
	});

	// 시크릿 계정에게만 서버가 secretViewer 와 시크릿 행(SECRET)을 준다. 투입현황·급여관리처럼 맨 앞에 🔒 시크릿 칩
	var SECRET_VIEW = false;
	function chipKeys() { return (SECRET_VIEW ? ['_SECRET'] : []).concat(Object.keys(STATUS)); }

	function renderStatusChips() {
		boChips('#stChks', chipKeys().map(function(k) {
			var secret = k === '_SECRET';
			return { k: k, name: secret ? '🔒 시크릿' : STATUS[k], cls: secret ? 'secret' : '', n: rows.filter(function(r) { return secret ? r.SECRET : r.STATUS_CD === k; }).length };
		}), shownSt, render);
	}

	function onlyLeft() { return shownSt.LEFT && !Object.keys(STATUS).some(function(k) { return k !== 'LEFT' && shownSt[k]; }); }

	// 비고는 메모로 옮겼다. 목록 💬 버튼과 인사카드 메모 탭에서 쌓는다
	var MEMO_API = hrMemoApi('/admin/staff/');

	function load(then) {
		$.post('/admin/staff/staffListData.do', function(res) {
			rows = res.list || [];
			CAN_SECRET = !!res.canSecret;
			if (res.secretViewer && !SECRET_VIEW) shownSt._SECRET = true;
			SECRET_VIEW = !!res.secretViewer;
			fillFilters();
			render();
			if (then) then();
		});
		loadBonus();
	}

	// ── 상여 적용 칩 (상여관리 권한이 있을 때만: 권한이 없으면 주소가 막혀 열이 안 생긴다) ──
	var BN = null;
	function loadBonus() {
		$.post('/admin/bonus/staffBonusData.do').done(function(res) {
			if (!res || !res.result || !res.result.items) return;
			BN = res.result;
			var keep = $('#fBonus').val();
			$('#fBonus').empty().append('<option value="">전체</option>').append(BN.items.filter(function(b) { return b.USE_YN === 'Y'; }).map(function(b) { return $('<option>').val(b.BONUS_SQ).text(b.BONUS_NM); })).val(keep || '');
			$('#bonusBar').removeClass('d-none').addClass('d-flex');
			render();
		});
	}
	$(document).on('change', '#fBonus', function() { render(); });

	var bnOpen = {}; // STAFF_SQ -> 펼침. 접힌 칸은 켜진 상여만 보인다
	function bonusCell($td, r) {
		var pick = $('#fBonus').val(), open = !!bnOpen[r.STAFF_SQ], shown = 0;
		BN.items.filter(function(b) { return b.USE_YN === 'Y' && (!pick || String(b.BONUS_SQ) === pick); }).forEach(function(b) {
			var a = BN.applies.filter(function(x) { return x.BONUS_SQ === b.BONUS_SQ && x.STAFF_SQ === r.STAFF_SQ; })[0], on = !!a;
			if (!on && !open) return;
			shown++;
			var $chip = $('<span class="dp-pill" role="switch" tabindex="0">').toggleClass('ok', on).attr({ 'aria-checked': on, 'aria-label': r.STAFF_NM + ' ' + b.BONUS_NM + (on ? ' 켜짐' : ' 꺼짐') }).text((on ? '● ' : '○ ') + b.BONUS_NM);
			function send(extra) { hrPost('/admin/bonus/applyBonusData.do', $.extend({ BONUS_SQ: b.BONUS_SQ, STAFF_SQ: r.STAFF_SQ, ON: 'Y' }, extra), function() { dpHide(); loadBonus(); }); }
			$chip.on('click keydown', function(e) {
				if (e.type === 'keydown' && e.key !== 'Enter' && e.key !== ' ') return;
				e.preventDefault();
				send(on ? { ON: 'N' } : {});
			});
			dpHover($chip, $chip, function() { return bonusCard(b, a, r); });
			var $w = $('<span class="st-bn">').append($chip);
			if (on && b.PER_AMT_YN === 'Y') {
				$w.append($('<input class="form-control" inputmode="numeric">').attr({ 'aria-label': r.STAFF_NM + ' ' + b.BONUS_NM + ' 금액', placeholder: dpWon(dpSteps(b.STEPS)[0].a) })
					.val(a.AMT === null || a.AMT === undefined ? '' : Number(a.AMT).toLocaleString('ko-KR')).on('change', function() { send({ AMT: this.value }); }));
			}
			if (on && b.TARGET_CD === 'REFERRER') {
				var $s = $('<select class="form-control">').attr('aria-label', r.STAFF_NM + ' 추천인').append('<option value="">추천인 ▾</option>');
				BN.staff.filter(function(s) { return s.STAFF_SQ !== r.STAFF_SQ; }).forEach(function(s) { $s.append($('<option>').val(s.STAFF_SQ).text(s.STAFF_NM)); });
				$w.append($s.val(a.REFERRER_SQ || '').on('change', function() { send({ REFERRER_SQ: this.value }); }));
			}
			$td.append($w);
		});
		if (!shown) $td.append('<span class="text-muted small mr-1">없음</span>');
		$td.append($('<button type="button" class="st-bn-toggle">').attr({ 'data-bn-sq': r.STAFF_SQ, 'aria-expanded': open, 'aria-label': r.STAFF_NM + ' 상여 ' + (open ? '접기' : '펼쳐서 수정'), title: open ? '접기' : '펼쳐서 수정' })
			.html(open ? '<i class="fas fa-chevron-up"></i>' : '<i class="fas fa-pen"></i>')
			.on('click', function() { bnOpen[r.STAFF_SQ] = !open; render(); $('[data-bn-sq=' + r.STAFF_SQ + ']').focus(); }));
	}

	// 칩에 마우스를 올리면: 항목 조건 + 이 사람 적용(기준일·달성일·조건 충족·지급 월), 꺼진 칩은 적용 방식
	function bonusCard(b, a, r) {
		var now = moment().format('YYYY-MM'), on = !!a, steps = dpSteps(b.STEPS);
		var h = '<div class="dp-card sm"><div class="dp-card-top">' + dpEsc(b.BONUS_NM) + '<span>' + (on ? '적용 중' : '꺼짐') + '</span></div><div class="dp-sec"><div class="s"><span>항목 조건</span><span></span></div>'
			+ dpLine('기준일', dpBaseText(b)) + steps.map(function(s, i) { return dpLine(i ? '' : '지급 단계', dpStepText(s)); }).join('')
			+ dpLine('지급', '달성 익월 급여 · ' + (b.TARGET_CD === 'REFERRER' ? '추천인' : '본인')) + '</div>';
		if (!on) return h + '<div class="dp-sec"><div class="s"><span>적용 방식</span><span></span></div><div><span style="white-space:normal">'
			+ (b.TARGET_CD === 'REFERRER' ? '추천받아 들어온 사람에게 켜고 추천인을 고르면, 단계마다 추천인의 익월 급여에 들어갑니다.' : '누르면 켭니다. 단계를 채우면 이 사람의 익월 급여 상여 칸에 자동으로 들어갑니다.') + '</span></div></div></div>';
		var plans = BN.plans.filter(function(p) { return p.BONUS_SQ === b.BONUS_SQ && p.PERSON_SQ === r.STAFF_SQ; });
		h += '<div class="dp-sec"><div class="s"><span>이 사람 적용</span><span></span></div>';
		if (a.AMT !== null && a.AMT !== undefined) h += dpLine('금액', dpWon(a.AMT) + ' (사람별)');
		if (b.TARGET_CD === 'REFERRER') h += dpLine('추천인', a.REFERRER_NM || '미지정 · 지급 안 됨');
		if (!plans.length) h += dpLine('기준일', '없음 · 입사일이나 투입 기록이 필요합니다');
		else h += dpLine('기준일', plans[0].BASE_DT);
		plans.forEach(function(p) {
			var st = !p.OK ? p.WHY : p.YM < now ? p.YM + ' 급여 (지난 달)' : p.YM === now ? p.YM + ' 급여 · 이번 달' : p.YM + ' 급여 · 예정';
			h += dpLine(p.LABEL + ' ' + dpWon(p.AMT), p.ACHIEVE_DT + ' 달성') + '<div><span></span><span class="' + (p.OK ? '' : 'text-danger') + '">' + dpEsc(st) + '</span></div>';
		});
		return h + '<div class="s"><span>켠 사람 · ' + dpEsc((a.EMPLY_NM || a.EMPLY_ID) + ' ' + a.REG_DT) + '</span><span></span></div></div></div>';
	}

	function fillFilters() {
		$('.st-filter').each(function() {
			var $s = $(this), field = $s.data('field'), keep = $s.val();
			var vals = rows.map(function(r) { return r[field]; }).filter(Boolean).filter(function(v, i, a) { return a.indexOf(v) === i; }).sort();
			$s.empty().append('<option value="">전체</option>');
			vals.forEach(function(v) { $s.append($('<option>').val(v).text(v)); });
			$s.val(keep || '');
		});
	}

	function resetFilters() {
		$('#keyword').val('');
		$('.st-filter').val('');
		$('#sortSel').val(onlyLeft() ? 'leaveDesc' : 'joinDesc');
		render();
	}

	function filtered() {
		var kw = $.trim($('#keyword').val()).toLowerCase();
		return rows.filter(function(r) {
			if (!shownSt[r.STATUS_CD] || (r.SECRET && !shownSt._SECRET)) return false;
			var ok = true;
			$('.st-filter').each(function() { if ($(this).val() && r[$(this).data('field')] !== $(this).val()) ok = false; });
			if (!ok) return false;
			return !kw || [r.STAFF_NM, r.PHONE, r.EMAIL, r.COMPANY_EMAIL, r.DEPT_NM, r.ORG_NM, r.MEMO].some(function(v) { return v && String(v).toLowerCase().indexOf(kw) >= 0; });
		}).sort(function(a, b) { return (b.SECRET ? 1 : 0) - (a.SECRET ? 1 : 0) || sorter($('#sortSel').val())(a, b); }); // 시크릿은 맨 위 고정
	}

	function sorter(key) {
		function s(v) { return v || ''; }
		return {
			joinDesc: function(a, b) { return s(b.JOIN_DT).localeCompare(s(a.JOIN_DT)); },
			joinAsc: function(a, b) { return (a.JOIN_DT ? 0 : 1) - (b.JOIN_DT ? 0 : 1) || s(a.JOIN_DT).localeCompare(s(b.JOIN_DT)); },
			leaveDesc: function(a, b) { return s(b.LEAVE_DT).localeCompare(s(a.LEAVE_DT)); },
			name: function(a, b) { return s(a.STAFF_NM).localeCompare(s(b.STAFF_NM), 'ko'); },
			seq: function(a, b) { return (+a.SEQ_NO || 1e9) - (+b.SEQ_NO || 1e9); }
		}[key];
	}

	// 입사일부터 퇴사일(없으면 오늘)까지. 날짜가 아니면 빈칸
	function tenure(r) {
		var from = moment(r.JOIN_DT, 'YYYY-MM-DD', true), to = r.LEAVE_DT ? moment(r.LEAVE_DT, 'YYYY-MM-DD', true) : moment();
		if (!from.isValid() || !to.isValid() || to.isBefore(from)) return '';
		var m = to.diff(from, 'months');
		return (m >= 12 ? Math.floor(m / 12) + '년 ' : '') + (m % 12) + '개월';
	}

	function missingDocs(r) {
		return DOCS.filter(function(d) { return docState(r, d) === 'miss'; });
	}

	function render() {
		renderStatusChips();
		renderOrgSeg();
		var list = filtered(), multi = Object.keys(STATUS).filter(function(k) { return shownSt[k]; }).length > 1;
		renderSummary(list);
		var cols = [['SEQ_NO', 'NO'], multi ? ['_STATUS', '재직 상태'] : null, ['ORG_NM', '소속'], ['DEPT_NM', '부서'], ['POSITION_NM', '직급'], ['STAFF_NM', '성명'], ['PHONE', '전화번호'], ['EMAIL', '개인 메일'], ['COMPANY_EMAIL', '회사 메일'],
			['JOIN_DT', '입사일'], shownSt.LEFT ? ['LEAVE_DT', '퇴사일'] : null, ['_TENURE', '근속'], ['_DOCS', '서류'], BN && !onlyLeft() ? ['_BONUS', '상여 적용'] : null, ['_MEMO', '메모']].filter(Boolean);
		$('#listHead').empty().append($('<tr>').append(cols.map(function(c) { return $('<th>').text(c[1]); })));
		var $body = $('#listBody').empty();
		if (!list.length) { boEmpty($body, '해당하는 직원이 없습니다.'); return; }
		list.forEach(function(r) {
			var $tr = $('<tr>').toggleClass('st-secret-row', !!r.SECRET);
			cols.forEach(function(c) {
				var $td = $('<td>');
				if (c[0] === 'STAFF_NM') {
					$td.append(r.SECRET ? $('<span title="시크릿">').text('🔒 ') : '').append($('<button type="button" class="st-name">').text(r.STAFF_NM).on('click', function() { openCard(r.STAFF_SQ); }));
					copyable($td, r, 'STAFF_NM');
				} else if (c[0] === '_TENURE') {
					$td.text(tenure(r));
				} else if (c[0] === '_DOCS') {
					var miss = missingDocs(r);
					$td.text(miss.length ? '미제출 ' + miss.length : '완료').attr('data-tone', miss.length ? 'warn' : 'good')
						.attr('title', miss.map(function(d) { return d[1]; }).join(', '));
				} else if (c[0] === '_STATUS') {
					$td.text(STATUS[r.STATUS_CD] || r.STATUS_CD);
				} else if (c[0] === '_BONUS') {
					if (r.STATUS_CD !== 'LEFT') bonusCell($td.addClass('st-bonus'), r);
				} else if (c[0] === '_MEMO') {
					$td.append(hrMemoBtn(MEMO_API, r.STAFF_SQ, r.MEMO_CNT, r.STAFF_NM, function() { load(); }));
				} else {
					editable($td, r, c[0], /_DT$/.test(c[0]) ? 'date' : null);
				}
				$tr.append($td);
			});
			$body.append($tr);
		});
	}

	// 소속 드롭다운의 빠른 선택. 인원은 지금 탭 기준
	function renderOrgSeg() {
		var inTab = rows.filter(function(r) { return shownSt[r.STATUS_CD] && (!r.SECRET || shownSt._SECRET); }), org = $('#fOrg').val() || '', $s = $('#orgSeg').empty();
		[['', '전체'], ['정규직', '정규직'], ['프리', '프리']].forEach(function(o) {
			var n = o[0] ? inTab.filter(function(r) { return r.ORG_NM === o[0]; }).length : inTab.length;
			$s.append($('<button type="button" class="btn btn-outline-secondary">').toggleClass('active', org === o[0]).attr('aria-pressed', org === o[0]).text(o[1] + ' ' + n)
				.on('click', function() { $('#fOrg').val(o[0]); render(); }));
		});
	}

	function renderSummary(list) {
		var by = {};
		list.forEach(function(r) { var k = r.ORG_NM || '소속 없음'; by[k] = (by[k] || 0) + 1; });
		var $s = $('#summary').empty().append($('<span class="st-chip">').append('합계 ').append($('<b>').text(list.length)));
		Object.keys(by).sort().forEach(function(k) { $s.append($('<span class="st-chip">').append(document.createTextNode(k + ' ')).append($('<b>').text(by[k]))); });
	}

	// 한 칸: 눌러서 수정 + 단축키 복사
	function editable($el, r, field, type, paint) {
		hrEditable($el, {
			url: '/admin/staff/saveStaffFieldData.do', key: { STAFF_SQ: r.STAFF_SQ }, field: field, type: type, label: r.STAFF_NM + ' ' + (LABELS[field] || field), paint: paint,
			show: function() { return r[field]; }, value: function() { return r[field]; },
			saved: function(v) { r[field] = v; if (field === 'STAFF_NM' || field === 'ORG_NM' || field === 'DEPT_NM' || field === 'POSITION_NM') fillFilters(); }
		});
		return copyable($el, r, field);
	}

	function copyable($el, r, field) {
		return $el.attr({ 'data-copy': field, 'data-sq': r.STAFF_SQ, tabindex: 0 });
	}

	function find(sq) { return rows.filter(function(r) { return String(r.STAFF_SQ) === String(sq); })[0]; }

	function openCard(sq) {
		opened = sq;
		paintCard();
		$('#cardModal').modal('show');
	}

	// 탭 이름 뒤 건수. 0건이면 붙이지 않는다
	function cardTabLabel(r, i) {
		var n = i === TAB.CAREER ? (career && career.sq === r.STAFF_SQ && career.d ? career.d.items.length : r.PRJ_CNT) : i === TAB.MEMO ? r.MEMO_CNT : i === TAB.EQP ? r.EQP_CNT : 0;
		if (i === TAB.DOCS) { var miss = missingDocs(r).length; return CARD_TABS[i][0] + (miss ? '(미제출 ' + miss + ')' : ''); }
		return CARD_TABS[i][0] + (n ? '(' + n + ')' : '');
	}

	function refreshCardTabs() {
		var r = find(opened);
		if (r) $('#cardBody > ul .nav-link').each(function(i) { $(this).text(cardTabLabel(r, i)); });
	}

	function paintCard() {
		var r = find(opened);
		if (!r) return;
		$('#cardTitle').text((r.SECRET ? '🔒 ' : '') + r.STAFF_NM + ' 인사카드 (' + STATUS[r.STATUS_CD] + ')');
		$('#btnStatus').text(r.STATUS_CD === 'WORK' ? '퇴사로 옮기기' : '재직으로 되돌리기');
		$('#btnWait').text(r.STATUS_CD === 'WAIT' ? '퇴사로 옮기기' : '대기로 옮기기');
		var $b = $('#cardBody').empty();
		var $tabs = $('<ul class="nav nav-tabs mb-3" role="tablist">').appendTo($b), $p = $('<div role="tabpanel">').appendTo($b);
		CARD_TABS.forEach(function(t, i) {
			if (i === TAB.SECRET && !CAN_SECRET) return;
			$('<li class="nav-item">').append($('<button type="button" class="nav-link" role="tab">').toggleClass('active', i === cardTab).attr('aria-selected', i === cardTab)
				.text(cardTabLabel(r, i))
				.on('click', function() { cardTab = i; paintCard(); $('#cardBody .nav-link.active').focus(); })).appendTo($tabs);
		});
		// 모든 탭이 같은 모양: 제목 달린 카드 안에 작은 이름표 + 값, 여러 건은 표
		var $cards = $('<div class="st-cards">').appendTo($p);
		function card(wide) { return $('<div class="st-card">').toggleClass('wide', !!wide).appendTo($cards); }
		SECTIONS.filter(function(s) { return CARD_TABS[cardTab][1].indexOf(s[0]) >= 0; }).forEach(function(s) {
			var $c = card();
			if (LISTS[s[0]]) { itemSection($c, r, LISTS[s[0]]); return; }
			$c.append(sectionHead(r, s[0], s[1]));
			var $g = $('<div class="st-grid">').appendTo($c);
			s[1].forEach(function(f) {
				var $row = $('<div class="hr-card-row">').append($('<div class="hr-card-label">').text(f[1])).appendTo($g);
				if (f[2] === 'secret') $row.append(secretCell(r, f[0]));
				else $row.append(editable($('<div>'), r, f[0], f[2]));
			});
			if (s[0] === '일자') $g.append($('<div class="hr-card-row">').append($('<div class="hr-card-label">').text('근속')).append($('<div class="hr-cell">').text(tenure(r) || '-')));
		});
		if ((cardTab === TAB.SALES || cardTab === TAB.CAREER) && (!career || career.sq !== r.STAFF_SQ)) loadCareer(r.STAFF_SQ);
		if (cardTab === TAB.SALES) salesTab(card, r);
		if (cardTab === TAB.CAREER) careerTab(card(true), r);
		if (cardTab === TAB.DOCS) {
			var $dc = card(true), cnt = { file: 0, miss: 0, na: 0 };
			DOCS.forEach(function(d) { cnt[docState(r, d)]++; });
			var $sum = $('<div class="st-dsum">'), $bar = $('<div class="st-dbar">'), need = DOCS.length - cnt.na;
			DOC_STATES.forEach(function(s) {
				$sum.append($('<span>').attr('data-s', s[0]).append($('<i>')).append(document.createTextNode(s[1] + ' ')).append($('<b>').text(cnt[s[0]])));
				if (s[0] !== 'na' && need) $bar.append($('<i>').attr({ 'data-s': s[0], title: s[1] + ' ' + cnt[s[0]] }).css('width', (cnt[s[0]] / need * 100) + '%'));
			});
			$dc.append($('<div class="hr-section d-flex align-items-center flex-wrap" style="gap:10px">').append('서류').append($sum)
				.append($('<button type="button" class="btn btn-sm btn-outline-primary ml-auto">').html('<i class="fab fa-google-drive"></i> 드라이브에서 찾기').on('click', openScan)));
			$dc.append($bar);
			// 여러 파일을 한 번에 놓는 곳. 끌고 들어오면 파랗게 바뀐다
			var $many = $('<input type="file" class="d-none" id="stDropInput" multiple accept="image/*,application/pdf,.hwp,.doc,.docx,.zip">')
				.on('change', function() { dropMany(r, $.makeArray(this.files)); this.value = ''; });
			var $drop = $('<label class="st-drop" for="stDropInput">').append($many)
				.append('<i class="fas fa-cloud-upload-alt"></i>')
				.append($('<div>').append('<b>서류 파일을 여기에 한 번에 끌어다 놓으세요</b>').append($('<small>').text('여러 개 가능 · 파일 이름으로 종류를 맞추고, 못 맞추면 골라요 · 누르면 파일 고르기 · 20MB 까지')))
			// 타일 밖 어디에 놓아도 이 영역으로 받는다(타일은 자기 서류로 받고 전파를 멈춘다)
			$dc.append($drop).on('dragover', function(e) { e.preventDefault(); $dc.find('.st-doc-row').removeClass('is-over'); $drop.addClass('is-over'); })
				.on('dragleave', function(e) { if (!$.contains(this, e.relatedTarget)) $drop.removeClass('is-over'); })
				.on('drop', function(e) { e.preventDefault(); $drop.removeClass('is-over'); dropMany(r, $.makeArray(e.originalEvent.dataTransfer.files)); });
			var used = {};
			DOC_GROUPS.concat([['기타', 'fa-folder', '', DOCS.map(function(d) { return d[0]; })]]).forEach(function(g) {
				var list = DOCS.filter(function(d) { return g[3].indexOf(d[0]) >= 0 && !used[d[0]]; });
				if (!list.length) return;
				var ok = list.filter(function(d) { used[d[0]] = 1; return docState(r, d) === 'file'; }).length;
				var $g = $('<div class="st-dgroup">').appendTo($dc).append($('<h6>').append($('<i class="fas">').addClass(g[1])).append(document.createTextNode(g[0]))
					.append($('<span>').text(ok + '/' + list.length + ' 파일' + (g[2] ? ' · ' + g[2] : ''))));
				var $t = $('<div class="st-dtiles">').appendTo($g);
				list.forEach(function(d) { $t.append(docRow(r, d)); });
			});
		}
		if (!docs || docs.sq !== r.STAFF_SQ) loadDocs(r.STAFF_SQ);
		if (cardTab === TAB.MEMO) {
			var $mc = card(true).append('<div class="hr-section">메모</div>');
			hrMemoFeed($('<div>').appendTo($mc), MEMO_API, r.STAFF_SQ, function() { load(refreshCardTabs); });
		}
		if (cardTab === TAB.SECRET && CAN_SECRET) secretTab(card(true), r);
		if (cardTab === TAB.EQP) {
			var $eq = $('<div id="staffEquipment">').appendTo(card(true));
			loadEquipment(r.STAFF_SQ, function(list) {
				$eq.empty().append($('<div class="hr-section">').text('대여 중인 장비 ' + list.length + '대'));
				if (!list.length) { $eq.append('<div class="small text-muted">대여 중인 장비가 없습니다.</div>'); return; }
				var $b = $('<tbody>');
				list.forEach(function(e) { $b.append($('<tr>').append($('<td>').text(e.EQP_NO), $('<td>').append($('<span class="sc-pill">').text(EQ_TYPE[e.TYPE_CD] || e.TYPE_CD)), $('<td>').text(e.MODEL_NM || '-'), $('<td>').text(e.START_DT || '-'), $('<td>').text(e.PURPOSE_NM || '-'))); });
				$eq.append($('<div class="table-responsive">').append($('<table class="sc-table" data-nosort>')
					.append('<thead><tr><th>장비번호</th><th>구분</th><th>모델</th><th>대여일</th><th>용도</th></tr></thead>').append($b)));
			});
		}
	}
	// 계정관리 계정 카드의 시크릿 탭과 같은 스위치·설명. 바로 저장된다
	function secretTab($p, r) {
		var $box = $('<div>').appendTo($p).append('<div class="small text-muted">불러오는 중…</div>');
		hrPost('/admin/staff/staffSecretData.do', { STAFF_SQ: r.STAFF_SQ }, function(res) {
			var s = res.result || {};
			$box.empty().append($('<div class="hr-section">').text('🔒 시크릿'));
			var $chk = $('<input type="checkbox" class="custom-control-input" id="stSecret">').prop('checked', s.SECRET_YN === 'Y');
			$box.append($('<div class="custom-control custom-switch mb-2">').append($chk).append($('<label class="custom-control-label font-weight-bold" for="stSecret">').text(s.linked ? '🔒 시크릿 계정 (' + s.EMPLY_ID + ')' : '🔒 시크릿 직원 (로그인 계정 없음)')))
				.append($('<div class="small text-muted">').text('켜면 이 직원의 직원관리·투입현황·급여관리 행과 합계·건수·엑셀이 시크릿이 아닌 사람에게 모두 빠집니다. 시크릿 계정끼리는 서로 보입니다. '
					+ (s.linked ? '계정관리의 시크릿 탭과 같은 설정이며, ' : '로그인 계정이 없어 이 직원은 숨겨지기만 하고, 시크릿 직원을 보는 권한은 계정에 켭니다. ') + '이 탭은 슈퍼관리자에게만 보이고 바로 저장됩니다.'));
			$chk.on('change', function() {
				var box = this;
				hrPost('/admin/staff/setStaffSecretData.do', { STAFF_SQ: r.STAFF_SQ, SECRET_YN: box.checked ? 'Y' : 'N' }, function() { toast('시크릿을 ' + (box.checked ? '켰습니다' : '껐습니다')); load(); }, function() { box.checked = !box.checked; });
			});
		});
	}

	var EQ_TYPE = hrCodeMap('EQP_TYPE');
	function loadEquipment(sq, done) {
		hrPost('/admin/equipment/staffEquipmentData.do', { STAFF_SQ: sq }, function(res) { done(res.result || []); });
	}

	// ── 영업정보 탭: 기술 스택은 수행이력에서 자동으로 모은다 ──
	function salesGrid($p, r, fields) {
		var $g = $('<div class="st-grid">').appendTo($p);
		fields.forEach(function(f) { $g.append($('<div class="hr-card-row">').append($('<div class="hr-card-label">').text(LABELS[f])).append(editable($('<div>'), r, f))); });
	}

	function salesTab(card, r) {
		function head($c, title, fields, type) { $c.append(sectionHead(r, title, fields.map(function(f) { return [f, LABELS[f], type]; }))); }
		var $st = card(true).append($('<div class="hr-section">').append('기술 스택&nbsp;').append('<span class="small text-muted font-weight-normal">수행이력에서 자동 계산 · 숫자는 프로젝트 수 · 칩을 누르면 그 프로젝트만 봅니다</span>'));
		var d = career && career.sq === r.STAFF_SQ ? career.d : null;
		if (!d) $st.append('<div class="small text-muted">불러오는 중…</div>');
		else scStack($st, d.items, function(t) { career.pick = t; cardTab = TAB.CAREER; paintCard(); });
		var $terms = card();
		head($terms, '영업 조건', SALES_TERMS);
		salesGrid($terms, r, SALES_TERMS);
		var texts = SALES_TEXTS.concat(['SK_EXTRA']), $etc = card();
		head($etc, '업무·기타', texts, 'textarea');
		texts.forEach(function(f) { $etc.append($('<div class="hr-card-row st-skill">').append($('<div class="hr-card-label">').text(LABELS[f])).append(editable($('<div>'), r, f))); });
	}

	// ── 탭 안의 수정 팝업과 여러 건 항목 ──
	function sectionHead(r, title, fields) {
		return $('<div class="hr-section d-flex align-items-center">').text(title)
			.append($('<button type="button" class="btn btn-sm btn-outline-secondary ml-auto">').attr('aria-label', title + ' 수정').html('<i class="fas fa-pen"></i> 수정').on('click', function() { editSection(r, title, fields); }));
	}

	function editSection(r, title, fields) {
		openEditor(title + ' 수정', fields.map(function(f) { return { name: f[0], label: f[1], type: f[2] === 'secret' ? null : f[2], val: r[f[0]] || '' }; }), function(vals, done) {
			saveFields(r, fields.map(function(f) { return [f[0], vals[f[0]], r[f[0]] || '']; }), done);
		});
	}

	var edSave = null;
	function openEditor(title, fields, save) {
		var $f = $('#edFields').empty();
		fields.forEach(function(f) {
			var id = 'ed_' + f.name, $c = hrControl(f.type, f.val).attr({ id: id, name: f.name }).prop('required', !!f.required);
			$('<div class="mb-2">').addClass(f.type === 'textarea' ? 'col-12' : 'col-md-6').append($('<label>').attr('for', id).text(f.label + (f.required ? ' *' : ''))).append($c).appendTo($f);
		});
		edSave = save;
		$('#edTitle').text(title);
		$('#edModal').modal('show');
	}

	function submitEditor() {
		var vals = {};
		$('#edFields [name]').each(function() { vals[this.name] = $.trim($(this).val()); });
		edSave(vals, function() { $('#edModal').modal('hide'); toast('저장했습니다'); });
	}

	// list: [칸, 새 값, 이전 값]. 바뀐 칸만 차례로 저장한다
	function saveFields(r, list, done) {
		var todo = list.filter(function(x) { return x[1] !== String(x[2]); });
		(function next(i) {
			if (i >= todo.length) { fillFilters(); render(); paintCard(); done(); return; }
			var field = todo[i][0], val = todo[i][1];
			hrPost('/admin/staff/saveStaffFieldData.do', { STAFF_SQ: r.STAFF_SQ, FIELD: field, VALUE: val }, function() {
				var secret = field === 'RRN' || field === 'ACCOUNT';
				r[field] = secret ? maskLocal(field, val) : val;
				if (secret) delete revealed[r.STAFF_SQ + '|' + field];
				next(i + 1);
			}, paintCard);
		})(0);
	}

	function has(v) { return !!v && v !== '-'; }

	function itemRows(r, spec) {
		var out = spec.base.map(function(b) { return { base: b, v: b.map(function(f) { return r[f] || ''; }) }; }).filter(function(x) { return x.v.some(has); });
		(items && items.sq === r.STAFF_SQ ? items.list : []).filter(function(i) { return i.ITEM_CD === spec.cd; }).forEach(function(i) {
			out.push({ item: i, v: spec.cols.map(function(c) { return i[c[0]] || ''; }) });
		});
		function ym(x) { return x.v[3].replace(/[^0-9]/g, '').substr(0, 6); }
		return spec.cd === 'EDU' ? out.sort(function(a, b) { return ym(b).localeCompare(ym(a)); }) : out;
	}

	function itemSection($p, r, spec) {
		var loaded = items && items.sq === r.STAFF_SQ, list = itemRows(r, spec);
		$p.append($('<div class="hr-section d-flex align-items-center">').text(spec.title).append($('<span class="small text-muted font-weight-normal ml-2">').text(loaded ? list.length + '건' : ''))
			.append($('<button type="button" class="btn btn-sm btn-outline-primary ml-auto">').attr('aria-label', spec.title + ' 추가').html('<i class="fas fa-plus"></i> 추가').on('click', function() { openItem(r, spec, null); })));
		if (!loaded) loadItems(r.STAFF_SQ);
		if (loaded && !list.length) $p.append($('<div class="small text-muted">').text('등록된 ' + spec.title + ' 정보가 없습니다.'));
		if (list.length) {
			var $body = $('<tbody>');
			list.forEach(function(x) {
				var $tr = $('<tr>').appendTo($body);
				x.v.forEach(function(v, i) {
					if (spec.cd === 'EDU' && i === 0 && !v) $tr.append('<td class="st-unset">구분 미지정</td>');
					else $tr.append($('<td>').text(v || '-'));
				});
				$tr.append($('<td class="text-right text-nowrap">')
					.append($('<button type="button" class="st-act">').attr('aria-label', spec.title + ' ' + (x.v[1] || x.v[0]) + ' 수정').html('<i class="fas fa-pen"></i>').on('click', function() { openItem(r, spec, x); }))
					.append($('<button type="button" class="st-act">').attr('aria-label', spec.title + ' ' + (x.v[1] || x.v[0]) + ' 삭제').html('<i class="fas fa-trash"></i>').on('click', function() { deleteItem(r, spec, x); })));
			});
			$p.append($('<div class="table-responsive">').append($('<table class="table table-sm cal-table st-prj st-item mb-2">')
				.append($('<thead>').append($('<tr>').append(spec.cols.map(function(c) { return $('<th>').text(c[1]); })).append('<th style="width:64px;"><span class="sr-only">관리</span></th>'))).append($body)));
		}
		if (spec.extra) salesGrid($p, r, spec.extra);
	}

	function loadItems(sq) {
		hrPost('/admin/staff/staffItemData.do', { STAFF_SQ: sq }, function(res) {
			items = { sq: sq, list: res.list || [] };
			if (String(opened) === String(sq) && cardTab < 2) paintCard();
		});
	}

	function openItem(r, spec, x) {
		// 기존 칸 값은 형식이 제각각이라 달력이 빈칸으로 만들지 않게 글자로 고친다
		var fields = spec.cols.map(function(c, i) { return { name: c[0], label: c[1], type: x && x.base && c[2] === 'month' ? null : c[2], required: !(x && x.base) && c[3], val: x ? x.v[i] : '' }; });
		openEditor(spec.title + (x ? ' 수정' : ' 추가'), fields, function(vals, done) {
			if (x && x.base) { saveFields(r, x.base.map(function(f, i) { return [f, vals['C' + (i + 1)], x.v[i]]; }), done); return; }
			hrPost('/admin/staff/saveStaffItemData.do', $.extend({ C3: '', C4: '', C5: '' }, vals, { STAFF_SQ: r.STAFF_SQ, ITEM_CD: spec.cd, ITEM_SQ: x ? x.item.ITEM_SQ : '' }), function() { loadItems(r.STAFF_SQ); done(); });
		});
	}

	function deleteItem(r, spec, x) {
		bootbox.confirm(spec.title + ' ' + (x.v[1] || x.v[0]) + ' 정보를 삭제할까요? 되돌릴 수 없습니다.', function(ok) {
			if (!ok) return;
			if (x.base) saveFields(r, x.base.map(function(f, i) { return [f, '', x.v[i]]; }), function() {});
			else hrPost('/admin/staff/deleteStaffItemData.do', { STAFF_SQ: r.STAFF_SQ, ITEM_SQ: x.item.ITEM_SQ }, function() { loadItems(r.STAFF_SQ); });
		});
	}

	// ── 수행이력 탭 (서버가 원본. 「새 버전으로 저장」을 눌러야 버전이 생긴다) ──
	var SC_ACT = { ADD: '추가', EDIT: '수정', DEL: '삭제', VERSION: '버전', RESTORE: '되돌림', IMPORT: '가져오기' };
	var SC_LOCKED = ['PRJ_NM', 'CLIENT_NM', 'START_YM', 'END_YM']; // 사내 투입 줄은 투입현황을 따른다
	var scEdit = null, scImp = null; // 고치는 줄 { PRJ_SQ, DEPLOY_SQ } / 워드에서 읽은 줄 { name, rows }

	function loadCareer(sq) {
		hrPost('/admin/staff/careerData.do', { STAFF_SQ: sq }, function(res) {
			career = { sq: sq, d: res.result, pick: career && career.sq === sq ? career.pick : null };
			var r = find(sq);
			if (r) r.PRJ_CNT = career.d.items.length;
			if (String(opened) === String(sq) && (cardTab === TAB.SALES || cardTab === TAB.CAREER)) paintCard();
		});
	}

	function careerTab($c, r) {
		var d = career && career.sq === r.STAFF_SQ ? career.d : null, sq = r.STAFF_SQ;
		if (!d) { $c.append('<div class="small text-muted">불러오는 중…</div>'); return; }
		function stat(k, v) { return $('<div class="st-stat">').append($('<small>').text(k)).append($('<b>').text(v)); }
		function btn(cls, html, fn) { return $('<button type="button" class="btn btn-sm">').addClass(cls).html(html).on('click', fn); }
		var $save = btn('btn-primary', '💾 새 버전으로 저장', function() { saveVersion(sq); }).prop('disabled', !d.dirty).attr('title', d.dirty ? '' : '최신 버전과 같아 저장할 것이 없습니다');
		$c.append($('<div class="st-hero">')
			.append(stat('총 경력', scCareer(d.items) || '-')).append(stat('프로젝트', d.items.length + '건'))
			.append(stat('버전', (d.ver ? '순정 v' + d.ver.VER_NO : '없음') + (d.edit ? ' · 가필 v' + d.edit.VER_NO : '')))
			.append($('<div class="st-btns">')
				.append(btn('btn-outline-primary', '<i class="fas fa-plus"></i> 이력 추가', function() { openCareer(null); }))
				.append($save)
				.append(btn('btn-outline-secondary', '🕘 버전', function() { openVersions(sq); }))
				.append(btn('btn-outline-primary', '✨ 프로필 자동생성', function() { openGen(sq); }))
				.append(btn('btn-outline-secondary', '📄 워드 받기', function() { chooseWord(sq); }))
				.append(btn('btn-outline-secondary', '<i class="fab fa-google-drive"></i> 워드 올리기', function() { careerWordDrive(sq); }))
				.append(btn('btn-outline-secondary', '⤒ 워드 가져오기', function() { openImport(); }))));
		if (d.dirty) $c.append($('<div class="st-dirty" role="status">').append($('<b>').text('작업 중')).append($('<span>').text(d.dirty + ' · 아직 버전으로 저장하지 않았습니다' + (d.ver ? ' (최신 v' + d.ver.VER_NO + ' · ' + d.ver.REG_DT + ')' : ''))));
		if (career.pick) $c.append($('<div class="st-bulk">').append($('<span>').text('「' + career.pick + '」 를 쓴 프로젝트만 보는 중'))
			.append(btn('btn-link p-0', '전체 보기', function() { career.pick = null; paintCard(); })));

		// 줄을 체크하면 나오는 일괄 처리 띠
		var $field = $('<select class="form-control form-control-sm" style="width:auto;" aria-label="한 번에 넣을 항목">'), $val = $('<input class="form-control form-control-sm" style="width:200px;" list="scBulkList" aria-label="넣을 값 (쉼표로 여러 개)" placeholder="값 (쉼표로 여러 개)">');
		var $list = $('<datalist id="scBulkList">'), $n = $('<b>');
		SC_PICKS.forEach(function(p) { $field.append($('<option>').val(p[0]).text(p[1])); });
		function fillList() { $list.empty(); (d.chips[$field.val()] || []).forEach(function(v) { $list.append($('<option>').val(v)); }); }
		$field.val('LANG_NM').on('change', fillList);
		fillList();
		function picked() { return $c.find('.sc-chk:checked').map(function() { return this.value; }).get(); }
		var $bulk = $('<div class="st-bulk">').prop('hidden', true).append($n).append('<span>에</span>').append($field).append($val).append($list)
			.append(btn('btn-primary', '한 번에 넣기', function() {
				hrPost('/admin/staff/bulkCareerData.do', { STAFF_SQ: sq, PRJ_SQS: picked().join(','), FIELD: $field.val(), VALUES: $val.val() }, function() { toast('넣었습니다'); loadCareer(sq); });
			}))
			.append(btn('btn-outline-danger ml-auto', '선택 삭제', function() { deleteCareer(sq, picked(), picked().length + '건'); })).appendTo($c);
		$c.on('change', '.sc-chk', function() { var n = picked().length; $bulk.prop('hidden', !n); $n.text(n + '건'); });

		var shown = career.pick ? d.items.filter(function(it) { return scEnv.some(function(e) { return scTokens(it[e[0]]).indexOf(career.pick) >= 0; }) || scTokens(it.IND_NM).concat(scTokens(it.ROLE_NM)).indexOf(career.pick) >= 0; }) : d.items;
		scTable($c, shown, { check: true, pick: career.pick, edit: function(it) { openCareer(it); }, copy: function(it) { openCareer(it, true); }, fill: function(it) { openCareer(it); },
			del: function(it) { deleteCareer(sq, [it.PRJ_SQ], it.PRJ_NM); }, empty: '프로젝트 이력이 없습니다. 「이력 추가」 나 「워드 가져오기」 로 시작하세요.' });

		if (d.logs.length) {
			var $lb = $('<tbody>');
			d.logs.forEach(function(l) { $lb.append($('<tr>').append($('<td class="text-nowrap text-muted">').text(l.REG_DT), $('<td class="text-nowrap">').append($('<span class="sc-pill">').text(SC_ACT[l.ACT_CD] || l.ACT_CD)), $('<td>').text([l.PRJ_NM, l.DETAIL].filter(Boolean).join(' · ')), $('<td class="text-nowrap text-muted">').text(l.REG_EMPLY_ID || ''))); });
			$c.append($('<details class="mt-3">').append($('<summary class="small text-muted">').text('최근 변경 ' + d.logs.length + '건')).append($('<table class="st-log w-100 mt-1" data-nosort>').append($lb)));
		}
	}

	function deleteCareer(sq, prjSqs, label) {
		bootbox.confirm(label + ' 수행이력을 삭제할까요? 저장해 둔 버전이 있으면 「🕘 버전」 에서 되돌릴 수 있습니다.', function(ok) {
			if (ok) hrPost('/admin/staff/deleteCareerData.do', { STAFF_SQ: sq, PRJ_SQS: prjSqs.join(',') }, function() { toast('삭제했습니다'); loadCareer(sq); });
		});
	}

	function saveVersion(sq) {
		hrPost('/admin/staff/saveCareerVersionData.do', { STAFF_SQ: sq }, function(res) { toast('v' + res.result + ' 로 저장했습니다'); loadCareer(sq); });
	}

	function careerWord(sq, verNo) {
		if (!verNo && career && career.d && career.d.dirty && career.d.ver) toast('최신 버전(v' + career.d.ver.VER_NO + ') 기준입니다. 작업 중 내용은 새 버전으로 저장한 뒤 받으세요');
		location.href = '/admin/staff/careerWord.do?STAFF_SQ=' + sq + (verNo ? '&VER_NO=' + verNo : '');
	}

	function careerWordDrive(sq) {
		toast('드라이브에 올리는 중…');
		hrPost('/admin/staff/careerWordDriveData.do', { STAFF_SQ: sq }, function() { toast('드라이브 폴더에 이력카드 워드를 올렸습니다 (이전에 올린 것은 바꿈)'); });
	}

	// ── 칩으로 넣는 입력 창 ──
	function careerInit() {
		$('#scOngoing').on('change', syncOngoing);
		$('#scSaveMore').on('click', function() { if ($('#scForm')[0].reportValidity()) saveCareer(true); });
		$('#scDelete').on('click', function() { $('#scModal').modal('hide'); deleteCareer(opened, [scEdit.PRJ_SQ], $('#scPRJ_NM').val()); });
		$('#scCopyPrev').on('click', copyPrevEnv);
		$('#scPick').on('click', '.sc-chip', function() { $(this).toggleClass('on').attr('aria-pressed', $(this).hasClass('on')); })
			.on('keydown', '.st-add', function(e) {
				if (e.key !== 'Enter') return;
				e.preventDefault(); // 폼이 저장되지 않게
				var $in = $(this);
				scTokens($in.val()).forEach(function(v) { pickChip($in.closest('[data-col]'), v, true); });
				$in.val('');
			});
		$('#scImpFile').on('change', readImport);
		$('#scImpApply').on('click', applyImport);
		genInit();
		dmInit();
	}

	function syncOngoing() {
		var on = $('#scOngoing').prop('checked'), locked = !!(scEdit && scEdit.DEPLOY_SQ);
		$('#scEND_YM').prop({ disabled: on || locked, required: !on });
		if (on) $('#scEND_YM').val('');
	}

	// 있는 칩이면 켜고, 없으면 만들어 켠다
	function pickChip($row, v, on) {
		var $chip = $row.find('.sc-chip').filter(function() { return $(this).text() === v; });
		if (!$chip.length) $chip = $('<button type="button" class="sc-chip gray">').text(v).insertBefore($row.find('.st-add'));
		if (on) $chip.addClass('on');
		$chip.attr('aria-pressed', $chip.hasClass('on'));
	}

	function openCareer(it, copy) {
		var d = career.d, x = it || {}, deploy = !copy && x.SRC === 'DEPLOY';
		scEdit = { PRJ_SQ: copy ? '' : (x.PRJ_SQ || ''), DEPLOY_SQ: deploy ? x.DEPLOY_SQ : '' };
		SC_TEXTS.forEach(function(f) { $('#sc' + f).val(x[f] || '').prop('disabled', deploy && SC_LOCKED.indexOf(f) >= 0); });
		$('#scOngoing').prop('checked', !!it && !x.END_YM).prop('disabled', deploy);
		syncOngoing();
		$('#scDeployNote').prop('hidden', !deploy);
		$('#scClients').empty().append((d.chips.CLIENT_NM || []).map(function(v) { return $('<option>').val(v); }));
		$('#scCompanies').empty().append((d.chips.COMPANY_NM || []).map(function(v) { return $('<option>').val(v); }));
		var $p = $('#scPick').empty();
		SC_PICKS.forEach(function(p) {
			var $row = $('<div>').attr('data-col', p[0]).append($('<input class="form-control st-add" placeholder="＋ 직접 입력">').attr('aria-label', p[1] + ' 직접 입력'));
			$p.append($('<span class="k">').text(p[1])).append($row);
			(d.chips[p[0]] || []).forEach(function(v) { pickChip($row, v, false); });
			scTokens(x[p[0]]).forEach(function(v) { pickChip($row, v, true); });
		});
		$('#scDelete').prop('hidden', !scEdit.PRJ_SQ || deploy);
		$('#scSaveMore').prop('hidden', !!it && !copy);
		$('#scTitle').text('수행이력 ' + (!it ? '추가' : copy ? '복제' : deploy ? '개발환경 입력' : '수정'));
		$('#scModal').modal('show');
	}

	// 지금 고치는 줄 말고, 개발환경이 있는 가장 최근 프로젝트 것을 켠다
	function copyPrevEnv() {
		var prev = career.d.items.filter(function(it) { return !(scEdit.PRJ_SQ && String(it.PRJ_SQ) === String(scEdit.PRJ_SQ)) && scEnv.some(function(e) { return it[e[0]]; }); })[0];
		if (!prev) { toast('개발환경이 입력된 다른 프로젝트가 없습니다'); return; }
		scEnv.forEach(function(e) { scTokens(prev[e[0]]).forEach(function(v) { pickChip($('#scPick [data-col=' + e[0] + ']'), v, true); }); });
		toast(prev.PRJ_NM + ' 의 개발환경을 켰습니다');
	}

	function saveCareer(more) {
		var sq = opened, data = { STAFF_SQ: sq, PRJ_SQ: scEdit.PRJ_SQ, DEPLOY_SQ: scEdit.DEPLOY_SQ, ONGOING_YN: $('#scOngoing').prop('checked') ? 'Y' : 'N' };
		SC_TEXTS.forEach(function(f) { data[f] = $.trim($('#sc' + f).val()); });
		$('#scPick [data-col]').each(function() {
			// 적어 두고 Enter 를 안 누른 값도 넣는다
			data[$(this).attr('data-col')] = $(this).find('.sc-chip.on').map(function() { return $(this).text(); }).get().concat(scTokens($(this).find('.st-add').val())).join(', ');
		});
		hrPost('/admin/staff/saveCareerData.do', data, function() {
			toast('수행이력을 저장했습니다');
			if (more) {
				// 방금 넣은 값이 칩으로 나오게 다시 읽은 뒤 빈 창을 연다
				hrPost('/admin/staff/careerData.do', { STAFF_SQ: sq }, function(res) { career = { sq: sq, d: res.result, pick: null }; paintCard(); openCareer(null); });
				return;
			}
			$('#scModal').modal('hide');
			loadCareer(sq);
		});
	}

	// ── 버전 창 ──
	function openVersions(sq) {
		$('#scVerView').empty();
		var $b = $('#scVerBody').empty();
		hrPost('/admin/staff/careerVersionsData.do', { STAFF_SQ: sq }, function(res) {
			var list = res.result || [];
			list.forEach(function(v, i) {
				function b(text, fn) { return $('<button type="button" class="btn btn-sm btn-outline-secondary mr-1">').text(text).attr('aria-label', 'v' + v.VER_NO + ' ' + text).on('click', fn); }
				var edit = v.VER_KIND === 'EDIT';
				$b.append($('<tr>').append($('<td>').append($('<b>').text('v' + v.VER_NO)).append(i === 0 ? ' <span class="sc-pill in">최신</span>' : ''),
					$('<td class="text-nowrap">').append($('<span class="sc-pill">').toggleClass('warn', edit).text(edit ? '가필' : '순정')).append(edit && v.BASE_VER ? $('<small class="text-muted">').text(' v' + v.BASE_VER + ' 기준') : ''), $('<td class="text-nowrap">').text(v.REG_DT), $('<td>').text(v.REG_EMPLY_ID || ''), $('<td>').text(v.PRJ_CNT + '건'), $('<td>').text(v.SUMMARY || ''),
					$('<td class="text-nowrap text-right">').append(b('보기', function() { viewVersion(sq, v.VER_NO, edit ? v.BASE_VER : null); })).append(b('워드', function() { careerWord(sq, v.VER_NO); })).append(edit ? '' : b('이 버전으로', function() { restoreVersion(sq, v.VER_NO); }))));
			});
			if (!list.length) boEmpty($b, '저장한 버전이 없습니다. 수행이력 탭에서 「새 버전으로 저장」 을 누르면 생깁니다.');
			$('#scVerModal').modal('show');
		});
	}

	// 가필(baseNo 있음)은 기준 순정 버전과 달라진 칸을 노랗게
	function viewVersion(sq, verNo, baseNo) {
		hrPost('/admin/staff/careerVersionData.do', { STAFF_SQ: sq, VER_NO: verNo }, function(res) {
			function show(cells) {
				scTable($('#scVerView').empty().append($('<div class="hr-section">').text('v' + verNo + ' 의 수행이력 (읽기 전용)' + (baseNo ? ' · 노란 칸은 v' + baseNo + '(순정)과 다른 곳' : ''))), res.result || [], { cells: cells });
			}
			if (!baseNo) return show(null);
			hrPost('/admin/staff/careerVersionData.do', { STAFF_SQ: sq, VER_NO: baseNo }, function(b) { show(scCells(b.result || [], res.result || [])); });
		});
	}

	// 기준과 비교해 줄(프로젝트명+시작월)마다 달라진 칸
	var SC_COLS = ['PRJ_NM', 'CLIENT_NM', 'COMPANY_NM', 'WORK_NM', 'WORK_AREA', 'ROLE_NM', 'START_YM', 'END_YM', 'IND_NM', 'APP_NM', 'MACHINE_NM', 'OS_NM', 'LANG_NM', 'DBMS_NM', 'TOOL_NM', 'FRAMEWORK_NM', 'ETC_NM'];
	function scCells(base, items) {
		var by = {}, out = {};
		base.forEach(function(it) { by[scKey(it)] = it; });
		items.forEach(function(it) {
			var b = by[scKey(it)];
			out[scKey(it)] = SC_COLS.filter(function(c) { return !b || String(b[c] || '') !== String(it[c] || ''); });
		});
		return out;
	}

	// 📄 워드 받기: 순정 최신 / 가필 최신 / 버전 창에서 고르기
	function chooseWord(sq) {
		var d = career.d, opts = [{ text: '순정 최신' + (d.ver ? ' (v' + d.ver.VER_NO + ')' : ' (버전 없음 · 지금 내용)'), value: 'ORIG' }];
		if (d.edit) opts.push({ text: '가필 최신 (v' + d.edit.VER_NO + ')', value: 'EDIT' });
		opts.push({ text: '고른 버전 (버전 창에서 「워드」)', value: 'PICK' });
		bootbox.prompt({ title: '어느 수행이력으로 워드를 만들까요?', inputType: 'select', inputOptions: opts, value: 'ORIG', callback: function(v) {
			if (v === 'PICK') openVersions(sq);
			else if (v) careerWord(sq, v === 'EDIT' ? 'EDIT' : '');
		} });
	}

	// ── ✨ 프로필 자동생성 (서버가 실제 프로젝트로 고른 자리·고정 줄·횟수대로 짠다) ──
	// scGen: { sq, slots: [{t: IND|ROLE, v: '금융 > 은행'}] 고른 순서(같은 값 여러 번 가능), pins: {KEY: {pos, start, end}} 사람이 옮기거나 기간을 고친 줄,
	//          codes: {IND: [...], ROLE: [...]}, open: {IND: 펼친 1단계}, edit: 목록 편집 중 }
	var scGen = null, GEN_KIND = { IND: '산업', ROLE: '역할' };
	function genConf() {
		function one(id) { return $('#' + id + ' .sc-chip.on').attr('data-v'); }
		var pins = Object.keys(scGen.pins).map(function(k) { var p = scGen.pins[k]; return { key: k, pos: p.pos, start: p.start, end: p.end }; });
		return { skills: $('#scGenSkills .sc-chip.on').map(function() { return $(this).attr('data-v'); }).get(), months: +$('#scGenMonths').val(), max: +$('#scGenMaxR').val(),
			sort: one('scGenSort'), slots: scGen.slots, pins: pins, photo: one('scGenPhoto') === 'Y' };
	}
	// 볼륨 스위치처럼 끄는 막대(--p 만큼 채움)와 옆 숫자 칸을 맞춘다
	function volPaint() {
		$('#scGenMonths, #scGenMaxR').each(function() { var $r = $(this), min = +$r.attr('min'), max = +$r.attr('max'); $r.css('--p', ((+$r.val() - min) / (max - min) * 100) + '%'); });
		var m = +$('#scGenMonths').val();
		$('#scGenY').val(Math.floor(m / 12));
		$('#scGenM').val(m % 12);
		$('#scGenN').val($('#scGenMaxR').val());
	}
	function clampNum(v, lo, hi) { v = Math.round(+v || 0); return Math.max(lo, Math.min(hi, v)); }
	function genChips(id, list, on) {
		$('#' + id).empty().append(list.map(function(x) { var v = String(x[0]); return $('<button type="button" class="sc-chip gray">').attr('data-v', v).toggleClass('on', on.indexOf(v) >= 0).attr('aria-pressed', on.indexOf(v) >= 0).text(x[1]); }));
	}
	function openGen(sq) {
		var d = career.d, list = [], seen = {};
		// 칩: 이 사람 수행이력에서 많이 쓴 기술(숫자는 프로젝트 수) 먼저, 그다음 회사에서 자주 쓰는 기술
		scEnv.slice(0, 4).forEach(function(e) { scCount(d.items, e[0]).forEach(function(t) { if (!seen[t[0]]) { seen[t[0]] = 1; list.push([t[0], t[0] + ' ' + t[1]]); } }); });
		scEnv.slice(0, 4).forEach(function(e) { (d.chips[e[0]] || []).slice(0, 12).forEach(function(v) { if (!seen[v]) { seen[v] = 1; list.push([v, v]); } }); });
		scGen = { sq: sq, slots: [], pins: {}, codes: d.codes || { IND: [], ROLE: [] }, open: {}, edit: false };
		genChips('scGenSkills', list, []);
		// 처음 기간은 가장 오래된 프로젝트 시작월부터 지금까지(1년 단위로 올림, 100년까지), 횟수는 프로젝트 수(1~100)
		var now = new Date(), oldest = d.items.map(function(it) { return String(it.START_YM || ''); }).filter(function(v) { return /^\d{4}-\d{2}/.test(v); }).sort()[0];
		var span = oldest ? (now.getFullYear() - +oldest.slice(0, 4)) * 12 + now.getMonth() + 1 - +oldest.slice(5, 7) + 1 : 120;
		$('#scGenMonths').val(clampNum(Math.ceil(span / 12) * 12, 12, 1200));
		$('#scGenMaxR').val(clampNum(d.items.length, 1, 100));
		volPaint();
		genChips('scGenSort', [['match', '기술 일치순'], ['recent', '최신순']], ['match']);
		genTrees();
		genSlots();
		var photo = docFiles(find(sq) || {}, 'DOC_PHOTO').length > 0;
		genChips('scGenPhoto', [['Y', '보이기'], ['', '가리기']], [photo ? 'Y' : '']);
		$('#scGenPhoto [data-v=Y]').prop('disabled', !photo).attr('title', photo ? '서류 탭 증명사진을 워드 첫 장에 보여요' : '서류 탭에 증명사진 파일이 없어요');
		$('#scGenModal').modal('show');
		if (!d.items.length) {
			// 고를 프로젝트가 없으면 계산하지 않고 어디서 채우는지 알려 준다
			$('#scGenSum').text('미리보기 · 0건');
			$('#scGenView').html('<div class="sc-gen-empty"><b>이 직원은 수행이력이 없습니다.</b><br>수행이력 탭에서 프로젝트를 넣거나, 목록 위 「드라이브에서 일괄 찾기」로 드라이브의 이력카드 워드를 가져오면 여기서 고를 수 있어요.</div>');
			$('#scGenSave, #scGenWord').prop('disabled', true);
			return;
		}
		genPreview();
	}
	// 산업·역할 1단계 칩 → 누르면 그 2단계가 펼쳐지고, 2단계(또는 「1단계 전체」)를 누를 때마다 자리가 하나씩 쌓인다
	function genTrees() {
		$('#scGenPick .sc-tree').each(function() {
			var kind = $(this).attr('data-kind'), list = scGen.codes[kind] || [], open = scGen.open[kind], $t = $(this).empty();
			var $top = $('<div class="sc-tree-top">').append($('<span class="sc-tree-k">').text(GEN_KIND[kind])).appendTo($t);
			list.filter(function(n) { return n.indexOf('>') < 0; }).forEach(function(n) {
				var $c = $('<button type="button" class="sc-chip gray sc-l1">').attr({ 'data-kind': kind, 'data-v': n, 'aria-expanded': open === n }).toggleClass('on', open === n).text(n + ' ▸');
				$top.append(scGen.edit ? $('<span class="sc-del-wrap">').append($c).append(genDelBtn(kind, n)) : $c);
			});
			$top.append($('<input type="text" class="form-control form-control-sm sc-add">').attr({ 'data-kind': kind, placeholder: '＋ 새 ' + GEN_KIND[kind] + ' (예: ' + (kind === 'IND' ? '금융 > 은행' : '개발 > 백엔드') + ')', 'aria-label': '새 ' + GEN_KIND[kind] + ' 추가' }));
			$top.append($('<button type="button" class="btn btn-link btn-sm sc-edit">').attr('data-kind', kind).text(scGen.edit ? '편집 끝' : '목록 편집'));
			if (!open) return;
			var $sub = $('<div class="sc-tree-sub">').appendTo($t);
			$sub.append($('<button type="button" class="sc-chip sc-pick">').attr({ 'data-kind': kind, 'data-v': open }).text('＋ ' + open + ' 전체'));
			list.filter(function(n) { return n.indexOf(open + ' >') === 0; }).forEach(function(n) {
				var $c = $('<button type="button" class="sc-chip sc-pick">').attr({ 'data-kind': kind, 'data-v': n }).text('＋ ' + n.split(' > ')[1]);
				$sub.append(scGen.edit ? $('<span class="sc-del-wrap">').append($c).append(genDelBtn(kind, n)) : $c);
			});
		});
	}
	function genDelBtn(kind, n) {
		return $('<button type="button" class="sc-del">').attr({ 'data-kind': kind, 'data-v': n, 'aria-label': n + ' 목록에서 삭제', title: '목록에서 삭제(공통코드)' }).html('&times;');
	}
	function genCode(kind, nm, act) {
		hrPost('/admin/staff/prjCodeData.do', { KIND: kind, NM: nm, ACT: act }, function(res) {
			scGen.codes = res.result;
			career.d.codes = res.result;
			if (act === 'DEL' && scGen.open[kind] === nm) delete scGen.open[kind];
			if (act === 'ADD') scGen.open[kind] = nm.split('>')[0].trim();
			genTrees();
			toast(nm + (act === 'DEL' ? ' 삭제' : ' 추가') + ' · 공통코드에도 반영');
		});
	}
	function genSlots() {
		var $s = $('#scGenSlots').empty();
		if (!scGen.slots.length) { $s.append('<span class="small text-muted">고른 자리 없음 · 아래에서 고르면 그 산업·역할 프로젝트가 고른 순서대로 앞에 놓여요(두 번 고르면 두 줄)</span>'); return; }
		scGen.slots.forEach(function(s, i) {
			$s.append($('<span class="sc-slot">').attr('data-kind', s.t).append($('<em>').text((i + 1) + ' ' + GEN_KIND[s.t])).append(document.createTextNode(' ' + s.v))
				.append($('<button type="button" class="sc-slot-x">').attr({ 'data-i': i, 'aria-label': (i + 1) + '번 자리 ' + s.v + ' 빼기' }).html('&times;')));
		});
	}
	function genPreview() {
		var conf = genConf();
		hrPost('/admin/staff/careerGenData.do', { STAFF_SQ: scGen.sq, GEN: JSON.stringify(conf) }, function(res) {
			var items = res.result || [], real = items.filter(function(it) { return it.EMPTY !== 'Y'; }), hit = real.filter(function(it) { return it.MATCH > 0; }).length;
			scGen.rows = items;
			$('#scGenSum').text('미리보기 · ' + real.length + '건' + (items.length > real.length ? ' · 못 채운 자리 ' + (items.length - real.length) : '') + (conf.skills.length ? ' · 고른 기술이 들어간 프로젝트 ' + hit + '건' : ''));
			genTable(items, conf.skills);
			$('#scGenSave, #scGenWord').prop('disabled', !real.length);
		});
	}
	// 미리보기 표: ▲▼ 로 옮기거나 기간을 고치면 그 줄은 📌 고정(다음 계산에서도 그 자리·기간), 📌 를 다시 누르면 풀린다
	function genTable(items, skills) {
		var now = new Date(), thisYm = now.getFullYear() + '-' + ('0' + (now.getMonth() + 1)).slice(-2);
		var $tb = $('<tbody>');
		items.forEach(function(it, i) {
			var $tr = $('<tr>').attr('data-i', i).appendTo($tb);
			if (it.EMPTY === 'Y') {
				$tr.addClass('sc-gen-hole').append($('<td>').text(i + 1)).append('<td></td>').append($('<td colspan="7">').text(it.SLOT + ' — 맞는 실제 프로젝트가 없어 비워 둔 자리(저장·워드에는 빠져요)'));
				return;
			}
			var pin = !!scGen.pins[it.KEY];
			$tr.toggleClass('sc-gen-pin', pin).append($('<td class="text-nowrap">').append($('<span>').text(i + 1 + ' '))
				.append($('<button type="button" class="st-act sc-mv">').attr({ 'data-d': -1, 'aria-label': it.PRJ_NM + ' 위로', title: '위로(고정됨)' }).prop('disabled', i === 0).text('▲'))
				.append($('<button type="button" class="st-act sc-mv">').attr({ 'data-d': 1, 'aria-label': it.PRJ_NM + ' 아래로', title: '아래로(고정됨)' }).prop('disabled', i === items.length - 1).text('▼')));
			$tr.append($('<td>').append($('<button type="button" class="st-act sc-pin">').attr({ 'aria-pressed': pin, 'aria-label': it.PRJ_NM + (pin ? ' 고정 풀기' : ' 고정'), title: pin ? '고정 풀기' : '이 자리·기간 고정' }).toggleClass('sc-pin-off', !pin).text('📌')));
			$tr.append($('<td>').append(it.SLOT ? $('<span class="sc-slot sm">').text(it.SLOT) : ''));
			var max = it.ORIG_END || thisYm;
			$tr.append($('<td class="text-nowrap sc-per">')
				.append($('<input type="month" class="sc-ym" data-f="start">').attr({ min: it.ORIG_START, max: max, 'aria-label': it.PRJ_NM + ' 시작월(실제 기간 안)' }).val(it.START_YM))
				.append(' ~ ')
				.append($('<input type="month" class="sc-ym" data-f="end">').attr({ min: it.ORIG_START, max: max, 'aria-label': it.PRJ_NM + ' 종료월(비우면 진행중)' }).val(it.END_YM || ''))
				.toggleClass('sc-changed', it.START_YM !== it.ORIG_START || (it.END_YM || '') !== (it.ORIG_END || '')));
			$tr.append($('<td>').text(it.PRJ_NM)).append($('<td>').text(it.CLIENT_NM || '')).append($('<td>').text(it.IND_NM || '')).append($('<td>').text(it.ROLE_NM || ''))
				.append($('<td class="text-center">').text(skills.length ? it.MATCH : ''));
		});
		if (!items.length) $tb.append('<tr><td colspan="9" class="text-center text-muted py-3">조건에 맞는 프로젝트가 없습니다. 기간을 늘리거나 고른 산업·역할을 줄여 보세요.</td></tr>');
		$('#scGenView').empty().append($('<div class="table-responsive">').append($('<table class="table table-sm sc-gen-tbl" data-nomore data-no-card>')
			.append('<thead><tr><th>순서</th><th>고정</th><th>자리</th><th>참여기간</th><th>프로젝트명</th><th>고객사</th><th>산업</th><th>역할</th><th>기술 일치</th></tr></thead>').append($tb)));
	}
	// 줄을 지금 자리·기간으로 고정한다
	function genPinRow(i, extra) {
		var it = scGen.rows[i];
		scGen.pins[it.KEY] = $.extend({ pos: i, start: it.START_YM, end: it.END_YM || '' }, extra || {});
	}
	function genInit() {
		$('#scGenModal').on('click', '.sc-chip:not(.sc-l1):not(.sc-pick)', function() {
			var $c = $(this), $box = $c.parent(), one = $box.is('[data-one]');
			if (one) $box.children().removeClass('on').attr('aria-pressed', false);
			$c.toggleClass('on', one || !$c.hasClass('on')).attr('aria-pressed', $c.hasClass('on'));
			if ($box.is('#scGenPhoto')) return; // 사진은 워드에만 쓰여 미리보기 표와 상관없다
			genPreview();
		});
		$('#scGenModal').on('click', '.sc-l1', function() {
			var k = $(this).attr('data-kind'), v = $(this).attr('data-v');
			scGen.open[k] = scGen.open[k] === v ? null : v;
			genTrees();
		}).on('click', '.sc-pick', function() {
			scGen.slots.push({ t: $(this).attr('data-kind'), v: $(this).attr('data-v') });
			genSlots();
			genPreview();
		}).on('click', '.sc-slot-x', function() {
			scGen.slots.splice(+$(this).attr('data-i'), 1);
			genSlots();
			genPreview();
		}).on('click', '.sc-edit', function() {
			scGen.edit = !scGen.edit;
			genTrees();
		}).on('click', '.sc-del', function() {
			var k = $(this).attr('data-kind'), v = $(this).attr('data-v');
			bootbox.confirm(GEN_KIND[k] + ' 「' + v + '」' + (v.indexOf('>') < 0 ? ' 과 그 아래 항목' : '') + '을 목록에서 뺄까요? 공통코드에서도 빠집니다(이미 고른 자리·수행이력 값은 그대로).', function(ok) { if (ok) genCode(k, v, 'DEL'); });
		}).on('keydown', '.sc-add', function(e) {
			if (e.key !== 'Enter' || e.originalEvent.isComposing || !$.trim(this.value)) return;
			e.preventDefault();
			genCode($(this).attr('data-kind'), $.trim(this.value), 'ADD');
		});
		// 미리보기 표: 옮기기·고정·기간
		$('#scGenView').on('click', '.sc-mv', function() {
			var i = +$(this).closest('tr').attr('data-i'), j = i + +$(this).attr('data-d'), a = scGen.rows[i], b = scGen.rows[j];
			genPinRow(i, { pos: j });
			if (b && b.EMPTY !== 'Y' && scGen.pins[b.KEY]) scGen.pins[b.KEY].pos = i; // 자리를 바꾼 상대가 고정 줄이면 그 자리도 바꾼다
			genPreview();
		}).on('click', '.sc-pin', function() {
			var i = +$(this).closest('tr').attr('data-i'), it = scGen.rows[i];
			if (scGen.pins[it.KEY]) delete scGen.pins[it.KEY]; else genPinRow(i);
			genPreview();
		}).on('change', '.sc-ym', function() {
			var $tr = $(this).closest('tr'), i = +$tr.attr('data-i');
			genPinRow(i, { start: $tr.find('[data-f=start]').val(), end: $tr.find('[data-f=end]').val() });
			genPreview(); // 서버가 실제 기간 밖이면 실제 값으로 되돌린다
		});
		// 막대를 끄는 동안은 숫자 칸만, 놓으면 미리보기. 숫자 칸을 고쳐도 막대가 따라간다
		$('#scGenMonths, #scGenMaxR').on('input', volPaint).on('change', genPreview);
		$('#scGenY, #scGenM').on('change', function() {
			$('#scGenMonths').val(clampNum(clampNum($('#scGenY').val(), 0, 100) * 12 + clampNum($('#scGenM').val(), 0, 11), 1, 1200));
			volPaint();
			genPreview();
		});
		$('#scGenN').on('change', function() { $('#scGenMaxR').val(clampNum(this.value, 1, 100)); volPaint(); genPreview(); });
		$('#scGenSave').on('click', function() {
			hrPost('/admin/staff/saveCareerGenData.do', { STAFF_SQ: scGen.sq, GEN: JSON.stringify(genConf()) }, function(res) { $('#scGenModal').modal('hide'); toast('가필 v' + res.result + ' 로 저장했습니다 (순정은 그대로)'); loadCareer(scGen.sq); });
		});
		$('#scGenWord').on('click', function() { location.href = '/admin/staff/careerWord.do?STAFF_SQ=' + scGen.sq + '&GEN=' + encodeURIComponent(JSON.stringify(genConf())); });
	}

	function restoreVersion(sq, verNo) {
		bootbox.confirm('작업 중 내용을 v' + verNo + ' 로 바꿀까요? 저장하지 않은 작업 중 내용은 사라집니다. 사내 투입에서 온 프로젝트명·기간은 투입현황 그대로입니다.', function(ok) {
			if (ok) hrPost('/admin/staff/restoreCareerData.do', { STAFF_SQ: sq, VER_NO: verNo }, function() { $('#scVerModal').modal('hide'); toast('v' + verNo + ' 내용으로 되돌렸습니다'); loadCareer(sq); });
		});
	}

	// ── 워드 가져오기 ──
	var SC_IMP = { NEW: ['추가', 'in'], DIFF: ['다름', 'warn'], SAME: ['같음', ''] };
	function openImport() {
		scImp = null;
		$('#scImpFile').val('');
		$('#scImpSum').text('');
		$('#scImpBody').empty();
		$('#scImpApply').prop('disabled', true);
		$('#scImpModal').modal('show');
	}

	function readImport() {
		var file = this.files[0];
		if (!file) return;
		var fd = new FormData();
		fd.append('STAFF_SQ', opened);
		fd.append('file', file);
		$('#scImpSum').text('읽는 중…');
		$.ajax({ url: '/admin/staff/importCareerPreviewData.do', type: 'POST', data: fd, processData: false, contentType: false }).done(function(res) {
			if (res.error) { $('#scImpSum').text(res.error); return; }
			scImp = { name: file.name, rows: res.result || [] };
			var n = { NEW: 0, DIFF: 0, SAME: 0 }, $b = $('#scImpBody').empty();
			scImp.rows.forEach(function(x, i) {
				n[x.STATE]++;
				$b.append($('<tr>').append($('<td>').append($('<input type="checkbox" class="sc-imp">').val(i).prop({ checked: x.STATE !== 'SAME', disabled: x.STATE === 'SAME' }).attr('aria-label', x.PRJ_NM + ' 반영')),
					$('<td>').append($('<span class="sc-pill">').addClass(SC_IMP[x.STATE][1]).text(SC_IMP[x.STATE][0])), $('<td class="text-nowrap">').text(x.START_YM + ' ~ ' + (x.END_YM || '진행중')), $('<td>').text(x.PRJ_NM), $('<td>').text(x.CLIENT_NM || ''),
					$('<td>').text(x.ROLE_NM || ''), $('<td>').text(x.LANG_NM || ''), $('<td>').text(x.DBMS_NM || ''), $('<td class="small text-muted">').text(x.CHANGED || '')));
			});
			$('#scImpSum').text(file.name + ' · ' + scImp.rows.length + '건 읽음 — 추가 ' + n.NEW + ' · 다름 ' + n.DIFF + ' · 같음 ' + n.SAME);
			$('#scImpApply').prop('disabled', !(n.NEW + n.DIFF));
		}).fail(function() { $('#scImpSum').text('파일을 읽지 못했습니다. 다시 시도해 주세요.'); });
	}

	function applyImport() {
		var sq = opened, picked = $('#scImpBody .sc-imp:checked').map(function() { return scImp.rows[this.value]; }).get();
		if (!picked.length) { toast('반영할 줄을 골라 주세요'); return; }
		hrPost('/admin/staff/importCareerData.do', { STAFF_SQ: sq, ROWS: JSON.stringify(picked), FILE_NM: scImp.name }, function(res) {
			$('#scImpModal').modal('hide');
			toast(res.result + '건을 반영했습니다');
			loadCareer(sq);
		});
	}

	// ── 서류 첨부 (구글 드라이브) ──
	var docs = null; // { sq, list }

	function downloadDoc(r, f) {
		toast(f.FILE_NM + ' 받는 중…');
		fetch('/admin/staff/downloadStaffDoc.do?STAFF_SQ=' + r.STAFF_SQ + '&DOC_SQ=' + f.DOC_SQ, { credentials: 'same-origin' }).then(function(res) {
			// 드라이브 연동이 끊겼으면 서버가 연동 화면으로 돌려보낸다
			if (res.redirected && res.url.indexOf('openGoogleLink') >= 0) { bootbox.alert('구글 드라이브 연동이 필요합니다. 연동 화면으로 이동합니다.', function() { location.href = res.url; }); return; }
			if (res.redirected) { bootbox.alert('로그인이 끊겼습니다. 다시 로그인해 주세요.'); return; }
			if (!res.ok) return res.text().then(function(t) { bootbox.alert(t || '파일을 받지 못했습니다.'); });
			return res.blob().then(function(b) {
				var url = URL.createObjectURL(b), a = $('<a>').attr({ href: url, download: f.FILE_NM }).appendTo('body');
				a[0].click();
				a.remove();
				URL.revokeObjectURL(url);
			});
		}).catch(function() { bootbox.alert('파일을 받지 못했습니다.'); });
	}
	var PARSEABLE = ['DOC_BANK', 'DOC_ID', 'DOC_REG', 'DOC_GRAD', 'DOC_MIL'];

	function docFiles(r, code) {
		return ((docs && docs.sq === r.STAFF_SQ ? docs.list : []) || []).filter(function(f) { return f.DOC_CD === code; });
	}
	// 파일이 연결돼 있으면 'file', 해당없음(-)이면 'na', 나머지는 'miss'. 이 직원 파일 목록을 아직 안 읽었으면 목록 조회의 DOC_FILES(파일 있는 서류 코드)로 본다
	function docState(r, d) {
		var has = docs && docs.sq === r.STAFF_SQ ? docFiles(r, d[0]).length > 0 : (',' + (r.DOC_FILES || '') + ',').indexOf(',' + d[0] + ',') >= 0;
		return has ? 'file' : r[d[0]] === '-' ? 'na' : 'miss';
	}
	function fileIcon(name) {
		var ext = String(name || '').split('.').pop().toLowerCase();
		return /^(jpe?g|png|gif|webp|heic|bmp)$/.test(ext) ? 'fa-file-image' : ext === 'pdf' ? 'fa-file-pdf' : /^docx?$/.test(ext) ? 'fa-file-word' : ext === 'zip' ? 'fa-file-archive' : 'fa-file-alt';
	}

	function docRow(r, d) {
		var state = docState(r, d), files = docFiles(r, d[0]), st = DOC_STATES.filter(function(s) { return s[0] === state; })[0];
		var $cell = $('<div class="st-dstat">'), badge = $('<span class="st-badge">').append($('<i class="fas">').addClass(st[2])).append(document.createTextNode(st[1]));
		// 파일이 붙은 서류는 상태를 고를 게 없다. 없으면 미제출·해당없음 중에서 고른다
		if (state === 'file') $cell.css('cursor', 'default').append(badge);
		else hrEditable($cell.attr('title', '눌러서 미제출·해당없음 바꾸기'), {
			url: '/admin/staff/saveStaffFieldData.do', key: { STAFF_SQ: r.STAFF_SQ }, field: d[0], type: DOC_VALUES, label: r.STAFF_NM + ' ' + d[1],
			show: function() { return st[1]; }, value: function() { return r[d[0]] === '-' ? '-' : ''; },
			paint: function($c) { $c.append(badge.clone()); },
			saved: function(v) { r[d[0]] = v; paintCard(); }
		});
		var $files = $('<div class="st-files">');
		files.forEach(function(f) {
			var $f = $('<span class="st-file">').append($('<i class="fas">').addClass(fileIcon(f.FILE_NM)))
				.append($('<a target="_blank" rel="noopener">').attr('href', f.WEB_LINK || ('https://drive.google.com/file/d/' + f.FILE_ID + '/view')).attr('title', f.FILE_NM + ' (드라이브에서 열기)').text(f.FILE_NM))
				.append($('<button type="button" class="st-dl">').attr({ 'aria-label': f.FILE_NM + ' 다운로드', title: '내 PC 로 받기' }).html('<i class="fas fa-download"></i> 받기').on('click', function() { downloadDoc(r, f); }));
			if (PARSEABLE.indexOf(d[0]) >= 0) $f.append($('<button type="button">').attr('aria-label', f.FILE_NM + ' 글자 다시 읽기').attr('title', '글자 다시 읽어 칸 채우기').html('<i class="fas fa-redo"></i>')
				.on('click', function() { docAction('/admin/staff/readStaffDocData.do', { STAFF_SQ: r.STAFF_SQ, DOC_CD: d[0], FILE_ID: f.FILE_ID }, d[1] + ' 다시 읽기'); }));
			$f.append($('<button type="button">').attr('aria-label', f.FILE_NM + ' 연결 끊기').attr('title', '연결 끊기 (드라이브 파일은 남는다)').html('&times;')
				.on('click', function() {
					bootbox.confirm(f.FILE_NM + ' 연결을 끊을까요? 드라이브의 파일은 지우지 않습니다.', function(ok) {
						if (ok) hrPost('/admin/staff/unlinkStaffDocData.do', { STAFF_SQ: r.STAFF_SQ, DOC_SQ: f.DOC_SQ }, function() { load(function() { loadDocs(r.STAFF_SQ); }); }); // 목록 미제출 수도 다시
					});
				}));
			$files.append($f);
		});
		var inputId = 'up_' + d[0];
		var $input = $('<input type="file" class="d-none" multiple accept="image/*,application/pdf,.hwp,.doc,.docx,.zip">').attr('id', inputId)
			.on('change', function() { uploadMany(r, $.map(this.files, function(f) { return [[d, f]]; })); this.value = ''; });
		var $attach = $('<label class="st-attach">').attr({ for: inputId, title: d[1] + ' 파일 첨부 (여러 개 가능)' }).html('<i class="fas fa-plus"></i>');
		var $row = $('<div class="st-doc-row">').attr('data-s', state)
			.append($('<div class="st-dtop">').append($('<div class="st-dname">').text(d[1])).append(copyable($cell, r, d[0])).append($input).append($attach))
			.append($files);
		// 타일에 놓은 파일은 몇 개든 이 서류로 첨부한다
		$row.on('dragover', function(e) { e.preventDefault(); e.stopPropagation(); $('.st-drop').removeClass('is-over'); $('.st-doc-row').not($row).removeClass('is-over'); $row.addClass('is-over'); })
			.on('dragleave drop', function() { $row.removeClass('is-over'); })
			.on('drop', function(e) { e.preventDefault(); e.stopPropagation(); uploadMany(r, $.map(e.originalEvent.dataTransfer.files, function(f) { return [[d, f]]; })); });
		return $row;
	}

	// 파일 이름으로 서류 종류 맞추기. 서버 StaffDocParser.NAME_RULES 와 같은 규칙(앞에 있는 것부터)
	var DOC_NAME_RULES = [[/주민등록등본|등본/, 'DOC_REG'], [/신분증|주민등록증|운전면허/, 'DOC_ID'], [/졸업증명|졸업장/, 'DOC_GRAD'], [/통장|계좌/, 'DOC_BANK'], [/증명사진|사진/, 'DOC_PHOTO'],
		[/건강보험|득실/, 'DOC_HI'], [/근로계약/, 'DOC_CONTRACT'], [/사업자/, 'DOC_BIZ'], [/고용보험/, 'DOC_EI'], [/보안서약/, 'DOC_SEC'], [/직무교육/, 'DOC_EDU'],
		[/국민취업/, 'DOC_NEP'], [/이력비공개|비공개/, 'DOC_PRIV'], [/범죄/, 'DOC_CRIME'], [/병적|병역/, 'DOC_MIL']];
	function guessDoc(name) {
		var hit = DOC_NAME_RULES.filter(function(x) { return x[0].test(name || ''); })[0];
		return hit ? DOCS.filter(function(d) { return d[0] === hit[1]; })[0] : null;
	}
	// 서류 탭 위 큰 영역에 놓은 여러 파일: 이름으로 맞춘 건 바로, 못 맞춘 건 종류를 골라서 올린다
	function dropMany(r, list) {
		var pairs = [], unknown = [];
		$.each(list, function(i, f) { var d = guessDoc(f.name); if (d) pairs.push([d, f]); else unknown.push(f); });
		if (!unknown.length) { uploadMany(r, pairs); return; }
		var opts = '<option value="">올리지 않음</option>' + DOCS.map(function(d) { return '<option value="' + d[0] + '">' + d[1] + '</option>'; }).join('');
		var $m = $('<div>').append($('<p class="small mb-2">').text('파일 이름으로 종류를 못 맞춘 파일입니다. 서류 종류를 골라 주세요.' + (pairs.length ? ' (맞춘 ' + pairs.length + '개는 같이 올립니다)' : '')));
		unknown.forEach(function(f, i) {
			$m.append($('<div class="d-flex align-items-center mb-1" style="gap:8px">').append($('<span class="small text-truncate" style="flex:1;min-width:0">').attr('title', f.name).text(f.name))
				.append($('<select class="form-control form-control-sm" style="width:150px">').attr({ 'data-i': i, 'aria-label': f.name + ' 서류 종류' }).html(opts)));
		});
		bootbox.dialog({ title: '서류 종류 고르기', message: $m, buttons: {
			cancel: { label: '취소', className: 'btn-outline-secondary btn-sm' },
			ok: { label: '올리기', className: 'btn-primary btn-sm', callback: function() {
				$m.find('select').each(function() { var d = DOCS.filter(function(x) { return x[0] === this.value; }, this)[0]; if (d) pairs.push([d, unknown[$(this).attr('data-i')]]); });
				uploadMany(r, pairs);
			} }
		} });
	}

	function loadDocs(sq) {
		$.post('/admin/staff/staffDocsData.do', { STAFF_SQ: sq }, function(res) {
			docs = { sq: sq, list: res.docs || [] };
			if (String(opened) === String(sq)) paintCard();
		});
	}

	// pairs: [[서류, 파일], ...]. 한 개씩 차례로 올리고(서버가 글자를 읽어 칸을 채우므로 동시에 올리지 않는다) 끝나면 결과를 모아 한 번에 알린다
	function uploadMany(r, pairs) {
		var big = pairs.filter(function(p) { return p[1].size > 20 * 1024 * 1024; });
		pairs = pairs.filter(function(p) { return p[1].size <= 20 * 1024 * 1024; });
		if (big.length) bootbox.alert('20MB 가 넘어 빼고 올립니다: ' + big.map(function(p) { return p[1].name; }).join(', '));
		if (!pairs.length) return;
		var merged = { filled: {}, conflicts: [] }, errors = [], ok = 0, i = 0;
		function next() {
			if (i >= pairs.length) {
				var res = { result: merged };
				if (errors.length) bootbox.alert('못 올린 파일<br>' + errors.map(function(e) { return $('<div>').text(e).html(); }).join('<br>'));
				if (ok) afterDoc(res, ok + '개 첨부'); else busy(false);
				return;
			}
			var d = pairs[i][0], file = pairs[i][1], fd = new FormData();
			busy(true, (pairs.length > 1 ? (i + 1) + '/' + pairs.length + ' · ' : '') + d[1] + ' 올리는 중…\n' + file.name);
			fd.append('STAFF_SQ', r.STAFF_SQ);
			fd.append('DOC_CD', d[0]);
			fd.append('file', file);
			$.ajax({ url: '/admin/staff/uploadStaffDocData.do', type: 'POST', data: fd, processData: false, contentType: false })
				.done(function(res) {
					if (res.error) { errors.push(file.name + ' : ' + res.error); return; }
					ok++;
					var out = res.result || {};
					$.extend(merged.filled, out.filled || {});
					merged.conflicts = merged.conflicts.concat(out.conflicts || []);
					if (out.ocrError) merged.ocrError = out.ocrError;
				})
				.fail(function() { errors.push(file.name + ' : 전송 실패'); })
				.always(function() { i++; next(); });
		}
		next();
	}

	function docAction(url, data, label) {
		busy(true, label + ' 중…');
		$.post(url, data).done(function(res) { afterDoc(res, label); }).fail(function() { busy(false); });
	}

	// 빈 칸은 서버가 이미 채웠다. 다른 값이 있던 칸은 골라서 바꾼다
	function afterDoc(res, label) {
		busy(false);
		if (res.error) { bootbox.alert(res.error); return; }
		var out = res.result || {}, filled = Object.keys(out.filled || {});
		toast(label + ' 완료' + (filled.length ? ' · 채움: ' + filled.map(function(f) { return LABELS[f] || f; }).join(', ') : '') + (out.ocrError ? ' · ' + out.ocrError : ''));
		var sq = opened;
		load(function() { loadDocs(sq); });
		if (!out.conflicts || !out.conflicts.length) return;
		var $list = $('<div>').append($('<p class="small">').text('서류에서 읽은 값이 지금 값과 다릅니다. 바꿀 항목을 고르세요.'));
		out.conflicts.forEach(function(c, i) {
			$list.append($('<div class="form-check">').append($('<input type="checkbox" class="form-check-input">').attr('id', 'cf' + i).val(i))
				.append($('<label class="form-check-label">').attr('for', 'cf' + i).append($('<b>').text(LABELS[c.field] || c.field)).append(document.createTextNode(' : ' + (c.old || '(빈칸)') + '  →  ' + c.shown))));
		});
		bootbox.dialog({ title: label + ' · 다른 값', message: $list, buttons: {
			cancel: { label: '그대로 두기', className: 'btn-outline-secondary btn-sm' },
			ok: { label: '고른 항목 바꾸기', className: 'btn-primary btn-sm', callback: function() {
				var picks = $list.find('input:checked').map(function() { return out.conflicts[this.value]; }).get(), left = picks.length;
				picks.forEach(function(c) {
					hrPost('/admin/staff/saveStaffFieldData.do', { STAFF_SQ: sq, FIELD: c.field, VALUE: c.value }, function() {
						if (--left === 0) { toast(picks.length + '개 항목을 바꿨습니다'); load(function() { if (opened) paintCard(); }); }
					});
				});
			} }
		} });
	}

	// 진행 안내는 공통 로딩 카드에 띄운다(오른쪽 아래 알림은 로딩 화면에 가려진다). 로딩 카드가 없는 화면을 위해 알림도 같이 둔다
	function busy(on, msg) {
		$('#cardBody').toggleClass('st-busy', on);
		if (window.boLoadText) window.boLoadText(on ? msg : '');
		if (on && !window.boLoadText) { clearTimeout(toastTimer); $('#copyToast').text(msg).show(); } else if (!on) { $('#copyToast').fadeOut(200); }
	}

	var scanned = [];
	function openScan() {
		var r = find(opened);
		busy(true, '드라이브에서 ' + r.STAFF_NM + ' 폴더를 찾는 중…');
		$.post('/admin/staff/scanStaffDocsData.do', { STAFF_SQ: r.STAFF_SQ }).done(function(res) {
			busy(false);
			if (res.error) { bootbox.alert(res.error); return; }
			scanned = res.result.files || [];
			$('#scanFolder').attr('href', res.result.folderLink);
			var linked = (docs && docs.list || []).map(function(f) { return f.FILE_ID + '|' + f.DOC_CD; });
			var $b = $('#scanBody').empty();
			if (!scanned.length) boEmpty($b, '폴더에 파일이 없습니다.');
			scanned.forEach(function(f, i) {
				var $sel = $('<select class="form-control form-control-sm">').attr('aria-label', f.FILE_NM + ' 서류 종류').append('<option value="">연결 안 함</option>');
				DOCS.forEach(function(d) { $sel.append($('<option>').val(d[0]).text(d[1])); });
				$sel.val(f.GUESS || '');
				var done = f.GUESS && linked.indexOf(f.FILE_ID + '|' + f.GUESS) >= 0;
				$b.append($('<tr>').append($('<td>').append($('<input type="checkbox">').attr({ id: 'sc' + i, 'aria-label': f.FILE_NM + ' 선택' }).val(i).prop('checked', !!f.GUESS && !done).prop('disabled', done)))
					.append($('<td>').append($('<a target="_blank" rel="noopener">').attr('href', f.WEB_LINK).text(f.PATH)).append(done ? ' <span class="small text-muted">(연결됨)</span>' : ''))
					.append($('<td>').append($sel.attr('data-i', i))));
			});
			$('#scanModal').modal('show');
		}).fail(function() { busy(false); });
	}

	function linkScanned() {
		var r = find(opened), picks = [];
		$('#scanBody input:checked').each(function() {
			var i = this.value, doc = $('#scanBody select[data-i=' + i + ']').val();
			if (doc) picks.push({ f: scanned[i], doc: doc });
		});
		if (!picks.length) { bootbox.alert('연결할 파일과 서류 종류를 골라 주세요.'); return; }
		$('#scanModal').modal('hide');
		// 하나씩 차례로: 글자 읽기가 겹치지 않게
		(function next(i) {
			if (i >= picks.length) return;
			var p = picks[i], label = (LABELS[p.doc] || p.doc) + ' 연결 (' + (i + 1) + '/' + picks.length + ')';
			busy(true, label + ' 중…');
			$.post('/admin/staff/linkStaffDocData.do', { STAFF_SQ: r.STAFF_SQ, DOC_CD: p.doc, FILE_ID: p.f.FILE_ID })
				.done(function(res) { afterDoc(res, label); next(i + 1); })
				.fail(function() { busy(false); });
		})(0);
	}

	function loadDrive() {
		$.post('/admin/staff/staffDriveStatusData.do', function(res) {
			var d = res.drive || {}, $s = $('#driveStatus').empty().append('<i class="fab fa-google-drive"></i> ');
			// 서류는 회사 공용 드라이브 연결로 올리고 읽는다(연결은 시스템 관리자가 왼쪽 계정 아래에서)
			$s.append(document.createTextNode(d.connected ? '공용 드라이브: ' + (d.account || '연결됨') : '공용 드라이브 미연결 · 시스템 관리자에게 연결 요청'));
			if (d.connected) $s.append(' ').append($('<button type="button" class="btn btn-sm btn-outline-primary py-0 ml-1" id="btnDriveMatch">').text('📂 드라이브에서 일괄 찾기').on('click', openDm));
		});
	}

	// ── 드라이브 일괄 찾기: 직원마다 한 번씩 찾고(바꾸는 것 없음), 고른 것만 반영 ──
	var dm = null; // { list: [직원], found: {STAFF_SQ: 찾은 결과} }
	function openDm() {
		dm = { list: filtered(), found: {} };
		$('#dmBody').empty();
		$('#dmSum').text('지금 목록 ' + dm.list.length + '명 · 「찾기 시작」을 누르면 한 명씩 찾아요(한 명에 몇 초)');
		$('#dmFind').prop('disabled', false);
		$('#dmApply').prop('disabled', true);
		$('#dmModal').modal('show');
	}
	function dmName(f) {
		return f.FILE_NM + (f.PATH && f.PATH !== f.FILE_NM ? '  (' + f.PATH.replace(/\/?[^/]*$/, '').replace(/ · $/, '') + ')' : '');
	}
	function dmRow(r, m) {
		var same = dm.list.filter(function(x) { return x.STAFF_NM === r.STAFF_NM; }).length > 1;
		var $tr = $('<tr>').attr('data-sq', r.STAFF_SQ);
		var $photo = $('<select class="form-control form-control-sm dm-photo">').attr('aria-label', r.STAFF_NM + ' 증명사진').append('<option value="">연결 안 함</option>');
		(m.photos || []).forEach(function(f) { $photo.append($('<option>').val(f.FILE_ID).text(dmName(f))); });
		if (m.linkedPhoto) $photo.prop('disabled', true).find('option:first').text('이미 연결됨 (' + m.linkedPhoto + ')');
		else if ((m.photos || []).length) $photo.val(m.photos[0].FILE_ID);
		var $word = $('<select class="form-control form-control-sm dm-word">').attr('aria-label', r.STAFF_NM + ' 이력카드 워드').append('<option value="">가져오지 않음</option>');
		var firstNew = null;
		(m.words || []).forEach(function(f) {
			var tail = f.ERR ? ' — ' + f.ERR : f.ROWS != null ? ' — 프로젝트 ' + f.ROWS + '건(새 ' + f.NEW + ')' : '';
			$word.append($('<option>').val(f.FILE_ID).text(dmName(f) + tail).prop('disabled', !!f.ERR));
			if (firstNew === null && f.NEW > 0) firstNew = f.FILE_ID;
		});
		if (firstNew) $word.val(firstNew);
		var hit = !!($photo.val() || $word.val());
		$tr.toggleClass('dm-miss', !(m.photos || []).length && !(m.words || []).length)
			.append($('<td>').append($('<input type="checkbox" class="dm-chk">').attr('aria-label', r.STAFF_NM + ' 반영').prop('checked', hit && !same)))
			.append($('<td class="text-nowrap">').text(r.STAFF_NM + ' ').append(same ? $('<span class="badge badge-warning">').text('동명이인 확인') : '').append($('<div class="small text-muted">').text(STATUS[r.STATUS_CD] || '')))
			.append($('<td class="small">').append(m.folder ? $('<a target="_blank" rel="noopener">').attr('href', 'https://drive.google.com/drive/folders/' + m.folder).text('열기') : $('<span class="text-muted">').text('못 찾음')))
			.append($('<td>').append($photo)).append($('<td>').append($word)).append($('<td class="small dm-res">'));
		return $tr;
	}
	function dmFilter() { $('#dmBody tr.dm-miss').toggle(!$('#dmOnlyHit').prop('checked')); }
	// 한 명씩 차례로 부른다(드라이브 호출이 많아 한 번에 다 하면 시간 초과가 난다)
	function dmEach(list, step, done) {
		var i = 0;
		(function next() {
			if (i >= list.length) { if (window.boLoadText) window.boLoadText(''); done(); return; }
			var r = list[i++];
			if (window.boLoadText) window.boLoadText(i + '/' + list.length + ' · ' + r.STAFF_NM);
			step(r, function() { next(); });
		})();
	}
	function dmInit() {
		$('#dmOnlyHit').on('change', dmFilter);
		$('#dmFind').on('click', function() {
			$(this).prop('disabled', true);
			var hits = 0;
			dmEach(dm.list, function(r, next) {
				$.post('/admin/staff/driveMatchData.do', { STAFF_SQ: r.STAFF_SQ }).done(function(res) {
					if (res.error) { $('#dmBody').append($('<tr class="dm-miss">').append($('<td>')).append($('<td>').text(r.STAFF_NM)).append($('<td colspan="4" class="small text-danger">').text(res.error))); return; }
					dm.found[r.STAFF_SQ] = res.result;
					var $tr = dmRow(r, res.result).appendTo('#dmBody');
					if (!$tr.hasClass('dm-miss')) hits++;
				}).always(function() { $('#dmSum').text('찾는 중 · ' + Object.keys(dm.found).length + '/' + dm.list.length + '명 · 찾은 직원 ' + hits); dmFilter(); next(); });
			}, function() {
				$('#dmSum').text(dm.list.length + '명 중 ' + hits + '명에게서 사진·워드를 찾았어요. 고른 것만 「선택 반영」');
				$('#dmApply').prop('disabled', !hits);
				dmFilter();
			});
		});
		$('#dmApply').on('click', function() {
			var picks = $('#dmBody tr').filter(function() { return $(this).find('.dm-chk').prop('checked') && ($(this).find('.dm-photo').val() || $(this).find('.dm-word').val()); });
			if (!picks.length) { bootbox.alert('반영할 직원을 골라 주세요.'); return; }
			bootbox.confirm(picks.length + '명에게 반영할까요? 증명사진은 서류 탭에 연결되고, 워드는 수행이력에 없는 프로젝트만 더해집니다.', function(ok) {
				if (!ok) return;
				$('#dmApply').prop('disabled', true);
				var list = picks.map(function() { return find($(this).attr('data-sq')); }).get(), done = 0;
				dmEach(list, function(r, next) {
					var $tr = $('#dmBody tr[data-sq="' + r.STAFF_SQ + '"]'), photo = $tr.find('.dm-photo:enabled').val() || '', word = $tr.find('.dm-word').val() || '';
					$.post('/admin/staff/driveMatchApplyData.do', { STAFF_SQ: r.STAFF_SQ, PHOTO_ID: photo, WORD_ID: word }).done(function(res) {
						if (res.error) { $tr.find('.dm-res').addClass('text-danger').text(res.error); return; }
						var o = res.result || {};
						done++;
						$tr.find('.dm-chk').prop({ checked: false, disabled: true });
						$tr.find('.dm-res').addClass('text-success').text([o.photo ? '사진 연결' : '', word ? '프로젝트 +' + (o.added || 0) : ''].filter(Boolean).join(' · ') || '바뀐 것 없음');
					}).fail(function() { $tr.find('.dm-res').addClass('text-danger').text('전송 실패'); }).always(next);
				}, function() {
					toast(done + '명 반영 완료');
					load();
				});
			});
		});
	}

	// 가린 값 + 원문 보기(눈). 원문을 연 뒤에 누르면 원문으로 고칠 수 있다
	function secretCell(r, field) {
		var key = r.STAFF_SQ + '|' + field, $wrap = $('<div class="st-secret">');
		var $val = $('<div>').css('flex', '1 1 auto');
		hrEditable($val, {
			url: '/admin/staff/saveStaffFieldData.do', key: { STAFF_SQ: r.STAFF_SQ }, field: field, label: r.STAFF_NM + ' ' + LABELS[field],
			show: function() { return revealed[key] !== undefined ? revealed[key] : r[field]; },
			value: function() { return revealed[key] !== undefined ? revealed[key] : r[field]; },
			saved: function(v) { revealed[key] = v; r[field] = maskLocal(field, v); }
		});
		var $eye = $('<button type="button" class="st-eye">').attr('aria-label', LABELS[field] + ' 원문 보기').append('<i class="far fa-eye"></i>');
		$eye.on('click', function() {
			if (revealed[key] !== undefined) { delete revealed[key]; paintCard(); return; }
			reveal(r.STAFF_SQ, field, function() { paintCard(); });
		});
		return $wrap.append(copyable($val, r, field)).append($eye);
	}

	// 서버(RrnCipher)와 같은 규칙으로 가린다: 주민번호 앞 6자리, 계좌번호 끝 4자리
	function maskLocal(field, v) {
		var d = String(v || '').replace(/[^0-9]/g, '');
		if (!v) return '';
		if (field === 'RRN') return d.length < 6 ? '*******' : d.substr(0, 6) + '-*******';
		return d.length <= 4 ? '****' : '******' + d.substr(d.length - 4);
	}

	function reveal(sq, field, done) {
		hrPost('/admin/staff/revealStaffData.do', { STAFF_SQ: sq, FIELD: field }, function(res) {
			revealed[sq + '|' + field] = res.value || '';
			done(res.value || '');
		});
	}

	// ── 칸 복사: 마우스를 올린 칸 또는 포커스 칸에서 Ctrl/⌘+C ──
	var hovered = null;
	$(document).on('mouseenter', '[data-copy]', function() { hovered = this; }).on('mouseleave', '[data-copy]', function() { if (hovered === this) hovered = null; });
	$(document).on('keydown', function(e) {
		if (!(e.ctrlKey || e.metaKey) || e.shiftKey || e.altKey || String(e.key).toLowerCase() !== 'c') return;
		// 글자를 끌어 선택했거나 입력칸 안이면 브라우저 기본 복사를 쓴다
		if (String(window.getSelection()) || $(e.target).is('input, textarea, select')) return;
		var el = $(document.activeElement).closest('[data-copy]')[0] || hovered;
		if (!el) return;
		e.preventDefault();
		var field = $(el).attr('data-copy'), sq = $(el).attr('data-sq'), r = find(sq), label = LABELS[field] || field;
		if (field === 'RRN' || field === 'ACCOUNT') {
			var have = revealed[sq + '|' + field];
			if (have !== undefined) { copyText(have, label); return; }
			reveal(sq, field, function(v) { copyText(v, label); if (opened) paintCard(); });
			return;
		}
		copyText(r ? (r[field] || '') : $(el).text(), label);
	});

	function copyText(text, label) {
		function done(ok) { toast(ok ? (text ? label + ' 복사했습니다' : label + ' 값이 비어 있습니다') : '복사하지 못했습니다'); }
		if (navigator.clipboard && window.isSecureContext) {
			navigator.clipboard.writeText(text).then(function() { done(true); }, function() { done(legacyCopy(text)); });
		} else {
			done(legacyCopy(text));
		}
	}

	// http 로 접속했을 때
	function legacyCopy(text) {
		var $t = $('<textarea aria-hidden="true" style="position:fixed;top:0;left:-9999px;">').val(text).appendTo('body'), ok = false, back = document.activeElement;
		$t[0].select();
		try { ok = document.execCommand('copy'); } catch (e) {}
		$t.remove();
		if (back) back.focus();
		return ok;
	}

	var toastTimer;
	function toast(msg) {
		clearTimeout(toastTimer);
		$('#copyToast').text(msg).show();
		toastTimer = setTimeout(function() { $('#copyToast').fadeOut(200); }, 1400);
	}

	function toggleStatus() {
		var r = find(opened), to = r.STATUS_CD === 'WORK' ? 'LEFT' : 'WORK';
		// 미반납 장비는 안내만 하고 퇴사 처리를 막지는 않는다
		loadEquipment(r.STAFF_SQ, function(list) {
			bootbox.confirm((to === 'LEFT' && list.length ? '반납하지 않은 장비가 ' + list.length + '대 있습니다. ' : '') + r.STAFF_NM + ' 님을 ' + STATUS[to] + '(으)로 옮길까요?' + (to === 'LEFT' && !r.LEAVE_DT ? ' 퇴사일자는 인사카드에서 입력해 주세요.' : ''), function(ok) {
				if (!ok) return;
				hrPost('/admin/staff/saveStaffFieldData.do', { STAFF_SQ: r.STAFF_SQ, FIELD: 'STATUS_CD', VALUE: to }, function() {
					r.STATUS_CD = to;
					shownSt[to] = true;
					paintCard();
					render();
				});
			});
		});
	}

	// 재직/퇴사 전환은 toggleStatus, 나머지 한 방향은 이 버튼이 맡는다
	function moveWait() {
		var r = find(opened), to = r.STATUS_CD === 'WAIT' ? 'LEFT' : 'WAIT';
		loadEquipment(r.STAFF_SQ, function(list) {
		bootbox.confirm((to === 'LEFT' && list.length ? '반납하지 않은 장비가 ' + list.length + '대 있습니다. ' : '') + r.STAFF_NM + ' 님을 ' + STATUS[to] + '(으)로 옮길까요?', function(ok) {
			if (!ok) return;
			hrPost('/admin/staff/saveStaffFieldData.do', { STAFF_SQ: r.STAFF_SQ, FIELD: 'STATUS_CD', VALUE: to }, function() {
				r.STATUS_CD = to;
				shownSt[to] = true;
				paintCard();
				render();
			});
		});
		});
	}

	function deleteCard() {
		var r = find(opened);
		bootbox.confirm(r.STAFF_NM + ' 님의 인사카드를 삭제할까요? 되돌릴 수 없습니다. 퇴사자는 삭제 대신 퇴사로 옮겨 주세요.', function(ok) {
			if (!ok) return;
			hrPost('/admin/staff/deleteStaffData.do', { STAFF_SQ: r.STAFF_SQ }, function() {
				$('#cardModal').modal('hide');
				load();
			});
		});
	}

	function openNew() {
		$('#newForm')[0].reset();
		$('#newForm [name=STATUS_CD]').val(Object.keys(STATUS).filter(function(k) { return shownSt[k]; })[0] || 'WORK');
		$('#newModal').modal('show');
	}

	function saveNew() {
		hrPost('/admin/staff/insertStaffData.do', $('#newForm').serialize(), function(res) {
			$('#newModal').modal('hide');
			shownSt[$('#newForm [name=STATUS_CD]').val()] = true;
			load(function() { openCard(res.STAFF_SQ); });
		});
	}
	</script>
</body>
</html>
