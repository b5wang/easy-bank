<#
Purpose:
Install or complete the Windows-side WSL prerequisite for the easy-bank dev environment.

How to run:
1. Sign in with your current Windows user on Windows 11. Do not switch to the built-in Administrator account.
2. Open PowerShell with "Run as administrator".
3. Go to the repository root.
4. Run:
   Set-ExecutionPolicy -Scope Process Bypass
   .\env\dev\00_minikube\windows\10-install-wsl.ps1

Notes:
- `.ps1` is a PowerShell script file.
- Do not run this file inside WSL Ubuntu.
- Prefer your current Windows user with elevated PowerShell; avoid the built-in Administrator account.
- If Windows requests a reboot during WSL installation, reboot first and rerun this script.
#>

param(
    [string]$DistroName = "Ubuntu-22.04"
)

$ErrorActionPreference = "Stop"

function Assert-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        throw "Please run this script in elevated PowerShell."
    }
}

Assert-Admin

Write-Host "Checking WSL status..."
$wslReady = $true
try {
    wsl --status | Out-Null
} catch {
    $wslReady = $false
}

if (-not $wslReady) {
    Write-Host "WSL is not fully available yet. Running: wsl --install"
    wsl --install
    Write-Warning "Windows may require a reboot. Reboot Windows first, then rerun this script."
    return
}

Write-Host "Updating WSL..."
wsl --update

Write-Host "Setting default WSL version to 2..."
wsl --set-default-version 2

$installedDistros = @(wsl --list --quiet 2>$null | ForEach-Object { $_.Trim() } | Where-Object { $_ })

if (-not ($installedDistros -contains $DistroName)) {
    Write-Host "Installing distro $DistroName ..."
    wsl --install -d $DistroName
    Write-Warning "If Ubuntu was installed for the first time, complete the initial user creation and rerun this script."
} else {
    Write-Host "$DistroName is already installed."
}

try {
    wsl --set-version $DistroName 2
} catch {
    Write-Warning "Unable to force $DistroName to WSL2 yet. If the distro was just installed, open it once and rerun the script."
}

try {
    wsl --set-default $DistroName
} catch {
    Write-Warning "Unable to set $DistroName as default yet."
}

Write-Host "Current WSL status:"
wsl --status

Write-Host "Current WSL distro list:"
wsl --list --verbose
