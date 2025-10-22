---Wrap many hooks in a hook
local Airline = require "ime.nvim.hooks.airline".Airline
local Cursor = require "ime.nvim.hooks.cursor".Cursor

local M = {
    ChainedHook = {}
}

---@param hook table?
---@return table hooks
function M.ChainedHook:new(hook)
    hook = hook or { Cursor(), Airline() }
    setmetatable(hook, {
        __index = self
    })
    return hook
end

setmetatable(M.ChainedHook, {
    __call = M.ChainedHook.new
})


---update IM signatures
function M.ChainedHook:update(...)
    for _, hook in ipairs(self) do
        hook:update(...)
    end
end

return M
