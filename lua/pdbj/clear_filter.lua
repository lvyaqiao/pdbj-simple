local common = require("pdbj/common")

local function filter(input, env)
    local context = env.engine.context
    for cand in input:iter() do
        yield(cand)
    end
    if common.is_topup(context.input) then
        if not context:get_selected_candidate() then
            context:clear()
        end
    end
end

return filter
