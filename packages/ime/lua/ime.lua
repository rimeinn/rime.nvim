---Display current schema name
---@module ime
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
local M = {}

---see `:h airline-xkblayout`
---@return string
function M.current()
    local ok, mod = pcall(require, "ime.nvim")
    if ok and mod.ime.backend then
        return mod.ime:get_schema_name()
    end
    -- https://github.com/black-desk/fcitx5-ui.nvim/pull/4/files
    local mode = vim.fn.mode()
    if mode ~= 'i' or mode ~= 'R' then
        return ''
    end

    for _, name in ipairs { "fcitx5.nvim", "rime.nvim" } do
        ok, mod = pcall(require, name)
        if ok then
            mod.init()
            return mod.ime:get_schema_name()
        end
    end
    return ""
end

return M
