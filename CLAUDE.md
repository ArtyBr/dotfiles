# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository tracking `~/.config`. It contains configuration for:
- **AwesomeWM** (`awesome/`) — tiling window manager (Lua)
- **Neovim** (`nvim/`) — LazyVim-based editor config (Lua)
- **Kitty** (`kitty/`) — terminal emulator
- **Tmux** (`tmux/`) — terminal multiplexer
- **Starship** (`starship.toml`) — shell prompt
- **Rofi** (`rofi/`) — application launcher

## Applying Configuration Changes

Most configs are live-reloaded or require a restart:

- **AwesomeWM**: `awesome --check` to validate, then `Mod4+Ctrl+R` to reload in-session, or `echo 'awesome.restart()' | awesome-client`
- **Neovim**: `:source %` for current file, `:Lazy sync` for plugin changes, `:checkhealth` for diagnostics
- **Tmux**: `tmux source ~/.config/tmux/tmux.conf` or `Ctrl+a r` if `tmux-sensible` is installed
- **Kitty**: `kill -SIGUSR1 $(pgrep kitty)` for live reload
- **Starship**: takes effect on next shell prompt automatically

## AwesomeWM Architecture (`awesome/`)

Entry point is `rc.lua`. Key customization points:

- `net_interface` variable near the top — update to match your network interface name (e.g., `wlp0s20f3`)
- `mytheme.lua` — colors, fonts, wallpaper path (Dracula color scheme)
- `widgets/` — custom widgets (battery, clock, date, tasklist, wireless, volume popup)
- `utils/autostart.lua` — apps launched on startup (currently `copyq`, `picom`)
- `utils/helpers/` — shared helper functions
- `awesome-wm-widgets/` — git submodule with community widgets (cpu, volume, logout-popup)
- `awesome-buttons/` — git submodule for button styles

The wibar (top bar) layout: `[layoutbox | taglist] [tasklist] [date | clock | battery | volume | wireless | cpu]`

**Modkey** is `Mod4` (Super/Windows key). Key bindings of note:
- `Mod4+Return` — kitty terminal
- `Mod4+b` — Zen Browser
- `Mod4+r` — Rofi launcher
- `Mod4+v` — CopyQ clipboard
- `Mod4+Shift+s` — Flameshot screenshot
- `Mod4+p` — logout popup

## Neovim Architecture (`nvim/`)

Based on [LazyVim](https://lazyvim.github.io). Structure:
- `lua/config/` — `lazy.lua` (plugin manager bootstrap), `options.lua`, `keymaps.lua`, `autocmds.lua`
- `lua/plugins/` — custom plugin specs that override/extend LazyVim defaults
- `lazy-lock.json` — pinned plugin versions

Plugin updates: `:Lazy update`. To add a plugin, create a new `.lua` file in `lua/plugins/`.

## Tmux (`tmux/tmux.conf`)

Prefix is `Ctrl+a`. Key bindings:
- `prefix + |` — vertical split
- `prefix + -` — horizontal split
- `h/j/k/l` — vim-style pane navigation (via `vim-tmux-navigator`)
- `Alt+j/k` — resize pane vertically

TPM plugins are in `tmux/plugins/`. Install: `prefix + I`. The `vim-tmux-navigator` plugin enables seamless navigation between tmux panes and neovim splits.

## Theme

Dracula color scheme used consistently across all tools:
- Background: `#282a36`, Foreground: `#f8f8f2`
- Accent/purple: `#bd93f9`, Pink: `#ff79c6`
- Font: JetBrainsMono Nerd Font
