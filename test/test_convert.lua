--- convert.lua / jisuanqi.lua 单位换算测试

local script_dir = debug.getinfo(1, "S").source:match("@(.*[/\\])") or ""
package.path = package.path .. ";" .. script_dir .. "../lua/?.lua"
package.path = package.path .. ";" .. script_dir .. "?.lua"

local runner = require("runner")
local convert = require("pdbj/calc/convert").convert

print("=== 单位换算测试 ===\n")

local function assert_approx(actual, expected, label)
  if type(actual) == "number" and type(expected) == "number" then
    local diff = math.abs(actual - expected)
    local ok = diff < 0.02
    if not ok then
      error(string.format("%s: expected ~%.4f, got %.4f (diff=%.4f)", label, expected, actual, diff))
    end
  else
    if actual ~= expected then
      error(string.format("%s: expected %s, got %s", label, tostring(expected), tostring(actual)))
    end
  end
end

-- 长度
runner.test("长度: 1km = 1000m", function()
  assert_approx(convert(1, "km", "m"), 1000, "1km->m")
  assert_approx(convert(100, "cm", "m"), 1, "100cm->m")
  assert_approx(convert(1, "m", "cm"), 100, "1m->cm")
  assert_approx(convert(1, "mm", "cm"), 0.1, "1mm->cm")
end)

runner.test("长度: 英制 <-> 公制", function()
  assert_approx(convert(100, "km", "mile"), 62.1371, "100km->mile")
  assert_approx(convert(1, "inch", "cm"), 2.54, "1inch->cm")
  assert_approx(convert(1, "ft", "inch"), 12, "1ft->inch")
  assert_approx(convert(1, "ft", "m"), 0.3048, "1ft->m")
  assert_approx(convert(1, "yard", "ft"), 3, "1yard->ft")
end)

runner.test("长度: 市制", function()
  assert_approx(convert(1, "chi", "cun"), 10, "1chi->cun")
  assert_approx(convert(1, "chi", "cm"), 33.333, "1chi->cm")
  assert_approx(convert(1, "zhang", "chi"), 10, "1zhang->chi")
  assert_approx(convert(1, "li", "m"), 500, "1li->m")
  assert_approx(convert(1, "li", "km"), 0.5, "1li->km")
end)

runner.test("长度: 别名", function()
  assert_approx(convert(1, "in", "cm"), 2.54, "1in->cm")
  assert_approx(convert(1, "yd", "m"), 0.9144, "1yd->m")
  assert_approx(convert(1, "mi", "km"), 1.609344, "1mi->km")
  assert_approx(convert(1, "feet", "inch"), 12, "1feet->inch")
  assert_approx(convert(1, "miles", "km"), 1.609344, "1miles->km")
end)

-- 重量
runner.test("重量: 公制", function()
  assert_approx(convert(1, "kg", "g"), 1000, "1kg->g")
  assert_approx(convert(1, "ton", "kg"), 1000, "1ton->kg")
  assert_approx(convert(1, "mg", "g"), 0.001, "1mg->g")
  assert_approx(convert(1, "t", "kg"), 1000, "1t->kg")
end)

runner.test("重量: 英制 <-> 公制", function()
  assert_approx(convert(1, "lb", "kg"), 0.45359, "1lb->kg")
  assert_approx(convert(1, "kg", "lb"), 2.20462, "1kg->lb")
  assert_approx(convert(1, "oz", "g"), 28.3495, "1oz->g")
end)

runner.test("重量: 市制", function()
  assert_approx(convert(1, "jin", "g"), 500, "1jin->g")
  assert_approx(convert(1, "jin", "kg"), 0.5, "1jin->kg")
  assert_approx(convert(1, "kg", "jin"), 2, "1kg->jin")
  assert_approx(convert(1, "liang", "g"), 50, "1liang->g")
  assert_approx(convert(1, "jin", "liang"), 10, "1jin->liang")
end)

runner.test("重量: 别名", function()
  assert_approx(convert(1, "lbs", "kg"), 0.45359, "1lbs->kg")
end)

-- 温度
runner.test("温度: C <-> F", function()
  assert_approx(convert(0, "C", "F"), 32, "0C->F")
  assert_approx(convert(100, "C", "F"), 212, "100C->F")
  assert_approx(convert(32, "F", "C"), 0, "32F->C")
  assert_approx(convert(37, "C", "F"), 98.6, "37C->F")
  assert_approx(convert(-40, "C", "F"), -40, "-40C->F")
end)

runner.test("温度: C <-> K", function()
  assert_approx(convert(0, "C", "K"), 273.15, "0C->K")
  assert_approx(convert(100, "C", "K"), 373.15, "100C->K")
  assert_approx(convert(273.15, "K", "C"), 0, "273.15K->C")
end)

runner.test("温度: F <-> K", function()
  assert_approx(convert(32, "F", "K"), 273.15, "32F->K")
  assert_approx(convert(212, "F", "K"), 373.15, "212F->K")
end)

-- 面积
runner.test("面积", function()
  assert_approx(convert(1, "km2", "ha"), 100, "1km2->ha")
  assert_approx(convert(1, "ha", "m2"), 10000, "1ha->m2")
  assert_approx(convert(1, "mu", "m2"), 666.667, "1mu->m2")
  assert_approx(convert(1, "acre", "m2"), 4046.86, "1acre->m2")
end)

-- 容积
runner.test("容积", function()
  assert_approx(convert(1, "l", "ml"), 1000, "1l->ml")
  assert_approx(convert(1, "gal", "l"), 3.7854, "1gal->l")
  assert_approx(convert(1, "m3", "l"), 1000, "1m3->l")
  assert_approx(convert(1, "L", "ml"), 1000, "1L->ml")
end)

-- 速度
runner.test("速度", function()
  assert_approx(convert(100, "kmh", "mps"), 27.78, "100kmh->mps")
  assert_approx(convert(1, "mps", "kmh"), 3.6, "1mps->kmh")
  assert_approx(convert(60, "mph", "kmh"), 96.56, "60mph->kmh")
end)

-- 数据
runner.test("数据", function()
  assert_approx(convert(1, "gb", "mb"), 1024, "1GB->MB")
  assert_approx(convert(1, "tb", "gb"), 1024, "1TB->GB")
  assert_approx(convert(1, "mb", "kb"), 1024, "1MB->KB")
  assert_approx(convert(1, "kb", "byte"), 1024, "1KB->byte")
end)

-- 自身换算
runner.test("自身换算: 同单位返回原值", function()
  assert_approx(convert(100, "m", "m"), 100, "100m->m")
  assert_approx(convert(50, "C", "C"), 50, "50C->C")
  assert_approx(convert(999, "gb", "gb"), 999, "999gb->gb")
end)

-- 错误处理
runner.test("错误: 未知单位", function()
  local ok, err = pcall(convert, 1, "xxx", "km")
  assert(not ok, "should error on unknown unit")
end)

runner.test("错误: 跨类别换算", function()
  local ok, err = pcall(convert, 1, "km", "kg")
  assert(not ok, "should error on cross-category")
end)

-- >> 语法糖预处理测试
runner.test(">> 语法糖: 预处理转换正确", function()
  local pattern = "([%d.]+)([%a]+)>>([%a]+)"
  local function preprocess(exp)
    return exp:gsub(pattern, function(n, f, t)
      return 'convert(' .. n .. ', "' .. f .. '", "' .. t .. '")'
    end)
  end

  local result = preprocess("100km>>mile")
  assert(result == 'convert(100, "km", "mile")', "100km>>mile: " .. result)

  result = preprocess("32F>>C")
  assert(result == 'convert(32, "F", "C")', "32F>>C: " .. result)

  result = preprocess("1.5inch>>cm")
  assert(result == 'convert(1.5, "inch", "cm")', "1.5inch>>cm: " .. result)

  result = preprocess(".5m>>cm")
  assert(result == 'convert(.5, "m", "cm")', ".5m>>cm: " .. result)
end)

runner.test(">> 语法糖: 不干扰普通表达式", function()
  local pattern = "([%d.]+)([%a]+)>>([%a]+)"
  local function preprocess(exp)
    return exp:gsub(pattern, function(n, f, t)
      return 'convert(' .. n .. ', "' .. f .. '", "' .. t .. '")'
    end)
  end

  assert(preprocess("1+1") == "1+1", "1+1 untouched")
  assert(preprocess("3>>1") == "3>>1", "3>>1 untouched") -- 数字+数字
  assert(preprocess("cos(0)") == "cos(0)", "cos(0) untouched")
end)

runner.summary()
