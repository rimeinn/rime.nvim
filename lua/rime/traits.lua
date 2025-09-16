---wrap `rime.Traits()`
local fs = require 'rime.fs'
local Traits = require 'rime'.Traits

local shared_data_dir = ""
---@diagnostic disable: undefined-global
-- luacheck: ignore 113
local prefix = os.getenv("PREFIX") or
    fs.dirname(fs.dirname(os.getenv("SHELL") or "/bin/sh"))
for _, dir in ipairs {
    -- /usr merge: /usr/bin/sh -> /usr/share/rime-data
    fs.joinpath(prefix, "share/rime-data"),
    -- non /usr merge: /bin/sh -> /usr/share/rime-data
    fs.joinpath(prefix, "usr/share/rime-data"),
    "/run/current-system/sw/share/rime-data",
    "/sdcard/rime-data"
} do
    if fs.isdirectory(dir) then
        shared_data_dir = dir
    end
end
local user_data_dir = ""
local home = os.getenv("HOME") or "."
for _, dir in ipairs {
    home .. "/.config/ibus/rime",
    home .. "/.local/share/fcitx5/rime",
    home .. "/.config/fcitx/rime",
    home .. "/sdcard/rime"
} do
    if fs.isdirectory(dir) then
        user_data_dir = dir
    end
end

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
        shared_data_dir = shared_data_dir,                  -- directory store shared data
        user_data_dir = user_data_dir,                      -- directory store user data
        log_dir = fs.joinpath(fs.stdpath("state"), "rime"), -- Directory of log files.
        -- Value is passed to Glog library using FLAGS_log_dir variable.
        -- NULL means temporary directory, and "" means only writing to stderr.
        app_name = "rime.nvim-rime", -- Pass a C-string constant in the format "rime.x"
        -- where 'x' is the name of your application.
        -- Add prefix "rime." to ensure old log files are automatically cleaned.
        min_log_level = 'FATAL',              -- Minimal level of logged messages.
        distribution_name = "Rime",           -- distribution name
        distribution_code_name = "nvim-rime", -- distribution code name
        distribution_version = "0.0.1",       -- distribution version
    },
}

---Wrap `rime.Traits`
---@param traits table?
---@return table
function M.Traits:new(traits)
    traits = traits or {}
    setmetatable(traits, {
        __index = self
    })
    fs.mkdir(traits.log_dir)
    return Traits(traits.shared_data_dir, traits.user_data_dir, traits.log_dir, traits.distribution_name,
        traits.distribution_code_name, traits.distribution_version, traits.app_name, M.log_level[traits.min_log_level])
end

setmetatable(M.Traits, {
    __call = M.Traits.new
})

return M
