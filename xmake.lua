-- luacheck: ignore 111 113 143
---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field
add_rules("mode.debug", "mode.release")

add_requires("rime")

target("rime")
do
    add_rules("lua.module", "lua.native-objects")
    add_files("*.nobj.lua")
    add_cflags("-Wno-int-conversion")
    add_packages("rime")
    set_configdir("lua/rime")
    add_configfiles("lua/rime/assets/templates/version.lua")
end
