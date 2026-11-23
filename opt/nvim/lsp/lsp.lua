-- Portable language server configuration
local base = "/opt/nvim/lsp"
local bin = base .. "/servers/bin/"

-- Use bundled Node.js and installed language server executables.
vim.env.PATH = base .. "/runtimes/node/bin:" .. bin .. vim.fn.getenv("PATH"):gsub("^", ":")

-- Recognize FPGA constraint files as Tcl.
vim.filetype.add({
    extension = {
        xdc = "tcl",
        sdc = "tcl",
    },
})

-- Language server definitions:
-- { Neovim config name, executable, optional arguments }
local servers = {
    -- FPGA development
    { "slang_server",   "slang-server" },
    { "vhdl_ls",        "vhdl_ls" },
    { "tclsp",          "tclsp" },

    -- General programming
    { "clangd",         "clangd" },
    { "basedpyright",   "basedpyright-langserver", "--stdio" },
    { "bashls",         "bash-language-server", "start" },
    { "lua_ls",         "lua-language-server" },
    { "rust_analyzer",  "rust-analyzer" },
    { "ts_ls",          "typescript-language-server", "--stdio" },

    -- Configuration and web
    { "jsonls",         "vscode-json-language-server", "--stdio" },
    { "yamlls",         "yaml-language-server", "--stdio" },
    { "html",           "vscode-html-language-server", "--stdio" },
    { "cssls",          "vscode-css-language-server", "--stdio" },
    { "taplo",          "taplo", "lsp", "stdio" },
    { "dockerls",       "docker-langserver", "--stdio" },

    -- Documents and build tools
    { "marksman",       "marksman", "server" },
    { "texlab",         "texlab" },
    { "cmake",          "cmake-language-server" },
    { "autotools_ls",   "autotools-language-server" },
}

-- Configure and enable all available servers.
for _, server in ipairs(servers) do
    local name = server[1]
    local executable = bin .. server[2]

    if vim.fn.executable(executable) == 1 then
        local cmd = { executable }

        for i = 3, #server do
            table.insert(cmd, server[i])
        end

        vim.lsp.config(name, { cmd = cmd })
        vim.lsp.enable(name)
    else
        vim.notify(
            "LSP executable missing: " .. executable,
            vim.log.levels.WARN
        )
    end
end
