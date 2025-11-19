---macOS
---@module platformdirs.macos
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

---@section user/site
---user/site directories

---@return string
function M.PlatformDirs:user_data_dir()
    return self:append_app_name_and_version(self:expand_user("~/Library/Application Support"))
end

---@return string
function M.PlatformDirs:site_data_dir()
    return self:append_app_name_and_version("/Library/Application Support")
end

---@return string
function M.PlatformDirs:user_cache_dir()
    return self:append_app_name_and_version(self:expand_user("~/Library/Caches"))
end

---@return string
function M.PlatformDirs:site_cache_dir()
    return self:append_app_name_and_version("/Library/Caches")
end

---@return string
function M.PlatformDirs:user_log_dir()
    return self:append_app_name_and_version(self:expand_user("~/Library/Logs"))
end

---@return string
function M.PlatformDirs:user_runtime_dir()
    return self:append_app_name_and_version(self:expand_user("~/Library/Caches/TemporaryItems"))
end

---@section user
---user directories

---@return string
function M.PlatformDirs:user_documents_dir()
    return self:expand_user("~/Documents")
end

---@return string
function M.PlatformDirs:user_downloads_dir()
    return self:expand_user("~/Downloads")
end

---@return string
function M.PlatformDirs:user_pictures_dir()
    return self:expand_user("~/Pictures")
end

---@return string
function M.PlatformDirs:user_videos_dir()
    return self:expand_user("~/Movies")
end

---@return string
function M.PlatformDirs:user_music_dir()
    return self:expand_user("~/Music")
end

---@return string
function M.PlatformDirs:user_desktop_dir()
    return self:expand_user("~/Desktop")
end
