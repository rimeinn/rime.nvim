---wrap `vim.fn`
---@module platformdirs.fn
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
if vim then
    return vim.fn
end
local lfs = require "lfs"
local M = {}

---wrap `vim.fn.isdirectory()`
---@param dir string
---@return boolean
function M.isdirectory(dir)
    return lfs.attributes(dir) and lfs.attributes(dir).mode == "directory"
end

---wrap `vim.fn.mkdir()`
---@param name string
function M.mkdir(name)
    lfs.mkdir(name)
end

---wrap `vim.fn.expand()`
---@param dir string
---@return string
function M.expand(dir)
    return dir
end

return M
