#!/usr/bin/env pwsh
<#
 One-click installer for fast decompression tools on Windows
 - Uses winget if available, falling back to choco if installed
 - Installs: 7zip, UnRAR, zstd, brotli, xz, lzip, lrzip (if available), arj, lha, cabextract, wget
 Note: Some Unix-only tools may be unavailable on Windows; we prioritize equivalents.
#>

function Have($cmd) { Get-Command $cmd -ErrorAction SilentlyContinue | ForEach-Object { $_ } }

function Install-WithWinget {
  param([string[]]$Ids)
  foreach ($id in $Ids) {
    try {
      Write-Host "[winget] 安装 $id ..."
      winget install --id $id --silent --accept-source-agreements --accept-package-agreements --scope machine | Out-Null
    } catch { }
  }
}

function Install-WithChoco {
  param([string[]]$Pkgs)
  foreach ($p in $Pkgs) {
    try {
      Write-Host "[choco] 安装 $p ..."
      choco install $p -y --no-progress | Out-Null
    } catch { }
  }
}

Write-Host "[Windows] 安装快速解压相关工具..."

$wingetIds = @(
  '7zip.7zip',         # 7-Zip
  'GnuWin32.UnRAR',    # UnRAR (if available; else skip)
  'Facebook.Zstandard',# zstd
  'Google.Brotli',     # brotli (if available)
  'GnuWin32.Wget'      # wget
)

$chocoPkgs = @(
  '7zip', 'unrar', 'zstd', 'brotli', 'xz', 'cabextract', 'wget'
)

if (Have winget) {
  Install-WithWinget -Ids $wingetIds
} elseif (Have choco) {
  Install-WithChoco -Pkgs $chocoPkgs
} else {
  Write-Host "[!] 未检测到 winget 或 choco。请安装其中之一后重试。"
  exit 1
}

Write-Host "[✓] 安装流程完成（不可用的软件将被跳过）。"


