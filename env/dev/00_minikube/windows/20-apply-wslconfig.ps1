<#
Purpose:
Apply the recommended .wslconfig template for the easy-bank development environment.

How to run:
1. Sign in with your current Windows user on Windows 11. Do not switch to the built-in Administrator account.
2. Open PowerShell with "Run as administrator".
3. Go to the repository root.
4. Run:
   Set-ExecutionPolicy -Scope Process Bypass
   .\env\dev\00_minikube\windows\20-apply-wslconfig.ps1

Notes:
- `.ps1` is a PowerShell script file.
- Do not run this file inside WSL Ubuntu.
- Prefer your current Windows user with elevated PowerShell; avoid the built-in Administrator account.
- If `%UserProfile%\.wslconfig` already exists, this script will stop unless you pass `-Force`.
#>

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
