---Update cursor colors
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
local M = {
    Cursor = {
        --- config for cursor
        highlight = 'CursorIM',
        schemas = {
            [".default"] = { bg = 'white' },
            double_pinyin_mspy = { bg = 'red' },
            japanese = { bg = 'yellow' }
        }
    }
}

---@param cursor table?
---@return table cursor
function M.Cursor:new(cursor)
    cursor = cursor or {}
    setmetatable(cursor, {
        __index = self
    })
    return cursor
end

setmetatable(M.Cursor, {
    __call = M.Cursor.new
})

---Set highlight
---@param schema string?
function M.Cursor:set_hl(schema)
    schema = schema or ".default"
    local hl = self.schemas[schema]
    vim.api.nvim_set_hl(0, self.highlight, hl)
end

---Update cursor colors
---@param session table
---@param is_enabled boolean
function M.Cursor:update(session, is_enabled)
    local schema = '.default'
    if is_enabled then
        schema = session:get_current_schema()
    end
    self:set_hl(schema)
end

return M
