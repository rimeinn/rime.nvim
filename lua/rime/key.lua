---Convert vim key name to rime key code and mask
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
local Key = require 'ime.key'.Key

local keys = require "rime.data.keys"
local modifiers = require "rime.data.modifiers"

local M = {
    Key = {}
}

---@param key table?
---@return table
function M.Key:new(key)
    key = key or {}
    key = Key(key, keys, modifiers)
    setmetatable(key, {
        __index = self
    })
    return key
end

setmetatable(M.Key, {
    __index = Key,
    __call = M.Key.new
})

return M
