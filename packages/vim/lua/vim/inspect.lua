---wrap `vim.inspect`.
-- <https://github.com/neovim/neovim/blob/v0.11.5/MAINTAIN.md?plain=1#L151>
---@module vim.inspect
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
if vim and vim.inspect then
    return vim.inspect
end
local _, inspect = pcall(require, 'inspect')
return inspect
