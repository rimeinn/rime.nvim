---Provide a simple IME
local fs = require 'rime.fs'
local Key = require 'rime.key'.Key
local UI = require 'rime.ui'.UI
local Session = require "rime.session".Session
local M = {
    Rime = {
    }
}

---@param rime table?
---@return table rime
function M.Rime:new(rime)
    rime = rime or {}
    rime.session = rime.session or Session()
    rime.ui = rime.ui or UI()
    setmetatable(rime, {
        __index = self
    })
    return rime
end

setmetatable(M.Rime, {
    __call = M.Rime.new
})

---wrap `ui:draw()`
---@param ... table
---@return string, string[], integer
function M.Rime:draw(...)
    for _, key in ipairs { ... } do
        if not self.session:process_key(key.code, key.mask) then
            local text = ""
            if key.mask == 0 then
                text = string.char(key.code)
            end
            return text, { self.ui.cursor }, 0
        end
    end
    local context = self.session:get_context()
    if context == nil or context.menu.num_candidates == 0 then
        return self.session:get_commit_text(), { self.ui.cursor }, 0
    end
    local lines, col = self.ui:draw(context)
    return "", lines, col
end

---wrap `self:draw()`
---@param ... string
function M.Rime:process(...)
    local keys = {}
    for _, name in ipairs { ... } do
        table.insert(keys, Key { name = name })
    end
    local unpack = unpack or table.unpack
    return self:draw(unpack(keys))
end

---wrap `self:draw()`
---@param ... table
function M.Rime:exe(...)
    local text, lines, _ = self:draw(...)
    print(text)
    print(table.concat(lines, "\n"))
end

---**entry for rime**
function M.Rime:main()
    while true do
        local c = fs.getchar()
        self:exe({ code = c })
    end
end

return M
