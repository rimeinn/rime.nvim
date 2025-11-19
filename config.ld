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
file = {"lua", "packages/platformdirs/lua", "assets/templates"}
description = title
full_description = [[
Use RIME in NeoVim!
]]
