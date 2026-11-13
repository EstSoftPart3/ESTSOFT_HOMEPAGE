/*
 * 피드백·업데이트 내역 공통(모든 관리자 화면, include_bottom.jspf 에서 불러옴). 서버는 BoFeedbackController.
 * - 상단 💬 피드백 버튼(#fbBtn): 쓰기 + 내 피드백/전체 상태 보기. 숫자는 상태가 바뀌었는데 안 본 내 피드백
 * - BO_UPDATE(sq): 업데이트 상세 팝업(기획서 형태), BO_SPEC(fbSq): 피드백 기획서 팝업
 * - 왼쪽 메뉴 '업데이트 내역'에 새 건 N 표시(본 마지막 번호는 브라우저에 기억)
 */
(function () {
	var STATUS = { NEW: '접수', REVIEW: '검토 대기', ING: '진행 중', DONE: '반영', HOLD: '보류', REJECT: '반려' };
	var TONE = { NEW: '', REVIEW: 'warn', ING: 'rent', DONE: 'ok', HOLD: '', REJECT: 'bad' };
	var KIND = { INCONV: '불편', BUG: '오류', NEW: '새 기능' };
	var UPD_URL = '/admin/update/openUpdateList.do', SEEN_KEY = 'boUpdateSeen';

	// 공통코드(FB_KIND·FB_STATUS)가 있으면 그 이름을 쓴다
	function names(grp, base) {
		var m = $.extend({}, base);
		if (window.HR_ALL_CODES) HR_ALL_CODES.forEach(function (c) { if (c.GRP === grp) m[c.CD] = c.NM; });
		return m;
	}
	window.BO_FB = { status: function () { return names('FB_STATUS', STATUS); }, kind: function () { return names('FB_KIND', KIND); }, tone: TONE };

	function esc(s) { return $('<div>').text(s == null ? '' : String(s)).html(); }
	function pill(text, tone) { return $('<span class="fb-pill">').addClass(tone || '').text(text); }
	function post(url, data, done) {
		$.post(url, data).done(function (res) {
			if (res.error) { bootbox.alert(res.error); return; }
			done(res.result);
		}).fail(function () { bootbox.alert('처리하지 못했습니다. 다시 로그인한 뒤 시도해 주세요.'); });
	}
	function lines(txt) { return $('<ul>').append(String(txt || '').split('\n').map(function (l) { return l.trim(); }).filter(Boolean).map(function (l) { return $('<li>').text(l.replace(/^[-·•]\s*/, '')); })); }
	// Claude 가 만든 기획서 HTML 은 스크립트 없이 분리된 칸(sandbox)에서만 보인다
	function specFrame(html, h) { return $('<iframe class="fb-spec" sandbox title="기획서">').attr('srcdoc', html).css('height', h || 420); }

	// ── 업데이트 상세 ──
	window.BO_UPDATE = function (sq) {
		post('/admin/update/detailData.do', { UPD_SQ: sq }, function (u) {
			if (!u) return;
			var $b = $('<div class="fb-upd">');
			$b.append($('<div class="fb-meta">').text([u.DEPLOY_DT + ' 배포', u.SCREENS, u.COMMIT_ID ? '커밋 ' + u.COMMIT_ID : ''].filter(Boolean).join(' · ')));
			if (u.FB_SQ) $b.append($('<div class="fb-req">').append($('<b>').text('💬 요청자 ' + (u.FB_EMPLY_NM || ''))).append(document.createTextNode(' · ' + (u.FB_REG_DT || '') + ' · "' + (u.FB_CONTENT || '') + '"'))
				.append(u.FB_ACT_NM ? $('<span class="fb-mute">').text(' · 진행: ' + u.FB_ACT_NM + ' ' + (u.FB_ACT_DT || '')) : ''));
			if (u.SPEC_HTML) $b.append(specFrame(u.SPEC_HTML, 320));
			$b.append($('<div class="fb-three">').append([['수정한 것', u.CHANGED_TXT], ['테스트할 것', u.TESTS_TXT], ['주의할 것', u.CAUTIONS_TXT]].map(function (x) {
				return $('<div>').append($('<b>').text(x[0])).append(lines(x[1]));
			})));
			bootbox.dialog({ title: esc(u.TITLE) + (u.FB_SQ ? ' <span class="fb-pill warn">💬 피드백 반영</span>' : ''), message: $b, size: 'xl', onEscape: true, backdrop: true, buttons: { ok: { label: '닫기', className: 'btn-sm btn-outline-secondary' } } });
		});
	};

	// ── 피드백 기획서 ──
	window.BO_SPEC = function (fbSq) {
		post('/admin/feedback/detailData.do', { FB_SQ: fbSq }, function (f) {
			if (!f || !f.SPEC_HTML) { bootbox.alert('아직 기획서가 없습니다. 평일 오전 9시 30분에 만들어집니다.'); return; }
			bootbox.dialog({ title: '기획서 — ' + esc(String(f.CONTENT).substring(0, 60)), message: specFrame(f.SPEC_HTML, '70vh'), size: 'xl', onEscape: true, backdrop: true });
		});
	};

	// ── 피드백 팝업(상단 버튼) ──
	function activeScreen() {
		var t = document.querySelector('#boTabs .bo-tab.on');
		return (t ? t.textContent : document.title).replace(/[×✕]/g, '').trim();
	}

	function openFeedback() {
		var kind = BO_FB.kind(), mine = true, data = null;
		var $kind = $('<select class="form-control form-control-sm" aria-label="종류">');
		$.each(kind, function (k, v) { $kind.append($('<option>').val(k).text(v)); });
		var $screen = $('<input class="form-control form-control-sm" maxlength="100" aria-label="화면">').val(activeScreen());
		var $ta = $('<textarea class="form-control form-control-sm enter-send" rows="3" maxlength="4000" aria-label="피드백 내용" placeholder="무엇이 불편한지, 어떻게 되면 좋을지 적어 주세요 · Enter 보내기, Shift+Enter 줄바꿈">');
		var $send = $('<button type="button" class="btn btn-sm btn-primary">보내기</button>');
		var $seg = $('<div class="fb-seg" role="tablist">'), $list = $('<div class="fb-list">');
		var $box = $('<div>').append($('<div class="form-row">')
			.append($('<div class="col-6 mb-2">').append('<label class="small mb-1">화면</label>').append($screen))
			.append($('<div class="col-6 mb-2">').append('<label class="small mb-1">종류</label>').append($kind)))
			.append('<label class="small mb-1">내용</label>').append($ta).append($('<div class="text-right mt-1">').append($send)).append($seg).append($list);

		function draw() {
			var me = data.me, status = BO_FB.status(), rows = data.list.filter(function (f) { return !mine || f.EMPLY_ID === me; });
			$seg.empty().append([[true, '내 피드백', data.list.filter(function (f) { return f.EMPLY_ID === me; }).length], [false, '전체', data.list.length]].map(function (s) {
				return $('<button type="button" role="tab">').attr('aria-selected', s[0] === mine).toggleClass('on', s[0] === mine).text(s[1] + ' ' + s[2]).on('click', function () { mine = s[0]; draw(); });
			}));
			$list.empty();
			if (!rows.length) $list.append('<div class="fb-mute py-2">아직 피드백이 없습니다.</div>');
			rows.slice(0, 50).forEach(function (f) {
				var $st = pill(status[f.STATUS_CD] || f.STATUS_CD, TONE[f.STATUS_CD]);
				var $it = $('<div class="fb-it">').append($('<div class="fb-who">').append($('<b>').text(f.EMPLY_ID === me ? '나' : (f.EMPLY_NM || f.EMPLY_ID)))
					.append($('<span>').text([f.REG_DT, f.SCREEN_NM, kind[f.KIND_CD] || f.KIND_CD].filter(Boolean).join(' · '))).append($st))
					.append($('<div class="fb-txt">').text(f.CONTENT));
				if (f.STATUS_CD === 'REJECT' && f.REJECT_REASON) $it.append($('<div class="fb-why">').text('반려 사유: ' + f.REJECT_REASON));
				if (f.STATUS_CD === 'DONE' && f.UPD_SQ) $it.append($('<button type="button" class="btn btn-link btn-sm p-0">').text('→ 업데이트 내역 보기').on('click', function () { BO_UPDATE(f.UPD_SQ); }));
				else if (f.HAS_SPEC == 1) $it.append($('<button type="button" class="btn btn-link btn-sm p-0">').text('기획서 보기').on('click', function () { BO_SPEC(f.FB_SQ); }));
				$list.append($it);
			});
		}
		function load() { post('/admin/feedback/listData.do', {}, function (r) { data = r; draw(); }); }

		$send.on('click', function () {
			if (!$.trim($ta.val())) { $ta.focus(); return; }
			$send.prop('disabled', true);
			$.post('/admin/feedback/saveData.do', { SCREEN_NM: $screen.val(), SCREEN_URL: location.pathname, KIND_CD: $kind.val(), CONTENT: $ta.val() }).done(function (res) {
				$send.prop('disabled', false);
				if (res.error) { bootbox.alert(res.error); return; }
				$ta.val(''); mine = true; load();
			}).fail(function () { $send.prop('disabled', false); });
		});
		$ta.on('enter-send', function () { if (!$send.prop('disabled')) $send.click(); });

		bootbox.dialog({ title: '💬 피드백', message: $box, onEscape: true, backdrop: true }).on('shown.bs.modal', function () { $ta.focus(); });
		load();
		// 팝업을 열면 바뀐 상태를 본 것으로 친다
		$.post('/admin/feedback/seenData.do').always(function () { paintBadge(0); });
	}

	function paintBadge(n) {
		var $d = $('#fbBtn .fb-dot');
		$d.text(n || '').prop('hidden', !n);
		$('#fbBtn').attr('aria-label', '피드백' + (n ? ' (상태 바뀐 내 피드백 ' + n + '건)' : ''));
	}

	// 업데이트 내역 메뉴의 N: 본 마지막 번호보다 새 건이 있으면
	function paintNew(latest) {
		var seen = 0;
		try { seen = Number(localStorage.getItem(SEEN_KEY) || 0); } catch (e) { return; }
		if (location.pathname === UPD_URL || window.BO_UPDATE_PAGE) { try { localStorage.setItem(SEEN_KEY, latest || 0); } catch (e) {} return; }
		var on = latest && latest > seen;
		[].forEach.call(document.querySelectorAll('aside a.nav-link[href="' + UPD_URL + '"] p'), function (p) {
			var b = p.querySelector('.fb-new');
			if (on && !b) { b = document.createElement('span'); b.className = 'fb-new'; b.textContent = 'N'; p.appendChild(b); }
			if (!on && b) b.remove();
		});
	}
	window.BO_UPDATE_SEEN = function (latest) { try { localStorage.setItem(SEEN_KEY, latest || 0); } catch (e) {} };

	$(function () {
		$(document).on('click', '#fbBtn', openFeedback);
		// 탭 안 화면(iframe)은 상단 메뉴가 없어 맨 위 창만 숫자를 읽는다
		if (window.top !== window || !document.getElementById('fbBtn')) return;
		$.post('/admin/feedback/badgeData.do').done(function (res) {
			if (!res.result) return;
			paintBadge(res.result.unseen);
			paintNew(res.result.latestUpdate);
		});
	});
})();
