---Provide a simple IME based on `ime.IME()`.
---any subclass can use `self:process()` to customize `self:exe()`
local fs = require 'ime.fs'
local Key = require 'rime.key'.Key
local UI = require 'ime.ui'.UI
local IME = require "ime.ime".IME
local Session = require "rime.session".Session
local M = {
    Rime = {}
}

---@param rime table?
---@return table rime
---@see ime.new
function M.Rime:new(rime)
    rime = rime or {}
    rime.session = rime.session or Session()
    rime.ui = rime.ui or UI()
    rime = IME(rime)
    setmetatable(rime, {
        __index = self
    })
    if rime.trigger then
        rime:process(rime.trigger.code, rime.trigger.mask)
    end
    return rime
end

setmetatable(M.Rime, {
    __index = IME,
    __call = M.Rime.new
})

---wrap `self.ui:draw()`
---@param ... table
---@return string, string[], integer
---@see ui.draw
function M.Rime:draw(...)
    for _, key in ipairs { ... } do
        if not self.session:process_key(key.code, key.mask) then
            local text = ""
            if key.mask == 0 then
                text = string.char(key.code)
            end
            return text, {}, 0
        end
    end
    local context = self.session:get_context()
    if context == nil or context.menu.num_candidates == 0 then
        return self.session:get_commit_text(), {}, 0
    end
    local lines, col = self.ui:draw(context)
    return "", lines, col
end

---wrap `self:draw()`
---@param ... string
---@see draw
function M.Rime:process(...)
    local keys = {}
    for _, name in ipairs { ... } do
        table.insert(keys, Key { name = name })
    end
    ---@diagnostic disable-next-line: deprecated
    local unpack = unpack or table.unpack
    return self:draw(unpack(keys))
end

---**entry for rime**
function M.Rime:main()
    self:enable()
    while true do
        local c = fs.getchar()
        self:call({ code = c, mask = 0 })
    end
end

---override `IME`.
---@section overrides

---override `IME`.
---@param ... table
function M.Rime:exe(...)
    local text, lines, _ = self:draw(...)
    print(text)
    print(table.concat(lines, "\n"))
end

return M
