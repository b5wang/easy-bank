<#
Purpose:
Install Docker Desktop for the easy-bank development environment.

How to run:
1. Download the Docker Desktop Windows installer first.
2. Sign in with your current Windows user on Windows 11. Do not switch to the built-in Administrator account.
3. Open PowerShell with "Run as administrator".
4. Go to the repository root.
5. Run:
   Set-ExecutionPolicy -Scope Process Bypass
   .\env\dev\00_minikube\windows\30-install-docker-desktop.ps1 -InstallerPath "C:\Users\<YourUser>\Downloads\Docker Desktop Installer.exe"

Notes:
- `.ps1` is a PowerShell script file.
- Do not run this file inside WSL Ubuntu.
- Prefer your current Windows user with elevated PowerShell; avoid the built-in Administrator account.
- The `-InstallerPath` value must point to a real Docker Desktop installer `.exe` file on Windows.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$InstallerPath
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

if (-not (Test-Path $InstallerPath)) {
    throw "Docker Desktop installer not found: $InstallerPath"
}

Write-Host "Installing Docker Desktop from $InstallerPath ..."

Start-Process -FilePath $InstallerPath `
    -ArgumentList "install", "--accept-license", "--backend=wsl-2", "--no-windows-containers" `
    -Wait

Write-Host "Docker Desktop installation command completed."
Write-Host "After opening Docker Desktop, confirm these settings manually:"
Write-Host "1. Use the WSL 2 based engine"
Write-Host "2. Resources > WSL Integration > Ubuntu-22.04 enabled"
Write-Host "3. Linux containers mode enabled"
