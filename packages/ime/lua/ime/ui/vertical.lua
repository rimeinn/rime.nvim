---Provide a vertical UI.
---NOTE: `ui:draw()`'s output is `win:update()`'s input
---@module ime.ui.vertical
local styles = require 'ime.ui'.styles

local M = {
    --- config for IME UI
    UI = {
        left_sep = "[",          -- symbol for left separator
        right_sep = "]",         -- symbol for right separator
        cursor = "|",            -- symbol for cursor
        indices = styles.circle, -- symbols for indices, maximum is 10 for 1-9, 0
    },
}

---@param ui table?
---@return table ui
function M.UI:new(ui)
    ui = ui or {}
    setmetatable(ui, {
        __index = self
    })
    return ui
end

setmetatable(M.UI, {
    __call = M.UI.new
})

---draw UI
---@param context table
---@return string[], integer
function M.UI:draw(context)
    local preedit = context.composition.preedit or ""
    preedit = preedit:sub(1, context.composition.cursor_pos) ..
        self.cursor .. preedit:sub(context.composition.cursor_pos + 1)
    local lines = { preedit }

    local candidates = context.menu.candidates
    local indices = self.indices
    for index, candidate in ipairs(candidates) do
        local text = indices[index] .. " " .. candidate.text
        if candidate.comment ~= nil then
            text = text .. " " .. candidate.comment
        end
        if (context.menu.highlighted_candidate_index + 1 == index) then
            text = self.left_sep .. text .. self.right_sep
        else
            text = " " .. text .. " "
        end
        table.insert(lines, text)
    end

    return lines, 0
end

return M
