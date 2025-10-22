---Wrap `vim.api.nvim_open_win()`.
---NOTE: `ui:draw()`'s output is `win:update()`'s input
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
local fs = require 'ime.fs'
local M = {
    Win = {
        win_id = -1,
        lines = {},
        config = {},
    }
}

---@param win table?
---@return table Win
function M.Win:new(win)
    win = win or {}
    win.buf_id = vim.api.nvim_create_buf(false, true)
    setmetatable(win, {
        __index = self
    })
    return win
end

setmetatable(M.Win, {
    __call = M.Win.new
})

---If the windows is valid
---@return boolean is_valid
function M.Win:is_valid()
    return vim.api.nvim_win_is_valid(self.win_id)
end

---If the windows has preedit
---@return boolean has_preedit
function M.Win:has_preedit()
    return #self.lines == 2
end

---Open or close a window
function M.Win:_update()
    if #self.lines == 0 then
        if self:is_valid() then
            vim.api.nvim_win_close(self.win_id, false)
        end
        return
    end
    vim.api.nvim_buf_set_lines(self.buf_id, 0, #self.lines, false, self.lines)
    if self:is_valid() then
        vim.api.nvim_win_set_config(self.win_id, self.config)
    else
        self.win_id = vim.api.nvim_open_win(self.buf_id, false, self.config)
    end
end

---Wrap `self._update()`
---@param lines string[]?
---@param col integer?
function M.Win:update(lines, col)
    self.lines = lines or {}
    local width = 0
    for _, line in ipairs(self.lines) do
        width = math.max(fs.strwidth(line), width)
    end
    self.config = {
        relative = "cursor",
        height = #self.lines,
        style = "minimal",
        width = width,
        row = 1,
        col = col or 0,
    }
    vim.schedule(
        function()
            self:_update()
        end
    )
end

return M
