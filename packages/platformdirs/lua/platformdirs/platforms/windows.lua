---win32 miss a library like ctypes, only luajit has `require'ffi'`
---@module platformdirs.platformdirs.windows
local fs = require 'platformdirs.fs'

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
    return os.getenv "USERPROFILE" or "/"
end

---@param path string
---@return string
function M.PlatformDirs.normpath(path)
    path = path:gsub("/", "\\")
    return path
end

---@param path string
---@return string
function M.PlatformDirs:expand_user(path)
    if path == "~" then
        return self.get_home()
    end
    if path:sub(1, 2) == "~/" then
        path = fs.joinpath(self.get_home(), path:sub(3))
    end
    return self.normpath(path)
end

---@param base string
---@param ... string
---@return string
function M.PlatformDirs:append_app_name_and_version(base, ...)
    local path = base
    if self.appname then
        if self.appauthor then
            path = fs.joinpath(path, self.appauthor)
        end
        path = fs.joinpath(path, self.appname, ...)
        if self.version then
            path = fs.joinpath(path, self.version)
        end
    end
    return self.normpath(path)
end

---user/site directories
---@section user/site

---`C:\Users\$USER\AppData\Local\$author\$app\$version`
---@return string
function M.PlatformDirs:user_data_dir()
    return self:append_app_name_and_version(self:expand_user(self.roaming and "~/AppData/Roaming" or "~/AppData/Local"))
end

---`C:\ProgramData\$author\$app\$version`
---@return string
function M.PlatformDirs:site_data_dir()
    return self:append_app_name_and_version("C:\\ProgramData")
end

---`C:\Users\$USER\AppData\Local\$author\$app\Caches\$version`
---@return string
function M.PlatformDirs:user_cache_dir()
    return self:append_app_name_and_version(self:expand_user("~/AppData/Local"), "Caches")
end

---`C:\ProgramData\$author\$app\Cache\$version`
---@return string
function M.PlatformDirs:site_cache_dir()
    return self:append_app_name_and_version("C:\\ProgramData", "Cache")
end

---`C:\Users\$USER\AppData\Local\$author\$app\$version\Logs`
---@return string
function M.PlatformDirs:user_log_dir()
    local path = self:user_state_dir()
    if self.opinion then
        path = fs.joinpath(path, "Logs")
        path = self.norm(path)
        self:optionally_create_directory(path)
    end
    return path
end

---`C:\Users\$USER\AppData\Local\Temp\$author\$app\$version`
---@return string
function M.PlatformDirs:user_runtime_dir()
    return self:append_app_name_and_version(self:expand_user("~/AppData/Local/Temp"))
end

---user directories
---@section user

---`C:\Users\$USER\Documents`
---@return string
function M.PlatformDirs:user_documents_dir()
    return self:expand_user("~/Documents")
end

---`C:\Users\$USER\Downloads`
---@return string
function M.PlatformDirs:user_downloads_dir()
    return self:expand_user("~/Downloads")
end

---`C:\Users\$USER\Pictures`
---@return string
function M.PlatformDirs:user_pictures_dir()
    return self:expand_user("~/Pictures")
end

---`C:\Users\$USER\Videos`
---@return string
function M.PlatformDirs:user_videos_dir()
    return self:expand_user("~/Videos")
end

---`C:\Users\$USER\Music`
---@return string
function M.PlatformDirs:user_music_dir()
    return self:expand_user("~/Music")
end

---`C:\Users\$USER\Desktop`
---@return string
function M.PlatformDirs:user_desktop_dir()
    return self:expand_user("~/Desktop")
end
