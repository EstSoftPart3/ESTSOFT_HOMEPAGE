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
	.st-doc-row { display: grid; grid-template-columns: 120px 76px 1fr auto; gap: 8px; align-items: start; padding: 4px 6px; border-radius: 6px; }
	.st-doc-row + .st-doc-row { border-top: 1px dashed rgba(17,17,17,.08); }
	.st-doc-row.is-over { outline: 2px dashed #16a0c4; background: #e3f6fb; }
	.st-doc-row .hr-card-label { line-height: 22px; }
	.st-files a { display: inline-block; max-width: 260px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; vertical-align: middle; font-size: 12px; }
	.st-file { display: inline-flex; align-items: center; gap: 2px; background: #f3f6f8; border-radius: 10px; padding: 0 4px 0 8px; margin: 0 4px 4px 0; }
	.st-file button { background: none; border: 0; padding: 0 3px; color: #888; font-size: 11px; }
	.st-file button:hover, .st-file button:focus { color: #0b6e8a; }
	.st-attach { font-size: 11px; padding: 1px 8px; margin: 0; cursor: pointer; }
	.st-busy { opacity: .5; pointer-events: none; }
	#driveStatus { font-size: 12px; }
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
	.st-docbar { height: 6px; border-radius: 3px; background: #e8edf2; overflow: hidden; margin-bottom: 10px; } .st-docbar i { display: block; height: 100%; background: #1d7a4a; }
	#copyToast { position: fixed; right: 18px; bottom: 18px; z-index: 2000; background: #222; color: #fff; font-size: 12px; padding: 6px 12px; border-radius: 6px; display: none; }
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
							<table class="table table-sm table-hover cal-table mb-0">
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
					<p class="small text-muted mb-2">「새 버전으로 저장」을 누를 때만 버전이 생깁니다. <b>보기</b>는 그 버전의 수행이력을 읽기 전용으로 보여 주고, <b>이 버전으로</b>는 작업 중 내용을 그 버전으로 바꿉니다(옛 버전은 지워지지 않습니다).</p>
					<div class="table-responsive"><table class="table table-sm mb-0" data-nosort><thead><tr><th>버전</th><th>저장한 때</th><th>저장한 사람</th><th>프로젝트</th><th>직전 버전과 달라진 점</th><th><span class="sr-only">관리</span></th></tr></thead><tbody id="scVerBody"></tbody></table></div>
					<div id="scVerView" class="mt-3"></div>
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
	<script src="/resources/common/staff-career.js?v=20261116"></script>

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
	var DOC_VALUES = { list: [['', '미제출'], ['O', 'O'], ['X', 'X'], ['-', '해당없음']] };
	var DOCS = [['DOC_REG', '주민등본'], ['DOC_ID', '신분증'], ['DOC_GRAD', '졸업증명'], ['DOC_BANK', '통장사본'], ['DOC_PHOTO', '증명사진'],
		['DOC_HI', '건보득실확인서'], ['DOC_CONTRACT', '근로계약'], ['DOC_BIZ', '사업자사실증명'], ['DOC_EI', '고용보험자격이력'], ['DOC_SEC', '보안서약서'],
		['DOC_EDU', '직무교육동의서'], ['DOC_NEP', '국민취업제도참여'], ['DOC_PRIV', '이력비공개'], ['DOC_CRIME', '범죄기록회보'], ['DOC_MIL', '병적증명서']];
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
		return DOCS.filter(function(d) { return !r[d[0]] || r[d[0]] === 'X'; });
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
			var $dc = card(true), miss = missingDocs(r).length;
			$dc.append($('<div class="hr-section d-flex align-items-center">').append('서류&nbsp;')
				.append($('<span class="small text-muted font-weight-normal">').text((DOCS.length - miss) + ' / ' + DOCS.length + ' 제출 · 파일은 구글 드라이브'))
				.append($('<button type="button" class="btn btn-sm btn-outline-primary ml-auto">').html('<i class="fab fa-google-drive"></i> 드라이브에서 찾기').on('click', openScan)));
			$dc.append($('<div class="st-docbar">').append($('<i>').css('width', Math.round((DOCS.length - miss) / DOCS.length * 100) + '%')));
			var $d = $('<div>').appendTo($dc);
			DOCS.forEach(function(d) { $d.append(docRow(r, d)); });
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
			.append(stat('버전', d.ver ? 'v' + d.ver.VER_NO : '없음'))
			.append($('<div class="st-btns">')
				.append(btn('btn-outline-primary', '<i class="fas fa-plus"></i> 이력 추가', function() { openCareer(null); }))
				.append($save)
				.append(btn('btn-outline-secondary', '🕘 버전', function() { openVersions(sq); }))
				.append(btn('btn-outline-secondary', '📄 워드 받기', function() { careerWord(sq, ''); }))
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
				$b.append($('<tr>').append($('<td>').append($('<b>').text('v' + v.VER_NO)).append(i === 0 ? ' <span class="sc-pill in">최신</span>' : ''), $('<td class="text-nowrap">').text(v.REG_DT), $('<td>').text(v.REG_EMPLY_ID || ''), $('<td>').text(v.PRJ_CNT + '건'), $('<td>').text(v.SUMMARY || ''),
					$('<td class="text-nowrap text-right">').append(b('보기', function() { viewVersion(sq, v.VER_NO); })).append(b('워드', function() { careerWord(sq, v.VER_NO); })).append(b('이 버전으로', function() { restoreVersion(sq, v.VER_NO); }))));
			});
			if (!list.length) boEmpty($b, '저장한 버전이 없습니다. 수행이력 탭에서 「새 버전으로 저장」 을 누르면 생깁니다.');
			$('#scVerModal').modal('show');
		});
	}

	function viewVersion(sq, verNo) {
		hrPost('/admin/staff/careerVersionData.do', { STAFF_SQ: sq, VER_NO: verNo }, function(res) {
			scTable($('#scVerView').empty().append($('<div class="hr-section">').text('v' + verNo + ' 의 수행이력 (읽기 전용)')), res.result || [], {});
		});
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

	function docRow(r, d) {
		var $cell = $('<div>');
		hrEditable($cell, {
			url: '/admin/staff/saveStaffFieldData.do', key: { STAFF_SQ: r.STAFF_SQ }, field: d[0], type: DOC_VALUES, label: r.STAFF_NM + ' ' + d[1],
			show: function() { return r[d[0]] || '미제출'; }, value: function() { return r[d[0]]; },
			saved: function(v) { r[d[0]] = v; paintCard(); }
		});
		$cell.attr('data-tone', !r[d[0]] || r[d[0]] === 'X' ? 'warn' : 'good').css({ 'border-radius': '4px', padding: '0 6px', 'line-height': '22px' });
		var $files = $('<div class="st-files">');
		((docs && docs.sq === r.STAFF_SQ ? docs.list : []) || []).filter(function(f) { return f.DOC_CD === d[0]; }).forEach(function(f) {
			var $f = $('<span class="st-file">').append($('<a target="_blank" rel="noopener">').attr('href', f.WEB_LINK || ('https://drive.google.com/file/d/' + f.FILE_ID + '/view')).attr('title', f.FILE_NM).text(f.FILE_NM))
				.append($('<button type="button" class="st-dl">').attr({ 'aria-label': f.FILE_NM + ' 다운로드', title: '다운로드' }).html('<i class="fas fa-download"></i>').on('click', function() { downloadDoc(r, f); }));
			if (PARSEABLE.indexOf(d[0]) >= 0) $f.append($('<button type="button">').attr('aria-label', f.FILE_NM + ' 글자 다시 읽기').attr('title', '글자 다시 읽어 칸 채우기').html('<i class="fas fa-redo"></i>')
				.on('click', function() { docAction('/admin/staff/readStaffDocData.do', { STAFF_SQ: r.STAFF_SQ, DOC_CD: d[0], FILE_ID: f.FILE_ID }, d[1] + ' 다시 읽기'); }));
			$f.append($('<button type="button">').attr('aria-label', f.FILE_NM + ' 연결 끊기').attr('title', '연결 끊기 (드라이브 파일은 남는다)').html('&times;')
				.on('click', function() {
					bootbox.confirm(f.FILE_NM + ' 연결을 끊을까요? 드라이브의 파일은 지우지 않습니다.', function(ok) {
						if (ok) hrPost('/admin/staff/unlinkStaffDocData.do', { STAFF_SQ: r.STAFF_SQ, DOC_SQ: f.DOC_SQ }, function() { loadDocs(r.STAFF_SQ); });
					});
				}));
			$files.append($f);
		});
		var inputId = 'up_' + d[0];
		var $input = $('<input type="file" class="d-none" accept="image/*,application/pdf,.hwp,.doc,.docx,.zip">').attr('id', inputId)
			.on('change', function() { if (this.files[0]) upload(r, d, this.files[0]); this.value = ''; });
		var $attach = $('<label class="btn btn-sm btn-outline-secondary st-attach">').attr('for', inputId).html('<i class="fas fa-paperclip"></i> 첨부');
		var $row = $('<div class="st-doc-row">').append($('<div class="hr-card-label">').text(d[1])).append(copyable($cell, r, d[0])).append($files).append($('<div>').append($input).append($attach));
		// 파일을 이 줄에 끌어다 놓아도 첨부한다
		$row.on('dragover', function(e) { e.preventDefault(); $row.addClass('is-over'); })
			.on('dragleave drop', function() { $row.removeClass('is-over'); })
			.on('drop', function(e) { e.preventDefault(); var f = e.originalEvent.dataTransfer.files[0]; if (f) upload(r, d, f); });
		return $row;
	}

	function loadDocs(sq) {
		$.post('/admin/staff/staffDocsData.do', { STAFF_SQ: sq }, function(res) {
			docs = { sq: sq, list: res.docs || [] };
			if (String(opened) === String(sq)) paintCard();
		});
	}

	function upload(r, d, file) {
		if (file.size > 50 * 1024 * 1024) { bootbox.alert('50MB 이하 파일만 올릴 수 있습니다.'); return; }
		var fd = new FormData();
		fd.append('STAFF_SQ', r.STAFF_SQ);
		fd.append('DOC_CD', d[0]);
		fd.append('file', file);
		busy(true, d[1] + ' 올리는 중… 글자를 읽으면 10초쯤 걸립니다');
		$.ajax({ url: '/admin/staff/uploadStaffDocData.do', type: 'POST', data: fd, processData: false, contentType: false })
			.done(function(res) { afterDoc(res, d[1] + ' 첨부'); })
			.fail(function() { busy(false); });
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

	function busy(on, msg) {
		$('#cardBody').toggleClass('st-busy', on);
		if (on) { clearTimeout(toastTimer); $('#copyToast').text(msg).show(); } else { $('#copyToast').fadeOut(200); }
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
