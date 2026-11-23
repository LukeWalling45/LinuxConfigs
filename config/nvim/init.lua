vim.opt.packpath:append(vim.fn.stdpath("config"))

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- Automatic language-specific indentation
vim.opt.autoindent = true
vim.cmd("filetype plugin indent on")

vim.opt.termguicolors = true

--vim.cmd.colorscheme("desert")
vim.cmd.colorscheme("habamax")

-- Diagnostic underline colors
vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", {
    undercurl = true,
    sp = "#FF5555",  -- Red
})

vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", {
    undercurl = true,
    sp = "#FFCC00",  -- Yellow
})

vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", {
    undercurl = true,
    sp = "#55AAFF",  -- Blue
})

vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", {
    undercurl = true,
    sp = "#55CCAA",  -- Green
})

vim.diagnostic.config({
    severity_sort = true,
})

vim.opt.statusline = "%f  %h%m%r%=Line %l/%L Col %c  %P"

vim.opt.fillchars:append({ vert = "│" })
vim.api.nvim_set_hl(0, "WinSeparator", {
    fg = "#A9A9A9",
    bg = "NONE"
})

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 2
vim.opt.signcolumn = "yes"
vim.opt.statuscolumn = "%s%=%{v:relnum == 0 ? v:lnum : v:relnum}│ "

vim.api.nvim_set_hl(0, "LineNr", { fg = "#78658A" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#B7A8C8" })

vim.opt.cursorline = false
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#1B0B2F" })

local function set_background(focused)
    local bg = focused and "#110620" or "#0D041A"
    vim.api.nvim_set_hl(0, "Normal", { bg = bg })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "#0D041A" })
end

set_background(true)

vim.api.nvim_create_autocmd("FocusGained", {
    callback = function()
        set_background(true)
        vim.wo.cursorline = true
    end,
})

vim.api.nvim_create_autocmd("FocusLost", {
    callback = function()
        set_background(false)
        vim.wo.cursorline = false
    end,
})

vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "WinLeave" }, {
    callback = function(args)
        vim.wo.cursorline = args.event == "WinEnter"
    end,
})

vim.opt.list = true
vim.opt.listchars = {
    tab = "→ ",
    trail = "·",
    nbsp = "␣",
    --leadmultispace = "│   ",
}

-- Indent Blankline
require("ibl").setup({
    indent = { char = "│" },
    scope = { enabled = false },
})


-- Tree-sitter
require("nvim-treesitter").setup({
    install_dir = vim.fn.stdpath("config")
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang then return end

        local ok = pcall(vim.treesitter.language.add, lang)
        if ok then
            pcall(vim.treesitter.start, args.buf, lang)
        end
    end,
})

-- Language server configuration
dofile("/opt/nvim/lsp/lsp.lua")

-- -- Trouble: diagnostics and references
-- require("trouble").setup({})
--
-- -- Telescope: project navigation
-- require("telescope").setup({})
--
-- -- Which-key: shortcut help
-- require("which-key").setup({
--     icons = { mappings = false },
-- })

-- Autocomplete
require("blink.cmp").setup({
    keymap = { preset = "default" },

    completion = {
        documentation = { auto_show = false },
    },

    sources = {
        default = { "lsp", "path", "buffer" },
    },

    fuzzy = {
        implementation = "lua",
    },
})

-- Git change indicators
require("gitsigns").setup({
    signs = {
        add          = { text = "+" },
        change       = { text = "┃" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
    },
})

-- -- Neo-tree file explorer
-- require("neo-tree").setup({
--     close_if_last_window = true,
--
--     window = {
--         position = "left",
--         width = 30,
--     },
--
--     filesystem = {
--         follow_current_file = {
--             enabled = true,
--         },
--     },
-- })


-- -- Bufferline: top file tabs
-- vim.opt.showtabline = 2
-- vim.opt.mouse = "a"
-- vim.api.nvim_set_hl(0, "BufferLineExplorer", {
--     fg = "#E9DDF5",
--     bg = "#38204F",
--     bold = true,
-- })
--
-- require("bufferline").setup({
--     options = {
--         mode = "buffers",
--         show_buffer_icons = false,
--         show_buffer_close_icons = true,
--         show_close_icon = false,
--
--         buffer_close_icon = "×",
--         modified_icon = "●",
--
--         separator_style = "thin",
--         indicator = {
--             style = "none",
--         },
--
--         always_show_bufferline = true,
--
--         custom_areas = {
--             left = function()
--                 return {
--                     {
--                         text = "%@v:lua.NeoTreeExplorerClick@ ☰ %X",
--                         fg = "#F1E8FF",
--                         bg = "#38204F",
--                     },
--                 }
--             end,
--         },
--
--         offsets = {
--             {
--                 filetype = "neo-tree",
--                 text = "EXPLORER",
--                 text_align = "center",
--                 highlight = "BufferLineExplorer",
--                 separator = true,
--             },
--         },
--         left_mouse_command = function(bufnr)
--             for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
--                 local buf = vim.api.nvim_win_get_buf(win)
--
--                 if vim.bo[buf].filetype ~= "neo-tree"
--                     and vim.bo[buf].buftype == "" then
--
--                     vim.api.nvim_set_current_win(win)
--                     vim.api.nvim_win_set_buf(win, bufnr)
--                     return
--                 end
--             end
--
--             vim.cmd("buffer " .. bufnr)
--         end,
--     },
--
--
--     highlights = {
--         fill = {
--             bg = "#0D041A",
--         },
--
--         background = {
--             fg = "#9483A8",
--             bg = "#150727",
--         },
--
--         buffer_selected = {
--             fg = "#E9DDF5",
--             bg = "#38204F",
--             bold = true,
--             italic = false,
--         },
--
--         buffer_visible = {
--             fg = "#B7A8C8",
--             bg = "#150727",
--         },
--
--         separator = {
--             fg = "#0D041A",
--             bg = "#150727",
--         },
--
--         separator_selected = {
--             fg = "#0D041A",
--             bg = "#38204F",
--         },
--
--         separator_visible = {
--             fg = "#0D041A",
--             bg = "#150727",
--         },
--
--         modified = {
--             fg = "#B7A8C8",
--             bg = "#150727",
--         },
--
--         modified_selected = {
--             fg = "#B7A8C8",
--             bg = "#38204F",
--         },
--
--         close_button = {
--             fg = "#9483A8",
--             bg = "#150727",
--         },
--
--         close_button_selected = {
--             fg = "#B7A8C8",
--             bg = "#38204F",
--         },
--
--         offset_separator = {
--             fg = "#A9A9A9",
--             bg = "#0D041A",
--         },
--     },
-- })
--
-- -- Clickable Explorer button
-- _G.NeoTreeExplorerClick = function()
--     vim.cmd("Neotree filesystem toggle left")
-- end
