<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/deploy/deploy_common.jspf"%>
<style>
	.st-bonus { white-space: normal; min-width: 260px; }
	.st-bn { display: inline-flex; align-items: center; gap: 4px; margin: 1px 4px 1px 0; }
	.st-bn .dp-pill { cursor: pointer; margin: 0; }
	.st-bn .dp-pill:focus { outline: 2px solid #16d5ff; }
	.st-bn input { width: 92px; height: 22px; font-size: 11px; padding: 0 4px; text-align: right; }
	.st-bn select { width: 100px; height: 22px; font-size: 11px; padding: 0 2px; }
	.st-bn-toggle { background: none; border: 0; padding: 0 4px; color: #888; font-size: 11px; vertical-align: middle; }
	.st-bn-toggle:hover, .st-bn-toggle:focus { color: #0b6e8a; }
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
	.st-tag { display: inline-block; font-size: 11px; line-height: 16px; padding: 1px 8px; border-radius: 10px; background: #e3f6fb; color: #0b6e8a; margin: 1px 4px 1px 0; max-width: 100%; overflow-wrap: anywhere; }
	.st-env { display: grid; grid-template-columns: 74px minmax(0, 1fr); gap: 1px 6px; }
	.st-env-label { color: #888; font-size: 11px; line-height: 20px; }
	.st-prj td { vertical-align: top; overflow-wrap: break-word; }
	.st-item td { white-space: pre-line; }
	.st-act { background: none; border: 0; padding: 0 4px; color: #888; }
	.st-act:hover, .st-act:focus { color: #0b6e8a; }
	.st-unset { color: #b7791f; }
	.st-prj-del { background: none; border: 0; padding: 0 4px; color: #888; }
	.st-prj-del:hover, .st-prj-del:focus { color: #c0392b; }
	.st-dl { color: #0b6e8a; padding: 0 3px; font-size: 11px; cursor: pointer; }
	.st-group { font-size: 12px; font-weight: 700; color: #666; margin: 8px 0 6px; padding-top: 8px; border-top: 1px solid rgba(17,17,17,.08); }
	#copyToast { position: fixed; right: 18px; bottom: 18px; z-index: 2000; background: #222; color: #fff; font-size: 12px; padding: 6px 12px; border-radius: 6px; display: none; }
</style>

<body class="hold-transition sidebar-mini">

	<div class="wrapper">

		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>

		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header">
					<h3 class="card-title bTitle"><b>직원관리</b></h3>
				</div>

				<div class="card-body">
					<div class="cal-panel">
						<div class="cal-panel-body">
							<div class="form-row align-items-end">
								<div class="col-md-3 col-12 mb-2">
									<label for="keyword">검색 (성명·연락처·메일·부서·비고)</label>
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
						<div class="cate-tabs" id="tabs" role="tablist" aria-label="재직 상태"></div>
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
			</section>
		</div>
	</div>

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

	<div class="modal fade" id="prjModal" tabindex="-1" role="dialog" aria-labelledby="prjTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="prjTitle">프로젝트 수행이력</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<form id="prjForm" onsubmit="savePrj(); return false;">
					<input type="hidden" name="STAFF_SQ"><input type="hidden" name="PRJ_SQ">
					<div class="modal-body">
						<div class="form-row" id="prjMain"></div>
						<div class="st-group">개발분야 (선택)</div>
						<div class="form-row" id="prjArea"></div>
						<div class="st-group">개발환경 (선택, 쉼표로 구분)</div>
						<div class="form-row" id="prjEnv"></div>
					</div>
					<div class="modal-footer"><button type="submit" class="btn btn-sm btn-primary">저장</button></div>
				</form>
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

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>

	<script>
	var STATUS = { WORK: '재직', LEFT: '퇴사', WAIT: '대기' };
	// 인사카드 탭: [이름, 그 탭에 그릴 SECTIONS 이름]. 영업정보/수행이력과 서류는 따로 그린다
	var CARD_TABS = [['기초정보', ['기초정보', '일자', '계좌(기업)', '비상연락망', '기타']], ['학력/교육', ['학력', '병역', '교육·자격']], ['영업정보/수행이력', []], ['서류', []]];
	var SALES_TERMS = ['GRADE_NM', 'REAL_CAREER', 'WISH_PRICE', 'SCORE', 'GAPIL_YN', 'AUTO_APLY_YN', 'WISH_LOC'];
	var SALES_SKILLS = ['SK_LANG', 'SK_BE', 'SK_FE', 'SK_FW', 'SK_DB', 'SK_IDE', 'SK_VCS', 'SK_OS'];
	var SALES_TEXTS = ['WORK_DOMAIN', 'EXPERTISE'], SALES_ETC = ['REPORT', 'ETC1', 'ETC2'];
	var PRJ_ENV = [['MACHINE_NM', '기종'], ['OS_NM', 'O.S'], ['LANG_NM', '언어'], ['DBMS_NM', 'DBMS'], ['TOOL_NM', 'TOOL'], ['FRAMEWORK_NM', 'FRAMEWORK'], ['ETC_NM', '기타']];
	var PRJ_MAIN = [['PRJ_NM', '프로젝트명(업무명) *', 6], ['CLIENT_NM', '고객사 *', 3], ['ROLE_NM', '역할 *', 3, { values: { '': '선택', '운영': '운영', '개발': '개발', '운영/개발': '운영/개발' } }],
		['START_YM', '시작월 *', 3, 'month'], ['END_YM', '종료월 *', 3, 'month'], ['WORK_NM', '업무단 *', 6]];
	var PRJ_AREA = [['IND_NM', '산업', 6], ['APP_NM', '응용', 6]];
	var PRJ_ENV_FIELDS = PRJ_ENV.map(function(e) { return [e[0], e[1], e[0] === 'ETC_NM' ? 6 : 3]; });
	var PRJ_ALL = PRJ_MAIN.concat(PRJ_AREA, PRJ_ENV_FIELDS);
	var cardTab = 0, prjs = null; // prjs: { sq, list }
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
		['기타', [['PREV_CAREER', '이전경력'], ['HOBBY', '취미'], ['LANG_SKILL', '외국어'], ['SPECIALTY', '특기'], ['MEMO', '비고', 'textarea']]],
		['영업 정보', [['GRADE_NM', '등급'], ['REAL_CAREER', '실경력'], ['WISH_PRICE', '희망단가'], ['SCORE', '점수'], ['GAPIL_YN', '가필여부'], ['AUTO_APLY_YN', '자동지원여부'],
			['SK_FE', 'F/E'], ['SK_BE', 'B/E'], ['WORK_DOMAIN', '업무·도메인'], ['WISH_LOC', '희망 위치'], ['SK_LANG', '언어·스크립트'], ['SK_FW', '프레임워크'],
			['SK_DB', 'DB'], ['SK_IDE', 'IDE·에디터'], ['SK_VCS', '형상관리'], ['SK_OS', '운영체제'], ['EXPERTISE', '전문분야'], ['REPORT', 'Report'], ['ETC1', '기타1'], ['ETC2', '기타2']]]
	];
	var LABELS = {};
	SECTIONS.forEach(function(s) { s[1].forEach(function(f) { LABELS[f[0]] = f[1]; }); });
	DOCS.forEach(function(d) { LABELS[d[0]] = d[1]; });

	var rows = [], current = 'WORK', opened = null;
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
		$('#cardModal').on('hidden.bs.modal', function() { opened = null; revealed = {}; docs = null; prjs = null; items = null; cardTab = 0; render(); });
		hrBuildFields('#prjMain', PRJ_MAIN);
		hrBuildFields('#prjArea', PRJ_AREA);
		hrBuildFields('#prjEnv', PRJ_ENV_FIELDS);
		PRJ_MAIN.forEach(function(f) { $('#f_' + f[0]).prop('required', true); });
		$('#f_END_YM').after('<div class="form-check mt-1"><input type="checkbox" class="form-check-input" id="prjOngoing" name="ONGOING_YN" value="Y"><label class="form-check-label small" for="prjOngoing">진행중</label></div>');
		$('#prjOngoing').on('change', syncOngoing);
		// 인사카드 위에 뜬 창을 닫아도 인사카드 스크롤이 유지되게 한다
		$(document).on('hidden.bs.modal', function() { if ($('.modal.show').length) $('body').addClass('modal-open'); });
		loadDrive();
	});

	$(document).on('click', '.cate-tab', function() { current = $(this).data('tab'); render(); });

	function load(then) {
		$.post('/admin/staff/staffListData.do', function(res) {
			rows = res.list || [];
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
		$('#sortSel').val(current === 'LEFT' ? 'leaveDesc' : 'joinDesc');
		render();
	}

	function filtered() {
		var kw = $.trim($('#keyword').val()).toLowerCase();
		return rows.filter(function(r) {
			if (r.STATUS_CD !== current) return false;
			var ok = true;
			$('.st-filter').each(function() { if ($(this).val() && r[$(this).data('field')] !== $(this).val()) ok = false; });
			if (!ok) return false;
			return !kw || [r.STAFF_NM, r.PHONE, r.EMAIL, r.COMPANY_EMAIL, r.DEPT_NM, r.ORG_NM, r.MEMO].some(function(v) { return v && String(v).toLowerCase().indexOf(kw) >= 0; });
		}).sort(sorter($('#sortSel').val()));
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
		$('#tabs').empty();
		$.each(STATUS, function(k, v) { $('#tabs').append(hrTab(k, v, rows.filter(function(r) { return r.STATUS_CD === k; }).length, current === k)); });
		renderOrgSeg();
		var list = filtered();
		renderSummary(list);
		var cols = [['SEQ_NO', 'NO'], ['ORG_NM', '소속'], ['DEPT_NM', '부서'], ['POSITION_NM', '직급'], ['STAFF_NM', '성명'], ['PHONE', '전화번호'], ['EMAIL', '개인 메일'], ['COMPANY_EMAIL', '회사 메일'],
			['JOIN_DT', '입사일'], current === 'LEFT' ? ['LEAVE_DT', '퇴사일'] : null, ['_TENURE', '근속'], ['_DOCS', '서류'], BN && current !== 'LEFT' ? ['_BONUS', '상여 적용'] : null, ['MEMO', '비고']].filter(Boolean);
		$('#listHead').empty().append($('<tr>').append(cols.map(function(c) { return $('<th>').text(c[1]); })));
		var $body = $('#listBody').empty();
		if (!list.length) { $body.append($('<tr>').append($('<td class="text-center text-muted py-4">').attr('colspan', cols.length).text('해당하는 직원이 없습니다.'))); return; }
		list.forEach(function(r) {
			var $tr = $('<tr>');
			cols.forEach(function(c) {
				var $td = $('<td>');
				if (c[0] === 'STAFF_NM') {
					$td.append($('<button type="button" class="st-name">').text(r.STAFF_NM).on('click', function() { openCard(r.STAFF_SQ); }));
					copyable($td, r, 'STAFF_NM');
				} else if (c[0] === '_TENURE') {
					$td.text(tenure(r));
				} else if (c[0] === '_DOCS') {
					var miss = missingDocs(r);
					$td.text(miss.length ? '미제출 ' + miss.length : '완료').attr('data-tone', miss.length ? 'warn' : 'good')
						.attr('title', miss.map(function(d) { return d[1]; }).join(', '));
				} else if (c[0] === '_BONUS') {
					bonusCell($td.addClass('st-bonus'), r);
				} else {
					editable($td, r, c[0], /_DT$/.test(c[0]) ? 'date' : null);
					if (c[0] === 'MEMO') $td.addClass('hr-memo');
				}
				$tr.append($td);
			});
			$body.append($tr);
		});
	}

	// 소속 드롭다운의 빠른 선택. 인원은 지금 탭 기준
	function renderOrgSeg() {
		var inTab = rows.filter(function(r) { return r.STATUS_CD === current; }), org = $('#fOrg').val() || '', $s = $('#orgSeg').empty();
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

	function paintCard() {
		var r = find(opened);
		if (!r) return;
		$('#cardTitle').text(r.STAFF_NM + ' 인사카드 (' + STATUS[r.STATUS_CD] + ')');
		$('#btnStatus').text(r.STATUS_CD === 'WORK' ? '퇴사로 옮기기' : '재직으로 되돌리기');
		$('#btnWait').text(r.STATUS_CD === 'WAIT' ? '퇴사로 옮기기' : '대기로 옮기기');
		var $b = $('#cardBody').empty();
		var $tabs = $('<ul class="nav nav-tabs mb-3" role="tablist">').appendTo($b), $p = $('<div role="tabpanel">').appendTo($b);
		CARD_TABS.forEach(function(t, i) {
			$('<li class="nav-item">').append($('<button type="button" class="nav-link" role="tab">').toggleClass('active', i === cardTab).attr('aria-selected', i === cardTab)
				.text(i === 3 ? t[0] + ' (미제출 ' + missingDocs(r).length + ')' : t[0])
				.on('click', function() { cardTab = i; paintCard(); $('#cardBody .nav-link.active').focus(); })).appendTo($tabs);
		});
		SECTIONS.filter(function(s) { return CARD_TABS[cardTab][1].indexOf(s[0]) >= 0; }).forEach(function(s) {
			if (LISTS[s[0]]) { itemSection($p, r, LISTS[s[0]]); return; }
			$p.append(sectionHead(r, s[0], s[1]));
			var $g = $('<div class="st-grid">').appendTo($p);
			s[1].forEach(function(f) {
				var $row = $('<div class="hr-card-row">').append($('<div class="hr-card-label">').text(f[1])).appendTo($g);
				if (f[2] === 'secret') $row.append(secretCell(r, f[0]));
				else $row.append(editable($('<div>'), r, f[0], f[2]));
			});
			if (s[0] === '일자') $g.append($('<div class="hr-card-row">').append($('<div class="hr-card-label">').text('근속')).append($('<div class="hr-cell">').text(tenure(r) || '-')));
		});
		if (cardTab === 2) salesTab($p, r);
		if (cardTab === 3) {
			$p.append($('<div class="hr-section d-flex align-items-center">').append('서류&nbsp;')
				.append($('<span class="small text-muted font-weight-normal">').text('(미제출 ' + missingDocs(r).length + '건 · 파일은 구글 드라이브)'))
				.append($('<button type="button" class="btn btn-sm btn-outline-primary ml-auto">').html('<i class="fab fa-google-drive"></i> 드라이브에서 찾기').on('click', openScan)));
			var $d = $('<div>').appendTo($p);
			DOCS.forEach(function(d) { $d.append(docRow(r, d)); });
		}
		if (!docs || docs.sq !== r.STAFF_SQ) loadDocs(r.STAFF_SQ);
		$b.append('<div class="hr-section">보유 장비</div>');
		var $eq = $('<div class="small" id="staffEquipment">').appendTo($b);
		loadEquipment(r.STAFF_SQ, function(list) {
			$eq.empty();
			if (!list.length) $eq.addClass('text-muted').text('대여 중인 장비가 없습니다.');
			list.forEach(function(e) { $eq.append($('<div>').text(e.EQP_NO + ' · ' + (EQ_TYPE[e.TYPE_CD] || e.TYPE_CD) + ' · ' + (e.MODEL_NM || '') + ' · ' + (e.START_DT || '') + ' ~')); });
		});
	}

	var EQ_TYPE = { NB: '노트북', MT: '모니터', DT: '데스크탑', MU: '마우스', KB: '키보드' };
	function loadEquipment(sq, done) {
		hrPost('/admin/equipment/staffEquipmentData.do', { STAFF_SQ: sq }, function(res) { done(res.result || []); });
	}

	// ── 영업정보/수행이력 탭 ──
	function tags($el, v) {
		String(v || '').split(',').map($.trim).filter(Boolean).forEach(function(t) { $el.append($('<span class="st-tag">').text(t)); });
		return $el;
	}

	function salesGrid($p, r, fields) {
		var $g = $('<div class="st-grid">').appendTo($p);
		fields.forEach(function(f) { $g.append($('<div class="hr-card-row">').append($('<div class="hr-card-label">').text(LABELS[f])).append(editable($('<div>'), r, f))); });
	}

	function salesRows($p, r, fields, paint) {
		fields.forEach(function(f) { $p.append($('<div class="hr-card-row st-skill">').append($('<div class="hr-card-label">').text(LABELS[f])).append(editable($('<div>'), r, f, null, paint))); });
	}

	function salesTab($p, r) {
		function head(title, fields, type) { $p.append(sectionHead(r, title, fields.map(function(f) { return [f, LABELS[f], type]; }))); }
		head('영업 조건', SALES_TERMS);
		salesGrid($p, r, SALES_TERMS);
		head('기술 스택', SALES_SKILLS, 'textarea');
		salesRows($p, r, SALES_SKILLS, tags);
		head('업무·기타', SALES_TEXTS.concat(SALES_ETC), 'textarea');
		salesRows($p, r, SALES_TEXTS);
		salesGrid($p, r, SALES_ETC);
		prjSection($p, r);
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

	function prjSection($p, r) {
		var list = prjs && prjs.sq === r.STAFF_SQ ? prjs.list : null;
		$p.append($('<div class="hr-section d-flex align-items-center">').append('프로젝트 수행이력&nbsp;').append($('<span class="small text-muted font-weight-normal">').text(list ? list.length + '건' : ''))
			.append($('<button type="button" class="btn btn-sm btn-outline-primary ml-auto">').html('<i class="fas fa-plus"></i> 이력 추가').on('click', function() { openPrj(null); })));
		if (!list) { loadPrjs(r.STAFF_SQ); return; }
		if (!list.length) { $p.append('<div class="small text-muted">등록된 수행이력이 없습니다.</div>'); return; }
		var $t = $('<table class="table table-sm cal-table st-prj mb-0">').append('<thead><tr><th style="width:120px;">참여기간</th><th style="width:170px;">프로젝트명(업무명)</th><th style="width:90px;">고객사</th><th style="width:130px;">업무단</th><th style="width:70px;">역할</th><th style="width:100px;">개발분야</th><th style="min-width:260px;">개발환경</th><th style="width:30px;"><span class="sr-only">삭제</span></th></tr></thead>');
		var $body = $('<tbody>').appendTo($t);
		list.forEach(function(x) {
			var $env = $('<div class="st-env">');
			PRJ_ENV.forEach(function(e) { if (x[e[0]]) $env.append($('<div class="st-env-label">').text(e[1])).append(tags($('<div>'), x[e[0]])); });
			$body.append($('<tr>').append($('<td>').text(x.START_YM + ' ~ ' + (x.END_YM || '진행중')))
				.append($('<td>').append($('<button type="button" class="st-name">').attr('title', '눌러서 수정').text(x.PRJ_NM).on('click', function() { openPrj(x); })))
				.append($('<td>').text(x.CLIENT_NM)).append($('<td>').text(x.WORK_NM)).append($('<td>').text(x.ROLE_NM))
				.append($('<td>').append($('<div>').text(x.IND_NM ? '산업 ' + x.IND_NM : '')).append($('<div>').text(x.APP_NM ? '응용 ' + x.APP_NM : '')))
				.append($('<td>').append($env))
				.append($('<td>').append($('<button type="button" class="st-prj-del">').attr('aria-label', x.PRJ_NM + ' 삭제').html('&times;').on('click', function() { deletePrj(x); }))));
		});
		$p.append($('<div class="table-responsive">').append($t));
	}

	function loadPrjs(sq) {
		hrPost('/admin/staff/staffPrjData.do', { STAFF_SQ: sq }, function(res) {
			prjs = { sq: sq, list: res.list || [] };
			if (String(opened) === String(sq) && cardTab === 2) paintCard();
		});
	}

	function syncOngoing() {
		var on = $('#prjOngoing').prop('checked');
		$('#f_END_YM').prop({ disabled: on, required: !on });
		if (on) $('#f_END_YM').val('');
	}

	function openPrj(x) {
		hrFillForm('#prjForm', PRJ_ALL, x || {});
		$('#prjForm [name=STAFF_SQ]').val(opened);
		$('#prjForm [name=PRJ_SQ]').val(x ? x.PRJ_SQ : '');
		$('#prjOngoing').prop('checked', !!x && !x.END_YM);
		syncOngoing();
		$('#prjTitle').text('프로젝트 수행이력 ' + (x ? '수정' : '추가'));
		$('#prjModal').modal('show');
	}

	function savePrj() {
		var sq = opened;
		hrPost('/admin/staff/saveStaffPrjData.do', $('#prjForm').serialize(), function() {
			$('#prjModal').modal('hide');
			toast('수행이력을 저장했습니다');
			loadPrjs(sq);
		});
	}

	function deletePrj(x) {
		bootbox.confirm(x.PRJ_NM + ' 수행이력을 삭제할까요? 되돌릴 수 없습니다.', function(ok) {
			if (ok) hrPost('/admin/staff/deleteStaffPrjData.do', { STAFF_SQ: x.STAFF_SQ, PRJ_SQ: x.PRJ_SQ }, function() { loadPrjs(x.STAFF_SQ); });
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
		if (file.size > 20 * 1024 * 1024) { bootbox.alert('20MB 이하 파일만 올릴 수 있습니다.'); return; }
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
			if (!scanned.length) $b.append('<tr><td colspan="3" class="text-center text-muted py-3">폴더에 파일이 없습니다.</td></tr>');
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
			if (d.connected) $s.append(document.createTextNode('서류 드라이브: ' + (d.account || '연결됨') + ' '));
			else $s.append(document.createTextNode('서류 드라이브 미연결 '));
			$s.append($('<a href="/admin/staff/driveStart.do">').text(d.connected ? '다시 연결' : '드라이브 연결'));
		});
		var m = /[?&]drive=(\w+)/.exec(location.search);
		if (m) bootbox.alert({ ok: '구글 드라이브를 연결했습니다.', fail: '드라이브 연결에 실패했습니다. 다시 시도해 주세요.', noclient: '구글 OAuth 클라이언트가 설정되지 않았습니다. 업무툴 > 캘린더 설정에서 먼저 넣어 주세요.' }[m[1]] || m[1]);
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
					current = to;
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
				current = to;
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
		$('#newForm [name=STATUS_CD]').val(current);
		$('#newModal').modal('show');
	}

	function saveNew() {
		hrPost('/admin/staff/insertStaffData.do', $('#newForm').serialize(), function(res) {
			$('#newModal').modal('hide');
			current = $('#newForm [name=STATUS_CD]').val();
			load(function() { openCard(res.STAFF_SQ); });
		});
	}
	</script>
</body>
</html>
