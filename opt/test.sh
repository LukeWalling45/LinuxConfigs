
#!/usr/bin/env bash

ROOT="/opt/nvim/lsp"
BIN="$ROOT/servers/bin"
export PATH="$ROOT/runtimes/node/bin:$BIN:$PATH"

pass=0
fail=0

check() {
    local name="$1"
    shift

    if "$@" >/dev/null 2>&1; then
        echo "PASS  $name"
        ((pass++))
    else
        echo "FAIL  $name"
        ((fail++))
    fi
}

echo "=== Portable LSP Validation ==="

# Runtime dependencies
check "Node.js" "$ROOT/runtimes/node/bin/node" --version
check "Python 3.11" python3.11 --version

# Language servers
check "SystemVerilog" "$BIN/slang-server" --version
check "VHDL" "$BIN/vhdl_ls" --version
check "Tcl" "$BIN/tclsp" --help
check "C/C++" "$BIN/clangd" --version
check "Python" "$BIN/basedpyright" --version
check "Bash" "$BIN/bash-language-server" --version
check "Lua" "$BIN/lua-language-server" --version
check "Rust" "$BIN/rust-analyzer" --version
check "TypeScript" "$BIN/typescript-language-server" --version
check "Markdown" "$BIN/marksman" --version
check "LaTeX" "$BIN/texlab" --version
check "CMake" "$BIN/cmake-language-server" --version
check "TOML" "$BIN/taplo" --version

# Check remaining server executables
for exe in \
    vscode-json-language-server \
    yaml-language-server \
    vscode-html-language-server \
    vscode-css-language-server \
    docker-langserver \
    autotools-language-server
do
    check "$exe" test -x "$BIN/$exe"
done

# Check for broken symbolic links
if [ -z "$(find -L "$ROOT" -type l -print -quit 2>/dev/null)" ]; then
    echo "PASS  Symbolic links"
    ((pass++))
else
    echo "FAIL  Broken symbolic links"
    ((fail++))
fi

echo
echo "=== Results: $pass PASS, $fail FAIL ==="

if (( fail > 0 )); then
    exit 1
fi

