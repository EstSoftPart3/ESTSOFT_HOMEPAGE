<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_head.jspf"%>
<style>
	.gl-top { display: flex; align-items: center; gap: 10px; margin-bottom: 12px; color: #5f6b75; }
	.gl-top .gl-help { margin-left: auto; background: none; border: 0; color: #0b6e8a; font-weight: 700; padding: 0; }
	.gl-need { background: #fff5dc; color: #7a5600; border-radius: 8px; padding: 10px 14px; margin-bottom: 12px; font-weight: 600; }
	.gl-cards { max-width: 640px; }
	.gl-card { display: flex; align-items: center; gap: 12px; background: #fff; border: 1px solid rgba(17,17,17,.12); border-radius: 10px; padding: 12px 14px; margin-bottom: 10px; }
	.gl-card.focus { box-shadow: 0 0 0 3px #e0a800; }
	.gl-logo { width: 34px; height: 34px; border-radius: 8px; display: grid; place-items: center; font-weight: 800; color: #fff; flex: none; font-size: 13px; }
	.gl-logo.DRIVE { background: linear-gradient(135deg, #1fa463 0 33%, #ffd04b 33% 66%, #4688f4 66%); }
	.gl-logo.CALENDAR { background: #4688f4; }
	.gl-card .t { font-weight: 700; } .gl-card .m { color: #17692f; font-size: 13px; }
	.gl-card .btn { margin-left: auto; min-width: 92px; }
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
	.gl-sec { max-width: 820px; border: 1px solid rgba(17,17,17,.12); border-radius: 10px; padding: 12px 14px; background: #fff; }
	.gl-sec-h { font-weight: 700; margin-bottom: 8px; display: flex; gap: 6px; align-items: center; }
	.gl-tag { font-size: 11px; font-weight: 700; border-radius: 999px; padding: 1px 8px; background: #eef1f4; color: #3c4650; }
	.gl-tag.CALENDAR { background: #e3edfd; color: #1a4b9c; } .gl-tag.DRIVE { background: #e6f6ea; color: #17692f; }
	.gl-admin ol { font-size: 13px; padding-left: 18px; } .gl-admin code { background: #eef1f4; border-radius: 4px; padding: 0 5px; }
	/* 단계(시스템 관리자): 1 앱 키 → 2 연결. 끝난 단계는 초록 ✓ */
	.gl-step { max-width: 640px; border: 1px solid rgba(17,17,17,.12); border-radius: 10px; background: #fff; margin-bottom: 10px; }
	.gl-step-h { display: flex; align-items: center; gap: 10px; padding: 10px 14px; }
	.gl-step-s { font-size: 12.5px; color: #5f6b75; } .gl-step-s.ok { color: #17692f; } .gl-step-s.warn { color: #7a5600; font-weight: 600; }
	.gl-num { width: 24px; height: 24px; border-radius: 999px; display: grid; place-items: center; font-size: 12px; font-weight: 800; flex: none; background: #0b6e8a; color: #fff; }
	.gl-num.done { background: #17692f; }
	.gl-step-b { border-top: 1px solid #f0f1f3; padding: 10px 14px 12px; }
	.gl-step.lock { opacity: .55; }
	.gl-step .gl-cards { max-width: none; } .gl-step .gl-card { margin-bottom: 8px; }
	@media (max-width: 767px) { .gl-guide .modal-body { grid-template-columns: 1fr; } .gl-steps { border-right: 0; border-bottom: 1px solid rgba(17,17,17,.1); } }
</style>
<%@ include file="/WEB-INF/jsp/bo/boinclude/page_open.jspf"%>
				<div class="card-header"><h3 class="card-title bTitle"><b>내 연동</b></h3></div>
				<div class="card-body">
					<div class="gl-top">회사 공용 구글 연결 하나를 모든 계정이 씁니다. 연결·해제는 시스템 관리자만 합니다.<button type="button" class="gl-help" id="glHelp">연결이 안 되나요?</button></div>
					<div id="glNeed" class="gl-need" hidden></div>
					<c:if test="${superUser}">
					<%-- 1단계 앱 키 → 2단계 연결. 앱 키가 있으면 한 줄로 접는다. 무엇을 읽을지(면접 캘린더·폴더)는 쓰는 화면에서 고른다 --%>
					<div class="gl-step" id="glStep1">
						<div class="gl-step-h"><span class="gl-num" id="glNum1">1</span><div><b>구글 앱 키</b><div class="gl-step-s" id="glClientState">확인 중…</div></div>
							<button type="button" class="gl-help ml-auto" id="glClientToggle" aria-expanded="false" aria-controls="glClient">바꾸기</button></div>
					<div class="gl-admin gl-step-b" id="glClient" hidden>
						<div class="small text-muted mb-2">「연결」 버튼이 구글에 우리 홈페이지를 알리는 열쇠입니다. <b>연결하기 전에 처음 한 번만</b> 넣고, 구글 콘솔에서 키를 새로 만들었을 때만 바꿉니다. 비운 칸은 지금 값을 그대로 둡니다.</div>
						<div class="form-row" style="max-width:780px">
							<div class="col-md-6 mb-2"><label for="glClientId" class="small font-weight-bold mb-1">OAuth 클라이언트 ID</label><input id="glClientId" class="form-control form-control-sm" autocomplete="off"></div>
							<div class="col-md-4 mb-2"><label for="glClientSecret" class="small font-weight-bold mb-1">클라이언트 시크릿</label><input id="glClientSecret" class="form-control form-control-sm" autocomplete="off"></div>
							<div class="col-md-2 mb-2 d-flex align-items-end"><button type="button" class="btn btn-sm btn-primary btn-block" id="glClientSave">저장</button></div>
						</div>
						<details class="mt-1"><summary>어디서 발급하나요?</summary>
							<ol>
								<li><a href="https://console.cloud.google.com/" target="_blank" rel="noopener">구글 클라우드 콘솔</a>에 회사 구글 계정으로 들어가 위쪽에서 프로젝트를 고릅니다(없으면 「새 프로젝트」).</li>
								<li>「API 및 서비스 → 라이브러리」에서 <b>Google Drive API</b>, <b>Google Calendar API</b>를 각각 「사용」으로 켭니다.</li>
								<li>「OAuth 동의 화면」: 사용자 유형 「외부」, 앱 이름·지원 메일 입력. 게시 상태가 「테스트」면 「테스트 사용자」에 연결할 구글 메일을 추가합니다.</li>
								<li>「사용자 인증 정보 → 사용자 인증 정보 만들기 → OAuth 클라이언트 ID」, 유형 「웹 애플리케이션」.</li>
								<li>「승인된 리디렉션 URI」에 <code id="glRedirect"></code> 를 글자 그대로 추가하고 「만들기」.</li>
								<li>뜨는 창의 <b>클라이언트 ID</b>(…apps.googleusercontent.com)와 <b>클라이언트 보안 비밀번호</b>(GOCSPX-…)를 위 칸에 붙여 넣고 저장합니다.</li>
							</ol>
						</details>
					</div>
					</div>
					<div class="gl-step" id="glStep2">
						<div class="gl-step-h"><span class="gl-num" id="glNum2">2</span><div><b>구글 연결</b><div class="gl-step-s">회사 공용 계정 하나로 드라이브·캘린더를 연결합니다</div></div></div>
						<div class="gl-step-b">
					</c:if>
					<div id="glCards" class="gl-cards"></div>
					<c:if test="${superUser}">
							<div class="small text-muted mt-1">이 연결을 쓰는 곳: <a href="/admin/batch/openInterviewBatch.do">신입면접 배치</a>(면접 캘린더·이력서 폴더는 그 화면에서 고름) · 직원 서류 · 장비 · 거래처 · 연구일지. 폴더·파일 이름 규칙은 각 화면의 ⚙ 드라이브 설정에서 정합니다.</div>
						</div>
					</div>
					</c:if>
				</div>
<%@ include file="/WEB-INF/jsp/bo/boinclude/page_close.jspf"%>

	<div class="modal fade gl-guide" id="glGuide" tabindex="-1" role="dialog" aria-labelledby="glGuideTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header"><h5 class="modal-title" id="glGuideTitle"></h5><button type="button" class="close" data-dismiss="modal" aria-label="닫기"><span aria-hidden="true">&times;</span></button></div>
				<div class="modal-body"><div class="gl-steps" id="glSteps" role="tablist"></div><div class="gl-view" id="glView" role="tabpanel"></div></div>
				<div class="modal-footer">
					<button type="button" class="btn btn-sm btn-outline-secondary" id="glPrev">이전</button>
					<button type="button" class="btn btn-sm btn-outline-primary" id="glNext">다음</button>
				</div>
			</div>
		</div>
	</div>

<%@ include file="/WEB-INF/jsp/bo/boinclude/page_script.jspf"%>
<script>
	var SVC = {
		DRIVE: { nm: 'Google Drive', logo: '▲', perm: 'Google Drive의 모든 파일 보기, 수정, 생성, 삭제' },
		CALENDAR: { nm: 'Google Calendar', logo: '31', perm: 'Google Calendar를 사용하여 액세스할 수 있는 모든 캘린더 보기' }
	};
	var IS_ADMIN = ${superUser == true};
	var q = new URLSearchParams(location.search), back = q.get('back') || '', focusSvc = q.get('svc');

	$(function() {
		// 도움말 가이드는 '연결이 안 되나요?'를 누를 때만. 기능 화면에서 넘어왔으면 그 서비스, 아니면 드라이브
		$('#glHelp').on('click', function() { guide(SVC[focusSvc] ? focusSvc : 'DRIVE'); });
		// 구글 앱 설정(슈퍼관리자): 저장값은 가려서 안내문으로만 보여 준다
		if ($('#glClient').length) {
			// 1단계: 앱 키가 있으면 「✓ 설정됨」 한 줄로 접고, 없으면 펼치고 2단계(연결)를 흐리게
			var client = function(d) {
				var set = !!d.clientReady;
				$('#glClientId').val('').attr('placeholder', d.clientMask || '…apps.googleusercontent.com');
				$('#glClientSecret').val('').attr('placeholder', d.secretMask || 'GOCSPX-…');
				$('#glNum1').toggleClass('done', set).text(set ? '✓' : '1');
				$('#glClientState').attr('class', 'gl-step-s ' + (set ? 'ok' : 'warn')).text(set ? '설정됨 · ' + d.clientMask : '아직 없음 · 연결하기 전에 먼저 넣어 주세요');
				$('#glClient').prop('hidden', set);
				$('#glClientToggle').prop('hidden', !set).text('바꾸기').attr('aria-expanded', !set);
				$('#glStep2').toggleClass('lock', !set);
			};
			hrPost('/admin/my/googleClientData.do', {}, function(res) { client(res.result); });
			$('#glClientToggle').on('click', function() {
				var open = $('#glClient').prop('hidden');
				$('#glClient').prop('hidden', !open);
				$(this).text(open ? '접기' : '바꾸기').attr('aria-expanded', open);
			});
			$('#glClientSave').on('click', function() {
				hrPost('/admin/my/saveGoogleClientData.do', { clientId: $('#glClientId').val(), clientSecret: $('#glClientSecret').val() }, function(res) { client(res.result); hrToast('구글 앱 키를 저장했습니다.'); });
			});
		}
		$('#glRedirect').text(location.origin.replace(/^http:/, 'https:') + '/admin/batch/driveCallback.do');
		if (q.get('need') && SVC[focusSvc]) $('#glNeed').prop('hidden', false).text(SVC[focusSvc].nm + (IS_ADMIN ? ' 연동이 필요한 기능입니다. 아래에서 연결하면 하던 화면으로 돌아갑니다.' : ' 회사 공용 연결이 없어 쓸 수 없습니다. 시스템 관리자에게 연결을 요청해 주세요.'));
		var msg = { ok: '연결했습니다.', fail: '연결하지 못했습니다. 다시 시도해 주세요.', denied: '구글에서 연결을 취소했습니다.',
			scope: '구글 동의 화면에서 권한 체크가 빠져 연결하지 않았습니다. 다시 연결하면서 권한 항목을 체크해 주세요.',
			noclient: '구글 OAuth 클라이언트가 설정되지 않았습니다. 관리자에게 문의해 주세요.', admin: '회사 공용 연결이라 시스템 관리자만 연결할 수 있습니다.' }[q.get('result')];
		if (msg) bootbox.alert((SVC[focusSvc] ? SVC[focusSvc].nm + ' ' : '') + msg);
		load();
	});

	function load() {
		hrPost('/admin/my/googleLinkData.do', {}, function(res) {
			var $c = $('#glCards').empty();
			res.result.forEach(function(l) {
				var s = SVC[l.SERVICE_CD]; if (!s) return;
				// 한 줄: 로고 · 이름(연결되면 초록 점 + 계정 메일) · 버튼 하나
				var $name = $('<div>').append($('<div class="t">').text(s.nm));
				if (l.LINKED) $name.append($('<div class="m">').text('● ' + (l.ACCOUNT || '연결됨')));
				var $btn = !IS_ADMIN ? $('<span class="text-muted small ml-auto">').text(l.LINKED ? '' : '시스템 관리자가 연결합니다')
					: l.LINKED ? $('<button type="button" class="btn btn-sm btn-outline-danger">').text('연결 해제').attr('aria-label', s.nm + ' 연결 해제').on('click', function() { unlink(l.SERVICE_CD); })
					: $('<button type="button" class="btn btn-sm btn-primary">').text('연결').attr('aria-label', s.nm + ' 연결').on('click', function() { go(l.SERVICE_CD); });
				$c.append($('<div class="gl-card">').toggleClass('focus', l.SERVICE_CD === focusSvc)
					.append($('<div class="gl-logo">').addClass(l.SERVICE_CD).text(s.logo)).append($name).append($btn));
			});
		});
	}

	// 「연결」은 바로 구글로 간다
	function go(svc) { location.href = '/admin/my/googleStart.do?svc=' + svc + (back ? '&back=' + encodeURIComponent(back) : ''); }

	function unlink(svc) {
		bootbox.confirm(SVC[svc].nm + ' 회사 공용 연결을 해제할까요? 모든 계정에서 이 연동을 쓰는 기능(면접 배치 포함)이 다시 연결할 때까지 동작하지 않습니다.', function(ok) {
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
				shot: '<div class="gl-g" style="background:#f6f8fa"><div class="gl-card" style="margin:0"><div class="gl-logo ' + svc + '">' + s.logo + '</div><div><div class="t">' + s.nm + '</div><div class="m">● 내 구글 계정 메일</div></div><span class="btn btn-sm btn-outline-danger">연결 해제</span></div></div>',
				li: ['이름 아래 초록 점과 계정 메일이 보이면 끝입니다.', '기능 화면에서 넘어왔다면 그 화면으로 바로 돌아갑니다.', '안 될 때: 「403 access_denied」는 관리자에게 테스트 사용자 추가를, 「redirect_uri_mismatch」는 콘솔 설정을 요청하세요.'] }
		];
	}

	var gAt = 0, gList = [];
	function guide(svc) {
		gAt = 0; gList = steps(svc);
		$('#glGuideTitle').text(SVC[svc].nm + ' 연결 방법');
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
</script>
</body>
</html>
