<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%-- 장비 대여증서. 담당자(게스트 서명·서명본 업로드)와 직원(본인 서명)이 같은 화면을 쓴다 --%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>장비 대여 증서</title>
<style>
	body { margin: 0; background: #f4f6f9; color: #111; font: 14px/1.7 "Malgun Gothic", sans-serif; }
	.bar, .act { max-width: 720px; margin: 14px auto; padding: 0 12px; }
	.bar { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
	.sp { flex: 1; }
	button { padding: 7px 14px; border: 1px solid #999; border-radius: 4px; background: #fff; font: inherit; cursor: pointer; }
	button.p { background: #0b6e8a; border-color: #0b6e8a; color: #fff; font-weight: 600; }
	button:focus-visible, input:focus-visible { outline: 2px solid #16d5ff; outline-offset: 2px; }
	.page { max-width: 720px; box-sizing: border-box; margin: 14px auto; padding: 44px 52px; background: #fff; border: 1px solid #ddd; }
	.page h1 { text-align: center; font-size: 24px; letter-spacing: .4em; margin: 0 0 24px; }
	.txt { white-space: pre-wrap; word-break: keep-all; }
	.who { display: flex; align-items: center; gap: 8px; min-height: 64px; margin-top: 8px; }
	.who img { height: 60px; max-width: 220px; }
	.box { background: #fff; border: 1px solid #ddd; padding: 16px; margin-bottom: 14px; }
	.box h2 { font-size: 15px; margin: 0 0 8px; }
	#pad { display: block; width: 100%; max-width: 480px; height: 160px; border: 1px dashed #0b6e8a; background: #fff; touch-action: none; }
	.row { display: flex; gap: 8px; margin-top: 10px; flex-wrap: wrap; align-items: center; }
	.done { color: #17692f; font-weight: 600; }
	#msg { color: #a32020; }
	@media (max-width: 560px) { .page { padding: 24px 18px; } }
	@media print { body { background: #fff; } .noprint { display: none !important; } .page { margin: 0 auto; border: 0; page-break-after: always; } .page:last-of-type { page-break-after: auto; } }
</style>
</head>
<body>
	<div class="bar noprint">
		<c:choose>
			<c:when test="${cert.sign != null && cert.sign.SIGN_TP == 'UPLOAD'}"><span class="done">서명본 첨부 완료 (${cert.sign.SIGN_DT})</span></c:when>
			<c:when test="${cert.sign != null}"><span class="done">서명 완료 (<c:out value="${cert.sign.SIGN_DT}"/>)</span></c:when>
			<c:otherwise><span>서명 대기</span></c:otherwise>
		</c:choose>
		<span class="sp"></span>
		<c:if test="${cert.sign != null && cert.sign.SIGN_TP == 'UPLOAD'}"><a href="<c:out value='${cert.sign.WEB_LINK}'/>" target="_blank" rel="noopener"><c:out value="${cert.sign.FILE_NM}"/></a></c:if>
		<button type="button" onclick="window.print();">인쇄</button>
	</div>

	<c:forEach var="p" items="${cert.pages}">
		<section class="page">
			<h1>장비 대여 증서</h1>
			<div class="txt"><c:out value="${p}"/></div>
			<div class="who">임차 : <c:out value="${cert.holder}"/> <c:choose><c:when test="${cert.sign.SIGN_IMG != null}"><img src="<c:out value='${cert.sign.SIGN_IMG}'/>" alt="<c:out value='${cert.holder}'/> 서명"></c:when><c:otherwise>(인)</c:otherwise></c:choose></div>
			<div class="who">임대 : 이에스티 대표 임 은 수 <c:choose><c:when test="${cert.seal != null}"><img src="<c:out value='${cert.seal}'/>" alt="대표 직인"></c:when><c:otherwise>(인)</c:otherwise></c:choose></div>
		</section>
	</c:forEach>

	<div class="act noprint">
		<c:if test="${canSign}">
			<div class="box">
				<h2>화면 서명</h2>
				<label><input type="checkbox" id="agree"> 위 증서 내용을 읽고 동의합니다.</label>
				<canvas id="pad" width="480" height="160" role="img" aria-label="서명 입력 칸. 마우스나 터치로 서명합니다."></canvas>
				<div class="row"><button type="button" id="clear">지우기</button><button type="button" class="p" id="sign">서명 완료</button></div>
			</div>
		</c:if>
		<c:if test="${canUpload}">
			<div class="box">
				<h2>서명본 파일 업로드</h2>
				<div>증서를 인쇄해 서명받은 뒤 스캔본이나 사진을 올립니다. (이미지·PDF, 20MB 이하)</div>
				<div class="row"><input type="file" id="file" accept="image/*,application/pdf" aria-label="서명본 파일"><button type="button" class="p" id="upload">업로드</button></div>
			</div>
		</c:if>
		<div id="msg" role="alert"></div>
	</div>

	<script>
	(function() {
		var group = '<c:out value="${cert.group}"/>', msg = document.getElementById('msg');
		function finish(res) {
			if (res.error) { msg.textContent = res.error; return; }
			location.reload();
		}
		function failed() { msg.textContent = '처리하지 못했습니다. 다시 로그인한 뒤 시도해 주세요.'; }

		var pad = document.getElementById('pad');
		if (pad) {
			var ctx = pad.getContext('2d'), down = false, drawn = false;
			ctx.lineWidth = 2.5; ctx.lineCap = 'round'; ctx.strokeStyle = '#111';
			function at(e) { var b = pad.getBoundingClientRect(); return [(e.clientX - b.left) * pad.width / b.width, (e.clientY - b.top) * pad.height / b.height]; }
			pad.addEventListener('pointerdown', function(e) { down = true; pad.setPointerCapture(e.pointerId); var p = at(e); ctx.beginPath(); ctx.moveTo(p[0], p[1]); });
			pad.addEventListener('pointermove', function(e) { if (!down) return; var p = at(e); ctx.lineTo(p[0], p[1]); ctx.stroke(); drawn = true; });
			pad.addEventListener('pointerup', function() { down = false; });
			document.getElementById('clear').addEventListener('click', function() { ctx.clearRect(0, 0, pad.width, pad.height); drawn = false; });
			document.getElementById('sign').addEventListener('click', function() {
				if (!document.getElementById('agree').checked) { msg.textContent = '증서 내용 동의에 체크해 주세요.'; return; }
				if (!drawn) { msg.textContent = '서명을 입력해 주세요.'; return; }
				var body = new URLSearchParams();
				body.append('group', group);
				body.append('IMG', pad.toDataURL('image/png'));
				fetch('<c:out value="${signUrl}"/>', { method: 'POST', body: body, credentials: 'same-origin' }).then(function(r) { return r.json(); }).then(finish).catch(failed);
			});
		}

		var upload = document.getElementById('upload');
		if (upload) upload.addEventListener('click', function() {
			var file = document.getElementById('file').files[0];
			if (!file) { msg.textContent = '파일을 골라 주세요.'; return; }
			if (file.size > 20 * 1024 * 1024) { msg.textContent = '20MB 이하 파일만 올릴 수 있습니다.'; return; }
			var fd = new FormData();
			fd.append('group', group);
			fd.append('file', file);
			upload.disabled = true;
			msg.textContent = '';
			fetch('/admin/equipment/uploadSignedData.do', { method: 'POST', body: fd, credentials: 'same-origin' }).then(function(r) { return r.json(); }).then(function(res) { upload.disabled = false; finish(res); }).catch(function() { upload.disabled = false; failed(); });
		});
	})();
	</script>
</body>
</html>
