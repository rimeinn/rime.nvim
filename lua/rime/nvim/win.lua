---Wrap `vim.api.nvim_open_win()`
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
local fs = require 'rime.fs'
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

---Open a window
function M.Win:_open()
    vim.api.nvim_buf_set_lines(self.buf_id, 0, #self.lines, false, self.lines)
    if self:is_valid() then
        vim.api.nvim_win_set_config(self.win_id, self.config)
    else
        self.win_id = vim.api.nvim_open_win(self.buf_id, false, self.config)
    end
end

---Close a window
function M.Win:_close()
    if self:is_valid() then
        vim.api.nvim_win_close(self.win_id, false)
    end
end

---Wrap `self._open()`
function M.Win:open(lines, col)
    local width = 0
    for _, line in ipairs(lines) do
        width = math.max(fs.strwidth(line), width)
    end
    self.lines = lines
    self.config = {
        relative = "cursor",
        height = #lines,
        style = "minimal",
        width = width,
        row = 1,
        col = col,
    }
    vim.schedule(
        function()
            self:_open()
        end
    )
end

---Wrap `self._close()`
function M.Win:close()
    self.lines = {}
    self.config = {}
    vim.schedule(
        function()
            self:_close()
        end
    )
end

return M
