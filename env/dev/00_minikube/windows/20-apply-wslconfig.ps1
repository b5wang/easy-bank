param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$sourcePath = Join-Path $PSScriptRoot ".wslconfig.example"
$targetPath = Join-Path $HOME ".wslconfig"

if (-not (Test-Path $sourcePath)) {
    throw "Template file not found: $sourcePath"
}

if ((Test-Path $targetPath) -and (-not $Force)) {
    throw "Target file already exists: $targetPath . Use -Force if you want to overwrite it."
}

if (Test-Path $targetPath) {
    $backupPath = "$targetPath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $targetPath $backupPath -Force
    Write-Host "Existing .wslconfig was backed up to $backupPath"
}

Copy-Item $sourcePath $targetPath -Force

Write-Host "Applied .wslconfig to $targetPath"
Write-Host "Run 'wsl --shutdown' after Docker Desktop and WSL settings are ready."
