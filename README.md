
# Neovim + tmux Setup

## Requirements
- Neovim 0.12.6
- tmux
- Zsh
- Git

## Installation

Copy the following files to their destinations:

| File | Destination |
|---|---|
| `nvim/` | `~/.config/nvim/` |
| `.tmux.conf` | `~/.tmux.conf` |
| `slang-server` | `/opt/nvim/bin/slang-server` |

Make slang-server executable:

```bash
sudo chmod +x /opt/nvim/bin/slang-server
```

Restart Neovim and reload tmux:

```bash
tmux source-file ~/.tmux.conf
```

