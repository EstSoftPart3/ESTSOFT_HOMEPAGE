// 모든 bootbox 팝업: 바깥 클릭·Esc 로 닫는다. 입력칸에 뭔가 적었으면 한 번 묻고 닫는다.
// 일부러 안 닫히게 하려면 그 창에 onEscape: false 를 준다. bootbox.alert/confirm/prompt 도 dialog 를 거친다.
(function () {
	if (!window.bootbox) return;
	$(document).on('input change', '.bootbox :input', function () { $(this).closest('.bootbox').data('dirty', true); });
	var dialog = bootbox.dialog;
	bootbox.dialog = function (o) {
		if (o && typeof o === 'object' && o.onEscape !== false) {
			var own = o.onEscape;
			if (o.backdrop === undefined) o.backdrop = true;
			o.onEscape = function (e) {
				var $m = this, run = function () { return typeof own === 'function' ? own.call($m, e) : true; };
				if (!$m.data('dirty')) return run();
				bootbox.confirm('입력한 내용이 사라집니다. 닫을까요?', function (ok) {
					if (ok && run() !== false) $m.modal('hide');
				});
				return false;
			};
		}
		return dialog.apply(this, arguments);
	};
})();
