---rime support for neovim
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
local rime = require "rime"
rime.Session = rime.Session or rime.RimeSessionId
local Traits = require 'rime.traits'.Traits
local parse_key = require("rime.keys").parse_key
local UI = require("rime.ui").UI
local M = require "rime.config"

---setup
---@param conf table
function M.setup(conf)
    M = vim.tbl_deep_extend("keep", conf, M)
end

---process key. wrap `lua.rime.keys.parse_key`()
---@param key string
---@param modifiers string[]
---@see process_keys
function M.process_key(key, modifiers)
    modifiers = modifiers or {}
    local keycode, mask = parse_key(key, modifiers)
    return M.session:process_key(keycode, mask)
end

---process keys
---@param keys string
---@param modifiers string[]
---@see process_key
function M.process_keys(keys, modifiers)
    modifiers = modifiers or {}
    for key in keys:gmatch("(.)") do
        if M.process_key(key, modifiers) == false then
            return false
        end
    end
    return true
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

---get rime commit
function M.get_commit_text()
    if M.session:commit_composition() then
        return M.session:get_commit().text
    end
    return ""
end

---reset keymaps
function M.reset_keymaps()
    if M.preedit ~= "" and M.has_set_keymaps == false then
        for _, lhs in ipairs(M.keys.special) do
            vim.keymap.set("i", lhs, M.callback(lhs), { buffer = 0, noremap = true, nowait = true, })
        end
        M.has_set_keymaps = true
    elseif M.preedit == "" and M.has_set_keymaps == true then
        for _, lhs in ipairs(M.keys.special) do
            vim.keymap.del("i", lhs, { buffer = 0 })
        end
        M.has_set_keymaps = false
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
    if M.process_key(key, {}) == false then
        if #key == 1 then
            M.feed_keys(key)
        end
        return
    end
    M.update_IM_signatures()
    local context = M.session:get_context()
    if context.menu.num_candidates == 0 then
        M.feed_keys(M.get_commit_text())
        return
    end
    vim.v.char = ""

    local ui = UI()
    local lines, col = ui:draw(context)
    M.preedit = lines[1]
        :gsub(ui.cursor, "")
        :gsub(" ", "")

    local width = 0
    for _, line in ipairs(lines) do
        width = math.max(vim.api.nvim_strwidth(line), width)
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

---clear composition
function M.clear_composition()
    M.session:clear_composition()
end

---initial
function M.init()
    if M.session == nil then
        M.traits = Traits()
        M.session = rime.Session()
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
            M.clear_composition()
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

---get context with all candidates, useful for `lua.rime.nvim.cmp`
---@param keys string
---@return table
function M.get_context_with_all_candidates(keys)
    M.init()
    M.process_keys(keys, {})
    local context = rime.get_context(M.sessionId)
    if (keys ~= '') then
        local result = context
        while (not context.menu.is_last_page) do
            M.process_key('=', {})
            context = rime.get_context(M.sessionId)
            result.menu.num_candidates = result.menu.num_candidates + context.menu.num_candidates
            if (result.menu.select_keys and context.menu.select_keys) then
                table.insert(result.menu.select_keys, context.menu.select_keys)
            end
            if (result.menu.candidates and context.menu.candidates) then
                table.insert(result.menu.candidates, context.menu.candidates)
            end
        end
    end
    M.clear_composition()
    return context
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
    local hl = M.cursor.default
    if vim.b.rime_is_enabled then
        hl = M.cursor[M.session:get_current_schema()] or hl
    end
    vim.api.nvim_set_hl(0, "CursorIM", hl)
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
                M.schema_list = rime.get_schema_list()
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
