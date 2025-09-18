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
        augroup_id = vim.api.nvim_create_augroup("rime", { clear = false }),
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
    rime.plugins = rime.plugins or Plugins()
    -- rime = Rime(rime)
    setmetatable(rime, {
        __index = self
    })
    return rime
end

setmetatable(M.Rime, {
    __index = Rime,
    __call = M.Rime.new
})

setmetatable(M, {
    __index = M.Rime(),
})

---setup
---@param conf table
function M.setup(conf)
    M = vim.tbl_deep_extend("keep", conf, M)
end

---get callback for draw UI
---@param key string
function M.callback(key)
    return function()
        return M.exe(key)
    end
end

---wrap `self:process()`
---@param input string
function M.exe(input)
    if not vim.b.rime_is_enabled then
        return
    end
    if input == "" then
        input = vim.v.char
    end
    if not M.win:has_preedit() then
        for _, disable_key in ipairs(M.keymap.keys.disable) do
            if input == vim.keycode(disable_key) then
                M.disable()
                return
            end
        end
    end

    local text, lines, col = M:process(input)
    M.feed_keys(text)
    if text ~= "" then
        M.win:close()
        M.keymap:set_special(M.win:has_preedit() and M.callback or nil)
        return
    end
    M.win:open(lines, col)
    M.keymap:set_special(M.win:has_preedit() and M.callback or nil)
    -- change input schema
    M.plugins:update(M.session, vim.b.rime_is_enabled)
end

---toggle IME
---@param is_enabled boolean?
---@see enable
---@see disable
function M.toggle(is_enabled)
    if is_enabled == nil then
        is_enabled = not vim.b.rime_is_enabled
    end
    vim.b.rime_is_enabled = is_enabled
    M.keymap:set_nowait(is_enabled)

    if is_enabled then
        if M.session == nil then
            M.session = Session()
        end
        vim.api.nvim_create_autocmd("InsertCharPre", {
            group = M.augroup_id,
            buffer = 0,
            callback = M.callback(""),
        })
        vim.api.nvim_create_autocmd({ "InsertLeave", "WinLeave" }, {
            group = M.augroup_id,
            buffer = 0,
            callback = function()
                M.session:clear_composition()
                M.win:close()
            end
        })
    else
        vim.api.nvim_create_augroup("rime", {})
    end
    M.plugins:update(M.session, vim.b.rime_is_enabled)
end

---enable IME
---@see toggle
function M.enable()
    M.toggle(true)
end

---disable IME
---@see toggle
function M.disable()
    M.toggle(false)
end

return M
