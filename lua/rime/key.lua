---Convert vim key name to rime key code and mask
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
local cjson = require 'cjson'
local fs = require 'vim.fs'
local Key = require 'ime.key'.Key

local M = {
    vim_to_rime = {
        pageup = "Page_Up",
        pagedown = "Page_Down",
        esc = "Escape",
        bs = "BackSpace",
        del = "Delete",
    },
    Key = {
        aliases = {
            ["<c-^>"] = "<c-6>",
            ["<c-_>"] = "<c-->",
            ["<c-/>"] = "<c-->",
        },
        modifiers = {},
    }
}

for k, v in pairs(Key.aliases) do
    M.Key.aliases[k] = v
end

---get file path
---@param name string
---@return string
function M.get_path(name)
    return fs.joinpath(
        fs.dirname(debug.getinfo(1).source:match("@?(.*)")),
        "assets", "json", name .. '.json'
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

M.keys = M.decode "keys"
for i, v in ipairs(M.decode "modifiers") do
    if v == "Shift" then
        M.Key.modifiers.S = 2 ^ (i - 1)
    elseif v == "Control" then
        M.Key.modifiers.C = 2 ^ (i - 1)
    elseif v == "Alt" then
        M.Key.modifiers.A = 2 ^ (i - 1)
    end
end
M.Key.modifiers.M = M.Key.modifiers.A

---@param key table?
---@return table
function M.Key:new(key)
    key = key or {}
    key = Key(key)
    setmetatable(key, {
        __tostring = self.tostring,
        __index = self
    })
    return key
end

---create a Key from a vim name
---@param name string
---@return integer
function M.Key.convert(name)
    return M.keys[M.vim_to_rime[name] or (name:sub(1, 1):upper() .. name:sub(2):lower())]
end

setmetatable(M.Key, {
    __index = Key,
    __call = M.Key.new
})

return M
