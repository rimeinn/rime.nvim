---select a `PlatformDirs` according to OS
---@module platformdirs
local PlatformDirs = require "platformdirs.platforms".PlatformDirs
local Unix = require "platformdirs.platforms.unix".PlatformDirs
local Android = require "platformdirs.platforms.android".PlatformDirs
local MacOS = require "platformdirs.platforms.macos".PlatformDirs
local Windows = require "platformdirs.platforms.windows".PlatformDirs

local M = {}

---refer <https://github.com/wakatime/prompt-style.lua/blob/0.0.11/lua/prompt/style.lua#L123>
---@param ... any
---@return table
function M.PlatformDirs(...)
    if os.getenv("ANDROID_DATA") == "/data" and os.getenv("ANDROID_ROOT") == "/system" then
        if os.getenv("SHELL") or os.getenv("PREFIX") then
            return Unix(...)
        end
        return Android(...)
    end
    local binary_format = package.cpath:match('([^.]+)$'):gsub(";$", "")
    if binary_format == "so" then
        return Unix(...)
    elseif binary_format == "dll" then
        return Windows(...)
    elseif binary_format == "dylib" then
        return MacOS(...)
    end
    return PlatformDirs(...)
end

return M
