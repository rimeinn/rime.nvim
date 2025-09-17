---Update cursor colors
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
local M = {
    Cursor = {
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

---Update cursor colors
---@param schema string?
function M.Cursor:update(schema)
    schema = schema or ".default"
    local hl = self.schemas[schema]
    vim.api.nvim_set_hl(0, "CursorIM", hl)
end

return M
