$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $projectRoot '..')
$toolsRoot = Resolve-Path (Join-Path $repoRoot '.android-build-tools')
$sdkRoot = Resolve-Path (Join-Path $toolsRoot 'android-sdk')
$gradle = Resolve-Path (Join-Path $toolsRoot 'gradle-6.7.1\bin\gradle.bat')
$jdk = Get-ChildItem -Directory (Join-Path $toolsRoot 'jdk8') | Select-Object -First 1

if (-not $jdk) {
    throw 'Portable JDK was not found under .android-build-tools\jdk8.'
}

$env:ANDROID_HOME = $sdkRoot.Path
$env:ANDROID_SDK_ROOT = $sdkRoot.Path
$env:JAVA_HOME = $jdk.FullName
$env:Path = (Join-Path $jdk.FullName 'bin') + ';' + $env:Path

Set-Content -Path (Join-Path $projectRoot 'local.properties') -Value ('sdk.dir=' + ($sdkRoot.Path -replace '\\', '/')) -Encoding ASCII

Push-Location $projectRoot
try {
    & $gradle --no-daemon assembleDebug
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    $dist = Join-Path $projectRoot 'dist'
    New-Item -ItemType Directory -Force -Path $dist | Out-Null
    Copy-Item -Force -Path (Join-Path $projectRoot 'app\build\outputs\apk\debug\app-debug.apk') -Destination (Join-Path $dist 'BibleViewer-debug.apk')
} finally {
    Pop-Location
}
