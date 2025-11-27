---wrap `vim`
---@module platformdirs.vim
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113 212
if vim then
    return vim
end
local M = {
    uv = require "platformdirs.uv"
}
local ok, luv = pcall(require, 'luv')
if ok then
    M.uv = luv
end

---wrap `vim.validate()`
---@diagnostic disable-next-line: unused-vararg
function M.validate(...)
    return true
end

---wrap `vim.gsplit()`
---@param s string
---@param sep string
---@param opts table?
---@diagnostic disable-next-line: unused-local
function M.gsplit(s, sep, opts)
    return s:gmatch("([^" .. sep .. "]+)" .. sep)
end

---wrap `vim.startswith()`
---@param s string
---@param prefix string
---@return boolean
function M.startswith(s, prefix)
    return s:sub(1, #prefix) == prefix
end

return M
