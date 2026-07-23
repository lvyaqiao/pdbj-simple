--- 拼读简并 共享模块
--- 提供自动上屏(顶屏)模式匹配、编码映射等公共功能

local common = {}

--- 自动上屏(顶屏) 编码格式检测
--- 与 speller.auto_select_pattern 协同工作
--- 匹配以下格式时触发自动提交:
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
