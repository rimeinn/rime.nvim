# platformdirs

A lua implementation of [platformdirs](https://github.com/tox-dev/platformdirs).

```lua
local PlatformDirs = require 'platformdirs'.PlatformDirs
print(PlatformDirs { appname = "ibus", version = "rime" }.user_config_dir())
```

```txt
/home/$USER/.config/ibus/rime
```
