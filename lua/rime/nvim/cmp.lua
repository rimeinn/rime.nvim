---rime support for nvim-cmp
local nvim_rime = require('rime.nvim')

local M = {}

---callback
---@param id integer
---@param candidates table
function M._callback(id, candidates)
    M._callback_table[id]({
        items = candidates,
        isIncomplete = true
    })
    table.remove(M._callback_table, id)
end

M._callback_table = {}

---new
---@return table
function M.new()
    return setmetatable({}, { __index = M })
end

---get keyword pattern
---@return string
function M.get_keyword_pattern()
    return '\\%([!-~]\\)*'
end

---complete
---@param request table
---@param callback table
-- luacheck: ignore 212/self
---@diagnostic disable-next-line: unused-local
function M.complete(self, request, callback)
    local keys = string.sub(request.context.cursor_before_line, request.offset)
    M._callback_table[request.context.id] = callback
    local cursor = request.context.cursor
    local context_id = request.context.id
    local menu = nvim_rime.get_full_context(keys).menu
    local items = {}
    for i, candidate in ipairs(menu.candidates) do
        local item = {
            label = candidate.text,
            filterText = keys,
            sortText = string.format("%08d", i),
            kind = 1,
            textEdit = {
                newText = candidate.text,
                range = {
                    start = {
                        line = cursor.row - 1,
                        character = cursor.col - #keys
                    },
                    ["end"] = {
                        line = cursor.row - 1,
                        character = cursor.col - 1
                    }
                }
            }
        }
        table.insert(items, item)
    end
    M._callback(context_id, items)
end

return M
