# rime.nvim

[![readthedocs](https://shields.io/readthedocs/rime-nvim)](https://rime-nvim.readthedocs.io)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/rimeinn/rime.nvim/main.svg)](https://results.pre-commit.ci/latest/github/rimeinn/rime.nvim/main)
[![github/workflow](https://github.com/rimeinn/rime.nvim/actions/workflows/main.yml/badge.svg)](https://github.com/rimeinn/rime.nvim/actions)

[![github/downloads](https://shields.io/github/downloads/rimeinn/rime.nvim/total)](https://github.com/rimeinn/rime.nvim/releases)
[![github/downloads/latest](https://shields.io/github/downloads/rimeinn/rime.nvim/latest/total)](https://github.com/rimeinn/rime.nvim/releases/latest)
[![github/issues](https://shields.io/github/issues/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim/issues)
[![github/issues-closed](https://shields.io/github/issues-closed/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim/issues?q=is%3Aissue+is%3Aclosed)
[![github/issues-pr](https://shields.io/github/issues-pr/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim/pulls)
[![github/issues-pr-closed](https://shields.io/github/issues-pr-closed/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim/pulls?q=is%3Apr+is%3Aclosed)
[![github/discussions](https://shields.io/github/discussions/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim/discussions)
[![github/milestones](https://shields.io/github/milestones/all/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim/milestones)
[![github/forks](https://shields.io/github/forks/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim/network/members)
[![github/stars](https://shields.io/github/stars/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim/stargazers)
[![github/watchers](https://shields.io/github/watchers/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim/watchers)
[![github/contributors](https://shields.io/github/contributors/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim/graphs/contributors)
[![github/commit-activity](https://shields.io/github/commit-activity/w/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim/graphs/commit-activity)
[![github/last-commit](https://shields.io/github/last-commit/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim/commits)
[![github/release-date](https://shields.io/github/release-date/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim/releases/latest)

[![github/license](https://shields.io/github/license/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim/blob/main/LICENSE)
[![github/languages](https://shields.io/github/languages/count/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim)
[![github/languages/top](https://shields.io/github/languages/top/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim)
[![github/directory-file-count](https://shields.io/github/directory-file-count/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim)
[![github/code-size](https://shields.io/github/languages/code-size/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim)
[![github/repo-size](https://shields.io/github/repo-size/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim)
[![github/v](https://shields.io/github/v/release/rimeinn/rime.nvim)](https://github.com/rimeinn/rime.nvim)

[![luarocks](https://img.shields.io/luarocks/v/Freed-Wu/rime.nvim)](https://luarocks.org/modules/Freed-Wu/rime.nvim)

Rime for neovim.

![screencast](https://github.com/user-attachments/assets/71882a57-d4dd-4898-8eee-b7a17ae5193f)

This project is consist of two parts:

- A lua binding of librime
- A librime frontend on neovim

## Dependence

- [librime](https://github.com/rime/librime)

```sh
# Ubuntu
sudo apt-get -y install librime-dev librime1
sudo apt-mark auto librime-dev
# ArchLinux
sudo pacman -S librime
# Android Termux
apt-get -y install librime
# Nix
# use nix-shell to create a virtual environment then build
# homebrew
brew install librime pkg-config
# Windows msys2
pacboy -S --noconfirm pkg-config librime gcc
```

## Install

### rocks.nvim

#### Command style

```vim
:Rocks install rime.nvim
```

#### Declare style

`~/.config/nvim/rocks.toml`:

```toml
[plugins]
"rime.nvim" = "scm"
```

Then

```vim
:Rocks sync
```

or:

```sh
$ luarocks --lua-version 5.1 --local --tree ~/.local/share/nvim/rocks install rime.nvim
# ~/.local/share/nvim/rocks is the default rocks tree path
# you can change it according to your vim.g.rocks_nvim.rocks_path
```

## Usage

### Binding

```lua
local UI = require "ime.ui".UI

local Key = require "rime.key".Key
local Session = require "rime.session".Session

local session = Session()
local key = Key {name = "n"}
local ui = UI()
if not session:process_key(key.code, key.mask) then
    return
end
local context = session:get_context()
if context == nil then
    return
end
local content, _ = ui:draw(context)
print(table.concat(content, "\n"))
```

```text
n|
[① 你]② 那 ③ 呢 ④ 能 ⑤ 年 ⑥ 您 ⑦ 内 ⑧ 拿 ⑨ 哪 ⓪ 弄 |>
```

A simplest example can be found by:

```sh
rime
```

### Frontend

Set keymap:

```lua
local Rime = require('rime.nvim.rime').Rime
local rime = Rime()
rime:create_autocmds()
vim.keymap.set('i', '<C-^>', rime:toggle_cb())
vim.keymap.set('i', '<C-@>', rime:enable_cb())
vim.keymap.set('i', '<C-_>', rime:disable_cb())
```

Once it is enabled, any printable key will be passed to rime in any case while
any non-printable key will be passed to rime only if rime window is opened. If
you want to pass a key to rime in any case, try:

```lua
vim.keymap.set('i', '<C-\\>', rime:callback('<C-\\>'))
```

It is useful for some key such as the key for switching input schema.

Lazy load is possible:

```lua
local ui = require('ime.ui')

local rime = require('rime.nvim')
rime.rime = { ui = ui.UI { indices = ui.styles.square } }
vim.keymap.set('i', '<C-^>', rime.toggle)
vim.keymap.set('i', '<C-@>', rime.enable)
vim.keymap.set('i', '<C-_>', rime.disable)
vim.keymap.set('i', '<C-\\>', rime.callback('<C-\\>'))
```

![square](https://github.com/user-attachments/assets/65c1de8b-c07c-4576-81bd-a034373ec160)

Only when you press `<C-^>`, `Rime():create_autocmds()` will be call, which will
save time.

Once you switch to ascii mode of rime, you **cannot** switch back unless you
have defined any hotkey to pass the key for switching ascii mode of rime to rime.
Because only printable key can be passed to rime when rime window is closed.

## Integration

### Other frontends of librime

This plugin will search ibus/fcitx/trime's config path by order and load it.
You can customize it by:

```lua
local Traits = require 'rime.traits'.Traits
local Session = require "rime.session".Session
local Rime = require 'rime.nvim.rime'.Rime

local rime = Rime {
    session = Session {
        traits = Traits {
            user_data_dir = vim.fn.expand "~/.config/ibus/rime"
        }
    }
}
rime:create_autocmds()
vim.keymap.set('i', '<C-^>', rime:toggle_cb())
```

### Vim Cursor

```vim
set guicursor=n-v-c-sm:block-Cursor/lCursor,i-ci-ve:ver25-CursorIM/lCursorIM,r-cr-o:hor20-CursorIM/lCursorIM
```

```lua
local Cursor = require('ime.nvim.hooks.cursor').Cursor

local cursor = Cursor {
  schemas = {
    [".default"] = { bg = 'white' },
    double_pinyin_mspy = { bg = 'red' },
    japanese = { bg = 'yellow' }
  }
}
local rime = Rime {
  hook = cursor
}
```

![ASCII](https://github.com/user-attachments/assets/2e45a3b3-195e-45c9-a99a-0c49e95fda56)

![MSPY](https://github.com/user-attachments/assets/05f9e142-0357-452b-b466-d25d06cdd954)

![japanese](https://github.com/user-attachments/assets/706ce7a7-9aa7-4e62-8ca6-af6dde799776)

### [vim-airline](https://github.com/vim-airline/vim-airline/)

In insert/replace/select/... mode, it will display current input schema name.

You can customize it. Such as:

Only display input schema name in insert mode:

```lua
local Airline = require('ime.nvim.hooks.airline').Airline

local airline = Airline()

function airline.get_new_mode(mode, old, name)
  if mode == 'i' then
    return name
  end
  return old
end

local rime = Rime {
  hook = airline
}
```

See airline's `g:airline_mode_map` to know `i`, `R`, `s`, ...

Disable all hooks:

```lua
local ChainedHook = require('ime.nvim.hooks.chainedhook').ChainedHook

local hook = ChainedHook { }
-- by default
-- local hook = ChainedHook { cursor, airline }
local rime = Rime {
  hook = hook
}
```

### [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

Like [cmp-rime](https://github.com/Ninlives/cmp-rime):

```lua
require('cmp').setup {
  -- ...
  sources = {
    -- ...
    { name = 'rime' }
  }
}
```

### [lualine](https://github.com/nvim-lualine/lualine.nvim)

```lua
local cfg = require('lualine').get_config()
table.insert(
  cfg.sections.lualine_y,
  'require("rime.nvim").get_schema_name()'
)
require('lualine').setup(cfg)
```

### [ime.nvim](https://github.com/rimeinn/ime.nvim)

- `ime.nvim` uses `:set iminsert=1/0` and `:set imsearch=1/0` to save external
  IME's enabled flags.
- `rime.nvim` uses `:let/unlet b:iminsert` to save internal IME's enabled flags.

So they will not conflict.

![ime.nvim](https://github.com/user-attachments/assets/c7b61bb2-0d30-4bf2-9745-cc8ff1690596)

### [fcitx5-ui.nvim](https://github.com/black-desk/fcitx5-ui.nvim)

Both `rime.nvim` and `fcitx5-ui.nvim` uses `:let/unlet b:iminsert` to save
internal IME's enabled flags. They will conflict.

### [vim-smartinput](https://github.com/kana/vim-smartinput)

```vim
call smartinput#map_to_trigger('i', '（', '（', '（')
call smartinput#define_rule({
      \ 'at': '\%#',
      \ 'char': '（',
      \ 'input': '（）<Left>',
      \ })
```

We use `|` to represent cursor. Every time you input a character:

1. rime.nvim will process it firstly, such as `|( -> |（`
2. vim-smartinput will process it then, such as `|（ -> （|）`

However, if a menu exists, the situation is different.
E.g.,

```vim
call smartinput#map_to_trigger('i', '【', '【', '【')
call smartinput#define_rule({
      \ 'at': '\%#',
      \ 'char': '【',
      \ 'input': '【】<Left>',
      \ })
```

When you input `[`:

```text
「|
[① 「 〔全角〕]② 【 ③ 〔 ④ ［ 〔全角〕
```

Then you press `2` to select the second candidate `【`, it will be:

1. rime.nvim will process it firstly, such as `|2 -> |【`
2. vim-smartinput will do nothing, because `|2` will not trigger the rule of `|【`.

You will not get `【|】`!

Especially, when you mix Chinese punctuation and ASCII punctuation:

```vim
call smartinput#map_to_trigger('i', '<Space>', '<Space>', '<Space>')
call smartinput#define_rule({
      \ 'at': '(\%#)',
      \ 'char': '<Space>',
      \ 'input': '<Space><Space><Left>',
      \ })
```

If you press `<Space>` in `(|)`, you will get `( | )`.
However, if you press `<Space>` to select the first candidate `你好`,
you will get `(你好| )` due to `| -> |你好`!
The best solution is using Chinese punctuation to get `（你好|）`.

### Nix

For Nix user, run
`/the/path/of/luarocks/rocks-5.1/rime.nvim/VERSION/scripts/update.sh` when
dynamic link libraries are broken after `nix-collect-garbage -d`.

## Related Projects

- [A collection](https://github.com/rimeinn/ime.nvim#librime) of rime frontends
  for neovim
- [A collection](https://github.com/rime/librime#frontends) of rime frontends

### Translators and Filters

- [librime-lua](https://github.com/hchunhui/librime-lua): use lua to write
  translators and filters of librime
- [librime-python](https://github.com/ayaka14732/librime-python): use python
- [librime-qjs](https://github.com/HuangJian/librime-qjs): use quickjs
