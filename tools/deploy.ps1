<#
운영 배포. 커밋을 따로 받아 빌드하고, 서버 잠금 안에서 war 를 바꾼다.
막는 것
  - 두 세션이 동시에 바꾸기: 서버 잠금 폴더(.deploy.lock). 30분 넘은 잠금은 버려진 것으로 보고 푼다.
  - 다른 세션 커밋 되돌리기: 운영에 올라간 커밋(DEPLOYED_COMMIT)이 이번 커밋의 조상이 아니면 멈춘다.
  - db.properties 빠진 war, 엉뚱한 war: war 안 파일과 크기를 검사한다.
  - 기동 실패: 메인·관리자 응답과 SEVERE 로그를 보고, 실패하면 직전 war 로 되돌린다.
사용: powershell -NoProfile -File tools\deploy.ps1 -Tag <영문작업이름> [-Ref master] [-Keep 20]
  -Keep 0 이면 오래된 백업을 지우지 않는다.
#>
param(
	[Parameter(Mandatory = $true)][ValidatePattern('^[A-Za-z0-9-]{1,30}$')][string]$Tag,
	[string]$Ref = 'master',
	[int]$Keep = 20
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$mvn = 'C:\dev\tools\maven\apache-maven-3.9.9\bin\mvn.cmd'
$env:JAVA_HOME = 'C:\dev\tools\jdk\jdk8u504-b01'
$dir = '/DATA/est_homepage'
$lock = "$dir/.deploy.lock"
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Remote([string]$script) {
	# PowerShell 5.1 은 파이프로 넘길 때 BOM 을 붙여서 base64 로 넘긴다
	$b64 = [Convert]::ToBase64String((New-Object System.Text.UTF8Encoding $false).GetBytes(($script -replace "`r", '')))
	$out = ssh devserver "echo $b64 | base64 -d | bash"
	if ($LASTEXITCODE -ne 0) { throw "서버 명령 실패($LASTEXITCODE): $out" }
	return ($out -join "`n")
}
function G { $o = & git -C $repo @args; if ($LASTEXITCODE -ne 0) { throw "git $args 실패" }; return $o }

# 1) 커밋 확인: origin/master 에 올라간 커밋만 배포한다
G fetch -q origin | Out-Null
$sha = (G rev-parse "$Ref^{commit}").Trim()
& git -C $repo merge-base --is-ancestor $sha origin/master
if ($LASTEXITCODE -ne 0) { throw "$sha 가 origin/master 에 없다. push 먼저 한다." }
$short = $sha.Substring(0, 7)
$props = Join-Path $repo 'src\main\resources\config\db.properties'
if (-not (Test-Path $props)) { throw "$props 가 없다(Git 제외 파일)." }
Write-Host "배포 커밋 $short ($Tag)"

# 2) 빌드: 다른 세션 작업이 섞이지 않게 커밋만 따로 받는다
$wt = Join-Path $env:TEMP "hp_deploy_${short}_$PID"
$war = Join-Path $env:TEMP "est_eep_${short}_$PID.war"
G worktree add -q --detach $wt $sha | Out-Null
try {
	Copy-Item $props (Join-Path $wt 'src\main\resources\config\db.properties')
	Push-Location $wt
	& $mvn -o -q clean package
	$code = $LASTEXITCODE
	Pop-Location
	if ($code -ne 0) { throw "빌드 실패($code)" }
	Copy-Item (Join-Path $wt 'target\est_eep.war') $war
} finally {
	& git -C $repo worktree remove --force $wt
}

# 3) war 검사
$size = (Get-Item $war).Length
if ($size -lt 170MB) { throw "war 가 너무 작다($size). 엉뚱한 war 일 수 있다." }
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($war)
try {
	foreach ($need in 'WEB-INF/classes/config/db.properties', 'WEB-INF/web.xml') {
		if (-not ($zip.Entries | Where-Object { $_.FullName -eq $need })) { throw "war 에 $need 가 없다." }
	}
} finally { $zip.Dispose() }
$hash = (Get-FileHash $war -Algorithm SHA256).Hash.ToLower()

# 4) 잠금: 최대 10분 기다린다
$owner = "$Tag $short $env:COMPUTERNAME $stamp"
$got = $false
for ($i = 0; $i -lt 40 -and -not $got; $i++) {
	$r = Remote @"
if [ -d $lock ] && [ -n "`$(find $lock -maxdepth 0 -mmin +30)" ]; then echo "STALE `$(cat $lock/owner 2>/dev/null)"; rm -rf $lock; fi
if mkdir $lock 2>/dev/null; then echo '$owner' > $lock/owner; echo GOT; else echo "WAIT `$(cat $lock/owner 2>/dev/null)"; fi
"@
	if ($r -match 'STALE') { Write-Host "30분 넘은 잠금을 풀었다: $r" }
	if ($r -match 'GOT') { $got = $true } else { Write-Host "다른 배포 중, 15초 뒤 다시: $r"; Start-Sleep 15 }
}
if (-not $got) { throw '10분 기다려도 잠금이 안 풀렸다.' }

try {
	# 5) 운영 커밋이 이번 커밋의 조상인지
	$deployed = (Remote "cat $dir/DEPLOYED_COMMIT 2>/dev/null || true").Trim()
	if ($deployed) {
		& git -C $repo merge-base --is-ancestor $deployed $sha
		if ($LASTEXITCODE -ne 0) { throw "운영 커밋 $deployed 가 $short 에 없다. 최신 master 를 받아 다시 배포한다." }
	} else { Write-Host 'DEPLOYED_COMMIT 이 없어 조상 검사를 건너뛴다(첫 배포).' }

	# 6) 올리고 바꾸고 재시작
	$up = "est_eep.war.upload-$Tag-$stamp"
	scp -q $war "devserver:$dir/$up"
	if ($LASTEXITCODE -ne 0) { throw 'scp 실패' }
	$remoteHash = (Remote "sha256sum $dir/$up | cut -d' ' -f1").Trim()
	if ($remoteHash -ne $hash) { Remote "rm -f $dir/$up" | Out-Null; throw "업로드 sha256 불일치" }
	$bak = "est_eep.war.bak-$stamp"
	Remote "set -e; cd $dir; cp -p est_eep.war $bak; mv $up est_eep.war; docker restart homepage >/dev/null; echo ok" | Out-Null
	Write-Host "교체함(백업 $bak), 기동 확인 중"

	# 7) 기동 확인: 최대 3분
	$ok = $false; $why = ''
	for ($i = 0; $i -lt 36 -and -not $ok; $i++) {
		Start-Sleep 5
		$r = Remote @"
main=`$(curl -s -o /dev/null -m 10 -w '%{http_code}' http://localhost:8080/)
adm=`$(curl -s -o /dev/null -m 10 -w '%{http_code}' http://localhost:8080/admin/login/loginPage.do)
log=`$(docker logs --tail 3000 homepage 2>&1 | awk '/Starting Servlet engine/{b=""} {b=b `$0 "\n"} END{printf "%s", b}')
echo "main=`$main adm=`$adm started=`$(echo "`$log" | grep -c 'Server startup in') severe=`$(echo "`$log" | grep -c SEVERE)"
"@
		$why = $r
		if ($r -match 'severe=[1-9]') { break }
		if ($r -match 'main=[23]\d\d adm=[23]\d\d started=[1-9]') { $ok = $true }   # 메인·관리자 모두 302(이동)가 정상
	}
	if (-not $ok) {
		Remote "set -e; cd $dir; cp -p $bak est_eep.war; docker restart homepage >/dev/null; echo ok" | Out-Null
		throw "기동 실패로 직전 war 로 되돌렸다: $why"
	}
	Remote "echo $sha > $dir/DEPLOYED_COMMIT" | Out-Null
	Write-Host "배포 성공: $why"

	# 8) 오래된 백업·남은 업로드 정리
	if ($Keep -gt 0) {
		$n = Remote "cd $dir; ls -1t est_eep.war.bak* | tail -n +$($Keep + 1) | xargs -r rm -f 2>/dev/null; find . -maxdepth 1 -name 'est_eep.war.upload-*' -mmin +120 -delete; ls -1 est_eep.war.bak* | wc -l"
		Write-Host "백업 정리 후 $($n.Trim())개 남음"
	}
} finally {
	Remote "grep -qF '$owner' $lock/owner 2>/dev/null && rm -rf $lock; true" | Out-Null
	Remove-Item $war -ErrorAction SilentlyContinue
}
