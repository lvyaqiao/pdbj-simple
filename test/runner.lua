--- 轻量级 Lua 测试运行器
--- 不依赖第三方库，使用标准 Lua assert

local runner = {}

local passed = 0
local failed = 0
local fail_details = {}

function runner.test(name, fn)
    local ok, err = pcall(fn)
    if ok then
        passed = passed + 1
        print(string.format("  [PASS] %s", name))
    else
        failed = failed + 1
        table.insert(fail_details, { name = name, error = err })
        print(string.format("  [FAIL] %s: %s", name, err))
    end
end

function runner.summary()
    print(string.format("\n=== Results: %d passed, %d failed ===", passed, failed))
    if failed > 0 then
        print("\nFailures:")
        for _, f in ipairs(fail_details) do
            print(string.format("  - %s: %s", f.name, f.error))
        end
        os.exit(1)
    end
end

return runner
