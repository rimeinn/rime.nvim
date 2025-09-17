---rime support for neovim
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
local fs = require 'rime.fs'
local _rime = require "rime"
local Session = _rime.Session or _rime.RimeSessionId
local Traits = require 'rime.traits'.Traits
local keys = require "rime.keys"
local Rime = require "rime.rime".Rime
local Cursor = require "rime.nvim.cursor".Cursor

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
local M = {
    --- config for default vim settings, overridden by `vim.g.airline_mode_map`
    default = {
        airline_mode_map = airline_mode_map -- used by `lua.rime.nvim.update_status_bar`
    },
    Rime = {
        preedit = "",
        have_set_keymaps = false,
        win_id = 0,
        buf_id = 0,
        augroup_id = 0,
        --- config for neovim keymaps
        keys = keys,
        cursor = nil,
    }
}

---@param rime table?
---@return table rime
function M.Rime:new(rime)
    rime = rime or {}
    rime.cursor = rime.cursor or Cursor()
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
                M.update_IM_signatures()
            end
        end
    end
    if M:process_key(key) == false then
        if #key == 1 then
            M.feed_keys(key)
        end
        return
    end
    M.update_IM_signatures()
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
    M.update_IM_signatures()
end

---get new airline mode map symbols in `update_status_bar`().
---use `setup`() to redfine it.
---@param old string
---@param name string
---@return string
function M.get_new_symbol(old, name)
    if old == M.airline_mode_map.i or old == M.airline_mode_map.ic or old == M.airline_mode_map.ix then
        return name
    end
    return old .. name
end

---update IM signatures
function M.update_IM_signatures()
    M.update_status_bar()
    M.update_cursor_color()
end

---update cursor color
function M.update_cursor_color()
    local schema = '.default'
    if vim.b.rime_is_enabled then
        schema = M.session:get_current_schema()
    end
    M.cursor:update(schema)
end

---update status bar by `airline_mode_map`. see `help airline`.
function M.update_status_bar()
    if vim.g.airline_mode_map then
        if M.airline_mode_map == nil then
            M.airline_mode_map = vim.tbl_deep_extend("keep", vim.g.airline_mode_map, M.default.airline_mode_map)
            M.g = { airline_mode_map = vim.g.airline_mode_map }
        end
        if not vim.b.rime_is_enabled then
            vim.g.airline_mode_map = M.g.airline_mode_map
        end
        if vim.b.rime_is_enabled and M.session ~= 0 then
            if M.schema_list == nil then
                M.schema_list = _rime.get_schema_list()
            end
            local schema_id = M.session:get_current_schema()
            for _, schema in ipairs(M.schema_list) do
                if schema.schema_id == schema_id then
                    for k, _ in pairs(M.default.airline_mode_map) do
                        vim.g.airline_mode_map = vim.tbl_deep_extend("keep",
                            { [k] = M.get_new_symbol(M.airline_mode_map[k], schema.name) }, vim.g.airline_mode_map)
                    end
                    break
                end
            end
        end
    end
end

return M
