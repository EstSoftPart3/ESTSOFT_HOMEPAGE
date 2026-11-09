<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>
<%@ include file="/WEB-INF/jsp/bo/calendar/calendar_style.jspf"%>

<body class="hold-transition sidebar-mini">
	<div class="wrapper">
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		<div class="content-wrapper">
			<section class="content cal-page">
				<div class="card-body">
					<div class="cal-panel"><div class="cal-empty"><i class="fas fa-lock mb-2" aria-hidden="true"></i><br>사용할 수 있는 메뉴가 없습니다. 슈퍼관리자에게 권한을 요청해 주세요.</div></div>
				</div>
			</section>
		</div>
	</div>
	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
</body>
</html>
