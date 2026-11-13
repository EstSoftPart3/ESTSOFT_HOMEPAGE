<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/deploy/deploy_common.jspf"%>
<style>
	#psHead th, #psBody td { white-space: nowrap; vertical-align: middle; }
	#psBody td.ps-prj { max-width: 260px; overflow: hidden; text-overflow: ellipsis; }
	.pl-chks { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; padding: 10px 14px 4px; }
	.pl-sep { width: 1px; align-self: stretch; background: rgba(17,17,17,.15); margin: 0 4px; }
	.pl-scroll { max-height: 68vh; overflow: auto; }
	.pl-sort { background: none; border: 0; padding: 0 0 0 3px; color: #9aa4ac; font-size: 10px; cursor: pointer; }
	.pl-sort.on { color: #0b6e8a; }
	#psBody tr.ps-secret td { background-color: #f4effc; }
	.ps-bar { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; background: #eef9fc; border: 1px solid #b9dbe6; border-radius: 8px; padding: 7px 10px; margin: 4px 14px 8px; }
	.ps-note { margin: 0 14px 8px; padding: 7px 10px; border-radius: 8px; background: #fff5dc; color: #7a5600; font-weight: 600; font-size: 12.5px; }
	.ps-log { border: 0; cursor: pointer; }
	.ps-form { display: grid; grid-template-columns: 150px 1fr; gap: 8px 12px; align-items: center; }
	.ps-form > label { margin: 0; color: #5f6b75; font-weight: 400; }
	.ps-var { display: inline-block; border: 1px dashed #0b6e8a; color: #0b6e8a; background: #eef9fc; border-radius: 4px; padding: 0 6px; margin: 2px; font-size: 12px; cursor: pointer; }
	.ps-var:focus { outline: 2px solid #16d5ff; }
	.ps-two { display: grid; grid-template-columns: minmax(0, 1.25fr) minmax(0, 1fr); gap: 14px; align-items: start; }
	.ps-mail { border: 1px solid rgba(17,17,17,.12); border-radius: 8px; background: #fff; overflow: hidden; }
	.ps-mail .h { padding: 8px 12px; border-bottom: 1px solid rgba(17,17,17,.1); font-size: 12px; }
	.ps-mail .h b { display: inline-block; width: 64px; color: #5f6b75; font-weight: 400; }
	.ps-mail iframe { width: 100%; height: 330px; border: 0; display: block; }
	.ps-att { display: inline-flex; gap: 6px; align-items: center; border: 1px solid rgba(17,17,17,.12); border-radius: 6px; padding: 4px 10px; background: #fafbfc; font-size: 12px; margin: 8px 12px 12px; }
	#sendList td { white-space: nowrap; }
	@media (max-width: 992px) { .ps-two { grid-template-columns: 1fr; } .ps-form { grid-template-columns: 1fr; } }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header d-flex flex-wrap align-items-center" style="gap:8px">
					<h3 class="card-title bTitle"><b>급여명세서</b></h3>
					<span class="dp-pill" id="status"></span>
					<div class="ml-auto d-flex align-items-center flex-wrap" style="gap:6px">
						<button type="button" class="btn btn-sm btn-outline-secondary" id="btnConf">⚙ 보내는 메일 설정</button>
						<button type="button" class="btn btn-sm btn-outline-secondary" id="prevYm" aria-label="이전 달">◀</button>
						<input type="month" id="ym" class="form-control form-control-sm" style="width:150px" aria-label="급여 월">
						<button type="button" class="btn btn-sm btn-outline-secondary" id="nextYm" aria-label="다음 달">▶</button>
						<span class="small text-muted" id="payDt"></span>
					</div>
				</div>
				<div class="cate-tabs" id="pageTabs" role="tablist" aria-label="화면 구분"></div>
				<div class="card-body">
					<div class="cal-panel" data-page="tax" hidden>
						<div class="ps-note" id="taxNote" hidden></div>
						<div class="ps-bar">
							<span id="taxRange"></span>
							<div class="ml-auto d-flex" style="gap:6px">
								<button type="button" class="btn btn-sm btn-outline-secondary" id="btnTaxXl">⬇ 엑셀 내려받기</button>
								<button type="button" class="btn btn-sm btn-primary" id="btnTaxSend">📧 세무서로 보내기</button>
							</div>
						</div>
						<div class="ps-two px-3 pb-3">
							<div>
								<div class="ps-form" style="grid-template-columns:80px 1fr">
									<label for="tTo">받는 주소 *</label><textarea id="tTo" class="form-control form-control-sm" rows="2" placeholder="세무사무소 메일. 여러 곳이면 쉼표나 줄바꿈으로 나눕니다"></textarea>
									<label for="tSubject">제목 *</label><input id="tSubject" class="form-control form-control-sm" maxlength="300">
									<label>넣을 값</label><div id="tVars"></div>
									<label for="tBody">내용 *</label><textarea id="tBody" class="form-control form-control-sm" rows="8"></textarea>
								</div>
								<div class="d-flex flex-wrap mt-2" style="gap:6px">
									<button type="button" class="btn btn-sm btn-outline-secondary" id="btnTaxDefault">기본 문구로 되돌리기</button>
									<span class="small text-muted align-self-center" id="tSaved"></span>
									<button type="button" class="btn btn-sm btn-primary ml-auto" id="btnTaxSave">저장</button>
								</div>
								<div class="small text-muted mt-2">보내는 계정·답장 주소·숨은 참조는 ⚙ 보내는 메일 설정(급여명세서와 같은 Gmail)을 씁니다.</div>
							</div>
							<div>
								<div class="small text-muted mb-1">보낸 기록</div>
								<div class="table-responsive" style="max-height:40vh">
									<table class="table table-sm cal-table mb-0"><thead><tr><th>일시</th><th>누가</th><th>귀속월</th><th>받는 주소</th><th>결과</th></tr></thead><tbody id="taxLogs"></tbody></table>
								</div>
							</div>
						</div>
					</div>
					<div class="cal-panel" data-page="slip">
						<div class="pl-chks" id="chks" role="group" aria-label="보기 구분"></div>
						<div class="ps-note" id="note" hidden></div>
						<div class="ps-bar">
							<b id="pickCount">0명 선택</b>
							<span class="small text-muted">체크한 사람에게 암호(생년월일 8자리)가 걸린 PDF 명세서를 보냅니다</span>
							<div class="ml-auto d-flex" style="gap:6px">
								<button type="button" class="btn btn-sm btn-primary" id="btnMail">📧 메일 보내기</button>
								<button type="button" class="btn btn-sm btn-outline-secondary" disabled title="문자 업체가 정해지면 추가됩니다">💬 문자 보내기 (준비 중)</button>
								<button type="button" class="btn btn-sm btn-outline-secondary" id="btnZip">⬇ PDF 내려받기(zip)</button>
							</div>
						</div>
						<div class="pl-scroll">
							<table class="table table-sm cal-table mb-0">
								<thead id="psHead"></thead>
								<tbody id="psBody"></tbody>
							</table>
						</div>
						<div class="small text-muted px-3 py-2">금액은 급여관리의 값 그대로입니다. 마감된 달만 보내거나 내려받을 수 있고, 미리보기는 언제든 됩니다(미리보기에는 암호가 없습니다). 받는 주소는 인사카드의 개인 메일, 암호는 주민번호의 생년월일 8자리(예: 19900101)입니다.</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<form id="zipForm" method="post" action="/admin/payslip/zip.do" target="_blank" hidden><input type="hidden" name="YM"><input type="hidden" name="STAFF_SQ"></form>

	<div class="modal fade" id="sendModal" tabindex="-1" role="dialog" aria-labelledby="sendTitle" aria-hidden="true" data-backdrop="static">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="sendTitle">급여명세서 보내기</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<div class="modal-body">
					<div id="sendSummary" class="mb-2"></div>
					<div class="table-responsive" style="max-height:46vh">
						<table class="table table-sm cal-table mb-0"><thead><tr><th>성명</th><th>받는 메일</th><th>결과</th></tr></thead><tbody id="sendList"></tbody></table>
					</div>
				</div>
				<div class="modal-footer">
					<span class="small text-muted mr-auto" id="sendProgress" aria-live="polite"></span>
					<button type="button" class="btn btn-sm btn-outline-secondary" data-dismiss="modal" id="sendClose">취소</button>
					<button type="button" class="btn btn-sm btn-primary" id="sendGo"></button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="confModal" tabindex="-1" role="dialog" aria-labelledby="confTitle" aria-hidden="true">
		<div class="modal-dialog modal-xl" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="confTitle">⚙ 보내는 메일 설정</h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<div class="cate-tabs" id="confTabs" role="tablist" aria-label="설정 구분"></div>
				<div class="modal-body">
					<div data-pane="account">
						<form id="accForm" onsubmit="saveAccount(); return false;">
							<div class="ps-form">
								<label>메일 서비스</label><div><span class="dp-pill ok">Gmail</span> <span class="small text-muted">회사 메일이 모두 Gmail 이라 고정입니다</span></div>
								<label for="cFromNm">보내는 사람 이름 *</label><input id="cFromNm" name="FROM_NM" class="form-control form-control-sm" maxlength="100" required>
								<label for="cFromAddr">보내는 Gmail 주소 *</label><input id="cFromAddr" name="FROM_ADDR" type="email" class="form-control form-control-sm" maxlength="200" required>
								<label for="cPw">앱 비밀번호 *</label>
								<div>
									<input id="cPw" name="APP_PW" type="password" class="form-control form-control-sm" maxlength="40" autocomplete="new-password" style="max-width:320px;display:inline-block">
									<span id="cPwState"></span>
									<details class="small text-muted mt-1"><summary>발급 방법</summary>Google 계정 로그인 비밀번호가 아니라 <b>앱 비밀번호 16자리</b>입니다. 보내는 Gmail 계정으로 로그인 → Google 계정 관리 → 보안 → 2단계 인증 켜기 → 「앱 비밀번호」에서 새로 만들기 → 나온 16자리를 여기에 붙여 넣습니다. 저장하면 암호화해 보관하고 화면에 다시 보이지 않습니다.</details>
								</div>
								<label for="cReply">답장 받을 주소</label><input id="cReply" name="REPLY_TO" type="email" class="form-control form-control-sm" maxlength="200" placeholder="비우면 보내는 주소">
								<label for="cBcc">숨은 참조(BCC)</label><input id="cBcc" name="BCC" type="email" class="form-control form-control-sm" maxlength="200" placeholder="선택 · 보낸 메일 보관용">
								<label for="cContact">담당자 연락처</label><input id="cContact" name="CONTACT" class="form-control form-control-sm" maxlength="100" placeholder="본문의 {담당자 연락처} 자리에 들어갑니다">
								<label>연결 상태</label><div><span id="cVerified"></span> <button type="button" class="btn btn-sm btn-outline-secondary" id="btnVerify">연결 확인</button> <span class="small text-muted">실제로 로그인만 해 보고 메일은 보내지 않습니다</span></div>
							</div>
							<div class="text-right mt-3"><span class="small text-muted mr-2">주소나 앱 비밀번호를 바꾸면 연결 확인을 다시 해야 보낼 수 있습니다</span><button type="submit" class="btn btn-sm btn-primary">저장</button></div>
						</form>
					</div>
					<div data-pane="body" hidden>
						<div class="ps-two">
							<div>
								<div class="ps-form" style="grid-template-columns:60px 1fr;margin-bottom:8px"><label for="cSubject">제목</label><input id="cSubject" class="form-control form-control-sm" maxlength="300"></div>
								<div class="mb-1"><span class="small text-muted">넣을 수 있는 값 (누르면 커서 자리에 들어갑니다. 금액은 PDF 에만 넣을 수 있습니다)</span><div id="cVars"></div></div>
								<textarea id="psEditor" rows="14" style="width:100%" aria-label="메일 내용"></textarea>
								<div class="d-flex flex-wrap mt-2" style="gap:6px">
									<button type="button" class="btn btn-sm btn-outline-secondary" id="btnDefault">기본 문구로 되돌리기</button>
									<button type="button" class="btn btn-sm btn-outline-secondary ml-auto" id="btnTest">✉ 시험 발송 (내 메일로)</button>
									<button type="button" class="btn btn-sm btn-primary" id="btnBody">저장</button>
								</div>
							</div>
							<div>
								<div class="small text-muted mb-1">받는 모습 미리보기 (예시 직원 값)</div>
								<div class="ps-mail">
									<div class="h"><div><b>보낸 사람</b><span id="pvFrom"></span></div><div><b>받는 사람</b>김예시 &lt;kim@example.com&gt;</div><div><b>제목</b><span id="pvSubject"></span></div></div>
									<iframe id="pvBody" sandbox title="메일 내용 미리보기"></iframe>
									<div class="ps-att">📎 🔒 <span id="pvFile"></span></div>
								</div>
							</div>
						</div>
					</div>
					<div data-pane="hist" hidden>
						<div class="table-responsive" style="max-height:60vh">
							<table class="table table-sm cal-table mb-0"><thead><tr><th>일시</th><th>누가</th><th>무엇을</th><th></th></tr></thead><tbody id="histBody"></tbody></table>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>

	<script>
	var TYPE_NM = { REGULAR: '정규', PROBATION: '수습', SPECIAL: '특고프리', BIZ: '사업자프리', EMP_INS: '고용보험알바', ETC: '기타계약', EXTERNAL: '외부업체' };
	// 체크 칩: 고용형태 [키, 이름, 형태들] + 발송 상태
	var TYPES = [['REGULAR', '정규', ['REGULAR']], ['PROBATION', '수습', ['PROBATION']], ['SPECIAL', '특고프리', ['SPECIAL']], ['BIZ', '사업자·기타', ['BIZ', 'EMP_INS', 'ETC']], ['EXTERNAL', '외부업체', ['EXTERNAL']]];
	var SENT = [['NONE', '미발송'], ['OK', '보냄'], ['FAIL', '실패']];
	var ym = moment().subtract(1, 'months').format('YYYY-MM'), rows = [], monthClosed = false, ready = false, secretViewer = false, checked = { _SECRET: true }, picked = {}, sortKey = 'STAFF_NM', sortDir = 1;
	var conf = null, confTab = 'account', oEditors = [], editorReady = false, pvTimer = null, sending = false;
	TYPES.concat(SENT).forEach(function(c) { checked[c[0]] = true; });

	$(function() {
		$('#ym').val(ym).on('change', function() { if (this.value) { ym = this.value; picked = {}; load(); } });
		$('#prevYm, #nextYm').on('click', function() { ym = moment(ym + '-01').add(this.id === 'prevYm' ? -1 : 1, 'months').format('YYYY-MM'); $('#ym').val(ym); picked = {}; load(); });
		$('#psHead').on('change', '#pickAll', function() { var on = this.checked; shown().forEach(function(r) { if (on) picked[r.STAFF_SQ] = true; else delete picked[r.STAFF_SQ]; }); render(); });
		$('#psBody').on('change', 'input.ps-chk', function() { if (this.checked) picked[this.value] = true; else delete picked[this.value]; paintBar(); });
		$('#btnMail').on('click', openSend);
		$('#btnZip').on('click', function() {
			var sqs = pickedRows().filter(function(r) { return r.HAS_BIRTH; }).map(function(r) { return r.STAFF_SQ; });
			if (!sqs.length) { bootbox.alert('내려받을 사람이 없습니다. 주민번호(생년월일)가 있는 사람만 암호를 걸어 내려받을 수 있습니다.'); return; }
			$('#zipForm [name=YM]').val(ym); $('#zipForm [name=STAFF_SQ]').val(sqs.join(',')); $('#zipForm').submit();
		});
		$('#btnConf').on('click', openConf);
		$('#sendGo').on('click', runSend);
		$('#sendModal').on('hide.bs.modal', function(e) { if (sending) e.preventDefault(); }).on('hidden.bs.modal', load);
		$('#confTabs').on('click', '.cate-tab', function() { showConfTab($(this).attr('data-tab')); });
		$('#btnVerify').on('click', verify);
		$('#btnBody').on('click', saveBody);
		$('#btnTest').on('click', testSend);
		$('#btnDefault').on('click', function() { bootbox.confirm('제목과 내용을 처음 기본 문구로 바꿀까요? 저장을 눌러야 반영됩니다.', function(ok) { if (ok) setBody(conf.DEFAULT_SUBJECT, conf.DEFAULT_BODY); }); });
		$('#cSubject, #cFromNm, #cFromAddr, #cContact').on('input', paintPreview);
		$('#confModal').on('hidden.bs.modal', function() { clearInterval(pvTimer); load(); });
		$('#pageTabs').on('click', '.cate-tab', function() { showPage($(this).attr('data-tab')); });
		$('#btnTaxXl').on('click', function() { window.open('/admin/payslip/taxExcel.do?YM=' + ym, '_blank'); });
		$('#btnTaxSave').on('click', saveTax);
		$('#btnTaxSend').on('click', sendTax);
		$('#btnTaxDefault').on('click', function() { $('#tSubject').val(taxConf.DEFAULT_SUBJECT); $('#tBody').val(htmlText(taxConf.DEFAULT_BODY)); $('#tSaved').text('저장을 눌러야 반영됩니다'); });
		showPage((function() { try { return localStorage.getItem('payslipPage'); } catch (e) { return null; } })() === 'tax' ? 'tax' : 'slip');
		load();
	});

	// ── 화면 탭: 급여명세서 / 세무서 자료 ──

	var page = 'slip', taxConf = null;
	function showPage(key) {
		page = key;
		try { localStorage.setItem('payslipPage', key); } catch (e) {}
		$('#pageTabs').empty().append(hrTab('slip', '급여명세서', '', key === 'slip')).append(hrTab('tax', '세무서 자료', '', key === 'tax'));
		$('[data-page]').each(function() { $(this).prop('hidden', $(this).attr('data-page') !== key); });
		if (key === 'tax') loadTax();
	}

	function loadTax() {
		paintTaxRange();
		hrPost('/admin/payslip/taxConfData.do', {}, function(res) {
			taxConf = res.result;
			$('#tTo').val((taxConf.TO_ADDR || '').split(', ').join('\n'));
			$('#tSubject').val(taxConf.SUBJECT);
			$('#tBody').val(htmlText(taxConf.BODY));
			$('#tSaved').text(taxConf.REG_DT ? '저장 ' + taxConf.REG_DT : '아직 저장 전 (기본 문구)');
			$('#tVars').empty().append(taxConf.VARS.map(function(v) { return $('<button type="button" class="ps-var">').text('{' + v + '}').on('click', function() { insertAt($('#tBody')[0], '{' + v + '}'); }); }));
			var $l = $('#taxLogs').empty();
			taxConf.logs.forEach(function(x) {
				$l.append($('<tr>').append($('<td>').text(x.REG_DT)).append($('<td>').text(x.EMPLY_NM || '')).append($('<td>').text(dpYmLabel(x.PAY_YM))).append($('<td>').text(x.TO_ADDR || ''))
					.append($('<td>').append($('<span class="dp-pill">').addClass(x.RESULT === 'OK' ? 'ok' : 'bad').text(x.RESULT === 'OK' ? '보냄' : '실패')).append(x.ERROR_MSG ? document.createTextNode(' ' + x.ERROR_MSG) : '')));
			});
			if (!taxConf.logs.length) boEmpty($l, '보낸 적이 없습니다.');
			paintTaxRange();
		});
	}

	function paintTaxRange() {
		var y = ym.substring(0, 4), m = Number(ym.substring(5));
		$('#taxRange').empty().append($('<b>').text(y + '년 1월 ~ ' + m + '월')).append(document.createTextNode(' · 달마다 시트(최근 달이 앞) · 전월과 달라진 칸은 노란색, 신규·퇴사·기본급 변경·수습 종료는 기타 칸에 적습니다'));
		var note = !monthClosed ? dpYmLabel(ym) + '은 아직 작성중이라 보낼 수 없습니다(내려받기는 지금 값으로 됩니다).' : taxConf && !taxConf.ready ? '⚙ 보내는 메일 설정에서 Gmail 연결 확인을 먼저 해 주세요.' : '';
		$('#taxNote').prop('hidden', !note).text(note);
		$('#btnTaxSend').prop('disabled', !monthClosed || !(taxConf && taxConf.ready));
	}

	// 내용 칸은 글로 고치고, 저장할 때 HTML 로 바꾼다
	function htmlText(html) {
		return $('<div>').html(String(html || '').replace(/<br\s*\/?>/gi, '\n').replace(/<\/p>\s*/gi, '\n\n')).text().replace(/\n{3,}/g, '\n\n').trim();
	}
	function textHtml(t) {
		return t.trim().split(/\n{2,}/).map(function(p) { return '<p>' + dpEsc(p).replace(/\n/g, '<br>') + '</p>'; }).join('');
	}
	function insertAt(el, v) {
		var s = el.selectionStart === null ? el.value.length : el.selectionStart;
		el.value = el.value.substring(0, s) + v + el.value.substring(el.selectionEnd === null ? s : el.selectionEnd);
		el.focus(); el.setSelectionRange(s + v.length, s + v.length);
	}

	function saveTax(after, fail) {
		hrPost('/admin/payslip/saveTaxConfData.do', { TO_ADDR: $('#tTo').val(), SUBJECT: $('#tSubject').val(), BODY: textHtml($('#tBody').val()) }, function() {
			if (typeof after === 'function') after(); else { loadTax(); bootbox.alert('저장했습니다.'); }
		}, typeof fail === 'function' ? fail : undefined);
	}

	function sendTax() {
		var to = $('#tTo').val().split(/[\s,;]+/).filter(Boolean);
		bootbox.confirm({ title: dpYmLabel(ym) + ' 세무서 자료 보내기', message: $('<div>').append($('<div>').text('받는 곳: ' + to.join(', '))).append($('<div>').text('첨부: ' + ym.substring(0, 4) + '년 1월~' + Number(ym.substring(5)) + '월 급여 엑셀 (주민번호 전체가 들어 있습니다)')).append('<div class="small text-muted mt-1">지금 화면의 주소·문구를 저장한 뒤 보냅니다.</div>').html(),
			callback: function(ok) {
				if (!ok) return;
				var $b = $('#btnTaxSend').prop('disabled', true).text('보내는 중…');
				function done() { $b.text('📧 세무서로 보내기'); loadTax(); }
				saveTax(function() {
					hrPost('/admin/payslip/sendTaxData.do', { YM: ym }, function(res) { done(); bootbox.alert(res.result + ' 로 보냈습니다.'); }, done);
				}, done);
			} });
	}

	function chipOf(type) { var c = TYPES.filter(function(c) { return c[2].indexOf(type) >= 0; })[0]; return c ? c[0] : 'BIZ'; }
	function typesOf(r) { var t = (r.TYPES || []).filter(Boolean); return t.length ? t : [r.EMP_TYPE_CD]; }
	function sentOf(r) { return r.LAST ? r.LAST.RESULT : 'NONE'; }
	function typeText(r) { var t = typesOf(r); return t.indexOf('REGULAR') >= 0 || t.indexOf('PROBATION') >= 0 ? '정규' + (t.length > 1 && t.some(function(x) { return x !== 'REGULAR' && x !== 'PROBATION'; }) ? ' 외' : '') : TYPE_NM[t[0]] || t[0] || ''; }

	function load() {
		hrPost('/admin/payslip/listData.do', { YM: ym }, function(res) {
			rows = res.result.rows; monthClosed = res.result.closed; ready = res.result.ready; secretViewer = res.result.secretViewer;
			$('#payDt').text('지급일자 ' + (res.result.PAY_DT || ''));
			render();
			if (page === 'tax') paintTaxRange();
		});
	}

	function visible(r) {
		if (r.SECRET && !checked._SECRET) return false;
		return checked[sentOf(r)] && typesOf(r).some(function(t) { return checked[chipOf(t)]; });
	}
	var SORT = { TYPE: typeText, HAS_BIRTH: function(r) { return r.HAS_BIRTH ? 1 : 0; }, LAST: function(r) { return r.LAST ? r.LAST.REG_DT : ''; } };
	function shown() {
		return rows.filter(visible).sort(function(a, b) {
			var x = SORT[sortKey] ? SORT[sortKey](a) : a[sortKey], y = SORT[sortKey] ? SORT[sortKey](b) : b[sortKey];
			x = x === undefined || x === null ? '' : x; y = y === undefined || y === null ? '' : y;
			return (b.SECRET ? 1 : 0) - (a.SECRET ? 1 : 0) || sortDir * (typeof x === 'number' && typeof y === 'number' ? x - y : String(x).localeCompare(String(y), 'ko', { numeric: true }));
		});
	}
	function pickedRows() { return rows.filter(function(r) { return picked[r.STAFF_SQ] && visible(r); }); }

	function render() {
		$('#status').text(monthClosed ? '마감' : '작성중').attr('class', 'dp-pill ' + (monthClosed ? 'ok' : 'warn'));
		var note = !monthClosed ? dpYmLabel(ym) + '은 아직 작성중입니다. 급여관리에서 마감한 뒤 보낼 수 있습니다(미리보기는 됩니다).' : !ready ? '보내는 메일 설정이 필요합니다. ⚙ 보내는 메일 설정에서 Gmail 계정을 넣고 연결 확인을 해 주세요.' : '';
		$('#note').prop('hidden', !note).text(note);
		renderChips();
		var list = shown(), $h = $('<tr>').append($('<th>').append($('<input type="checkbox" id="pickAll">').attr('aria-label', '보이는 사람 전체 선택').prop('checked', list.length > 0 && list.every(function(r) { return picked[r.STAFF_SQ]; }))));
		[['성명', 'STAFF_NM'], ['형태', 'TYPE'], ['프로젝트', 'PRJ'], ['지급계', 'PAY_TOTAL', 'dp-num'], ['공제계', 'DED_TOTAL', 'dp-num'], ['실지급', 'NET', 'dp-num'], ['생년월일(암호)', 'HAS_BIRTH'], ['받는 메일', 'EMAIL'], ['발송', 'LAST']].forEach(function(c) {
			var on = sortKey === c[1];
			$h.append($('<th>').addClass(c[2] || '').text(c[0]).append($('<button type="button" class="pl-sort">').toggleClass('on', on).attr('aria-label', c[0] + ' 정렬').text(on ? (sortDir > 0 ? '▲' : '▼') : '↕')
				.on('click', function() { if (sortKey === c[1]) sortDir = -sortDir; else { sortKey = c[1]; sortDir = 1; } render(); })));
		});
		$('#psHead').empty().append($h.append('<th>명세서</th>'));
		var $b = $('#psBody').empty();
		if (!list.length) boEmpty($b, '해당하는 급여가 없습니다. 체크나 달을 바꿔 보세요.');
		list.forEach(function(r) {
			$b.append($('<tr>').toggleClass('ps-secret', !!r.SECRET)
				.append($('<td>').append($('<input type="checkbox" class="ps-chk">').val(r.STAFF_SQ).prop('checked', !!picked[r.STAFF_SQ]).attr('aria-label', r.STAFF_NM + ' 선택')))
				.append($('<td>').append(r.SECRET ? $('<span title="시크릿">').text('🔒 ') : '').append($('<b>').text(r.STAFF_NM)))
				.append($('<td>').text(typeText(r))).append($('<td class="ps-prj">').text(r.PRJ || '').attr('title', r.PRJ || ''))
				.append($('<td class="dp-num">').text(dpWon(r.PAY_TOTAL))).append($('<td class="dp-num">').text(dpWon(r.DED_TOTAL))).append($('<td class="dp-num font-weight-bold">').text(dpWon(r.NET)))
				.append($('<td>').append(r.HAS_BIRTH ? $('<span class="dp-pill ok">').text('●●●●●●●● 있음') : $('<span class="dp-pill bad" title="인사카드에 주민번호를 넣어야 암호를 걸 수 있습니다">').text('주민번호 없음')))
				.append($('<td>').append(r.EMAIL ? document.createTextNode(r.EMAIL) : $('<span class="dp-pill bad" title="인사카드의 개인 메일">').text('없음')))
				.append($('<td>').append(lastPill(r)))
				.append($('<td>').append($('<a class="btn btn-sm btn-outline-secondary py-0" target="_blank" rel="noopener">').attr({ href: '/admin/payslip/preview.do?YM=' + ym + '&STAFF_SQ=' + r.STAFF_SQ, 'aria-label': r.STAFF_NM + ' 명세서 미리보기' }).text('👁 미리보기'))));
		});
		paintBar();
	}

	function renderChips() {
		var chips = secretViewer ? [{ k: '_SECRET', name: '🔒 시크릿', cls: 'secret', n: rows.filter(function(r) { return r.SECRET; }).length }] : [];
		TYPES.forEach(function(c) { chips.push({ k: c[0], name: c[1], n: rows.filter(function(r) { return typesOf(r).some(function(t) { return chipOf(t) === c[0]; }); }).length }); });
		chips.push('<span class="pl-sep" aria-hidden="true"></span>');
		SENT.forEach(function(c) { chips.push({ k: c[0], name: c[1], n: rows.filter(function(r) { return sentOf(r) === c[0]; }).length }); });
		boChips('#chks', chips, checked, render);
	}

	function paintBar() {
		var n = pickedRows().length;
		$('#pickCount').text(n + '명 선택');
		$('#btnMail').prop('disabled', !n || !monthClosed || !ready).attr('title', !monthClosed ? '마감된 달만 보낼 수 있습니다' : !ready ? '보내는 메일 설정이 필요합니다' : '');
		$('#btnZip').prop('disabled', !n || !monthClosed).attr('title', monthClosed ? '' : '마감된 달만 내려받을 수 있습니다');
	}

	// 발송 칸: 마지막 발송 결과. 누르면 그 사람의 발송 이력
	function lastPill(r) {
		var l = r.LAST, $p = $('<button type="button" class="dp-pill ps-log">').addClass(!l ? '' : l.RESULT === 'OK' ? 'ok' : 'bad').text(!l ? '미발송' : (l.RESULT === 'OK' ? '📧 ' : '📧 실패 ') + l.REG_DT)
			.attr('aria-label', r.STAFF_NM + ' 발송 이력');
		return $p.on('click', function() {
			hrPost('/admin/payslip/logData.do', { YM: ym, STAFF_SQ: r.STAFF_SQ }, function(res) {
				var $t = $('<table class="table table-sm cal-table mb-0">').append('<thead><tr><th>일시</th><th>누가</th><th>받는 메일</th><th>결과</th></tr></thead>'), $b = $('<tbody>').appendTo($t);
				res.result.forEach(function(x) {
					$b.append($('<tr>').append($('<td>').text(x.REG_DT)).append($('<td>').text(x.EMPLY_NM || '')).append($('<td>').text(x.TO_ADDR || '—'))
						.append($('<td>').append($('<span class="dp-pill">').addClass(x.RESULT === 'OK' ? 'ok' : 'bad').text(x.RESULT === 'OK' ? '보냄' : '실패')).append(x.ERROR_MSG ? document.createTextNode(' ' + x.ERROR_MSG) : '')));
				});
				if (!res.result.length) boEmpty($b, '보낸 적이 없습니다.');
				dpInfo(r.STAFF_NM + ' · ' + dpYmLabel(ym) + ' 명세서 발송 이력', $('<div class="table-responsive">').append($t));
			});
		});
	}

	// ── 보내기: 한 명씩 이어서 보내고 결과를 줄마다 보인다 ──

	var sendQueue = [];
	function openSend() {
		var all = pickedRows(), skip = [], again = 0;
		sendQueue = all.filter(function(r) {
			var why = !r.HAS_BIRTH ? '주민번호(생년월일) 없음' : !r.EMAIL ? '개인 메일 없음' : '';
			if (why) skip.push([r, why]); else if (sentOf(r) === 'OK') again++;
			return !why;
		});
		$('#sendTitle').text(dpYmLabel(ym) + ' 급여명세서 메일 보내기');
		$('#sendSummary').empty().append($('<div>').append($('<b>').text(sendQueue.length + '명')).append(' 에게 보냅니다. ').append(skip.length ? $('<span class="dp-pill bad">').text(skip.length + '명 빠짐') : '')
			.append(again ? $('<span class="dp-pill warn">').text('이미 보낸 사람 ' + again + '명 포함 (다시 보냄)') : ''))
			.append('<div class="small text-muted">첨부: 사람별 PDF 1개 · 여는 암호는 그 사람의 생년월일 8자리</div>');
		var $l = $('#sendList').empty();
		sendQueue.forEach(function(r) { $l.append($('<tr>').attr('data-sq', r.STAFF_SQ).append($('<td>').text(r.STAFF_NM)).append($('<td>').text(r.EMAIL)).append($('<td class="res">').append('<span class="dp-pill">대기</span>'))); });
		skip.forEach(function(x) { $l.append($('<tr class="text-muted">').append($('<td>').text(x[0].STAFF_NM)).append($('<td>').text(x[0].EMAIL || '—')).append($('<td>').append($('<span class="dp-pill bad">').text('빠짐 · ' + x[1])))); });
		$('#sendGo').text(sendQueue.length + '명에게 보내기').prop('disabled', !sendQueue.length).show();
		$('#sendClose').text('취소');
		$('#sendProgress').text('');
		$('#sendModal').modal('show');
	}

	function runSend() {
		var queue = sendQueue.slice(), ok = 0, fail = [], total = queue.length;
		sending = true;
		$('#sendGo, #sendClose').prop('disabled', true);
		function result(r, good, msg) {
			$('#sendList tr[data-sq=' + r.STAFF_SQ + '] .res').empty().append($('<span class="dp-pill">').addClass(good ? 'ok' : 'bad').text(good ? '보냄' : '실패')).append(msg ? document.createTextNode(' ' + msg) : '');
			if (good) ok++; else fail.push(r);
		}
		function next() {
			var r = queue.shift();
			if (!r) {
				sending = false;
				sendQueue = fail;
				$('#sendProgress').text('끝 · 보냄 ' + ok + ' · 실패 ' + fail.length);
				$('#sendClose').prop('disabled', false).text('닫기');
				$('#sendGo').prop('disabled', !fail.length).text('실패한 ' + fail.length + '명 다시 보내기').toggle(fail.length > 0);
				return;
			}
			$('#sendProgress').text('보내는 중 ' + (total - queue.length) + ' / ' + total);
			$('#sendList tr[data-sq=' + r.STAFF_SQ + '] .res').html('<span class="dp-pill warn">보내는 중…</span>');
			$.post('/admin/payslip/sendData.do', { YM: ym, STAFF_SQ: r.STAFF_SQ }).done(function(res) {
				if (res && res.result) result(r, res.result.RESULT === 'OK', res.result.MSG); else result(r, false, (res && res.error) || '응답을 읽지 못했습니다');
				// 설정·마감 문제처럼 모두에게 같은 오류면 더 보내지 않는다
				if (res && res.error) { queue.forEach(function(x) { result(x, false, '보내지 않음'); }); queue = []; }
				next();
			}).fail(function() { result(r, false, '서버에 연결하지 못했습니다'); next(); });
		}
		next();
	}

	// ── 보내는 메일 설정 ──

	function openConf() {
		hrPost('/admin/payslip/confData.do', {}, function(res) {
			conf = res.result;
			$('#cFromNm').val(conf.FROM_NM || ''); $('#cFromAddr').val(conf.FROM_ADDR || ''); $('#cReply').val(conf.REPLY_TO || ''); $('#cBcc').val(conf.BCC || ''); $('#cContact').val(conf.CONTACT || '');
			$('#cPw').val('').attr('placeholder', conf.HAS_PW ? '저장됨 · 바꿀 때만 입력' : '앱 비밀번호 16자리').prop('required', !conf.HAS_PW);
			$('#cVars').empty().append(conf.VARS.map(function(v) { return $('<button type="button" class="ps-var">').text('{' + v + '}').on('click', function() { insertVar('{' + v + '}'); }); }));
			$('#cSubject').val(conf.SUBJECT);
			paintConf();
			showConfTab('account');
			$('#confModal').modal('show');
		});
	}

	function paintConf() {
		$('#cPwState').empty().append(conf.HAS_PW ? '<span class="dp-pill ok">저장됨</span>' : '<span class="dp-pill warn">없음</span>');
		$('#cVerified').empty().append(conf.VERIFIED_YN === 'Y' ? $('<span class="dp-pill ok">').text('연결 확인됨 · ' + (conf.VERIFIED_DT || '')) : $('<span class="dp-pill bad">').text('연결 확인 필요'));
		var $h = $('#histBody').empty();
		conf.hist.forEach(function(h) {
			var $act = $('<td>');
			if (h.KIND_CD === 'BODY') $act.append($('<button type="button" class="btn btn-sm btn-outline-secondary py-0 mr-1">이 버전 보기</button>').on('click', function() { showVersion(h); }))
				.append($('<button type="button" class="btn btn-sm btn-outline-secondary py-0">이 버전으로 되돌리기</button>').on('click', function() {
					bootbox.confirm(h.REG_DT + ' 버전의 제목·내용으로 되돌릴까요?', function(ok) { if (ok) hrPost('/admin/payslip/revertBodyData.do', { HIST_SQ: h.HIST_SQ }, reloadConf); });
				}));
			$h.append($('<tr>').append($('<td>').text(h.REG_DT)).append($('<td>').text(h.EMPLY_NM || h.EMPLY_ID)).append($('<td>').text(h.SUMMARY)).append($act));
		});
		if (!conf.hist.length) boEmpty($h, '아직 바꾼 기록이 없습니다.');
		$('#confTabs').empty().append(hrTab('account', '메일 계정', conf.VERIFIED_YN === 'Y' ? '' : '!', confTab === 'account')).append(hrTab('body', '메일 내용', '', confTab === 'body'))
			.append(hrTab('hist', '설정 이력', conf.hist.length || '', confTab === 'hist'));
	}

	function reloadConf(after) {
		hrPost('/admin/payslip/confData.do', {}, function(res) {
			var keep = confTab;
			conf = res.result;
			paintConf();
			if (keep === 'body') { $('#cSubject').val(conf.SUBJECT); setEditor(conf.BODY); }
			if (typeof after === 'function') after();
		});
	}

	function showConfTab(key) {
		confTab = key;
		$('#confModal [data-pane]').each(function() { $(this).prop('hidden', $(this).attr('data-pane') !== key); });
		$('#confTabs .cate-tab').each(function() { var on = $(this).attr('data-tab') === key; $(this).toggleClass('active', on).attr('aria-selected', on); });
		clearInterval(pvTimer);
		if (key !== 'body') return;
		// iframe 에디터는 보이는 상태에서 만들어야 크기가 맞는다
		if (oEditors.getById && oEditors.getById.psEditor) setEditor(conf.BODY);
		else nhn.husky.EZCreator.createInIFrame({ oAppRef: oEditors, elPlaceHolder: 'psEditor', sSkinURI: '/resources/navereditor/SmartEditor2Skin.html',
			htParams: { bUseToolbar: true, bUseVerticalResizer: true, bUseModeChanger: true, fOnBeforeUnload: function() {} },
			fOnAppLoad: function() { editorReady = true; setEditor(conf.BODY); }, fCreator: 'createSEditor2' });
		pvTimer = setInterval(paintPreview, 1000);
		paintPreview();
	}
	$('#confModal').on('shown.bs.modal', function() { if (confTab === 'body') showConfTab('body'); });

	function setEditor(html) { if (editorReady) oEditors.getById.psEditor.exec('SET_IR', [html || '']); }
	function editorHtml() { return editorReady ? oEditors.getById.psEditor.getIR() : (conf ? conf.BODY : ''); }
	function setBody(subject, body) { $('#cSubject').val(subject); setEditor(body); paintPreview(); }

	// 값 칩: 제목 칸에 커서가 있으면 제목에, 아니면 본문 커서 자리에 넣는다
	var lastFocus = 'body';
	$('#cSubject').on('focus', function() { lastFocus = 'subject'; });
	function insertVar(v) {
		if (lastFocus === 'subject') {
			var el = $('#cSubject')[0], s = el.selectionStart === null ? el.value.length : el.selectionStart;
			el.value = el.value.substring(0, s) + v + el.value.substring(el.selectionEnd === null ? s : el.selectionEnd);
			el.focus(); el.setSelectionRange(s + v.length, s + v.length);
			lastFocus = 'body'; // 다음 칩은 다시 본문으로. 제목에 또 넣으려면 제목 칸을 누른다
		} else if (editorReady) {
			oEditors.getById.psEditor.exec('PASTE_HTML', [v]);
		}
		paintPreview();
	}

	function sampleVars() {
		return { '성명': '김예시', '귀속월': dpYmLabel(ym), '지급일자': ($('#payDt').text().replace('지급일자 ', '') || ''), '부서': '개발팀', '직급': '선임', '회사명': '주식회사 이에스티소프트', '담당자 연락처': $('#cContact').val() || '' };
	}
	function fill(t, html) {
		var v = sampleVars();
		Object.keys(v).forEach(function(k) { t = t.split('{' + k + '}').join(html ? dpEsc(v[k]) : v[k]); });
		return t;
	}
	var pvLast = '';
	function paintPreview() {
		if (!conf) return;
		$('#pvFrom').text(($('#cFromNm').val() || '주식회사 이에스티소프트') + ' <' + ($('#cFromAddr').val() || '보내는 주소 없음') + '>');
		$('#pvSubject').text(fill($('#cSubject').val() || '', false));
		$('#pvFile').text(Number(ym.substring(5)) + '월 이에스티_급여명세서_김예시.pdf');
		var html = fill(editorHtml() || '', true);
		if (html === pvLast) return;
		pvLast = html;
		// 스크립트가 돌지 않는 틀 안에서만 그린다
		$('#pvBody').attr('srcdoc', '<!doctype html><meta charset="utf-8"><body style="font:13px/1.6 \'Malgun Gothic\',sans-serif;margin:14px;color:#15191d">' + html + '</body>');
	}

	function saveAccount() {
		hrPost('/admin/payslip/saveAccountData.do', $('#accForm').serialize(), function() { $('#cPw').val(''); reloadConf(function() { $('#cPw').attr('placeholder', conf.HAS_PW ? '저장됨 · 바꿀 때만 입력' : '앱 비밀번호 16자리').prop('required', !conf.HAS_PW); }); });
	}

	function verify() {
		var $b = $('#btnVerify').prop('disabled', true).text('확인 중…');
		function done() { $b.prop('disabled', false).text('연결 확인'); reloadConf(); }
		hrPost('/admin/payslip/verifyData.do', {}, function() { done(); bootbox.alert('Gmail 연결을 확인했습니다. 이제 명세서를 보낼 수 있습니다.'); }, done);
	}

	function saveBody() {
		hrPost('/admin/payslip/saveBodyData.do', { SUBJECT: $('#cSubject').val(), BODY: editorHtml() }, function() { reloadConf(function() { bootbox.alert('메일 내용을 저장했습니다.'); }); });
	}

	function testSend() {
		var $b = $('#btnTest').prop('disabled', true).text('보내는 중…');
		function done() { $b.prop('disabled', false).text('✉ 시험 발송 (내 메일로)'); }
		hrPost('/admin/payslip/testSendData.do', { SUBJECT: $('#cSubject').val(), BODY: editorHtml() }, function(res) {
			done();
			bootbox.alert(res.result + ' 로 시험 메일을 보냈습니다. 첨부 PDF 암호는 19900101 입니다(예시 값). 지금 화면의 문구로 보냈고, 저장은 따로 눌러야 합니다.');
		}, done);
	}

	function showVersion(h) {
		hrPost('/admin/payslip/bodyVersionData.do', { HIST_SQ: h.HIST_SQ }, function(res) {
			var $f = $('<iframe sandbox title="메일 내용" style="width:100%;height:50vh;border:1px solid rgba(17,17,17,.12);border-radius:6px">')
				.attr('srcdoc', '<!doctype html><meta charset="utf-8"><body style="font:13px/1.6 \'Malgun Gothic\',sans-serif;margin:14px">' + (res.result.BODY || '') + '</body>');
			dpInfo(h.REG_DT + ' 버전', $('<div>').append($('<div class="mb-2">').append('<b>제목</b> ').append(document.createTextNode(res.result.SUBJECT || ''))).append($f));
		});
	}
	</script>
</body>
</html>
