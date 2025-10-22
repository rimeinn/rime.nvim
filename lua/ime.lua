---Display current schema name
local M = {}

---see `:h airline-xkblayout`
---@return string
function M.current()
    local ok, mod = pcall(require, "ime.nvim")
    if ok and mod.ime.backend then
        return mod.ime.backend:get_schema_name()
    end
    ok, mod = pcall(require, "fcitx5-ui")
    if ok then
        return mod.displayCurrentIM()
    end
    ok, mod = pcall(require, "rime.nvim")
    if ok then
        mod.init()
        return mod.ime.session:get_schema_name()
    end
    return ""
end

return M
