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

## Image preview

Opening a PNG, JPG, JPEG, or PDF file from Neo-tree displays it in Neovim. This
requires a terminal that supports the Kitty graphics protocol, such as Kitty,
Ghostty, or WezTerm. The image data is transferred through the terminal when
Neovim is running over SSH, so the image file does not need to exist locally.

Run `:checkhealth snacks` to diagnose terminal image support. When using tmux,
Snacks enables passthrough for the current pane automatically; tmux 3.3 or newer
is recommended.
