---wrap `vim.json`.
---Although vim.json is cjson actually, vim doesn't support `require'cjson'`.
---@module vim.json
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
if vim and vim.json then
    return vim.json
end
local _, cjson = pcall(require, 'cjson')
return cjson
