---wrap `rime.Traits()`
---@module rime.traits
local fn = require 'vim.fn'
local PlatformDirs = require 'platformdirs'.PlatformDirs

local Traits = require 'rime'.Traits
local _, distribution_version = pcall(require, 'rime.version')

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
        user_data_dir = "/sdcard/rime", -- directory store user data
        -- Value is passed to Glog library using FLAGS_log_dir variable.
        -- NULL means temporary directory, and "" means only writing to stderr.
        log_dir = PlatformDirs {
            appname = "nvim", version = "rime"
        }:user_state_dir(), -- Directory of log files.
        app_name = "rime.nvim-rime", -- Pass a C-string constant in the format "rime.x"
        -- where 'x' is the name of your application.
        -- Add prefix "rime." to ensure old log files are automatically cleaned.
        min_log_level = 'FATAL', -- Minimal level of logged messages.
        distribution_name = "Rime", -- distribution name
        distribution_code_name = "nvim-rime", -- distribution code name
        distribution_version = distribution_version, -- distribution version
    },
}

for _, dir in ipairs(PlatformDirs { appname = "rime-data", multipath = true }:site_data_dirs()) do
    if fn.isdirectory(dir) then
        M.Traits.shared_data_dir = dir
    end
end
for _, dir in ipairs {
    PlatformDirs { appname = "ibus", version = "rime" }:user_config_dir(),
    PlatformDirs { appname = "fcitx5", version = "rime" }:user_data_dir(),
    PlatformDirs { appname = "fcitx", version = "rime" }:user_config_dir(),
} do
    if fn.isdirectory(dir) then
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
    traits.distribution_version = traits.distribution_version:match("%d[%d.]+%d") or "0.0.1"
    traits.distribution_version = traits.distribution_version:gsub("%.+", ".")
    fn.mkdir(traits.log_dir, 'p')
    return Traits(traits.shared_data_dir, traits.user_data_dir, traits.log_dir, traits.distribution_name,
        traits.distribution_code_name, traits.distribution_version, traits.app_name,
        M.log_level[traits.min_log_level])
end

setmetatable(M.Traits, {
    __call = M.Traits.new
})

return M
