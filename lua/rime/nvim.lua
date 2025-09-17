---rime support for neovim
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
local fs = require 'rime.fs'
local _rime = require "rime"
local Session = _rime.Session or _rime.RimeSessionId
local Traits = require 'rime.traits'.Traits
local keys = require "rime.keys"
local Rime = require "rime.rime".Rime
local Airline = require "rime.nvim.airline".Airline
local Cursor = require "rime.nvim.cursor".Cursor

local M = {
    Rime = {
        preedit = "",
        have_set_keymaps = false,
        win_id = 0,
        buf_id = 0,
        augroup_id = 0,
        --- config for neovim keymaps
        keys = keys,
        airline = nil,
        cursor = nil,
    }
}

---@param rime table?
---@return table rime
function M.Rime:new(rime)
    rime = rime or {}
    rime.cursor = rime.cursor or Cursor()
    rime.airline = rime.airline or Airline()
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
        if vim.b.rime_is_enabled then
            return M.draw_ui(key)
        end
    end
end

---reset keymaps
function M.reset_keymaps()
    if M.preedit ~= "" and M.have_set_keymaps == false then
        for _, lhs in ipairs(M.keys.special) do
            vim.keymap.set("i", lhs, M.callback(lhs), { buffer = 0, noremap = true, nowait = true, })
        end
        M.have_set_keymaps = true
    elseif M.preedit == "" and M.have_set_keymaps == true then
        for _, lhs in ipairs(M.keys.special) do
            vim.keymap.del("i", lhs, { buffer = 0 })
        end
        M.have_set_keymaps = false
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
    M.win_close()
    M.preedit = ""
    M.reset_keymaps()
end

---draw UI. wrap `ui.draw()`
---@param key string
function M.draw_ui(key)
    if key == "" then
        key = vim.v.char
    end
    if M.preedit == "" then
        for _, disable_key in ipairs(M.keys.disable) do
            if key == vim.keycode(disable_key) then
                M.disable()
                M.update()
            end
        end
    end
    if M:process_key(key) == false then
        if #key == 1 then
            M.feed_keys(key)
        end
        return
    end
    M.update()
    local context = M.session:get_context()
    if context.menu.num_candidates == 0 then
        M.feed_keys(M:get_commit_text())
        return
    end
    vim.v.char = ""

    local ui = M.ui
    local lines, col = ui:draw(context)
    M.preedit = lines[1]
        :gsub(ui.cursor, "")
        :gsub(" ", "")

    local width = 0
    for _, line in ipairs(lines) do
        width = math.max(fs.strwidth(line), width)
    end
    local config = {
        relative = "cursor",
        height = #lines,
        style = "minimal",
        width = width,
        row = 1,
        col = col,
    }
    if M.buf_id == 0 or not vim.api.nvim_buf_is_valid(M.buf_id) then
        M.buf_id = vim.api.nvim_create_buf(false, true)
    end
    vim.schedule(
        function()
            vim.api.nvim_buf_set_lines(M.buf_id, 0, #lines, false, lines)
            if (M.win_id == 0 or not vim.api.nvim_win_is_valid(M.win_id)) then
                M.win_id = vim.api.nvim_open_win(M.buf_id, false, config)
            else
                vim.api.nvim_win_set_config(M.win_id, config)
            end
        end
    )
    M.reset_keymaps()
end

---close IME window
function M.win_close()
    vim.schedule(
        function()
            if M.win_id ~= 0 and vim.api.nvim_win_is_valid(M.win_id) then
                vim.api.nvim_win_close(M.win_id, false)
            end
            M.win_id = 0
        end
    )
end

---initial
function M.init()
    if M.session == nil then
        M.traits = Traits()
        M.session = Session()
    end
    if M.augroup_id == 0 then
        M.augroup_id = vim.api.nvim_create_augroup("rime", { clear = false })
    end
end

---enable IME
---@see disable
---@see toggle
function M.enable()
    M.init()
    for _, nowait_key in ipairs(M.keys.nowait) do
        vim.keymap.set("i", nowait_key, nowait_key, { buffer = 0, noremap = true, nowait = true })
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
            M.win_close()
        end
    })
    vim.b.rime_is_enabled = true
end

---disable IME
---@see enable
---@see toggle
function M.disable()
    for _, nowait_key in ipairs(M.keys.nowait) do
        vim.keymap.del("i", nowait_key, { buffer = 0 })
    end

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
