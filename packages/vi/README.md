# vi

use vim.fs outside of neovim.

```lua
-- comment it!
-- local fs = require'vim.fs'
local fs = require'vi.fs'
local path = fs.joinpath('/a/b/c', 'd')
print(path)
```

```text
/a/b/c/d
```

Works like `vim.fs`!

You also can add `local vim = require'vi'` before any `vim.fs.*()`.

See `:help vim.fs` in neovim to know its usage.
