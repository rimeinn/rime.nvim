---Update airline Airline
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
local M = {
    Airline = {
        --- config for default vim settings, overridden by `vim.g.airline_mode_map`
        modes = {
            s = "SELECT",
            S = 'S-LINE',
            ["\x13"] = 'S-BLOCK',
            i = 'INSERT',
            ic = 'INSERT COMPL GENERIC',
            ix = 'INSERT COMPL',
            R = 'REPLACE',
            Rc = 'REPLACE COMP GENERIC',
            Rv = 'V REPLACE',
            Rx = 'REPLACE COMP',
        }
    }
}

---@param airline table?
---@return table Airline
function M.Airline:new(airline)
    airline = airline or {}
    if airline.modes == nil and vim.g.airline_mode_map then
        airline.modes = vim.g.airline_mode_map
    end
    setmetatable(airline, {
        __index = self
    })
    return airline
end

setmetatable(M.Airline, {
    __call = M.Airline.new
})

---get new airline mode map symbols
---@param mode string mode name
---@param old string old mode symbol
---@param name string schema name
---@return string new new mode symbol
function M.Airline.get_new_mode(mode, old, name)
    for mode_name, _ in pairs(M.Airline.modes) do
        if mode_name == mode then
            if mode:sub(1, 1) == 'i' then
                return name
            end
            return old .. name
        end
    end
    return old
end

---get new modes from old modes and session
---@param session table
---@return table<string, string> modes
function M.Airline:get_new_modes(session)
    local name = session:get_schema_name()
    local modes = {}
    for mode, old in pairs(self.modes) do
        modes[mode] = M.Airline.get_new_mode(mode, old, name)
    end
    return modes
end

---update status bar by `airline_mode_map`. see `help airline`.
---@param session table
---@param is_enabled boolean
function M.Airline:update(session, is_enabled)
    if vim.g.airline_mode_map then
        if is_enabled then
            vim.g.airline_mode_map = self:get_new_modes(session)
        else
            vim.g.airline_mode_map = self.modes
        end
    end
end

return M
