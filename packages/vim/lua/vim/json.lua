---wrap `vim.json`. `vim.json` doesn't use `boolean` rather than `0 | 1`.
---@module vim.json
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
if vim and vim.json then
    return vim.json
end
local _, cjson = pcall(require, 'cjson')
return cjson
