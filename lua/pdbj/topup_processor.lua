local common = require("pdbj/common")

local function processor(key_event, env)
    local context = env.engine.context
    local keycode = key_event.keycode
    -- 末尾编码不在字母范围（非拼写输入）时，不触发自动提交
    -- 0x61-0x7a = a-z, 0x41-0x5a = A-Z
    if (keycode < 0x61 or keycode > 0x7a) and (keycode < 0x41 or keycode > 0x5a) then
        return 2
    end
    if common.is_topup(context.input) then
        context:commit()
    end
    return 2
end

return processor
