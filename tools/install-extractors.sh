#!/usr/bin/env bash

# One-click installer for fast decompression tools used by dtrx
# - macOS: Homebrew
# - Linux: apt/dnf/yum/pacman/zypper (auto-detected)
# - Windows: use the accompanying PowerShell script install-extractors.ps1

set -u

need_sudo() {
  if [ "$(id -u)" -ne 0 ]; then echo 1; else echo 0; fi
}

have() { command -v "$1" >/dev/null 2>&1; }

install_macos() {
  if ! have brew; then
    echo "[!] 未检测到 Homebrew。请先安装 Homebrew:"
    echo "    NONINTERACTIVE=1 /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
  fi

  local pkgs=(
    pigz pbzip2 xz zstd brotli
    sevenzip p7zip unzip unrar cabextract unar
    lha arj lrzip lzip rpm cpio file wget
  )

  echo "[macOS] 使用 Homebrew 安装依赖..."
  for p in "${pkgs[@]}"; do
    # 'sevenzip' 与 'p7zip' 可能有其一
    if brew list --versions "$p" >/dev/null 2>&1; then
      echo "  - $p 已安装，跳过"
    else
      echo "  - 安装 $p ..."
      brew install "$p" || true
    fi
  done

  # 链接 7-Zip 二进制到 PATH（某些环境仅提供 7zz）
  if have 7zz && ! have 7z; then
    echo "[macOS] 检测到 7zz，创建 7z 兼容链接到 /usr/local/bin (可能需要 sudo)"
    if [ $(need_sudo) -eq 1 ]; then sudo ln -sf "$(command -v 7zz)" /usr/local/bin/7z; else ln -sf "$(command -v 7zz)" /usr/local/bin/7z; fi
  fi
}

install_linux() {
  local pm=""
  if have apt-get; then pm="apt"; fi
  if have dnf; then pm="dnf"; fi
  if have yum && [ -z "$pm" ]; then pm="yum"; fi
  if have pacman; then pm="pacman"; fi
  if have zypper; then pm="zypper"; fi

  if [ -z "$pm" ]; then
    echo "[!] 未能检测到受支持的包管理器 (apt/dnf/yum/pacman/zypper)。请手动安装所需工具。"
    exit 1
  fi

  echo "[Linux] 使用包管理器: $pm 安装依赖..."
  case "$pm" in
    apt)
      if [ $(need_sudo) -eq 1 ]; then sudo apt-get update -y; else apt-get update -y; fi
      # note: Debian/Ubuntu 下 'lha' 是虚拟包，这里用实际实现 'lhasa'
      local pkgs=(pigz pbzip2 xz-utils zstd brotli p7zip-full unzip unrar-free cabextract unar lhasa arj lrzip lzip rpm cpio file wget)
      if [ $(need_sudo) -eq 1 ]; then sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}" || true; else DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}" || true; fi
      ;;
    dnf)
      local pkgs=(pigz pbzip2 xz zstd brotli p7zip p7zip-plugins unzip unrar cabextract unar lhasa arj lrzip lzip rpm cpio file wget)
      if [ $(need_sudo) -eq 1 ]; then sudo dnf install -y "${pkgs[@]}" || true; else dnf install -y "${pkgs[@]}" || true; fi
      ;;
    yum)
      local pkgs=(pigz pbzip2 xz zstd brotli p7zip p7zip-plugins unzip unrar cabextract unar lhasa arj lrzip lzip rpm cpio file wget)
      if [ $(need_sudo) -eq 1 ]; then sudo yum install -y "${pkgs[@]}" || true; else yum install -y "${pkgs[@]}" || true; fi
      ;;
    pacman)
      local pkgs=(pigz pbzip2 xz zstd brotli p7zip unzip unrar cabextract unar lhasa arj lrzip lzip rpmextract cpio file wget)
      if [ $(need_sudo) -eq 1 ]; then sudo pacman -Sy --noconfirm "${pkgs[@]}" || true; else pacman -Sy --noconfirm "${pkgs[@]}" || true; fi
      ;;
    zypper)
      local pkgs=(pigz pbzip2 xz zstd brotli p7zip unzip unrar cabextract unar lhasa arj lrzip lzip rpm cpio file wget)
      if [ $(need_sudo) -eq 1 ]; then sudo zypper --non-interactive install "${pkgs[@]}" || true; else zypper --non-interactive install "${pkgs[@]}" || true; fi
      ;;
  esac
}

main() {
  case "$(uname -s)" in
    Darwin)
      install_macos
      ;;
    Linux)
      install_linux
      ;;
    MINGW*|MSYS*|CYGWIN*)
      echo "[!] 检测到 Windows 环境，请使用 PowerShell 脚本: tools/install-extractors.ps1"
      exit 1
      ;;
    *)
      echo "[!] 未知平台: $(uname -s)"
      exit 1
      ;;
  esac

  echo "[✓] 安装流程完成（部分包若不存在会被跳过）。"
}

main "$@"


