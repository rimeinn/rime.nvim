# vim

Use some neovim functions in PUC lua/luajit.

- Use `luafilesystem` to simulate `vim.fn.*`
- Use optional `luaposix` or `luv` to simulate `vim.uv`.

```lua
local fs = require'vim.fs'
local path = fs.dirname(fs.joinpath('/a/b/c', 'd', 'e'))
print(path)
-- /a/b/c/d
```

```lua
local filetype = require'vim.filetype'
local ft = filetype.match{ filename = "Makefile" }
print(ft)
-- make
```

See `:help vim.XXX` in neovim to know `XXX`'s usage.

You also can add `local vim = require'vim'` before any `vim.*.*()`.
