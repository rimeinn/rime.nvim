---wrap `vim.shared`
---@module vim.shared
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113 212
if vim and vim.validate then
    return vim
end
local M = {
    env = {},
    regex = {},
}

---wrap `vim.deepcopy()`
---@param orig any
---@param noref any
---@diagnostic disable-next-line: unused-local
function M.deepcopy(orig, noref)
    return orig
end

---wrap `vim.validate()`
---@diagnostic disable-next-line: unused-vararg
function M.validate(...)
    return true
end

---wrap `vim.gsplit()`
---@param s string
---@param sep string
---@param opts table?
---@return function
---@diagnostic disable-next-line: unused-local
function M.gsplit(s, sep, opts)
    return s:gmatch("([^" .. sep .. "]+)" .. sep .. '?')
end

---wrap `vim.split()`
---@param s string
---@param sep string
---@param opts table?
---@return string[]
---@diagnostic disable-next-line: unused-local
function M.split(s, sep, opts)
    local matches = {}
    for m in s:gmatch("([^" .. sep .. "]+)" .. sep .. '?') do
        table.insert(matches, m)
    end
    return matches
end

---wrap `vim.startswith()`
---@param s string
---@param prefix string
---@return boolean
function M.startswith(s, prefix)
    return s:sub(1, #prefix) == prefix
end

---wrap `vim.pesc()`
---@param s string
---@return string
function M.pesc(s)
    return s
end

setmetatable(M.env, {
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
