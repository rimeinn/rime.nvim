---rime support for neovim based `rime.Rime()`.
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
local Rime = require "rime.rime".Rime
local Win = require "rime.nvim.win".Win
local Keymap = require "rime.nvim.keymap".Keymap
local Hook = require "rime.nvim.hooks.chainedhook".ChainedHook

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

---@param rime table?
---@return table rime
function M.Rime:new(rime)
    rime = rime or {}
    rime.keymap = rime.keymap or Keymap()
    rime.hook = rime.hook or Hook()
    rime.augroup_id = rime.augroup_id or vim.api.nvim_create_augroup("rime", { clear = false })
    rime = Rime(rime)
    setmetatable(rime, {
        __index = self
    })
    return rime
end

setmetatable(M.Rime, {
    __index = Rime,
    __call = M.Rime.new
})

---override `IME`.
---@section overrides

---wrap `self:process()`
---@param input string?
function M.Rime:exe(input)
    input = input or vim.v.char
    if not self.win:has_preedit() then
        for _, disable_key in ipairs(self.keymap.keys.disable) do
            if input == vim.keycode(disable_key) then
                self:_toggle(false)
                return
            end
        end
    end

    local text, lines, col = self:process(input)
    M.feed_keys(text)
    self.win:update(lines, col)
    self.keymap:set_special(self.win:has_preedit() and self.callback or nil, self)
    -- change input schema
    if text == "" then
        self.hook:update(self.session, self:is_enabled())
    end
end

---enable/disable IME
function M.Rime:switch()
    local is_enabled = self:is_enabled()
    self.keymap:set_nowait(is_enabled)

    if is_enabled then
        vim.api.nvim_create_autocmd("InsertCharPre", {
            group = self.augroup_id,
            buffer = 0,
            callback = self:callback(),
        })
        vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
            group = self.augroup_id,
            buffer = 0,
            callback = function()
                self.session:clear_composition()
                self.win:update()
            end
        })
        vim.api.nvim_create_autocmd("BufEnter", {
            group = self.augroup_id,
            callback = function()
                self.hook:update(self.session, self:is_enabled())
            end
        })
    else
        vim.api.nvim_create_augroup("rime", {})
    end
    self.hook:update(self.session, is_enabled)
end

---use `vim.b.rime_is_enabled` to keep local
---@param is_enabled boolean?
function M.Rime:is_enabled(is_enabled)
    if is_enabled == nil then
        return vim.b.rime_is_enabled or self.rime_is_enabled
    end
    vim.b.rime_is_enabled = is_enabled
    return vim.b.rime_is_enabled
end

return M
