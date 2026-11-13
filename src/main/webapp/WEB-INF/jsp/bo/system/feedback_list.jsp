<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/hr/hr_common.jspf"%>
<style>
	.fl-chks { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; padding: 10px 14px; }
	.pl-chip { display: inline-flex; gap: 6px; align-items: center; padding: 4px 10px; border-radius: 999px; border: 1px solid rgba(17,17,17,.15); font-weight: 700; font-size: 12.5px; color: #444; cursor: pointer; user-select: none; margin: 0; background: #fff; }
	.pl-chip input { margin: 0; cursor: pointer; }
	.pl-chip .cnt { background: rgba(17,17,17,.08); border-radius: 999px; padding: 0 7px; font-size: 11px; }
	.pl-chip.on { border-color: #0b6e8a; background: #eef9fc; color: #0b6e8a; }
	.fl-split { display: grid; grid-template-columns: minmax(0, 1.2fr) minmax(0, 1fr); border-top: 1px solid rgba(17,17,17,.08); }
	.fl-split > div + div { border-left: 1px solid rgba(17,17,17,.08); }
	#flBody tr { cursor: pointer; } #flBody tr.sel td { background: #eef9fc; }
	.fl-detail { padding: 12px 14px; }
	.fl-detail h4 { font-size: 15px; margin: 0 0 4px; display: flex; gap: 8px; align-items: center; }
	.fl-sec { font-size: 12px; font-weight: 700; color: #5f6b75; margin: 12px 0 4px; }
	.fl-box { border: 1px solid rgba(17,17,17,.1); border-radius: 8px; padding: 8px 10px; white-space: pre-wrap; font-size: 13px; background: #fafbfc; }
	.fl-acts { display: flex; gap: 6px; justify-content: flex-end; align-items: center; margin-top: 14px; padding-top: 10px; border-top: 1px solid rgba(17,17,17,.08); }
	.fl-acts .lock { margin-right: auto; font-size: 11.5px; color: #5f6b75; }
	@media (max-width: 991px) { .fl-split { grid-template-columns: 1fr; } .fl-split > div + div { border-left: 0; border-top: 1px solid rgba(17,17,17,.08); } }
</style>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-header d-flex align-items-center">
					<h3 class="card-title bTitle"><b>피드백</b></h3>
					<span class="small text-muted ml-3">위 💬 피드백 버튼으로 남긴 글 · 평일 오전 9시 30분에 Claude 가 기획서를 붙여 '검토 대기'로 둡니다</span>
				</div>
				<div class="card-body">
					<div class="cal-panel">
						<div class="fl-chks" id="chks" aria-label="상태"></div>
						<div class="fl-split">
							<div>
								<table class="table table-sm cal-table mb-0">
									<thead><tr><th>접수</th><th>화면</th><th>종류</th><th>내용</th><th>요청자</th><th>상태</th><th>처리</th></tr></thead>
									<tbody id="flBody"></tbody>
								</table>
							</div>
							<div class="fl-detail" id="flDetail"><div class="text-muted">왼쪽에서 피드백을 고르세요.</div></div>
						</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
	<%@ include file="/WEB-INF/jsp/bo/hr/hr_script.jspf"%>
	<script>
	var data = { list: [] }, pick = null, checked = {};
	var ORDER = ['NEW', 'REVIEW', 'ING', 'DONE', 'HOLD', 'REJECT'];
	ORDER.forEach(function(s) { checked[s] = s !== 'DONE' && s !== 'REJECT'; });

	$(function() {
		load();
		$('#chks').on('change', 'input.pl-chk', function() { checked[this.value] = this.checked; render(); });
		$('#chks').on('click', '#chkAll', function() {
			var all = ORDER.every(function(s) { return checked[s]; });
			ORDER.forEach(function(s) { checked[s] = !all; });
			render();
		});
	});

	function load(keep) {
		hrPost('/admin/feedback/listData.do', {}, function(res) {
			data = res.result;
			if (!keep) { var q = /[?&]FB_SQ=(\d+)/.exec(location.search); if (q) pick = +q[1]; }
			render();
		});
	}

	function render() {
		var st = BO_FB.status(), kind = BO_FB.kind();
		var all = ORDER.every(function(s) { return checked[s]; });
		var $c = $('#chks').empty().append($('<button type="button" class="btn btn-sm btn-outline-secondary" id="chkAll">').text(all ? '☑ 전체 해제' : '☐ 전체 선택'));
		ORDER.forEach(function(s) {
			var n = data.list.filter(function(f) { return f.STATUS_CD === s; }).length;
			$c.append($('<label class="pl-chip">').toggleClass('on', !!checked[s]).append($('<input type="checkbox" class="pl-chk">').val(s).prop('checked', !!checked[s]))
				.append($('<span>').text(st[s])).append(n ? $('<span class="cnt">').text(n) : ''));
		});
		var rows = data.list.filter(function(f) { return checked[f.STATUS_CD]; }), $b = $('#flBody').empty();
		if (!rows.length) $b.append('<tr><td colspan="7" class="text-center text-muted py-4">해당하는 피드백이 없습니다.</td></tr>');
		rows.forEach(function(f) {
			$b.append($('<tr>').toggleClass('sel', f.FB_SQ === pick).on('click', function() { pick = f.FB_SQ; render(); })
				.append($('<td>').text(f.REG_DT.substr(5, 5))).append($('<td>').text(f.SCREEN_NM || '')).append($('<td>').text(kind[f.KIND_CD] || f.KIND_CD))
				.append($('<td>').append($('<span class="td-cut">').text(f.CONTENT.replace(/\s+/g, ' '))))
				.append($('<td>').text(f.EMPLY_NM || f.EMPLY_ID)).append($('<td>').append($('<span class="fb-pill">').addClass(BO_FB.tone[f.STATUS_CD] || '').text(st[f.STATUS_CD] || f.STATUS_CD)))
				.append($('<td>').text(f.ACT_NM ? f.ACT_NM + ' ' + (f.ACT_DT || '').substr(5) : '')));
		});
		detail(data.list.filter(function(f) { return f.FB_SQ === pick; })[0]);
	}

	function detail(f) {
		var $d = $('#flDetail').empty();
		if (!f) { $d.append('<div class="text-muted">왼쪽에서 피드백을 고르세요.</div>'); return; }
		var st = BO_FB.status();
		$d.append($('<h4>').text('#' + f.FB_SQ).append($('<span class="fb-pill">').addClass(BO_FB.tone[f.STATUS_CD] || '').text(st[f.STATUS_CD])));
		$d.append($('<div class="small text-muted">').text([f.EMPLY_NM || f.EMPLY_ID, f.REG_DT, f.SCREEN_NM, BO_FB.kind()[f.KIND_CD]].filter(Boolean).join(' · ')));
		$d.append('<div class="fl-sec">요청 내용</div>').append($('<div class="fl-box">').text(f.CONTENT));
		if (f.PLAN_TXT) $d.append($('<div class="fl-sec">').text('기획서 · 바꿀 것' + (f.EST_TXT ? ' (예상 ' + f.EST_TXT + ')' : ''))).append($('<div class="fl-box">').text(f.PLAN_TXT));
		if (f.HAS_SPEC == 1) $d.append($('<button type="button" class="btn btn-sm btn-outline-secondary mt-2">기획서 크게 보기</button>').on('click', function() { BO_SPEC(f.FB_SQ); }));
		else if (f.STATUS_CD === 'NEW') $d.append('<div class="small text-muted mt-2">기획서는 평일 오전 9시 30분에 만들어집니다.</div>');
		if (f.DEV_NOTE) $d.append('<div class="fl-sec">개발 반영 내용</div>').append($('<div class="fl-box">').text(f.DEV_NOTE));
		if (f.STATUS_CD === 'REJECT' && f.REJECT_REASON) $d.append('<div class="fl-sec">반려 사유</div>').append($('<div class="fl-box">').text(f.REJECT_REASON));
		if (f.STATUS_CD === 'DONE' && f.UPD_SQ) $d.append($('<button type="button" class="btn btn-sm btn-outline-primary mt-2">업데이트 내역 보기</button>').on('click', function() { BO_UPDATE(f.UPD_SQ); }));
		// 진행·보류·반려는 슈퍼관리자·시스템 운영자에게만(서버도 같은 검사)
		if (data.canAct && f.STATUS_CD !== 'DONE') {
			$d.append($('<div class="fl-acts">').append('<span class="lock">🔒 슈퍼관리자·시스템 운영자만</span>')
				.append($('<button type="button" class="btn btn-sm btn-outline-danger">반려</button>').on('click', function() { ask(f, 'REJECT', '반려 사유', '왜 진행하지 않는지 적어 주세요. 요청자의 피드백 창에 그대로 보입니다.', ''); }))
				.append($('<button type="button" class="btn btn-sm btn-outline-secondary">보류</button>').prop('disabled', f.STATUS_CD === 'HOLD').on('click', function() {
					bootbox.confirm('이 피드백을 보류할까요? 나중에 다시 진행하거나 반려할 수 있습니다.', function(ok) { if (ok) act(f, 'HOLD', ''); });
				}))
				.append($('<button type="button" class="btn btn-sm btn-primary">진행</button>').prop('disabled', f.STATUS_CD === 'ING').on('click', function() {
					ask(f, 'ING', '개발 반영 내용', '이대로 개발합니다. 기획서의 바꿀 것이 미리 채워져 있으니 더하거나 빼 주세요.', f.DEV_NOTE || f.PLAN_TXT || f.CONTENT);
				})));
		}
	}

	// 진행·반려 입력 창. 비우면 막는다(서버도 같은 검사)
	function ask(f, status, label, hint, value) {
		var $ta = $('<textarea class="form-control form-control-sm" rows="6" maxlength="4000">').attr('aria-label', label).val(value);
		bootbox.dialog({
			title: (status === 'ING' ? '진행' : '반려') + ' — ' + $('<div>').text(f.CONTENT.substring(0, 40)).html(),
			message: $('<div>').append($('<label class="small font-weight-bold">').text(label + ' *')).append($ta).append($('<div class="small text-muted mt-1">').text(hint)),
			onEscape: true, backdrop: true,
			buttons: {
				cancel: { label: '취소', className: 'btn-sm btn-outline-secondary' },
				ok: { label: status === 'ING' ? '진행' : '반려', className: 'btn-sm ' + (status === 'ING' ? 'btn-primary' : 'btn-danger'), callback: function() {
					if (!$.trim($ta.val())) { $ta.addClass('is-invalid').focus(); return false; }
					act(f, status, $ta.val());
				} }
			}
		}).on('shown.bs.modal', function() { $ta.focus(); });
	}

	function act(f, status, text) {
		hrPost('/admin/feedback/actData.do', { FB_SQ: f.FB_SQ, STATUS_CD: status, TEXT: text }, function() { load(true); });
	}
	</script>
</body>
</html>
