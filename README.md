# LinuxConfigs

Portable Neovim, language server, and tmux configurations for offline Rocky Linux development environments.

The goal is to provide a consistent development environment across multiple machines without requiring users to download plugins or language servers individually.

## Repository Structure

```text
LinuxConfigs/
├── .tmux.conf
├── .zshrc
├── config/
│   ├── nvim/
│   │   ├── init.lua
│   │   └── pack/
│   │       └── lab/
│   │           └── start/
│   └── tmux_active_color.py
└── opt/
    ├── nvim/
    │   └── lsp/
    │       ├── lsp.lua
    │       ├── servers/
    │       └── runtimes/
    └── test.sh
```

Neovim itself is installed separately under `/opt/nvim`.

## Requirements

- Rocky Linux 8/9 or a compatible Linux environment
- Neovim 0.12.6
- tmux 3.2a
- Python 3.6 or newer for tmux color detection
- GNOME Terminal with GSettings for automatic tmux highlighting
- Required language server runtimes installed or provided by the bundled environment

The editor configuration is designed for offline use. Plugin files and language server packages are maintained locally rather than downloaded by Neovim at startup.

## Installation

Copy the repository configuration files to their corresponding locations:

| Repository | Destination |
|---|---|
| `config/nvim/` | `~/.config/nvim/` |
| `config/tmux_active_color.py` | `~/.config/tmux_active_color.py` |
| `.tmux.conf` | `~/.tmux.conf` |
| `opt/nvim/lsp/` | `/opt/nvim/lsp/` |

Install or copy the Neovim executable to `/opt/nvim` separately.

Add `/opt/nvim/bin` to your `PATH` if it is not already available.

The `.zshrc` file is optional and should not overwrite a user's existing shell configuration.

Keep the bundled language server directory structure intact, including its executables, packages, runtime files, and symbolic links. Some language servers depend on system runtimes such as Python 3.11.

Run `opt/test.sh` to perform the included environment checks, where applicable.

## Neovim Configuration

The main configuration is:

```text
~/.config/nvim/init.lua
```

Features include:

- Habamax colorscheme, with Desert retained as an alternative
- Terminal-adaptive background highlighting
- Relative line numbers and custom status column
- Four-space indentation
- Active split and current-line highlighting
- Diagnostic underlines
- Tree-sitter syntax highlighting
- Language Server Protocol support
- Autocomplete through blink.cmp
- Git change indicators through gitsigns.nvim
- Indentation guides through indent-blankline.nvim

Language servers are configured separately in:

```text
/opt/nvim/lsp/lsp.lua
```

### Terminal-Adaptive Colors

Neovim queries the terminal background using OSC 11 and calculates brighter colors for selected UI elements.

Default adjustments:

| Element | Adjustment |
|---|---|
| Inactive split | Terminal background |
| Active split | +3% |
| Current line | +6% |
| Relative line-number text | +20% |

The current line number uses a bright foreground color.

Percentages are adjusted in `init.lua`:

```lua
local brightness = {
    active = 0.03,
    cursorline = 0.06,
    linenumber = 0.20,
}
```

The adjustment blends each RGB channel toward white, allowing the configuration to work with very dark backgrounds, including pure black.

If terminal background detection fails, the editor retains transparent background defaults.

## tmux Configuration

The main configuration is:

```text
~/.tmux.conf
```

Features include:

- RGB terminal support
- Mouse support
- Vi-style copy mode
- Pane and window numbering beginning at 1
- Pane navigation integrated with Neovim
- Pane resizing using `Prefix + h/j/k/l`
- New panes opening in the current working directory
- Active pane identification
- Terminal-adaptive pane highlighting

### Terminal-Adaptive Pane Highlighting

tmux uses the terminal background for inactive panes and a background 3% brighter for the active pane.

The configuration initializes both styles to the terminal default:

```tmux
set -g window-style 'bg=default'
set -g window-active-style 'bg=default'
```

Two hooks initialize the active color when a session is created or a client attaches:

```tmux
set-hook -g session-created 'run-shell -b "python3 ~/.config/tmux_active_color.py"'
set-hook -g client-attached 'run-shell -b "python3 ~/.config/tmux_active_color.py"'
```

The Python helper:

```text
~/.config/tmux_active_color.py
```

Reads the configured background color of the default GNOME Terminal profile using GSettings, applies the brightness adjustment, and updates tmux's `window-active-style`.

To change the active pane brightness, edit:

```python
BRIGHTNESS = 0.03
```

tmux highlighting works independently of Neovim.

**Limitations:** The helper currently supports GNOME Terminal's default profile, not arbitrary terminal emulators or nondefault profiles. It assumes that the profile has a configured background color rather than relying on system theme colors. tmux also shares global window styling across attached clients.

## Reloading Configurations

Reload tmux without restarting the server:

```bash
tmux source-file ~/.tmux.conf
```

Check the active pane color:

```bash
tmux show -gwv window-active-style
```

Restart Neovim after editing `init.lua`.

For troubleshooting tmux color detection, run:

```bash
python3 ~/.config/tmux_active_color.py
tmux show -gwv window-active-style
```

## Offline Deployment

The environment is intended to be copied onto machines without internet access.

- Copy Neovim and the required runtime files into `/opt/nvim`.
- Copy the user configuration into `~/.config/nvim`.
- Copy the tmux configuration and Python helper to their designated locations.
- Preserve bundled plugin directories, language server packages, and executable permissions.
- Verify that the required system runtimes and shared libraries are available.

No online plugin manager or automatic package installation is required at Neovim startup.

## Configuration Philosophy

- Keep configuration centralized and understandable.
- Avoid unnecessary dependencies.
- Preserve each user's preferred terminal and shell configuration.
- Use terminal-derived colors rather than hardcoded personal color schemes.
- Keep language server and editor installations portable across machines.
- Support offline development without requiring network access.

