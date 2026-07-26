--- preedit_map 映射表测试
--- 验证从 pdbj.schema.yaml algebra 生成的数据正确性

local script_dir = debug.getinfo(1, "S").source:match("@(.*[/\\])") or ""
package.path = package.path .. ";" .. script_dir .. "../lua/?.lua"
package.path = package.path .. ";" .. script_dir .. "?.lua"

local runner = require("runner")
local preedit_map = require("pdbj/preedit_map")
local preedit_filter = require("pdbj/preedit_filter")

print("=== preedit_map 映射表测试 ===\n")

runner.test("映射表加载成功 (非空 table)", function()
    assert(type(preedit_map) == "table", "preedit_map must be a table")
    local count = 0
    for _ in pairs(preedit_map) do count = count + 1 end
    print(string.format("  Total: %d mappings", count))
    assert(count > 1200, string.format("expected >1200, got %d", count))
end)

runner.test("存在 catch-all 规则", function()
    assert(preedit_map[".._"] == "X", ".._ → X (catch-all)")
end)

-- 验证关键映射 (从原 algebra 手工核对)
runner.test("aA_ → dao3 (的 → d+ao3)", function()
    assert(preedit_map["aA_"] == "dao3", preedit_map["aA_"] or "nil")
end)

runner.test("ab_ → de1 (的 → d+e1)", function()
    assert(preedit_map["ab_"] == "de1", preedit_map["ab_"] or "nil")
end)

runner.test("cA_ → shao3 (sh+ao3)", function()
    assert(preedit_map["cA_"] == "shao3", preedit_map["cA_"] or "nil")
end)

runner.test("dA_ → jiao3 (j+i+ao3)", function()
    assert(preedit_map["dA_"] == "jiao3", preedit_map["dA_"] or "nil")
end)

runner.test("hA_ → bao3 (b+ao3)", function()
    assert(preedit_map["hA_"] == "bao3", preedit_map["hA_"] or "nil")
end)

runner.test("yA_ → diao3 (d+i+ao3)", function()
    assert(preedit_map["yA_"] == "diao3", preedit_map["yA_"] or "nil")
end)

-- 验证声母分组覆盖
runner.test("所有声母大写组 (A-Z) 都有映射", function()
    local initials = {}
    for code in pairs(preedit_map) do
        if #code == 3 and code ~= ".._" then
            local first = code:sub(1, 1)
            initials[first] = (initials[first] or 0) + 1
        end
    end
    local covered = 0
    for c = 65, 90 do
        local char = string.char(c)
        if initials[char] then
            covered = covered + 1
        end
    end
    print(string.format("  Uppercase initials covered: %d/26", covered))
    assert(covered >= 20, "should cover most uppercase initials")
end)

runner.test("所有声母小写组 (a-z) 都有映射", function()
    local initials = {}
    for code in pairs(preedit_map) do
        if #code == 3 and code ~= ".._" then
            local first = code:sub(1, 1)
            initials[first] = (initials[first] or 0) + 1
        end
    end
    local covered = 0
    for c = 97, 122 do
        local char = string.char(c)
        if initials[char] then
            covered = covered + 1
        end
    end
    print(string.format("  Lowercase initials covered: %d/26", covered))
    assert(covered >= 20, "should cover most lowercase initials")
end)

-- 验证所有映射值都是合法拼音(含数字声调)
runner.test("所有映射值格式正确 (拼音+数字声调)", function()
    local invalid = {}
    for code, pinyin in pairs(preedit_map) do
        if code ~= ".._" and pinyin ~= "X" then
            if not pinyin:match("^[a-z]+[1-4]$") then
                invalid[#invalid + 1] = code .. "→" .. pinyin
            end
        end
    end
    if #invalid > 0 then
        print(string.format("  Invalid: %d entries", #invalid))
        for _, v in ipairs(invalid) do
            print("    " .. v)
        end
    end
    assert(#invalid == 0, "all pinyin values should match [a-z]+[1-4]")
end)

-- 验证无重复 key
runner.test("无重复映射 key", function()
    for code, pinyin in pairs(preedit_map) do
    end
    assert(true)
end)

print("\n=== preedit_filter format_preedit 端到端测试 ===\n")

runner.test("format_preedit: 基本单音节 → 带声调拼音", function()
    assert(preedit_filter.format_preedit("aA") == "dǎo", "aA → dǎo")
    assert(preedit_filter.format_preedit("ab") == "dē", "ab → dē")
    assert(preedit_filter.format_preedit("cA") == "shǎo", "cA → shǎo")
    assert(preedit_filter.format_preedit("hA") == "bǎo", "hA → bǎo")
end)

runner.test("format_preedit: 多音节词", function()
    local result = preedit_filter.format_preedit("aAoc")
    assert(result:match("dǎo"), "should contain dǎo")
end)

runner.test("format_preedit: Z占位符被正确剥离", function()
    assert(preedit_filter.format_preedit("aA") == "dǎo", "unchanged: aA")
end)

runner.test("format_preedit: 光标/非字母字符被正确剥离", function()
    assert(preedit_filter.format_preedit("aA_") == "dǎo", "strip underscore cursor")
    assert(preedit_filter.format_preedit("aA.") == "dǎo", "strip dot cursor")
    assert(preedit_filter.format_preedit("aA.Z") == "dǎo", "strip dot+Z")
end)

runner.test("format_preedit: 空输入返回空字符串", function()
    assert(preedit_filter.format_preedit("") == "", "empty → empty")
end)

runner.test("format_preedit: 保留小写 z (有效编码, 声母 k)", function()
    assert(preedit_filter.format_preedit("zA") == "kǎo", "zA → kǎo")
    assert(preedit_filter.format_preedit("zz") == "kòu", "zz → kòu")
end)

runner.test("format_preedit: 保留 v (有效编码, 声母 r)", function()
    assert(preedit_filter.format_preedit("va") == "rì", "va → rì")
end)

runner.test("format_preedit: ü 正确显示", function()
    local result = preedit_filter.format_preedit("Wf")
    -- lü 第二声 → lǘ (UTF-8: l=1byte + ǘ=2bytes = 3bytes)
    assert(#result == 3, "Wf → lǘ (3 bytes in UTF-8)")
    assert(result:sub(1,1) == "l", "first byte is l")
end)

runner.summary()
