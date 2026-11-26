/**
 * 직원 휴가: 인사카드 휴가 탭(vacTab)과 홈 캘린더 「＋ 휴가」(vacForm)가 같이 쓴다. jQuery·bootbox 필요.
 * 서버: /admin/staff/vacationData.do · saveVacationData.do · deleteVacationData.do · vacationRangeData.do (StaffVacationService)
 * 휴가 줄: { VAC_SQ, STAFF_SQ, START_DT, END_DT(비면 기간 미정), HALF_CD(AM·PM), VAC_CD, PAID_YN, MEMO, SRC_CD(USER·EXCEL), DAYS }
 */
(function() {
	// 종류: 공통코드 HR_VAC_TYPE 이 있으면 그것, 없으면 기본값(StaffVacationService.TYPES 와 같게). 세 번째는 기본 유급 여부
	var DEF = [['ANNUAL', '연차', 'Y'], ['HALF', '반차', 'Y'], ['SICK', '병가', 'Y'], ['FAMILY', '경조', 'Y'], ['PERSONAL', '개인사유', 'N'],
		['MATERNITY', '출산휴가', 'Y'], ['PARENTAL', '육아휴직', 'N'], ['LEAVE', '무급휴직', 'N'], ['ETC', '기타', 'N']];
	function types() {
		var codes = typeof hrAllCodes === 'function' ? hrAllCodes('HR_VAC_TYPE') : [];
		if (!codes.length) return DEF;
		return codes.map(function(c) { var d = DEF.filter(function(x) { return x[0] === c.CD; })[0]; return [c.CD, c.NM, d ? d[2] : 'N']; });
	}
	function typeName(cd) { var t = types().filter(function(x) { return x[0] === cd; })[0]; return t ? t[1] : cd; }
	window.vacTypeName = typeName;

	function today() { var d = new Date(); return d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2); }
	function addDays(ymd, n) { var d = new Date(ymd + 'T00:00:00'); d.setDate(d.getDate() + n); return d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2); }
	function md(ymd) { return ymd ? ymd.substr(5).replace('-', '.') : ''; }
	// 기간 글: 반차는 「11.13 오후」, 기간 미정은 「~ 오늘(기간 미정)」
	function period(v) {
		if (v.HALF_CD) return v.START_DT + ' ' + (v.HALF_CD === 'AM' ? '오전' : '오후');
		return v.START_DT + ' ~ ' + (v.END_DT ? (v.END_DT.substr(0, 4) === v.START_DT.substr(0, 4) ? v.END_DT.substr(5) : v.END_DT) : '오늘(기간 미정)');
	}
	window.vacPeriod = period;
	function daysText(n) { return (Math.round(n * 10) / 10) + '일'; }
	function pill(paid) { return $('<span class="vc-pill">').addClass(paid === 'Y' ? 'paid' : 'unpaid').text(paid === 'Y' ? '유급' : '무급'); }
	window.vacPill = pill;

	function post(url, data, ok) {
		$.post(url, data).done(function(res) {
			if (res && res.error) { bootbox.alert(res.error); return; }
			ok(res);
		}).fail(function() { bootbox.alert('저장하지 못했습니다. 잠시 뒤 다시 해 주세요.'); });
	}

	/**
	 * 등록·수정 창. o: { staff: {STAFF_SQ, STAFF_NM} 이 없으면 직원 고르는 칸이 나온다, vac: 고칠 휴가, start, end, saved(): 저장 뒤 }
	 */
	window.vacForm = function(o) {
		var v = o.vac || {}, half = v.HALF_CD || '', isHalf = !!half || v.VAC_CD === 'HALF';
		var $f = $('<div class="vc-form">');
		var staffSq = o.staff ? o.staff.STAFF_SQ : v.STAFF_SQ;
		if (!o.staff && !v.VAC_SQ) {
			var $who = $('<input type="text" class="form-control form-control-sm" list="vcStaffList" placeholder="이름을 입력해 고르세요" aria-label="직원">');
			var $dl = $('<datalist id="vcStaffList">');
			$f.append(row('직원', $('<div>').append($who).append($dl)));
			$.post('/admin/staff/staffListData.do').done(function(res) {
				var list = (res.list || []).slice().sort(function(a, b) { return (a.STATUS_CD === 'WORK' ? 0 : 1) - (b.STATUS_CD === 'WORK' ? 0 : 1) || String(a.STAFF_NM).localeCompare(b.STAFF_NM); });
				list.forEach(function(r) { $dl.append($('<option>').val(r.STAFF_NM + ' · ' + (r.ORG_NM || '') + (r.STATUS_CD === 'WORK' ? '' : ' (' + (r.STATUS_CD === 'LEFT' ? '퇴사' : '대기') + ')') + ' #' + r.STAFF_SQ)); });
			});
			$who.on('change input', function() { var m = /#(\d+)$/.exec(this.value); staffSq = m ? m[1] : null; });
		}
		var $s = $('<input type="date" class="form-control form-control-sm vc-d" aria-label="시작일">').val(v.START_DT || o.start || today());
		var $e = $('<input type="date" class="form-control form-control-sm vc-d" aria-label="종료일">').val(v.END_DT || o.end || o.start || today());
		var $open = $('<label class="vc-open"><input type="checkbox"> 기간 미정</label>');
		$open.find('input').prop('checked', !!v.VAC_SQ && !v.END_DT && !v.HALF_CD);
		var $half = $('<select class="form-control form-control-sm vc-half" aria-label="반차 오전·오후"><option value="AM">오전</option><option value="PM">오후</option></select>').val(half || 'AM');
		var $days = $('<b class="vc-days">');
		$f.append(row('기간', $('<div class="vc-per">').append($s).append(' ~ ').append($e).append($half).append($open).append($days)));
		var $types = $('<div class="vc-types">');
		types().forEach(function(t) { $types.append($('<button type="button" class="vc-chip">').attr({ 'data-v': t[0], 'data-paid': t[2], 'aria-pressed': false }).text(t[1])); });
		$f.append(row('종류', $types));
		var $paid = $('<div class="vc-seg"><button type="button" data-v="Y">유급</button><button type="button" data-v="N">무급</button></div>');
		$f.append(row('구분', $('<div>').append($paid).append('<small class="vc-hint">무급은 급여관리 일할에서 빠져요(마감 전 달)</small>')));
		var $memo = $('<textarea class="form-control form-control-sm" rows="2" maxlength="1000" placeholder="사유·참고" aria-label="메모">').val(v.MEMO || '');
		$f.append(row('메모', $memo));
		if (v.SRC_CD === 'EXCEL') $f.append('<div class="vc-note">엑셀(투입현황·급여관리)에서 옮긴 휴가예요. 이미 급여에 반영된 기록이라 무급이어도 급여를 다시 깎지 않아요.</div>');

		var cd = v.VAC_CD || (isHalf ? 'HALF' : 'ANNUAL'), paid = v.PAID_YN || null;
		function pickType(c, keepPaid) {
			cd = c;
			$types.children().each(function() { var on = $(this).attr('data-v') === c; $(this).toggleClass('on', on).attr('aria-pressed', on); });
			if (!keepPaid) setPaid($types.children('[data-v="' + c + '"]').attr('data-paid') || 'Y');
			sync();
		}
		function setPaid(p) { paid = p; $paid.children().each(function() { $(this).toggleClass('on', $(this).attr('data-v') === p); }); }
		function sync() {
			var h = cd === 'HALF';
			$e.toggle(!h && !$open.find('input').prop('checked'));
			$half.toggle(h);
			$open.toggle(!h);
			var s = $s.val(), e = h ? s : $open.find('input').prop('checked') ? today() : $e.val();
			var n = h ? 0.5 : s && e && e >= s ? Math.round((new Date(e) - new Date(s)) / 864e5) + 1 : 0;
			$days.text(n ? daysText(n) + ($open.find('input').prop('checked') && !h ? ' (오늘까지)' : '') : '');
		}
		$types.on('click', '.vc-chip', function() { pickType($(this).attr('data-v')); });
		$paid.on('click', 'button', function() { setPaid($(this).attr('data-v')); });
		$s.add($e).add($open.find('input')).on('change', sync);
		pickType(cd, !!paid);
		if (paid) setPaid(paid);

		function save(force) {
			if (!staffSq) { bootbox.alert('직원을 목록에서 골라 주세요.'); return false; }
			var h = cd === 'HALF', open = !h && $open.find('input').prop('checked');
			var data = { STAFF_SQ: staffSq, VAC_SQ: v.VAC_SQ || '', START_DT: $s.val(), END_DT: h ? $s.val() : open ? '' : $e.val(), HALF_CD: h ? $half.val() : '',
				VAC_CD: cd, PAID_YN: paid, MEMO: $.trim($memo.val()), FORCE: force ? 'Y' : '' };
			post('/admin/staff/saveVacationData.do', data, function(res) {
				var r = res.result || {};
				if (r.OVERLAP) {
					bootbox.confirm('같은 기간에 이미 휴가가 있어요.<br>' + r.OVERLAP.map(function(x) { return $('<div>').text(period(x) + ' · ' + typeName(x.VAC_CD) + ' · ' + (x.PAID_YN === 'Y' ? '유급' : '무급')).html(); }).join('<br>') + '<br>그래도 저장할까요?', function(ok) { if (ok) save(true); });
					return;
				}
				dlg.modal('hide');
				if (o.saved) o.saved();
			});
			return false;
		}
		var buttons = {};
		if (v.VAC_SQ) buttons.del = { label: '삭제', className: 'btn-outline-danger btn-sm mr-auto', callback: function() {
			bootbox.confirm('이 휴가를 지울까요? ' + period(v), function(ok) { if (ok) post('/admin/staff/deleteVacationData.do', { STAFF_SQ: v.STAFF_SQ, VAC_SQ: v.VAC_SQ }, function() { dlg.modal('hide'); if (o.saved) o.saved(); }); });
			return false;
		} };
		buttons.cancel = { label: '취소', className: 'btn-outline-secondary btn-sm' };
		buttons.ok = { label: '저장', className: 'btn-primary btn-sm', callback: function() { return save(false); } };
		var dlg = bootbox.dialog({ title: (v.VAC_SQ ? '휴가 수정' : '휴가 등록') + (o.staff ? ' · ' + o.staff.STAFF_NM : ''), message: $f, onEscape: true, className: 'vc-dialog', buttons: buttons });
		return dlg;
	};
	function row(label, $c) { return $('<div class="vc-row">').append($('<span class="vc-k">').text(label)).append($c); }

	/** 인사카드 휴가 탭: 위 달력(끌거나 눌러 기간 고르기, 막대를 누르면 수정) + 아래 목록. counted(n) 은 건수가 바뀔 때 */
	window.vacTab = function($box, staff, counted) {
		var list = [], ym = today().substr(0, 7);
		function load() {
			$.post('/admin/staff/vacationData.do', { STAFF_SQ: staff.STAFF_SQ }).done(function(res) {
				list = res.list || [];
				if (counted) counted(list.length);
				paint();
			});
		}
		function reopen() { load(); }
		function form(start, end, vac) { vacForm({ staff: staff, vac: vac, start: start, end: end, saved: reopen }); }
		function paint() {
			$box.empty();
			var y = today().substr(0, 4), paidN = 0, unpaidN = 0;
			list.forEach(function(v) { if (v.START_DT.substr(0, 4) === y) { if (v.PAID_YN === 'Y') paidN += +v.DAYS; else unpaidN += +v.DAYS; } });
			$box.append($('<div class="hr-section d-flex align-items-center flex-wrap" style="gap:8px">').append('휴가 ')
				.append($('<span class="small text-muted font-weight-normal">').text('올해 유급 ' + daysText(paidN) + ' · 무급 ' + daysText(unpaidN) + ' · 달력에서 날짜를 끌거나 눌러 기간을 고르면 등록 창이 떠요'))
				.append($('<button type="button" class="btn btn-sm btn-outline-primary ml-auto">').text('＋ 휴가 등록').on('click', function() { form(today(), today()); })));
			// 달력
			var first = new Date(ym + '-01T00:00:00'), startDow = first.getDay(), last = new Date(first.getFullYear(), first.getMonth() + 1, 0).getDate();
			var $bar = $('<div class="vc-calbar">').appendTo($box);
			$bar.append($('<button type="button" class="btn btn-sm btn-outline-secondary" aria-label="이전 달">◀</button>').on('click', function() { move(-1); }))
				.append($('<b>').text(first.getFullYear() + '년 ' + (first.getMonth() + 1) + '월'))
				.append($('<button type="button" class="btn btn-sm btn-outline-secondary" aria-label="다음 달">▶</button>').on('click', function() { move(1); }))
				.append($('<button type="button" class="btn btn-sm btn-outline-secondary">오늘</button>').on('click', function() { ym = today().substr(0, 7); paint(); }))
				.append($('<span class="ml-auto small">').append(pill('Y')).append(' ').append(pill('N')));
			var $cal = $('<div class="vc-cal" role="grid">').appendTo($box);
			['일', '월', '화', '수', '목', '금', '토'].forEach(function(d, i) { $cal.append($('<div class="vc-hd">').toggleClass('sun', i === 0).toggleClass('sat', i === 6).text(d)); });
			for (var i = 0; i < startDow; i++) $cal.append('<div class="vc-day off"></div>');
			for (var d = 1; d <= last; d++) {
				var ymd = ym + '-' + ('0' + d).slice(-2), dow = (startDow + d - 1) % 7;
				var $c = $('<div class="vc-day" tabindex="0">').attr({ 'data-d': ymd, 'aria-label': ymd + ' 휴가 등록' }).toggleClass('sun', dow === 0).toggleClass('sat', dow === 6).toggleClass('today', ymd === today())
					.append($('<span class="vc-n">').text(d));
				list.forEach(function(v) {
					var end = v.END_DT || today();
					if (v.START_DT <= ymd && ymd <= end) {
						$c.append($('<button type="button" class="vc-bar">').addClass(v.PAID_YN === 'Y' ? 'paid' : 'unpaid').toggleClass('open', !v.END_DT)
							.attr('title', period(v) + ' · ' + typeName(v.VAC_CD) + (v.MEMO ? ' · ' + v.MEMO : '')).text(typeName(v.VAC_CD) + (v.HALF_CD ? (v.HALF_CD === 'AM' ? '(오전)' : '(오후)') : ''))
							.on('mousedown click', function(e) { e.stopPropagation(); if (e.type === 'click') form(null, null, v); }));
					}
				});
				$cal.append($c);
			}
			// 끌어서 기간 고르기(누르기만 하면 하루)
			var from = null;
			$cal.on('mousedown', '.vc-day[data-d]', function(e) { e.preventDefault(); from = $(this).attr('data-d'); mark(from, from); })
				.on('mouseenter', '.vc-day[data-d]', function() { if (from) mark(from, $(this).attr('data-d')); })
				.on('keydown', '.vc-day[data-d]', function(e) { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); form($(this).attr('data-d'), $(this).attr('data-d')); } });
			$(document).off('mouseup.vac').on('mouseup.vac', function(e) {
				if (!from) return;
				var to = $(e.target).closest('.vc-day[data-d]').attr('data-d') || from, a = from < to ? from : to, b = from < to ? to : from;
				from = null;
				$cal.find('.sel').removeClass('sel');
				form(a, b);
			});
			function mark(a, b) { var lo = a < b ? a : b, hi = a < b ? b : a; $cal.find('.vc-day[data-d]').each(function() { var x = $(this).attr('data-d'); $(this).toggleClass('sel', x >= lo && x <= hi); }); }
			// 목록
			var $t = $('<table class="table table-sm vc-list" data-nomore>').append('<thead><tr><th>기간</th><th>일수</th><th>종류</th><th>구분</th><th>메모</th><th>등록</th><th></th></tr></thead>');
			var $tb = $('<tbody>').appendTo($t);
			list.forEach(function(v) {
				$tb.append($('<tr>').toggleClass('vc-open-row', !v.END_DT).append($('<td>').text(period(v)).append(!v.END_DT ? ' <span class="vc-tag">기간 미정</span>' : ''))
					.append($('<td>').text(daysText(+v.DAYS))).append($('<td>').text(typeName(v.VAC_CD))).append($('<td>').append(pill(v.PAID_YN)))
					.append($('<td class="vc-memo">').text(v.MEMO || '')).append($('<td class="small text-muted">').text((v.SRC_CD === 'EXCEL' ? '엑셀 · ' : '') + (v.UPDT_EMPLY_ID || '') + (v.UPDT_DT ? ' · ' + v.UPDT_DT.substr(5) : '')))
					.append($('<td class="text-nowrap">').append($('<button type="button" class="vc-act" title="수정">').attr('aria-label', period(v) + ' 휴가 수정').html('<i class="fas fa-pen"></i>').on('click', function() { form(null, null, v); }))));
			});
			if (!list.length) $tb.append('<tr><td colspan="7" class="text-center text-muted py-3">등록한 휴가가 없습니다. 달력에서 날짜를 끌거나 「＋ 휴가 등록」을 눌러요.</td></tr>');
			$box.append($('<div class="table-responsive">').append($t));
		}
		function move(n) { var d = new Date(ym + '-01T00:00:00'); d.setMonth(d.getMonth() + n); ym = d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2); paint(); }
		load();
	};

	$('<style>').text([
		'.vc-pill { display: inline-block; border-radius: 999px; padding: 1px 9px; font-size: 11.5px; font-weight: 700; } .vc-pill.paid, .vc-bar.paid { background: #dff3e6; color: #1d7a4a; } .vc-pill.unpaid, .vc-bar.unpaid { background: #fde9d6; color: #a85a00; }',
		'.vc-calbar { display: flex; align-items: center; gap: 8px; margin: 6px 0 8px; } .vc-calbar b { font-size: 15px; }',
		'.vc-cal { display: grid; grid-template-columns: repeat(7, minmax(0, 1fr)); border-top: 1px solid #e3e8ee; border-left: 1px solid #e3e8ee; user-select: none; }',
		'.vc-hd, .vc-day { border-right: 1px solid #e3e8ee; border-bottom: 1px solid #e3e8ee; } .vc-hd { text-align: center; font-weight: 700; background: #f7f9fb; font-size: 12px; padding: 3px 0; }',
		'.vc-day { min-height: 64px; padding: 2px 3px; font-size: 11.5px; cursor: pointer; min-width: 0; } .vc-day.off { background: #fafbfc; cursor: default; } .vc-day:hover { background: #f4fafc; }',
		'.vc-day.sel { background: #e3f6fb; box-shadow: inset 0 0 0 2px #16a0c4; } .vc-day.today .vc-n { background: #0b6e8a; color: #fff; border-radius: 999px; padding: 0 5px; }',
		'.sun, .vc-day.sun .vc-n { color: #c0392b; } .sat, .vc-day.sat .vc-n { color: #2f6fb0; }',
		'.vc-bar { display: block; width: 100%; margin-top: 2px; border: 0; border-radius: 4px; padding: 0 4px; font-size: 11px; font-weight: 600; text-align: left; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }',
		'.vc-bar.open { background-image: repeating-linear-gradient(45deg, transparent 0 5px, rgba(255,255,255,.55) 5px 8px); }',
		'.vc-list { margin-top: 12px; font-size: 12.5px; } .vc-list td { vertical-align: middle; white-space: nowrap; } .vc-list td.vc-memo { white-space: normal; max-width: 280px; }',
		'.vc-tag { font-size: 10.5px; background: #fff3c4; color: #8a5a00; border-radius: 999px; padding: 0 6px; } .vc-act { background: none; border: 0; color: #888; } .vc-act:hover { color: #0b6e8a; }',
		'.vc-row { display: grid; grid-template-columns: 56px 1fr; gap: 8px; align-items: center; margin-bottom: 10px; font-size: 13px; } .vc-k { color: #6b7785; }',
		'.vc-per { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; } .vc-d { width: 150px; } .vc-half { width: 90px; } .vc-open { margin: 0; font-size: 12.5px; } .vc-days { margin-left: 4px; color: #0b6e8a; }',
		'.vc-types { display: flex; flex-wrap: wrap; gap: 4px; } .vc-chip { border: 0; border-radius: 999px; background: #eef1f4; padding: 3px 11px; font-size: 12.5px; } .vc-chip.on { background: #0b6e8a; color: #fff; }',
		'.vc-seg { display: inline-flex; border: 1px solid #ccd3db; border-radius: 8px; overflow: hidden; } .vc-seg button { border: 0; background: #fff; padding: 4px 16px; font-size: 12.5px; } .vc-seg button.on { background: #0b6e8a; color: #fff; }',
		'.vc-hint { color: #8a96a3; margin-left: 8px; } .vc-note { font-size: 12px; background: #f4f7fa; border-radius: 6px; padding: 6px 10px; color: #555; }',
		'@media (max-width: 767px) { .vc-day { min-height: 48px; } .vc-bar { font-size: 10px; } .vc-d { width: 135px; } }'
	].join('\n')).appendTo('head');
})();
