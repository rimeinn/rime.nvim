---default config. see `lua vim.print(require"rime.config")`
local fs = require "rime.fs"
local shared_data_dir = ""
---@diagnostic disable: undefined-global
-- luacheck: ignore 113
local prefix = os.getenv("PREFIX") or
    fs.dirname(fs.dirname(os.getenv("SHELL") or "/bin/sh"))
for _, dir in ipairs {
    -- /usr merge: /usr/bin/sh -> /usr/share/rime-data
    fs.joinpath(prefix, "share/rime-data"),
    -- non /usr merge: /bin/sh -> /usr/share/rime-data
    fs.joinpath(prefix, "usr/share/rime-data"),
    "/run/current-system/sw/share/rime-data",
    "/sdcard/rime-data"
} do
    if fs.isdirectory(dir) then
        shared_data_dir = dir
    end
end
local user_data_dir = ""
local home = os.getenv("HOME") or "."
for _, dir in ipairs {
    home .. "/.config/ibus/rime",
    home .. "/.local/share/fcitx5/rime",
    home .. "/.config/fcitx/rime",
    home .. "/sdcard/rime"
} do
    if fs.isdirectory(dir) then
        user_data_dir = dir
    end
end

local nowait = { "!", "<Bar>", "}", "~" }
-- "
for i = 0x23, 0x26 do
    local key = string.char(i)
    table.insert(nowait, key)
end
-- '()
for i = 0x2a, 0x7b do
    local key = string.char(i)
    table.insert(nowait, key)
end
local special = { "<S-Esc>", "<S-Tab>", "<BS>", "<M-BS>", "<C-Space>", "<M-C-Space>", "<M-Bar>" }
for _, name in ipairs { "Insert", "CR", "Del", "Up", "Down", "Left", "Right", "Home", "End", "PageUp", "PageDown" } do
    for _, s_name in ipairs { name, "S-" .. name } do
        for _, c_s_name in ipairs { s_name, "C-" .. s_name } do
            for _, keyname in ipairs { c_s_name, "M-" .. c_s_name } do
                table.insert(special, "<" .. keyname .. ">")
            end
        end
    end
end
for i = 1, 35 do
    table.insert(special, "<F" .. i .. ">")
end
for i = 0x41, 0x5a do
    local keyname = string.char(i)
    for _, lhs in ipairs({ "<C-" .. keyname .. ">", "<M-C-" .. keyname .. ">" }) do
        table.insert(special, lhs)
    end
end
table.insert(special, "<M-C-[>")
for i = 0x5c, 0x5f do
    local keyname = string.char(i)
    for _, lhs in ipairs { "<C-" .. keyname .. ">", "<M-C-" .. keyname .. ">" } do
        table.insert(special, lhs)
    end
end
for i = 0x21, 0x7b do
    table.insert(special, "<M-" .. string.char(i) .. ">")
end
-- <M-Bar>
for i = 0x7d, 0x7e do
    table.insert(special, "<M-" .. string.char(i) .. ">")
end

local indices = {
    "①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨", "⓪"
}
local airline_mode_map = {
    s = "SELECT",
    S = 'S-LINE',
    ["\x13"] = 'S-BLOCK',
    i = 'INSERT',
    ic = 'INSERT COMPL GENERIC',
    ix = 'INSERT COMPL',
    R = 'REPLACE',
    Rc = 'REPLACE COMP GENERIC',
    Rv = 'V REPLACE',
    Rx = 'REPLACE COMP',
}
return {
    preedit = "",
    has_set_keymaps = false,
    win_id = 0,
    buf_id = 0,
    augroup_id = 0,
    --- config for neovim keymaps
    keys = {
        nowait = nowait,   -- keys which map <nowait>, see `help <nowait>`
        special = special, -- keys which only be mapped when IME window is opened
        disable = {        -- keys which will disable IME. It is useful when you input CJKV/ASCII mixedly
            "<Space>"
        },
    },
    --- config for rime traits
    traits = {
        shared_data_dir = shared_data_dir,           -- directory store shared data
        user_data_dir = user_data_dir,               -- directory store user data
        log_dir = fs.joinpath(fs.stdpath("state"), "rime"), -- Directory of log files.
        -- Value is passed to Glog library using FLAGS_log_dir variable.
        -- NULL means temporary directory, and "" means only writing to stderr.
        app_name = "rime.nvim-rime", -- Pass a C-string constant in the format "rime.x"
        -- where 'x' is the name of your application.
        -- Add prefix "rime." to ensure old log files are automatically cleaned.
        min_log_level = 3, -- Minimal level of logged messages.
        -- Value is passed to Glog library using FLAGS_minloglevel variable.
        -- 0 = INFO (default), 1 = WARNING, 2 = ERROR, 3 = FATAL
        distribution_name = "Rime",           -- distribution name
        distribution_code_name = "nvim-rime", -- distribution code name
        distribution_version = "0.0.1",       -- distribution version
    },
    --- config for neovim IME UI
    ui = {
        left = "<|",       -- symbol for left menu
        right = "|>",      -- symbol for right menu
        left_sep = "[",    -- symbol for left separator
        right_sep = "]",   -- symbol for right separator
        cursor = "|",      -- symbol for cursor
        indices = indices, -- symbols for indices, maximum is 10 for 1-9, 0
    },
    --- config for default vim settings
    default = {
        airline_mode_map = airline_mode_map -- used by `lua.rime.nvim.update_status_bar`
    },
    --- config for cursor
    cursor = {
        default = { bg = 'white' },
        double_pinyin_mspy = { bg = 'red' },
        japanese = { bg = 'yellow' }
    }
}
