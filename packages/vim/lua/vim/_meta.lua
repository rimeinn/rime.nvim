---wrap `vim`
---@module vim._meta
local M = {
    env = {},
    regex = {},
}

setmetatable(M.env, {
-- luacheck: ignore 212
---@diagnostic disable-next-line: unused-local
  __index = function(t, k)
    return os.getenv(k) or ''
  end,
})

---wrap `vim.regex()`
---@param pattern string
---@return table
function M.regex:new(pattern)
    local regex = { pattern = pattern }
    setmetatable(regex, {
        __index = self
    })
    return regex
end

setmetatable(M.regex, {
    __call = M.regex.new
})

---wrap `vim.regex():match_str()`
---@param str string
---@return integer?
---@return integer?
function M.regex:match_str(str)
    return str:match(self.pattern) and 1, 1
end

return M
