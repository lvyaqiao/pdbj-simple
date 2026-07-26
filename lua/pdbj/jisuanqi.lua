-- Rime Script >https://github.com/baopaau/rime-lua-collection/blob/master/calculator_translator.lua
-- 簡易計算器（執行安全沙箱化的 Lua 表達式）
--
-- 格式：=<exp>
-- Lambda語法糖：\<arg>.<exp>|
--
-- 例子：
-- =1+1 輸出 2
-- =floor(9^(8/7)*cos(deg(6))) 輸出 -3
-- =e^pi>pi^e 輸出 true
-- =max({1,7,2}) 輸出 7
-- =map({1,2,3},\x.x^2|) 輸出 {1, 4, 9}
-- =map(range(-5,5),\x.x*pi/4|,deriv(sin)) 輸出 {-0.7071, -1, -0.7071, 0, 0.7071, 1, 0.7071, 0, -0.7071, -1}
-- =$(range(-50,50))(map,\x.x/100|,\x.-60*x^2-16*x+20|)(max)() 輸出 21.066

-- 需在方案增加 `recognizer/patterns/expression: "^=.*$"`

local mathlib    = require("pdbj/calc/mathlib")
local calculus   = require("pdbj/calc/calculus")
local functional = require("pdbj/calc/functional")
local formatter  = require("pdbj/calc/formatter")

-- 白名單沙箱：用戶表達式只能訪問這三個模塊中的函數
local sandbox = {}
for k, v in pairs(mathlib) do
  if k ~= "path" then sandbox[k] = v end
end
for k, v in pairs(calculus) do
  sandbox[k] = v
end
for k, v in pairs(functional) do
  sandbox[k] = v
end

local greedy = true

local function calculator_translator(input, seg)
  if string.sub(input, 1, 1) ~= "=" then return end

  local expfin = greedy or string.sub(input, -1, -1) == ";"
  local exp = (greedy or not expfin) and string.sub(input, 2, -1) or string.sub(input, 2, -2)

  -- 空格輸入可能
  exp = exp:gsub("#", " ")

  if not expfin then return end

  local expe = exp
  -- 鏈式調用語法糖
  expe = expe:gsub("%$", " chain ")
  -- lambda語法糖
  do
    local count
    repeat
      expe, count = expe:gsub("\\%s*([%a%d%s,_]-)%s*%.(.-)|", " (function (%1) return %2 end) ")
    until count == 0
  end

  local fn, compile_err = load("return " .. expe, "=calc", "t", sandbox)
  if not fn then return end
  local ok, result = pcall(fn)
  if not ok or result == nil then return end

  local result_type = type(result)
  result = formatter.serialize(result)
  yield(Candidate("number", seg.start, seg._end, exp .. "=" .. result, "等式", "123"))
  yield(Candidate("number", seg.start, seg._end, result, "答案"))
  if result_type == "number" then
    yield(Candidate("number", seg.start, seg._end, formatter.speakMoney(result), " 金额"))
  end
end

return calculator_translator
