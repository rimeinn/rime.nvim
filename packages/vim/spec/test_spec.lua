package.path = package.path .. ';lua/?.lua'

local fn = require "vim.fn"

-- luacheck: ignore 113
---@diagnostic disable: undefined-global
describe("test fn", function()
    it("tests strwidth", function()
        assert.are.equal(fn.strwidth "算法", 4)
    end)
    it("tests trim", function()
        assert.are.equal(fn.trim "  A B ", "A B")
    end)
end)
