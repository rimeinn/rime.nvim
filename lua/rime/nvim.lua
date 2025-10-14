---lazy load `rime.nvim.rime`
local Rime = require('rime.nvim.rime').Rime

local M = {}

---init if required
function M.init()
    M.ime = M.ime or Rime(M.rime)
end

---wrap `self.ime:toggle()`
---@see ime.toggle
function M.toggle()
    M.init()
    return M.ime:toggle()
end

---wrap `self.ime:enable()`
---@see ime.enable
function M.enable()
    M.init()
    return M.ime:enable()
end

---wrap `self.ime:disable()`
---@see ime.disable
function M.disable()
    M.init()
    return M.ime:disable()
end

---wrap `self.ime:callback()`
---@param key string?
---@see ime.callback
function M.callback(key)
    return function ()
        M.init()
        return M.ime:callback(key)
    end
end

return M
