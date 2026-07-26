-- calc/mathlib.lua
-- 基础数学函数、数组工具、迭代器和系统函数
-- 不依赖其他 calc 模块

local cos = math.cos
local sin = math.sin
local tan = math.tan
local acos = math.acos
local asin = math.asin
local atan = math.atan
local rad = math.rad
local deg = math.deg

local abs = math.abs
local floor = math.floor
local ceil = math.ceil
local mod = math.fmod
local trunc = function (x, dc)
  if dc == nil then
    return math.modf(x)
  end
  return x - mod(x, dc)
end

local round = function (x, dc)
  dc = dc or 1
  local dif = mod(x, dc)
  if abs(dif) > dc / 2 then
    return x < 0 and x - dif - dc or x - dif + dc
  end
  return x - dif
end

local random = math.random
local randomseed = math.randomseed

local inf = math.huge
local MAX_INT = math.maxinteger
local MIN_INT = math.mininteger
local pi = math.pi
local sqrt = math.sqrt
local exp = math.exp
local e = exp(1)
local ln = math.log
local log = function (x, base)
  base = base or 10
  return ln(x)/ln(base)
end

local min = function (arr)
  local m = inf
  for k, x in ipairs(arr) do
   m = x < m and x or m
  end
  return m
end

local max = function (arr)
  local m = -inf
  for k, x in ipairs(arr) do
   m = x > m and x or m
  end
  return m
end

local sum = function (t)
  local acc = 0
  for k,v in ipairs(t) do
    acc = acc + v
  end
  return acc
end

local avg = function (t)
  return sum(t) / #t
end

local isinteger = function (x)
  return math.fmod(x, 1) == 0
end

-- iterator . array
local array = function (...)
  local arr = {}
  for v in ... do
    arr[#arr + 1] = v
  end
  return arr
end

-- iterator <- [from, to)
local irange = function (from,to)
  if to == nil then
    to = from
    from = 0
  end
  local i = from - 1
  to = to - 1
  return function()
    if i < to then
      i = i + 1
      return i
    end
  end
end

-- array <- [from, to)
local range = function (from, to)
  return array(irange(from, to))
end

-- array . reversed iterator
local irev = function (arr)
  local i = #arr + 1
  return function()
    if i > 1 then
      i = i - 1
      return arr[i]
    end
  end
end

-- array . reversed array
local arev = function (arr)
  return array(irev(arr))
end

local date = os.date
local time = os.time
local path = function ()
  return debug.getinfo(1).source:match("@?(.*/)")
end

return {
  cos = cos, sin = sin, tan = tan,
  acos = acos, asin = asin, atan = atan,
  rad = rad, deg = deg,
  abs = abs, floor = floor, ceil = ceil,
  mod = mod, trunc = trunc, round = round,
  random = random, randomseed = randomseed,
  inf = inf, MAX_INT = MAX_INT, MIN_INT = MIN_INT,
  pi = pi, sqrt = sqrt, exp = exp, e = e,
  ln = ln, log = log,
  min = min, max = max, sum = sum, avg = avg,
  isinteger = isinteger,
  array = array, irange = irange, range = range,
  irev = irev, arev = arev,
  date = date, time = time, path = path,
}
