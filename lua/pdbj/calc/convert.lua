-- calc/convert.lua
-- 单位换算（温度、长度、重量、面积、容积、速度、数据）

local units = {
  -- 长度 (base: meter)
  mm    = { cat = "length", to = 0.001 },
  cm    = { cat = "length", to = 0.01 },
  m     = { cat = "length", to = 1 },
  km    = { cat = "length", to = 1000 },
  inch  = { cat = "length", to = 0.0254 },
  ["in"] = { cat = "length", to = 0.0254 },
  ft    = { cat = "length", to = 0.3048 },
  feet  = { cat = "length", to = 0.3048 },
  yard  = { cat = "length", to = 0.9144 },
  yd    = { cat = "length", to = 0.9144 },
  mile  = { cat = "length", to = 1609.344 },
  miles = { cat = "length", to = 1609.344 },
  mi    = { cat = "length", to = 1609.344 },
  chi   = { cat = "length", to = 1 / 3 },
  cun   = { cat = "length", to = 1 / 30 },
  zhang = { cat = "length", to = 10 / 3 },
  li    = { cat = "length", to = 500 },
  -- 重量 (base: gram)
  mg    = { cat = "weight", to = 0.001 },
  g     = { cat = "weight", to = 1 },
  kg    = { cat = "weight", to = 1000 },
  ton   = { cat = "weight", to = 1e6 },
  t     = { cat = "weight", to = 1e6 },
  oz    = { cat = "weight", to = 28.349523125 },
  lb    = { cat = "weight", to = 453.59237 },
  lbs   = { cat = "weight", to = 453.59237 },
  jin   = { cat = "weight", to = 500 },
  liang = { cat = "weight", to = 50 },
  -- 温度 (special)
  C = { cat = "temp" },
  F = { cat = "temp" },
  K = { cat = "temp" },
  -- 面积 (base: sq meter)
  m2   = { cat = "area", to = 1 },
  km2  = { cat = "area", to = 1e6 },
  ha   = { cat = "area", to = 10000 },
  mu   = { cat = "area", to = 2000 / 3 },
  acre = { cat = "area", to = 4046.8564224 },
  -- 容积 (base: liter)
  ml  = { cat = "volume", to = 0.001 },
  l   = { cat = "volume", to = 1 },
  L   = { cat = "volume", to = 1 },
  gal = { cat = "volume", to = 3.785411784 },
  m3  = { cat = "volume", to = 1000 },
  -- 速度 (base: m/s)
  mps = { cat = "speed", to = 1 },
  kmh = { cat = "speed", to = 1 / 3.6 },
  mph = { cat = "speed", to = 0.44704 },
  -- 数据 (base: byte)
  byte = { cat = "data", to = 1 },
  kb   = { cat = "data", to = 1024 },
  mb   = { cat = "data", to = 1048576 },
  gb   = { cat = "data", to = 1073741824 },
  tb   = { cat = "data", to = 1099511627776 },
}

local function temp_convert(value, from, to)
  if from == to then return value end
  if from == "C" then
    if to == "F" then return value * 9 / 5 + 32 end
    if to == "K" then return value + 273.15 end
  elseif from == "F" then
    if to == "C" then return (value - 32) * 5 / 9 end
    if to == "K" then return (value - 32) * 5 / 9 + 273.15 end
  elseif from == "K" then
    if to == "C" then return value - 273.15 end
    if to == "F" then return (value - 273.15) * 9 / 5 + 32 end
  end
end

local function convert(value, from, to)
  local uf = units[from]
  local ut = units[to]
  if not uf then error("未知单位: " .. from) end
  if not ut then error("未知单位: " .. to) end
  if uf.cat ~= ut.cat then error("不同类别无法换算: " .. uf.cat .. " -> " .. ut.cat) end
  if uf.cat == "temp" then
    return temp_convert(value, from, to)
  end
  return value * uf.to / ut.to
end

return { convert = convert }
