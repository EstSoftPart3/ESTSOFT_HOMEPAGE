# 인사 관리 엑셀(재직자·퇴사자 시트) -> 직원관리 이관용 JSON. 엑셀은 읽기만 한다.
# 사용: powershell -File sql\staff_export.ps1 -Xlsx "<...\01. 인사 관리.xlsx>" -Out "<저장소 밖 경로>\staff.json"
# 결과 파일에 주민번호·계좌번호 원문이 들어 있다. 저장소에 넣지 말고, staff_import.py 로 넣은 뒤 바로 지운다.
# 열은 3행 제목으로 찾는다(시트마다 열 순서가 조금 다르다). 모르는 제목이 나오면 멈춘다.
param([Parameter(Mandatory = $true)][string]$Xlsx, [Parameter(Mandatory = $true)][string]$Out)
$ErrorActionPreference = 'Stop'

# 엑셀 3행 제목(공백 제거) -> 컬럼. 같은 제목이 여러 번 나오면 왼쪽부터 차례로 쓴다
$SPEC = @(
	@('NO', 'SEQ_NO'), @('소속', 'ORG_NM'), @('부서', 'DEPT_NM'), @('직급', 'POSITION_NM'), @('성명', 'STAFF_NM'), @('주민등록번호', 'RRN'),
	@('전화번호', 'PHONE'), @('개인 메일', 'EMAIL'), @('회사 메일', 'COMPANY_EMAIL'), @('상세주소(시도)', 'ADDR'), @('인근지하철역', 'STATION'), @('입사일자', 'JOIN_DT'), @('퇴사일자', 'LEAVE_DT'),
	@('학교명', 'HS_NM'), @('전공(부전공)', 'HS_MAJOR'), @('졸업년월', 'HS_GRAD'), @('학교명', 'UNIV_NM'), @('전공(부전공)', 'UNIV_MAJOR'), @('졸업년월', 'UNIV_GRAD'),
	@('최종학력', 'FINAL_EDU'), @('입대일', 'MIL_IN_DT'), @('전역일', 'MIL_OUT_DT'), @('면제사유', 'MIL_EXEMPT'),
	@('교육명', 'EDU_NM'), @('시작일|교육시작일', 'EDU_START_DT'), @('종료일|교육종료일', 'EDU_END_DT'), @('기관명', 'EDU_ORG'), @('정보처리기사취득일', 'CERT_DT'),
	@('은행', 'BANK_NM'), @('계좌번호', 'ACCOUNT'),
	@('주민등본', 'DOC_REG'), @('신분증', 'DOC_ID'), @('졸업증명', 'DOC_GRAD'), @('통장사본', 'DOC_BANK'), @('증명사진', 'DOC_PHOTO'), @('건보득실확인서', 'DOC_HI'),
	@('근로계약', 'DOC_CONTRACT'), @('사업자사실증명|사업자증명', 'DOC_BIZ'), @('고용보험자격이력', 'DOC_EI'), @('보안서약서', 'DOC_SEC'), @('직무교육동의서', 'DOC_EDU'),
	@('국민취업제도참여', 'DOC_NEP'), @('이력비공개', 'DOC_PRIV'), @('범죄기록회보', 'DOC_CRIME'), @('병적증명서', 'DOC_MIL'),
	@('관계1', 'EMG_REL1'), @('연락처1', 'EMG_TEL1'), @('관계2', 'EMG_REL2'), @('연락처2', 'EMG_TEL2'),
	@('이전경력', 'PREV_CAREER'), @('취미', 'HOBBY'), @('외국어', 'LANG_SKILL'), @('특기', 'SPECIALTY'), @('비고', 'MEMO'), @('점수', 'SCORE'),
	@('가필여부', 'GAPIL_YN'), @('자동지원여부', 'AUTO_APLY_YN'), @('등급', 'GRADE_NM'), @('실경력', 'REAL_CAREER'), @('희망단가', 'WISH_PRICE'),
	@('F/E', 'SK_FE'), @('B/E', 'SK_BE'), @('업무및도메인', 'WORK_DOMAIN'), @('위치\(.*', 'WISH_LOC'), @('기타', 'ETC1'), @('언어/스크립트', 'SK_LANG'),
	@('Report', 'REPORT'), @('위치', $null), @('프레임워크/라이브러리', 'SK_FW'), @('데이터베이스', 'SK_DB'), @('IDE/에디터', 'SK_IDE'), @('형상관리', 'SK_VCS'),
	@('기타', 'ETC2'), @('전문분야', 'EXPERTISE'), @('운영체제', 'SK_OS')
)
$DATE_FIELDS = @('JOIN_DT', 'LEAVE_DT')

# 별칭은 | 로 나눈다. 글자 그대로 비교하고, \( 가 든 별칭만 정규식(희망 위치 열 제목이 길어서)
function HeaderIs($h, $aliases) {
	foreach ($a in $aliases.Split('|')) {
		if ($a.Contains('\(')) { if ($h -match ('^' + $a + '$')) { return $true } }
		elseif ($h -ceq $a) { return $true }
	}
	return $false
}

function MapColumns($ws) {
	$used = New-Object bool[] $SPEC.Count
	$map = @{}
	for ($c = 1; $c -le 80; $c++) {
		$h = ("$($ws.Cells.Item(3, $c).Value2)" -replace '\s', '')
		if ($h -eq '') { continue }
		$hit = $false
		for ($i = 0; $i -lt $SPEC.Count; $i++) {
			if (-not $used[$i] -and (HeaderIs $h $SPEC[$i][0])) {
				$used[$i] = $true; $hit = $true
				if ($SPEC[$i][1]) { $map[$SPEC[$i][1]] = $c }
				break
			}
		}
		if (-not $hit) { throw "[$($ws.Name)] $c 열 제목을 모릅니다: $h" }
	}
	foreach ($need in 'STAFF_NM', 'JOIN_DT', 'RRN', 'ACCOUNT') { if (-not $map.ContainsKey($need)) { throw "[$($ws.Name)] $need 열을 찾지 못했습니다" } }
	return $map
}

$xl = New-Object -ComObject Excel.Application
$xl.DisplayAlerts = $false
$all = New-Object System.Collections.ArrayList
try {
	$wb = $xl.Workbooks.Open($Xlsx, 0, $true)
	foreach ($sheet in @(@('재직자', 'WORK'), @('퇴사자', 'LEFT'))) {
		$ws = $wb.Worksheets.Item($sheet[0])
		$map = MapColumns $ws
		$v = $ws.Range('A1:CB1000').Value2
		$n = 0
		for ($r = 4; $r -le 1000; $r++) {
			$name = "$($v[$r, $map['STAFF_NM']])".Trim()
			if ($name -eq '') { continue }
			$row = [ordered]@{ STATUS_CD = $sheet[1] }
			foreach ($f in $map.Keys) {
				$c = $map[$f]; $x = $v[$r, $c]
				if ($null -eq $x) { continue }
				if ($x -is [double]) {
					# 날짜 칸은 yyyy-MM-dd, 그 밖의 숫자는 엑셀에 보이는 글자 그대로(전화번호 앞 0, 2015.10 같은 값 보존)
					$s = if ($DATE_FIELDS -contains $f) { [DateTime]::FromOADate($x).ToString('yyyy-MM-dd') } else { "$($ws.Cells.Item($r, $c).Text)".Trim() }
				} else {
					$s = "$x".Trim()
				}
				if ($s -ne '') { $row[$f] = $s }
			}
			[void]$all.Add($row)
			$n++
		}
		Write-Host "$($sheet[0]): $n 명"
	}
	$wb.Close($false)
} finally {
	$xl.Quit()
}
[IO.File]::WriteAllText($Out, ($all | ConvertTo-Json -Depth 3 -Compress), (New-Object Text.UTF8Encoding $false))
Write-Host "저장: $Out ($($all.Count) 명)"
