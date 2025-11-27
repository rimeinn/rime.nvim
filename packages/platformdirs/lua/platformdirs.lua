---select a `PlatformDirs` according to OS
---@module platformdirs
local uv = require "vi.uv"
local PlatformDirs = require "platformdirs.platforms".PlatformDirs
local Unix = require "platformdirs.platforms.unix".PlatformDirs
local Android = require "platformdirs.platforms.android".PlatformDirs
local MacOS = require "platformdirs.platforms.macos".PlatformDirs
local Windows = require "platformdirs.platforms.windows".PlatformDirs

local M = {}

---@param ... any
---@return table
function M.PlatformDirs(...)
    if os.getenv("ANDROID_DATA") == "/data" and os.getenv("ANDROID_ROOT") == "/system" then
        if os.getenv("SHELL") or os.getenv("PREFIX") then
            return Unix(...)
        end
        return Android(...)
    end
    local sysname = uv.os_uname().sysname:lower()
    if sysname:find('linux') or sysname:find('unix') then
        return Unix(...)
    elseif sysname:find('windows') or sysname:find('mingw') then
        return Windows(...)
    elseif sysname:find('macos') then
        return MacOS(...)
    end
    return PlatformDirs(...)
end

return M
