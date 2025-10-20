---A fake IME to provide callbacks
---`self:enable_cb()`, `self:disable_cb()`, `self.toggle_cb()` and ``
---for neovim.
---any subclass must define `self:exe()`
local M = {
    IME = {
        is_enabled = false
    }
}

---@param ime table?
---@return table ime
function M.IME:new(ime)
    ime = ime or {}
    setmetatable(ime, {
        __index = self
    })
    return ime
end

setmetatable(M.IME, {
    __call = M.IME.new
})

---execute IME. **abstract method**
---@param ... any
function M.IME:exe(...)
    print(self, ...)
end

---get IME enabled flag
---@return boolean
function M.IME:get_enabled()
    return self.is_enabled
end

---set IME enabled flag
---@param is_enabled boolean
function M.IME:set_enabled(is_enabled)
    self.is_enabled = is_enabled
end

---Wrappers
---@section wrappers

---wrap `self:exe()`
---@param ... any
---@see exe
function M.IME:call(...)
    if not self:get_enabled() then
        return
    end
    self:exe(...)
end

---toggle IME.
---@see enable
---@see disable
function M.IME:toggle()
    self:set_enabled(not self:get_enabled())
end

---enable IME.
---@see toggle
function M.IME:enable()
    if self:get_enabled() == false then
        self:set_enabled(true)
    end
end

---disable IME.
---@see toggle
function M.IME:disable()
    if self:get_enabled() then
        self:set_enabled(false)
    end
end

---Callbacks
---@section callbacks

---get a callback for `self:toggle()`
---@see toggle
function M.IME:toggle_cb()
    return function()
        self:toggle()
    end
end

---get a callback for `self:enable()`
---@see enable
function M.IME:enable_cb()
    return function()
        self:enable()
    end
end

---get a callback for `self:disable()`
---@see disable
function M.IME:disable_cb()
    return function()
        self:disable()
    end
end

---get a callback for `self:call()`
---@param key any
---@see call
function M.IME:callback(key)
    return function()
        return self:call(key)
    end
end

return M
