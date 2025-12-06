# IME

A library related to input method engine for neovim.

The following IMEs depend on it:

- [rime.nvim](https://github.com/rimeinn/rime.nvim):
  - use librime to realize IME core logic
  - use neovim to draw UI
  - use lua binding of librime to call librime from neovim
- [fcitx5-ui.nvim](https://github.com/black-desk/fcitx5-ui.nvim):
  - use fcitx5 to realize IME core logic
  - use neovim to draw UI
  - use dbus to call fcitx5 from neovim
- [ime.nvim](https://github.com/rimeinn/ime.nvim):
  - use fcitx5/ibus to realize IME core logic and draw UI
  - use dbus to call fcitx5/ibus from neovim
