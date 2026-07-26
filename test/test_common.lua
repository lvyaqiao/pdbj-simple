--- common.lua 测试

local script_dir = debug.getinfo(1, "S").source:match("@(.*[/\\])") or ""
package.path = package.path .. ";" .. script_dir .. "../lua/?.lua"
package.path = package.path .. ";" .. script_dir .. "?.lua"

local runner = require("runner")
local common = require("pdbj/common")

print("=== common.lua 模式检测测试 ===\n")

-- 模式基础测试
runner.test("检测到 patterns 表存在", function()
    assert(type(common.TOPUP_PATTERNS) == "table", "TOPUP_PATTERNS must be a table")
    assert(#common.TOPUP_PATTERNS > 0, "TOPUP_PATTERNS must not be empty")
end)

runner.test("检测到 is_topup 函数存在", function()
    assert(type(common.is_topup) == "function", "is_topup must be a function")
end)

-- 顶屏模式测试: Z.. (零声介+韵调)
runner.test("Z.. 模式: 零声介+韵调应触发顶屏", function()
    assert(common.is_topup("Zaa"), "Zaa should trigger topup")
    assert(common.is_topup("Zb1"), "Zb1 should trigger topup")
end)

-- 顶屏模式测试: .Z. (一击字: 声介+ZZ)
runner.test(".Z. 模式: 一击字应触发顶屏", function()
    assert(common.is_topup("aZa"), "aZa should trigger topup")
    assert(common.is_topup("oZo"), "oZo should trigger topup")
end)

-- 顶屏模式测试: .[S-X]Z (一击字: 声介+单字母+Z)
runner.test(".[S-X]Z 模式: 特殊一击字变体应触发顶屏", function()
    assert(common.is_topup("aSZ"), "aSZ should trigger topup")
    assert(common.is_topup("aXZ"), "aXZ should trigger topup")
    assert(not common.is_topup("aRZ"), "aRZ should NOT trigger (R not in S-X)")
end)

-- 顶屏模式测试: ..a (两击末尾a结尾)
runner.test("..a 模式: 两击末尾a应触发顶屏", function()
    assert(common.is_topup("aba"), "aba should trigger topup")
    assert(common.is_topup("ZZa"), "ZZa should trigger topup")
end)

-- 顶屏模式测试: ...Z.. (三击编码含Z占位)
runner.test("...Z.. 模式: 三击Z占位应触发顶屏", function()
    assert(common.is_topup("abcZde"), "abcZde should trigger topup")  -- ...Z.. = 6 chars
    assert(common.is_topup("xyzZuv"), "xyzZuv should trigger topup")
end)

-- 顶屏模式测试: ....Z. (四击编码含Z占位)
runner.test("....Z. 模式: 四击Z占位应触发顶屏", function()
    assert(common.is_topup("abcdZe"), "abcdZe should trigger topup")
end)

-- 顶屏模式测试: .....Z (五击编码含Z占位)
runner.test(".....Z 模式: 五击Z占位应触发顶屏", function()
    assert(common.is_topup("abcdeZ"), "abcdeZ should trigger topup")
end)

-- 顶屏模式测试: ......... (九字符以上)
runner.test("......... 模式: 九字符以上应触发顶屏", function()
    assert(common.is_topup("abcdefghi"), "abcdefghi should trigger topup (exactly 9)")
    assert(common.is_topup("ABCDEFGHI"), "ABCDEFGHI should trigger topup (exactly 9)")
end)

-- 不应触发顶屏的边界情况
runner.test("不触发: 空字符串", function()
    assert(not common.is_topup(""), "empty string should not trigger topup")
end)

runner.test("不触发: 短字符串", function()
    assert(not common.is_topup("a"), "single char should not trigger topup")
    assert(not common.is_topup("ab"), "two chars should not trigger topup")
end)

runner.test("不触发: 不匹配的三字符", function()
    assert(not common.is_topup("abc"), "abc should not trigger topup (not ..a)")
    assert(not common.is_topup("abZ"), "abZ should not trigger topup (not .Z.)")
    assert(not common.is_topup("aRY"), "aRY should not trigger topup (not .[S-X]Z)")
end)

-- 回归测试: 与原 topup_processor 中 check_string_format 行为一致
runner.test("回归: 与原 check_string_format 行为一致性", function()
    local old_patterns = {
        "^Z..$",
        "^.Z.$",
        "^.[S-X]Z$",
        "^..a$",
        "^...Z..$",
        "^....Z.$",
        "^.....Z$",
        "^.........$",
    }
    local function old_check(s)
        for _, p in ipairs(old_patterns) do
            if string.match(s, p) then
                return true
            end
        end
        return false
    end

    local test_cases = {
        "Zaa", "aZa", "aSZ", "aXZ", "aba", "abcZde",
        "abcdZe", "abcdeZ", "abcdefghi", "", "a", "ab",
        "abc", "aRZ", "aZZ", "bZZ", "oZZ", "abZ", "aRY",
    }
    for _, tc in ipairs(test_cases) do
        assert(
            common.is_topup(tc) == old_check(tc),
            string.format("Mismatch for input '%s': new=%s old=%s", tc,
                tostring(common.is_topup(tc)), tostring(old_check(tc)))
        )
    end
end)

-- 验证 speller 层模式与 processor 层模式的一致性
runner.test("speller 模式是 topup 模式的子集", function()
    -- SPELLER_AUTO_SELECT_PATTERN 匹配的所有字符串都应被 TOPUP_PATTERNS 覆盖
    local speller_pat = common.SPELLER_AUTO_SELECT_PATTERN
    assert(type(speller_pat) == "string", "SPELLER_AUTO_SELECT_PATTERN must be a string")
    assert(#speller_pat > 0, "SPELLER_AUTO_SELECT_PATTERN must not be empty")

    -- 测试每种 speller 子模式
    local cases = {
        -- .Z. (一击字)
        { code = "aZa", desc = "one-stroke char (aZZ-like)" },
        { code = "oZo", desc = "one-stroke char (oZZ-like)" },
        -- Z.. (零声介)
        { code = "Zaa", desc = "zero-initial + rhyme" },
        { code = "Zb1", desc = "zero-initial + rhyme variant" },
        -- ..a (两击末尾a)
        { code = "aba", desc = "two-stroke ending in a" },
        -- ....+ (四字符以上)
        { code = "abcd", desc = "4 chars exactly" },
        { code = "abcde", desc = "5 chars" },
        { code = "abcdefgh", desc = "8 chars" },
    }
    for _, c in ipairs(cases) do
        local match_speller = string.match(c.code, speller_pat)
        local match_topup = common.is_topup(c.code)
        if match_speller then
            assert(match_topup,
                string.format("speller matched '%s' (%s) but topup did not", c.code, c.desc))
        end
    end
end)

-- 验证 YAML 与 Lua 中 auto_select_pattern 字符串完全相等
runner.test("auto_select_pattern 与 common.SPELLER_AUTO_SELECT_PATTERN 精确一致", function()
    local f = io.open("pdbj.schema.yaml", "r")
    if not f then
        f = io.open("../pdbj.schema.yaml", "r")
    end
    assert(f, "cannot open pdbj.schema.yaml from CWD or parent dir")
    local content = f:read("*all")
    f:close()

    local yaml_pattern = content:match("auto_select_pattern:%s*'([^']+)'")
    assert(yaml_pattern, "failed to extract auto_select_pattern from pdbj.schema.yaml")

    assert(yaml_pattern == common.SPELLER_AUTO_SELECT_PATTERN,
        string.format(
            "auto_select_pattern MISMATCH!\n" ..
            "  YAML (pdbj.schema.yaml):      '%s'\n" ..
            "  Lua  (common.lua):             '%s'\n" ..
            "  Please sync and try again.",
            yaml_pattern, common.SPELLER_AUTO_SELECT_PATTERN))
end)

runner.summary()
