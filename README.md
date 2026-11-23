# LinuxConfigs

Offline installation of Neovim plugins, language servers, and tmux configuration for Rocky Linux.

Run all commands from the root of this repository.

## 1. Extract Large Binaries

Three executables are stored as ZIP files to accommodate GitHub's file-size limits. Extract them in their existing directories.

```bash
(cd opt/nvim/lsp/servers/packages/clangd/clangd_23.1.0/bin && unzip -o clangd.zip)
(cd opt/nvim/lsp/runtimes/node/bin && unzip -o node.zip)
(cd opt/nvim/lsp/servers/packages/basedpyright/venv/lib/python3.11/site-packages/nodejs_wheel/bin && unzip -o node.zip)
```

## 2. Install Configurations

```bash
mkdir -p ~/.config/nvim
cp -a config/nvim/. ~/.config/nvim/

cp .tmux.conf ~/
cp config/tmux_active_color.py ~/.config/
```

The included `.zshrc` is optional. Users can retain their existing shell configurations.

## 3. Install Language Servers

Neovim is expected to already be installed under `/opt/nvim`.

```bash
sudo mkdir -p /opt/nvim/lsp
sudo cp -a opt/nvim/lsp/. /opt/nvim/lsp/
```

Restore executable permissions if necessary:

```bash
sudo chmod +x /opt/nvim/lsp/servers/packages/clangd/clangd_23.1.0/bin/clangd
sudo chmod +x /opt/nvim/lsp/runtimes/node/bin/node
sudo chmod +x /opt/nvim/lsp/servers/packages/basedpyright/venv/lib/python3.11/site-packages/nodejs_wheel/bin/node
```

Some bundled language servers require system dependencies, including Python 3.11.

## 4. Verify Installation

```bash
nvim --version
tmux -V
```

Open Neovim and check language server status:

```vim
:checkhealth vim.lsp
```

## 5. Reload tmux

```bash
tmux source-file ~/.tmux.conf
```

The tmux configuration uses `~/.config/tmux_active_color.py` to detect the default GNOME Terminal profile's background color and apply a brighter active-pane background.

Requires Python 3.6+ and GNOME Terminal with an explicitly configured background color.

Verify the active pane color:

```bash
tmux show -gwv window-active-style
```

## Notes

- Designed for offline environments; no plugin downloads are required during startup.
- Neovim plugins are installed under `~/.config/nvim/pack/lab/start/`.
- Language servers are configured in `/opt/nvim/lsp/lsp.lua`.
- Neovim highlighting automatically adapts to the terminal background.
- tmux active-pane highlighting is initialized when sessions are created or clients attach.
- Existing user shell settings do not need to be replaced.

