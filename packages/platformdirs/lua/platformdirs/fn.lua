---wrap `vim.fn`
---@module platformdirs.fn
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
local lfs = require "lfs"
local M = {}

---wrap `vim.fs.joinpath()`
---@param ... string
---@return string
function M.joinpath(...)
    if vim then
        return vim.fs.joinpath(...)
    end
    return table.concat({ ... }, '/')
end

---wrap `vim.fn.isdirectory()`
---@param dir string
---@return boolean
function M.isdirectory(dir)
    if vim then
        return vim.fn.isdirectory(dir) == 1
    end
    return lfs.attributes(dir) and lfs.attributes(dir).mode == "directory"
end

---wrap `vim.fn.mkdir()`
---@param name string
function M.mkdir(name)
    if vim then
        vim.fn.mkdir(name, "p")
        return
    end
    lfs.mkdir(name)
end

---wrap `vim.uv.getuid()`
---@return integer id
function M.getuid()
    local ok, mod = pcall(require, 'luv')
    if not ok then
        ok, mod = pcall(require, 'posix.unistd')
    end
    if ok then
        return mod.getuid()
    end
    local p = io.popen "id -u"
    local id = 1000
    if p then
        id = tonumber(p:read("*a")) or id
        p:close()
    end
    return id
end

return M
