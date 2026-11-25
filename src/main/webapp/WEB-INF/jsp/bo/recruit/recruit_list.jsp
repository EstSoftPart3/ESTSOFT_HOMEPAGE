<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/bo/boinclude/page_head.jspf"%>
<%-- 모집 관리(plans/deploy-recruit-split-spec.html). 모집 5가지 보기(달력이 처음). 대기자 패널은 모집 상세 팝업 오른쪽에 붙고, 대기자를 끌어 놓거나 누르면 그 모집에 지원 --%>
<style>
	.rc-top { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; margin-bottom: 10px; }
	.rc-views { display: inline-flex; gap: 4px; margin-left: auto; }
	.rc-views button { border: 1px solid rgba(17,17,17,.15); background: #fff; border-radius: 999px; padding: 3px 11px; font-size: 12.5px; font-weight: 700; color: #444; }
	.rc-views button[aria-pressed=true] { background: #111; border-color: #111; color: #fff; }
	.rc-main { min-height: 480px; overflow: auto; }
	/* 모집 상세 팝업: 왼쪽 모집 정보, 오른쪽 대기자 패널(#rcSide 를 평소엔 숨겨 두었다가 옮겨 붙임) */
	.rc-detail .modal-dialog { max-width: min(1640px, 96vw); }
	.rc-dwrap { display: flex; gap: 16px; align-items: flex-start; }
	.rc-dwrap > #rcDetail { flex: 1 1 0; min-width: 0; } /* 좌우 반반 */
	.rc-side { flex: 1 1 0; min-width: 0; position: sticky; top: 0; max-height: calc(100vh - 190px); overflow: auto; border-left: 1px solid #eef1f4; padding-left: 14px; }
	@media (max-width: 1199px) { .rc-dwrap { flex-direction: column; } .rc-side { width: auto; position: static; max-height: none; border-left: 0; padding-left: 0; border-top: 1px solid #eef1f4; padding-top: 10px; } }
	.rc-pf { display: flex; flex-wrap: wrap; gap: 4px; margin-bottom: 8px; }
	.rc-pf .form-control { height: 30px; font-size: 12.5px; flex: 1 1 120px; width: auto; }
	.rc-yr { font-weight: 700; } .rc-loc { display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; font-size: 11.5px; color: #495057; overflow-wrap: anywhere; }
	#ppTable { table-layout: fixed; width: 100%; } #ppTable td { overflow-wrap: anywhere; white-space: normal !important; } /* BO 공통은 표 칸을 한 줄로 묶어 칩이 옆 칸으로 넘친다 */ #ppTable tr[draggable=true]:hover td { background: #eef9fc; }
	.rc-rel { margin-top: 3px; font-size: 11px; color: #5f3dc4; } .rc-rel b { letter-spacing: 1px; }
	.rc-tk.on { background: #5f3dc4; color: #fff; }
	.rc-prof-ok { display: inline-block; background: #d3f9d8; color: #2b8a3e; border-radius: 6px; padding: 0 6px; font-size: 11px; font-weight: 800; margin-right: 3px; }
	.rc-x { border: 1px solid #ced4da; background: #fff; border-radius: 999px; padding: 0 9px; font-size: 11.5px; font-weight: 700; color: #495057; }
	.rc-x.drop { border-color: #ffa8a8; color: #c92a2a; } .rc-x:hover, .rc-x:focus { background: #f1f3f5; }
	.rc-dropzone { display: flex; flex-direction: column; align-items: center; gap: 2px; border: 2px dashed #0b6e8a; background: #eef9fc; color: #0b6e8a; border-radius: 10px; padding: 14px 10px; margin-top: 8px; text-align: center; font-size: 13px; }
	.rc-dropzone span { font-size: 11.5px; color: #5f7f8a; }
	body.rc-dragging .rc-dropzone { background: #d0f0fa; border-color: #087f9c; box-shadow: 0 0 0 4px rgba(11,110,138,.15); }
	.rc-dropzone.over { background: #b8e8f5 !important; outline: none !important; }
	.rc-tk { display: inline-block; background: #e7f5ff; color: #1864ab; border-radius: 4px; padding: 0 5px; margin: 1px 2px 1px 0; font-size: 11px; font-weight: 600; }
	.rc-noprof { border: 1px solid #fa5252; background: #fff5f5; color: #c92a2a; border-radius: 6px; padding: 1px 7px; font-size: 11.5px; font-weight: 800; white-space: nowrap; }
	button.rc-noprof:hover, button.rc-noprof:focus { background: #ffe3e3; }
	#ppTable tr.noprof td { background: #fffafa; }
	.rc-cal td { cursor: pointer; } .rc-cal td:hover { background: #f8fbfc; }
	.rc-day-add { float: right; border: 0; background: none; color: #0b6e8a; font-weight: 800; padding: 0 4px; line-height: 16px; opacity: 0; }
	.rc-cal td:hover .rc-day-add, .rc-day-add:focus { opacity: 1; }
	.rc-cal .ev-ap { display: block; padding: 0 4px 1px 10px; font-size: 10.5px; color: #495057; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; cursor: pointer; }
	.rc-side h3, .rc-main h3, #rcDetail h3 { font-size: 14px; font-weight: 800; margin: 0 0 8px; display: flex; gap: 6px; align-items: center; flex-wrap: wrap; }
	.rc-cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 10px; }
	.rc-card { border: 1px solid rgba(17,17,17,.12); border-radius: 10px; padding: 10px 12px; background: #fff; cursor: pointer; position: relative; }
	.rc-card:hover { border-color: #0b6e8a; }
	.rc-card.miss { border: 2px solid #ffc078; background: #fffaf0; }
	.rc-card.done { opacity: .62; }
	.rc-card.over, tr.over td, .rc-bcol.over { outline: 3px dashed #0b6e8a; outline-offset: -3px; background: #eef9fc; }
	.rc-card .cl { font-weight: 800; font-size: 15px; margin-top: 4px; }
	.rc-card .pj { color: #495057; font-size: 12.5px; margin-bottom: 6px; }
	.rc-card dl { display: grid; grid-template-columns: 62px 1fr; gap: 2px 6px; font-size: 12px; margin: 0; }
	.rc-card dt { color: #868e96; font-weight: 600; } .rc-card dd { margin: 0; }
	.rc-q { color: #e67700; font-weight: 700; }
	.rc-pill { display: inline-block; border-radius: 999px; padding: 0 8px; font-size: 11px; font-weight: 700; background: #f1f3f5; color: #495057; white-space: nowrap; }
	.rc-pill.OPEN { background: #e7f5ff; color: #1864ab; } .rc-pill.APPLY { background: #edf2ff; color: #4c3fd0; } .rc-pill.FILLED { background: #d3f9d8; color: #2b8a3e; } .rc-pill.CLOSED { background: #e9ecef; color: #495057; }
	.rc-pill.warn { background: #fff3bf; color: #e67700; } .rc-pill.bad { background: #ffe3e3; color: #c92a2a; }
	.rc-sk { display: inline-block; background: #f1f4f6; border-radius: 4px; padding: 0 5px; margin: 1px 2px 1px 0; font-size: 11px; }
	.rc-prog { height: 5px; background: #eef1f4; border-radius: 3px; margin-top: 8px; overflow: hidden; } .rc-prog i { display: block; height: 100%; background: #4c6ef5; }
	.rc-mini { display: flex; justify-content: space-between; font-size: 11.5px; color: #5f6b75; margin-top: 3px; }
	.rc-app { display: flex; gap: 6px; align-items: center; font-size: 12px; margin-top: 4px; }
	.rc-app b { min-width: 46px; }
	.rc-step { border: 0; border-radius: 999px; padding: 0 8px; font-size: 11px; font-weight: 700; background: #edf2ff; color: #364fc7; white-space: nowrap; }
	.rc-step.DOC { background: #f1f3f5; color: #495057; } .rc-step.INTV, .rc-step.INTV_WAIT { background: #fff4e6; color: #d9480f; } .rc-step.JOIN_WAIT { background: #e6fcf5; color: #087f5b; }
	.rc-step.INTV_SUB { background: #f3f0ff; color: #6741d9; } .rc-step.INTV_CHK { background: #fff3bf; color: #e67700; }
	.rc-step.JOIN { background: #d3f9d8; color: #2b8a3e; } .rc-step.DROP { background: #ffe3e3; color: #c92a2a; text-decoration: line-through; }
	.rc-stepper { display: inline-flex; border: 1px solid #dee2e6; border-radius: 999px; overflow: hidden; flex-wrap: wrap; }
	.rc-stepper button { border: 0; border-left: 1px solid #fff; background: #fff; padding: 2px 9px; font-size: 11.5px; color: #868e96; }
	.rc-stepper button:first-child { border-left: 0; } .rc-stepper button.past { background: #d3f9d8; color: #2b8a3e; font-weight: 700; } .rc-stepper button.now { background: #0b6e8a; color: #fff; font-weight: 800; }
	.rc-who { border: 0; background: none; padding: 0; color: inherit; text-align: left; cursor: pointer; }
	.rc-who:hover b, .rc-who:focus b { color: #0b6e8a; text-decoration: underline; }
	.rc-pop { position: fixed; top: 0; left: 0; width: 100%; height: 100%; border: 0; z-index: 1060; background: transparent; }
	.rc-pop-wait { position: fixed; inset: 0; z-index: 1059; background: rgba(0,0,0,.25); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 700; }
	.rc-menu { position: absolute; z-index: 1060; background: #fff; border: 1px solid #ccd3d9; border-radius: 8px; box-shadow: 0 6px 18px rgba(0,0,0,.15); padding: 4px; min-width: 150px; }
	.rc-menu button { display: block; width: 100%; text-align: left; border: 0; background: none; padding: 4px 10px; border-radius: 6px; font-size: 12.5px; }
	.rc-menu button:hover, .rc-menu button:focus { background: #f1f4f6; } .rc-menu button.cur { font-weight: 800; color: #0b6e8a; }
	.rc-board { display: grid; grid-template-columns: repeat(4, minmax(200px, 1fr)); gap: 10px; }
	.rc-bcol { background: #f8f9fa; border-radius: 10px; padding: 8px; min-height: 200px; }
	.rc-bcol .rc-card { margin-bottom: 8px; }
	.rc-cal { width: 100%; table-layout: fixed; border-collapse: collapse; font-size: 11.5px; }
	.rc-cal th { text-align: center; background: #f6f8fa; padding: 4px; } .rc-cal td { vertical-align: top; height: 82px; border: 1px solid #eef1f4; padding: 3px; }
	.rc-cal td.out { background: #fafbfc; color: #adb5bd; } .rc-cal td.today { background: #eef9fc; }
	.rc-cal .ev { display: block; border-radius: 4px; padding: 0 4px; margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; cursor: pointer; }
	.rc-cal .ev.intv, .rc-cal-legend .ev.intv { background: #fff; color: #c2410c; border: 1px solid #ffc9a8; border-left: 4px solid #e8590c; border-radius: 3px; }
	.rc-cal .ev.intv b, .rc-cal-legend .ev.intv b { font-weight: 800; } .rc-cal .ev.intv small { color: #868e96; }
	.rc-note-kv { grid-template-columns: 100px 1fr; gap: 8px 10px; } .rc-note-kv > label { align-self: start; padding-top: 3px; }
	.rc-note-kv.editing .rc-wayb:not(.rc-add-code) { border-color: #fa5252; color: #c92a2a; } .rc-note-kv.editing .rc-wayb:not(.rc-add-code)::after { content: ' ✕'; }
	.rc-add-code { border-style: dashed; color: #0b6e8a; }
	.rc-qa-row { display: grid; grid-template-columns: 1fr 1.4fr 20px; gap: 4px; margin-bottom: 4px; align-items: start; }
	.rc-qa-row textarea { font-size: 12.5px; }
	@media (max-width: 767px) { .rc-qa-row { grid-template-columns: 1fr 20px; } .rc-qa-row .a { grid-column: 1; } }
	.rc-linkbtn { border: 1px solid #0b6e8a; background: #eef9fc; color: #0b6e8a; border-radius: 999px; padding: 0 9px; font-size: 11.5px; font-weight: 700; }
	.rc-linkbtn.sent { border-style: dashed; background: #fff; } .rc-linkbtn:hover, .rc-linkbtn:focus { background: #d0f0fa; }
	.rc-self { display: inline-block; border-radius: 999px; padding: 0 8px; font-size: 11px; font-weight: 800; background: #d3f9d8; color: #2b8a3e; } .rc-self.adm { background: #e7f5ff; color: #1864ab; } .rc-self.wait { background: #fff3bf; color: #e67700; }
	.rc-newdot { color: #e8590c; font-size: 12px; } .rc-selfev { color: #2b8a3e; font-size: 10px; }
	.rc-vchip { background: #eef9fc; color: #0b6e8a; border: 1px solid #b6e3ef; border-radius: 999px; padding: 0 9px; font-size: 12.5px; font-weight: 700; }
	.rc-qview { border: 1px solid #dfe4e8; border-radius: 10px; overflow: hidden; } .rc-qview > div { display: grid; grid-template-columns: 30px 1fr; gap: 6px; padding: 7px 10px; border-bottom: 1px solid #eef1f4; font-size: 13px; }
	.rc-qview > div:last-child { border-bottom: 0; } .rc-qview .n { color: #868e96; } .rc-qview .q { font-weight: 700; } .rc-qview .a { color: #495057; white-space: pre-wrap; }
	.rc-memo { background: #fafbfc; border: 1px solid #e9ecef; border-radius: 8px; padding: 6px 10px; font-size: 13px; white-space: pre-wrap; }
	.rc-calstat { background: #fafbfc; border: 1px solid #dfe4e8; border-radius: 8px; padding: 4px 10px; font-size: 12px; } .rc-calstat b { display: block; font-size: 16px; }
	.rc-calstat.bad { border-color: #ffa8a8; } .rc-calstat.bad b { color: #c92a2a; }
	.rc-fromcal { display: inline-block; border-radius: 999px; padding: 0 7px; font-size: 10.5px; font-weight: 800; background: #e7f5ff; color: #1864ab; }
	.rc-notebtn { border: 1px dashed #b197fc; background: #fff; color: #6741d9; border-radius: 999px; padding: 0 9px; font-size: 11.5px; font-weight: 700; max-width: 100%; white-space: normal; text-align: left; }
	.rc-notebtn.has { border-style: solid; background: #f3f0ff; } .rc-notebtn:hover, .rc-notebtn:focus { background: #e5dbff; }
	.ist { font-style: normal; font-size: 10px; font-weight: 800; border-radius: 4px; padding: 0 4px; background: #fff4e6; color: #d9480f; }
	.ist.ok { background: #d3f9d8; color: #2b8a3e; } .ist.sub { background: #f3f0ff; color: #6741d9; } .ist.wait { background: #fff3bf; color: #e67700; } .ist.x { background: #e9ecef; color: #868e96; }
	.rc-cal .ev.intv.x { border-left-color: #adb5bd; border-color: #dee2e6; color: #868e96; text-decoration: line-through; } .rc-cal .ev.intv.x .ist { text-decoration: none; }
	.rc-cal-legend { display: flex; gap: 6px; align-items: center; font-size: 11px; flex-wrap: wrap; }
	.rc-cal-legend .ev { display: inline-block; border-radius: 4px; padding: 0 5px; }
	.rc-cal-legend .ev.reg { background: #e7f5ff; color: #1864ab; } .rc-cal-legend .ev.due { background: #ffe3e3; color: #c92a2a; } .rc-cal-legend .ev.start { background: #d3f9d8; color: #2b8a3e; } .rc-cal-legend .ev-ap { color: #495057; }
	.rc-cal .ev.due { background: #ffe3e3; color: #c92a2a; } .rc-cal .ev.start { background: #d3f9d8; color: #2b8a3e; } .rc-cal .ev.reg { background: #e7f5ff; color: #1864ab; }
	.rc-tl { display: grid; grid-template-columns: 160px 1fr; gap: 5px 8px; align-items: center; font-size: 12px; min-width: 640px; }
	.rc-tl .mon { display: grid; font-weight: 700; color: #868e96; } .rc-tl .trk { position: relative; height: 16px; background: #f1f3f5; border-radius: 4px; }
	.rc-tl .bar { position: absolute; top: 0; bottom: 0; background: #ffd8a8; border-radius: 4px; cursor: pointer; } .rc-tl .bar.open { border-right: 2px dashed #d9480f; }
	.rc-tl .bar.FILLED { background: #b2f2bb; } .rc-tl .bar.pp { top: 5px; bottom: 5px; background: #96f2d7; } .rc-tl .now { position: absolute; top: -2px; bottom: -2px; width: 2px; background: #0b6e8a; }
	#ppTable td { vertical-align: top; font-size: 12px; }
	#ppTable tr[draggable=true] td:first-child { cursor: grab; }
	#ppTable td:first-child b { white-space: nowrap; }
	#ppTable .sub { color: #868e96; font-size: 11px; }
	.rc-ver { display: inline-block; border: 1px solid #ced4da; border-radius: 6px; padding: 0 5px; font-size: 10.5px; margin: 1px 2px 1px 0; color: #495057; background: #fff; text-decoration: none !important; }
	.rc-ver.EDIT { border-color: #b197fc; color: #6741d9; background: #f3f0ff; }
	.rc-find { position: relative; margin-bottom: 8px; }
	.rc-find-list { position: absolute; left: 0; right: 0; top: 34px; z-index: 30; background: #fff; border: 1px solid #c9ced6; border-radius: 8px; box-shadow: 0 8px 20px rgba(0,0,0,.12); max-height: 320px; overflow: auto; }
	.rc-find-list .it { display: flex; gap: 6px; padding: 6px 10px; border-bottom: 1px solid #f1f3f5; font-size: 12px; cursor: grab; align-items: center; flex-wrap: wrap; }
	.rc-kv { display: grid; grid-template-columns: 110px 1fr; gap: 6px 10px; align-items: center; font-size: 13px; }
	.rc-kv > label { margin: 0; font-weight: 700; color: #495057; font-size: 12.5px; } .rc-kv > label.q { color: #e67700; }
	.rc-kv .form-control { height: 30px; font-size: 13px; }
	.rc-kv > .rc-sec { grid-column: 1 / -1; margin: 8px 0 0; }
	.rc-kv > .rc-sec:first-child { margin-top: 0; }
	.rc-kv4 { grid-template-columns: 72px minmax(0, 1fr) 72px minmax(0, 1fr); gap: 4px 8px; }
	.rc-kv4 > label { font-size: 12px; } .rc-kv4 .form-control { height: 28px; font-size: 12.5px; padding: 2px 8px; } .rc-kv4 textarea.form-control { height: auto; }
	.rc-kv4 > .wide { grid-column: span 3; }
	.rc-kv4 > .rc-sec { margin: 6px 0 0; padding-top: 6px; font-size: 12px; font-weight: 800; color: #868e96; }
	@media (max-width: 767px) { .rc-kv4 { grid-template-columns: 72px minmax(0, 1fr); } .rc-kv4 > .wide { grid-column: auto; } }
	.rc-rawbox { margin: 0 0 8px; border: 1px solid #e9ecef; border-radius: 8px; padding: 4px 10px; background: #fafbfc; }
	.rc-rawbox > summary { font-size: 12.5px; font-weight: 800; cursor: pointer; color: #495057; } .rc-rawbox[open] > summary { margin-bottom: 4px; }
	.rc-raw { font: 12px/1.7 ui-monospace, Consolas, monospace; white-space: pre-wrap; background: #fafbfc; border: 1px solid #e9ecef; border-radius: 8px; padding: 8px 10px; max-height: 240px; overflow: auto; }
	.rc-sec { border-top: 1px solid #eef1f4; padding-top: 10px; margin-top: 12px; } .rc-sec h4 { font-size: 13px; font-weight: 800; margin-bottom: 8px; display: flex; gap: 6px; align-items: center; }
	.rc-opt { display: flex; gap: 8px; align-items: center; border: 1px solid #dee2e6; border-radius: 8px; padding: 7px 10px; margin-bottom: 6px; cursor: pointer; font-size: 13px; }
	.rc-opt.on { border-color: #0b6e8a; background: #eef9fc; }
	.rc-opt { flex-wrap: wrap; } .rc-psum { flex-basis: 100%; display: flex; flex-wrap: wrap; gap: 3px 8px; align-items: center; font-size: 11.5px; color: #5f6b75; }
	.rc-note { font-size: 11.5px; color: #868e96; }
	.rc-chips .pl-chip { margin-bottom: 0; }
	.rc-drop-hint { border: 1px dashed #c9ced6; border-radius: 8px; padding: 10px; text-align: center; color: #868e96; font-size: 12px; margin-top: 6px; }
	.rc-wayb { border: 1px solid #ced4da; background: #fff; border-radius: 999px; padding: 2px 12px; font-size: 12.5px; margin-right: 4px; }
	.rc-wayb[aria-pressed=true] { background: #0b6e8a; border-color: #0b6e8a; color: #fff; font-weight: 700; }
	.rc-join2 { background: #fff9db; border: 1px solid #ffe066; border-radius: 8px; padding: 10px; }
	.rc-add { border: 1px dashed #0b6e8a; background: #fff; color: #0b6e8a; border-radius: 999px; padding: 1px 10px; font-size: 11.5px; font-weight: 700; margin-top: 6px; }
	.rc-pick { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; width: 100%; text-align: left; border: 1px solid #dee2e6; background: #fff; border-radius: 8px; padding: 8px 10px; margin-bottom: 6px; font-size: 13px; }
	.rc-pick:hover, .rc-pick:focus { border-color: #0b6e8a; background: #eef9fc; }
	@media (max-width: 767px) {
		.rc-views { flex-wrap: wrap; margin-left: 0; }
		.rc-add { padding: 6px 14px; font-size: 13px; }
		.rc-cal { font-size: 10px; } .rc-cal th { padding: 2px 0; } .rc-cal td { height: auto; min-height: 44px; padding: 1px; }
		.rc-cal .ev { font-size: 0; height: 6px; padding: 0; margin-top: 1px; } /* 폰: 일정은 색 띠만, 누르면 상세 */
		.rc-cal .ev-ap { display: none; } .rc-day-add { opacity: 1; }
		.rc-board-wrap::before, .rc-tl-wrap::before { content: '← 가로로 넘겨 보세요 →'; display: inline-block; position: sticky; left: 8px; font-size: 11px; color: #868e96; margin: 4px 0; }
	}
</style>
<%@ include file="/WEB-INF/jsp/bo/boinclude/page_open.jspf"%>
<div class="card-header d-flex align-items-center flex-wrap" style="gap:6px">
	<h3 class="card-title bTitle mr-auto"><b>모집 관리</b></h3>
</div>
<div class="card-body">
	<div class="rc-top">
		<div id="stChips" class="rc-chips d-flex flex-wrap align-items-center" style="gap:4px" role="group" aria-label="모집 상태"></div>
		<input type="search" id="rcFind" class="form-control form-control-sm" style="width:200px" placeholder="고객사·사업명·기술 찾기" aria-label="모집 찾기">
		<div class="rc-views" role="group" aria-label="보기">
			<button type="button" data-view="cal" aria-pressed="true">📅 달력</button><button type="button" data-view="card" aria-pressed="false">▦ 카드</button><button type="button" data-view="table" aria-pressed="false">☰ 표</button><button type="button" data-view="board" aria-pressed="false">▥ 상태 보드</button><button type="button" data-view="tl" aria-pressed="false">▬ 타임라인</button>
		</div>
		<button type="button" class="btn btn-sm btn-outline-primary" id="calBtn" title="구글 캘린더(est.part2)의 모집·인터뷰 가져오기 — 매일 09:00 배치 때도 자동">📅 캘린더</button>
		<button type="button" class="btn btn-sm btn-primary" id="addBtn">+ 모집 등록</button>
	</div>
	<div class="rc-main" id="rcMain"><div class="text-muted p-3">불러오는 중…</div></div>
	<div id="rcSideHome" hidden>
		<div class="rc-side" id="rcSide">
			<h3>대기자 <span id="ppCnt" class="text-muted"></span>
				<span id="ppSort" class="ml-auto" role="group" aria-label="대기자 정렬" hidden><button type="button" class="rc-wayb" data-sort="rel" title="이 모집의 요구 기술·등급·근무지와 맞는 순">관련도순</button><button type="button" class="rc-wayb" data-sort="name">이름순</button></span></h3>
			<div id="ppChips" class="rc-chips d-flex flex-wrap align-items-center mb-2" style="gap:4px" role="group" aria-label="대기자 구분"></div>
			<div class="rc-pf" role="group" aria-label="대기자 거르기">
				<input type="search" id="pfLoc" class="form-control form-control-sm" placeholder="📍 지역 (예: 강남 판교)" aria-label="지역으로 거르기 (띄어 쓰면 하나라도 맞는 사람)" autocomplete="off">
				<select id="pfYear" class="form-control form-control-sm" aria-label="연차로 거르기">
					<option value="">연차 전체</option><option value="0-1">1년 미만</option><option value="1-3">1~3년</option><option value="3-5">3~5년</option><option value="5-10">5~10년</option><option value="10-99">10년 이상</option>
				</select>
				<input type="search" id="pfTech" class="form-control form-control-sm" list="pfTechList" placeholder="🛠 주요기술 (예: Java)" aria-label="주요기술로 거르기" autocomplete="off">
				<datalist id="pfTechList"></datalist>
			</div>
			<div class="rc-find">
				<input type="search" id="ppFind" class="form-control form-control-sm" placeholder="🔍 전체 직원에서 찾기 (투입 중 포함)" aria-label="전체 직원에서 찾기" autocomplete="off">
				<div class="rc-find-list" id="ppFindList" hidden></div>
			</div>
			<div class="tbl-scroll"><!-- 없으면 ui-table.js 가 .rc-side 를 스크롤 상자로 보고 그 앞(가로 flex)에 위 스크롤바를 끼워 넣어 가운데 빈 영역이 생긴다 -->
			<table class="table table-sm" id="ppTable" data-nopick><!-- 팝업 안으로 옮겨 다시 그리면 공통 체크 칸이 머리글에만 남아 칸이 어긋난다 -->
				<colgroup><col style="width:30%"><col style="width:14%"><col style="width:20%"><col style="width:18%"><col style="width:18%"></colgroup>
				<thead><tr><th scope="col">성명 · 프로필</th><th scope="col">연차</th><th scope="col">지역</th><th scope="col">주요기술</th><th scope="col">상태</th></tr></thead>
				<tbody id="ppBody"></tbody>
			</table>
			</div>
			<div class="rc-note">줄을 누르거나 왼쪽 모집 정보에 끌어 놓으면 이 모집 지원 창이 떠요. 프로필(수행이력 버전)이 없는 사람은 먼저 등록해야 해요.</div>
		</div>
	</div>
</div>
<%@ include file="/WEB-INF/jsp/bo/boinclude/page_close.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/boinclude/page_script.jspf"%>
<script>
var PATH = location.pathname, D = null, VIEW = 'cal', ST_CHK = { OPEN: true, APPLY: true, FILLED: true, CLOSED: false, MISS: false }, PP_CHK = { WAIT: true, FUTURE: true, SOON: true };
var STATUS = { OPEN: '모집중', APPLY: '지원 진행', FILLED: '충원 완료', CLOSED: '마감' };
// 결과 제출(INTV_SUB)은 본인이 링크로 기록을 내면, 확인중(INTV_CHK)은 관리자가 그 기록을 열어 보거나 직접 기록하면 자동으로(서버 autoStep)
var STEPS = [['DOC', '서류검토'], ['INTV_WAIT', '인터뷰대기'], ['INTV', '인터뷰확정'], ['INTV_SUB', '인터뷰 결과 제출'], ['INTV_CHK', '인터뷰 결과 확인중'], ['JOIN_WAIT', '투입대기'], ['JOIN', '투입확정']];
var STEP_NM = { DROP: '탈락' }; STEPS.forEach(function(s) { STEP_NM[s[0]] = s[1]; });
var WAY = { FACE: '대면', VIDEO: '화상', PHONE: '전화' };
var MISS = [['CLIENT_NM', '고객사'], ['PRJ_NM', '사업명'], ['GRADE_TXT', '등급·인원'], ['START_DT', '투입 시작'], ['WORK_AREA', '근무지'], ['SALE_PARTNER_SQ', '매출처'], ['PRICE_TXT', '단가']];
var FIELDS = [['CLIENT_NM', '고객사'], ['PRJ_NM', '사업명'], ['GRADE_TXT', '등급·인원', '예: 중급 2 · 고급 1'], ['HEAD_CNT', '정원(명)', '', 'number'], ['START_DT', '투입 시작', '', 'date'], ['END_DT', '투입 종료', '비우면 미정', 'date'],
	['PERIOD_TXT', '기간 원문'], ['WORK_AREA', '근무지'], ['PRICE_TXT', '단가 🔒'], ['SKILLS', '요구 기술', '쉼표로'], ['PREFER', '우대'], ['SALE_PARTNER_SQ', '매출처', '', 'partner'], ['MGR_NM', '담당'], ['CLOSE_DT', '지원 마감', '', 'date'], ['MEMO', '메모', '', 'textarea']];
// 상세 칸 묶음: 이 칸 앞에 섹션 제목을 넣는다
var SECTION_AT = { CLIENT_NM: '사업 정보', START_DT: '기간·근무지', PRICE_TXT: '조건', SALE_PARTNER_SQ: '거래처·마감' };
var calMonth = null;
var CUR_SQ = null, PP_SORT = 'rel'; // 대기자 패널이 붙은 모집(관련도 기준), 정렬

function today() { var d = new Date(); return d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2); }
function days(a, b) { return Math.round((new Date(b) - new Date(a)) / 86400000); }
function md(d) { return d ? d.substring(5, 10).replace('-', '/') : ''; }
function esc(s) { return $('<div>').text(s == null ? '' : s).html(); }
function notes(list) { if (list && list.length) bootbox.alert({ title: '알림', message: $('<ul class="mb-0 pl-3">').append(list.map(function(n) { return $('<li>').text(n); })) }); }

$(function() {
	// 열 때는 늘 달력부터(보기 버튼으로 바꾼 것은 이번 화면에서만)
	$('.rc-views').on('click', 'button', function() { VIEW = $(this).data('view'); render(); });
	$('#rcFind').on('input', render);
	$('#addBtn').on('click', function() { pasteDialog(); });
	$('#calBtn').on('click', calDialog);
	$('#pfLoc, #pfTech').on('input', people);
	$('#pfYear').on('change', people);
	$('#ppSort').on('click', 'button', function() { PP_SORT = $(this).data('sort'); people(); });
	findBox();
	hrDriveGear('RECRUIT');
	// 투입현황 대기 현황의 「지원 중 모집」 링크(?open=모집번호)는 그 모집 상세를 연다
	load(function() { var m = /[?&]open=(\d+)/.exec(location.search); if (m) detail(m[1]); });
});

function load(after) {
	hrPost('/admin/recruit/listData.do', {}, function(res) {
		D = res.result;
		hrSetCodes(D.codes);
		people();
		render();
		if (after) after();
	});
}

// ── 계산 ──
function appsOf(sq) { return D.applies.filter(function(a) { return String(a.RECRUIT_SQ) === String(sq); }); }
function profilesOf(staffSq) { return D.profiles.filter(function(p) { return String(p.STAFF_SQ) === String(staffSq); }); }
function staffOf(sq) { return D.staff.filter(function(s) { return String(s.STAFF_SQ) === String(sq); })[0]; }
function partnerName(sq) { var p = D.partners.filter(function(x) { return String(x.PARTNER_SQ) === String(sq); })[0]; return p ? p.PARTNER_NM : ''; }
function missing(r) {
	return MISS.filter(function(m) {
		var v = r[m[0]];
		if (m[0] === 'PRICE_TXT') return v !== '🔒' && (!v || /미정/.test(v));
		return v === null || v === undefined || v === '';
	});
}
// 사람 상태: FUTURE 투입 예정, SOON 철수 임박(30일 안), ACTIVE 투입 중, WAIT 대기
function personState(staffSq) {
	var rows = D.current.filter(function(c) { return String(c.STAFF_SQ) === String(staffSq); }), t = today();
	var fut = rows.filter(function(c) { return c.STATE === 'FUTURE'; })[0];
	if (fut) return { k: 'FUTURE', label: '투입 예정 D-' + days(t, fut.START_DT), row: fut };
	var act = rows.filter(function(c) { return c.STATE === 'ACTIVE'; }).sort(function(a, b) { return String(a.END_DT || '9').localeCompare(String(b.END_DT || '9')); })[0];
	if (act) {
		var left = act.END_DT ? days(t, act.END_DT) : null;
		return left !== null && left <= 30 ? { k: 'SOON', label: '철수 D-' + left, row: act } : { k: 'ACTIVE', label: '투입 중', row: act };
	}
	var last = rows[0], s = staffOf(staffSq), from = last && last.END_DT ? last.END_DT : s && s.JOIN_DT;
	return { k: 'WAIT', label: '대기' + (from ? ' ' + Math.max(0, days(from, t)) + '일' : ''), row: last };
}
function activeAppsOfStaff(staffSq) { return D.applies.filter(function(a) { return String(a.STAFF_SQ) === String(staffSq) && ['DOC', 'INTV_WAIT', 'INTV', 'INTV_SUB', 'INTV_CHK', 'JOIN_WAIT'].indexOf(a.STEP_CD) >= 0; }); }
function recruitOf(sq) { return D.recruits.filter(function(r) { return String(r.RECRUIT_SQ) === String(sq); })[0]; }

// ── 대기자 패널 ──
function verChips(staffSq) {
	var ps = profilesOf(staffSq);
	if (!ps.length) {
		if (!D.canStaff) return $('<span class="rc-noprof">프로필 없음</span>').attr('title', '인사카드 › 수행이력에서 버전을 저장해야 지원할 수 있어요');
		return $('<button type="button" class="rc-noprof">프로필 없음 · ＋ 등록</button>').attr('title', '인사카드 › 수행이력을 열어 「새 버전으로 저장」으로 등록해요')
			.on('click', function(e) { e.stopPropagation(); staffPop(staffSq, true); });
	}
	return $('<span>').append(ps.slice(0, 4).map(function(p) {
		return $('<a class="rc-ver">').addClass(p.VER_KIND).attr({ href: '/admin/recruit/profileWord.do?STAFF_SQ=' + staffSq + '&VER_NO=' + p.VER_NO, title: p.REG_DT + ' · 프로젝트 ' + (p.PRJ_CNT || 0) + '건 · 눌러서 워드 받기' })
			.text((p.VER_KIND === 'EDIT' ? '가필 v' : '순정 v') + p.VER_NO).on('click', function(e) { e.stopPropagation(); });
	}));
}
function people() {
	var cnt = { WAIT: 0, FUTURE: 0, SOON: 0 }, rows = [];
	var loc = $.trim($('#pfLoc').val()).split(/[\s,]+/).filter(Boolean), yr = ($('#pfYear').val() || '').split('-'), tk = techKey($('#pfTech').val());
	var techs = {}, exact = false;
	D.staff.forEach(function(s) { (s.TECHS || []).forEach(function(t) { techs[t] = 1; if (techKey(t) === tk) exact = true; }); });
	// 아는 기술 이름 그대로면(Java) 그 기술만, 아니면 들어간 글자로(spr → Spring) 찾는다
	function techOk(t) { return exact ? techKey(t) === tk : techKey(t).indexOf(tk) >= 0; }
	D.staff.forEach(function(s) {
		var st = personState(s.STAFF_SQ);
		if (cnt[st.k] !== undefined) cnt[st.k]++;
		if (!PP_CHK[st.k]) return;
		var where = String((s.WISH_LOC || '') + ' ' + (s.ADDR || '')).replace(/\s/g, ''), y = career(s).y;
		if (loc.length && !loc.some(function(w) { return where.indexOf(w) >= 0; })) return;
		if (yr[0] !== '' && (y === null || y < +yr[0] || y >= +yr[1])) return;
		if (tk && !(s.TECHS || []).some(techOk)) return;
		rows.push({ s: s, st: st, rel: relOf(s, st) });
	});
	boChips('#ppChips', [{ k: 'WAIT', name: '대기', n: cnt.WAIT }, { k: 'FUTURE', name: '투입 예정', n: cnt.FUTURE }, { k: 'SOON', name: '철수 임박', n: cnt.SOON }], PP_CHK, people);
	var $dl = $('#pfTechList');
	if ($dl.children().length !== Object.keys(techs).length) $dl.empty().append(Object.keys(techs).sort().map(function(t) { return $('<option>').val(t); }));
	var $b = $('#ppBody').empty();
	var byRel = PP_SORT === 'rel' && !!CUR_SQ;
	$('#ppSort button').each(function() { $(this).attr('aria-pressed', $(this).data('sort') === PP_SORT); });
	$('#ppSort').prop('hidden', !CUR_SQ);
	rows.sort(function(a, b) { return (byRel ? b.rel.score - a.rel.score : 0) || ['WAIT', 'SOON', 'FUTURE'].indexOf(a.st.k) - ['WAIT', 'SOON', 'FUTURE'].indexOf(b.st.k) || String(a.s.STAFF_NM).localeCompare(b.s.STAFF_NM); });
	rows.forEach(function(x) { $b.append(personRow(x.s, x.st, x.rel)); });
	if (!rows.length) boEmpty($b, '고른 조건에 해당하는 사람이 없습니다.');
	$('#ppCnt').text(rows.length);
}
// 관련도: 지금 열린 모집(CUR_SQ)과 얼마나 맞는지. 요구 기술 하나에 3, 등급 2, 근무지 2(「전지역·상관없음」은 1), 프로필 2, 대기 1·투입 예정 -1
function lv(t) { var o = {}; String(t || '').replace(/[초중고특]/g, function(c) { o[c] = 1; }); return o; }
function relOf(s, st) {
	var r = CUR_SQ && recruitOf(CUR_SQ), out = { score: 0, max: 1, why: [], tech: {} };
	if (!r) return out;
	var mine = (s.TECHS || []).map(techKey), need = String(r.SKILLS || '').split(/[,/·\s\-+&]+/).map(function(x) { return $.trim(x); }).filter(Boolean);
	// Spring·SpringBoot·Spring Framework, React·ReactJS 는 같은 기술로(Java 와 JavaScript 는 다름)
	function same(a, b) { var x = function(k) { return k.replace(/(boot|framework|mvc|js)$/, ''); }; return !!a && x(a) === x(b); }
	var hit = need.filter(function(n) { var k = techKey(n); return mine.some(function(m) { return same(m, k); }); });
	var names = (s.TECHS || []).filter(function(t) { var k = techKey(t); return hit.some(function(n) { return same(k, techKey(n)); }); });
	names.forEach(function(t) { out.tech[techKey(t)] = 1; });
	out.score += hit.length * 3; out.max = need.length * 3 + 2 + 2 + 2 + 1;
	if (hit.length) out.why.push('기술 ' + names.join('·'));
	var need2 = lv(r.GRADE_TXT), me2 = lv(s.GRADE_NM);
	if (Object.keys(me2).some(function(k) { return need2[k]; })) { out.score += 2; out.why.push('등급 ' + s.GRADE_NM); }
	var wish = String(s.WISH_LOC || '').replace(/\s/g, ''), area = String(r.WORK_AREA || '').split(/[\s,/·()]+/).map(function(w) { return w.replace(/(역|상주|근무|인근|부근)$/, ''); }).filter(function(w) { return w.length >= 2; });
	var place = area.filter(function(w) { return wish.indexOf(w) >= 0; })[0];
	if (place) { out.score += 2; out.why.push('지역 ' + place); }
	else if (/전지역|전체가능|상관없|어디든/.test(wish)) { out.score += 1; out.why.push('지역 무관'); }
	if (profilesOf(s.STAFF_SQ).length) out.score += 2;
	out.score += st.k === 'WAIT' ? 1 : st.k === 'FUTURE' ? -1 : 0;
	return out;
}
// JAVA·Java·Spring Boot·SpringBoot 처럼 표기만 다른 기술을 같게 본다(서버 StaffCareerService.techKey 와 같은 규칙)
function techKey(t) { return String(t || '').toLowerCase().replace(/[\s\-_.]/g, ''); }
// 연차: 실경력(예: 4년2개월, 신입)을 읽고, 없거나 못 읽으면 수행이력 첫 시작월부터 센다. y 는 년(소수), 못 정하면 null
function career(s) {
	var t = $.trim(s.REAL_CAREER || ''), m;
	if (/신입|없음/.test(t)) return { y: 0, label: '신입' };
	if ((m = /(\d+)\s*년(?:\s*(\d+)\s*개월)?|(\d+)\s*개월/.exec(t))) return { y: m[3] ? m[3] / 12 : +m[1] + (m[2] ? m[2] / 12 : 0), label: t };
	if (s.FIRST_YM) {
		var d = new Date(), mon = (d.getFullYear() - +s.FIRST_YM.substring(0, 4)) * 12 + d.getMonth() + 1 - +s.FIRST_YM.substring(5, 7);
		if (mon >= 0) return { y: mon / 12, label: '약 ' + (mon >= 12 ? Math.floor(mon / 12) + '년' : mon + '개월'), guess: true };
	}
	return { y: null, label: t };
}
function personRow(s, st, rel) {
	var has = profilesOf(s.STAFF_SQ).length > 0, apps = activeAppsOfStaff(s.STAFF_SQ), c = career(s), techs = s.TECHS || [];
	rel = rel || { score: 0, max: 1, why: [], tech: {} };
	var ps = profilesOf(s.STAFF_SQ);
	var $tr = $('<tr>').attr({ draggable: has, 'data-staff': s.STAFF_SQ }).toggleClass('noprof', !has);
	// 마우스를 올리면 잘린 정보까지 한 번에 보인다
	$tr.attr('title', [s.STAFF_NM + ' (' + [s.POSITION_NM, s.DEPT_NM, s.GRADE_NM].filter(Boolean).join(' · ') + ')', '연차: ' + (c.label || '-'), '지역: ' + (s.WISH_LOC || '-'), '주요기술: ' + (techs.join(', ') || '-'),
		'상태: ' + st.label + (st.row && st.k !== 'WAIT' ? ' · ' + (st.row.CLIENT_NM || '') : ''), '프로필: ' + (has ? ps.map(function(p) { return (p.VER_KIND === 'EDIT' ? '가필 v' : '순정 v') + p.VER_NO; }).join(', ') : '없음'),
		CUR_SQ ? '관련도: ' + (rel.why.join(' · ') || '맞는 항목 없음') : '', has ? '모집 상세에서 줄을 누르거나 왼쪽에 끌어 놓으면 지원' : '프로필이 없어 지원할 수 없어요'].filter(Boolean).join('\n'));
	var $nm = $('<td>').append(nameEl(s, has)).append($('<div class="sub">').text([s.POSITION_NM, s.DEPT_NM].filter(Boolean).join(' · ')))
		.append($('<div class="mt-1">').append(has ? $('<span class="rc-prof-ok">✓ 프로필</span>').add(verChips(s.STAFF_SQ)) : verChips(s.STAFF_SQ)));
	if (CUR_SQ) {
		var dots = Math.max(0, Math.min(4, Math.round(4 * rel.score / rel.max)));
		$nm.append($('<div class="rc-rel">').append($('<b>').text('관련 ' + '●●●●'.substring(0, dots) + '○○○○'.substring(dots))).append(rel.why.length ? $('<span>').text(' ' + rel.why.join(' · ')) : ''));
	}
	$tr.append($nm);
	$tr.append($('<td>').append($('<span class="rc-yr">').text(c.label || '-')).append(s.GRADE_NM ? $('<div class="sub">').text(s.GRADE_NM) : ''));
	$tr.append($('<td>').append(s.WISH_LOC ? $('<span class="rc-loc">').text(s.WISH_LOC) : $('<span class="sub">-</span>')));
	$tr.append($('<td>').append(techs.map(function(t) { return $('<span class="rc-tk">').toggleClass('on', !!rel.tech[techKey(t)]).text(t); })));
	var $st = $('<td>').append($('<span class="rc-pill">').addClass(st.k === 'SOON' ? 'warn' : st.k === 'FUTURE' ? 'FILLED' : '').text(st.label)).append(st.row && st.k !== 'WAIT' ? $('<div class="sub">').text(st.row.CLIENT_NM || '') : '');
	apps.forEach(function(a) {
		var r = recruitOf(a.RECRUIT_SQ);
		$st.append($('<div class="sub">').append($('<a href="#">').text('지원: ' + (r ? r.CLIENT_NM || '(고객사)' : '') + ' · ' + STEP_NM[a.STEP_CD] + (a.INTV_DT && a.STEP_CD === 'INTV' ? ' 🎤' + md(a.INTV_DT) : '')).on('click', function(e) { e.preventDefault(); e.stopPropagation(); detail(a.RECRUIT_SQ); })));
	});
	$tr.append($st);
	dragSource($tr, s.STAFF_SQ, has);
	return $tr;
}
// 이름을 누르면 인사카드를 이 화면 위에 띄운다(홈 일정 팝업과 같은 ?embed=1&popup=1 틀). 닫으면 다시 불러와 프로필을 새로 그린다
function nameEl(s, has) {
	var $b = $('<b>').text((has ? '⠿ ' : '') + s.STAFF_NM);
	if (!D.canStaff) return $b;
	return $('<button type="button" class="rc-who">').attr('title', has ? '인사카드 열기' : '인사카드 › 수행이력에서 프로필 등록').append($b)
		.on('click', function(e) { e.stopPropagation(); staffPop(s.STAFF_SQ, !has); });
}
function staffPop(sq, career) {
	var $wait = $('<div class="rc-pop-wait" role="status">인사카드 불러오는 중…</div>').appendTo('body');
	var $f = $('<iframe class="rc-pop" title="인사카드">').attr('src', '/admin/staff/openStaffList.do?STAFF_SQ=' + sq + (career ? '&TAB=CAREER' : '') + '&embed=1&popup=1').appendTo('body');
	function done() { $(window).off('message.rcpop'); $f.remove(); $wait.remove(); }
	$(window).off('message.rcpop').on('message.rcpop', function(m) {
		var d = m.originalEvent.data;
		if (!d || !d.boPopup || m.originalEvent.source !== $f[0].contentWindow) return;
		if (d.boPopup === 'open') { $wait.remove(); $f[0].focus(); }
		else if (d.boPopup === 'close') { done(); load(); }
		else if (d.boPopup === 'empty') { done(); bootbox.alert('인사카드를 열 수 없어요(퇴사자이거나 직원관리 권한이 없음).'); }
	});
}
function dragSource($el, staffSq, ok) {
	if (!ok && D.canStaff) { $el.on('click', function() { staffPop(staffSq, true); }); return; }
	if (!ok) { $el.on('click', function() { bootbox.alert('저장된 수행이력 프로필이 없어 지원할 수 없어요. 인사카드 › 수행이력에서 「새 버전으로 저장」을 먼저 해 주세요.'); }); return; }
	$el.attr('draggable', true).on('dragstart', function(e) { e.originalEvent.dataTransfer.setData('text/plain', 'staff:' + staffSq); e.originalEvent.dataTransfer.effectAllowed = 'copy'; $('body').addClass('rc-dragging'); })
		.on('dragend', function() { $('body').removeClass('rc-dragging'); })
		.on('click', function(e) { var sq = $('#rcDetail').data('sq'); if (sq && !$(e.target).closest('a, button').length) applyDialog(sq, staffSq); }); // 상세 팝업 안에서 줄을 누르면 그 모집에 지원
}
function dropTarget($el, recruitSq) {
	$el.on('dragover', function(e) { if (!dragKind(e)) return; e.preventDefault(); $el.addClass('over'); })
		.on('dragleave drop', function() { $el.removeClass('over'); })
		.on('drop', function(e) {
			var v = e.originalEvent.dataTransfer.getData('text/plain') || '';
			if (v.indexOf('staff:') !== 0) return;
			e.preventDefault();
			e.stopPropagation(); // 상세 팝업은 안쪽(지원자 칸)과 바깥(모집 정보 전체)이 둘 다 받으므로 한 번만
			$('body').removeClass('rc-dragging');
			$el.parents('.over').removeClass('over');
			applyDialog(recruitSq, v.substring(6));
		});
}
function dragKind(e) { var t = e.originalEvent.dataTransfer.types; return t && [].indexOf.call(t, 'text/plain') >= 0; }

// 전체 직원에서 찾기(투입 중 포함)
function findBox() {
	var $in = $('#ppFind'), $list = $('#ppFindList');
	$in.on('input focus', function() {
		var q = $.trim($in.val());
		$list.empty().prop('hidden', !q);
		if (!q || !D) return;
		D.staff.filter(function(s) { return String(s.STAFF_NM).indexOf(q) >= 0; }).slice(0, 30).forEach(function(s) {
			var st = personState(s.STAFF_SQ), has = profilesOf(s.STAFF_SQ).length > 0;
			var $it = $('<div class="it">').append(nameEl(s, has)).append($('<span class="rc-yr small">').text(career(s).label || '')).append($('<span class="rc-pill">').toggleClass('FILLED', st.k === 'ACTIVE').text(st.label))
				.append($('<span class="rc-note">').text(st.row && st.k !== 'WAIT' ? (st.row.CLIENT_NM || '') + (st.row.END_DT ? ' · ~' + st.row.END_DT : '') : '')).append($('<div style="width:100%">').append(verChips(s.STAFF_SQ)));
			dragSource($it, s.STAFF_SQ, has);
			$list.append($it);
		});
		if (!$list.children().length) $list.append('<div class="it text-muted">찾는 직원이 없습니다(재직·대기 직원만)</div>');
	});
	$(document).on('click', function(e) { if (!$(e.target).closest('.rc-find').length) $list.prop('hidden', true); });
	$in.on('keydown', function(e) { if (e.key === 'Escape') { $in.val(''); $list.prop('hidden', true); } });
}

// ── 모집 목록 ──
function filtered() {
	var q = $.trim($('#rcFind').val()).toLowerCase();
	return D.recruits.filter(function(r) {
		if (ST_CHK.MISS && !missing(r).length) return false;
		if (!ST_CHK[r.STATUS_CD]) return false;
		return !q || [r.CLIENT_NM, r.PRJ_NM, r.SKILLS, r.WORK_AREA, r.SALE_PARTNER_NM].join(' ').toLowerCase().indexOf(q) >= 0;
	});
}
function render() {
	if (!D) return;
	var cnt = { MISS: 0 };
	D.recruits.forEach(function(r) { cnt[r.STATUS_CD] = (cnt[r.STATUS_CD] || 0) + 1; if (missing(r).length) cnt.MISS++; });
	boChips('#stChips', Object.keys(STATUS).map(function(k) { return { k: k, name: STATUS[k], n: cnt[k] || 0 }; }).concat(['<span class="mx-1 text-muted">|</span>', { k: 'MISS', name: '⚠ 확인 필요만', n: cnt.MISS, cls: 'alert' }]), ST_CHK, render);
	$('.rc-views button').each(function() { $(this).attr('aria-pressed', $(this).data('view') === VIEW); });
	var list = filtered(), $m = $('#rcMain').empty();
	$m.append($('<h3>').text('모집 ' + list.length));
	if (!D.recruits.length) { $m.append('<div class="cal-empty p-4 text-center text-muted">모집이 없습니다. 「+ 모집 등록」에 고객사 요청 원문을 붙여 넣어 등록해 주세요.</div>'); return; }
	({ card: viewCards, table: viewTable, board: viewBoard, cal: viewCal, tl: viewTimeline })[VIEW]($m, list);
}

function gradeLine(r) { return (r.GRADE_TXT || (r.HEAD_CNT ? r.HEAD_CNT + '명' : '')); }
function period(r) { return r.START_DT ? r.START_DT + ' ~ ' + (r.END_DT || '(미정)') : (r.PERIOD_TXT || ''); }
function joinedCnt(r) { return appsOf(r.RECRUIT_SQ).filter(function(a) { return a.STEP_CD === 'JOIN'; }).length; }
function closeLeft(r) { return r.CLOSE_DT ? days(today(), r.CLOSE_DT) : null; }
function stepSummary(r) {
	var c = {};
	appsOf(r.RECRUIT_SQ).forEach(function(a) { if (a.STEP_CD !== 'DROP') c[a.STEP_CD] = (c[a.STEP_CD] || 0) + 1; });
	return STEPS.filter(function(s) { return c[s[0]]; }).map(function(s) { return s[1] + ' ' + c[s[0]]; }).join(' · ');
}
function q(v) { return v === null || v === undefined || v === '' ? $('<span class="rc-q">? 미입력</span>') : document.createTextNode(v); }

function card(r, compact) {
	var miss = missing(r), apps = appsOf(r.RECRUIT_SQ), head = Number(r.HEAD_CNT || 0), joined = joinedCnt(r), left = closeLeft(r);
	var $c = $('<div class="rc-card" tabindex="0" role="button">').attr('data-sq', r.RECRUIT_SQ).toggleClass('miss', miss.length > 0).toggleClass('done', r.STATUS_CD === 'FILLED' || r.STATUS_CD === 'CLOSED');
	var $top = $('<div class="d-flex align-items-center flex-wrap" style="gap:4px">').append($('<span class="rc-pill">').addClass(r.STATUS_CD).text(STATUS[r.STATUS_CD]));
	if (miss.length) $top.append($('<span class="rc-pill warn">').text('⚠ 확인 필요 ' + miss.length).attr('title', miss.map(function(m) { return m[1]; }).join(', ')));
	if (left !== null && r.STATUS_CD !== 'CLOSED') $top.append($('<span class="rc-pill">').toggleClass('bad', left <= 3).text(left >= 0 ? '마감 D-' + left : '마감 지남'));
	if (r.FROM_CAL === 'Y') $top.append($('<span class="rc-fromcal" title="구글 캘린더에서 가져온 모집">📅 캘린더</span>'));
	$top.append($('<span class="ml-auto rc-note">').text(md(r.REG_D)));
	$c.append($top).append($('<div class="cl">').append(q(r.CLIENT_NM))).append($('<div class="pj">').append(r.PRJ_NM ? document.createTextNode(r.PRJ_NM) : $('<span class="rc-q">사업명 — 못 읽음</span>')));
	if (!compact) {
		var $dl = $('<dl>');
		function row(k, v) { $dl.append($('<dt>').text(k)).append($('<dd>').append(v)); }
		row('등급·인원', $('<b>').append(q(gradeLine(r))));
		row('투입', q(period(r)));
		row('근무지', q(r.WORK_AREA));
		row('단가', r.PRICE_TXT === '🔒' ? '🔒 권한자만' : q(r.PRICE_TXT));
		if (r.SKILLS) row('기술', $('<span>').append(String(r.SKILLS).split(/[,/·]/).filter(function(s) { return $.trim(s); }).map(function(s) { return $('<span class="rc-sk">').text($.trim(s)); })));
		row('매출처', r.SALE_PARTNER_SQ ? document.createTextNode(r.SALE_PARTNER_NM || partnerName(r.SALE_PARTNER_SQ)) : $('<span class="rc-q">').text('? ' + (r.SALE_PARTNER_TXT ? '"' + r.SALE_PARTNER_TXT + '" — 거래처 목록에 없음' : '미입력')));
		if (Number(r.FILE_CNT)) row('첨부', '📎' + r.FILE_CNT);
		$c.append($dl);
	}
	$c.append($('<div class="rc-prog">').append($('<i>').css({ width: (head ? Math.min(100, joined * 100 / head) : 0) + '%', background: r.STATUS_CD === 'FILLED' ? '#2f9e44' : '' })));
	$c.append($('<div class="rc-mini">').append($('<span>').text('지원 ' + apps.filter(function(a) { return a.STEP_CD !== 'DROP'; }).length + ' · 충원 ' + joined + '/' + (head || '?'))).append($('<span>').text(stepSummary(r))));
	apps.filter(function(a) { return a.STEP_CD !== 'DROP'; }).forEach(function(a) {
		$c.append($('<div class="rc-app">').append($('<b>').text(a.STAFF_NM)).append(stepChip(a)));
	});
	$c.append(addBtn(r.RECRUIT_SQ));
	$c.on('click', function(e) { if (!$(e.target).closest('button, a').length) detail(r.RECRUIT_SQ); }).on('keydown', function(e) { if (e.key === 'Enter' && e.target === this) detail(r.RECRUIT_SQ); });
	dropTarget($c, r.RECRUIT_SQ);
	return $c;
}

function viewCards($m, list) {
	var $g = $('<div class="rc-cards">');
	list.forEach(function(r) { $g.append(card(r)); });
	$m.append($g);
	if (!list.length) $m.append('<div class="text-muted p-3">고른 조건에 맞는 모집이 없습니다.</div>');
}
function viewTable($m, list) {
	var $t = $('<table class="table table-sm table-hover" id="rcTable" data-no-card>').append('<thead><tr><th scope="col">상태</th><th scope="col">확인</th><th scope="col">고객사</th><th scope="col">사업명</th><th scope="col">등급·인원</th><th scope="col">투입</th><th scope="col">근무지</th><th scope="col">단가</th><th scope="col">기술</th><th scope="col">매출처</th><th scope="col">지원/충원</th><th scope="col">진행</th><th scope="col">마감</th><th scope="col">등록일</th></tr></thead>');
	var $b = $('<tbody>').appendTo($t);
	list.forEach(function(r) {
		var miss = missing(r), left = closeLeft(r), apps = appsOf(r.RECRUIT_SQ).filter(function(a) { return a.STEP_CD !== 'DROP'; });
		var $tr = $('<tr style="cursor:pointer">').on('click', function(e) { if (!$(e.target).closest('button, a').length) detail(r.RECRUIT_SQ); });
		$tr.append($('<td>').append($('<span class="rc-pill">').addClass(r.STATUS_CD).text(STATUS[r.STATUS_CD])));
		$tr.append($('<td>').append(miss.length ? $('<span class="rc-pill warn">').text('⚠ ' + miss.length) : ''));
		[r.CLIENT_NM, r.PRJ_NM, gradeLine(r), period(r), r.WORK_AREA, r.PRICE_TXT, r.SKILLS, r.SALE_PARTNER_NM || r.SALE_PARTNER_TXT].forEach(function(v) { $tr.append($('<td>').append(q(v))); });
		$tr.append($('<td>').text(apps.length + ' · ' + joinedCnt(r) + '/' + (r.HEAD_CNT || '?')));
		$tr.append($('<td>').append(apps.map(function(a) { return $('<div class="text-nowrap">').append(document.createTextNode(a.STAFF_NM + ' ')).append(stepChip(a)); })).append(addBtn(r.RECRUIT_SQ)));
		$tr.append($('<td>').text(left === null ? '' : left >= 0 ? 'D-' + left : '지남'));
		$tr.append($('<td>').text(r.REG_D || ''));
		dropTarget($tr, r.RECRUIT_SQ);
		$b.append($tr);
	});
	if (!list.length) boEmpty($b, '고른 조건에 맞는 모집이 없습니다.');
	$m.append($('<div class="table-responsive">').append($t));
}
// 상태 보드: 칸 사이로 끌면 모집 상태가 바뀐다
function viewBoard($m, list) {
	var $g = $('<div class="rc-board">');
	Object.keys(STATUS).forEach(function(k) {
		var items = list.filter(function(r) { return r.STATUS_CD === k; });
		var $col = $('<div class="rc-bcol">').append($('<div class="mb-2">').append($('<span class="rc-pill">').addClass(k).text(STATUS[k] + ' ' + items.length)));
		items.forEach(function(r) {
			var $c = card(r, true).attr('draggable', true).on('dragstart', function(e) { e.originalEvent.dataTransfer.setData('text/plain', 'recruit:' + r.RECRUIT_SQ); });
			$col.append($c);
		});
		$col.on('dragover', function(e) { e.preventDefault(); $col.addClass('over'); }).on('dragleave drop', function() { $col.removeClass('over'); }).on('drop', function(e) {
			var v = e.originalEvent.dataTransfer.getData('text/plain') || '';
			if (v.indexOf('recruit:') !== 0) return;
			e.preventDefault();
			hrPost('/admin/recruit/statusData.do', { RECRUIT_SQ: v.substring(8), STATUS_CD: k }, function() { load(); });
		});
		$g.append($col);
	});
	$m.append($('<div class="rc-note mb-2">').text('모집 카드를 옆 칸으로 끌면 상태가 바뀌어요. 지원자는 카드를 눌러 상세 팝업 오른쪽 대기자에서 추가해요.')).append($('<div class="rc-board-wrap" style="overflow:auto">').append($g));
}
// 달력: 등록·마감·인터뷰·투입 시작
function viewCal($m, list) {
	var base = calMonth || today().substring(0, 7), y = +base.substring(0, 4), mo = +base.substring(5, 7);
	var first = new Date(y, mo - 1, 1), start = new Date(first); start.setDate(1 - ((first.getDay() + 6) % 7));
	// 날짜마다 인터뷰(시간순, 위)와 모집 일정(같은 모집의 등록·마감·투입은 한 줄로 합침)
	var ev = {}, KIND = { reg: '● 등록', due: '⏰ 마감', start: '▶ 투입' };
	function day(d) { d = d.substring(0, 10); return ev[d] = ev[d] || { intv: [], rec: {}, order: [] }; }
	function add(d, cls, sq) {
		if (!d) return;
		var x = day(d);
		if (!x.rec[sq]) { x.rec[sq] = []; x.order.push(sq); }
		x.rec[sq].push(cls);
	}
	// 모집 일정 아래 지원자 한 줄(이름 단계, 탈락 제외)
	function apLine(sq) {
		var ap = appsOf(sq).filter(function(a) { return a.STEP_CD !== 'DROP'; });
		if (!ap.length) return null;
		var txt = '👤 ' + ap.map(function(a) { return a.STAFF_NM + ' ' + STEP_NM[a.STEP_CD]; }).join(' · ');
		return $('<span class="ev-ap">').text(txt).attr('title', txt).on('click', function(e) { e.stopPropagation(); detail(sq); });
	}
	list.forEach(function(r) {
		add(r.REG_D, 'reg', r.RECRUIT_SQ);
		add(r.CLOSE_DT, 'due', r.RECRUIT_SQ);
		add(r.START_DT, 'start', r.RECRUIT_SQ);
		appsOf(r.RECRUIT_SQ).forEach(function(a) { if (a.INTV_DT) day(a.INTV_DT).intv.push({ a: a, r: r }); }); // 탈락한 인터뷰도 「탈락」으로 남긴다
	});
	var $nav = $('<div class="d-flex align-items-center mb-2" style="gap:6px">')
		.append($('<button type="button" class="btn btn-sm btn-outline-secondary" aria-label="이전 달">‹</button>').on('click', function() { var d = new Date(y, mo - 2, 1); calMonth = d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2); render(); }))
		.append($('<b>').text(y + '년 ' + mo + '월'))
		.append($('<button type="button" class="btn btn-sm btn-outline-secondary" aria-label="다음 달">›</button>').on('click', function() { var d = new Date(y, mo, 1); calMonth = d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2); render(); }))
		.append($('<button type="button" class="btn btn-sm btn-link">이번 달</button>').on('click', function() { calMonth = null; render(); }))
		.append('<span class="rc-cal-legend ml-auto"><span class="ev intv"><b>14:00</b> 🎤 인터뷰</span><span class="ev reg">● 등록</span><span class="ev due">⏰ 마감</span><span class="ev start">▶ 투입</span><span class="ev-ap">👤 지원자</span></span>');
	var $t = $('<table class="rc-cal">').append('<thead><tr><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th>토</th><th>일</th></tr></thead>'), $b = $('<tbody>').appendTo($t), t = today();
	for (var w = 0; w < 6; w++) {
		var $tr = $('<tr>');
		for (var i = 0; i < 7; i++) {
			var d = new Date(start); d.setDate(start.getDate() + w * 7 + i);
			var key = d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2);
			var label = (d.getMonth() + 1) + '월 ' + d.getDate() + '일';
			var $td = $('<td>').toggleClass('out', d.getMonth() !== mo - 1).toggleClass('today', key === t).attr('title', label + ' · 빈 곳을 누르면 이 날짜로 모집 등록')
				.append($('<div>').text(d.getDate()).append($('<button type="button" class="rc-day-add">+</button>').attr('aria-label', label + ' 모집 등록')));
			(function(key) { $td.on('click', function(e) { if (!$(e.target).closest('.ev, .ev-ap').length) pasteDialog(key); }); })(key);
			var x = ev[key];
			if (x) {
				x.intv.sort(function(p, q) { return p.a.INTV_DT.localeCompare(q.a.INTV_DT); }).forEach(function(v) {
					var is = intvState(v.a), sum = noteSummary(noteOf(v.a)), tip = '🎤 인터뷰 ' + v.a.INTV_DT.substring(11, 16) + ' · ' + is[1] + ' · ' + v.a.STAFF_NM + ' · ' + (v.r.CLIENT_NM || '') + ' ' + (v.r.PRJ_NM || '') + (v.a.INTV_PLACE ? ' · ' + v.a.INTV_PLACE : '') + (sum ? '\n📝 ' + sum : '');
					$td.append($('<span class="ev intv">').addClass(is[0]).attr('title', tip).append($('<b>').text(v.a.INTV_DT.substring(11, 16))).append(document.createTextNode(' 🎤 ' + v.a.STAFF_NM + ' ')).append($('<i class="ist">').addClass(is[0]).text(is[1])).append(' ').append($('<small>').text(v.r.CLIENT_NM || '')).append(v.a.LINK_SUBMIT_DT ? $('<b class="rc-selfev">').text(' 📝 제출' + (selfNew(v.a) ? ' ●' : '')) : '')
						.on('click', function() { noteDialog(v.a); })); // 달력 인터뷰는 바로 기록 창(본인 제출이면 보기)
				});
				x.order.forEach(function(sq) {
					var r = recruitOf(sq), kinds = x.rec[sq], txt = kinds.map(function(k) { return KIND[k]; }).join(' · ') + ' ' + (r.CLIENT_NM || '모집');
					var main = ['start', 'due', 'reg'].filter(function(k) { return kinds.indexOf(k) >= 0; })[0]; // 색은 투입 > 마감 > 등록
					$td.append($('<span class="ev">').addClass(main).text(txt).attr('title', txt + ' ' + (r.PRJ_NM || '')).on('click', function() { detail(sq); }));
					$td.append(apLine(sq));
				});
			}
			$tr.append($td);
		}
		$b.append($tr);
		if (d.getMonth() !== mo - 1 && w >= 4) break;
	}
	$m.append($nav).append($t);
}
// 인터뷰 상태 [클래스, 이름]: 탈락 / 통과(투입대기·확정) / 예정(앞으로) / 결과 대기(지났는데 인터뷰확정 그대로)
function intvState(a) {
	if (a.STEP_CD === 'DROP') return ['x', '탈락'];
	if (a.STEP_CD === 'JOIN_WAIT' || a.STEP_CD === 'JOIN') return ['ok', '통과'];
	if (a.STEP_CD === 'INTV_SUB') return ['sub', '결과 제출'];
	if (a.STEP_CD === 'INTV_CHK') return ['wait', '결과 확인중'];
	return a.INTV_DT.substring(0, 16) > nowYmdHm() ? ['plan', '예정'] : ['wait', '결과 대기'];
}
function nowYmdHm() { var d = new Date(); return today() + ' ' + ('0' + d.getHours()).slice(-2) + ':' + ('0' + d.getMinutes()).slice(-2); }
// 타임라인: 이번 달부터 6개월, 모집 투입 기간 막대 + 철수 임박 인원
function viewTimeline($m, list) {
	var t = today(), from = new Date(+t.substring(0, 4), +t.substring(5, 7) - 1, 1), to = new Date(from); to.setMonth(to.getMonth() + 6);
	var span = to - from;
	function pos(d) { return Math.max(0, Math.min(100, (new Date(d) - from) * 100 / span)); }
	var $g = $('<div class="rc-tl">'), $mon = $('<div class="mon">').css('grid-template-columns', 'repeat(6, 1fr)');
	for (var i = 0; i < 6; i++) { var d = new Date(from); d.setMonth(d.getMonth() + i); $mon.append($('<span>').text((d.getMonth() + 1) + '월')); }
	$g.append('<span></span>').append($mon);
	list.forEach(function(r) {
		var $trk = $('<span class="trk">').append($('<i class="now">').css('left', pos(t) + '%'));
		if (r.START_DT) {
			var l = pos(r.START_DT), rr = r.END_DT ? pos(r.END_DT) : 100;
			$trk.append($('<i class="bar">').addClass(r.STATUS_CD).toggleClass('open', !r.END_DT).css({ left: l + '%', width: Math.max(1, rr - l) + '%' }).attr('title', period(r)).on('click', function() { detail(r.RECRUIT_SQ); }));
		}
		var $nm = $('<b class="text-truncate">').text(r.CLIENT_NM || '(고객사)').attr('title', (r.CLIENT_NM || '') + ' ' + (r.PRJ_NM || '')).css('cursor', 'pointer').on('click', function() { detail(r.RECRUIT_SQ); });
		dropTarget($trk, r.RECRUIT_SQ);
		$g.append($nm).append($trk);
	});
	D.staff.forEach(function(s) {
		var st = personState(s.STAFF_SQ);
		if (st.k !== 'SOON' || !st.row || !st.row.END_DT) return;
		var $trk = $('<span class="trk" style="background:none">').append($('<i class="bar pp">').css({ left: 0, width: pos(st.row.END_DT) + '%' }).attr('title', s.STAFF_NM + ' 철수 ' + st.row.END_DT));
		$g.append($('<span class="text-success">').text(s.STAFF_NM + ' 철수')).append($trk);
	});
	$m.append($('<div class="rc-tl-wrap" style="overflow:auto">').append($g)).append('<div class="rc-note mt-2">주황 막대: 모집 투입 기간(점선 끝은 종료 미정) · 초록 얇은 막대: 30일 안에 철수하는 사람</div>');
}

// ── 지원 단계 ──
function stepChip(a) {
	var label = STEP_NM[a.STEP_CD] + (a.STEP_CD === 'INTV' && a.INTV_DT ? ' ' + md(a.INTV_DT) : '') + ' ▾';
	return $('<button type="button" class="rc-step">').addClass(a.STEP_CD).text(label).attr('aria-label', a.STAFF_NM + ' 진행 단계 ' + STEP_NM[a.STEP_CD] + ' 바꾸기').on('click', function(e) {
		e.stopPropagation();
		stepMenu($(this), a);
	});
}
function stepMenu($at, a) {
	$('.rc-menu').remove();
	var $menu = $('<div class="rc-menu" role="menu">');
	STEPS.concat([['DROP', '✕ 탈락']]).forEach(function(s) {
		$menu.append($('<button type="button" role="menuitem">').toggleClass('cur', s[0] === a.STEP_CD).text((s[0] === a.STEP_CD ? '● ' : '') + s[1]).on('click', function() { $menu.remove(); changeStep(a, s[0]); }));
	});
	if (a.STEP_CD !== 'JOIN') $menu.append($('<button type="button" role="menuitem">↺ 지원 취소 (기록 지움)</button>').on('click', function() { $menu.remove(); cancelApply(a); }));
	var o = $at.offset();
	$menu.css({ left: o.left, top: o.top + $at.outerHeight() + 2 }).appendTo('body');
	$menu.find('button').first().focus();
	setTimeout(function() { $(document).one('click', function() { $menu.remove(); }); });
	$menu.on('keydown', function(e) { if (e.key === 'Escape') { $menu.remove(); $at.focus(); } });
}
function stepper(a) {
	var idx = STEPS.map(function(s) { return s[0]; }).indexOf(a.STEP_CD);
	var $s = $('<span class="rc-stepper" role="group">').attr('aria-label', a.STAFF_NM + ' 진행 단계');
	STEPS.forEach(function(s, i) {
		$s.append($('<button type="button">').toggleClass('past', idx > i).toggleClass('now', idx === i).attr('aria-pressed', idx === i)
			.text((idx > i ? '✓ ' : idx === i ? '● ' : '') + s[1] + (s[0] === 'INTV' && a.INTV_DT && idx >= i ? ' ' + md(a.INTV_DT) + ' ' + a.INTV_DT.substring(11, 16) : ''))
			.on('click', function() { if (s[0] !== a.STEP_CD || s[0] === 'INTV' || s[0] === 'JOIN') changeStep(a, s[0]); }));
	});
	return $s;
}
function changeStep(a, step) {
	if (step === 'INTV') return interviewDialog(a);
	if (step === 'JOIN') return joinDialog(a);
	if (step === a.STEP_CD) return;
	function send(del, reason) {
		hrPost('/admin/recruit/stepData.do', { APPLY_SQ: a.APPLY_SQ, STEP_CD: step, DEL_DEPLOY: del ? 'Y' : 'N', REASON: reason || '' }, function(res) { notes(res.result); reload(); });
	}
	function ask(del) {
		if (step !== 'DROP') return send(del);
		bootbox.prompt({ title: a.STAFF_NM + ' 탈락 사유 (선택)', inputType: 'text', callback: function(v) { if (v !== null) send(del, v); } });
	}
	if (a.STEP_CD === 'JOIN' && a.DEPLOY_SQ) {
		bootbox.dialog({ title: '투입확정을 되돌려요', message: '투입현황에 만든 「투입 예정」도 지울까요? 이미 투입일이 지나 투입 중이면 지우지 않아요.', onEscape: true, buttons: {
			cancel: { label: '취소', className: 'btn-sm btn-outline-secondary' },
			keep: { label: '남기고 바꾸기', className: 'btn-sm btn-outline-primary', callback: function() { ask(false); } },
			del: { label: '지우고 바꾸기', className: 'btn-sm btn-danger', callback: function() { ask(true); } } } });
		return;
	}
	ask(false);
}
// 지원 취소: 탈락과 달리 지원 기록을 지워 같은 사람을 다시 지원시킬 수 있다
function cancelApply(a) {
	bootbox.confirm({ title: a.STAFF_NM + ' 지원 취소', message: '이 지원 기록을 지워요. 나중에 다시 지원시킬 수 있고, 드라이브의 프로필 워드는 휴지통으로 가요' + (a.INTV_DT ? '. 앞으로 잡힌 인터뷰는 취소 메일이 가요' : '') + '.<br><span class="rc-note">떨어진 거라면 「탈락」을 쓰세요. 탈락은 기록이 남아요.</span>',
		buttons: { confirm: { label: '지원 취소', className: 'btn-sm btn-danger' }, cancel: { label: '닫기', className: 'btn-sm btn-outline-secondary' } },
		callback: function(ok) { if (ok) hrPost('/admin/recruit/cancelData.do', { APPLY_SQ: a.APPLY_SQ }, function(res) { notes(res.result); hrToast(a.STAFF_NM + ' 지원을 취소했어요.'); reload(); }); } });
}
function reload() { var open = $('#rcDetail').data('sq'); load(function() { if (open) detail(open); }); }

// ── 모집 상세 ──
function detail(sq) {
	hrPost('/admin/recruit/detailData.do', { RECRUIT_SQ: sq }, function(res) {
		// 다시 열 때(저장 뒤 reload)는 애니메이션 없이 바꿔 끼운다: fade 를 빼면 동기로 닫혀 hidden 이 새 팝업보다 먼저 끝나 modal-open 이 지워지지 않는다
		var $old = $('#rcDetailModal'), swap = $old.hasClass('show'), top = $old.scrollTop();
		$('#rcSide').appendTo('#rcSideHome'); // 닫히는 팝업과 함께 지워지지 않게 먼저 빼 둔다
		if (swap) $old.removeClass('fade').modal('hide');
		bootbox.hideAll();
		var r = res.result.recruit, miss = missing(r), apps = appsOf(sq);
		var $f = $('<div id="rcDetail">').data('sq', sq);
		var $head = $('<div class="d-flex align-items-center flex-wrap mb-2" style="gap:6px">');
		var $st = $('<select class="form-control form-control-sm" style="width:auto" aria-label="모집 상태">');
		$.each(STATUS, function(k, v) { $st.append($('<option>').val(k).text(v)); });
		$st.val(r.STATUS_CD).on('change', function() { hrPost('/admin/recruit/statusData.do', { RECRUIT_SQ: sq, STATUS_CD: this.value }, reload); });
		$head.append($st);
		if (miss.length) $head.append($('<span class="rc-pill warn">').text('⚠ 확인 필요 ' + miss.length));
		$head.append($('<span class="rc-note">').text(r.REG_D + ' 등록 · ' + (r.REG_EMPLY_ID || '')));
		$f.append($head);
		// 원문(맨 위, 접고 펴기 — 펼친 상태는 이 브라우저에 기억). 글자를 끌어 선택하면 넣을 칸을 고른다
		var $raw = $('<div class="rc-raw" tabindex="0">').text(r.RAW_TEXT || '(원문 없음)'), rawOpen = false;
		try { rawOpen = localStorage.getItem('rc:rawOpen') === 'Y'; } catch (e) {}
		var $rawBox = $('<details class="rc-rawbox">').prop('open', rawOpen).append($('<summary>').text('📄 등록 원문 ' + (r.RAW_TEXT ? '(' + String(r.RAW_TEXT).split('\n').length + '줄)' : '(없음)')))
			.append($raw).append('<div class="rc-note mt-1">글자를 끌어 선택하면 넣을 칸을 고르는 메뉴가 떠요.</div>')
			.on('toggle', function() { try { localStorage.setItem('rc:rawOpen', this.open ? 'Y' : 'N'); } catch (e) {} });
		$f.append($rawBox);
		// 지원자
		var $ap = $('<div>');
		apps.forEach(function(a) { $ap.append(applyRow(a)); });
		if (!apps.length) $ap.append('<div class="rc-note">아직 지원자가 없어요. 오른쪽 대기자 줄을 누르거나 여기로 끌어 놓으면 지원 창이 떠요.</div>');
		var $apDrop = $('<div class="rc-dropzone">').append('<b>⬇ 여기에 대기자를 끌어 놓으면 지원</b>').append('<span>오른쪽 대기자 줄을 잡아 이 상자에 놓거나, 줄을 한 번 누르세요</span>');
		dropTarget($apDrop, sq);
		$f.append($('<div class="rc-sec" style="border-top:0;margin-top:0;padding-top:0">').append($('<h4>').text('지원자 ' + apps.filter(function(a) { return a.STEP_CD !== 'DROP'; }).length)).append($ap).append($apDrop));
		var $form = fieldForm(r, miss);
		$f.append($form);
		rawPicker($raw, $form);
		// 드라이브 폴더
		var $fold = $('<div class="d-flex align-items-center" style="gap:6px">');
		if (r.FOLDER_ID) $fold.append('📁 ').append($('<a target="_blank" rel="noopener">').attr('href', 'https://drive.google.com/drive/folders/' + r.FOLDER_ID).text('드라이브에서 열기 ↗'));
		else $fold.append('<span class="text-warning">폴더 없음</span>').append($('<button type="button" class="btn btn-sm btn-outline-primary">폴더 만들기</button>').on('click', function() { hrPost('/admin/recruit/folderData.do', { RECRUIT_SQ: sq }, reload); }));
		$f.append($('<div class="rc-sec">').append('<h4>드라이브 폴더</h4>').append($fold));
		// 첨부
		var $files = $('<table class="table table-sm mb-1">'), $fb = $('<tbody>').appendTo($files);
		res.result.files.forEach(function(x) {
			$fb.append($('<tr>').append($('<td>').append($('<a target="_blank" rel="noopener">').attr('href', x.FILE_URL || '#').text('📄 ' + x.FILE_NM)))
				.append($('<td class="rc-note">').text(Math.max(1, Math.round((x.FILE_SIZE || 0) / 1024)) + 'KB · ' + x.REG_DT + ' ' + (x.REG_EMPLY_ID || '')))
				.append($('<td class="text-right">').append($('<button type="button" class="btn btn-sm btn-link text-danger p-0" aria-label="첨부 지우기">🗑</button>').on('click', function() {
					bootbox.confirm(x.FILE_NM + ' 을(를) 지울까요? 드라이브에서는 휴지통으로 가요.', function(ok) { if (ok) hrPost('/admin/recruit/deleteFileData.do', { RECRUIT_SQ: sq, FILE_SQ: x.FILE_SQ }, reload); });
				}))));
		});
		var $up = $('<input type="file" multiple class="d-none">').on('change', function() { uploadFiles(sq, this.files, reload); });
		var $drop = $('<div class="rc-drop-hint" tabindex="0" role="button">📎 여기에 파일을 끌어 놓거나 눌러서 고르기</div>').on('click keydown', function(e) { if (e.type === 'click' || e.key === 'Enter') $up.click(); })
			.on('dragover', function(e) { e.preventDefault(); }).on('drop', function(e) { e.preventDefault(); uploadFiles(sq, e.originalEvent.dataTransfer.files, reload); });
		$f.append($('<div class="rc-sec">').append($('<h4>').text('첨부 ' + res.result.files.length)).append($files).append($drop).append($up));
		// 이력
		var $log = $('<details class="rc-sec">').append($('<summary class="small font-weight-bold">').text('변경 이력 ' + res.result.logs.length));
		res.result.logs.forEach(function(l) { $log.append($('<div class="small">').text(l.REG_DT + ' · ' + (l.EMPLY_ID || '') + ' · ' + l.SUMMARY)); });
		$f.append($log);
		dropTarget($f, sq); // 왼쪽 모집 정보 어디에 놓아도 지원
		CUR_SQ = sq;
		people(); // 이 모집 기준 관련도순으로 다시 그림
		var $dlg = bootbox.dialog({ title: (r.CLIENT_NM || '(고객사 미입력)') + ' · ' + (r.PRJ_NM || ''), message: $('<div class="rc-dwrap">').append($f).append($('#rcSide')), size: 'extra-large', className: 'rc-detail', onEscape: true, backdrop: true, animate: !swap, buttons: {
			del: { label: '모집 삭제', className: 'btn-sm btn-outline-danger mr-auto', callback: function() {
				bootbox.confirm('이 모집을 지울까요? 드라이브 폴더는 그대로 남아요.', function(ok) { if (ok) hrPost('/admin/recruit/deleteData.do', { RECRUIT_SQ: sq }, function() { bootbox.hideAll(); load(); }); });
				return false;
			} },
			close: { label: '닫기', className: 'btn-sm btn-outline-secondary' },
			save: { label: '저장', className: 'btn-sm btn-primary', callback: function() {
				var data = $.extend({ RECRUIT_SQ: sq }, formData($form));
				hrPost('/admin/recruit/saveData.do', data, function(res2) { notes(res2.result.notes); hrToast('저장했습니다.'); reload(); });
				return false;
			} } } }).attr('id', 'rcDetailModal').on('hide.bs.modal', function(e) { if (e.target === this) { $('#rcSide').appendTo('#rcSideHome'); CUR_SQ = null; } });
		if (swap) $dlg.scrollTop(top);
	});
}
function applyRow(a) {
	var $r = $('<div class="d-flex align-items-center flex-wrap mb-2" style="gap:8px">').toggleClass('text-muted', a.STEP_CD === 'DROP');
	$r.append($('<b style="min-width:56px">').text(a.STAFF_NM));
	$r.append($('<span class="rc-ver">').addClass(String(a.VER_LABEL || '').indexOf('가필') === 0 ? 'EDIT' : '').text(a.VER_LABEL || '-'));
	if (a.FROM_CAL === 'Y') $r.append($('<span class="rc-fromcal" title="캘린더 인터뷰 일정에서 가져옴">📅 캘린더</span>'));
	if (a.STEP_CD === 'DROP') $r.append($('<span class="rc-step DROP">').text('탈락')).append($('<span class="rc-note">').text(a.DROP_REASON || ''))
		.append($('<button type="button" class="btn btn-sm btn-link p-0">되살리기</button>').on('click', function() { changeStep(a, 'DOC'); }));
	else $r.append(stepper(a)).append($('<button type="button" class="rc-x drop" title="떨어짐 — 기록이 남아요">✕ 탈락</button>').on('click', function() { changeStep(a, 'DROP'); }));
	if (a.STEP_CD !== 'JOIN') $r.append($('<button type="button" class="rc-x" title="지원 기록을 지워요 — 다시 지원시킬 수 있어요">↺ 취소</button>').on('click', function() { cancelApply(a); }));
	if (a.FILE_ID) $r.append($('<a target="_blank" rel="noopener" title="모집 폴더에 저장된 프로필 워드">').attr('href', 'https://drive.google.com/file/d/' + a.FILE_ID + '/view').text('📄 ' + (a.FILE_NM || '워드')));
	else $r.append($('<button type="button" class="btn btn-sm btn-warning py-0 font-weight-bold" title="지원할 때 드라이브에 올리지 못했어요">⚠ 드라이브에 없음 · 다시 저장</button>').on('click', function() { hrPost('/admin/recruit/wordData.do', { APPLY_SQ: a.APPLY_SQ }, function() { hrToast('드라이브에 저장했어요.'); reload(); }); }));
	if (a.INTV_DT) { var is = intvState(a); $r.append($('<span class="rc-note">').text('🎤 ' + a.INTV_DT + ' · ' + (WAY[a.INTV_WAY] || '') + (a.INTV_PLACE ? ' · ' + a.INTV_PLACE : '') + ' ').append($('<i class="ist">').addClass(is[0]).text(is[1]))); }
	if (a.INTV_DT || a.INTV_NOTE) {
		var sum = noteSummary(noteOf(a));
		if (!a.LINK_SUBMIT_DT) $r.append(linkBtn(a));
		$r.append($('<button type="button" class="rc-notebtn">').toggleClass('has', !!sum).attr('title', sum ? '인터뷰 기록 보기' : '인터뷰 기록 남기기').text(sum ? '📝 ' + sum : '📝 인터뷰 기록').on('click', function(e) { e.stopPropagation(); noteDialog(a); }));
		if (a.LINK_SUBMIT_DT) $r.append($('<span class="rc-self">').text('본인 제출 ' + md(a.LINK_SUBMIT_DT) + ' ' + a.LINK_SUBMIT_DT.substring(11))).append(selfNew(a) ? $('<span class="rc-newdot" title="새로 제출됨">●</span>') : '');
	}
	if (a.DEPLOY_SQ) $r.append($('<a href="/admin/deploy/openDeployList.do" target="_blank" rel="noopener">투입현황 보기 ↗</a>'));
	if (a.DRAFT && a.STEP_CD === 'JOIN_WAIT') $r.append($('<button type="button" class="btn btn-sm btn-link p-0">투입확정 임시 저장 이어서 ›</button>').on('click', function() { joinDialog(a); }));
	return $r;
}

// 칸 입력 폼(상세·등록 공통). 못 읽은 칸은 주황
function fieldForm(r, miss) {
	var missKeys = (miss || []).map(function(m) { return m[0]; }), $k = $('<div class="rc-kv rc-kv4">'); // 한 줄에 칸 두 쌍(rc-kv4)으로 높이를 줄인다
	FIELDS.forEach(function(f) {
		var id = 'rf_' + f[0], v = r[f[0]], $c;
		if (SECTION_AT[f[0]]) $k.append($('<div class="hr-section rc-sec">').text(SECTION_AT[f[0]]));
		if (f[0] === 'PRICE_TXT' && !D.canPay) { $k.append($('<label>').text('단가')).append($('<span class="text-muted">').text('🔒 급여 권한자만 보고 고쳐요')); return; }
		if (f[3] === 'partner') {
			$c = $('<select class="form-control form-control-sm">').append('<option value="">(고르기)</option>');
			D.partners.filter(function(p) { return p.USE_YN === 'Y' && p.SALE_YN !== 'N'; }).forEach(function(p) { $c.append($('<option>').val(p.PARTNER_SQ).text(p.PARTNER_NM)); });
			$c.val(v || '');
			var $wrap = $('<div class="d-flex align-items-center flex-wrap wide" style="gap:6px">').append($c.css('width', 'auto').attr({ id: id, name: f[0] }));
			if (r.SALE_PARTNER_TXT && !v) $wrap.append($('<span class="rc-q small">').text('원문: "' + r.SALE_PARTNER_TXT + '" — 목록에 없음'));
			$wrap.append('<a href="/admin/partner/openPartnerList.do" target="_blank" rel="noopener" class="small">+ 새 거래처로 등록 ↗</a>');
			$wrap.append($('<input type="hidden" name="SALE_PARTNER_TXT">').val(r.SALE_PARTNER_TXT || ''));
			$k.append($('<label>').attr('for', id).toggleClass('q', missKeys.indexOf(f[0]) >= 0).text(f[1])).append($wrap);
			return;
		}
		$c = f[3] === 'textarea' ? $('<textarea rows="2" class="form-control form-control-sm wide">') : $('<input class="form-control form-control-sm">').attr('type', f[3] || 'text');
		$c.attr({ id: id, name: f[0], placeholder: f[2] || '' }).val(v == null ? '' : v);
		$k.append($('<label>').attr('for', id).toggleClass('q', missKeys.indexOf(f[0]) >= 0).text(f[1])).append($c);
	});
	return $k;
}
function formData($form) {
	var d = {};
	$form.find('[name]').each(function() { d[this.name] = $.trim($(this).val()); });
	return d;
}
// 원문에서 고른 글자를 칸에 넣는 작은 메뉴
function rawPicker($raw, $form) {
	$raw.on('mouseup keyup', function() {
		var sel = window.getSelection ? String(window.getSelection()) : '';
		$('.rc-menu').remove();
		sel = $.trim(sel);
		if (!sel || sel.length > 300) return;
		var $menu = $('<div class="rc-menu" role="menu">').append($('<div class="rc-note px-2">').text('"' + sel.substring(0, 20) + '" 넣을 칸'));
		FIELDS.forEach(function(f) {
			var $in = $form.find('[name=' + f[0] + ']');
			if (!$in.length || $in.is('select') || $in.attr('type') === 'hidden') return;
			$menu.append($('<button type="button" role="menuitem">').text(f[1]).on('click', function() {
				var v = sel;
				if ($in.attr('type') === 'date') { var m = sel.match(/(\d{4})\D+(\d{1,2})\D+(\d{1,2})/); if (!m) { bootbox.alert('날짜 칸에는 2026-12-01 같은 날짜를 골라 주세요.'); return; } v = m[1] + '-' + ('0' + m[2]).slice(-2) + '-' + ('0' + m[3]).slice(-2); }
				$in.val(v).addClass('is-valid').closest('.rc-kv').find('label[for=' + $in.attr('id') + ']').removeClass('q');
				$menu.remove();
			}));
		});
		var rect = window.getSelection().getRangeAt(0).getBoundingClientRect();
		$menu.css({ left: rect.left + window.scrollX, top: rect.bottom + window.scrollY + 4 }).appendTo('body');
		setTimeout(function() { $(document).one('mousedown', function(e) { if (!$(e.target).closest('.rc-menu').length) $menu.remove(); }); });
	});
}
function uploadFiles(sq, files, done) {
	files = [].slice.call(files || []);
	(function next(i) {
		if (i >= files.length) { if (done) done(); return; }
		var fd = new FormData();
		fd.append('RECRUIT_SQ', sq);
		fd.append('file', files[i]);
		hrToast(files[i].name + ' 올리는 중…');
		$.ajax({ url: '/admin/recruit/uploadData.do', type: 'POST', data: fd, processData: false, contentType: false }).done(function(res) {
			if (res.error) { if (res.error.indexOf('[연동 필요:') !== 0) bootbox.alert(files[i].name + ': ' + res.error); }
			next(i + 1);
		}).fail(function() { next(i + 1); });
	})(0);
}

// ── 📅 캘린더 가져오기(plans/recruit-cal-import-spec.html): 설정·마지막 결과·못 맞춘 일정, 지금 가져오기 ──
function calDialog() {
	var CNT = [['NEW', '모집 새로'], ['SAME', '이미 있음'], ['INTV', '인터뷰 맞춤'], ['ADD', '지원자 추가'], ['MISS', '못 맞춤'], ['OTHER', '그 밖 일정']];
	var $f = $('<div>'), dlg;
	function paint(d) {
		var $id = $('<input class="form-control form-control-sm" style="max-width:280px">').val(d.CAL_ID);
		$f.empty().append($('<div class="d-flex align-items-center flex-wrap mb-2" style="gap:6px">').append('<b class="small">읽을 캘린더 ID</b>').append($id)
			.append($('<button type="button" class="btn btn-sm btn-outline-secondary">저장</button>').on('click', function() { post({ ACT: 'SAVE', CAL_ID: $id.val() }, '저장했어요.'); }))
			.append('<span class="rc-note">회사 공용 캘린더 연결(면접 배치와 같은)로 읽어요. 매일 09:00 배치 때 최근 30일을 자동으로 가져와요.</span>'));
		var l = d.last;
		if (!l) { $f.append('<div class="rc-note mb-2">아직 가져온 적이 없어요. 처음엔 「처음부터 전체」로 2021년 1월부터 가져와 주세요.</div>'); return; }
		$f.append($('<div class="small mb-1">').text('마지막 가져오기 ' + l.AT + ' · ' + ({ AUTO: '배치', RUN: '최근 30일', ALL: '처음부터 전체' }[l.TRIGGER] || l.TRIGGER) + ' · ' + l.FROM + ' 부터 · ' + l.CAL_ID));
		if (l.OK === false) $f.append($('<div class="alert alert-danger py-1 px-2 small">').text('가져오지 못했어요: ' + (l.ERROR || '')));
		var $s = $('<div class="d-flex flex-wrap mb-2" style="gap:6px">');
		CNT.forEach(function(c) { $s.append($('<div class="rc-calstat">').toggleClass('bad', c[0] === 'MISS' && (l.CNT || {})[c[0]] > 0).append($('<b>').text((l.CNT || {})[c[0]] || 0)).append(document.createTextNode(c[1]))); });
		$f.append($s);
		var miss = l.MISS_LIST || [];
		if (miss.length) {
			var $t = $('<table class="table table-sm mb-1" data-nopick>').append('<thead><tr><th>날짜</th><th>일정</th><th>못 맞춘 이유</th></tr></thead>'), $b = $('<tbody>').appendTo($t);
			miss.forEach(function(m) { $b.append($('<tr>').append($('<td class="text-nowrap">').text(m.D)).append($('<td>').text(m.T)).append($('<td class="text-danger">').text(m.WHY))); });
			$f.append($t).append('<div class="rc-note">모집을 먼저 등록하거나 직원 이름을 맞춰 두면 다음 가져오기 때 자동으로 맞춰져요.</div>');
		}
	}
	function post(data, toast) {
		hrPost('/admin/recruit/calData.do', data, function(res) { paint(res.result); if (toast) hrToast(toast); if (data.ACT === 'RUN' || data.ACT === 'ALL') load(); });
	}
	dlg = bootbox.dialog({ title: '📅 모집 캘린더 가져오기', message: $f, size: 'large', onEscape: true, buttons: {
		all: { label: '처음부터 전체(2021-01~)', className: 'btn-sm btn-outline-secondary mr-auto', callback: function() {
			bootbox.confirm('2021년 1월부터 캘린더 전체를 가져올까요? 몇 분 걸릴 수 있어요. 이미 가져온 일정은 다시 넣지 않아요.', function(ok) { if (ok) post({ ACT: 'ALL' }, '가져왔어요.'); });
			return false;
		} },
		close: { label: '닫기', className: 'btn-sm btn-outline-secondary' },
		run: { label: '지금 가져오기(최근 30일)', className: 'btn-sm btn-primary', callback: function() { post({ ACT: 'RUN' }, '가져왔어요.'); return false; } } } });
	post({ ACT: 'VIEW' });
}

// ── + 모집 등록(원문 붙여 넣기). day: 달력에서 고른 날짜 → 투입 시작(또는 지원 마감)에 넣는다 ──
function pasteDialog(day) {
	var $f = $('<div>'), dayKey = 'START_DT', $ta = $('<textarea class="form-control" rows="7" aria-label="원문 붙여 넣기" placeholder="메일·카톡·문서 원문을 그대로 붙여 넣어 주세요.&#10;예) [모집] 신한금융그룹 책무이행시스템 초급 1명&#10;기간: 12월 초 ~ 6개월&#10;근무지: 을지로 상주">');
	var $res = $('<div class="mt-2 p-2" style="border:1px dashed #bac8ff;border-radius:8px;background:#f8f9ff">').append('<div class="rc-note">붙여 넣으면 바로 읽어서 아래에 채워요. 고쳐서 저장하면 돼요.</div>');
	var $files = $('<input type="file" multiple class="form-control-file form-control-sm" aria-label="첨부 파일">'), $form = null, timer;
	if (day) {
		var $sel = $('<select class="form-control form-control-sm d-inline-block mx-1" style="width:auto" aria-label="고른 날짜를 넣을 칸"><option value="START_DT">투입 시작</option><option value="CLOSE_DT">지원 마감</option></select>').on('change', function() {
			var old = dayKey;
			dayKey = this.value;
			if ($form) { if ($form.find('[name=' + old + ']').val() === day) $form.find('[name=' + old + ']').val(''); if (!$form.find('[name=' + dayKey + ']').val()) $form.find('[name=' + dayKey + ']').val(day); }
		});
		$f.append($('<div class="alert alert-info py-1 px-2 small mb-2">').append('📅 ' + (+day.substring(5, 7)) + '월 ' + (+day.substring(8, 10)) + '일을').append($sel).append('칸에 넣어요. 원문에 날짜가 있으면 원문 값이 먼저예요.'));
	}
	$f.append('<div class="small font-weight-bold mb-1">원문 붙여 넣기</div>').append($ta).append($res)
		.append($('<div class="mt-2 small">').append('<b>첨부</b> ').append($files).append('<div class="rc-note">저장한 뒤 모집 드라이브 폴더의 「첨부」에 올라가요.</div>'));
	function parse() {
		hrPost('/admin/recruit/parseData.do', { RAW_TEXT: $ta.val() }, function(res) {
			var r = res.result;
			if (day && !r[dayKey]) r[dayKey] = day;
			var miss = missing(r);
			$form = fieldForm(r, miss);
			$res.empty().append($('<div class="small font-weight-bold mb-2">').text('읽은 결과' + (miss.length ? ' · ⚠ 못 읽은 칸 ' + miss.length + ' (주황, 그대로 저장해도 돼요)' : ''))).append($form);
		});
	}
	$ta.on('input', function() { clearTimeout(timer); timer = setTimeout(parse, 400); });
	bootbox.dialog({ title: '+ 모집 등록' + (day ? ' · ' + md(day) : ''), message: $f, size: 'large', onEscape: true, buttons: {
		cancel: { label: '취소', className: 'btn-sm btn-outline-secondary' },
		ok: { label: '등록 · 드라이브 폴더 만들기', className: 'btn-sm btn-primary', callback: function() {
			if (!$.trim($ta.val())) { $ta.focus(); return false; }
			var data = $.extend({ RAW_TEXT: $ta.val() }, $form ? formData($form) : {});
			if (day && !data[dayKey]) data[dayKey] = day;
			hrPost('/admin/recruit/saveData.do', data, function(res) {
				var sq = res.result.RECRUIT_SQ, files = $files[0].files;
				bootbox.hideAll();
				notes(res.result.notes);
				uploadFiles(sq, files, function() { load(function() { detail(sq); }); });
			});
			return false;
		} } } }).on('shown.bs.modal', function() { $ta.focus(); });
}

// ── 「＋ 지원자 추가」: 끌어 놓기 대신 대기자 패널과 같은 사람 중에서 골라 applyDialog 로 ──
function addBtn(recruitSq) {
	return $('<button type="button" class="rc-add">＋ 지원자 추가</button>').on('click', function(e) { e.stopPropagation(); pickApplicant(recruitSq); });
}
function pickApplicant(recruitSq) {
	var applied = appsOf(recruitSq).map(function(a) { return String(a.STAFF_SQ); });
	var $find = $('<input type="search" class="form-control form-control-sm mb-2" placeholder="이름 찾기 (비우면 대기자만)" aria-label="지원자 이름 찾기">'), $list = $('<div style="max-height:55vh;overflow:auto">');
	var dlg = bootbox.dialog({ title: '지원자 고르기', message: $('<div>').append($find).append($list), onEscape: true, buttons: { cancel: { label: '닫기', className: 'btn-secondary' } } });
	function paint() {
		var q = $.trim($find.val());
		var rows = D.staff.filter(function(s) { return applied.indexOf(String(s.STAFF_SQ)) < 0 && (q ? String(s.STAFF_NM).indexOf(q) >= 0 : PP_CHK[personState(s.STAFF_SQ).k]); });
		$list.empty();
		rows.slice(0, 50).forEach(function(s) {
			var st = personState(s.STAFF_SQ), has = profilesOf(s.STAFF_SQ).length > 0;
			$list.append($('<button type="button" class="rc-pick">').prop('disabled', !has).append($('<b>').text(s.STAFF_NM))
				.append($('<span class="rc-pill">').addClass(st.k === 'SOON' ? 'warn' : st.k === 'FUTURE' ? 'FILLED' : '').text(st.label))
				.append($('<span class="rc-note">').text(has ? [s.POSITION_NM, s.DEPT_NM].filter(Boolean).join(' · ') : '프로필 없음'))
				.on('click', function() { /* 앞 창이 다 닫힌 뒤 열어야 body.modal-open 이 안 지워져 스크롤된다 */ dlg.one('hidden.bs.modal', function() { applyDialog(recruitSq, s.STAFF_SQ); }).modal('hide'); }));
		});
		if (!rows.length) $list.append('<div class="text-muted p-2">고를 사람이 없습니다.</div>');
	}
	$find.on('input', paint);
	paint();
}

// ── 지원 창 ──
function applyDialog(recruitSq, staffSq) {
	var r = recruitOf(recruitSq), s = staffOf(staffSq), ps = profilesOf(staffSq), st = personState(staffSq);
	if (!r || !s) return;
	if (appsOf(recruitSq).some(function(a) { return String(a.STAFF_SQ) === String(staffSq); })) { bootbox.alert(s.STAFF_NM + ' 님은 이미 이 모집에 지원했어요.'); return; }
	if (!ps.length) { bootbox.alert('저장된 수행이력 프로필이 없어 지원할 수 없어요. 인사카드 › 수행이력에서 버전을 저장해 주세요.'); return; }
	var $f = $('<div>'), pick = String(ps[0].VER_NO);
	if (st.k === 'ACTIVE' || st.k === 'SOON') $f.append($('<div class="alert alert-warning py-1 px-2 small">').text('현재 ' + (st.row.CLIENT_NM || '') + ' 투입 중' + (st.row.END_DT ? '(~' + st.row.END_DT + ')' : '') + '이에요. 그래도 지원할까요?'));
	if (st.k === 'FUTURE') $f.append($('<div class="alert alert-info py-1 px-2 small">').text((st.row.CLIENT_NM || '') + ' 투입 예정(' + st.row.START_DT + ')인 사람이에요.'));
	$f.append('<div class="small mb-1">함께 보낼 수행이력 프로필</div>');
	function opt(val, html, sub, preview) {
		var $o = $('<div class="rc-opt" role="radio" tabindex="0">').attr({ 'aria-checked': pick === val, 'data-ver': val }).toggleClass('on', pick === val).append($('<b>').text(html)).append($('<span class="rc-note">').text(sub));
		if (preview) $o.append($('<a class="ml-auto small">').attr('href', preview).text('미리보기(워드)').on('click', function(e) { e.stopPropagation(); }));
		$o.on('click keydown', function(e) { if (e.type === 'keydown' && e.key !== 'Enter' && e.key !== ' ') return; e.preventDefault(); pick = val; $f.find('.rc-opt').removeClass('on').attr('aria-checked', false); $o.addClass('on').attr('aria-checked', true); paintName(); });
		return $o;
	}
	ps.forEach(function(p, i) { $f.append(opt(String(p.VER_NO), (p.VER_KIND === 'EDIT' ? '가필 v' : '순정 v') + p.VER_NO, p.REG_DT + ' · 프로젝트 ' + (p.PRJ_CNT || 0) + '건' + (i === 0 ? ' · 최신' : ''), '/admin/recruit/profileWord.do?STAFF_SQ=' + staffSq + '&VER_NO=' + p.VER_NO)); });
	$f.append(opt('GEN', '✨ 이 모집에 맞춰 가필 새로 생성', r.SKILLS ? '요구 기술(' + r.SKILLS + ') 순으로 정리해 새 가필 버전을 만들어요' : '요구 기술이 비어 있어 최근 순으로 만들어요'));
	var $name = $('<div class="rc-note mt-2">');
	function paintName() {
		var p = ps.filter(function(x) { return String(x.VER_NO) === pick; })[0];
		$name.text('📁 …/' + (r.CLIENT_NM || '') + '_' + (r.PRJ_NM || '') + ' / ' + s.STAFF_NM + '_수행이력_' + (pick === 'GEN' ? '가필v(새 번호)' : (p.VER_KIND === 'EDIT' ? '가필v' : '순정v') + p.VER_NO) + '.docx');
	}
	paintName();
	$f.append($name);
	// 프로필마다 기간·역할·산업·많이 쓴 기술(모집 요구 기술과 같은 것은 보라색)
	var want = String(r.SKILLS || '').split(/[,/·\s\-+&]+/).map(techKey).filter(Boolean);
	hrPost('/admin/recruit/versionsData.do', { STAFF_SQ: staffSq }, function(res) {
		(res.result || []).forEach(function(v) {
			var $s = $('<div class="rc-psum">');
			if (v.SPAN) $s.append($('<span>').text('📅 ' + v.SPAN));
			if ((v.ROLES || []).length) $s.append($('<span>').text('역할 ' + v.ROLES.join('·')));
			if ((v.INDS || []).length) $s.append($('<span>').text('산업 ' + v.INDS.join('·')));
			(v.TECHS || []).forEach(function(t) { $s.append($('<span class="rc-tk">').toggleClass('on', want.indexOf(techKey(t)) >= 0).text(t)); });
			$f.find('.rc-opt[data-ver="' + v.VER_NO + '"]').append($s);
		});
	});
	// 이 창만 닫고 reload: 상세 팝업이 열려 있으면 깜빡임 없이 그 자리에서 지원자가 늘어난다
	var dlg = bootbox.dialog({ title: s.STAFF_NM + ' → ' + (r.CLIENT_NM || '모집') + ' 지원', message: $f, onEscape: true, buttons: {
		cancel: { label: '취소', className: 'btn-sm btn-outline-secondary' },
		ok: { label: '지원 · 드라이브에 저장', className: 'btn-sm btn-primary', callback: function() {
			hrPost('/admin/recruit/applyData.do', { RECRUIT_SQ: recruitSq, STAFF_SQ: staffSq, VER: pick }, function(res) { dlg.modal('hide'); notes(res.result.notes); hrToast(s.STAFF_NM + ' 지원을 등록했어요.'); reload(); });
			return false;
		} } } });
}

// ── 인터뷰 기록: 인터뷰를 본 사람과 통화하며 들은 내용. 칩은 공통코드(RC_INTV_*)라 ＋로 바로 추가, ✎ 로 빼기 ──
// [키, 이름, 여러 개?]. 질문·답변(여러 쌍, 모의 인터뷰 자료)과 메모만 글로 쓴다
var NOTE_CATS = [['mood', 'MOOD', '분위기'], ['who', 'WHO', '면접관', true], ['dur', 'DUR', '소요 시간'], ['flow', 'FLOW', '진행 흐름', true], ['askd', 'ASKD', '많이 받은 질문', true],
	['tech', 'TECH', '질문받은 기술', true], ['feel', 'FEEL', '본인 느낌'], ['cli', 'CLI', '고객 반응', null, '본인이 느낀'], ['etc', 'ETC', '특이사항', true], ['notice', 'NOTICE', '결과 안내']];
function noteOf(a) { try { return JSON.parse(a.INTV_NOTE || '{}') || {}; } catch (e) { return {}; } }
function noteSummary(n) {
	var qa = (n.qa || []).filter(function(x) { return x.q; }).length;
	var s = [n.mood, n.dur, n.feel && '느낌 ' + n.feel, n.cli && '고객 ' + n.cli].concat(n.etc || []).concat([n.notice && '안내 ' + n.notice]).filter(Boolean);
	if (!s.length && n.r) s = [n.r, n.cli && '고객 ' + n.cli].filter(Boolean); // 2026-11-20 첫 버전(평가형) 기록
	return s.join(' · ') + (qa ? ' · ❓' + qa : '') + (n.memo ? ' · 💬' : '');
}
// ── 인터뷰 기록 링크(계정 없이 본인이 제출, /intv.do?t=…) ──
function linkUrl(token) { return location.origin + '/intv.do?t=' + token; }
function copyText(t, done) {
	var ok = function() { hrToast(done); };
	if (navigator.clipboard && window.isSecureContext) return navigator.clipboard.writeText(t).then(ok, function() { bootbox.prompt({ title: '링크를 복사해 주세요', value: t, callback: function() {} }); });
	bootbox.prompt({ title: '링크를 복사해 주세요', value: t, callback: function() {} });
}
function linkLive(a) { return a.LINK_TOKEN && a.LINK_EXP_DT && a.LINK_EXP_DT > nowYmdHm(); }
function newLink(a) {
	hrPost('/admin/recruit/linkData.do', { APPLY_SQ: a.APPLY_SQ }, function(res) {
		a.LINK_TOKEN = res.result.TOKEN; a.LINK_EXP_DT = res.result.LINK_EXP_DT;
		copyText(linkUrl(a.LINK_TOKEN), '링크를 복사했어요 · ' + md(a.LINK_EXP_DT) + ' 까지 열려요');
		reload();
	});
}
function linkBtn(a) {
	var live = linkLive(a);
	return $('<button type="button" class="rc-linkbtn">').toggleClass('sent', !!live).attr('title', live ? '눌러서 같은 링크 다시 복사' : '본인이 계정 없이 인터뷰 기록을 남기는 링크를 만들어 복사')
		.text(live ? '🔗 링크 보냄 · ' + md(a.LINK_EXP_DT) + ' 만료' : '🔗 기록 링크').on('click', function(e) {
			e.stopPropagation();
			if (live) copyText(linkUrl(a.LINK_TOKEN), '링크를 다시 복사했어요'); else newLink(a);
		});
}
// 본인 제출 뒤 관리자가 아직 안 열어 봤으면 새 제출(●)
function selfNew(a) { var n = noteOf(a); return !!a.LINK_SUBMIT_DT && n.by === 'SELF' && (!n.seenAt || n.seenAt < (n.selfAt || a.LINK_SUBMIT_DT)); }
// 인터뷰 기록 창 하나로 등록·수정·질문 추가/삭제·기록 지우기. 본인이 링크로 낸 기록도 여기서 바로 고친다
function noteDialog(a) {
	var r = recruitOf(a.RECRUIT_SQ) || {}, n = $.extend({}, noteOf(a)), fromDetail = $('#rcDetail').length > 0, editing = false; // 달력에서 열면 「모집 상세 열기」를 보인다
	var wasNew = selfNew(a), done = false, canCheck = ['DOC', 'INTV_WAIT', 'INTV', 'INTV_SUB'].indexOf(a.STEP_CD) >= 0;
	if (wasNew) hrPost('/admin/recruit/noteSeenData.do', { APPLY_SQ: a.APPLY_SQ }, function() {}); // 새 제출 ● 끄기
	NOTE_CATS.forEach(function(c) { if (c[3]) n[c[0]] = $.isArray(n[c[0]]) ? n[c[0]] : []; else n[c[0]] = n[c[0]] || ''; });
	var skills = String(r.SKILLS || '').split(/[,/·]+/).map(function(x) { return $.trim(x); }).filter(Boolean);
	var $k = $('<div class="rc-kv rc-note-kv">');
	var $edit = $('<button type="button" class="btn btn-sm btn-link p-0">✎ 예시 빼기</button>').on('click', function() { editing = !editing; $k.toggleClass('editing', editing); $(this).text(editing ? '✓ 다 뺐어요' : '✎ 예시 빼기'); });
	// 제출 상태 + 본인에게 보낼 링크 복사(살아 있는 링크면 그대로, 없으면 새로 만듦)
	var live = linkLive(a), $state = $('<div class="d-flex flex-wrap align-items-center" style="grid-column:1/-1;gap:6px">');
	if (a.LINK_SUBMIT_DT) $state.append($('<span class="rc-self">').text('본인 제출 ' + md(a.LINK_SUBMIT_DT) + ' ' + a.LINK_SUBMIT_DT.substring(11)));
	else $state.append($('<span class="rc-self wait">').text('제출 전' + (live ? ' · 링크 보냄 ' + md(a.LINK_EXP_DT) + ' 만료' : '')));
	if (n.adminAt) $state.append($('<span class="rc-self adm">').text('관리자 수정 ' + n.adminAt));
	if (n.by === 'CAL') $state.append($('<span class="rc-fromcal">').text('📅 캘린더 보고에서 가져옴 ' + (n.calAt || '')));
	$state.append($('<span class="rc-step">').addClass(a.STEP_CD).text(STEP_NM[a.STEP_CD] || ''));
	$state.append($('<button type="button" class="rc-linkbtn">🔗 제출 링크 복사</button>').attr('title', '본인이 계정 없이 이 기록을 남기는 링크').on('click', function() {
		if (linkLive(a)) copyText(linkUrl(a.LINK_TOKEN), '링크를 복사했어요 · ' + md(a.LINK_EXP_DT) + ' 까지 열려요');
		else hrPost('/admin/recruit/linkData.do', { APPLY_SQ: a.APPLY_SQ }, function(res) {
			a.LINK_TOKEN = res.result.TOKEN; a.LINK_EXP_DT = res.result.LINK_EXP_DT;
			copyText(linkUrl(a.LINK_TOKEN), '링크를 복사했어요 · ' + md(a.LINK_EXP_DT) + ' 까지 열려요');
			if (!a.LINK_SUBMIT_DT) $state.find('.rc-self.wait').text('제출 전 · 링크 보냄 ' + md(a.LINK_EXP_DT) + ' 만료');
		});
	}));
	if (linkLive(a) || a.LINK_SUBMIT_DT) $state.append($('<button type="button" class="btn btn-sm btn-link p-0">링크 다시 만들기</button>').attr('title', '지금 링크를 막고 새 링크를 복사').on('click', function() {
		bootbox.confirm('새 링크를 만들까요? 지금 링크는 바로 막혀요.', function(ok) { if (ok) { done = true; dlg.modal('hide'); newLink(a); } });
	}));
	$k.append($state);
	$k.append($('<div class="rc-note" style="grid-column:1/-1">').text('통화로 들은 내용을 칩으로 골라요. 없는 예시는 「＋」로 바로 추가하면 다음부터 고를 수 있어요. ').append($edit));
	NOTE_CATS.forEach(function(c) {
		var key = c[0], $g = $('<span class="d-flex flex-wrap" style="gap:4px" role="group">').attr('aria-label', c[2]);
		function opts() { var l = (D.intvCodes && D.intvCodes[c[1]]) || []; return (key === 'tech' ? skills.filter(function(x) { return l.indexOf(x) < 0; }) : []).concat(l); }
		function on(v) { return c[3] ? n[key].indexOf(v) >= 0 : n[key] === v; }
		function paint() {
			$g.empty();
			var list = opts();
			// 지난 기록에 있었는데 목록에서 빠진 값도 고른 채로 보인다
			(c[3] ? n[key] : n[key] ? [n[key]] : []).forEach(function(v) { if (list.indexOf(v) < 0) list.push(v); });
			list.forEach(function(v) {
				$g.append($('<button type="button" class="rc-wayb">').attr('aria-pressed', on(v)).text(v).on('click', function() {
					if (editing) {
						if ((D.intvCodes[c[1]] || []).indexOf(v) < 0) return; // 모집 요구 기술처럼 코드가 아닌 칩은 못 뺀다
						return bootbox.confirm('「' + v + '」 예시를 ' + c[2] + ' 목록에서 뺄까요? 이미 남긴 기록은 그대로예요.', function(ok) {
							if (ok) hrPost('/admin/recruit/intvCodeData.do', { KIND: c[1], ACT: 'DEL', NM: v }, function(res) { D.intvCodes = res.result; paint(); });
						});
					}
					if (c[3]) { var i = n[key].indexOf(v); if (i >= 0) n[key].splice(i, 1); else n[key].push(v); }
					else n[key] = n[key] === v ? '' : v; // 다시 누르면 풀기
					paint();
				}));
			});
			$g.append($('<button type="button" class="rc-wayb rc-add-code" title="예시 추가">＋</button>').on('click', function() {
				bootbox.prompt({ title: c[2] + ' 예시 추가', placeholder: '예) ' + (opts()[0] || ''), callback: function(v) {
					v = $.trim(v || '');
					if (!v) return;
					hrPost('/admin/recruit/intvCodeData.do', { KIND: c[1], ACT: 'ADD', NM: v }, function(res) {
						D.intvCodes = res.result;
						if (c[3]) { if (n[key].indexOf(v) < 0) n[key].push(v); } else n[key] = v; // 추가한 것은 바로 고른 상태로
						paint();
					});
				} });
			}));
		}
		paint();
		$k.append($('<label>').text(c[2]).append(c[3] ? $('<small class="d-block text-muted font-weight-normal">').text('여러 개') : c[4] ? $('<small class="d-block text-muted font-weight-normal">').text(c[4]) : '')).append($g);
	});
	// 기억나는 질문과 답변(여러 쌍) — 나중에 모의 인터뷰 자료로 쓴다
	var $qa = $('<div class="rc-qa">');
	function qaRow(x) {
		var $row = $('<div class="rc-qa-row">')
			.append($('<textarea rows="1" class="form-control form-control-sm q" maxlength="500" placeholder="질문 (예: Spring 트랜잭션 전파는 어떻게 썼나요?)">').val(x.q || ''))
			.append($('<textarea rows="2" class="form-control form-control-sm a" maxlength="2000" placeholder="뭐라고 답했는지 (기억나는 만큼)">').val(x.a || ''))
			.append($('<button type="button" class="btn btn-sm btn-link text-danger p-0" aria-label="이 질문 지우기">✕</button>').on('click', function() { $row.remove(); }));
		$qa.append($row);
		return $row;
	}
	(n.qa && n.qa.length ? n.qa : [{}]).forEach(qaRow);
	var $addQ = $('<button type="button" class="btn btn-sm btn-outline-primary mt-1">＋ 질문 추가</button>').on('click', function() { qaRow({}).find('.q').focus(); });
	$k.append($('<label>').text('기억나는 질문').append($('<small class="d-block text-muted font-weight-normal">').text('질문 · 답변'))).append($('<div>').append($qa).append($addQ));
	var $memo = $('<textarea rows="2" class="form-control form-control-sm" maxlength="1000" placeholder="그 밖에 들은 것 (선택)">').val(n.memo || '');
	$k.append('<label>메모</label>').append($memo);
	function collect() {
		n.qa = $qa.find('.rc-qa-row').map(function() { return { q: $.trim($(this).find('.q').val()), a: $.trim($(this).find('.a').val()) }; }).get().filter(function(x) { return x.q || x.a; });
		n.memo = $.trim($memo.val());
		delete n.r; delete n.comm; delete n.att; delete n.chk; delete n.ask; // 첫 버전(평가형) 칸은 새로 저장할 때 정리
		return n;
	}
	var before = JSON.stringify(collect());
	var dlg = bootbox.dialog({ title: '📝 ' + a.STAFF_NM + ' · ' + (r.CLIENT_NM || '') + ' 인터뷰 기록' + (a.INTV_DT ? ' (' + a.INTV_DT + ')' : ''), message: $k, size: 'large', onEscape: true, buttons: {
		del: { label: '🗑 기록 지우기', className: 'btn-sm btn-outline-danger mr-1' + (a.INTV_NOTE ? '' : ' d-none'), callback: function() {
			bootbox.confirm('이 인터뷰 기록을 지울까요? 본인이 제출한 내용도 함께 지워져요(링크는 그대로).', function(ok) {
				if (ok) hrPost('/admin/recruit/noteData.do', { APPLY_SQ: a.APPLY_SQ, INTV_NOTE: '', SUMMARY: '' }, function() { done = true; dlg.modal('hide'); hrToast('인터뷰 기록을 지웠어요.'); reload(); });
			});
			return false;
		} },
		open: { label: '모집 상세 열기', className: 'btn-sm btn-outline-primary mr-auto' + (fromDetail ? ' d-none' : ''), callback: function() { done = true; dlg.one('hidden.bs.modal', function() { detail(a.RECRUIT_SQ); }); } },
		cancel: { label: '닫기', className: 'btn-sm btn-outline-secondary' },
		// 저장하면 인터뷰 결과 확인중(서버 note → autoStep). 본인 제출을 고쳤으면 관리자 수정 시각을 남긴다
		ok: { label: canCheck && a.LINK_SUBMIT_DT ? '✓ 확인 · 저장(결과 확인중으로)' : canCheck ? '저장(결과 확인중으로)' : '기록 저장', className: 'btn-sm ' + (canCheck && a.LINK_SUBMIT_DT ? 'btn-success' : 'btn-primary'), callback: function() {
			collect();
			if (n.by === 'SELF') { if (JSON.stringify(n) !== before) n.adminAt = nowYmdHm(); n.seenAt = nowYmdHm(); }
			hrPost('/admin/recruit/noteData.do', { APPLY_SQ: a.APPLY_SQ, INTV_NOTE: JSON.stringify(n), SUMMARY: noteSummary(n) }, function() {
				done = true;
				dlg.modal('hide');
				hrToast('인터뷰 기록을 저장했어요.');
				reload();
			});
			return false;
		} } } });
	if (wasNew) dlg.one('hidden.bs.modal', function() { if (!done) reload(); }); // 닫을 때 다시 불러와 ● 를 끈다
}

// ── 인터뷰 일정 ──
function interviewDialog(a) {
	var r = recruitOf(a.RECRUIT_SQ) || {}, cur = a.INTV_DT || '', way = a.INTV_WAY || 'FACE';
	var $d = $('<input type="date" class="form-control form-control-sm" id="ivD">').val(cur ? cur.substring(0, 10) : '');
	var $s = $('<input type="time" class="form-control form-control-sm" id="ivS" step="600">').val(cur ? cur.substring(11, 16) : '14:00');
	var $e = $('<input type="time" class="form-control form-control-sm" id="ivE" step="600" aria-label="끝 시각">').val(a.INTV_END_DT ? a.INTV_END_DT.substring(11, 16) : '');
	var $w = $('<span role="group" aria-label="방식">');
	$.each(WAY, function(k, v) { $w.append($('<button type="button" class="rc-wayb">').attr('aria-pressed', k === way).text(v).on('click', function() { way = k; $w.find('button').attr('aria-pressed', false); $(this).attr('aria-pressed', true); })); });
	var $p = $('<input class="form-control form-control-sm" id="ivP" maxlength="300">').val(a.INTV_PLACE || r.WORK_AREA || '');
	var $with = $('<input class="form-control form-control-sm" id="ivW" maxlength="200" placeholder="선택">').val(a.INTV_WITH || '');
	var $k = $('<div class="rc-kv">').append('<label for="ivD">일시</label>').append($('<div class="d-flex align-items-center" style="gap:4px">').append($d).append($s).append('~').append($e))
		.append('<label>방식</label>').append($w).append('<label for="ivP">장소</label>').append($p).append('<label for="ivW">동행</label>').append($with)
		.append('<label>알림</label>').append('<span class="small">✉ 저장하면 본인 회사 메일로 자동 발송 · 바꾸거나 취소해도 다시 보내요</span>');
	var dlg = bootbox.dialog({ title: '🎤 ' + a.STAFF_NM + ' · ' + (r.CLIENT_NM || '') + ' 인터뷰 일정', message: $k, onEscape: true, buttons: {
		later: { label: '나중에', className: 'btn-sm btn-outline-secondary', callback: function() {
			if (a.STEP_CD === 'DOC') hrPost('/admin/recruit/stepData.do', { APPLY_SQ: a.APPLY_SQ, STEP_CD: 'INTV_WAIT' }, reload); // 일정을 비우면 인터뷰대기에 머문다
		} },
		ok: { label: '일정 저장', className: 'btn-sm btn-primary', callback: function() {
			if (!$d.val() || !$s.val()) { bootbox.alert('날짜와 시작 시각을 넣어 주세요.'); return false; }
			hrPost('/admin/recruit/interviewData.do', { APPLY_SQ: a.APPLY_SQ, INTV_DT: $d.val() + ' ' + $s.val(), INTV_END_DT: $e.val() ? $d.val() + ' ' + $e.val() : '', INTV_WAY: way, INTV_PLACE: $p.val(), INTV_WITH: $with.val() },
				function(res) { dlg.modal('hide'); notes(res.result); reload(); });
			return false;
		} } } });
}

// ── 투입확정(항상 확인·추가 입력) ──
function joinDialog(a) {
	var r = recruitOf(a.RECRUIT_SQ) || {}, draft = {};
	try { draft = JSON.parse(a.DRAFT || '{}') || {}; } catch (e) { draft = {}; }
	var st = personState(a.STAFF_SQ), last = st.row || {};
	var grade = hrAllCodes('HR_DEPLOY_GRADE').filter(function(c) { return String(r.GRADE_TXT || '').indexOf(c.NM) === 0; })[0];
	function v(k, def) { return draft[k] !== undefined && draft[k] !== '' ? draft[k] : def; }
	function partnerSel(name, val, kind) {
		var $s = $('<select class="form-control form-control-sm">').attr({ name: name, id: 'jn_' + name }).append('<option value=""></option>');
		D.partners.filter(function(p) { return p.USE_YN === 'Y' && p[kind] !== 'N'; }).forEach(function(p) { $s.append($('<option>').val(p.PARTNER_SQ).text(p.PARTNER_NM)); });
		return $s.val(val || '');
	}
	function inp(name, val, type) { return $('<input class="form-control form-control-sm">').attr({ name: name, id: 'jn_' + name, type: type || 'text' }).val(val == null ? '' : val); }
	var $k1 = $('<div class="rc-kv">')
		.append('<label for="jn_CLIENT_NM">고객사</label>').append(inp('CLIENT_NM', v('CLIENT_NM', r.CLIENT_NM)))
		.append('<label for="jn_PRJ_NM">프로젝트</label>').append(inp('PRJ_NM', v('PRJ_NM', r.PRJ_NM)))
		.append('<label for="jn_GRADE_CD">등급</label>').append(hrControl({ code: 'HR_DEPLOY_GRADE' }, v('GRADE_CD', grade ? grade.CD : '')).attr({ name: 'GRADE_CD', id: 'jn_GRADE_CD' }))
		.append('<label for="jn_SALE_PARTNER_SQ">매출처</label>').append(partnerSel('SALE_PARTNER_SQ', v('SALE_PARTNER_SQ', r.SALE_PARTNER_SQ), 'SALE_YN'))
		.append('<label for="jn_WORK_AREA">근무지역</label>').append(inp('WORK_AREA', v('WORK_AREA', r.WORK_AREA)))
		.append('<label for="jn_START_DT">투입일 *</label>').append($('<div class="d-flex align-items-center" style="gap:4px">').append(inp('START_DT', v('START_DT', r.START_DT), 'date')).append('~').append(inp('END_DT', v('END_DT', r.END_DT), 'date').attr('aria-label', '철수일')));
	var way = v('WORK_WAY', '상주'), $way = $('<span role="group" aria-label="근무 방식">');
	['상주', '재택', '혼합'].forEach(function(w) { $way.append($('<button type="button" class="rc-wayb">').attr('aria-pressed', w === way).text(w).on('click', function() { way = w; $way.find('button').attr('aria-pressed', false); $(this).attr('aria-pressed', true); })); });
	var $k2 = $('<div class="rc-kv">')
		.append('<label for="jn_EMP_TYPE_CD">형태 *</label>').append($('<div class="d-flex align-items-center" style="gap:6px">').append(hrControl({ code: 'HR_EMP_TYPE' }, v('EMP_TYPE_CD', last.EMP_TYPE_CD || '')).attr({ name: 'EMP_TYPE_CD', id: 'jn_EMP_TYPE_CD' }).css('width', 'auto')).append(last.EMP_TYPE_CD ? '<span class="rc-note">지난 투입 값 제안</span>' : ''))
		.append('<label for="jn_BUY_PARTNER_SQ">매입처</label>').append($('<div class="d-flex align-items-center" style="gap:6px">').append(partnerSel('BUY_PARTNER_SQ', v('BUY_PARTNER_SQ', last.BUY_PARTNER_SQ), 'BUY_YN').css('width', 'auto')).append('<span class="rc-note">프리·외주일 때</span>'));
	if (D.canPay) {
		$k2.append('<label for="jn_SALE_PRICE">매출단가 🔒</label>').append($('<div class="d-flex align-items-center" style="gap:6px">').append(inp('SALE_PRICE', v('SALE_PRICE', '')).attr('inputmode', 'numeric').css('width', '160px')).append($('<span class="rc-note">').text(r.PRICE_TXT ? "모집 단가 '" + r.PRICE_TXT + "' 참고" : '')))
			.append('<label for="jn_COST_PRICE">계약단가 🔒</label>').append($('<div class="d-flex align-items-center" style="gap:6px">').append(inp('COST_PRICE', v('COST_PRICE', '')).attr('inputmode', 'numeric').css('width', '160px')).append($('<span class="rc-note">').text(last.COST_PRICE ? '지난 투입 ' + Number(last.COST_PRICE).toLocaleString() : '')));
	}
	$k2.append('<label>근무 방식</label>').append($way).append('<label for="jn_MEMO">메모</label>').append(inp('MEMO', v('MEMO', '')).attr('placeholder', '계약 조건·특이사항'));
	var $f = $('<div>').append('<div class="small mb-2">투입현황에 <b>투입 예정</b>으로 등록하기 전에 확인·추가 입력을 받아요.</div>')
		.append('<div class="small font-weight-bold mb-1">① 모집에서 채운 값 <span class="rc-note font-weight-normal">— 확인만, 고쳐도 돼요</span></div>').append($k1)
		.append('<div class="small font-weight-bold mt-3 mb-1" style="color:#e67700">② 추가 입력 <span class="rc-note font-weight-normal">— 모집 정보로는 정해지지 않는 값</span></div>').append($('<div class="rc-join2">').append($k2))
		.append($('<div class="rc-note mt-1">').text('* 는 꼭 입력. ' + (D.canPay ? '🔒 단가는 급여 권한자에게만 보여요.' : '단가는 급여 권한자만 넣을 수 있어 비워 둔 채 등록돼요(투입현황에서 권한자가 넣어요).')));
	function data(draftYn) {
		var d = { APPLY_SQ: a.APPLY_SQ, DRAFT: draftYn ? 'Y' : 'N', WORK_WAY: way };
		$f.find('[name]').each(function() { d[this.name] = $.trim($(this).val()); });
		if (d.SALE_PRICE) d.SALE_PRICE = d.SALE_PRICE.replace(/[^\d]/g, '');
		if (d.COST_PRICE) d.COST_PRICE = d.COST_PRICE.replace(/[^\d]/g, '');
		return d;
	}
	var dlg = bootbox.dialog({ title: '✅ ' + a.STAFF_NM + ' 투입확정', message: $f, size: 'large', onEscape: true, buttons: {
		cancel: { label: '취소', className: 'btn-sm btn-outline-secondary' },
		draft: { label: '임시 저장', className: 'btn-sm btn-outline-primary', callback: function() { hrPost('/admin/recruit/joinData.do', data(true), function() { dlg.modal('hide'); hrToast('임시 저장했어요(투입대기).'); reload(); }); return false; } },
		ok: { label: '투입확정 · 투입 예정 등록', className: 'btn-sm btn-primary', callback: function() {
			var d = data(false);
			if (!d.EMP_TYPE_CD || !d.START_DT) { bootbox.alert('형태와 투입일을 넣어 주세요.'); return false; }
			hrPost('/admin/recruit/joinData.do', d, function(res) {
				dlg.modal('hide');
				hrToast(a.STAFF_NM + ' 투입확정 · 투입현황에 투입 예정으로 등록했어요.');
				var others = res.result.others || [];
				if (!others.length) return reload();
				bootbox.confirm({ title: '다른 모집 ' + others.length + '건 진행 중', message: $('<div>').append('<p class="mb-1">같은 사람이 다른 모집에서도 진행 중이에요. 모두 취소할까요?</p>').append($('<ul class="mb-0">').append(others.map(function(o) { return $('<li>').text((o.CLIENT_NM || '') + ' ' + (o.PRJ_NM || '') + ' · ' + STEP_NM[o.STEP_CD]); }))),
					buttons: { confirm: { label: '모두 탈락 처리', className: 'btn-sm btn-danger' }, cancel: { label: '그대로 두기', className: 'btn-sm btn-outline-secondary' } },
					callback: function(yes) {
						if (!yes) return reload();
						(function next(i) { if (i >= others.length) return reload(); hrPost('/admin/recruit/stepData.do', { APPLY_SQ: others[i].APPLY_SQ, STEP_CD: 'DROP', REASON: '다른 모집 투입확정' }, function() { next(i + 1); }, function() { next(i + 1); }); })(0);
					} });
			});
			return false;
		} } } });
}

</script>
</body>
</html>
