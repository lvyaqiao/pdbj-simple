-- calc/calculus.lua
-- 高等数学：统计、导数近似、数值积分、Runge-Kutta ODE 求解
-- 依赖 mathlib: round, abs, sqrt

local M = require("pdbj/calc/mathlib")
local round = M.round
local abs = M.abs
local sqrt = M.sqrt

-- # Statistics
local fac = function (n)
  local acc = 1
  for i = 2,n do
    acc = acc * i
  end
  return acc
end

local nPr = function (n, r)
  return fac(n) / fac(n - r)
end

local nCr = function (n, r)
  return nPr(n,r) / fac(r)
end

local MSE = function (t)
  local ss = 0
  local s = 0
  local n = #t
  for k,v in ipairs(t) do
    ss = ss + v*v
    s = s + v
  end
  return sqrt((n*ss - s*s) / (n*n))
end

-- # Calculus
-- Linear approximation
local lapproxd = function (f, delta)
  local delta = delta or 1e-8
  return function (x)
           return (f(x+delta) - f(x)) / delta
         end
end

-- Symmetric approximation
local sapproxd = function (f, delta)
  local delta = delta or 1e-8
  return function (x)
           return (f(x+delta) - f(x-delta)) / delta / 2
         end
end

-- 近似導數
local deriv = function (f, delta, dc)
  dc = dc or 1e-4
  local fd = sapproxd(f, delta)
  return function (x)
           return round(fd(x), dc)
         end
end

-- Trapezoidal rule
local trapzo = function (f, a, b, n)
  local dif = b - a
  local acc = 0
  for i = 1, n-1 do
    acc = acc + f(a + dif * (i/n))
  end
  acc = acc * 2 + f(a) + f(b)
  acc = acc * dif / n / 2
  return acc
end

-- 近似積分
local integ = function (f, delta, dc)
  delta = delta or 1e-4
  dc = dc or 1e-4
  return function (a, b)
           if b == nil then
             b = a
             a = 0
           end
           local n = round(abs(b - a) / delta)
           return round(trapzo(f, a, b, n), dc)
         end
end

-- Runge-Kutta
local rk4 = function (f, timestep)
  local timestep = timestep or 0.01
  return function (start_x, start_y, time)
           local x = start_x
           local y = start_y
           local t = time
           for i = 0, t, timestep do
             local k1 = f(x, y)
             local k2 = f(x + (timestep/2), y + (timestep/2)*k1)
             local k3 = f(x + (timestep/2), y + (timestep/2)*k2)
             local k4 = f(x + timestep, y + timestep*k3)
             y = y + (timestep/6)*(k1 + 2*k2 + 2*k3 + k4)
             x = x + timestep
           end
           return y
         end
end

return {
  fac = fac, nPr = nPr, nCr = nCr, MSE = MSE,
  lapproxd = lapproxd, sapproxd = sapproxd, deriv = deriv,
  trapzo = trapzo, integ = integ, rk4 = rk4,
}
