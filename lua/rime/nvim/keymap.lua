---config for keys.
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
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

local M = {
    Keymap = {
        --- config for neovim keymaps
        maps = {},
        keys = {
            nowait = nowait,   -- keys which map <nowait>, see `help <nowait>`
            special = special, -- keys which only be mapped when IME window is opened
            disable = {        -- keys which will disable IME. It is useful when you input CJKV/ASCII mixedly
                "<Space>"
            },
        },
    }
}

---@param keymap table?
---@return table keymap
function M.Keymap:new(keymap)
    keymap = keymap or {}
    setmetatable(keymap, {
        __index = self
    })
    return keymap
end

setmetatable(M.Keymap, {
    __call = M.Keymap.new
})

---set or delete keymap
---@param lhs string
---@param callback string | function?
function M.Keymap:set(lhs, callback, ...)
    if not callback and self.maps[lhs] then
        vim.keymap.del("i", lhs, { buffer = 0 })
        self.maps[lhs] = nil
    elseif callback and not self.maps[lhs] then
        local rhs = callback
        if type(callback) == "function" then
            rhs = callback(..., lhs)
        end
        vim.keymap.set("i", lhs, rhs, { buffer = 0, noremap = true, nowait = true, })
        self.maps[lhs] = rhs
    end
end

---set special keymaps
---@param callback function?
function M.Keymap:set_special(callback, ...)
    for _, lhs in ipairs(self.keys.special) do
        self:set(lhs, callback, ...)
    end
end

---set `<nowait>` keymaps
---@param is_enabled boolean
function M.Keymap:set_nowait(is_enabled)
    for _, lhs in ipairs(self.keys.nowait) do
        self:set(lhs, is_enabled and lhs or nil)
    end
end

return M
