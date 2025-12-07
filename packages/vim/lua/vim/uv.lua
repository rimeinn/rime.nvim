---wrap `vim.uv`
---@module vim.uv
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
local _ok, luv = pcall(require, 'luv')
if _ok then
    return luv
end
local lfs = require "lfs"
local M = {}

---wrap `vim.uv.cwd()`
---@return string cwd
function M.cwd()
    return lfs.currentdir()
end

---wrap `vim.uv.fs_stat()`
---@param path string
---@return table opts
function M.fs_stat(path)
    local opts = lfs.attributes(path) or {}
    opts.type = opts.mode
    opts.mtime = {}
    if opts.modification then
        opts.mtime.sec = math.floor(opts.modification / 1000000000)
        opts.mtime.nsec = opts.modification % 1000000000
    end
    return opts
end

---wrap `vim.uv.os_uname()`
---@return table opts
function M.os_uname()
    local opts = {}
    local binary_format = package.cpath:match('([^.]+);?$')
    if binary_format == "dll" then
        opts.sysname = "windows"
    elseif binary_format == "so" then
        opts.sysname = "unix"
    elseif binary_format == "dylib" then
        opts.sysname = "macos"
    else
        opts.sysname = "unknown"
    end
    return opts
end

---wrap `vim.uv.getuid()`
---@return integer id
function M.getuid()
    local ok, mod = pcall(require, 'posix.unistd')
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

---wrap `vim.uv.realpath()`
---@return string?
function M.fs_realpath(...)
    local ok, mod = pcall(require, 'posix.stdlib')
    if ok then
        return mod.realpath(...)
    end
end

---wrap `vim.uv.rmdir()`
function M.fs_rmdir(...)
    lfs.rmdir(...)
end

---wrap `vim.uv.fs_unlink()`
function M.fs_unlink(...)
    lfs.rmdir(...)
end

---wrap `vim.uv.os_getenv()`
---@return string?
function M.os_getenv(...)
    return os.getenv(...)
end

---wrap `vim.uv.os_getenv()`
---@return string?
function M.os_homedir()
    return os.getenv("HOME") or os.getenv("USERPROFILE")
end

return M
