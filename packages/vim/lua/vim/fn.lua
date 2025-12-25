---wrap `vim.fn`. `vim.fn` doesn't use `boolean` rather than `0 | 1`.
---@module vim.fn
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113 212
if vim and vim.fn then
    return vim.fn
end
local lfs = require "lfs"
local json = require "vim.json"
local fs = require 'vim.fs'
local uv = require 'vim.uv'
local M = {}

---wrap `vim.fn.json_decode()`
---@param string string
---@return table
function M.json_decode(string)
    return json.decode(string)
end

---wrap `vim.fn.json_encode()`
---@param expr table
---@return string
function M.json_encode(expr)
    return json.encode(expr)
end

---wrap `vim.fn.has()`
---@param feature string
---@return 0 | 1
function M.has(feature)
    local ret
    if feature == 'win32' then
        ret = uv.os_uname().sysname == "windows"
    elseif feature == 'nvim' then
        ret = true
    end
    return ret and 1 or 0
end

---wrap `vim.fn.getcwd()`
---@return string cwd
function M.getcwd()
    return lfs.currentdir()
end

---wrap `vim.fn.executable()`
---@param expr string
---@return 0 | 1
function M.executable(expr)
    local attr = lfs.attributes(expr)
    return attr and attr.mode ~= "directory" and attr.permissions:match 'x' and 1 or 0
end

---wrap `vim.fn.isdirectory()`
---@param dir string
---@return 0 | 1
function M.isdirectory(dir)
    local attr = lfs.attributes(dir)
    return attr and attr.mode == "directory" and 1 or 0
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
    if dir == "~" then
        dir = uv.os_homedir() or "/"
    elseif dir:match "^~/" then
        dir = dir:gsub("^~", uv.os_homedir() or "")
    end
    local path = dir
    for m in path:gmatch('%$[a-zA-Z_]+') do
        dir = dir:gsub('%' .. m, os.getenv(m:sub(2)) or '')
    end
    return dir
end

---wrap `vim.fn.getchar()`
---@return integer
function M.getchar()
    return io.read(1):byte()
end

---wrap `vim.fn.readfile()`
---@param fname string
---@return string[]
function M.readfile(fname)
    local f = io.open(fname)
    local lines = {}
    if f then
        for line in f:lines() do
            table.insert(lines, line)
        end
        f:close()
    end
    return lines
end

---wrap `vim.fn.substitute()`
---@param string string
---@param pat string
---@param sub string
---@param flags string
---@return string
function M.substitute(string, pat, sub, flags)
    local n
    if not flags:match 'g' then
        n = 1
    end
    string = string:gsub(pat, sub, n)
    return string
end

---wrap `vim.fn.did_filetype()`
---@return 0
function M.did_filetype()
    return 0
end

---wrap `vim.fn.strwidth()`
---@param string string
---@return integer
function M.strwidth(string)
    local i = 1
    local width = 0
    while i <= # string do
        local nr = string:byte(i)
        -- CJKV character
        local w = nr > 225 and nr < 240 and 2 or 1
        width = width + w
        -- utf-8
        local offset = nr > 240 and 4 or nr > 225 and 3 or nr > 192 and 2 or 1
        i = i + offset
    end
    return #string
end

---wrap `vim.fn.fnameescape()`
---@param string string
---@return string
function M.fnameescape(string)
    string = string:gsub("[+| %%]", "\\%1")
    return string
end

---wrap `vim.fn.fnamemodify()`
---@param fname string
---@param mods string
---@return string
function M.fnamemodify(fname, mods)
    for mod in mods:gmatch(':(.)') do
        if mod == 'p' then
            fname = fs.abspath(fname)
            if M.isdirectory(fname) == 1 then
                fname = fs.joinpath(fname, '')
            end
        elseif mod == 'h' then
            fname = fs.dirname(fname)
        elseif mod == 't' then
            fname = fs.basename(fname)
        elseif mod == 'e' then
            fname = fname:match('%.[^./]+$') or ''
        elseif mod == 'r' then
            fname = fname:match('(.*)%.[^./]+$') or fname
        end
    end
    return fname
end

return M
