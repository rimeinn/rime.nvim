-- luacheck: ignore 111 113 143
---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field
add_rules("mode.debug", "mode.release")

add_requires("rime")

rule("json2lua")
do
    set_extensions(".json")
    on_build_file(function(target, sourcefile, _opt)
        import("core.project.depend")
        os.mkdir(target:targetdir())
        local targetfile = path.join(target:targetdir(), path.basename(sourcefile) .. ".lua")
        depend.on_changed(function()
            os.vrunv('scripts/json2lua.lua', { sourcefile, targetfile })
        end, { files = sourcefile })
    end)
    before_install(function(target)
        local targetfile = path.join(target:targetdir(), "*.lua")
        print(targetfile)
        target:add("installfiles", targetfile, { prefixdir = "../lua/rime/data" })
    end)
end

target("rime")
do
    add_rules("lua.module", "lua.native-objects")
    add_files("*.nobj.lua")
    add_cflags("-Wno-int-conversion")
    add_packages("rime")
    set_configdir("lua/rime")
    add_configfiles("assets/templates/traits.lua")
end

target("json")
do
    set_kind("object")
    add_rules("json2lua")
    add_files("assets/json/*.json")
end
