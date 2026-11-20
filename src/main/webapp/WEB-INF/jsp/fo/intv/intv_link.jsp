<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%><%
	response.setHeader("Cache-Control", "no-store");
%><!doctype html>
<%-- 인터뷰 기록 링크(로그인 없음, plans/recruit-intv-link-spec.html). 토큰(?t=)이 곧 권한. 칩·저장은 /intvData.do, /intvSave.do --%>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex, nofollow">
<meta name="referrer" content="no-referrer">
<title>인터뷰 기록</title>
<style>
	* { box-sizing: border-box; }
	body { margin: 0; background: #f5f7f9; color: #1f2933; font: 15px/1.5 "Pretendard", "Malgun Gothic", -apple-system, sans-serif; }
	.wrap { max-width: 640px; margin: 0 auto; padding: 18px 16px 90px; }
	h1 { font-size: 19px; margin: 0; } .meta { color: #6b7680; font-size: 13px; margin: 2px 0 6px; }
	.hint { font-size: 12.5px; color: #6b7680; background: #fff; border: 1px solid #dfe4e8; border-radius: 10px; padding: 8px 10px; margin: 8px 0 4px; }
	.grp { background: #fff; border: 1px solid #dfe4e8; border-radius: 12px; padding: 10px 12px; margin-top: 10px; }
	.grp > .t { font-size: 13px; font-weight: 800; color: #495057; margin-bottom: 6px; } .grp > .t small { font-weight: 400; color: #868e96; }
	.chips { display: flex; flex-wrap: wrap; gap: 6px; }
	.chip { border: 1px solid #ced4da; border-radius: 999px; padding: 6px 12px; font-size: 14px; background: #fff; color: #1f2933; cursor: pointer; }
	.chip[aria-pressed=true] { background: #0b6e8a; border-color: #0b6e8a; color: #fff; font-weight: 700; }
	textarea { width: 100%; border: 1px solid #ced4da; border-radius: 8px; padding: 8px 10px; font: inherit; font-size: 14px; resize: vertical; }
	.qa { border: 1px dashed #dfe4e8; border-radius: 10px; padding: 8px; margin-bottom: 8px; position: relative; }
	.qa .n { font-size: 12px; font-weight: 800; color: #6b7680; margin-bottom: 4px; }
	.qa textarea + textarea { margin-top: 4px; }
	.qa .del { position: absolute; right: 8px; top: 6px; border: 0; background: none; color: #c92a2a; font-size: 13px; }
	.add { border: 1px solid #0b6e8a; color: #0b6e8a; background: #eef9fc; border-radius: 8px; padding: 6px 12px; font-size: 14px; font-weight: 700; }
	.bar { position: fixed; left: 0; right: 0; bottom: 0; background: #fff; border-top: 1px solid #dfe4e8; padding: 10px 16px; }
	.bar button { display: block; width: 100%; max-width: 608px; margin: 0 auto; border: 0; border-radius: 10px; background: #0b6e8a; color: #fff; font-size: 16px; font-weight: 800; padding: 12px; }
	.bar button:disabled { opacity: .6; }
	.msg { text-align: center; padding: 120px 20px; } .msg .big { font-size: 44px; } .msg h1 { margin: 6px 0; }
	.err { color: #c92a2a; font-size: 13px; text-align: center; margin-top: 6px; }
</style>
</head>
<body>
<div class="wrap" id="app"><div class="msg"><div class="meta">불러오는 중…</div></div></div>
<script src="/resources/bo/plugins/jquery/jquery.min.js"></script>
<script>
(function() {
	var token = (/[?&]t=([A-Za-z0-9_-]+)/.exec(location.search) || [])[1] || '';
	// [키, 공통코드 묶음, 이름, 여러 개?] — 관리자 기록 창(recruit_list.jsp NOTE_CATS)과 같은 순서
	var CATS = [['mood', 'MOOD', '분위기'], ['who', 'WHO', '면접관', 1], ['dur', 'DUR', '소요 시간'], ['flow', 'FLOW', '진행 흐름', 1], ['askd', 'ASKD', '많이 받은 질문', 1],
		['tech', 'TECH', '질문받은 기술', 1], ['feel', 'FEEL', '본인 느낌'], ['cli', 'CLI', '고객 반응 (내가 느낀)'], ['etc', 'ETC', '특이사항', 1], ['notice', 'NOTICE', '결과 안내']];
	var $app = $('#app');
	function msg(icon, title, text) { $app.empty().append($('<div class="msg">').append($('<div class="big">').text(icon)).append($('<h1>').text(title)).append($('<div class="meta">').text(text))); $('.bar').remove(); }
	function post(url, data, ok) {
		$.ajax({ url: url, type: 'POST', data: $.extend({ t: token }, data), dataType: 'json' }).done(function(res) {
			if (res.error) return msg('⏰', '열 수 없어요', res.error);
			ok(res.result);
		}).fail(function() { msg('⚠️', '연결하지 못했어요', '잠시 뒤 다시 열어 주세요.'); });
	}
	if (!token) return msg('⚠️', '링크가 올바르지 않아요', '받은 링크를 그대로 열어 주세요.');
	post('/intvData.do', {}, function(d) {
		var n = d.note || {};
		CATS.forEach(function(c) { if (c[3]) n[c[0]] = $.isArray(n[c[0]]) ? n[c[0]] : []; else n[c[0]] = n[c[0]] || ''; });
		var skills = String(d.SKILLS || '').split(/[,/·]+/).map(function(x) { return $.trim(x); }).filter(Boolean);
		$app.empty().append($('<h1>').text('인터뷰 어떠셨어요?'))
			.append($('<div class="meta">').text([d.STAFF_NM + ' 님', d.CLIENT_NM, d.INTV_DT ? d.INTV_DT + ' ' + d.INTV_WAY : ''].filter(Boolean).join(' · ')))
			.append($('<div class="hint">').text('기억나는 대로 눌러서 골라 주세요. 해당 없으면 비워 둬도 돼요. ' + d.LINK_EXP_DT + ' 까지 이 링크로 다시 들어와 고칠 수 있어요.'));
		CATS.forEach(function(c) {
			var key = c[0], list = (key === 'tech' ? skills : []).concat((d.codes || {})[c[1]] || []);
			(c[3] ? n[key] : n[key] ? [n[key]] : []).forEach(function(v) { if (list.indexOf(v) < 0) list.push(v); });
			list = list.filter(function(v, i) { return list.indexOf(v) === i; });
			var $c = $('<div class="chips">');
			list.forEach(function(v) {
				var on = c[3] ? n[key].indexOf(v) >= 0 : n[key] === v;
				$c.append($('<button type="button" class="chip">').attr('aria-pressed', on).text(v).on('click', function() {
					if (c[3]) { var i = n[key].indexOf(v); if (i >= 0) n[key].splice(i, 1); else n[key].push(v); $(this).attr('aria-pressed', i < 0); }
					else { n[key] = n[key] === v ? '' : v; $c.find('.chip').each(function() { $(this).attr('aria-pressed', $(this).text() === n[key]); }); }
				}));
			});
			if (list.length) $app.append($('<div class="grp">').append($('<div class="t">').text(c[2] + ' ').append(c[3] ? $('<small>').text('여러 개') : '')).append($c));
		});
		// 기억나는 질문·답변(여러 개)
		var $qa = $('<div>');
		function qaRow(x) {
			var $r = $('<div class="qa">').append($('<div class="n">').text('질문'))
				.append($('<textarea rows="2" class="q" maxlength="500" placeholder="받은 질문 (예: Spring 트랜잭션은 어떻게 쓰셨나요?)">').val(x.q || ''))
				.append($('<textarea rows="2" class="a" maxlength="2000" placeholder="뭐라고 답했는지 (기억나는 만큼)">').val(x.a || ''))
				.append($('<button type="button" class="del" aria-label="이 질문 지우기">✕ 지우기</button>').on('click', function() { $r.remove(); }));
			$qa.append($r);
			return $r;
		}
		(n.qa && n.qa.length ? n.qa : [{}]).forEach(qaRow);
		$app.append($('<div class="grp">').append('<div class="t">기억나는 질문 · 답변 <small>여러 개</small></div>').append($qa)
			.append($('<button type="button" class="add">＋ 질문 추가</button>').on('click', function() { qaRow({}).find('.q').focus(); })));
		var $memo = $('<textarea rows="3" maxlength="1000" placeholder="그 밖에 하고 싶은 말 (선택)">').val(n.memo || '');
		$app.append($('<div class="grp">').append('<div class="t">메모</div>').append($memo));
		var $err = $('<div class="err">');
		$app.append($err);
		var $btn = $('<button type="button">제출하기</button>');
		$('body').append($('<div class="bar">').append($btn));
		$btn.on('click', function() {
			n.qa = $qa.find('.qa').map(function() { return { q: $.trim($(this).find('.q').val()), a: $.trim($(this).find('.a').val()) }; }).get().filter(function(x) { return x.q || x.a; });
			n.memo = $.trim($memo.val());
			$btn.prop('disabled', true).text('보내는 중…');
			$.ajax({ url: '/intvSave.do', type: 'POST', data: { t: token, INTV_NOTE: JSON.stringify(n) }, dataType: 'json' }).done(function(res) {
				if (res.error) { $err.text(res.error); $btn.prop('disabled', false).text('제출하기'); return; }
				msg('✅', '제출했어요', '감사합니다. ' + d.LINK_EXP_DT + ' 까지는 이 링크로 다시 들어와 고칠 수 있어요.');
			}).fail(function() { $err.text('보내지 못했어요. 잠시 뒤 다시 눌러 주세요.'); $btn.prop('disabled', false).text('제출하기'); });
		});
	});
})();
</script>
</body>
</html>
