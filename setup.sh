#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INIT_VIM="${SCRIPT_DIR}/init.vim"

if [[ ! -f "${INIT_VIM}" ]]; then
  printf 'Could not find init.vim next to this script.\n' >&2
  exit 1
fi

install_macos_dependencies() {
  if ! command -v brew >/dev/null 2>&1; then
    printf 'Installing Homebrew...\n'
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  printf 'Installing command-line dependencies and language servers...\n'
  brew update
  brew install \
    bash-language-server \
    curl \
    fd \
    git \
    go \
    gopls \
    lazygit \
    neovim \
    node \
    pyright \
    ripgrep \
    texlab \
    tree-sitter

  printf 'Installing macOS applications, TeX, and a Nerd Font...\n'
  brew install --cask basictex skim font-jetbrains-mono-nerd-font

  export PATH="/Library/TeX/texbin:${PATH}"
  if ! command -v latexmk >/dev/null 2>&1; then
    printf 'Installing latexmk through TeX Live...\n'
    sudo /Library/TeX/texbin/tlmgr update --self
    sudo /Library/TeX/texbin/tlmgr install latexmk
  fi
}

install_linux_dependencies() {
  if ! command -v apt-get >/dev/null 2>&1; then
    printf 'This script supports apt-based Linux distributions only.\n' >&2
    exit 1
  fi

  if [[ "${EUID}" -eq 0 ]]; then
    SUDO=()
  elif command -v sudo >/dev/null 2>&1; then
    SUDO=(sudo)
  else
    printf 'sudo is required to install apt packages.\n' >&2
    exit 1
  fi

  printf 'Installing Linux system dependencies with apt...\n'
  "${SUDO[@]}" apt-get update
  "${SUDO[@]}" apt-get install -y \
    build-essential \
    ca-certificates \
    chktex \
    curl \
    fd-find \
    file \
    git \
    golang-go \
    npm \
    ripgrep \
    tar

  mkdir -p "${HOME}/.local/bin" "${HOME}/.local/lib/nvim"
  export PATH="${HOME}/.local/bin:${PATH}"

  if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    ln -sfn "$(command -v fdfind)" "${HOME}/.local/bin/fd"
  fi

  case "$(uname -m)" in
    x86_64)
      NVIM_ARCH='x86_64'
      TEXLAB_ARCH='x86_64'
      ;;
    aarch64 | arm64)
      NVIM_ARCH='arm64'
      TEXLAB_ARCH='aarch64'
      ;;
    *)
      printf 'Unsupported Linux architecture: %s\n' "$(uname -m)" >&2
      exit 1
      ;;
  esac

  TEMP_DIR="$(mktemp -d)"
  trap 'rm -rf "${TEMP_DIR}"' EXIT

  printf 'Installing the latest Neovim release under ~/.local...\n'
  curl -fL \
    "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz" \
    -o "${TEMP_DIR}/nvim.tar.gz"
  tar -xzf "${TEMP_DIR}/nvim.tar.gz" \
    --strip-components=1 \
    -C "${HOME}/.local/lib/nvim"
  ln -sfn "${HOME}/.local/lib/nvim/bin/nvim" "${HOME}/.local/bin/nvim"

  printf 'Installing TexLab under ~/.local...\n'
  curl -fL \
    "https://github.com/latex-lsp/texlab/releases/latest/download/texlab-${TEXLAB_ARCH}-linux.tar.gz" \
    -o "${TEMP_DIR}/texlab.tar.gz"
  tar -xzf "${TEMP_DIR}/texlab.tar.gz" -C "${HOME}/.local/bin" texlab
  chmod +x "${HOME}/.local/bin/texlab"

  printf 'Installing language tooling under ~/.local...\n'
  GOBIN="${HOME}/.local/bin" go install golang.org/x/tools/gopls@latest
  GOBIN="${HOME}/.local/bin" go install github.com/jesseduffield/lazygit@latest
  npm install --global --prefix "${HOME}/.local" bash-language-server pyright tree-sitter-cli
}

case "$(uname -s)" in
  Darwin)
    install_macos_dependencies
    ;;
  Linux)
    install_linux_dependencies
    ;;
  *)
    printf 'Supported operating systems: macOS and apt-based Linux.\n' >&2
    exit 1
    ;;
esac

NVIM_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/nvim"
VIM_PLUG_PATH="${NVIM_DATA_HOME}/site/autoload/plug.vim"

if [[ ! -f "${VIM_PLUG_PATH}" ]]; then
  printf 'Bootstrapping vim-plug...\n'
  mkdir -p "$(dirname -- "${VIM_PLUG_PATH}")"
  curl -fLo "${VIM_PLUG_PATH}" \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

printf 'Installing Neovim plugins...\n'
nvim --headless -u "${INIT_VIM}" \
  "+PlugInstall --sync" \
  '+qa'

printf 'Installing Treesitter parsers...\n'
nvim --headless -u "${INIT_VIM}" \
  "+lua require('nvim-treesitter').install({ 'bash', 'go', 'gomod', 'gosum', 'gotmpl', 'gowork', 'json', 'lua', 'markdown', 'markdown_inline', 'python', 'toml', 'vim', 'vimdoc', 'yaml' }):wait(300000)" \
  '+qa'

printf '\nSetup complete. Ensure ~/.local/bin is on PATH, then restart Neovim.\n'
