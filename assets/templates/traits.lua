---wrap `rime.Traits()`
local fs = require 'rime.fs'
local Traits = require 'rime'.Traits

local M = {
    --- Value is passed to Glog library using FLAGS_minloglevel variable.
    log_level = {
        INFO = 0,
        WARNING = 1,
        ERROR = 2,
        FATAL = 3,
    },
    --- config for rime traits
    Traits = {
        shared_data_dir = "/sdcard/rime-data", -- directory store shared data
        user_data_dir = "/sdcard/rime",        -- directory store user data
        -- Value is passed to Glog library using FLAGS_log_dir variable.
        -- NULL means temporary directory, and "" means only writing to stderr.
        log_dir = fs.joinpath(fs.stdpath("state"), "rime"), -- Directory of log files.
        app_name = "rime.nvim-rime",                        -- Pass a C-string constant in the format "rime.x"
        -- where 'x' is the name of your application.
        -- Add prefix "rime." to ensure old log files are automatically cleaned.
        min_log_level = 'FATAL',              -- Minimal level of logged messages.
        distribution_name = "Rime",           -- distribution name
        distribution_code_name = "nvim-rime", -- distribution code name
        distribution_version = "${GIT_TAG}",  -- distribution version
    },
}

local xdg_data_dirs = os.getenv "XDG_DATA_DIRS" or "/usr/share:/usr/local/share"
local home = os.getenv("HOME") or "."
local xdg_config_home = os.getenv "XDG_CONFIG_HOME" or fs.joinpath(home, ".config")
local xdg_data_home = os.getenv "XDG_DATA_HOME" or fs.joinpath(home, ".local", "share")

for dir in xdg_data_dirs:gmatch("([^:]+):?") do
    dir = fs.joinpath(dir, "rime-data")
    if fs.isdirectory(dir) then
        M.Traits.shared_data_dir = dir
    end
end
for _, dir in ipairs {
    fs.joinpath(xdg_config_home, "ibus"),
    fs.joinpath(xdg_data_home, "fcitx5"),
    fs.joinpath(xdg_config_home, "fcitx")
} do
    dir = fs.joinpath(dir, "rime")
    if fs.isdirectory(dir) then
        M.Traits.user_data_dir = dir
    end
end

---Wrap `rime.Traits`
---@param traits table?
---@return table
function M.Traits:new(traits)
    traits = traits or {}
    setmetatable(traits, {
        __index = self
    })
    if traits.version:match "%$" or traits.version == "none" then
        traits.version = "0.0.1"
    end
    fs.mkdir(traits.log_dir)
    return Traits(traits.shared_data_dir, traits.user_data_dir, traits.log_dir, traits.distribution_name,
        traits.distribution_code_name, traits.distribution_version, traits.app_name,
        M.log_level[traits.min_log_level])
end

setmetatable(M.Traits, {
    __call = M.Traits.new
})

return M
