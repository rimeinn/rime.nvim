---abstract class.
---@module platformdirs.platforms
local fn = require 'vim.fn'
local fs = require 'vim.fs'

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
    if self.ensure_exists and not fn.isdirectory(path) then
        fn.mkdir(path)
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

---user/site directories
---@section user/site

---store user-specific data files.
---`~/.$app`
---@return string
function M.PlatformDirs:user_data_dir()
    local home = self.get_home()
    if self.appname then
        return fs.joinpath(home, "." .. self.appname)
    end
    return home
end

---the preference-ordered set of base directories to search for data files.
---`user_data_dir`
---@return string
function M.PlatformDirs:site_data_dir()
    return self:user_data_dir()
end

---@return string[]
function M.PlatformDirs:site_data_dirs()
    return { self:site_data_dir() }
end

---store user-specific configuration files.
---`user_data_dir`
---@return string
function M.PlatformDirs:user_config_dir()
    return self:user_data_dir()
end

---the preference-ordered set of base directories to search for configuration files.
---`user_config_dir`
---@return string
function M.PlatformDirs:site_config_dir()
    return self:user_config_dir()
end

---@return string[]
function M.PlatformDirs:site_config_dirs()
    return { self:site_config_dir() }
end

---store user-specific non-essential files.
---`user_data_dir`
---@return string
function M.PlatformDirs:user_cache_dir()
    return self:user_data_dir()
end

---`user_cache_dir`
---@return string
function M.PlatformDirs:site_cache_dir()
    return self:user_cache_dir()
end

---store user-specific state files.
---`user_cache_dir`
---@return string
function M.PlatformDirs:user_state_dir()
    return self:user_cache_dir()
end

---`user_state_dir/log`
---@return string
function M.PlatformDirs:user_log_dir()
    local path = self:user_state_dir()
    if self.opinion then
        path = fs.joinpath(path, "log")
        self:optionally_create_directory(path)
    end
    return path
end

---store user-specific non-essential runtime files and other file objects
---such as sockets, named pipes, ...
---`user_cache_dir/tmp`
---@return string
function M.PlatformDirs:user_runtime_dir()
    local path = self:user_cache_dir()
    if self.opinion then
        path = fs.joinpath(path, "tmp")
        self:optionally_create_directory(path)
    end
    return path
end

---`user_runtime_dir`
---@return string
function M.PlatformDirs:site_runtime_dir()
    return self:user_runtime_dir()
end

---user directories
---@section user

---`~`
---@return string
function M.PlatformDirs:user_documents_dir()
    return self.get_home()
end

---`~`
---@return string
function M.PlatformDirs:user_downloads_dir()
    return self.get_home()
end

---`~`
---@return string
function M.PlatformDirs:user_pictures_dir()
    return self.get_home()
end

---`~`
---@return string
function M.PlatformDirs:user_videos_dir()
    return self.get_home()
end

---`~`
---@return string
function M.PlatformDirs:user_music_dir()
    return self.get_home()
end

---`~`
---@return string
function M.PlatformDirs:user_desktop_dir()
    return self.get_home()
end

return M
