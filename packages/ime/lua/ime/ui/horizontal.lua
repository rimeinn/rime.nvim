---Provide a horizontal UI.
---NOTE: `ui:draw()`'s output is `win:update()`'s input
---@module ime.ui.horizontal
local fn = require 'ime.fn'
local styles = require 'ime.ui'.styles

local M = {
    --- config for IME UI
    UI = {
        left = "<|",             -- symbol for left menu
        right = "|>",            -- symbol for right menu
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

    local candidates = context.menu.candidates
    local line = ""
    local indices = self.indices
    for index, candidate in ipairs(candidates) do
        local text = indices[index] .. " " .. candidate.text
        if candidate.comment ~= nil then
            text = text .. " " .. candidate.comment
        end
        if (context.menu.highlighted_candidate_index + 1 == index) then
            text = self.left_sep .. text
        elseif (context.menu.highlighted_candidate_index + 2 == index) then
            text = self.right_sep .. text
        else
            text = " " .. text
        end
        line = line .. text
    end
    if (context.menu.num_candidates == context.menu.highlighted_candidate_index + 1) then
        line = line .. self.right_sep
    else
        line = line .. " "
    end
    local col = 0
    local left = self.left
    if context.menu.page_no ~= 0 then
        local left_width = fn.strwidth(left)
        line = left .. line
        local whitespace = " "
        preedit = whitespace:rep(left_width) .. preedit
        col = col - left_width
    end
    if (context.menu.is_last_page == false and context.menu.num_candidates > 0) then
        line = line .. self.right
    end

    return { preedit, line }, col
end

return M
