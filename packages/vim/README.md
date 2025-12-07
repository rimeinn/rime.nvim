# vim

Use some neovim functions in PUC lua/luajit.

- Use `luafilesystem` to simulate `vim.fn.*`
- Use optional `luaposix` or `luv` to simulate `vim.uv`.

## vim.fs

```lua
local fs = require'vim.fs'
local path = fs.dirname(fs.joinpath('/a/b/c', 'd', 'e'))
print(path)
-- /a/b/c/d
```

See `:help vim.fs` in neovim to know its usage.

## vim.filetype

```lua
local filetype = require'vim.filetype'
local ft = filetype.match{ filename = "Makefile" }
print(ft)
-- make
```

See `:help vim.filetype` in neovim to know its usage.

You also can add `local vim = require'vim'` before any `vim.*.*()`.
