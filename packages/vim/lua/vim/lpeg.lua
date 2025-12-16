---wrap `vim.lpeg`.
---In fact, vim support `require'lpeg'` which is shorter and preferred.
---@module vim.lpeg
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
if vim and vim.lpeg then
    return vim.lpeg
end
local _, lpeg = pcall(require, 'lpeg')
return lpeg
