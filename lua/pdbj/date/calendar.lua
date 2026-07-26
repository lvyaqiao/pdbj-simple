-- date/calendar.lua
-- 日历查询、中文日期格式化、翻译器入口
-- 依赖 astronomy, ganzhili, lunar

local A = require("pdbj/date/astronomy")
local G = require("pdbj/date/ganzhili")
local L = require("pdbj/date/lunar")

-- 可配置纪念日
local BIRTHDAY = { year = "2000", month = "10", day = "31" }
local VALENTINE = { year = "2021", month = "02", day = "14" }

local function CnDate_translator(y)
	 local t,cstr,t2
	 cstr = {"〇","一","二","三","四","五","六","七","八","九"}  t=""
	 for i =1,y.len(y) do
		  t2=cstr[tonumber(y.sub(y,i,i))+1]
		  if i==5 and t2 ~= "〇" then t2="年十" elseif i==5 and t2 == "〇" then t2="年"  end
		  if i==6 and t2 ~= "〇" then t2 =t2 .. "月" elseif i==6 and t2 == "〇" then t2="月"  end
		  --if t.sub(t,t.len(t)-1)=="年" then t2=t2 .. "月" end
		  if i==7 and tonumber(y.sub(y,7,7))>1 then t2= t2 .. "十" elseif i==7 and t2 == "〇" then t2="" elseif i==7 and tonumber(y.sub(y,7,7))==1 then t2="十" end
		  if i==8 and t2 ~= "〇" then t2 =t2 .. "日" elseif i==8 and t2 == "〇" then t2="日"  end
		  t=t .. t2
	end
		  return t
end



--日历查询
local function QueryLunarInfo(date)
	local str,LunarDate,LunarGz,result,DateTime,Cweek
	date=tostring(date) result={}
	str = date:gsub("^(%u+)","")
	if string.match(str,"^(20)%d%d+$")~=nil or string.match(str,"^(19)%d%d+$")~=nil then
		if string.len(str)==4 then str=str..string.sub(os.date("%m%d%H"),1) elseif string.len(str)==5 then str=str..string.sub(os.date("%m%d%H"),2) elseif string.len(str)==6 then str=str..string.sub(os.date("%m%d%H"),3) elseif string.len(str)==7 then str=str..string.sub(os.date("%m%d%H"),4)
		elseif string.len(str)==8 then str=str..string.sub(os.date("%m%d%H"),5) elseif string.len(str)==9 then str=str..string.sub(os.date("%m%d%H"),6) else str=string.sub(str,1,10) end
		if tonumber(string.sub(str,5,6))>12 or tonumber(string.sub(str,5,6))<1 or tonumber(string.sub(str,7,8))>31 or tonumber(string.sub(str,7,8))<1 or tonumber(string.sub(str,9,10))>24 then return result end
		LunarDate=L.Date2LunarDate(str)  LunarGz=G.lunarJzl(str)  DateTime=L.LunarDate2Date(str,0)
		dateRQ=string.sub(str,1,4).."年"..string.sub(str,5,6).."月"..string.sub(str,7,8).."日"
		Cweek=L.chinese_weekday(L.CXweek(string.sub(str,1,8)))--查询目标日期星期几
		Cweek2=string.sub(str,1,4).."年第"..L.CXweek2(string.sub(str,1,8)).."周 "--查询目标日期周数
		if LunarGz~=nil then
			result={
				{dateRQ,"〔数字⇉公历〕"}
				,{Cweek2..Cweek,"〔公历⇉星期〕"}
				,{LunarDate,"〔公历⇉农历〕"}
				,{LunarGz,"〔公历⇉干支〕"}
			}
			if tonumber(string.sub(str,7,8))<31 then
				table.insert(result,{DateTime,"〔农历⇉公历〕"})

				local glrq=L.LunarDate2Date(string.sub(str,1,8),0)--如果是闰月0改成1
				m=string.match(glrq,"年(.-)月")
				if #m==2 then
					glrq=string.gsub(glrq,"年","","1")
				else
					glrq=string.gsub(glrq,"年","0","1")
				end
					d=string.match(glrq,"月(.-)日") 
				if #d==2 then
					glrq=string.gsub(glrq,"月","","1")
				else
					glrq=string.gsub(glrq,"月","0","1")
				end
				glrq=string.gsub(glrq,"日","","1")
				glrq=glrq..string.sub(str,9,10)
				table.insert(result,{G.lunarJzl(glrq),"〔农历⇉干支〕"})

				local leapDate={L.LunarDate2Date(str,1),"〔农历".."（闰）".."⇉公历〕"}
				if string.match(leapDate[1],"^(%d+)")~=nil then
					table.insert(result,leapDate)

					local glrq=L.LunarDate2Date(string.sub(str,1,8),1)--如果是闰月0改成1
					m=string.match(glrq,"年(.-)月")
					if #m==2 then
						glrq=string.gsub(glrq,"年","","1")
					else
						glrq=string.gsub(glrq,"年","0","1")
					end
						d=string.match(glrq,"月(.-)日") 
					if #d==2 then
						glrq=string.gsub(glrq,"月","","1")
					else
						glrq=string.gsub(glrq,"月","0","1")
					end
					glrq=string.gsub(glrq,"日","","1")
					glrq=glrq..string.sub(str,9,10)
					table.insert(result,{G.lunarJzl(glrq),"〔农历".."（闰）".."⇉干支〕"})

				end
			end
		end
	end

	return result
end
--[[ ---------------测试----------------
local n=QueryLunarInfo(199105)
for i=1,#n do
	print(n[i][1]..n[i][2])
end
--]] ----------------------------------

--农历倒计时
local function nl_shengri(y,m,d)
    nlsrsj=y..m..d--农历时间
    date1=os.date("%Y%m%d")
    date2=L.LunarDate2Date(nlsrsj,0)--如果是闰月0改1
    m=string.match(date2,"年(.-)月")
    if #m==2 then
    date2=string.gsub(date2,"年","","1")
    else
    date2=string.gsub(date2,"年","0","1")
    end
    d=string.match(date2,"月(.-)日") 
    if #d==2 then
    date2=string.gsub(date2,"月","","1")
    else
    date2=string.gsub(date2,"月","0","1")
    end
    date2=string.gsub(date2,"日","","1")
    result=L.diffDate(date1,date2)
    return result
end

local function nl_shengri2(y,m,d)
  while nl_shengri(y,m,d)== -1 do
    y=tonumber(y+1)
  end
    result=nl_shengri(y,m,d)
  return result
end
--农历倒计时结束


local function main_translator(input, seg)
--日期
  if (input == "vaZpdZ") then
    date = os.date("%Y-%m-%d")
    num_year=os.date("%j/")..L.IsLeap(os.date("%Y"))
    candidate = Candidate("date", seg.start, seg._end, date, num_year)
    yield(candidate)
    
    date = os.date("%Y年%m月%d日")
    candidate = Candidate("date", seg.start, seg._end, date, "")
    yield(candidate)
    
    date = CnDate_translator(os.date("%Y%m%d"))
    candidate = Candidate("date", seg.start, seg._end, date, "")
    yield(candidate)
    
    date = L.Date2LunarDate(os.date("%Y%m%d")) .. A.JQtest(os.date("%Y%m%d"))
    candidate = Candidate("date", seg.start, seg._end, date,"")
    yield(candidate)

  --时间
  elseif (input == "cfZdtZ") then
    time = string.gsub(os.date("%H:%M:%S"), "^0+", "")
    candidate = Candidate("time", seg.start, seg._end, time,"" )
    yield(candidate)

	date = os.date("%Y-%m-%d")
    time = string.gsub(os.date("%H:%M:%S"), "^0+", "")
    candidate = Candidate("date", seg.start, seg._end, date.." "..time, "")
    yield(candidate)

  --星期
  elseif (input == "fgZpdZ") then
    weekday = L.chinese_weekday(os.date("%w"))
    num_weekday = os.date("第%W周")
    candidate = Candidate("xiqy", seg.start, seg._end, weekday, num_weekday)
    yield(candidate)
    
    weekday = L.chinese_weekday2(os.date("%w"))
    candidate = Candidate("xiqy", seg.start, seg._end, weekday, num_weekday)
    yield(candidate)
    
    weekday = os.date("%a")
    candidate = Candidate("xiqy", seg.start, seg._end, weekday, num_weekday)
    yield(candidate)
    
    weekday = os.date("%A")
    candidate = Candidate("xiqy", seg.start, seg._end, weekday, num_weekday)
    yield(candidate)

--农历
  elseif (input == "XjZmaZ") then
    date = L.Date2LunarDate(os.date("%Y%m%d")) .. A.JQtest(os.date("%Y%m%d"))
    candidate = Candidate("date", seg.start, seg._end, date,"")
    yield(candidate)
    
    date = G.lunarJzl(os.date("%Y%m%d%H"))
    candidate = Candidate("date", seg.start, seg._end, date, " ")
    yield(candidate)
    
    date = L.Date2LunarDate(os.date("%Y%m%d")) .. L.GetLunarSichen(os.date("%H"),1)
    candidate = Candidate("date", seg.start, seg._end, date,"")
    yield(candidate)

  --节气
  elseif (input == "diZpaZ") then
    local jqs=A.GetNowTimeJq(os.date("%Y%m%d"))--获取节气，从下个节气开始
    --当下个节气过远时(大于7天)，增加显示上个节气
    if tonumber(L.diffDate(os.date("%Y%m%d"),string.gsub(jqs[1]:sub(8,-1),"-",""))) >7 then
		a=string.gsub(jqs[1]:sub(8,-1),"-","")
		if a:sub(7,8) >"17" then
			a=a-17
		elseif a:sub(5,6) > "01" then
			a=a-100+13
		else
			a=a-10000+1100+13
		end
		a=tostring(a):sub(1,-3)
		jqs=A.GetNowTimeJq(a)
	end

    for i =1,#jqs do
		if i <= 2 then
			yield(Candidate("jwql", seg.start, seg._end, jqs[i], ""))
		end
--        yield(Candidate("jwql", seg.start, seg._end, string.sub(jqs[i],1,6), string.sub(jqs[i],7,-1)))
    end
  --日历查询
  elseif string.sub(input, 1, 1) == "=" then
  local n = string.sub(input, 2)
  if tonumber(n) ~= nil then
    if string.match(n,"^(20)%d%d+$")~=nil or string.match(n,"^(19)%d%d+$")~=nil then
      lunar=QueryLunarInfo(n)
      if #lunar>0 then
        for i=1,#lunar do
          yield(Candidate(input, seg.start, seg._end, lunar[i][1],lunar[i][2]))
        end
      end
    end
  end --if tonumber
  elseif (input == "sjx/") then
    --公历倒计时
    local sth_y = BIRTHDAY.year
    local sth_m = BIRTHDAY.month
    local sth_d = BIRTHDAY.day
--[[    --农历倒计时
    bb_y="1997" --农历生日——年
    bb_m="03"  --农历生日——月
    bb_d="16"   --农历生日——日
]]
--    sjxsr="距离下次生日还有"..nl_shengri2(sth_y,sth_m,sth_d).."天"
    sjxsr="距离下次生日还有"..L.diffDate2(os.date("%Y%m%d"),sth_y..sth_m..sth_d).."天"
    candidate = Candidate("sjx/", seg.start, seg._end, sjxsr, "")
    yield(candidate)
    --公历倒计时
    local sth_y = VALENTINE.year
    local sth_m = VALENTINE.month
    local sth_d = VALENTINE.day
    djs="距离下次情人节还有"..L.diffDate2(os.date("%Y%m%d"),sth_y..sth_m..sth_d).."天"
    candidate = Candidate("sjx/", seg.start, seg._end, djs, "")
    yield(candidate)
    --农历倒计时
    bb_y="2021" --农历生日——年
    bb_m="07"  --农历生日——月
    bb_d="07"   --农历生日——日
    djs="距离下次七夕节还有"..nl_shengri2(bb_y,bb_m,bb_d).."天"
    candidate = Candidate("sjx/", seg.start, seg._end, djs, "")
    yield(candidate)
  end  --if
end --function

return main_translator
