---ldoc config
-- luacheck: ignore 111
---@diagnostic disable: lowercase-global
project = "rime.nvim"
title = "rime.nvim: librime binding for NeoVim"
format = "cmark"
dir = "_readthedocs/html"
readme = {
    "README.md"
}
-- "packages/vim/lua"
-- some vim's lua script has @class with conflict of ldoc
file = {"lua", "packages/ime/lua", "packages/platformdirs/lua"}
description = title
full_description = [[
Use RIME in NeoVim!
]]
