---Wrap `vim.api.nvim_open_win()`
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
local fs = require 'rime.fs'
local M = {
    Win = {
        win_id = -1,
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

---Open a window
---@param lines string[]
---@param col integer
function M.Win:_open(lines, col)
    local width = 0
    for _, line in ipairs(lines) do
        width = math.max(fs.strwidth(line), width)
    end
    local config = {
        relative = "cursor",
        height = #lines,
        style = "minimal",
        width = width,
        row = 1,
        col = col,
    }
    vim.api.nvim_buf_set_lines(self.buf_id, 0, #lines, false, lines)
    if vim.api.nvim_win_is_valid(self.win_id) then
        vim.api.nvim_win_set_config(self.win_id, config)
    else
        self.win_id = vim.api.nvim_open_win(self.buf_id, false, config)
    end
end

---Close a window
function M.Win:_close()
    if vim.api.nvim_win_is_valid(self.win_id) then
        vim.api.nvim_win_close(self.win_id, false)
        self.win_id = -1
    end
end

---Wrap `self._open()`
---@param lines string[]
---@param col integer
function M.Win:open(lines, col)
    vim.schedule(
        function()
            self:_open(lines, col)
        end
    )
end

---Wrap `self._close()`
function M.Win:close()
    vim.schedule(
        function()
            self:_close()
        end
    )
end

return M
