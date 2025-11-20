# platformdirs

A lua implementation of [platformdirs](https://github.com/tox-dev/platformdirs).

```lua
local PlatformDirs = require 'platformdirs'.PlatformDirs
print(PlatformDirs { appname = "ibus", version = "rime" }:user_config_dir())
-- Unix
-- /home/$USER/.config/ibus/rime
-- macOS
-- /Users/$USER/Library/Application Support/ibus/rime
-- Android
-- /data/user/$user/$apk/shared_prefs/ibus/rime
-- Windows
-- C:\Users\$USER\ProgramData\ibus\rime
```
