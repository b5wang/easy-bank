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
