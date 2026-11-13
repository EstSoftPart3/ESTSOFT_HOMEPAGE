/*
 * 관리자 목록 화면 공통 조각 (jQuery 뒤에 읽는다). 표 동작(정렬·틀고정·칸 이동·50줄)은 ui-table.js, 모양(.pl-chip·.cal-empty)은 include_top·calendar_style.
 */

// 체크 칩 줄: [☐ 전체 선택] + 칩(이름·건수).
// chips: [{ k: 값, name: 이름, n: 건수(빼면 안 보임), cls: 덧붙일 class(secret·alert), hide: true 면 그리지 않되 전체 선택에는 포함 }]. 칩 사이에 끼울 것(구분선)은 HTML 글자로 넣는다
// checked: 화면이 들고 있는 { 값: true } 를 그대로 고친다. changed: 바뀐 뒤 부른다(보통 render)
function boChips(box, chips, checked, changed) {
	var keys = chips.filter(function(c) { return c.k; }).map(function(c) { return c.k; }), all = keys.every(function(k) { return checked[k]; });
	var $c = $(box).empty().append($('<button type="button" class="btn btn-sm btn-outline-secondary pl-all">').text(all ? '☑ 전체 해제' : '☐ 전체 선택').on('click', function() {
		keys.forEach(function(k) { checked[k] = !all; });
		changed();
	}));
	chips.forEach(function(c) {
		if (!c.k) { $c.append(c); return; }
		if (c.hide) return;
		// class pl-chk: Shift+클릭 범위 선택(include_bottom)이 같은 class 끼리 묶는다
		$c.append($('<label class="pl-chip">').addClass(c.cls || '').toggleClass('on', !!checked[c.k])
			.append($('<input type="checkbox" class="pl-chk">').val(c.k).prop('checked', !!checked[c.k]).on('change', function() { checked[c.k] = this.checked; changed(); }))
			.append($('<span>').text(c.name)).append(c.n === undefined ? '' : $('<span class="cnt">').text(c.n)));
	});
	return $c;
}

// 목록이 비었을 때 안내 한 줄. 칸 수는 머리글에서 센다(머리글이 없으면 넉넉히 잡는다)
function boEmpty(tbody, msg) {
	var $b = $(tbody), n = 0;
	$b.closest('table').find('thead tr').first().children().each(function() { n += this.colSpan || 1; });
	return $b.append($('<tr>').append($('<td class="cal-empty">').attr('colspan', n || 99).text(msg)));
}
