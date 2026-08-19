param()

$ErrorActionPreference = "Stop"

$BaseDir = Resolve-Path (Join-Path $PSScriptRoot "..")

$UIHost = $env:DOGRAH_UI_HOST
if ([string]::IsNullOrWhiteSpace($UIHost)) { $UIHost = "0.0.0.0" }

$DockerUp = $env:DOGRAH_DOCKER_UP
if ([string]::IsNullOrWhiteSpace($DockerUp)) { $DockerUp = "1" }

function Cleanup {
  try {
    & (Join-Path $BaseDir "scripts/stop_services.ps1") | Out-Null
  } catch {
    # Best-effort cleanup.
  }
}

try {
  $activate = Join-Path $BaseDir "venv\Scripts\Activate.ps1"
  if (Test-Path $activate) {
    # Activate the repo venv if it exists.
    . $activate
  }

  if ($DockerUp -eq "1") {
    docker compose -f (Join-Path $BaseDir "docker-compose-local.yaml") up -d | Out-Null
  }

  Write-Host "Starting backend..."
  & (Join-Path $BaseDir "scripts/start_services_dev.ps1")

  Write-Host "Starting UI (Next.js)..."
  Set-Location (Join-Path $BaseDir "ui")
  & npm run dev -- --hostname $UIHost
} finally {
  Cleanup
}

