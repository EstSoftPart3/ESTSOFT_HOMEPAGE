<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/board/board_style.jspf"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_open.jspf"%>
				<div class="card-body">
					<nav class="brd-crumb" aria-label="경로"><a href="/admin/board/openBoardManage.do">게시판 관리</a> › <a id="crumbBoard" href="#"></a> › <b id="crumbMode"></b></nav>

					<form class="cal-panel" id="form" novalidate
						data-emply-sq="<c:out value="${loginInfo.loginInfo[0].emplySq}"/>" data-emply-nm="<c:out value="${loginInfo.loginInfo[0].emplyNm}"/>">
						<header class="brd-head"><h2 class="brd-title mb-0" id="heading"></h2></header>

						<details class="brd-quote" id="quote" hidden>
							<summary><b>원글</b> · <span id="quoteTitle"></span></summary>
							<iframe class="brd-body" id="quoteBody" title="원글 본문" sandbox="allow-same-origin allow-popups allow-popups-to-escape-sandbox"></iframe>
						</details>

						<div class="brd-form">
							<div class="form-group">
								<label for="brdTtl">제목</label>
								<input type="text" class="form-control form-control-sm" id="brdTtl" maxlength="200" required>
							</div>
							<div class="form-group" id="eduRow" hidden>
								<label for="brdTchr">강사 · 교육일</label>
								<div class="form-row">
									<div class="col-sm-6 mb-1"><input type="text" class="form-control form-control-sm" id="brdTchr" placeholder="강사" aria-label="강사"></div>
									<div class="col-sm-6 mb-1"><input type="date" class="form-control form-control-sm" id="brdEduDt" aria-label="교육일"></div>
								</div>
							</div>
							<div class="form-group">
								<span class="small font-weight-bold text-secondary">공개</span>
								<div class="d-flex flex-wrap" style="gap: 24px;">
									<div class="custom-control custom-switch">
										<input type="checkbox" class="custom-control-input" id="useYn" checked>
										<label class="custom-control-label" for="useYn">사용</label>
									</div>
									<div class="custom-control custom-switch" id="delRow" hidden>
										<input type="checkbox" class="custom-control-input" id="delYn">
										<label class="custom-control-label" for="delYn">삭제됨 <span class="text-muted small">(끄면 되살립니다)</span></label>
									</div>
								</div>
							</div>
							<div class="form-group top">
								<label for="naverEditor">내용</label>
								<div><textarea rows="20" cols="40" id="naverEditor" style="width: 100%;"></textarea></div>
							</div>
						</div>

						<footer class="brd-bar sticky">
							<a class="btn btn-sm btn-outline-secondary" id="btnCancel" href="#">취소</a>
							<span class="mr-auto"></span>
							<span class="small text-muted mr-2" id="writer"></span>
							<button type="submit" class="btn btn-sm btn-primary" id="btnSave"><i class="fas fa-check"></i> 저장</button>
						</footer>
					</form>
				</div>
			<%@ include file="/WEB-INF/jsp/bo/boinclude/page_close.jspf"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/board/board_common.jspf"%>
<script>
	var B = boardOf('<c:out value="${board}"/>'), MODE = '<c:out value="${mode}"/>', brdSq = boardParam('brdSq');
	var $form = $('#form'), oEditors = [], editorReady = $.Deferred(), parent = null, saved = '', saving = false;
	// 기존 화면처럼 교육일정은 로그인한 직원 이름, 나머지는 「관리자」로 쓴다
	var writer = B.key === 'education' ? $form.data('emplyNm') : '관리자';
	var backUrl = MODE === 'write' ? boardUrl(B.key, 'List') : boardUrl(B.key, 'Detail') + '?brdSq=' + encodeURIComponent(brdSq);

	$('#crumbBoard').text(B.name).attr('href', boardUrl(B.key, 'List'));
	$('#crumbMode').text({ write: '새 글 쓰기', edit: '글 수정', reply: '답글 쓰기' }[MODE]);
	$('#heading').text(B.name + ' · ' + $('#crumbMode').text());
	$('#eduRow').prop('hidden', !B.extra);
	$('#delRow').prop('hidden', MODE !== 'edit');
	$('#writer').text(MODE === 'edit' ? '' : '작성자: ' + writer);
	$('#btnCancel').attr('href', backUrl);

	nhn.husky.EZCreator.createInIFrame({
		oAppRef: oEditors, elPlaceHolder: 'naverEditor', sSkinURI: '/resources/navereditor/SmartEditor2Skin.html',
		htParams: { bUseToolbar: true, bUseVerticalResizer: true, bUseModeChanger: true, fOnBeforeUnload: function() {} },
		fOnAppLoad: function() { editorReady.resolve(); }, fCreator: 'createSEditor2'
	});
	function editorHtml() { return oEditors.getById ? oEditors.getById.naverEditor.getIR() : ''; }
	function snapshot() { return JSON.stringify([$('#brdTtl').val(), $('#brdTchr').val(), $('#brdEduDt').val(), $('#useYn').prop('checked'), $('#delYn').prop('checked'), editorHtml()]); }

	function fail(msg) { bootbox.alert(msg || '처리하지 못했습니다. 다시 로그인한 뒤 시도해 주세요.'); }

	function loadDetail() {
		return $.post(boardData(B.key, 'DetailData'), { brdSq: brdSq }, null, 'json').then(function(res) {
			return ((res[B.key + 'BoardDetailData'] || {})[B.key + 'BoardDetailData'] || [])[0];
		});
	}

	if (MODE === 'write') {
		editorReady.done(function() { saved = snapshot(); $('#brdTtl').focus(); });
	} else {
		loadDetail().done(function(r) {
			if (!r) { fail('글을 찾을 수 없습니다.'); return; }
			if (MODE === 'reply') {
				parent = r;
				$('#quoteTitle').text(r.brdTtl + ' — ' + r.brdWrtr + ' · ' + (r.brdRegDt || '').substring(0, 10));
				$('#quote').prop('hidden', false).on('toggle', function() { boardFit(document.getElementById('quoteBody')); });
				boardFrame(document.getElementById('quoteBody'), boardHtml(r.brdCntnt));
				$('#brdTtl').val('RE: ' + r.brdTtl.replace(/^(RE:\s*)+/i, ''));
				editorReady.done(function() { saved = snapshot(); });
				return;
			}
			$('#brdTtl').val(r.brdTtl);
			$('#brdTchr').val(r.brdTchr);
			$('#brdEduDt').val((r.brdEduDt || '').substring(0, 10));
			$('#useYn').prop('checked', r.useYn !== 'N');
			$('#delYn').prop('checked', r.delYn === 'Y');
			editorReady.done(function() {
				oEditors.getById.naverEditor.exec('SET_IR', ['']);
				oEditors.getById.naverEditor.exec('PASTE_HTML', [boardHtml(r.brdCntnt)]);
				saved = snapshot();
			});
		}).fail(function() { fail(); });
	}

	// 삭제됨을 켜면 사용도 끈다(삭제 처리와 같은 상태)
	$('#delYn').on('change', function() { if (this.checked) $('#useYn').prop('checked', false); });

	$('#btnCancel').on('click', function(e) {
		if (snapshot() === saved) return;
		e.preventDefault();
		bootbox.confirm({ message: '저장하지 않은 내용이 있습니다. 나갈까요?', locale: 'kr', buttons: { confirm: { label: '나가기' }, cancel: { label: '계속 쓰기' } },
			callback: function(ok) { if (ok) { saved = snapshot(); location.href = backUrl; } } });
	});
	window.addEventListener('beforeunload', function(e) { if (!saving && saved && snapshot() !== saved) { e.preventDefault(); e.returnValue = ''; } });

	function need(sel, msg) { bootbox.alert({ message: msg, locale: 'kr', callback: function() { $(sel).focus(); } }); return false; }

	$form.on('submit', function(e) {
		e.preventDefault();
		if (saving) return;
		oEditors.getById.naverEditor.exec('UPDATE_CONTENTS_FIELD', []);
		var html = $('#naverEditor').val();
		var d = { brdTtl: $.trim($('#brdTtl').val()), brdCntnt: html, useYn: $('#useYn').prop('checked') ? 'Y' : 'N' };
		if (!d.brdTtl) return need('#brdTtl', '제목을 입력해 주세요.');
		if (B.extra) {
			d.brdTchr = $.trim($('#brdTchr').val()); d.brdEduDt = $('#brdEduDt').val();
			if (!d.brdTchr) return need('#brdTchr', '강사를 입력해 주세요.');
			if (!d.brdEduDt) return need('#brdEduDt', '교육일을 입력해 주세요.');
		}
		if (!$.trim(boardPlain(html).replace(/ /g, ' ')) && !/<img/i.test(html)) return bootbox.alert('내용을 입력해 주세요.');

		var act = { write: 'InsertData', edit: 'UpdateData', reply: 'ReplyInsertData' }[MODE], next;
		if (MODE === 'edit') {
			$.extend(d, { brdSq: brdSq, delYn: $('#delYn').prop('checked') ? 'Y' : 'N' });
			next = backUrl;
		} else {
			$.extend(d, { emplySq: $form.data('emplySq'), brdTypCd: { notice: 'NT', freedom: 'FD', technology: 'TL', education: 'ED' }[B.key], brdWrtr: writer });
			if (MODE === 'reply') $.extend(d, { brdReRep: parent.brdReRep, brdReLev: parent.brdReLev, brdReOrd: parent.brdReOrd });
			next = backUrl; // 새 글은 목록, 답글은 원글 상세(답글 목록이 보인다)
		}
		saving = true;
		$('#btnSave').prop('disabled', true).html('<span class="spinner-border spinner-border-sm"></span> 저장 중');
		$.post(boardData(B.key, act), d).done(function() { location.href = next; })
			.fail(function() { saving = false; $('#btnSave').prop('disabled', false).html('<i class="fas fa-check"></i> 저장'); fail('저장하지 못했습니다. 내용이 너무 길거나 로그인이 끊겼을 수 있습니다.'); });
	});
</script>
</body>
</html>
