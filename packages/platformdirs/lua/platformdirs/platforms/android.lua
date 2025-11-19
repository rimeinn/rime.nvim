---android miss a library like <https://pypi.org/project/jnius>
---@module platformdirs.platformdirs.android
local PlatformDirs = require 'platformdirs.platformdirs'.PlatformDirs

local M = {
    PlatformDirs = {
        home = os.getenv "HOME" or "."
    }
}

---@return string
function M.android_folder()
    for path in package.path:gmatch("([^:]+):?") do
        if path:match("/data/(data|user/%d+)/(.+)/files") then
            return path:match("(.*)/files")
        end
    end
    return "/data/data/com.termux"
end

---@param platformdirs table?
---@return table platformdirs
function M.PlatformDirs:new(platformdirs)
    platformdirs = platformdirs or {}
    platformdirs = PlatformDirs(platformdirs)
    setmetatable(platformdirs, {
        __index = self
    })
    return platformdirs
end

setmetatable(M.PlatformDirs, {
    __index = PlatformDirs,
    __call = M.PlatformDirs.new
})

---@return string
function M.PlatformDirs.get_home()
    return "/storage/emulated/0"
end

---user/site directories
---@section user/site

---@return string
function M.PlatformDirs:user_data_dir()
    return self:append_app_name_and_version(M.android_folder(), "files")
end

---@return string
function M.PlatformDirs:user_config_dir()
    return self:append_app_name_and_version(M.android_folder(), "shared_prefs")
end

---@return string
function M.PlatformDirs:user_cache_dir()
    return self:append_app_name_and_version(M.android_folder(), "cache")
end

---user directories
---@section user

---@return string
function M.PlatformDirs:user_documents_dir()
    return self:expand_user("~/Documents")
end

---not Downloads
---@return string
function M.PlatformDirs:user_downloads_dir()
    return self:expand_user("~/Download")
end

---@return string
function M.PlatformDirs:user_pictures_dir()
    return self:expand_user("~/Pictures")
end

---@return string
function M.PlatformDirs:user_videos_dir()
    return self:expand_user("~/DCIM/Camera")
end

---@return string
function M.PlatformDirs:user_music_dir()
    return self:expand_user("~/Music")
end

---@return string
function M.PlatformDirs:user_desktop_dir()
    return self:expand_user("~/Desktop")
end
