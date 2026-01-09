---wrap `vim.base64`.
---@module vim.base64
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
if vim and vim.base64 then
    return vim.base64
end
local _, base64 = pcall(require, 'base64')
return base64
