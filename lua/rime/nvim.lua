---lazy load `rime.nvim.rime`
local Rime = require('rime.nvim.rime').Rime

local M = {}

function M.init()
    M.ime = M.ime or Rime(M.rime)
end

function M.toggle()
    M.init()
    return M.ime:_toggle()
end

function M.enable()
    M.init()
    return M.ime:_toggle(true)
end

function M.disable()
    M.init()
    return M.ime:_toggle(false)
end

---@param key string?
function M.callback(key)
    return function ()
        M.init()
        return M.ime:callback(key)
    end
end

return M
