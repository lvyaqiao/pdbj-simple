-- date/ganzhili.lua
-- 干支历类：年月日时干支、生肖计算
-- 依赖 astronomy: getYearJQ

local A = require("pdbj/date/astronomy")

--天干
local tiangan = {"甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"}
--地支
local dizhi = {"子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"}

--周期循环数
local function calR2(n, round)
  local x = math.floor(math.fmod(n, round))
  if x == 0 then x = round end
  return x
end

--根据六十甲子序号，返回六十甲子字符串,甲子从1开始
local function get60JiaZiStr(i)
  local gan = i % 10
  if gan == 0 then gan = 10 end
  local zhi = i % 12
  if zhi == 0 then zhi = 12 end
  return tiangan[gan] .. dizhi[zhi]
end

local GanZhiLi = {}

function GanZhiLi:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o:setTime(os.time())
  return o
end

function GanZhiLi:calRound(start, offset, round)
  if start > round or start <= 0 then return nil end
  offset = math.floor(math.fmod(start + offset, round))
  if offset >= 0 then
    if offset == 0 then offset = round end
    return offset
  else
    return round + offset
  end
end

function GanZhiLi:setTime(t)
  self.ttime = t
  self.tday = os.date("*t", t)
  self.jqs = A.getYearJQ(self.tday.year)
  self.ganZhiYearNum = self:calGanZhiYearNum()
  if self.ganZhiYearNum ~= self.tday.year then
    self.jqs = A.getYearJQ(self.ganZhiYearNum)
  end
  self.ganZhiMonNum = self:calGanZhiMonthNum()
  self.curJq = self:getCurJQ()
end

function GanZhiLi:getCurJQ()
  local x = 0
  if self.ttime < self.jqs[1] then return nil end
  for i = 1, 23 do
    if self.jqs[i] <= self.ttime and self.jqs[i + 1] > self.ttime then x = i break end
  end
  if x == 0 then x = 24 end
  return x
end

function GanZhiLi:calGanZhiYearNum()
  if self.ttime < self.jqs[1] then return self.tday.year - 1
  else return self.tday.year end
end

function GanZhiLi:calGanZhiMonthNum()
  if self.ttime < self.jqs[1] then return nil end
  local x = 0
  for i = 1, 23 do
    if self.jqs[i] <= self.ttime and self.jqs[i + 1] > self.ttime then x = i end
  end
  if x == 0 then x = 24 end
  return math.floor((x + 1) / 2)
end

function GanZhiLi:getYearGanZhi()
  local jiaziYear = 1984
  local yeardiff = self.ganZhiYearNum - jiaziYear
  return self:calRound(1, yeardiff, 60)
end

function GanZhiLi:getYearGan()
  return calR2(self:getYearGanZhi(), 10)
end

function GanZhiLi:getYearZhi()
  return calR2(self:getYearGanZhi(), 12)
end

function GanZhiLi:getMonGanZhi()
  local ck = { year = 2010, month = 2, day = 4, hour = 6, min = 42, sec = 0 }
  local x = os.time(ck)
  local ydiff = self.ganZhiYearNum - ck.year
  local mdiff = self.ganZhiMonNum - 1
  if ydiff >= 0 then
    mdiff = ydiff * 12 + mdiff
  else
    mdiff = (ydiff + 1) * 12 + mdiff - 12
  end
  return self:calRound(15, mdiff, 60)
end

function GanZhiLi:getMonGan()
  return calR2(self:getMonGanZhi(), 10)
end

function GanZhiLi:getMonZhi()
  return calR2(self:getMonGanZhi(), 12)
end

function GanZhiLi:getDayGanZhi()
  local DAYSEC = 24 * 3600
  local jiaziDayTime = os.time({ year = 2012, month = 8, day = 30, hour = 23, min = 0, sec = 0 })
  local daydiff = math.floor((self.ttime - jiaziDayTime) / DAYSEC)
  return self:calRound(1, daydiff, 60)
end

function GanZhiLi:getDayGan()
  return calR2(self:getDayGanZhi(), 10)
end

function GanZhiLi:getDayZhi()
  return calR2(self:getDayGanZhi(), 12)
end

function GanZhiLi:getHourGanZhi()
  local SHICHENSEC = 3600 * 2
  local jiaziShiTime = os.time({ year = 2012, month = 8, day = 30, hour = 23, min = 0, sec = 0 })
  local shiDiff = math.floor((self.ttime - jiaziShiTime) / SHICHENSEC)
  return self:calRound(1, shiDiff, 60)
end

function GanZhiLi:getShiGan()
  return calR2(self:getHourGanZhi(), 10)
end

function GanZhiLi:getShiZhi()
  return calR2(self:getHourGanZhi(), 12)
end

local function lunarJzl(y)
  y = tostring(y)
  local x = GanZhiLi:new()
  x:setTime(os.time({
    year = tonumber(y.sub(y, 1, 4)),
    month = tonumber(y.sub(y, 5, -5)),
    day = tonumber(y.sub(y, 7, -3)),
    hour = tonumber(y.sub(y, 9, -1)),
    min = 4, sec = 5
  }))
  local yidx = x:getYearGanZhi()
  local midx = x:getMonGanZhi()
  local didx = x:getDayGanZhi()
  local hidx = x:getHourGanZhi()
  return get60JiaZiStr(yidx) .. "年" .. get60JiaZiStr(midx) .. "月"
    .. get60JiaZiStr(didx) .. "日" .. get60JiaZiStr(hidx) .. "时"
end

return {
  GanZhiLi = GanZhiLi,
  lunarJzl = lunarJzl,
}
