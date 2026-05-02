$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Push-Location $projectRoot
try {
    if (-not (Test-Path (Join-Path $projectRoot 'node_modules'))) {
        npm install
    }

    $env:CSC_IDENTITY_AUTO_DISCOVERY = 'false'
    npm run build:win
} finally {
    Pop-Location
}
