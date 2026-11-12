<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/lab/lab_style.jspf"%>
<style>
	/* 진행 단계: 접으면 현재 단계 한 줄, 펴면 전체 */
	.lab-stepbox { margin-bottom: 12px; }
	.lab-fold { display: flex; flex-wrap: wrap; align-items: center; gap: 12px; background: #fff; border: 2px solid #0a4a78; border-radius: 10px; padding: 10px 14px; }
	.lab-fold .dot { width: 34px; height: 34px; border-radius: 50%; border: 3px solid #0a4a78; color: #0a4a78; display: flex; align-items: center; justify-content: center; font-weight: 700; box-shadow: 0 0 0 5px #dcecf8; flex: none; }
	.lab-fold.all .dot { background: #0b6e8a; border-color: #0b6e8a; color: #fff; box-shadow: none; }
	.lab-fold b { color: #0a4a78; font-size: 15px; }
	.lab-fold small { color: #495057; }
	.lab-fold .bar { flex: 1; min-width: 100px; height: 8px; background: #eef1f4; border-radius: 4px; overflow: hidden; }
	.lab-fold .bar i { display: block; height: 100%; background: #0b6e8a; }
	.lab-stepper { list-style: none; display: flex; margin: -10px 0 0; padding: 18px 8px 12px; background: #fff; border: 2px solid #0a4a78; border-top: 0; border-radius: 0 0 10px 10px; overflow-x: auto; }
	.lab-stepper li { flex: 1 0 110px; position: relative; text-align: center; }
	.lab-stepper li::before { content: ""; position: absolute; top: 15px; left: -50%; width: 100%; height: 4px; background: #ced4da; }
	.lab-stepper li:first-child::before { display: none; }
	.lab-stepper li.done::before, .lab-stepper li.now::before { background: #0b6e8a; }
	.lab-stepper .d { position: relative; width: 34px; height: 34px; margin: 0 auto 6px; border-radius: 50%; border: 3px solid #ced4da; background: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; color: #495057; }
	.lab-stepper .done .d { background: #0b6e8a; border-color: #0b6e8a; color: #fff; }
	.lab-stepper .now .d { border-color: #0a4a78; color: #0a4a78; box-shadow: 0 0 0 5px #dcecf8; }
	.lab-stepper .n { display: block; font-weight: 700; font-size: 13px; }
	.lab-stepper li:not(.done):not(.now) .n { color: #6c757d; font-weight: 400; }
	.lab-stepper .w { display: block; font-size: 12px; color: #495057; min-height: 18px; }
	@media (max-width: 767px) {
		.lab-stepper { flex-direction: column; gap: 6px; }
		.lab-stepper li { display: grid; grid-template-columns: 40px 1fr; text-align: left; flex: none; }
		.lab-stepper li::before { display: none; }
		.lab-stepper .d { grid-row: span 2; margin: 0; }
	}
	/* 연구원별 업무요약 */
	.lab-cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 12px; }
	.lab-card { border: 1px solid #ced4da; border-radius: 8px; padding: 12px 14px; }
	.lab-card.empty { background: #fafbfc; color: #495057; }
	.lab-card h5 { display: flex; align-items: center; gap: 8px; font-size: 16px; font-weight: 700; margin: 0 0 8px; }
	.lab-card .role { font-size: 12px; font-weight: 400; padding: 1px 8px; border-radius: 10px; background: #eef1f4; }
	.lab-card .role.head { background: #0a4a78; color: #fff; }
	.lab-card .cnt { margin-left: auto; font-size: 13px; font-weight: 400; color: #495057; }
	.lab-card ul { margin: 0; padding-left: 18px; }
	/* 첨부파일 */
	.lab-file { word-break: break-all; }
	.lab-ext { display: inline-block; margin-left: 6px; font-size: 11px; font-weight: 700; color: #fff; background: #5b6b7a; border-radius: 4px; padding: 0 5px; }
	.lab-ext.pdf { background: #b02a37; }
	#labToast { position: fixed; right: 18px; bottom: 18px; z-index: 2000; background: #222; color: #fff; font-size: 13px; padding: 8px 14px; border-radius: 6px; display: none; }
	.lab-body { width: 100%; min-height: 160px; border: 1px solid #ced4da; border-radius: 6px; }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header"><h3 class="card-title bTitle"><b>연구일지</b></h3></div>
				<div class="card-body">
					<div class="lab-view" id="viewList">
						<div class="cal-panel">
							<div class="cal-panel-body">
								<div class="form-row align-items-end">
									<div class="col-md-3 col-12 mb-2"><div class="lab-team"><label for="fTeam">연구팀</label><select id="fTeam" class="form-control form-control-sm"></select></div></div>
									<div class="col-md-3 col-6 mb-2"><label for="fName">과제명</label><input type="search" id="fName" class="form-control form-control-sm"></div>
									<div class="col-md-2 col-6 mb-2"><label for="fRun">진행</label><select id="fRun" class="form-control form-control-sm"><option value="">전체</option><option value="ON">진행 중</option><option value="OFF">종료</option></select></div>
									<div class="col-md-1 col-6 mb-2"><button type="button" class="btn btn-sm btn-primary btn-block" onclick="drawList();">조회</button></div>
									<div class="col-md-3 col-6 mb-2 text-right"><button type="button" class="btn btn-sm btn-primary" onclick="openProject();"><i class="fas fa-plus"></i> 과제 등록</button></div>
								</div>
							</div>
						</div>
						<div class="cal-panel"><div class="table-responsive px-3">
							<table class="table table-sm table-hover cal-table mb-0">
								<thead><tr><th>과제명</th><th>연구기간</th><th>연구장소</th><th>최근 일지</th><th>결재 상태</th><th>일지</th></tr></thead>
								<tbody id="listBody"></tbody>
							</table>
						</div></div>
					</div>
					<div class="lab-view" id="viewProject" style="display:none;"></div>
					<div class="lab-view" id="viewJournal" style="display:none;"></div>
				</div>
			</section>
		</div>
	</div>

	<div class="modal fade" id="projectModal" tabindex="-1" role="dialog" aria-labelledby="projectTitle" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<form class="modal-content" onsubmit="saveProject(); return false;">
				<div class="modal-header">
					<h5 class="modal-title" id="projectTitle">과제 등록</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<input type="hidden" id="PRJ_SQ">
					<div class="form-group"><label for="TEAM_SQ">연구팀</label><select id="TEAM_SQ" class="form-control form-control-sm" required></select></div>
					<div class="form-group"><label for="PRJ_NM">과제명</label><input id="PRJ_NM" class="form-control form-control-sm" maxlength="200" required></div>
					<div class="form-row">
						<div class="form-group col-6"><label for="START_DT">연구 시작일</label><input type="date" id="START_DT" class="form-control form-control-sm" required></div>
						<div class="form-group col-6"><label for="END_DT">연구 종료일</label><input type="date" id="END_DT" class="form-control form-control-sm" required></div>
					</div>
					<div class="form-group"><label for="PLACE">연구장소</label><input id="PLACE" class="form-control form-control-sm" maxlength="200" required></div>
					<div class="form-group">
						<label for="DRIVE_FOLDER_ID">드라이브 과제 폴더 (주소 또는 ID)</label>
						<input id="DRIVE_FOLDER_ID" class="form-control form-control-sm" required aria-describedby="folderHelp">
						<small id="folderHelp" class="form-text text-muted">대표 확인이 끝나면 PDF 가 이 폴더의 <b>02. 연구일지</b> 에 올라갑니다.</small>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">취소</button>
					<button type="submit" class="btn btn-sm btn-primary">저장</button>
				</div>
			</form>
		</div>
	</div>

	<div id="labToast" role="status" aria-live="polite"></div>

	<div class="modal fade" id="journalModal" tabindex="-1" role="dialog" aria-labelledby="journalTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document">
			<form class="modal-content" onsubmit="saveJournal(); return false;">
				<div class="modal-header">
					<h5 class="modal-title" id="journalTitle">일지 등록</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
				</div>
				<div class="modal-body">
					<div class="form-row">
						<div class="form-group col-md-6"><label for="jProject">과제</label><input id="jProject" class="form-control form-control-sm" readonly></div>
						<div class="form-group col-md-6"><label for="jYm">대상 월</label><input type="month" id="jYm" class="form-control form-control-sm" required></div>
					</div>
					<div class="form-group"><label for="jMembers">연구인원 (자동)</label><input id="jMembers" class="form-control form-control-sm" readonly></div>
					<div class="form-group mb-0"><label for="editor">연구 내용</label><textarea id="editor" rows="16" style="width:100%;"></textarea></div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">취소</button>
					<button type="submit" class="btn btn-sm btn-primary" id="jSave">저장</button>
				</div>
			</form>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>
	<script>
	var STATUS = { DRAFT: '작성 중', SUBMITTED: '결재 중', APPROVED: '결재 완료', CLOSED: '마감' };
	var ACTION = { CREATE: '작성 시작', SAVE: '저장', SUBMIT: '제출', APPROVE: '확인', REJECT: '반려', CLOSE: '마감', UPLOAD: '드라이브 업로드', MAIL: '메일 발송', MAIL_FAIL: '메일 실패' };
	var projects = [], teams = [], project = null, journal = null, editing = null, prjTab = 0, jrnTab = 0;
	var oEditors = [], editorReady = false, editorHtml = '';

	function pill(st) { return st ? $('<span class="lab-pill">').addClass(st).text(STATUS[st]) : ''; }
	function today() { return new Date(Date.now() + 9 * 3600000).toISOString().slice(0, 10); }

	// ── 목록 ──
	function drawList() {
		var team = $('#fTeam').val(), name = $('#fName').val().trim().toLowerCase(), run = $('#fRun').val(), now = today();
		var list = projects.filter(function(p) {
			return String(p.TEAM_SQ) === team && (!name || p.PRJ_NM.toLowerCase().indexOf(name) >= 0) && (!run || (run === 'ON') === (p.END_DT >= now));
		});
		var $b = $('#listBody').empty();
		if (!list.length) $b.append('<tr><td colspan="6" class="text-center text-muted">과제가 없습니다.</td></tr>');
		list.forEach(function(p) {
			$('<tr>').append($('<td>').append($('<a class="lab-open">').attr('href', '#p=' + p.PRJ_SQ).text(p.PRJ_NM)),
				$('<td>').text(p.START_DT + ' ~ ' + p.END_DT), $('<td>').text(p.PLACE), $('<td>').text(p.LAST_YM || ''),
				$('<td>').append(pill(p.LAST_STATUS)), $('<td>').text(p.JRN_CNT + '건')).appendTo($b);
		});
	}

	function loadList() {
		hrPost('/admin/lab/projectListData.do', {}, function(res) { projects = res.result; drawList(); });
	}

	// ── 과제 상세 ──
	function tabBar(names, cur, pick) {
		var $t = $('<div class="lab-tabs" role="tablist">');
		names.forEach(function(n, i) {
			$('<button type="button" role="tab">').attr('aria-selected', i === cur ? 'true' : 'false').text(n).click(function() { pick(i); }).appendTo($t);
		});
		return $t;
	}

	function backBar(href) {
		return $('<div class="lab-back">').append($('<a class="btn btn-sm btn-outline-secondary">목록</a>').attr('href', href));
	}

	function toast(msg) { $('#labToast').text(msg).stop(true, true).fadeIn(100).delay(1500).fadeOut(300); }

	/** 첨부파일: 파일명.확장자 그대로, 확장자 표시를 붙인다 */
	function fileLink(name, link) {
		if (!link) return '';
		var nm = name || '첨부파일', ext = /\.([a-z0-9]{1,5})$/i.exec(nm);
		return $('<a target="_blank" rel="noopener" class="lab-file">').attr('href', link).text(nm)
			.append(ext ? $('<span class="lab-ext">').toggleClass('pdf', ext[1].toLowerCase() === 'pdf').text(ext[1].toUpperCase()) : '');
	}

	/** 진행 단계: 작성 → 제출 → 결재 단계들 → 결재 완료 → 마감. 접으면 현재 단계만, 펴고 접은 상태는 브라우저에 기억한다 */
	function stepBox(r) {
		var j = r.journal, st = j.STATUS_CD;
		function last(code) { var h = r.history.filter(function(x) { return x.ACTION_CD === code; }).pop(); return h ? (h.ACTOR_NM || h.ACTOR_ID) + ' · ' + h.REG_DT.slice(5, 10) : ''; }
		var items = [{ n: '작성', w: last('CREATE') }, { n: '제출', w: st === 'DRAFT' ? '' : last('SUBMIT') }];
		r.steps.forEach(function(s) {
			var waiting = st === 'SUBMITTED' && String(s.STEP_NO) === String(j.CUR_STEP);
			items.push({ n: s.STEP_NO + '단계 ' + s.STEP_NM, w: s.DONE_DT ? (s.DONE_NM || '') + ' · ' + s.DONE_DT.slice(5, 10) : (s.EMPLY_NM || s.EMPLY_ID || '') + (waiting ? ' 확인 대기' : '') });
		});
		items.push({ n: '결재 완료', w: '' });
		items.push({ n: '마감', w: st === 'CLOSED' ? last('CLOSE') : r.headNm ? '연구소장 ' + r.headNm + (st === 'APPROVED' ? ' 마감 대기' : '') : '' });
		var all = st === 'CLOSED', at = st === 'DRAFT' ? 0 : st === 'SUBMITTED' ? 1 + Number(j.CUR_STEP) : st === 'APPROVED' ? items.length - 1 : items.length;
		var done = Math.min(at, items.length), cur = items[Math.min(at, items.length - 1)];
		var title = all ? '마감 완료 · ' + last('CLOSE') : (st === 'DRAFT' ? '작성 중' : cur.n) + (cur.w && st !== 'DRAFT' ? ' · ' + cur.w : '');
		var open = false;
		try { open = localStorage.getItem('labStepOpen') === '1'; } catch (e) {}
		var $btn = $('<button type="button" class="btn btn-sm btn-outline-secondary ml-auto">');
		var $fold = $('<div class="lab-fold">').toggleClass('all', all).append(
			$('<span class="dot" aria-hidden="true">').text(all ? '✓' : Math.min(at, items.length - 1) + 1),
			$('<div>').append($('<b>').text(title), '<br>', $('<small>').text(items.length + '단계 중 ' + (all ? items.length : Math.min(at, items.length - 1) + 1) + '번째 · 완료 ' + done + '개')),
			$('<div class="bar" aria-hidden="true"><i></i></div>'), $btn);
		$fold.find('.bar i').css('width', Math.round(done * 100 / items.length) + '%');
		var $full = $('<ol class="lab-stepper" id="labStepper">');
		items.forEach(function(x, i) {
			var cls = i < at || all ? 'done' : i === at ? 'now' : '';
			$('<li>').addClass(cls).attr('aria-current', cls === 'now' ? 'step' : null).append($('<span class="d" aria-hidden="true">').text(cls === 'done' ? '✓' : i + 1), $('<span class="n">').text(x.n), $('<span class="w">').text(x.w || '')).appendTo($full);
		});
		function paint() {
			$full.toggle(open);
			$fold.css('border-radius', open ? '10px 10px 0 0' : '10px');
			$btn.attr({ 'aria-expanded': open, 'aria-controls': 'labStepper' }).text(open ? '접기 ▴' : '전체 단계 펴기 ▾');
		}
		$btn.click(function() { open = !open; try { localStorage.setItem('labStepOpen', open ? '1' : '0'); } catch (e) {} paint(); });
		paint();
		return $('<div class="lab-stepbox">').append($fold, $full);
	}

	function summaryText(x, ym) {
		return x.STAFF_NM + '(' + (x.ROLE_CD === 'HEAD' ? '연구소장' : '연구원') + ') · ' + ym + '\n' + (x.ITEMS.length ? x.ITEMS.map(function(i) { return '- ' + i; }).join('\n') : '- 담당 항목 없음');
	}

	function copyText(text, msg) {
		function fallback() { var $t = $('<textarea style="position:fixed;top:-1000px;">').val(text).appendTo('body'); $t[0].select(); document.execCommand('copy'); $t.remove(); toast(msg); }
		if (navigator.clipboard && window.isSecureContext) navigator.clipboard.writeText(text).then(function() { toast(msg); }, fallback);
		else fallback();
	}

	/** 연구원별 업무요약: 일지 본문의 '담당자' 항목을 사람별로 모은다. 마감 메일 본문과 같은 내용 */
	function drawSummary($b, r) {
		var j = r.journal, list = r.recipients || [];
		$b.append($('<div class="lab-actions">').append($('<button type="button" class="btn btn-sm btn-primary">전체 복사</button>').prop('disabled', !list.length).click(function() {
			copyText(list.map(function(x) { return summaryText(x, j.YM); }).join('\n\n'), '전체 업무요약을 복사했습니다');
		})));
		if (!list.length) { $b.append('<p class="text-muted mb-0">그 달에 소속된 연구원이 없습니다.</p>'); return; }
		var $g = $('<div class="lab-cards">').appendTo($b);
		list.forEach(function(x) {
			var $c = $('<div class="lab-card">').toggleClass('empty', !x.ITEMS.length).appendTo($g);
			$c.append($('<h5>').append($('<span>').text(x.STAFF_NM), $('<span class="role">').toggleClass('head', x.ROLE_CD === 'HEAD').text(x.ROLE_CD === 'HEAD' ? '연구소장' : '연구원'),
				$('<span class="cnt">').text(x.ITEMS.length + '건'),
				$('<button type="button" class="btn btn-sm btn-outline-secondary">복사</button>').attr('aria-label', x.STAFF_NM + ' 업무요약 복사').click(function() { copyText(summaryText(x, j.YM), x.STAFF_NM + ' 업무요약을 복사했습니다'); })));
			if (x.ITEMS.length) $c.append($('<ul>').append(x.ITEMS.map(function(i) { return $('<li>').text(i); })));
			else $c.append($('<p class="mb-0">').text('일지에서 담당 항목을 찾지 못했습니다. 본문에 "담당자: ' + x.STAFF_NM + '" 처럼 적으면 여기에 모입니다.'));
		});
	}

	function info(rows) {
		var $b = $('<tbody>');
		rows.forEach(function(r) { $('<tr>').append($('<th scope="row">').text(r[0]), r[1] instanceof jQuery ? $('<td>').append(r[1]) : $('<td>').text(r[1] || '')).appendTo($b); });
		return $('<table class="table table-sm table-bordered lab-info mb-0">').append($b);
	}

	function drawProject() {
		var p = project.project, $v = $('#viewProject').empty();
		$v.append($('<div class="lab-head">').append($('<h4>').text(p.PRJ_NM)));
		$v.append(tabBar(['월간 일지', '과제 정보'], prjTab, function(i) { prjTab = i; drawProject(); }));
		var $panel = $('<div class="cal-panel"><div class="cal-panel-body"></div></div>').appendTo($v), $b = $panel.find('.cal-panel-body');
		if (prjTab === 0) {
			$b.append($('<div class="lab-actions">').append($('<button type="button" class="btn btn-sm btn-primary"><i class="fas fa-plus"></i> 일지 등록</button>').click(function() { openJournal(); })));
			var $t = $('<tbody>');
			if (!project.journals.length) $t.append('<tr><td colspan="6" class="text-center text-muted">일지가 없습니다.</td></tr>');
			project.journals.forEach(function(j) {
				var pdf = j.PDF_LINK ? $('<a target="_blank" rel="noopener">열기</a>').attr('href', j.PDF_LINK) : j.UPLOAD_ERR ? $('<span class="text-danger">업로드 실패</span>') : '';
				var origin = fileLink(j.ATTACH_NM, j.ORIGIN_LINK);
				$('<tr>').append($('<td>').append($('<a class="lab-open">').attr('href', '#j=' + j.JRN_SQ).text(j.YM)), $('<td>').text(j.WRITER_NM || ''), $('<td>').text(j.WRITE_DT || ''),
					$('<td>').append(pill(j.STATUS_CD)), $('<td>').append(pdf), $('<td>').append(origin)).appendTo($t);
			});
			$b.append($('<div class="table-responsive">').append($('<table class="table table-sm table-hover cal-table mb-0"><thead><tr><th>대상 월</th><th>작성자</th><th>작성일</th><th>결재 상태</th><th>PDF</th><th>첨부파일</th></tr></thead></table>').append($t)));
		} else {
			$b.append($('<div class="lab-actions">').append($('<button type="button" class="btn btn-sm btn-primary">수정</button>').click(function() { openProject(p); })));
			$b.append(info([['연구팀', p.TEAM_NM], ['과제명', p.PRJ_NM], ['연구기간', p.START_DT + ' ~ ' + p.END_DT], ['연구장소', p.PLACE],
				['드라이브', $('<a target="_blank" rel="noopener">폴더 열기</a>').attr('href', 'https://drive.google.com/drive/folders/' + encodeURIComponent(p.DRIVE_FOLDER_ID))]]));
		}
		$v.append(backBar('#'));
	}

	function loadProject(sq, then) {
		hrPost('/admin/lab/projectDetailData.do', { PRJ_SQ: sq }, function(res) { project = res.result; if (then) then(); else drawProject(); });
	}

	function openProject(p) {
		$('#projectTitle').text(p ? '과제 수정' : '과제 등록');
		['PRJ_SQ', 'PRJ_NM', 'START_DT', 'END_DT', 'PLACE', 'DRIVE_FOLDER_ID'].forEach(function(f) { $('#' + f).val(p && p[f] || ''); });
		$('#TEAM_SQ').val(p ? p.TEAM_SQ : $('#fTeam').val());
		$('#projectModal').modal('show');
	}

	function saveProject() {
		var data = {};
		['PRJ_SQ', 'TEAM_SQ', 'PRJ_NM', 'START_DT', 'END_DT', 'PLACE', 'DRIVE_FOLDER_ID'].forEach(function(f) { data[f] = $('#' + f).val(); });
		hrPost('/admin/lab/saveProjectData.do', data, function() {
			$('#projectModal').modal('hide');
			loadList();
			if (data.PRJ_SQ) loadProject(data.PRJ_SQ);
		});
	}

	// ── 일지 상세 ──
	// 에디터 HTML 은 스크립트가 돌지 않는 격리 영역에 보여 준다. 높이를 재려고 same-origin 만 허용한다
	function richFrame(html) {
		var $f = $('<iframe class="lab-body" sandbox="allow-same-origin" title="연구 내용">');
		$f.on('load', function() { var d = this.contentDocument; if (d && d.documentElement) this.style.height = (d.documentElement.scrollHeight + 8) + 'px'; });
		return $f.attr('srcdoc', '<!doctype html><meta charset="utf-8"><style>body{margin:12px;font:14px sans-serif}table{border-collapse:collapse}td,th{border:1px solid #868e96;padding:4px 8px}</style>' + (html || ''));
	}

	function act(url, data, done) {
		$('#viewJournal .lab-head button').prop('disabled', true);
		hrPost(url, $.extend({ JRN_SQ: journal.journal.JRN_SQ }, data), done || showCurrent, showCurrent);
	}

	function drawJournal() {
		var r = journal, j = r.journal, st = j.STATUS_CD, $v = $('#viewJournal').empty();
		var $head = $('<div class="lab-head">').append($('<h4>').text(j.YM + ' 월간 연구일지 · ' + j.PRJ_NM)).appendTo($v);
		function button(label, cls, fn) { $('<button type="button" class="btn btn-sm">').addClass(cls).text(label).click(fn).appendTo($head); }
		if (st === 'DRAFT') {
			button('수정', 'btn-outline-secondary', function() { openJournal(r); });
			button('제출', 'btn-primary', function() { act('/admin/lab/submitJournalData.do'); });
		}
		var cur = r.steps.filter(function(s) { return String(s.STEP_NO) === String(j.CUR_STEP); })[0];
		if (r.canApprove) {
			button('반려', 'btn-outline-danger', function() {
				bootbox.prompt({ title: '반려 사유', inputType: 'textarea', callback: function(note) { if (note !== null) act('/admin/lab/rejectJournalData.do', { NOTE: note }); } });
			});
			button((cur ? cur.STEP_NM : '') + ' 확인', 'btn-primary', function() { act('/admin/lab/approveJournalData.do'); });
			if (r.needSign) $head.find('button:last').prop('disabled', true);
		}
		if (r.canClose) {
			button('마감', 'btn-primary', function() {
				var to = (r.recipients || []).map(function(x) { return x.STAFF_NM; }).join(', ');
				bootbox.confirm($('<div>').text('마감하면 수정할 수 없게 잠기고, PDF 가 드라이브에 올라가며, 연구원(' + to + ')에게 메일이 갑니다. 마감할까요?').html(), function(ok) {
					if (!ok) { showCurrent(); return; }
					act('/admin/lab/closeJournalData.do', {}, function(res) {
						if (res.result.publishError) bootbox.alert($('<div>').text('마감은 끝났지만 PDF 업로드·메일 발송에 실패했습니다. ' + res.result.publishError).html());
						showCurrent();
					});
				});
			});
		}
		if (st === 'CLOSED' && (!j.PDF_LINK || !j.MAIL_DT)) button('업로드·메일 다시 시도', 'btn-primary', function() { act('/admin/lab/uploadJournalData.do'); });
		if (j.PDF_LINK) $head.append($('<a target="_blank" rel="noopener" class="btn btn-sm btn-outline-primary">드라이브에서 PDF 열기</a>').attr('href', j.PDF_LINK));

		$v.append(stepBox(r));
		if (r.needSign) $v.append($('<div class="alert alert-warning py-2">').append('서명을 등록해야 승인할 수 있습니다. ', $('<a class="lab-open">결재라인에서 내 서명 등록</a>').attr('href', '/admin/lab/openLabManage.do#t=' + j.TEAM_SQ + '&tab=3')));
		if (st === 'APPROVED' && !r.canClose) $v.append($('<div class="alert alert-info py-2">').text('결재가 모두 끝났습니다. 연구소장(' + (r.headNm || '미지정') + ')이 마감합니다.'));
		if (st === 'CLOSED' && j.UPLOAD_ERR && (!j.PDF_LINK || !j.MAIL_DT)) $v.append($('<div class="alert alert-danger py-2" role="status">').text('실패: ' + j.UPLOAD_ERR));
		if (r.recipients && st === 'APPROVED') {
			var $rt = $('<tbody>');
			r.recipients.forEach(function(x) {
				var kind = { COMPANY: '회사 메일', PERSONAL: '개인 메일 (회사 메일 없음)', NONE: '주소 없음' }[x.KIND];
				$('<tr>').append($('<td>').text(x.STAFF_NM), $('<td>').text(x.ADDR || ''), $('<td>').toggleClass('text-danger', x.KIND !== 'COMPANY').text(kind), $('<td>').text(x.ITEMS.length + '건')).appendTo($rt);
			});
			$v.append($('<div class="cal-panel"><div class="cal-panel-body"><b>마감 메일 받을 연구원</b></div></div>').find('.cal-panel-body')
				.append($('<div class="table-responsive">').append($('<table class="table table-sm cal-table mb-0"><thead><tr><th>성명</th><th>받는 주소</th><th>구분</th><th>본인 담당 항목</th></tr></thead></table>').append($rt))).end());
		}

		$v.append(tabBar(['일지 내용', '연구원별 업무요약', '처리 이력'], jrnTab, function(i) { jrnTab = i; drawJournal(); }));
		var $panel = $('<div class="cal-panel"><div class="cal-panel-body"></div></div>').appendTo($v), $b = $panel.find('.cal-panel-body');
		if (jrnTab === 0) {
			var rows = [['작성자', j.WRITER_NM], ['연구장소', j.PLACE], ['연구기간', j.PERIOD], ['연구인원', r.members || '그 달에 소속된 연구원이 없습니다']];
			if (j.ORIGIN_LINK) rows.push(['첨부파일', fileLink(j.ATTACH_NM, j.ORIGIN_LINK)]);
			if (j.MAIL_DT) rows.push(['메일 발송', j.MAIL_DT]);
			$b.append($('<div class="mb-2">').append(info(rows)));
			$b.append(richFrame(j.CONTENT));
		} else if (jrnTab === 1) {
			drawSummary($b, r);
		} else {
			var $t = $('<tbody>');
			r.history.slice().reverse().forEach(function(h) {
				// 확인 이력의 메모는 단계 이름이라 처리 칸에 붙여 보여 준다
				$('<tr>').append($('<td>').text(h.REG_DT), $('<td>').text(h.ACTION_CD === 'APPROVE' ? (h.NOTE || '') + ' 확인' : ACTION[h.ACTION_CD] || h.ACTION_CD), $('<td>').text((h.ACTOR_NM || '') + ' (' + h.ACTOR_ID + ')'),
					$('<td>').text(h.ACTION_CD === 'APPROVE' ? '' : h.NOTE || '')).appendTo($t);
			});
			$b.append($('<div class="table-responsive">').append($('<table class="table table-sm cal-table mb-0"><thead><tr><th>일시</th><th>처리</th><th>처리자</th><th>메모</th></tr></thead></table>').append($t)));
		}
		$v.append(backBar('#p=' + j.PRJ_SQ));
	}

	// ── 일지 등록·수정 팝업 ──
	function setEditor() {
		if (editorReady) oEditors.getById.editor.exec('SET_IR', [editorHtml]);
	}

	function openJournal(r) {
		editing = r ? r.journal : null;
		$('#journalTitle').text(r ? '일지 수정' : '일지 등록');
		$('#jProject').val(r ? r.journal.PRJ_NM : project.project.PRJ_NM);
		var d = new Date();
		$('#jYm').val(r ? r.journal.YM : d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2)).prop('readOnly', !!r);
		editorHtml = r ? (r.journal.CONTENT || '') : '';
		if (r) $('#jMembers').val(r.members); else loadMembers();
		$('#journalModal').modal('show');
	}

	function loadMembers() {
		if (!$('#jYm').val()) return;
		hrPost('/admin/lab/monthMembersData.do', { TEAM_SQ: project.project.TEAM_SQ, YM: $('#jYm').val() }, function(res) { $('#jMembers').val(res.result); });
	}

	function saveJournal() {
		oEditors.getById.editor.exec('UPDATE_CONTENTS_FIELD', []);
		var html = $('#editor').val(), $btn = $('#jSave').prop('disabled', true), enable = function() { $btn.prop('disabled', false); };
		if (editing) {
			hrPost('/admin/lab/saveJournalData.do', { JRN_SQ: editing.JRN_SQ, CONTENT: html }, function() { enable(); $('#journalModal').modal('hide'); showCurrent(); }, enable);
		} else {
			hrPost('/admin/lab/createJournalData.do', { PRJ_SQ: project.project.PRJ_SQ, YM: $('#jYm').val(), CONTENT: html }, function(res) {
				enable();
				$('#journalModal').modal('hide');
				loadList();
				location.hash = '#j=' + res.result;
			}, enable);
		}
	}

	// iframe 에디터는 보이는 상태에서 만들어야 크기가 맞아 팝업이 처음 열릴 때 만든다
	$('#journalModal').on('shown.bs.modal', function() {
		if (oEditors.getById && oEditors.getById.editor) { setEditor(); return; }
		nhn.husky.EZCreator.createInIFrame({
			oAppRef: oEditors,
			elPlaceHolder: 'editor',
			sSkinURI: '/resources/navereditor/SmartEditor2Skin.html',
			htParams: { bUseToolbar: true, bUseVerticalResizer: true, bUseModeChanger: false, fOnBeforeUnload: function() {} },
			fOnAppLoad: function() {
				editorReady = true;
				setEditor();
			},
			fCreator: 'createSEditor2'
		});
	});
	$('#jYm').on('change', function() { if (!editing) loadMembers(); });

	// ── 화면 전환 ──
	function showCurrent() {
		var m = /^#(p|j)=(\d+)$/.exec(location.hash);
		$('.lab-view').hide();
		if (!m) { $('#viewList').show(); loadList(); }
		else if (m[1] === 'p') { $('#viewProject').show(); loadProject(m[2]); }
		else {
			$('#viewJournal').show();
			hrPost('/admin/lab/journalDetailData.do', { JRN_SQ: m[2] }, function(res) {
				journal = res.result;
				// 수정 팝업과 일지 등록이 과제 정보를 쓰므로 함께 읽는다
				loadProject(journal.journal.PRJ_SQ, drawJournal);
			});
		}
		window.scrollTo(0, 0);
	}

	$(window).on('hashchange', function() { prjTab = 0; jrnTab = 0; showCurrent(); });
	$('#fTeam, #fRun').on('change', drawList);
	$('#fName').on('input', drawList);
	hrPost('/admin/lab/optionsData.do', {}, function(res) {
		teams = res.result.teams.filter(function(t) { return t.USE_YN === 'Y'; });
		teams.forEach(function(t) { $('#fTeam, #TEAM_SQ').append($('<option>').val(t.TEAM_SQ).text(t.TEAM_NM)); });
		showCurrent();
	});
	</script>
</body>
</html>
