---wrap `rime.Session()`
local rime = require "rime"
local Session = rime.Session or rime.RimeSessionId
local Key = require 'rime.key'.Key
local Traits = require 'rime.traits'.Traits

local M = {
    Session = {}
}

---@param session table?
---@return table session
function M.Session:new(session)
    session = session or {}
    session.traits = session.traits or Traits()
    session.userdata = Session()
    setmetatable(session, {
        __index = self
    })
    return session
end

setmetatable(M.Session, {
    __call = M.Session.new
})

---wrap `session.get_current_schema()`
function M.Session:get_current_schema(...)
    return self.userdata:get_current_schema(...)
end

---wrap `session.select_schema()`
function M.Session:select_schema(...)
    return self.userdata:select_schema(...)
end

---wrap `session.process_key()`
function M.Session:process_key(...)
    return self.userdata:process_key(...)
end

---wrap `session.get_context()`
function M.Session:get_context(...)
    return self.userdata:get_context(...)
end

---wrap `session.get_commit()`
function M.Session:get_commit(...)
    return self.userdata:get_commit(...)
end

---wrap `session.commit_composition()`
function M.Session:commit_composition(...)
    return self.userdata:commit_composition(...)
end

---wrap `session.commit_composition()`
function M.Session:clear_composition(...)
    return self.userdata:clear_composition(...)
end

M.Session.get_schema_list = rime.get_schema_list

---get schema name
---@return string name
function M.Session:get_schema_name()
    local schemas = self.get_schema_list()
    local schema_id = self:get_current_schema()
    for _, schema in ipairs(schemas) do
        if schema.schema_id == schema_id then
            return schema.name
        end
    end
    return ""
end

---get rime commit
---@return string text
function M.Session:get_commit_text()
    local text = ""
    if self:commit_composition() then
        local commit = self:get_commit()
        if commit then
            text = commit.text
        end
    end
    return text
end

---process key. wrap `session:process_key()`
---@param name string
---@return boolean
function M.Session:parse_key(name)
    local key = Key({ name = name })
    return self:process_key(key.code, key.mask)
end

---get context with all candidates, useful for `lua.rime.nvim.cmp`
---@param input string
---@return table
function M.Session:get_full_context(input)
    for name in input:gmatch("(.)") do
        if self:parse_key(name) == false then
            break
        end
    end
    local result = self:get_context()
    local context = result
    while (not context.menu.is_last_page) do
        self:parse_key('=')
        context = self:get_context()
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
    self:clear_composition()
    result.menu.is_last_page = true
    return result
end

return M
