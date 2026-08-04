--- preedit_filter.lua - 替代 translator.preedit_format algebra 的 Lua filter
--- 将抽象编码 (如 aA, ab 等) 转换为带声调的拼音显示
---
--- 数据来源: lua/pdbj/preedit_map.lua (手写维护的映射表)
---
--- 用法:
---   1. 测试: lua -e "pf=require('pdbj.preedit_filter') print(pf.format_preedit('aA'))"
---   2. Rime: 在 schema engine.filters 中添加 lua_filter@*pdbj.preedit_filter

local preedit_map = require("pdbj/preedit_map")

--- 声调数字 → Unicode 声调符号
local tone_marks = {
    a = { [1] = "ā", [2] = "á", [3] = "ǎ", [4] = "à" },
    e = { [1] = "ē", [2] = "é", [3] = "ě", [4] = "è" },
    o = { [1] = "ō", [2] = "ó", [3] = "ǒ", [4] = "ò" },
    i = { [1] = "ī", [2] = "í", [3] = "ǐ", [4] = "ì" },
    u = { [1] = "ū", [2] = "ú", [3] = "ǔ", [4] = "ù" },
    v = { [1] = "ǖ", [2] = "ǘ", [3] = "ǚ", [4] = "ǜ" },
}

--- 将韵腹+数字声调替换为 Unicode 声调符号
local function apply_tone_marks(s)
    return (s:gsub("([aeiouv])([1-4])", function(vowel, tone)
        local t = tonumber(tone)
        return tone_marks[vowel] and tone_marks[vowel][t] or vowel .. tone
    end))
end

--- 将数字声调移到韵腹之后
--- e.g. "ao3" → "a3o", "ang2" → "a2ng", "ai4" → "a4i", "er4" → "e4r"
local function reposition_tone(s)
    s = s:gsub("([aeo])([iuo])([1-4])", "%1%3%2")
    s = s:gsub("([aeiou])(ng?)([1-4])", "%1%3%2")
    s = s:gsub("(e)(r)([1-4])", "%1%3%2")
    return s
end

local function replace_v(s)
    return (s:gsub("v", "ü"))
end

--- 格式化单个音节编码为拼音显示
--- @param code string 形如 "aA" 的两字符编码
--- @return string 拼音显示 (如 "dǎo"), 未匹配时返回原始编码
local function format_syllable(code)
    if #code < 2 then return code end

    local pinyin = preedit_map[code]

    if not pinyin then
        return code
    end

    pinyin = reposition_tone(pinyin)
    pinyin = apply_tone_marks(pinyin)
    pinyin = replace_v(pinyin)
    return pinyin
end

--- 格式化预编辑显示: 将抽象编码转换为拼音显示
--- 编码按 2 字符一组分割，每组映射为一个音节
--- @param code string 抽象编码 (e.g. "aA", "aAoc"), 可能含光标标记 (. _ 空格)
--- @return string 格式化后的拼音显示 (e.g. "dǎo", "dǎo lì")
function format_preedit(code)
    if not code or code == "" then
        return ""
    end

    -- 剥离非字母字符和占位符 Z
    --   a-zA-Y = 保留所有编码字母 (a-z 小写声母/韵调, A-Y 大写声母/韵调)
    --   Z = 占位符 (无韵调/无声介), 对拼音显示无意义
    code = code:gsub("[^a-zA-Y]+", "")

    if code == "" then
        return ""
    end

    local result = {}
    local pos = 1
    while pos <= #code do
        local chunk = code:sub(pos, pos + 1)
        table.insert(result, format_syllable(chunk))
        pos = pos + 2
    end
    return table.concat(result, " ")
end

local this = {}

--- Rime filter 入口: 格式化预编辑显示
function this.func(translation, env)
    for candidate in translation:iter() do
        local code = candidate.preedit or ""
        if code ~= "" then
            candidate.preedit = format_preedit(code)
        end
        yield(candidate)
    end
end

-- 测试用导出
this.format_preedit = format_preedit
this.preedit_map = preedit_map

return this
