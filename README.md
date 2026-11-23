# LinuxConfigs

Portable Neovim, tmux, and Zsh configuration for Rocky Linux.

## Setup

From your home directory:

```bash
cd ~/LinuxConfigs
```

### 1. Extract large binaries

```bash
unzip -o clangd.zip -d .
unzip -o node.zip -d .
unzip -o basedpyright-node.zip -d .
```

### 2. Copy Neovim configuration

```bash
mkdir -p ~/.config
cp -a config/nvim ~/.config/
```

### 3. Copy language servers

```bash
sudo mkdir -p /opt/nvim
sudo cp -a opt/nvim/lsp /opt/nvim/
```

### 4. Restore executable permissions

```bash
sudo chmod +x /opt/nvim/lsp/servers/packages/clangd/clangd_23.1.0/bin/clangd
sudo chmod +x /opt/nvim/lsp/runtimes/node/bin/node
sudo chmod +x /opt/nvim/lsp/servers/packages/basedpyright/venv/lib/python3.11/site-packages/nodejs_wheel/bin/node
```

### 5. Copy tmux and Zsh configuration

```bash
cp .tmux.conf ~/.tmux.conf
cp .zshrc ~/.zshrc
```

## Verify

```bash
nvim --version
/opt/nvim/lsp/servers/bin/slang-server --version
/opt/nvim/lsp/runtimes/node/bin/node --version
```

Open an `.sv` file in Neovim and run:

```vim
:checkhealth vim.lsp
```

## Notes

- Neovim must already be installed at `/opt/nvim/`.
- Python-based language servers may require Python 3.11.
- No Mason installation or internet connection is required.
- ZIP files must contain their original repository-relative paths.

