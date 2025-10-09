---wrap `vim.fs` and `vim.fn`
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
    return table.concat({...}, '/')
end

---wrap `vim.fs.dirname()`
---@param path string
---@return string
function M.dirname(path)
    if vim then
        return vim.fs.dirname(path)
    end
    return path:match("(.*)/[^/]*$") or '/'
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

---wrap `vim.fn.stdpath()`
---@param name string
---@return string
function M.stdpath(name)
    if vim then
        return vim.fn.stdpath(name)
    end
    return M.joinpath(os.getenv("HOME") or ".", ".local", name)
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
        return vim.api.nvim_strwidth(string)
    end
    return #string
end

return M
