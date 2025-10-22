---wrap `vim.fs` and `vim.fn`
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
local M = {}

---wrap `vim.fn.getchar()`
---@return integer
function M.getchar()
    if vim then
        return vim.fn.getchar()
    end
    return io.read(1):byte()
end

---wrap `vim.fn.strwidth()`
---@param string string
---@return integer
function M.strwidth(string)
    if vim then
        return vim.fn.strwidth(string)
    end
    return #string
end

return M
