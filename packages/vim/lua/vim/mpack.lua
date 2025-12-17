---wrap `vim.mpack`.
---NOTE: neovim's `require'mpack'` redefine some function names.
-- <https://github.com/neovim/neovim/blob/v0.11.5/src/nvim/lua/stdlib.c#L743>
---@module vim.mpack
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
if vim and vim.mpack then
    return vim.mpack
end
local _, mpack = pcall(require, 'mpack')
mpack.encode = mpack.pack
mpack.decode = mpack.unpack
return mpack
