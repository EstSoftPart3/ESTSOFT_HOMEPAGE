<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<style>
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
									<label for="keyword">검색 (성명·연락처·이메일·부서·비고)</label>
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
							<div id="summary" class="mt-1"></div>
						</div>
					</div>

					<div class="cal-panel">
						<div class="cate-tabs" id="tabs" role="tablist" aria-label="재직 상태"></div>
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

	<div id="copyToast" role="status" aria-live="polite"></div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>

	<script>
	var STATUS = { WORK: '재직', LEFT: '퇴사' };
	var DOC_VALUES = { list: [['', '미제출'], ['O', 'O'], ['X', 'X'], ['-', '해당없음']] };
	var DOCS = [['DOC_REG', '주민등본'], ['DOC_ID', '신분증'], ['DOC_GRAD', '졸업증명'], ['DOC_BANK', '통장사본'], ['DOC_PHOTO', '증명사진'],
		['DOC_HI', '건보득실확인서'], ['DOC_CONTRACT', '근로계약'], ['DOC_BIZ', '사업자사실증명'], ['DOC_EI', '고용보험자격이력'], ['DOC_SEC', '보안서약서'],
		['DOC_EDU', '직무교육동의서'], ['DOC_NEP', '국민취업제도참여'], ['DOC_PRIV', '이력비공개'], ['DOC_CRIME', '범죄기록회보'], ['DOC_MIL', '병적증명서']];
	// 인사카드 칸: [필드, 라벨, 종류]. 종류 'secret' 은 가린 값 + 원문 보기
	var SECTIONS = [
		['기초정보', [['STAFF_NM', '성명'], ['ORG_NM', '소속'], ['DEPT_NM', '부서'], ['POSITION_NM', '직급'], ['SEQ_NO', 'NO'],
			['RRN', '주민등록번호', 'secret'], ['PHONE', '전화번호'], ['EMAIL', '이메일'], ['ADDR', '주소(시도)'], ['STATION', '인근지하철역']]],
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
		load();
		$('#keyword').on('input', render);
		$('#sortSel, .st-filter').on('change', render);
		hrBuildFields('#newFields', [['STAFF_NM', '성명 *', 6], ['STATUS_CD', '재직 상태', 6, { values: STATUS }], ['ORG_NM', '소속', 4], ['DEPT_NM', '부서', 4],
			['POSITION_NM', '직급', 4], ['PHONE', '전화번호', 6], ['JOIN_DT', '입사일자', 6, 'date']]);
		$('#cardModal').on('hidden.bs.modal', function() { opened = null; revealed = {}; render(); });
	});

	$(document).on('click', '.cate-tab', function() { current = $(this).data('tab'); render(); });

	function load(then) {
		$.post('/admin/staff/staffListData.do', function(res) {
			rows = res.list || [];
			fillFilters();
			render();
			if (then) then();
		});
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
			return !kw || [r.STAFF_NM, r.PHONE, r.EMAIL, r.DEPT_NM, r.ORG_NM, r.MEMO].some(function(v) { return v && String(v).toLowerCase().indexOf(kw) >= 0; });
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
		var work = rows.filter(function(r) { return r.STATUS_CD === 'WORK'; }).length;
		$('#tabs').empty().append(hrTab('WORK', '재직', work, current === 'WORK')).append(hrTab('LEFT', '퇴사', rows.length - work, current === 'LEFT'));
		var list = filtered();
		renderSummary(list);
		var cols = [['SEQ_NO', 'NO'], ['ORG_NM', '소속'], ['DEPT_NM', '부서'], ['POSITION_NM', '직급'], ['STAFF_NM', '성명'], ['PHONE', '전화번호'], ['EMAIL', '이메일'],
			['JOIN_DT', '입사일'], current === 'LEFT' ? ['LEAVE_DT', '퇴사일'] : null, ['_TENURE', '근속'], ['_DOCS', '서류'], ['MEMO', '비고']].filter(Boolean);
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
				} else {
					editable($td, r, c[0], /_DT$/.test(c[0]) ? 'date' : null);
					if (c[0] === 'MEMO') $td.addClass('hr-memo');
				}
				$tr.append($td);
			});
			$body.append($tr);
		});
	}

	function renderSummary(list) {
		var by = {};
		list.forEach(function(r) { var k = r.ORG_NM || '소속 없음'; by[k] = (by[k] || 0) + 1; });
		var $s = $('#summary').empty().append($('<span class="st-chip">').append('합계 ').append($('<b>').text(list.length)));
		Object.keys(by).sort().forEach(function(k) { $s.append($('<span class="st-chip">').append(document.createTextNode(k + ' ')).append($('<b>').text(by[k]))); });
	}

	// 한 칸: 눌러서 수정 + 단축키 복사
	function editable($el, r, field, type) {
		hrEditable($el, {
			url: '/admin/staff/saveStaffFieldData.do', key: { STAFF_SQ: r.STAFF_SQ }, field: field, type: type, label: r.STAFF_NM + ' ' + (LABELS[field] || field),
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
		var $b = $('#cardBody').empty();
		SECTIONS.forEach(function(s) {
			$b.append($('<div class="hr-section">').text(s[0]));
			var $g = $('<div class="st-grid">').appendTo($b);
			s[1].forEach(function(f) {
				var $row = $('<div class="hr-card-row">').append($('<div class="hr-card-label">').text(f[1])).appendTo($g);
				if (f[2] === 'secret') $row.append(secretCell(r, f[0]));
				else $row.append(editable($('<div>'), r, f[0], f[2]));
			});
			if (s[0] === '일자') $g.append($('<div class="hr-card-row">').append($('<div class="hr-card-label">').text('근속')).append($('<div class="hr-cell">').text(tenure(r) || '-')));
		});
		$b.append($('<div class="hr-section">').append('서류 ').append($('<span class="small text-muted font-weight-normal">').text('(미제출 ' + missingDocs(r).length + '건)')));
		var $d = $('<div class="st-docs">').appendTo($b);
		DOCS.forEach(function(d) {
			var $cell = $('<div>');
			hrEditable($cell, {
				url: '/admin/staff/saveStaffFieldData.do', key: { STAFF_SQ: r.STAFF_SQ }, field: d[0], type: DOC_VALUES, label: r.STAFF_NM + ' ' + d[1],
				show: function() { return r[d[0]] || '미제출'; }, value: function() { return r[d[0]]; },
				saved: function(v) { r[d[0]] = v; paintCard(); }
			});
			$cell.attr('data-tone', !r[d[0]] || r[d[0]] === 'X' ? 'warn' : 'good');
			$d.append($('<div class="hr-card-row">').append($('<div class="hr-card-label">').css('flex-basis', '96px').text(d[1])).append(copyable($cell, r, d[0])));
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
		bootbox.confirm(r.STAFF_NM + ' 님을 ' + STATUS[to] + '(으)로 옮길까요?' + (to === 'LEFT' && !r.LEAVE_DT ? ' 퇴사일자는 인사카드에서 입력해 주세요.' : ''), function(ok) {
			if (!ok) return;
			hrPost('/admin/staff/saveStaffFieldData.do', { STAFF_SQ: r.STAFF_SQ, FIELD: 'STATUS_CD', VALUE: to }, function() {
				r.STATUS_CD = to;
				current = to;
				paintCard();
				render();
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
