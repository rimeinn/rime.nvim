local ok, err = pcall(require, 'cmp')
if ok then
    err.register_source('rime', require('rime.nvim.plugins.cmp').new())
end
