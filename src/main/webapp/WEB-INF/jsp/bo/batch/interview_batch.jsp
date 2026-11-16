<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>

<%-- 비밀값 칸을 type=password 로 두면 브라우저가 계정 비밀번호를 자동으로 채운다. 입력하는 동안 글자 칸에 가림 처리만 한다 --%>
<style>
	.secret-typing { -webkit-text-security: disc; }
	/* 가져오기: 값 한 줄 + 버튼 하나 */
	.ib-line { display: flex; align-items: center; gap: 10px; padding: 7px 0; border-bottom: 1px dashed #e6e9ec; }
	.ib-line:last-of-type { border-bottom: 0; }
	.ib-ico { width: 26px; height: 26px; border-radius: 7px; display: grid; place-items: center; flex: none; background: #eef1f4; }
	.ib-n { min-width: 92px; }
	.ib-v .p { color: #5f6b75; } .ib-v.none { color: #7a5600; font-weight: 600; } .ib-v.ok { color: #17692f; } .ib-v.bad { color: #a32020; font-weight: 600; }
	.ib-chip { font-size: 11px; border-radius: 999px; padding: 1px 7px; background: #fff5dc; color: #7a5600; font-weight: 600; }
	.ib-act { margin-left: auto; }
	.ib-alert { background: #fdeaea; color: #8a1c1c; border-radius: 8px; padding: 8px 12px; font-size: 13px; margin: 2px 0 6px 36px; }
	.ib-alert a { font-weight: 700; }
	.ib-saved { color: #17692f; font-size: 12px; font-weight: 700; }
	/* 고르기 창 */
	.pk-list { border: 1px solid rgba(17,17,17,.12); border-radius: 8px; max-height: 50vh; overflow-y: auto; }
	.pk-it { display: flex; align-items: center; gap: 10px; width: 100%; border: 0; border-bottom: 1px solid #f0f1f3; background: #fff; padding: 9px 12px; text-align: left; font-size: 13.5px; }
	.pk-it:last-child { border-bottom: 0; }
	.pk-it:hover, .pk-it:focus { background: #f6fbfd; }
	.pk-it.on { background: #eef9fc; font-weight: 700; }
	.pk-sw { width: 12px; height: 12px; border-radius: 3px; flex: none; background: #9aa4ac; }
	.pk-meta { margin-left: auto; font-size: 12px; color: #5f6b75; font-weight: 400; }
	.pk-crumb { display: flex; flex-wrap: wrap; gap: 4px; align-items: center; font-size: 13px; margin-bottom: 8px; }
	.pk-crumb button { border: 0; background: none; padding: 0; color: #0b6e8a; font-weight: 600; }
	.pk-crumb b { color: #1f2328; }
	.pk-tabs { display: flex; gap: 4px; margin-bottom: 8px; }
	.pk-tabs button { border: 1px solid rgba(17,17,17,.12); background: #fff; border-radius: 999px; padding: 3px 12px; font-size: 12.5px; font-weight: 700; color: #5f6b75; }
	.pk-tabs button[aria-pressed=true] { background: #111; color: #fff; border-color: #111; }
	.pk-sel { font-size: 12.5px; background: #eef9fc; color: #0b6e8a; border-radius: 6px; padding: 6px 10px; margin-top: 8px; }
	.pk-empty { padding: 14px; color: #5f6b75; font-size: 13px; text-align: center; }
</style>

<body class="hold-transition sidebar-mini">

	<div class="wrapper">

		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>

		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header">
					<h3 class="card-title bTitle"><b>신입면접 배치</b></h3>
				</div>

				<div class="card-body">

					<div class="cal-panel">
						<div class="cal-panel-head">
							<span><i class="fas fa-cog"></i> 가져오기</span>
							<span class="d-flex align-items-center" style="gap:12px">
								<label class="mb-0 font-weight-normal"><input type="checkbox" id="srcAuto" disabled> 자동 09:00·면접 10분 전</label>
								<button type="button" id="runBtn" class="btn btn-sm btn-dark" onclick="runNow();">지금 실행</button>
							</span>
						</div>
						<%-- 읽을 캘린더·이력서 폴더는 여기서 고른다(시스템 관리자만). 구글 연결 자체는 🔗 내 연동 --%>
						<div class="cal-panel-body" id="icalBody">
							<div class="ib-line"><span class="ib-ico">📅</span><b class="ib-n">면접 캘린더</b><span id="srcLegacy" class="ib-chip" hidden>예전 iCal 로 읽는 중</span><span id="srcCal" class="ib-v">-</span>
								<span class="ib-act"><span class="ib-saved" id="calSaved" hidden>저장됨</span> <c:if test="${superUser}"><button type="button" class="btn btn-sm btn-primary" id="calPickBtn">캘린더 고르기</button></c:if></span></div>
							<div class="ib-alert" id="calErr" hidden></div>
							<div class="ib-line"><span class="ib-ico">📁</span><b class="ib-n">이력서 폴더</b><span id="srcFolder" class="ib-v">-</span>
								<span class="ib-act"><span class="ib-saved" id="folderSaved" hidden>저장됨</span> <c:if test="${superUser}"><button type="button" class="btn btn-sm btn-outline-secondary" id="folderPickBtn">폴더 고르기</button></c:if></span></div>
							<div class="ib-alert" id="folderErr" hidden></div>
							<div class="ib-line"><span class="ib-ico">🔗</span><b class="ib-n">구글 연결</b><span id="srcDrive" class="ib-v">-</span>
								<span class="ib-act"><a class="btn btn-sm btn-link" href="/admin/my/openGoogleLink.do?back=/admin/batch/openInterviewBatch.do">내 연동 ›</a></span></div>
							<c:if test="${!superUser}"><small class="text-muted d-block mt-1">캘린더·이력서 폴더는 시스템 관리자가 고릅니다.</small></c:if>
						</div>
					</div>

					<div class="cal-panel">
						<div class="cal-panel-head"><span><i class="fas fa-history"></i> 실행 이력</span><small id="preStatus" class="text-muted"></small></div>
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0">
								<thead>
									<tr>
										<th scope="col">실행 시각</th><th scope="col">구분</th><th scope="col">이름</th><th scope="col">결과</th><th scope="col">대상 주</th>
										<th scope="col">읽음</th><th scope="col">추가</th><th scope="col">수정</th><th scope="col">변경 없음</th><th scope="col">제외</th><th scope="col">실패</th><th scope="col">상세</th>
									</tr>
								</thead>
								<tbody id="logBody"></tbody>
							</table>
						</div>
					</div>

				</div>
			</section>
		</div>

		<div class="modal fade" id="detailModal" tabindex="-1" role="dialog" aria-labelledby="detailTitle" aria-hidden="true">
			<div class="modal-dialog modal-xl modal-dialog-scrollable" role="document">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title" id="detailTitle">실행 상세</h5>
						<button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button>
					</div>
					<div class="modal-body p-0">
						<div class="table-responsive">
							<table class="table table-sm cal-table mb-0">
								<thead>
									<tr><th scope="col">처리</th><th scope="col">면접일</th><th scope="col">시간</th><th scope="col">이름</th><th scope="col">일정 제목</th><th scope="col">사유</th><th scope="col">이력서</th></tr>
								</thead>
								<tbody id="detailBody"></tbody>
							</table>
						</div>
					</div>
				</div>
			</div>
		</div>

	<c:if test="${superUser}">
		<div class="modal fade" id="calPick" tabindex="-1" role="dialog" aria-labelledby="calPickTitle" aria-hidden="true">
			<div class="modal-dialog" role="document">
				<div class="modal-content">
					<div class="modal-header"><h5 class="modal-title" id="calPickTitle">면접 캘린더 고르기</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
					<div class="modal-body">
						<input type="search" id="calFind" class="form-control form-control-sm mb-2" placeholder="캘린더 이름 찾기" aria-label="캘린더 이름 찾기">
						<div class="pk-list" id="calList" role="radiogroup" aria-label="캘린더"></div>
						<div class="small text-muted mt-2" id="calHint"></div>
					</div>
					<div class="modal-footer"><button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">취소</button><button type="button" class="btn btn-sm btn-primary" id="calPickOk" disabled>이 캘린더로</button></div>
				</div>
			</div>
		</div>
		<div class="modal fade" id="folderPick" tabindex="-1" role="dialog" aria-labelledby="folderPickTitle" aria-hidden="true">
			<div class="modal-dialog" role="document">
				<div class="modal-content">
					<div class="modal-header"><h5 class="modal-title" id="folderPickTitle">이력서 폴더 고르기</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
					<div class="modal-body">
						<div class="pk-tabs"><button type="button" data-mode="MY" aria-pressed="true">내 드라이브</button><button type="button" data-mode="SHARED" aria-pressed="false">공유 문서함</button></div>
						<div class="pk-crumb" id="fdCrumb"></div>
						<input type="search" id="fdFind" class="form-control form-control-sm mb-2" placeholder="폴더 이름 찾기(Enter) · 드라이브 폴더 주소를 붙여 넣어도 이동" aria-label="폴더 찾기 또는 주소">
						<div class="pk-list" id="fdList"></div>
						<div class="pk-sel" id="fdSel"></div>
					</div>
					<div class="modal-footer"><span class="small text-muted mr-auto">폴더를 누르면 들어가고, 위 경로를 누르면 올라갑니다</span><button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal">취소</button><button type="button" class="btn btn-sm btn-primary" id="fdOk" disabled>이 폴더로</button></div>
				</div>
			</div>
		</div>
	</c:if>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>

	<script>
	var STATUS = { OK: ['성공', 'badge-success'], WARN: ['일부 실패', 'badge-warning'], FAIL: ['실패', 'badge-danger'] };
	var RESULT = { INSERT: ['추가', 'badge-success'], UPDATE: ['수정', 'badge-info'], SAME: ['변경 없음', 'badge-secondary'], EXCL: ['제외', 'badge-light'], SKIP: ['실패', 'badge-danger'] };
	var selectedSq = null, IS_SUPER = ${superUser == true}, src = null;

	$(function() {
		$.getJSON('/admin/batch/icalListData.do', function(res) { renderSource(res.list); if (IS_SUPER) loadSource(); })
			.fail(function() { $('#srcCal').text('설정을 불러오지 못했습니다.'); });
		if (IS_SUPER) {
			$('#calPickBtn').on('click', openCalPick);
			$('#folderPickBtn').on('click', function() { openFolderPick(); });
		}
		$.getJSON('/admin/batch/interviewBatchLogData.do', function(res) {
			renderLog(res.list);
			var pre = res.pre || {};
			$('#preStatus').text('스케줄러 확인 ' + (pre.lastCheck || '대기 중') + ' · 오늘 면접 ' + ((pre.todayTimes || []).join(', ') || '없음') + ' (각 10분 전 실행)');
		})
			.fail(function() { emptyRow('#logBody', 12, '이력을 불러오지 못했습니다.'); });
		$('#srcAuto').on('change', function() { setAuto(selectedSq, this.checked); });
	});

	function emptyRow(body, cols, text) {
		$(body).empty().append($('<tr>').append($('<td class="cal-empty">').attr('colspan', cols).text(text)));
	}

	function badge(map, code) {
		var b = map[code] || [code, 'badge-secondary'];
		return $('<span class="badge">').addClass(b[1]).text(b[0]);
	}

	// 면접 일정 세트는 하나(첫 줄). 사용자 입력이 들어가므로 text() 로 넣는다
	function renderSource(list) {
		var r = (list || [])[0];
		selectedSq = r ? r.ICAL_SQ : null;
		$('#srcLegacy').prop('hidden', !(r && r.ICAL_MASK));
		$('#srcCal').text(r && r.ICAL_NM ? r.ICAL_NM : '아직 고르지 않음').attr('class', 'ib-v' + (r && r.ICAL_NM ? '' : ' none'));
		$('#srcFolder').text(r && r.FOLDER_MASK || '아직 고르지 않음').attr('class', 'ib-v' + (r && r.FOLDER_MASK ? '' : ' none'));
		$('#srcDrive').text(r && r.DRIVE_CONNECTED ? '● ' + (r.DRIVE_ACCOUNT || '연결됨') : '연결 안 됨').attr('class', 'ib-v ' + (r && r.DRIVE_CONNECTED ? 'ok' : 'bad'));
		$('#srcAuto').prop('disabled', !r).prop('checked', !!r && r.AUTO_YN === 'Y');
	}

	// ── 시스템 관리자: 캘린더·폴더 고르기. 고르면 바로 저장 ──

	// 구글 오류 안내 { code, msg, url } → 그 줄 아래 빨간 칸
	function showErr(sel, err) {
		var $e = $(sel).empty().prop('hidden', !err);
		if (!err) return;
		$e.text(err.msg + ' ');
		if (err.url) $e.append($('<a target="_blank" rel="noopener">').attr('href', err.url).text('켜러 가기 ↗'));
		else if (err.code === 'NOLINK' || err.code === 'EXPIRED' || err.code === 'SCOPE') $e.append($('<a>').attr('href', '/admin/my/openGoogleLink.do?back=/admin/batch/openInterviewBatch.do').text('내 연동에서 연결 ›'));
	}

	function loadSource(then) {
		$.post('/admin/my/interviewSourceData.do', function(res) {
			if (res.error) return showErr('#calErr', { msg: res.error });
			src = res;
			showErr('#calErr', res.calendarError);
			showErr('#folderErr', res.folderError);
			if (res.folderPath && res.folderPath.length) {
				var p = res.folderPath, $v = $('#srcFolder').empty().attr('class', 'ib-v');
				$v.append($('<span class="p">').text(p.slice(0, -1).map(function(x) { return x.name; }).concat(['']).join(' › '))).append(document.createTextNode(p[p.length - 1].name));
			}
			if (then) then();
		}, 'json');
	}

	function saved(sel) { $(sel).prop('hidden', false).stop(true, true).show().delay(1500).fadeOut(300, function() { $(this).prop('hidden', true).show(); }); }

	function saveSource(data, savedSel) {
		$.post('/admin/my/saveInterviewSourceData.do', data, function(res) {
			if (res.error) return bootbox.alert(res.error);
			$('.modal').modal('hide');
			$.getJSON('/admin/batch/icalListData.do', function(r) { renderSource(r.list); loadSource(); });
			saved(savedSel);
		}, 'json').fail(function() { bootbox.alert('저장하지 못했습니다.'); });
	}

	// 면접·인터뷰 이름이 위로, 생일·휴일 같은 구글 기본·구독은 아래로
	function calRank(c) {
		if (/면접|인터뷰|interview/i.test(c.summary || '')) return 0;
		if (/#holiday|#contacts|#weeknum/.test(c.id)) return 3;
		return c.role === 'reader' ? 2 : 1;
	}
	var calPicked = null;
	function openCalPick() {
		calPicked = null;
		$('#calFind').val('');
		$('#calPickOk').prop('disabled', true);
		$('#calPick').modal('show');
		$('#calList').html('<div class="pk-empty">불러오는 중입니다.</div>');
		loadSource(function() {
			if (src.calendarError) { $('#calList').html('<div class="pk-empty">').find('.pk-empty').text(src.calendarError.msg); return; }
			drawCals();
		});
	}
	function drawCals() {
		var kw = $.trim($('#calFind').val()).toLowerCase(), cur = src.result && src.result.CAL_ID;
		var cals = (src.calendars || []).filter(function(c) { return !kw || String(c.summary).toLowerCase().indexOf(kw) >= 0; })
			.sort(function(a, b) { return calRank(a) - calRank(b) || String(a.summary).localeCompare(String(b.summary), 'ko'); });
		var $l = $('#calList').empty();
		if (!cals.length) $l.append($('<div class="pk-empty">').text(kw ? '찾는 캘린더가 없습니다.' : '연결 계정이 볼 수 있는 캘린더가 없습니다.'));
		cals.forEach(function(c) {
			var on = calPicked ? calPicked.id === c.id : c.id === cur;
			var kind = c.primary ? '기본' : /#holiday|#contacts|#weeknum/.test(c.id) ? '구글 기본·구독' : c.role === 'owner' ? '내 캘린더' : '공유받음';
			$l.append($('<button type="button" class="pk-it" role="radio">').toggleClass('on', on).attr('aria-checked', on)
				.append($('<span class="pk-sw">').css('background', c.color || '')).append($('<span>').text(c.summary)).append($('<span class="pk-meta">').text(kind))
				.on('click', function() { calPicked = c; $('#calPickOk').prop('disabled', c.id === cur); drawCals(); }));
		});
		$('#calHint').text('안 보이나요? 그 캘린더 주인이 구글 캘린더 → 캘린더 설정 → 「특정 사용자와 공유」에 '
			+ ($('#srcDrive').text().replace('● ', '') || '연결 계정 메일') + ' 을 넣으면 여기에 나옵니다.');
	}
	$(document).on('input', '#calFind', function() { if (src) drawCals(); });
	$(document).on('click', '#calPickOk', function() { if (calPicked) saveSource({ calId: calPicked.id, calName: calPicked.summary }, '#calSaved'); });

	// 폴더 창: 지금 들어와 있는 폴더(fd.path 의 끝)를 고른다
	var fd = { mode: 'MY', parent: '', path: [] };
	function openFolderPick() {
		var p = src && src.folderPath;
		fd = { mode: 'MY', parent: p && p.length ? p[p.length - 1].id : '', path: [] };
		$('#fdFind').val('');
		$('#folderPick').modal('show');
		listFolders();
	}
	function listFolders(q) {
		$('.pk-tabs button').each(function() { $(this).attr('aria-pressed', $(this).data('mode') === fd.mode); });
		$('#fdList').html('<div class="pk-empty">불러오는 중입니다.</div>');
		$.post('/admin/my/driveFoldersData.do', { parent: fd.parent, mode: fd.mode, q: q || '' }, function(res) {
			if (res.error || res.googleError) { $('#fdList').html('<div class="pk-empty">').find('.pk-empty').text((res.googleError || {}).msg || res.error); return; }
			fd.path = res.path || [];
			drawCrumb(q);
			var $l = $('#fdList').empty();
			if (!res.result.length) $l.append($('<div class="pk-empty">').text(q ? '찾는 폴더가 없습니다.' : '하위 폴더가 없습니다.'));
			res.result.forEach(function(f) {
				$l.append($('<button type="button" class="pk-it">').append($('<span>').text('📁')).append($('<span>').text(f.name)).append($('<span class="pk-meta">').text('›'))
					.attr('aria-label', f.name + ' 폴더 열기').on('click', function() { fd.parent = f.id; $('#fdFind').val(''); listFolders(); }));
			});
			var here = fd.path[fd.path.length - 1];
			$('#fdSel').text(here ? '고를 폴더: ' + fd.path.map(function(x) { return x.name; }).join(' › ') + ' · 배치는 이 아래 년/월/일/이름 폴더에서 이력서를 찾습니다' : (q ? '찾은 폴더를 눌러 들어간 뒤 고르세요' : '폴더를 눌러 들어간 뒤 고르세요'));
			$('#fdOk').prop('disabled', !here);
		}, 'json').fail(function() { $('#fdList').html('<div class="pk-empty">폴더를 불러오지 못했습니다.</div>'); });
	}
	function drawCrumb(q) {
		var $c = $('#fdCrumb').empty();
		if (q) return $c.append($('<b>').text('「' + q + '」 찾은 결과'));
		if (!fd.path.length) return $c.append($('<b>').text(fd.mode === 'SHARED' ? '공유 문서함' : '내 드라이브'));
		fd.path.forEach(function(x, i) {
			if (i) $c.append($('<span class="text-muted">').text('›'));
			if (i === fd.path.length - 1) $c.append($('<b>').text(x.name));
			else $c.append($('<button type="button">').text(x.name).on('click', function() { fd.parent = x.id; listFolders(); }));
		});
	}
	$(document).on('click', '.pk-tabs button', function() { fd = { mode: $(this).data('mode'), parent: '', path: [] }; $('#fdFind').val(''); listFolders(); });
	$(document).on('keydown', '#fdFind', function(e) {
		if (e.key !== 'Enter' || e.originalEvent.isComposing) return;
		e.preventDefault();
		var v = $.trim(this.value), m = v.match(/\/folders\/([\w-]{10,})/) || v.match(/^([\w-]{25,})$/);
		if (m) { fd.parent = m[1]; this.value = ''; listFolders(); } else listFolders(v);
	});
	$(document).on('click', '#fdOk', function() { var here = fd.path[fd.path.length - 1]; if (here) saveSource({ folder: here.id }, '#folderSaved'); });
	function renderLog(list) {
		if (!list || !list.length) return emptyRow('#logBody', 12, '아직 실행 이력이 없습니다.');
		var $body = $('#logBody').empty();
		list.forEach(function(r) {
			var $tr = $('<tr>');
			[r.START_DT, { AUTO: '자동', PRE: '면접 전' }[r.TRIGGER_CD] || '수동', r.ICAL_NM || '-'].forEach(function(v) { $tr.append($('<td>').text(v)); });
			$tr.append($('<td>').append(badge(STATUS, r.STATUS_CD)));
			$tr.append($('<td>').text(r.FROM_DT + ' ~ ' + r.TO_DT));
			[r.READ_CNT, r.INSERT_CNT, r.UPDATE_CNT, r.SAME_CNT, r.EXCL_CNT, r.SKIP_CNT].forEach(function(v) { $tr.append($('<td>').text(v)); });
			$tr.append($('<td>').append($('<button type="button" class="btn btn-xs btn-outline-dark">보기</button>').on('click', function() { openDetail(r); })));
			$body.append($tr);
			var note = r.ERROR_MSG || r.SKIP_DETAIL;
			if (note) {
				$body.append($('<tr>').append($('<td colspan="12" class="small text-muted" style="white-space:pre-line;">').text(note)));
			}
		});
	}

	function openDetail(r) {
		$('#detailTitle').text('실행 상세 · ' + r.START_DT + (r.ICAL_NM ? ' · ' + r.ICAL_NM : ''));
		emptyRow('#detailBody', 7, '불러오는 중입니다.');
		$('#detailModal').modal('show');
		$.getJSON('/admin/batch/interviewBatchDetailData.do', { logSq: r.BATCH_LOG_SQ }, function(res) {
			if (!res.list || !res.list.length) return emptyRow('#detailBody', 7, r.ERROR_MSG || '상세 내역이 없습니다. 기능 추가 전 실행이거나 대상 주에 일정이 없었습니다.');
			var $body = $('#detailBody').empty();
			res.list.forEach(function(d) {
				$body.append($('<tr>').append(
					$('<td>').append(badge(RESULT, d.RESULT_CD)),
					$('<td>').text(d.INTV_DT || ''), $('<td>').text(d.INTV_TM || ''), $('<td class="cal-title">').text(d.APLY_NM || ''),
					$('<td>').text(d.EVT_TITLE || ''), $('<td>').text(d.REASON || ''), $('<td>').text(d.RESUME_NOTE || '')));
			});
		}).fail(function() { emptyRow('#detailBody', 7, '상세 내역을 불러오지 못했습니다.'); });
	}

	function runNow() {
		if (!selectedSq) return alert('면접 캘린더가 정해지지 않았습니다. 시스템 관리자가 위 「캘린더 고르기」로 정해 주세요.');
		var $btn = $('#runBtn').prop('disabled', true).text('실행 중...');
		$.post('/admin/batch/runInterviewBatchData.do', { icalSq: selectedSq }, function(res) {
			if (res.error) return alert(res.error);
			renderLog(res.list);
		}, 'json').fail(function() { alert('실행 요청에 실패했습니다.'); })
			.always(function() { $btn.prop('disabled', false).text('지금 실행'); });
	}

	function setAuto(sq, auto) {
		$.post('/admin/batch/autoIcalData.do', { icalSq: sq, auto: auto }, function(res) { renderSource(res.list); }, 'json')
			.fail(function() {
				alert('변경에 실패했습니다.');
				$.getJSON('/admin/batch/icalListData.do', function(res) { renderSource(res.list); });
			});
	}
	</script>
</body>
</html>
