---default config. see `lua vim.print(require"rime.config")`
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
