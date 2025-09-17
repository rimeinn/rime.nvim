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

---get rime commit
---@return string text
function M.Rime:get_commit_text()
    local text = ""
    if self.session:commit_composition() then
        local commit = self.session:get_commit()
        if commit then
            text = commit.text
        end
    end
    return text
end

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
        return self:get_commit_text(), { self.ui.cursor }, 0
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

---process key. wrap `session:process_key()`
---@param name string
---@return boolean
function M.Rime:process_key(name)
    local key = Key({ name = name })
    return self.session:process_key(key.code, key.mask)
end

---get context with all candidates, useful for `lua.rime.nvim.cmp`
---@param input string
---@return table
function M.Rime:get_context(input)
    for name in input:gmatch("(.)") do
        if self:process_key(name) == false then
            break
        end
    end
    local result = self.session:get_context()
    local context = result
    while (not context.menu.is_last_page) do
        self:process_key('=')
        context = self.session:get_context()
        result.menu.num_candidates = result.menu.num_candidates + context.menu.num_candidates
        if (result.menu.select_keys and context.menu.select_keys) then
            for _, key in ipairs(context.menu.select_keys) do
                table.insert(result.menu.select_keys, key)
            end
        end
        if (result.menu.candidates and context.menu.candidates) then
            for _, candidate in ipairs(context.menu.candidates) do
                table.insert(result.menu.candidates, candidate)
            end
        end
    end
    self.session:clear_composition()
    result.menu.is_last_page = true
    return result
end

return M
