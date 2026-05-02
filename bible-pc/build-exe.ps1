$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Push-Location $projectRoot
try {
    if (-not (Test-Path (Join-Path $projectRoot 'node_modules'))) {
        npm install
    }

    $env:CSC_IDENTITY_AUTO_DISCOVERY = 'false'
    $env:ELECTRON_BUILDER_DISABLE_BUILD_CACHE = 'true'
    npm run build:win
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    $unpackedDir = Join-Path $projectRoot 'dist\win-unpacked'
    $debugFile = Join-Path $projectRoot 'dist\builder-debug.yml'
    if (Test-Path $unpackedDir) {
        Remove-Item -LiteralPath $unpackedDir -Recurse -Force
    }
    if (Test-Path $debugFile) {
        Remove-Item -LiteralPath $debugFile -Force
    }
} finally {
    Pop-Location
}
