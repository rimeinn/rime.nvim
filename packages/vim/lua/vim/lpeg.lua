---wrap `vim.lpeg`.
-- <https://github.com/neovim/neovim/blob/v0.11.5/src/nvim/lua/stdlib.c#L757>
---@module vim.lpeg
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
if vim and vim.lpeg then
    return vim.lpeg
end
local _, lpeg = pcall(require, 'lpeg')
return lpeg
