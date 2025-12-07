---wrap `vim._meta`
---@module vim
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113 212
local vim = require "vim.shared"
vim.filetype = require "vim.filetype"
vim.fs = require 'vim.fs'
vim.fn = require 'vim.fn'
vim.uv = require "vim.uv"
return vim
