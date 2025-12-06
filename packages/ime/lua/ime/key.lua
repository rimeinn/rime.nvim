---Convert vim key name `<C-A>` to A's code and Ctrl's mask
---@module ime.key
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
local M = {
    keys = {
        --- key aliases
        aliases = {
            ["C-M"] = "Return",
            ["C-I"] = "Tab",
            ["C-["] = "Escape",
        },
        --- key map for any modifiers. keep capital name
        any = {
            Bs = "BackSpace",
            Del = "Delete",
            Cr = "Return",
            Enter = "Return",
            Esc = "Escape",
            Lt = "less",
            Pageup = "Page_Up",
            Pagedown = "Page_Down",
            Space = "space",
            Bar = "bar",
            Minus = "minus",
        },
        --- key map for Control
        Control = {
            _ = "minus",
            ["^"] = "6",
            ["@"] = "Space",
        },
        --- modifier map
        modifiers = {
            C = "Control",
            S = "Shift",
            M = "Alt",
            A = "Alt",
        }
    },
    --- config for Key
    Key = {
        code = string.byte(' '), -- rime key code
        mask = 0, -- rime key mask
    }
}

---@param key table?
---@param keys table<string, integer>? map key name `A` to key code `0x41`
---@param modifiers string[]? map number to modifier
---@return table
function M.Key:new(key, keys, modifiers)
    key = key or {}
    keys = keys or {}
    modifiers = modifiers or {}
    if key.code == nil then
        local mask = 0
        local name = key.name
        -- convert vim key name to rime key name
        if name:sub(1, 1) == "<" and name:sub( -1) == ">" then
            name = name:sub(2, -2):gsub("-[-]", "-minus"):upper()
            name = M.keys.aliases[name] or name
            local parts = {}
            for part in name:gmatch("([^-]+)") do
                table.insert(parts, part)
            end
            name = table.remove(parts)
            -- don't capitalize alphabetas
            if #name ~= 1 then
                name = name:sub(1, 1):upper() .. name:sub(2):lower()
                -- lower alphabetas for any modifier: S-A -> S-a
            elseif parts ~= {} then
                name = name:lower()
            end
            -- map vim key name to rime key name
            if parts == { "C" } then
                name = M.keys.Control[name] or name
            end
            name = M.keys.any[name] or name
            for _, part in ipairs(parts) do
                part = M.keys.modifiers[part] or part
                for i, modifier in ipairs(modifiers) do
                    if modifier == part then
                        mask = mask + 2 ^ (i - 1)
                    end
                end
            end
        end
        -- convert rime key name to rime key code
        key.code = keys[name] or name:byte()
        key.mask = mask
    end
    setmetatable(key, {
        __index = self
    })
    if key.name == nil then
        local name = 'space'
        if key.code < 256 then
            name = string.char(key.code)
            if name == ' ' then
                name = 'Space'
            end
        else
            for n, code in pairs(keys) do
                if key.code == code then
                    name = n
                    break
                end
            end
            for k, v in pairs(M.keys.any) do
                if name == v then
                    name = k:upper()
                end
            end
        end
        local mask = key.mask
        if mask > 0 then
            if #name == 1 then
                name = name:upper()
            end
            for i = #modifiers, 1, -1 do
                local modifier = modifiers[i]
                if mask >= 2 ^ (i - 1) then
                    mask = mask - 2 ^ (i - 1)
                    for k, v in pairs(M.keys.modifiers) do
                        if modifier == v then
                            name = k .. "-" .. name
                            break
                        end
                    end
                end
            end
            name = "<" .. name .. ">"
        end
        key.name = name
    end
    return key
end

setmetatable(M.Key, {
    __call = M.Key.new
})

return M
