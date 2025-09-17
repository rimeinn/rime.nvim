---Provide a simple IME
local fs = require 'rime.fs'
local Key = require 'rime.key'.Key
local UI = require 'rime.ui'.UI
local _rime = require "rime"
local Session = _rime.Session or _rime.RimeSessionId
local Traits = require 'rime.traits'.Traits
local M = {
    Rime = {
        ui = UI(),
        -- lazy instantiation
        traits = nil,
        session = nil,
    }
}

---@param rime table?
---@return table rime
function M.Rime:new(rime)
    rime = rime or {}
    rime.traits = rime.traits or Traits()
    rime.session = rime.session or Session()
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
        local text = ""
        if self.session:commit_composition() then
            local commit = self.session:get_commit()
            if commit then
                text = commit.text
            end
        end
        return text, { self.ui.cursor }, 0
    end
    local lines, col = self.ui:draw(context)
    return "", lines, col
end

---wrap `self:draw()`
---@param ... table
function M.Rime:call(...)
    local text, lines, _ = self:draw(...)
    print(text)
    print(table.concat(lines, "\n"))
end

---**entry for rime**
function M.Rime:main()
    while true do
        local c = fs.getchar()
        local key = Key { code = c }
        self:call(key)
    end
end

return M
