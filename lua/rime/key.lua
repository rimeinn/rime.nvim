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
        code = keys.space,
        mask = 0,
    }
}

---@param key string | table?
---@return table
function M.Key:new(key)
    key = key or {}
    if type(key) == type('') then
        ---@diagnostic disable-next-line: param-type-mismatch
        key = M.Key.vim_to_rime(key)
    end
    ---@diagnostic disable-next-line: return-type-mismatch
    setmetatable(key, {
        __index = self
    })
    ---@diagnostic disable-next-line: return-type-mismatch
    return key
end

setmetatable(M.Key, {
    __call = M.Key.new
})

---convert vim key name to rime code and mask
---@param key string
---@return table key
function M.Key.vim_to_rime(key)
    local mask = 0
    -- convert vim key name to rime key name
    if key:sub(1, 1) == "<" and key:sub(-1) == ">" then
        key = key:sub(2, -2):gsub("-[-]", "-minus"):upper()
        key = M.keys.aliases[key] or key
        local parts = {}
        for part in key:gmatch("([^-]+)") do
            table.insert(parts, part)
        end
        key = table.remove(parts)
        -- don't capitalize alphabetas
        if #key ~= 1 then
            key = key:sub(1, 1):upper() .. key:sub(2)
            -- lower alphabetas for any modifier: S-A -> S-a
        elseif parts ~= {} then
            key = key:lower()
        end
        -- map vim key name to rime key name
        if parts == { "C" } then
            key = M.keys.Control[key] or key
        end
        key = M.keys.any[key] or key
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
    local code = keys[key] or key:byte()

    return { code = code, mask = mask }
end

return M
