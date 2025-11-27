# vim

use vim.fs outside of neovim.

```lua
local fs = require'vim.fs'
local path = fs.joinpath('/a/b/c', 'd')
print(path)
```

```text
/a/b/c/d
```

- When you run this lua script in neovim, it will do nothing.
- When you run this lua script in lua, it will work like `vim.fs`!

You also can add `local vim = require'vim'` before any `vim.fs.*()`.

See `:help vim.fs` in neovim to know its usage.
