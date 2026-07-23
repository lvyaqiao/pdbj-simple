--- 拼读简并 共享模块
--- 提供自动上屏(顶屏)模式匹配、编码映射等公共功能
---
--- 注意: 本文件是顶屏规则的唯一真实来源。
--- pdbj.schema.yaml 中的 speller.auto_select_pattern 需与本文件保持一致,
--- 修改本文件时请同步更新 schema。

local common = {}

--- 自动上屏(顶屏) 编码格式检测
--- 与 speller.auto_select_pattern 协同工作:
---   - speller 层匹配后自动选中候选 (auto_select)
---   - processor 层匹配后自动提交已选候选 (commit)
--- 因此 speller 层的模式是 processor 层模式的子集。
---
--- speller 层模式 (写入 pdbj.schema.yaml speller.auto_select_pattern):
common.SPELLER_AUTO_SELECT_PATTERN = "^(.Z.|Z..|..a|....+)$"

--- processor/filter 层模式 (Lua 运行时自动提交):
---   Z..    : 零声介+韵调, e.g. 安(#an1), 耳(#er3)
---   .Z.    : 一击字: 声介+ZZ, e.g. 的(aZZ), 了(oZZ)
---   .[S-X]Z: 一击字: 声介+单字母+Z, 特殊一击字变体
---   ..a    : 两击末尾a结尾 (单手模式)
---   ...Z.. : 三击编码含Z占位
---   ....Z. : 四击编码含Z占位
---   .....Z : 五击编码含Z占位
---   ......... : 长编码九字符以上直接上屏
common.TOPUP_PATTERNS = {
    "^Z..$",
    "^.Z.$",
    "^.[S-X]Z$",
    "^..a$",
    "^...Z..$",
    "^....Z.$",
    "^.....Z$",
    "^.........$",
}

--- 检测编码字符串是否满足自动上屏（顶屏）条件
--- @param s string 当前输入编码
--- @return boolean true 表示满足自动上屏条件
function common.is_topup(s)
    for _, pattern in ipairs(common.TOPUP_PATTERNS) do
        if string.match(s, pattern) then
            return true
        end
    end
    return false
end

return common
