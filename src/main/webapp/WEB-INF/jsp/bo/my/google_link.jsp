<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_head.jspf"%>
<style>
	.gl-intro { color: #5f6b75; margin-bottom: 12px; }
	.gl-need { background: #fff5dc; color: #7a5600; border-radius: 8px; padding: 10px 14px; margin-bottom: 12px; font-weight: 600; }
	.gl-cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 14px; }
	.gl-card { background: #fff; border: 1px solid rgba(17,17,17,.12); border-radius: 12px; padding: 16px; display: flex; flex-direction: column; gap: 10px; }
	.gl-card.off { border-style: dashed; }
	.gl-card.focus { box-shadow: 0 0 0 3px #e0a800; }
	.gl-head { display: flex; align-items: center; gap: 10px; }
	.gl-logo { width: 40px; height: 40px; border-radius: 10px; display: grid; place-items: center; font-weight: 800; color: #fff; flex: none; }
	.gl-logo.DRIVE { background: linear-gradient(135deg, #1fa463 0 33%, #ffd04b 33% 66%, #4688f4 66%); }
	.gl-logo.CALENDAR { background: #4688f4; }
	.gl-head .t { font-weight: 700; font-size: 15px; } .gl-head .d { color: #5f6b75; font-size: 12px; }
	.gl-state { margin-left: auto; font-size: 11.5px; font-weight: 700; border-radius: 999px; padding: 1px 10px; white-space: nowrap; }
	.gl-state.ok { background: #e6f6ea; color: #17692f; } .gl-state.no { background: #eef1f4; color: #444; }
	.gl-acct { background: #f6f8fa; border-radius: 8px; padding: 7px 10px; font-size: 13px; }
	.gl-scope { font-size: 12.5px; color: #444; margin: 0; padding-left: 18px; }
	.gl-uses { display: flex; flex-wrap: wrap; gap: 4px; } .gl-uses span { font-size: 11px; border: 1px solid #b9dbe6; background: #eef9fc; color: #0b6e8a; border-radius: 10px; padding: 0 8px; }
	.gl-foot { display: flex; align-items: center; gap: 6px; border-top: 1px solid rgba(17,17,17,.1); padding-top: 10px; font-size: 12px; color: #5f6b75; }
	.gl-foot .gl-help { margin-right: auto; background: none; border: 0; color: #0b6e8a; font-weight: 700; padding: 0; }
	/* 가이드 창 */
	.gl-guide .modal-body { display: grid; grid-template-columns: 190px 1fr; padding: 0; min-height: 360px; }
	.gl-steps { border-right: 1px solid rgba(17,17,17,.1); background: #fafbfc; padding: 8px 0; }
	.gl-steps button { display: flex; gap: 8px; align-items: center; width: 100%; border: 0; background: none; text-align: left; padding: 8px 14px; font-size: 13px; color: #5f6b75; }
	.gl-steps .n { width: 20px; height: 20px; border-radius: 999px; border: 1px solid rgba(17,17,17,.15); display: inline-grid; place-items: center; font-size: 11px; background: #fff; flex: none; }
	.gl-steps .done { color: #17692f; } .gl-steps .done .n { background: #17692f; border-color: #17692f; color: #fff; }
	.gl-steps .on { color: #111; font-weight: 700; background: #eef9fc; } .gl-steps .on .n { background: #0b6e8a; border-color: #0b6e8a; color: #fff; }
	.gl-view { padding: 14px 16px; }
	.gl-view h6 { font-weight: 700; font-size: 15px; } .gl-view ul { font-size: 13px; padding-left: 18px; }
	.gl-warn { background: #fff5dc; color: #7a5600; border-radius: 8px; padding: 6px 10px; font-size: 12.5px; margin-top: 8px; }
	.gl-shot { position: relative; border: 1px solid #dadce0; border-radius: 8px; overflow: hidden; background: #fff; margin-bottom: 10px; }
	.gl-shot img { display: block; width: 100%; }
	.gl-pin { position: absolute; border: 3px solid #e0a800; border-radius: 8px; }
	.gl-pin b { position: absolute; top: -12px; left: -12px; background: #e0a800; color: #111; width: 22px; height: 22px; border-radius: 999px; display: grid; place-items: center; font-size: 12px; }
	.gl-g { padding: 14px 16px; font-size: 13px; color: #202124; }
	.gl-g .gt { font-size: 17px; margin: 6px 0 4px; } .gl-g .lnk { color: #1a73e8; font-weight: 600; position: relative; }
	.gl-g .gb { display: inline-block; background: #1a73e8; color: #fff; border-radius: 18px; padding: 4px 16px; font-weight: 600; font-size: 12.5px; position: relative; }
	.gl-g .gb.l { background: #fff; color: #1a73e8; border: 1px solid #dadce0; }
	.gl-g .acc { display: flex; gap: 10px; align-items: center; border-bottom: 1px solid #e0e0e0; padding: 8px 2px; position: relative; }
	.gl-g .av { width: 26px; height: 26px; border-radius: 999px; background: #c8d7f5; display: grid; place-items: center; font-size: 12px; color: #1a4b9c; font-weight: 700; }
	.gl-g .perm { display: flex; gap: 8px; border: 1px solid #e0e0e0; border-radius: 8px; padding: 8px; margin: 6px 0; position: relative; }
	.gl-g .cb { width: 16px; height: 16px; border-radius: 3px; background: #1a73e8; color: #fff; font-size: 11px; display: grid; place-items: center; flex: none; margin-top: 2px; }
	.gl-admin summary { cursor: pointer; font-weight: 700; color: #0b6e8a; }
	.gl-admin ol { font-size: 13px; padding-left: 18px; } .gl-admin code { background: #eef1f4; border-radius: 4px; padding: 0 5px; }
	@media (max-width: 767px) { .gl-guide .modal-body { grid-template-columns: 1fr; } .gl-steps { border-right: 0; border-bottom: 1px solid rgba(17,17,17,.1); } }
</style>
<%@ include file="/WEB-INF/jsp/bo/boinclude/page_open.jspf"%>
				<div class="card-header"><h3 class="card-title bTitle"><b>내 연동</b></h3></div>
				<div class="card-body">
					<div class="gl-intro">내 구글 계정을 한 번 연결해 두면 아래 기능이 내 계정으로 동작합니다. 다른 관리자의 연동은 보이지 않습니다.</div>
					<div id="glNeed" class="gl-need" hidden></div>
					<div id="glCards" class="gl-cards"></div>
					<c:if test="${superUser}">
					<details class="gl-admin mt-4">
						<summary>관리자 설정 안내 (구글 클라우드 콘솔, 처음 한 번)</summary>
						<ol class="mt-2">
							<li>console.cloud.google.com → 지금 쓰는 프로젝트 → <b>API 및 서비스 → 사용자 인증 정보</b> → 쓰고 있는 OAuth 클라이언트</li>
							<li>「승인된 리디렉션 URI」에 <code id="glRedirect"></code> 가 있는지 확인(예전부터 등록된 주소, 없으면 추가하고 저장)</li>
							<li><b>OAuth 동의 화면 → 대상</b>: 게시 상태가 '테스트'면 연결할 직원 구글 메일을 「테스트 사용자」에 추가(최대 100명). 전 직원이 쓰려면 「앱 게시」</li>
							<li><b>API 라이브러리</b>에서 Google Drive API · Google Calendar API 가 「사용」인지 확인</li>
							<li>클라이언트 ID·시크릿은 <a href="/admin/batch/openInterviewBatch.do">배치 &gt; 신입면접</a> 화면에서 넣습니다(모든 내 연동 공통)</li>
							<li>직원 서류·연구일지는 각자 계정으로 같은 회사 폴더에 올리므로, 연결하는 사람의 구글 계정에 '2. 인사관리' 등 폴더 편집 권한이 있어야 합니다</li>
						</ol>
					</details>
					</c:if>
				</div>
<%@ include file="/WEB-INF/jsp/bo/boinclude/page_close.jspf"%>

	<div class="modal fade gl-guide" id="glGuide" tabindex="-1" role="dialog" aria-labelledby="glGuideTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="glGuideTitle"></h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<div class="modal-body"><div class="gl-steps" id="glSteps" role="tablist"></div><div class="gl-view" id="glView" role="tabpanel"></div></div>
				<div class="modal-footer">
					<label class="mr-auto small text-muted mb-0" id="glSkipBox"><input type="checkbox" id="glSkip"> 다음부터 바로 구글로 이동</label>
					<button type="button" class="btn btn-sm btn-outline-secondary" id="glPrev">이전</button>
					<button type="button" class="btn btn-sm btn-outline-primary" id="glNext">다음</button>
					<button type="button" class="btn btn-sm btn-primary" id="glGo">구글로 이동해 연결</button>
				</div>
			</div>
		</div>
	</div>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_script.jspf"%>
<script>
	var SVC = {
		DRIVE: { nm: 'Google Drive', d: '파일 올리기·읽기', logo: '▲', scope: ['회사 폴더에 서류·이력서·연구일지 PDF 를 올리고 읽기', '연결한 계정 메일 보기'], uses: ['직원 서류', '장비 첨부', '거래처 서류 읽기', '연구일지 PDF', '면접 배치 이력서'],
			perm: 'Google Drive의 모든 파일 보기, 수정, 생성, 삭제' },
		CALENDAR: { nm: 'Google Calendar', d: '일정 읽기', logo: '31', scope: ['내 캘린더 일정 읽기만 (고치지 않음)', '연결한 계정 메일 보기'], uses: ['캘린더 일정 가져오기'],
			perm: 'Google Calendar를 사용하여 액세스할 수 있는 모든 캘린더 보기' }
	};
	var q = new URLSearchParams(location.search), back = q.get('back') || '', focusSvc = q.get('svc');
	var SKIP_KEY = 'glGuideSkip';
	function skip(v) { try { if (v === undefined) return localStorage.getItem(SKIP_KEY) === '1'; localStorage.setItem(SKIP_KEY, v ? '1' : '0'); } catch (e) { return false; } }

	$(function() {
		$('#glRedirect').text(location.origin.replace(/^http:/, 'https:') + '/admin/batch/driveCallback.do');
		if (q.get('need') && SVC[focusSvc]) $('#glNeed').prop('hidden', false).text(SVC[focusSvc].nm + ' 연동이 필요한 기능입니다. 아래에서 연결하면 하던 화면으로 돌아갑니다.');
		var msg = { ok: '연결했습니다.', fail: '연결하지 못했습니다. 다시 시도해 주세요.', denied: '구글에서 연결을 취소했습니다.',
			scope: '구글 동의 화면에서 권한 체크가 빠져 연결하지 않았습니다. 다시 연결하면서 권한 항목을 체크해 주세요.',
			noclient: '구글 OAuth 클라이언트가 설정되지 않았습니다. 관리자에게 문의해 주세요.' }[q.get('result')];
		if (msg) bootbox.alert((SVC[focusSvc] ? SVC[focusSvc].nm + ' ' : '') + msg);
		load();
	});

	function load() {
		hrPost('/admin/my/googleLinkData.do', {}, function(res) {
			var $c = $('#glCards').empty();
			res.result.forEach(function(l) {
				var s = SVC[l.SERVICE_CD]; if (!s) return;
				var $card = $('<div class="gl-card">').toggleClass('off', !l.LINKED).toggleClass('focus', l.SERVICE_CD === focusSvc);
				$card.append($('<div class="gl-head">').append($('<div class="gl-logo">').addClass(l.SERVICE_CD).text(s.logo))
					.append($('<div>').append($('<div class="t">').text(s.nm)).append($('<div class="d">').text(s.d)))
					.append($('<span class="gl-state">').addClass(l.LINKED ? 'ok' : 'no').text(l.LINKED ? '● 연결됨' : '연결 안 됨')));
				if (l.LINKED) $card.append($('<div class="gl-acct">').text(l.ACCOUNT || '연결됨'));
				$card.append($('<ul class="gl-scope">').append(s.scope.map(function(x) { return $('<li>').text(x); })));
				$card.append($('<div class="gl-uses">').append(s.uses.map(function(x) { return $('<span>').text(x); })));
				var $f = $('<div class="gl-foot">').append($('<button type="button" class="gl-help">').text('? 연결 방법 보기').on('click', function() { guide(l.SERVICE_CD, false); }));
				if (l.LINKED) {
					$f.append($('<span>').text(l.REG_DT + ' 연결'));
					$f.append($('<button type="button" class="btn btn-sm btn-outline-primary">').text('다시 연결').on('click', function() { start(l.SERVICE_CD); }));
					$f.append($('<button type="button" class="btn btn-sm btn-outline-danger">').text('연결 해제').on('click', function() { unlink(l.SERVICE_CD); }));
				} else {
					$f.append($('<button type="button" class="btn btn-sm btn-primary">').text('연결').on('click', function() { start(l.SERVICE_CD); }));
				}
				$c.append($card.append($f));
			});
		});
	}

	function go(svc) { location.href = '/admin/my/googleStart.do?svc=' + svc + (back ? '&back=' + encodeURIComponent(back) : ''); }
	// 처음 연결은 가이드를 먼저 보여 주고, '다음부터 바로'를 고른 사람은 바로 구글로
	function start(svc) { if (skip()) go(svc); else guide(svc, true); }

	function unlink(svc) {
		bootbox.confirm(SVC[svc].nm + ' 연결을 해제할까요? 이 연동을 쓰는 기능은 다시 연결할 때까지 동작하지 않습니다.' + (svc === 'DRIVE' ? ' 면접 배치를 이 계정으로 연결해 두었다면 배치도 이력서를 못 읽습니다.' : ''), function(ok) {
			if (ok) hrPost('/admin/my/googleUnlinkData.do', { svc: svc }, load);
		});
	}

	// ── 연결 가이드: 왼쪽 단계, 오른쪽 화면(누를 곳은 노란 테두리+번호) ──
	function pin(style, n) { return '<span class="gl-pin" style="' + style + '"><b>' + n + '</b></span>'; }
	function steps(svc) {
		var s = SVC[svc];
		return [
			{ t: '구글 계정 로그인', h: '1. 회사 업무용 구글 계정으로 로그인',
				shot: '<img src="/resources/bo/img/guide/google-signin.jpg" alt="구글 로그인 화면">' + pin('left:52%;top:15%;width:45%;height:11%', 1) + pin('left:87%;top:48%;width:10%;height:8%', 2),
				li: ['① 회사 업무에 쓰는 구글 계정 메일을 넣고', '② 「다음」 → 비밀번호 입력', '이미 브라우저에 로그인돼 있으면 이 화면 없이 2단계로 넘어갑니다.'],
				warn: '개인 계정으로 연결하면 올린 파일의 주인이 개인 계정이 됩니다. 회사 계정을 쓰세요.' },
			{ t: '계정 고르기', h: '2. 연결할 계정 고르기',
				shot: '<div class="gl-g"><div class="gt">계정 선택</div><div class="text-muted small mb-1">이에스티소프트 관리자(으)로 이동</div><div class="acc"><span class="av">홍</span><div>홍길동<br><small class="text-muted">회사 업무용 계정</small></div>' + pin('inset:2px -4px', 1) + '</div><div class="acc"><span class="av">개</span><div>개인 계정<br><small class="text-muted">개인 메일</small></div></div></div>',
				li: ['① 회사 업무용 계정을 누릅니다.', '계정이 하나뿐이면 이 화면은 나오지 않습니다.'] },
			{ t: '확인되지 않은 앱 경고', h: '3. 「Google에서 확인하지 않은 앱」이 나오면',
				shot: '<div class="gl-g"><div style="color:#d93025;font-size:26px">⚠</div><div class="gt">Google에서 확인하지 않은 앱</div><div class="mt-3"><span class="lnk">고급' + pin('inset:-6px -8px', 1) + '</span></div><div class="mt-3 small"><span class="lnk">이에스티소프트 관리자(으)로 이동(안전하지 않음)' + pin('inset:-6px -8px', 2) + '</span></div></div>',
				li: ['① 「고급」 → ② 「…(으)로 이동(안전하지 않음)」', '회사 안에서만 쓰는 앱이라 구글 검수를 받지 않아 나오는 경고입니다.', '이 화면이 안 나오면 4단계로 넘어갑니다.'] },
			{ t: '권한 체크', h: '4. 권한에 체크하고 「계속」',
				shot: '<div class="gl-g"><div class="gt" style="font-size:15px">이에스티소프트 관리자에서 Google 계정에 액세스하려고 합니다</div><div class="perm"><span class="cb">✓</span><div>' + s.perm + '</div>' + pin('inset:-4px', 1) + '</div><div class="perm"><span class="cb">✓</span><div>Google 계정의 기본 이메일 주소 보기</div></div><div class="text-right mt-2"><span class="gb l">취소</span> <span class="gb">계속' + pin('inset:-6px -8px', 2) + '</span></div></div>',
				li: ['① 「' + s.perm + '」 항목에 반드시 체크', '② 「계속」'],
				warn: '체크를 빼고 넘어가면 연결되지 않고 이 화면으로 돌아옵니다.' },
			{ t: '연결 완료', h: '5. 내 연동으로 돌아와 「연결됨」 확인',
				shot: '<div class="gl-g" style="background:#f6f8fa"><div style="background:#fff;border:1px solid #e0e0e0;border-radius:10px;padding:10px;display:flex;gap:10px;align-items:center"><div class="gl-logo ' + svc + '" style="width:28px;height:28px;font-size:12px">' + s.logo + '</div><b>' + s.nm + '</b><span class="gl-state ok">● 연결됨</span></div><div class="small text-muted mt-1">연결한 계정 메일이 보이면 끝</div></div>',
				li: ['카드에 연결한 계정 메일이 보이면 끝입니다.', '기능 화면에서 넘어왔다면 그 화면으로 바로 돌아갑니다.', '안 될 때: 「403 access_denied」는 관리자에게 테스트 사용자 추가를, 「redirect_uri_mismatch」는 콘솔 설정을 요청하세요.'] }
		];
	}

	var gSvc = null, gAt = 0, gList = [];
	function guide(svc, connecting) {
		gSvc = svc; gAt = 0; gList = steps(svc);
		$('#glGuideTitle').text(SVC[svc].nm + ' 연결 방법');
		$('#glGo, #glSkipBox').toggle(connecting);
		$('#glSkip').prop('checked', skip());
		paintGuide();
		$('#glGuide').modal('show');
	}
	function paintGuide() {
		$('#glSteps').empty().append(gList.map(function(st, i) {
			return $('<button type="button" role="tab">').attr('aria-selected', i === gAt).toggleClass('on', i === gAt).toggleClass('done', i < gAt)
				.append($('<span class="n">').text(i < gAt ? '✓' : i + 1)).append($('<span>').text(st.t)).on('click', function() { gAt = i; paintGuide(); });
		}));
		var st = gList[gAt], $v = $('#glView').empty().append($('<h6>').text(st.h)).append($('<div class="gl-shot">').html(st.shot))
			.append($('<ul>').append(st.li.map(function(x) { return $('<li>').text(x); })));
		if (st.warn) $v.append($('<div class="gl-warn">').text(st.warn));
		$('#glPrev').prop('disabled', gAt === 0);
		$('#glNext').prop('disabled', gAt === gList.length - 1);
	}
	$('#glPrev').on('click', function() { if (gAt > 0) { gAt--; paintGuide(); } });
	$('#glNext').on('click', function() { if (gAt < gList.length - 1) { gAt++; paintGuide(); } });
	$('#glGo').on('click', function() { skip($('#glSkip').prop('checked')); go(gSvc); });
</script>
</body>
</html>
