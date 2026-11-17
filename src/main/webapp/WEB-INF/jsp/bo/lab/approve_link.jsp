<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%--
  연구일지 승인 요청 메일의 링크 화면(로그인 없이, 휴대폰에서도). 토큰은 그 결재자·그 일지·그 단계에만 쓰인다.
  데이터는 JSON 으로 넘기고 화면은 textContent 로만 그린다. 일지 본문(HTML)은 스크립트가 돌지 않는 iframe 안에 보인다.
--%><%
	String json = new org.codehaus.jackson.map.ObjectMapper().writeValueAsString(request.getAttribute("view"))
		.replace("<", "\\u003c").replace(">", "\\u003e").replace("&", "\\u0026").replace("\u2028", "\\u2028").replace("\u2029", "\\u2029");
	String token = String.valueOf(request.getAttribute("token")).replaceAll("[^A-Za-z0-9_-]", "");
%><!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex">
<meta name="referrer" content="no-referrer">
<title>연구일지 승인</title>
<style>
* { box-sizing: border-box; }
body { margin: 0; background: #eef1f4; color: #212529; font: 15px/1.6 "Malgun Gothic", "Apple SD Gothic Neo", sans-serif; }
.wrap { max-width: 720px; margin: 0 auto; padding: 16px; }
.top { background: #0a4a78; color: #fff; border-radius: 10px 10px 0 0; padding: 16px 18px; }
.top small { opacity: .8; display: block; }
.top b { font-size: 19px; }
.card { background: #fff; border-radius: 0 0 10px 10px; padding: 16px 18px; box-shadow: 0 1px 3px rgba(0,0,0,.08); }
.msg { background: #fff; border-radius: 10px; padding: 28px 18px; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,.08); }
.msg b { display: block; font-size: 18px; margin-bottom: 6px; }
table.info { width: 100%; border-collapse: collapse; background: #f8f9fa; border-radius: 6px; margin-bottom: 14px; }
table.info td { padding: 7px 10px; vertical-align: top; }
table.info td:first-child { color: #6c757d; white-space: nowrap; width: 64px; }
.steps { display: flex; flex-wrap: wrap; gap: 6px; }
.step { border: 1px solid #ced4da; border-radius: 14px; padding: 1px 10px; font-size: 13px; }
.step.done { border-color: #198754; color: #198754; }
.step.now { border-color: #0b6e8a; background: #0b6e8a; color: #fff; font-weight: 700; }
h2 { font-size: 15px; margin: 16px 0 6px; }
table.people { width: 100%; border-collapse: collapse; font-size: 14px; }
table.people td { padding: 7px 8px; border-top: 1px solid #eef1f4; vertical-align: top; }
table.people td:first-child { font-weight: 700; white-space: nowrap; width: 70px; }
table.people ul { margin: 0; padding-left: 18px; }
iframe { width: 100%; min-height: 240px; border: 1px solid #dee2e6; border-radius: 6px; background: #fff; }
.bar { position: sticky; bottom: 0; background: #fff; border-top: 1px solid #dee2e6; padding: 12px 16px; display: flex; gap: 10px; max-width: 720px; margin: 0 auto; }
button { font: inherit; border-radius: 8px; padding: 12px; border: 1px solid #adb5bd; background: #fff; cursor: pointer; }
button.ok { flex: 1; background: #0b6e8a; border-color: #0b6e8a; color: #fff; font-weight: 700; font-size: 16px; }
button.no { color: #b02a37; border-color: #b02a37; min-width: 88px; }
button:disabled { opacity: .55; cursor: default; }
textarea { width: 100%; min-height: 90px; font: inherit; padding: 8px; border: 1px solid #adb5bd; border-radius: 6px; }
.warn { background: #fff3cd; color: #664d03; border-radius: 6px; padding: 8px 10px; margin-bottom: 12px; font-size: 14px; }
.note { color: #6c757d; font-size: 12px; margin-top: 10px; }
</style>
</head>
<body>
<div class="wrap" id="app"></div>
<script>
(function() {
	var view = <%= json %>, token = '<%= token %>', app = document.getElementById('app');
	function el(tag, cls, text) { var e = document.createElement(tag); if (cls) e.className = cls; if (text != null) e.textContent = text; return e; }
	function message(title, sub) {
		app.innerHTML = '';
		var m = el('div', 'msg'); m.appendChild(el('b', null, title)); if (sub) m.appendChild(el('div', null, sub));
		app.appendChild(m);
		var bar = document.querySelector('.bar'); if (bar) bar.remove();
	}
	if (view.ERROR) { message('처리할 수 없는 링크입니다', view.ERROR); return; }

	var j = view.journal, step = view.step;
	var top = el('div', 'top'); top.appendChild(el('small', null, '이에스티소프트 연구소 · 연구일지 승인'));
	top.appendChild(el('b', null, j.YM + ' 월간 연구일지'));
	app.appendChild(top);
	var card = el('div', 'card'); app.appendChild(card);
	card.appendChild(el('div', null, (step.EMPLY_NM || '') + ' 님, 아래 내용을 확인하고 승인해 주세요.'));
	if (view.needSign) card.appendChild(el('div', 'warn', '등록된 서명이 없어 승인할 수 없습니다. 연구소 관리 > 결재라인에서 서명을 먼저 등록해 주세요(반려는 할 수 있습니다).'));

	var info = el('table', 'info');
	function row(k, v) { var tr = el('tr'); tr.appendChild(el('td', null, k)); var td = el('td'); if (typeof v === 'string') td.textContent = v; else td.appendChild(v); tr.appendChild(td); info.appendChild(tr); }
	row('과제', j.PRJ_NM || '');
	row('작성', j.WRITER_NM || '');
	if (j.SNAP_MEMBERS) row('연구원', j.SNAP_MEMBERS);
	var st = el('div', 'steps');
	(view.steps || []).forEach(function(s) {
		var now = String(s.STEP_NO) === String(j.CUR_STEP);
		st.appendChild(el('span', 'step' + (s.DONE_DT ? ' done' : now ? ' now' : ''), s.STEP_NO + '단계 ' + s.STEP_NM + ' ' + (s.EMPLY_NM || '') + (s.DONE_DT ? ' ✓' : now ? ' · 지금' : '')));
	});
	row('결재', st);
	card.appendChild(info);

	if ((view.recipients || []).length) {
		card.appendChild(el('h2', null, '연구원별 업무'));
		var pt = el('table', 'people');
		view.recipients.forEach(function(p) {
			var tr = el('tr'); tr.appendChild(el('td', null, p.STAFF_NM));
			var td = el('td');
			if (!p.ITEMS.length) td.textContent = '-';
			else { var ul = el('ul'); p.ITEMS.forEach(function(i) { ul.appendChild(el('li', null, i)); }); td.appendChild(ul); }
			tr.appendChild(td); pt.appendChild(tr);
		});
		card.appendChild(pt);
	}

	card.appendChild(el('h2', null, '일지 내용'));
	var f = document.createElement('iframe');
	f.setAttribute('sandbox', 'allow-same-origin');
	f.title = '연구 내용';
	f.onload = function() { var d = f.contentDocument; if (d && d.documentElement) f.style.height = (d.documentElement.scrollHeight + 8) + 'px'; };
	f.srcdoc = '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><style>body{margin:10px;font:14px/1.6 sans-serif;word-break:keep-all;overflow-wrap:anywhere}table{border-collapse:collapse}td,th{border:1px solid #868e96;padding:4px 8px}p{margin:0 0 4px}</style>' + (j.CONTENT || '');
	card.appendChild(f);
	card.appendChild(el('div', 'note', '이 화면은 승인 요청 메일을 받은 본인만 사용해 주세요. 한 번 처리하거나 7일이 지나면 링크가 만료됩니다.'));

	var bar = el('div', 'bar');
	var no = el('button', 'no', '반려'), ok = el('button', 'ok', step.STEP_NM + ' 승인');
	ok.type = no.type = 'button';
	if (view.needSign) ok.disabled = true;
	bar.appendChild(no); bar.appendChild(ok);
	document.body.appendChild(bar);

	function send(action, note) {
		ok.disabled = no.disabled = true;
		var body = 't=' + encodeURIComponent(token) + '&ACTION=' + action + (note ? '&NOTE=' + encodeURIComponent(note) : '');
		fetch('/lab/approveLinkData.do', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' }, body: body })
			.then(function(r) { return r.json(); })
			.then(function(res) {
				if (res.error) { alert(res.error); ok.disabled = !!view.needSign; no.disabled = false; return; }
				if (action === 'REJECT') message('반려했습니다', '작성자에게 일지가 작성 중으로 돌아갔습니다.');
				else message('승인했습니다', res.result === 'APPROVED' ? '결재가 모두 끝났습니다. 연구소장이 마감합니다.' : '다음 결재자에게 승인 요청 메일이 갑니다.');
			})
			.catch(function() { alert('처리하지 못했습니다. 잠시 뒤 다시 시도해 주세요.'); ok.disabled = !!view.needSign; no.disabled = false; });
	}
	ok.onclick = function() { if (confirm(j.YM + ' 연구일지를 승인할까요? 등록된 서명이 찍힙니다.')) send('APPROVE'); };
	no.onclick = function() {
		var note = prompt('반려 사유를 입력해 주세요.');
		if (note === null) return;
		if (!note.trim()) { alert('반려 사유를 입력해 주세요.'); return; }
		send('REJECT', note.trim());
	};
})();
</script>
</body>
</html>
