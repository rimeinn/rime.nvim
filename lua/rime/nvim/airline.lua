---Update airline Airline
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
local rime = require 'rime'
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
    if airline.mode == nil and vim.g.airline_mode_map then
        airline.mode = vim.g.airline_mode_map
    end
    setmetatable(airline, {
        __index = self
    })
    return airline
end

setmetatable(M.Airline, {
    __call = M.Airline.new
})

---get new airline mode map symbols in `update_status_bar`().
---@param old string
---@param name string
---@return string
function M.Airline:get_new_symbol(old, name)
    if old == self.modes.i or old == self.modes.ic or old == self.modes.ix then
        return name
    end
    return old .. name
end

---get schema name
---@param session table
function M.get_schema_name(session)
    local schemas = rime.get_schema_list()
    local schema_id = session:get_current_schema()
    for _, schema in ipairs(schemas) do
        if schema.schema_id == schema_id then
            return schema.name
        end
    end
    return ""
end

---update `g:airline_mode_map`
---@param session table
function M.Airline:update_modes(session)
    for k, _ in pairs(self.modes) do
        vim.g.airline_mode_map = vim.tbl_deep_extend("keep",
            { [k] = self:get_new_symbol(self.modes[k], M.get_schema_name(session)) },
            vim.g.airline_mode_map)
    end
end

---update status bar by `airline_mode_map`. see `help airline`.
---@param session table
---@param is_enabled boolean
function M.Airline:update(session, is_enabled)
    if vim.g.airline_mode_map then
        if not is_enabled then
            vim.g.airline_mode_map = self.modes
        end
        if is_enabled then
            self:update_modes(session)
        end
    end
end

return M
