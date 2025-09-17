---rime support for neovim
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
local Session = require "rime.session".Session
local Keymap = require "rime.nvim.keymap".Keymap
local Rime = require "rime.rime".Rime
local Airline = require "rime.nvim.airline".Airline
local Cursor = require "rime.nvim.cursor".Cursor
local Win = require "rime.nvim.win".Win

local M = {
    Rime = {
        preedit = "",
        win = Win(),
        augroup_id = vim.api.nvim_create_augroup("rime", { clear = false }),
    }
}

---@param rime table?
---@return table rime
function M.Rime:new(rime)
    rime = rime or {}
    rime.cursor = rime.cursor or Cursor()
    rime.airline = rime.airline or Airline()
    rime.keymap = rime.keymap or Keymap()
    -- rime = Rime(rime)
    setmetatable(rime, {
        __index = self
    })
    return rime
end

---initial
function M.init()
    if M.session == nil then
        M.session = Session()
    end
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
        if vim.b.rime_is_enabled then
            return M.draw_ui(key)
        end
    end
end

---feed keys
---@param text string
function M.feed_keys(text)
    if vim.v.char ~= "" then
        vim.v.char = text
    else
        -- cannot work
        -- vim.api.nvim_feedkeys(text, 't', true)
        local cursor = vim.api.nvim_win_get_cursor(0)
        local r = cursor[1]
        local c = cursor[2]
        vim.api.nvim_buf_set_text(0, r - 1, c, r - 1, c, { text })
        vim.api.nvim_win_set_cursor(0, { r, c + #text })
    end
    M.win:close()
    M.preedit = ""
    M.keymap:set_special(M.preedit ~= "" and M.callback or nil)
end

---draw UI. wrap `ui.draw()`
---@param key string
function M.draw_ui(key)
    if key == "" then
        key = vim.v.char
    end
    if M.preedit == "" then
        for _, disable_key in ipairs(M.keymap.keys.disable) do
            if key == vim.keycode(disable_key) then
                M.disable()
                M.update()
            end
        end
    end
    if M.session:parse_key(key) == false then
        if #key == 1 then
            M.feed_keys(key)
        end
        return
    end
    M.update()
    local context = M.session:get_context()
    if context.menu.num_candidates == 0 then
        M.feed_keys(M.session:get_commit_text())
        return
    end
    vim.v.char = ""

    local ui = M.ui
    local lines, col = ui:draw(context)
    M.preedit = lines[1]:gsub(ui.cursor, ""):gsub(" ", "")

    M.win:open(lines, col)
    M.keymap:set_special(M.preedit ~= "" and M.callback or nil)
end

---enable IME
---@see disable
---@see toggle
function M.enable()
    M.init()
    M.keymap:set_nowait(true)

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
    vim.b.rime_is_enabled = true
end

---disable IME
---@see enable
---@see toggle
function M.disable()
    M.keymap:set_nowait(false)

    vim.api.nvim_create_augroup("rime", {})
    vim.b.rime_is_enabled = false
end

---toggle IME
---@see enable
---@see disable
function M.toggle()
    if vim.b.rime_is_enabled then
        M.disable()
    else
        M.enable()
    end
    M.update()
end

---update IM signatures
function M.update()
    M.airline:update(M.session, vim.b.rime_is_enabled)
    M.cursor:update(M.session, vim.b.rime_is_enabled)
end

return M
