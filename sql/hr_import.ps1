# 면접·교육생 엑셀 -> SQL 생성 (한 번만 쓰는 이관 스크립트). 엑셀을 읽기만 하고, 건수가 안 맞으면 멈춘다
# 사용: powershell -File sql\hr_import.ps1 -Dir "<엑셀 폴더>" -Out "<저장소 밖 경로>\hr_import_data.sql"
# 결과 파일에 개인정보가 들어 있으니 저장소에 넣지 말고 이관 후 지운다
# 값은 엑셀 글자 그대로 들어간다. 넣은 뒤 sql\hr_code.sql, sql\hr_code2.sql 순서로 코드로 바꾼다
# shortcut: 중복 방지 장치가 없어 빈 테이블에만 실행한다. 다시 넣으려면 두 테이블을 비운 뒤 실행
# 주민등록번호와 면접비(지출·충전·잔액, 인출 시트)는 일부러 읽지 않는다
param([Parameter(Mandatory = $true)][string]$Dir, [Parameter(Mandatory = $true)][string]$Out)
$ErrorActionPreference = 'Stop'

$script:sql = New-Object System.Text.StringBuilder
function Lit($v) {
	if ($null -eq $v -or "$v" -eq '') { return 'NULL' }
	return "'" + ("$v" -replace '\\', '\\' -replace "'", "''" -replace "`r", '' -replace "`n", '\n') + "'"
}
# 빈 칸과 '-' 는 값 없음. 정수로 저장된 숫자는 소수점 없이 글자로
function Txt($v) {
	if ($null -eq $v) { return $null }
	if ($v -is [double] -and $v -eq [math]::Floor($v)) { return ([long]$v).ToString() }
	$s = "$v".Trim()
	if ($s -eq '' -or $s -eq '-') { return $null }
	return $s
}
function DateStr($d) { [DateTime]::FromOADate($d).ToString('yyyy-MM-dd') }
# 날짜 칸인데 글자면 글자 그대로 둔다(출근일자의 '2일 후 도망' 같은 값)
function DateOrTxt($v) { if ($v -is [double]) { return DateStr $v }; return Txt $v }
function Time($v) { if ($v -is [double]) { return [DateTime]::FromOADate($v).ToString('HH:mm') }; return Txt $v }
# 엑셀의 오타 두 건. 시트 연도와 앞뒤 행으로 확인한 값
$DATE_FIX = @{ '20225-03-19' = '2025-03-19'; '2026-07-030' = '2026-07-30' }
function IntvDate($v) {
	if ($v -is [double]) { return DateStr $v }
	$s = Txt $v
	if ($null -eq $s) { return $null }
	if ($DATE_FIX.ContainsKey($s)) { return $DATE_FIX[$s] }
	throw "면접일자를 읽을 수 없습니다: $s"
}
function Headers($v, $row, $cols) {
	$h = @{}
	for ($c = 1; $c -le $cols; $c++) {
		$t = ("$($v[$row,$c])" -replace '\s', '')
		if ($t -eq '') { continue }
		# 면접상태 열이 두 개다: 앞이 참석 여부, 뒤가 면접 결과
		if ($h.ContainsKey($t)) { $h[$t + '2'] = $c } else { $h[$t] = $c }
	}
	return $h
}

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false; $excel.DisplayAlerts = $false
$counts = @{}
try {
	[void]$script:sql.AppendLine("SET NAMES utf8mb4;`nSTART TRANSACTION;")

	$wb = $excel.Workbooks.Open((Join-Path $Dir '02. 면접 관리.xlsx'), 0, $true)
	$intvCnt = 0
	foreach ($y in '2023', '2024', '2025', '2026') {
		$ws = $wb.Worksheets.Item($y)
		$maxr = $ws.UsedRange.Rows.Count
		$v = $ws.Range($ws.Cells.Item(1, 1), $ws.Cells.Item($maxr, 29)).Value2
		$h = Headers $v 7 29
		$memoCol = if ($h['비고']) { $h['비고'] } else { $h['특이사항'] }

		for ($r = 8; $r -le $maxr; $r++) {
			if ("$($v[$r,1])".StartsWith('예시')) { continue }
			$name = Txt $v[$r, 3]
			if ($null -eq $name) { continue }

			$intvCnt++
			$cols = @{
				SEQ_NO = Txt $v[$r, $h['순번']]; APLY_NM = $name; GENDER = Txt $v[$r, $h['성별']]; INTV_DT = IntvDate $v[$r, $h['면접일자']]; INTV_TM = Time $v[$r, $h['면접시간']]
				APLY_TARGET = Txt $v[$r, $h['지원대상']]; APLY_ROUTE = Txt $v[$r, $h['지원방법']]; PHONE = Txt $v[$r, $h['연락처']]; ATTEND_ST = Txt $v[$r, $h['면접상태']]
				EDU = Txt $v[$r, $h['최종학력(원본)']]; AGE = Txt $v[$r, $h['나이']]; ADDR = Txt $v[$r, $h['주소지']]; STATION = Txt $v[$r, $h['인근지하철역/호선']]
				CAREER = Txt $v[$r, $h['이전경력']]; LANG = Txt $v[$r, $h['외국어']]; MEMO = Txt $v[$r, $memoCol]; HOBBY = Txt $v[$r, $h['취미']]; SPECIALTY = Txt $v[$r, $h['특기']]
				SALARY = Txt $v[$r, $h['계약예정연봉']]; RESULT_ST = Txt $v[$r, $h['면접상태2']]; NOTICE_ST = Txt $v[$r, $h['합격통보상태']]; JOIN_ST = Txt $v[$r, $h['입사여부']]; JOIN_DT = DateOrTxt $v[$r, $h['출근일자']]
			}
			# 2023 시트에는 지방가능여부 열이 없다
			if ($h['지방가능여부']) { $cols.LOCAL_YN = Txt $v[$r, $h['지방가능여부']] }
			$names = @($cols.Keys); $vals = $names | ForEach-Object { Lit $cols[$_] }
			[void]$script:sql.AppendLine("INSERT INTO TB_EEP_HR_INTV_M ($($names -join ',')) VALUES ($($vals -join ','));")
		}
	}
	$counts['면접자'] = $intvCnt
	$wb.Close($false)

	$wb = $excel.Workbooks.Open((Join-Path $Dir '03. 교육생 관리.xlsx'), 0, $true)
	$status = @{ '교육진행중' = 'ING'; '교육종료' = 'END'; '중도이탈' = 'DROP' }
	$skills = [ordered]@{ SK_JSP = 'JSP'; SK_THYMELEAF = 'Thymeleaf'; SK_VUE = 'Vue'; SK_REACT = 'React'; SK_NODE_FE = 'Node'; SK_SPRING = 'spring(boot)'; SK_JAVA = 'java'; SK_NODE_BE = 'node'; SK_NEXACRO = 'nexacro'; SK_WEBSQUARE = 'websquare'; SK_EXBUILDER = 'exbuilder' }
	foreach ($sheet in $status.Keys) {
		$ws = $wb.Worksheets.Item($sheet)
		$maxr = $ws.UsedRange.Row + $ws.UsedRange.Rows.Count - 1
		$v = $ws.Range($ws.Cells.Item(1, 1), $ws.Cells.Item($maxr, 31)).Value2
		# Node 와 node 는 대소문자만 달라 해시표에서 합쳐지므로 위치(프론트/백엔드)로 찾는다
		$h = New-Object System.Collections.Hashtable ([StringComparer]::Ordinal)
		for ($c = 1; $c -le 31; $c++) { $t = ("$($v[3,$c])" -replace '\s', ''); if ($t) { $h[$t] = $c } }
		$early = if ($h['조기파견여부']) { $h['조기파견여부'] } else { $h['조기투입여부'] }
		$cnt = 0
		for ($r = 4; $r -le $maxr; $r++) {
			$name = Txt $v[$r, 3]
			if ($null -eq $name) { continue }
			$start = $v[$r, $h['교육시작일']]
			$cols = @{
				SEQ_NO = Txt $v[$r, $h['순번']]; STATUS_CD = $status[$sheet]; LEAVE_NOTE = Txt $v[$r, 1]; TRN_NM = $name; GENDER = Txt $v[$r, $h['성별']]; EDU = Txt $v[$r, $h['최종학력']]; AGE = Txt $v[$r, $h['나이']]
				ADDR = Txt $v[$r, $h['주소지']]; STATION = Txt $v[$r, $h['인근지하철역/호선']]; CAREER = Txt $v[$r, $h['이전경력']]; LANG = Txt $v[$r, $h['외국어']]; LOCAL_YN = Txt $v[$r, $h['지방가능여부']]
				EARLY_YN = Txt $v[$r, $early]; SPECIAL_YN = Txt $v[$r, $h['특수계약여부']]; MEMO = Txt $v[$r, $h['참고사항']]
				EDU_START_DT = if ($start -is [double]) { DateStr $start } else { $null }
				INTERVIEW_YN = Txt $v[$r, $h['인터뷰']]; INTERVIEW_AVAIL = DateOrTxt $v[$r, $h['인터뷰가능일']]
			}
			if ($start -isnot [double] -and $null -ne (Txt $start)) { throw "[$sheet] 교육시작일을 읽을 수 없습니다: r$r" }
			foreach ($k in $skills.Keys) { $cols[$k] = Txt $v[$r, $h[$skills[$k]]] }
			$names = @($cols.Keys); $vals = $names | ForEach-Object { Lit $cols[$_] }
			[void]$script:sql.AppendLine("INSERT INTO TB_EEP_HR_TRAINEE_M ($($names -join ',')) VALUES ($($vals -join ','));")
			$cnt++
		}
		$counts[$sheet] = $cnt
	}
	$wb.Close($false)
	[void]$script:sql.AppendLine('COMMIT;')
}
finally { $excel.Quit() }

$expected = @{ '면접자' = 803; '교육진행중' = 1; '교육종료' = 52; '중도이탈' = 34 }
foreach ($k in $expected.Keys) { if ($counts[$k] -ne $expected[$k]) { throw "$k 건수 $($counts[$k]) 가 예상 $($expected[$k]) 와 다릅니다" } }

[IO.File]::WriteAllText($Out, $script:sql.ToString(), (New-Object Text.UTF8Encoding $false))
Write-Host "완료: $(($counts.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', ')"
