---abstract class.
---user/site_*_dir:
---  data
---  config
---  cache
---  state
---by default,
---  log: state/log
---  runtime: cache/tmp
---user_*_dir:
---  documents
---  downloads
---  pictures
---  videos
---  music
---  desktop
---@module platformdirs.platformsdirs
local fs = require 'platformdirs.fs'

local M = {
    PlatformDirs = {
        roaming = false,
        multipath = false,
        opinion = true,
        ensure_exists = false,
    }
}

---@param platformdirs table?
---@return table platformdirs
function M.PlatformDirs:new(platformdirs)
    platformdirs = platformdirs or {}
    setmetatable(platformdirs, {
        __index = self
    })
    return platformdirs
end

setmetatable(M.PlatformDirs, {
    __call = M.PlatformDirs.new
})

---@param ... string
---@return string
function M.PlatformDirs:append_app_name_and_version(...)
    local path = fs.joinpath(...)
    if self.appname then
        path = fs.joinpath(path, self.appname)
        if self.version then
            path = fs.joinpath(path, self.version)
        end
    end
    return path
end

---@param path string
function M.PlatformDirs:optionally_create_directory(path)
    if self.ensure_exists and not fs.isdirectory(path) then
        fs.mkdir(path)
    end
end

---@param directory string
---@return string
function M.PlatformDirs:first_item_as_path_if_multipath(directory)
    if self.multipath then
        return directory:match("([^:]+):?")
    end
    return directory
end

---@return string
function M.PlatformDirs.get_home()
    return "."
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
    return path
end

---@section user/site
---user/site directories

---@return string
function M.PlatformDirs:user_data_dir()
    local home = self.get_home()
    if self.appname then
        return fs.joinpath(home, "." .. self.appname)
    end
    return home
end

---@return string
function M.PlatformDirs:site_data_dir()
    return self:user_data_dir()
end

---@return string[]
function M.PlatformDirs:site_data_dirs()
    return { self:site_data_dir() }
end

---@return string
function M.PlatformDirs:user_config_dir()
    return self:user_data_dir()
end

---@return string
function M.PlatformDirs:site_config_dir()
    return self:user_config_dir()
end

---@return string[]
function M.PlatformDirs:site_config_dirs()
    return { self:site_config_dir() }
end

---@return string
function M.PlatformDirs:user_cache_dir()
    return self:user_data_dir()
end

---@return string
function M.PlatformDirs:site_cache_dir()
    return self:user_cache_dir()
end

---@return string
function M.PlatformDirs:user_state_dir()
    return self:user_cache_dir()
end

---@return string
function M.PlatformDirs:user_log_dir()
    local path = self:user_state_dir()
    if self.opinion then
        path = fs.joinpath(path, "log")
        self:optionally_create_directory(path)
    end
    return path
end

---@return string
function M.PlatformDirs:user_runtime_dir()
    local path = self:user_cache_dir()
    if self.opinion then
        path = fs.joinpath(path, "tmp")
        self:optionally_create_directory(path)
    end
    return path
end

---@return string
function M.PlatformDirs:site_runtime_dir()
    return self:user_runtime_dir()
end

---@section user
---user directories

---@return string
function M.PlatformDirs:user_documents_dir()
    return self.get_home()
end

---@return string
function M.PlatformDirs:user_downloads_dir()
    return self.get_home()
end

---@return string
function M.PlatformDirs:user_pictures_dir()
    return self.get_home()
end

---@return string
function M.PlatformDirs:user_videos_dir()
    return self.get_home()
end

---@return string
function M.PlatformDirs:user_music_dir()
    return self.get_home()
end

---@return string
function M.PlatformDirs:user_desktop_dir()
    return self.get_home()
end

return M
