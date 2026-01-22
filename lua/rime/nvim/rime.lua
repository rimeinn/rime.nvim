---rime support for neovim based `rime.Rime()`.
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
local Win = require "ime.nvim.win".Win
local Keymap = require "ime.nvim.keymap".Keymap
local Hook = require "ime.nvim.hooks.chainedhook".ChainedHook

local Rime = require "rime.rime".Rime

local M = {
    Rime = {
        win = Win(),
    }
}

---feed keys, wrap `vim.v.char`
---@param text string
function M.feed_keys(text)
    if vim.v.char ~= "" then
        vim.v.char = text
        return
    end
    -- input is <CR>
    vim.api.nvim_put({ text }, "b", false, true)
end

---@param rime table?
---@return table rime
function M.Rime:new(rime)
    rime = rime or {}
    rime.keymap = rime.keymap or Keymap()
    rime.hook = rime.hook or Hook()
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

---create autocmds.
---@param augroup_id integer?
function M.Rime:create_autocmds(augroup_id)
    augroup_id = augroup_id or vim.api.nvim_create_augroup("rime", {})

    vim.api.nvim_create_autocmd("InsertCharPre", {
        group = augroup_id,
        callback = self:callback()
    })

    vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
        group = augroup_id,
        callback = function()
            if not self:get_enabled() then
                return
            end
            self.session:clear_composition()
            self.win:update()
        end
    })

    vim.api.nvim_create_autocmd("BufEnter", {
        group = augroup_id,
        callback = function()
            self.hook:update(self, self:get_enabled())
        end
    })
end

---get current schema ID, aka short name
---@return string
function M.Rime:get_current_schema()
    return self.session:get_current_schema()
end

---get current schema name
---@return string
function M.Rime:get_schema_name()
    return self.session:get_schema_name()
end

---override `IME`.
---@section overrides

---wrap `self:process()`
---@param input string?
function M.Rime:exe(input)
    input = input or vim.v.char
    if not self.win:has_preedit() then
        for _, disable_key in ipairs(self.keymap.keys.disable) do
            if input == vim.keycode(disable_key) then
                self:disable()
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
        self.hook:update(self, self:get_enabled())
    end
end

---save the flag to use IM in insert mode for each buffer.
---override `self.iminsert` because it is global to all buffers.
---@param is_enabled boolean
-- luacheck: ignore 212/self
function M.Rime:set_enabled(is_enabled)
    self.keymap:set_nowait(is_enabled)
    self.hook:update(self, is_enabled)
    vim.b.iminsert = is_enabled or nil
end

---similar to `set_enabled()`.
---@return boolean
-- luacheck: ignore 212/self
function M.Rime:get_enabled()
    return vim.b.iminsert
end

return M
