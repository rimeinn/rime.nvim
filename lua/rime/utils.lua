---utilities
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
local keys = require "rime.data.keys"
local modifiers = require "rime.data.modifiers"
local M = {}

---judge if dir is a directory
---@param dir string
---@return boolean
function M.isdirectory(dir)
    if vim then
        return vim.fn.isdirectory(dir) == 1
    end
    return require "lfs".attributes(dir).mode == "directory"
end

---join two paths
---@param dir string
---@param file string
---@return string
function M.joinpath(dir, file)
    if vim then
        return vim.fs.joinpath(dir, file)
    end
    return dir .. "/" .. file
end

--- get dirname
---@param dir string
---@return string
function M.dirname(dir)
    if vim then
        return vim.fs.dirname(dir)
    end
    local result, _ = dir:gsub("/[^/]+/?$", "")
    return result
end

-- get stdpath
---@param name
---@return string
function M.stdpath(name)
    if vim then
        return vim.fn.stdpath(name)
    end
    return os.getenv("HOME") or "."
end

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

---draw UI
---@param context table
---@param ui table
---@param left_width integer
---@return string[]
---@return integer
function M.draw_ui(context, ui, left_width)
    local preedit = context.composition.preedit or ""
    preedit = preedit:sub(1, context.composition.cursor_pos) ..
        ui.cursor .. preedit:sub(context.composition.cursor_pos + 1)
    local candidates = context.menu.candidates
    local candidates_ = ""
    local indices = ui.indices
    for index, candidate in ipairs(candidates) do
        local text = indices[index] .. " " .. candidate.text
        if candidate.comment ~= nil then
            text = text .. " " .. candidate.comment
        end
        if (context.menu.highlighted_candidate_index + 1 == index) then
            text = ui.left_sep .. text
        elseif (context.menu.highlighted_candidate_index + 2 == index) then
            text = ui.right_sep .. text
        else
            text = " " .. text
        end
        candidates_ = candidates_ .. text
    end
    if (context.menu.num_candidates == context.menu.highlighted_candidate_index + 1) then
        candidates_ = candidates_ .. ui.right_sep
    else
        candidates_ = candidates_ .. " "
    end
    local col = 0
    local left = ui.left
    if context.menu.page_no ~= 0 then
        local num = left_width
        candidates_ = left .. candidates_
        local whitespace = " "
        preedit = whitespace:rep(num) .. preedit
        col = col - num
    end
    if (context.menu.is_last_page == false and context.menu.num_candidates > 0) then
        candidates_ = candidates_ .. ui.right
    end
    return { preedit, candidates_ }, col
end

return M
