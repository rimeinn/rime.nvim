---wrap `vim.fn`
---@module vim.fn
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113 212
if vim and vim.fn then
    return vim.fn
end
local lfs = require "lfs"
local fs = require 'vim.fs'
local M = {}

---wrap `vim.fn.getcwd()`
---@return string cwd
function M.getcwd()
    if vim then
        return vim.fn.getcwd()
    end
    return lfs.currentdir()
end

---wrap `vim.fn.isdirectory()`
---@param dir string
---@return boolean
function M.isdirectory(dir)
    return lfs.attributes(dir) and lfs.attributes(dir).mode == "directory"
end

---wrap `vim.fn.mkdir()`
---@param name string
---@param flags string?
---@param prot integer?
---@diagnostic disable-next-line: unused-local
function M.mkdir(name, flags, prot)
    lfs.mkdir(name)
end

---wrap `vim.fn.expand()`
---@param dir string
---@return string
function M.expand(dir)
    return dir
end

---wrap `vim.fn.getchar()`
---@return integer
function M.getchar()
    return io.read(1):byte()
end

---wrap `vim.fn.strwidth()`
---@param string string
---@return integer
function M.strwidth(string)
    return #string
end

---wrap `vim.fn.fnamemodify()`
---@param fname string
---@param mods string
---@return string
function M.fnamemodify(fname, mods)
    for mod in mods:gmatch(':(.)') do
        if mod == 'p' then
            fname = fs.abspath(fname)
            if M.isdirectory(fname) then
                fname = fs.joinpath(fname, '')
            end
        elseif mod == 'h' then
            fname = fs.dirname(fname)
        end
    end
    return fname
end

return M
