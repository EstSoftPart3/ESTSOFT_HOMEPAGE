<%@ page language="java" contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html lang="ko">

<head>
   <%@ include file="/WEB-INF/include/header.jspf" %>
   <style>
	.eq-state { font-size: 12px; font-weight: 600; padding: 1px 8px; border-radius: 9px; background: #e6f6ea; color: #17692f; }
	.eq-state.bad { background: #fff5dc; color: #7a5600; }
	.eq-no { font-family: Consolas, monospace; font-size: 13px; white-space: nowrap; }
   </style>
</head>

<body>
   	<%@ include file="/WEB-INF/include/navbar.jspf" %>

    <div class="container py-5" style="min-height: 60vh;">
    	<h2 class="mb-4" style="font-weight: 700;">내 장비</h2>
    	<div id="notice" class="alert alert-warning" role="status" hidden></div>
    	<div id="signArea" class="mb-4" hidden>
    		<h5>서명 대기 대여증서</h5>
    		<ul id="signList" class="list-group"></ul>
    	</div>
    	<div class="table-responsive">
    		<table class="table align-middle">
    			<thead><tr><th>장비번호</th><th>구분</th><th>모델</th><th>대여일</th><th id="auditHead" hidden></th></tr></thead>
    			<tbody id="list"><tr><td colspan="4" class="text-center text-muted py-4">불러오는 중입니다.</td></tr></tbody>
    		</table>
    	</div>
    	<p class="small text-muted">목록에 없는 장비를 쓰고 있거나 내 장비가 아닌 항목이 있으면 담당자에게 알려 주세요.</p>
    </div>

    <%@ include file="/WEB-INF/include/footer.jspf" %>

    <script>
    <%@ include file="/WEB-INF/jsp/bo/hr/codes.jspf"%>
    var TYPE = hrCodeMap('EQP_TYPE');

    function load() {
    	$.post('/eep/equipment/myEquipmentData.do', function(res) {
    		var $body = $('#list').empty();
    		if (res.error) {
    			$body.append($('<tr>').append($('<td colspan="4" class="text-center text-muted py-4">').text(res.error)));
    			return;
    		}
    		var rows = res.list || [], audit = rows.filter(function(r) { return r.RESULT_CD; }), waiting = audit.filter(function(r) { return r.RESULT_CD === 'NONE'; });
    		$('#notice').prop('hidden', !waiting.length).text(waiting.length ? (waiting[0].AUDIT_YM + ' 장비 확인을 완료해 주세요. 미응답 ' + waiting.length + '대') : '');
    		$('#auditHead').prop('hidden', !audit.length).text(audit.length ? audit[0].AUDIT_YM + ' 확인' : '');
    		var groups = {}, $sign = $('#signList').empty();
    		rows.filter(function(r) { return r.SIGN_WAIT === 'Y'; }).forEach(function(r) { (groups[r.RENT_GROUP] = groups[r.RENT_GROUP] || []).push(r.EQP_NO); });
    		Object.keys(groups).forEach(function(g) {
    			$sign.append($('<li class="list-group-item d-flex justify-content-between align-items-center">').append($('<span class="eq-no">').text(groups[g].join(', ')))
    				.append($('<a class="btn btn-sm btn-primary">').attr('href', '/eep/equipment/certificate.do?group=' + encodeURIComponent(g)).text('증서 확인 후 서명')));
    		});
    		$('#signArea').prop('hidden', !Object.keys(groups).length);
    		if (!rows.length) { $body.append('<tr><td colspan="4" class="text-center text-muted py-4">대여 중인 장비가 없습니다.</td></tr>'); return; }
    		rows.forEach(function(r) {
    			var $tr = $('<tr>').append($('<td class="eq-no">').text(r.EQP_NO)).append($('<td>').text(TYPE[r.TYPE_CD] || r.TYPE_CD)).append($('<td>').text(r.MODEL_NM || '')).append($('<td>').text(r.START_DT || ''));
    			if (audit.length) $tr.append($('<td>').append(answer(r)));
    			$body.append($tr);
    		});
    	});
    }

    function answer(r) {
    	if (!r.RESULT_CD) return '';
    	var $w = $('<div class="d-flex gap-1 align-items-center flex-wrap">');
    	if (r.RESULT_CD !== 'NONE') $w.append($('<span class="eq-state">').toggleClass('bad', r.RESULT_CD === 'BAD').attr('title', r.NOTE || '').text(r.RESULT_CD === 'OK' ? '이상 없음' : '문제 있음'));
    	$w.append($('<button type="button" class="btn btn-sm btn-outline-primary">').text('이상 없음').on('click', function() { send(r, 'OK', ''); }));
    	$w.append($('<button type="button" class="btn btn-sm btn-outline-secondary">').text('문제 있음').on('click', function() {
    		bootbox.prompt({ title: r.EQP_NO + ' 문제 내용', inputType: 'textarea', locale: 'ko', callback: function(note) { if (note) send(r, 'BAD', note); } });
    	}));
    	return $w;
    }

    function send(r, result, note) {
    	$.post('/eep/equipment/respondData.do', { EQP_SQ: r.EQP_SQ, RESULT_CD: result, NOTE: note }, function(res) {
    		if (res.error) { bootbox.alert(res.error); return; }
    		load();
    	});
    }

    load();
    </script>
</body>
</html>
