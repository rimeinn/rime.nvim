---wrap `vim.json`.
-- <https://github.com/neovim/neovim/blob/v0.11.5/MAINTAIN.md?plain=1#L149>
---@module vim.json
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
if vim and vim.json then
    return vim.json
end
local _, cjson = pcall(require, 'cjson')
return cjson
