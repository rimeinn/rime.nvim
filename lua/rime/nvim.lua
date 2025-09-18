---rime support for neovim
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
local Session = require "rime.session".Session
local Rime = require "rime.rime".Rime
local Win = require "rime.nvim.win".Win
local Keymap = require "rime.nvim.keymap".Keymap
local Plugins = require "rime.nvim.plugins".Plugins

local M = {
    Rime = {
        win = Win(),
    }
}

---feed keys, wrap `vim.v.char` and `vim.api.nvim_feedkeys()`
---TODO: `vim.api.nvim_feedkeys(text, 't', true)` cannot work
---@param text string
function M.feed_keys(text)
    if vim.v.char ~= "" then
        vim.v.char = text
        return
    end
    local cursor = vim.api.nvim_win_get_cursor(0)
    local r = cursor[1]
    local c = cursor[2]
    vim.api.nvim_buf_set_text(0, r - 1, c, r - 1, c, { text })
    vim.api.nvim_win_set_cursor(0, { r, c + #text })
end

---setup
---@param conf table
function M.setup(conf)
    M = vim.tbl_deep_extend("keep", conf, M)
end

---@param rime table?
---@return table rime
function M.Rime:new(rime)
    rime = rime or {}
    rime.keymap = rime.keymap or Keymap()
    rime.plugins = rime.plugins or Plugins()
    rime.augroup_id = rime.augroup_id or vim.api.nvim_create_augroup("rime", { clear = false })
    -- rime = Rime(rime)
    local UI = require'rime.ui'.UI
    rime.ui = rime.ui or UI()
    setmetatable(rime, {
        __index = self
    })
    return rime
end

setmetatable(M.Rime, {
    __index = Rime,
    __call = M.Rime.new
})

local rime = M.Rime()

---get callback for drawing UI
---@param key string
function M.Rime:callback(key)
    return function()
        return self:exe(key)
    end
end

---wrap `self:process()`
---@param input string
function M.Rime:exe(input)
    if not vim.b.rime_is_enabled then
        return
    end
    if input == "" then
        input = vim.v.char
    end
    if not rime.win:has_preedit() then
        for _, disable_key in ipairs(rime.keymap.keys.disable) do
            if input == vim.keycode(disable_key) then
                self:disable()
                return
            end
        end
    end

    local text, lines, col = rime:process(input)
    M.feed_keys(text)
    if text ~= "" then
        rime.win:close()
        rime.keymap:set_special(rime.win:has_preedit() and self.callback or nil, rime)
        return
    end
    rime.win:open(lines, col)
    rime.keymap:set_special(rime.win:has_preedit() and self.callback or nil, rime)
    -- change input schema
    rime.plugins:update(rime.session, vim.b.rime_is_enabled)
end

---toggle IME
---@param is_enabled boolean?
---@see enable
---@see disable
function M.Rime:toggle(is_enabled)
    if is_enabled == nil then
        is_enabled = not vim.b.rime_is_enabled
    end
    vim.b.rime_is_enabled = is_enabled
    rime.keymap:set_nowait(is_enabled)

    if is_enabled then
        if rime.session == nil then
            rime.session = Session()
        end
        vim.api.nvim_create_autocmd("InsertCharPre", {
            group = rime.augroup_id,
            buffer = 0,
            callback = rime:callback(""),
        })
        vim.api.nvim_create_autocmd({ "InsertLeave", "WinLeave" }, {
            group = rime.augroup_id,
            buffer = 0,
            callback = function()
                rime.session:clear_composition()
                rime.win:close()
            end
        })
    else
        vim.api.nvim_create_augroup("rime", {})
    end
    rime.plugins:update(rime.session, vim.b.rime_is_enabled)
end

---enable IME
---@see toggle
function M.Rime:enable()
    self:toggle(true)
end

---disable IME
---@see toggle
function M.Rime:disable()
    self:toggle(false)
end

return M
