/*
 * 홈페이지(사용자 화면) 피드백 버튼(#foFbBtn, navbar.jspf). 로그인 안 한 사람은 이름·이메일(선택)을 함께 받는다.
 * 서버: /eep/feedback/saveData.do (BoFeedbackController.foSaveData). 관리자 화면 피드백 목록에 '홈페이지 · 화면' 으로 쌓인다.
 */
(function () {
	var KIND = { INCONV: '불편', BUG: '오류', NEW: '새 기능' };

	function open() {
		var guest = !$('#foFbBtn').is('[data-login]');
		var $kind = $('<select class="form-select form-select-sm" id="foFbKind">');
		$.each(KIND, function (k, v) { $kind.append($('<option>').val(k).text(v)); });
		var $ta = $('<textarea class="form-control form-control-sm" id="foFbText" rows="4" maxlength="4000" placeholder="무엇이 불편한지, 어떻게 되면 좋을지 적어 주세요">');
		var $name = $('<input class="form-control form-control-sm" id="foFbName" maxlength="30" autocomplete="name">');
		var $mail = $('<input type="email" class="form-control form-control-sm" id="foFbMail" maxlength="100" autocomplete="email" placeholder="답변을 받을 경우">');
		// 사람에게는 안 보이는 칸: 봇이 채우면 서버가 버린다
		var $hp = $('<input type="text" name="website" tabindex="-1" autocomplete="off" aria-hidden="true" style="position:absolute;left:-9999px;width:1px;height:1px;">');
		var $box = $('<div>')
			.append($('<div class="mb-2">').append('<label class="form-label small mb-1" for="foFbKind">종류</label>').append($kind))
			.append($('<div class="mb-2">').append('<label class="form-label small mb-1" for="foFbText">내용 *</label>').append($ta))
			.append($hp);
		if (guest) {
			$box.append($('<div class="row g-2">')
				.append($('<div class="col-sm-5">').append('<label class="form-label small mb-1" for="foFbName">이름 (선택)</label>').append($name))
				.append($('<div class="col-sm-7">').append('<label class="form-label small mb-1" for="foFbMail">이메일 (선택)</label>').append($mail)));
		}
		var dlg = bootbox.dialog({
			title: '💬 피드백', message: $box, onEscape: true, backdrop: true,
			buttons: {
				cancel: { label: '닫기', className: 'btn-sm btn-outline-secondary' },
				ok: { label: '보내기', className: 'btn-sm btn-primary', callback: function () {
					if (!$.trim($ta.val())) { $ta.focus(); return false; }
					var $btn = dlg.find('[data-bb-handler=ok]').prop('disabled', true);
					$.post('/eep/feedback/saveData.do', {
						KIND_CD: $kind.val(), CONTENT: $ta.val(), NAME: $name.val(), MAIL: $mail.val(), HP: $hp.val(),
						SCREEN_NM: document.title, SCREEN_URL: location.pathname
					}).done(function (res) {
						if (res.error) { $btn.prop('disabled', false); bootbox.alert(res.error); return; }
						dlg.modal('hide');
						bootbox.alert('보내 주셔서 감사합니다. 확인 후 반영하겠습니다.');
					}).fail(function () { $btn.prop('disabled', false); bootbox.alert('보내지 못했습니다. 잠시 뒤 다시 시도해 주세요.'); });
					return false;
				} }
			}
		});
		dlg.on('shown.bs.modal', function () { $ta.focus(); });
	}

	$(document).on('click', '#foFbBtn', function (e) { e.preventDefault(); open(); });
})();
