--- assembly.lua - 部首标注 filter
--- 为候选词附加部首注释 (如 "［扌］")
---
--- 数据来源: lua/pdbj/assembly_map.lua (由 tools/gen_assembly_map.lua 根据
---   lua/pdbj/assembly.txt 生成)

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
