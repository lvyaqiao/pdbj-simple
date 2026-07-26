-- calc/functional.lua
-- 函数式编程工具：map, filter, fold, chain
-- 依赖 mathlib: irev

local M = require("pdbj/calc/mathlib")
local irev = M.irev

local map = function (t, ...)
  local ta = {}
  for k,v in pairs(t) do
    local tmp = v
    for _,f in pairs({...}) do tmp = f(tmp) end
    ta[k] = tmp
  end
  return ta
end

local filter = function (t, ...)
  local ta = {}
  local i = 1
  for k,v in pairs(t) do
    local erase = false
    for _,f in pairs({...}) do
      if not f(v) then
        erase = true
        break
      end
    end
    if not erase then
      ta[i] = v
      i = i + 1
    end
  end
  return ta
end

-- e.g: foldr({2,3},\n,x.x^n|,2) = 81
local foldr = function (t, f, val)
  for k,v in pairs(t) do
    val = f(val, v)
  end
  return val
end

-- e.g: foldl({2,3},\n,x.x^n|,2) = 512
local foldl = function (t, f, val)
  for v in irev(t) do
    val = f(val, v)
  end
  return val
end

-- 調用鏈生成函數（HOF for method chaining）
-- e.g: chain(range(-5,5))(map,\x.x/5|)(map,sin)(map,\x.e^x*10|)(map,floor)()
--    = floor(map(map(map(range(-5,5),\x.x/5|),sin),\x.e^x*10|))
--    = {4, 4, 5, 6, 8, 10, 12, 14, 17, 20}
-- 可以用 $ 代替 chain
local chain = function (t)
  local ta = t
  local function cf(f, ...)
    if f ~= nil then
      ta = f(ta, ...)
      return cf
    else
      return ta
    end
  end
  return cf
end

return {
  map = map,
  filter = filter,
  foldr = foldr,
  foldl = foldl,
  chain = chain,
}
