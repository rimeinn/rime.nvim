---respect
---[XDG base directories](https://specifications.freedesktop.org/basedir-spec/latest/)
---and
---[XDG user directories](https://www.freedesktop.org/wiki/Software/xdg-user-dirs/)
---@module platformdirs.platforms.unix
local fs = require 'vim.fs'
local uv = require 'vim.uv'
local PlatformDirs = require 'platformdirs.platforms'.PlatformDirs

local M = {
    PlatformDirs = {
    }
}

---@param env string
---@param default string
---@return string
function M.getenv(env, default)
    local path = os.getenv(env)
    if path == nil or path == "" then
        path = default
    end
    return path
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
    return os.getenv "HOME" or "/"
end

---user/site directories
---@section user/site

---`/home/$USER/.local/share/$app/$version`
---@return string
function M.PlatformDirs:user_data_dir()
    local path = M.getenv("XDG_DATA_HOME", self:expand_user("~/.local/share"))
    return self:append_app_name_and_version(path)
end

---@return string[]
function M.PlatformDirs:site_data_dirs()
    local path = M.getenv("XDG_DATA_DIRS", "/usr/share:/usr/local/share")
    local paths = {}
    for p in path:gmatch("([^:]+):?") do
        table.insert(paths, self:append_app_name_and_version(p))
    end
    return paths
end

---`/usr/share/$app/$version:/usr/local/share/$app/$version`
---@return string
function M.PlatformDirs:site_data_dir()
    local paths = self:site_data_dirs()
    if not self.multipath then
        return paths[1]
    end
    return table.concat(paths, ':')
end

---`/home/$USER/.config/$app/$version`
---@return string
function M.PlatformDirs:user_config_dir()
    local path = M.getenv("XDG_CONFIG_HOME", self:expand_user("~/.config"))
    return self:append_app_name_and_version(path)
end

---@return string[]
function M.PlatformDirs:site_config_dirs()
    local path = M.getenv("XDG_CONFIG_DIRS", "/etc/xdg")
    local paths = {}
    for p in path:gmatch("([^:]+):?") do
        table.insert(paths, self:append_app_name_and_version(p))
    end
    return paths
end

---`/etc/xdg/$app/$version`
---@return string
function M.PlatformDirs:site_config_dir()
    local paths = self:site_config_dirs()
    if not self.multipath then
        return paths[1]
    end
    return table.concat(paths, ':')
end

---`/home/$USER/.cache/$app/$version`
---@return string
function M.PlatformDirs:user_cache_dir()
    local path = M.getenv("XDG_CACHE_HOME", self:expand_user("~/.cache"))
    return self:append_app_name_and_version(path)
end

---`/var/cache/$app/$version`
---@return string
function M.PlatformDirs:site_cache_dir()
    return self:append_app_name_and_version("/var/cache")
end

---`/home/$USER/.local/state/$app/$version`
---@return string
function M.PlatformDirs:user_state_dir()
    local path = M.getenv("XDG_STATE_HOME", self:expand_user("~/.local/state"))
    return self:append_app_name_and_version(path)
end

---Linux: `/run/user/1000/$app/$version`
---BSD: `/var/run/user/1000/$app/$version`
---fallback: `/tmp/runtime-1000/$app/$version`
---@return string
function M.PlatformDirs:user_runtime_dir()
    local id = uv.getuid()
    local path = fs.joinpath("/run/user", id)
    if not fs.isdirectory(path) then
        path = fs.joinpath("/var/run/user", id)
        if not fs.isdirectory(path) then
            path = fs.joinpath("/tmp", "runtime-" .. id)
        end
    end
    path = M.getenv("XDG_RUNTIME_DIR", path)
    return self:append_app_name_and_version(path)
end

---Linux: `/run/$app/$version`
---BSD: `/var/run/$app/$version`
---@return string
function M.PlatformDirs:site_runtime_dir()
    local path = "/run"
    if not fs.isdirectory(path) then
        path = fs.joinpath("/var/run")
    end
    path = M.getenv("XDG_RUNTIME_DIR", path)
    return self:append_app_name_and_version(path)
end

---user directories
---@section user

---`/home/$USER/Documents`
---@return string
function M.PlatformDirs:user_documents_dir()
    return M.getenv("XDG_DOCUMENTS_DIR", self:expand_user("~/Documents"))
end

---`/home/$USER/Downloads`
---@return string
function M.PlatformDirs:user_downloads_dir()
    return M.getenv("XDG_DOWNLOAD_DIR", self:expand_user("~/Downloads"))
end

---`/home/$USER/Pictures`
---@return string
function M.PlatformDirs:user_pictures_dir()
    return M.getenv("XDG_PICTURES_DIR", self:expand_user("~/Pictures"))
end

---`/home/$USER/Videos`
---@return string
function M.PlatformDirs:user_videos_dir()
    return M.getenv("XDG_VIDEOS_DIR", self:expand_user("~/Videos"))
end

---`/home/$USER/Music`
---@return string
function M.PlatformDirs:user_music_dir()
    return M.getenv("XDG_MUSIC_DIR", self:expand_user("~/Music"))
end

---`/home/$USER/Desktop`
---@return string
function M.PlatformDirs:user_desktop_dir()
    return M.getenv("XDG_DESKTOP_DIR", self:expand_user("~/Desktop"))
end

return M
