---Convert vim key name `<C-A>` to A's code and Ctrl's mask
---@module ime.key
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
local M = {
    --- config for Key
    Key = {
        code = (' '):byte(), -- rime key code
        mask = 0,            -- rime key mask
        aliases = {
            ["<nul>"] = "<c-space>",
            ["<c-@>"] = "<c-space>",
            ["<c-h>"] = "<bs>",
            ["<c-i>"] = "<tab>",
            ["<nl>"] = "<c-j>",
            ["<c-m>"] = "<return>",
            ["<enter>"] = "<return>",
            ["<cr>"] = "<return>",
            ["<c-[>"] = "<esc>",
            ["<space>"] = " ",
            ["<lt>"] = "<",
            ["<bslash>"] = "\\",
            ["<bar>"] = "|",
        },
        modifiers = {
            S = 2 ^ 0,
            C = 2 ^ 2,
            A = 2 ^ 3,
            M = 2 ^ 3,
        }
    }
}

---@param key table?
---@return table
function M.Key:new(key)
    key = key or {}
    setmetatable(key, {
        __tostring = self.tostring,
        __index = self
    })
    return key
end

---print a printable key
---@return string
function M.Key:tostring()
    if self.mask ~= 0 or self.code < (" "):byte() or self.code > ("~"):byte() then
        return ""
    end
    return string.char(self.code)
end

---create a Key from a vim name
---@param name string
---@return table
function M.Key:from_vim(name)
    -- <space> -> ' '
    name = self.aliases[name:lower()] or name
    if #name == 1 then
        return self { code = name:byte() }
    end
    name = name:sub(2, -2):lower()
    local mask = 0
    for prefix in name:gmatch "([^-])-" do
        mask = mask + self.modifiers[prefix:upper()]
    end
    -- make "-" work
    name = name:match("[^-]+$") or "-"
    -- space -> ' '
    name = self.aliases["<" .. name:lower() .. ">"] or name
    -- C-A is same as c-a
    if mask == self.modifiers.C then
        name = name:lower()
    end
    if #name == 1 then
        return self {
            code = name:byte(),
            mask = mask,
        }
    end
    return self {
        code = self.convert(name:lower()),
        mask = mask,
    }
end

setmetatable(M.Key, {
    __call = M.Key.new
})

return M
