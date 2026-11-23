
-- ============================================================
-- Plugin Path
-- ============================================================

vim.opt.packpath:append(vim.fn.stdpath("config"))


-- ============================================================
-- Editor Settings
-- ============================================================

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.autoindent = true

vim.cmd("filetype plugin indent on")

-- True color support
vim.opt.termguicolors = true

-- Statusline
vim.opt.statusline = "%f  %h%m%r%=Line %l/%L Col %c  %P"

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 2
vim.opt.signcolumn = "yes"

vim.opt.statuscolumn =
    "%s%=%{v:relnum == 0 ? v:lnum : v:relnum}│ "

-- Whitespace indicators
vim.opt.list = true
vim.opt.listchars = {
    tab = "→ ",
    trail = "·",
    nbsp = "␣",
    -- leadmultispace = "│   ",
}

-- Window separators
vim.opt.fillchars:append({ vert = "│" })


-- ============================================================
-- Colorscheme
-- ============================================================

-- vim.cmd.colorscheme("desert")
vim.cmd.colorscheme("habamax")

-- Neutral split separator
vim.api.nvim_set_hl(0, "WinSeparator", {
    fg = "#A9A9A9",
    bg = "NONE",
})


-- ============================================================
-- Terminal-Based Highlighting
-- ============================================================

-- Brightness adjustments relative to the terminal background.
-- Values blend each RGB channel toward white.
--
-- 0.00 = terminal background
-- 0.05 = 5% brighter
-- 0.10 = 10% brighter
-- 0.20 = 20% brighter
-- 1.00 = pure white

local brightness = {
    active = 0.03,       -- Active pane / split
    cursorline = 0.06,   -- Current line
    linenumber = 0.20,  -- Relative line numbers
}

-- Inactive windows retain the terminal background.
-- The current line number retains the colorscheme's color.

-- Transparent fallback until terminal detection succeeds
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })

-- Preserve existing colorscheme highlight attributes
local original = {}

for _, name in ipairs({
    "Normal",
    "NormalNC",
    "CursorLine",
    "LineNr",
}) do
    original[name] = vim.api.nvim_get_hl(0, {
        name = name,
        link = false,
    })
end

-- Blend a hex color toward white
local function lighten(hex, amount)
    local r = tonumber(hex:sub(2, 3), 16)
    local g = tonumber(hex:sub(4, 5), 16)
    local b = tonumber(hex:sub(6, 7), 16)

    local function adjust(value)
        return math.floor(
            value + (255 - value) * amount + 0.5
        )
    end

    return string.format(
        "#%02X%02X%02X",
        adjust(r),
        adjust(g),
        adjust(b)
    )
end

-- Convert an OSC 11 RGB channel to 8-bit
local function decode_channel(value)
    local maximum = 16 ^ #value - 1

    return math.floor(
        tonumber(value, 16) * 255 / maximum + 0.5
    )
end

-- Extract terminal background from an OSC 11 response
local function detect_background(sequence)
    local r, g, b = sequence:match(
        "\027%]11;rgb:(%x+)/(%x+)/(%x+)"
    )

    if not r then
        return nil
    end

    return string.format(
        "#%02X%02X%02X",
        decode_channel(r),
        decode_channel(g),
        decode_channel(b)
    )
end

-- Detected background and focus state
local base_color = nil
local focused = true

-- Apply calculated colors to Neovim
local function apply_colors()
    if not base_color then
        return
    end

    local active = lighten(
        base_color, brightness.active
    )

    local line = lighten(
        base_color, brightness.cursorline
    )

    local numbers = lighten(
        base_color, brightness.linenumber
    )

    -- Active split
    vim.api.nvim_set_hl(
        0,
        "Normal",
        vim.tbl_extend("force", original.Normal, {
            bg = focused and active or base_color,
        })
    )

    -- Inactive splits
    vim.api.nvim_set_hl(
        0,
        "NormalNC",
        vim.tbl_extend("force", original.NormalNC, {
            bg = base_color,
        })
    )

    -- Current-line highlight
    vim.api.nvim_set_hl(
        0,
        "CursorLine",
        vim.tbl_extend("force", original.CursorLine, {
            bg = line,
        })
    )

    -- Relative line numbers
    vim.api.nvim_set_hl(
        0,
        "LineNr",
        vim.tbl_extend("force", original.LineNr, {
            fg = numbers,
            bg = "NONE",
        })
    )

    -- Keep the colorscheme's current line-number color
    -- while matching the surrounding background.
    vim.api.nvim_set_hl(0, "CursorLineNr", {
        bg = "NONE",
        fg = vim.api.nvim_get_hl(
            0, { name = "Normal", link = false }
        ).fg,
        bold = true,
    })
end

-- Apply matching highlighting to the active tmux pane
local function update_tmux()
    if not base_color or not vim.env.TMUX then
        return
    end

    local active = lighten(
        base_color, brightness.active
    )

    vim.fn.system({
        "tmux",
        "set-option",
        "-gw",
        "window-active-style",
        "bg=" .. active,
    })
end

local theme_group = vim.api.nvim_create_augroup(
    "TerminalTheme",
    { clear = true }
)

-- Receive the terminal's OSC 11 background response
vim.api.nvim_create_autocmd("TermResponse", {
    group = theme_group,

    callback = function(event)
        local color = detect_background(
            event.data.sequence
        )

        if not color then
            return
        end

        base_color = color

        apply_colors()
        update_tmux()
    end,
})

-- Track terminal focus
vim.api.nvim_create_autocmd("FocusGained", {
    group = theme_group,

    callback = function()
        focused = true
        apply_colors()
    end,
})

vim.api.nvim_create_autocmd("FocusLost", {
    group = theme_group,

    callback = function()
        focused = false
        apply_colors()
    end,
})

-- Request the terminal background when Neovim starts
vim.api.nvim_create_autocmd("VimEnter", {
    group = theme_group,
    once = true,

    callback = function()
        vim.schedule(function()
            if vim.env.TMUX then
                -- OSC 11 wrapped for tmux passthrough
                vim.api.nvim_ui_send(
                    "\027Ptmux;\027\027]11;?\007\027\\"
                )
            else
                -- Direct terminal OSC 11 query
                vim.api.nvim_ui_send(
                    "\027]11;?\027\\"
                )
            end
        end)
    end,
})


-- ============================================================
-- Cursor-Line Behavior
-- ============================================================

-- Highlight only the current line in the active split.
vim.opt.cursorline = false

local function update_cursorline()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        vim.wo[win].cursorline =
            focused and win == vim.api.nvim_get_current_win()
    end
end

vim.api.nvim_create_autocmd({
    "VimEnter",
    "WinEnter",
    "WinLeave",
    "FocusGained",
    "FocusLost",
}, {
    callback = function()
        vim.schedule(update_cursorline)
    end,
})


-- ============================================================
-- Diagnostics
-- ============================================================

-- Diagnostic underline colors
vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", {
    undercurl = true,
    sp = "#FF5555",
})

vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", {
    undercurl = true,
    sp = "#FFCC00",
})

vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", {
    undercurl = true,
    sp = "#55AAFF",
})

vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", {
    undercurl = true,
    sp = "#55CCAA",
})

vim.diagnostic.config({
    severity_sort = true,
})


-- ============================================================
-- Indent Blankline
-- ============================================================

require("ibl").setup({
    indent = {
        char = "│",
    },

    scope = {
        enabled = false,
    },
})


-- ============================================================
-- Tree-sitter
-- ============================================================

require("nvim-treesitter").setup({
    install_dir = vim.fn.stdpath("config"),
})

-- Enable Tree-sitter for supported languages
vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(
            args.match
        )

        if not lang then
            return
        end

        local ok = pcall(
            vim.treesitter.language.add,
            lang
        )

        if ok then
            pcall(
                vim.treesitter.start,
                args.buf,
                lang
            )
        end
    end,
})


-- ============================================================
-- Language Servers
-- ============================================================

dofile("/opt/nvim/lsp/lsp.lua")


-- ============================================================
-- Autocomplete
-- ============================================================

require("blink.cmp").setup({
    keymap = {
        preset = "default",
    },

    completion = {
        documentation = {
            auto_show = false,
        },
    },

    sources = {
        default = {
            "lsp",
            "path",
            "buffer",
        },
    },

    fuzzy = {
        implementation = "lua",
    },
})


-- ============================================================
-- Git Change Indicators
-- ============================================================

require("gitsigns").setup({
    signs = {
        add          = { text = "+" },
        change       = { text = "┃" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
    },
})

