---utilities
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
local keys = require "rime.data.keys"
local modifiers = require "rime.data.modifiers"
local M = {}

---parse key to keycode
---@param key string
---@param modifiers_ string[]
---@return integer
---@return integer
function M.parse_key(key, modifiers_)
    local keycode = key:byte()
    -- convert vim key name to rime key name
    if key:sub(1, 1) == "<" and key:sub(-1) == ">" then
        key = key:sub(2, -2):upper()
            :gsub("-[-]", "-minus")
            :gsub("C[-]_", "C-minus")
            :gsub("C[-]M", "Return")
            :gsub("C[-]I", "Tab")
            :gsub("C[-][[]", "Escape")
            :gsub("C[-]^", "C-6")
            :gsub("C[-]@", "C-Space")
        local parts = {}
        for part in key:gmatch("([^-]+)") do
            table.insert(parts, part)
        end
        key = table.remove(parts):lower()
        if key ~= "space" and key ~= "bar" and key ~= "minus" and #key ~= 1 then
            key = key:sub(1, 1):upper() .. key:sub(2)
        end
        for _, part in ipairs(parts) do
            if part == "S" then
                table.insert(modifiers_, "Shift")
            elseif part == "C" then
                table.insert(modifiers_, "Control")
            elseif part == "M" then
                table.insert(modifiers_, "Alt")
            end
        end
        if key == "Bs" then
            key = "BackSpace"
        elseif key == "Del" then
            key = "Delete"
        elseif key == "Cr" or key == "Enter" then
            key = "Return"
        elseif key == "Esc" then
            key = "Escape"
        elseif key == "Lt" then
            key = "less"
        elseif key:sub(1, 4) == "Page" then
            key = "Page_" .. key:sub(5, 5):upper() .. key:sub(6)
        end
    end
    -- convert rime key name to rime key code
    for k, v in pairs(keys) do
        if key == k then
            keycode = v
            break
        end
    end

    local mask = 0
    for _, modifier_ in ipairs(modifiers_) do
        for i, modifier in ipairs(modifiers) do
            if modifier == modifier_ then
                mask = mask + 2 ^ (i - 1)
            end
        end
    end
    return keycode, mask
end

return M
