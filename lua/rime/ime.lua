---A fake IME to provide callbacks
---`self:enable_cb()`, `self:disable_cb()`, `self.toggle_cb()` and ``
---for neovim.
---any subclass must define `self:switch()` and `self:exe()`
local M = {
    IME = {
        rime_is_enabled = false
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

---enable/disable IME. **abstract method**
---@param is_enabled boolean
function M.IME:switch(is_enabled)
    print(self.rime_is_enabled and is_enabled)
end

---set/get IME enabled flag
---@param is_enabled boolean?
function M.IME:is_enabled(is_enabled)
    if is_enabled == nil then
        return self.rime_is_enabled
    end
    self.rime_is_enabled = is_enabled
    return self.rime_is_enabled
end

---Wrappers
---@section wrappers

---wrap `self:exe()`
---@param ... any
---@see exe
function M.IME:call(...)
    if not self:is_enabled() then
        return
    end
    self:exe(...)
end

---toggle IME. wrap `self:switch()`
---@param is_enabled boolean?
---@see enable
---@see disable
function M.IME:toggle(is_enabled)
    if is_enabled == nil then
        is_enabled = not self:is_enabled()
    end
    if self:is_enabled() == is_enabled then
        return
    end
    self:is_enabled(is_enabled)

    self:switch(is_enabled)
end

---enable IME. wrap `self:toggle()`
---@see toggle
function M.IME:enable()
    return function()
        self:toggle(true)
    end
end

---disable IME. wrap `self:toggle()`
---@see toggle
function M.IME:disable()
    self:toggle(false)
end

---Callbacks
---@section callbacks

---get a callback for `self:toggle()`
---@see toggle
---@param is_enabled boolean?
function M.IME:toggle_cb(is_enabled)
    return function()
        self:toggle(is_enabled)
    end
end

---get a callback for `self:enable()`
---@see toggle
function M.IME:enable_cb()
    return function()
        self:toggle(true)
    end
end

---get a callback for `self:disable()`
---@see toggle
function M.IME:disable_cb()
    return function()
        self:toggle(false)
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
