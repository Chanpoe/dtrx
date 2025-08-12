#!/usr/bin/env pwsh
<#
 One-click installer for fast decompression tools on Windows (best-effort)
 - Uses winget if available, falling back to choco if installed
 - Installs minimal, reliable set first: 7zip, zstd, wget
 - 7-Zip 可处理 zip/7z/rar，大多数场景无需单独安装 unrar
 - 其它 Unix-only 工具（brotli/xz/lzip/lrzip/cabextract/arj/lha）在 winget 上可用性不稳定，尽量通过 choco 安装
 注意：项目本身不原生支持 Windows 运行（参见 setup.cfg）。建议优先在 WSL/Docker 中使用。
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
  '7zip.7zip',          # 7-Zip
  'Facebook.Zstandard', # zstd
  'GnuWin32.Wget'       # wget (可选)
)

$chocoPkgs = @(
  '7zip', 'zstd', 'brotli', 'xz', 'cabextract', 'wget', 'unrar'
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


