# NeoVim Configuration

## Setup

On macOS or an apt-based Linux distribution, run:

```sh
./setup.sh
```

The script installs Neovim, the configured language servers and command-line
tools, vim-plug, all plugins, and the Treesitter parsers used by `init.vim`.
macOS uses Homebrew and also installs BasicTeX, Skim, and a Nerd Font. Linux uses
only `apt` for system packages and skips those macOS-specific applications;
install a TeX distribution, `latexmk`, and a PDF viewer separately if VimTeX
support is needed.
