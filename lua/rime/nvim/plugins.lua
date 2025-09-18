---Wrap all plugins
local Airline = require "rime.nvim.plugins.airline".Airline
local Cursor = require "rime.nvim.plugins.cursor".Cursor

local M = {
    Plugins = {}
}

---@param plugins table?
---@return table plugins
function M.Plugins:new(plugins)
    plugins = plugins or {
        plugins = {
            cursor = Cursor(),
            airline = Airline(),
        }
    }
    setmetatable(plugins, {
        __index = self
    })
    return plugins
end

setmetatable(M.Plugins, {
    __call = M.Plugins.new
})


---update IM signatures
function M.Plugins:update(...)
    for _, plugin in pairs(self.plugins) do
        plugin:update(...)
    end
end

return M
