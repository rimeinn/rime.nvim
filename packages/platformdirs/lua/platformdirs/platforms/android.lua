---android miss a library like <https://pypi.org/project/jnius>
---@module platformdirs.platforms.android
local PlatformDirs = require 'platformdirs.platforms'.PlatformDirs

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

---`/data/user/0/com.app.vendor/files/$app/$version`
---@return string
function M.PlatformDirs:user_data_dir()
    return self:append_app_name_and_version(M.android_folder(), "files")
end

---`/data/user/0/com.app.vendor/shared_prefs/$app/$version`
---@return string
function M.PlatformDirs:user_config_dir()
    return self:append_app_name_and_version(M.android_folder(), "shared_prefs")
end

---`/data/user/0/com.app.vendor/cache/$app/$version`
---@return string
function M.PlatformDirs:user_cache_dir()
    return self:append_app_name_and_version(M.android_folder(), "cache")
end

---user directories
---@section user

---`/storage/emulated/0/Documents`
---@return string
function M.PlatformDirs:user_documents_dir()
    return self:expand_user("~/Documents")
end

---`/storage/emulated/0/Download`
---**not `Downloads`**
---@return string
function M.PlatformDirs:user_downloads_dir()
    return self:expand_user("~/Download")
end

---`/storage/emulated/0/Pictures`
---note screenshot is `/storage/emulated/0/DCIM/Screenshots`
---@return string
function M.PlatformDirs:user_pictures_dir()
    return self:expand_user("~/Pictures")
end

---`/storage/emulated/0/DCIM/Camera`
---@return string
function M.PlatformDirs:user_videos_dir()
    return self:expand_user("~/DCIM/Camera")
end

---`/storage/emulated/0/Music`
---@return string
function M.PlatformDirs:user_music_dir()
    return self:expand_user("~/Music")
end

---`/storage/emulated/0/Desktop`
---@return string
function M.PlatformDirs:user_desktop_dir()
    return self:expand_user("~/Desktop")
end

return M
