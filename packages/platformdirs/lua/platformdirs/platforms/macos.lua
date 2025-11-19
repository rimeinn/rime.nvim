---macOS
---@module platformdirs.platformdirs.macos
local PlatformDirs = require 'platformdirs.platformdirs'.PlatformDirs

local M = {
    PlatformDirs = {
    }
}

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
    return os.getenv "HOME" or "/"
end

---user/site directories
---@section user/site

---`/Users/$USER/Library/Application Support/$app/$version`
---@return string
function M.PlatformDirs:user_data_dir()
    return self:append_app_name_and_version(self:expand_user("~/Library/Application Support"))
end

---`/Library/Application Support/$app/$version`
---@return string
function M.PlatformDirs:site_data_dir()
    return self:append_app_name_and_version("/Library/Application Support")
end

---`/Users/$USER/Library/Caches/$app/$version`
---@return string
function M.PlatformDirs:user_cache_dir()
    return self:append_app_name_and_version(self:expand_user("~/Library/Caches"))
end

---`/Library/Caches/$app/$version`
---@return string
function M.PlatformDirs:site_cache_dir()
    return self:append_app_name_and_version("/Library/Caches")
end

---`/Users/$USER/Library/Logs/$app/$version`
---@return string
function M.PlatformDirs:user_log_dir()
    return self:append_app_name_and_version(self:expand_user("~/Library/Logs"))
end

---`/Users/$USER/Library/TemporaryItems/$app/$version`
---@return string
function M.PlatformDirs:user_runtime_dir()
    return self:append_app_name_and_version(self:expand_user("~/Library/Caches/TemporaryItems"))
end

---user directories
---@section user

---`/Users/$USER/Documents`
---@return string
function M.PlatformDirs:user_documents_dir()
    return self:expand_user("~/Documents")
end

---`/Users/$USER/Downloads`
---@return string
function M.PlatformDirs:user_downloads_dir()
    return self:expand_user("~/Downloads")
end

---`/Users/$USER/Pictures`
---@return string
function M.PlatformDirs:user_pictures_dir()
    return self:expand_user("~/Pictures")
end

---`/Users/$USER/Movies`
---@return string
function M.PlatformDirs:user_videos_dir()
    return self:expand_user("~/Movies")
end

---`/Users/$USER/Music`
---@return string
function M.PlatformDirs:user_music_dir()
    return self:expand_user("~/Music")
end

---`/Users/$USER/Desktop`
---@return string
function M.PlatformDirs:user_desktop_dir()
    return self:expand_user("~/Desktop")
end
