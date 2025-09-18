---utilities
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
local keys = require "rime.data.keys"
local modifiers = require "rime.data.modifiers"
local M = {
    keys = {
        aliases = {
            ["C-M"] = "Return",
            ["C-I"] = "Tab",
            ["C-["] = "Escape",
        },
        -- capital
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
        Control = {
            _ = "minus",
            ["^"] = "6",
            ["@"] = "Space",
        },
        modifiers = {
            C = "Control",
            S = "Shift",
            M = "Alt",
            A = "Alt",
        }
    },
    Key = {
        name = 'Space',
        code = keys.space,
        mask = 0,
    }
}

---@param key table?
---@return table
function M.Key:new(key)
    key = key or {}
    if key.code == nil then
        local mask = 0
        local name = key.name
        -- convert vim key name to rime key name
        if name:sub(1, 1) == "<" and name:sub(-1) == ">" then
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
    return key
end

setmetatable(M.Key, {
    __call = M.Key.new
})

return M
