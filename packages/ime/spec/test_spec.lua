package.path = package.path .. ';lua/?.lua'

local Key = require "ime.key".Key
local UI = require "ime.ui".UI

-- luacheck: ignore 113
---@diagnostic disable: undefined-global
describe("test", function()
    it("tests parse key", function()
        local key = Key:from_vim "<C-M-S>"
        assert.are.equal(key.code, string.byte('s'))
        assert.are.equal(key.mask, 2 ^ 2 + 2 ^ 3)
    end)
    it("tests draw ui", function()
        local ui = UI()
        local context = {
            composition = {
                length = 1,
                cursor_pos = 1,
                sel_start = 0,
                sel_end = 1,
                preedit = "w",
            },
            menu = {
                page_size = 10,
                page_no = 0,
                is_last_page = false,
                highlighted_candidate_index = 0,
                num_candidates = 10,
                candidates = {
                    { text = "我" },
                    { text = "为" },
                    { text = "玩" },
                    { text = "问" },
                    { text = "无" },
                    { text = "万" },
                    { text = "完" },
                    { text = "网" },
                    { text = "王" },
                    { text = "外" },
                }
            }
        }
        local lines, col = ui:draw(context)
        assert.are.equal(lines[1], "w|")
        assert.are.equal(lines[2], "[① 我]② 为 ③ 玩 ④ 问 ⑤ 无 ⑥ 万 ⑦ 完 ⑧ 网 ⑨ 王 ⓪ 外 |>")
        assert.are.equal(col, 0)
    end)
end)
