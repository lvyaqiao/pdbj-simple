--- assembly.lua - 部首标注 filter
--- 为候选词附加部首注释 (如 "［扌］")
---
--- 数据来源: lua/pdbj/assembly_map.lua (手写维护的映射表)

local radicals = require("pdbj/assembly_map")

local this = {
    lookup_tags = { "extra" },
}

function this.func(translation, env)
    for candidate in translation:iter() do
        local radical = radicals[candidate.text]
        if radical then
            candidate.comment = candidate.comment .. string.format("［%s］", radical)
        end
        yield(candidate)
    end
end

return this
