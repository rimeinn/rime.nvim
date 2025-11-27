---wrap `vim`
---@module vim
local vim = require "vim.shared"
vim.fs = require 'vim.fs'
vim.fn = require 'vim.fn'
vim.uv = require "vim.uv"
return vim
