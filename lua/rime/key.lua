---Convert vim key name to rime key code and mask
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
local cjson = require 'cjson'
local fs = require 'vim.fs'
local Key = require 'ime.key'.Key

local M = {
    Key = {}
}

---get file path
---@param name string
---@return string
function M.get_path(name)
    return fs.joinpath(
        fs.dirname(debug.getinfo(1).source:match("@?(.*)")),
        "assets", "json", name
    )
end

---get file content
---@param path string
---@return string
function M.read(path)
    local f = io.open(path)
    local text = "{}"
    if f then
        text = f:read "*a"
        f:close()
    end
    return text
end

---decode a json
---@param name string
---@return table
function M.decode(name)
    return cjson.decode(M.read(M.get_path(name)))
end

local keys = M.decode "keys"
local modifiers = M.decode "modifiers"

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
