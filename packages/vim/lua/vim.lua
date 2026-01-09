---wrap `vim._meta`
---@module vim
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113 212
local vim = require 'vim.shared'
vim.filetype = require 'vim.filetype'
vim.fs = require 'vim.fs'
vim.uri = require 'vim.uri'
vim.version = require 'vim.version'
vim.iter = require 'vim.iter'
vim.glob = require 'vim.glob'
vim.base64 = require 'vim.base64'
-- not full APIs
vim.fn = require 'vim.fn'
-- external modules
vim.json = require 'vim.json'
vim.inspect = require 'vim.inspect'
-- package.loaded
vim.uv = require 'vim.uv'
vim.lpeg = require 'vim.lpeg'
vim.mpack = require 'vim.mpack'
return vim
