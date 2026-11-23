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
	/* 휴대폰 알림(텔레그램) */
	.gl-logo.TG { background: #2aa3df; font-size: 16px; }
	.tg-l { font-size: 12.5px; color: #5f6b75; margin: 10px 0 4px; }
	.tg-chip { display: inline-flex; align-items: center; gap: 5px; border: 1px solid rgba(17,17,17,.18); border-radius: 999px; padding: 3px 12px; margin: 0 4px 4px 0; font-size: 13px; cursor: pointer; background: #fff; min-height: 32px; }
	.tg-chip.on { background: #e8f4fb; border-color: #2aa3df; color: #0f6c99; font-weight: 600; }
	.tg-chip input { margin: 0; }
	.tg-row { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; }
	.tg-wait { background: #fff5dc; color: #7a5600; border-radius: 8px; padding: 8px 12px; font-size: 13px; margin-top: 8px; }
	.tg-qr { background: #fff; padding: 6px; border: 1px solid #e0e0e0; border-radius: 6px; display: inline-block; margin-top: 6px; }
	.gl-g .tgm { background: #dfe8ee; border-radius: 8px; padding: 10px; display: flex; flex-direction: column; gap: 6px; }
	.gl-g .tgm .b { background: #fff; border-radius: 10px; padding: 6px 9px; max-width: 88%; position: relative; font-size: 12.5px; }
	.gl-g .tgm .me { align-self: flex-end; background: #e1f7c9; }
	.gl-g .tgbar { background: #fff; border: 1px solid #ccd; border-radius: 8px; padding: 6px 10px; color: #8a949e; position: relative; margin-top: 6px; }
	.gl-g .tgstart { display: block; text-align: center; background: #fff; color: #2aa3df; font-weight: 700; border-radius: 8px; padding: 8px; position: relative; margin-top: 6px; }
	.gl-g .tgbtn { display: block; text-align: center; background: #f0f6fb; color: #1a73b0; border-radius: 6px; padding: 3px; margin-top: 5px; }
	@media (max-width: 767px) { .gl-guide .modal-body { grid-template-columns: 1fr; } .gl-steps { border-right: 0; border-bottom: 1px solid rgba(17,17,17,.1); } }
</style>
<%@ include file="/WEB-INF/jsp/bo/boinclude/page_open.jspf"%>
				<div class="card-header"><h3 class="card-title bTitle"><b>내 연동</b></h3></div>
				<div class="card-body">
					<div class="gl-top">회사 공용 구글 연결 하나를 모든 계정이 씁니다(연결·해제는 시스템 관리자). 아래 휴대폰 알림은 각자 연결합니다.<button type="button" class="gl-help" id="glHelp">연결이 안 되나요?</button></div>
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
							<div class="small text-muted mt-1">이 연결을 쓰는 곳: <a href="/admin/batch/openInterviewBatch.do">면접 배치</a>(면접 캘린더·이력서 폴더는 그 화면에서 고름) · 직원 서류 · 장비 · 거래처 · 연구일지. 폴더·파일 이름 규칙은 각 화면의 ⚙ 드라이브 설정에서 정합니다.</div>
						</div>
					</div>
					</c:if>
					<%-- 휴대폰 알림(텔레그램): 봇은 시스템 관리자가 한 번, 연결·설정은 각자 --%>
					<div class="gl-step mt-3" id="tgBox">
						<div class="gl-step-h"><span class="gl-logo TG">✈</span><div><b>휴대폰 알림 (텔레그램)</b><div class="gl-step-s" id="tgState">확인 중…</div></div>
							<button type="button" class="gl-help ml-auto" id="tgHelp">연결 방법</button></div>
						<c:if test="${superUser}">
						<div class="gl-step-b" id="tgBot">
							<div class="d-flex align-items-center" style="gap:8px"><b class="small">알림 봇</b><span class="gl-step-s" id="tgBotState"></span>
								<button type="button" class="gl-help ml-auto" id="tgBotToggle">바꾸기</button></div>
							<div id="tgBotForm" hidden>
								<div class="small text-muted my-1">텔레그램 앱의 <b>@BotFather</b> 에서 봇을 만들고 받은 토큰을 넣습니다. 처음 한 번만 하면 모든 관리자가 이 봇으로 알림을 받습니다. <button type="button" class="gl-help" id="tgBotHelp">봇 만드는 방법 보기</button></div>
								<div class="form-row" style="max-width:620px">
									<div class="col-md-9 mb-1"><label for="tgToken" class="sr-only">봇 토큰</label><input id="tgToken" type="password" class="form-control form-control-sm" autocomplete="off" placeholder="123456789:AA… (BotFather 가 준 토큰)"></div>
									<div class="col-md-3 mb-1"><button type="button" class="btn btn-sm btn-primary btn-block" id="tgBotSave">확인 후 저장</button></div>
								</div>
							</div>
						</div>
						</c:if>
						<div class="gl-step-b" id="tgLink"></div>
						<div class="gl-step-b" id="tgConf" hidden>
							<div class="tg-l">일정 몇 분 전에 받을 일정</div><div id="tgKinds"></div>
							<div class="tg-l">몇 분 전</div>
							<div class="btn-group btn-group-sm" role="group" aria-label="몇 분 전" id="tgBefore"><button type="button" class="btn btn-outline-secondary" data-v="10">10분</button><button type="button" class="btn btn-outline-secondary" data-v="30">30분</button><button type="button" class="btn btn-outline-secondary" data-v="60">60분</button></div>
							<div class="tg-l">시간이 바뀌거나 취소되면 바로 알림 <span class="text-muted">(기본 끔)</span></div><div id="tgChange"></div>
							<div class="mt-2"><button type="button" class="btn btn-sm btn-primary" id="tgConfSave">설정 저장</button></div>
						</div>
					</div>
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

	// ── 휴대폰 알림(텔레그램) ──
	var tg = null, tgWaitTimer = null, IS_PHONE = /Android|iPhone|iPad|iPod/i.test(navigator.userAgent);
	$(function() {
		tgLoad();
		$('#tgHelp').on('click', function() { guide('TG_LINK'); });
		$('#tgBotHelp').on('click', function() { guide('TG_BOT'); });
		$('#tgBotToggle').on('click', function() { var open = $('#tgBotForm').prop('hidden'); $('#tgBotForm').prop('hidden', !open); $(this).text(open ? '접기' : '바꾸기'); });
		$('#tgBotSave').on('click', function() {
			var t = $.trim($('#tgToken').val());
			if (!t) { bootbox.alert('BotFather 가 준 토큰을 붙여 넣어 주세요.'); return; }
			var $b = $(this).prop('disabled', true).text('텔레그램에 확인 중…');
			hrPost('/admin/my/tgSaveBotData.do', { token: t }, function() { $('#tgToken').val(''); hrToast('알림 봇을 저장했습니다.'); tgLoad(); $b.prop('disabled', false).text('확인 후 저장'); },
				function() { $b.prop('disabled', false).text('확인 후 저장'); });
		});
		$('#tgBefore').on('click', 'button', function() { $('#tgBefore button').removeClass('active'); $(this).addClass('active'); });
		$('#tgConfSave').on('click', function() {
			hrPost('/admin/my/tgSaveConfData.do', { kinds: tgChecked('#tgKinds'), before: $('#tgBefore .active').data('v') || 30, changeKinds: tgChecked('#tgChange') }, function(res) { tgPaint(res.result); hrToast('알림 설정을 저장했습니다.'); });
		});
		$(document).on('change', '.tg-chip input', function() { $(this).closest('.tg-chip').toggleClass('on', this.checked); });
	});
	function tgChecked(box) { return $(box).find('input:checked').map(function() { return this.value; }).get().join(','); }
	function tgLoad() { hrPost('/admin/my/tgData.do', {}, function(res) { tgPaint(res.result); }); }

	function tgPaint(d) {
		tg = d;
		var bot = d.bot || {}, l = d.link, on = l && l.STATUS_CD === 'ON';
		$('#tgBotState').attr('class', 'gl-step-s ' + (bot.ready ? 'ok' : 'warn')).text(bot.ready ? '✓ @' + bot.name + ' · 토큰 ' + bot.mask : '아직 없음 · 먼저 봇을 만들어 토큰을 넣어 주세요');
		if (!bot.ready) { $('#tgBotForm').prop('hidden', false); $('#tgBotToggle').prop('hidden', true); } else { $('#tgBotToggle').prop('hidden', false); }
		$('#tgState').attr('class', 'gl-step-s ' + (on ? 'ok' : '')).text(!bot.ready ? '시스템 관리자의 봇 설정이 필요합니다' : on ? '● 연결됨 · ' + (l.TG_USER_NM || '') + ' · ' + l.LINK_DT : '면접·인터뷰·내 할 일 몇 분 전에 내 휴대폰이 울립니다 (나만)');
		var $l = $('#tgLink').empty();
		if (!bot.ready) {
			$l.append($('<div class="small text-muted">').text(IS_ADMIN ? '위 「알림 봇」에 토큰을 넣으면 연결 버튼이 나타납니다.' : '관리자 설정이 필요합니다. 시스템 관리자가 알림 봇을 설정하면 여기서 연결할 수 있습니다.'));
		} else if (on) {
			$l.append($('<div class="tg-row">')
				.append($('<button type="button" class="btn btn-sm btn-outline-primary" id="tgTest">').text('시험 알림 보내기').on('click', function() { hrPost('/admin/my/tgTestData.do', {}, function() { hrToast('보냈습니다. 휴대폰을 확인해 주세요.'); }); }))
				.append($('<button type="button" class="btn btn-sm btn-outline-secondary">').text('다른 휴대폰으로 바꾸기').on('click', tgStart))
				.append($('<button type="button" class="btn btn-sm btn-outline-danger" id="tgUnlink">').text('연결 끊기').on('click', function() {
					bootbox.confirm('텔레그램 알림 연결을 끊을까요? 다시 연결할 때까지 알림이 오지 않습니다.', function(ok) { if (ok) hrPost('/admin/my/tgUnlinkData.do', {}, function(res) { tgPaint(res.result); }); });
				})));
		} else {
			$l.append($('<div class="tg-row">').append($('<button type="button" class="btn btn-sm btn-primary" id="tgStart" style="background:#2aa3df;border-color:#2aa3df">').text('✈ 텔레그램 연결').on('click', tgStart))
				.append($('<span class="small text-muted">').text('휴대폰에 텔레그램이 있어야 합니다.')));
		}
		// 설정: 연결됐을 때만. 볼 권한이 있는 종류만 칩으로
		$('#tgConf').prop('hidden', !on);
		if (on) {
			var kinds = (l.KINDS || '').split(','), ch = (l.CHANGE_KINDS || '').split(',');
			var chip = function(k, list) { var c = list.indexOf(k.cd) >= 0; return $('<label class="tg-chip">').toggleClass('on', c).append($('<input type="checkbox">').val(k.cd).prop('checked', c)).append(document.createTextNode(k.nm)); };
			$('#tgKinds').empty().append(d.kinds.map(function(k) { return chip(k, kinds); }));
			$('#tgChange').empty().append(d.kinds.filter(function(k) { return k.change; }).map(function(k) { return chip(k, ch); }));
			if (!$('#tgChange').children().length) $('#tgChange').append('<span class="small text-muted">면접·모집 화면 권한이 있을 때 고를 수 있습니다.</span>');
			$('#tgBefore button').removeClass('active').filter('[data-v="' + l.BEFORE_MIN + '"]').addClass('active');
		}
	}

	// 1회용 코드 링크를 열고, 봇에서 「시작」을 누를 때까지 3초마다 확인(최대 10분)
	function tgStart() {
		var w = IS_PHONE ? null : window.open('about:blank', '_blank'); // 팝업 차단을 피하려고 클릭 순간에 연다
		hrPost('/admin/my/tgStartData.do', {}, function(res) {
			var url = res.result;
			if (IS_PHONE) location.href = url; else if (w) w.location = url;
			var $w = $('<div class="tg-wait" id="tgWait">').append($('<div>').html('휴대폰 텔레그램에서 봇 대화가 열리면 <b>「시작」</b>을 눌러 주세요. 연결되면 여기가 바로 바뀝니다. (10분 안)'));
			if (!IS_PHONE) {
				$w.append($('<div class="small mt-1">').text('PC 에 텔레그램이 없으면 휴대폰 카메라로 아래 QR 을 찍으세요.'));
				var $qr = $('<div class="tg-qr">').appendTo($w);
				tgQr($qr[0], url);
				$w.append($('<div class="small mt-1">').append($('<a target="_blank" rel="noopener">').attr('href', url).text('링크 다시 열기')));
			}
			$w.append($('<div class="mt-2">').append($('<button type="button" class="btn btn-sm btn-outline-secondary">').text('연결 확인').on('click', tgCheck)));
			$('#tgLink').append($w);
			clearInterval(tgWaitTimer);
			var until = Date.now() + 600000;
			tgWaitTimer = setInterval(function() { if (Date.now() > until) { clearInterval(tgWaitTimer); return; } tgCheck(true); }, 3000);
		}, function() { if (w) w.close(); });
	}
	function tgCheck(quiet) {
		$.post('/admin/my/tgCheckData.do', {}, function(res) {
			if (!res.result) return;
			// 코드가 쓰이면(WAITING 0) 연결된 것. 「다른 휴대폰으로 바꾸기」도 같은 조건
			if (res.result.link && res.result.link.STATUS_CD === 'ON' && !Number(res.result.link.WAITING)) {
				clearInterval(tgWaitTimer); tgPaint(res.result); hrToast('텔레그램이 연결됐습니다. 「시험 알림 보내기」로 확인해 보세요.'); return;
			}
			if (quiet !== true) hrToast('아직 「시작」 메시지가 오지 않았습니다. 봇 대화에서 「시작」을 눌러 주세요.');
		});
	}
	// QR 은 cdnjs 의 qrcodejs 를 이 화면에서만 불러 그린다. 못 불러오면 링크만 보인다
	function tgQr(el, url) {
		var draw = function() { try { new QRCode(el, { text: url, width: 150, height: 150 }); } catch (e) { $(el).remove(); } };
		if (window.QRCode) return draw();
		$.ajax({ url: 'https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js', dataType: 'script', cache: true }).done(draw).fail(function() { $(el).remove(); });
	}

	// 화면 안 가이드(텔레그램). 실제 화면처럼 그린 목업, 누를 곳은 노란 테두리+번호
	var TG_GUIDE = {
		TG_BOT: { title: '알림 봇 만드는 방법 (시스템 관리자, 처음 한 번)', steps: function() { return [
			{ t: 'BotFather 찾기', h: '1. 텔레그램에서 @BotFather 찾기',
				shot: '<div class="gl-g"><div class="tgbar">🔍 BotFather' + pin('inset:-4px', 1) + '</div><div class="acc"><span class="av" style="background:#2aa3df;color:#fff">B</span><div>BotFather ✔<br><small class="text-muted">@BotFather · 공식 봇</small></div>' + pin('inset:2px -4px', 2) + '</div></div>',
				li: ['휴대폰이나 PC 텔레그램에서 ① 검색창에 BotFather 를 입력하고', '② 파란 체크(✔)가 붙은 @BotFather 를 누릅니다.', '대화가 처음이면 아래 「시작」을 누릅니다.'],
				warn: '이름이 비슷한 가짜 봇이 있습니다. 반드시 파란 체크가 있는 @BotFather 를 고르세요.' },
			{ t: '/newbot 입력', h: '2. /newbot 보내기',
				shot: '<div class="gl-g"><div class="tgm"><div class="b me">/newbot' + pin('inset:-4px', 1) + '</div><div class="b">Alright, a new bot. How are we going to call it? Please choose a name for your bot.</div></div></div>',
				li: ['① 입력창에 /newbot 을 쓰고 보냅니다.', '봇 이름을 물어보면 다음 단계로 갑니다.'] },
			{ t: '이름 정하기', h: '3. 봇 이름(보이는 이름) 보내기',
				shot: '<div class="gl-g"><div class="tgm"><div class="b me">EST 일정 알림' + pin('inset:-4px', 1) + '</div><div class="b">Good. Now let\'s choose a username for your bot. It must end in `bot`.</div></div></div>',
				li: ['① 알림을 받을 때 보일 이름을 보냅니다. 예: EST 일정 알림', '한글도 됩니다. 나중에 BotFather 에서 바꿀 수 있습니다.'] },
			{ t: '아이디 정하기', h: '4. 봇 아이디 보내기 (영문, bot 으로 끝)',
				shot: '<div class="gl-g"><div class="tgm"><div class="b me">est_schedule_alarm_bot' + pin('inset:-4px', 1) + '</div><div class="b">Done! Congratulations on your new bot. … Use this token to access the HTTP API:<br><b style="color:#d6336c">123456789:AAH…xyz</b>' + pin('left:6px;right:6px;bottom:2px;height:22px', 2) + '</div></div></div>',
				li: ['① 영문·숫자·밑줄로, 끝이 bot 인 아이디를 보냅니다. 예: est_schedule_alarm_bot', '이미 있는 아이디면 다른 이름을 달라고 합니다. 바꿔서 다시 보내세요.', '② 완료 메시지 안의 「숫자:영문」 긴 값이 토큰입니다. 길게 눌러 복사합니다.'],
				warn: '토큰은 비밀번호와 같습니다. 채팅방·메일·메모에 붙여 넣지 말고 이 화면에만 넣으세요.' },
			{ t: '토큰 넣기', h: '5. 이 화면 「알림 봇」 칸에 붙여 넣고 저장',
				shot: '<div class="gl-g" style="background:#f6f8fa"><div class="d-flex" style="gap:6px"><div class="form-control form-control-sm" style="position:relative">••••••••••••' + pin('inset:-4px', 1) + '</div><span class="btn btn-sm btn-primary" style="position:relative;white-space:nowrap">확인 후 저장' + pin('inset:-6px', 2) + '</span></div><div class="m mt-2" style="color:#17692f">✓ @est_schedule_alarm_bot · 토큰 ****dxyz</div></div>',
				li: ['① 복사한 토큰을 붙여 넣고 ② 「확인 후 저장」', '서버가 텔레그램에 토큰을 확인한 뒤 저장합니다(암호화). 봇 아이디가 초록으로 보이면 끝입니다.', '이제 모든 관리자에게 「텔레그램 연결」 버튼이 보입니다. 토큰을 새로 받았을 때만 「바꾸기」로 다시 넣습니다.'],
				warn: '다른 봇의 토큰으로 바꾸면 모든 관리자의 연결이 끊겨 각자 다시 연결해야 합니다.' }
		]; } },
		TG_LINK: { title: '내 휴대폰 연결 방법', steps: function() { return [
			{ t: '텔레그램 설치', h: '1. 휴대폰에 텔레그램 설치·가입',
				shot: '<div class="gl-g"><div class="acc"><span class="av" style="background:#2aa3df;color:#fff">✈</span><div>Telegram Messenger<br><small class="text-muted">앱스토어 · 플레이스토어</small></div><span class="gb" style="margin-left:auto;position:relative">받기' + pin('inset:-6px', 1) + '</span></div></div>',
				li: ['① 앱스토어(아이폰)·플레이스토어(안드로이드)에서 Telegram 을 설치하고 전화번호로 가입합니다.', '이미 쓰고 있으면 넘어갑니다.'] },
			{ t: '연결 누르기', h: '2. 이 화면에서 「✈ 텔레그램 연결」',
				shot: '<div class="gl-g" style="background:#f6f8fa"><div class="gl-card" style="margin:0"><div class="gl-logo TG">✈</div><div><div class="t">휴대폰 알림 (텔레그램)</div></div><span class="btn btn-sm btn-primary" style="background:#2aa3df;border-color:#2aa3df;position:relative">✈ 텔레그램 연결' + pin('inset:-6px', 1) + '</span></div></div>',
				li: ['① 휴대폰으로 관리자 화면을 열었다면 누르면 텔레그램 앱이 바로 열립니다.', 'PC 라면 새 창이 열리고, 화면에 QR 이 나옵니다. 휴대폰 카메라로 QR 을 찍으세요.', '이 링크는 10분 동안 한 번만 쓸 수 있습니다.'] },
			{ t: '「시작」 누르기', h: '3. 봇 대화에서 「시작」',
				shot: '<div class="gl-g"><div class="tgm"><div class="b">회사 관리자 화면 일정 알림 봇입니다.</div></div><span class="tgstart">시작' + pin('inset:-4px', 1) + '</span></div>',
				li: ['① 아래쪽 「시작」(START)을 누릅니다.', '「✅ 관리자 계정 … 과 연결됐습니다」 답장이 오고, 이 화면도 「● 연결됨」으로 바뀝니다.', '안 바뀌면 이 화면의 「연결 확인」을 누르세요.'] },
			{ t: '시험·설정', h: '4. 시험 알림 보내고 받을 일정 고르기',
				shot: '<div class="gl-g"><div class="tgm"><div class="b">🔔 <b>14:00 신입면접 홍길동</b> (30분 후)<span class="tgbtn">상세 보기 ↗</span></div></div><div class="mt-2"><span class="tg-chip on">✓ 신입면접</span><span class="tg-chip on">✓ 경력면접</span><span class="tg-chip on">✓ 모집 인터뷰</span><span class="tg-chip on">✓ 내 할 일</span></div><div class="mt-1" style="position:relative;display:inline-block"><span class="btn btn-sm btn-outline-secondary">30분</span>' + pin('inset:-6px', 1) + '</div></div>',
				li: ['「시험 알림 보내기」로 휴대폰이 울리는지 확인합니다.', '받을 일정 종류와 ① 몇 분 전(10·30·60)을 고르고 「설정 저장」.', '시간이 바뀌거나 취소될 때도 받고 싶으면 아래 칸에서 종류를 켭니다(기본 끔).', '소리가 안 나면 휴대폰 설정 › 알림 › Telegram 이 켜져 있는지 보세요.'] }
		]; } }
	};

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
		gAt = 0; gList = TG_GUIDE[svc] ? TG_GUIDE[svc].steps() : steps(svc);
		$('#glGuideTitle').text(TG_GUIDE[svc] ? TG_GUIDE[svc].title : SVC[svc].nm + ' 연결 방법');
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
